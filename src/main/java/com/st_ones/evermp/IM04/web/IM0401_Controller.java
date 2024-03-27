package com.st_ones.evermp.IM04.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM04.service.IM0401_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM04/IM0401")
public class IM0401_Controller extends BaseController {

    @Autowired
    IM0401_Service im0401Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 품목분류 현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM04_001/view")
    public String IM04_001(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	req.setAttribute("keyRule", PropertiesManager.getString("eversrm.item.type.management.rule"));
        return "/evermp/IM04/IM04_001";
    }

    @RequestMapping(value = "/IM04_001/im04001_selectItemClass")
    public void selectItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> result = im0401Service.selectItemClass(param);

        resp.setGridObject("grid1", result);

        ObjectMapper om = new ObjectMapper();
        String jsonStr = om.writeValueAsString(result);
        resp.setParameter("refItemList", jsonStr);
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/IM04_001/im04001_selectChildClass")
    public void selectChildClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        String itemClassType = param.get("ITEM_CLS_TYPE_CLICKED");
        if (itemClassType.equals("C1")) {
            resp.setGridObject("grid2", im0401Service.selectChildClass(param));
        } else if (itemClassType.equals("C2")) {
            resp.setGridObject("grid3", im0401Service.selectChildClass(param));
        } else if (itemClassType.equals("C3")) {
            resp.setGridObject("grid4", im0401Service.selectChildClass(param));
        }

        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/IM04_001/im04001_saveItemClass")
    public void saveItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = new ArrayList<Map<String, Object>>();

        String classToSave = req.getParameter("CLASS_TO_SAVE");
        if (classToSave.equals("C1")) {
            gridData = req.getGridData("grid1");
        } else if (classToSave.equals("C2")) {
            gridData = req.getGridData("grid2");
        } else if (classToSave.equals("C3")) {
            gridData = req.getGridData("grid3");
        } else if (classToSave.equals("C4")) {
            gridData = req.getGridData("grid4");
        }

        String message = im0401Service.saveItemClass(gridData);
        resp.setResponseMessage(message);
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/IM04_001/im04001_deleteItemClass")
    public void deleteItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = new ArrayList<Map<String, Object>>();

        String classToDelete = req.getParameter("CLASS_TO_DELETE");
        if (classToDelete.equals("C1")) {
            gridData = req.getGridData("grid1");
        } else if (classToDelete.equals("C2")) {
            gridData = req.getGridData("grid2");
        } else if (classToDelete.equals("C3")) {
            gridData = req.getGridData("grid3");
        } else if (classToDelete.equals("C4")) {
            gridData = req.getGridData("grid4");
        }

        String message = im0401Service.deleteItemClass(gridData);
        resp.setResponseMessage(message);
        resp.setResponseCode("true");
    }
}