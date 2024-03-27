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
 * @File Name : BSYT_Service.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public enum BaseDataType {
	
	MANUAL_CONTRACT("manualContract"), CONSULTATION("consultation"), CONTRACT("contract"), APPROVAL("app");
	
	private String baseDataType;
	BaseDataType(String type) {
		this.baseDataType = type;
	}

	public static BaseDataType fromString(String type) throws Exception {
		if (type != null) {
			for (BaseDataType t : BaseDataType.values()) {
				if (type.equalsIgnoreCase(t.baseDataType)) {
					return t;
				}
			}
		}
		throw new EnumerationNotFoundException(type);
	}
}
