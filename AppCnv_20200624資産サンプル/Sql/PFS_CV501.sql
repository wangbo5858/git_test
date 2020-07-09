/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 製造計画トラン出力
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
cSID	VARCHAR2(25) := 'PFS_CV501';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ユーザ

CURSOR cProResult(P_COMCD VARCHAR2,P_DIVCD VARCHAR2) IS
	SELECT
		FPS.PRODUCT_ID
		,FPS.PRODUCT_SEQ
		,FPS.ITEM_CODE
		,FLR.PROCESS_CODE
		,FLS.RESOURCE_CODE	LINE_CODE
		,FLR.PROPERTY01 	LINE_GROUP_CODE
		,TO_DATE(TO_CHAR(FLS.START_DATE,'YYYY/MM/DD'),'YYYY/MM/DD')	PRODUCT_DATE
		,FLS.START_DATE		PRODUCT_START_DATE
		,FLS.END_DATE		PRODUCT_END_DATE
		,FLS.LOCATION_QUANTITY	PRODUCT_QUANTITY
	FROM
		FTP_PRODUCT_SCHEDULE FPS
		,FTP_LOCATION_SCHEDULE FLS
		,FMR_LINE_RESOURCE FLR
	WHERE
		FPS.COMPANY_CODE = FLS.COMPANY_CODE
	AND	FPS.DIVISION_CODE = FLS.DIVISION_CODE
	AND	FPS.COMPANY_CODE = FLR.COMPANY_CODE
	AND	FPS.DIVISION_CODE = FLR.DIVISION_CODE
	AND	FPS.PRODUCT_ID = FLS.LOCATION_ID
	AND	FPS.PRODUCT_SEQ = FLS.LOCATION_SEQ
	AND	FPS.PRODUCT_SUB_SEQ = FLS.SUB_SEQ
	AND	FPS.COMPANY_CODE = P_COMCD
	AND	FPS.DIVISION_CODE = P_DIVCD
	AND	FLS.ASSIGN_FLG = 1	-- 割当済み
	AND	FPS.PROPERTY10 = '0'	-- 充填
	AND	LENGTH(FPS.PRODUCT_ID) = 13
	AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	ORDER BY FPS.PRODUCT_ID,FPS.PRODUCT_SEQ,FPS.ITEM_CODE
;
vProResult	cProResult%ROWTYPE;

