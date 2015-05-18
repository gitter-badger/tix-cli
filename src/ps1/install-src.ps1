param($RootPath=$HOME)
##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

. $RootPath\src\ps1\install-config.ps1 -RootPath $RootPath

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

Filter Add-Shortcut {
  Create-Shortcut $_.dir $_.name
}

Filter Copy-Files {
  If(Test-Path $_.dest) {
    rm $_.dest
  }
  Copy-Item $_.src $_.dest
}

Function New-HardLinkBin($target) {
  New-HardLinkIn $local.bin $target
}

Filter Add-HardLinks {
  New-HardLinkBin $_.link
}

Filter Execute-Ps1Scripts {
  Execute-Ps1 $_.src
}

Filter Execute-ShScripts {
  Execute-Sh $_.filePath
}


Write-Host "--Installing zip archives--"
$installs.zip|Write-PipeList -PassThru|Expand-ZipArchives

Write-Host "--Installing 7z archives--"
$installs.sevenZ|Write-PipeList -PassThru|Expand-7zArchives

Write-Host "--Installing tar.xz archives--"
$installs.tarXz|Write-PipeList -PassThru|Expand-TarXzArchives

Write-Host "--Adding to path--"
$installs.paths|Write-PipeList -PassThru|Add-Paths

Write-Host "--Prepending the path--"
Prepend-Path "LOCAL_PATH"

Write-Host "--Writing shortcuts--"
$installs.shortcut|Write-PipeList -PassThru|Add-Shortcut

Write-Host "--Copying files--"
$installs.copy|Write-PipeList -PassThru|Copy-Files

Write-Host "--Adding hard links--"
$installs.hardLinks|Write-PipeList -PassThru|Add-HardLinks

Write-Host "--Executing ps1 scripts--"
$installs.ps1|Write-PipeList -PassThru|Execute-Ps1Scripts

Write-Host "--Executing sh scripts--"
$installs.sh|Write-PipeList -PassThru|Execute-ShScripts
