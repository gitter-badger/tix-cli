@echo off
set INSTALL_ROOT=%USERPROFILE%
call %INSTALL_ROOT%\local\config\variables.bat
set PATH=%LOCAL_PATH%;%PATH%
call push-all.bat

pushd ..\
START /WAIT npm version patch
START /WAIT npm publish
START /WAIT git push origin master
popd

rmdir /s /q %INSTALL_ROOT%\local
rmdir /s /q %INSTALL_ROOT%\src\bat
call ..\src\cmd\download-install-src.cmd
