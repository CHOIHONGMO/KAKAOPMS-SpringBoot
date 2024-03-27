package com.st_ones.eversrm.system.task.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.task.BSYT_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : BSYT_Service.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "bsyt_Service")
public class BSYT_Service extends BaseService {

    @Autowired
    private MessageService msg;

    @Autowired
    private BSYT_Mapper bsyt_Mapper;

    public List<Map<String, Object>> selectTaskPersonInCharge(Map<String, String> param) throws Exception {
        return bsyt_Mapper.selectTaskPersonInCharge(param);
    }

    public List<Map<String, Object>> selectMappingPlant(List<Map<String, Object>> gridData) throws Exception {
        List<Map<String, Object>> returnGrid2 = null;

        for (Map<String, Object> grid : gridData) {
            returnGrid2 = bsyt_Mapper.selectMappingPlant(grid);
        }
        return returnGrid2;
    }

    public List<Map<String, Object>> selectMappingUser(List<Map<String, Object>> gridData) throws Exception {
        List<Map<String, Object>> returnGrid3 = null;

        for (Map<String, Object> grid : gridData) {
            returnGrid3 = bsyt_Mapper.selectMappingUser(grid);
        }
        return returnGrid3;
    }

    @SuppressWarnings("rawtypes")
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveTaskPersonInCharge(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            int chk = bsyt_Mapper.checkTaskPersonInCharge(gridData);

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCBACP");
            if (chk == 0) {
                gridData.put("CH_TYPE","C");
                bsyt_Mapper.insertTaskPersonInCharge(gridData);
            } else {
                gridData.put("CH_TYPE","U");
                bsyt_Mapper.updateTaskPersonInCharge(gridData);
            }


            //매핑저장시 직무 History 저장
            bsyt_Mapper.saveHistoryBACH(gridData);
        }
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String deleteTaskPersonInCharge(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCBACP");
            bsyt_Mapper.deleteTaskPersonInCharge(gridData);

            //매핑삭제시직무 History 저장
            gridData.put("CH_TYPE","D");
            bsyt_Mapper.saveHistoryBACH(gridData);

        }
        return msg.getMessage("0017");
    }

    public List<Map<String, Object>> selectUserInCharge(Map<String, String> param) throws Exception {
        return bsyt_Mapper.selectUserInCharge(param);
    }

    public List<Map<String, Object>> selectTaskCodeBySearch(Map<String, String> param) throws Exception {
        return bsyt_Mapper.selectTaskCodeBySearch(param);
    }

    public List<Map<String, Object>> selectTaskCode(Map<String, String> param) throws Exception {
        return bsyt_Mapper.selectTaskCode(param);
    }

    public List<Map<String, Object>> selectMappingUser_add(Map<String, String> param) throws Exception {
        return bsyt_Mapper.selectMappingUser_add(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveTaskCode(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            int chk = bsyt_Mapper.checkTaskCode(gridData);

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCBACO");
            if (chk == 0) {
                bsyt_Mapper.insertTaskCode(gridData);
            } else {
                bsyt_Mapper.updateTaskCode(gridData);
            }

        }
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveMappingPlant(List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {
            bsyt_Mapper.saveMappingPlant(gridData);
        }
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String deleteMappingPlant(List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {
            bsyt_Mapper.deleteMappingPlant(gridData);
        }
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String deleteTaskCode(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCBACO");
            bsyt_Mapper.deleteTaskCode(gridData);
        }
        return msg.getMessage("0017");
    }

    //직무-사용자저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String[] doSaveTaskUser(Map formData, List<Map<String, Object>> gridDatas) throws Exception {
        String args[] = new String[1];
        for (Map<String, Object> gridData : gridDatas) {

            gridData.put("BUYER_CD", formData.get("BUYER_CD_S"));
            gridData.put("CTRL_CD", formData.get("CTRL_CD_S"));
            gridData.put("CTRL_USER_ID", gridData.get("USER_ID"));

            int chk = bsyt_Mapper.checkTaskPersonInCharge(gridData);

            gridData.put("TABLE_NM", "STOCBACP");
            if (chk == 0) {
                gridData.put("CH_TYPE","C");
                bsyt_Mapper.insertTaskPersonInCharge(gridData);
            } else {
                gridData.put("CH_TYPE","U");
                bsyt_Mapper.updateTaskPersonInCharge(gridData);
            }


            //매핑저장시 직무 History 저장
            bsyt_Mapper.saveHistoryBACH(gridData);
        }
        args[0] = msg.getMessage("0001");
        return args;
    }

    //직무-사용자삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String[] doDeleteTaskUser(Map formData, List<Map<String, Object>> gridDatas) throws Exception {
        String args[] = new String[1];
        for (Map<String, Object> gridData : gridDatas) {

            gridData.put("BUYER_CD", formData.get("BUYER_CD_S"));
            gridData.put("CTRL_CD", formData.get("CTRL_CD_S"));
            gridData.put("CTRL_USER_ID", gridData.get("USER_ID"));

            gridData.put("BUYER_CD_ORI", formData.get("BUYER_CD_S"));
            gridData.put("CTRL_CD_ORI", formData.get("CTRL_CD_S"));
            gridData.put("CTRL_USER_ID_ORI", gridData.get("USER_ID"));

            gridData.put("TABLE_NM", "STOCBACP");
            bsyt_Mapper.deleteTaskPersonInCharge(gridData);

            //매핑삭제시직무 History 저장
            gridData.put("CH_TYPE","D");
            bsyt_Mapper.saveHistoryBACH(gridData);

        }
        args[0] = msg.getMessage("0017");

        return args;
    }

    public List<Map<String, Object>> selectTaskItemMapping(Map<String, String> param) throws Exception {
        return bsyt_Mapper.selectTaskItemMapping(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveTaskItemMapping(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

//            gridData.put("CTRL_CD", new JSONObject((Map) gridData.get("CTRL_CD")).get("text"));
            int chk = bsyt_Mapper.existTaskItemMapping(gridData);
            /* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCBAMT");

            if (chk == 0) {
                bsyt_Mapper.insertTaskItemMapping(gridData);
            } else {
                bsyt_Mapper.updateTaskItemMapping(gridData);
            }

        }
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String deleteTaskItemMapping(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCBAMT");
            bsyt_Mapper.deleteTaskItemMapping(gridData);
        }
        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public List<Map<String, Object>> BSYT_070_doSearch(Map<String, String> param) throws Exception {
        return bsyt_Mapper.BSYT_070_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BSYT_070_doSave(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> grid : gridData) {
            bsyt_Mapper.BSYT_070_doSave(grid);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BSYT_070_doDelete(List<Map<String, Object>> gridData) throws Exception {
        for (Map<String, Object> grid : gridData) {
            bsyt_Mapper.BSYT_070_doDelete(grid);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> BSYT_070_doSaveCheck(List<Map<String, Object>> gridData) throws Exception {
        String returnMsg = "", message = "", status = "";
        int cnt = 0;
        Map<String, String> returnMap = new HashMap<String, String>();

        List<Map<String, Object>> usplList = bsyt_Mapper.BSYT_070_doSearch(new HashMap<String, String>());

        // 최초 등록 시 체크
        if (usplList.size() > 0) {
            for (Map<String, Object> uspl : usplList) {
                for (Map<String, Object> grid : gridData) {
                    if (uspl.get("USER_ID").equals(grid.get("USER_ID")) &&
                            uspl.get("PLANT_CD").equals(grid.get("PLANT_CD"))) {
                        message += uspl.get("USER_ID") + ", " + uspl.get("PLANT_CD") + "\n";
                        cnt++;
                    }
                }
            }

            if (cnt > 0) {
                status = "2";
                returnMsg = msg.getMessage("0034") + "\n" + message;
            } else {
                status = "1";
                returnMsg = msg.getMessage("0031");
            }
        } else {
            status = "1";
            returnMsg = msg.getMessage("0031");
        }

        returnMap.put("message", returnMsg);
        returnMap.put("status", status);

        return returnMap;
    }

    //직무-사용자 이력 조회
    public List<Map<String, Object>> bsyt080Select(Map<String, String> param) throws Exception {

        if(EverString.isNotEmpty(param.get("CTRL_NM"))) {
            param.put("ctrlType", EverString.forInQuery(param.get("CTRL_NM"), ","));
        }

        return bsyt_Mapper.bsyt080Select(param);
    }

}