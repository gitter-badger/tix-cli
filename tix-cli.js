/**
 * TixInc CLI
 *
 * This script is an all-inclusive CLI for setup and deployment of TixInc applications.
 * So long as system dependencies are installed, this script will run on Windows, Linux and Mac.
 *
 * System Dependencies: Git, Node.js
 */

//** Modify these args to control how the cli works. */
var config = {
  base: {
    windows: 'c:',
    linux: process.env['HOME']
  },
  path: {
    installRoot: 'TixInc',
    cliDir: 'TixCli',
    npmDir: 'npm',
    jsDir: 'TixInc.js',
    netDir: 'TixInc.Net',
    classicDir: 'TixInc.Classic',
    cliFile: 'tix-cli.js',
    tokenFile: 'token.json'
  },
  npmDependencies: [
    'minimist',
    'shelljs',
    'lodash',
    'colors',
    'read'
  ],
  flags: {
    cleanIfNotCliWorkingDir: true,
    promptToInstallDependencies: false
  }
};


var fs = require('fs');
var join = require('path').join;

//** Gets the platform specific base path for current platform. */
function getPlatformBase() {
  var platform = require('os').platform();
  switch (platform) {
    case 'win32':
    case 'win64':
      return config.base.windows;
    case 'linux':
    case 'darwin':
    case 'osx':
      return config.base.linux;
    default:
      throw 'Unknown platform [' + platform + '], cannot set base path.';
  }
}

//** Remap install root to absolute path based at the platform specific base path. */
config.path.installRoot = join(getPlatformBase(), config.path.installRoot);

//** Gets the absolute install root path or a path relative to it if supplied. */
function getPath(path) {
  if (path) {
    return join(config.path.installRoot, path);
  }
  return config.path.installRoot;
}

function getPathStats(path) {
  return fs.lstatSync(path);
}

function dirExists(path) {
  try {
    return getPathStats(path).isDirectory();
  }
  catch (e) {
    return false;
  }
}

/**
 * CliBasic class.
 * This cli has no dependencies on any npm packages and is used to setup the bare dependencies in a cli folder to allow
 * other automation.
 * @class
 */
