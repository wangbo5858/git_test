echo off
rem =============================================
rem �T�[�o�[�E���W���[���N��
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
rem �T�[�o�[�N��(�҂����킹���Ȃ�)
rem -----------------------------------------
%PFS_DRVE%
cd %PSV_PATH%
EXECASVR.EXE /AE:%PSV_PATH%ProFourS.exe
rem start %PSV_PATH%ProFourS.exe

rem ----------------------------------------
rem �I��
rem ----------------------------------------
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0