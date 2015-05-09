##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
##################################################################

$baseUri = 'https://github.com'
$rawBaseUri = 'https://raw.githubusercontent.com/TixInc/tix-cli/master/src'
$srcUri = '/TixInc/tix-cli/tree/master/src'
$srcPath = Join-Path $HOME src
$binPath = Join-Path $srcPath bin
$fileFilter = '*.*'
$classFilter = 'js-directory-link'

# Each of these get downloaded to bin path
$binFiles = @(
 @{
    Title='7-Zip Command Line';
    FileUrl='http://www.7-zip.org/a/7za920.zip';
    FilePath=(Join-Path $binPath 7za920.zip)
  },
  @{
    Title='Python 2.7.9';
    FileUrl='https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi';
    FilePath=(Join-Path $binPath python-2.7.9.msi)
  },
  @{
    Title='MSYS2Base 20150202 Linux Virtualization Layer';
    FileUrl='http://downloads.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20150202.tar.xz';
    FilePath=(Join-Path $binPath msys2-base-x86_64-20150202.tar.xz)
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
    $fileUrl = "$relativeUriOut/$($fileLink.innerText)"
    $filePath = Join-Path $relativePath $fileLink.innerText
    (New-Object PSObject -Property @{
      FileUrl=$fileUrl;
      FilePath= $filePath;
    })
  }
}

# Recursively scrape github raw repo for the FilePath FileUrl objects
$fileMaps=Scrape-Files-Recursive $srcUri $rawBaseUri $srcPath

Write-Host ($fileMaps | Format-List | Out-String)

# Takes a pipe of FileUrl FilePath, creates the directories, and downloads the file
Filter Download-Files
{
    $fileUrl = $_.FileUrl
    $filePath = $_.FilePath
    If (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Downloading $fileUrl to $filePath"
        $dir = Split-Path $filePath -Parent
        If(!(Test-Path -Path $dir -PathType Container)) {
          New-Item -Path $dir -type Directory
        }
        Invoke-WebRequest "$fileUrl" -OutFile "$filePath"
    }
}

#Download all github raw source files and binary files
$fileMaps|Download-Files
$binFiles|Download-Files