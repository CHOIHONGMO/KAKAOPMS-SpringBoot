package com.st_ones.eversrm.system.multiLang.service;

import com.st_ones.common.cache.data.*;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.multiLang.BSYL_Mapper;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
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
 * @File Name : BSYL_Service.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "bsyl_Service")
public class BSYL_Service extends BaseService {

    @Autowired private BSYL_Mapper bsyl_Mapper;
    @Autowired private MessageService msg;
    @Autowired private MessageCache messageCache;
    @Autowired private ColumnInfoCache columnInfoCache;
    @Autowired private BottomBarInfoCache bottomBarInfoCache;
    @Autowired private FormInfoCache formInfoCache;
    @Autowired private MulgSaCache mulgSaCache;
    @Autowired private MulgPopupNameCache mulgPopupNameCache;
    @Autowired private MulgPopupInfoCache mulgPopupInfoCache;
    @Autowired private MulgMtCache mulgMtCache;
    @Autowired private DocNumService docNumService;

    public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {

        List<Map<String, Object>> multiLanguageData = bsyl_Mapper.doSearch(param);

        for (Map<String, Object> map : multiLanguageData) {
            int width = 0;
            if (map.get("COLUMN_WIDTH") != null)
                width = ((BigDecimal)map.get("COLUMN_WIDTH")).intValue();

            if (width > 0 && width < 10)
                map.put("WIDTH_UNIT", "F");
            else
                map.put("WIDTH_UNIT", "X");
        }

        return multiLanguageData;
    }

    @SuppressWarnings("rawtypes")
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSave(List<Map<String, Object>> gridDatas) throws Exception {

        for (int i = 0; i < gridDatas.size(); i++) {

            Map<String, Object> gridMap = gridDatas.get(i);
            Iterator<String> mapItor = gridMap.keySet().iterator();

            while (mapItor.hasNext()) {
                String keyVal = mapItor.next();

                if ("SCREEN_ID".equals(keyVal) || "LANG_CD".equals(keyVal) || "MULTI_CD".equals(keyVal) || "FORM_GRID_ID".equals(keyVal)) {
                    String tmpVal = (String)gridMap.get(keyVal);
                    gridDatas.get(i).put(keyVal, tmpVal.trim());
                }
            }
        }

        int checkCnt = 0;
        String checkId = "";

        convertMultiContentsQuatation(gridDatas);

        for (Map<String, Object> gridData : gridDatas) {
            gridData.put("exclusion", "true");

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCLANG");

            checkCnt = bsyl_Mapper.checkColumnId(gridData);

            // checkCnt == 0 ? insert : update
            if (checkCnt == 0) {
                gridData.put("TABLE_NM", "STOCLANG");
                bsyl_Mapper.doInsert(gridData);
                removeCache(gridData);
            }
            else {
                gridData.put("TABLE_NM", "STOCLANG");

                checkId = checkId + gridData.get("MULTI_CD") + ",";
                bsyl_Mapper.doUpdate(gridData);
                removeCache(gridData);
            }
        }

        checkId = checkId.length() > 0 ? checkId.substring(0, checkId.length() - 1) : checkId;
        String message = checkId.length() > 0 ? msg.getMessage("0032", checkId) : msg.getMessage("0031");
        return message;
    }

    private void convertMultiContentsQuatation(List<Map<String, Object>> gridDatas) {
        for (Map<String, Object> gridData : gridDatas) {
            String value = (String)gridData.get("MULTI_CONTENTS");
            value = value.replace("'", "’");
            value = value.replace("\"", "＂");
            gridData.put("MULTI_CONTENTS", value);
        }
    }

    private void removeCache(Map<String, Object> gridData) {
        String screenId = (String)gridData.get("SCREEN_ID");
        String gridId = (String)gridData.get("FORM_GRID_ID");
        String langCd = (String)gridData.get("LANG_CD");
        messageCache.removeData(screenId, langCd);
        formInfoCache.removeData(screenId, langCd);
        columnInfoCache.removeData(screenId, gridId, langCd);
        bottomBarInfoCache.removeData(langCd);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDelete(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCLANG");

            bsyl_Mapper.doDelete(gridData);
            removeCache(gridData);
        }

        return msg.getMessage("0017");

    }

