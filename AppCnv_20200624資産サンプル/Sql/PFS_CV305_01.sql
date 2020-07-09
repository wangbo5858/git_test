/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �i�ڍ��@�}�X�^�捞
-- �y�����z
--   &1  : �X�L�[�}��(PPS�p�̃X�L�[�})
--   &2  : ��ЃR�[�h
--   &3  : ���ƕ��R�[�h
--   &4  : �H��R�[�h
-- �y���l�z
-- 
/******************************************************************************/

DECLARE

inCOMCD   VARCHAR2(25) := '&2';  -- ��ЃR�[�h
inDIVCD   VARCHAR2(25) := '&3';  -- ���ƕ��R�[�h
inPLTCD   VARCHAR2(25) := '&4';  -- �H��R�[�h

cDEL	VARCHAR2(1) := '1';	-- �A�g�t���O�F�폜
cSID	VARCHAR2(25) := 'PFS_V305_01';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cItemLine IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,ITEM_CODE
		,PROCESS_PATTERN
		,LINE_RESOURCE_CODE
		,VALID_START
		,VALID_END
		,PRODUCT_SPEED
		,YIELD_RATE
		,CIP_INTERVAL
		,CIP_TIME
		,MIN_PRODUCT
		,INC_PRODUCT
		,MAX_PRODUCT
		,PROCES_LT
		,JPRINT_FLAG
		,PRIORITY
	FROM FUM_ITEM_LINE
	ORDER BY IF_SEQ
	;
vILineRec	cItemLine%ROWTYPE;

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

	PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �J�n');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cItemLine;
	LOOP
		-- �i�ڍ��@(IN)�̓Ǎ�
		FETCH cItemLine INTO vILineRec;
		EXIT WHEN cItemLine%NOTFOUND;
		
		IF vILineRec.IF_FLAG <> cDEL THEN
		-- �ǉ��E�X�V����
			MERGE INTO &1 .FMR_LINE_PRODUCT_PROCESS LPP -- [���C�������菇]
			USING (
				SELECT
					 IL.ITEM_CODE                     ITEM_CODE
					,IL.PROCESS_PATTERN               PROCESS_PATTERN
					,IL.LINE_RESOURCE_CODE            LINE_RESOURCE_CODE
					,IL.VALID_START                   VALID_START
					,IL.VALID_END                     VALID_END
					,IL.PRODUCT_SPEED                 PRODUCT_SPEED
					,IL.YIELD_RATE                    YIELD_RATE
					,IL.CIP_INTERVAL                  CIP_INTERVAL
					,IL.CIP_TIME                      CIP_TIME
					,IL.MIN_PRODUCT                   MIN_PRODUCT
					,IL.INC_PRODUCT                   INC_PRODUCT
					,IL.MAX_PRODUCT                   MAX_PRODUCT
					,IL.PROCES_LT                     PROCES_LT
					,IL.JPRINT_FLAG                   JPRINT_FLAG
					,IL.PRIORITY                      PRIORITY
					,BM.BOM_PATTERN                   BOM_PATTERN
				FROM (
					SELECT
						 vILineRec.ITEM_CODE            ITEM_CODE
						,vILineRec.PROCESS_PATTERN      PROCESS_PATTERN
						,vILineRec.LINE_RESOURCE_CODE   LINE_RESOURCE_CODE
						,vILineRec.VALID_START          VALID_START
						,vILinerec.VALID_END            VALID_END
						,vILineRec.PRODUCT_SPEED        PRODUCT_SPEED
						,vILineRec.YIELD_RATE           YIELD_RATE
						,vILineRec.CIP_INTERVAL         CIP_INTERVAL
						,vILineRec.CIP_TIME             CIP_TIME
						,vILineRec.MIN_PRODUCT          MIN_PRODUCT
						,vILineRec.INC_PRODUCT          INC_PRODUCT
						,vILineRec.MAX_PRODUCT          MAX_PRODUCT
						,vILineRec.PROCES_LT            PROCES_LT
						,vILineRec.JPRINT_FLAG          JPRINT_FLAG
						,vILineRec.PRIORITY             PRIORITY
					FROM DUAL
					) IL LEFT OUTER JOIN (
					SELECT
						 ITEM_CODE                      ITEM_CODE
						,PROCESS_PATTERN                PROCESS_PATTERN
						,MIN(BOM_PATTERN)               BOM_PATTERN
					FROM FMI_BOM BI
					WHERE
						    BI.ITEM_CODE       = vILineRec.ITEM_CODE
						AND BI.PROCESS_PATTERN = vILineRec.PROCESS_PATTERN
					GROUP BY BI.ITEM_CODE, BI.PROCESS_PATTERN
					) BM
					ON (
							IL.ITEM_CODE       = BM.ITEM_CODE
						AND IL.PROCESS_PATTERN = BM.PROCESS_PATTERN
					)
			) ULPP
			ON (
					LPP.COMPANY_CODE       = inCOMCD
				AND LPP.DIVISION_CODE      = inDIVCD
				AND LPP.ITEM_CODE          = ULPP.ITEM_CODE
				AND LPP.PROCESS_PATTERN    = ULPP.PROCESS_PATTERN
				AND LPP.PROCESS_SEQ        = 999
				AND LPP.LINE_RESOURCE_CODE = ULPP.LINE_RESOURCE_CODE
				AND LPP.VALID_START        = ULPP.VALID_START
			)
			WHEN MATCHED THEN
				UPDATE SET
					 UNIT_CAPACITY        = NVL(ULPP.PRODUCT_SPEED, 1)
					,VALID_END            = ULPP.VALID_END
					,STOP_INTERVAL1       = NVL(ULPP.CIP_INTERVAL, 0)
					,STOP_TIME_LENGTH1    = NVL(ULPP.CIP_TIME, 0)
					,PROPERTY01           = NVL(ULPP.PROCES_LT, 0)
					,PROPERTY02           = NVL(ULPP.JPRINT_FLAG, 0)
					,PROPERTY03           = NVL(ULPP.YIELD_RATE, 100)
					,PROPERTY04           = NVL(ULPP.MIN_PRODUCT, -1)
					,PROPERTY05           = NVL(ULPP.INC_PRODUCT, -1)
					,PROPERTY06           = NVL(ULPP.MAX_PRODUCT, -1)
					,PRIORITY             = ULPP.PRIORITY
					,UPD_SID              = cSID
					,UPD_USER             = cUSER
					,UPD_DATE             = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,ITEM_CODE
					,PROCESS_PATTERN
					,PROCESS_SEQ
					,LINE_RESOURCE_CODE
					,UNIT_CAPACITY
					,VALID_START
					,VALID_END
					,MIN_PRODUCT_QUANTITY
					,INC_PRODUCT_QUANTITY
					,MAX_PRODUCT_QUANTITY
					,BOM_PATTERN
					,PRIORITY
					,STOP_INTERVAL1
					,STOP_TIME_LENGTH1
					,PROPERTY01
					,PROPERTY02
					,PROPERTY03
					,PROPERTY04
					,PROPERTY05
					,PROPERTY06
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,ULPP.ITEM_CODE
					,ULPP.PROCESS_PATTERN
					,999
					,ULPP.LINE_RESOURCE_CODE
					,NVL(ULPP.PRODUCT_SPEED, 1)
					,ULPP.VALID_START
					,ULPP.VALID_END
					,1
					,1
					,99999999
					,ULPP.BOM_PATTERN
					,ULPP.PRIORITY
					,NVL(ULPP.CIP_INTERVAL, 0)
					,NVL(ULPP.CIP_TIME, 0)
					,NVL(ULPP.PROCES_LT, 0)
					,NVL(ULPP.JPRINT_FLAG, 0)
					,NVL(ULPP.YIELD_RATE, 100)
					,NVL(ULPP.MIN_PRODUCT, -1)
					,NVL(ULPP.INC_PRODUCT, -1)
					,NVL(ULPP.MAX_PRODUCT, -1)
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		ELSE
		-- �폜����
			DELETE
			FROM &1 .FMR_LINE_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE       = inCOMCD
				AND DIVISION_CODE      = inDIVCD
				AND ITEM_CODE          = vILineRec.ITEM_CODE
				AND PROCESS_PATTERN    = vILineRec.PROCESS_PATTERN
				AND PROCESS_SEQ        = 999
				AND LINE_RESOURCE_CODE = vILineRec.LINE_RESOURCE_CODE
				AND VALID_START        = vILineRec.VALID_START
			;
			nDel := nDel + 1;
		END IF;
		
		-- �i�ڍ��@�����ɒǉ�
		INSERT INTO FUM_ITEM_LINE_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,ITEM_CODE
			,PROCESS_PATTERN
			,LINE_RESOURCE_CODE
			,VALID_START
			,VALID_END
			,PRODUCT_SPEED
			,YIELD_RATE
			,CIP_INTERVAL
			,CIP_TIME
			,MIN_PRODUCT
			,INC_PRODUCT
			,MAX_PRODUCT
			,PROCES_LT
			,JPRINT_FLAG
			,PRIORITY
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vILineRec.IF_FLAG
			,vILineRec.IF_SEQ
			,SYSDATE
			,vILineRec.ITEM_CODE
			,vILineRec.PROCESS_PATTERN
			,vILineRec.LINE_RESOURCE_CODE
			,vILineRec.VALID_START
			,vILineRec.VALID_END
			,vILineRec.PRODUCT_SPEED
			,vILineRec.YIELD_RATE
			,vILineRec.CIP_INTERVAL
			,vILineRec.CIP_TIME
			,vILineRec.MIN_PRODUCT
			,vILineRec.INC_PRODUCT
			,vILineRec.MAX_PRODUCT
			,vILineRec.PROCES_LT
			,vILineRec.JPRINT_FLAG
			,vILineRec.PRIORITY
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- �i�ڍ��@(IN)����폜
		DELETE FROM FUM_ITEM_LINE
		WHERE IF_SEQ = vILineRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cItemLine;
	
	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )');
	PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �G���[�I��');
		RAISE;

END;
/

