/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �����v��g�����o��
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
cSID	VARCHAR2(25) := 'PFS_CV501';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cProResult(P_COMCD VARCHAR2,P_DIVCD VARCHAR2) IS
	SELECT
		FPS.PRODUCT_ID
		,FPS.PRODUCT_SEQ
		,FPS.ITEM_CODE
		,FLR.PROCESS_CODE
		,FLS.RESOURCE_CODE	LINE_CODE
		,FLR.PROPERTY01 	LINE_GROUP_CODE
		,TO_DATE(TO_CHAR(FLS.START_DATE,'YYYY/MM/DD'),'YYYY/MM/DD')	PRODUCT_DATE
		,FLS.START_DATE		PRODUCT_START_DATE
		,FLS.END_DATE		PRODUCT_END_DATE
		,FLS.LOCATION_QUANTITY	PRODUCT_QUANTITY
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
	AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	ORDER BY FPS.PRODUCT_ID,FPS.PRODUCT_SEQ,FPS.ITEM_CODE
;
vProResult	cProResult%ROWTYPE;

CURSOR cProSub(P_COMCD VARCHAR2,P_DIVCD VARCHAR2,P_PRODOUCT_ID VARCHAR2) IS
	SELECT
		TYOUGOU_ID
		,TYOUGOU_ITEM_CODE
		,TYOUGOU_PROCESS_CODE
		,TYOUGOU_LINE_CODE
		,TYOUGOU_LINE_GROUP_CODE
		,TYUSYUTU_ID
		,TYUSYUTU_ITEM_CODE
		,TYUSYUTU_PROCESS_CODE
		,TYUSYUTU_LINE_CODE
		,TYUSYUTU_LINE_GROUP_CODE
	FROM
	(
		SELECT
			RANK() OVER(PARTITION BY SUBSTR(FPS.PRODUCT_ID,0,13) ORDER BY FPS.ITEM_CODE)	TYOUGOU_ROW
			,FPS.ITEM_CODE		TYOUGOU_ITEM_CODE
			,FPS.PRODUCT_ID		TYOUGOU_ID
			,FLR.PROCESS_CODE	TYOUGOU_PROCESS_CODE
			,FLS.RESOURCE_CODE	TYOUGOU_LINE_CODE
			,FLR.PROPERTY01 	TYOUGOU_LINE_GROUP_CODE
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
		AND	FPS.PROPERTY10 = '1'	-- ����
		AND	SUBSTR(FPS.PRODUCT_ID,0,13) = P_PRODOUCT_ID	-- �e�Ɠ���
		AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	) TYOUGOU_DATA
	FULL OUTER JOIN
	(
		SELECT
			RANK() OVER(PARTITION BY SUBSTR(FPS.PRODUCT_ID,0,13) ORDER BY FPS.ITEM_CODE)	TYUSYUTU_ROW
			,FPS.ITEM_CODE		TYUSYUTU_ITEM_CODE
			,FPS.PRODUCT_ID		TYUSYUTU_ID
			,FLR.PROCESS_CODE	TYUSYUTU_PROCESS_CODE
			,FLS.RESOURCE_CODE	TYUSYUTU_LINE_CODE
			,FLR.PROPERTY01 	TYUSYUTU_LINE_GROUP_CODE
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
		AND	FPS.PROPERTY10 = '2'	-- ���o
		AND	SUBSTR(FPS.PRODUCT_ID,0,13) = P_PRODOUCT_ID	-- �e�Ɠ���
		AND	FLS.RESOURCE_CODE = FLR.LINE_RESOURCE_CODE
	) TYUSYUTU_DATA
	ON TYOUGOU_DATA.TYOUGOU_ROW = TYUSYUTU_DATA.TYUSYUTU_ROW
;
vProSub	cProSub%ROWTYPE;

CURSOR cProAka IS
	SELECT
		Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_LAST
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		FROM
			FUT_PRODUCT_PLAN_NEW
	)
;
vProAka	cProAka%ROWTYPE;

CURSOR cProKuro IS
	SELECT
		Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_NEW
	MINUS(
		SELECT
			Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		FROM
			FUT_PRODUCT_PLAN_LAST
	)
