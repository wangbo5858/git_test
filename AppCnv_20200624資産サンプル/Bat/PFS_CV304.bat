echo off
rem =============================================
rem  �i�ڍ\���}�X�^�捞����
rem ---------------------------------------------
rem �y�����z
rem ---------------------------------------------
rem �y���l�z
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem Update
rem =============================================
set CURRENT_DRV=%~d0
set CURRENT_DIR=%CD%

rem ----------------------------------------
rem ��������
rem ----------------------------------------
call %~dp0"..\Common\initialize.bat"
%PFS_DRVE%
echo off

rem ----------------------------------------
rem �o�b�`�w��
rem ----------------------------------------
set PKEY=PFS_CV304
set PNAME=�i�ڍ\���}�X�^�捞

rem ----------------------------------------
rem �J�n
rem ----------------------------------------
echo %DATE% %TIME% �o�b�`�����J�n >> "%LOG_PATH%\%PKEY%.log"

rem ----------------------------------------
rem �o�b�`�������s
rem ----------------------------------------
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 0 1 "���������s���ł��B"
sqlplus %CONNECT_MAIN% @%SQL_PATH%%PKEY% %SCHEMA_PPS% %COMCD% %DIVCD% %PLTCD% >> "%LOG_PATH%\%PKEY%.log"
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR001)

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
rem ERR001
rem ----------------------------------------
:ERR001
echo ----------------------------------------
echo [%PKEY%]�G���[���������܂���
echo ----------------------------------------
echo %ERRVAL% >> "%LOG_PATH%\%PKEY%.log"
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 3 8 "�G���[���������܂����B(%PNAME%)[%ERRVAL%]"
echo %DATE% %TIME% �G���[�����I >> "%LOG_PATH%\%PKEY%.log"
%CURRENT_DRV%
cd /d %CURRENT_DIR%
echo on
exit /b -1
