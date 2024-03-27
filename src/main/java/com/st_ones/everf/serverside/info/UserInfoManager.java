package com.st_ones.everf.serverside.info;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.BaseConstant;
import com.st_ones.everf.serverside.threadlocal.GlobalMapThreadLocal;

public class UserInfoManager {

    private UserInfoManager() {
    }

    public static void createUserInfo(UserInfo userInfo) {
        GlobalMapThreadLocal.set(BaseConstant.THREAD_LOCAL_USERINFO_KEY, userInfo);
    }

    public static void removeUserInfo() {
        GlobalMapThreadLocal.set(BaseConstant.THREAD_LOCAL_USERINFO_KEY, null);
    }

    public static UserInfo getUserInfo() {
        Object userInfo = GlobalMapThreadLocal.get(BaseConstant.THREAD_LOCAL_USERINFO_KEY);
        if (userInfo == null) {
            return new UserInfo();
        }
        return (UserInfo) userInfo;
    }

    public static UserInfo getUserInfoImpl() {
        Object userInfo = GlobalMapThreadLocal.get(BaseConstant.THREAD_LOCAL_USERINFO_KEY);
        if (userInfo == null) {
            return new UserInfo();
        }
        return (UserInfo) userInfo;
    }
}