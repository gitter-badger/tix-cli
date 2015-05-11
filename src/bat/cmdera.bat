@echo off
if "%~1"=="" set LOCAL_ROOT=%HOMEPATH%\local
call %LOCAL_ROOT%\config\variables.bat && set PATH=%LOCAL_PATH%;%PATH%
set CMDER_ROOT=%LOCAL_ROOT%\cmder

start %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe /icon "%CMDER_ROOT%\cmder.exe" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd /k "%CMDER_ROOT%\vendor\init.bat cd %CD% && %~1"