package com.st_ones.evermp.BMY1.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BMY1.BMY1_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BMY1_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "bmy1_Service")
public class BMY1_Service extends BaseService {

	@Autowired BMY1_Mapper bmy1_Mapper;

	@Autowired MessageService msg;

	/** ******************************************************************************************
     * 고객사, 협력사 공지사항 현황조회
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> bmy1050_doSearch(Map<String, String> param) throws Exception {
		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		param.put("USER_TYPE", userInfo.getUserType());
		
		return bmy1_Mapper.bmy1050_doSearch(param);
	}
	/** ******************************************************************************************
	 * 고객사, Mysite관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> bmy1040_doSearch(Map<String, String> param) throws Exception {

		return bmy1_Mapper.bmy1040_doSearch(param);
	}
}
