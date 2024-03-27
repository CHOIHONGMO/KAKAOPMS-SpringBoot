package com.st_ones.eversrm.master.vendor.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.master.vendor.service.BBV_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : BBV_Controller.java 
 * @author  이연무
 * @date 2018. 02. 05.
 * @version 1.0  
 * @see 
 */

@Controller
@RequestMapping(value = "/eversrm/master/vendor")
public class BBV_Controller extends BaseController {

	@Autowired private BBV_Service bbv_Service;

	@Autowired private CommonComboService commonComboService;

	/** ******************************************************************************************
     * 구매사 조회
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BBV_090/view")
	public String my01001_view(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		return "/eversrm/master/vendor/BBV_090";
	}

	@RequestMapping(value = "/doSearchCandidate")
	public void doSearchCandidate(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.putAll(formData);
        String selectedBuyerJson = req.getParameter("selectedBuyers");
		if (selectedBuyerJson != null) {
            paramMap.put("selectedBuyers", new ObjectMapper().readValue(selectedBuyerJson, List.class));
            resp.setGridObject("gridR", bbv_Service.doSearchCandidate(paramMap));
		} else {
            resp.setGridObject("gridL", bbv_Service.doSearchCandidate(paramMap));
        }
	}

	@RequestMapping(value = "/bbv090_doSearchR")
	public void bbv090_doSearchR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		//resp.setGridObject("gridR", bbv_Service.bbv090_doSearchR(req.getFormData()));
	}

	@RequestMapping(value = "/IM03009_doSearchCandidate")
	public void IM03009_doSearchCandidate(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.putAll(formData);
		String selectedBuyerJson = req.getParameter("selectedBuyers");
		if (selectedBuyerJson != null) {
			paramMap.put("selectedBuyers", new ObjectMapper().readValue(selectedBuyerJson, List.class));
			resp.setGridObject("gridR", bbv_Service.IM03009_doSearchCandidate(paramMap));
		} else {
			resp.setGridObject("gridL", bbv_Service.IM03009_doSearchCandidate(paramMap));
		}
	}

	@RequestMapping(value = "/IM03009_doSetGridR")
	public void IM03009_doSetGridR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridR", bbv_Service.IM03009_doSetGridR(req.getFormData()));
	}

}