function CliBasic(args) {
  var that = this;
  var installRoot = getPath();
  var cliDir = getPath(args.path.cliDir);
  var cliPath = join(cliDir, args.path.cliFile);
  var packagePath = join(cliDir, 'package.json');

  function log(message, source) {
    var msg = 'CliBasic';
    if (source) {
      msg += '.' + source;
    }
    msg += ': ' + message;
    console.log(msg);
  }

  var getExecOpts = function () {
    return {encoding: 'utf8', stdio: 'inherit'}
  };

  var execSync = function (command, opts) {
    try {
      return require('child_process').execSync(command, opts || getExecOpts());
    }
    catch (e) {
      log(e, 'execSync');
    }
  };

  this.moduleExists = function (moduleName) {
    return dirExists(cliDir + '/node_modules/' + moduleName);
  };

  this.rmDir = function (path) {
    if (!dirExists(path)) {
      log(path + ' directory does not exist.  Skipping clean.', 'rmDir');
      return;
    }
    execSync('rm -rf ' + path);
  };

  this.rmSym = function (path) {
    log('Attempting to remove symlink at ' + path, 'rmSym');
    execSync('rm n ' + path);
  };

  this.mkAndChDir = function (path) {
    this.mkDir(path);
    this.chDir(path);
  };

  this.mkDir = function (path) {
    if (dirExists(path)) {
      log(path + ' directory already exists.  Skipping make.', 'mkDir');
      return;
    }
    execSync('mkdir ' + path);
  };

  this.chDir = function (path) {
    log('Changed directory to: ' + path, 'chDir');
    process.chdir(path);
  };


  function iterateNpmDependencies(fn) {
    var returns = [];
    for (var i = 0; i < args.npmDependencies.length; i++) {
      returns.push(fn(args.npmDependencies[i]));
    }
    return returns;
  }


  /** Copies this script into the CLI directory where it can be run from. */
  this.installCli = function () {
    try {
      fs.writeFileSync(cliPath, fs.readFileSync(__filename));
    }
    catch (e) {
      log(e, 'installCli');
    }
  };

  /** Installs package.json and npm dependencies to cli directory. */
  this.installNpm = function () {
    that.packageInit();
    iterateNpmDependencies(that.installNpmModule);
  };

  //** Sets up a package.json in cli directory so it can make use of require(). */
  this.packageInit = function () {
    var package_json = {
      "name": "tix-cli",
      "version": "1.0.0",
      "main": "tix-cli.js",
      "description": "This is a small temporary package setup on the fly to allow use of npm dependencies and require in TixInc CLI.",
      "private": "true"
    };
    fs.writeFileSync(packagePath, JSON.stringify(package_json, null, 4));
  };

  this.installNpmModule = function (moduleName) {
    execSync('npm install --save ' + moduleName);
  };

  /** Deletes the cli directory. */
  this.uninstall = function () {
    if (__dirname === cliDir) {
      console.log('Cannot uninstall, CLI is being executed from the CLI directory.')
    }
    else {
      console.log('Uninstalling previous installation of tix-cli at ' + cliDir);
      // Remove symbolic links
      //that.rmSym(join(cliDir + 'node_modules', 'ext'));
      //that.rmSym(join(cliDir + 'node_modules', 'automation'));
      //that.rmSym(join(cliDir + 'node_modules', 'config'));
      that.rmDir(cliDir);
    }
  };

  /** This method detects whether the cli basic dependencies have already been configured or not. */
  this.isInstalled = function () {
    var results = iterateNpmDependencies(that.moduleExists);
    for (var i = 0; i < results.length; i++) {
      if (!results[i]) {
        return false;
      }
    }
    return true;
  };

  /** This method orchestrates setting up basic dependencies, which allows use of CliAdvanced. */
  this.install = function () {
    // Setup folder structure
    that.mkDir(installRoot);
    that.mkAndChDir(cliDir);

    // Install dependencies
    that.installCli();
    that.installNpm();

    log('Dependencies installed.', 'install');
  }
}

/**
 * Functionality from this cli is dependent on dependencies installed in cli basic.  This cli should be run from the
 * cli directory.
 * @class
 */
