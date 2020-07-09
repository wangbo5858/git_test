/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �i�ڃ}�X�^�捞
-- �y�����z
--   &1  : �X�L�[�}��(PPS�p�̃X�L�[�})
--   &2  : ��ЃR�[�h
--   &3  : ���ƕ��R�[�h
--   &4  : �H��R�[�h
-- �y���l�z
-- 
/******************************************************************************/
SET VERIFY       OFF
SET ECHO         OFF
SET TRIMSPOOL    ON
SET WRAP         ON
SET LINESIZE     2000
SET SERVEROUTPUT ON

DECLARE

inCOMCD   VARCHAR2(25) := '&2';  -- ��ЃR�[�h
inDIVCD   VARCHAR2(25) := '&3';  -- ���ƕ��R�[�h
inPLTCD   VARCHAR2(25) := '&4';  -- �H��R�[�h

cDEL	VARCHAR2(1) := '1';	-- �A�g�t���O�F�폜
cSID	VARCHAR2(25) := 'PFS_CV303';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cItem IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,ITEM_CODE
		,ITEM_CODE2
		,ITEM_ABBRE
		,ITEM_NAME
		,ITEM_NAME2
		,BRAND_CODE
		,BRAND_NAME
		,PROCESS_CODE
		,HON_CASE
		,ML_HON
		,CASE_PALLET
		,MULTI_PACK
		,PLATE
		,BOTTLE_SIZE
		,FLAVOR
		,DISPLAY_FLAG
	FROM FUM_ITEM
	ORDER BY IF_SEQ
	;
vItemRec	cItem%ROWTYPE;

vMULTI_PACK		VARCHAR2(25);
vPLATE			VARCHAR2(25);
vBOTTLE_SIZE	VARCHAR2(25);
vFLAVOR			VARCHAR2(25);

nCnt	NUMBER;
nDel	NUMBER;

/******************************************************************************/
--  ���O�o��
-- �y�����z
--   pinMessage  : ���b�Z�[�W
/******************************************************************************/
PROCEDURE PrintLog(pinMessage VARCHAR2) IS
BEGIN
	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY/MM/DD HH24:MI:SS.FF3') || ' : ' || pinMessage);
END;


/***************************/
/* ���C������              */
/***************************/
BEGIN

	PrintLog(cSID || '�i�ڃ}�X�^�捞 �J�n');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cItem;
	LOOP
		-- �i��(IN)�̓Ǎ�
		FETCH cItem INTO vItemRec;
		EXIT WHEN cItem%NOTFOUND;
		
		IF vItemRec.IF_FLAG <> cDEL THEN
		-- �ǉ��E�X�V����
		-- �i��
			MERGE INTO &1 .FMI_ITEM FI -- [�i��]
			USING (
				SELECT
					 vItemRec.ITEM_CODE     ITEM_CODE
					,vItemRec.ITEM_CODE2    ITEM_CODE2
					,vItemRec.ITEM_ABBRE    ITEM_ABBRE
					,vItemRec.ITEM_NAME     ITEM_NAME
					,vItemRec.ITEM_NAME2    ITEM_NAME2
					,vItemRec.BRAND_CODE    BRAND_CODE
					,vItemRec.BRAND_NAME    BRAND_NAME
					,vItemRec.PROCESS_CODE  PROCESS_CODE
					,vItemRec.HON_CASE      HON_CASE
					,vItemRec.ML_HON        ML_HON
					,vItemRec.CASE_PALLET   CASE_PALLET
					,vItemRec.MULTI_PACK    MULTI_PACK
					,vItemRec.PLATE         PLATE
					,vItemRec.BOTTLE_SIZE   BOTTLE_SIZE
					,vItemRec.FLAVOR        FLAVOR
					,vItemRec.DISPLAY_FLAG  DISPLAY_FLAG
				FROM DUAL
			) UI
			ON (
					FI.COMPANY_CODE   = inCOMCD
				AND FI.DIVISION_CODE  = inDIVCD
				AND FI.ITEM_CODE      = UI.ITEM_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME         = UI.ITEM_NAME
					,ABBREVIATION = UI.ITEM_ABBRE
					,PROPERTY01   = TRIM(UI.BRAND_CODE)
					,PROPERTY02   = UI.BRAND_NAME
					,PROPERTY03   = TRIM(UI.ITEM_CODE2)
					,PROPERTY04   = UI.ITEM_NAME2
					,PROPERTY05   = UI.HON_CASE
					,PROPERTY06   = UI.ML_HON
					,PROPERTY07   = UI.CASE_PALLET
					,PROPERTY08   = TRIM(UI.MULTI_PACK)
					,PROPERTY09   = TRIM(UI.PLATE)
					,PROPERTY10   = TRIM(UI.BOTTLE_SIZE)
					,PROPERTY11   = TRIM(UI.FLAVOR)
					,PROPERTY12   = UI.DISPLAY_FLAG
					,UPD_SID      = cSID
					,UPD_USER     = cUSER
					,UPD_DATE     = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,ITEM_CODE
					,NAME
					,ABBREVIATION
					,ITEM_TYPE
					,PROPERTY01
					,PROPERTY02
					,PROPERTY03
					,PROPERTY04
					,PROPERTY05
					,PROPERTY06
					,PROPERTY07
					,PROPERTY08
					,PROPERTY09
					,PROPERTY10
					,PROPERTY11
					,PROPERTY12
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
					,UI.ITEM_NAME
					,UI.ITEM_ABBRE
					,'4'
					,TRIM(UI.BRAND_CODE)
					,UI.BRAND_NAME
					,TRIM(UI.ITEM_CODE2)
					,UI.ITEM_NAME2
					,UI.HON_CASE
					,UI.ML_HON
					,UI.CASE_PALLET
					,TRIM(UI.MULTI_PACK)
					,TRIM(UI.PLATE)
					,TRIM(UI.BOTTLE_SIZE)
					,TRIM(UI.FLAVOR)
					,UI.DISPLAY_FLAG
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		-- �݌ɊǗ����
			MERGE INTO &1 .FMI_SKU FS -- [�i�݌ɊǗ����]
			USING (
				SELECT
					 vItemRec.ITEM_CODE     ITEM_CODE
					,vItemRec.PROCESS_CODE  PROCESS_CODE
				FROM DUAL
			) US
			ON (
					FS.COMPANY_CODE   = inCOMCD
				AND FS.DIVISION_CODE  = inDIVCD
				AND FS.LOCATION_CODE  = inPLTCD
				AND FS.ITEM_CODE      = US.ITEM_CODE
			)
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,ITEM_CODE
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
					,US.ITEM_CODE
					,CASE WHEN US.PROCESS_CODE = 'JYU' THEN 3 ELSE 2 END -- 3:End-Equal 2:Start-Equas
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		-- �H������
			MERGE INTO &1 .FMI_PROCESS_SEQUENCE FPS -- [�H������]
			USING (
				SELECT
					 vItemRec.ITEM_CODE     ITEM_CODE
					,vItemRec.PROCESS_CODE  PROCESS_CODE
				FROM DUAL
			) UPS
			ON (
					FPS.COMPANY_CODE   = inCOMCD
				AND FPS.DIVISION_CODE  = inDIVCD
				AND FPS.ITEM_CODE      = UPS.ITEM_CODE
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
					,'*'
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
			vBOTTLE_SIZE := TRIM(vItemRec.BOTTLE_SIZE);
			IF vBOTTLE_SIZE IS NOT NULL THEN
			-- �i�ڃO���[�v��`
				MERGE INTO &1 .FMI_ITEMGROUP_DEFINE FID -- [�i�ڃO���[�v��`]
				USING (
					SELECT
						 vItemRec.ITEM_CODE ITEM_CODE
						,vBOTTLE_SIZE       ITEMGROUP_CODE
					FROM DUAL
				) UFID
				ON (
						FID.COMPANY_CODE   = inCOMCD
					AND FID.DIVISION_CODE  = inDIVCD
					AND FID.ITEMGROUP_CODE = UFID.ITEMGROUP_CODE
					AND FID.ITEM_CODE      = UFID.ITEM_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEMGROUP_CODE
						,ITEM_CODE
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UFID.ITEMGROUP_CODE
						,UFID.ITEM_CODE
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			-- �i�ڃO���[�v
				MERGE INTO &1 .FMI_ITEMGROUP FIG -- [�i�ڃO���[�v]
				USING (
					SELECT
						 vBOTTLE_SIZE   ITEMGROUP_CODE
					FROM DUAL
				) UIG
				ON (
						FIG.COMPANY_CODE   = inCOMCD
					AND FIG.DIVISION_CODE  = inDIVCD
					AND FIG.ITEMGROUP_CODE = UIG.ITEMGROUP_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEMGROUP_CODE
						,NAME
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UIG.ITEMGROUP_CODE
						,UIG.ITEMGROUP_CODE
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			END IF;
			vFLAVOR := TRIM(vItemRec.FLAVOR);
			IF vFLAVOR IS NOT NULL THEN
			-- �i�ڃO���[�v��`
				MERGE INTO &1 .FMI_ITEMGROUP_DEFINE FID -- [�i�ڃO���[�v��`]
				USING (
					SELECT
						 vItemRec.ITEM_CODE  ITEM_CODE
						,vFLAVOR             ITEMGROUP_CODE
					FROM DUAL
				) UFID
				ON (
						FID.COMPANY_CODE   = inCOMCD
					AND FID.DIVISION_CODE  = inDIVCD
					AND FID.ITEMGROUP_CODE = UFID.ITEMGROUP_CODE
					AND FID.ITEM_CODE      = UFID.ITEM_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEMGROUP_CODE
						,ITEM_CODE
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UFID.ITEMGROUP_CODE
						,UFID.ITEM_CODE
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			-- �i�ڃO���[�v
				MERGE INTO &1 .FMI_ITEMGROUP FIG -- [�i�ڃO���[�v]
				USING (
					SELECT
						 vFLAVOR     ITEMGROUP_CODE
					FROM DUAL
				) UIG
				ON (
						FIG.COMPANY_CODE   = inCOMCD
					AND FIG.DIVISION_CODE  = inDIVCD
					AND FIG.ITEMGROUP_CODE = UIG.ITEMGROUP_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEMGROUP_CODE
						,NAME
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UIG.ITEMGROUP_CODE
						,UIG.ITEMGROUP_CODE
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			END IF;
		-- BOTTLE_SIZE�AFLAVOR�̕ύX�ɂ���ĕi�ڃO���[�v��`���c����̂��폜
		-- �i�ڃO���[�v
			DELETE
			FROM &1 .FMI_ITEMGROUP FIG
			WHERE
				    FIG.COMPANY_CODE    = inCOMCD
				AND FIG.DIVISION_CODE   = inDIVCD
				AND FIG.ITEMGROUP_CODE IN (
					SELECT ITEMGROUP_CODE
					FROM &1 .FMI_ITEMGROUP_DEFINE
					WHERE 
						    COMPANY_CODE    = inCOMCD
						AND DIVISION_CODE   = inDIVCD
					GROUP BY ITEMGROUP_CODE
					HAVING COUNT(ITEMGROUP_CODE) = 1
				)
				AND FIG.ITEMGROUP_CODE IN (
					SELECT ITEMGROUP_CODE FROM &1 .FMI_ITEMGROUP_DEFINE FID
					WHERE 
						    FID.COMPANY_CODE    = inCOMCD
						AND FID.DIVISION_CODE   = inDIVCD
						AND FID.ITEM_CODE       = vItemRec.ITEM_CODE
					MINUS
					(
					SELECT ITEMGROUP_CODE FROM &1 .FMI_ITEMGROUP_DEFINE FID
					WHERE 
						    FID.COMPANY_CODE    = inCOMCD
						AND FID.DIVISION_CODE   = inDIVCD
						AND FID.ITEM_CODE       = vItemRec.ITEM_CODE
						AND FID.ITEMGROUP_CODE  = vBOTTLE_SIZE
					UNION
					SELECT ITEMGROUP_CODE FROM &1 .FMI_ITEMGROUP_DEFINE FID
					WHERE 
						    FID.COMPANY_CODE    = inCOMCD
						AND FID.DIVISION_CODE   = inDIVCD
						AND FID.ITEM_CODE       = vItemRec.ITEM_CODE
						AND FID.ITEMGROUP_CODE  = vFLAVOR
					)
				)
			;
		-- �i�ڃO���[�v��`
			DELETE
			FROM &1 .FMI_ITEMGROUP_DEFINE
			WHERE
				    COMPANY_CODE   = inCOMCD
				AND DIVISION_CODE  = inDIVCD
				AND ITEM_CODE      = vItemRec.ITEM_CODE
				AND ITEMGROUP_CODE NOT IN (
					SELECT ITEMGROUP_CODE FROM &1 .FMI_ITEMGROUP_DEFINE FID
					WHERE 
						    FID.COMPANY_CODE    = inCOMCD
						AND FID.DIVISION_CODE   = inDIVCD
						AND FID.ITEM_CODE       = vItemRec.ITEM_CODE
						AND FID.ITEMGROUP_CODE  = vBOTTLE_SIZE
					UNION
					SELECT ITEMGROUP_CODE FROM &1 .FMI_ITEMGROUP_DEFINE FID
					WHERE 
						    FID.COMPANY_CODE    = inCOMCD
						AND FID.DIVISION_CODE   = inDIVCD
						AND FID.ITEM_CODE       = vItemRec.ITEM_CODE
						AND FID.ITEMGROUP_CODE  = vFLAVOR
					)
			;
			vMULTI_PACK := TRIM(vItemRec.MULTI_PACK);
			IF vMULTI_PACK IS NOT NULL THEN
			-- ��L����
				MERGE INTO &1 .FMR_POSSESS_RESOURCE FPR -- [��L����]
				USING (
					SELECT
						 vMULTI_PACK   POSSESS_RESOURCE_CODE
					FROM DUAL
				) UPR
				ON (
						FPR.COMPANY_CODE          = inCOMCD
					AND FPR.DIVISION_CODE         = inDIVCD
					AND FPR.POSSESS_RESOURCE_CODE = UPR.POSSESS_RESOURCE_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,POSSESS_RESOURCE_CODE
						,NAME
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UPR.POSSESS_RESOURCE_CODE
						,UPR.POSSESS_RESOURCE_CODE
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			-- ��L�����菇
				MERGE INTO &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP -- [��L�����菇]
				USING (
					SELECT
						 vItemRec.ITEM_CODE  ITEM_CODE
						,vMULTI_PACK         POSSESS_RESOURCE_CODE
					FROM DUAL
				) UPPP
				ON (
						FPPP.COMPANY_CODE          = inCOMCD
					AND FPPP.DIVISION_CODE         = inDIVCD
					AND FPPP.ITEM_CODE             = UPPP.ITEM_CODE
					AND FPPP.POSSESS_RESOURCE_CODE = UPPP.POSSESS_RESOURCE_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEM_CODE
						,PROCESS_PATTERN
						,PROCESS_SEQ
						,LINE_RESOURCE_CODE
						,POSSESS_PATTERN
						,POSSESS_RESOURCE_CODE
						,TIME_RELATION_TYPE
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UPPP.ITEM_CODE
						,'*'
						,-999
						,'*'
						,'*'
						,UPPP.POSSESS_RESOURCE_CODE
						,1
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			END IF;
			vPLATE := TRIM(vItemRec.PLATE);
			IF vPLATE IS NOT NULL THEN
			-- ��L����
				MERGE INTO &1 .FMR_POSSESS_RESOURCE FPR -- [��L����]
				USING (
					SELECT
						 vPLATE  POSSESS_RESOURCE_CODE
					FROM DUAL
				) UPR
				ON (
						FPR.COMPANY_CODE          = inCOMCD
					AND FPR.DIVISION_CODE         = inDIVCD
					AND FPR.POSSESS_RESOURCE_CODE = UPR.POSSESS_RESOURCE_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,POSSESS_RESOURCE_CODE
						,NAME
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UPR.POSSESS_RESOURCE_CODE
						,UPR.POSSESS_RESOURCE_CODE
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			-- ��L�����菇
				MERGE INTO &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP -- [��L�����菇]
				USING (
					SELECT
						 vItemRec.ITEM_CODE  ITEM_CODE
						,vPLATE              POSSESS_RESOURCE_CODE
					FROM DUAL
				) UPPP
				ON (
						FPPP.COMPANY_CODE          = inCOMCD
					AND FPPP.DIVISION_CODE         = inDIVCD
					AND FPPP.ITEM_CODE             = UPPP.ITEM_CODE
					AND FPPP.POSSESS_RESOURCE_CODE = UPPP.POSSESS_RESOURCE_CODE
				)
				WHEN NOT MATCHED THEN
					INSERT (
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEM_CODE
						,PROCESS_PATTERN
						,PROCESS_SEQ
						,LINE_RESOURCE_CODE
						,POSSESS_PATTERN
						,POSSESS_RESOURCE_CODE
						,TIME_RELATION_TYPE
						,PRIORITY
						,INS_SID
						,INS_USER
						,INS_DATE
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 inCOMCD
						,inDIVCD
						,UPPP.ITEM_CODE
						,'*'
						,-999
						,'*'
						,'*'
						,UPPP.POSSESS_RESOURCE_CODE
						,1
						,0
						,cSID
						,cUSER
						,SYSDATE
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			END IF;
		--  MULTI_PACK�APLATE�̕ύX�ɂ���Đ�L�������c����̂��폜
		-- ��L����
			DELETE
			FROM &1 .FMR_POSSESS_RESOURCE FPR
			WHERE
				    FPR.COMPANY_CODE    = inCOMCD
				AND FPR.DIVISION_CODE   = inDIVCD
				AND FPR.POSSESS_RESOURCE_CODE IN (
					SELECT POSSESS_RESOURCE_CODE
					FROM (
						SELECT POSSESS_RESOURCE_CODE, ITEM_CODE
						FROM &1 .FMR_POSSESS_PRODUCT_PROCESS
						WHERE 
							    COMPANY_CODE    = inCOMCD
							AND DIVISION_CODE   = inDIVCD
						GROUP BY POSSESS_RESOURCE_CODE, ITEM_CODE
					)
					GROUP BY POSSESS_RESOURCE_CODE
					HAVING COUNT(POSSESS_RESOURCE_CODE) = 1
				)
				AND FPR.POSSESS_RESOURCE_CODE IN (
					SELECT POSSESS_RESOURCE_CODE FROM &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP
					WHERE 
						    FPPP.COMPANY_CODE          = inCOMCD
						AND FPPP.DIVISION_CODE         = inDIVCD
						AND FPPP.ITEM_CODE             = vItemRec.ITEM_CODE
					MINUS
					(
					SELECT POSSESS_RESOURCE_CODE FROM &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP
					WHERE 
						    FPPP.COMPANY_CODE          = inCOMCD
						AND FPPP.DIVISION_CODE         = inDIVCD
						AND FPPP.ITEM_CODE             = vItemRec.ITEM_CODE
						AND FPPP.POSSESS_RESOURCE_CODE = vMULTI_PACK
					UNION
					SELECT POSSESS_RESOURCE_CODE FROM &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP
					WHERE 
						    FPPP.COMPANY_CODE          = inCOMCD
						AND FPPP.DIVISION_CODE         = inDIVCD
						AND FPPP.ITEM_CODE             = vItemRec.ITEM_CODE
						AND FPPP.POSSESS_RESOURCE_CODE = vPLATE
					)
				)
			;
		-- ��L�����菇
			DELETE
			FROM &1 .FMR_POSSESS_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE          = inCOMCD
				AND DIVISION_CODE         = inDIVCD
				AND ITEM_CODE             = vItemRec.ITEM_CODE
				AND POSSESS_RESOURCE_CODE NOT IN (
					SELECT POSSESS_RESOURCE_CODE FROM &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP
					WHERE 
						    FPPP.COMPANY_CODE          = inCOMCD
						AND FPPP.DIVISION_CODE         = inDIVCD
						AND FPPP.ITEM_CODE             = vItemRec.ITEM_CODE
						AND FPPP.POSSESS_RESOURCE_CODE = vMULTI_PACK
					UNION
					SELECT POSSESS_RESOURCE_CODE FROM &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP
					WHERE 
						    FPPP.COMPANY_CODE          = inCOMCD
						AND FPPP.DIVISION_CODE         = inDIVCD
						AND FPPP.ITEM_CODE             = vItemRec.ITEM_CODE
						AND FPPP.POSSESS_RESOURCE_CODE = vPLATE
					)
			;
		ELSE
		-- �폜����
		-- �i��
			DELETE
			FROM &1 .FMI_ITEM
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vItemRec.ITEM_CODE
			;
		-- �݌ɊǗ����
			DELETE
			FROM &1 .FMI_SKU
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND LOCATION_CODE = inPLTCD
				AND ITEM_CODE     = vItemRec.ITEM_CODE
			;
		-- �H������
			DELETE
			FROM &1 .FMI_PROCESS_SEQUENCE
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vItemRec.ITEM_CODE
			;
		-- �i�ڃO���[�v
			DELETE
			FROM &1 .FMI_ITEMGROUP FIG
			WHERE
				    FIG.COMPANY_CODE    = inCOMCD
				AND FIG.DIVISION_CODE   = inDIVCD
				AND FIG.ITEMGROUP_CODE IN (
					SELECT ITEMGROUP_CODE
					FROM &1 .FMI_ITEMGROUP_DEFINE
					WHERE 
						    COMPANY_CODE    = inCOMCD
						AND DIVISION_CODE   = inDIVCD
					GROUP BY ITEMGROUP_CODE
					HAVING COUNT(ITEMGROUP_CODE) = 1
				)
				AND EXISTS (
					SELECT * FROM &1 .FMI_ITEMGROUP_DEFINE FID
					WHERE 
						    FID.COMPANY_CODE   = inCOMCD
						AND FID.DIVISION_CODE  = inDIVCD
						AND FID.ITEM_CODE      = vItemRec.ITEM_CODE
						AND FID.ITEMGROUP_CODE = FIG.ITEMGROUP_CODE
				)
			;
		-- �i�ڃO���[�v��`
			DELETE
			FROM &1 .FMI_ITEMGROUP_DEFINE
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vItemRec.ITEM_CODE
			;
		-- ��L�����i��L�����菇�ƕR�t���č폜�j
			DELETE
			FROM &1 .FMR_POSSESS_RESOURCE FPR
			WHERE
				    FPR.COMPANY_CODE    = inCOMCD
				AND FPR.DIVISION_CODE   = inDIVCD
				AND FPR.POSSESS_RESOURCE_CODE IN (
					SELECT POSSESS_RESOURCE_CODE
					FROM (
						SELECT POSSESS_RESOURCE_CODE, ITEM_CODE
						FROM &1 .FMR_POSSESS_PRODUCT_PROCESS
						WHERE 
							    COMPANY_CODE    = inCOMCD
							AND DIVISION_CODE   = inDIVCD
						GROUP BY POSSESS_RESOURCE_CODE, ITEM_CODE
					)
					GROUP BY POSSESS_RESOURCE_CODE
					HAVING COUNT(POSSESS_RESOURCE_CODE) = 1
				)
				AND EXISTS (
					SELECT * FROM &1 .FMR_POSSESS_PRODUCT_PROCESS FPPP
					WHERE 
						    FPPP.COMPANY_CODE          = inCOMCD
						AND FPPP.DIVISION_CODE         = inDIVCD
						AND FPPP.ITEM_CODE             = vItemRec.ITEM_CODE
						AND FPPP.POSSESS_RESOURCE_CODE = FPR.POSSESS_RESOURCE_CODE
				)
			;
		-- ��L�����菇
			DELETE
			FROM &1 .FMR_POSSESS_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE          = inCOMCD
				AND DIVISION_CODE         = inDIVCD
				AND ITEM_CODE             = vItemRec.ITEM_CODE
			;
			nDel := nDel + 1;
		END IF;
		
		-- �i�ڗ����ɒǉ�
		INSERT INTO FUM_ITEM_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,ITEM_CODE
			,ITEM_CODE2
			,ITEM_ABBRE
			,ITEM_NAME
			,ITEM_NAME2
			,BRAND_CODE
			,BRAND_NAME
			,PROCESS_CODE
			,HON_CASE
			,ML_HON
			,CASE_PALLET
			,MULTI_PACK
			,PLATE
			,BOTTLE_SIZE
			,FLAVOR
			,DISPLAY_FLAG
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vItemRec.IF_FLAG
			,vItemRec.IF_SEQ
			,SYSDATE
			,vItemRec.ITEM_CODE
			,vItemRec.ITEM_CODE2
			,vItemRec.ITEM_ABBRE
			,vItemRec.ITEM_NAME
			,vItemRec.ITEM_NAME2
			,vItemRec.BRAND_CODE
			,vItemRec.BRAND_NAME
			,vItemRec.PROCESS_CODE
			,vItemRec.HON_CASE
			,vItemRec.ML_HON
			,vItemRec.CASE_PALLET
			,vItemRec.MULTI_PACK
			,vItemRec.PLATE
			,vItemRec.BOTTLE_SIZE
			,vItemRec.FLAVOR
			,vItemRec.DISPLAY_FLAG
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- �i��(IN)����폜
		DELETE FROM FUM_ITEM
		WHERE IF_SEQ = vItemRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cItem;
	
	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )');
	PrintLog(cSID || '�i�ڃ}�X�^�捞 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�i�ڃ}�X�^�捞 �G���[�I��');
		RAISE;

END;
/

EXIT;

