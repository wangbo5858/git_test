echo off
rem =============================================
rem  号機マスタ取込処理
rem ---------------------------------------------
rem 【引数】
rem ---------------------------------------------
rem 【備考】
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem Update
rem =============================================
set CURRENT_DRV=%~d0
set CURRENT_DIR=%CD%

rem ----------------------------------------
rem 環境初期化
rem ----------------------------------------
call %~dp0"..\Common\initialize.bat"
%PFS_DRVE%
echo off

rem ----------------------------------------
rem バッチ指定
rem ----------------------------------------
set PKEY=PFS_CV302
set PNAME=号機マスタ取込

rem ----------------------------------------
rem 開始
rem ----------------------------------------
echo %DATE% %TIME% バッチ処理開始 >> "%LOG_PATH%\%PKEY%.log"

rem ----------------------------------------
rem バッチ処理実行
rem ----------------------------------------
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 0 1 "処理を実行中です。"
sqlplus %CONNECT_MAIN% @%SQL_PATH%%PKEY% %SCHEMA_PPS% %COMCD% %DIVCD% %PLTCD% %DOTCD% >> "%LOG_PATH%\%PKEY%.log"
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR001)
rem ----------------------------------------
rem 終了
rem ----------------------------------------
echo %DATE% %TIME% バッチ処理終了 >> "%LOG_PATH%\%PKEY%.log"
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 1 2 "処理が正常終了しました。"
%CURRENT_DRV%
cd /d %CURRENT_DIR%
echo on
exit /b 0
