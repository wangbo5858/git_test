/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 製造依頼トラン取込
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
cSID	VARCHAR2(25) := 'PFS_CV401';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ユーザ

CURSOR cProReq IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,PROD_REQ_ID
		,REQ_MONTH
		,ITEM_CODE
		,ITEM_CODE2
		,ITEM_NAME2
		,REQ_QTY
		,REQ_DATE
		,REQ_LINE
		,BOM_UPD_FLAG
		,PROPERTY01
		,PROPERTY02
		,PROPERTY03
		,PROPERTY04
		,PROPERTY05
	FROM FUT_PRODUCT_REQUIRE
	ORDER BY IF_SEQ
	;
vProReqRec	cProReq%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;
nErr	NUMBER;

vHistID VARCHAR(25);
nHistNo NUMBER;

nErrFlag NUMBER;
nSelCnt  NUMBER;

/******************************************************************************/
--  ログ出力
-- 【引数】
--   pinMessage  : メッセージ
/******************************************************************************/
PROCEDURE PrintLog(pinMessage VARCHAR2) IS
BEGIN
	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY/MM/DD HH24:MI:SS.FF3') || ' : ' || pinMessage);
END;

/******************************************************************************/
--  エラー出力
-- 【引数】
--   pinProReqRec  ： 製造依頼(IN)
--   pinErrMessage ： エラーメッセージ
/******************************************************************************/
PROCEDURE OutError(pinProReqRec cProReq%ROWTYPE, pinErrMessage VARCHAR2) IS
BEGIN
	INSERT INTO FUT_PROD_REQUIRE_ERROR
	(
		 PROD_REQ_HIST_ID
		,IF_FLAG
		,IF_SEQ
		,IF_DATE
		,ERRMSG
		,PROD_REQ_ID
		,UPD_SID
		,UPD_USER
		,UPD_DATE
	)
	VALUES
	(
		 TO_CHAR(nHistNo,'FM0000000000000000000000000')
		,pinProReqRec.IF_FLAG
		,pinProReqRec.IF_SEQ
		,SYSDATE
		,pinErrMessage
		,pinProReqRec.PROD_REQ_ID
		,cSID
		,cUSER
		,SYSDATE
	)
	;
	nHistNo := nHistNo + 1;
END;

