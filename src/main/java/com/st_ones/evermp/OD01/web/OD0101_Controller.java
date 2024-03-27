package com.st_ones.evermp.OD01.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.OD01.service.OD0101_Service;
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
 * @File Name : BMY1_Controller.java
 * @author
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/OD01/OD0101")
public class OD0101_Controller extends BaseController {

    @Autowired private OD0101_Service od0101_Service;
    @Autowired private CommonComboService commonComboService;
    @Autowired private MessageService msg;

    /** ******************************************************************************************
     * 운영사 : 주문대기목록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/OD01_001/view")
    public String OD01_001(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","B100");    //고객사담당

        String vendorIFList = commonComboService.getCodeComboAsJson("MP088");
        req.setAttribute("vendorIFList", vendorIFList);

        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));

        return "/evermp/OD01/OD01_001";
    }

    @RequestMapping(value = "/OD01_001/doSearch")
    public void od01001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));

        resp.setGridObject("grid", od0101_Service.od01001_doSearch(param));
    }

    @RequestMapping(value = "/od01001_doTransferCtrl")
    public void od01001_doTransferCtrl(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("AM_USER_ID", EverString.nullToEmptyString(req.getParameter("sAM_USER_ID")));
        formData.put("AM_USER_CHANGE_RMK", EverString.nullToEmptyString(req.getParameter("AM_USER_CHANGE_RMK")));

        String msg = od0101_Service.od01001_doTransferCtrl(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    // 승인요청
    @RequestMapping(value = "/od01001_doReqConfirm")
    public void od01001_doReqConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        formData.put("CONFIRM_REQ_RMK", EverString.nullToEmptyString(req.getParameter("CONFIRM_REQ_RMK")));

        String msg = od0101_Service.od01001_doReqConfirm(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    // 발주승인
    @RequestMapping(value = "/od01001_doPoConfirm")
    public void od01001_doPoConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));

//        od0101_Service.od01001_doPoConfirmXX(formData, req.getGridData("grid"));
        String msg = od0101_Service.od01001_doPoConfirm(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/od01001_doPoConfirmReject")
    public void od01001_doPoConfirmReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        formData.put("PO_CONFIRM_REJECT_RMK", EverString.nullToEmptyString(req.getParameter("PO_CONFIRM_REJECT_RMK")));

        String msg = od0101_Service.od01001_doPoConfirmReject(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    // 저장
    @RequestMapping(value = "/od01001_doSave")
    public void od01001_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("CONFIRM_REQ_RMK", EverString.nullToEmptyString(req.getParameter("CONFIRM_REQ_RMK")));

        String msg = od0101_Service.od01001_doSave(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    // 운영사 메모, 저장
    @RequestMapping(value = "/od01001_doSaveAGENT_MEMO")
    public void od01001_doSaveAGENT_MEMO(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = new HashMap<String, String>();

        String msg = od0101_Service.od01001_doSaveAGENT_MEMO(formData, req.getGridData("grid"));

        resp.setResponseMessage(msg);
    }

    /** ******************************************************************************************
     * 운영사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/OD01_010/view")
    public String OD01_010(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자

        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));

        return "/evermp/OD01/OD01_010";
    }

    @RequestMapping(value = "/OD01_010/doSearch")
    public void od01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        /*Map<String, String> param = req.getFormData();
        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));
        resp.setGridObject("grid", od0101_Service.od01010_doSearch(param));*/

        List<Map<String, Object>> gridList = od0101_Service.od01010_doSearch(req.getFormData());
        //resp.sendJSON(gridList);
        resp.setGridObject("grid", gridList);
        resp.setGridObject("gridEx", gridList);
    }

    @RequestMapping(value = "/OD01_010/doExcelDown")
    public void od01010_doExcelDown(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDatas = req.getGridData("grid");
        resp.setGridObject("gridEx", gridDatas);
    }

    // 운영사 메모, 저장
    @RequestMapping(value = "/od01010_doSaveAGENT_MEMO")
    public void od01010_doSaveAGENT_MEMO(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = new HashMap<String, String>();

        String msg = od0101_Service.od01001_doSaveAGENT_MEMO(formData, req.getGridData("grid"));

        resp.setResponseMessage(msg);
    }

    // 주문취소
    @RequestMapping(value = "/od01010_doCancelPO")
    public void od01010_doCancelPO(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = od0101_Service.od01010_doCancelPO(gridList);

        resp.setResponseMessage(rtnMsg);
    }

    /** ******************************************************************************************
     * 운영사 > 주문관리 > 주문진행현황 > 주문변경
     * @param req
     * @return String
     * @throws Exception
     */
    @RequestMapping(value="/OD01_011/view")
    public String OD01_011(EverHttpRequest req) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        List<Map<String, Object>> list = od0101_Service.od01011_doSearch(param);
        Map<String, Object> map = list.get(0);

        req.setAttribute("DATA", map);

        return "/evermp/OD01/OD01_011";
    }

    @RequestMapping(value = "/od01011_doSearch")
    public void od01011_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        List<Map<String, Object>> list = od0101_Service.od01011_doSearchINV(param);
        List<Map<String, Object>> list2 = od0101_Service.od01011_doSearchINV2(param);

        resp.setGridObject("grid", list2);
        resp.setGridObject("grid2", list);
    }

    @RequestMapping(value="/od01011_doOrder")
    public void od01011_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        String messageCode = od0101_Service.od01011_doOrder(param);
        if( "0001".equals(messageCode) || "0023".equals(messageCode) ) {
            resp.setResponseCode("OK");
        } else {
            resp.setResponseCode("NO");
        }
        resp.setResponseMessage(msg.getMessage(messageCode));
    }

    @RequestMapping(value="/od01011_doSaveRecipient")
    public void od01011_doSaveRecipient(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        String rtnMsg = od0101_Service.od01011_doSaveRecipient(param);

        resp.setResponseMessage(rtnMsg);
    }

    /** ******************************************************************************************
     * 운영사 : 주문IF현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/OD01_020/view")
    public String OD01_020(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/OD01/OD01_020";
    }

    @RequestMapping(value = "/OD01_020/doSearch")
    public void od01020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));

        resp.setGridObject("grid", od0101_Service.od01020_doSearch(param));
    }

    // 저장
    @RequestMapping(value = "/od01020_doSave")
    public void od01020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = od0101_Service.od01020_doSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 배치실행
    @RequestMapping(value = "/od01020_doBatchExec")
    public void od01020_doBatchExec(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = od0101_Service.od01020_doBatchExec(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    /** ******************************************************************************************
     * 운영사 : 입고IF현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/OD01_030/view")
    public String OD01_030(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/OD01/OD01_030";
    }

    @RequestMapping(value = "/OD01_030/doSearch")
    public void od01030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));

        resp.setGridObject("grid", od0101_Service.od01030_doSearch(param));
    }

    /**
     * 주문이력관리(구.MP)
     */
    @RequestMapping(value="/OD01_040/view")
    public String OD01_040(EverHttpRequest req) throws Exception {
        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("END_DATE", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/OD01/OD01_040";
    }

    @RequestMapping(value = "/OD01040_doSearch")
    public void od01040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("grid", od0101_Service.od01040_doSearch(param));
    }
}
