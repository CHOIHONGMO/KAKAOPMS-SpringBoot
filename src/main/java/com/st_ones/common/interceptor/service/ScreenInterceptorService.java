package com.st_ones.common.interceptor.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.cache.data.*;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.generator.domain.GridMeta;
import com.st_ones.common.generator.service.GridGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoScreenIdException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;
import org.mybatis.spring.MyBatisSystemException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import java.util.*;

import static com.st_ones.everf.serverside.info.UserInfoManager.getUserInfo;

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
 * @File Name : ScreenInterceptorService.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "screenInterceptorService")
@Scope("prototype")
public class ScreenInterceptorService extends BaseService {

    @Autowired
    MessageService messageService;
    @Autowired
    ScrnCache scrnCache;
    @Autowired
    FormInfoCache formInfoCache;
    @Autowired
    ColumnInfoCache columnInfoCache;
    @Autowired
    ButtonInfoCache buttonInfoCache;
    @Autowired
    BreadCrumbCache breadCrumbCache;
    @Autowired
    MulgPopupNameCache mulgPopupNameCache;
    @Autowired
    MulgMtCache mulgMtCache;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    GridGenService gridGenService;

    Logger logger = LoggerFactory.getLogger(ScreenInterceptorService.class);

    public void checkScreenURL(String screenURL) throws Exception {
        if (!screenURL.contains("view.so")) {
            return;
        } else if (!scrnCache.hasScreenId(screenURL)) {
            throw new NoScreenIdException(messageService.getMessageForService(this, "exception_msg") + " url: " + screenURL);
        }
    }

    public String getScreenId(String screenURL) throws Exception {
        return scrnCache.getScreenIdByURL(screenURL);
    }

    @SuppressWarnings("unused")
    public Map<String, String> getBreadCrumbs(String screenId, String moduleType, boolean popupFlag, String viewName, boolean detailView, String tmpl_menu_cd, String paramScreenName) throws Exception {

        String langCd = getUserInfo().getLangCd();
        String grantedAuthCd = getUserInfo().getGrantedAuthCd();
        Map<String, String> map = new HashMap<String, String>();
        List<String> screenNameList = breadCrumbCache.getData(screenId, moduleType, grantedAuthCd, langCd);
        Map<String, String> screenNameAndBreadCrumb = new HashMap<String, String>();

        try {

            if (tmpl_menu_cd == null || true == popupFlag) {
                screenNameAndBreadCrumb = getBreadCrumbs(screenId, popupFlag, screenNameList, detailView);
            } else {
				/*for(int k = 0; k < screenNameList.size(); k++) {
					if (tmpl_menu_cd.equals(  screenNameList.get(k)  )) {
						List<String> mm = new ArrayList<String>();
						mm.add(tmpl_menu_cd);
						screenNameAndBreadCrumb = getBreadCrumbs(screenId, popupFlag, mm, detailView);
					}
				}*/
                screenNameAndBreadCrumb = getBreadCrumbs(screenId, popupFlag, screenNameList, detailView);
            }

        } catch (MyBatisSystemException e) {
            logger.error("Error in STOCMULG: " + e.getMessage());
        }

        // Screen Full Name 받아오기
        Map<String, String> fullMenuNm = scrnCache.getFullMenuNm(tmpl_menu_cd);

        String screenName = screenNameAndBreadCrumb.get("screenName");
        String fullScreenName = screenNameAndBreadCrumb.get("screenName");

        if (EverString.isNotEmpty(paramScreenName)) {
            if (fullMenuNm != null) {
                fullScreenName = fullMenuNm.get("MODULE_NM") + " > " + fullMenuNm.get("HIGH_TMPL_MENU_NM") + " > " + paramScreenName;
            } else {
                fullScreenName = paramScreenName;
            }

            // 기존 경로 포함 안함
            screenName = paramScreenName;
        }

        if (PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            fullScreenName = fullScreenName + " (" + screenId + ")";
            screenName = screenName + " (" + screenId + ")";
        }

        map.put("screenName", screenName);
        map.put("fullScreenName", fullScreenName);
        map.put("labelNarrowWidth", PropertiesManager.getString("eversrm.style.labelNarrowWidth"));
        map.put("breadCrumb", screenNameAndBreadCrumb.get("breadCrumb"));
        map.put("breadCrumbHeight", "8"); // screen Path's field height
        map.put("breadCrumbFontColor", "blue"); // screen Path's font color
        map.put("breadCrumbFontStyle", " "); // screen Path's font style

        return map;
    }

