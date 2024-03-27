package com.st_ones.eversrm.system.task.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.task.service.BSYT_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
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
 * @File Name : BSYT_Controller.java
 * @date 2013. 07. 22.
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/task")
public class BSYT_Controller extends BaseController {

    @Autowired
    private BSYT_Service bsytService;
    @Autowired
    private MessageService msg;
    @Autowired
    private CommonComboService commonComboService;

    /**
     * 직무관리/직무별-사용자매핑
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_010/view")
    public String BSYT_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        // 고객사 운영사 관리자 사용메뉴
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/eversrm/system/task/BSYT_010";
    }

    @RequestMapping(value = "selectMappingPlant")
    public void selectMappingPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        resp.setGridObject("grid2", bsytService.selectMappingPlant(gridData));
        resp.setGridObject("grid3", bsytService.selectMappingUser(gridData));
    }

    @RequestMapping(value = "selectTaskCode")
    public void selectTaskCode(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsytService.selectTaskCode(param));
    }

    //직무관리 > 직무-사용자매핑리스트
    @RequestMapping(value = "selectMappingUser_add")
    public void selectMappingUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("gridDT", bsytService.selectMappingUser_add(param));
    }

    //직무관리 >직무사용자저장
    @RequestMapping(value = "/taskCodeList/doSaveTaskUser")
    public void doSaveTaskUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridDT = req.getGridData("gridDT");

        String message[] = bsytService.doSaveTaskUser(form, gridDT);


        resp.setResponseMessage(message[0]);
        resp.setResponseCode("true");
    }

    //직무관리 > 직무사용자삭제
    @RequestMapping(value = "/taskCodeList/doDeleteTaskUser")
    public void doDeleteTaskUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridDT = req.getGridData("gridDT");

        String message[] = bsytService.doDeleteTaskUser(form, gridDT);


        resp.setResponseMessage(message[0]);
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "taskCodeList/saveTaskCode")
    public void saveTaskCode(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsytService.saveTaskCode(gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/taskCodeList/deleteTaskCode")
    public void deleteTaskCode(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsytService.deleteTaskCode(gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "mappingPlantList/savePlant")
    public void saveMappingPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid2");
        String msg = bsytService.saveMappingPlant(gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "mappingPlantList/deletePlant")
    public void deleteMappingPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid2");
        String msg = bsytService.deleteMappingPlant(gridData);

        resp.setResponseMessage(msg);
    }

    /**
     * 사용자별-직무매핑
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_020/view")
    public String BSYT_020(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        /*if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }*/
        //예외로 컨트롤러에 적용
        req.setAttribute("refBuyerCode", commonComboService.getCodesAsJson("CB0002", new HashMap<String, String>()));
        req.setAttribute("refCtrlType", commonComboService.getCodeComboAsJson("M024"));
        return "/eversrm/system/task/BSYT_020";
    }

    @RequestMapping(value = "/taskPersonInCharge/selectTaskPersonInCharge")
    public void selectTaskPersonInCharge(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        makeGridTextLinkStyle(resp, "grid", "CTRL_NM");
        makeGridTextLinkStyle(resp, "grid", "USER_NM");
        resp.setGridObject("grid", bsytService.selectTaskPersonInCharge(param));
    }

    @RequestMapping(value = "/taskPersonInCharge/saveTaskPersonInCharge")
    public void saveTaskPersonInCharge(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsytService.saveTaskPersonInCharge(gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/taskPersonInCharge/deleteTaskPersonInCharge")
    public void deleteTaskPersonInCharge(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsytService.deleteTaskPersonInCharge(gridData);

        resp.setResponseMessage(msg);
    }

    /**
     * 사용자 조회
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_060/view")
    public String BSYT_060(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }

        req.setAttribute("refBuyerCode", commonComboService.getCodesAsJson("CB0002", new HashMap<String, String>()));
        return "/eversrm/system/task/BSYT_060";
    }

    @RequestMapping(value = "/selectUserInCharge")
    public void selectUserInCharge(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsytService.selectUserInCharge(param));
    }

    /**
     * 직무코드조회
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_050/view")
    public String BSYT_050(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }

        req.setAttribute("refBuyerCd", commonComboService.getCodes("CB0002", new HashMap<String, String>()));
        req.setAttribute("refCtrlType", commonComboService.getCodeCombo("M024"));
        return "/eversrm/system/task/BSYT_050";
    }

    @RequestMapping(value = "/selectTaskCodeBySearch")
    public void selectTaskCodeBySearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("grid", bsytService.selectTaskCodeBySearch(param));
    }

    /**
     * 직무-상품분류 Mapping
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_030/view")
    public String BSYT_030(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
            if (baseInfo.getSuperUserFlag().equals("0") || !baseInfo.getUserType().equals(Code.OPERATOR)) {
                return "/eversrm/noSuperAuth";
            }
        }

        Map<String, String> param = new HashMap<String, String>();
        param.put("type", "1");
        req.setAttribute("itemClass1List", commonComboService.getCodesAsJson("CB0012", param));
        req.setAttribute("refBuyerCode", commonComboService.getCodesAsJson("CB0002", new HashMap<String, String>()));
        req.setAttribute("refCtrlType", commonComboService.getCodeCombo("M024"));
        return "/eversrm/system/task/BSYT_030";
    }

    /**
     * 품목분류를 가져오는 공통 서비스
     * 카탈로그 화면에서도 이 서비스를 같이 사용하므로 변경 시 주의!
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "BSYT_030/getItemClassList")
    public void getItemClassList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", UserInfoManager.getUserInfo().getGateCd());
        param.putAll(req.getFormData());
        String itemClassType = req.getParameter("type");
        if (itemClassType.equals("2")) {
            resp.setParameter("itemClassList", commonComboService.getCodesAsJson("CB0005", param));
        } else if (itemClassType.equals("3")) {
            resp.setParameter("itemClassList", commonComboService.getCodesAsJson("CB0006", param));
        } else if (itemClassType.equals("4")) {
            resp.setParameter("itemClassList", commonComboService.getCodesAsJson("CB0007", param));
        }
    }

    @RequestMapping(value = "taskItemMapping/selectTaskItemMapping")
    public void selectTaskItemMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        makeGridTextLinkStyle(resp, "grid", "CTRL_CD");
        resp.setGridObject("grid", bsytService.selectTaskItemMapping(param));
    }

    @RequestMapping(value = "taskItemMapping/saveTaskItemMapping")
    public void saveTaskItemMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsytService.saveTaskItemMapping(gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "taskItemMapping/deleteTaskItemMapping")
    public void deleteTaskItemMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsytService.deleteTaskItemMapping(gridData);

        resp.setResponseMessage(msg);
    }

    /**
     * 사용자 - 플랜트 Mapping
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_070/view")
    public String BSYT_070(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }

        req.setAttribute("refFlant", commonComboService.getCodesAsJson("CB0036", new HashMap<String, String>()));
        return "/eversrm/system/task/BSYT_070";
    }

    @RequestMapping(value = "/BSYT_070/doSearch")
    public void BSYT_070_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsytService.BSYT_070_doSearch(param));
    }

    @RequestMapping(value = "/BSYT_070/doSave")
    public void BSYT_070_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");

        //String returnMsg = bsytService.BSYT_070_doSave(gridData);
        //resp.setResponseMessage(returnMsg);

        bsytService.BSYT_070_doSave(gridData);

        resp.setResponseMessage(msg.getMessage("0031"));
    }

    @RequestMapping(value = "/BSYT_070/doDelete")
    public void BSYT_070_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");

        bsytService.BSYT_070_doDelete(gridData);

        resp.setResponseMessage(msg.getMessage("0017"));
    }

    /**
     * 사용자별-직무매핑 이력
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYT_080/view")
    public String BSYT_080(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }

        req.setAttribute("refBuyerCode", commonComboService.getCodesAsJson("CB0002", new HashMap<String, String>()));

        return "/eversrm/system/task/BSYT_080";
    }

    @RequestMapping(value = "/bsyt080/doSelect")
    public void bsyt080Select(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsytService.bsyt080Select(param));
    }

    //이미지 텍스트그리드
    private void makeGridTextLinkStyle(EverHttpResponse resp, String grid, String columnName) {
        resp.setGridColStyle(grid, columnName, "cursor", "pointer");
        resp.setGridColStyle(grid, columnName, "color", "#000DFF");
        resp.setGridColStyle(grid, columnName, "text-decoration", "underline");
    }

}