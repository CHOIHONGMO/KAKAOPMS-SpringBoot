package com.st_ones.common.sample.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sample.SampleMapper;
import com.st_ones.everf.serverside.service.BaseService;
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
 * @File Name : SampleService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "sampleService")
public class SampleService extends BaseService {

	@Autowired
	private DocNumService docNumService;

	@Autowired
	private MessageService msg;

	@Autowired
	SampleMapper sampleMapper;

	public List<Map<String, Object>> doSearchPage1(Map<String, String> params) throws Exception {
		return sampleMapper.doSearchPage1(params);
	}

	public List<Map<String, Object>> doSearchPage6(Map<String, String> params) throws Exception {
		return sampleMapper.doSearchPage6(params);
	}

	public void doConnect(Map<String, String> params) throws Exception {
		String domain = String.valueOf(params.get("DOMAIN"));
		String userId = String.valueOf(params.get("USER_ID"));
		String password = String.valueOf(params.get("PASSWORD"));

		getLog().error("DOMAIN ---> " + domain);
		getLog().error("userId ---> " + userId);
		getLog().error("password ---> " + password);
	}
}