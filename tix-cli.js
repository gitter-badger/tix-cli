'use strict';

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
  platform: getPlatform(),
  basePath: {
    windows: process.env['HOME'], //'c:',
    linux: process.env['HOME']
  },
  installPath: 'TixInc',
  path: {
    cliDir: 'TixCli',
    npmDir: 'npm',
    jsDir: 'TixInc.js',
    netDir: 'TixInc.Net',
    classicDir: 'TixInc.Classic',
    cliFile: 'tix-cli.js',
    tokenFile: '.token.json'
  },
  npmDependencies: [
    'minimist',
    'shelljs',
    'lodash',
    'colors',
    'read',
    'q',
    'ftp'
  ],
  flags: {
    cleanIfNotCliWorkingDir: true,
    promptToInstallDependencies: false
  }
};

var fs = require('fs');
var join = require('path').join;

//** Map install root to absolute path based at the platform specific base path. */
config.installRoot = join(getPlatformBase(), config.installPath);

function getPlatform() {
  var platform = require('os').platform();
  switch (platform) {
    case 'win32':
    case 'win64':
      return 'windows';
    case 'linux':
    case 'darwin':
    case 'osx':
      return 'linux';
    default:
      throw 'Unknown platform [' + platform + '], cannot set base path.';
  }
}

//** Gets the platform specific base path for current platform. */
function getPlatformBase() {
  switch (getPlatform()) {
    case 'windows':
      return config.basePath.windows;
    case 'linux':
      return config.basePath.linux;
    default:
      throw 'Unknown platform [' + platform + '], cannot set base path.';
  }
}


//** Gets the absolute install root path or a path relative to it if supplied. */
function toAbsPath(path) {
  return join(config.installRoot, path);
}

var templateImports = {
  'imports': {
    'toAbsPath': toAbsPath
  }
};

/** Get information about a path. */
function getPathStats(path) {
  return fs.lstatSync(path);
}

