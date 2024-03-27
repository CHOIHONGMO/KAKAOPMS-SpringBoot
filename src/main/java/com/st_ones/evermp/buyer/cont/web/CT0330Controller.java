package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0330Controller  extends BaseController {

    private static Logger logger = LoggerFactory.getLogger(CT0330Controller.class);
	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
    @Autowired private MessageService messageService;
    @Autowired private CT0300Service ct0300service;

    /**
     * 계약서 현황
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/CT0330/view")
    public String contractStatus(EverHttpRequest req) throws Exception {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        String ctrlCd = baseInfo.getCtrlCd();
        if(ctrlCd==null) ctrlCd = "";


        req.setAttribute("fromDate", EverDate.addMonths(-3));
        req.setAttribute("toDate", EverDate.addMonths(36));
        req.setAttribute("pdfPath", PropertiesManager.getString("wizpdf.server.domainName") + "/contPDF/");
        req.setAttribute("authFlag", ( ctrlCd.indexOf("C100") > -1 ? true : false));

        Map<String, String> param = new HashMap<>();
        param.put("FLAG1", "C");
        req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
        return "/evermp/buyer/cont/CT0330";
    }

    /**
     * 계약서 현황 조회
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0330/doSearch")
    public void ecoa0020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("INFO_FLAG", "Y");
        resp.setGridObject("grid", ct0300service.ecoa0020_doSearch(param));
    }

    // 담당자 변경
    @RequestMapping(value="/CT0330/doChangeContUser")
    public void ECOA0020_doChangeContUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String contUserId = EverString.nullToEmptyString(req.getParameter("CONT_USER_ID"));

        String rtnMsg = ct0300service.ECOA0020_doChangeContUser(contUserId, gridData);
        resp.setResponseMessage(rtnMsg);
    }

    // 계약서 복사
    @RequestMapping(value="/CT0330/doCopy")
    public void ECOA0020_doCopy(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");

        Map<String, String> rtnMap = ct0300service.ECOA0020_doCopy(gridData);
        resp.setParameter("newContNum", rtnMap.get("newContNum"));
        resp.setParameter("newContCnt", rtnMap.get("newContCnt"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }



    // ERP 매핑삭제
    @RequestMapping(value="/CT0330/doDelMapping")
    public void ECOA0020_doDelMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");

        String rtnMsg = ct0300service.ECOA0020_doDelMapping(gridData);
        resp.setResponseMessage(rtnMsg);
    }

    // 계약서 보증서 저장
    @RequestMapping(value="/CT0330/doSave")
    public void ECOA0020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");

        ct0300service.BECM_050_doSave(gridData);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    // 계약서 추가첨부 저장
    @RequestMapping(value="/CT0330/doAttSave")
    public void ECOA0020_doAttSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");

        ct0300service.BECM_050_doAttSave(gridData);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    @RequestMapping(value = "/CT0330/doSendToImageTest")
    public void ecoa0020_doSendToImageTest(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String elementId = "";

        List<Map<String, Object>> gridDatas = req.getGridData("grid");
        for(Map<String, Object> gridData : gridDatas) {
            String contNum = String.valueOf(gridData.get("CONT_NUM"));
            String contCnt = String.valueOf(gridData.get("CONT_CNT"));
            elementId = ct0300service.sendFileToImageServer(contNum, contCnt);
        }
        resp.setParameter("elementId", elementId);
    }

    // 계약서 추가파일 저장
    @RequestMapping(value="/CT0330/doAddFileSave")
    public void ECOA0020_doAddFileSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");

        ct0300service.ECOA0020_doAddFileSave(gridData);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }



}
