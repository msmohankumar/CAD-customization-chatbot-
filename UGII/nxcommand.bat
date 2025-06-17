@echo off
rem ========================================================================= 
rem                                                                        
rem       Copyright (c) 2018 Siemens PLM Solutions.
rem            Unpublished - All rights reserved                      
rem                                                                          
rem ========================================================================= 
rem
rem Script Name:  NXCOMMAND.BAT
rem
rem This script is used to start up NX command prompt.
rem
rem ========================================================================= 
rem  
rem
setlocal

rem Make sure we are in script folder, cleans up UNC launches
pushd %~dp0

rem Back up to the parent folder, %UGII_BASE_DIR% location
pushd ..

rem Set the parent folder location to a variable
set base_dir=%cd%

rem Return to the script folder location
popd
 
rem Call ugiicmd.bat and keep command prompt open.
%SystemRoot%\System32\cmd.exe /k ""%base_dir%\ugii\ugiicmd.bat" "%base_dir%""

endlocal
@echo on




