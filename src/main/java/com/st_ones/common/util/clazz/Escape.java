package com.st_ones.common.util.clazz;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : Escape.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 09. 04.
 * @version 1.0  
 * @see 
 */

public class Escape {

	public static String setEscape(String src) {   
    	int i;   
    	char j;   
    	StringBuffer tmp = new StringBuffer();   
    	tmp.ensureCapacity(src.length() * 6);   
    	
    	for (i = 0; i < src.length(); i++) {   
    		j = src.charAt(i);   
    		if (Character.isDigit(j) || Character.isLowerCase(j) || Character.isUpperCase(j))   
    			tmp.append(j);   
    		else if (j < 256) {   
    			tmp.append("%");   
    			if (j < 16)   
    				tmp.append("0");   
    			tmp.append(Integer.toString(j, 16));   
    		} else {   
    			tmp.append("%u");   
    			tmp.append(Integer.toString(j, 16));   
    		}   
    	}   
    	return tmp.toString();   
    }   

    public static String setUnescape(String src) {   
    	StringBuffer tmp = new StringBuffer();   
    	tmp.ensureCapacity(src.length());   
    	
    	int lastPos = 0, pos = 0;   
    	char ch;   
    	
    	while (lastPos < src.length()) {   
    		pos = src.indexOf("%", lastPos);   
    	
    		if (pos == lastPos) {   
    			if (src.charAt(pos + 1) == 'u') {   
    				ch = (char) Integer.parseInt(src.substring(pos + 2, pos + 6), 16);   
    				tmp.append(ch);   
    				lastPos = pos + 6;   
    			} else {   
    				ch = (char) Integer.parseInt(src.substring(pos + 1, pos + 3), 16);   
    				tmp.append(ch);   
    				lastPos = pos + 3;   
    			}   
    		} else {   
    			if (pos == -1) {   
    				tmp.append(src.substring(lastPos));   
    				lastPos = src.length();   
    			} else {   
    				tmp.append(src.substring(lastPos, pos));   
    				lastPos = pos;   
    			}   
    		}   
    	}   
    	return tmp.toString();   
    }

}
