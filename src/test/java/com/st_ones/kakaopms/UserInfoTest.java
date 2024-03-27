package com.st_ones.kakaopms;

import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.threadlocal.GlobalMapThreadLocal;

public class UserInfoTest {

    private UserInfoTest() {
    }

    public static <T extends BaseInfo> void createUserInfo(T userInfo) {
        GlobalMapThreadLocal.set("EVERF_USER_INFO", userInfo);
    }

    public static void removeUserInfo() {
        GlobalMapThreadLocal.set("EVERF_USER_INFO", (Object)null);
    }

    public static <T extends BaseInfo> T getUserInfo() {
        Object userInfo = GlobalMapThreadLocal.get("EVERF_USER_INFO");
        return (T) (userInfo == null ? new BaseInfo() : (BaseInfo)userInfo);
    }

    public static <T> T getUserInfoImpl() {
        Object userInfo = GlobalMapThreadLocal.get("EVERF_USER_INFO");
        return userInfo == null ? (T) new BaseInfo() : (T) userInfo;
    }
}