    public Map<String, String> getBreadCrumbs(String screenId, boolean popupFlag, List<String> screenNameList, boolean detailView) throws Exception {

        StringBuffer breadCrumbs = new StringBuffer();
        Map<String, String> screenNameAndBreadCrumb = new HashMap<String, String>();
        int screenNameListSize = screenNameList.size();

        if ((!popupFlag) && (screenNameListSize != 0)) {

			/*breadCrumbs.append(mulgMtCache.getData(screenNameList.get(0)));
			for(int i=1; i < screenNameListSize-1; i++){
				breadCrumbs.append(" > ");
				breadCrumbs.append(mulgMtCache.getData(screenNameList.get(i)));
			}*/

            for (int i = 0; i < screenNameListSize; i++) {
                breadCrumbs.append(mulgMtCache.getData(screenNameList.get(i)));

                if (screenNameListSize != (i + 1)) {
                    breadCrumbs.append(" > ");
                }
            }
            screenNameAndBreadCrumb.put("screenName", mulgMtCache.getData(screenNameList.get(screenNameListSize - 1)));
            screenNameAndBreadCrumb.put("breadCrumb", breadCrumbs.toString());
            return screenNameAndBreadCrumb;
        }

        String SCREEN_NAME_CD = "SC";
        if (!detailView) {
            screenNameAndBreadCrumb.put("screenName", mulgPopupNameCache.getData(screenId, SCREEN_NAME_CD));
            return screenNameAndBreadCrumb;
        }

        String popupName = mulgPopupNameCache.getData(screenId, "SCP");

        if (EverString.isEmpty(popupName)) {
            popupName = mulgPopupNameCache.getData(screenId, SCREEN_NAME_CD);
            screenNameAndBreadCrumb.put("screenName", popupName);
        } else {
            screenNameAndBreadCrumb.put("screenName", popupName);
        }
        return screenNameAndBreadCrumb;
    }

