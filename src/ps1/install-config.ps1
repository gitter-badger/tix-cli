param($RootPath=$HOME)
. $RootPath\src\ps1\extensions-path.ps1 -RootPath $RootPath

# Create installs hash table and add various installation definitions to it
$installs=@{}

# Defines zip files that need to be unzipped
$installs.Add('zip', @(
  @{
    title='7-Zip Command Line'
    src=Join-Path $src.bin 7za920.zip
    dest=Join-Path $base.local 7z
  }
))
# Defines 7z files that need to be unzipped
$installs.Add('sevenZ', @(
  @{
    title='Python Portable 2.7.6.1 Core'
    src=Join-Path $src.bin python_2761_core.7z
    dest=Join-Path $base.local python
    #link=Join-Path $base.local python\App\python.exe
  },
  @{
    title='cmder - Portable console emulator for windows'
    src=Join-Path $src.bin cmder.7z
    dest=Join-Path $base.local cmder
    #link=Join-Path $base.local cmder\Cmder.exe
  }
))
# Defines tar.xz files that need to be decompressed
$installs.Add('tarXz', @(
  @{
    title='msys2 Core Files (Arch Linux Emulation)'
    src=Join-Path $src.bin msys2-base.tar.xz
    dest=Join-Path $base.local msys2
    #link=Join-Path $base.local msys64\msys2_shell.cmd
    #addPath=Join-Path $base.local msys2\msys64
  }
))
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
  },
  @{
    title='node.exe - copy to bin'
    src=Join-Path $src.bin node.exe
    dest=Join-Path $local.bin node.exe
  }
))
$installs.Add('taskbar', @(
  @{
    dir=$local.bin
    name='cmder.cmd'
  }
))
$installs.Add('symLinks', @(
))
$installs.Add('hardLinks', @(
  @{
    link=Join-Path $base.local 7z\7za.exe
  }
))
# Defines shell script files that need to be executed
$installs.Add('sh', @(
  @{
    title='tix-cli && node full install'
    command="%USERPROFILE%\src\sh\post-install.sh && exit"
  }
))

$installs.Add('paths', @(
  @{
    path=Join-Path $base.local python\App
  }
))

Write-Host '--install-config.ps1 sourced--'