package com.st_ones.everf.serverside.domain;


import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;

public class BaseDomain extends BaseObject {

    private static final long serialVersionUID = -7253266986993971389L;

    public UserInfo getSes() {
        return UserInfoManager.getUserInfo();
    }
}
