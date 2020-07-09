/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 品目号機マスタ取込 品目マスタ更新1
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
cSID	VARCHAR2(25) := 'PFS_V305_02';	-- サブシステムID
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

	PrintLog(cSID || '品目号機マスタ取込 品目マスタ更新1 開始');
	
	UPDATE FMI_ITEM FI
	SET FI.ITEM_TYPE = NVL(
			(
			SELECT FP.PROPERTY01
			FROM (
					SELECT MIN(LPP1.LINE_RESOURCE_CODE) LINE_RESOURCE_CODE
					FROM FMR_LINE_PRODUCT_PROCESS LPP1 INNER JOIN
						 (
							SELECT
								 COMPANY_CODE
								,DIVISION_CODE
								,ITEM_CODE
								,MIN(PRIORITY) PRIORITY
							FROM FMR_LINE_PRODUCT_PROCESS
							GROUP BY COMPANY_CODE, DIVISION_CODE, ITEM_CODE
						 ) LPP2
						ON      LPP1.COMPANY_CODE  = inCOMCD
						 	AND LPP1.DIVISION_CODE = inDIVCD
						 	AND LPP1.ITEM_CODE     = FI.ITEM_CODE
						 	AND LPP2.COMPANY_CODE  = inCOMCD
							AND LPP2.DIVISION_CODE = inDIVCD
							AND LPP2.ITEM_CODE     = FI.ITEM_CODE
							AND LPP1.PRIORITY      = LPP2.PRIORITY
				) LPP
				INNER JOIN FMR_LINE_RESOURCE LR
				ON      LR.COMPANY_CODE       = inCOMCD
				 	AND LR.DIVISION_CODE      = inDIVCD
				 	AND LR.LINE_RESOURCE_CODE = LPP.LINE_RESOURCE_CODE
				INNER JOIN FMR_PROCESS FP
				ON      FP.COMPANY_CODE  = inCOMCD
				 	AND FP.DIVISION_CODE = inDIVCD
				 	AND FP.PROCESS_CODE  = LR.PROCESS_CODE
			)
			,'4')
	WHERE
		    EXISTS (
		    	SELECT * FROM FMR_LINE_PRODUCT_PROCESS
		    	WHERE
					    COMPANY_CODE   = inCOMCD
				 	AND DIVISION_CODE  = inDIVCD
				 	AND ITEM_CODE      = FI.ITEM_CODE
				)
	;
	COMMIT;

	PrintLog(cSID || '品目号機マスタ取込 品目マスタ更新1 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '品目号機マスタ取込 品目マスタ更新1 エラー終了');
		RAISE;

END;
/

