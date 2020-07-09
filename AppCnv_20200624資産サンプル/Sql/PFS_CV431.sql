/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �I�����g�����X�V����
--   �����˗�TBL�i�����j�̎捞�t���O���I���i1�j�̃��R�[�h�ɑ΂��āA�i�ڍ\���X�V�t���O���X�V����i1�j�ɍX�V����B
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

cSID	VARCHAR2(25) := 'PFS_CV431';	-- �T�u�V�X�e��ID

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

	PrintLog(cSID || '�I�����g�����X�V���� �J�n');
	
	UPDATE FUT_PRODUCT_REQUIRE_ALL SET BOM_Upd_Flag = '1' WHERE Flg = '1';
	
	COMMIT;

	PrintLog(cSID || '�I�����g�����X�V���� �I��');

EXCEPTION
	WHEN OTHERS THEN
		PrintLog(cSID || '�I�����g�����X�V���� �G���[�I��');
		RAISE;

END;
/

EXIT;

