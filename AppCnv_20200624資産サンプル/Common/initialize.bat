echo off
rem =============================================
rem  ������ �o�b�`
rem
rem �y�����z
rem
rem �y���l�z
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem =============================================

rem ---------------------------------------------
rem �Ǘ��h���C�u�A�t�H���_�̐ݒ�
rem ---------------------------------------------
rem �Ǘ��h���C�u
set PFS_DRVE=D:

rem �Ǘ��t�H���_��
set PJ_NAME=PFS_JF

rem PROFOURS���W���[���t�H���_(�T�[�o�[�A�N���C�A���g�A�X�^���h�A���[��)
set PSV_NAME=PFS_Server
set PCL_NAME=PFS_Client
set PSA_NAME=PFS_StandAlone

rem ---------------------------------------------
rem �Ǘ��t�H���_�p�X
rem ---------------------------------------------
set PFS_PATH=%PFS_DRVE%\%PJ_NAME%\
set SQL_PATH=%PFS_DRVE%\%PJ_NAME%\AppCnv\Sql\
set BAT_PATH=%PFS_DRVE%\%PJ_NAME%\AppCnv\Bat\
set SLC_PATH=%PFS_DRVE%\%PJ_NAME%\AppCnv\Ctrl\
set LOG_PATH=%PFS_DRVE%\%PJ_NAME%\AppCnv\Log\
set CMN_PATH=%PFS_DRVE%\%PJ_NAME%\AppCnv\Common\
set ADD_PATH=%PFS_DRVE%\%PJ_NAME%\AddOn\
set PSV_PATH=%PFS_DRVE%\%PJ_NAME%\%PSV_NAME%\
set PCL_PATH=%PFS_DRVE%\%PJ_NAME%\%PCL_NAME%\
set PSA_PATH=%PFS_DRVE%\%PJ_NAME%\%PSA_NAME%\
set BKU_PATH=%PFS_DRVE%\%PJ_NAME%_BKUP\

rem ---------------------------------------------
rem �f�[�^�x�[�X���̐ݒ�
rem ---------------------------------------------
set DB=PFS_JF

rem ---------------------------------------------
rem �X�L�[�}���̐ݒ�
rem ---------------------------------------------
set SCHEMA_PPS=PFS_JF

rem PROFOURS���C���X�L�[�}
set MAIN_SCHEMA=PFS_JF
rem ---------------------------------------------
rem �ڑ�������̐ݒ�
rem ---------------------------------------------
set CONNECT_PPS=%SCHEMA_PPS%/%SCHEMA_PPS%@%DB%
set CONNECT_MAIN=%MAIN_SCHEMA%/%MAIN_SCHEMA%@%DB%

rem ---------------------------------------------
rem �萔�̐ݒ�
rem ---------------------------------------------
rem ��ЃR�[�h
set COMCD=JF
rem ���ƕ��R�[�h
set DIVCD=JF
rem �H��R�[�h
set PLTCD=*
rem �f�t�H���g���Ǝ��ԃR�[�h
set DOTCD=Ot03

rem ---------------------------------------------
rem ��M�t�@�C��
rem ---------------------------------------------

rem ---------------------------------------------
rem ���M�t�@�C��
rem ---------------------------------------------

exit /b
