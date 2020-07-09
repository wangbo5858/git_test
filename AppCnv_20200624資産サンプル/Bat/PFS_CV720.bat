echo off
rem =============================================
rem サーバー・モジュール停止処理
rem 
rem 【引数】
rem 
rem 【備考】
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem Update
rem =============================================
rem ----------------------------------------
rem 現在のドライブ、ディレクトリ情報の記録。
rem ※CALLする先のバッチで使用している変数と被らないことを確認すること。
rem ----------------------------------------
set APPBAT_DRV=%~d0
set APPBAT_DIR=%CD%

rem ----------------------------------------
rem 環境初期化
rem ----------------------------------------
call %~dp0"..\Common\initialize.bat"
%PFS_DRVE%
echo off

rem -----------------------------------------
rem サーバー停止
rem -----------------------------------------
%PFS_DRVE%
cd %PSV_PATH%
start /wait ScpShutDown.exe
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem ----------------------------------------
rem 終了
rem ----------------------------------------
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0

rem ----------------------------------------
rem ERR000
rem プロセス・キル処理
rem SystemWalkerでエラーコード1を受け取ると次に進まないため0を返すようにする。
rem ----------------------------------------
:ERR000
taskkill /im ProFourS.exe /f
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0