echo off
rem =============================================
rem  初期化 バッチ
rem
rem 【引数】
rem
rem 【備考】
rem ---------------------------------------------
rem Create 2017.02.14 FJ)Fukuyama
rem =============================================

rem ---------------------------------------------
rem 管理ドライブ、フォルダの設定
rem ---------------------------------------------
rem 管理ドライブ
set PFS_DRVE=D:

rem 管理フォルダ名
set PJ_NAME=PFS_JF

rem PROFOURSモジュールフォルダ(サーバー、クライアント、スタンドアローン)
set PSV_NAME=PFS_Server
set PCL_NAME=PFS_Client
set PSA_NAME=PFS_StandAlone

rem ---------------------------------------------
rem 管理フォルダパス
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
rem データベース名の設定
rem ---------------------------------------------
set DB=PFS_JF

rem ---------------------------------------------
rem スキーマ名の設定
rem ---------------------------------------------
set SCHEMA_PPS=PFS_JF

rem PROFOURSメインスキーマ
set MAIN_SCHEMA=PFS_JF
rem ---------------------------------------------
rem 接続文字列の設定
rem ---------------------------------------------
set CONNECT_PPS=%SCHEMA_PPS%/%SCHEMA_PPS%@%DB%
set CONNECT_MAIN=%MAIN_SCHEMA%/%MAIN_SCHEMA%@%DB%

rem ---------------------------------------------
rem 定数の設定
rem ---------------------------------------------
rem 会社コード
set COMCD=JF
rem 事業部コード
set DIVCD=JF
rem 工場コード
set PLTCD=*
rem デフォルト操業時間コード
set DOTCD=Ot03

rem ---------------------------------------------
rem 受信ファイル
rem ---------------------------------------------

rem ---------------------------------------------
rem 送信ファイル
rem ---------------------------------------------

exit /b