CURSOR cProSub(P_COMCD VARCHAR2,P_DIVCD VARCHAR2,P_PRODOUCT_ID VARCHAR2) IS
	SELECT
		TYOUGOU_ID
		,TYOUGOU_ITEM_CODE
		,TYOUGOU_PROCESS_CODE
		,TYOUGOU_LINE_CODE
		,TYOUGOU_LINE_GROUP_CODE
		,TYUSYUTU_ID
		,TYUSYUTU_ITEM_CODE
		,TYUSYUTU_PROCESS_CODE
		,TYUSYUTU_LINE_CODE
		,TYUSYUTU_LINE_GROUP_CODE
	FROM
	(
		SELECT
			RANK() OVER(PARTITION BY SUBSTR(FPS.PRODUCT_ID,0,13) ORDER BY FPS.ITEM_CODE)	TYOUGOU_ROW
			,FPS.ITEM_CODE		TYOUGOU_ITEM_CODE
			,FPS.PRODUCT_ID		TYOUGOU_ID
			,FLR.PROCESS_CODE	TYOUGOU_PROCESS_CODE
			,FLS.RESOURCE_CODE	TYOUGOU_LINE_CODE
			,FLR.PROPERTY01 	TYOUGOU_LINE_GROUP_CODE
		FROM
			FTP_PRODUCT_SCHEDULE FPS
			,FTP_LOCATION_SCHEDULE FLS
			,FMR_LINE_RESOURCE FLR
		WHERE
			FPS.COMPANY_CODE = FLS.COMPANY_CODE
		AND	FPS.DIVISION_CODE = FLS.DIVISION_CODE
		AND	FPS.COMPANY_CODE = FLR.COMPANY_CODE
		AND	FPS.DIVISION_CODE = FLR.DIVISION_CODE
		AND	FPS.PRODUCT_ID = FLS.LOCATION_ID
		AND	FPS.PRODUCT_SEQ = FLS.LOCATION_SEQ
		AND	FPS.PRODUCT_SUB_SEQ = FLS.SUB_SEQ
		AND	FPS.COMPANY_CODE = P_COMCD
		AND	FPS.DIVISION_CODE = P_DIVCD
		AND	FLS.ASSIGN_FLG = 1	-- 割当済み
		AND	FPS.PROPERTY10 = '1'	-- 調合
		AND	SUBSTR(FPS.PRODUCT_ID,0,13) = P_PRODOUCT_ID	-- 親と同一
		AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	) TYOUGOU_DATA
	FULL OUTER JOIN
	(
		SELECT
			RANK() OVER(PARTITION BY SUBSTR(FPS.PRODUCT_ID,0,13) ORDER BY FPS.ITEM_CODE)	TYUSYUTU_ROW
			,FPS.ITEM_CODE		TYUSYUTU_ITEM_CODE
			,FPS.PRODUCT_ID		TYUSYUTU_ID
			,FLR.PROCESS_CODE	TYUSYUTU_PROCESS_CODE
			,FLS.RESOURCE_CODE	TYUSYUTU_LINE_CODE
			,FLR.PROPERTY01 	TYUSYUTU_LINE_GROUP_CODE
		FROM
			FTP_PRODUCT_SCHEDULE FPS
			,FTP_LOCATION_SCHEDULE FLS
			,FMR_LINE_RESOURCE FLR
		WHERE
			FPS.COMPANY_CODE = FLS.COMPANY_CODE
		AND	FPS.DIVISION_CODE = FLS.DIVISION_CODE
		AND	FPS.COMPANY_CODE = FLR.COMPANY_CODE
		AND	FPS.DIVISION_CODE = FLR.DIVISION_CODE
		AND	FPS.PRODUCT_ID = FLS.LOCATION_ID
		AND	FPS.PRODUCT_SEQ = FLS.LOCATION_SEQ
		AND	FPS.PRODUCT_SUB_SEQ = FLS.SUB_SEQ
		AND	FPS.COMPANY_CODE = P_COMCD
		AND	FPS.DIVISION_CODE = P_DIVCD
		AND	FLS.ASSIGN_FLG = 1	-- 割当済み
		AND	FPS.PROPERTY10 = '2'	-- 抽出
		AND	SUBSTR(FPS.PRODUCT_ID,0,13) = P_PRODOUCT_ID	-- 親と同一
		AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	) TYUSYUTU_DATA
	ON TYOUGOU_DATA.TYOUGOU_ROW = TYUSYUTU_DATA.TYUSYUTU_ROW
;
vProSub	cProSub%ROWTYPE;

CURSOR cProAka IS
	SELECT
		Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_LAST
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		FROM
			FUT_PRODUCT_PLAN_NEW
	)
;
vProAka	cProAka%ROWTYPE;

CURSOR cProKuro IS
	SELECT
		Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_NEW
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		FROM
			FUT_PRODUCT_PLAN_LAST
	)
;
vProKuro	cProKuro%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;
nErr	NUMBER;

vNOWDATE DATE;
nIF_Seq NUMBER;
nProduct_Seq NUMBER;

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
--  HISTデータ作成
-- 【引数】
--   
/******************************************************************************/
PROCEDURE MakeHist(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_PRODUCT_PLAN_HIST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	)
	SELECT
		IF_Flag
		,IF_Seq
		,vNOWDATE
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_LAST
	;
	DELETE FROM FUT_PRODUCT_PLAN_LAST
	;
END;
/******************************************************************************/
--  LASTデータ作成
-- 【引数】
--   
/******************************************************************************/
PROCEDURE MakeLast(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_PRODUCT_PLAN_LAST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	)
	SELECT
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_NEW
	;
	DELETE FROM FUT_PRODUCT_PLAN_NEW
	;
