@echo off
rem ========================================================================= *
rem                                                                           *
rem       Copyright (c) 1996-2001 Unigraphics Solutions, Inc.
rem                  Unpublished - All rights reserved                        *
rem                                                                           *
rem ========================================================================= *
rem
rem File Name:  UGII.BAT
rem 
rem ========================================================================= 
rem
rem This script will set the appropriate variables and then run Unigraphics.
rem
rem Input Parameters:
rem
rem Command line parameters will be passed through to Unigraphics.  See
rem the UG Workstation Guide for information on supported parameters.
rem
rem NOTE: you MUST use a colon ':' to delimit a switch from its value.
rem 
rem       For example:
rem	  ugii -retrieve:block.prt
rem
rem ========================================================================= 
rem  
rem
rem Using a bat file to start up NX is not recommended.  This file is
rem legacy, and is left for customers that have depended on it.
rem If you need to set environment variables, you should customize them
rem in a ugii_env.dat file.
rem
setlocal
rem 
rem Set variables.
rem
rem UNIGRAPHICS requires the following PATH variable:
rem
set PATH=%UGII_BASE_DIR%\nxbin;%PATH%
rem
rem
start "Title" "%UGII_BASE_DIR%\\nxbin\\ugraf.exe" %*
if ERRORLEVEL 1 goto error_exit
goto normal_exit
:error_exit
pause
:normal_exit
endlocal
@echo on
