package com.st_ones.common.file.service;

import org.apache.commons.lang3.StringUtils;

public class UUIDGenerator {
    public static String getUUID(String uuidType) {

        int length = 20;
        if(!StringUtils.equals(uuidType, "UUID")) {
            length = 50;
        }

        int index;
        char[] charSet = new char[] {
                '0','1','2','3','4','5','6','7','8','9'
                ,'A','B','C','D','E','F','G','H','I','J','K','L','M'
                ,'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
                ,'a','b','c','d','e','f','g','h','i','j','k','l','m'
                ,'n','o','p','q','r','s','t','u','v','w','x','y','z'
                ,'_'};

        StringBuffer sb = new StringBuffer();
        for(int i=0; i < length; i++) {
            index = (int) (charSet.length * Math.random());
            sb.append(charSet[index]);
        }

        return sb.toString();
    }
}
