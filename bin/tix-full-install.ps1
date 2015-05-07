##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

$source = "$HOME\src"
$install = "$HOME\local"

$packages = @(
  @{
    title='7-Zip for Windows';
    type='download';
    url='http://www.7-zip.org/a/7z938-x64.msi';
    arguments="/qb ALLUSERS=2 MSIINSTALLPERUSER=1 INSTALLDIR=`"$install\7z`""
  },
  @{
    title='Python 2.7.9';
    type='download';
    url='https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi';
    arguments="/qb ALLUSERS=2 MSIINSTALLPERUSER=1 TARGETDIR=$install\python279 ADDLOCAL=ALL"
  },
  @{
    title='MSYS2Base 20150202 Linux Virtualization Layer';
    type='download';
    url='http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150202.tar.xz';
    destName='msys2';
    executeFile='msys2_shell.bat'
  },
  @{
    title='MSYS2 Synchronize and Update packages';
    type='download';
    url='https://raw.githubusercontent.com/TixInc/TixCli/master/bin/msys2-sync-update.sh'
  },
  @{
    title='MSYS2 Post Install';
    type='execute';
    path="$install\msys2\msys2_shell.bat";
  },
  @{
    title='Tix Post Install Script';
    type='download';
    url='https://raw.githubusercontent.com/TixInc/TixCli/master/bin/tix-full-post-install.sh';
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

function InstallTarXz($filePath, $destPath, $executePath)
{
    Write-Host "Installing $filePath to $destPath and executing $executePath"
    $arguments = "x $filePath -so | 7z x -aoa -si -ttar -o`"$destPath`""
    Write-Host "Installing tar.xz $filePath to $destPath with $arguments"
    Start-Process 7z -ArgumentList $arguments -Wait -PassThru
    Write-Host "Finished unzipping $destPath"
    Start-Process $executePath -Wait -PassThru
    Write-Host "Finished installing $executePath"
}

function InstallSh ($filePath)
{
    Write-Host "Executing script at $filePath"
    Start-Process $filePath -Wait -PassThru
    Write-Host "Finished executing script at $filePath"
}

function Install ($filePath, $arguments)
{
    Write-Host "Installing $filePath with $arguments"
    Start-Process $filePath -ArgumentList $arguments -Wait -PassThru
    Write-Host "Finished installing $filePath"
}

#Once we've downloaded all our files lets install them.
foreach ($package in $packages) {
    Write-Host 'Processing started...'
    $title = $package.title
    $type = $package.type
    Write-Host 'Processing ' + $title + ' as ' + $type
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
        $executeFile = $package.executeFile
        $destPath = "$install\$destName"
        $executePath = "$destPath\$executeFile"
        InstallTarXz $filePath $destPath $executePath
      }
      ElseIf($ext -eq '.sh')
      {
        InstallSh $filePath
      }
      Else
      {
        Install $filePath $package.arguments
      }
    }
    Else
    {
      $path = $package.path
      InstallSh $path
    }
}
