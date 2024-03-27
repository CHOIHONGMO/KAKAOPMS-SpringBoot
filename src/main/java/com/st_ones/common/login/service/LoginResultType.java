package com.st_ones.common.login.service;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : LoginResultType.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public enum LoginResultType {
	SUCCESS {

	},
	FAIL_NOT_EXIST_ID {

	},
	FAIL_NOT_EXIST_USER_TYPE {
		
	},
	FAIL_WRONG_PASSWORD {

	},
	WRONG_PASSWORD_EXCEEDED_CNT {

	},
	FAIL_LOGIN_DATE_PASS{

	},
	FAIL_USER_BLOCK {

	}
}