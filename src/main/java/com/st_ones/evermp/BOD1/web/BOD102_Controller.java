package com.st_ones.evermp.BOD1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BOD1.service.BOD102_Service;
import com.st_ones.evermp.BS99.service.BS9901_Service;
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
 * @File Name : BOD102_Controller.java
 * @author  최홍모
 * @date 2018. 10. 25.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/BOD1/BOD102")
public class BOD102_Controller extends BaseController {

    @Autowired private BOD102_Service bod102_Service;
    @Autowired private BS9901_Service bs9901service;
    @Autowired private CommonComboService commonComboService;
    @Autowired private MessageService msg;

    /** ******************************************************************************************
     * 주문일괄등록
     */
    @RequestMapping(value="/BOD1_020/view")
    public String BOD1_020(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
	  	       return "/eversrm/noSuperAuth";
	  	      }

		//================== 템플릿 파일 번호 가져오기 ==================
        Map<String, String> tempData = new HashMap<String, String>();
        tempData.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.CPOBULK.key"));
        Map<String, String> tempMap = bs9901service.doSearch_templateFile(tempData);
        req.setAttribute("TEMP_ATT_FILE_NUM", (tempMap!=null&&tempMap.size()>0)?tempMap.get("ATT_FILE_NUM"):"");
        //================== 템플릿 파일 번호 가져오기 ==================

        // 사용자 기본배송지 가져오기
        Map<String, Object> delyInfo = bod102_Service.bod1020_doSearchDelyInfo(null);
        req.setAttribute("delyInfo", delyInfo);

        req.setAttribute("hopeDueDate", EverDate.addDateDay(EverDate.getDate(), 7));
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());

        return "/evermp/BOD1/BOD1_020";
    }

    // 조회
    @RequestMapping(value = "/bod1020_doSearch")
    public void bod1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("CUST_CD", param.get("CUST_CD"));

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
            param.put("CUST_CD", userInfo.getCompanyCd());
        }


        //resp.setParameter("PLANT_CD_Options", commonComboService.getCodesAsJson("CB0100", param));

        resp.setGridObject("grid", bod102_Service.bod1020_doSearch(req.getFormData()));
    }

    // 플랜트, 조회
    @RequestMapping(value = "/bod1020_doSearchPLANT")
    public void bod1020_doSearchPLANT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("CUST_CD", param.get("CUST_CD"));
        resp.setParameter("PLANT_CD_Options", commonComboService.getCodesAsJson("CB0100", param));
    }

    // 저장 및 유효성 검증
    @RequestMapping(value="/bod1020_doSave")
    public void bod1020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Save");

        String returnMsg = bod102_Service.bod1020_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }

    // 주문하기
    @RequestMapping(value="/bod1020_doOrder")
    public void bod1020_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Order");

        String returnMsg = bod102_Service.bod1020_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }

    // 주문품목 삭제
    @RequestMapping(value="/bod1020_doDelete")
    public void bod1020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bod102_Service.bod1020_doDelete(gridList);
        resp.setResponseMessage(returnMsg);
    }

    /**
     * 주문일괄등록 엑셀업로드
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/doSetExcelImportItemCpo")
    public void doSetExcelImportItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bod102_Service.doSetExcelImportItem(req.getGridData("grid")));
    }















	/*
	 * 정산용 업로드
	 */

    @RequestMapping(value="/BOD1_021/view")
    public String BOD1_021(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		//================== 템플릿 파일 번호 가져오기 ==================
        Map<String, String> tempData = new HashMap<String, String>();
        //tempData.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.CPOBULK.key"));

        tempData.put("TMPL_NUM", "BOD1_021");

        Map<String, String> tempMap = bs9901service.doSearch_templateFile(tempData);
        req.setAttribute("TEMP_ATT_FILE_NUM", (tempMap!=null&&tempMap.size()>0)?tempMap.get("ATT_FILE_NUM"):"");
        //================== 템플릿 파일 번호 가져오기 ==================

        // 사용자 기본배송지 가져오기
        Map<String, Object> delyInfo = bod102_Service.bod1020_doSearchDelyInfo(null);
        req.setAttribute("delyInfo", delyInfo);

        req.setAttribute("hopeDueDate", EverDate.addDateDay(EverDate.getDate(), 7));
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());

        return "/evermp/BOD1/BOD1_021";
    }




    // 저장 및 유효성 검증
    @RequestMapping(value="/bod1021_doSave")
    public void bod1021_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Save");

        String returnMsg = bod102_Service.bod1021_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }

    // 주문하기
    @RequestMapping(value="/bod1021_doOrder")
    public void bod1021_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Order");

        String returnMsg = bod102_Service.bod1021_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }





    // 조회
    @RequestMapping(value = "/bod1021_doSearch")
    public void bod1021_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("CUST_CD", param.get("CUST_CD"));

        resp.setGridObject("grid", bod102_Service.bod1021_doSearch(req.getFormData()));
    }

}