    public Map<String, String> getButtonInfo(EverHttpRequest req, String screenId, boolean detailView, boolean popupFlag) throws Exception {

        Map<String, String> buttonInfoMap = new HashMap<String, String>();


        if (req.getSession(false) == null) return buttonInfoMap;

        UserInfo userInfo = (UserInfo) req.getSession(false).getAttribute("ses");
        String userId = "VIRTUAL";
        String langCd = "KO";
        if (userInfo != null) {
            userId = userInfo.getUserId();
            langCd = userInfo.getLangCd();
        }


        List<Map<String, String>> buttonInfoList = buttonInfoCache.getData(screenId, langCd, userId);
        List<Map<String, String>> forLoggingList = new ArrayList<Map<String, String>>();

        for (Map<String, String> buttonInfo : buttonInfoList) {

            HashMap<String, String> forLoggingMap = new HashMap<String, String>();
            String actionCd = buttonInfo.get("actionCd");            // 버튼의 액션코드(ACTION_CD)
            String buttonCaption = buttonInfo.get("buttonCaption");    // 버튼의 액션명 (ACTION_NM)
            String btnIcon = buttonInfo.get("btnIcon");            // 버튼 아이콘 이미지
            boolean invisibleFlag = buttonInfo.get("invisibleFlag").equals("1");    // 화면액션관리 (BSYS_020)의 버튼숨기기(INVISIBLE_FLAG)
            String disabled = "false";
            String visible = "true";

            // 사용자 VIRTUAL인 경우 : 모든 버튼 보이도록 함
            if (userId.equals("VIRTUAL")) {
                disabled = "false";
                visible = "true";
            } else {
                // 운영사인 경우에만 버튼 권한을 Control한다.
                if (userInfo.isOperator() && !popupFlag && !userInfo.isSuperUser() && StringUtils.equals(buttonInfo.get("buttonAuth"), "N")) {
                    disabled = "true";
                }
            }

            // 버튼별 권한 검토
            //System.out.println("=========> 버튼 권한 [" + actionCd + "(" + buttonCaption + ")] : " + disabled);
            if (invisibleFlag) {
                visible = "false";
            }

            buttonInfoMap.put(actionCd + "_N", buttonCaption);
            buttonInfoMap.put(actionCd + "_I", btnIcon);
            buttonInfoMap.put(actionCd + "_D", disabled);
            buttonInfoMap.put(actionCd + "_V", visible);

            forLoggingMap.put("componentId", actionCd);
            forLoggingMap.put("buttonCaption", buttonCaption);
            forLoggingMap.put("btnIcon", btnIcon);
            forLoggingMap.put("disabled", disabled);
            forLoggingMap.put("visible", visible);
            forLoggingList.add(forLoggingMap);

            // 버튼 유형이 ETC인 경우 보이지 않도록 함
            if (detailView && !buttonInfo.get("fpFlag").equals("ETC")) { // if function point is defined by 'ETC', then display the button.
                buttonInfoMap.put(actionCd + "_V", "false");
                buttonInfoMap.put(actionCd + "_D", "true");
                forLoggingMap.put("visible", "false");
            }
        }

        buttonInfoCache.buttonInfoLoggging(screenId, forLoggingList);

        Map<String, Map<String, String>> buttonInfoData = new HashMap<String, Map<String, String>>();
        for (Map<String, String> buttonInfo : forLoggingList) {
            String id = buttonInfo.get("componentId");
            buttonInfo.put("caption", buttonInfo.get("buttonCaption"));
            buttonInfo.put("icon", buttonInfo.get("btnIcon"));
            buttonInfoData.put(id, buttonInfo);
        }

        if (buttonInfoData != null) {
            buttonInfoMap.put("buttonInfoList", new ObjectMapper().writeValueAsString(buttonInfoData));
        }

        return buttonInfoMap;
    }

