@echo off
rem ========================================================================= *
rem                                                                           *
rem       Copyright (c) 1996-2001 Unigraphics Solutions, Inc.
rem                  Unpublished - All rights reserved                        *
rem                                                                           *
rem ========================================================================= *
rem  
rem
setlocal
rem
rem Set the Metalanguage file variable
rem
set UGII_08_FILE=%UGII_BASE_DIR%\ugopen\08.ugf

rem
rem Check for the usage of this script via the arg list
rem
if "%1"=="" goto :noargs
if %1==-r goto :run
if %1==-R goto :run
if %1==-c goto :comlink
if %1==-C goto :comlink
if %1==-l goto :comlink
if %1==-L goto :comlink
:noargs
rem
rem if arg1 is not equal to "c", "l" or "r" then error with usage info
echo.
echo Valid usage of grip batch on Windows NT is one of the following:
echo.
echo gripbatch {[-c] [-l]} [-e] [-dev:?] [-name:?] [-dir:?] [-list] filespec
echo gripbatch -r [-dev:?] [-name:?] [-dir:?] filespec ['string']
echo.
goto :end

rem
rem Invoke GCAL as requested in compile or link mode
rem
:comlink
@echo on
set PATH=%UGII_BASE_DIR%\ugopen;%UGII_BASE_DIR%\nxbin;%PATH%
start gcal.exe %1 %2 %3 %4 %5 %6 %7 %8 %9
@echo off
goto :end

rem
rem Invoke UG_IMAGE as requested in run mode
rem
:run
@echo on
set PATH=%UGII_BASE_DIR%\nxbin;%PATH%
start /B ugraf.exe %1 %2 %3 %4 %5 %6 %7 %8 %9
@echo off
:end
endlocal
