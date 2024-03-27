package com.st_ones.common.util.clazz;

import com.st_ones.common.util.SpringContextUtil;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.json.simple.JSONObject;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.security.SecureRandom;
import java.util.*;
import java.util.Map.Entry;

public class EverString {

    private static Logger logger = LoggerFactory.getLogger(EverString.class);

    /**
     * EverWebGrid 의 ImageText 컴포넌트에서 TEXT 만 추출한다. .<br>
     * return Object(TEXT 를 Return)
     * @param mapData 의 Object Data(map.get("XXX"))
     * @return Object
     */
    public static Object getCellValueGridImageText(Object mapData) {
        return new JSONObject((Map) mapData).get("text");
    }

    /**
     * str에서 sub의 반복 횟수를 반환 합니다.<br>
     * return matching sub string count
     * @param str  확인할 문자열 null이 들어 올 수도 있습니다.
     * source string
     * @param sub  count 할 부분 문자열 null이 들어 올 수도 있습니다.
     * target String
     * @return int
     */
    public static int countMatches(String str, String sub) {
        return StringUtils.countMatches(str, sub);
    }

    /**
     * 문자열이 비었거나 null인지 확인 합니다.
     * NOTE: white space에 대한 검사는 하지 않습니다.<br>
     * return true when String is null or empty<br>
     * @param str  확인할 문자열 null일 수 있습니다.
     * @return 문자열이 null이거나 빈문자열 일 경우 {@code true}를 반환 합니다.
     */
    public static boolean isEmpty(String str) {
        return StringUtils.isEmpty(str);
    }

    /**
     * 문자열이 비었거나 null인지 확인 합니다.<br>
     * return false when String is null or empty
     * @param str  확인할 문자열 null일 수 있습니다.
     * @return 문자열이 null 또는 공백이 아닐 경우 {@code true}를 반환 합니다.
     */
    public static boolean isNotEmpty(String str) {
        return StringUtils.isNotEmpty(str);
    }

    /**
     * String Array를 한 문자열로 합침니다.
     * 처음과 끝은 separator가 추가 되지 않습니다.
     * separator null 인 경우 빈문자열과 같이 취급 됩니다.<br>
     *
     * concat string array
     * Beginning and end of the String will not be added separator.
     *  separator null will be treated as empty string.
     * @param array  한 문자열로 합쳐질 배열
     * source
     * @param separator 구분자, null일 경우 빈문자열로 취급
     * seprator
     * @return String
     */
    public static String combinationArr(String[] array, String separator) {
        return StringUtils.join(array, separator);
    }

    /**
     * 왼쪽에 문자열 길이가 파라미터의 길이가 될때 까지 repChar를 채웁니다.<br>
     * add left with given character and length
     * @param str  패딩을 할 대상 문자열
     * source
     * @param length  문자열 길이
     * length
     * @param repChar  채울 물자열
     * fill character
     * @return String
     */
    public static String lpad(String str, int length, String repChar) {
        return StringUtils.leftPad(str, length, repChar);
    }

    /**
     * 오른쪽에 문자열 길이가 length가 될때 까지 repChar를 채웁니다.<br>
     * add right with given character and length
     * @param str  패딩을 할 대상 문자열
     * source
     * @param length  문자열 길이
     * length
     * @param repChar  채울 물자열
     * fill character
     * @return String
     */
    public static String rpad(String str, int length, String repChar) {
        return StringUtils.rightPad(str, length, repChar);
    }

    /**
     * str을 separatorChars 문자열로 잘라 문자열 배열을 만듭니다.<br>
     * str to string array with separator
     * @param str  자를 문자열
     * @param separatorChars  구분자
     * @return String[]
     */
    public static String[] strToArray(String str, String separatorChars) {
        return StringUtils.split(str, separatorChars);
    }

    /**
     * compare String
     * @param foo
     * @param bar
     * @return when same StringValue then reutrn true else false
     */
    public static boolean equals(String foo, String bar) {
        return StringUtils.equals(foo, bar);
    }

    /**
     * compare String
     * @param foo
     * @param bar
     * @return when not same StringValue then reutrn true else false
     */
    public static boolean notEquals(String foo, String bar) {
        return !StringUtils.equals(foo, bar);
    }

    /**
     * String foo의 값이 "true" 이면 fos "false" 이면 neg 둘다 아니면 foo를 반환<br>
     * return fos's value when foo's value is "true"
     * return neg's value when foo's value is "false"
     * else return foo's value
     * @param foo String
     * @param pos String
     * @param neg String
     * @return String
     * @throws Exception
     */
    public static String repToStr(String foo, String pos, String neg) {
        if (StringUtils.isEmpty(foo) || StringUtils.equals(foo, "null")) {
            return "";
        }
        if (StringUtils.equals(foo, "true")) {
            return pos;
        }
        if (StringUtils.equals(foo, "false")) {
            return neg;
        }
        return foo;
    }