    public Map<String, String> getFormInfo(EverHttpRequest req, String screenId, boolean detailView) throws Exception {

        UserInfo bi = getUserInfo();
        String langCd = StringUtils.isEmpty(bi.getLangCd()) ? PropertiesManager.getString("eversrm.langCd.default") : bi.getLangCd();
        String numberFormat = StringUtils.isEmpty(bi.getNumberFormat()) ? "###,##0.00" : bi.getNumberFormat();
        List<Map<String, String>> formInfoList = formInfoCache.getData(screenId, langCd);

        Map<String, String> map = new HashMap<String, String>();
        map.put("everNumberFormat", StringUtils.isEmpty(bi.getNumberFormat()) ? PropertiesManager.getString("eversrm.default.numberFormat") : bi.getNumberFormat());
        map.put("inputDateFormat", StringUtils.isEmpty(bi.getDateFormat()) ? PropertiesManager.getString("eversrm.default.dateFormat") : bi.getDateFormat());
        map.put("valueFormat", StringUtils.isEmpty(bi.getDateValueFormat()) ? PropertiesManager.getString("eversrm.default.dateValueFormat") : bi.getDateValueFormat());
        map.put("gridDateFormat", PropertiesManager.getString("eversrm.default.grid.dateFormat"));
        ArrayList<Map<String, String>> _formInfoList = new ArrayList<Map<String, String>>();

        for (Map<String, String> formInfo : formInfoList) {

            if (!formInfo.get("multiType").equals("F")) {
                continue;
            }

            String multiContents = EverString.nullToEmptyString(formInfo.get("multiContents"));
            String maxLength = EverString.nullToEmptyString(formInfo.get("maxLength"));
            if (maxLength.contains(".")) {
                maxLength = maxLength.replaceAll("0+$", "");
                maxLength = maxLength.replaceAll("\\.$", "");
            }

            String backColor = EverString.isEmpty(formInfo.get("backColor")) ? "" : formInfo.get("backColor").equals("E") ? "true" : "false";
            String disableFlag = EverString.isEmpty(formInfo.get("disableFlag")) ? "false" : formInfo.get("disableFlag").equals("1") ? "true" : "false";
            String invisibleFlag = EverString.isEmpty(formInfo.get("invisibleFlag")) ? "true" : formInfo.get("invisibleFlag").equals("1") ? "false" : "true";
            String editable = EverString.nullToEmptyString(formInfo.get("editable")).equals("true") ? "false" : "true";
            String dataType = EverString.nullToEmptyString(formInfo.get("dataType"));
            String alignmentType = EverString.nullToEmptyString(formInfo.get("alignmentType"));
            String alignType = "";
            String onNumberKr = EverString.nullToEmptyString(formInfo.get("onNumberKr"));
            String currencyText = EverString.nullToEmptyString(formInfo.get("currencyText"));
            if (("C").equals(alignmentType)) {
                alignType = "center";
            } else if (("L").equals(alignmentType)) {
                alignType = "left";
            } else if (("R").equals(alignmentType)) {
                alignType = "right";
            }
            String screenNumberFormat = "";
            String columnWidth = "100%";
            if (!("").equals(EverString.nullToEmptyString(formInfo.get("width")))) {
                if (("date").equals(EverString.nullToEmptyString(formInfo.get("columnType")))) {
                    columnWidth = "85";
                } else {
                    if (("100").equals(EverString.nullToEmptyString(formInfo.get("width")))) {
                        columnWidth = "100%";
                    } else {
                        columnWidth = EverString.nullToEmptyString(formInfo.get("width"));
                    }
                }
            }

            if (dataType.equals("NUM") || dataType.equals("SEQ") || dataType.equals("CNT")) {
                screenNumberFormat = "0";
            } else if (dataType.equals("MAX") || dataType.equals("AMT")) {
                screenNumberFormat = "0";
            } else if (dataType.equals("DEC1")) {
                screenNumberFormat = "1";
            } else if (dataType.equals("DEC2")) {
                screenNumberFormat = "2";
            } else if (dataType.equals("DEC3")) {
                screenNumberFormat = "3";
            } else if (dataType.equals("DEC4")) {
                screenNumberFormat = "4";
            } else if (dataType.equals("PER")) { /* Percentage */
                screenNumberFormat = "2";
            } else if (dataType.equals("QTY")) { /* Quantity */
                screenNumberFormat = "3";
            } else if (dataType.equals("RAT")) { /* Rate */
                screenNumberFormat = "2";
            } else if (dataType.equals("SCO")) { /* Score */
                screenNumberFormat = "1";
            } else if (dataType.equals("PRI")) { /* Price */
                screenNumberFormat = "0";
            } else {
                screenNumberFormat = "";
            }

            // 해당 화면에서 Grid의 panel을 보여줄지,말지를 설정한다.
            map.put("panelVisible", EverString.nullToEmptyString(formInfo.get("panelVisible")).equals("1") ? "true" : PropertiesManager.getString("eversrm.gridOption.panelVisible"));
            // shrinkToFit 값이 지정되어 있지 않으면 Properties 에서 가져온 값으로 넣어준다.
            map.put("shrinkToFit", EverString.nullToEmptyString(formInfo.get("shrinkToFit")).equals("1") ? "true" : PropertiesManager.getString("eversrm.gridOption.shrinkToFit"));

            String dateFormat = StringUtils.isEmpty(bi.getDateFormat()) ? PropertiesManager.getString("eversrm.default.dateFormat") : bi.getDateFormat();
            String dataFormat = getDataFormat(dataType, dateFormat, numberFormat);

            String formId = formInfo.get("formId");
            String columnId = formInfo.get("columnId");
            String prefix = formId + "_" + columnId;
            map.put(prefix + "_N", multiContents);
            map.put(prefix + "_M", maxLength);
            map.put(prefix + "_R", backColor);
            map.put(prefix + "_D", disableFlag);
            map.put(prefix + "_V", invisibleFlag);
            map.put(prefix + "_RO", editable);
            map.put(prefix + "_F", dataFormat);
            map.put(prefix + "_NF", screenNumberFormat);
            map.put(prefix + "_W", columnWidth);
            map.put(prefix + "_A", alignType);
            map.put(prefix + "_KR", "1".equals(onNumberKr) ? "true" : "false");
            map.put(prefix + "_CT", currencyText);

            HashMap<String, String> _formInfo = new HashMap<String, String>();
            _formInfo.put("componentId", columnId);
            _formInfo.put("label", multiContents);
            _formInfo.put("maxLength", maxLength);
            _formInfo.put("required", backColor);
            _formInfo.put("disabled", disableFlag);
            _formInfo.put("visible", invisibleFlag);
            _formInfo.put("readOnly", editable);
            _formInfo.put("format", dataFormat);
            _formInfoList.add(_formInfo);
            if (detailView) { // set the component's attributes to disabled/not editable if user requested detail view.
                map.put(prefix + "_RO", "true");
//				map.put(prefix + "_D", "true");
                _formInfo.put("readOnly", "true");
                _formInfo.put("disabled", "true");
            }

            String commonId = formInfo.get("commonId");
            if (StringUtils.isNotEmpty(commonId)) {
                String tempColId = WordUtils.capitalizeFully(columnId.replaceAll("_", " ")).replaceAll(" ", "");
                String colId = tempColId.substring(0, 1).toLowerCase() + tempColId.substring(1, tempColId.length()) + "Options";
                logger.info("폼 콤보 생성: {} / 결과: {}", colId, commonComboService.getCodeComboAsJson(commonId));
                req.setAttribute(colId, commonComboService.getCodeComboAsJson(commonId));
            }
        }

        if (formInfoList.size() == 0) {
            map.put("panelVisible", PropertiesManager.getString("eversrm.gridOption.panelVisible"));
            // shrinkToFit 값이 지정되어 있지 않으면 Properties 에서 가져온 값으로 넣어준다.
            map.put("shrinkToFit", PropertiesManager.getString("eversrm.gridOption.shrinkToFit"));
        }
        // 해당 화면에서 Grid의 panel을 보여줄지,말지를 설정한다.
        map.put("rowNumbers", PropertiesManager.getString("eversrm.gridOption.rowNumbers"));
        map.put("sortable", PropertiesManager.getString("eversrm.gridOption.sortable"));
        map.put("enterToNextRow", PropertiesManager.getString("eversrm.gridOption.enterToNextRow"));
        map.put("acceptZero", PropertiesManager.getString("eversrm.gridOption.acceptZero"));
        map.put("multiSelect", PropertiesManager.getString("eversrm.gridOption.multiSelect"));
        map.put("singleSelect", PropertiesManager.getString("eversrm.gridOption.singleSelect"));

        map.put("formInfoList", new ObjectMapper().writeValueAsString(_formInfoList));

        // TODO: ux 속성 설정
        Map<String, Map<String, String>> formInfoMap = new HashMap<String, Map<String, String>>();
        for (Map<String, String> formInfo : _formInfoList) {
            String id = formInfo.get("componentId");
            formInfoMap.put(id, new HashMap<String, String>(formInfo));
        }

        map.put("formInfoMap", new ObjectMapper().writeValueAsString(formInfoMap));
        return map;
    }

