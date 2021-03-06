echo off
rem =============================================
rem マスタ取込処理
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

rem ----------------------------------------
rem バッチ指定
rem ※PNAME,PKEY 変数はCALL先で使用しているので使用禁止。
rem ※ナビゲータ画面で実行するボタンのメニュIDを指定すること。
rem ----------------------------------------
set BATNAME=マスタ取込

rem ----------------------------------------
rem メニューステータス出力処理実行
rem ----------------------------------------
%PFS_DRVE%
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %BATNAME% 0 1 "処理を実行中です。"

rem -----------------------------------------
rem 工程マスタ取込
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV301.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem -----------------------------------------
rem 号機マスタ取込
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV302.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem -----------------------------------------
rem 品目マスタ取込
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV303.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem -----------------------------------------
rem 品目構成マスタ取込
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV304.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem -----------------------------------------
rem 品目号機マスタ取込
rem -----------------------------------------
%PFS_DRVE%
cd %BAT_PATH%
call PFS_CV305.bat
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem ----------------------------------------
rem 終了
rem ----------------------------------------
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %BATNAME% 1 2 "処理が正常終了しました。"
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b 0


rem ----------------------------------------
rem ERR000
rem ----------------------------------------
:ERR000
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %BATNAME% 3 8 "エラーが発生しました。[%ERRVAL%]"
%APPBAT_DRV%
cd /d %APPBAT_DIR%
echo on
exit /b -1