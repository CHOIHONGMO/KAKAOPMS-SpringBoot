package com.st_ones.common.multiLanguage.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.multiLanguage.service.MultiLanguageService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : MultiLanguageController.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 08. 23.
 * @version 1.0  
 * @see 
 */

@Controller
@RequestMapping(value = "/common/multiLanguage")
public class MultiLanguageController extends BaseController {

	@Autowired
	private MultiLanguageService multiLanguageService;

	@Autowired
	private CommonComboService commonComboService;

	@RequestMapping(value = "/BSYL_030/view")
	public String multiLanguagePopupView(EverHttpRequest req) throws Exception {
		Map<String, String> parameters = reqParamMapToStringMap(req.getParameterMap());
		String multi_nm = getMultiName(parameters.get("multi_cd"));
		parameters.put("multi_nm", multi_nm);
		req.setAttribute("searchParam", parameters);
		return "/common/multilanguage/BSYL_030";
	}

	/**
	 * @param langCode
	 * @param multi_code
	 * @return
	 * 화면명: SC
	 *		템플릿그룹: TG
	 *		권한: AU
	 *		화면액션: SA
	 *		메뉴그룹: MG
	 *		메뉴템플릿: MT
	 *		액션프로파일: AP:
	 * @throws Exception
	 */
	private String getMultiName(String multi_cd) throws Exception {
		List<Map<String, String>>  multiNameList = commonComboService.getCodeCombo("M048");
		String multi_name_value = null;
		for (Map<String, String> map : multiNameList) {
			if (map.get("value").equals(multi_cd)) {
				multi_name_value = map.get("text");
			}
		}
		return multi_name_value;
	}

	@RequestMapping(value = "/multiLanguagePopup/doSearch")
	public void multiLanguagePopupDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());
		List<Map<String, Object>> gridData = multiLanguageService.getMultiLanguageList(param);
		resp.setGridObject("grid", gridData);
		resp.setResponseMessage("success");
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/multiLanguagePopup/doSave")
	public void multiLanguagePopupDoSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> searchParm = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = multiLanguageService.multiLanguagePopupDoSave(searchParm, gridData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/multiLanguagePopup/doDelete")
	public void multiLanguagePopupDoDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridDataParam = req.getGridData("grid");
		String msg = multiLanguageService.doDeletePopup(gridDataParam);
		resp.setResponseMessage(msg);
		resp.setResponseCode("0001");
	}

}