    /**
     * 무작위 문자열을 randomStringLength 만큼 type으로 생성<br>
     * create random string
     * @param randomStringLength int 무작위 문자열을 만들 길이
     * string length
     * @param type String N: 숫자만, S: 문자열만, NS: 문자,숫자 혼합
     * N: only number, S:  only character, NS: number or character
     * @return String
     */
    public static String getRandomString(int randomStringLength, String type) {
        if ("N".equals(type)) {
            return RandomStringUtils.randomNumeric(randomStringLength);
        }
        if ("S".equals(type)) {
            return RandomStringUtils.randomAlphabetic(randomStringLength);
        }
        if ("NS".equals(type)) {
            return RandomStringUtils.randomAlphanumeric(randomStringLength);
        }
        return null;
    }

    /**
     * 문자열 중에 del문자열 제거<br>
     * remove del in str
     * @param str String
     * @param del String
     * @return String
     */
    public static String ignoreSeparator(String str, String del) {
        return StringUtils.replace(str, del, "");
    }

    /**
     * exception 정보를 String 형태로 return<br>
     * return exception infomation as String
     * @param throwable Throwable
     * @return String
     */
    public static String getStackTrace(Throwable throwable) {
        return ExceptionUtils.getStackTrace(throwable);
    }

    /**
     * 문자 코드
     * org.owasp.esapi.codecs.HTMLEntityCodec 에서 추출해서 사용
     * http://owasp-esapi-java.googlecode.com/svn/trunk/src/main/java/org/owasp/esapi/codecs/HTMLEntityCodec.java
     * @param str
     * @return
     */
    public static String replaceInjectionString(String str){
        Map<Character, String> map = new HashMap<Character,String>(252);
        map.put((char)34,       "\"");        /* quotation mark */
        map.put((char)39,       "\'");        /* single quotation mark */
        map.put((char)60,       "&lt;");        /* less-than sign */
        map.put((char)62,       "&gt;");        /* greater-than sign */

        if(str == null) return null;
        map.keySet();
        for (Character ch : map.keySet()) {
            str = str.replaceAll(ch.toString(), map.get(ch));
        }

        String stringValue = str;
        if (stringValue.toUpperCase().indexOf("--") != -1) {
            stringValue = replace(stringValue, "--", "－－");
        }

        if (stringValue.toUpperCase().indexOf(";") != -1) {
            // stringValue = replace(stringValue, ";", "；");
        }

        if (stringValue.toUpperCase().indexOf("%") != -1) {
            stringValue = replace(stringValue, "%", "％");
        }

        if (stringValue.toUpperCase().indexOf("'") != -1) {
            stringValue = replace(stringValue, "'", "");
        }

        if (stringValue.toUpperCase().indexOf("'") != -1) {
            stringValue = replace(stringValue, "'", "");
        }
        if (stringValue.toUpperCase().indexOf("SELECT") != -1) {
            stringValue = replace(stringValue, "select", "");
            stringValue = replace(stringValue, "SELECT", "");
        }
        if (stringValue.toUpperCase().indexOf("DUAL") != -1) {
            stringValue = replace(stringValue, "dual", "");
            stringValue = replace(stringValue, "DUAL", "");
        }


        if (stringValue.toUpperCase().indexOf("JAVASCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("JAVASCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 10);
            stringValue = replace(stringValue, temp_str, "ＪＡＶＡＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("JSCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("JSCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 7);
            stringValue = replace(stringValue, temp_str, "ＪＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("VBSCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("VBSCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 8);
            stringValue = replace(stringValue, temp_str, "ＶＢＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("SCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("SCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 6);
            stringValue = replace(stringValue, temp_str, "ＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("IFRAME") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("IFRAME");
            String temp_str = stringValue.substring(instr_location, instr_location + 6);
            stringValue = replace(stringValue, temp_str, "ＩＦＲＡＭＥ");
        }
        if (stringValue.toUpperCase().indexOf("FRAME") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("FRAME");
            String temp_str = stringValue.substring(instr_location, instr_location + 5);
            stringValue = replace(stringValue, temp_str, "ＦＲＡＭＥ");
        }
        if (stringValue.toUpperCase().indexOf("EXPRESSION") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("EXPRESSION");
            String temp_str = stringValue.substring(instr_location, instr_location + 10);
            stringValue = replace(stringValue, temp_str, "ＥＸＰＲＥＳＳＩＯＮ");
        }
        if (stringValue.toUpperCase().indexOf("ALERT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("ALERT");
            String temp_str = stringValue.substring(instr_location, instr_location + 5);
            stringValue = replace(stringValue, temp_str, "ＡＬＥＲＴ");
        }
        if (stringValue.toUpperCase().indexOf("OPEN") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("OPEN");
            String temp_str = stringValue.substring(instr_location, instr_location + 4);
            stringValue = replace(stringValue, temp_str, "ＯＰＥＮ");
        }
        if (stringValue.toUpperCase().indexOf("&#") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("&#");
            String temp_str = stringValue.substring(instr_location, instr_location + 2);
            stringValue = replace(stringValue, temp_str, "＆＃");
        }

        return stringValue;
    }

    public static String replaceInjectionRichTextEdit(String str){
        Map<Character, String> map = new HashMap<Character,String>(252);
        map.put((char)39,       "＇");        /* single quotation mark */

        if(str == null) return null;
        map.keySet();
        for (Character ch : map.keySet()) {
            str = str.replaceAll(ch.toString(), map.get(ch));
        }

        String stringValue = str;

        if (stringValue.toUpperCase().indexOf("--") != -1) {
            stringValue = replace(stringValue, "--", "－－");
        }

        if (stringValue.toUpperCase().indexOf("%") != -1) {
            stringValue = replace(stringValue, "%", "％");
        }

        if (stringValue.toUpperCase().indexOf("JAVASCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("JAVASCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 10);
            stringValue = replace(stringValue, temp_str, "ＪＡＶＡＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("JSCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("JSCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 7);
            stringValue = replace(stringValue, temp_str, "ＪＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("VBSCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("VBSCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 8);
            stringValue = replace(stringValue, temp_str, "ＶＢＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("SCRIPT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("SCRIPT");
            String temp_str = stringValue.substring(instr_location, instr_location + 6);
            stringValue = replace(stringValue, temp_str, "ＳＣＲＩＰＴ");
        }
        if (stringValue.toUpperCase().indexOf("IFRAME") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("IFRAME");
            String temp_str = stringValue.substring(instr_location, instr_location + 6);
            stringValue = replace(stringValue, temp_str, "ＩＦＲＡＭＥ");
        }
        if (stringValue.toUpperCase().indexOf("FRAME") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("FRAME");
            String temp_str = stringValue.substring(instr_location, instr_location + 5);
            stringValue = replace(stringValue, temp_str, "ＦＲＡＭＥ");
        }
        if (stringValue.toUpperCase().indexOf("EXPRESSION") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("EXPRESSION");
            String temp_str = stringValue.substring(instr_location, instr_location + 10);
            stringValue = replace(stringValue, temp_str, "ＥＸＰＲＥＳＳＩＯＮ");
        }
        if (stringValue.toUpperCase().indexOf("ALERT") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("ALERT");
            String temp_str = stringValue.substring(instr_location, instr_location + 5);
            stringValue = replace(stringValue, temp_str, "ＡＬＥＲＴ");
        }
        if (stringValue.toUpperCase().indexOf("OPEN") != -1) {
            int instr_location = stringValue.toUpperCase().indexOf("OPEN");
            String temp_str = stringValue.substring(instr_location, instr_location + 4);
            stringValue = replace(stringValue, temp_str, "ＯＰＥＮ");
        }
        if (stringValue.toUpperCase().indexOf("&#") != -1) {
//			int instr_location = stringValue.toUpperCase().indexOf("&#");
//			String temp_str = stringValue.substring(instr_location, instr_location + 2);
//			stringValue = replace(stringValue, temp_str, "＆＃");
        }

        return stringValue;
    }

    public static Map<String, Object> forTransactionQuery(Map<String, Object> param) throws UserInfoNotFoundException { //throws UserInfoNotFoundException {

        Map<String, Object> resultParam = new HashMap<String, Object>();

        Iterator<Entry<String, Object>> it = param.entrySet().iterator();

        String fieldID = "";
        Object fieldValue = "";
        String stringValue = "";

        while (it.hasNext()) {

            Entry<String, Object> entry = it.next();

            fieldID = toEmpty(entry.getKey());
            fieldValue = param.get(entry.getKey());

            stringValue = "";
            if (fieldValue instanceof String) {
                stringValue = toEmpty((String)fieldValue);
            }

            if (!isEmpty(stringValue)) {
                //ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ
                if (stringValue.toUpperCase().indexOf("--") != -1) {
                    stringValue = replace(stringValue, "--", "－－");
                }

                if (stringValue.toUpperCase().indexOf(";") != -1) {
                    stringValue = replace(stringValue, ";", "；");
                }

                if (stringValue.toUpperCase().indexOf("%") != -1) {
                    stringValue = replace(stringValue, "%", "％");
                }

                if (stringValue.toUpperCase().indexOf("JAVASCRIPT") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("JAVASCRIPT");
                    String temp_str = stringValue.substring(instr_location, instr_location + 10);
                    stringValue = replace(stringValue, temp_str, "ＪＡＶＡＳＣＲＩＰＴ");
                }
                if (stringValue.toUpperCase().indexOf("JSCRIPT") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("JSCRIPT");
                    String temp_str = stringValue.substring(instr_location, instr_location + 7);
                    stringValue = replace(stringValue, temp_str, "ＪＳＣＲＩＰＴ");
                }
                if (stringValue.toUpperCase().indexOf("VBSCRIPT") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("VBSCRIPT");
                    String temp_str = stringValue.substring(instr_location, instr_location + 8);
                    stringValue = replace(stringValue, temp_str, "ＶＢＳＣＲＩＰＴ");
                }
                if (stringValue.toUpperCase().indexOf("SCRIPT") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("SCRIPT");
                    String temp_str = stringValue.substring(instr_location, instr_location + 6);
                    stringValue = replace(stringValue, temp_str, "ＳＣＲＩＰＴ");
                }
                if (stringValue.toUpperCase().indexOf("IFRAME") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("IFRAME");
                    String temp_str = stringValue.substring(instr_location, instr_location + 6);
                    stringValue = replace(stringValue, temp_str, "ＩＦＲＡＭＥ");
                }
                if (stringValue.toUpperCase().indexOf("FRAME") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("FRAME");
                    String temp_str = stringValue.substring(instr_location, instr_location + 5);
                    stringValue = replace(stringValue, temp_str, "ＦＲＡＭＥ");
                }
                if (stringValue.toUpperCase().indexOf("EXPRESSION") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("EXPRESSION");
                    String temp_str = stringValue.substring(instr_location, instr_location + 10);
                    stringValue = replace(stringValue, temp_str, "ＥＸＰＲＥＳＳＩＯＮ");
                }
                if (stringValue.toUpperCase().indexOf("ALERT") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("ALERT");
                    String temp_str = stringValue.substring(instr_location, instr_location + 5);
                    stringValue = replace(stringValue, temp_str, "ＡＬＥＲＴ");
                }
                if (stringValue.toUpperCase().indexOf("OPEN") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("OPEN");
                    String temp_str = stringValue.substring(instr_location, instr_location + 4);
                    stringValue = replace(stringValue, temp_str, "ＯＰＥＮ");
                }
                if (stringValue.toUpperCase().indexOf("&#") != -1) {
                    int instr_location = stringValue.toUpperCase().indexOf("&#");
                    String temp_str = stringValue.substring(instr_location, instr_location + 2);
                    stringValue = replace(stringValue, temp_str, "＆＃");
                }

                resultParam.put(fieldID, stringValue);

            } else {

                resultParam.put(fieldID, fieldValue);

                if (UserInfoManager.getUserInfoImpl() != null) {
                    (resultParam).put("ses", UserInfoManager.getUserInfoImpl());
                }

            }

        }

        return resultParam;

    }

    public static String toEmpty(String str) {

        String rtnVal = "";
        byte[] byteRes = null;

        if (str == null) {
            rtnVal = "";
        } else {
            try {
                //rtnVal = URLDecoder.decode(str, "UTF-8");
                byteRes = str.getBytes("UTF-8");
                rtnVal = new String(byteRes, "UTF-8");
            } catch (UnsupportedEncodingException e) {
                logger.error(e.getMessage(), e);
            }
        }
        return rtnVal;
    }

    /**
     * 널 문자열이 들어오면 빈 문자열을 return
     * 아닐 경우는 입력 값을 return<br>
     * if input is  null then return empty String
     * else return input
     * @param str
     * @return String
     */
    public static String nullToEmptyString(String str) {
        if (isEmpty(str)) {
            return "";
        }
        return str;
    }


    public static String CheckInjection(String str) {
        return  replaceInjectionString(str);
    }

    public static String CheckInjectionRichTextEdit(String str) {
        return  replaceInjectionRichTextEdit(str);
    }


    public static String nullToEmptyString(Object obj) {
        if (isEmpty((String)obj)) {
            return "";
        }
        return (String)obj;
    }

    /**
     * 널 또는 빈 문자열의 경우 디폴트 스트링을 반환
     * @param target
     * @param defaultString
     * @return
     */
    public static String defaultIfEmpty(String target, String defaultString) {
        return StringUtils.defaultIfEmpty(target, defaultString);
    }

    public static String replace(String text, String searchString, String replacement) {
        return StringUtils.replace(text, searchString, replacement);
    }

    @Test
    public void testReplace() {
        String main_img = "D:/AttachFiles/BIZNTS_PROD/Public/MIG/uploadimg/202004_01/20200401/5121560.jpg";
        String imgFileNum = main_img.split("/")[main_img.split("/").length - 1];
        String thumbnail_Path = main_img.substring(0, main_img.indexOf(imgFileNum));
        System.out.println(thumbnail_Path);
        System.out.println(main_img.indexOf("Public"));
        System.out.println(main_img.indexOf(imgFileNum));
        System.out.println(main_img.substring(27 + 7, 67));
        System.out.println(imgFileNum);

    }

    public static String replaceAll(String text, String searchString, String replacement) {
        if (text == null) return "";
        String returnText = "";
        returnText = text;
        for (int i = 0; i < returnText.length(); i++) {
            if (String.valueOf(returnText.charAt(i)).equals(searchString)) {
                returnText = returnText.replace(searchString, replacement);
            }
        }

        return returnText;
    }

    /**
     * 2차원 문자열 배열에서 해당 문자열의 인덱스를 반환<br>
     * return searchString index in Dimension String array
     * from wiseframework getIndex
     * difference: 첫번째 인덱스를 넘기고 두번째 인덱스만 리턴 받음
     * @param strComplexArray
     * @param searchString
     * @return String
     */
    public static int[] getIndexFromDimensionStringArray(String[][] strComplexArray, String searchString) {
        for (int i = 0; i < strComplexArray.length; i++) {
            for (int j = 0; j < strComplexArray.length; j++) {
                if (strComplexArray[i][j].equals(searchString)) {
                    return new int[] {i, j};
                }
            }
        }
        return new int[] {-1, -1};
    }

    /**
     * convert \n to &lt;br/&gt;
     * @param str
     * @return String
     */
    public static String nToBr(String str) {
        return StringUtils.replace(str, "\n", "<br/>");
    }

    /**
     * convert &lt;br/&gt; to \n
     * @param str
     * @return String
     */
    public static String brToN(String str) {
        return StringUtils.replace(str, "<br/>", "\n");
    }

    /**
     * 문자열 내에 delimeter 로 구분된 항목 들을 sql in 절에 맞는 형태로 변형(for in query)<br>
     * convert string with delimeter as Sql IN Statement
     * @param str
     * @param delimeter
     * @return String
     */
    public static String forInQuery(String str, String delimeter) {
        if(StringUtils.isEmpty(str)) {
            return null;
        }
        String[] split = StringUtils.split(StringUtils.deleteWhitespace(str), delimeter);
        String join = StringUtils.join(split, "', '");
        return String.format("('%s')", join);
    }

    /**
     * Url encoding
     * @param str
     * @return String
     */
    public static String encodeUrl(String str) {
		/* @formatter:off */
        String[][] replaceMapArray = { {"%", "%25"}, {"#", "%23"}, {"&", "%26"}, {"'", "%27"}, {"+", "%2B"}, {":", "%3A"}, {";", "%3B"}, {"=", "%3D"}, {"\"", "%22"}, {" ", "+"}, {"\\n", "<br>"} };
		/* @formatter:on */

        StrBuilder strBuilder = new StrBuilder(str);
        for (String[] replaceMap : replaceMapArray) {
            strBuilder.replaceAll(replaceMap[0], replaceMap[1]);
        }
        return strBuilder.toString();
    }

    /**
     * Url decodeUrl
     * @param str
     * @return String
     */
    public static String decodeUrl(String str) {
		/* @formatter:off */
        String[][] replaceMapArray = { {" ", "+"} };
		/* @formatter:on */

        StrBuilder strBuilder = new StrBuilder(str);
        for (String[] replaceMap : replaceMapArray) {
            strBuilder.replaceAll(replaceMap[0], replaceMap[1]);
        }
        return strBuilder.toString();
    }

    /**
     * 문자열 덧셈<br>
     * Add number String
     * @param value1
     * @param value2
     * @return String
     */
    public static String add(String value1, String value2) {
        return new BigDecimal(value1).add(new BigDecimal(value2)).toString();
    }

    /**
     * 문자열 뺄셈<br>
     * subtract number String
     * @param value1
     * @param value2
     * @return String
     */
    public static String subtract(String value1, String value2) {
        return new BigDecimal(value1).subtract(new BigDecimal(value2)).toString();
    }

    /**
     * 문자열 곱셈<br>
     * multiply number String
     * @param value1
     * @param value2
     * @return String
     */
    public static String multiply(String value1, String value2) {
        return new BigDecimal(value1).multiply(new BigDecimal(value2)).toString();
    }

    /**
     * 문자열 나눗셈 rounding 모드와 자릿수 지정<br>
     * divide number String with rounding mode and digits
     * @param value1
     * @param value2
     * @param scale
     * @param roundMode
     * @return String
     */
    public static String divide(String value1, String value2, int scale, int roundMode) {
        return new BigDecimal(value1).divide(new BigDecimal(value2), scale, roundMode).toString();
    }

    /**
     * 문자열 나눗셈 반올림 할 자리수 지정<br>
     *  divide number String with rounding digits
     * @param value1
     * @param value2
     * @param scale
     * @return String
     */
    public static String divide(String value1, String value2, int scale) {
        return divide(value1, value2, scale, BigDecimal.ROUND_HALF_UP).toString();
    }

    /**
     * 문자열 나눗셈 소숫점 둘째 자리 까지<br>
     * divide number Up to two decimal places
     * @param value1
     * @param value2
     * @return String
     */
    public static String divide(String value1, String value2) {
        return divide(value1, value2, 2);
    }

    /**
     * 문자열 나머지(mod, %)<br>
     * mod number String
     * @param value1
     * @param value2
     * @return String
     */
    public static String remainder(String value1, String value2) {
        return new BigDecimal(value1).remainder(new BigDecimal(value2)).toString();
    }

    /**
     * 문자열을 srcEncodingType에서 targetEncodingType으로 변환<br>
     * convert String Encoding
     * @param str
     * @param srcEncodingType
     * @param targetEncodingType
     * @return String
     * @throws UnsupportedEncodingException
     */
    public static String convertEncoding(String str, String srcEncodingType, String targetEncodingType) throws UnsupportedEncodingException {
//        return StringUtils.toEncodedString(str.getBytes(srcEncodingType), Charset.forName(targetEncodingType));
    	return new String(str.getBytes(srcEncodingType), targetEncodingType);
    }

    /**
     * 8859_1문자열을 KSC5601로 변환
     * 변환에 실패하면 null을 반환<br>
     * convert String 8859_1 when fail convert to KSC5601
     * @param str
     * @return String
     */
    public static String e2k(String str) {
        try {
            return convertEncoding(str, "8859_1", "KSC5601");
        } catch (UnsupportedEncodingException e) {
            return null;
        }
    }

    /**
     * KSC5601문자열을 8859_1로 변환<br>
     * convert KSC5601 String to 8859_1
     * 변환에 실패하면 null을 반환
     * @param str
     * @return String
     */
    public static String k2e(String str) {
        try {
            return convertEncoding(str, "KSC5601", "8859_1");
        } catch (UnsupportedEncodingException e) {
            return null;
        }
    }

    public static ArrayList<String> chopSplitString(String data, int length) throws Exception {

        ArrayList<String> list = new ArrayList<String>();

        String ui = data;
        int dataLength = getLengthb(ui);

        while (dataLength > 0) {
            list.add(getSubString(ui, 0, length));
            ui = getSubString(ui, length, dataLength);
            dataLength = getLengthb(ui);
        }

        return list;
    }

    public static String getSubString(String str, int start, int end) {
        if (str == null) return "";
        int rSize = 0;
        int len = 0;

        StringBuffer sb = new StringBuffer();

        for (; rSize < str.length(); rSize++) {
            if (str.charAt(rSize) > 0x007F) {
                len += 2;
            } else {
                len++;
            }

            if ((len > start) && (len <= end)) {
                sb.append(str.charAt(rSize));
            }
        }

        return sb.toString();
    }

    public static int getLengthb(String str) {
        int rSize = 0;
        int len = 0;

        for (; rSize < str.length(); rSize++) {
            if (str.charAt(rSize) > 0x007F) {
                len += 2;
            } else {
                len++;
            }
        }

        return len;
    }

    public static String getDBLinkName(String tableName, String dbLinkName) throws Exception {
        String databaseId = SpringContextUtil.getUtilService().getDatabaseCode();
        if ("OR".equals(databaseId)) {
            return tableName + dbLinkName;
        } else if ("MS".equals(databaseId)) {
            return dbLinkName + tableName;
        } else {
            return tableName;
        }
    }

    /**
     * @Method Name : preventSqlInjection
     * @Author daguri
     * @Date 2014. 10. 31.
     * @Version 1.0
     * @Param :
     * @Return : String
     * @Description
     * @param value
     * @return
     */
    public static String preventSqlInjection(String value) {

        if(value == null) {
            return null;
        }

        Map<Character, String> guideMap = new HashMap<Character, String>();
        guideMap.put((char)60, "&lt;");
        guideMap.put((char)62, "&gt;");
        guideMap.put((char)34, "\"");
        guideMap.put((char)39, "''");
        for(Character ch : guideMap.keySet()) {
            value = value.replaceAll(ch.toString(), guideMap.get(ch));
        }

        return value;
    }

    /**
     * @Method Name : rePreventSqlInjection
     * @Author daguri
     * @Date 2014. 10. 31.
     * @Version 1.0
     * @Param :
     * @Return : String
     * @Description
     * @param value
     * @return
     */
    public static String rePreventSqlInjection(String value) {
        if(value == null) {
            return null;
        }

        Map<String, String> guideMap = new HashMap<String, String>();
        guideMap.put("&lt;", "<");
        guideMap.put("&gt;", ">");
        guideMap.put("&#39;", "'");

        for(String ch : guideMap.keySet()) {
            value = value.replaceAll(ch, guideMap.get(ch));
        }

        return value;
    }

	/**
	 * @Method Name : makeGridTextLinkStyle
	 * @Author daguri
	 * @Date 2014. 11. 3.
	 * @Version 1.0
	 * @Param :
	 * @Return : void
	 * @Description
	 * @param resp
	 * @param grid
	 * @param columnName
	 */
	public static void makeGridTextLinkStyle(EverHttpResponse resp, String grid, String columnName) {
		resp.setGridColStyle(grid, columnName, "cursor", "pointer");
		resp.setGridColStyle(grid, columnName, "color", "#000DFF");
		resp.setGridColStyle(grid, columnName, "text-decoration", "underline");
	}

	public static void makeGridTextBlueStyle(EverHttpResponse resp, String grid, String columnName) {
		resp.setGridColStyle(grid, columnName, "cursor", "pointer");
		resp.setGridColStyle(grid, columnName, "color", "#000DFF");
	}

	public static String replaceToXmlString(String str) {
		String xmlStr = str;

		xmlStr = replace(xmlStr, "&", "&amp;");
		xmlStr = replace(xmlStr, "<", "&lt;");
		xmlStr = replace(xmlStr, ">", "&gt;");
		xmlStr = replace(xmlStr, "'", "&apos;");
		xmlStr = replace(xmlStr, "\"", "&quot;");

		return xmlStr;
	}

	public static String replaceStringFromXml(String xmlStr) {
		String str = xmlStr;

		str = replace(str, "&amp;", "&");
		str = replace(str, "&lt;", "<");
		str = replace(str, "&gt;", ">");
		str = replace(str, "&apos;", "'");
		str = replace(str, "&quot;", "\"");

		return str;
	}

    public static Map<String, String> getDataMap(EverHttpRequest req) {

        Map<String, String> mRequest = new HashMap<String, String>();
        Enumeration e = req.getRequest().getParameterNames();

        while( e.hasMoreElements() ) {
            String paramName = e.nextElement().toString();
            String paramValue = req.getRequest().getParameter(paramName);
            if ( paramName == null || paramValue == null ) continue;
            paramName = paramName.toUpperCase().replace("AMP;", "");

            mRequest.put(paramName, paramValue);
        }

        return mRequest;
    }

    public static String changeCharacterSetDb2AppString(String sourceStr) {

//    	if(! PropertiesManager.getBoolean("eversrm.system.database.encoding.useFlag")) {
//    		return sourceStr;
//    	}

        if(StringUtils.isEmpty(sourceStr)) {
            return "";
        }
/*
    	String dbValue = PropertiesManager.getString("eversrm.system.database.encoding.db.value");
    	String appValue = PropertiesManager.getString("eversrm.system.database.encoding.app.value");

        try {
            sourceStr = new String(sourceStr.getBytes(dbValue), appValue);
        } catch (UnsupportedEncodingException e) {
            logger.error(e.getMessage(), e);
        }
*/
        return sourceStr;
    }

    public static String changeCharacterSetApp2DbString(String sourceStr) {
    	if(! PropertiesManager.getBoolean("eversrm.system.database.encoding.useFlag")) {
    		return sourceStr;
    	}
        if(StringUtils.isEmpty(sourceStr)) {
            return "";
        }

        String dbValue = PropertiesManager.getString("eversrm.system.database.encoding.db.value");
        String appValue = PropertiesManager.getString("eversrm.system.database.encoding.app.value");

        try {
            sourceStr = new String(nullToEmptyString(sourceStr).getBytes(appValue), dbValue);
        } catch (UnsupportedEncodingException e) {
            logger.error(e.getMessage(), e);
        }
        return sourceStr;
    }

    /**
     * 보안정책에 의한 마스킹 처리
     * @param str
     * @param type
     * @return
     * @throws Exception
     */
    public static String setEncryptedString(String str, String type) throws Exception {

        if(str == null) {
            return str;
        }

	    if(type != null) {
            if (type.equals("N")) { /** Name */
                StringBuilder s = new StringBuilder(str);
                try {
                    s.setCharAt(1, '*');
                } catch(StringIndexOutOfBoundsException se) {
                    return s.toString();
                }
                return s.toString();
            } else if (type.equals("A")) { /** All */
                str = StringUtils.replacePattern(str, ".", "*");
            } else if (type.equals("E")) { /** Etc. */

                StringBuilder s = new StringBuilder(str);
                try {
                    s.setCharAt(3, '*');
                } catch(StringIndexOutOfBoundsException se) {
                    return s.toString();
                }

                try {
                    s.setCharAt(4, '*');
                } catch(StringIndexOutOfBoundsException se) {
                    return s.toString();
                }

                return s.toString();
            }
        } else {
	        throw new Exception("No type specified!");
        }

        return str;
    }

    @Test
    public void doTestEncryptedString() throws Exception {

        String alphabet = "ABCD";
        System.err.println(setEncryptedString(alphabet, "A"));
        System.err.println(setEncryptedString(alphabet, "N"));
        System.err.println(setEncryptedString(alphabet, "E"));

    }

    public static String getRandomPassword(int cnt) {

        char pwCollection[] = new char[] {
                '1','2','3','4','5','6','7','8','9','0',
//                'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
//                '!','@','#','$','%','^','*','(',')','+'
        };//배열에 선언

        char pwCollectionD[] = new char[] {
                '1','2','3','4','5','6','7','8','9','0'
        };

        char pwCollectionS[] = new char[] {
                '!','@','#','$','%','^','*','(',')','+'
        };

        char pwCollectionU[] = new char[] {
                'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
        };//배열에 선언

        char pwCollectionL[] = new char[] {
                'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
        };//배열에 선언

        String ranPw = "";
        /* 아무거나 8자리 */
        for (int i = 0; i < cnt; i++) {
            int selectRandomPw = (int)(new SecureRandom().nextDouble()*(pwCollection.length));
            ranPw += pwCollection[selectRandomPw];
        }

        /* 숫자 1자리 */
        /*for (int i = 0; i < 1; i++) {
            int selectRandomPw = (int)(new SecureRandom().nextDouble()*(pwCollectionD.length));
            ranPw += pwCollectionD[selectRandomPw];
        }*/

        /* 아무거나 4자리 */
        /*for (int i = 0; i < 5; i++) {
            int selectRandomPw = (int)(new SecureRandom().nextDouble()*(pwCollection.length));
            ranPw += pwCollection[selectRandomPw];
        }*/

        /* 대문자 1자리 */
        /*for (int i = 0; i < 1; i++) {
            int selectRandomPw = (int)(new SecureRandom().nextDouble()*(pwCollectionS.length));
            ranPw += pwCollectionU[selectRandomPw];
        }*/

        /* 소문자 3자리 */
        /*for (int i = 0; i < 3; i++) {
            int selectRandomPw = (int)(new SecureRandom().nextDouble()*(pwCollectionS.length));
            ranPw += pwCollectionL[selectRandomPw];
        }*/

        /* 특수문자 1자리 */
        /*for (int i = 0; i < 1; i++) {
            int selectRandomPw = (int)(new SecureRandom().nextDouble()*(pwCollectionS.length));
            ranPw += pwCollectionS[selectRandomPw];
        }*/

        return ranPw;
    }

    // FIXME: Base64
//    public static String getImageEncode(byte[] byteImg) {
//        return Base64.encode(byteImg);
//    }

    public static String getUrl(EverHttpRequest req) {
        String port = ":".equals(":" + req.getServerPort()) ? "" : ":" + req.getServerPort();
        return req.getScheme() + "://"+req.getServerName() + port;
    }

    public static String getClientIpAddress(EverHttpRequest req) {

        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getRemoteAddr();
        }
        if (EverString.nullToEmptyString(ip).trim().length() <= 0) {
            ip = req.getRemoteAddr();
        }
        return EverString.nullToEmptyString(ip);
    }
}
