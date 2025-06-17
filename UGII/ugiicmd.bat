@echo off
rem
rem =========================================================================
rem                                                                       
rem       Copyright (c) 1996-2001 Unigraphics Solutions, Inc.
rem                  Unpublished - All rights reserved                     
rem                                                                         
rem =========================================================================
rem File Name:  UGIICMD.BAT
rem 
rem =========================================================================
rem
rem This script will set the path to enable use of Unigraphics and UGOPEN
rem
rem Inputs:
rem %1% - UG Install directory
rem %2% - Auto or blank
rem
rem =========================================================================
rem  
rem
set base=%1
set base_dir=%base:"=%
if "%base_dir:~-1%" == "\" set base_dir=%base_dir:~0,-1%
set UGII_BASE_DIR=%base_dir%
set PATH=%base_dir%\nxbin;%base_dir%\ugii;%PATH%
if exist "%base_dir%\ugopen\ufvars.bat" call "%base_dir%\ugopen\ufvars.bat" "%base_dir%"
if "%DISPLAY%" == "" set DISPLAY=LOCALPC:0.0
if "%2%" == "" goto end
if exist "%HOMEDRIVE%%HOMEPATH%" cd /d %HOMEDRIVE%%HOMEPATH%
if not exist "%HOMEDRIVE%%HOMEPATH%" cd /d %SystemDrive%\users\default
:end
@echo on
