@echo off
@echo "Running process_plmuri.bat..."
@echo %1

@if exist "%UGII_BASE_DIR%" goto :process_command

:process_command
@setlocal
@"%UGII_BASE_DIR%\nxbin\ugs_router.exe" -ug -passthrough -pllink=%1
@endlocal
