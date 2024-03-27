package com.st_ones.common.combo.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
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
 * @File Name : CommonComboController.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Controller
@RequestMapping(value = "/common/combo")
public class CommonComboController extends BaseController {

	@Autowired
	private CommonComboService comboService;
	
	@RequestMapping(value = "/sampleMultiCombo/view")
	public String sampleMultiCombo(EverHttpRequest everReq) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("type", "1");
		return "/common/combo/sampleMultiCombo";
	}
	
	@RequestMapping(value = "/getMultiComboValue")
	public void getMultiComboValue(EverHttpRequest everReq, EverHttpResponse everResp) throws Exception {
		everResp.setResponseCode("true");
	}

    @RequestMapping(value = "/getComboOption")
    public void getComboOption(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());

        resp.setParameter("comboOption", comboService.getCodesAsJson(param.get("codeType"), param));
    }

	/**
	 * 사업구분 별 제조사 콤보 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/getMakerOptions")
	public void getMakerOptions(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());
		param.putAll(req.getFormData());
		resp.setParameter("makerOptions", comboService.getCodeComboAsJson2("CB9999", param));
	}
}