END;
/******************************************************************************/
--  NEWデータ作成
-- 【引数】
--   
/******************************************************************************/
PROCEDURE MakeNew(vNOWDATE DATE) IS
BEGIN
	nIF_Seq := 0;
	OPEN cProResult(inCOMCD,inDIVCD);
	LOOP
		-- 製造結果(充填)の読込
		FETCH cProResult INTO vProResult;
		EXIT WHEN cProResult%NOTFOUND;

		-- 調合、抽出の取得
		nProduct_Seq := 0;
		OPEN cProSub(inCOMCD,inDIVCD,SUBSTR(vProResult.Product_ID,0,13));
		LOOP 
			-- 製造結果(調合、抽出)の読込
			FETCH cProSub INTO vProSub;
			EXIT WHEN cProSub%NOTFOUND;

			nProduct_Seq := nProduct_Seq + 1;	--調合、抽出あり

			nIF_Seq := nIF_Seq + 1;
			INSERT INTO FUT_PRODUCT_PLAN_NEW(
				IF_Flag
				,IF_Seq
				,IF_Date
				,Product_ID
				,Product_Seq
				,Item_Code
				,Process_Code
				,Line_Code
				,Line_Group_Code
				,Product_Date
				,Product_Start_Date
				,Product_End_Date
				,Product_Quantity
				,Item_Code2
				,Process_Code2
				,Line_Code2
				,Line_Group_Code2
				,Item_Code3
				,Process_Code3
				,Line_Code3
				,Line_Group_Code3
			) VALUES (
				'0'
				,nIF_Seq
				,vNOWDATE
				,vProResult.Product_ID
				,nProduct_Seq
				,vProResult.Item_Code
				,vProResult.Process_Code
				,vProResult.Line_Code
				,vProResult.Line_Group_Code
				,vProResult.Product_Date
				,vProResult.Product_Start_Date
				,vProResult.Product_End_Date
				,vProResult.Product_Quantity
				,vProSub.TYUSYUTU_ITEM_CODE
				,vProSub.TYUSYUTU_PROCESS_CODE
				,vProSub.TYUSYUTU_LINE_CODE
				,vProSub.TYUSYUTU_LINE_GROUP_CODE
				,vProSub.TYOUGOU_ITEM_CODE
				,vProSub.TYOUGOU_PROCESS_CODE
				,vProSub.TYOUGOU_LINE_CODE
				,vProSub.TYOUGOU_LINE_GROUP_CODE
			)
			;

		END LOOP;
		CLOSE cProSub;
		
		-- 挿入(調合、抽出の無い場合)
		IF (nProduct_Seq = 0) THEN
			nIF_Seq := nIF_Seq + 1;
			INSERT INTO FUT_PRODUCT_PLAN_NEW(
				IF_Flag
				,IF_Seq
				,IF_Date
				,Product_ID
				,Product_Seq
				,Item_Code
				,Process_Code
				,Line_Code
				,Line_Group_Code
				,Product_Date
				,Product_Start_Date
				,Product_End_Date
				,Product_Quantity
				,Item_Code2
				,Process_Code2
				,Line_Code2
				,Line_Group_Code2
				,Item_Code3
				,Process_Code3
				,Line_Code3
				,Line_Group_Code3
			) VALUES (
				'0'
				,nIF_Seq
				,vNOWDATE
				,vProResult.Product_ID
				,1
				,vProResult.Item_Code
				,vProResult.Process_Code
				,vProResult.Line_Code
				,vProResult.Line_Group_Code
				,vProResult.Product_Date
				,vProResult.Product_Start_Date
				,vProResult.Product_End_Date
				,vProResult.Product_Quantity
				,''
				,''
				,''
				,''
				,''
				,''
				,''
				,''
			)
			;
		END IF;
	END LOOP;
	CLOSE cProResult;
