echo off
rem =============================================
rem �T�[�o�[�E���W���[����~����
rem 
rem �y�����z
rem 
rem �y���l�z
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
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

rem -----------------------------------------
rem �T�[�o�[��~
rem -----------------------------------------
%PFS_DRVE%
cd %PSV_PATH%
start /wait ScpShutDown.exe
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem ----------------------------------------
rem �I��
rem ----------------------------------------
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0

rem ----------------------------------------
rem ERR000
rem �v���Z�X�E�L������
rem SystemWalker�ŃG���[�R�[�h1���󂯎��Ǝ��ɐi�܂Ȃ�����0��Ԃ��悤�ɂ���B
rem ----------------------------------------
:ERR000
taskkill /im ProFourS.exe /f
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0