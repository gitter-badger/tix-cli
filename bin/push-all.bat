set INSTALL_ROOT=%USERPROFILE%
pushd %INSTALL_ROOT%\tixinc\tix-cli-src
git add . && git commit -am "updates to tix-cli-src" && git push origin master
popd