    @SuppressWarnings("unused")
    private String getDataFormat(String dataType, String dateFormat, String numberFormat) {
        String naturalNumberFormat = numberFormat.substring(0, 7);
//		String hundredthsFormat = numberFormat.substring(0, 10);
//		String thousandThsFormat  = hundredthsFormat + '0';

        if (dataType == null) {
            return numberFormat;
        }
        if (dataType.equals("D")) {
            return dateFormat;
        }
        if (dataType.equals("NUM")) {
            return naturalNumberFormat;
        }
        if (dataType.equals("SEQ")) {
            return naturalNumberFormat;
        }
        if (dataType.equals("CNT")) {
            return naturalNumberFormat;
        }
        if (dataType.equals("AMT")) {
            return naturalNumberFormat;
        }
        if (dataType.equals("QTY")) {
            return naturalNumberFormat;
        }
        if (dataType.equals("PRI")) {
            return naturalNumberFormat;
        }
        return numberFormat;
    }

    public Map<String, String> getScreenMessage(String screenId) throws Exception {
        Map<String, String> screenMessage = new HashMap<String, String>();
        List<Map<String, String>> messagesByScreenId = messageService.getMessagesByScreenId(screenId, true);
        for (Map<String, String> map : messagesByScreenId) {
            String key = screenId + "_" + EverString.nullToEmptyString(map.get("MULTI_CD"));
            String value = map.get("MULTI_CONTENTS");
            value = value.replace("'", "’");
            value = value.replace("\"", "＂");
            screenMessage.put(key, value);
        }
        return screenMessage;
    }