    public List<Map<String, Object>> doSearchDataLength(Map<String, String> param) throws Exception {
        return bsyl_Mapper.doSearchDataLength(param);
    }

    public List<Map<String, Object>> doSearchDOMC(Map<String, String> param) throws Exception {
    	return bsyl_Mapper.doSearchDOMC(param);
    }

    public List<Map<String, Object>> doSearchWord(Map<String, String> param) throws Exception {

//        String stringMergeOperator = null;
//        String databaseId = PropertiesManager.getString("eversrm.system.database"); //SpringContextUtil.getUtilService().getDatabaseId();

//        if ("OR".equals(databaseId)) {
//            stringMergeOperator = "||";
//        } else if ("MS".equals(databaseId)) {
//            stringMergeOperator = "+";
//        } else {
//            throw new SystemPropertyNotFoundException("illegal database id. this value has been set by context persistence VendorDatabaseIdProvider bean. databaseId: " + databaseId);
//        }

        UserInfo baseInfo = UserInfoManager.getUserInfoImpl();

        String[] tmp = param.get("SEARCH_WORD").split("_");
        String sqlQuery = "";

        for (int i = tmp.length-1, y = 0; i > 0; i--, y++) {
            if (EverString.isNotEmpty(tmp[i])) {
                sqlQuery = sqlQuery + "UNION ALL \n";
                sqlQuery = sqlQuery + "SELECT FORMAT, DOMAIN_TYPE, DOMAIN_NM, DATA, DATA_LENGTH, PRE_FORMAT, ALIGNMENT, COL_WIDTH, '" + (y + 3) + "' AS NUM FROM STOCDOMA \n";
                sqlQuery = sqlQuery + "WHERE GATE_CD = '" + baseInfo.getGateCd() + "' AND UPPER(DOMAIN_NM) = UPPER('_" + EverString.CheckInjection(tmp[i]) + "')\n";
//                getLog().info(sqlQuery);
            }
        }

        param.put("sqlQuery", sqlQuery);
        return bsyl_Mapper.doSearchWord(param);
    }

