package com.st_ones.evermp.OD02.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.OD02.service.OD0204_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
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
 * @File Name : OD0204_Controller.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/OD02/OD0204")
public class OD0204_Controller extends BaseController {

	@Autowired private OD0204_Service OD0204_Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 운영사 : 납품서생성 대행
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/OD02_040/view")
	public String OD02_040(EverHttpRequest req) throws Exception {
		 UserInfo userInfo = UserInfoManager.getUserInfo();
	        if(!"C".equals(userInfo.getUserType())) {
	        	return "/eversrm/noSuperAuth";
	        }

		Map<String, String> param = req.getFormData();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자


        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));

        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());

		return "/evermp/OD02/OD02_040";
	}

	@RequestMapping(value = "/OD02_040/doSearch")
	public void OD02040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", OD0204_Service.OD02040_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/OD02_040/doCreateInvoice")
	public void OD02040_doCreateInvoice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		List<Map<String, Object>> reqInList = new ArrayList<>();

		 OD0204_Service.OD02040_doCreateInvoice(gridList, reqInList);


        resp.setResponseMessage(msg.getMessage("0031"));
	}
	 // 확정취소
    @RequestMapping(value = "/OD02_040/doCancel")
    public void OD0204_doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = OD0204_Service.OD0204_doCancel(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }
    // 출하종결
    @RequestMapping(value = "/OD02_040/doPoCancel")
    public void OD0204_doPoCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> formData = new HashMap<String, String>();
    	formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
    	String msg = OD0204_Service.OD0204_doPoCancel(formData,req.getGridData("grid"));
    	resp.setResponseMessage(msg);
    }



}
