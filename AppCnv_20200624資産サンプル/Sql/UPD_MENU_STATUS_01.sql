-- =================================================================================================
-- UPD_MENU_STATUS_01.sql
-- =================================================================================================
DECLARE
  -- -----------------------------------------------------------------------------------------------
  -- �ϐ�(�����p)
  -- -----------------------------------------------------------------------------------------------
  prmSYSTEM_ID               FAN_MENU_STATUS.SYSTEM_ID%TYPE;                      -- �V�X�e��ID
  prmMENU_ID                 FAN_MENU_STATUS.MENU_ID%TYPE;                        -- ���j���[ID
  prmSTATUS_TYPE             FAN_MENU_STATUS.STATUS_TYPE%TYPE;                    -- �X�e�[�^�X�敪
  prmUPDATE_TYPE             NUMBER;                                              -- ���j���[�X�e�[�^�X�X�V�敪
  prmEXPLANATION             FAN_MENU_STATUS.EXPLANATION%TYPE;                    -- ����
  -- -----------------------------------------------------------------------------------------------
  -- �ϐ�(�J�[�\���p)
  -- -----------------------------------------------------------------------------------------------
  CURSOR cur_MenuStatus(p_vSYSTEM_ID VARCHAR2,p_vMENU_ID VARCHAR2) IS
    SELECT * FROM FAN_MENU_STATUS
    WHERE SYSTEM_ID = p_vSYSTEM_ID AND MENU_ID = p_vMENU_ID
  ;
  row_MenuStatus             cur_MenuStatus%ROWTYPE;              -- ���j���[�X�e�[�^�X
  -- -----------------------------------------------------------------------------------------------
  -- �ϐ�(�f�[�^�擾�^�X�V�p)
  -- -----------------------------------------------------------------------------------------------
  orgSTART_DATE              FAN_MENU_STATUS.START_DATE%TYPE;                     -- �J�n����
  orgEND_DATE                FAN_MENU_STATUS.END_DATE%TYPE;                       -- �I������
  orgSAVE_DATE               FAN_MENU_STATUS.SAVE_DATE%TYPE;                      -- �ۑ�����
  orgWARNING_DATE            FAN_MENU_STATUS.WARNING_DATE%TYPE;                   -- �x������
  orgERROR_DATE              FAN_MENU_STATUS.ERROR_DATE%TYPE;                     -- �ُ����
  orgLAST_START_DATE         FAN_MENU_STATUS.LAST_START_DATE%TYPE;                -- �O��J�n����
  orgLAST_END_DATE           FAN_MENU_STATUS.LAST_END_DATE%TYPE;                  -- �O��I������
  orgLAST_SAVE_DATE          FAN_MENU_STATUS.LAST_SAVE_DATE%TYPE;                 -- �O��ۑ�����
  orgLAST_WARNING_DATE       FAN_MENU_STATUS.LAST_WARNING_DATE%TYPE;              -- �O��x������
  orgLAST_ERROR_DATE         FAN_MENU_STATUS.LAST_ERROR_DATE%TYPE;                -- �O��ُ����
  orgINS_SID                 FAN_MENU_STATUS.INS_SID%TYPE;                        -- �ǉ��T�u�V�X�e��ID
  orgINS_USER                FAN_MENU_STATUS.INS_USER%TYPE;                       -- �ǉ����[�U�[
  orgINS_DATE                FAN_MENU_STATUS.INS_DATE%TYPE;                       -- �ǉ�����
  orgUPD_SID                 FAN_MENU_STATUS.UPD_SID%TYPE;                        -- �X�V�T�u�V�X�e��ID
  orgUPD_USER                FAN_MENU_STATUS.UPD_USER%TYPE;                       -- �X�V���[�U�[
  orgUPD_DATE                FAN_MENU_STATUS.UPD_DATE%TYPE;                       -- �X�V����
  -- ===============================================================================================
  -- ������
  -- ===============================================================================================
  PROCEDURE Initialize IS
  BEGIN
    orgSTART_DATE            := NULL;                                             -- �J�n����
    orgEND_DATE              := NULL;                                             -- �I������
    orgSAVE_DATE             := NULL;                                             -- �ۑ�����
    orgWARNING_DATE          := NULL;                                             -- �x������
    orgERROR_DATE            := NULL;                                             -- �ُ����
    orgLAST_START_DATE       := NULL;                                             -- �O��J�n����
    orgLAST_END_DATE         := NULL;                                             -- �O��I������
    orgLAST_SAVE_DATE        := NULL;                                             -- �O��ۑ�����
    orgLAST_WARNING_DATE     := NULL;                                             -- �O��x������
    orgLAST_ERROR_DATE       := NULL;                                             -- �O��ُ����
    orgINS_SID               := NULL;                                             -- �ǉ��T�u�V�X�e��ID
    orgINS_USER              := NULL;                                             -- �ǉ����[�U�[
    orgINS_DATE              := SYSDATE;                                          -- �ǉ�����
    orgUPD_SID               := NULL;                                             -- �X�V�T�u�V�X�e��ID
    orgUPD_USER              := NULL;                                             -- �X�V���[�U�[
    orgUPD_DATE              := SYSDATE;                                          -- �X�V����
  END;
  -- ===============================================================================================
  -- ���f�[�^�擾
  -- ===============================================================================================
  PROCEDURE GetOldData(p_vSYSTEM_ID VARCHAR2, p_vMENU_ID VARCHAR2) IS
  BEGIN
    OPEN cur_MenuStatus(p_vSYSTEM_ID, p_vMENU_ID);
    LOOP
      FETCH cur_MenuStatus INTO row_MenuStatus;
      EXIT WHEN cur_MenuStatus%NOTFOUND;
        orgSTART_DATE        := row_MenuStatus.START_DATE;                        -- �J�n����
        orgEND_DATE          := row_MenuStatus.END_DATE;                          -- �I������
        orgSAVE_DATE         := row_MenuStatus.SAVE_DATE;                         -- �ۑ�����
        orgWARNING_DATE      := row_MenuStatus.WARNING_DATE;                      -- �x������
        orgERROR_DATE        := row_MenuStatus.ERROR_DATE;                        -- �ُ����
        orgLAST_START_DATE   := row_MenuStatus.LAST_START_DATE;                   -- �O��J�n����
        orgLAST_END_DATE     := row_MenuStatus.LAST_END_DATE;                     -- �O��I������
        orgLAST_SAVE_DATE    := row_MenuStatus.LAST_SAVE_DATE;                    -- �O��ۑ�����
        orgLAST_WARNING_DATE := row_MenuStatus.LAST_WARNING_DATE;                 -- �O��x������
        orgLAST_ERROR_DATE   := row_MenuStatus.LAST_ERROR_DATE;                   -- �O��ُ����
        orgINS_SID           := row_MenuStatus.INS_SID;                           -- �ǉ��T�u�V�X�e��ID
        orgINS_USER          := row_MenuStatus.INS_USER;                          -- �ǉ����[�U�[
        orgINS_DATE          := row_MenuStatus.INS_DATE;                          -- �ǉ�����
        orgUPD_SID           := row_MenuStatus.UPD_SID;                           -- �X�V�T�u�V�X�e��ID
        orgUPD_USER          := row_MenuStatus.UPD_USER;                          -- �X�V���[�U�[
        orgUPD_DATE          := row_MenuStatus.UPD_DATE;                          -- �X�V����
      EXIT;
    END LOOP;
    CLOSE cur_MenuStatus;
  END;
  -- ===============================================================================================
  -- �V���t�ݒ�
  -- ===============================================================================================
  PROCEDURE SetNewDate(p_UpdateType NUMBER) IS
  BEGIN
    
    IF    (p_UpdateType = 1) THEN                 -- 1 : START_DATE       �J�n����
      IF (orgSTART_DATE      IS NOT NULL) THEN
        orgLAST_START_DATE   := orgSTART_DATE;
      END IF;
      IF (orgEND_DATE        IS NOT NULL) THEN
        orgLAST_END_DATE     := orgEND_DATE;
      END IF;
      IF (orgSAVE_DATE       IS NOT NULL) THEN
        orgLAST_SAVE_DATE    := orgSAVE_DATE;
      END IF;
      IF (orgWARNING_DATE    IS NOT NULL) THEN
        orgLAST_WARNING_DATE := orgWARNING_DATE;
      END IF;
      IF (orgERROR_DATE      IS NOT NULL) THEN
        orgLAST_ERROR_DATE   := orgERROR_DATE;
      END IF;
      orgEND_DATE            := NULL;
      orgSAVE_DATE           := NULL;
      orgWARNING_DATE        := NULL;
      orgERROR_DATE          := NULL;
      orgSTART_DATE          := SYSDATE;
    ELSIF (p_UpdateType = 2) THEN                 -- 2 : END_DATE         �I������
      orgEND_DATE            := SYSDATE;
    ELSIF (p_UpdateType = 3) THEN                 -- 3 : SAVE_DATE        �ۑ�����
      orgSAVE_DATE           := SYSDATE;
    ELSIF (p_UpdateType = 4) THEN                 -- 4 : WARNING_DATE     �x������
      orgWARNING_DATE        := SYSDATE;
    ELSIF (p_UpdateType = 5) THEN                 -- 5 : ERROR_DATE       �ُ����
      orgERROR_DATE          := SYSDATE;
    ELSIF (p_UpdateType = 6) THEN                 -- 6 : SAVE_END_DATE    �ۑ��I������
      orgEND_DATE            := SYSDATE;
      orgSAVE_DATE           := SYSDATE;
    ELSIF (p_UpdateType = 7) THEN                 -- 7 : WARNING_END_DATE �x���I������
      orgEND_DATE            := SYSDATE;
      orgWARNING_DATE        := SYSDATE;
    ELSIF (p_UpdateType = 8) THEN                 -- 8 : ERROR_END_DATE   �ُ�I������
      orgEND_DATE            := SYSDATE;
      orgERROR_DATE          := SYSDATE;
    ELSE
      NULL;
    END IF;
  END;
  -- ===============================================================================================
  -- �f�[�^�X�V
  -- ===============================================================================================
  PROCEDURE UpdateData(p_vSYSTEM_ID VARCHAR2, p_vMENU_ID VARCHAR2, p_vSTATUS_TYPE NUMBER, p_vEXPLANATION NVARCHAR2) IS
  BEGIN
    DELETE FROM FAN_MENU_STATUS WHERE SYSTEM_ID = p_vSYSTEM_ID AND MENU_ID = p_vMENU_ID;
    INSERT INTO FAN_MENU_STATUS (
       SYSTEM_ID                                                  -- �V�X�e��ID
      ,MENU_ID                                                    -- ���j���[ID
      ,STATUS_TYPE                                                -- �X�e�[�^�X�敪
      ,EXPLANATION                                                -- ����
      ,START_DATE                                                 -- �J�n����
      ,END_DATE                                                   -- �I������
      ,SAVE_DATE                                                  -- �ۑ�����
      ,WARNING_DATE                                               -- �x������
      ,ERROR_DATE                                                 -- �ُ����
      ,LAST_START_DATE                                            -- �O��J�n����
      ,LAST_END_DATE                                              -- �O��I������
      ,LAST_SAVE_DATE                                             -- �O��ۑ�����
      ,LAST_WARNING_DATE                                          -- �O��x������
      ,LAST_ERROR_DATE                                            -- �O��ُ����
      ,INS_SID                                                    -- �ǉ��T�u�V�X�e��ID
      ,INS_USER                                                   -- �ǉ����[�U�[
      ,INS_DATE                                                   -- �ǉ�����
      ,UPD_SID                                                    -- �X�V�T�u�V�X�e��ID
      ,UPD_USER                                                   -- �X�V���[�U�[
      ,UPD_DATE                                                   -- �X�V����
    ) VALUES (
       p_vSYSTEM_ID                                               -- �V�X�e��ID
      ,p_vMENU_ID                                                 -- ���j���[ID
      ,p_vSTATUS_TYPE                                             -- �X�e�[�^�X�敪
      ,p_vEXPLANATION                                             -- ����
      ,orgSTART_DATE                                              -- �J�n����
      ,orgEND_DATE                                                -- �I������
      ,orgSAVE_DATE                                               -- �ۑ�����
      ,orgWARNING_DATE                                            -- �x������
      ,orgERROR_DATE                                              -- �ُ����
      ,orgLAST_START_DATE                                         -- �O��J�n����
      ,orgLAST_END_DATE                                           -- �O��I������
      ,orgLAST_SAVE_DATE                                          -- �O��ۑ�����
      ,orgLAST_WARNING_DATE                                       -- �O��x������
      ,orgLAST_ERROR_DATE                                         -- �O��ُ����
      ,orgINS_SID                                                 -- �ǉ��T�u�V�X�e��ID
      ,orgINS_USER                                                -- �ǉ����[�U�[
      ,orgINS_DATE                                                -- �ǉ�����
      ,orgUPD_SID                                                 -- �X�V�T�u�V�X�e��ID
      ,orgUPD_USER                                                -- �X�V���[�U�[
      ,orgUPD_DATE                                                -- �X�V����
    )
    ;
  END;
-- =================================================================================================
-- ���C������
-- =================================================================================================
BEGIN
  prmSYSTEM_ID   := SUBSTR('&1', 1, 25);
  prmMENU_ID     := SUBSTR('&2', 1, 25);
  prmSTATUS_TYPE := TO_NUMBER('&3');
  prmUPDATE_TYPE := TO_NUMBER('&4');
  prmEXPLANATION := SUBSTR('&5', 1, 255);

  Initialize();
  GetOldData(prmSYSTEM_ID, prmMENU_ID);
  SetNewDate(prmUPDATE_TYPE);
  UpdateData(prmSYSTEM_ID, prmMENU_ID, prmSTATUS_TYPE, prmEXPLANATION);
END;
/
