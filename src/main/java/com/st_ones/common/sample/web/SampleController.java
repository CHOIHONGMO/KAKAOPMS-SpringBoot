package com.st_ones.common.sample.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.login.web.LoginController;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sample.service.SampleService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

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
 * @File Name : SampleController.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/common/sample")
public class SampleController extends BaseController {

	@Autowired
	private SampleService sampleService;

	@Autowired
	private LoginController loginController;

	@Autowired
	private MessageService msg;

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private CommonComboService commonComboService;

	@RequestMapping(value = "/samplePage1/view")
	public String getSamplePage1View(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String cds = commonComboService.getCodeComboAsJson("M001");
        String cds2 = commonComboService.getCodeComboAsJson("M026");
        String cds3 = commonComboService.getCodeComboAsJson("M009");

        ObjectMapper om = new ObjectMapper();

        req.setAttribute("LanguageList", cds);
        req.setAttribute("multiTypeCd", om.writeValueAsString(cds2));
        req.setAttribute("multiLanguageModuleType", om.writeValueAsString(cds3));

		return "/common/sample/samplePage1";
	}

    @RequestMapping(value = "/TEST010/view")
    public String TEST010() {
        return "/common/sample/TEST010";
    }

    @RequestMapping(value = "/TEST010/doConnect")
    public void Test010DoConnect(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
    	sampleService.doConnect(param);
    }


    @RequestMapping(value = "/samplePage2/view")
    public String getSamplePage2View() {
        return "/common/sample/samplePage2";
    }

    @RequestMapping(value = "/samplePage3/view")
    public String getSamplePage3View() {
        return "/common/sample/samplePage3";
    }

    @RequestMapping(value = "/samplePage4/view")
    public String getSamplePage4View() {
        return "/common/sample/samplePage4";
    }

    @RequestMapping(value = "/samplePage5/view")
    public String getSamplePage5View() {
        return "/common/sample/samplePage5";
    }

    @RequestMapping(value = "/samplePage6/view")
    public String getSamplePage6View(EverHttpRequest req) throws Exception {
        return "/common/sample/samplePage6";
    }

    @RequestMapping(value = "/samplePage7/view")
    public String getSamplePage7View(EverHttpRequest req) throws Exception {
        return "/common/sample/samplePage7";
    }

    @RequestMapping(value = "/icons/view")
    public String getSampleIconView() {
        return "/common/sample/icons";
    }

    @RequestMapping(value = "/doUpdate.so")
    public void doUpdate(EverHttpRequest request, EverHttpResponse response) throws Exception {

    }

    @RequestMapping(value = "/doSearch.so", method= RequestMethod.POST)
    public void doSearch(EverHttpRequest request, EverHttpResponse response) throws Exception {
        List<Map<String, Object>> gridData = new ArrayList<Map<String, Object>>();

        for(int i = 0; i < 10000; i++) {
        	Map<String, Object> data = new HashMap<String, Object>();

        	response.setGridCellStyle( "BSYS_010", String.valueOf( i ), "SCREEN_ID", "background-color", "green");

        	data.put("DATA_AUTH_FLAG",	"0");
        	data.put("DEVELOPER_CD",	"linh");
        	data.put("GATE_CD",			"100");
        	data.put("INSERT_FLAG",		"U");
        	data.put("MODULE_TYPE",		"PR");
        	data.put("REG_DATE",		"20120101");
        	data.put("REG_USER_ID",		"MASTER");
        	data.put("SCREEN_ID",		"SPQ_030");
        	data.put("SCREEN_ID_ORG",	"SPQ_030");
        	data.put("SCREEN_NM",		"'역경매참여'");
        	data.put("SCREEN_TYPE",		"JSP");
        	data.put("SCREEN_URL",		"/wisepro/solicit/rAuction/rAuctionMgt/rAuctionParticipation/view.wu");
        	data.put("USE_FLAG",		"1");

        	gridData.add(data);
        }

        Map<String, String> tmp = new HashMap<String, String>();
        tmp.put("url", "/images/eversrm/buttons/btn_user.gif");
        tmp.put("option", "stretched");

        response.setCellReadOnly( "BSYS_010", "0", "SCREEN_NM", false);
        response.setCellReadOnly( "BSYS_010", "0", "SCREEN_URL", false);
        response.setRowNotEdit( "BSYS_010", "0", true);

        response.setCellReadOnly( "BSYS_010", "1", "SCREEN_NM", true);
        response.setCellReadOnly( "BSYS_010", "1", "SCREEN_URL", true);
        response.setRowNotEdit( "BSYS_010", "2", true);

        response.setGridColStyle("BSYS_010", "SCREEN_NM", "background-color", "pink");
        response.setGridRowStyle("BSYS_010", "0", "background-color", "green");
        response.setGridRowStyle("BSYS_010", "1", "background-color", "100|200|10");
        response.setGridCellStyle("BSYS_010", "0", "SCREEN_NM", "background-color", "red");
        response.setGridCellStyle("BSYS_010", "0", "SCREEN_NM", "font-size", "14");
        response.setGridCellStyle("BSYS_010", "0", "MODULE_TYPE", "background-color", "red");
        response.setGridCellStyle("BSYS_010", "0", "SCREEN_ID", "background-image", tmp);
        response.setGridObject("BSYS_010", gridData);
        response.setParameter("result", "ok");
        response.setResponseCode("0001");
        response.setResponseMessage("It's done!");
    }

    @RequestMapping(value = "/getDocNoTest")
	public void getDocNoTest(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();

    	String docNo = docNumService.getDocNumber(param.get("docType"));
    	param.put("DOC_NO", docNo);

    	resp.setResponseCode("0001");
    	resp.setResponseMessage(msg.getMessage("0018", docNo));
    	resp.setParameter("docNo", docNo);
    	resp.setFormDataObject(param);

    }

    @RequestMapping(value = "/doSearchPage6")
	public void doSearchPage6(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	UserInfo baseInfo = UserInfoManager.getUserInfo();
    	Map<String, String> param = req.getFormData();
    	param.put("FROM_DATE", EverDate.getGmtFromDate(param.get("fromDate"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("TO_DATE", EverDate.getGmtToDate(param.get("toDate"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		List<Map<String, Object>> list = sampleService.doSearchPage6(param);

    	resp.setResponseCode("0001");
    	resp.setResponseMessage("Result : " + list.size());

	}

    @RequestMapping(value = "/doAopTest")
	public void doAopTest(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	UserInfo baseInfo = UserInfoManager.getUserInfo();
    	Map<String, String> param = req.getFormData();
    	param.put("FROM_DATE", EverDate.getGmtFromDate(param.get("fromDate"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("TO_DATE", EverDate.getGmtToDate(param.get("toDate"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

//		String rtnMsg = "";
//
//		try {
//			List<Map<String, Object>> list = badi_Service.doSearchItemAttributeManagement(param);
//			rtnMsg = "Result : " + list.size();
//		} catch(Exception e) {
//			rtnMsg = e.getMessage();
//		}

//		List<Map<String, Object>> list = badi_Service.doSearchItemAttributeManagement(param);
		resp.setResponseCode("0001");
//		resp.setResponseMessage("Result : " + list.size());

	}

    @RequestMapping(value = "/gridTree/view")
    public String gridTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	return "/common/sample/gridTree";
    }


    @RequestMapping(value = "/gridTree/copy")
    public void gridTreeCopy(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	String grid = req.getParameter("grid");

    	List<Map<String, Object>> gridData = (List<Map<String, Object>>) (new ObjectMapper()).readValue(grid, Object.class);

    	resp.setGridObject("grid", gridData);
    }
}