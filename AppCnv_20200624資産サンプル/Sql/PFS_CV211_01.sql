/* 例外エラーによる対応 */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- 過去データ削除
-- 【引数】
--   &1  : スキーマ名(PPS用のスキーマ)
--   &2  : 会社コード
--   &3  : 事業部コード
--   &4  : 工場コード
--   &5  : 削除日数
-- 【備考】
--
/******************************************************************************/

-- 製造計画を削除
DELETE FROM &1 .FTP_PRODUCT_SCHEDULE TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 PS.COMPANY_CODE
					,PS.DIVISION_CODE
					,PS.PRODUCT_ID
				FROM
					 &1 .FTP_PRODUCT_ORDER PO
					,&1 .FTP_PRODUCT_SCHEDULE PS
					,&1 .FTP_LOCATION_SCHEDULE LS
				WHERE
				 	    LS.KEY_TYPE = 1
					AND LS.RESOURCE_TYPE = 1
					AND LS.ASSIGN_FLG = 1
					AND PO.COMPANY_CODE = PS.COMPANY_CODE
					AND PO.DIVISION_CODE = PS.DIVISION_CODE
					AND PO.PRODUCT_ID = PS.PRODUCT_ID
					AND PS.COMPANY_CODE = LS.COMPANY_CODE
					AND PS.DIVISION_CODE = LS.DIVISION_CODE
					AND PS.PRODUCT_ID = LS.LOCATION_ID
					AND LS.START_DATE < TRUNC(SYSDATE - &5)
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.PRODUCT_ID = TG.PRODUCT_ID
	)
;

-- 製造オーダーを削除
DELETE FROM &1 .FTP_PRODUCT_ORDER TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 PO.COMPANY_CODE
					,PO.DIVISION_CODE
					,PO.PRODUCT_ID
				FROM
					 &1 .FTP_PRODUCT_ORDER PO
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    PO.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND PO.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND PO.PRODUCT_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.PRODUCT_ID = TG.PRODUCT_ID
	)
;

-- 配置計画を削除
DELETE FROM &1 .FTP_LOCATION_SCHEDULE TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 LS.COMPANY_CODE
					,LS.DIVISION_CODE
					,LS.LOCATION_ID
				FROM
					 &1 .FTP_LOCATION_SCHEDULE LS
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    LS.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND LS.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND LS.LOCATION_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.LOCATION_ID = TG.LOCATION_ID
	)
;

-- 占有資源配置計画を削除
DELETE FROM &1 .FTP_POSSESS_LOCATION_SCHEDULE TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 LS.COMPANY_CODE
					,LS.DIVISION_CODE
					,LS.LOCATION_ID
				FROM
					 &1 .FTP_POSSESS_LOCATION_SCHEDULE LS
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    LS.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND LS.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND LS.LOCATION_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.LOCATION_ID = TG.LOCATION_ID
	)
;

-- 切替計画 前後を削除
DELETE FROM &1 .FTP_SETUP_SCHEDULE TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 TG.COMPANY_CODE
					,TG.DIVISION_CODE
					,TG.PRODUCT_ID
				FROM
					 &1 .FTP_SETUP_SCHEDULE TG
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    TG.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND TG.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND TG.PRODUCT_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.PRODUCT_ID = TG.PRODUCT_ID
	)
;
DELETE FROM &1 .FTP_SETUP_SCHEDULE TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 TG.COMPANY_CODE
					,TG.DIVISION_CODE
					,TG.NEXT_PRODUCT_ID
				FROM
					 &1 .FTP_SETUP_SCHEDULE TG
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    TG.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND TG.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND TG.NEXT_PRODUCT_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.NEXT_PRODUCT_ID = TG.NEXT_PRODUCT_ID
	)
;

-- 切替サマリー 前後 を削除
DELETE FROM &1 .FTP_SETUP_SUMMARY TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 TG.COMPANY_CODE
					,TG.DIVISION_CODE
					,TG.PRODUCT_ID
				FROM
					 &1 .FTP_SETUP_SUMMARY TG
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    TG.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND TG.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND TG.PRODUCT_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.PRODUCT_ID = TG.PRODUCT_ID
	)
;
DELETE FROM &1 .FTP_SETUP_SUMMARY TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 TG.COMPANY_CODE
					,TG.DIVISION_CODE
					,TG.NEXT_PRODUCT_ID
				FROM
					 &1 .FTP_SETUP_SUMMARY TG
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    TG.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND TG.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND TG.NEXT_PRODUCT_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.NEXT_PRODUCT_ID = TG.NEXT_PRODUCT_ID
	)
;

-- 在庫情報
DELETE FROM &1 .FTI_STOCK_INFO FSI
WHERE
	FSI.ARRIVAL_DATE < TRUNC(SYSDATE - &5)
AND FSI.STOCK_TYPE = 2 -- 入庫予定
;

-- 入庫計画を削除
DELETE FROM &1 .FTI_ARRIVAL_SCHEDULE TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 TG.COMPANY_CODE
					,TG.DIVISION_CODE
					,TG.PRODUCT_ID
				FROM
					 &1 .FTI_ARRIVAL_SCHEDULE TG
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    TG.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND TG.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND TG.PRODUCT_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.PRODUCT_ID = TG.PRODUCT_ID
	)
;

-- 従属需要を削除
DELETE FROM &1 .FTI_DEPENDENT_DEMAND TG
WHERE
	EXISTS
	(
		SELECT
			*
		FROM
			(
				SELECT
					 TG.COMPANY_CODE
					,TG.DIVISION_CODE
					,TG.DEMAND_ID
				FROM
					 &1 .FTI_DEPENDENT_DEMAND TG
					,&1 .FTP_PRODUCT_SCHEDULE PS
				WHERE
					    TG.COMPANY_CODE = PS.COMPANY_CODE(+)
					AND TG.DIVISION_CODE = PS.DIVISION_CODE(+)
					AND TG.DEMAND_ID = PS.PRODUCT_ID(+)
					AND PS.PRODUCT_ID IS NULL
			) PL
		WHERE
			    PL.COMPANY_CODE = TG.COMPANY_CODE
			AND PL.DIVISION_CODE = TG.DIVISION_CODE
			AND PL.DEMAND_ID = TG.DEMAND_ID
	)
;

-- 製造実績
DELETE FROM &1 .FTR_PRODUCT_RESULT TG
WHERE
	TG.START_DATE < TRUNC(SYSDATE - &5)
;


-- 在庫基準カレンダー
DELETE FROM &1 .FTC_INVENTORY_CALENDAR FIC
WHERE
	FIC.CALENDAR_DATE < TRUNC(SYSDATE - &5)
;


COMMIT;

EXIT;
