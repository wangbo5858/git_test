/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �H���}�X�^�捞
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
cSID	VARCHAR2(25) := 'PFS_CV301';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cProc IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,PROCESS_CODE
		,PROCESS_NAME
	FROM FUM_PROCESS
	ORDER BY IF_SEQ
	;
vProcRec	cProc%ROWTYPE;

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

	PrintLog(cSID || '�H���}�X�^�捞 �J�n');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cProc;
	LOOP
		-- �H��(IN)�̓Ǎ�
		FETCH cProc INTO vProcRec;
		EXIT WHEN cProc%NOTFOUND;
		
		IF vProcRec.IF_FLAG <> cDEL THEN
		-- �ǉ��E�X�V����
		-- �H��
			MERGE INTO &1 .FMR_PROCESS FP -- [�H��]
			USING (
				SELECT
					 vProcRec.PROCESS_CODE PROCESS_CODE
					,vProcRec.PROCESS_NAME PROCESS_NAME
				FROM DUAL
			) UP
			ON (
					FP.COMPANY_CODE  = inCOMCD
				AND FP.DIVISION_CODE = inDIVCD
				AND FP.PROCESS_CODE  = UP.PROCESS_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME         = UP.PROCESS_NAME
					,UPD_SID      = cSID
					,UPD_USER     = cUSER
					,UPD_DATE     = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,PROCESS_CODE
					,NAME
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,UP.PROCESS_CODE
					,UP.PROCESS_NAME
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		-- �� 2017/09/28 �R�����g�E�A�E�g
		/*	
		--�_�~�[�i�� �i��
			MERGE INTO &1 .FMI_ITEM FI -- [�i��]
			USING (
				SELECT
					 'DUMMY_' || vProcRec.PROCESS_CODE             ITEM_CODE
					,'�_�~�[�i��(' || vProcRec.PROCESS_NAME || ')' NAME
				FROM DUAL
			) UI
			ON (
					FI.COMPANY_CODE  = inCOMCD
				AND FI.DIVISION_CODE = inDIVCD
				AND FI.ITEM_CODE     = UI.ITEM_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME         = UI.NAME
					,UPD_SID      = cSID
					,UPD_USER     = cUSER
					,UPD_DATE     = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,ITEM_CODE
					,NAME
					,ITEM_TYPE
					,PRODUCT_TYPE
					,STD_BOM_PATTERN
					,STD_PROCESS_PATTERN
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
					,UI.NAME
					,5
					,2
					,'*'
					,'*'
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		--�_�~�[�i�� �݌ɊǗ����
			MERGE INTO &1 .FMI_SKU FS -- [�݌ɊǗ����]
			USING (
				SELECT
					 'DUMMY_' || vProcRec.PROCESS_CODE ITEM_CODE
				FROM DUAL
			) US
			ON (
					FS.COMPANY_CODE  = inCOMCD
				AND FS.DIVISION_CODE = inDIVCD
				AND FS.LOCATION_CODE = inPLTCD
				AND FS.ITEM_CODE     = US.ITEM_CODE
			)
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,ITEM_CODE
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
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		--�_�~�[�i�� �H������
			MERGE INTO &1 .FMI_PROCESS_SEQUENCE FPS -- [�H������]
			USING (
				SELECT
					 'DUMMY_' || vProcRec.PROCESS_CODE ITEM_CODE
					,vProcRec.PROCESS_CODE             PROCESS_CODE
				FROM DUAL
			) UPS
			ON (
					FPS.COMPANY_CODE  = inCOMCD
				AND FPS.DIVISION_CODE = inDIVCD
				AND FPS.ITEM_CODE     = UPS.ITEM_CODE
			)
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,ITEM_CODE
					,PROCESS_PATTERN
					,PROCESS_SEQ
					,PROCESS_CODE
					,ASSIGN_LINE_TYPE
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
					,2
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
		*/
		-- �� 2017/09/29 �R�����g�E�A�E�g
		ELSE
		-- �폜����
		-- �H��
			DELETE
			FROM &1 .FMR_PROCESS
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND PROCESS_CODE  = vProcRec.PROCESS_CODE
			;
		-- �� 2017/09/29 �R�����g�E�A�E�g
		/*
		--�_�~�[�i�� �i��
			DELETE
			FROM &1 .FMI_ITEM
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = 'DUMMY_' || vProcRec.PROCESS_CODE
			;
		--�_�~�[�i�� �݌ɊǗ����
			DELETE
			FROM &1 .FMI_SKU
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = 'DUMMY_' || vProcRec.PROCESS_CODE
			;
		--�_�~�[�i�� �H������
			DELETE
			FROM &1 .FMI_PROCESS_SEQUENCE
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = 'DUMMY_' || vProcRec.PROCESS_CODE
			;
		*/
		-- �� 2017/09/29 �R�����g�E�A�E�g
			nDel := nDel + 1;
		END IF;
		
		-- �H�������ɒǉ�
		INSERT INTO FUM_PROCESS_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,PROCESS_CODE
			,PROCESS_NAME
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vProcRec.IF_FLAG
			,vProcRec.IF_SEQ
			,SYSDATE
			,vProcRec.PROCESS_CODE
			,vProcRec.PROCESS_NAME
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- �H��(IN)����폜
		DELETE FROM FUM_PROCESS
		WHERE IF_SEQ = vProcRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cProc;

	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )');
	PrintLog(cSID || '�H���}�X�^�捞 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�H���}�X�^�捞 �G���[�I��');
		RAISE;

END;
/

EXIT;

