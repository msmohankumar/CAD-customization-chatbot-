REM #/HEAD LAUNCH_BATCHMESHER BAT CAETOPO
REM #/SYS WNT
@echo off
rem ========================================================================= *
rem                                                                           *
rem       COPYRIGHT 2018 SIEMENS PRODUCT LIFECYCLE MANAGEMENT SOFTWARE INC.
rem                  Unpublished - All rights reserved                        *
rem                                                                           *
rem ========================================================================= *
rem
rem File Name:  launch_batchmesher_v3.bat
rem 
rem ========================================================================= 
rem
rem This script will set the appropriate variables and then launch Unigraphics
rem batch mesher version 3.0 UI.
rem
rem Input Parameters:
rem
rem     None.
rem
rem
rem ========================================================================= 
rem  
rem
rem =========================================================================
rem
rem
@echo OFF
REM This assumes that you have the following environment setup
REM 
REM 1) JDK1.4.2_03 and above   
REM 
REM
REM The first argument passed is the UGII_BASE_DIR. So set it.
REM To avoid double double quotes later, remove any quotes that 
REM are part of the environment variable now
set base=%1

REM
REM  Check if UGII_BASE_DIR is installed.
REM
REM if EXIST %UGII_BASE_DIR% (
if not defined UGII_BASE_DIR (
   echo  UGNX path could not be established.  UGII_BASE_DIR not set.
   goto ERROR_EXIT
) ELSE (
   echo UGNX path established. UGII_BASE_DIR=%UGII_BASE_DIR%
REM
REM Check if UGII_BASE_DIR really points to a valid directory.
REM
if NOT EXIST "%UGII_BASE_DIR%\nxbin" (
    echo UGII_BASE_DIR set to invalid installation.
    goto ERROR_EXIT
)
)

 

REM
REM Check for UG license server
REM
if not defined SPLM_LICENSE_SERVER (
REM
rem
echo ERROR: SPLM_LICENSE_SERVER is not defined.
rem
goto ERROR_EXIT
)

REM
REM Check if the NX JAVA is present. If so, use it.
REM

if not defined UGII_JAVA_HOME (
@for /f "tokens=*" %%I in (' "%UGII_BASE_DIR%\nxbin\env_print" UGII_JAVA_HOME') do set UGII_JAVA_HOME=%%I
)

if defined UGII_JAVA_HOME (
    "%UGII_JAVA_HOME%\bin\java" -jar "%UGII_BASE_DIR%\nxbin\VerifyJava.jar" external "%UGII_JAVA_HOME%"
    set JAVA_COMMAND="%UGII_JAVA_HOME%\bin\java"
    set JAVA_DIRECTORY="%UGII_JAVA_HOME%"
) ELSE (
REM
REM Issue an error the we do not have java
REM

   echo  Appropriate JAVA version for nx could not be found.  
   echo  UGII_JAVA_HOME not set [Current value: UGII_JAVA_HOME=%UGII_JAVA_HOME%]
   echo  Please set UGII_JAVA_HOME path to the location where java 
   echo  is installed and retry.
   echo.
   goto ERROR_EXIT

)



echo.
echo Batch Mesher needs JAVA version 1.4.2_03 or above.
echo JAVA version being used :
%JAVA_COMMAND% -version
echo.

REM
REM Check if grid command variable that launches the grid processing
REM tool is defined; else set it to blank.
REM
if not defined  BATCHMESHER_GRID ( 
set BATCHMESHER_GRID=""
)

REM
REM Check if local ugnx_batchmesher_v3.exe location is specified.
REM ... and if path is set do check if the executable exists there.
REM (Full path is needed; .\aaaa\bbbb will not work)
REM
if not defined  LOCAL_UGNX_BATCHMESHER_EXE ( 
set UGNX_BATCHMESHER_EXE_PATH=""
)

if defined  LOCAL_UGNX_BATCHMESHER_EXE ( 
if NOT EXIST "%LOCAL_UGNX_BATCHMESHER_EXE%\ugnx_batchmesher_v3.exe" (
    goto ERROR_LOCAL_UGNX_BATCHMESHER_EXE_PATH 
)
set UGNX_BATCHMESHER_EXE_PATH=%LOCAL_UGNX_BATCHMESHER_EXE%
echo.
echo Local path specified for ugnx_batchmesher_v3.exe.
echo Will use ugnx_batchmesher_v3.exe from : "%UGNX_BATCHMESHER_EXE_PATH%"
echo.

)

REM
REM Check if local ugnx_cad2prt.exe location is specified.
REM ... and if path is set do check if the executable exists there.
REM (Full path is needed; .\aaaa\bbbb will not work)
REM
if not defined  LOCAL_UGNX_CAD2PRT_EXE ( 
set UGNX_CAD2PRT_EXE_PATH="%UGII_BASE_DIR%\nxbin"
)

if defined  LOCAL_UGNX_CAD2PRT_EXE ( 
if NOT EXIST "%LOCAL_UGNX_CAD2PRT_EXE%\ugnx_cad2prt.exe" (
    goto ERROR_LOCAL_UGNX_CAD2PRT_EXE_PATH 
)
set UGNX_CAD2PRT_EXE_PATH=%LOCAL_UGNX_CAD2PRT_EXE%
echo.
echo Local path specified for ugnx_cad2prt.exe.
echo Will use ugnx_cad2prt.exe from : "%UGNX_CAD2PRT_EXE_PATH%"
echo.
)

REM 

REM
REM Batch mesher application requires UGNX version 401 above.
REM It requires two executables ugnx_batchmesher_v3.exe and ugnx_cad2prt.exe.
REM Both should exist in %UGII_BASE_DIR%\nxbin
REM
if NOT EXIST "%UGII_BASE_DIR%\nxbin\ugnx_cad2prt.exe" (
    goto ERROR_UGVERSION 
)
if NOT EXIST "%UGII_BASE_DIR%\nxbin\ugnx_batchmesher_v3.exe" ( 
    goto ERROR_UGVERSION 
) 


REM
REM ******************************************
REM Launching the application using jar files.
REM ******************************************
REM
REM Check where the jar file exists
REM
if EXIST ".\batchmesher_ui_v3.jar" ( 
set BATCHMESH_JAR_PATH=.
) else ( 
if EXIST ".\out\java\jars\batchmesher_ui_v3.jar" (
set BATCHMESH_JAR_PATH=.\out\java\jars
) else (
set BATCHMESH_JAR_PATH=%UGII_BASE_DIR%\nxbin
)
)

if NOT EXIST "%BATCHMESH_JAR_PATH%\batchmesher_ui_v3.jar" (
@echo.
@echo ERROR: Unable to locate batchmesher_ui.jar.
@echo        Check the directory %BATCHMESH_JAR_PATH%.
@echo        Either UG installation path is incorrect OR installed UG version
@echo        does not support batch-mesher.
@echo.
@echo        Batch mesher needs UGNX version 401[or above].
@echo.
goto ERROR_EXIT
)

REM 
REM Finally ... launch batch mesher UI.
REM
@echo Launching Batchmesher UI ...
@echo.

REM =======================================================================
REM Launching the application using class files. (Class files were not put)
REM =======================================================================

rem =====================
rem Launch using jar file
rem =====================
if not defined UGII_CSHELP_DOCS (
@for /f "tokens=*" %%I in (' "%UGII_BASE_DIR%\nxbin\env_print" UGII_CSHELP_DOCS') do set UGII_CSHELP_DOCS=%%I
)
set JAVA_COMMAND_LINE=%JAVA_COMMAND% -DBATCH_MESH_CSHELP_HTML_DOCS="%UGII_CSHELP_DOCS%/#goto:batchmesher:xid663923" -DGRID_SUBMIT=%BATCHMESHER_GRID% -DLOCAL_UGNX_BATCHMESHER_EXE_PATH=%UGNX_BATCHMESHER_EXE_PATH% -DLOCAL_UGNX_CAD2PRT_EXE_PATH=%UGNX_CAD2PRT_EXE_PATH% -classpath "%BATCHMESH_JAR_PATH%\batchmesher_ui_v3.jar" UGbatchmeshingControl.UGBatchMeshingControlClassV3



@echo %JAVA_COMMAND_LINE%
@echo.
%JAVA_COMMAND_LINE%

goto END

:ERROR_UGVERSION
@echo.
@echo ERROR: Unable to locate ugnx_cad2prt.exe and/or ugnx_batchmesher_v3.exe
@echo        in the UG installation directory.
@echo        (path: %UGII_BASE_DIR%) 
@echo        Either UG installation path is incorrect OR installed UG version
@echo        does not support batch-mesher.
@echo.
@echo        Batch mesher needs UGNX version 401(or above).
@echo.
goto ERROR_EXIT

:ERROR_LOCAL_UGNX_CAD2PRT_EXE_PATH
@echo.
@echo ERROR: Local executable environment variable is specified.
@echo        (LOCAL_UGNX_CAD2PRT_EXE is set to %LOCAL_UGNX_CAD2PRT_EXE%) 
@echo        Unable to locate ugnx_cad2prt.exe 
@echo.
@echo.
goto ERROR_EXIT

:ERROR_LOCAL_UGNX_BATCHMESHER_EXE_PATH
@echo.
@echo ERROR: Local executable environment variable is specified.
@echo        (LOCAL_UGNX_BATCHMESHER_EXE is set to %LOCAL_UGNX_BATCHMESHER_EXE%) 
@echo        Unable to locate ugnx_batchmesher_v3.exe.
@echo.
@echo.
goto ERROR_EXIT


:ERROR_EXIT
@echo ERROR: Unable to launch batch mesher UI.  
@echo.         
:END


