param($RootPath=$HOME)
##################################################################
# Installs basic Windows dependencies for TixInc applications.   #
##################################################################

. $RootPath\src\ps1\install-config.ps1 -RootPath $RootPath
$CHOCOLATEY_PATH=Join-Path $base.local chocolatey

Filter Expand-ZipArchives {
  Expand-Zip $_.src $_.dest
}

Filter Expand-7zArchives {
  Expand-7z $_.src $_.dest
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

Filter Execute-ShScripts {
  Execute-Sh $_.command
}

$CHOCOLATEY_PATH|Ensure-Directory
[Environment]::SetEnvironmentVariable("ChocolateyInstall", "$CHOCOLATEY_PATH", "User")
$env:ChocolateyInstall="$CHOCOLATEY_PATH"
Write-Host "--Installing Chocolatey (https://chocolatey.org) Package Manager for Windows--"
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1

Write-Host "--Installing zip archives--"
$installs.zip|Write-PipeList -PassThru|Expand-ZipArchives

Write-Host "--Installing 7z archives--"
$installs.sevenZ|Write-PipeList -PassThru|Expand-7zArchives

Write-Host "--Adding to path (variables.cmd)--"
$installs.paths|Write-PipeList -PassThru|Add-Paths
Prepend-Path "LOCAL_PATH"

Write-Host "--Writing shortcuts--"
$installs.shortcut|Write-PipeList -PassThru|Add-Shortcut

Write-Host "--Copying files--"
$installs.copy|Write-PipeList -PassThru|Copy-Files

Write-Host "--Adding hard links--"
$installs.hardLinks|Write-PipeList -PassThru|Add-HardLinks

###Write-Host "--Executing sh scripts--"
###$installs.sh|Write-PipeList -PassThru|Execute-ShScripts

Write-Host "--Executing install.sh bash script and exiting--"
Execute-Sh "$RootPath\src\sh\install.sh"

exit