    public String getExcelDownMode(String screenId) throws Exception {
        return formInfoCache.getExcelDownMode(screenId);
    }


    public Map<String, Object> getToolbarInfo(String screenId, String tmplMenuCd) {
        return buttonInfoCache.getToolbarInfo(screenId, tmplMenuCd);
    }

    public Map<Object, Object> gridGen2(String gridId, String screenId, boolean detailView) throws Exception {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        String numberFormat = baseInfo.getNumberFormat();
        String dateFormat = baseInfo.getDateFormat();
        String langCode = StringUtils.defaultIfEmpty(baseInfo.getLangCd(), PropertiesManager.getString("eversrm.langCd.default"));

        gridGenService.init(screenId, gridId, langCode, dateFormat, numberFormat);
        gridGenService.getEssential();

        List<GridMeta> columnInfos = gridGenService.getColumnInfos();

        // 버튼 이미지 정보 가져오기
        List<Map<String, Object>> btnImageInfo = gridGenService.getBtnImageInfos(screenId);

        List<Object> list = new ArrayList<Object>();
        Map<Object, Object> rtnData = new LinkedHashMap<Object, Object>();

        for (GridMeta data : columnInfos) {

            String colType = data.getColumnType();
            Map<Object, Object> defData = new LinkedHashMap<Object, Object>();
            Map<Object, Object> tempData = new LinkedHashMap<Object, Object>();

            tempData.put("columnId", data.getColumnId());
            tempData.put("columnType", colType);
            tempData.put("commonId", data.getCommonId());
            tempData.put("text", data.getText());
            tempData.put("width", data.getWidth());
            tempData.put("maxLength", data.getMaxLength());
            tempData.put("editable", detailView ? "false" : data.getEditable());
            tempData.put("align", data.getAlign());
            tempData.put("frozen", data.isFrozeFlag());
            tempData.put("textWrap", data.getTextWrap());
            tempData.put("decimalYn", data.isDecimalYn());
            tempData.put("maskType", data.getMaskType());
            tempData.put("btnImage", btnImageInfo);

            if ("E".equals(data.getEssential())) {
                tempData.put("required", "true");
                tempData.put("defStyle", "E");
            } else {
                if ("D".equals(data.getEssential())) {
                    tempData.put("defStyle", "D");
                } else if ("O".equals(data.getEssential())) {
                    tempData.put("defStyle", "O");
                } else ;

                tempData.put("required", "false");
            }

            if ("imagetext".equals(data.getColumnType())) {

                if (data.getImageName() == null) {
                    defData.put("src", "");
                } else {
                    defData.put("src", data.getImageName());
                }

                defData.put("text", "");
                tempData.put("defData", defData);

            } else if ("combo".equals(data.getColumnType())) {

                List<Map<String, String>> comboData = data.getCombos();

                if (comboData != null) {
                    for (Map<String, String> tmp : comboData) {
                        tmp.put(tmp.get("value"), tmp.get("text"));
                    }
					// FIXME: 아래 코드 오류남
                    // tempData.put("defData", comboData);
                }
            } else if ("date".equals(data.getColumnType())) {
                tempData.put("defData", "yyyy/MM/dd");
            } else if ("number".equals(data.getColumnType())) {
                tempData.put("defData", data.getDataFormat());
            }

            list.add(tempData);
        }

        logger.info("{}", list);

        rtnData.put("gridColData", EverConverter.getJsonString(list));
        rtnData.put("detailView", detailView);
        rtnData.put("gridId", gridId);

        return rtnData;
        //resp.setContentType("application/json");
        //resp.getWriter().write(new ObjectMapper().writeValueAsString(rtnData));
    }
}