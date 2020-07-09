echo on
rem =============================================
rem  業務バッチ
rem ---------------------------------------------
rem Create 2017.03.03 M.Ueda
rem Update
rem =============================================

rem ---------------------------------------------
rem 環境初期化
rem ---------------------------------------------
call %~dp0"..\Common\initialize.bat"

rem ---------------------------------------------
rem PROFOURSサーバー停止
rem ---------------------------------------------
call %BAT_PATH%PFS_CV720.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem バックアップ処理
rem ---------------------------------------------
call %BAT_PATH%PFS_CV100.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem システム情報更新
rem ---------------------------------------------
call %BAT_PATH%PFS_CV200.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem マスタ取込
rem ---------------------------------------------
call %BAT_PATH%PFS_CV300.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem PROFOURSサーバー起動
rem ---------------------------------------------
call %BAT_PATH%PFS_CV710.bat
set ERRVAL=%ERRORLEVEL%
rem echo %ERRVAL%
rem pause
if %ERRVAL% NEQ 0 (exit /b -1)

rem ---------------------------------------------
rem 終了(正常)
rem ---------------------------------------------
exit /b 0
