@echo off
rem ========================================================================= *
rem                                                                           *
rem       Copyright (c) 2005-2006 Unigraphics Solutions, Inc.
rem                  Unpublished - All rights reserved                        *
rem                                                                           *
rem ========================================================================= *
rem
rem File Name:  ICE.bat
rem 
rem ========================================================================= 
rem
rem This script will set the appropriate variables and then launch Knowledge
rem Fusion Interactive Class Editor.
rem
rem Input Parameters:
rem
rem     Optional parameter for UGII_BASE_DIR.
rem
rem
rem ========================================================================= 
rem  
rem
rem =========================================================================
rem
rem

REM This batch file will run Knowledge Fusion ICE in stand-alone mode
REM
REM This assumes that you have the following environment setup
REM 
REM 1) JDK1.7 and above
REM

REM To avoid double double quotes later, remove any quotes that 
REM are part of the environment variable now

if not "%~1" == "" (
   REM If first arg is a directory then reset the UGII_BASE_DIR
   if exist "%~1\ugii" set UGII_BASE_DIR=%~1
)
set UGII_BASE_DIR=%UGII_BASE_DIR:"=%

REM
REM  Check if UGII_BASE_DIR is installed.
REM
REM if EXIST %UGII_BASE_DIR% (
if not defined UGII_BASE_DIR (
   echo NX path could not be established.  UGII_BASE_DIR not set.
   goto ERROR_EXIT
) ELSE (
   echo NX path established. UGII_BASE_DIR=%UGII_BASE_DIR%
   echo.
   
REM
REM Check if UGII_BASE_DIR really points to a valid directory.
REM
  if NOT EXIST "%UGII_BASE_DIR%\nxbin" (
    echo UGII_BASE_DIR set to invalid NX install.
    goto ERROR_EXIT
  )
)

REM
REM Check for NX license server
REM
if not defined SPLM_LICENSE_SERVER (
  echo ERROR: SPLM_LICENSE_SERVER is not defined.
  echo        Current Setting: %SPLM_LICENSE_SERVER%
  echo        Check:  SPLM_LICENSE_SERVER=28000@<server>.
  goto ERROR_EXIT
)

REM Check if UGII_JAVA_HOME is defined in the UGII_ENV
if not defined UGII_JAVA_HOME (
@for /f "tokens=*" %%I in (' "%UGII_BASE_DIR%\nxbin\env_print" UGII_JAVA_HOME') do set UGII_JAVA_HOME=%%I
)

REM 
REM PR 647988  The 2nd new way to test for a valid UGII_JAVA_HOME.
REM this works if the variable has parenthesis in the string for 32 bit java
REM which otherwise screws up the if statements.
REM The for loop converts UGII_JAVA_HOME to the short name with no special characters
REM the other method with the "=% does not work if UGII_JAVA_HOME is undefined beccause the
REM string becomes =", which seems to screw things up just as much as parenthesis
REM JTEST is the file name converted to a short name that has no special characters.
REM

echo Testing for UGII_JAVA_HOME
FOR /F "delims=" %%I in ('echo %UGII_JAVA_HOME%') do set JHOME=%%~sI

REM if we can't determine java home then exit because we no longer have
REM an NX JRE to use due to licensing issues
if not "%JHOME%" == "" (
  if not exist "%JHOME%" (
     echo JAVA path could not be established using UGII_JAVA_HOME.
     echo MSGBOX "Java was not found using UGII_JAVA_HOME.",16,"ICE Launch Error" >%TEMP%\message.vbs
     call %TEMP%\message.vbs
     del %TEMP%\message.vbs /f /q
     goto ERROR_EXIT
     echo.
  ) else ( 
    echo Using UGII_JAVA_HOME for the location of Java
    echo.
    set JAVA_COMMAND="%JHOME%\bin\java"
    set JAVAW_COMMAND="%JHOME%\bin\javaw"
  )
) else (
  echo Unable to find a JAVA path, UGII_JAVA_HOME is undefined.
  echo MSGBOX "Unable to find a JAVA path, UGII_JAVA_HOME is undefined",16,"ICE Launch Error" >%TEMP%\message.vbs
  call %TEMP%\message.vbs
  del %TEMP%\message.vbs /f /q
  goto ERROR_EXIT
  echo.
)

%JAVA_COMMAND% -jar "%UGII_BASE_DIR%\nxbin\VerifyJava.jar" external "%UGII_JAVA_HOME%"

if errorlevel 1 (
  echo Java version is not supported
  echo MSGBOX "Java version is not supported",16,"ICE Launch Error" >%TEMP%\message.vbs
  call %TEMP%\message.vbs
  del %TEMP%\message.vbs /f /q
  goto ERROR_EXIT
) else (
  echo Java version is supported
)
echo.


set PATH=%FMS_HOME%\lib;%UGII_BASE_DIR%\nxbin;%PATH%

@echo Starting Knowledge Fusion ICE...
set JAVA_COMMAND_LINE=start /B "ICE" %JAVAW_COMMAND% -jar "%UGII_BASE_DIR%\nxbin\ICE.jar" -b

%JAVA_COMMAND_LINE% 
goto END

:ERROR_EXIT
@echo ERROR: Unable to launch Knowledge Fusion ICE.  
@ping 127.0.0.1 -n 7 -w 1000>null
@echo.         
:END