;
vProKuro	cProKuro%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;
nErr	NUMBER;

vNOWDATE DATE;
nIF_Seq NUMBER;
nProduct_Seq NUMBER;

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
--  HIST�f�[�^�쐬
-- �y�����z
--   
/******************************************************************************/
PROCEDURE MakeHist(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_PRODUCT_PLAN_HIST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	)
	SELECT
		IF_Flag
		,IF_Seq
		,vNOWDATE
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_LAST
	;
	DELETE FROM FUT_PRODUCT_PLAN_LAST
	;
END;
/******************************************************************************/
--  LAST�f�[�^�쐬
-- �y�����z
--   
/******************************************************************************/
PROCEDURE MakeLast(vNOWDATE DATE) IS
BEGIN
	INSERT INTO FUT_PRODUCT_PLAN_LAST
	(
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	)
	SELECT
		IF_Flag
		,IF_Seq
		,IF_Date
		,Product_ID
		,Product_Seq
		,Item_Code
		,Process_Code
		,Line_Code
		,Line_Group_Code
		,Product_Date
		,Product_Start_Date
		,Product_End_Date
		,Product_Quantity
		,Item_Code2
		,Process_Code2
		,Line_Code2
		,Line_Group_Code2
		,Item_Code3
		,Process_Code3
		,Line_Code3
		,Line_Group_Code3
	FROM
		FUT_PRODUCT_PLAN_NEW
	;
	DELETE FROM FUT_PRODUCT_PLAN_NEW
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
		-- ��������(�[�U)�̓Ǎ�
		FETCH cProResult INTO vProResult;
		EXIT WHEN cProResult%NOTFOUND;

		-- �����A���o�̎擾
		nProduct_Seq := 0;
		OPEN cProSub(inCOMCD,inDIVCD,SUBSTR(vProResult.Product_ID,0,13));
		LOOP 
			-- ��������(�����A���o)�̓Ǎ�
			FETCH cProSub INTO vProSub;
			EXIT WHEN cProSub%NOTFOUND;

			nProduct_Seq := nProduct_Seq + 1;	--�����A���o����

			nIF_Seq := nIF_Seq + 1;
			INSERT INTO FUT_PRODUCT_PLAN_NEW(
				IF_Flag
				,IF_Seq
				,IF_Date
				,Product_ID
				,Product_Seq
				,Item_Code
				,Process_Code
				,Line_Code
				,Line_Group_Code
				,Product_Date
				,Product_Start_Date
				,Product_End_Date
				,Product_Quantity
				,Item_Code2
				,Process_Code2
				,Line_Code2
				,Line_Group_Code2
				,Item_Code3
				,Process_Code3
				,Line_Code3
				,Line_Group_Code3
			) VALUES (
				'0'
				,nIF_Seq
				,vNOWDATE
				,vProResult.Product_ID
				,nProduct_Seq
				,vProResult.Item_Code
				,vProResult.Process_Code
				,vProResult.Line_Code
				,vProResult.Line_Group_Code
				,vProResult.Product_Date
				,vProResult.Product_Start_Date
				,vProResult.Product_End_Date
				,vProResult.Product_Quantity
				,vProSub.TYUSYUTU_ITEM_CODE
				,vProSub.TYUSYUTU_PROCESS_CODE
				,vProSub.TYUSYUTU_LINE_CODE
				,vProSub.TYUSYUTU_LINE_GROUP_CODE
				,vProSub.TYOUGOU_ITEM_CODE
				,vProSub.TYOUGOU_PROCESS_CODE
				,vProSub.TYOUGOU_LINE_CODE
				,vProSub.TYOUGOU_LINE_GROUP_CODE
			)
			;

		END LOOP;
		CLOSE cProSub;
		
		-- �}��(�����A���o�̖����ꍇ)
		IF (nProduct_Seq = 0) THEN
			nIF_Seq := nIF_Seq + 1;
			INSERT INTO FUT_PRODUCT_PLAN_NEW(
				IF_Flag
				,IF_Seq
				,IF_Date
				,Product_ID
				,Product_Seq
				,Item_Code
				,Process_Code
				,Line_Code
				,Line_Group_Code
				,Product_Date
				,Product_Start_Date
				,Product_End_Date
				,Product_Quantity
				,Item_Code2
				,Process_Code2
				,Line_Code2
				,Line_Group_Code2
				,Item_Code3
				,Process_Code3
				,Line_Code3
				,Line_Group_Code3
			) VALUES (
				'0'
				,nIF_Seq
				,vNOWDATE
				,vProResult.Product_ID
				,1
				,vProResult.Item_Code
				,vProResult.Process_Code
				,vProResult.Line_Code
				,vProResult.Line_Group_Code
				,vProResult.Product_Date
				,vProResult.Product_Start_Date
				,vProResult.Product_End_Date
				,vProResult.Product_Quantity
				,''
				,''
				,''
				,''
				,''
				,''
				,''
				,''
			)
			;
		END IF;
	END LOOP;
	CLOSE cProResult;
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
		INSERT INTO FUT_PRODUCT_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		) VALUES (
			'1'
			,nIF_Seq
			,vNOWDATE
			,vProAka.Product_ID
			,vProAka.Product_Seq
			,vProAka.Item_Code
			,vProAka.Process_Code
			,vProAka.Line_Code
			,vProAka.Line_Group_Code
			,vProAka.Product_Date
			,vProAka.Product_Start_Date
			,vProAka.Product_End_Date
			,vProAka.Product_Quantity
			,vProAka.Item_Code2
			,vProAka.Process_Code2
			,vProAka.Line_Code2
			,vProAka.Line_Group_Code2
			,vProAka.Item_Code3
			,vProAka.Process_Code3
			,vProAka.Line_Code3
			,vProAka.Line_Group_Code3
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
		INSERT INTO FUT_PRODUCT_PLAN
		(
			IF_Flag
			,IF_Seq
			,IF_Date
			,Product_ID
			,Product_Seq
			,Item_Code
			,Process_Code
			,Line_Code
			,Line_Group_Code
			,Product_Date
			,Product_Start_Date
			,Product_End_Date
			,Product_Quantity
			,Item_Code2
			,Process_Code2
			,Line_Code2
			,Line_Group_Code2
			,Item_Code3
			,Process_Code3
			,Line_Code3
			,Line_Group_Code3
		) VALUES (
			'0'
			,nIF_Seq
			,vNOWDATE
			,vProKuro.Product_ID
			,vProKuro.Product_Seq
			,vProKuro.Item_Code
			,vProKuro.Process_Code
			,vProKuro.Line_Code
			,vProKuro.Line_Group_Code
			,vProKuro.Product_Date
			,vProKuro.Product_Start_Date
			,vProKuro.Product_End_Date
			,vProKuro.Product_Quantity
			,vProKuro.Item_Code2
			,vProKuro.Process_Code2
			,vProKuro.Line_Code2
			,vProKuro.Line_Group_Code2
			,vProKuro.Item_Code3
			,vProKuro.Process_Code3
			,vProKuro.Line_Code3
			,vProKuro.Line_Group_Code3
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

	PrintLog(cSID || '�����v��g�����o�� �J�n');
	
	nCnt := 0;
	nDel := 0;
	nErr := 0;
	
	-- ���ݎ����擾
	SELECT SYSDATE
	INTO vNOWDATE	
	FROM DUAL;

	PrintLog(cSID || '�����v�旚��ޔ� �J�n');
	MakeHist(vNOWDATE);
	PrintLog(cSID || '�����v�旚��ޔ� �I��');

	PrintLog(cSID || '�����v��O��쐬 �J�n');
	MakeLast(vNOWDATE);
	PrintLog(cSID || '�����v��O��쐬 �I��');

	PrintLog(cSID || '�����v��ŐV�쐬 �J�n');
	MakeNew(vNOWDATE);
	PrintLog(cSID || '�����v��ŐV�쐬 �I��');

	PrintLog(cSID || '���Y�v��쐬 �J�n');
	MakeAkaKuro(vNOWDATE);
	PrintLog(cSID || '���Y�v��쐬 �I��');
	
	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )' || ' (�G���[���� ' || nErr || ' )');
	PrintLog(cSID || '�����v��g�����o�� �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�����v��g�����o�� �G���[�I��');
		RAISE;

END;

/

EXIT;

