package com.st_ones.kakaopms;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;

public class ExtendTest {

    public static void main(String[] args) {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        System.err.println(userInfo);


    }
}