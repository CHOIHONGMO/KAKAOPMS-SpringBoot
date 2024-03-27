package com.st_ones.common.popup.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.popup.CommonCodeUtil;
import com.st_ones.common.popup.service.CommonPopupService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : CommonPopupController.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/common/popup")
public class CommonPopupController extends BaseController {

    private static final String END_ANGLE = ">";
    private static final String COMMON_DESC = "CC";
    public static final String LIST_ITEM_TEXT = "LT";
    public static final String SEARCH_CONDITION_TEXT = "ST";

    @Autowired
    CommonPopupService commonPopupService;

    @Autowired
    CommonComboService commonComboService;

    @Autowired
    LargeTextService largeTextService;

    @RequestMapping(value = "/commonPopup/doSearch")
    public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> argMap = req.getFormData();

        Map<String, String> parametersMap = new HashMap<String, String>();
        parametersMap.put("_maskDefinitions", argMap.get("_maskDefinitions"));

        // , 뒤에 한칸 띄운 이유는 파라미터에 ,로 구분된 값을 넘기기 위해서이니 공백을 삭제하면 안됩니다.
        String[] argKey = req.getParameter("parameters").split(", ");

        if(argKey.length > 0) {
            for(int i = 0; i < argKey.length; i++) {

                argKey[i] = argKey[i].replace("@@@",","); //참고:BBV_Controller.java

                if(argKey[i].trim().indexOf("#") == -1) {
                    String[] tmp = (argKey[i].trim()).split("=");
                    if(tmp.length > 1) {
                        String tmp0 = EverString.nullToEmptyString(tmp[0]).equals("") ? tmp[0] : tmp[0].replace("{", "").replace("}", "");
                        String tmp1 = EverString.nullToEmptyString(tmp[1]).equals("") ? tmp[1] : tmp[1].replace("{", "").replace("}", "");
                        parametersMap.put(tmp0, tmp1);
                    }
                }
            }
        }

        String common_Id = argMap.get("commonId");

        Map<String, String> commonPopupDetail = commonPopupService.seachComboDetailInfo(common_Id);
        if(commonPopupDetail.get(SEARCH_CONDITION_TEXT) != null) {
        	setSearchCondition(req, commonPopupDetail.get(SEARCH_CONDITION_TEXT).split("###"));
        }
        setListItem(req, commonPopupDetail.get(LIST_ITEM_TEXT).split("###"), commonPopupDetail.get("LIST_ITEM_CD").split("###"), commonPopupDetail.get("WINDOW_WIDTH"));
        String replacedSql = CommonCodeUtil.getReplacedSql(EverString.rePreventSqlInjection(commonPopupDetail.get("SQL_TEXT")), parametersMap);

