package com.st_ones.eversrm.system.screen.service;

import com.st_ones.common.cache.data.AuthorizedButtonCache;
import com.st_ones.common.cache.data.ButtonInfoCache;
import com.st_ones.common.cache.data.ScrnCache;
import com.st_ones.common.config.service.EverConfigService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.multiLang.BSYL_Mapper;
import com.st_ones.eversrm.system.screen.BSYS_Mapper;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
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
 * @File Name : BSYS_Service.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "bsys_Service")
public class BSYS_Service extends BaseService {

    private static final String EVER_DBLINK = "ever.remote.database.link.name";

    @Autowired
    private EverConfigService everConfigService;
    @Autowired
    private LargeTextService largeTextService;
    @Autowired
    private BSYS_Mapper bsys_Mapper;
    @Autowired
    private MessageService msg;
    @Autowired
    private DocNumService docNumService;
    @Autowired
    private BSYL_Mapper bsyl_Mapper;
    @Autowired
    private AuthorizedButtonCache authorizedButtonCache;
    @Autowired
    private ButtonInfoCache buttonInfoCache;
    @Autowired
    private ScrnCache scrnCache;

    public List<Map<String, Object>> doSearchScreenManagement(Map<String, String> param) throws Exception {
        return bsys_Mapper.doSearchScreenManagement(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveScreenManagement(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCSCRN");
            int checkCnt = bsys_Mapper.checkScreenManagement(gridData);
            if (checkCnt == 0) {
                gridData.put("TABLE_NM", "STOCSCRN");
                bsys_Mapper.doInsertScreenManagement(gridData);
                scrnCache.removeData();
            } else {
                bsys_Mapper.doUpdateScreenManagement(gridData);
                scrnCache.removeData();
            }

            if (PropertiesManager.getString("eversrm.database.sync").equals("true")) {
                //This parameter is use for sync of each database server.
                gridData.put("TABLE_NM", EverString.getDBLinkName("STOCSCRN", everConfigService.getSystemConfig(EVER_DBLINK)));

                checkCnt = bsys_Mapper.checkScreenManagement(gridData);
                if (checkCnt == 0) {
                    bsys_Mapper.doInsertScreenManagement(gridData);
                    scrnCache.removeData();
                } else {
                    bsys_Mapper.doUpdateScreenManagement(gridData);
                    scrnCache.removeData();
                }
            }
        }
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteScreenManagement(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCSCRN");
            bsys_Mapper.doDeleteScreenManagement(gridData);
            scrnCache.removeData();
        }
        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doCopyScreenManagement(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            formData.put("ORI_SCREEN_ID", String.valueOf(gridData.get("SCREEN_ID")));
        }
        formData.put("NEW_SCREEN_ID", formData.get("COPY_SCREEN_ID"));
        formData.put("NEW_SCREEN_NM", formData.get("COPY_SCREEN_NM"));
        formData.put("NEW_SCREEN_URL", formData.get("COPY_SCREEN_URL"));

        int checkCnt = bsys_Mapper.checkScreenId(formData);
        if (checkCnt > 0) {
            throw new EverException(msg.getMessageForService(this, "existScreenId").replace("@@", "\n"));
        }

        bsys_Mapper.doCopyScreenManagementSCRN(formData);
        bsys_Mapper.doCopyScreenManagementSCAC(formData);
        bsys_Mapper.doCopyScreenManagementMULG(formData);
        bsys_Mapper.doCopyScreenManagementLANG(formData);

        return msg.getMessageForService(this, "success");
    }

    public List<Map<String, Object>> doSearchScreenActionManagement(Map<String, String> param) throws Exception {
        return bsys_Mapper.doSearchScreenActionManagement(param);
    }

    @SuppressWarnings("rawtypes")
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveScreenActionManagement(List<Map<String, Object>> gridDatas) throws Exception {

        List<Map<String, String>> availableButtonCodeList = bsys_Mapper.getAvailableButtonCodeList();
        List<String> codeList = new ArrayList<String>();
        List<String> codeAndNameList = new ArrayList<String>();
        UserInfo userInfo = UserInfoManager.getUserInfoImpl();

        for (Map<String, String> rowData : availableButtonCodeList) {
            codeList.add(rowData.get("CTRL_CD"));
            codeAndNameList.add("   " + rowData.get("CTRL_CD") + "  (" + rowData.get("CTRL_NM") + ")\n");
        }

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCSCAC");
            if (StringUtils.isNotEmpty((String) gridData.get("BUTTON_AUTH"))) {

                String buttonAuth = (String) gridData.get("BUTTON_AUTH");
                String[] bas = buttonAuth.split(",");
                for (String ba : bas) {
                    if (!codeList.contains(ba)) {
                        String[] t = codeAndNameList.toArray(new String[codeAndNameList.size()]);
                        throw new EverException("Couldn't update data.\n* Available button auth codes are: \n\n" + StringUtils.join(t, ",").replaceAll(",", ""));
                    }
                }
            }

            int buttonCount = bsys_Mapper.checkScreenActionManagement(gridData);
            String screenId = (String) gridData.get("SCREEN_ID");
            String langCd = userInfo.getLangCd();
            String userId = userInfo.getUserId();

            if (buttonCount > 0) {

                gridData.put("TABLE_NM", "STOCSCAC");

                bsys_Mapper.doUpdateScreenActionManagement(gridData);
                buttonInfoCache.removeData(screenId, langCd, userId);
            } else {

                gridData.put("TABLE_NM", "STOCSCAC");

                bsys_Mapper.doInsertScreenActionManagement(gridData);
                buttonInfoCache.removeData(screenId, langCd, userId);
            }
        }

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteScreenActionManagement(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCSCAC");

            bsys_Mapper.doDeleteScreenActionManagement(gridData);
            String screenId = (String) gridData.get("SCREEN_ID_ORI");
            buttonInfoCache.removeData(screenId);
        }

        return msg.getMessage("0017");
    }

