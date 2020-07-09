/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 工程マスタ取込
-- 【引数】
--   &1  : スキーマ名(PPS用のスキーマ)
--   &2  : 会社コード
--   &3  : 事業部コード
--   &4  : 工場コード
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

cDEL	VARCHAR2(1) := '1';	-- 連携フラグ：削除
cSID	VARCHAR2(25) := 'PFS_CV301';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ユーザ

CURSOR cProc IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,PROCESS_CODE
		,PROCESS_NAME
	FROM FUM_PROCESS
	ORDER BY IF_SEQ
	;
vProcRec	cProc%ROWTYPE;

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

	PrintLog(cSID || '工程マスタ取込 開始');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cProc;
	LOOP
		-- 工程(IN)の読込
		FETCH cProc INTO vProcRec;
		EXIT WHEN cProc%NOTFOUND;
		
		IF vProcRec.IF_FLAG <> cDEL THEN
		-- 追加・更新処理
		-- 工程
			MERGE INTO &1 .FMR_PROCESS FP -- [工程]
			USING (
				SELECT
					 vProcRec.PROCESS_CODE PROCESS_CODE
					,vProcRec.PROCESS_NAME PROCESS_NAME
				FROM DUAL
			) UP
			ON (
					FP.COMPANY_CODE  = inCOMCD
				AND FP.DIVISION_CODE = inDIVCD
				AND FP.PROCESS_CODE  = UP.PROCESS_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME         = UP.PROCESS_NAME
					,UPD_SID      = cSID
					,UPD_USER     = cUSER
					,UPD_DATE     = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,PROCESS_CODE
					,NAME
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,UP.PROCESS_CODE
					,UP.PROCESS_NAME
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		-- ↓ 2017/09/28 コメント・アウト
		/*	
		--ダミー品目 品目
			MERGE INTO &1 .FMI_ITEM FI -- [品目]
			USING (
				SELECT
					 'DUMMY_' || vProcRec.PROCESS_CODE             ITEM_CODE
					,'ダミー品目(' || vProcRec.PROCESS_NAME || ')' NAME
				FROM DUAL
			) UI
			ON (
					FI.COMPANY_CODE  = inCOMCD
				AND FI.DIVISION_CODE = inDIVCD
				AND FI.ITEM_CODE     = UI.ITEM_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME         = UI.NAME
					,UPD_SID      = cSID
					,UPD_USER     = cUSER
					,UPD_DATE     = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,ITEM_CODE
					,NAME
					,ITEM_TYPE
					,PRODUCT_TYPE
					,STD_BOM_PATTERN
					,STD_PROCESS_PATTERN
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,UI.ITEM_CODE
					,UI.NAME
					,5
					,2
					,'*'
					,'*'
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		--ダミー品目 在庫管理情報
			MERGE INTO &1 .FMI_SKU FS -- [在庫管理情報]
			USING (
				SELECT
					 'DUMMY_' || vProcRec.PROCESS_CODE ITEM_CODE
				FROM DUAL
			) US
			ON (
					FS.COMPANY_CODE  = inCOMCD
				AND FS.DIVISION_CODE = inDIVCD
				AND FS.LOCATION_CODE = inPLTCD
				AND FS.ITEM_CODE     = US.ITEM_CODE
			)
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,ITEM_CODE
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
					,US.ITEM_CODE
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		--ダミー品目 工程順序
			MERGE INTO &1 .FMI_PROCESS_SEQUENCE FPS -- [工程順序]
			USING (
				SELECT
					 'DUMMY_' || vProcRec.PROCESS_CODE ITEM_CODE
					,vProcRec.PROCESS_CODE             PROCESS_CODE
				FROM DUAL
			) UPS
			ON (
					FPS.COMPANY_CODE  = inCOMCD
				AND FPS.DIVISION_CODE = inDIVCD
				AND FPS.ITEM_CODE     = UPS.ITEM_CODE
			)
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,ITEM_CODE
					,PROCESS_PATTERN
					,PROCESS_SEQ
					,PROCESS_CODE
					,ASSIGN_LINE_TYPE
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,UPS.ITEM_CODE
					,'*'
					,999
					,UPS.PROCESS_CODE
					,2
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		*/
		-- ↑ 2017/09/29 コメント・アウト
		ELSE
		-- 削除処理
		-- 工程
			DELETE
			FROM &1 .FMR_PROCESS
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND PROCESS_CODE  = vProcRec.PROCESS_CODE
			;
		-- ↓ 2017/09/29 コメント・アウト
		/*
		--ダミー品目 品目
			DELETE
			FROM &1 .FMI_ITEM
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = 'DUMMY_' || vProcRec.PROCESS_CODE
			;
		--ダミー品目 在庫管理情報
			DELETE
			FROM &1 .FMI_SKU
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = 'DUMMY_' || vProcRec.PROCESS_CODE
			;
		--ダミー品目 工程順序
			DELETE
			FROM &1 .FMI_PROCESS_SEQUENCE
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = 'DUMMY_' || vProcRec.PROCESS_CODE
			;
		*/
		-- ↑ 2017/09/29 コメント・アウト
			nDel := nDel + 1;
		END IF;
		
		-- 工程履歴に追加
		INSERT INTO FUM_PROCESS_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,PROCESS_CODE
			,PROCESS_NAME
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vProcRec.IF_FLAG
			,vProcRec.IF_SEQ
			,SYSDATE
			,vProcRec.PROCESS_CODE
			,vProcRec.PROCESS_NAME
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- 工程(IN)から削除
		DELETE FROM FUM_PROCESS
		WHERE IF_SEQ = vProcRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cProc;

	COMMIT;

	PrintLog(cSID || '処理件数 ' || nCnt || ' (削除件数 ' || nDel || ' )');
	PrintLog(cSID || '工程マスタ取込 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '工程マスタ取込 エラー終了');
		RAISE;

END;
/

EXIT;

