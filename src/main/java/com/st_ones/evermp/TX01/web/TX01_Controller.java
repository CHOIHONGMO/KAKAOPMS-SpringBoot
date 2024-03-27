package com.st_ones.evermp.TX01.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.TX01.service.TX01_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/TX01")
public class TX01_Controller extends BaseController {

    @Autowired private TX01_Service tx01_Service;
    @Autowired private MessageService msg;
    @Autowired CommonComboService commonComboService;

    /**
     * 운영사 > 정산관리 > 매출정산 > 매출세금계산서 현황
     */
    @RequestMapping(value="/TX01_010/view")
    public String TX01_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"B".equals(userInfo.getUserType()) &&!"C".equals(userInfo.getUserType())) {
	  	       return "/eversrm/noSuperAuth";
	  	      }
        boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);

        req.setAttribute("TODAY", EverDate.getDate());
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.addMonths(0).substring(4, 6));
        req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));
        return "/evermp/TX01/TX01_010";
    }

    @RequestMapping(value = "/tx01010_doSearch")
    public void tx01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", tx01_Service.tx01010_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/tx01010_doSearchTTID")
    public void tx01010_doSearchTTID(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid_TTID", tx01_Service.tx01010_doSearchTTID(req.getFormData()));
    }

    @RequestMapping(value = "/tx01010_doUpdateTTID")
    public void tx01010_doUpdateTTID(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid_TTID");

        tx01_Service.tx01010_doUpdateTTID(gridList, form);
    }

    @RequestMapping(value = "/tx01010_doSearchBILLSTAT")
    public void tx01010_doSearchBILLSTAT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setParameter("MSG", tx01_Service.tx01010_doSearchBILLSTAT(req.getFormData()));
    }

    @RequestMapping(value = "/tx01010_doSave")
    public void tx01010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx01_Service.tx01010_doSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 삭제
    @RequestMapping(value = "/tx01010_doTaxCancel")
    public void tx01010_doTaxCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx01_Service.tx01010_doTaxCancel(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 병합
    @RequestMapping(value = "/tx01010_doSaveMerge")
    public void tx01010_doSaveMerge(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx01_Service.tx01010_doSaveMerge(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/tx01010_doSaveDeposit")
    public void tx01010_doSaveDeposit(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx01_Service.tx01010_doSaveDeposit(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 전송
    @RequestMapping(value = "/tx01010_doUniPostTrans")
    public void tx01010_doUniPostTrans(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01010_doUniPostTrans(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "038"));
            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 전송
	@RequestMapping(value = "/tx01010_doSendBillTrans")
	public void tx01010_doSendBillTrans(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		try {
            rtnMsg = tx01_Service.tx01010_doSendBillTrans(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "038"));
            resp.setResponseCode("ERR");
            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
	}

	// 취소
    @RequestMapping(value = "/tx01010_doUniPostCancel")
    public void tx01010_doUniPostCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01010_doUniPostCancel(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "037"));
            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    @RequestMapping(value = "/tx01010_doSendBillCancel")
    public void tx01010_doSendBillCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01010_doSendBillCancel(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "037"));
            resp.setResponseCode("ERR");
            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 재전송
    @RequestMapping(value = "/tx01010_doUniPostReSend")
    public void tx01010_doUniPostReSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01010_doUniPostReSend(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
//            String[] s = e.getMessage().split((":"));
//            String TAX_NUM = s[0];
//
//            if("T".equals(s[1])) {
                resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "038"));
//            } else if("S".equals(s[1])) {
//                resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "037"));
//            }

            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", TAX_NUM);
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 재전송
    @RequestMapping(value = "/tx01010_doSendBillReSend")
    public void tx01010_doSendBillReSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01010_doSendBillReSend(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            String[] s = e.getMessage().split((":"));
            String TAX_NUM = s[0];

            if("T".equals(s[1])) {
                resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "038"));
            } else if("S".equals(s[1])) {
                resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "037"));
            }

            resp.setResponseCode("ERR");
            rtnMsg.put("TAX_NUM", TAX_NUM);
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 메일 재발송
    @RequestMapping(value = "/tx01010_doUniPostMailReSend")
    public void tx01010_doUniPostMailReSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01010_doUniPostMailReSend(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "050"));
            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 운영사 > 정산관리 > 매출정산 > 매출회계계산서 목록
    @RequestMapping(value="/TX01_020/view")
    public String TX01_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.addMonths(0).substring(4, 6));

        return "/evermp/TX01/TX01_020";
    }

    // 조회
    @RequestMapping(value = "/tx01020_doSearch")
    public void tx01020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", tx01_Service.tx01020_doSearch(req.getFormData()));
    }


    // 조회
    @RequestMapping(value = "/tx01020_detail")
    public void tx01020_detail(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String,String> param = req.getFormData();
    	param.put("MGRNO",req.getParameter("MGRNO"));

    	List<Map<String, Object>> list = tx01_Service.tx01020_detail( param );


    	String data = new ObjectMapper().writeValueAsString(list);
    	resp.setResponseMessage(data);
    }



















    // 회계확정
    @RequestMapping(value = "/tx01020_doAccC")
    public void tx01020_doAccC(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        tx01_Service.tx01020_doAccC(req.getGridData("grid"));
    }

    // 회계확정취소
    @RequestMapping(value = "/tx01020_doAccC_Cancel")
    public void tx01020_doAccC_Cancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        tx01_Service.tx01020_doAccC_Cancel(req.getGridData("grid"));
    }

    // 회계검증
    @RequestMapping(value = "/tx01020_doAccV")
    public void tx01020_doAccV(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        tx01_Service.tx01020_doAccV(req.getGridData("grid"));
    }

    // 회계검증취소
    @RequestMapping(value = "/tx01020_doAccV_Cancel")
    public void tx01020_doAccV_Cancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        tx01_Service.tx01020_doAccV_Cancel(req.getGridData("grid"));
    }

    // 자동전표실 메입
    @RequestMapping(value = "/tx01020_doAutoDocExe")
    public void tx01020_doAutoDocExe(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	List<Map<String,Object>> gridData = req.getGridData("grid");
    	Map<String,String> param = req.getFormData();


    	String type = param.get("TYPE");



    	if("AR".equals(type)) { // 매출
            for (Map<String, Object> grid : gridData) {
            	grid.put("DOCNO"     , grid.get("AR_NO"));
            	tx01_Service.chkDgnsSend(grid);
            }

    		tx01_Service.closeYnChkS(param, gridData);
        	String seqId = "";
            for (Map<String, Object> grid : gridData) {
            	seqId = tx01_Service.AR_GO_INS(param, grid);
            	tx01_Service.AR_GO_CALL(seqId,param, grid); // 매출콜
            }
    	} else if("AP".equals(type)) { //매입
            for (Map<String, Object> grid : gridData) {
            	grid.put("DOCNO"     , grid.get("AP_NO"));
            	tx01_Service.chkDgnsSend(grid);
            }

    		tx01_Service.closeYnChkP(param, gridData);
        	String seqId = "";
            for (Map<String, Object> grid : gridData) {
            	seqId = tx01_Service.AP_GO_INS(param, grid);
            	tx01_Service.AP_GO_CALL(seqId,param, grid); // 매입콜
            }
    	}

    }

    // 월매출마감종료
    @RequestMapping(value = "/tx01020_doSalesClose")
    public void tx01020_doSalesClose(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("TYPE", req.getParameter("TYPE"));

        tx01_Service.tx01020_doSalesClose(param);
    }


    @RequestMapping(value = "/doSalesCloseCancel")
    public void doSalesCloseCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("TYPE", req.getParameter("TYPE"));

        tx01_Service.doSalesCloseCancel(param);
    }










    /** ******************************************************************************************
     * 운영사 > 정산관리 > 매출정산 > 전표이관
     * @param req
     * @return String
     * @throws Exception
     */
    @RequestMapping(value="/TX01_011/view")
    public String TX01_011(EverHttpRequest req) throws Exception {
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.addMonths(-1).substring(4, 6));

        return "/evermp/TX01/TX01_011";
    }

    @RequestMapping(value = "/tx01011_doSearch")
    public void tx01011_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", tx01_Service.tx01011_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/tx01011_doSearchTTID")
    public void tx01011_doSearchTTID(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid_TTID", tx01_Service.tx01011_doSearchTTID(req.getFormData()));
    }

    @RequestMapping(value = "/tx01011_doSave")
    public void tx01011_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx01_Service.tx01011_doSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/tx01011_doSlipTrans")
    public void tx01011_doSlipTrans(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx01_Service.tx01011_doSlipTrans(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_011", "033") + " [" + e.getMessage() + "]");
            resp.setResponseCode("ERR");
            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }



    }

    @RequestMapping(value = "/tx01011_doSlipTransCancel")
    public void tx01011_doSlipTransCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx01_Service.tx01011_doSlipTransCancel(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }














    // 월마감종료
    @RequestMapping(value = "/chkClose")
    public void chkClose(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("TYPE", req.getParameter("TYPE"));
        resp.setResponseMessage(tx01_Service.chkClose(param));
    }






}
