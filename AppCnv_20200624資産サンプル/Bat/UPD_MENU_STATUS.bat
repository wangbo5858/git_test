set CONNECT_DB=%1
sqlplus %CONNECT_DB% @"%SQL_PATH%UPD_MENU_STATUS.sql" %2 %3 %4 %5 %6
exit /b
