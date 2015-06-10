param($RootPath=$HOME)
###########################################################
# This file controls what will be installed where.        #
###########################################################

. $RootPath\src\ps1\extensions-path.ps1 -RootPath $RootPath

### Create installs hash table and add various installation definitions to it
$installs=@{}

### Defines zip files that need to be unzipped
$installs.Add('zip', @(
  @{
    title='7-Zip Command Line'
    src=Join-Path $src.bin 7za920.zip
    dest=Join-Path $base.local 7z
  }
))

### Defines 7z files that need to be unzipped
$installs.Add('sevenZ', @(
  @{
    title='Python Portable 2.7.6.1 Core'
    src=Join-Path $src.bin python_2761_core.7z
    dest=Join-Path $base.local python
  },
  @{
    title='cmder - Portable console emulator for windows'
    src=Join-Path $src.bin cmder.7z
    dest=Join-Path $base.local cmder
  }
))

### Copy Files ti bin and other directories.
$installs.Add('copy', @(
  @{
    title='cmder init file'
    src=Join-Path $src.cmd cmder.cmd
    dest=Join-Path $local.bin cmder.cmd
  },
  @{
    title='ConEmu.xml - configuration file for cmder'
    src=Join-Path $src.xml ConEmu.xml
    dest=Join-Path $base.local 'cmder\config\ConEmu.xml'
  }
))

### These folders will be added to the PATH environment variable.
$installs.Add('paths', @(
  @{
    path=Join-Path $base.local python\App
  }
))

### Adds shortcuts to desktop / start menu
$installs.Add('shortcut', @(
  @{
    dir=$local.bin
    name='cmder.cmd'
  }
))

### Hard links will be created in the local\bin folder for each of these paths which is sourced to the PATH environment variable.
$installs.Add('hardLinks', @(
  @{
    link=Join-Path $base.local 7z\7za.exe
  }
))

### Defines shell script files that need to be executed
$installs.Add('sh', @(
  @{
    title='NPM and tix-cli install'
    command="$RootPath\src\sh\install.sh"
  }
))

Write-Host '--install-config.ps1 sourced--'