END;
/******************************************************************************/
--  赤黒データ作成
-- 【引数】
--   
/******************************************************************************/
PROCEDURE MakeAkaKuro(vNOWDATE DATE) IS
BEGIN
	nIF_Seq := 0;
	-- 赤データ作成
	OPEN cProAka;
	LOOP
		-- 赤データの読込
		FETCH cProAka INTO vProAka;
		EXIT WHEN cProAka%NOTFOUND;

		-- 赤データの作成
		nIF_Seq := nIF_Seq + 1;
		INSERT INTO FUT_PRODUCT_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		) VALUES (
			'1'
			,nIF_Seq
			,vNOWDATE
			,vProAka.Product_ID
			,vProAka.Product_Seq
			,vProAka.Item_Code
			,vProAka.Process_Code
			,vProAka.Line_Code
			,vProAka.Line_Group_Code
			,vProAka.Product_Date
			,vProAka.Product_Start_Date
			,vProAka.Product_End_Date
			,vProAka.Product_Quantity
			,vProAka.Item_Code2
			,vProAka.Process_Code2
			,vProAka.Line_Code2
			,vProAka.Line_Group_Code2
			,vProAka.Item_Code3
			,vProAka.Process_Code3
			,vProAka.Line_Code3
			,vProAka.Line_Group_Code3
		)
	;
	END LOOP;
	CLOSE cProAka;
	nDel := nIF_Seq;

	-- 黒データ作成
	OPEN cProKuro;
	LOOP
		-- 黒データの読込
		FETCH cProKuro INTO vProKuro;
		EXIT WHEN cProKuro%NOTFOUND;

		-- 黒データの作成
		nIF_Seq := nIF_Seq + 1;
		INSERT INTO FUT_PRODUCT_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		) VALUES (
			'0'
			,nIF_Seq
			,vNOWDATE
			,vProKuro.Product_ID
			,vProKuro.Product_Seq
			,vProKuro.Item_Code
			,vProKuro.Process_Code
			,vProKuro.Line_Code
			,vProKuro.Line_Group_Code
			,vProKuro.Product_Date
			,vProKuro.Product_Start_Date
			,vProKuro.Product_End_Date
			,vProKuro.Product_Quantity
			,vProKuro.Item_Code2
			,vProKuro.Process_Code2
			,vProKuro.Line_Code2
			,vProKuro.Line_Group_Code2
			,vProKuro.Item_Code3
			,vProKuro.Process_Code3
			,vProKuro.Line_Code3
			,vProKuro.Line_Group_Code3
		)
	;
	END LOOP;
	CLOSE cProKuro;
	nCnt := nIF_Seq - nDel;
END;
/***************************/
/* メイン処理              */
/***************************/
BEGIN

	PrintLog(cSID || '製造計画トラン出力 開始');
	
	nCnt := 0;
	nDel := 0;
	nErr := 0;
	
	-- 現在時刻取得
	SELECT SYSDATE
	INTO vNOWDATE	
	FROM DUAL;

	PrintLog(cSID || '製造計画履歴退避 開始');
	MakeHist(vNOWDATE);
	PrintLog(cSID || '製造計画履歴退避 終了');

	PrintLog(cSID || '製造計画前回作成 開始');
	MakeLast(vNOWDATE);
	PrintLog(cSID || '製造計画前回作成 終了');

	PrintLog(cSID || '製造計画最新作成 開始');
	MakeNew(vNOWDATE);
	PrintLog(cSID || '製造計画最新作成 終了');

	PrintLog(cSID || '生産計画作成 開始');
	MakeAkaKuro(vNOWDATE);
	PrintLog(cSID || '生産計画作成 終了');
	
	COMMIT;

	PrintLog(cSID || '処理件数 ' || nCnt || ' (削除件数 ' || nDel || ' )' || ' (エラー件数 ' || nErr || ' )');
	PrintLog(cSID || '製造計画トラン出力 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '製造計画トラン出力 エラー終了');
		RAISE;

END;

/

EXIT;

