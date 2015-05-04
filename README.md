TixCli
======

TixCli is a [command line interface](http://en.wikipedia.org/wiki/Command-line_interface) to interact with GitHub Authorization API and perform setup and deployment of private TixInc repositories.


### Table of Contents

  * [Setup](#setup)
    * [Windows](#windows-setup)
    * [Linux / OSX](#linux-osx-setup)
    * [Any OS](#any-os-setup)
  * [Usage](#usage)


___


Setup <a id="setup"></a>
========================

* The TixCli and other TixInc applications require Git and Node.js on the local machine.  If the machine does not yet have these dependencies, jump to the OS specific section ([Windows](#windows-setup) or [Linux / OSX](linux-osx-setup)) and run the oneliner. You will be prompted to enter a username and password so that the TixCli can acquire a GitHub api token to use on your behalf.

* If the local machine already has Git and Node.js, jump to the [Any OS](#any-os-setup) section and run the oneliner in a shell.



#### Windows <a id="windows-setup"></a>


Copy/paste the oneliner below into Administrator command prompt to get Git / Node.js and TixCli installed:

``` cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/TixCli/master/powershell/tix-cli-dependencies.ps1'))
```


#### Linux / OSX <a id="linux-osx-setup"></a>

Instructions coming soon...


#### Any OS <a id="any-os-setup"></a>

If Git and Node.js are installed on the local machine, run this oneliner at git bash or linux shell to install the CLI:

``` sh
curl https://raw.githubusercontent.com/TixInc/TixCli/master/tix-cli.js > tix-cli.js && node tix-cli
```

___


Usage <a id="usage"></a>
========================

After running the setup steps above, you should eventually be prompted with a command prompt "TIX>" which means the CLI has been setup and is ready to use.  You can use the command "?" to list basic information about all the supported commands.

The CLI can be modified by changing the config object literal at the top of the tix-cli.js file.  The default uses this configuration:

```js
var config = {
  base: {
    windows: 'C:',
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
  'colors'
  ],
  flags: {
    cleanIfNotCliWorkingDir: true,
    promptToInstallDependencies: false
  }
};
```

The TixCli by default gets installed to `C:\TixInc\TixCli` directory on Windows and `~/TixInc/TixCli` on Linux / OSX.  Other TixInc applications will get installed by TixCli to the TixInc directory for the respective platform.


After the initial install, the CLI may be run again at any time by navigating your shell of choice to the TixCli directory and run `node tix-cli`.
