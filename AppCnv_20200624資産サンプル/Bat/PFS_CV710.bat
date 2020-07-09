echo off
rem =============================================
rem サーバー・モジュール起動
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
rem サーバー起動(待ち合わせしない)
rem -----------------------------------------
%PFS_DRVE%
cd %PSV_PATH%
EXECASVR.EXE /AE:%PSV_PATH%ProFourS.exe
rem start %PSV_PATH%ProFourS.exe

rem ----------------------------------------
rem 終了
rem ----------------------------------------
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0