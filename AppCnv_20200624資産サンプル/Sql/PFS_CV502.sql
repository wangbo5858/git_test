/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �����v��CIP�g�����o��
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
cSID	VARCHAR2(25) := 'PFS_CV502';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cProResult(P_COMCD VARCHAR2,P_DIVCD VARCHAR2) IS
	SELECT
		FPS.PRODUCT_ID
		,FPS.PRODUCT_SEQ
		,FLR.PROCESS_CODE
		,FLS.RESOURCE_CODE	LINE_CODE
		,FLR.PROPERTY01 	LINE_GROUP_CODE
		,FLS.START_DATE		PRODUCT_START_DATE
		,FLS.END_DATE		PRODUCT_END_DATE
		,FPS.PROPERTY22		CIPNUM
		,FPS.PROPERTY23		CIPLEN
		,FPS.PROPERTY24		CIPTERM
	FROM
		FTP_PRODUCT_SCHEDULE FPS
		,FTP_LOCATION_SCHEDULE FLS
		,FMR_LINE_RESOURCE FLR
	WHERE
		FPS.COMPANY_CODE = FLS.COMPANY_CODE
	AND	FPS.DIVISION_CODE = FLS.DIVISION_CODE
	AND	FPS.COMPANY_CODE = FLR.COMPANY_CODE
	AND	FPS.DIVISION_CODE = FLR.DIVISION_CODE
	AND	FPS.PRODUCT_ID = FLS.LOCATION_ID
	AND	FPS.PRODUCT_SEQ = FLS.LOCATION_SEQ
	AND	FPS.PRODUCT_SUB_SEQ = FLS.SUB_SEQ
	AND	FPS.COMPANY_CODE = P_COMCD
	AND	FPS.DIVISION_CODE = P_DIVCD
	AND	FLS.ASSIGN_FLG = 1	-- �����ς�
	AND	FPS.PROPERTY10 = '0'	-- �[�U
	AND	LENGTH(FPS.PRODUCT_ID) = 13
	AND     FPS.PROPERTY22 >= 0	-- CIP1��ȏ�
	AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	ORDER BY FPS.PRODUCT_ID
;
vProResult	cProResult%ROWTYPE;

CURSOR cSetupResult(P_COMCD VARCHAR2,P_DIVCD VARCHAR2) IS
	SELECT
		FSS.PRODUCT_ID
		,FSS.PRODUCT_SEQ
		,FLR.PROCESS_CODE
		,FSS.RESOURCE_CODE	LINE_CODE
		,FLR.PROPERTY01 	LINE_GROUP_CODE
		,FSS.START_DATE		
		,FSS.END_DATE		
	FROM
		FTP_SETUP_SUMMARY FSS
		,FMR_LINE_RESOURCE FLR
		,FMR_PROCESS FP
	WHERE
		FSS.COMPANY_CODE = FLR.COMPANY_CODE
	AND	FSS.DIVISION_CODE = FLR.DIVISION_CODE
	AND	FSS.COMPANY_CODE = FP.COMPANY_CODE
	AND	FSS.DIVISION_CODE = FP.DIVISION_CODE
	AND	FSS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	AND	FLR.PROCESS_CODE = FP.PROCESS_CODE
	AND	FSS.ASSIGN_FLG = 1		-- �����̂�
	AND	FP.PROPERTY01 = '0'		-- �[�U�̂�
	ORDER BY FSS.PRODUCT_ID
;
vSetupResult	cSetupResult%ROWTYPE;

CURSOR cProAka IS
	SELECT
		Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_LAST
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		FROM
			FUT_CIP_PLAN_NEW
	)
;
vProAka	cProAka%ROWTYPE;

CURSOR cProKuro IS
	SELECT
		Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_NEW
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		FROM
			FUT_CIP_PLAN_LAST
	)
;
vProKuro	cProKuro%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;
nErr	NUMBER;

vNOWDATE DATE;
nIF_Seq NUMBER;
nProduct_Seq NUMBER;

vCIPStartTime DATE;
vCIPEndTime DATE;

vCIPLEN_WK VARCHAR2(50);
vCIPTERM_WK VARCHAR2(50);

nErrFlag NUMBER;
nSelCnt  NUMBER;

