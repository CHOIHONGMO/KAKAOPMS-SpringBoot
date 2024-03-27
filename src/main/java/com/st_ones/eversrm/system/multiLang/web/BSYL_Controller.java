package com.st_ones.eversrm.system.multiLang.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.multiLang.service.BSYL_Service;
import org.apache.commons.lang3.text.WordUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
 * @File Name : BSYL_Controller.java
 * @date 2013. 07. 22.
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/multiLang")
public class BSYL_Controller extends BaseController {

    @Autowired
    private BSYL_Service bsyl_Service;

    @Autowired
    private CommonComboService commonComboService;

    /**
     * 화면속성관리
     * @param resp
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYL_020/view")
    public String BSYL_020(EverHttpRequest resp) throws Exception {
        /* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            BaseInfo baseInfo = (BaseInfo) resp.getSession().getAttribute("ses");
            if (baseInfo.getSuperUserFlag().equals("0")) {
                return "/eversrm/noSuperAuth";
            }
        }
        return "/eversrm/system/multiLang/BSYL_020";
    }

    @RequestMapping(value = "/doSearch")
    public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String tagGuide = "";
        Map<String, String> param = req.getFormData();
        param.put("ANOTHER_LANG", req.getParameter("anotherLangVal"));

        List<Map<String, Object>> gridDatas = bsyl_Service.doSearch(param);
        for (Map<String, Object> gridData : gridDatas) {
            final String columnType = (String) gridData.get("COLUMN_TYPE");

            if (!gridData.get("MULTI_TYPE").equals("F") || EverString.isEmpty(columnType)) {
                continue;
            }

            final String searchConditionFlag = (String) gridData.get("SEARCH_CONDITION_FLAG");
            final String columnId = (String) gridData.get("COLUMN_ID");
            final String formGridId = (String) gridData.get("FORM_GRID_ID");
            final String disableFlag = (String) gridData.get("DISABLE_FLAG");
            final String formId = formGridId + "_" + columnId;

            if (columnType.equals("text")) {

                tagGuide = String.format("<e:label for=\"%s\" title=\"${%s_N}\" />\n"
                                + "<e:field>\n"
                                + "<e:inputText id=\"%s\" name=\"%s\" value=\"\" width=\"${%s_W}\" maxLength=\"${%s_M}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" />\n"
                                + "</e:field>"
                        , columnId, formId
                        , columnId, columnId, formId, formId, formId, formId, formId);
            } else if (columnType.equals("textarea")) {
                tagGuide = String.format("<e:label for=\"%s\" title=\"${%s_N}\"/>\n"
                                + "<e:field>\n"
                                + "<e:textArea id=\"%s\" name=\"%s\" value=\"\" height=\"100px\" width=\"${%s_W}\" maxLength=\"${%s_M}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" />\n"
                                + "</e:field>\n"
                        , columnId, formId
                        , columnId, columnId, formId, formId, formId, formId, formId);
            } else if (columnType.equals("search")) {
                tagGuide = String.format("<e:label for=\"%s\" title=\"${%s_N}\"/>\n"
                                + "<e:field>\n"
                                + "<e:search id=\"%s\" name=\"%s\" value=\"\" width=\"${%s_W}\" maxLength=\"${%s_M}\" onIconClick=\"${%s_RO ? 'everCommon.blank' : ''}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" />\n"
                                + "</e:field>\n"
                        , columnId, formId
                        , columnId, columnId, formId, formId, formId, formId, formId, formId);
            } else if (columnType.equals("search") && searchConditionFlag.equals("0")) {
                tagGuide = String.format("<e:select id=\"st_%s\" name=\"st_%s\" value=\"${st_default}\" width=\"${everMultiWidth}\" readOnly=\"false\" disabled=\"false\" required=\"false\" options=\"${searchTerms}\" visible=\"${everMultiVisible}\" />\n"
                                + "<e:search id=\"%s\" name=\"%s\" value=\"\" width=\"${%s_W}\" maxLength=\"${%s_M}\" onIconClick=\"${%s_RO ? 'everCommon.blank' : ''}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" />\n"
                        , columnId, columnId
                        , columnId, columnId, formId, formId, formId, formId, formId, formId);
            } else if (columnType.equals("date") || columnType.equals("customdate")) {
                tagGuide = String.format("<e:label for=\"%s\" title=\"${%s_N}\"/>\n"
                                + "<e:field>\n"
                                + "<e:inputDate id=\"%s\" name=\"%s\" value=\"\" width=\"${inputDateWidth}\" datePicker=\"true\" required=\"${%s_R}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" />\n"
                                + "</e:field>\n"
                        , columnId, formId
                        , columnId, columnId, formId, formId, formId);
            } else if ((columnType.equals("date") || columnType.equals("customdate")) && disableFlag.equals("0")) {
                tagGuide = String.format("<e:inputDate id=\"%s\" name=\"%s\" value=\"\" width=\"${%s_W}\" datePicker=\"true\" required=\"${%s_R}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" />\n"
                        , columnId, columnId, formId, formId, formId, formId);
            } else if (columnType.equals("number")) {
                tagGuide = String.format("<e:label for=\"%s\" title=\"${%s_N}\"/>\n"
                                + "<e:field>\n"
                                + "<e:inputNumber id=\"%s\" name=\"%s\" value=\"\" width=\"${%s_W}\" maxValue=\"${%s_M}\" decimalPlace=\"${%s_NF}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" />\n"
                                + "</e:field>\n"
                        , columnId, formId
                        , columnId, columnId, formId, formId, formId, formId, formId, formId);
            } else if (columnType.equals("number") && searchConditionFlag.equals("0")) {
                tagGuide = String.format("<e:inputNumber id=\"%s\" name=\"%s\" value=\"\" width=\"${%s_W}\" maxValue=\"${%s_M}\" decimalPlace=\"${%s_NF}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" />\n"
                        , columnId, columnId, formId, columnId, formId, formId, formId, formId, formId);

            } else if (columnType.equals("combo")) {

                String tempColId = WordUtils.capitalizeFully(columnId.replaceAll("_", " ")).replaceAll(" ", "");
                String colOptions = tempColId.substring(0, 1).toLowerCase() + tempColId.substring(1, tempColId.length()) + "Options";

                tagGuide = String.format("<e:label for=\"%s\" title=\"${%s_N}\"/>\n"
                                + "<e:field>\n"
                                + "<e:select id=\"%s\" name=\"%s\" value=\"\" options=\"${" + colOptions + "}\" width=\"${%s_W}\" disabled=\"${%s_D}\" readOnly=\"${%s_RO}\" required=\"${%s_R}\" placeHolder=\"\" />\n"
                                + "</e:field>"
                        , columnId, formId
                        , columnId, columnId, formId, formId, formId, formId);
            } else if (columnType.equals("checkbox")) {

            }
            if (EverString.isNotEmpty(tagGuide)) {
                gridData.put("TAG_GUIDE", tagGuide);
            }
        }
        resp.setGridObject("jqGrid", gridDatas);
    }

    @RequestMapping(value = "/doSave")
    public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("jqGrid");
        String msg = bsyl_Service.doSave(gridData);
        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/doDelete")
    public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("jqGrid");
        String msg = bsyl_Service.doDelete(gridData);
        resp.setResponseMessage(msg);

    }

    @RequestMapping(value = "/BSYL_021/view")
    public String BSYL_021(EverHttpRequest resp) throws Exception {
        return "/eversrm/system/multiLang/BSYL_021";
    }

    /**
     * 다국어팝업
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYL_040/view")
    public String BSYL_040(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
            if (baseInfo.getSuperUserFlag().equals("0")) {
                return "/everqis/noSuperAuth";
            }
        }

        return "/eversrm/system/multiLang/BSYL_040";
    }

    @RequestMapping(value = "/doSearchWord")
    public void doSearchWord(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bsyl_Service.doSearchWord(param));

    }

    @RequestMapping(value = "/doChoiceDomain")
    public void doChoiceDomain(EverHttpResponse resp, @RequestParam(value = "searchWord") String searchWord) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        Map<String, Object> result = new HashMap<String, Object>();
        param.put("SEARCH_WORD", searchWord);
        param.put("st_SEARCH_WORD", "L");

        param.put("OWNER", PropertiesManager.getString("eversrm.system.database.owner"));
        List<Map<String, Object>> dataLengthData = bsyl_Service.doSearchDataLength(param);

        Object dataLength = null;
        String dataLengthMsg = "";
        int dataCnt = dataLengthData.size();
        if (dataCnt == 1) {
            dataLength = dataLengthData.get(0).get("DATA_LENGTH");
        } else if (dataCnt > 1) {
            dataLength = dataLengthData.get(0).get("DATA_LENGTH");
            dataLengthMsg = "[해당 컬럼에 대한 Data Length 정보입니다.]";
            for (Map<String, Object> tmpMap : dataLengthData) {
                dataLengthMsg = dataLengthMsg + "@@" + tmpMap.get("TABLE_NAME") + " : " + tmpMap.get("DATA_TYPE") + "(" + tmpMap.get("DATA_LENGTH") + ")";
            }
        }

        List<Map<String, Object>> domainData = bsyl_Service.doSearchDOMC(param);

        Map<String, String> mostUsedWord = bsyl_Service.getMostUsedWord(param);
        resp.setParameter("mostUsedWord", new ObjectMapper().writeValueAsString(mostUsedWord));

        // 입력한 Column ID에 대한 Domain이 STCODOMC Table에 1건 있으므로 그리드에 바로 Setting 한다.
        if (domainData.size() == 1) {

            result = domainData.get(0);
            result.put("FORMAT", result.get("FORMAT"));
            result.put("DOMAIN_TYPE", result.get("DOMAIN_TYPE"));
            result.put("DOMAIN_NM", result.get("DOMAIN_NM"));
            result.put("DATA", result.get("DATA"));
            result.put("DATA_TYPE", result.get("PRE_FORMAT"));
            result.put("DATA_LENGTH", dataLength != null ? dataLength : result.get("DATA_LENGTH"));
            result.put("PRE_FORMAT", result.get("PRE_FORMAT"));
            result.put("ALIGNMENT", result.get("ALIGNMENT"));
            result.put("COL_WIDTH", result.get("COL_WIDTH"));
            result.put("COL_TYPE", result.get("COL_TYPE"));
            result.put("COMMON_ID", result.get("COMMON_ID"));

            ObjectMapper om = new ObjectMapper();
            resp.setParameter("openFlag", "N");
            resp.setParameter("domainData", om.writeValueAsString(result));

        } else if (domainData.size() >= 1) { // STCODOMC Table에서 여러건이 나왔으므로, STCODOMA Table을 조회한다.

            domainData.clear();
            domainData = bsyl_Service.doSearchWord(param);

            // 입력한 Column ID에 대한 Domain이 STCODOMA Table에 1건 있으므로 그리드에 바로 Setting 한다.
            if (domainData.size() == 1) {

                result = domainData.get(0);
                result.put("FORMAT", result.get("FORMAT"));
                result.put("DOMAIN_TYPE", result.get("DOMAIN_TYPE"));
                result.put("DOMAIN_NM", result.get("DOMAIN_NM"));
                result.put("DATA", result.get("DATA"));
                result.put("DATA_TYPE", result.get("PRE_FORMAT"));
                result.put("DATA_LENGTH", dataLength != null ? dataLength : result.get("DATA_LENGTH"));
                result.put("PRE_FORMAT", result.get("PRE_FORMAT"));
                result.put("ALIGNMENT", result.get("ALIGNMENT"));
                result.put("COL_WIDTH", result.get("COL_WIDTH"));
                result.put("COL_TYPE", result.get("COL_TYPE"));
                result.put("MULTI_CONTENTS", result.get("DOMAIN_DESC"));
                result.put("COMMON_ID", result.get("COMMON_ID"));

                ObjectMapper om = new ObjectMapper();
                resp.setParameter("openFlag", "N");
                resp.setParameter("domainData", om.writeValueAsString(result));

            } else if (domainData.size() > 1) { // 입력한 Column ID에 대한 Domain이 STCODOMA Table에 여러건 있으므로 Popup창을 띄운다.

                resp.setParameter("openFlag", "Y");
                resp.setParameter("domainData", searchWord);

            }

        } else {

            // STCODOMC Table에서 조회된 건이 없으므로, STCODOMA Table을 조회한다.
            domainData.clear();
            domainData = bsyl_Service.doSearchWord(param);

            // STCODOMC Table에는 없으나, STCODOMA Table에는 1건 있으므로 Grid에 바로 Setting 한다.
            if (domainData.size() > 0) {

                result = domainData.get(0);
                result.put("FORMAT", result.get("FORMAT"));
                result.put("DOMAIN_TYPE", result.get("DOMAIN_TYPE"));
                result.put("DOMAIN_NM", result.get("DOMAIN_NM"));
                result.put("DATA", result.get("DATA"));
                result.put("DATA_TYPE", result.get("PRE_FORMAT"));
                result.put("DATA_LENGTH", dataLength != null ? dataLength : result.get("DATA_LENGTH"));
                result.put("PRE_FORMAT", result.get("PRE_FORMAT"));
                result.put("ALIGNMENT", result.get("ALIGNMENT"));
                result.put("COL_WIDTH", result.get("COL_WIDTH"));
                result.put("COL_TYPE", result.get("COL_TYPE"));
                result.put("COMMON_ID", result.get("COMMON_ID"));

                ObjectMapper om = new ObjectMapper();
                resp.setParameter("openFlag", "N");
                resp.setParameter("domainData", om.writeValueAsString(result));

            } else { // STCODOMC, STCODOMA Table 모두 조회된 값이 없으므로 Domain을 검색할 수 있는 Popup창을 띄운다.

                resp.setParameter("openFlag", "Y");
                resp.setParameter("domainData", "");

            }
        }
        resp.setParameter("dataLengthMsg", dataLengthMsg);
    }

    /**
     * 다국어팝업
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BSYL_030/view")
    public String BSYL_030(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
            if (baseInfo.getSuperUserFlag().equals("0")) {
                return "/everqis/noSuperAuth";
            }
        }

        Map<String, String> parameters = reqParamMapToStringMap(req.getParameterMap());
        String multi_nm = getMultiName(parameters.get("multi_cd"));
        parameters.put("multi_nm", multi_nm);
        req.setAttribute("searchParam", parameters);
        return "/eversrm/system/multiLang/BSYL_030";
    }

    /**
     * @param multi_cd
     * @return 화면명: SC
     * 템플릿그룹: TG
     * 권한: AU
     * 화면액션: SA
     * 메뉴그룹: MG
     * 메뉴템플릿: MT
     * 액션프로파일: AP:
     * @throws Exception
     */
    private String getMultiName(String multi_cd) throws Exception {
        List<Map<String, String>> multiNameList = commonComboService.getCodeCombo("M048");
        String multi_name_value = null;
        for (Map<String, String> map : multiNameList) {
            if (map.get("value").equals(multi_cd)) {
                multi_name_value = map.get("text");
            }
        }
        return multi_name_value;
    }

