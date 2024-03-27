package com.st_ones.eversrm.eApproval.eApprovalBox.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.ApprovalException;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.eApproval.eApprovalBox.service.BAPP_Service;
import org.apache.commons.lang.StringUtils;
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
 * @File Name : BAPP_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/eApproval/eApprovalBox")
public class BAPP_Controller extends BaseController {

	@Autowired LargeTextService largeTextService;

	@Autowired private BAPP_Service bapp_Service;

	@Autowired private CommonComboService commonComboService;

	/** ******************************************************************************************
     * 수신함
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/BAPP_010/view")
	public String mailBox(EverHttpRequest req) throws Exception {

		ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("refStatus", om1.writeValueAsString(commonComboService.getCodeCombo("M020")));
        ObjectMapper om2 = new ObjectMapper();
		req.setAttribute("refSignReqStatus", om2.writeValueAsString(commonComboService.getCodeCombo("M040")));
        ObjectMapper om3 = new ObjectMapper();
		req.setAttribute("refDocType", om3.writeValueAsString(commonComboService.getCodeCombo("M038")));

		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/eversrm/eApproval/eApprovalBox/BAPP_010";
	}

	@RequestMapping(value = "/BAPP_010/searchMailBox")
	public void searchMailBox(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("regDateFrom", EverDate.getGmtFromDate(param.get("regDateFrom"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("regDateTo", EverDate.getGmtToDate(param.get("regDateTo"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		makeGridTextLinkStyle(resp, "grid", "APP_DOC_NUM");
		makeGridTextLinkStyle(resp, "grid", "VIEW_CNT");
		resp.setGridObject("grid", bapp_Service.searchMailBox(param));
    	resp.setResponseCode("true");
	}

	/** ******************************************************************************************
     * 발신함
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/BAPP_040/view")
	public String sendBox(EverHttpRequest req) throws Exception {

		ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("approvalStatus", om1.writeValueAsString(commonComboService.getCodeCombo("M020")));
        ObjectMapper om2 = new ObjectMapper();
		req.setAttribute("rfaStatus", om2.writeValueAsString(commonComboService.getCodeCombo("M040")));
        ObjectMapper om3 = new ObjectMapper();
		req.setAttribute("docType", om3.writeValueAsString(commonComboService.getCodeCombo("M038")));

		req.setAttribute("fromDate", EverDate.addMonths(-2));
		req.setAttribute("toDate", EverDate.getDate());

		return "/eversrm/eApproval/eApprovalBox/BAPP_040";
	}

	@RequestMapping(value = "/BAPP_040/getSendBoxList")
	public void getSendBoxList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("START_DATE", EverDate.getGmtFromDate(param.get("START_DATE"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("END_DATE", EverDate.getGmtToDate(param.get("END_DATE"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		makeGridTextLinkStyle(resp, "grid", "APP_DOC_NUM");
		makeGridTextLinkStyle(resp, "grid", "CNT");
    	resp.setGridObject("grid", bapp_Service.getSendBoxList(param));
    	resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BAPP_040/doCancelRFA")
	public void doCancelRFA(EverHttpRequest req, EverHttpResponse resp) throws Exception{

		String msg = null;
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		try {
			msg = bapp_Service.doCancelRFA(gridDatas.get(0));
			resp.setResponseMessage(msg);
		} catch (ApprovalException e) {
			resp.setResponseMessage(e.getMessage());
		}
		resp.setResponseCode("true");
	}

	/** ******************************************************************************************
     * 결재요청 Popup
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/BAPP_050/view")
	public String approvalRequestPopupView(EverHttpRequest req) throws Exception {
        ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("ref_IMPORTANCE_STATUS", om1.writeValueAsString(commonComboService.getCodeCombo("M053")));

		return "/eversrm/eApproval/eApprovalBox/BAPP_050";
	}

	@RequestMapping(value = "/BAPP_050/doSelectPreviousInfo")
	public void approvalRequestPopupDoSelect(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String gateCd = req.getParameter("gateCd");
		String docNum = req.getParameter("docNum");
		String docCnt = req.getParameter("docCnt");

		Map<String, String> approvalInfoKey = new HashMap<String, String>();
		approvalInfoKey.put("GATE_CD", gateCd);
		approvalInfoKey.put("APP_DOC_NUM", docNum);
		approvalInfoKey.put("APP_DOC_CNT", docCnt);

		Map<String, String> formData = bapp_Service.selectPreviousInfoForm(approvalInfoKey);
		if (formData == null) {
			resp.setResponseCode("true");
			return;
		}

		String contentsTextNum = formData.get("CONTENTS_TEXT_NUM");
		String docContents = largeTextService.selectLargeText(contentsTextNum);
		formData.put("DOC_CONTENTS", docContents);

		resp.setFormDataObject(formData);
		resp.setGridObject("grid", bapp_Service.selectPreviousInfoGrid(approvalInfoKey));

		resp.setResponseMessage("Success");
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BAPP_050/doSelectMyPath")
	public void approvalRequestPopupDoSelectMyPath(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String strApprovalPathKey = req.getParameter("strApprovalPathKey");

		@SuppressWarnings("unchecked")
		HashMap<String, String> approvalPathKey = new ObjectMapper().readValue(strApprovalPathKey, HashMap.class);
		approvalPathKey.put("gateCd", approvalPathKey.get("GATE_CD"));
		approvalPathKey.put("pathNum", approvalPathKey.get("PATH_NUM"));

		resp.setGridObject("grid", bapp_Service.selectLULP(approvalPathKey));

		resp.setResponseMessage("Success");
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BAPP_050/doCheckUserName")
	public void approvalRequestPopupDoCheckUserName(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String userName = req.getParameter("userName");

		String userInfoString;
		try {
			userInfoString = bapp_Service.getMatchUserInfoByName(userName);
		} catch (ApprovalException e) {
			resp.setParameter("count", String.valueOf(e.getSelectedUserCount()));

			resp.setResponseMessage(e.getMessage());
			resp.setResponseCode("true");
			return;
		}

		resp.setParameter("userInfo", userInfoString);
		resp.setResponseMessage("oneUserSelected");
		resp.setResponseCode("true");
	}

	/** ******************************************************************************************
     * 결재요청 Popup
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/BAPP_550/view")
	public String BAPP_550(EverHttpRequest req) {

		boolean isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
		boolean islocalMode = PropertiesManager.getBoolean("eversrm.system.localserver");
		boolean devMode = ((isDevelopmentMode || islocalMode) ? true : false);

		req.setAttribute("isDevelopmentMode", devMode);
		return "/eversrm/eApproval/eApprovalBox/BAPP_550";
	}

	@RequestMapping(value = "/userSearch")
	public void selectHouse(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridR", bapp_Service.userSearch(req.getFormData()));
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/doSearchDecideArbitrarily")
	public void doSearchDecideArbitrarily(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String,Object> param = new HashMap<String, Object>();
		param.put("BIZ_CLS1", EverString.nullToEmptyString(req.getParameter("bizCls1")));
		param.put("BIZ_CLS2", EverString.nullToEmptyString(req.getParameter("bizCls2")));
		param.put("BIZ_CLS3", EverString.nullToEmptyString(req.getParameter("bizCls3")));
		param.put("BIZ_AMT", EverString.nullToEmptyString(req.getParameter("bizAmt")));
		param.put("BIZ_RATE", EverString.nullToEmptyString(req.getParameter("bizRate")));
		param.put("REQ_USER_ID", EverString.nullToEmptyString(req.getParameter("reqUserId")));
		param.put("PR_SUBJECT", EverString.nullToEmptyString(req.getParameter("prSubject")));

		List<Map<String, Object>> rtnList = bapp_Service.doSearchDecideArbitrarily(param);
		resp.setParameter("appFlag", (rtnList.size() > 0 ? "Y" : "N"));
		resp.setGridObject("gridL", rtnList);
	}

	@RequestMapping(value = "/doSearchSync")
	public void doSearchSync(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String,Object> mmm = new HashMap<String,Object>();
		mmm.put("USER_IDS", req.getParameter("USER_IDS"));

		resp.setGridObject("gridL", bapp_Service.doSearchSync(  mmm   ));
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/getRealignmentApprovalList")
	public void approvalHelper(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String sortType = req.getParameter("sortType");

        List<Map<String, Object>> gridL = req.getGridData("gridL");

        if(sortType.equals("up")) {

        	int maxSize = gridL.size();

        	for(int i = maxSize-1; i >= 0; i--) {

        		Map<String, Object> currData = gridL.get(i);
                String checkFlag = (String)currData.get("CHECK_FLAG");

                if(StringUtils.equals(checkFlag, "1")) {

                	if(i != 0) {

                    	Map<String, Object> prevData = gridL.get(i-1);
                        String signReqType = StringUtils.defaultIfEmpty((String)prevData.get("SIGN_REQ_TYPE"), "");
                        String decideFlag = StringUtils.defaultIfEmpty((String)prevData.get("DECIDE_FLAG"), "");

                        // 이전의 결재타입이 병렬합의, 병렬결재라면
                        if(signReqType.equals("4") || signReqType.equals("7")) {

                        	for(int j = i; j > 0; j--) {
                                if(j-1 >= 0) {
                                    Map<String, Object> beforePrevData = gridL.get(j-1);
                                    String beforePrevSignReqType = StringUtils.defaultIfEmpty((String)beforePrevData.get("SIGN_REQ_TYPE"), "");

                                    if(beforePrevSignReqType.equals("4") || beforePrevSignReqType.equals("7")) {
                                        gridL.set(j, beforePrevData);
                                        if(j-1 == 0) {
                                            gridL.set(j-1, currData);
                                        }
                                    } else {
                                        gridL.set(j, currData);
                                        gridL.set(j-1, beforePrevData);
                                        i = j-1;
                                        break;
                                    }
                                } else {
                                    gridL.set(1, gridL.get(0));
                                    gridL.set(0, currData);
                                    i = j;
                                    break;
                                }
                            }
                        /* 추가된 결재자에 대해서는 전결라인에 상관없이 어디든 이동이 가능하다.
                        } else if(decideFlag.equals("Y")) {
                        	gridL.set(i, currData); */
                    	} else {
                            gridL.set(i-1, currData);
                            gridL.set(i, prevData);
                            i--;
                            break;
                        }
                    }
                } else {
                    gridL.set(i, currData);
                }
            }

        } else if(sortType.equals("down")) {

        	int maxSize = gridL.size();

        	for(int i = 0; i < maxSize; i++) {

        		Map<String, Object> currData = gridL.get(i);
                String checkFlag = (String)currData.get("CHECK_FLAG");

                if(StringUtils.equals(checkFlag, "1")) {

                	if(i != maxSize-1) {

                    	Map<String, Object> prevData = gridL.get(i+1);
                        String signReqType = StringUtils.defaultIfEmpty((String)prevData.get("SIGN_REQ_TYPE"), "");
                        String decideFlag = StringUtils.defaultIfEmpty((String)prevData.get("DECIDE_FLAG"), "");

                        // 이전의 결재타입이 병렬합의, 병렬결재라면
                        if(signReqType.equals("4") || signReqType.equals("7")) {

                        	for(int j = i; j < maxSize; j++) {
                                if(j+1 < maxSize) {
                                    Map<String, Object> afterNextData = gridL.get(j+1);
                                    String beforePrevSignReqType = StringUtils.defaultIfEmpty((String)afterNextData.get("SIGN_REQ_TYPE"), "");

                                    if(beforePrevSignReqType.equals("4") || beforePrevSignReqType.equals("7")) {
                                        gridL.set(j, afterNextData);
                                    } else {
                                        gridL.set(j, currData);
                                        i = j;
                                        break;
                                    }
                                } else {
                                    gridL.set(maxSize-2, gridL.get(maxSize-1));
                                    gridL.set(maxSize-1, currData);
                                    i = j;
                                    break;
                                }
                            }
                        /* 추가된 결재자에 대해서는 전결라인에 상관없이 어디든 이동이 가능하다.
                        } else if(decideFlag.equals("Y")) {
                        	gridL.set(i, currData); */
                    	} else {
                            gridL.set(i, prevData);
                            gridL.set(i+1, currData);
                            i++;
                        }
                    }
                } else {
                    gridL.set(i, currData);
                }
            }
        }
        resp.setGridObject("gridL", gridL);
	}

	@RequestMapping(value = "/BAPP_550/doSelectMyPath")
	public void approvalRequestPopupDoSelectMyPathII(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String strApprovalPathKey = req.getParameter("strApprovalPathKey");

		@SuppressWarnings("unchecked")
		HashMap<String, String> approvalPathKey = new ObjectMapper().readValue(strApprovalPathKey, HashMap.class);
		approvalPathKey.put("gateCd", approvalPathKey.get("GATE_CD"));
		approvalPathKey.put("pathNum", approvalPathKey.get("PATH_NUM"));

		resp.setGridObject("gridL", bapp_Service.selectLULP(approvalPathKey));

		resp.setResponseMessage("Success");
		resp.setResponseCode("true");
	}


	@RequestMapping(value = "/eApprovalSignPeopleList/view")
	public String approvalSignUserList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setParameter("APP_DOC_NUM", req.getParameter("APP_DOC_NUM"));
        resp.setParameter("APP_DOC_CNT", req.getParameter("APP_DOC_CNT"));
		return "/eversrm/eApproval/eApprovalSignPeopleList";
	}


	@RequestMapping("/BAPP_060/view")
	public String BAPP_060_View(EverHttpRequest req) throws Exception {
		ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("refStatus", om1.writeValueAsString(commonComboService.getCodeCombo("M020")));
		ObjectMapper om2 = new ObjectMapper();
		req.setAttribute("refSignReqStatus", om2.writeValueAsString(commonComboService.getCodeCombo("M040")));
		ObjectMapper om3 = new ObjectMapper();
		req.setAttribute("refDocType", om3.writeValueAsString(commonComboService.getCodeCombo("M038")));

		if("Y".equals(req.getParameter("summary"))) {
			req.setAttribute("fromDate", EverDate.addMonths(-1));
		} else {
			req.setAttribute("fromDate", EverDate.getDate().substring(0,6) + "01");
		}
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("signStatus", "P");
		return "/eversrm/eApproval/eApprovalBox/BAPP_060";
	}

	// 조회
	@RequestMapping(value = "/BAPP_060/getSendReceiveBoxList")
	public void getSendReceiveBoxList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("regDateFrom", EverDate.getGmtFromDate(param.get("regDateFrom"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("regDateTo", EverDate.getGmtToDate(param.get("regDateTo"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		resp.setGridObject("grid", bapp_Service.getSendReceiveBoxList(param));
//		resp.setResponseCode("true");

		List<Map<String, Object>> list = bapp_Service.getSendReceiveBoxList(param);

		for (Map<String, Object> grid : list) {
			String docType = String.valueOf( grid.get("DOC_TYPE") );
			String consultContentsUrl = PropertiesManager.getString("eversrm.approval.consultContentsUrl." + docType);
			if (!consultContentsUrl.contains("?")) {
				consultContentsUrl += "?";
			}
			grid.put("CONSULTCONTENTSURL", consultContentsUrl);
		}

		makeGridTextLinkStyle(resp, "grid", "SUBJECT");
		makeGridTextLinkStyle(resp, "grid", "VIEW_CNT");

		resp.setGridObject("grid", list);
		resp.setResponseCode("true");
	}

	@RequestMapping("/BAPP_060A/view")
	public String BAPP_060A_View(EverHttpRequest req) throws Exception {
		ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("refStatus", om1.writeValueAsString(commonComboService.getCodeCombo("M020")));
		ObjectMapper om2 = new ObjectMapper();
		req.setAttribute("refSignReqStatus", om2.writeValueAsString(commonComboService.getCodeCombo("M040")));
		ObjectMapper om3 = new ObjectMapper();
		req.setAttribute("refDocType", om3.writeValueAsString(commonComboService.getCodeCombo("M038")));
		/*
		if("Y".equals(req.getParameter("summary"))) {
			req.setAttribute("fromDate", EverDate.addMonths(-1));
		} else {
			req.setAttribute("fromDate", EverDate.getDate().substring(0,6) + "01");
		}
		*/
		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("signStatus", "");

		return "/eversrm/eApproval/eApprovalBox/BAPP_060A";
	}

	//조회
	@RequestMapping(value = "/BAPP_060A/getSendReceiveBoxListA")
	public void getSendReceiveBoxListA(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("regDateFrom", EverDate.getGmtFromDate(param.get("regDateFrom"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("regDateTo", EverDate.getGmtToDate(param.get("regDateTo"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		resp.setGridObject("grid", bapp_Service.getSendReceiveBoxList(param));
//		resp.setResponseCode("true");

		List<Map<String, Object>> list = bapp_Service.getSendReceiveBoxListA(param);

    	/*for (Map<String, Object> grid : list) {
    		String docType = String.valueOf( grid.get("DOC_TYPE") );
    		String consultContentsUrl = PropertiesManager.getString("eversrm.approval.consultContentsUrl." + docType);
    		if (!consultContentsUrl.contains("?")) {
    			consultContentsUrl += "?";
    		}

    		grid.put("CONSULTCONTENTSURL", consultContentsUrl);
		}*/

		resp.setGridObject("grid", list);
		resp.setResponseCode("true");
	}

	//이미지 텍스트그리드
	private void makeGridTextLinkStyle(EverHttpResponse resp, String grid, String columnName) {
        resp.setGridColStyle(grid, columnName, "cursor", "pointer");
        resp.setGridColStyle(grid, columnName, "color", "#000DFF");
        resp.setGridColStyle(grid, columnName, "text-decoration", "underline");
	}

}