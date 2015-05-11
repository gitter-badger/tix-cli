CLI Sources
===========

This document serves to describe the installation process flow for the command line interface.


Purpose
-------

Windows has some terrible design choices at its roots:

* Ugly File System
  * User AppData folder... what is this \Roaming, \Local, \LocalLow
  * Spaces commonly used in path names
  * Root of file system is a drive letter
  * Using '\' in paths instead of what every other OS (and URIs) use: '/'


* Registry - Apps cannot be portable because they are installed to the file system and registry, often leaving behind junk or not uninstalling properly.
  * Can't move applications on a machine
  * Confusion in where to configure applications
  * One wrong edit will leave computer broken

* Max file path - 260 characters
  * Windows has the shortest max path length and the longest (verbose) file system paths of modern operating systems


Git and many modern development tools do not run natively on Windows.  Instead they require a Linux-like shell be installed on the local machine to emulate running Linux processes.

Linux comes in many flavors with differing goals.  There are also multiple ports of it to Windows.


This project aims to allow a complete silent portable install and configuration of Linux development tools (shell, git, node.js) to the users home directory.  This should bypass a lot of issues that are caused by Windows UAC.

___

Paths
-----

* ~/
  * The users home directory (C:\\Users\\[Username]\\)
* ~/src
  * The directory that all source code is downloaded to in preparation for installation.  Future updates of tools will download updated source here in preparation for installation.
  * The [src](https://github.com/TixInc/tix-cli/tree/master/src) folder of this repository (master branch), is recursively walked and downloaded to the local machine.
* ~/src/bin
  * The directory that all binaries (.exe, .msi, .zip .7z, .tar.xz) packages are downloaded to.
* ~/local
  * The directory that the portable environment will be installed to.
  * Every component that gets installed here will be placed in a folder with a short name and no spaces (Windows file path limits...)
* ~/local/bin
  * Following installation to a subdirectory of ~/local, executables of those applications get hard links here.
  * This folder gets prepended to the path in the shell provided with this installation which will cause the tools here to take precedence over tools installed on the local system for that shell.


Scripts
-------

[**To download and install the platform, open Windows command prompt (Start > "cmd.exe" > [enter]) and run:**](cmd/download-install-src.cmd)
```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "If(Test-Path ~\tmp.ps1){rm ~\tmp.ps1};((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/tix-cli/master/src/ps1/download-src.ps1?$(Get-Random)'))|Out-File ~\tmp.ps1;~\tmp.ps1 -Install -CleanSource;rm ~\tmp.ps1"
```



This will kick off the following chain in this order:

* Download and execute powershell script: [src/ps1/download-src.ps1](https://raw.githubusercontent.com/TixInc/tix-cli/master/src/ps1/download-src.ps1)
  * Downloads all sources required for the installation to ~/src
  * Downloads all binaries required for the installation to ~/src/bin

* Executes ~/src/ps1/install-src.ps1
  * Expands all zip, 7z, and tar.xz archives in ~/src/bin and defined in ~/src/ps1/install-config.ps1 to ~/local directories
  * Hard link executables from the ~/local directories to ~/local/bin
  * Execute additional powershell scripts to configure shell
  * Execute shell scripts to configure linux environment



Other Cmd.exe Scripts
---------------------

[**Download updated sources to ~/src but do not install (same filenames will be skipped):**](cmd/download-src.cmd)
```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/tix-cli/master/src/ps1/download-src.ps1?$(Get-Random)'));"
```

[**Install the current ~/src configuration to ~/local:**](cmd/install-src.cmd)
```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -File ~\src\ps1\install-src.ps1
```

**Download and install to a custom directory (C:\\nix):**
```cmd
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "If(Test-Path ~\tmp.ps1){rm ~\tmp.ps1};((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TixInc/tix-cli/master/src/ps1/download-src.ps1?$(Get-Random)'))|Out-File ~\tmp.ps1;~\tmp.ps1 -RootPath C:\nix -Install -CleanSource;rm ~\tmp.ps1"
```

___

Links
-----

* [Better Windows Command Line from Scott Hanselman](http://www.hanselman.com/blog/MakingABetterSomewhatPrettierButDefinitelyMoreFunctionalWindowsCommandLine.aspx)
* [Was the Windows Registry a Good Idea?](http://blog.codinghorror.com/was-the-windows-registry-a-good-idea/)