function CliAdvanced(args, rlInterface) {
  var that = this;
  var rl = rlInterface;
  var sh = require('shelljs');
  var _ = require('lodash');
  require('colors');

  var cliDir = getPath(args.path.cliDir);
  var cliPath = join(cliDir, args.path.cliFile);
  var tokenPath = join(cliDir, args.path.tokenFile);
  var automationPath = join(cliDir, 'automation');
  var tokenUrl = null;
  this.init = function (callbackFn) {
    getToken(function (accessToken) {
      tokenUrl = 'https://' + accessToken + '@github.com';
      if (dirExists(automationPath)) {
        that.isExtendedMode = true;
      }
      callbackFn();
    });
  };


  var ascii = "                                                                           \r\n                                                          `.,:,,`          \r\n                                                  `::::::::::::::::::,     \r\n                                            ::::`          .::::::::::::   \r\n                                         .:,                 :::::::::::   \r\n                                       :`                     ::::::::::   \r\n                                     .                        ,:::::::::   \r\n                                                              :::::::::.   \r\n                                                              :::::::::    \r\n                                      --------:              .::::::::`    \r\n                       `@@@@@@@@      -------;               :::::::::     \r\n                       @@@@@@@@:                                           \r\n                       @@@@@@@@                                            \r\n                   #@@@@@@@@@@@@@@   @@@@@@@@   @@@@@@@#    @@@@@@@'       \r\n                   @@@@@@@@@@@@@@+  '@@@@@@@@    @@@@@@@: ;@@@@@@@         \r\n           +++        @@@@@@@@      @@@@@@@@      @@@@@@@@@@@@@@#    ,##'  \r\n          ''''+      #@@@@@@@'      @@@@@@@@      .@@@@@@@@@@@@`    :++++# \r\n         +''''''    .@@@@@@@@      @@@@@@@@         #@@@@@@@:       ++++++`\r\n         `'''''     @@@@@@@@      @@@@@@@@.       @@@@@@@@@@@       +++++# \r\n          :''+`    `@@@@@@@@      @@@@@@@@      ,@@@@@@@@@@@@@       #++#  \r\n                   `@@@@@@@@      @@@@@@@@'    @@@@@@@@'@@@@@@@            \r\n                    @@@@@@@@@#''' '@@@@@@@@@'@@@@@@@@:  @@@@@@@;           \r\n                      ...........   ................     .......           \r\n                                                                           \r\n                                                      ,,,,,,,,,            \r\n                                                  ::::::::::',             \r\n                   :`                        .::::::::::+:`                \r\n                   :,                     `::::::::::,+:`                  \r\n                  `:;`                 .::::::::::::',`                    \r\n                   :::`            `:::::::::::::+;.                       \r\n                   :::::,`   .::::::::::::::::'',`                         \r\n                    :::::::::::::::::::::::'':`                            \r\n                      `:::::::::::;+;:.`                                   \r\n                          `..,...`                                         \r\n                                                                           ";


  function log(message, source) {
    var msg = 'CliAdvanced';
    if (source) {
      msg += '.' + source;
    }
    msg += ': ' + message;
    console.log(msg);
  }

  function executeAt(path, fn, dieOnError) {
    sh.pushd(path);
    try {
      var result = fn();
      sh.popd();
      return result;
    }
    catch (e) {
      log(e, 'executeAt');
      sh.popd();
      if (dieOnError) {
        process.exit(1);
      }
    }
  }

  // TODO: FIX THIS ONE
  function npmDirs() {
    fs.readdir(getPath(args.path.npmDir + '\\'), function (err, files) {
      return files;
    });
  }

  function fatal(message) {
    sh.echo('Error: ' + message);
    sh.exit(1);
  }

  function exec(command, error) {
    if (sh.exec(command).code !== 0) {
      if (error) {
        throw error;
      }
    }
  }

  function clone(githubPath) {
    var cloneUrl = tokenUrl + '/' + githubPath;
    exec('git clone ' + cloneUrl, 'An error occurred cloning from ' + cloneUrl + '.');
    log('Successfully cloned: ' + githubPath, 'clone');
  }

  function npmLink(path) {
    exec('npm link ' + path, 'An error occurred linking ' + path + '.');
    log('Successfully linked: ' + path, 'npmLink');
  }

  this.isExtendedMode = false;

  this.commands = {
    'is-env-ready': {
      desc: 'Tests to see whether all required tools have been installed on this system.',
      fn: function () {
        if (!sh.which('git')) {
          fatal('TixInc applications require git installed and in your environment PATH.');
        }
        if (!sh.which('npm')) {
          fatal('TixInc applications requires npm installed and in your environment PATH.');
        }
        console.log('The environment is good to go!');
      }
    },
    'clone-npm': {
      desc: 'Clones the TixInc npm modules recursively to ' + getPath(args.path.npmDir) + '.',
      fn: function () {
        executeAt(getPath(), function () {
          // clone submodules...
          clone('TixInc/npm');

          executeAt('npm', function () {
            // Add token to git urls in file so we can clone them.
            // TODO: Remove the token from .gitmodules paths following the change.
            sh.sed('-i', /https:\/\/github\.com/g, tokenUrl, '.gitmodules');
            exec('git submodule update --init --recursive', 'An error occurred recursively pulling submodule dependencies.');
          });
        });
      }
    },
    'clone-config': {
      desc: 'Clones the TixInc npm config module to ' + getPath() + '.',
      fn: function () {
        executeAt(getPath(), function () {
          // clone config module
          clone('TixInc/config');
        });
      }
    },
    'clone-automation': {
      desc: 'Clones the TixInc npm automation module to ' + getPath() + '.',
      fn: function () {
        executeAt(getPath(), function () {
          // clone automation module
          clone('TixInc/automation');
        });
      }
    },
    'clone-ext': {
      desc: 'Clones the TixInc npm ext module to ' + getPath() + '.',
      fn: function () {
        executeAt(getPath(), function () {
          // clone ext module
          clone('TixInc/ext');
        });
      }
    },
    'clone-js': {
      desc: 'Clones the TixInc.js module (node.js host and angular app) to ' + getPath('TixInc.js') + '.',
      fn: function () {
        executeAt(getPath(), function () {
          clone('TixInc/TixInc.js');
        });
      }
    },
    'clone-net': {
      desc: 'Clones the TixInc.Net module (web apis and other modern .NET libraries) to ' + getPath('TixInc.Net') + '.',
      fn: function () {
        executeAt(getPath(), function () {
          clone('TixInc/TixInc.Net');
        });
      }
    },
    'clone-classic': {
      desc: 'Clones the TixInc.Classic module (classic asp and web forms projects) to ' + getPath('TixInc.Classic') + '.',
      fn: function () {
        executeAt(getPath(), function () {
          clone('TixInc/TixInc.Classic');
        });
      }
    },
    'clone-node': {
      desc: 'Clones all TixInc modern node libraries (npm and TixInc.js) into ' + getPath() + '.',
      fn: function () {
        that.execCommand('clone-npm');
        that.execCommand('clone-js');
      }
    },
    'clone-modern': {
      desc: 'Clones all TixInc modern libraries (npm, TixInc.js, and TixInc.Net) into ' + getPath() + '.',
      fn: function () {
        that.execCommand('clone-npm');
        that.execCommand('clone-js');
        that.execCommand('clone-net');
      }
    },
    'npm-link': {
      desc: 'Links all of the TixInc npm modules to the TixInc.js project for local development.',
      fn: function () {
        var dirs = npmDirs();
        console.dir(dirs);
        executeAt(getPath('TixInc.js'), function () {
          _.forEach(dirs, function (dir) {
            npmLink('../npm/' + dir);
          });
        });
      }
    },
    'easy-setup': {
      desc: 'Clones, links, and run tests on all modern repositories and runs tests to ensure they are working.',
      fn: function () {
        that.execCommand('clone-modern');
        that.execCommand('npm-link');
      }
    },
    'extended-mode': {
      alias: {short: 'x', long: 'extend'},
      desc: 'Installs additional TixInc dependencies to cli folder and allows running advanced commands.',
      fn: function () {
        if (that.isExtendedMode) {
          console.log('Already in extended mode.  To see extended mode commands, use "??".');
          return;
        }
        clone('TixInc/config');
        clone('TixInc/automation');
        clone('TixInc/ext');
        npmLink('./config');
        npmLink('./automation');
        npmLink('./ext');
        var CliExtended = require('automation/cli');
        that.extCommands = (new CliExtended()).commands;
        that.isExtendedMode = true;
        that.printHeader();
      }
    },
    '?': {
      alias: {short: 'h', long: 'help'},
      desc: 'Prints information about the available commands.',
      fn: function () {
        printCommands(that.commands);
      }
    },
    '??': {
      desc: 'Prints information about extended commands.',
      fn: function () {
        if (that.isExtendedMode) {
          printCommands(that.extCommands);
        }
        else {
          console.log('Must be in extended mode to print these commands.');
        }
      }
    }
  };

  function printCommands(commands) {
    var printCommand = _.template('<%= command %>:<%= alias %> <%= desc %>');
    _.forEach(commands, function (n, key) {
      var printObj = {
        command: key,
        desc: n.desc,
        alias: that.getAliasStr(key)
      };
      console.log(printCommand(printObj));
    });
  }

  this.getAliasStr = function (commandName) {
    var short = that.getShortAlias(commandName);
    var long = that.getLongAlias(commandName);
    if (short || long) {
      var str = '[';
      if (short) {
        str += short;
        if (long) {
          str += ',' + long;
        }
      }
      else {
        str += 'long';
      }
      str += ']';
      return str;
    }
    return _.noop();
  };

  this.getShortAlias = function (commandName) {
    var alias = getCommand(commandName).alias;
    return alias && alias.short ? '-' + alias.short : _.noop();
  };

  this.getLongAlias = function (commandName) {
    var alias = getCommand(commandName).alias;
    return alias && alias.long ? '--' + alias.long : _.noop();
  };

  /** Build alias object for quickly looking up a command by alias. */
  this.alias = _.chain(that.commands)
    .transform(function (result, n, commandName) {
      if (n.alias) {
        if (n.alias.short) {
          result['-' + n.alias.short] = commandName;
        }
        if (n.alias.long) {
          result['--' + n.alias.long] = commandName;
        }
      }
    }).value();


  function getCommand(name) {
    var command = that.commands[name];
    if (!command) {
      if (that.isExtendedMode) {
        command = that.extCommands[name];
      }
    }
    if (command) {
      return command;
    }
    if (_.startsWith(name, '-')) {
      return getCommand(that.alias[name]);
    }
    return false;
  }

  /** Executes a command by full name (e.g. "?"), short alias (e.g. "-h"), or long alias (e.g. "--help"). */
  this.execCommand = function (name) {
    var cmd = getCommand(name);
    if (cmd) {
      if(cmd.async) {
        rl.pause();
        cmd.fn(function() {
          rl.resume();
        });
      }
      else {
        cmd.fn();
      }
    }
    else {
      that.printUnknown();
    }
  };

  this.printUnknown = function () {
    console.log('You must supply a valid command.  For a list of commands use "?".');
  };

  this.printHeader = function () {
    if (that.isExtendedMode) {
      console.log(ascii.replace(/\+/g, '+'.blue).replace(/:/g, ':'.yellow).replace(/'/g, '\''.green).replace(/-/g, '-'.red));
      console.log('TixInc extended command line interface: Type "?" for a list of available commands or "??" for extended commands.');
    }
    else {
      console.log(ascii);
      console.log('TixInc command line interface: Type "?" for a list of available commands.');
    }
  };

  this.getPrompt = function () {
    if (that.isExtendedMode) {
      return 'TIX'.yellow + '>'.red;
    }
    return 'TIX>';
  };

  function getToken(callbackFn) {
    try {
      var tokenFile = require('./token');
      callbackFn(tokenFile.access_token);
    }
    catch (e) {
      var read = require('read');
      console.log('Your GitHub credentials are required to acquire a GitHub api token.  They will not be saved.');
      read({prompt: 'Please enter your GitHub username: '}, function (err, username) {
        read({prompt: 'Please enter your GitHub password: ', silent: true}, function (err, password) {
          installToken(username, password, callbackFn);
        });
      });
    }
  }

  function installToken(username, password, callbackFn) {
    var exec = require('child_process').exec;
    var clientId = 'eae2d821f84f1bb4ae6f';
    var clientSecret = 'a097eb9f9e497f03e63af8e775aeabb489246f99';

    var body = {
      "client_id": clientId,
      "client_secret": clientSecret,
      "scopes": [
        "repo"
      ],
      "note": "Repository access for TixInc CLI use."
    };
    var data = JSON.stringify(body).replace(/"/g, '\\"');
    var cmd = 'curl --user ' + username + ':' + password + ' -X POST -H "Content-Type: application/json" -d "' + data + '" https://api.github.com/authorizations';
    exec(cmd, function (err, stdout, stderr) {
      function printAndExit(error) {
        console.log(error);
        console.log('Exiting...');
        process.exit(1);
      }

      if (err) {
        printAndExit(err);
      }
      else if (stdout && stdout.indexOf('Problems parsing JSON') !== -1) {
        printAndExit(stdout);
      }

      var res = JSON.parse(stdout);
      var tokenJson = {
        "access_token": res.token
      };
      fs.writeFileSync(tokenPath, JSON.stringify(tokenJson, null, 4));
      callbackFn(res.token);
    });
  }
}

/**
 * CliBasicShell for CliShell dependency deployment.
 * @param args
 * @class
 */
function CliBasicShell(args) {
  var cliBasic = new CliBasic(args);

  var cliDir = getPath(args.path.cliDir);
  console.log('clidir: ' + cliDir);
  console.log('__dirname: ' + __dirname);

  // Clean up previous installation.
  if (__dirname !== cliDir && args.flags.cleanIfNotCliWorkingDir) {
    cliBasic.uninstall();
  }

  if (cliBasic.isInstalled()) {
    return startShell(args);
  }

  var rl = createInterface();

  /** Installs basic dependencies and starts the CLI. */
  function installAndStartShell() {
    console.log('Installing to ' + cliDir + '...');
    cliBasic.install();
    startShell(args);
  }

  console.log('Basic dependencies must be installed to use tix-cli.  These will be installed to ' + cliDir);
  if (!args.flags.promptToInstallDependencies) {
    console.log('Skipping user confirmation per flag.');
    return installAndStartShell();
  }

  rl.question('Would you like to install dependencies (Y/n)?: ', function (answer) {
    if (answer.match(/^y(es)?$/i)) {
      installAndStartShell();
    }
    else {
      console.log('Fine, be that way! :P');
      process.exit(0);
    }
  });
}


/**
 * CliShell for interactive deployment of TixInc apps at command line.
 * @param args
 * @class
 */
function CliShell(args) {
  var rl = createInterface();
  var cli = new CliAdvanced(args, rl);
  cli.init(function () {
    cli.printHeader();
    rl.setPrompt(cli.getPrompt());
    rl.prompt();

    function onExit() {
      var cliDir = getPath(args.path.cliDir);
      if (__dirname !== cliDir) {
        console.log('You can delete the current file at ' + __filename + ' and run the CLI in the future from ' + cliDir + ' with "node tix-cli".');
      }
      console.log('Goodbye!');
    }

    rl.on('line', function (line) {
      var command = line.trim();
      cli.execCommand(command);
      rl.setPrompt(cli.getPrompt());
      rl.prompt();
    })
      .on('close', function () {
        onExit();
        process.exit(0);
      });
  });


}

/** Gets a readline (built-in) interface. */
function createInterface() {
  return require('readline').createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
  });
}

/** Ensures advanced CLI shell gets started in the cli directory so that npm dependencies will be loadable. */
function startShell(args) {
  var cliDir = getPath(args.path.cliDir);
  var cliPath = join(cliDir, args.path.cliFile);

  if (cliPath === __filename) {
    console.log('Starting CLI shell...');
    new CliShell(args);
  }
  else {
    console.log('Starting CLI shell in CLI directory...');
    var cli = require(cliPath);
    new cli.CliShell(args);
  }
}

/**
 * Exports basic shell so it can be run from a CLI.
 * @type {CliBasicShell}
 */
exports.CliBasicShell = CliBasicShell;

/**
 * Exports shell so it can be run from a CLI.
 * @type {CliShell}
 */
exports.CliShell = CliShell;

/**
 * Exports CliBasic for functional use in node.js automation apps.
 * @type {CliBasic}
 */
exports.CliBasic = CliBasic;

/**
 * Exports CliAdvanced for functional use in node.js automation apps.
 * @type {CliAdvanced}
 */
exports.CliAdvanced = CliAdvanced;


if (require.main === module) {
  console.log('CLI MODE');
  // Called via a CLI so we should start the shell load process...
  new CliBasicShell(config);
}
else {
  console.log('REQUIRE MODE');
}
