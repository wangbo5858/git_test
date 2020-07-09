/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 号機マスタ取込
-- 【引数】
--   &1  : スキーマ名(PPS用のスキーマ)
--   &2  : 会社コード
--   &3  : 事業部コード
--   &4  : 工場コード
--   &5  : デフォルト操業時間コード
-- 【備考】
-- 
/******************************************************************************/
SET VERIFY       OFF
SET ECHO         OFF
SET TRIMSPOOL    ON
SET WRAP         ON
SET LINESIZE     2000
SET SERVEROUTPUT ON

DECLARE

inCOMCD   VARCHAR2(25) := '&2';  -- 会社コード
inDIVCD   VARCHAR2(25) := '&3';  -- 事業部コード
inPLTCD   VARCHAR2(25) := '&4';  -- 工場コード
inOPECD   VARCHAR2(25) := '&5';  -- 操業時間コード

cDEL	VARCHAR2(1) := '1';				-- 連携フラグ：削除
cSID	VARCHAR2(25) := 'PFS_CV302';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';		-- ユーザ

CURSOR cLine IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,PROCESS_CODE
		,LINE_RESOURCE_CODE
		,LINE_RESOURCE_NAME
		,GROUP_CODE
		,GROUP_NAME
	FROM FUM_LINE
	ORDER BY IF_SEQ
	;
vLineRec	cLine%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;

/******************************************************************************/
--  ログ出力
-- 【引数】
--   pinMessage  : メッセージ
/******************************************************************************/
PROCEDURE PrintLog(pinMessage VARCHAR2) IS
BEGIN
	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY/MM/DD HH24:MI:SS.FF3') || ' : ' || pinMessage);
END;


