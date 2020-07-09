/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �i�ڍ��@�}�X�^�捞 �i�ڃ}�X�^�X�V1
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
cSID	VARCHAR2(25) := 'PFS_V305_02';	-- �T�u�V�X�e��ID
cUSER	VARCHAR2(25) := 'SYSTEM';	-- ���[�U

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

	PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �i�ڃ}�X�^�X�V1 �J�n');
	
	UPDATE FMI_ITEM FI
	SET FI.ITEM_TYPE = NVL(
			(
			SELECT FP.PROPERTY01
			FROM (
					SELECT MIN(LPP1.LINE_RESOURCE_CODE) LINE_RESOURCE_CODE
					FROM FMR_LINE_PRODUCT_PROCESS LPP1 INNER JOIN
						 (
							SELECT
								 COMPANY_CODE
								,DIVISION_CODE
								,ITEM_CODE
								,MIN(PRIORITY) PRIORITY
							FROM FMR_LINE_PRODUCT_PROCESS
							GROUP BY COMPANY_CODE, DIVISION_CODE, ITEM_CODE
						 ) LPP2
						ON      LPP1.COMPANY_CODE  = inCOMCD
						 	AND LPP1.DIVISION_CODE = inDIVCD
						 	AND LPP1.ITEM_CODE     = FI.ITEM_CODE
						 	AND LPP2.COMPANY_CODE  = inCOMCD
							AND LPP2.DIVISION_CODE = inDIVCD
							AND LPP2.ITEM_CODE     = FI.ITEM_CODE
							AND LPP1.PRIORITY      = LPP2.PRIORITY
				) LPP
				INNER JOIN FMR_LINE_RESOURCE LR
				ON      LR.COMPANY_CODE       = inCOMCD
				 	AND LR.DIVISION_CODE      = inDIVCD
				 	AND LR.LINE_RESOURCE_CODE = LPP.LINE_RESOURCE_CODE
				INNER JOIN FMR_PROCESS FP
				ON      FP.COMPANY_CODE  = inCOMCD
				 	AND FP.DIVISION_CODE = inDIVCD
				 	AND FP.PROCESS_CODE  = LR.PROCESS_CODE
			)
			,'4')
	WHERE
		    EXISTS (
		    	SELECT * FROM FMR_LINE_PRODUCT_PROCESS
		    	WHERE
					    COMPANY_CODE   = inCOMCD
				 	AND DIVISION_CODE  = inDIVCD
				 	AND ITEM_CODE      = FI.ITEM_CODE
				)
	;
	COMMIT;

	PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �i�ڃ}�X�^�X�V1 �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �i�ڃ}�X�^�X�V1 �G���[�I��');
		RAISE;

END;
/

