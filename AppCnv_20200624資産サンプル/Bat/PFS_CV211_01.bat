echo off
rem =============================================
rem  �ߋ��f�[�^�폜
rem 
rem �y�����z
rem 
rem �y���l�z
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem Update
rem =============================================

rem ----------------------------------------
rem ��������
rem ----------------------------------------
call %~dp0"..\Common\initialize.bat"

rem ----------------------------------------
rem �o�b�`�w��
rem ----------------------------------------
set PKEY=PFS_CV211_01

set CURRENT_DRV=%~d0
set CURRENT_DIR=%CD%
%PFS_DRVE%
echo off

rem ----------------------------------------
rem �폜�����w��
rem ----------------------------------------
set ARG_DATE=%1
if "%ARG_DATE%" == "" (set ARG_DATE="770")
echo %DATE% %TIME% "�폜�����F%ARG_DATE%" >> "%LOG_PATH%\%PKEY%.log"

rem ----------------------------------------
rem �J�n
rem ----------------------------------------
echo %DATE% %TIME% �o�b�`�����J�n >> "%LOG_PATH%\%PKEY%.log"

rem ----------------------------------------
rem �폜�������s
rem ----------------------------------------
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 0 1 "���������s���ł��B"
sqlplus %CONNECT_MAIN% @%PKEY% %SCHEMA_PPS% %COMCD% %DIVCD% %PLTCD% %ARG_DATE% >> "%LOG_PATH%\%PKEY%.log"
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem ----------------------------------------
rem �I��
rem ----------------------------------------
echo %DATE% %TIME% �o�b�`�����I�� >> "%LOG_PATH%\%PKEY%.log"
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 1 2 "����������I�����܂����B"
%CURRENT_DRV%
cd /d %CURRENT_DIR%
echo on
exit /b 0

rem ----------------------------------------
rem ERR000
rem ----------------------------------------
:ERR000
echo ----------------------------------------
echo [%PKEY%]�G���[���������܂���
echo ----------------------------------------
echo %ERRVAL% >> "%LOG_PATH%\%PKEY%.log"
call  %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 3 8 "�G���[���������܂����B[%ERRVAL%]"
echo %DATE% %TIME% �G���[�����I >> "%LOG_PATH%\%PKEY%.log"
%CURRENT_DRV%
cd /d %CURRENT_DIR%
echo on
exit /b -1
