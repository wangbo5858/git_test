-- =================================================================================================
-- UPD_MENU_STATUS_01.sql
-- =================================================================================================
DECLARE
  -- -----------------------------------------------------------------------------------------------
  -- 変数(引数用)
  -- -----------------------------------------------------------------------------------------------
  prmSYSTEM_ID               FAN_MENU_STATUS.SYSTEM_ID%TYPE;                      -- システムID
  prmMENU_ID                 FAN_MENU_STATUS.MENU_ID%TYPE;                        -- メニューID
  prmSTATUS_TYPE             FAN_MENU_STATUS.STATUS_TYPE%TYPE;                    -- ステータス区分
  prmUPDATE_TYPE             NUMBER;                                              -- メニューステータス更新区分
  prmEXPLANATION             FAN_MENU_STATUS.EXPLANATION%TYPE;                    -- 説明
  -- -----------------------------------------------------------------------------------------------
  -- 変数(カーソル用)
  -- -----------------------------------------------------------------------------------------------
  CURSOR cur_MenuStatus(p_vSYSTEM_ID VARCHAR2,p_vMENU_ID VARCHAR2) IS
    SELECT * FROM FAN_MENU_STATUS
    WHERE SYSTEM_ID = p_vSYSTEM_ID AND MENU_ID = p_vMENU_ID
  ;
  row_MenuStatus             cur_MenuStatus%ROWTYPE;              -- メニューステータス
  -- -----------------------------------------------------------------------------------------------
  -- 変数(データ取得／更新用)
  -- -----------------------------------------------------------------------------------------------
  orgSTART_DATE              FAN_MENU_STATUS.START_DATE%TYPE;                     -- 開始日時
  orgEND_DATE                FAN_MENU_STATUS.END_DATE%TYPE;                       -- 終了日時
  orgSAVE_DATE               FAN_MENU_STATUS.SAVE_DATE%TYPE;                      -- 保存日時
  orgWARNING_DATE            FAN_MENU_STATUS.WARNING_DATE%TYPE;                   -- 警告日時
  orgERROR_DATE              FAN_MENU_STATUS.ERROR_DATE%TYPE;                     -- 異常日時
  orgLAST_START_DATE         FAN_MENU_STATUS.LAST_START_DATE%TYPE;                -- 前回開始日時
  orgLAST_END_DATE           FAN_MENU_STATUS.LAST_END_DATE%TYPE;                  -- 前回終了日時
  orgLAST_SAVE_DATE          FAN_MENU_STATUS.LAST_SAVE_DATE%TYPE;                 -- 前回保存日時
  orgLAST_WARNING_DATE       FAN_MENU_STATUS.LAST_WARNING_DATE%TYPE;              -- 前回警告日時
  orgLAST_ERROR_DATE         FAN_MENU_STATUS.LAST_ERROR_DATE%TYPE;                -- 前回異常日時
  orgINS_SID                 FAN_MENU_STATUS.INS_SID%TYPE;                        -- 追加サブシステムID
  orgINS_USER                FAN_MENU_STATUS.INS_USER%TYPE;                       -- 追加ユーザー
  orgINS_DATE                FAN_MENU_STATUS.INS_DATE%TYPE;                       -- 追加日時
  orgUPD_SID                 FAN_MENU_STATUS.UPD_SID%TYPE;                        -- 更新サブシステムID
  orgUPD_USER                FAN_MENU_STATUS.UPD_USER%TYPE;                       -- 更新ユーザー
  orgUPD_DATE                FAN_MENU_STATUS.UPD_DATE%TYPE;                       -- 更新日時
  -- ===============================================================================================
  -- 初期化
  -- ===============================================================================================
  PROCEDURE Initialize IS
  BEGIN
    orgSTART_DATE            := NULL;                                             -- 開始日時
    orgEND_DATE              := NULL;                                             -- 終了日時
    orgSAVE_DATE             := NULL;                                             -- 保存日時
    orgWARNING_DATE          := NULL;                                             -- 警告日時
    orgERROR_DATE            := NULL;                                             -- 異常日時
    orgLAST_START_DATE       := NULL;                                             -- 前回開始日時
    orgLAST_END_DATE         := NULL;                                             -- 前回終了日時
    orgLAST_SAVE_DATE        := NULL;                                             -- 前回保存日時
    orgLAST_WARNING_DATE     := NULL;                                             -- 前回警告日時
    orgLAST_ERROR_DATE       := NULL;                                             -- 前回異常日時
    orgINS_SID               := NULL;                                             -- 追加サブシステムID
    orgINS_USER              := NULL;                                             -- 追加ユーザー
    orgINS_DATE              := SYSDATE;                                          -- 追加日時
    orgUPD_SID               := NULL;                                             -- 更新サブシステムID
    orgUPD_USER              := NULL;                                             -- 更新ユーザー
    orgUPD_DATE              := SYSDATE;                                          -- 更新日時
  END;
  -- ===============================================================================================
  -- 旧データ取得
  -- ===============================================================================================
  PROCEDURE GetOldData(p_vSYSTEM_ID VARCHAR2, p_vMENU_ID VARCHAR2) IS
  BEGIN
    OPEN cur_MenuStatus(p_vSYSTEM_ID, p_vMENU_ID);
    LOOP
      FETCH cur_MenuStatus INTO row_MenuStatus;
      EXIT WHEN cur_MenuStatus%NOTFOUND;
        orgSTART_DATE        := row_MenuStatus.START_DATE;                        -- 開始日時
        orgEND_DATE          := row_MenuStatus.END_DATE;                          -- 終了日時
        orgSAVE_DATE         := row_MenuStatus.SAVE_DATE;                         -- 保存日時
        orgWARNING_DATE      := row_MenuStatus.WARNING_DATE;                      -- 警告日時
        orgERROR_DATE        := row_MenuStatus.ERROR_DATE;                        -- 異常日時
        orgLAST_START_DATE   := row_MenuStatus.LAST_START_DATE;                   -- 前回開始日時
        orgLAST_END_DATE     := row_MenuStatus.LAST_END_DATE;                     -- 前回終了日時
        orgLAST_SAVE_DATE    := row_MenuStatus.LAST_SAVE_DATE;                    -- 前回保存日時
        orgLAST_WARNING_DATE := row_MenuStatus.LAST_WARNING_DATE;                 -- 前回警告日時
        orgLAST_ERROR_DATE   := row_MenuStatus.LAST_ERROR_DATE;                   -- 前回異常日時
        orgINS_SID           := row_MenuStatus.INS_SID;                           -- 追加サブシステムID
        orgINS_USER          := row_MenuStatus.INS_USER;                          -- 追加ユーザー
        orgINS_DATE          := row_MenuStatus.INS_DATE;                          -- 追加日時
        orgUPD_SID           := row_MenuStatus.UPD_SID;                           -- 更新サブシステムID
        orgUPD_USER          := row_MenuStatus.UPD_USER;                          -- 更新ユーザー
        orgUPD_DATE          := row_MenuStatus.UPD_DATE;                          -- 更新日時
      EXIT;
    END LOOP;
    CLOSE cur_MenuStatus;
  END;
  -- ===============================================================================================
  -- 新日付設定
  -- ===============================================================================================
  PROCEDURE SetNewDate(p_UpdateType NUMBER) IS
  BEGIN
    
    IF    (p_UpdateType = 1) THEN                 -- 1 : START_DATE       開始日時
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
    ELSIF (p_UpdateType = 2) THEN                 -- 2 : END_DATE         終了日時
      orgEND_DATE            := SYSDATE;
    ELSIF (p_UpdateType = 3) THEN                 -- 3 : SAVE_DATE        保存日時
      orgSAVE_DATE           := SYSDATE;
    ELSIF (p_UpdateType = 4) THEN                 -- 4 : WARNING_DATE     警告日時
      orgWARNING_DATE        := SYSDATE;
    ELSIF (p_UpdateType = 5) THEN                 -- 5 : ERROR_DATE       異常日時
      orgERROR_DATE          := SYSDATE;
    ELSIF (p_UpdateType = 6) THEN                 -- 6 : SAVE_END_DATE    保存終了日時
      orgEND_DATE            := SYSDATE;
      orgSAVE_DATE           := SYSDATE;
    ELSIF (p_UpdateType = 7) THEN                 -- 7 : WARNING_END_DATE 警告終了日時
      orgEND_DATE            := SYSDATE;
      orgWARNING_DATE        := SYSDATE;
    ELSIF (p_UpdateType = 8) THEN                 -- 8 : ERROR_END_DATE   異常終了日時
      orgEND_DATE            := SYSDATE;
      orgERROR_DATE          := SYSDATE;
    ELSE
      NULL;
    END IF;
  END;
  -- ===============================================================================================
  -- データ更新
  -- ===============================================================================================
  PROCEDURE UpdateData(p_vSYSTEM_ID VARCHAR2, p_vMENU_ID VARCHAR2, p_vSTATUS_TYPE NUMBER, p_vEXPLANATION NVARCHAR2) IS
  BEGIN
    DELETE FROM FAN_MENU_STATUS WHERE SYSTEM_ID = p_vSYSTEM_ID AND MENU_ID = p_vMENU_ID;
    INSERT INTO FAN_MENU_STATUS (
       SYSTEM_ID                                                  -- システムID
      ,MENU_ID                                                    -- メニューID
      ,STATUS_TYPE                                                -- ステータス区分
      ,EXPLANATION                                                -- 説明
      ,START_DATE                                                 -- 開始日時
      ,END_DATE                                                   -- 終了日時
      ,SAVE_DATE                                                  -- 保存日時
      ,WARNING_DATE                                               -- 警告日時
      ,ERROR_DATE                                                 -- 異常日時
      ,LAST_START_DATE                                            -- 前回開始日時
      ,LAST_END_DATE                                              -- 前回終了日時
      ,LAST_SAVE_DATE                                             -- 前回保存日時
      ,LAST_WARNING_DATE                                          -- 前回警告日時
      ,LAST_ERROR_DATE                                            -- 前回異常日時
      ,INS_SID                                                    -- 追加サブシステムID
      ,INS_USER                                                   -- 追加ユーザー
      ,INS_DATE                                                   -- 追加日時
      ,UPD_SID                                                    -- 更新サブシステムID
      ,UPD_USER                                                   -- 更新ユーザー
      ,UPD_DATE                                                   -- 更新日時
    ) VALUES (
       p_vSYSTEM_ID                                               -- システムID
      ,p_vMENU_ID                                                 -- メニューID
      ,p_vSTATUS_TYPE                                             -- ステータス区分
      ,p_vEXPLANATION                                             -- 説明
      ,orgSTART_DATE                                              -- 開始日時
      ,orgEND_DATE                                                -- 終了日時
      ,orgSAVE_DATE                                               -- 保存日時
      ,orgWARNING_DATE                                            -- 警告日時
      ,orgERROR_DATE                                              -- 異常日時
      ,orgLAST_START_DATE                                         -- 前回開始日時
      ,orgLAST_END_DATE                                           -- 前回終了日時
      ,orgLAST_SAVE_DATE                                          -- 前回保存日時
      ,orgLAST_WARNING_DATE                                       -- 前回警告日時
      ,orgLAST_ERROR_DATE                                         -- 前回異常日時
      ,orgINS_SID                                                 -- 追加サブシステムID
      ,orgINS_USER                                                -- 追加ユーザー
      ,orgINS_DATE                                                -- 追加日時
      ,orgUPD_SID                                                 -- 更新サブシステムID
      ,orgUPD_USER                                                -- 更新ユーザー
      ,orgUPD_DATE                                                -- 更新日時
    )
    ;
  END;
-- =================================================================================================
-- メイン処理
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
