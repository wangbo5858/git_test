echo off
rem =============================================
rem  �o�b�N�A�b�v
rem 
rem �y�����z
rem 
rem �y���l�z
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem Update
rem =============================================
set APPBAT_DRV=%~d0
set APPBAT_DIR=%CD%

rem ----------------------------------------------------------------------
rem ��������
rem ----------------------------------------------------------------------
call %~dp0"..\Common\initialize.bat"

rem -----------------------------------
rem �o�b�N�A�b�v�t�H���_�쐬
rem -----------------------------------
rem �t�H���_����ݒ�
FOR /F "tokens=1,2,3 delims=/ " %%i IN ('DATE /T') DO @SET SUFFIX_DATE=%%i%%j%%k
set time_tmp=%time: =0%
set time_tmp=%time_tmp:~0,2%%time_tmp:~3,2%%time_tmp:~6,2%%time_tmp:~9,2%
set BKUP_HOME_NAME=%SUFFIX_DATE%%time_tmp%

rem �o�b�N�A�b�v�t�H���_���쐬
set BKUP_PATH=%BKU_PATH%%BKUP_HOME_NAME%\
md %BKUP_PATH%

rem ----------------------------------------------------------------------
rem ���O�o�b�N�A�b�v(���O�E�t�@�C���̃R�s�[)
rem ----------------------------------------------------------------------

rem -----------------------------------
rem �R���o�[�^
rem -----------------------------------
set SUBD_PATH=AppCnv\Log
set ORIG_PATH=%PFS_PATH%%SUBD_PATH%
set LOG_BKUP_PATH=%BKUP_PATH%LOG\%SUBD_PATH%\
md %LOG_BKUP_PATH%
xcopy %ORIG_PATH% %LOG_BKUP_PATH% %OPTIONCP%

rem -----------------------------------
rem PROFOURS�N���C�A���g
rem -----------------------------------
set SUBD_PATH=%PCL_NAME%\Log
set ORIG_PATH=%PFS_PATH%%SUBD_PATH%
set LOG_BKUP_PATH=%BKUP_PATH%LOG\%SUBD_PATH%\
md %LOG_BKUP_PATH%
xcopy %ORIG_PATH% %LOG_BKUP_PATH% %OPTIONCP%

rem -----------------------------------
rem PROFOURS�T�[�o�[
rem -----------------------------------
set SUBD_PATH=%PSV_NAME%\Log
set ORIG_PATH=%PFS_PATH%%SUBD_PATH%
set LOG_BKUP_PATH=%BKUP_PATH%LOG\%SUBD_PATH%\
md %LOG_BKUP_PATH%
xcopy %ORIG_PATH% %LOG_BKUP_PATH% %OPTIONCP%

rem ----------------------------------------------------------------------
rem �_���v�o�b�N�A�b�v(DMP�t�@�C���̎擾�A�R�s�[)
rem ----------------------------------------------------------------------
rem -----------------------------------
rem DB�G�N�X�|�[�g
rem -----------------------------------
set DMP_BKUP_PATH=%BKUP_PATH%DMP\
md %DMP_BKUP_PATH%
exp %CONNECT_PPS% file=%DMP_BKUP_PATH%%SCHEMA_PPS%.dmp log=%DMP_BKUP_PATH%%SCHEMA_PPS%.log owner=(%SCHEMA_PPS%, %SCHEMA_PPS%_SIM00, %SCHEMA_PPS%_SIM01, %SCHEMA_PPS%_SIM02, %SCHEMA_PPS%_SIM03, %SCHEMA_PPS%_SIM04, %SCHEMA_PPS%_SIM05, %SCHEMA_PPS%_SIM06, %SCHEMA_PPS%_SIM07, %SCHEMA_PPS%_SIM08)

rem -----------------------------------
rem �t�@�C�����k�����t�@�C���폜
rem -----------------------------------
zip %DMP_BKUP_PATH%%SCHEMA_PPS%.zip %DMP_BKUP_PATH%%SCHEMA_PPS%.dmp
if %ERRORLEVEL% EQU 0 (del /q %DMP_BKUP_PATH%%SCHEMA_PPS%.dmp)

rem ----------------------------------------------------------------------
rem ���W���[���o�b�N�A�b�v(���W���[���̈��k�A�R�s�[)
rem ----------------------------------------------------------------------
rem -----------------------------------
rem ���W���[�����k
rem -----------------------------------
set MDL_BKUP_PATH=%BKUP_PATH%MODULE\
md %MDL_BKUP_PATH%
echo zip -r %MDL_BKUP_PATH%MODULE.zip %PFS_PATH%
zip -r %MDL_BKUP_PATH%%PJ_NAME%.zip %PFS_PATH%

rem ----------------------------------------------------------------------
rem ���O�폜
rem ----------------------------------------------------------------------
rem -----------------------------------
rem �R���o�[�^
rem -----------------------------------
set SUBD_PATH=AppCnv\Log
set ORIG_PATH=%PFS_PATH%%SUBD_PATH%
del %ORIG_PATH%\* /q

rem -----------------------------------
rem PROFOURS�N���C�A���g
rem -----------------------------------
set SUBD_PATH=%PCL_NAME%\Log
set ORIG_PATH=%PFS_PATH%%SUBD_PATH%
del %ORIG_PATH%\* /q

rem -----------------------------------
rem PROFOURS�T�[�o�[
rem -----------------------------------
set SUBD_PATH=%PSV_NAME%\Log
set ORIG_PATH=%PFS_PATH%%SUBD_PATH%
del %ORIG_PATH%\* /q

rem ----------------------------------------------------------------------
rem �ߋ��t�H���_�폜
rem ----------------------------------------------------------------------
for /f "skip=10" %%i in ('dir /b /ad /o-n %BKU_PATH%') do rd /s /q %BKU_PATH%\%%i

exit /b 0
