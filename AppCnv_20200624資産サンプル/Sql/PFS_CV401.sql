/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �����˗��g�����捞
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
cSID	VARCHAR2(25) := 'PFS_CV401';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

CURSOR cProReq IS
	SELECT
		 IF_FLAG
		,IF_SEQ
		,PROD_REQ_ID
		,REQ_MONTH
		,ITEM_CODE
		,ITEM_CODE2
		,ITEM_NAME2
		,REQ_QTY
		,REQ_DATE
		,REQ_LINE
		,BOM_UPD_FLAG
		,PROPERTY01
		,PROPERTY02
		,PROPERTY03
		,PROPERTY04
		,PROPERTY05
	FROM FUT_PRODUCT_REQUIRE
	ORDER BY IF_SEQ
	;
vProReqRec	cProReq%ROWTYPE;

nCnt	NUMBER;
nDel	NUMBER;
nErr	NUMBER;

vHistID VARCHAR(25);
nHistNo NUMBER;

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
--  �G���[�o��
-- �y�����z
--   pinProReqRec  �F �����˗�(IN)
--   pinErrMessage �F �G���[���b�Z�[�W
/******************************************************************************/
PROCEDURE OutError(pinProReqRec cProReq%ROWTYPE, pinErrMessage VARCHAR2) IS
BEGIN
	INSERT INTO FUT_PROD_REQUIRE_ERROR
	(
		 PROD_REQ_HIST_ID
		,IF_FLAG
		,IF_SEQ
		,IF_DATE
		,ERRMSG
		,PROD_REQ_ID
		,UPD_SID
		,UPD_USER
		,UPD_DATE
	)
	VALUES
	(
		 TO_CHAR(nHistNo,'FM0000000000000000000000000')
		,pinProReqRec.IF_FLAG
		,pinProReqRec.IF_SEQ
		,SYSDATE
		,pinErrMessage
		,pinProReqRec.PROD_REQ_ID
		,cSID
		,cUSER
		,SYSDATE
	)
	;
	nHistNo := nHistNo + 1;
END;

/***************************/
/* ���C������              */
/***************************/
BEGIN

	PrintLog(cSID || '�����˗��g�����捞 �J�n');
	
	nCnt := 0;
	nDel := 0;
	nErr := 0;
	
	SELECT MAX(PROD_REQ_HIST_ID)
	INTO vHistID
	FROM FUT_PROD_REQUIRE_ERROR;
	
	PrintLog(cSID || '�����˗��捞�G���[����ID �ő�l(' || vHistID || ')');
	IF vHistID IS NULL THEN
		nHistNo := 0;
	ELSE
		nHistNo := TO_NUMBER(vHistID) + 1;
	END IF;
	
	OPEN cProReq;
	LOOP
		-- �����˗�(IN)�̓Ǎ�
		FETCH cProReq INTO vProReqRec;
		EXIT WHEN cProReq%NOTFOUND;
		
		IF vProReqRec.IF_FLAG <> cDEL THEN
		-- �G���[�`�F�b�N
			nErrFlag := 0;
		-- �����˗���
			IF vProReqRec.REQ_QTY < 0 THEN
				OutError(vProReqRec, '�����˗��ʂ��}�C�i�X�ł��B');
				nErrFlag := 1;
			END IF;
		-- �i�ڃ`�F�b�N
			SELECT COUNT(*) INTO nSelCnt
			FROM FMI_ITEM
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vProReqRec.ITEM_CODE
			;
			IF nSelCnt = 0 THEN
				OutError(vProReqRec, '�i�ڂ��i�ڃ}�X�^�ɂ���܂���B');
				nErrFlag := 1;
			END IF;
			SELECT COUNT(*) INTO nSelCnt
			FROM FMR_LINE_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE  = inCOMCD
				AND DIVISION_CODE = inDIVCD
				AND ITEM_CODE     = vProReqRec.ITEM_CODE
			;
			IF nSelCnt = 0 THEN
				OutError(vProReqRec, '�i�ڂ����C�������菇�}�X�^�ɂ���܂���B');
				nErrFlag := 1;
			END IF;
		-- �i�ڃ`�F�b�N
			SELECT COUNT(*) INTO nSelCnt
			FROM FMR_LINE_PRODUCT_PROCESS
			WHERE
				    COMPANY_CODE       = inCOMCD
				AND DIVISION_CODE      = inDIVCD
				AND LINE_RESOURCE_CODE = vProReqRec.REQ_LINE
			;
			IF nSelCnt = 0 THEN
				OutError(vProReqRec, '�����˗����C�������C�������菇�}�X�^�ɂ���܂���B');
				nErrFlag := 1;
			END IF;
		-- �ǉ��E�X�V����
			IF nErrFlag = 0 THEN
				MERGE INTO &1 .FUT_PRODUCT_REQUIRE_ALL FRA -- [�����˗�]
				USING (
					SELECT
						 vProReqRec.IF_FLAG       IF_FLAG
						,vProReqRec.IF_SEQ        IF_SEQ
						,vProReqRec.PROD_REQ_ID   PROD_REQ_ID
						,vProReqRec.REQ_MONTH     REQ_MONTH
						,vProReqRec.ITEM_CODE     ITEM_CODE
						,vProReqRec.ITEM_CODE2    ITEM_CODE2
						,vProReqRec.ITEM_NAME2    ITEM_NAME2
						,vProReqRec.REQ_QTY       REQ_QTY
						,vProReqRec.REQ_DATE      REQ_DATE
						,vProReqRec.REQ_LINE      REQ_LINE
						,vProReqRec.BOM_UPD_FLAG  BOM_UPD_FLAG
						,vProReqRec.PROPERTY01    PROPERTY01
						,vProReqRec.PROPERTY02    PROPERTY02
						,vProReqRec.PROPERTY03    PROPERTY03
						,vProReqRec.PROPERTY04    PROPERTY04
						,vProReqRec.PROPERTY05    PROPERTY05
					FROM DUAL
				) UPA
				ON (
						FRA.REQ_MONTH = UPA.REQ_MONTH
					AND FRA.ITEM_CODE = UPA.ITEM_CODE
					AND FRA.REQ_DATE  = UPA.REQ_DATE
				)
				WHEN MATCHED THEN
					UPDATE SET
						 IF_FLAG      = UPA.IF_FLAG
						,IF_SEQ       = UPA.IF_SEQ
						,PROD_REQ_ID  = UPA.PROD_REQ_ID
						,ITEM_CODE2   = UPA.ITEM_CODE2
						,ITEM_NAME2   = UPA.ITEM_NAME2
						,REQ_QTY      = UPA.REQ_QTY
						,REQ_LINE     = UPA.REQ_LINE
						,BOM_UPD_FLAG = UPA.BOM_UPD_FLAG
						,PROPERTY01   = UPA.PROPERTY01
						,PROPERTY02   = UPA.PROPERTY02
						,PROPERTY03   = UPA.PROPERTY03
						,PROPERTY04   = UPA.PROPERTY04
						,PROPERTY05   = UPA.PROPERTY05
						,UPD_SID      = cSID
						,UPD_USER     = cUSER
						,UPD_DATE     = SYSDATE
				WHEN NOT MATCHED THEN
					INSERT (
						 IF_FLAG
						,IF_SEQ
						,PROD_REQ_ID
						,REQ_MONTH
						,ITEM_CODE
						,ITEM_CODE2
						,ITEM_NAME2
						,REQ_QTY
						,REQ_DATE
						,REQ_LINE
						,BOM_UPD_FLAG
						,PROPERTY01
						,PROPERTY02
						,PROPERTY03
						,PROPERTY04
						,PROPERTY05
						,UPD_SID
						,UPD_USER
						,UPD_DATE
					) VALUES (
						 UPA.IF_FLAG
						,UPA.IF_SEQ
						,UPA.PROD_REQ_ID
						,UPA.REQ_MONTH
						,UPA.ITEM_CODE
						,UPA.ITEM_CODE2
						,UPA.ITEM_NAME2
						,UPA.REQ_QTY
						,UPA.REQ_DATE
						,UPA.REQ_LINE
						,UPA.BOM_UPD_FLAG
						,UPA.PROPERTY01
						,UPA.PROPERTY02
						,UPA.PROPERTY03
						,UPA.PROPERTY04
						,UPA.PROPERTY05
						,cSID
						,cUSER
						,SYSDATE
					)
				;
			ELSE
				nErr := nErr + 1;
			END IF;
		ELSE
		-- �폜����
			DELETE
			FROM &1 .FUT_PRODUCT_REQUIRE_ALL
			WHERE
					REQ_MONTH = vProReqRec.REQ_MONTH
				AND ITEM_CODE = vProReqRec.ITEM_CODE
				AND REQ_DATE  = vProReqRec.REQ_DATE
			;
			nDel := nDel + 1;
		END IF;
		
		-- �����˗������ɒǉ�
		INSERT INTO FUT_PROD_REQUIRE_HIST (
			 IF_FLAG
			,IF_SEQ
			,IF_DATE
			,PROD_REQ_ID
			,REQ_MONTH
			,ITEM_CODE
			,ITEM_CODE2
			,ITEM_NAME2
			,REQ_QTY
			,REQ_DATE
			,REQ_LINE
			,BOM_UPD_FLAG
			,PROPERTY01
			,PROPERTY02
			,PROPERTY03
			,PROPERTY04
			,PROPERTY05
			,UPD_SID
			,UPD_USER
			,UPD_DATE
		) VALUES (
			 vProReqRec.IF_FLAG
			,vProReqRec.IF_SEQ
			,SYSDATE
			,vProReqRec.PROD_REQ_ID
			,vProReqRec.REQ_MONTH
			,vProReqRec.ITEM_CODE
			,vProReqRec.ITEM_CODE2
			,vProReqRec.ITEM_NAME2
			,vProReqRec.REQ_QTY
			,vProReqRec.REQ_DATE
			,vProReqRec.REQ_LINE
			,vProReqRec.BOM_UPD_FLAG
			,vProReqRec.PROPERTY01
			,vProReqRec.PROPERTY02
			,vProReqRec.PROPERTY03
			,vProReqRec.PROPERTY04
			,vProReqRec.PROPERTY05
			,cSID
			,cUSER
			,SYSDATE
		)
		;
		-- �����˗�(IN)����폜
		DELETE FROM FUT_PRODUCT_REQUIRE
		WHERE IF_SEQ = vProReqRec.IF_SEQ
		;
		
		nCnt := nCnt + 1;
		
	END LOOP;
	CLOSE cProReq;
	
	COMMIT;

	PrintLog(cSID || '�������� ' || nCnt || ' (�폜���� ' || nDel || ' )' || ' (�G���[���� ' || nErr || ' )');
	PrintLog(cSID || '�����˗��g�����捞 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�����˗��g�����捞 �G���[�I��');
		RAISE;

END;
/

EXIT;

