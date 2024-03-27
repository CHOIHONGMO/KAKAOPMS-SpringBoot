package com.st_ones.eversrm.system.code.service;

import com.st_ones.common.cache.data.CodeCache;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverAuthorityIgnore;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.code.BSYC_Mapper;
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
 * @File Name : BSYC_Service.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "bsyc_Service")
public class BSYC_Service extends BaseService {

    @Autowired
    private MessageService messageService;
    @Autowired
    private BSYC_Mapper bsycMapper;
    @Autowired
    private CodeCache codeCache;

    public List<Map<String, Object>> doSearchHD(Map<String, String> param) throws Exception {
        return bsycMapper.doSearchHD(param);
    }

    @SuppressWarnings("rawtypes")
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveHD(List<Map<String, Object>> gridDatas) throws Exception {

        Map<String, Object> param = new HashMap<String, Object>();
        String newKey = bsycMapper.getNewKey(param);

        for (Map<String, Object> gridData : gridDatas) {

            gridData.put("CODE_TYPE", EverString.isEmpty(String.valueOf(gridData.get("CODE_TYPE"))) || gridData.get("CODE_TYPE") == null ? newKey : gridData.get("CODE_TYPE"));

            int checkCnt = bsycMapper.checkHDData(gridData);
            // checkCnt = 0 : new Insert, checkCnt = 1 : Update, checkCnt = 2 : Select Insert

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCCODH");

            if (checkCnt == 0) {
                bsycMapper.doInsertHD(gridData);
            } else if (checkCnt == 1) {
                bsycMapper.doUpdateHD(gridData);
                codeCache.refreshData((String) gridData.get("CODE_TYPE"), (String) gridData.get("LANG_CD"));
            } else if (checkCnt == 2) {
                int transCnt = bsycMapper.doSelectInsertHD(gridData);
                if (transCnt < 1) {
                    throw new EverException(messageService.getMessageForService(this, "exception_msg"));
                }
            }
        }
        return messageService.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteHD(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            gridData.put("TABLE_NM", "STOCCODH");
            bsycMapper.doDeleteHD(gridData);

            gridData.put("TABLE_NM", "STOCCODD");
            bsycMapper.doDeleteDT(gridData);

            codeCache.refreshData((String) gridData.get("CODE_TYPE"), (String) gridData.get("LANG_CD"));

        }
        return messageService.getMessage("0017");
    }

    public List<Map<String, Object>> doSearchDT(Map<String, String> param) throws Exception {
        return bsycMapper.doSearchDT(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            if (bsycMapper.checkConstraintR31(gridData) == 0) {
                throw new NoResultException(messageService.getMessageForService(this, "exception_msg"));
            }

            int checkCnt = bsycMapper.checkDTData(gridData);

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCCODD");

            // checkCnt = 0 : new Insert, checkCnt = 1 : Update, checkCnt = 2 : Select Insert
            if (checkCnt == 0) {
                bsycMapper.doInsertDT(gridData);
                codeCache.refreshData((String) gridData.get("CODE_TYPE"), (String) gridData.get("LANG_CD"));
            } else if (checkCnt == 1) {
                bsycMapper.doUpdateDT(gridData);
                codeCache.refreshData((String) gridData.get("CODE_TYPE"), (String) gridData.get("LANG_CD"));
            } else if (checkCnt == 2) {
                int transCnt = bsycMapper.doSelectInsertDT(gridData);
                codeCache.refreshData((String) gridData.get("CODE_TYPE"), (String) gridData.get("LANG_CD"));
                if (transCnt < 1) {
                    throw new NoResultException(messageService.getMessageForService(this, "exception_msg"));
                }
            }
        }
        return messageService.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCCODD");
            bsycMapper.doDeleteDT(gridData);
            codeCache.refreshData((String) gridData.get("CODE_TYPE"), (String) gridData.get("LANG_CD"));
        }
        return messageService.getMessage("0017");
    }

    @EverAuthorityIgnore
    public List<Map<String, String>> getSTOCCODEByCodeType(String codeType, String langCd) {
        return codeCache.getData(codeType, langCd);
    }

    @EverAuthorityIgnore
    public List<Map<String, String>> getSTOCCODEByCodeType(String codeType, String[] columnIds) throws UserInfoNotFoundException {

        String langCd = UserInfoManager.getUserInfo().getLangCd();
        List<Map<String, String>> stocCodeByCodeType = getSTOCCODEByCodeType(codeType, langCd);
        List<Map<String, String>> list = new ArrayList<Map<String, String>>();

        for (Map<String, String> stcoCode : stocCodeByCodeType) {
            Map<String, String> map = new HashMap<String, String>();
            for (String columnId : columnIds) {
                map.put(columnId, stcoCode.get(columnId));
            }
            list.add(map);
        }
        return list;
    }

    @EverAuthorityIgnore
    public String getCodeValue(String codeType, String code) throws Exception {

        String langCd = UserInfoManager.getUserInfo().getLangCd();
        List<Map<String, String>> codes = getSTOCCODEByCodeType(codeType, langCd);
        for (Map<String, String> map : codes) {
            if (map.get("CODE").equals(code)) {
                return map.get("CODE_DESC");
            }
        }
        getLog().error(String.format("code value is not exist. codeType: %s, code: %s", codeType, code));
        return null;
    }

    public List<Map<String, String>> getCodeCombo(String codeType) throws Exception {

        List<Map<String, String>> list = new ArrayList<Map<String, String>>();

        Map<String, String> param = new HashMap<String, String>();
        param.put("CODE_TYPE", codeType);
        param.put("LANG_CODE", UserInfoManager.getUserInfo().getLangCd());

        List<Map<String, String>> codes = bsycMapper.getComCodeAndText(param);
        for (Map<String, String> code : codes) {
            Map<String, String> map = new HashMap<String, String>();
            map.put("value", code.get("CODE"));
            map.put("text", code.get("CODE_DESC"));
            list.add(map);
        }
        return list;
    }
}