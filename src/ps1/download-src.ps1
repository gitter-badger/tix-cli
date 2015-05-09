##################################################################
# Downloads basic Windows dependencies for TixInc applications.  #
#                                                                #
# Specify source to control the directory that will be used      #
# to download installation files and $packages to control whats  #
# downloaded.                                                    #
##################################################################

#Invoke-WebRequest [-Uri] <Uri> [-Body <Object> ] [-Certificate <X509Certificate> ] [-CertificateThumbprint <String> ] [-ContentType <String> ] [-Credential <PSCredential> ] [-DisableKeepAlive] [-Headers <IDictionary> ] [-InFile <String> ] [-InformationAction <System.Management.Automation.ActionPreference> {SilentlyContinue | Stop | Continue | Inquire | Ignore | Suspend} ] [-InformationVariable <System.String> ] [-MaximumRedirection <Int32> ] [-Method <WebRequestMethod> {Default | Get | Head | Post | Put | Delete | Trace | Options | Merge | Patch} ] [-OutFile <String> ] [-PassThru] [-Proxy <Uri> ] [-ProxyCredential <PSCredential> ] [-ProxyUseDefaultCredentials] [-SessionVariable <String> ] [-TimeoutSec <Int32> ] [-TransferEncoding <String> {chunked | compress | deflate | gzip | identity} ] [-UseBasicParsing] [-UseDefaultCredentials] [-UserAgent <String> ] [-WebSession <WebRequestSession> ] [ <CommonParameters>]

#$links = Invoke-WebRequest -Uri https://github.com/TixInc/tix-cli/tree/master/bin|Select -exp Links|Where{$_.class -eq "js-directory-link"}|Select -exp href

$baseUri = 'https://github.com'
$rawBaseUri = 'https://raw.githubusercontent.com/TixInc/tix-cli/master/src'
$srcUri = '/TixInc/tix-cli/tree/master/src'
$srcPath = "$HOME\src"
$fileFilter = '*.*'
$classFilter = 'js-directory-link'

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

$fileMaps=Scrape-Files-Recursive $srcUri $rawBaseUri $srcPath

Write-Host ($fileMaps | Format-List | Out-String)

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

$fileMaps|Download-Files