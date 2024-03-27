package com.st_ones.eversrm.system.env.service;

import com.st_ones.common.cache.data.SystCache;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.env.BSYE_Mapper;
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
 * @File Name : BSYE_Service.java
 * @date 2013. 07. 22.
 * @see
 */

@Service(value = "bsye_Service")
public class BSYE_Service extends BaseService {

    @Autowired
    private MessageService msg;

    @Autowired
    BSYE_Mapper bsye_Mapper;

    @Autowired
    SystCache systCache;

    public List<Map<String, Object>> doSearchEnv(Map<String, String> param) throws Exception {
        return bsye_Mapper.doSearchEnv(param);
    }

    public String deleteEnvironment(List<Map<String, Object>> gridDatas) throws Exception {
        int rtn = -1;

        for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
            gridData.put("TABLE_NM", "STOCSYST");

            rtn = bsye_Mapper.deleteEnvironment(gridData);
            systCache.initData();

            if (rtn < 1) {
                throw new NoResultException(msg.getMessage("0003"));
            }
        }

        return msg.getMessage("0017");
    }

    public List<Map<String, Object>> selectHouse(Map<String, String> param) {
        return bsye_Mapper.selectHouse(param);
    }

    public List<Map<String, Object>> searchCompany(Map<String, String> param) {
        return bsye_Mapper.selectCompany(param);
    }

    public List<Map<String, Object>> doSelectPurOrganization(Map<String, String> param) {
        return bsye_Mapper.selectPurOrganization(param);
    }

    public List<Map<String, Object>> doSelectPlant(Map<String, String> param) {
        return bsye_Mapper.selectPlant(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveEnvironment(List<Map<String, Object>> gridDatas) throws Exception {

        int rtn = -1;

        for (Map<String, Object> gridData : gridDatas) {

            if (gridData.get("INSERT_FLAG").equals("I")) {
                
                gridData.put("KEY", gridData.get("SYS_KEY"));
                gridData.put("VALUE", gridData.get("SYS_VALUE"));

                gridData.remove("SYS_KEY");
                gridData.remove("SYS_VALUE");

                int checkCnt = bsye_Mapper.existsWiseConfInformation(gridData);

				/* This parameter is use for sync of each database server. */
                gridData.put("TABLE_NM", "STOCSYST");

                // checkCnt == 0 ? insert : update
                if (checkCnt == 0) {
                    // Setting document number.
                    rtn = bsye_Mapper.createEnvironment(gridData);
                    systCache.removeData((String) gridData.get("KEY"));

                }
            } else {
                /* This parameter is use for sync of each database server. */
                gridData.put("TABLE_NM", "STOCSYST");
                rtn = bsye_Mapper.updateEnvironment(gridData);
                systCache.initData();
            }

            if (rtn < 1) {
                throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
            }
        }

        return msg.getMessage("0001");
    }
}