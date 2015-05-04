TixCli
======

Command line interface to interact with GitHub Authorization API and perform setup and deployment of private TixInc repositories.


Setup
-----

The TixCli and other TixInc applications require Git and Node.js on the local machine.  If the machine does not yet have these dependencies, jump to the OS specific section ([Windows] [windows]) and run the oneliner. Done =).

If the local machine already has Git and Node.js, jump to the "Any OS" section and run the oneliner at a shell.


[windows]: https://github.com/TixInc/TixCli "Windows"
#### Windows


To get all dependencies and CLI running on your local machine run the following oneliner in Administrator command prompt:


    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/TixCli/master/powershell/tix-cli-dependencies.ps1'))"



#### Linux / OSX

Instructions coming soon...



#### Any OS

If you already have Git and Node.js installed on the local machine, run the following oneliner at the git bash or linux shell to  install and run the CLI:


    curl https://raw.githubusercontent.com/TixInc/TixCli/master/tix-cli.js > tix-cli.js && node tix-cli


