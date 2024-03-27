package com.st_ones.evermp.STO.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.STO.service.STO0401_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "evermp/STO")
public class STO0401_Controller extends BaseController {

    @Autowired
    private MessageService msg;

    @Autowired
    private STO0401_Service sto0401_Service;


    /**
     * 재고관리 > 재고수불마감 > 재고수불상세내역 (STO04_050))
     */
    @RequestMapping(value="/STO04_050/view")
    public String STO02_010(EverHttpRequest req) throws Exception {
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }

        return "/evermp/STO/STO04_050";
    }

    @RequestMapping(value = "/STO04_050/sto0405_doSearch")
    public void STO0301_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sto0401_Service.sto0405_doSearch(req.getFormData()));
    }
    /** ****************************************************************************************************************
     * 재고관리 > 재고수불마감 > 재고수불마감(회계) (STO04_020)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/STO04_020/view")
    public String STO04_020(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }
    	req.setAttribute("YYYY", EverDate.getYear());
    	req.setAttribute("MM", EverDate.addDateMonth(EverDate.getDate(),+0).substring(4,6));
    	req.setAttribute("NOWMM", EverDate.addDateMonth(EverDate.getDate(), +0).substring(0,6));

    	return "/evermp/STO/STO04_020";
    }
    //조회
    @RequestMapping(value = "/STO04_020/sto0402_doSearch")
    public void STO0402_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sto0401_Service.sto0402_doSearch(req.getFormData()));
    }
    //마감 실행
    @RequestMapping(value = "/STO04_020/sto0402_doConfirm")
    public void sto0402_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> form = req.getFormData();
    	form.put("NEXT_MONTH",req.getParameter("NEXT_MONTH"));
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String rtnMsg = sto0401_Service.sto0402_doConfirm(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }
    //마감삭제
    @RequestMapping(value="/STO04_020/sto0402_doDelete")
    public void sto0402_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = new HashMap<String, String>();
    	param.put("YEAR_MONTH",req.getParameter("YEAR_MONTH"));
        String returnMsg = sto0401_Service.sto0402_doDelete(param);

        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 재고관리 > 재고수불마감 > 월별 재고수불부
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/STO04_040/view")
    public String STO04_040(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }
    	req.setAttribute("YYYY", EverDate.getYear());
    	req.setAttribute("MM", EverDate.addDateMonth(EverDate.getDate(), +0).substring(4,6));
        return "/evermp/STO/STO04_040";
    }
    //조회
    @RequestMapping(value = "/STO04_040/sto0404_doSearch")
    public void STO0404_doSearch(EverHttpRequest req, EverHttpResponse resp)  throws Exception {
        resp.setGridObject("grid", sto0401_Service.sto0404_doSearch(req.getFormData()));
    }
    //마감
    @RequestMapping(value = "/STO04_040/sto0404_doSave")
    public void STO0404_doSave(EverHttpRequest req, EverHttpResponse resp)  throws Exception {
    	 Map<String, String> param = new HashMap<String, String>();
    	 param.put("RD_DATE",req.getParameter("RD_DATE"));
    	 String regMsg = sto0401_Service.sto0404_doSave(param);
    	 resp.setResponseMessage(regMsg);
    }
    //삭제
    @RequestMapping(value = "/STO04_040/sto0404_doDelete")
    public void sto0404_doDelete(EverHttpRequest req, EverHttpResponse resp)  throws Exception {
    	Map<String, String> param = new HashMap<String, String>();
    	param.put("RD_DATE",req.getParameter("RD_DATE"));
    	String regMsg = sto0401_Service.sto0404_doDelete(param);
    	resp.setResponseMessage(regMsg);
    }
    /** ****************************************************************************************************************
     * 재고관리 > 재고수불마감 > 기간별 재고수불부
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/STO04_010/view")
    public String STO04_010(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }
    	 req.setAttribute("addFromDate", EverDate.getDate());
         return "/evermp/STO/STO04_010";
    }
    //조회
    @RequestMapping(value = "/STO04_010/sto0401_doSearch")
    public void STO0401_doSearch(EverHttpRequest req, EverHttpResponse resp)  throws Exception {

       resp.setGridObject("grid", sto0401_Service.sto0401_doSearch(req.getFormData()));
    }
    /** ****************************************************************************************************************
     * 재고관리 > 재고수불마감 > 재고수불마감 상세 (STO04_030)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/STO04_030/view")
    public String STO04_030(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }

       req.setAttribute("YYYY", EverDate.getYear());
       req.setAttribute("MM", EverDate.addDateMonth(EverDate.getDate(), -1).substring(4,6));

    	return "/evermp/STO/STO04_030";

    }
    //조회
    @RequestMapping(value = "/STO04_030/sto0403_doSearch")
    public void STO0403_doSearch(EverHttpRequest req, EverHttpResponse resp)  throws Exception {

    	resp.setGridObject("grid", sto0401_Service.sto0403_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 재고관리 >  VMI기간별 재고수불부
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/STO04_010P01/view")
    public String STO04_010P01(EverHttpRequest req) throws Exception {

    	 req.setAttribute("addFromDate", EverDate.getDate());
         return "/evermp/STO/STO04_010P01";
    }
    //조회
    @RequestMapping(value = "/STO04_010P01/sto0401p01_doSearch")
    public void STO0401P01_doSearch(EverHttpRequest req, EverHttpResponse resp)  throws Exception {

       resp.setGridObject("grid", sto0401_Service.sto0401p01_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 재고관리 >  입출고내역조회(공급사)
    * @param req
     * @return
     * @throws Exception
     */

    @RequestMapping(value="/STO04_060/view")
    public String STO04_060(EverHttpRequest req) throws Exception {
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());

        return "/evermp/STO/STO04_060";
    }

    @RequestMapping(value = "/STO04_060/sto0406_doSearch")
    public void STO0406_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sto0401_Service.sto0406_doSearch(req.getFormData()));
    }
}
