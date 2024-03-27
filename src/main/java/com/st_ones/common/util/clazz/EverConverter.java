package com.st_ones.common.util.clazz;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.*;

public class EverConverter {

    private static Logger logger = LoggerFactory.getLogger(EverConverter.class);

    /**
     * Object를 JSONString으로 변환
     * Convert Object to JSONString
     *
     * @param jsonBean
     * @return String
     * @throws Exception
     */
    public static String getJsonString(Object jsonBean) throws Exception {
        String jsonString = null;
        ObjectMapper objMapper = new ObjectMapper();
        objMapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
        jsonString = objMapper.writeValueAsString(jsonBean);
        return jsonString;
    }

    /**
     * JSONString을 읽어 객체로 반환
     * Convert JSONString to Object
     *
     * @param jsonStr
     * @param objType
     * @return <T>
     * @throws Exception
     */
    public static <T> T readJsonObject(String jsonStr, Class<T> objType) throws Exception {
        ObjectMapper objMapper = new ObjectMapper();
        T t = objMapper.readValue(jsonStr, objType);
        return t;
    }

    /**
     * MultiSearchCondition을 위한 method
     * For Multi Serch Condition
     *
     * @param map
     * @return Map<String, Object>
     * @throws Exception
     */
    public static Map<String, Object> forDynamicQuery(Map<String, Object> map) throws Exception {

        List<String> multiKeys = new ArrayList<String>();
        Set<String> keySet = map.keySet();

        for (String key : keySet) {
            Object value = map.get(key);
            if (!(value instanceof String)) {
                continue;
            }

            String searchValue = (String) map.get(key);
            final String stKey = "st_" + key;

//            if (!map.containsKey(stKey)) {
//                continue;
//            }

//            String mode = (String) map.get(stKey);
            map.put(key, searchValue);

//            if (mode == null) continue;

//            if (!EverString.isEmpty(mode) && !EverString.isEmpty(searchValue)) {
                multiKeys.add(key);
//            }
        }

        for (String key : multiKeys) {
            String value = (String) map.get(key);
//            String mode = (String) map.get("st_" + key);
            String mode = "L";
            value = value.trim();
            logger.debug("EverConverter: Mode:{} /key: {} : {}", mode, key, value);
            map.put(key, value);
            map.putAll(makeDynamicStatement(mode, key, value));
        }
        return map;
    }

    /**
     * MultiSearchCondition을 위한 method
     * For Multi Serch Condition
     *
     * @param mode
     * @param key
     * @param value
     * @return Map<String, Object>
     */
    private static Map<String, String> makeDynamicStatement(String mode, String key, String value) throws Exception {

        HashMap<String, String> elementMap = new HashMap<String, String>();
        elementMap.put("E_R", " = '%s'"); // Equal
        elementMap.put("D_R", " != '%s'"); // Different
        String stringMergeOperator = null;
        String databaseId = PropertiesManager.getString("eversrm.system.database"); //SpringContextUtil.getUtilService().getDatabaseId();

        if ("OR".equals(databaseId)) {
            stringMergeOperator = "||";
        } else if ("MS".equals(databaseId)) {
            stringMergeOperator = "+";
        } else if ("MY".equals(databaseId)) {
            stringMergeOperator = ",";
        } else {
            throw new Exception("illegal database id. this value has been set by context persistence VendorDatabaseIdProvider bean. databaseId: " + databaseId);
        }

        elementMap.put("L_L", "UPPER(");
        elementMap.put("L_R", ") LIKE '%%' " + stringMergeOperator + " UPPER('%s') " + stringMergeOperator + " '%%'"); // Like
        elementMap.put("NL_L", "UPPER(");
        elementMap.put("NL_R", ") NOT LIKE '%%' " + stringMergeOperator + " UPPER('%s') " + stringMergeOperator + " '%%'"); // Not Like
        elementMap.put("B_R", " > '%s'"); // Big
        elementMap.put("BE_R", " >= '%s'"); // Big or Equal
        elementMap.put("S_R", " < '%s'"); // Small
        elementMap.put("SE_R", " <= '%s'"); // Small or Equal
        elementMap.put("IN_R", " IS NULL"); // is Null
        elementMap.put("INN_R", " IS NOT NULL"); // is Not Null
        elementMap.put("I_R", " IN " + EverString.forInQuery(value, ",")); // In
        elementMap.put("NI_R", " NOT IN " + EverString.forInQuery(value, ",")); // Not In

        Map<String, String> map = new HashMap<String, String>();
        String left = EverString.nullToEmptyString(elementMap.get(mode + "_L"));
        String right = EverString.nullToEmptyString(elementMap.get(mode + "_R"));

        /* 멀티서치 로직은 myBatis에서 #가 아닌 $를 사용해서 붙이므로 SQL Injection 공격에 취약하다. */
        left = String.format(left, EverString.changeCharacterSetApp2DbString(value.replaceAll("&#39;", "''").replaceAll("'", "''")));
        right = String.format(right, EverString.changeCharacterSetApp2DbString(value.replaceAll("&#39;", "''").replaceAll("'", "''")));

        //System.err.println("=====================================================================key="+key);

        if(!"".equals(key)) {
            String subStringKey = key.substring(key.length() - 2, key.length());
            if (subStringKey.equalsIgnoreCase("_L") || subStringKey.equalsIgnoreCase("_R")) {
                return map;
            } else {
                map.put(key + "_L", left);
                map.put(key + "_R", right);
            }
        }


        return map;
    }

    /**
     * null check
     *
     * @param str
     * @return String
     */
    public static String nullChk(String str) {

        String rtnVal = "";
        if (str == null) {
            rtnVal = "";
        } else {
            try {
                rtnVal = URLDecoder.decode(str, "UTF-8");
            } catch (UnsupportedEncodingException unsupportedencodingexception) {
                logger.error(unsupportedencodingexception.getMessage(), unsupportedencodingexception);
            }
        }
        return rtnVal;
    }

}