package com.st_ones.eversrm.system.docNo.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.docNo.service.BSYD_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
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
 * @File Name : BSYD_Controller.java
 * @date 2013. 07. 22.
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/docNo")
public class BSYD_Controller extends BaseController {

    @Autowired
    private BSYD_Service bsyd_Service;

    /**
     * 문서번호채번관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYD_010/view")
    public String BSYD_010(EverHttpRequest req) throws Exception {

        /* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }
        return "/eversrm/system/docNo/BSYD_010";
    }

    @RequestMapping(value = "/doSearch")
    public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsyd_Service.doSearch(param));
    }

    @RequestMapping(value = "/doSave")
    public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsyd_Service.doSave(gridData);
        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/doDelete")
    public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsyd_Service.doDelete(gridData);
        resp.setResponseMessage(msg);

    }

}