@powershell -NoProfile -ExecutionPolicy unrestricted -Command "rm ~\src\* -recurse -exclude bin\*;cp ~\tixinc\tix-cli-src\src ~\ -recurse -PassThru;~\src\ps1\install-src.ps1"