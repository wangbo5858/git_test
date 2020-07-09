/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 品目号機マスタ取込 工程順序マスタ更新
-- 【引数】
--   &1  : スキーマ名(PPS用のスキーマ)
--   &2  : 会社コード
--   &3  : 事業部コード
--   &4  : 工場コード
-- 【備考】
-- 
/******************************************************************************/

DECLARE

inCOMCD   VARCHAR2(25) := '&2';  -- 会社コード
inDIVCD   VARCHAR2(25) := '&3';  -- 事業部コード
inPLTCD   VARCHAR2(25) := '&4';  -- 工場コード

cDEL	VARCHAR2(1) := '1';	-- 連携フラグ：削除
cSID	VARCHAR2(25) := 'PFS_V305_03';	-- サブシステムID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ユーザ

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

	PrintLog(cSID || '品目号機マスタ取込 工程順序マスタ更新 開始');
	
	MERGE INTO &1 .FMI_PROCESS_SEQUENCE FPS -- [工程順序]
	USING (
		SELECT DISTINCT
			 PS.ITEM_CODE        ITEM_CODE
			,PS.PROCESS_CODE     PROCESS_CODE
			,LPP.PROCESS_PATTERN PROCESS_PATTERN
		FROM FMI_PROCESS_SEQUENCE PS INNER JOIN 
			(
			SELECT
				 LPP1.COMPANY_CODE            COMPANY_CODE
				,LPP1.DIVISION_CODE           DIVISION_CODE
				,LPP1.ITEM_CODE               ITEM_CODE
				,LPP1.PROCESS_PATTERN         PROCESS_PATTERN
			FROM FMR_LINE_PRODUCT_PROCESS LPP1 INNER JOIN
				 (
					SELECT
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEM_CODE
						,PROCESS_PATTERN
						,MIN(PRIORITY) PRIORITY
					FROM FMR_LINE_PRODUCT_PROCESS
					GROUP BY COMPANY_CODE, DIVISION_CODE, ITEM_CODE, PROCESS_PATTERN
				 ) LPP2
				ON      LPP1.COMPANY_CODE    = inCOMCD
				 	AND LPP1.DIVISION_CODE   = inDIVCD
				 	AND LPP2.COMPANY_CODE    = inCOMCD
					AND LPP2.DIVISION_CODE   = inDIVCD
					AND LPP1.ITEM_CODE       = LPP2.ITEM_CODE
					AND LPP1.PROCESS_PATTERN = LPP2.PROCESS_PATTERN
					AND LPP1.PRIORITY        = LPP2.PRIORITY
				GROUP BY LPP1.COMPANY_CODE, LPP1.DIVISION_CODE, LPP1.ITEM_CODE, LPP1.PROCESS_PATTERN
			) LPP
			ON (
					PS.COMPANY_CODE    = LPP.COMPANY_CODE
				AND PS.DIVISION_CODE   = LPP.DIVISION_CODE
				AND PS.ITEM_CODE       = LPP.ITEM_CODE
			)
	) UPS
	ON (
			FPS.COMPANY_CODE    = inCOMCD
		AND FPS.DIVISION_CODE   = inDIVCD
		AND FPS.ITEM_CODE       = UPS.ITEM_CODE
		AND FPS.PROCESS_PATTERN = UPS.PROCESS_PATTERN
	)
	WHEN MATCHED THEN
		UPDATE SET
			 PROCESS_CODE = UPS.PROCESS_CODE
			,UPD_SID      = cSID
			,UPD_USER     = cUSER
			,UPD_DATE     = SYSDATE
	WHEN NOT MATCHED THEN
		INSERT (
			 COMPANY_CODE
			,DIVISION_CODE
			,ITEM_CODE
			,PROCESS_PATTERN
			,PROCESS_SEQ
			,PROCESS_CODE
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
			,UPS.PROCESS_PATTERN
			,999
			,UPS.PROCESS_CODE
			,cSID
			,cUSER
			,SYSDATE
			,cSID
			,cUSER
			,SYSDATE
		)
	;
	-- 工程パターンに'*' 以外があれば、'*'の工程順序を削除する。
	DELETE FROM FMI_PROCESS_SEQUENCE FPS
	WHERE
		    FPS.COMPANY_CODE    = inCOMCD
		AND FPS.DIVISION_CODE   = inDIVCD
		AND FPS.PROCESS_PATTERN = '*'
		AND EXISTS (
			SELECT * FROM FMI_PROCESS_SEQUENCE FPS2
			WHERE
				    FPS2.COMPANY_CODE     = FPS.COMPANY_CODE
				AND FPS2.DIVISION_CODE    = FPS.DIVISION_CODE
				AND FPS2.ITEM_CODE        = FPS.ITEM_CODE
				AND FPS2.PROCESS_PATTERN <> '*'
			)
	;
	COMMIT;
	
	PrintLog(cSID || '品目号機マスタ取込 工程順序マスタ更新 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '品目号機マスタ取込 工程順序マスタ更新 エラー終了');
		RAISE;

END;
/

