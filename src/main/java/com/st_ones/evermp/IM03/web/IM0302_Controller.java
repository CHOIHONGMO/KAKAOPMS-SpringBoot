package com.st_ones.evermp.IM03.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM03.service.IM0302_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM03/IM0302")
public class IM0302_Controller extends BaseController {

    @Autowired
    IM0302_Service im0302Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;

    /** ****************************************************************************************************************
     * 독점품목관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_030/view")
    public String IM01_030(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_030";
    }


    @RequestMapping(value = "/im01030_doSearch")
    public void im01030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0302Service.im01030_doSearch(req.getFormData()));
    }


    //독점품목저장
    @RequestMapping(value="/im01030_doSave")
    public void im01030_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0302Service.im01030_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    //독점품목삭제
    @RequestMapping(value="/im01030_doDelete")
    public void im01030_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0302Service.im01030_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 동의/유사어 관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_020/view")
    public String IM03_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());

    	return "/evermp/IM03/IM03_020";
    }

    // 동의/유사어 조회
    @RequestMapping(value = "/im03020_doSearch")
    public void im03020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0302Service.im03020_doSearch(req.getFormData()));
    }

    // 동의/유사어 저장
    @RequestMapping(value="/im03020_doSave")
    public void im03020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0302Service.im03020_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    // 동의/유사어 삭제
    @RequestMapping(value="/im03020_doDelete")
    public void im03020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0302Service.im03020_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * MySite 관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_050/view")
    public String IM01_050(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_050";
    }

    @RequestMapping(value = "/im01050_doSearch")
    public void im01050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0302Service.im01050_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/im01050_doSearchDp")
    public void im01050_doSearchDp(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridDp", im0302Service.im01050_doSearchDp(req.getFormData()));
    }

    // mysite저장
    @RequestMapping(value="/im01050_doSave")
    public void im01050_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0302Service.im01050_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    // mysite삭제
    @RequestMapping(value="/im01050_doDelete")
    public void im01050_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0302Service.im01050_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    // mysite 부서별 저장
    @RequestMapping(value="/im01050_doSaveDp")
    public void im01050_doSaveDp(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridList = req.getGridData("gridDp");
        String returnMsg = im0302Service.im01050_doSaveDp(gridList);

        resp.setResponseMessage(returnMsg);
    }

    // mysite 부서별 삭제
    @RequestMapping(value="/im01050_doDeleteDp")
    public void im01050_doDeleteDp(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridList = req.getGridData("gridDp");
        String returnMsg = im0302Service.im01050_doDeleteDp(gridList);

        resp.setResponseMessage(returnMsg);
    }

}