/***************************/
/* メイン処理              */
/***************************/
BEGIN

	PrintLog(cSID || '号機マスタ取込 開始');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cLine;
	LOOP
		-- 号機(IN)の読込
		FETCH cLine INTO vLineRec;
		EXIT WHEN cLine%NOTFOUND;
		
		IF vLineRec.IF_FLAG <> cDEL THEN
		-- 追加・更新処理
			MERGE INTO &1 .FMR_LINE_RESOURCE FL -- [ライン資源]
			USING (
				SELECT
					 vLineRec.PROCESS_CODE       PROCESS_CODE
					,vLineRec.LINE_RESOURCE_CODE LINE_RESOURCE_CODE
					,vLineRec.LINE_RESOURCE_NAME LINE_RESOURCE_NAME
					,vLineRec.GROUP_CODE         GROUP_CODE
					,vLineRec.GROUP_NAME         GROUP_NAME
				FROM DUAL
			) UL
			ON (
					FL.COMPANY_CODE        = inCOMCD
				AND FL.DIVISION_CODE       = inDIVCD
				AND FL.LINE_RESOURCE_CODE  = UL.LINE_RESOURCE_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 LOCATION_CODE         = inPLTCD
					,PROCESS_CODE          = UL.PROCESS_CODE
					,NAME                  = UL.LINE_RESOURCE_NAME
					,RUNNING_CALENDAR_CODE = UL.LINE_RESOURCE_CODE
					,PROPERTY01            = TRIM(UL.GROUP_CODE)
					,PROPERTY02            = UL.GROUP_NAME
					,UPD_SID               = cSID
					,UPD_USER              = cUSER
					,UPD_DATE              = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,PROCESS_CODE
					,LINE_RESOURCE_CODE
					,NAME
					,RUNNING_CALENDAR_CODE
					,PROPERTY01
					,PROPERTY02
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,inPLTCD
					,UL.PROCESS_CODE
					,UL.LINE_RESOURCE_CODE
					,UL.LINE_RESOURCE_NAME
					,UL.LINE_RESOURCE_CODE
					,TRIM(UL.GROUP_CODE)
					,UL.GROUP_NAME
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
			
			MERGE INTO &1 .FMC_RUNNING_CALENDAR FRC -- [稼働カレンダー]
			USING (
				SELECT
					 vLineRec.PROCESS_CODE       PROCESS_CODE
					,vLineRec.LINE_RESOURCE_CODE LINE_RESOURCE_CODE
					,vLineRec.LINE_RESOURCE_NAME LINE_RESOURCE_NAME
					,vLineRec.GROUP_CODE         GROUP_CODE
					,vLineRec.GROUP_NAME         GROUP_NAMAG
				FROM DUAL
			) UL
			ON (
					FRC.COMPANY_CODE          = inCOMCD
				AND FRC.DIVISION_CODE         = inDIVCD
				AND FRC.RUNNING_CALENDAR_CODE = UL.LINE_RESOURCE_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME                  = UL.LINE_RESOURCE_NAME
					,UPD_SID               = cSID
					,UPD_USER              = cUSER
					,UPD_DATE              = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,RUNNING_CALENDAR_CODE
					,NAME
					,ABBREVIATION
					,DATE_START
					,DATE_END
					,RUNNING_FLG_1
					,RUNNING_FLG_2
					,RUNNING_FLG_3
					,RUNNING_FLG_4
					,RUNNING_FLG_5
					,RUNNING_FLG_6
					,RUNNING_FLG_7
					,OPERATION_TIME_CODE_1
					,OPERATION_TIME_CODE_2
					,OPERATION_TIME_CODE_3
					,OPERATION_TIME_CODE_4
					,OPERATION_TIME_CODE_5
					,OPERATION_TIME_CODE_6
					,OPERATION_TIME_CODE_7
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,UL.LINE_RESOURCE_CODE
					,UL.LINE_RESOURCE_NAME
					,NULL
					,TO_DATE('2017/01/01','YYYY/MM/DD')
					,TO_DATE('2017/12/31','YYYY/MM/DD')
					,1
					,1
					,1
					,1
					,1
					,1
					,1
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		ELSE
		-- 削除処理
			-- [ライン資源]
			DELETE
			FROM &1 .FMR_LINE_RESOURCE
			WHERE
				    COMPANY_CODE       = inCOMCD
				AND DIVISION_CODE      = inDIVCD
				AND LINE_RESOURCE_CODE = vLineRec.LINE_RESOURCE_CODE
			;
			-- [稼働カレンダー]
			DELETE
			FROM  &1 .FMC_RUNNING_CALENDAR
			WHERE
				    COMPANY_CODE          = inCOMCD
				AND DIVISION_CODE         = inDIVCD
				AND RUNNING_CALENDAR_CODE = vLineRec.LINE_RESOURCE_CODE
			;
			-- [特定日稼働状況]
			DELETE
			FROM  &1 .FMC_RUNNING_DAY_STATUS
			WHERE
				    COMPANY_CODE          = inCOMCD
				AND DIVISION_CODE         = inDIVCD
				AND RUNNING_CALENDAR_CODE = vLineRec.LINE_RESOURCE_CODE
			;
			nDel := nDel + 1;
		END IF;
		
		-- 号機履歴に追加
		INSERT INTO FUM_LINE_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,PROCESS_CODE
			,LINE_RESOURCE_CODE
			,LINE_RESOURCE_NAME
			,GROUP_CODE
			,GROUP_NAME
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vLineRec.IF_FLAG
			,vLineRec.IF_SEQ
			,SYSDATE
			,vLineRec.PROCESS_CODE
			,vLineRec.LINE_RESOURCE_CODE
			,vLineRec.LINE_RESOURCE_NAME
			,vLineRec.GROUP_CODE
			,vLineRec.GROUP_NAME
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- 号機(IN)から削除
		DELETE FROM FUM_LINE
		WHERE IF_SEQ = vLineRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cLine;

	COMMIT;

	PrintLog(cSID || '処理件数 ' || nCnt || ' (削除件数 ' || nDel || ' )');
	PrintLog(cSID || '号機マスタ取込 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '号機マスタ取込 エラー終了');
		RAISE;

END;
/

EXIT;

