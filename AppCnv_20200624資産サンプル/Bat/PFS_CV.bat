echo on
rem =============================================
rem  �Ɩ��o�b�`
rem ---------------------------------------------
rem Create 2017.03.03 M.Ueda
rem Update
rem =============================================

rem ---------------------------------------------
rem ��������
rem ---------------------------------------------
call %~dp0"..\Common\initialize.bat"

rem ---------------------------------------------
rem PROFOURS�T�[�o�[��~
rem ---------------------------------------------
call %BAT_PATH%PFS_CV720.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem �o�b�N�A�b�v����
rem ---------------------------------------------
call %BAT_PATH%PFS_CV100.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem �V�X�e�����X�V
rem ---------------------------------------------
call %BAT_PATH%PFS_CV200.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem �}�X�^�捞
rem ---------------------------------------------
call %BAT_PATH%PFS_CV300.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem PROFOURS�T�[�o�[�N��
rem ---------------------------------------------
call %BAT_PATH%PFS_CV710.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem �I��(����)
rem ---------------------------------------------
exit /b 0
