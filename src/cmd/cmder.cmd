@ECHO ON
SET LOCAL_ROOT=%USERPROFILE%\local
SET CMDER_ROOT=%LOCAL_ROOT%\cmder
CALL %LOCAL_ROOT%\config\variables.cmd

SET cmd_switch=/s /c
IF [%1]==[] GOTO RunNoParams

SET is_command=false
SET "arg_line="
:ShiftParams
IF "%1"=="" GOTO RunWithParams

IF /I "%1"=="/k" (
	ECHO Setting /k switch...
	SET cmd_switch=/s /k
	SHIFT
	GOTO ShiftParams
)

IF /I "%1"=="/x" (
	ECHO Setting /x switch-run as command
	SET is_command=true
	SHIFT
	GOTO ShiftParams
)

SET arg_line=%arg_line% %1
SHIFT
GOTO ShiftParams

:RunWithParams
ECHO Running with switches: %cmd_switch%

IF %is_command%==true GOTO RunWithCommand

START %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe /icon "%CMDER_ROOT%\vendor\msysgit\etc\git.ico" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd %cmd_switch% ""%CMDER_ROOT%\vendor\msysgit\bin\sh.exe" --login -i -- %arg_line%"

GOTO EndScript

:RunWithCommand

START %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe /icon "%CMDER_ROOT%\vendor\msysgit\etc\git.ico" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd %cmd_switch% ""%CMDER_ROOT%\vendor\msysgit\bin\sh.exe" --login -i -c %arg_line%"

GOTO EndScript


:RunNoParams

START %CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.exe /icon "%CMDER_ROOT%\vendor\msysgit\etc\git.ico" /title Cmder /loadcfgfile "%CMDER_ROOT%\config\ConEmu.xml" /cmd cmd /s /c ""%CMDER_ROOT%\vendor\msysgit\bin\sh.exe" --login -i"

:EndScript