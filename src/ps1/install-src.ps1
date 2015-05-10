##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

#$ErrorActionPreference="Stop"

# Source the extension script to get additional functions and install paths to get path objects
. ..\ps1\extensions.ps1
. ..\ps1\install-config.ps1


Function New-SymLinkBin($target) {
  New-HardLinkIn $local.bin $target
}

Filter Install-Zip {
  #Write-Host ($_ | Format-Table | Out-String)
  Expand-Zip $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Install-7z {
  #Write-Host ($_ | Format-Table | Out-String)
  Expand-7z $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Install-TarXz {


}

Write-Host "--Installing zip archives--"
$installs.zip|Write-PipeTable|Install-Zip

Write-Host "--Installing 7z archives--"
$installs.sevenZ|Write-PipeTable|Install-7z

Write-Host "--Installing tar.xz archives--"
$installs.tarXz|Write-PipeTable|Install-TarXz


#Once we've downloaded all our files lets install them.
ForEach ($package in $packages) {
    $title = $package.title
    $type = $package.type
    Write-Host "Processing $title as $type"
    If($type -eq 'download') {
      If ($ext -eq '.msi')
      {
        Install-Msi $filePath $package.arguments
      }
      ElseIf($ext -eq '.xz')
      {
        $execute = $package.execute
        $arguments = $package.arguments
        Install-Tar-Xz $filePath $execute $arguments
      }
      ElseIf($ext -eq '.zip')
      {
        Install-Zip $filePath
      }
      Else
      {
        If($package.execute)
        {
          If($package.arguments)
          {
            Execute-With-Args $package.execute $package.arguments
          }
          Else
          {
            Execute $package.execute
          }
        }
        Else {
          If($package.arguments)
          {
            Execute-With-Args $filePath $package.arguments
          }
          Else
          {
            Execute $filePath
          }
        }
      }
    }
    Else
    {
          If($package.arguments)
          {
            Execute-With-Args $package.path $package.arguments
          }
          Else
          {
            Execute $package.path
          }
    }
}


<#
$msys2Dir = "$install\msys64"
$msys2Path = "$msys2Dir\msys2_shell.bat"
#>

# Switch over to sym link in local bin path
#$env:Path += ";$7zDir;$pythonDir;$msys2Dir"

$packages = @(
 <# @{
    title='7-Zip for Windows';
    url='http://www.7-zip.org/a/7z938-x64.msi';
    arguments="/qb ALLUSERS=2 MSIINSTALLPERUSER=1 /norestart INSTALLDIR=`"$7zDir`""
  },
  @{
    title='7-Zip Command Line';
    url='http://www.7-zip.org/a/7za920.zip';
    destPath="$7zDir"
  },
  @{
    title='Python 2.7.9';
    url='https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi';
    arguments="/qb ALLUSERS=2 MSIINSTALLPERUSER=1 /norestart TARGETDIR=`"$pythonPath`""
  },
  @{
    title='MSYS2Base 20150202 Linux Virtualization Layer';
    url='http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150202.tar.xz';
    execute="$msys2Path";
    arguments="exit"
  },
  @{
    title='MSYS2 Synchronize and Update packages';
    url='$repo/bin/msys2-sync-update.sh?' + Get-Random;
    execute="$msys2Path";
    arguments="$source\msys2-sync-update.sh exit"
  },
  @{
    title='Tix Post Install Script';
    url='$repo/bin/tix-full-post-install.sh?' + Get-Random;
    execute="$msys2Path";
    arguments="$source\tix-full-post-install.sh exit"
  }
  #>
)


<#

If (!(Test-Path -Path $source -PathType Container))
{
  New-Item -Path $source -ItemType Directory | Out-Null
}

#>

