package com.st_ones.evermp.BS99.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS99.service.BS9901_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 17 오후 5:27
 */

@Controller
@RequestMapping(value = "/evermp/BS99/BS9901")
public class BS9901_Controller extends BaseController {

	@Autowired
    CommonComboService commonComboService;

    @Autowired
	BS9901_Service bs9901_Service;

    /** *****************
     * 템플릿관리
     * ******************/
    @RequestMapping(value = "/BS99_010/view")
    public String BS99_010_View(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS99/BS99_010";
    }

    @RequestMapping(value = "/bs99010_doSearch")
    public void bs99010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs9901_Service.bs99010_doSearch(req.getFormData()));
    }

    @RequestMapping(value="/bs99010_doSave")
    public void bs99010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs9901_Service.bs99010_doSave(gridList);
        resp.setResponseMessage(returnMsg);
    }

    @RequestMapping(value="/bs99010_getTmplAttFileNum")
	public void getTmplAttFileNum(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String attFileNum = "";
		String tmplNum = req.getParameter("tmplNum");

		List<Map<String, String>> codeCombo = commonComboService.getCodeCombo("CB0063");
		for (Map<String, String> code : codeCombo) {
			if(code.get("value").equals(tmplNum)) {
				attFileNum = code.get("ATT_FILE_NUM");
				break;
			}
		}
		resp.setParameter("attFileNum", attFileNum);
	}

    /** *****************
     * 기준정보 > 고객의소리 > 고객의소리 진행현황
     * ******************/
    @RequestMapping(value = "/BS99_020/view")
    public String BS99_020_View(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"B".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = req.getParamDataMap();

        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("END_DATE", EverDate.getDate());
        req.setAttribute("CTRL_CD", userInfo.getCtrlCd());
        req.setAttribute("form", param);

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","BASIC");    // 기본(공통)
        req.setAttribute("DS_USER_ID_Options", commonComboService.getCodesAsJson("CB0094", param));

        if("Y".equals(param.get("MOVE_LINK_YN"))) {
            req.setAttribute("vocTypeOptions2", commonComboService.getCodesAsJson("CB0097", param));
        }
        return "/evermp/BS99/BS99_020";
    }

    @RequestMapping(value = "/bs99020_doSearch")
    public void bs99020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs9901_Service.bs99020_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/bs99020_doReceipt")
    public void bs99020_doReceipt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs9901_Service.bs99020_doReceipt(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 기준정보 > 고객의소리 > 고객의소리 진행현황 > 고객의소리 등록/수정 팝업
     * ******************/
    @RequestMapping(value = "/BS99_021/view")
    public String BS99_021_View(EverHttpRequest req) throws Exception {
        Map<String, String> inParam = req.getParamDataMap();
        List<Map<String, Object>> list;

        UserInfo userInfo = UserInfoManager.getUserInfo();

        String VC_NO = inParam.get("VC_NO");
        String REQ_COM_TEXT = "";
        String REQ_INFO_TEXT = "";
        String REQ_DATE = "";
        String REQ_INFO_DEPT_TEXT = "";
        String USER_TYPE = userInfo.getUserType();
        String REQ_COM_CD = "";
        String REQ_COM_TYPE = "";
        String USER_ID = userInfo.getUserId();
        String USER_EQ = "";
        String USER_DS_EQ = "";

        if(!"".equals(VC_NO) && null != VC_NO) {
            list = bs9901_Service.bs99021_doSearch(inParam);
            Map<String, Object> data = list.get(0);

            REQ_COM_TEXT = data.get("REQ_COM_CD") + " / " + data.get("REQ_COM_NM");
            REQ_INFO_TEXT = data.get("REQ_USER_NM") + " / " + data.get("REQ_DATE");
            REQ_INFO_DEPT_TEXT = String.valueOf(data.get("DEPT_NM"));

            if(USER_ID.equals(data.get("REQ_USER_ID"))) {
                USER_EQ = "Y";
            } else {
                USER_EQ = "N";
            }

            if(USER_ID.equals(data.get("DS_USER_ID"))) {
                USER_DS_EQ = "Y";
            } else {
                USER_DS_EQ = "N";
            }

            req.setAttribute("DATA", data);
        }

        req.setAttribute("VC_NO", VC_NO);
        req.setAttribute("REQ_COM_TEXT", REQ_COM_TEXT);
        req.setAttribute("REQ_INFO_TEXT", REQ_INFO_TEXT);
        req.setAttribute("REQ_INFO_DEPT_TEXT", REQ_INFO_DEPT_TEXT);
        req.setAttribute("REQ_DATE", REQ_DATE);

        req.setAttribute("USER_EQ", USER_EQ);
        req.setAttribute("USER_DS_EQ", USER_DS_EQ);

        req.setAttribute("USER_TYPE", USER_TYPE);
        req.setAttribute("REQ_COM_CD", REQ_COM_CD);
        req.setAttribute("REQ_COM_TYPE", REQ_COM_TYPE);
        req.setAttribute("CTRL_CD", userInfo.getCtrlCd());

        req.setAttribute("callbackFunction", inParam.get("callbackFunction"));

        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","BASIC");

        req.setAttribute("DS_USER_ID_Options", commonComboService.getCodesAsJson("CB0094", param));

        return "/evermp/BS99/BS99_021";
    }

    @RequestMapping(value = "/bs99021_doReceipt")
    public void bs99021_doReceipt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> inParam = req.getFormData();

        String rtnMsg = bs9901_Service.bs99021_doReceipt(inParam);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs99021_doInAction")
    public void bs99021_doInAction(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> inParam = req.getFormData();

        String rtnMsg = bs9901_Service.bs99021_doInAction(inParam);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs99021_doActionComplete")
    public void bs99021_doActionComplete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> inParam = req.getFormData();

        String rtnMsg = bs9901_Service.bs99021_doActionComplete(inParam);

        resp.setResponseMessage(rtnMsg);
    }
}
