package com.st_ones.evermp.BOD1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BOD1.service.BOD101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BOD1/BOD101")
public class BOD106_Controller extends BaseController {

	@Autowired private BOD101_Service bod101Service;
	@Autowired private CommonComboService commonComboService;
	@Autowired private MessageService msg;

	@RequestMapping(value="/BOD1_110/view")
	public String BOD1_110(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
	  	       return "/eversrm/noSuperAuth";
	  	      }
        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -3));
        req.setAttribute("END_DATE", EverDate.getDate());

		return "/evermp/BOD1/BOD1_110";
	}

    @RequestMapping(value = "/bod1110Dosearch")
    public void py01020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bod101Service.bod1110Dosearch(req.getFormData()));
    }


	@RequestMapping(value="/BOD1_111/view")
	public String BOD1_111(EverHttpRequest req) throws Exception {
        req.setAttribute("TO_DAY", EverDate.getDate());
        String cpo_no = req.getParameter("CPO_NO");
        String cust_cd = req.getParameter("CUST_CD");
        Map<String,String> param = new HashMap<String,String>();
        param.put("CPO_NO",cpo_no);
        param.put("CUST_CD",cust_cd);
        req.setAttribute("form",bod101Service.getBackMaster(param));
        return "/evermp/BOD1/BOD1_111";
	}

    @RequestMapping(value = "/bod1111Dosearch")
    public void bod1111Dosearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bod101Service.bod1111Dosearch(req.getFormData()));
    }




    @RequestMapping(value = "/doBack")
    public void od01001_doPoConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        String msg = bod101Service.doBack(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }






	@RequestMapping(value="/BOD1_120/view")
	public String BOD1_120(EverHttpRequest req) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType()) ) {
	  	       return "/eversrm/noSuperAuth";
	  	      }
        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -3));
        req.setAttribute("END_DATE", EverDate.getDate());
		return "/evermp/BOD1/BOD1_120";
	}

    @RequestMapping(value = "/bod1120Dosearch")
    public void bod1120Dosearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bod101Service.bod1120Dosearch(req.getFormData()));
    }







    @RequestMapping(value = "/doBackCancel")
    public void doBackCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        String msg = bod101Service.doBackCancel(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }


    @RequestMapping(value = "/doBackAgree")
    public void doBackAgree(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        String msg = bod101Service.doBackAgree(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }








}
