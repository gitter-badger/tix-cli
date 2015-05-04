TixCli
======

Command line interface to interact with GitHub Authorization API and perform setup and deployment of private TixInc repositories.


Windows
-------

To get all dependencies and CLI running on your local machine run the following oneliner in Administrator command prompt:


    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/TixCli/master/powershell/tix-cli-dependencies.ps1'))"


Any OS
------


If you already have Git and Node.js installed on the local machine, run the following oneliner at the git (or linux) shell to  install and run the CLI:


    curl https://raw.githubusercontent.com/TixInc/TixCli/master/tix-cli.js > tix-cli.js && node tix-cli