    public List<Map<String, Object>> getMultiLanguageList(Map<String, String> param) {
        return bsyl_Mapper.getMultiLanguageList(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class, timeout = -1)
    public String multiLanguagePopupDoSave(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            gridData.put("MULTI_NM", EverString.isEmpty((String) gridData.get("MULTI_NM")) ? param.get("multi_nm") : gridData.get("MULTI_NM"));
            gridData.put("MULTI_CD", EverString.isEmpty((String) gridData.get("MULTI_CD")) ? param.get("multi_cd") : gridData.get("MULTI_CD"));
            gridData.put("SCREEN_ID", EverString.isEmpty((String) gridData.get("SCREEN_ID")) ? param.get("screen_id") : gridData.get("SCREEN_ID"));
            gridData.put("ACTION_CD", EverString.isEmpty((String) gridData.get("ACTION_CD")) ? param.get("action_cd") : gridData.get("ACTION_CD"));
            gridData.put("TMPL_MENU_CD", EverString.isEmpty((String) gridData.get("TMPL_MENU_CD")) ? param.get("tmpl_menu_cd") : gridData.get("TMPL_MENU_CD"));
            gridData.put("AUTH_CD", EverString.isEmpty((String) gridData.get("AUTH_CD")) ? param.get("auth_cd") : gridData.get("AUTH_CD"));
            gridData.put("ACTION_PROFILE_CD", EverString.isEmpty((String) gridData.get("ACTION_PROFILE_CD")) ? param.get("action_profile_cd") : gridData.get("ACTION_PROFILE_CD"));
            gridData.put("TMPL_MENU_GROUP_CD", EverString.isEmpty((String) gridData.get("TMPL_MENU_GROUP_CD")) ? param.get("tmpl_menu_group_cd") : gridData.get("TMPL_MENU_GROUP_CD"));
            gridData.put("MENU_GROUP_CD", EverString.isEmpty((String) gridData.get("MENU_GROUP_CD")) ? param.get("menu_group_cd") : gridData.get("MENU_GROUP_CD"));
            gridData.put("COMMON_ID", EverString.isEmpty((String) gridData.get("COMMON_ID")) ? param.get("common_id") : gridData.get("COMMON_ID"));
            gridData.put("OTHER_CD", EverString.isEmpty((String) gridData.get("OTHER_CD")) ? param.get("other_cd") : gridData.get("OTHER_CD"));

            Iterator<String> mapItor = gridData.keySet().iterator();
            while (mapItor.hasNext()) {

                String keyVal = mapItor.next();

                if ("GATE_CD".equals(keyVal) || "MULTI_SQ".equals(keyVal) || "LANG_CD".equals(keyVal)) {
                    String tmpVal = "";
                    if(gridData.get(keyVal) instanceof Integer || gridData.get(keyVal) instanceof Long) {
                        tmpVal = String.valueOf(gridData.get(keyVal));
                    } else {
                        tmpVal = StringUtils.defaultIfEmpty((String) gridData.get(keyVal), "");
                    }
                    gridData.put(keyVal, tmpVal.trim());
                }
            }

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCMULG");
            if ("U".equals(gridData.get("INSERT_FLAG"))) {
                bsyl_Mapper.multiLanguagePopupDoUpdate(gridData);
                removeMulgCache(gridData);
            } else {
                bsyl_Mapper.multiLanguagePopupDoInsert(gridData);
                removeMulgCache(gridData);
            }
        }

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String insertMenuName(Map<String, String> param) throws Exception {

        Iterator<String> mapItor = param.keySet().iterator();
        while (mapItor.hasNext()) {
            String keyVal = mapItor.next();

            if ("HOUSE_CODE".equals(keyVal) || "MULTI_SEQ".equals(keyVal) || "LANG_CODE".equals(keyVal)) {
                String tmpVal = param.get(keyVal);
                param.put(keyVal, tmpVal.trim());
            }
        }

		/* This parameter is use for sync of each database server. */
        param.put("TABLE_NAME", "ICOMMULG");
        bsyl_Mapper.insertMenuName(param);
        initMulgCache();

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeletePopup(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> gridRow : gridData) {
            if (EverString.isEmpty(gridRow.get("MULTI_SQ") instanceof String ? (String) gridRow.get("MULTI_SQ") : String.valueOf(gridRow.get("MULTI_SQ")))) {
                continue;
            }
			/* This parameter is use for sync of each database server. */
            gridRow.put("TABLE_NM", "STOCMULG");

            bsyl_Mapper.multiLanguagePopupDoDelete(gridRow);

            initMulgCache();
        }
        return msg.getMessage("0017");
    }

    private void removeMulgCache(Map<String, Object> gridData) {

        String screenId = (String) gridData.get("SCREEN_ID");
        String langCd = (String) gridData.get("LANG_CD");
        String commonId = (String) gridData.get("COMMON_ID");
        String tmplMenuCd = (String) gridData.get("TMPL_MENU_CD");
        String multiCd = (String) gridData.get("MULTI_CD");

        mulgMtCache.removeData(tmplMenuCd, langCd);
        mulgPopupInfoCache.removeData(commonId, langCd);
        mulgSaCache.removeData(screenId, langCd);
        mulgPopupNameCache.removeData(screenId, multiCd, langCd);
    }

    private void initMulgCache() {
        mulgMtCache.initData();
        mulgPopupInfoCache.initData();
        mulgSaCache.initData();
        mulgPopupNameCache.initData();
    }

    /**
     * 화면권한코드를 조회한다.
     * TEXT1: 접근불가능한 직무
     * TEXT2: 접근불가능한 사용자ID
     * TEXT3: 접근가능한 직무(접근불가능한 직무 체크보다 우선순위 높음)
     * @param param
     * @return
     */
    public List<Map<String, Object>> bsyl050_getScreenAuth(Map<String, String> param) {


        List<Map<String, Object>> resultGridData = new ArrayList<Map<String, Object>>();
        Map<String, String> screenAccessibleData = bsyl_Mapper.selectScreenAccessibleCode(param);
        if(screenAccessibleData != null) {
            String screenNotAccessibleCode = screenAccessibleData.get("TEXT1");
            String screenNotAccessibleUserIds = screenAccessibleData.get("TEXT2");
            String screenAccessibleCode = screenAccessibleData.get("TEXT3");
            if(StringUtils.isNotEmpty(screenAccessibleCode)) {
                Map<String, Object> rowData = new HashMap<String, Object>();
                rowData.put("AUTH_TYPE", "PD");
                rowData.put("AUTH_CONTENTS", screenAccessibleCode);
                resultGridData.add(rowData);
            }
            if(StringUtils.isNotEmpty(screenNotAccessibleCode)) {
                Map<String, Object> rowData = new HashMap<String, Object>();
                rowData.put("AUTH_TYPE", "CD");
                rowData.put("AUTH_CONTENTS", screenNotAccessibleCode);
                resultGridData.add(rowData);
            }
            if(StringUtils.isNotEmpty(screenNotAccessibleUserIds)) {
                String[] arrayOfUserIds = screenNotAccessibleUserIds.split(",");
                for (String userId : arrayOfUserIds) {
                    Map<String, Object> rowData = new HashMap<String, Object>();
                    rowData.put("AUTH_TYPE", "ID");
                    rowData.put("AUTH_CONTENTS", userId);
                    resultGridData.add(rowData);
                }
            }
        }

        return resultGridData;
    }

    /**
     * 화면권한코드를 저장한다.
     * 데이터를 여러 row로 나눠서 저장하는 게 아니고 TEXT1에는 화면접근코드를, TEXT2에는 사용자ID를 ,(Comma)로 구분하여 STOCCODD 테이블에 입력한다.
     * @param formData
     * @param gridData
     * @return
     * @throws UserInfoNotFoundException
     */
    public String bsyl050_doSave(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {

        String notAccessibleUserId = "";
        for (Map<String, Object> rowData : gridData) {
            if(StringUtils.equals((String)rowData.get("AUTH_TYPE"), "CD")) {
                formData.put("TEXT1", (String)rowData.get("AUTH_CONTENTS"));
            } else if(StringUtils.equals((String)rowData.get("AUTH_TYPE"), "ID")) {
                String authContents = (String)rowData.get("AUTH_CONTENTS");
                notAccessibleUserId = notAccessibleUserId + authContents + ",";
            } else if(StringUtils.equals((String)rowData.get("AUTH_TYPE"), "PD")) {
                formData.put("TEXT3", (String)rowData.get("AUTH_CONTENTS"));
            }
        }

        formData.put("TEXT2", notAccessibleUserId);

        if(bsyl_Mapper.getCountExistsScreenAccessibleCode(formData) == 0) {
            bsyl_Mapper.insertScreenAccessibleCode(formData);
        } else {
            bsyl_Mapper.updateScreenAccessibleCode(formData);
        }

        return msg.getMessage("0001");
    }

    /**
     * 화면권한코드를 삭제한다.
     * 데이터가 1 row 이기 때문에 화면에서 선택한 row의 DEL_FLAG을 '1'로 셋팅하고 서비스로 넘겨주고,
     * 서비스에서는 그 데이터만 제외시킨 후 TEXT1, TEXT2에 다시 셋팅해서 업데이트한다.
     *
     * @param formData
     * @param gridData
     * @return
     * @throws UserInfoNotFoundException
     */
    public String bsyl050_doDelete(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {

        String notAccessibleUserId = "";
        for (Map<String, Object> rowData : gridData) {
            if(!StringUtils.equals((String)rowData.get("DEL_FLAG"), "1")) {
                if(StringUtils.equals((String)rowData.get("AUTH_TYPE"), "CD")) {
                    formData.put("TEXT1", (String)rowData.get("AUTH_CONTENTS"));
                } else if(StringUtils.equals((String)rowData.get("AUTH_TYPE"), "ID")) {
                    String authContents = (String)rowData.get("AUTH_CONTENTS");
                    notAccessibleUserId = notAccessibleUserId + authContents + ",";
                }
            }
        }

        formData.put("TEXT2", notAccessibleUserId);

        bsyl_Mapper.updateScreenAccessibleCode(formData);

        return msg.getMessage("0017");
    }

    /**
     * 사용자별 컬럼정의 조회
     * 사용자별 컬럼정의한 그리드 레이아웃 데이터가 존재하면 해당내용을, 없다면 화면속성관리의 그리드레이아웃 데이터를 조회한다.
     *
     * @param param
     * @return gridData
     */
    public List<Map<String, Object>> BSYL021_doSearch(Map<String, String> param) throws Exception {
        return bsyl_Mapper.BSYL021_STOCLANG_Search(param);
    }

    public List<Map<String, Object>> BSYL021_doSearchSub(Map<String, String> param) throws Exception {
        return bsyl_Mapper.BSYL021_STOCUSCC_Search(param);
    }

    /**
     * 사용자별 컬럼정의 저장
     * 사용자별 컬럼 내용(순서와, 너비 변경)을 STOCUSLN에 저장
     *
     * @param gridData
     * @param param
     * @return gridData
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BSYL021_doSave(List<Map<String, Object>> gridData, Map<String, String> param) throws Exception {

        for (Map<String, Object> grid : gridData) {
            bsyl_Mapper.BSYL021_doDelete(grid); //해당데이터 삭제후 insert

            if(grid.get("DISABLE_FLAG").equals("0")){  //표기x 면 넓이 =0
                grid.put("COLUMN_WIDTH",0);
            }else{ //표기o면 넓이 지정 또는 디폴트
                if(Integer.parseInt(grid.get("COLUMN_WIDTH").toString())>0){
                    grid.put("COLUMN_WIDTH", grid.get("COLUMN_WIDTH"));
                }else{
                    grid.put("COLUMN_WIDTH", grid.get("ORI_COLUMN_WIDTH"));
                }
            }
            bsyl_Mapper.BSYL021_doSave(grid);

            String screenId = (String)grid.get("SCREEN_ID");
            String gridId = (String)grid.get("FORM_GRID_ID");
            String langCd = (String)grid.get("LANG_CD");

            //columnInfoCache.removeData(screenId, gridId, langCd);
        }
        //columnInfoCache.removeAllCaches();
    }

    /**
     * 사용자별 컬럼정의 테이블 초기화 -> 데이터 삭제
     *
     * @param gridData
     */
    public void BSYL021_doDelete(List<Map<String, Object>> gridData) throws Exception {
        for (Map<String, Object> grid : gridData) {
            bsyl_Mapper.BSYL021_doDelete(grid);

            /*String screenId = (String)grid.get("SCREEN_ID");
            String gridId = (String)grid.get("FORM_GRID_ID");
            String langCd = (String)grid.get("LANG_CD");
            columnInfoCache.removeData(screenId, gridId, langCd);*/
        }
    }

    public void BSYL021_doReset(List<Map<String, Object>> gridData, Map<String, String> param) throws Exception {
        bsyl_Mapper.BSYL021_doReset(param);

        /*for (Map<String, Object> grid : gridData) {
            String screenId = (String)grid.get("SCREEN_ID");
            String gridId = (String)grid.get("FORM_GRID_ID");
            String langCd = (String)grid.get("LANG_CD");
            columnInfoCache.removeData(screenId, gridId, langCd);
        }*/
        //columnInfoCache.removeAllCaches();
    }

    public Map<String, String> getMostUsedWord(Map<String, String> param) {
        return bsyl_Mapper.getMostUsedWord(param);
    }

    /**
     * 해당 컬럼 버튼이미지 저장
     * @param gridData
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BSYL_022_doSave(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> grid : gridData) {
            if(EverString.nullToEmptyString(grid.get("SORT_SQ")).equals("")) {
                grid.put("SORT_SQ", docNumService.getDocNumber("BI"));
            }
            bsyl_Mapper.BSYL_022_doSave(grid);
        }

    }

    public List<Map<String,Object>> BSYL_022_doSearch(Map<String, String> formData) throws Exception {
        return bsyl_Mapper.BSYL_022_doSearch(formData);
    }

    public void BSYL_022_doDelete(List<Map<String, Object>> gridData) {
        for (Map<String, Object> grid : gridData) {
            bsyl_Mapper.BSYL_022_doDelete(grid);
        }
    }
}
