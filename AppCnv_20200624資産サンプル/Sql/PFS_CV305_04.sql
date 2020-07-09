/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �i�ڍ��@�}�X�^�捞 �H�������}�X�^�X�V
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
cSID	VARCHAR2(25) := 'PFS_V305_03';	-- �T�u�V�X�e��ID
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

	PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �H�������}�X�^�X�V �J�n');
	
	MERGE INTO &1 .FMI_PROCESS_SEQUENCE FPS -- [�H������]
	USING (
		SELECT DISTINCT
			 PS.ITEM_CODE        ITEM_CODE
			,PS.PROCESS_CODE     PROCESS_CODE
			,LPP.PROCESS_PATTERN PROCESS_PATTERN
		FROM FMI_PROCESS_SEQUENCE PS INNER JOIN 
			(
			SELECT
				 LPP1.COMPANY_CODE            COMPANY_CODE
				,LPP1.DIVISION_CODE           DIVISION_CODE
				,LPP1.ITEM_CODE               ITEM_CODE
				,LPP1.PROCESS_PATTERN         PROCESS_PATTERN
			FROM FMR_LINE_PRODUCT_PROCESS LPP1 INNER JOIN
				 (
					SELECT
						 COMPANY_CODE
						,DIVISION_CODE
						,ITEM_CODE
						,PROCESS_PATTERN
						,MIN(PRIORITY) PRIORITY
					FROM FMR_LINE_PRODUCT_PROCESS
					GROUP BY COMPANY_CODE, DIVISION_CODE, ITEM_CODE, PROCESS_PATTERN
				 ) LPP2
				ON      LPP1.COMPANY_CODE    = inCOMCD
				 	AND LPP1.DIVISION_CODE   = inDIVCD
				 	AND LPP2.COMPANY_CODE    = inCOMCD
					AND LPP2.DIVISION_CODE   = inDIVCD
					AND LPP1.ITEM_CODE       = LPP2.ITEM_CODE
					AND LPP1.PROCESS_PATTERN = LPP2.PROCESS_PATTERN
					AND LPP1.PRIORITY        = LPP2.PRIORITY
				GROUP BY LPP1.COMPANY_CODE, LPP1.DIVISION_CODE, LPP1.ITEM_CODE, LPP1.PROCESS_PATTERN
			) LPP
			ON (
					PS.COMPANY_CODE    = LPP.COMPANY_CODE
				AND PS.DIVISION_CODE   = LPP.DIVISION_CODE
				AND PS.ITEM_CODE       = LPP.ITEM_CODE
			)
	) UPS
	ON (
			FPS.COMPANY_CODE    = inCOMCD
		AND FPS.DIVISION_CODE   = inDIVCD
		AND FPS.ITEM_CODE       = UPS.ITEM_CODE
		AND FPS.PROCESS_PATTERN = UPS.PROCESS_PATTERN
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
			,UPS.PROCESS_PATTERN
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
	-- �H���p�^�[����'*' �ȊO������΁A'*'�̍H���������폜����B
	DELETE FROM FMI_PROCESS_SEQUENCE FPS
	WHERE
		    FPS.COMPANY_CODE    = inCOMCD
		AND FPS.DIVISION_CODE   = inDIVCD
		AND FPS.PROCESS_PATTERN = '*'
		AND EXISTS (
			SELECT * FROM FMI_PROCESS_SEQUENCE FPS2
			WHERE
				    FPS2.COMPANY_CODE     = FPS.COMPANY_CODE
				AND FPS2.DIVISION_CODE    = FPS.DIVISION_CODE
				AND FPS2.ITEM_CODE        = FPS.ITEM_CODE
				AND FPS2.PROCESS_PATTERN <> '*'
			)
	;
	COMMIT;
	
	PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �H�������}�X�^�X�V �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�i�ڍ��@�}�X�^�捞 �H�������}�X�^�X�V �G���[�I��');
		RAISE;

END;
/

