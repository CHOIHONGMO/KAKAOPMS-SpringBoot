package com.st_ones.eversrm.system.env.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.env.service.BSYE_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @version 1.0
 * @File Name : BSYE_Controller.java
 * @date 2013. 07. 22.
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/env")
public class BSYE_Controller extends BaseController {

    @Autowired
    private BSYE_Service bsye_Service;

    @Autowired
    private CommonComboService commonComboService;
    
    /**
     * 환경설정
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYE_010/view")
    public String environmentSetup(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
            return "/eversrm/noSuperAuth";
        }

        req.setAttribute("refOrganizationScale", commonComboService.getCodeComboAsJson("M010"));
        return "/eversrm/system/env/BSYE_010";
    }

    @RequestMapping(value = "/BSYE_020/view")
    public String environmentSetup_PurOrganizationPopup() throws Exception {
        return "/eversrm/system/env/BSYE_020";
    }

    @RequestMapping(value = "/environmentSetup_HousePopup/view")
    public String environmentSetup_HousePopup() throws Exception {
        return "/eversrm/system/env/environmentSetup_HousePopup";
    }

    @RequestMapping(value = "/environmentSetup_CompanyPopup/view")
    public String environmentSetup_CompanyPopup() throws Exception {
        return "/eversrm/system/env/environmentSetup_CompanyPopup";
    }

    @RequestMapping(value = "/environmentSetup_PurOrgPopup/view")
    public String environmentSetup_PurOrgPopup() throws Exception {
        return "/eversrm/system/env/environmentSetup_PurOrgPopup";
    }

    @RequestMapping(value = "/environmentSetup_PlantPopup/view")
    public String environmentSetup_PlantPopup() throws Exception {
        return "/eversrm/system/env/environmentSetup_PlantPopup";
    }

    @RequestMapping(value = "/environmentSetup_HousePopup/doSearchHouse")
    public void doSearchHouse(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsye_Service.selectHouse(param));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/environmentSetup_CompanyPopup/doSearchCompany")
    public void doSearchCompany(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsye_Service.searchCompany(param));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/environmentSetup_PurOrganizationPopup/doSelectPurOrganization")
    public void doSelectPurOrganization(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsye_Service.doSelectPurOrganization(param));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/environmentSetup_PlantPopup/doSelectPlant")
    public void doSelectPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsye_Service.doSelectPlant(param));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/environmentSetup/searchEnvironment")
    public void searchEnvironment(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsye_Service.doSearchEnv(param));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/environmentSetup/saveEnvironment")
    public void saveEnvironment(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String msg = bsye_Service.saveEnvironment(req.getGridData("grid"));

        resp.setResponseMessage(msg);
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/environmentSetup/deleteEnvironment")
    public void deleteEnvironment(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String msg = bsye_Service.deleteEnvironment(req.getGridData("grid"));

        resp.setResponseMessage(msg);
        resp.setResponseCode("true");

    }

}