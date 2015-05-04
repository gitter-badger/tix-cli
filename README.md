TixCli
======

Command line interface to interact with GitHub Authorization API and perform setup and deployment of private TixInc repositories.

___


Setup
-----

The TixCli and other TixInc applications require Git and Node.js on the local machine.  If the machine does not yet have these dependencies, jump to the OS specific section below and run the oneliner. Done =).

If the local machine already has Git and Node.js, jump to the "Any OS" section and run the oneliner in a shell.



### Windows


Copy/paste the oneliner below into Administrator command prompt to get Git / Node.js and TixCli installed:

`@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/TixCli/master/powershell/tix-cli-dependencies.ps1'))"`



### Linux / OSX

Instructions coming soon...


___


### Any OS

If Git and Node.js are installed on the local machine, run this oneliner at git bash or linux shell to install the CLI:

`curl https://raw.githubusercontent.com/TixInc/TixCli/master/tix-cli.js > tix-cli.js && node tix-cli`


