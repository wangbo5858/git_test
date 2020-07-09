/* ��O�G���[�ɂ��Ή� */
WHENEVER OSERROR  EXIT FAILURE     ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

/******************************************************************************/
-- �V�X�e�����X�V
-- �y�����z
--   &1  : �X�L�[�}��(PPS�p�̃X�L�[�})
--   &2  : ��ЃR�[�h
--   &3  : ���ƕ��R�[�h
--   &4  : �H��R�[�h
--   &5  : �w���
/******************************************************************************/

DECLARE
	arg_date      CONSTANT VARCHAR2(100) := '&5';
	var_base_date DATE;
BEGIN
	var_base_date := SYSDATE;
	IF arg_date <> '*' THEN
		var_base_date := TO_DATE(REPLACE(REPLACE(arg_date,'/',''),'-',''),'YYYYMMDD');
	END IF;

	-- �v��K���̍X�V
	UPDATE FAD_PLANNING_RULE TG
	SET TG.APPOINT_TODAY = TRUNC(var_base_date, 'DD')
	;

	-- �r���N���A
	DELETE FROM FAD_ITEM_EXCLUSIVE;		/* �i�ڔr�� */
	DELETE FROM FAD_LOAD_EXCLUSIVE;		/* ���הr�� */
	DELETE FROM FAD_TABLE_EXCLUSIVE;	/* �e�[�u���r�� */

	-- �J�E���g�E�N���A
	DELETE FROM FAN_MENU_RUN_CNT;

	COMMIT;
END;
/

EXIT;
