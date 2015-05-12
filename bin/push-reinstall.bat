@echo off
set INSTALL_ROOT=%USERPROFILE%
call %INSTALL_ROOT%\local\config\variables.bat
set PATH=%LOCAL_PATH%;%PATH%
call push-all.bat
call npm-publish.bat
rmdir /s /q %INSTALL_ROOT%\local
rmdir /s /q %INSTALL_ROOT%\src\bat
call ..\src\cmd\download-install-src.cmd
