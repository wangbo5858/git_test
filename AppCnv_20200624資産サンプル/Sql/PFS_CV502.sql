/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 製造計画CIPトラン出力
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
cSID	VARCHAR2(25) := 'PFS_CV502';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ユーザ

CURSOR cProResult(P_COMCD VARCHAR2,P_DIVCD VARCHAR2) IS
	SELECT
		FPS.PRODUCT_ID
		,FPS.PRODUCT_SEQ
		,FLR.PROCESS_CODE
		,FLS.RESOURCE_CODE	LINE_CODE
		,FLR.PROPERTY01 	LINE_GROUP_CODE
		,FLS.START_DATE		PRODUCT_START_DATE
		,FLS.END_DATE		PRODUCT_END_DATE
		,FPS.PROPERTY22		CIPNUM
		,FPS.PROPERTY23		CIPLEN
		,FPS.PROPERTY24		CIPTERM
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
	AND     FPS.PROPERTY22 >= 0	-- CIP1回以上
	AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	ORDER BY FPS.PRODUCT_ID
;
vProResult	cProResult%ROWTYPE;

CURSOR cSetupResult(P_COMCD VARCHAR2,P_DIVCD VARCHAR2) IS
	SELECT
		FSS.PRODUCT_ID
		,FSS.PRODUCT_SEQ
		,FLR.PROCESS_CODE
		,FSS.RESOURCE_CODE	LINE_CODE
		,FLR.PROPERTY01 	LINE_GROUP_CODE
		,FSS.START_DATE		
		,FSS.END_DATE		
	FROM
		FTP_SETUP_SUMMARY FSS
		,FMR_LINE_RESOURCE FLR
		,FMR_PROCESS FP
	WHERE
		FSS.COMPANY_CODE = FLR.COMPANY_CODE
	AND	FSS.DIVISION_CODE = FLR.DIVISION_CODE
	AND	FSS.COMPANY_CODE = FP.COMPANY_CODE
	AND	FSS.DIVISION_CODE = FP.DIVISION_CODE
	AND	FSS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	AND	FLR.PROCESS_CODE = FP.PROCESS_CODE
	AND	FSS.ASSIGN_FLG = 1		-- 割当のみ
	AND	FP.PROPERTY01 = '0'		-- 充填のみ
	ORDER BY FSS.PRODUCT_ID
;
vSetupResult	cSetupResult%ROWTYPE;

CURSOR cProAka IS
	SELECT
		Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_LAST
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		FROM
			FUT_CIP_PLAN_NEW
	)
;
vProAka	cProAka%ROWTYPE;

CURSOR cProKuro IS
	SELECT
		Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_NEW
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		FROM
			FUT_CIP_PLAN_LAST
	)
;
vProKuro	cProKuro%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;
nErr	NUMBER;

vNOWDATE DATE;
nIF_Seq NUMBER;
nProduct_Seq NUMBER;

vCIPStartTime DATE;
vCIPEndTime DATE;

vCIPLEN_WK VARCHAR2(50);
vCIPTERM_WK VARCHAR2(50);

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
--  文字列切り抜き
-- 【引数】
--   
/******************************************************************************/
FUNCTION STRTOKEN(
	P_STRING VARCHAR2, P_DELIMIT VARCHAR2,
	P_POS POSITIVEN := 1, P_NTH POSITIVEN := 1,
	P_EOD VARCHAR2 := NULL)
RETURN VARCHAR2
IS
	vStartPos	PLS_INTEGER;
	vEndPos		PLS_INTEGER;
BEGIN
	IF (P_POS = 1) THEN
		vStartPos := 1;
	ELSE
		vStartPos := INSTR(P_STRING, P_DELIMIT, 1, P_POS - 1);
		IF (vStartPos = 0) THEN
			RETURN P_EOD;
		END IF;
		vStartPos := vStartPos + 1;
	END IF;
	vEndPos := INSTR(P_STRING, P_DELIMIT, vStartPos, P_NTH);
	IF (vEndPos = 0) THEN
		RETURN SUBSTR(P_STRING, vStartPos);
	END IF;
	RETURN SUBSTR(P_STRING, vStartPos, vEndPos - vStartPos);
END;

/******************************************************************************/
--  HISTデータ作成
-- 【引数】
--   
/******************************************************************************/
PROCEDURE MakeHist(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_CIP_PLAN_HIST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	)
	SELECT
		IF_Flag
		,IF_Seq
		,vNOWDATE
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_LAST
	;
	DELETE FROM FUT_CIP_PLAN_LAST
	;
