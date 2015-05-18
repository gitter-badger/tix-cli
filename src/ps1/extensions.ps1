param($INSTALL_ROOT=$HOME)
#################################################
# Reusable functions for powershell.            #
#################################################

$LOCAL_ROOT=Join-Path $INSTALL_ROOT local
$7ZA_PATH=Join-Path $LOCAL_ROOT '7z\7za.exe'
$LOCAL_BIN_ROOT=Join-Path $LOCAL_ROOT bin
$CMDER_PATH=Join-Path $LOCAL_BIN_ROOT cmder.cmd


Filter Write-PipeTable {
    Param( [switch]$PassThru )
    Write-Host ($_ | Format-Table | Out-String)
    If($PassThru) {
      Write-Output $_
    }
}

Filter Write-PipeList {
    Param( [switch]$PassThru )
    Write-Host ($_ | Format-List | Out-String)
    if($PassThru) {
      Write-Output $_
    }
}

Filter Ensure-Directory {
  Param( [switch]$PassThru )
  If(!(Test-Path -Path $_ -PathType Container)) {
    New-Item -Path $_ -type Directory | Out-Null
    If($PassThru) {
      Write-Output $_
    }
  }
}

Function Expand-Zip ($zipPath, $destDir) {
  $shell = New-Object -com shell.application
  $zip = $shell.Namespace($zipPath)

  $destDir|Ensure-Directory

  ForEach($item in $zip.items()) {
    $shell.Namespace($destDir).CopyHere($item, 0x10)
  }
}

Function Execute($filePath, $arguments)
{
    If($arguments) {
        Start-Process $filePath -ArgumentList $arguments -Wait -PassThru
    }
    Else {
        Start-Process $filePath -Wait -PassThru
    }
}

Function Execute-Sh($command) {
    Echo Executing:"$CMDER_PATH $command"
    Execute $CMDER_PATH $command
}

Function Execute-7z($arguments) {
    Write-Host "$7ZA_PATH $arguments"
    Execute $7ZA_PATH $arguments
}

Function Expand-7z($filePath, $destDir) {
  $destDir|Ensure-Directory
  Execute-7z "x -aoa -o$destDir $filePath"
}

Function Execute-Ps1($filePath) {
    Execute powershell.exe "-File=$filePath"
}

Function Install-Msi ($filePath, $arguments) {
    Execute msiexec.exe "/i $filePath $arguments"
}

Function New-HardLink ($link, $target) {
    Write-Host "Hard linking $target to $link"
    Invoke-Expression "cmd /c mklink /H $link $target"
}

Function New-HardLinkIn ($dir, $target) {
  $fileName = [System.IO.Path]::GetFileName($target)
  $dir|Ensure-Directory
  $link = Join-Path $dir $fileName
  New-HardLink $link $target
}

Function New-SymLink ($link, $target) {
    $baseCmd='cmd /c mklink'
    If (Test-Path -PathType Container $target) {
        $baseCmd+=' /d'
    }
    Write-Host "Symbolic linking $target to $link"
    Invoke-Expression "$baseCmd $link $target"
}

Function New-SymLinkIn ($dir, $target) {
  $fileName = [System.IO.Path]::GetFileName($target)
  $dir|Ensure-Directory
  $link = Join-Path $dir $fileName
  New-SymLink $link $target
}

Function Remove-Path ($path) {
    If (Test-Path $path) {
      Remove-Item $path
    }
}

# Downloads a file from url to directory
Function Download-File($url, $filePath) {
    If (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Downloading $url to $filePath"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile("$url", "$filePath")
    }
}

Filter Download-Files {
    Download-File $_.fileUrl $_.filePath
}

### This function currently is only useful for building a shortcut to cmder.exe, eventually will be more generic.
Function Create-Shortcut($fileDir, $fileName) {
  #$sa = new-object -c shell.application
  #$ns = $sa.namespace($fileDir)
  #$pn = parsename($fileName)
  #$pn.invokeverb('taskbarpin')

  $cmdName = 'cmder'
  $cmdPath=Join-Path $fileDir $fileName
  $iconPath = Join-Path $HOME local\cmder\vendor\msysgit\etc\git.ico
  Write-Host "adding shortcut at $cmdPath"
  $taskbarFolder = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\Taskbar\"
  $startMenuFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\"
  $desktopFolder = Join-Path $HOME Desktop
  $objShell = New-Object -ComObject WScript.Shell
  $objShortCut = $objShell.CreateShortcut("$startMenuFolder\$cmdName.lnk")
  $objShortCut.IconLocation = "$iconPath"
  $objShortCut.TargetPath = 'cmd'
  $objShortCut.Arguments="/c ""$cmdPath"""
  $objShortCut.Save()

  $desktopShortCut = $objShell.CreateShortcut("$desktopFolder\$cmdName.lnk")
  $desktopShortCut.IconLocation = "$iconPath"
  $desktopShortCut.TargetPath = 'cmd'
  $desktopShortCut.Arguments="/c ""$cmdPath"""
  $desktopShortCut.Save()
}

Write-Host '--extensions.ps1 sourced--'