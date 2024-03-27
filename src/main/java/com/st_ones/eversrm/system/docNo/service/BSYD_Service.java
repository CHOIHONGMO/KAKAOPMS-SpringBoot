package com.st_ones.eversrm.system.docNo.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.docNo.BSYD_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : BSYD_Service.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "bsyd_Service")
public class BSYD_Service extends BaseService {

    @Autowired
    private BSYD_Mapper bsyd_Mapper;

    @Autowired
    private MessageService msg;

    public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
        return bsyd_Mapper.doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSave(List<Map<String, Object>> gridDatas) throws Exception {

        int checkCnt = 0;

        for (Map<String, Object> gridData : gridDatas) {

            checkCnt = bsyd_Mapper.checkDocType(gridData);

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCDNCT");
            if (checkCnt == 0) {
                bsyd_Mapper.doInsert(gridData);
            } else {
                bsyd_Mapper.doUpdate(gridData);
            }
        }

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDelete(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCDNCT");

            bsyd_Mapper.doDelete(gridData);

        }

        return msg.getMessage("0017");
    }

}