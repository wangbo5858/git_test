/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- システム情報更新
-- 【引数】
--   &1  : スキーマ名(PPS用のスキーマ)
--   &2  : 会社コード
--   &3  : 事業部コード
--   &4  : 工場コード
--   &5  : 指定日
/******************************************************************************/

DECLARE
	arg_date      CONSTANT VARCHAR2(100) := '&5';
	var_base_date DATE;
BEGIN
	var_base_date := SYSDATE;
	IF arg_date <> '*' THEN
		var_base_date := TO_DATE(REPLACE(REPLACE(arg_date,'/',''),'-',''),'YYYYMMDD');
	END IF;

	-- 計画規則の更新
	UPDATE FAD_PLANNING_RULE TG
	SET TG.APPOINT_TODAY = TRUNC(var_base_date, 'DD')
	;

	-- 排他クリア
	DELETE FROM FAD_ITEM_EXCLUSIVE;		/* 品目排他 */
	DELETE FROM FAD_LOAD_EXCLUSIVE;		/* 負荷排他 */
	DELETE FROM FAD_TABLE_EXCLUSIVE;	/* テーブル排他 */

	-- カウント・クリア
	DELETE FROM FAN_MENU_RUN_CNT;

	COMMIT;
END;
/

EXIT;
