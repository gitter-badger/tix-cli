param($RootPath=$HOME)
. $RootPath\src\ps1\install-config.ps1 -RootPath $RootPath

##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

If(Test-Path -Path $HOME\tmp.ps1) {
  Remove-Item $HOME\tmp.ps1
}


Function New-SymLinkBin($target) {
  New-HardLinkIn $local.bin $target
}

Filter Expand-ZipArchives {
  Expand-Zip $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Expand-7zArchives {
  Expand-7z $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Expand-TarXzArchives {
  Expand-TarXz $_.src $_.dest
  New-SymLinkBin $_.link
}

Filter Execute-Ps1Scripts {
  Execute-Ps1 $_.src
}

Filter Execute-ShScripts {
  Execute-Sh $_.src
}


Write-Host "--Installing zip archives--"
$installs.zip|Write-PipeTable -PassThru|Expand-ZipArchives

Write-Host "--Installing 7z archives--"
$installs.sevenZ|Write-PipeTable -PassThru|Expand-7zArchives

Write-Host "--Installing tar.xz archives--"
$installs.tarXz|Write-PipeTable -PassThru|Expand-TarXzArchives

Write-Host "--Executing ps1 scripts--"
$installs.ps1|Write-PipeTable -PassThru|Execute-Ps1Scripts

Write-Host "--Executing sh scripts--"
$installs.sh|Write-PipeTable -PassThru|Execute-ShScripts


 <#
  1:20
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
