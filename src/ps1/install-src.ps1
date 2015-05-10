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
  Expand-Zip $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Install-7z {
  Expand-7z $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Install-TarXz {
  Expand-TarXz $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Run-Ps1 {
  Execute-Ps1 $_.src
}

Filter Run-Sh {

}


Write-Host "--Installing zip archives--"
$installs.zip|Write-PipeTable|Install-Zip

Write-Host "--Installing 7z archives--"
$installs.sevenZ|Write-PipeTable|Install-7z

Write-Host "--Installing tar.xz archives--"
$installs.tarXz|Write-PipeTable|Install-TarXz

Write-Host "--Executing ps1 scripts--"
$installs.ps1|Write-PipeTable|Run-Ps1

Write-Host "--Executing sh scripts--"
$installs.sh|Write-PipeTable|Run-Sh


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
