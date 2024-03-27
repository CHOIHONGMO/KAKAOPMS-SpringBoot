package com.st_ones.eversrm.master.vendor.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.master.vendor.BBV_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
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
 * @File Name : BBV_Service.java
 * @author  이연무
 * @date 2018. 02. 05.
 * @version 1.0
 * @see
 */

@Service(value = "bbv_Service")
public class BBV_Service extends BaseService {

	@Autowired BBV_Mapper bbv_Mapper;

	@Autowired MessageService msg;

	/** ******************************************************************************************
     * 구매사 조회
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> doSearchCandidate(Map<String, Object> param) throws Exception {

		Map<String,Object> param2 = new HashMap<String, Object>();
		param2.putAll(param);

		return bbv_Mapper.doSearchCandidate(param2);
	}

	public List<Map<String, Object>> IM03009_doSearchCandidate(Map<String, Object> param) throws Exception {

		Map<String,Object> param2 = new HashMap<String, Object>();
		param2.putAll(param);

		return bbv_Mapper.IM03009_doSearchCandidate(param2);
	}

	public List<Map<String, Object>> IM03009_doSetGridR(Map<String, String> param) throws Exception {

		if(!EverString.nullToEmptyString(param.get("CUST_CD_LIST")).equals("")){
			param.put("CUST_CD_LIST", EverString.forInQuery(param.get("CUST_CD_LIST"), ","));
		}
		return bbv_Mapper.IM03009_doSetGridR(param);
	}

}
