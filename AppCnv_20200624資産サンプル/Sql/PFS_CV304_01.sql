/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 品目構成マスタ取込
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
cSID	VARCHAR2(25) := 'PFS_CV304';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ユーザ

CURSOR cBom IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,ITEM_CODE
		,PROCESS_PATTERN
		,LOW_ITEM_CODE
		,BOM_PATTERN
		,VALID_START
		,VALID_END
	FROM FUM_BOM
	ORDER BY IF_SEQ
	;
vBomRec	cBom%ROWTYPE;

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

	PrintLog(cSID || '品目構成マスタ取込 開始');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cBom;
	LOOP
		-- 品目構成(IN)の読込
		FETCH cBom INTO vBomRec;
		EXIT WHEN cBom%NOTFOUND;
		
		IF vBomRec.IF_FLAG <> cDEL THEN
		-- 追加・更新処理
			MERGE INTO &1 .FMI_BOM FB -- [品目構成]
			USING (
				SELECT
					 vBomRec.ITEM_CODE            ITEM_CODE
					,vBomRec.PROCESS_PATTERN      PROCESS_PATTERN
					,vBomRec.LOW_ITEM_CODE        LOW_ITEM_CODE
					,vBomRec.BOM_PATTERN          BOM_PATTERN
					,vBomRec.VALID_START          VALID_START
					,vBomRec.VALID_END            VALID_END
				FROM DUAL
			) UB
			ON (
					FB.COMPANY_CODE      = inCOMCD
				AND FB.DIVISION_CODE     = inDIVCD
				AND FB.LOCATION_CODE     = inPLTCD
				AND FB.ITEM_CODE         = UB.ITEM_CODE
				AND FB.PROCESS_PATTERN   = UB.PROCESS_PATTERN
				AND FB.LOW_LOCATION_CODE = inPLTCD
				AND FB.LOW_ITEM_CODE     = UB.LOW_ITEM_CODE
				AND FB.BOM_PATTERN       = UB.BOM_PATTERN
				AND FB.VALID_START       = UB.VALID_START
			)
			WHEN MATCHED THEN
				UPDATE SET
					 VALID_END             = UB.VALID_END
					,UPD_SID               = cSID
					,UPD_USER              = cUSER
					,UPD_DATE              = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,ITEM_CODE
					,PROCESS_PATTERN
					,PROCESS_SEQ
					,BOM_PATTERN
					,LOW_LOCATION_CODE
					,LOW_ITEM_CODE
					,VALID_START
					,VALID_END
					,QUANTITY_NUMERATOR
					,QUANTITY_DENOMINATOR
					,TIME_RELATION_TYPE
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
					,UB.ITEM_CODE
					,UB.PROCESS_PATTERN
					,999
					,UB.BOM_PATTERN
					,inPLTCD
					,UB.LOW_ITEM_CODE
					,UB.VALID_START
					,UB.VALID_END
					,1
					,1
					,1 -- S-S時間関係
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
			DELETE
			FROM &1 .FMI_BOM
			WHERE
				    COMPANY_CODE      = inCOMCD
				AND DIVISION_CODE     = inDIVCD
				AND LOCATION_CODE     = inPLTCD
				AND ITEM_CODE         = vBomRec.ITEM_CODE
				AND PROCESS_PATTERN   = vBomRec.PROCESS_PATTERN
				AND LOW_LOCATION_CODE = inPLTCD
				AND LOW_ITEM_CODE     = vBomRec.LOW_ITEM_CODE
				AND BOM_PATTERN       = vBomRec.BOM_PATTERN
				AND VALID_START       = vBomRec.VALID_START
			;
			nDel := nDel + 1;
		END IF;
		
		-- 品目構成履歴に追加
		INSERT INTO FUM_BOM_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,ITEM_CODE
			,PROCESS_PATTERN
			,LOW_ITEM_CODE
			,BOM_PATTERN
			,VALID_START
			,VALID_END
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vBomRec.IF_FLAG
			,vBomRec.IF_SEQ
			,SYSDATE
			,vBomRec.ITEM_CODE
			,vBomRec.PROCESS_PATTERN
			,vBomRec.LOW_ITEM_CODE
			,vBomRec.BOM_PATTERN
			,vBomRec.VALID_START
			,vBomRec.VALID_END
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- 品目構成(IN)から削除
		DELETE FROM FUM_BOM
		WHERE IF_SEQ = vBomRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cBom;
	
	COMMIT;

	PrintLog(cSID || '処理件数 ' || nCnt || ' (削除件数 ' || nDel || ' )');
	PrintLog(cSID || '品目構成マスタ取込 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '品目構成マスタ取込 エラー終了');
		RAISE;

END;
/

