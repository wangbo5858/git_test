echo off
rem =============================================
rem  過去データ削除
rem 
rem 【引数】
rem 
rem 【備考】
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem Update
rem =============================================

rem ----------------------------------------
rem 環境初期化
rem ----------------------------------------
call %~dp0"..\Common\initialize.bat"

rem ----------------------------------------
rem バッチ指定
rem ----------------------------------------
set PKEY=PFS_CV211_01

set CURRENT_DRV=%~d0
set CURRENT_DIR=%CD%
%PFS_DRVE%
echo off

rem ----------------------------------------
rem 削除日数指定
rem ----------------------------------------
set ARG_DATE=%1
if "%ARG_DATE%" == "" (set ARG_DATE="770")
echo %DATE% %TIME% "削除日数：%ARG_DATE%" >> "%LOG_PATH%\%PKEY%.log"

rem ----------------------------------------
rem 開始
rem ----------------------------------------
echo %DATE% %TIME% バッチ処理開始 >> "%LOG_PATH%\%PKEY%.log"

rem ----------------------------------------
rem 削除処理実行
rem ----------------------------------------
cd %SQL_PATH%
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 0 1 "処理を実行中です。"
sqlplus %CONNECT_MAIN% @%PKEY% %SCHEMA_PPS% %COMCD% %DIVCD% %PLTCD% %ARG_DATE% >> "%LOG_PATH%\%PKEY%.log"
set ERRVAL=%ERRORLEVEL%
if %ERRVAL% NEQ 0 (goto ERR000)

rem ----------------------------------------
rem 終了
rem ----------------------------------------
echo %DATE% %TIME% バッチ処理終了 >> "%LOG_PATH%\%PKEY%.log"
call %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 1 2 "処理が正常終了しました。"
%CURRENT_DRV%
cd /d %CURRENT_DIR%
echo on
exit /b 0

rem ----------------------------------------
rem ERR000
rem ----------------------------------------
:ERR000
echo ----------------------------------------
echo [%PKEY%]エラーが発生しました
echo ----------------------------------------
echo %ERRVAL% >> "%LOG_PATH%\%PKEY%.log"
call  %BAT_PATH%UPD_MENU_STATUS.bat %CONNECT_MAIN% PROFOURS %PKEY% 3 8 "エラーが発生しました。[%ERRVAL%]"
echo %DATE% %TIME% エラー発生！ >> "%LOG_PATH%\%PKEY%.log"
%CURRENT_DRV%
cd /d %CURRENT_DIR%
echo on
exit /b -1