    @RequestMapping(value = "/multiLanguagePopup/doSearch")
    public void multiLanguagePopupDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        //Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = bsyl_Service.getMultiLanguageList(param);
        resp.setGridObject("grid", gridData);
        resp.setResponseMessage("success");
    }

    @RequestMapping(value = "/multiLanguagePopup/doSave")
    public void multiLanguagePopupDoSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> searchParm = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsyl_Service.multiLanguagePopupDoSave(searchParm, gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/multiLanguagePopup/doDelete")
    public void multiLanguagePopupDoDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDataParam = req.getGridData("grid");
        String msg = bsyl_Service.doDeletePopup(gridDataParam);
        resp.setResponseMessage(msg);

        resp.getWriter().println();
    }

    @RequestMapping(value = "/BSYL_050/view")
    public String BSYL_050(EverHttpRequest req) throws Exception {
        return "/eversrm/system/multiLang/BSYL_050";
    }

    @RequestMapping(value = "/BSYL_050/doSearch")
    public void bsyl050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridData = bsyl_Service.bsyl050_getScreenAuth(formData);
        resp.setGridObject("grid", gridData);
        resp.setResponseMessage("success");
    }

    @RequestMapping(value = "/BSYL_050/doSave")
    public void bsyl050_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("grid");
        String msg = bsyl_Service.bsyl050_doSave(formData, gridData);

        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/BSYL_050/doDelete")
    public void bsyl050_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridDataParam = req.getGridData("grid");
        String msg = bsyl_Service.bsyl050_doDelete(formData, gridDataParam);
        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/BSYL021_doSearch")
    public void BSYL021_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bsyl_Service.BSYL021_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/BSYL021_doSearchSub")
    public void BSYL021_doSearchSub(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridSub", bsyl_Service.BSYL021_doSearchSub(req.getFormData()));
    }

    @RequestMapping(value = "/BSYL021_doSave")
    public void BSYL021_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("gridSub");
        bsyl_Service.BSYL021_doSave(gridData, param);
    }

    @RequestMapping(value = "/BSYL021_doDelete")
    public void BSYL021_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("gridSub");

        bsyl_Service.BSYL021_doDelete(gridData);

    }

    @RequestMapping(value = "/BSYL021_doReset")
    public void BSYL021_doReset(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("gridSub");

        bsyl_Service.BSYL021_doReset(gridData, param);

    }

    @RequestMapping(value = "/BSYL_022/view")
    public String BSYL_022(EverHttpRequest resp) throws Exception {

        return "/eversrm/system/multiLang/BSYL_022";
    }

    @RequestMapping(value = "/BSYL_022_doSearch")
    public void BSYL_022_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();

        List<Map<String, Object>> gridData = bsyl_Service.BSYL_022_doSearch(formData);
        resp.setGridObject("grid", gridData);
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/BSYL_022_doSave")
    public void BSYL_022_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        bsyl_Service.BSYL_022_doSave(gridData);

        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/BSYL_022_doDelete")
    public void BSYL_022_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        bsyl_Service.BSYL_022_doDelete(gridData);

        resp.setResponseCode("true");
    }
}