        String sql = putArgToSql(argMap, replacedSql);

        Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());
        parametersMap.putAll(param);
        parametersMap.putAll(argMap);
        resp.setGridObject(common_Id, commonPopupService.getGridData(sql, parametersMap));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/commonPopup/doSearchAsJson")
    public void doSearchAsJson(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> argMap = req.getFormData();
        argMap.put("arg1", req.getParameter("arg1"));
        argMap.put("arg2", req.getParameter("arg2"));
        argMap.put("arg3", req.getParameter("arg3"));
        argMap.put("arg4", req.getParameter("arg4"));
        Map<String, String> parametersMap = new HashMap<String, String>();
        parametersMap.put("_maskDefinitions", argMap.get("_maskDefinitions"));

        // , 뒤에 한칸 띄운 이유는 파라미터에 ,로 구분된 값을 넘기기 위해서이니 공백을 삭제하면 안됩니다.
        String[] argKey = req.getParameter("parameters").split(", ");

        if(argKey.length > 0) {
            for(int i = 0; i < argKey.length; i++) {

                argKey[i] = argKey[i].replace("@@@",","); //참고:BBV_Controller.java

                if(argKey[i].trim().indexOf("#") == -1) {
                    String[] tmp = (argKey[i].trim()).split("=");
                    if(tmp.length > 1) {
                        String tmp0 = EverString.nullToEmptyString(tmp[0]).equals("") ? tmp[0] : tmp[0].replace("{", "").replace("}", "");
                        String tmp1 = EverString.nullToEmptyString(tmp[1]).equals("") ? tmp[1] : tmp[1].replace("{", "").replace("}", "");
                        parametersMap.put(tmp0, tmp1);
                    }
                }
            }
        }

        String commonId = req.getParameter("commonId");
        Map<String, String> commonPopupDetail = commonPopupService.seachComboDetailInfo(commonId);
        String replacedSql = CommonCodeUtil.getReplacedSql(EverString.rePreventSqlInjection(commonPopupDetail.get("SQL_TEXT")), parametersMap);

        String sql = putArgToSql(argMap, replacedSql);

		if (sql.contains("#")) {
			throw new Exception("No qualified parameter. \n" + sql);
		}

        parametersMap.put("sql", sql);

		ObjectMapper objectMapper = new ObjectMapper();
        List<LinkedHashMap<String, Object>> gridDataAsHashMap = commonPopupService.getGridDataAsHashMap(parametersMap);
        resp.getWriter().write(objectMapper.writeValueAsString(gridDataAsHashMap));
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/commonPopup/view")
    public String view(EverHttpRequest everReq, @RequestParam("COMMON_ID") String commonId) throws Exception {

        Map<String, String> parameters = reqParamMapToStringMap(everReq.getParameterMap());
        Map<String, String> commonPopupDetail = commonPopupService.seachComboDetailInfo(commonId);
        if(commonPopupDetail.get(SEARCH_CONDITION_TEXT) != null) {
        	setSearchCondition(everReq, commonPopupDetail.get(SEARCH_CONDITION_TEXT).split("###"));
        }
        setListItem(everReq, commonPopupDetail.get(LIST_ITEM_TEXT).split("###"), commonPopupDetail.get("LIST_ITEM_CD").split("###"), commonPopupDetail.get("WINDOW_WIDTH"));
        String replacedSql = CommonCodeUtil.getReplacedSql(commonPopupDetail.get("SQL_TEXT"), parameters);
        HashMap<String, Object> searchCondition = new HashMap<String, Object>();

        searchCondition.put("sql", replacedSql);
        searchCondition.put("commonId", commonId);
        searchCondition.put("colSize", searchCondition.size());
        everReq.setAttribute("isDev", PropertiesManager.getBoolean("eversrm.system.developmentFlag"));
        everReq.setAttribute("parameters", parameters.toString());
        everReq.setAttribute("searchCondition", searchCondition);
        everReq.setAttribute("typeCode", commonPopupDetail.get("TYPE_CD"));
        everReq.setAttribute("commonDesc", commonPopupDetail.get("TT"));
        everReq.setAttribute("autoSearchFlag", commonPopupDetail.get("AUTO_SEARCH_FLAG"));
        everReq.setAttribute("windowWidth", EverString.nullToEmptyString(commonPopupDetail.get("WINDOW_WIDTH")).equals("") ? "700" : commonPopupDetail.get("WINDOW_WIDTH"));
        everReq.setAttribute("windowHeight", EverString.nullToEmptyString(commonPopupDetail.get("WINDOW_HEIGHT")).equals("") ? "600" : commonPopupDetail.get("WINDOW_HEIGHT"));
        return "/common/commonPopup/commonPopup";
    }

    @RequestMapping(value = "/commonPopup/getDimension")
    public void getDimenSion(EverHttpRequest everReq, EverHttpResponse everResp) throws Exception {
        Map<String, String> popupDimension = commonPopupService.seachComboDetailInfo(everReq.getParameter("COMMON_ID"));
        everResp.setParameter("width", popupDimension.get("WINDOW_WIDTH"));
        everResp.setParameter("height", popupDimension.get("WINDOW_HEIGHT"));
        everResp.setResponseCode("0001");
    }

    @RequestMapping(value = "/commonPopupSample/changeCodeType")
    public void changeCodeType(EverHttpRequest everReq, EverHttpResponse everResp) throws Exception {
        everResp.setResponseCode("true");
    }

    @RequestMapping(value = "/commonPopupSample/view")
    public String sampleView(EverHttpRequest everReq) throws Exception {
        return "/wisec/common/commonPopup/commonPopupSample";
    }

    @RequestMapping(value = "/chartPopup/view")
    public String chartPopup(EverHttpRequest everReq) throws Exception {
        return "/wisec/common/commonPopup/chartPopup";
    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    private String putArgToSql(Map<String, String> argMapPar, String sql) throws Exception {

        // 개인정보 암/복호화관련 적용. [원본은 아래 주석처리된 소스]
    	// 2017.06.07
        Map<String, String> argMap = argMapPar;
        argMap = (Map)EverConverter.forDynamicQuery((Map)argMap);
        Set<String> keySet = argMap.keySet();
        StrBuilder strBuilder = new StrBuilder(sql);
        for (String key : keySet) {

        	/*
        	 * <arg1 AND>USER_ID</arg1>
        	 * 암호화가 적용되지 않은 컬럼의 경우 위와 같이 기존과 같이 사용하지만...
        	 * <enc1 AND>XX1.ENC_INDEX_VARCHAR2(USER_NM, 'NAME')
        	 *           LIKE '%' || XX1.ENC_INDEX_VARCHAR2_SEL(UPPER(#paramStr1#), 'NAME') || '%'</enc1>
        	 * 암호화가 적용된 컬럼의 경우 위와 같이 arg 대신 enc로 대체하여 사용한다.
        	 */
            if (!key.contains("arg") && !key.contains("enc")) {
           		continue;
            }
            String prefix = String.format("<%s", key);
            String postfix = String.format("</%s", key);

            String prefixE = String.format("<%s", key.replace("arg", "enc"));
            String postfixE = String.format("</%s", key.replace("arg", "enc"));

			boolean hasArg = false;
            while (StringUtils.isEmpty(argMap.get(key)) && strBuilder.contains(prefix)) {
                int startIndex = strBuilder.indexOf(prefix);
                int endIndex = strBuilder.indexOf(postfix);
                endIndex = strBuilder.indexOf(END_ANGLE, endIndex);
                strBuilder.delete(startIndex, endIndex + 1);
                hasArg = true;
            }
            while (StringUtils.isEmpty(argMap.get(key)) && strBuilder.contains(prefixE)) {
            	int startIndex = strBuilder.indexOf(prefixE);
            	int endIndex = strBuilder.indexOf(postfixE);
            	endIndex = strBuilder.indexOf(END_ANGLE, endIndex);
            	strBuilder.delete(startIndex, endIndex + 1);
            	hasArg = true;
            }
            if (hasArg) {
                continue;
            }

            String replaceType = "N";

            int preFixIndex = -1;
            while ((preFixIndex = strBuilder.indexOf(prefix)) != -1) {
            	strBuilder.deleteFirst(prefix);
                int endAngleIndex = strBuilder.indexOf(END_ANGLE, preFixIndex);
                strBuilder.replace(endAngleIndex, endAngleIndex + 1, " " + argMap.get(key + "_L"));
            }

            int preFixIndexE = -1;
            while ((preFixIndexE = strBuilder.indexOf(prefixE)) != -1) {
            	strBuilder.deleteFirst(prefixE);
            	int endAngleIndex = strBuilder.indexOf(END_ANGLE, preFixIndexE);
            	strBuilder.replace(endAngleIndex, endAngleIndex + 1, " ");
            }

            int postfixIndex = -1;
            while ((postfixIndex = strBuilder.indexOf(postfix)) != -1) {
                strBuilder.replaceFirst(postfix, argMap.get(key + "_R"));
                int endAngleIndex = strBuilder.indexOf(END_ANGLE, postfixIndex);
                strBuilder.delete(endAngleIndex, endAngleIndex + 1);
            }

            int postfixIndexE = -1;
            while ((postfixIndexE = strBuilder.indexOf(postfixE)) != -1) {
            	strBuilder.replaceFirst(postfixE, "");
            	int endAngleIndex = strBuilder.indexOf(END_ANGLE, postfixIndexE);
            	strBuilder.delete(endAngleIndex, endAngleIndex + 1);
            	replaceType = "S";
            }

            if(replaceType.equals("N")) {
            	String argKey = String.format("#%s#", key);
	            String argValue = String.format("'%s'", EverString.CheckInjection(argMap.get(key)));
	            strBuilder.replaceAll(argKey, argValue);
            } else {
            	String argKey = String.format("#%s#", "paramStr" + key.replace("arg", ""));
	            String argValue = String.format("'%s'", EverString.changeCharacterSetApp2DbString(argMapPar.get(key).replaceAll("&#39;", "''")));
                strBuilder.replaceAll(argKey, argValue);
            }
        }

        return strBuilder.toString();
    }

    private void setListItem(EverHttpRequest everReq, String[] itemTextList, String[] itemCodeList, String windowWidthString) {

        List<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();
        int windowWidth = Integer.parseInt(windowWidthString);
        int gridWidth = windowWidth - 45;
        int columnCount = itemTextList.length;
        int columnWidth = gridWidth / columnCount;
        for (int i = 0; i < itemTextList.length; i++) {

            HashMap<String, String> map = new HashMap<String, String>();
            String id = itemCodeList[i];
            String width = String.valueOf(columnWidth);

            HashMap<String, String> maskMap = null;
            if(StringUtils.contains(id,"_$")) {

                maskMap = new HashMap<String, String>();
                maskMap.put("id", id);
                maskMap.put("text", itemTextList[i]);
                maskMap.put("maskType", StringUtils.substringAfterLast(id, "_$"));
                maskMap.put("width", width);

                id = StringUtils.substringBeforeLast(id, "_$");
                width = "0";
            }

            map.put("id", id);
            map.put("text", itemTextList[i]);
            map.put("width", width);

            if (itemCodeList[i].substring(0, 4).equals("NUM_")) {
                map.put("type", "number");
                map.put("align", "right");
                map.put("maxLength", "22.0");
                map.put("dataFormat", "");
            } else if (itemCodeList[i].substring(0, 4).equals("SCO_")) {
                map.put("type", "number");
                map.put("align", "right");
                map.put("maxLength", "22.2");
                map.put("dataFormat", "##.00");
            } else if (itemCodeList[i].substring(0, 4).equals("SEQ_")) {
                map.put("type", "number");
                map.put("align", "center");
                map.put("maxLength", "6.0");
                map.put("dataFormat", "");
            } else if (itemCodeList[i].substring(0, 4).equals("CTX_")) {
                map.put("type", "text");
                map.put("align", "center");
                map.put("maxLength", "200");
                map.put("dataFormat", "");
            } else {
                map.put("type", "text");
                map.put("align", "left");
                map.put("maxLength", "200");
                map.put("dataFormat", "");
            }

            if(maskMap != null) {

                maskMap.put("type", map.get("type"));
                maskMap.put("align", map.get("align"));
                maskMap.put("maxLength", map.get("maxLength"));
                maskMap.put("dataFormat", map.get("dataFormat"));

                list.add(maskMap);
            }

            list.add(map);
        }

        everReq.setAttribute("gridColumns", list);
    }

    private void setSearchCondition(EverHttpRequest everReq, String[] searchConditions) {
        List<Map<String, String>> searchConditionList = new ArrayList<Map<String, String>>();
        int index = 1;
        for (String searchCondition : searchConditions) {
            Map<String, String> map = new HashMap<String, String>();
            map.put("label", searchCondition);
            map.put("id", "arg" + (index++));
            map.put("label", searchCondition);
            map.put("visible", "true");
            map.put("width", "1ft");
            searchConditionList.add(map);
        }
        everReq.setAttribute("searchConditionList", searchConditionList);
    }


    @RequestMapping(value = "/common_text_view/view")
    public String common_text_view(EverHttpRequest req) throws Exception {
        return "/common/commonPopup/common_text_view";
    }

    @RequestMapping(value = "/common_text_input/view")
    public String common_text_input(EverHttpRequest req) throws Exception {
        return "/common/commonPopup/common_text_input";
    }

    @RequestMapping(value = "/commonFileAttach/view")
    public String commonFileAttach(EverHttpRequest req) throws Exception {

        return "/common/commonFileAttach";
    }

    @RequestMapping(value = "/commonImgFileAttach/view")
    public String commonImgFileAttach(EverHttpRequest req) throws Exception {

        return "/common/commonImgFileAttach";
    }

    @RequestMapping(value = "/commonTextContents/view")
    public String commonTextContents(EverHttpRequest req) throws Exception {

        return "/common/commonTextContents";
    }

    @RequestMapping(value = "/commonRichTextContents/view")
    public String commonRichTextContents(EverHttpRequest req) throws Exception {

        String largeTextNum = req.getParameter("largeTextNum");
        if(StringUtils.isNotEmpty(largeTextNum)) {
            req.setAttribute("TEXT_CONTENTS", largeTextService.selectLargeText(largeTextNum));
        }

        return "/common/commonRichTextContents";
    }

    @RequestMapping(value = "/getLargeTextNum")
    public void saveTextAndReturnLargeTextNumber(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        resp.setParameter("largeTextNum", largeTextService.saveLargeText(formData.get("TEXT_NUM"), formData.get("TEXT_CONTENTS")));
    }

}