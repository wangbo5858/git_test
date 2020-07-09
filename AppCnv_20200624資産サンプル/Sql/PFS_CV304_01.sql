/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �i�ڍ\���}�X�^�捞
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
cSID	VARCHAR2(25) := 'PFS_CV304';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cBom IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,ITEM_CODE
		,PROCESS_PATTERN
		,LOW_ITEM_CODE
		,BOM_PATTERN
		,VALID_START
		,VALID_END
	FROM FUM_BOM
	ORDER BY IF_SEQ
	;
vBomRec	cBom%ROWTYPE;

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

	PrintLog(cSID || '�i�ڍ\���}�X�^�捞 �J�n');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cBom;
	LOOP
		-- �i�ڍ\��(IN)�̓Ǎ�
		FETCH cBom INTO vBomRec;
		EXIT WHEN cBom%NOTFOUND;
		
		IF vBomRec.IF_FLAG <> cDEL THEN
		-- �ǉ��E�X�V����
			MERGE INTO &1 .FMI_BOM FB -- [�i�ڍ\��]
			USING (
				SELECT
					 vBomRec.ITEM_CODE            ITEM_CODE
					,vBomRec.PROCESS_PATTERN      PROCESS_PATTERN
					,vBomRec.LOW_ITEM_CODE        LOW_ITEM_CODE
					,vBomRec.BOM_PATTERN          BOM_PATTERN
					,vBomRec.VALID_START          VALID_START
					,vBomRec.VALID_END            VALID_END
				FROM DUAL
			) UB
			ON (
					FB.COMPANY_CODE      = inCOMCD
				AND FB.DIVISION_CODE     = inDIVCD
				AND FB.LOCATION_CODE     = inPLTCD
				AND FB.ITEM_CODE         = UB.ITEM_CODE
				AND FB.PROCESS_PATTERN   = UB.PROCESS_PATTERN
				AND FB.LOW_LOCATION_CODE = inPLTCD
				AND FB.LOW_ITEM_CODE     = UB.LOW_ITEM_CODE
				AND FB.BOM_PATTERN       = UB.BOM_PATTERN
				AND FB.VALID_START       = UB.VALID_START
			)
			WHEN MATCHED THEN
				UPDATE SET
					 VALID_END             = UB.VALID_END
					,UPD_SID               = cSID
					,UPD_USER              = cUSER
					,UPD_DATE              = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,ITEM_CODE
					,PROCESS_PATTERN
					,PROCESS_SEQ
					,BOM_PATTERN
					,LOW_LOCATION_CODE
					,LOW_ITEM_CODE
					,VALID_START
					,VALID_END
					,QUANTITY_NUMERATOR
					,QUANTITY_DENOMINATOR
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
					,UB.ITEM_CODE
					,UB.PROCESS_PATTERN
					,999
					,UB.BOM_PATTERN
					,inPLTCD
					,UB.LOW_ITEM_CODE
					,UB.VALID_START
					,UB.VALID_END
					,1
					,1
					,1 -- S-S���Ԋ֌W
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
			FROM &1 .FMI_BOM
			WHERE
				    COMPANY_CODE      = inCOMCD
				AND DIVISION_CODE     = inDIVCD
				AND LOCATION_CODE     = inPLTCD
				AND ITEM_CODE         = vBomRec.ITEM_CODE
				AND PROCESS_PATTERN   = vBomRec.PROCESS_PATTERN
				AND LOW_LOCATION_CODE = inPLTCD
				AND LOW_ITEM_CODE     = vBomRec.LOW_ITEM_CODE
				AND BOM_PATTERN       = vBomRec.BOM_PATTERN
				AND VALID_START       = vBomRec.VALID_START
			;
			nDel := nDel + 1;
		END IF;
		
		-- �i�ڍ\�������ɒǉ�
		INSERT INTO FUM_BOM_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,ITEM_CODE
			,PROCESS_PATTERN
			,LOW_ITEM_CODE
			,BOM_PATTERN
			,VALID_START
			,VALID_END
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vBomRec.IF_FLAG
			,vBomRec.IF_SEQ
			,SYSDATE
			,vBomRec.ITEM_CODE
			,vBomRec.PROCESS_PATTERN
			,vBomRec.LOW_ITEM_CODE
			,vBomRec.BOM_PATTERN
			,vBomRec.VALID_START
			,vBomRec.VALID_END
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- �i�ڍ\��(IN)����폜
		DELETE FROM FUM_BOM
		WHERE IF_SEQ = vBomRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cBom;
	
	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )');
	PrintLog(cSID || '�i�ڍ\���}�X�^�捞 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�i�ڍ\���}�X�^�捞 �G���[�I��');
		RAISE;

END;
/

