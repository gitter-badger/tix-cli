ENABLEEXTENSIONS
if "%~1"=="" set %LOCAL_ROOT%=%HOMEPATH%\local

for /f "delims=" %%x in (%LOCAL_ROOT%\config\path.config) do (set "%%x")

if DEFINED LOCAL_PATH (set PATH=%LOCAL_PATH%;%PATH%) else (echo "No LOCAL_PATH defined")