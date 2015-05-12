param($RootPath=$HOME, [switch]$Install, [switch]$CleanSource, [switch]$CleanLocal)
##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
##################################################################

# $RootPath is the directory to install src and local file systems to.
# $Install is a flag that can be set to kick off the installation when download is finished.

$baseUri = 'https://github.com'
$rawBaseUri = 'https://raw.githubusercontent.com/TixInc/tix-cli/master/src'
$srcUri = '/TixInc/tix-cli/tree/master/src'
$srcPath = Join-Path $RootPath src
$binPath = Join-Path $srcPath bin
$localPath = Join-Path $RootPath local

$fileFilter = '*.*'
$classFilter = 'js-directory-link'

If($CleanSource) {
  If (Test-Path $srcPath\cmd) {
    Remove-Item $srcPath\cmd -Recurse -Force
  }
  If (Test-Path $srcPath\ps1) {
    Remove-Item $srcPath\ps1 -Recurse -Force
  }
  If (Test-Path $srcPath\sh) {
    Remove-Item $srcPath\sh -Recurse -Force
  }
}

If($CleanLocal) {
  If(Test-Path $localPath) {
    Remove-Item $localPath -Recurse -Force
  }
}


# Each of these get downloaded to bin path
$binFiles = @(
 @{
    title='7-Zip Command Line'
    src='http://www.7-zip.org/a/7za920.zip'
    dest=Join-Path $binPath 7za920.zip
  },
  @{
    title='Python Portable 2.7.6.1 Core';
    src='https://s3-us-west-2.amazonaws.com/tixinc/python/python_2761_core.7z'
    dest=Join-Path $binPath python_2761_core.7z
  },
  @{
    title='cmder full - Portable console emulator for windows'
    src='https://s3-us-west-2.amazonaws.com/tixinc/cmder/cmder.7z'
    dest=Join-Path $binPath cmder.7z
  },
  <#
  @{
    title='cmder - Portable console emulator for windows'
    src='https://s3-us-west-2.amazonaws.com/tixinc/cmder/cmder_mini.7z'
    dest=Join-Path $binPath cmder_mini.7z
  },#>
  @{
    title='latest nodejs executable'
    src='http://nodejs.org/dist/latest/node.exe'
    dest=Join-Path $binPath node.exe
  },
  @{
    title='MSYS2Base 20150202 Linux Virtualization Layer'
    src='http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150202.tar.xz'
    dest=Join-Path $binPath msys2-base.tar.xz
  }
)

# Recursive powershell!!!
Function Scrape-Files-Recursive ($relativeUri, $relativeUriOut, $relativePath) {
  $links = Invoke-WebRequest -Uri "$baseUri$relativeUri" -TimeoutSec 20|Select -Exp Links|Where{$_.class -Eq "js-directory-link"}

  ForEach ($dirLink in $links|Where{$_.innerText -NotLike $fileFilter}) {
    # gets the url of the directory
    $dirUrl = $dirLink|Select -Exp href
    $relativePathComponent = $dirLink|Select -Exp innerText
    ForEach($component in $relativePathComponent) {
      $dirOutUrl = "$relativeUriOut/$component"
      # gets the path name and joins it to the current recursive relative path for the directory.
      $dirPath = Join-Path $relativePath $component
      Scrape-Files-Recursive $dirUrl $dirOutUrl $dirPath
    }
  }

  # Gets file urls and pipes them back up the chain
  $fileLinks = $links|Where{$_.innerText -Like $fileFilter}

  ForEach($fileLink in $fileLinks) {
    $src = "$relativeUriOut/$($fileLink.innerText)"
    $dest= Join-Path $relativePath $fileLink.innerText
    (New-Object PSObject -Property @{
      src="$src";
      dest=$dest;
    })
  }
}

# Recursively scrape github raw repo for the dest src objects
$fileMaps=Scrape-Files-Recursive $srcUri $rawBaseUri $srcPath

Write-Host ($fileMaps | Format-List | Out-String)

Filter Append-Random {
  $_.src += "?$(Get-Random)"
  $_
}

# Takes a pipe of src dest, creates the directories, and downloads the file
Filter Download-Files {
    $src = $_.src
    $dest= $_.dest
    If (!(Test-Path -Path $dest -PathType Leaf)) {
        Write-Host "Downloading $src to $dest"
        $dir = Split-Path $dest -Parent
        If(!(Test-Path -Path $dir -PathType Container)) {
          New-Item -Path $dir -type Directory
        }
        Invoke-WebRequest "$src" -OutFile "$dest"
    }
}

#Download all github raw source files and binary files
$fileMaps|Append-Random|Download-Files
$binFiles|Download-Files
Write-Host '--Download complete--'

If($Install) {
  Write-Host "--Installing in $RootPath--"
  . $RootPath\src\ps1\install-src.ps1 -RootPath $RootPath
}