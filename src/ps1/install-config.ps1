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
  <#
  @{
    title='cmder - Portable console emulator for windows'
    src=Join-Path $src.bin cmder_mini.7z
    dest=Join-Path $base.local cmder
    #link=Join-Path $base.local cmder\Cmder.exe
    addPath=Join-Path $base.local cmder
  }
  #>
))
# Defines tar.xz files that need to be decompressed
$installs.Add('tarXz', @(
  @{
    title='msys2 Core Files (Arch Linux Emulation)'
    src=Join-Path $src.bin msys2-base.tar.xz
    dest=Join-Path $base.local msys2
    #link=Join-Path $base.local msys64\msys2_shell.bat
    #addPath=Join-Path $base.local msys2\msys64
  }
))
$installs.Add('copy', @(
  @{
    title='cmder-batch file'
    src=Join-Path $src.bat cmder.bat
    dest=Join-Path $local.bin cmder.bat
  },
  @{
    title='source paths batch file'
    src=Join-Path $src.bat source-paths.bat
    dest=Join-Path $local.bin source-paths.bat
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
$installs.Add('symLinks', @(


))
$installs.Add('hardLinks', @(
  @{
    link=Join-Path $base.local 7z\7za.exe
  }
))
$installs.Add('bat', @(
              <#
  @{
     title='source paths script'
     filePath=Join-Path $local.bin source-paths.bat
  }
  #>
))
$installs.Add('ps1', @(
  <#
  @{
     title='msys2 init script'
     src=Join-Path $src.ps1 msys2-init.ps1
  }
  #>
))
# Defines shell script files that need to be executed
$installs.Add('sh', @(
  <#
  @{
    title='node.js src install'
    filePath=Join-Path $src.sh node-npm-src-install.sh
  },
  #>
))
$installs.Add('inlineSh', @(
  @{
    title='tix-cli && node full install'
    command="%USERPROFILE%\src\sh\install-node-tix-cli.sh"
  }
))




$installs.Add('paths', @(
  <#@{
    path=$local.bin
  },#>
  @{
    path=Join-Path $base.local python\App
  }<#,
  @{
    path=Join-Path $base.local cmder
  }
  #>
))

Write-Host '--install-config.ps1 sourced--'