    public List<Map<String, Object>> doSearchScreenIdPopup(Map<String, String> param) throws Exception {
        return bsys_Mapper.doSearchScreenIdPopup(param);
    }

    public Map<String, String> selectHelpInfo(String paramScreenId) throws Exception {
        return bsys_Mapper.selectHelpInfo(paramScreenId);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveHelpInfo(Map<String, String> formData) throws Exception {

        formData.put("HELP_TEXT_NUM", largeTextService.saveLargeText(EverString.nullToEmptyString(formData.get("HELP_TEXT_NUM")), formData.get("CONTENTS")));
        bsys_Mapper.updateHelpInfo(formData);

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteHelpInfo(Map<String, String> formData) throws Exception {

        bsys_Mapper.deleteHelpInfo(formData);
        return msg.getMessage("0001");
    }

    public List<Map<String, Object>> doSearchTActionProfileManagement(Map<String, String> param) throws Exception {
        return bsys_Mapper.doSearchTActionProfileManagement(param);
    }

    public List<Map<String, Object>> doSearchLActionProfileManagement(Map<String, String> param) throws Exception {
        return bsys_Mapper.doSearchLActionProfileManagement(param);
    }

    public List<Map<String, Object>> doSearchRActionProfileManagement(Map<String, String> param) throws Exception {
        return bsys_Mapper.doSearchRActionProfileManagement(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveTActionProfileManagement(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            int checkCnt = 0;

            if (gridData.get("ACTION_PROFILE_CD") != "") {
                checkCnt = bsys_Mapper.checkTActionProfileManagement(gridData);
            }

            if ("I".equals(gridData.get("INSERT_FLAG"))) {
                if (checkCnt == 0) {
                    String docn = docNumService.getDocNumber("AP");

                    gridData.put("ACTION_PROFILE_CD", docn);

                    Map<String, Object> formdata = new HashMap<String, Object>();

                    UserInfo baseInfo = UserInfoManager.getUserInfoImpl();
                    String langCd = baseInfo.getLangCd();
                    formdata.put("LANG_CD", langCd);
                    formdata.put("MULTI_NAME", gridData.get("ACTION_PROFILE_NM").toString());
                    formdata.put("SCREEN_ID", "-");
                    formdata.put("DEL_FLAG", "0");
                    formdata.put("MULTI_CD", "AP");
                    formdata.put("ACTION_PROFILE_CD", docn);
                    formdata.put("ACTION_CD", "");
                    formdata.put("TMPL_MENU_CD", "");
                    formdata.put("AUTH_CD", "");
                    formdata.put("TMPL_MENU_GROUP_CD", "");
                    formdata.put("MENU_GROUP_CD", "");
                    formdata.put("COMMON_ID", "");
                    formdata.put("MULTI_DESC", "");
                    formdata.put("TABLE_NM", "STOCMULG");
                    //formdata.put("_LINKDB_NAME", wiseConfigService.getSystemConfig(WISE_DBLINK));
                    bsyl_Mapper.multiLanguagePopupDoInsert(formdata);

					/* This parameter is use for sync of each database server. */
                    gridData.put("TABLE_NM", "STOCACPH");

                    bsys_Mapper.doInsertTActionProfileManagement(gridData);
                }
            } else {
                if (checkCnt > 0) {

					/* This parameter is use for sync of each database server. */
                    gridData.put("TABLE_NM", "STOCACPH");
                    bsys_Mapper.doUpdateTActionProfileManagement(gridData);
                }
            }
        }

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteTActionProfileManagement(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            if ("U".equals(gridData.get("INSERT_FLAG"))) {
                int checkCnt = bsys_Mapper.checkTActionProfileManagement(gridData);
                /* This parameter is use for sync of each database server. */
                gridData.put("TABLE_NM", "STOCACPH");

                if (checkCnt > 0) {
                    bsys_Mapper.doDeleteTActionProfileManagement(gridData);
                }
            }
        }

        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveLActionProfileManagement(String actionProfileCd, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCACPF");
            gridData.put("ACTION_PROFILE_CD", actionProfileCd);
            int checkCnt = bsys_Mapper.checkLActionProfileManagement(gridData);

            if (checkCnt == 0) {
                gridData.put("TABLE_NM", "STOCACPF");
                bsys_Mapper.doInsertLActionProfileManagement(gridData);
                authorizedButtonCache.removeData((String) gridData.get("SCREEN_ID"), (String) gridData.get("ACTION_PROFILE_CD"));
            } else {
                gridData.put("TABLE_NM", "STOCACPF");
                bsys_Mapper.doUpdateLActionProfileManagement(gridData);
                authorizedButtonCache.removeData((String) gridData.get("SCREEN_ID"), (String) gridData.get("ACTION_PROFILE_CD"));
            }
        }

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteLActionProfileManagement(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            if ("U".equals(gridData.get("INSERT_FLAG"))) {

                gridData.put("TABLE_NM", "STOCACPF");

                bsys_Mapper.doDeleteLActionProfileManagement(gridData);
                authorizedButtonCache.removeData((String) gridData.get("SCREEN_ID"), (String) gridData.get("ACTION_PROFILE_CD"));
            }
        }

        return msg.getMessage("0017");
    }
}