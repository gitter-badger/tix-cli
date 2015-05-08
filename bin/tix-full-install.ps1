##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

$ErrorActionPreference = "Stop"

$source = "$HOME\src"
$install = "$HOME\local"

$repo = "https://raw.githubusercontent.com/TixInc/TixCli/master"

$7zDir = "$install\7z"
$7zPath = "$7zDir\7z.exe"
$pythonDir = "$install\python"
$pythonPath = "$pythonPath\python.exe"
$msys2Dir = "$install\msys64"
$msys2Path = "$msys2Dir\msys2_shell.bat"

# Switch over to sym link in local bin path
$env:Path += ";$7zDir;$pythonDir;$msys2Dir"

$packages = @(
  @{
    title='7-Zip for Windows';
    type='download';
    url='http://www.7-zip.org/a/7z938-x64.msi';
    arguments="/qb ALLUSERS=2 MSIINSTALLPERUSER=1 INSTALLDIR=`"$7zDir`""
  },
  @{
    title='Python 2.7.9';
    type='download';
    url='https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi';
    arguments="/qb ALLUSERS=2 MSIINSTALLPERUSER=1 TARGETDIR=`"$pythonPath`""
  },
  @{
    title='MSYS2Base 20150202 Linux Virtualization Layer';
    type='download';
    url='http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150202.tar.xz';
    execute="$msys2Path";
    arguments="exit"
  },
  @{
    title='MSYS2 Synchronize and Update packages';
    type='download';
    url='$repo/bin/msys2-sync-update.sh';
    execute="$msys2Path";
    arguments="$source\msys2-sync-update.sh exit"
  },
  @{
    title='Tix Post Install Script';
    type='download';
    url='$repo/bin/tix-full-post-install.sh';
    execute="$msys2Path";
    arguments="$source\tix-full-post-install.sh exit"
  }

  # old scripts
  <#
  @{
    title='Git For Windows 1.9.5';
    url='https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20150319/Git-1.9.5-preview20150319.exe';
    arguments='/SILENT /SUPPRESSMSGBOXES /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
  },
  @{
    title='Node.js 0.12.2';
    url='http://nodejs.org/dist/v0.12.2/x64/node-v0.12.2-x64.msi';
    arguments='/qr'
  },
  @{
     title='Node.js and NPM From Source';
     url='https://raw.githubusercontent.com/TixInc/TixCli/master/bin/node-npm-src-install.sh';
  },
  @{
    title='TixCli';
    url='https://raw.githubusercontent.com/TixInc/TixCli/master/bin/tix-cli-install.sh';
  }
  #>
)



If (!(Test-Path -Path $source -PathType Container)) {New-Item -Path $source -ItemType Directory | Out-Null}

Function New-SymLink ($link, $target)
{
    if (test-path -pathtype container $target)
    {
        $command = "cmd /c mklink /d"
    }
    else
    {
        $command = "cmd /c mklink"
    }

    invoke-expression "$command $link $target"
}

Function Remove-SymLink ($link)
{
    if (test-path -pathtype container $link)
    {
        $command = "cmd /c rmdir"
    }
    else
    {
        $command = "cmd /c del"
    }

    invoke-expression "$command $link"
}


# Downloads a file from url to directory
function DownloadFile
{
    param( [string]$url, [string]$filePath )

    If (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Downloading $url to $filePath"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile("$url", "$filePath")
    }
}

function InstallMsi ($filePath, $arguments)
{
    $command = "/i $filePath $arguments"
    Write-Host "Installing msi $filePath with $command"
    Start-Process msiexec.exe -ArgumentList $command -Wait -PassThru
    Write-Host "Finished installing $filePath"
}

## Decompresses, unzips, and installs the contents of a .tar.xz package.
function InstallTarXz($filePath, $execute, $arguments)
{
    # Decompress: x (Extract w/ full paths) -aoa (Overwrite files:no prompt)
    $argumentsXz = "x -aoa $filePath"
    Write-Host "Decompressing xz: $7zPath $argumentsXz"
    Start-Process $7zPath -ArgumentList $argumentsXz -Wait -PassThru
    Write-Host "Finished decompressing"

    # Unzip: x (Extract w/ full paths) -aoa (Overwrite files:no prompt) -ttar (tar file) -o (dest)
    $filePathTar = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $argumentsTar = "x -aoa -ttar -o$install $filePathTar"
    Write-Host "Unzipping tar: $7zPath $argumentsTar"
    Start-Process $7zPath -ArgumentList $argumentsTar -Wait -PassThru
    Write-Host "Finished unzipping"

    Write-Host "Installing: $execute $arguments"
    Start-Process $execute -ArgumentList $arguments -Wait -PassThru
    Write-Host "Finished installing"
}


function Install ($filePath, $arguments)
{
    Write-Host "Installing $filePath with $arguments"
    Start-Process $filePath -ArgumentList $arguments -Wait -PassThru
    Write-Host "Finished installing $filePath"
}

#Once we've downloaded all our files lets install them.
foreach ($package in $packages) {
    $title = $package.title
    $type = $package.type
    Write-Host "Processing $title as $type"
    If($type -eq 'download') {
      $url = $package.url
      $fileName = Split-Path $url -Leaf
      $filePath = Join-Path -Path $source -ChildPath $fileName
      DownloadFile -url $url -filePath $filePath
      $fileNameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
      $ext = [System.IO.Path]::GetExtension($fileName)
      Write-Host "Installing $filePath with extension $ext"
      If ($ext -eq '.msi')
      {
        InstallMsi $filePath $package.arguments
      }
      ElseIf($ext -eq '.xz')
      {
        $execute = $package.execute
        $arguments = $package.arguments
        InstallTarXz $filePath $execute $arguments
      }
      Else
      {
        If($package.execute) {
          $execute = $package.execute
          $arguments = $package.arguments
          Install $execute $arguments
        }
        Else {
          Install $filePath $package.arguments
        }
      }
    }
    Else
    {
      $path = $package.path
      $arguments = $package.arguments
      Install $path $arguments
    }
}