/** Find out if a directory exists at the given path. */
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
function CliBasic(config) {
  var that = this;
  var installRoot = config.installRoot;
  var cliDir = toAbsPath(config.path.cliDir);
  var cliPath = join(cliDir, config.path.cliFile);
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
    for (var i = 0; i < config.npmDependencies.length; i++) {
      returns.push(fn(config.npmDependencies[i]));
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
function CliAdvanced(config, token) {
  var that = this;
  var sh = require('shelljs');
  sh.config.silent = true;
  var _ = require('lodash');
  require('colors');

  var installRoot = config.installRoot;
  var cliDir = toAbsPath(config.path.cliDir);
  var automationPath = join(cliDir, 'automation');
  var tokenUrl = 'https://' + token + '@github.com';

  this.isExtendedMode = false;
  if (dirExists(automationPath)) {
    enableExtendedMode();
  }


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

  function fatal(message) {
    sh.echo('Error: ' + message);
    sh.exit(1);
  }

  function exec(command, error, isLoud) {
    var opts = {silent: !that.isVerbose};
    if (isLoud) {
      opts.silent = false;
    }
    if (sh.exec(command, opts).code !== 0) {
      if (error) {
        throw error;
      }
    }
  }

  function clone(githubPath, localPath) {
    var cloneUrl = tokenUrl + '/' + githubPath;
    var cmd = 'git clone ' + cloneUrl;
    if (localPath) {
      cmd += ' ' + localPath;
    }
    exec(cmd, 'An error occurred cloning from ' + cloneUrl + '.', true);
    log('Successfully cloned: ' + githubPath, 'clone');
  }

  function npmLink(path) {
    exec('npm link ' + path, 'An error occurred linking ' + path + '.', true);
    log('Successfully linked: ' + path, 'npmLink');
  }

  function npmInstall() {
    exec('npm install', 'An error occurred during npm install.', true);
    log('Successfully installed.', 'npmInstall');
  }


  /** Definitions for all commands supported by CliExtended interface. */
  this.commands = {
    "is-env-ready": {
      "desc": "Tests to see whether all required tools have been installed on this system.",
      "category": "utility"
    },
    "interactive": {
      "alias": "i",
      "desc": "Allows CLI to be run interactively even when commands have been passed on command line.",
      "category": "utility"
    },
    "verbose": {
      "alias": "v",
      "desc": "Enables verbose mode which prints underlying output from commands being executed.",
      "category": "utility"
    },
    "ls": {
      "desc": "Prints contents of install directory (<%= installRoot %>).",
      "category": "utility"
    },
    "clone-repo": {
      "desc": "Clones a GitHub repo to install directory or local path.",
      "category": "clone",
      "args": {
        "github-path": {
          "alias": "g",
          "desc": "The github path to the repo (e.g. https://github.com/[github-path].git)"
        },
        "local-path": {
          "alias": "p",
          "desc": "The local path relative to the working directory.",
          "nullable": true
        },
        "working-dir": {
          "alias": "d",
          "desc": "The current working directory relative to install root to execute from.",
          "default": "<%= installRoot %>"
        }
      }
    },
    "clone-npm": {
      "desc": "Clones the TixInc npm modules recursively to <% toAbsPath(path.npmDir) %>.",
      "category": "clone"
    },
    "clone-config": {
      "desc": "Clones the TixInc npm config module to <%= installRoot %>.",
      "category": "clone"
    },
    "clone-automation": {
      "desc": "Clones the TixInc npm automation module to <%= installRoot %>.",
      "category": "clone"
    },
    "clone-ext": {
      "desc": "Clones the TixInc npm ext module to <%= installRoot %>.",
      "category": "clone"
    },
    "clone-js": {
      "desc": "Clones the TixInc.js module (node.js host and angular app) to <% toAbsPath('TixInc.js') %>.",
      "category": "clone"
    },
    "clone-net": {
      "desc": "Clones the TixInc.Net module (web apis and other modern .NET libraries) to <% toAbsPath('TixInc.Net') %>.",
      "category": "clone"
    },
    "clone-classic": {
      "desc": "Clones the TixInc.Classic module (classic asp and web forms projects) to <% toAbsPath('TixInc.Classic') %>.",
      "category": "clone"
    },
    "clone-node": {
      "desc": "Clones all TixInc modern node libraries (npm and TixInc.js) into <%= installRoot %>.",
      "category": "clone"
    },
    "clone-modern": {
      "desc": "Clones all TixInc modern libraries (npm, TixInc.js, and TixInc.Net) into <%= installRoot %>.",
      "category": "clone"
    },
    "clone-cli-src": {
      "desc": "Clones the TixCli source code to <% toAbsPath('TixCliSrc') %>.",
      "category": "clone"
    },
    "acpush-repo": {
      "desc": "Git add and commit a repository in the install directory.",
      "category": "acpush",
      "args": {
        "message": {
          "alias": "m",
          "desc": "A commit message to use."
        },
        "branch": {
          "alias": "b",
          "desc": "The branch to push to.",
          "default": "master"
        },
        "repo": {
          "alias": "r",
          "desc": "The repository to push."
        }
      }
    },
    "acpush-automation": {
      "desc": "Git adds, commits, and pushes automation module.",
      "category": "acpush"
    },
    "acpush-config": {
      "desc": "Git adds, commits, and pushes config module.",
      "category": "acpush"
    },
    "acpush-cli-src": {
      "desc": "Git adds, commits, and pushes TixCli source.",
      "category": "acpush"
    },
    "acpush-all": {
      "desc": "Git adds, commits, and pushes all cloned modules.",
      "category": "acpush",
      "args": {
        "acpush-commands": {
          "alias": "p",
          "desc": "Array of acpush-commands to run.",
          "default": ["acpush-automation", "acpush-config", "acpush-cli-src"]
        }
      }
    },
    "pull-repo": {
      "desc": "Git pulls a repository that has been cloned to the install directory.",
      "category": "pull",
      "args": {
        "repo": {
          "alias": "r",
          "desc": "The repo to pull."
        },
        "branch": {
          "alias": "b",
          "desc": "The branch to pull.",
          "default": "master"
        }
      }
    },
    "pull-automation": {
      "desc": "Git pulls automation module.",
      "category": "pull"
    },
    "pull-config": {
      "desc": "Git pulls config module.",
      "category": "pull"
    },
    "pull-cli-src": {
      "desc": "Git pulls TixCli source module.",
      "category": "pull"
    },
    "pull-all": {
      "desc": "Git pulls all cloned modules.",
      "category": "pull",
      "args": {
        "pull-commands": {
          "alias": "c",
          "desc": "The array of pull commands to issue.",
          "default": ["pull-automation", "pull-config", "pull-cli-src"]
        }
      }
    },
    "npm-link": {
      "desc": "Links all of the TixInc npm modules to the specified module project for local development.",
      "category": "link",
      "args": {
        "module": {
          "alias": "m",
          "desc": "Module that npm link is running on."
        },
        "path": {
          "alias": "p",
          "desc": "Path to the module that is being linked."
        }
      }
    },
    "npm-link-modules": {
      "desc": "Links all the git npm submodules to the module (Defaults to TixInc.js).",
      "category": "link",
      "overrides": ["npm-link"],
      "args": {
        "module": {
          "alias": "m",
          "desc": "Module that npm link is running on.",
          "default": "TixInc.js"
        },
        "paths": {
          "alias": "p",
          "desc": "Paths that are being npm linked to.",
          "default": [
            "../npm/config",
            "../npm/automation",
            "../npm/ext",
            "../npm/client",
            "../npm/server"
          ]
        }
      }
    },
    "npm-install": {
      "desc": "Runs npm install on the specified module.",
      "category": "install",
      "args": {
        "module": {
          "alias": "m",
          "desc": "Module that npm install is running on.",
          "default": "TixInc.js"
        }
      }
    },
    "easy-setup": {
      "alias": "s",
      "desc": "Clones, links, and run tests on all modern repositories and runs tests to ensure they are working.",
      "category": "setup",
      "args": {
        "commands": {
          "alias": "c",
          "desc": "Array of commands to run for easy setup.",
          "default": ["clone-modern", "npm-link-modules", "npm-install"]
        }
      }
    },
    "debug": {
      "alias": "d",
      "desc": "Starts debugging TixInc.js module via gulp task.",
      "category": "execution",
      "args": {
        "module": {
          "alias": "m",
          "desc": "The module to debug.",
          "default": "TixInc.js"
        }
      }
    },
    "uninstall-extended": {
      "desc": "Uninstalls extended module.",
      "category": "utility"
    },
    "upgrade": {
      "desc": "Upgrades tix-cli to latest source control in master branches.",
      "category": "utility"
    },
    "extended-mode": {
      "alias": "x",
      "desc": "Installs additional TixInc dependencies to cli directory and allows running advanced commands.",
      "category": "utility",
      "args": {
        "clone-paths": {
          "alias": "c",
          "desc": "Array of GitHub repository paths to clone to cli directory.",
          "default": ["TixInc/config", "TixInc/automation", "TixInc/ext"]
        },
        "link-paths": {
          "alias": "l",
          "desc": "Array of paths to be linked to the TixCli module.",
          "default": ["./config", "./automation", "./ext"]
        }
      }
    },
    "print-process": {
      "desc": "Prints the node.js process variable for this environment.",
      "category": "utility",
      "args": {
        "node": {
          "alias": "n",
          "desc": "Prints information about a specific property or the process variable",
          "nullable": true
        }
      }
    },
    "?": {
      "alias": "h",
      "desc": "Prints information about the available commands.",
      "category": "utility"
    },
    "??": {
      "desc": "Prints information about extended commands.",
      "category": "utility"
    }
  };

  /** Amends each command (key) in object literal with a function. */
  function addFns(commandFns) {
    _.forEach(commandFns, function (fn, commandName) {
      addFn(commandName, fn);
    });
  }

  /** Amends the command definition with a function. */
  function addFn(commandName, fn) {
    var cmd = that.commands[commandName];
    if (cmd) {
      cmd.fn = fn;
    } else {
      var msg = _.template('ERROR: No command definition exists for <%= obj %>, ensure that it exists in [CliAdvanced.commands]');
      console.log(msg);
    }
  }

  /** Amends each command (key) in object literal with a function returning a promise (for async). */
  function addFnQs(commandFns) {
    _.forEach(commandFns, function (fn, commandName) {
      addFnQ(commandName, fn);
    });
  }

  /** Amends the command definition with a function returning a promise (for async). */
  function addFnQ(commandName, fn) {
    addFn(commandName, function (argv, args) {
      var deferred = Q.defer();
      fn(deferred, argv, args);
      return deferred.promise;
    });
  }

  /** The functions for each command definition. */
  var commandFns = {
    "is-env-ready": function () {
      if (!sh.which('git')) {
        fatal('TixInc applications require git installed and in your environment PATH.');
      }
      if (!sh.which('npm')) {
        fatal('TixInc applications requires npm installed and in your environment PATH.');
      }
      console.log('The environment is good to go!');
    },
    "interactive": function () {
      console.log('Running interactively...');
    },
    "verbose": function () {
      that.isVerbose = true;
      sh.config.silent = false;
    },
    "ls": function (argv, arg) {
      executeAt(installRoot, function () {
        if (arg) {
          exec('ls ' + arg, 'An error occurred during list directory.', true);
        } else {
          exec('ls', 'An error occurred during list directory.', true);
        }
      });
    },
    "clone-repo": function (argv) {
      var cwd = argv['working-dir'];
      var githubPath = argv['github-path'];
      var localPath = argv['local-path'];
      executeAt(cwd, function () {
        console.log('Cloning ' + githubPath + ' to ' + cwd + '.');
        clone(githubPath, localPath);
      });
    },
    "clone-config": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/config'
      });
    },
    "clone-automation": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/automation'
      });
    },
    "clone-ext": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/ext'
      });
    },
    "clone-js": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/TixInc.js'
      });
    },
    "clone-net": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/TixInc.Net'
      });
    },
    "clone-classic": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/TixInc.Classic'
      });
    },
    "clone-node": function () {
      that.execCommands(['clone-npm', 'clone-js']);
    },
    "clone-modern": function () {
      that.execCommands(['clone-npm', 'clone-js', 'clone-net']);
    },
    "clone-cli-src": function () {
      that.execCommand('clone-repo', {
        'github-path': 'TixInc/TixCli',
        'local-path': 'TixCliSrc'
      });
    },
    "clone-npm": function () {
      executeAt(installRoot, function () {
        // clone submodules...
        clone('TixInc/npm');
        executeAt('npm', function () {
          // Add token to git urls in file so we can clone them.
          sh.sed('-i', /https:\/\/github\.com/g, tokenUrl, '.gitmodules');
          exec('git submodule update --init --recursive', 'An error occurred recursively pulling submodule dependencies.');
          sh.sed('-i', /https:\/\/[\w\.]+@github\.com/g, 'https://github.com', '.gitmodules');
        });
      });
    },
    "acpush-repo": function (argv) {
      var message = argv.m || argv.message;
      var branch = argv.b || argv.branch || 'master';
      executeAt(toAbsPath(argv.repo), function () {
        console.log('On repository: ' + argv.repo);
        var commands = [
          'git add .',
          'git commit -am ' + message,
          'git push origin ' + branch
        ];
        _.forEach(commands, function (cmd) {
          console.log(cmd);
          exec(cmd, 'An error occurred during the add / commit / push operation.', true);
        });
      });
    },
    "acpush-automation": function (argv) {
      argv.repo = 'automation';
      that.execCommand('acpush-repo', argv);
    },
    "acpush-config": function (argv) {
      argv.repo = 'config';
      that.execCommand('acpush-repo', argv);
    },
    "acpush-cli-src": function (argv) {
      argv.repo = 'TixCliSrc';
      that.execCommand('acpush-repo', argv);
      executeAt(toAbsPath(argv.repo), function () {
        exec('npm version patch', 'Error patching version.', true);
        exec('npm publish', 'Error publishing.', true);
        exec('git push origin master');
      });
    },
    "acpush-all": function (argv) {
      that.execCommands(argv['acpush-commands'], argv);
    },
    "pull-repo": function (argv) {
      executeAt(toAbsPath(argv.repo), function () {
        console.log('Pulling repository ' + argv.repo + ' from branch ' + argv.branch + '.');
        exec('git pull origin ' + argv.branch);
      });
    },
    "pull-automation": function (argv) {
      that.execCommand('pull-repo', {
        'repo': 'automation',
        'branch': argv.branch
      });
    },
    "pull-config": function (argv) {
      that.execCommand('pull-repo', {
        'repo': 'config',
        'branch': argv.branch
      });
    },
    "pull-cli-src": function (argv) {
      argv.repo = 'TixCliSrc';
      that.execCommand('pull-repo', {
        'repo': 'TixCliSrc',
        'branch': argv.branch
      });
    },
    "pull-all": function (argv) {
      that.execCommands(argv['pull-commands'], argv);
    },
    "npm-link": function (argv) {
      executeAt(toAbsPath(argv.module), function () {
        npmLink(argv.path);
      });
    },
    "npm-link-modules": function (argv) {
      _.forEach(argv.paths, function (p) {
        that.execCommand('npm-link', {path: p, module: argv.module});
      });
    },
    "npm-install": function (argv) {
      executeAt(toAbsPath(argv.module), function () {
        npmInstall();
      });
    },
    "easy-setup": function (argv) {
      //bashConfig();
      //npmConfig();
      that.execCommands(argv.commands, argv);
    },
    "debug": function (argv) {
      executeAt(toAbsPath(argv.module), function () {
        //exec('npm install gulp -g', 'Error occurred installing gulp globally.', true);
        //exec('gulp debug', 'Error occurred during gulp debug.', true);
        exec('node bin/www');
      });
    },
    "uninstall-extended": function () {
      if (that.isExtendedMode) {
        var cliBasic = new CliBasic(config);
        executeAt(cliDir, function () {
          cliBasic.rmDir('automation');
          cliBasic.rmDir('config');
          cliBasic.rmDir('ext');
        });
        that.isExtendedMode = false;
      }
    },
    "upgrade": function () {
      that.execCommand("uninstall-extended");
      that.execCommand("extended-mode");
    },
    "extended-mode": function (argv) {
      if (that.isExtendedMode) {
        console.log('Already in extended mode.  To see extended mode commands, use "??".');
        return;
      }
      console.log('Installing extended mode...');
      console.log('Cloning additional dependencies...');
      var clonePaths = argv['clone-paths'];
      _.forEach(clonePaths, function (githubPath) {
        that.execCommand('clone-repo', {
          'github-path': githubPath,
          'working-dir': toAbsPath('TixCli')
        });
      });
      console.log('Linking dependencies...');
      var linkPaths = argv['link-paths'];
      that.execCommand('npm-link-modules', {
        paths: linkPaths,
        module: 'TixCli'
      });
      enableExtendedMode();
    },
    "print-process": function (argv) {
      if (argv.node) {
        console.dir(process[argv.node]);
      } else {
        console.dir(process);
      }
    },
    "?": function () {
      printCommands(that.commands);
    },
    "??": function () {
      if (that.isExtendedMode) {
        printCommands(that.extCommands);
      }
      else {
        console.log('Must be in extended mode to print these commands.');
      }
    }
  };

  addFns(commandFns);

  function enableExtendedMode() {
    var CliExtended = require('automation/cli');
    that.extCommands = (new CliExtended()).commands;
    that.isExtendedMode = true;
    that.printHeader();
  }

  function printCommands(commands) {
    var printCommand = _.template('<%= command %>:<%= alias %> <%= desc %>');
    _.forEach(commands, function (n, key) {
      var printObj = {
        command: key,
        desc: _.template(n.desc, templateImports)(config),
        alias: that.getAliasStr(key)
      };
      console.log(printCommand(printObj));
    });
  }

  this.getAliasStr = function (commandName) {
    var alias = that.getAlias(commandName);
    if (alias) {
      return '[alias: -' + alias + ']';
    }
    return _.noop();
  };

  this.getAlias = function (commandName) {
    var alias = getCommand(commandName).alias;
    return alias ? alias : _.noop();
  };

  /** Build alias object for quickly looking up a command by alias. */
  this.alias = _.chain(that.commands)
    .transform(function (result, n, commandName) {
                 if (n.alias) {
                   result[n.alias] = commandName;
                 }
               }).value();


  function getCommand(name) {
    var command = that.commands[name] || that.commands[that.alias[name]];
    if (!command) {
      if (that.isExtendedMode) {
        command = that.extCommands[name];
      }
    }
    if (command) {
      return command;
    }
    return false;
  }

  this.execCommands = function (names, argv, args) {
    _.forEach(names, function (name) {
      that.execCommand(name, argv, args);
    });
  };

  /** Executes a command by full name (e.g. "?") or alias (e.g. "-h"). */
  this.execCommand = function (name, argv, args) {
    var normalizeArgs = function (argDef, argName) {
      // If there is a default specified, set it if not set.
      if (argDef.default) {
        var def = _.isString(argDef.default) ? _.template(argDef.default, templateImports)(config) : argDef.default;
        argv[argName] = argv[argName] || def;
      } // Else, coalesce the value and its alias to the value or throw error if its not specified and not nullable.
      else {
        var argVal = argv[argName] || argv[argDef.alias];
        if (!argDef.nullable && !argVal) {
          var error = 'Command ' + name + ' requires parameter --' + argName;
          if (argDef.alias) {
            error += ' or -' + argDef.alias;
          }
          error += ' set.';
          throw error;
        }
        argv[argName] = argVal;
      }
    };

    try {
      var cmd = getCommand(name);
      if (cmd) {
        if (cmd.args) {
          _.forEach(cmd.args, normalizeArgs);
        }
        return cmd.fn(argv, args);
      }
      else {
        that.printUnknown();
      }
    }
    catch (err) {
      console.log(err);
      return false;
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
}

/**
 * CliBasicShell for CliShell dependency deployment.
 * @param config
 * @param args
 * @class
 */
function CliBasicShell(config, args) {

  var cliBasic = new CliBasic(config);
  var cliDir = toAbsPath(config.path.cliDir);

  // Clean up previous installation.
  if (__dirname !== cliDir && config.flags.cleanIfNotCliWorkingDir) {
    cliBasic.uninstall();
  }

  if (cliBasic.isInstalled()) {
    return startShell(config, args);
  }


  /** Installs basic dependencies and starts the CLI. */
  function installAndStartShell() {
    console.log('Installing to ' + cliDir + '...');
    cliBasic.install();
    startShell(config, args);
  }

  console.log('Basic dependencies must be installed to use tix-cli.  These will be installed to ' + cliDir);
  if (!config.flags.promptToInstallDependencies) {
    console.log('Skipping user confirmation per flag.');
    return installAndStartShell();
  }

  var rl = createInterface();
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
 * @param config
 * @param mainArgs
 * @class
 */
function CliShell(config, mainArgs) {
  var _ = require('lodash');
  var parseArgs = require('minimist');
  var mainArgv = parseArgs(mainArgs);

  var argCommands = _.omit(mainArgv, '_');
  var isInteractive = mainArgs.length === 0 || mainArgv.i || mainArgv.interactive;
  var cliDir = toAbsPath(config.path.cliDir);
  var tokenPath = toAbsPath(config.path.tokenFile);


  function init(token) {
    console.log('CliShell.init');
    var cli = new CliAdvanced(config, token);
    console.log('CliAdvanced');
    cli.printHeader();

    _.forEach(argCommands, function (argv, commandName) {
      if (argv === true) {
        execAndHandle(commandName);
      } else {
        execAndHandle(commandName, argv);
      }
    });

    if (!isInteractive) {
      return;
    }

    var rl = createInterface();
    prompt();
    rl.on('line', function (line) {
      var command = line.trim();

      var commandSplit = splitArgs(command);
      var commandName = commandSplit.length > 1 ? commandSplit[0].trim() : command;
      var arg = commandSplit.length > 1 ? commandSplit.slice(1) : _.noop();
      if (arg) {
        execAndHandle(commandName, parseArgs(arg), arg.join(' '));
      } else {
        execAndHandle(commandName);
      }
    }).on('close', function () {
      console.log('exit');
      if (__dirname !== cliDir) {
        console.log('You can delete the current file at ' + __filename + ' and run the CLI in the future from ' + cliDir + ' with "node tix-cli".');
      }
      console.log('Goodbye!');
      process.exit(0);
    });

    function execAndHandle(commandName, argv, arg) {
      if (rl && isInteractive) {
        rl.pause();
      }
      var result = argv ? cli.execCommand(commandName, argv, arg) : cli.execCommand(commandName, {});
      if (result && result.then) {
        result.then(function () {
          prompt();
        }, function (err) {
          console.log(err);
          prompt();
        });
      }
      else {
        prompt();
      }
    }

    /** Splits arguments ignoring quoted content. */
    function splitArgs(str) {
      return str.match(/(?:[^\s"]+|"[^"]*")+/g)
    }

    function prompt() {
      if (rl && isInteractive) {
        rl.setPrompt(cli.getPrompt());
        rl.prompt();
      }
    }
  }

  getToken(init);

  function getToken(callbackFn) {
    try {
      var tokenFile = require(tokenPath);

      callbackFn(tokenFile.access_token);
    }
    catch (e) {
      console.log('Token path: ' + tokenPath);
      console.log('Could not find token: ' + e);
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

/** Gets a readline (built-in) interface. */
function createInterface() {
  return require('readline').createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
  });
}

/** Ensures advanced CLI shell gets started in the cli directory so that npm dependencies will be loadable. */
function startShell(config, args) {
  var cliDir = toAbsPath(config.path.cliDir);
  var cliPath = join(cliDir, config.path.cliFile);

  if (cliPath === __filename) {
    console.log('Starting CLI shell...');
    new CliShell(config, args);
  }
  else {
    console.log('Starting CLI shell in CLI directory...');
    var cli = require(cliPath);
    new cli.CliShell(config, args);
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
  new CliBasicShell(config, process.argv.slice(2));
}
else {
  console.log('REQUIRE MODE');
}
