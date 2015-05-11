@echo on
set LOCAL_ROOT=%HOMEPATH%\local && set CMDER_ROOT=%LOCAL_ROOT%\cmder
call %LOCAL_ROOT%\config\variables.bat && set PATH=%LOCAL_PATH%;%PATH%

start %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe /icon "%CMDER_ROOT%\cmder.exe" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd /k "%CMDER_ROOT%\vendor\init.bat cd %CD%"