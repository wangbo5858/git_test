echo off
rem =============================================
rem �g����1�o�͏���
rem 
rem �y�����z
rem 
rem �y���l�z
rem ---------------------------------------------
rem Create 2017.12.04 FJ)Ueda
rem Update
rem =============================================
rem ----------------------------------------
rem ���݂̃h���C�u�A�f�B���N�g�����̋L�^�B
rem ��CALL�����̃o�b�`�Ŏg�p���Ă���ϐ��Ɣ��Ȃ����Ƃ��m�F���邱�ƁB
rem ----------------------------------------
set APPBAT_DRV=%~d0
set APPBAT_DIR=%CD%

rem ----------------------------------------
rem ��������
rem ----------------------------------------
call %~dp0"..\Common\initialize.bat"
%PFS_DRVE%
echo off

rem ----------------------------------------
rem �o�b�`�w��
rem ��PNAME,PKEY �ϐ���CALL��Ŏg�p���Ă���̂Ŏg�p�֎~�B
rem ���i�r�Q�[�^��ʂŎ��s����{�^���̃��j��ID���w�肷�邱�ƁB
rem ----------------------------------------
set BATNAME=�g�����o��

rem ----------------------------------------
rem ���j���[�X�e�[�^�X�o�͏������s
rem ----------------------------------------
%PFS_DRVE%
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %BATNAME% 0 1 "���������s���ł��B"

rem -----------------------------------------
rem ���Y�v��A�g
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV501.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem -----------------------------------------
rem ���Y�v��CIP�A�g
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV502.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)


rem ----------------------------------------
rem �I��
rem ----------------------------------------
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %BATNAME% 1 2 "����������I�����܂����B"
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0


rem ----------------------------------------
rem ERR000
rem ----------------------------------------
:ERR000
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %BATNAME% 3 8 "�G���[���������܂����B[%ERRVAL%]"
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b -1