/******************************************************************************/
--  ���O�o��
-- �y�����z
--   pinMessage  : ���b�Z�[�W
/******************************************************************************/
PROCEDURE PrintLog(pinMessage VARCHAR2) IS
BEGIN
	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY/MM/DD HH24:MI:SS.FF3') || ' : ' || pinMessage);
END;
/******************************************************************************/
--  ������؂蔲��
-- �y�����z
--   
/******************************************************************************/
FUNCTION STRTOKEN(
	P_STRING VARCHAR2, P_DELIMIT VARCHAR2,
	P_POS POSITIVEN := 1, P_NTH POSITIVEN := 1,
	P_EOD VARCHAR2 := NULL)
RETURN VARCHAR2
IS
	vStartPos	PLS_INTEGER;
	vEndPos		PLS_INTEGER;
BEGIN
	IF (P_POS = 1) THEN
		vStartPos := 1;
	ELSE
		vStartPos := INSTR(P_STRING, P_DELIMIT, 1, P_POS - 1);
		IF (vStartPos = 0) THEN
			RETURN P_EOD;
		END IF;
		vStartPos := vStartPos + 1;
	END IF;
	vEndPos := INSTR(P_STRING, P_DELIMIT, vStartPos, P_NTH);
	IF (vEndPos = 0) THEN
		RETURN SUBSTR(P_STRING, vStartPos);
	END IF;
	RETURN SUBSTR(P_STRING, vStartPos, vEndPos - vStartPos);
END;

/******************************************************************************/
--  HIST�f�[�^�쐬
-- �y�����z
--   
/******************************************************************************/
PROCEDURE MakeHist(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_CIP_PLAN_HIST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	)
	SELECT
		IF_Flag
		,IF_Seq
		,vNOWDATE
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_LAST
	;
	DELETE FROM FUT_CIP_PLAN_LAST
	;
END;
/******************************************************************************/
--  LAST�f�[�^�쐬
-- �y�����z
--   
/******************************************************************************/
PROCEDURE MakeLast(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_CIP_PLAN_LAST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	)
	SELECT
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,CIP_Start_Date
		,CIP_End_Date
	FROM
		FUT_CIP_PLAN_NEW
	;
	DELETE FROM FUT_CIP_PLAN_NEW
	;
END;
/******************************************************************************/
--  NEW�f�[�^�쐬
-- �y�����z
--   
/******************************************************************************/
PROCEDURE MakeNew(vNOWDATE DATE) IS
BEGIN
	nIF_Seq := 0;
	OPEN cProResult(inCOMCD,inDIVCD);
	LOOP
		-- ����CIP����(�[�U)�̓Ǎ�
		FETCH cProResult INTO vProResult;
		EXIT WHEN cProResult%NOTFOUND;

		-- �ϐ�������
		nProduct_Seq := 0;
		vCIPStartTime := vProResult.PRODUCT_START_DATE;

		FOR i IN 1..vProResult.CIPNUM LOOP
			vCIPLEN_WK := strtoken(vProResult.CIPLEN, ',', i);
			vCIPTERM_WK := strtoken(vProResult.CIPTERM, ',', i);

			IF (vCIPLEN_WK IS NOT NULL AND vCIPTERM_WK IS NOT NULL) THEN
				vCIPStartTime := vCIPStartTime + (TO_NUMBER(vCIPTERM_WK) / 24 / 60);
				vCIPEndTime := vCIPStartTime + (TO_NUMBER(vCIPLEN_WK) / 24 / 60);

				-- �i�[
				nIF_Seq := nIF_Seq + 1;
				nProduct_Seq := nProduct_Seq + 1;
				INSERT INTO FUT_CIP_PLAN_NEW
				(
					IF_Flag
					,IF_Seq
					,IF_Date
					,Product_ID
					,Product_Seq
					,Process_Code
					,Line_Code
					,Line_Group_Code
					,CIP_Start_Date
					,CIP_End_Date
				) VALUES (
					'0'
					,nIF_Seq
					,vNOWDATE
					,vProResult.Product_ID
					,nProduct_Seq
					,vProResult.Process_Code
					,vProResult.Line_Code
					,vProResult.Line_Group_Code
					,vCIPStartTime
					,vCIPEndTime
				)
				;
				vCIPStartTime := vCIPEndTime;
			END IF;

		END LOOP;

	END LOOP;
	CLOSE cProResult;

	OPEN cSetupResult(inCOMCD,inDIVCD);
	LOOP
		-- �����ؑ֌���(�[�U)�̓Ǎ�
		FETCH cSetupResult INTO vSetupResult;
		EXIT WHEN cSetupResult%NOTFOUND;

		-- �ϐ�������
		nProduct_Seq := 0;

		-- �i�[
		nIF_Seq := nIF_Seq + 1;
		nProduct_Seq := nProduct_Seq + 1;
		INSERT INTO FUT_CIP_PLAN_NEW
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		) VALUES (
			'0'
			,nIF_Seq
			,vNOWDATE
			,' '		-- vSetupResult.Product_ID
			,0			-- nProduct_Seq
			,vSetupResult.Process_Code
			,vSetupResult.Line_Code
			,vSetupResult.Line_Group_Code
			,vSetupResult.START_DATE
			,vSetupResult.END_DATE
		)
		;
	END LOOP;
	CLOSE cSetupResult;
END;
/******************************************************************************/
--  �ԍ��f�[�^�쐬
-- �y�����z
--   
/******************************************************************************/
PROCEDURE MakeAkaKuro(vNOWDATE DATE) IS
BEGIN
	nIF_Seq := 0;
	-- �ԃf�[�^�쐬
	OPEN cProAka;
	LOOP
		-- �ԃf�[�^�̓Ǎ�
		FETCH cProAka INTO vProAka;
		EXIT WHEN cProAka%NOTFOUND;

		-- �ԃf�[�^�̍쐬
		nIF_Seq := nIF_Seq + 1;
		INSERT INTO FUT_CIP_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		) VALUES (
			'1'
			,nIF_Seq
			,vNOWDATE
			,vProAka.Product_ID
			,vProAka.Product_Seq
			,vProAka.Process_Code
			,vProAka.Line_Code
			,vProAka.Line_Group_Code
			,vProAka.CIP_Start_Date
			,vProAka.CIP_End_Date
		)
	;
	END LOOP;
	CLOSE cProAka;
	nDel := nIF_Seq;

	-- ���f�[�^�쐬
	OPEN cProKuro;
	LOOP
		-- ���f�[�^�̓Ǎ�
		FETCH cProKuro INTO vProKuro;
		EXIT WHEN cProKuro%NOTFOUND;

		-- ���f�[�^�̍쐬
		nIF_Seq := nIF_Seq + 1;
		INSERT INTO FUT_CIP_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,CIP_Start_Date
			,CIP_End_Date
		) VALUES (
			'0'
			,nIF_Seq
			,vNOWDATE
			,vProKuro.Product_ID
			,vProKuro.Product_Seq
			,vProKuro.Process_Code
			,vProKuro.Line_Code
			,vProKuro.Line_Group_Code
			,vProKuro.CIP_Start_Date
			,vProKuro.CIP_End_Date
		)
	;
	END LOOP;
	CLOSE cProKuro;
	nCnt := nIF_Seq - nDel;
END;
/***************************/
/* ���C������              */
/***************************/
BEGIN

	PrintLog(cSID || '�����v��CIP�g�����o�� �J�n');
	
	nCnt := 0;
	nDel := 0;
	nErr := 0;
	
	-- ���ݎ����擾
	SELECT SYSDATE
	INTO vNOWDATE	
	FROM DUAL;

	PrintLog(cSID || '�����v��CIP����ޔ� �J�n');
	MakeHist(vNOWDATE);
	PrintLog(cSID || '�����v��CIP����ޔ� �I��');

	PrintLog(cSID || '�����v��CIP�O��쐬 �J�n');
	MakeLast(vNOWDATE);
	PrintLog(cSID || '�����v��CIP�O��쐬 �I��');

	PrintLog(cSID || '�����v��CIP�ŐV�쐬 �J�n');
	MakeNew(vNOWDATE);
	PrintLog(cSID || '�����v��CIP�ŐV�쐬 �I��');

	PrintLog(cSID || '���Y�v��CIP�쐬 �J�n');
	MakeAkaKuro(vNOWDATE);
	PrintLog(cSID || '���Y�v��CIP�쐬 �I��');
	
	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )' || ' (�G���[���� ' || nErr || ' )');
	PrintLog(cSID || '�����v��CIP�g�����o�� �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�����v��CIP�g�����o�� �G���[�I��');
		RAISE;

END;

/

EXIT;

