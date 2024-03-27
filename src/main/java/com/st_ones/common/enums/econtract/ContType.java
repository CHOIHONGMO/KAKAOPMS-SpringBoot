package com.st_ones.common.enums.econtract;

import com.st_ones.everf.serverside.exception.EnumerationNotFoundException;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : ContType.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public enum ContType {
	
	CONTRACT("contract"), EX_CONTRACT("exContract"), SO_CONTRACT("soContract"), APPROVAL("app"), STOP("contractStop"), RESUME("contractResume"), CONSULTATION("consultation");
	
	private String contType;
	ContType(String type) {
		this.contType = type;
	}

	public static ContType fromString(String type) throws Exception {
		if (type != null) {
			for (ContType t : ContType.values()) {
				if (type.equalsIgnoreCase(t.contType)) {
					return t;
				}
			}
		}
		throw new EnumerationNotFoundException(type);
	}
}
