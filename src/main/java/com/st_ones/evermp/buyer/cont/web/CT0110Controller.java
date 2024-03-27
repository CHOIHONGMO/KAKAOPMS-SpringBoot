package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0100Service;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0110Controller  extends BaseController {

	@Autowired CommonComboService commonComboService;
	@Autowired LargeTextService largeTextService;
	@Autowired CT0100Service ct0100service;
    @Autowired MessageService messageService;
    @Autowired EverMailService evermailservice;

	@RequestMapping(value = "/CT0110/view")
	public String formManagement(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		req.setAttribute("fromDate", EverDate.addMonths(-12));
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("formTypes", commonComboService.getCodeComboAsJson("M078"));
		req.setAttribute("formGubun", commonComboService.getCodeComboAsJson("M176"));
		return "/evermp/buyer/cont/CT0110";
	}

	@RequestMapping(value = "/CT0110/doSearch")
	public void formManagementDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		resp.setGridObject("grid", ct0100service.formManagementDoSearch(req.getFormData()));
	}

	@RequestMapping(value = "/CT0110/doCopy")
	public void formManagementDoCopy(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String message = ct0100service.formManagementDoCopy(req.getGridData("grid"));
		resp.setResponseMessage(message);
	}

	@RequestMapping(value = "/CT0110/doDelete")
	public void formManagementDoDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");

        String message = ct0100service.formManagementDoDelete(gridData);
		resp.setResponseMessage(message);
	}

	@RequestMapping(value = "/CT0110/doReplace")
	public void doReplace(EverHttpRequest req, EverHttpResponse resp) {
		ct0100service.doReplace();
	}

    /**
     * 계약서 작성
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/CT0110P01/view")
	public String formSelection(EverHttpRequest req) throws Exception {

		ct0100service.setFormSelectionInitData(req);
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/buyer/cont/CT0110P01";
	}

	@RequestMapping(value = "/CT0110P01/doSearchMainForm")
	public void doSearchMainForm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		String bundleFlag = req.getParameter("bundleFlag");
		String resumeFlag = req.getParameter("resumeFlag");
		param.put("bundleFlag", String.valueOf(StringUtils.equals(bundleFlag, "1")));   // 일괄여부가 Y인 것만 조회할지
		param.put("resumeFlag", String.valueOf(StringUtils.equals(resumeFlag, "true")));// 변경계약일 경우
		resp.setGridObject("gridM", ct0100service.doSearchMainForm(param));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/CT0110P01/doSearchAdditionalForm")
	public void doSearchAdditionalForm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		String selectedFormNum = req.getParameter("selectedFormNum");
		param.put("FORM_NUM", selectedFormNum);
		resp.setGridObject("gridA", ct0100service.doSearchAdditionalForm(param));
	}

	@RequestMapping(value = "/CT0110P01/doSearchSupAttachFileInfo")
	public void doSearchSupAttachFileInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
		param.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));
		param.put("CONTRACT_FORM_TYPE", EverString.nullToEmptyString(req.getParameter("contractFormType")));
		resp.setGridObject("gridS", ct0100service.doSearchSupAttachFileInfo(param));
	}

	@RequestMapping(value = "/CT0110P01/doSearchPayInfo")
	public void doSearchPayInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
		param.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));
		param.put("VENDOR_CD", EverString.nullToEmptyString(req.getParameter("vendorCd")));
		resp.setGridObject("gridP", ct0100service.doSearchPayInfo(param));
	}

	@RequestMapping(value = "/CT0110P01/doSearchPayInfoForERP")
	public void doSearchPayInfoForERP(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("PURC_CONT_NUM", EverString.nullToEmptyString(req.getParameter("purcContNum")));

		resp.setGridObject("gridP", ct0100service.doSearchPayInfoForERP(param));
	}

	/**
	 * 계약서 주서식 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/CT0110P01/getContractForm")
	public void becf030_getContractForm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("contNum", req.getParameter("contNum"));
		param.put("contCnt", req.getParameter("contCnt"));
		param.put("selectedFormNum", req.getParameter("selectedFormNum"));
		param.put("formContents", req.getParameter("formContents"));
		param.put("type", "M"); // Main Form
		param.put("first_view", req.getParameter("first_view"));

		String resultContractForm = ct0100service.getFormWithManualContractInfo(req, resp, param);
		resp.setParameter("contractForm", resultContractForm);

		resp.setResponseCode("true");
	}

	/**
	 * 부서식 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/CT0110P01/getSubContractForm")
	public void becf030_getSubContractForm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("contNum", req.getParameter("contNum"));
		param.put("contCnt", req.getParameter("contCnt"));
		param.put("FORM_NUM", req.getParameter("selectedFormNum"));
		param.put("type", "S"); // Sub Form
		param.put("first_view", req.getParameter("first_view"));

		String resultContractForm = ct0100service.getFormWithManualContractInfo(req, resp, param);
		resp.setParameter("contractForm", resultContractForm);
	}

	@RequestMapping(value = "/ECOA0012/view")
	public String becf_view(EverHttpRequest req) {
		req.setAttribute("ckEditorHtml", req.getParameter("ckEditorHtml"));
		return "/evermp/buyer/cont/ECOA0012";
	}



}