/***************************/
/* メイン処理              */
/***************************/
BEGIN

	PrintLog(cSID || '製造依頼トラン取込 開始');
	
	nCnt := 0;
	nDel := 0;
	nErr := 0;
	
	SELECT MAX(PROD_REQ_HIST_ID)
	INTO vHistID
	FROM FUT_PROD_REQUIRE_ERROR;
	
	PrintLog(cSID || '製造依頼取込エラー履歴ID 最大値(' || vHistID || ')');
	IF vHistID IS NULL THEN
		nHistNo := 0;
	ELSE
		nHistNo := TO_NUMBER(vHistID) + 1;
	END IF;
	
	OPEN cProReq;
	LOOP
		-- 製造依頼(IN)の読込
		FETCH cProReq INTO vProReqRec;
		EXIT WHEN cProReq%NOTFOUND;
		
		IF vProReqRec.IF_FLAG <> cDEL THEN
		-- エラーチェック
			nErrFlag := 0;
		-- 製造依頼量
			IF vProReqRec.REQ_QTY < 0 THEN
				OutError(vProReqRec, '製造依頼量がマイナスです。');
				nErrFlag := 1;
			END IF;
		-- 品目チェック
			SELECT COUNT(*) INTO nSelCnt
			FROM FMI_ITEM
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vProReqRec.ITEM_CODE
			;
			IF nSelCnt = 0 THEN
				OutError(vProReqRec, '品目が品目マスタにありません。');
				nErrFlag := 1;
			END IF;
			SELECT COUNT(*) INTO nSelCnt
			FROM FMR_LINE_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vProReqRec.ITEM_CODE
			;
			IF nSelCnt = 0 THEN
				OutError(vProReqRec, '品目がライン製造手順マスタにありません。');
				nErrFlag := 1;
			END IF;
		-- 品目チェック
			SELECT COUNT(*) INTO nSelCnt
			FROM FMR_LINE_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE       = inCOMCD
				AND DIVISION_CODE      = inDIVCD
				AND LINE_RESOURCE_CODE = vProReqRec.REQ_LINE
			;
			IF nSelCnt = 0 THEN
				OutError(vProReqRec, '製造依頼ラインがライン製造手順マスタにありません。');
				nErrFlag := 1;
			END IF;
		-- 追加・更新処理
			IF nErrFlag = 0 THEN
				MERGE INTO &1 .FUT_PRODUCT_REQUIRE_ALL FRA -- [製造依頼]
				USING (
					SELECT
						 vProReqRec.IF_FLAG       IF_FLAG
						,vProReqRec.IF_SEQ        IF_SEQ
						,vProReqRec.PROD_REQ_ID   PROD_REQ_ID
						,vProReqRec.REQ_MONTH     REQ_MONTH
						,vProReqRec.ITEM_CODE     ITEM_CODE
						,vProReqRec.ITEM_CODE2    ITEM_CODE2
						,vProReqRec.ITEM_NAME2    ITEM_NAME2
						,vProReqRec.REQ_QTY       REQ_QTY
						,vProReqRec.REQ_DATE      REQ_DATE
						,vProReqRec.REQ_LINE      REQ_LINE
						,vProReqRec.BOM_UPD_FLAG  BOM_UPD_FLAG
						,vProReqRec.PROPERTY01    PROPERTY01
						,vProReqRec.PROPERTY02    PROPERTY02
						,vProReqRec.PROPERTY03    PROPERTY03
						,vProReqRec.PROPERTY04    PROPERTY04
						,vProReqRec.PROPERTY05    PROPERTY05
					FROM DUAL
				) UPA
				ON (
						FRA.REQ_MONTH = UPA.REQ_MONTH
					AND FRA.ITEM_CODE = UPA.ITEM_CODE
					AND FRA.REQ_DATE  = UPA.REQ_DATE
				)
				WHEN MATCHED THEN
					UPDATE SET
						 IF_FLAG      = UPA.IF_FLAG
						,IF_SEQ       = UPA.IF_SEQ
						,PROD_REQ_ID  = UPA.PROD_REQ_ID
						,ITEM_CODE2   = UPA.ITEM_CODE2
						,ITEM_NAME2   = UPA.ITEM_NAME2
						,REQ_QTY      = UPA.REQ_QTY
						,REQ_LINE     = UPA.REQ_LINE
						,BOM_UPD_FLAG = UPA.BOM_UPD_FLAG
						,PROPERTY01   = UPA.PROPERTY01
						,PROPERTY02   = UPA.PROPERTY02
						,PROPERTY03   = UPA.PROPERTY03
						,PROPERTY04   = UPA.PROPERTY04
						,PROPERTY05   = UPA.PROPERTY05
						,UPD_SID      = cSID
						,UPD_USER     = cUSER
						,UPD_DATE     = SYSDATE
				WHEN NOT MATCHED THEN
					INSERT (
						 IF_FLAG
						,IF_SEQ
						,PROD_REQ_ID
						,REQ_MONTH
						,ITEM_CODE
						,ITEM_CODE2
						,ITEM_NAME2
						,REQ_QTY
						,REQ_DATE
						,REQ_LINE
						,BOM_UPD_FLAG
						,PROPERTY01
						,PROPERTY02
						,PROPERTY03
						,PROPERTY04
						,PROPERTY05
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 UPA.IF_FLAG
						,UPA.IF_SEQ
						,UPA.PROD_REQ_ID
						,UPA.REQ_MONTH
						,UPA.ITEM_CODE
						,UPA.ITEM_CODE2
						,UPA.ITEM_NAME2
						,UPA.REQ_QTY
						,UPA.REQ_DATE
						,UPA.REQ_LINE
						,UPA.BOM_UPD_FLAG
						,UPA.PROPERTY01
						,UPA.PROPERTY02
						,UPA.PROPERTY03
						,UPA.PROPERTY04
						,UPA.PROPERTY05
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			ELSE
				nErr := nErr + 1;
			END IF;
		ELSE
		-- 削除処理
			DELETE
			FROM &1 .FUT_PRODUCT_REQUIRE_ALL
			WHERE
					REQ_MONTH = vProReqRec.REQ_MONTH
				AND ITEM_CODE = vProReqRec.ITEM_CODE
				AND REQ_DATE  = vProReqRec.REQ_DATE
			;
			nDel := nDel + 1;
		END IF;
		
		-- 製造依頼履歴に追加
		INSERT INTO FUT_PROD_REQUIRE_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,PROD_REQ_ID
			,REQ_MONTH
			,ITEM_CODE
			,ITEM_CODE2
			,ITEM_NAME2
			,REQ_QTY
			,REQ_DATE
			,REQ_LINE
			,BOM_UPD_FLAG
			,PROPERTY01
			,PROPERTY02
			,PROPERTY03
			,PROPERTY04
			,PROPERTY05
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vProReqRec.IF_FLAG
			,vProReqRec.IF_SEQ
			,SYSDATE
			,vProReqRec.PROD_REQ_ID
			,vProReqRec.REQ_MONTH
			,vProReqRec.ITEM_CODE
			,vProReqRec.ITEM_CODE2
			,vProReqRec.ITEM_NAME2
			,vProReqRec.REQ_QTY
			,vProReqRec.REQ_DATE
			,vProReqRec.REQ_LINE
			,vProReqRec.BOM_UPD_FLAG
			,vProReqRec.PROPERTY01
			,vProReqRec.PROPERTY02
			,vProReqRec.PROPERTY03
			,vProReqRec.PROPERTY04
			,vProReqRec.PROPERTY05
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- 製造依頼(IN)から削除
		DELETE FROM FUT_PRODUCT_REQUIRE
		WHERE IF_SEQ = vProReqRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cProReq;
	
	COMMIT;

	PrintLog(cSID || '処理件数 ' || nCnt || ' (削除件数 ' || nDel || ' )' || ' (エラー件数 ' || nErr || ' )');
	PrintLog(cSID || '製造依頼トラン取込 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '製造依頼トラン取込 エラー終了');
		RAISE;

END;
/

EXIT;

