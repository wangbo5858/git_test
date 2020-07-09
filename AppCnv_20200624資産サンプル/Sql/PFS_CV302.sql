/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- ���@�}�X�^�捞
-- �y�����z
--   &1  : �X�L�[�}��(PPS�p�̃X�L�[�})
--   &2  : ��ЃR�[�h
--   &3  : ���ƕ��R�[�h
--   &4  : �H��R�[�h
--   &5  : �f�t�H���g���Ǝ��ԃR�[�h
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
inOPECD   VARCHAR2(25) := '&5';  -- ���Ǝ��ԃR�[�h

cDEL	VARCHAR2(1) := '1';				-- �A�g�t���O�F�폜
cSID	VARCHAR2(25) := 'PFS_CV302';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';		-- ���[�U

CURSOR cLine IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,PROCESS_CODE
		,LINE_RESOURCE_CODE
		,LINE_RESOURCE_NAME
		,GROUP_CODE
		,GROUP_NAME
	FROM FUM_LINE
	ORDER BY IF_SEQ
	;
vLineRec	cLine%ROWTYPE;

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

	PrintLog(cSID || '���@�}�X�^�捞 �J�n');
	
	nCnt := 0;
	nDel := 0;
	
	OPEN cLine;
	LOOP
		-- ���@(IN)�̓Ǎ�
		FETCH cLine INTO vLineRec;
		EXIT WHEN cLine%NOTFOUND;
		
		IF vLineRec.IF_FLAG <> cDEL THEN
		-- �ǉ��E�X�V����
			MERGE INTO &1 .FMR_LINE_RESOURCE FL -- [���C������]
			USING (
				SELECT
					 vLineRec.PROCESS_CODE       PROCESS_CODE
					,vLineRec.LINE_RESOURCE_CODE LINE_RESOURCE_CODE
					,vLineRec.LINE_RESOURCE_NAME LINE_RESOURCE_NAME
					,vLineRec.GROUP_CODE         GROUP_CODE
					,vLineRec.GROUP_NAME         GROUP_NAME
				FROM DUAL
			) UL
			ON (
					FL.COMPANY_CODE        = inCOMCD
				AND FL.DIVISION_CODE       = inDIVCD
				AND FL.LINE_RESOURCE_CODE  = UL.LINE_RESOURCE_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 LOCATION_CODE         = inPLTCD
					,PROCESS_CODE          = UL.PROCESS_CODE
					,NAME                  = UL.LINE_RESOURCE_NAME
					,RUNNING_CALENDAR_CODE = UL.LINE_RESOURCE_CODE
					,PROPERTY01            = TRIM(UL.GROUP_CODE)
					,PROPERTY02            = UL.GROUP_NAME
					,UPD_SID               = cSID
					,UPD_USER              = cUSER
					,UPD_DATE              = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,LOCATION_CODE
					,PROCESS_CODE
					,LINE_RESOURCE_CODE
					,NAME
					,RUNNING_CALENDAR_CODE
					,PROPERTY01
					,PROPERTY02
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
					,UL.PROCESS_CODE
					,UL.LINE_RESOURCE_CODE
					,UL.LINE_RESOURCE_NAME
					,UL.LINE_RESOURCE_CODE
					,TRIM(UL.GROUP_CODE)
					,UL.GROUP_NAME
					,cSID
					,cUSER
					,SYSDATE
					,cSID
					,cUSER
					,SYSDATE
				)
			;
			
			MERGE INTO &1 .FMC_RUNNING_CALENDAR FRC -- [�ғ��J�����_�[]
			USING (
				SELECT
					 vLineRec.PROCESS_CODE       PROCESS_CODE
					,vLineRec.LINE_RESOURCE_CODE LINE_RESOURCE_CODE
					,vLineRec.LINE_RESOURCE_NAME LINE_RESOURCE_NAME
					,vLineRec.GROUP_CODE         GROUP_CODE
					,vLineRec.GROUP_NAME         GROUP_NAMAG
				FROM DUAL
			) UL
			ON (
					FRC.COMPANY_CODE          = inCOMCD
				AND FRC.DIVISION_CODE         = inDIVCD
				AND FRC.RUNNING_CALENDAR_CODE = UL.LINE_RESOURCE_CODE
			)
			WHEN MATCHED THEN
				UPDATE SET
					 NAME                  = UL.LINE_RESOURCE_NAME
					,UPD_SID               = cSID
					,UPD_USER              = cUSER
					,UPD_DATE              = SYSDATE
			WHEN NOT MATCHED THEN
				INSERT (
					 COMPANY_CODE
					,DIVISION_CODE
					,RUNNING_CALENDAR_CODE
					,NAME
					,ABBREVIATION
					,DATE_START
					,DATE_END
					,RUNNING_FLG_1
					,RUNNING_FLG_2
					,RUNNING_FLG_3
					,RUNNING_FLG_4
					,RUNNING_FLG_5
					,RUNNING_FLG_6
					,RUNNING_FLG_7
					,OPERATION_TIME_CODE_1
					,OPERATION_TIME_CODE_2
					,OPERATION_TIME_CODE_3
					,OPERATION_TIME_CODE_4
					,OPERATION_TIME_CODE_5
					,OPERATION_TIME_CODE_6
					,OPERATION_TIME_CODE_7
					,INS_SID
					,INS_USER
					,INS_DATE
					,UPD_SID
					,UPD_USER
					,UPD_DATE
				) VALUES (
					 inCOMCD
					,inDIVCD
					,UL.LINE_RESOURCE_CODE
					,UL.LINE_RESOURCE_NAME
					,NULL
					,TO_DATE('2017/01/01','YYYY/MM/DD')
					,TO_DATE('2017/12/31','YYYY/MM/DD')
					,1
					,1
					,1
					,1
					,1
					,1
					,1
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
					,inOPECD
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
			-- [���C������]
			DELETE
			FROM &1 .FMR_LINE_RESOURCE
			WHERE
				    COMPANY_CODE       = inCOMCD
				AND DIVISION_CODE      = inDIVCD
				AND LINE_RESOURCE_CODE = vLineRec.LINE_RESOURCE_CODE
			;
			-- [�ғ��J�����_�[]
			DELETE
			FROM  &1 .FMC_RUNNING_CALENDAR
			WHERE
				    COMPANY_CODE          = inCOMCD
				AND DIVISION_CODE         = inDIVCD
				AND RUNNING_CALENDAR_CODE = vLineRec.LINE_RESOURCE_CODE
			;
			-- [������ғ���]
			DELETE
			FROM  &1 .FMC_RUNNING_DAY_STATUS
			WHERE
				    COMPANY_CODE          = inCOMCD
				AND DIVISION_CODE         = inDIVCD
				AND RUNNING_CALENDAR_CODE = vLineRec.LINE_RESOURCE_CODE
			;
			nDel := nDel + 1;
		END IF;
		
		-- ���@�����ɒǉ�
		INSERT INTO FUM_LINE_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,PROCESS_CODE
			,LINE_RESOURCE_CODE
			,LINE_RESOURCE_NAME
			,GROUP_CODE
			,GROUP_NAME
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vLineRec.IF_FLAG
			,vLineRec.IF_SEQ
			,SYSDATE
			,vLineRec.PROCESS_CODE
			,vLineRec.LINE_RESOURCE_CODE
			,vLineRec.LINE_RESOURCE_NAME
			,vLineRec.GROUP_CODE
			,vLineRec.GROUP_NAME
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- ���@(IN)����폜
		DELETE FROM FUM_LINE
		WHERE IF_SEQ = vLineRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cLine;

	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )');
	PrintLog(cSID || '���@�}�X�^�捞 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '���@�}�X�^�捞 �G���[�I��');
		RAISE;

END;
/

EXIT;

