REM  Your Teamcenter Application folder (dos 8.3)
set IMAN_ROOT=c:\UGS\2005SR1
REM  Your Teamcenter Data folder (dos 8.3)
set IMAN_DATA=\\hsvnt0376\UGS\tcdata

cd /d %ugii_base_dir%\NXBIN
ugs_router.exe -ugm -passthrough %1
