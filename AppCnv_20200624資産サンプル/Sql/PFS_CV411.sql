/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 製造依頼トラン取込後処理
--   製造依頼TBL（内部）の品目構成更新フラグを更新なし（0）に、取込済フラグをあり（1）に、更新する。
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

cSID	VARCHAR2(25) := 'PFS_CV411';	-- サブシステムID

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

	PrintLog(cSID || '製造依頼トラン取込後処理 開始');
	
	UPDATE FUT_PRODUCT_REQUIRE_ALL SET Flg = '1' WHERE BOM_Upd_Flag = '1';
	UPDATE FUT_PRODUCT_REQUIRE_ALL SET BOM_Upd_Flag = '0';
	
	COMMIT;

	PrintLog(cSID || '製造依頼トラン取込後処理 終了');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '製造依頼トラン取込後処理 エラー終了');
		RAISE;

END;
/

EXIT;