END;
/******************************************************************************/
--  LASTデータ作成
-- 【引数】
--   
/******************************************************************************/
PROCEDURE MakeLast(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_CIP_PLAN_LAST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	)
	SELECT
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_NEW
	;
	DELETE FROM FUT_CIP_PLAN_NEW
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
		-- 製造CIP結果(充填)の読込
		FETCH cProResult INTO vProResult;
		EXIT WHEN cProResult%NOTFOUND;

		-- 変数初期化
		nProduct_Seq := 0;
		vCIPStartTime := vProResult.PRODUCT_START_DATE;

		FOR i IN 1..vProResult.CIPNUM LOOP
			vCIPLEN_WK := strtoken(vProResult.CIPLEN, ',', i);
			vCIPTERM_WK := strtoken(vProResult.CIPTERM, ',', i);

			IF (vCIPLEN_WK IS NOT NULL AND vCIPTERM_WK IS NOT NULL) THEN
				vCIPStartTime := vCIPStartTime + (TO_NUMBER(vCIPTERM_WK) / 24 / 60);
				vCIPEndTime := vCIPStartTime + (TO_NUMBER(vCIPLEN_WK) / 24 / 60);

				-- 格納
				nIF_Seq := nIF_Seq + 1;
				nProduct_Seq := nProduct_Seq + 1;
				INSERT INTO FUT_CIP_PLAN_NEW
				(
					IF_Flag
					,IF_Seq
					,IF_Date
					,Product_ID
					,Product_Seq
					,Process_Code
					,Line_Code
					,Line_Group_Code
					,CIP_Start_Date
					,CIP_End_Date
				) VALUES (
					'0'
					,nIF_Seq
					,vNOWDATE
					,vProResult.Product_ID
					,nProduct_Seq
					,vProResult.Process_Code
					,vProResult.Line_Code
					,vProResult.Line_Group_Code
					,vCIPStartTime
					,vCIPEndTime
				)
				;
				vCIPStartTime := vCIPEndTime;
			END IF;

		END LOOP;

	END LOOP;
	CLOSE cProResult;

	OPEN cSetupResult(inCOMCD,inDIVCD);
	LOOP
		-- 製造切替結果(充填)の読込
		FETCH cSetupResult INTO vSetupResult;
		EXIT WHEN cSetupResult%NOTFOUND;

		-- 変数初期化
		nProduct_Seq := 0;

		-- 格納
		nIF_Seq := nIF_Seq + 1;
		nProduct_Seq := nProduct_Seq + 1;
		INSERT INTO FUT_CIP_PLAN_NEW
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		) VALUES (
			'0'
			,nIF_Seq
			,vNOWDATE
			,' '		-- vSetupResult.Product_ID
			,0			-- nProduct_Seq
			,vSetupResult.Process_Code
			,vSetupResult.Line_Code
			,vSetupResult.Line_Group_Code
			,vSetupResult.START_DATE
			,vSetupResult.END_DATE
		)
		;
	END LOOP;
	CLOSE cSetupResult;
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
		INSERT INTO FUT_CIP_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		) VALUES (
			'1'
			,nIF_Seq
			,vNOWDATE
			,vProAka.Product_ID
			,vProAka.Product_Seq
			,vProAka.Process_Code
			,vProAka.Line_Code
			,vProAka.Line_Group_Code
			,vProAka.CIP_Start_Date
			,vProAka.CIP_End_Date
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
		INSERT INTO FUT_CIP_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		) VALUES (
			'0'
			,nIF_Seq
			,vNOWDATE
			,vProKuro.Product_ID
			,vProKuro.Product_Seq
			,vProKuro.Process_Code
			,vProKuro.Line_Code
			,vProKuro.Line_Group_Code
			,vProKuro.CIP_Start_Date
			,vProKuro.CIP_End_Date
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

	PrintLog(cSID || '製造計画CIPトラン出力 開始');
	
	nCnt := 0;
	nDel := 0;
	nErr := 0;
	
	-- 現在時刻取得
	SELECT SYSDATE
	INTO vNOWDATE	
	FROM DUAL;

	PrintLog(cSID || '製造計画CIP履歴退避 開始');
	MakeHist(vNOWDATE);
	PrintLog(cSID || '製造計画CIP履歴退避 終了');

	PrintLog(cSID || '製造計画CIP前回作成 開始');
	MakeLast(vNOWDATE);
	PrintLog(cSID || '製造計画CIP前回作成 終了');

	PrintLog(cSID || '製造計画CIP最新作成 開始');
	MakeNew(vNOWDATE);
	PrintLog(cSID || '製造計画CIP最新作成 終了');

	PrintLog(cSID || '生産計画CIP作成 開始');
	MakeAkaKuro(vNOWDATE);
	PrintLog(cSID || '生産計画CIP作成 終了');
	
	COMMIT;

	PrintLog(cSID || '処理件数 ' || nCnt || ' (削除件数 ' || nDel || ' )' || ' (エラー件数 ' || nErr || ' )');
	PrintLog(cSID || '製造計画CIPトラン出力 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '製造計画CIPトラン出力 エラー終了');
		RAISE;

END;

/

EXIT;

