param($RootPath=$HOME)
. $RootPath\src\ps1\install-config.ps1 -RootPath $RootPath

##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

Function New-HardLinkBin($target) {
  New-HardLinkIn $local.bin $target
}

Function New-SymLinkBin($target) {
  New-SymLinkIn $local.bin $target
}

Filter Expand-ZipArchives {
  Expand-Zip $_.src $_.dest
}

Filter Expand-7zArchives {
  Expand-7z $_.src $_.dest
}

Filter Expand-TarXzArchives {
  Expand-TarXz $_.src $_.dest
}

Filter Add-Paths {
  Add-Path $_.path
}

Filter Copy-Files {
  If(Test-Path $_.dest) {
    rm $_.dest
  }
  Copy-Item $_.src $_.dest
}

Filter Add-Taskbar {
  Pin-Taskbar $_.dir $_.name
}

Filter Execute-BatScripts {
  Execute-Bat $_.filePath
}

Filter Source-BatScripts {
  Source-Bat $_.filePath
}

Filter Execute-Ps1Scripts {
  Execute-Ps1 $_.src
}

Filter Execute-ShScripts {
  Execute-Sh $_.filePath
}

Filter Execute-InlineShScripts {
  Execute-Sh $_.command
}

Filter Add-SymLinks {
  New-SymLinkBin $_.link
}

Filter Add-HardLinks {
  New-HardLinkBin $_.link
}


#Write-Host 'Writing .npmrc'
#"$HOME\.npmrc"

Write-Host "--Installing zip archives--"
$installs.zip|Write-PipeList -PassThru|Expand-ZipArchives

Write-Host "--Installing 7z archives--"
$installs.sevenZ|Write-PipeList -PassThru|Expand-7zArchives

Write-Host "--Installing tar.xz archives--"
$installs.tarXz|Write-PipeList -PassThru|Expand-TarXzArchives

Write-Host "--Adding to path--"
$installs.paths|Write-PipeList -PassThru|Add-Paths

$installs.taskbar|Write-PipeList -PassThru|Add-Taskbar

Write-Host "--Copying files--"
$installs.copy|Write-PipeList -PassThru|Copy-Files

Write-Host "--Adding symbolic links--"
$installs.symLinks|Write-PipeList -PassThru|Add-SymLinks

Write-Host "--Adding hard links--"
$installs.hardLinks|Write-PipeList -PassThru|Add-HardLinks

Write-Host "--Sourcing bat scripts--"
$installs.bat|Write-PipeList -PassThru|Execute-BatScripts

Write-Host "--Executing ps1 scripts--"
$installs.ps1|Write-PipeList -PassThru|Execute-Ps1Scripts

Write-Host "--Executing sh scripts--"
$installs.sh|Write-PipeList -PassThru|Execute-ShScripts

Write-Host "--Executing inline sh scripts--"
$installs.inlineSh|Write-PipeList -PassThru|Execute-InlineShScripts





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
