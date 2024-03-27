package com.st_ones.common.session.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.session.SessionMapper;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.service.BaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SessionService extends BaseService {

    @Autowired
    SessionMapper sessionMapper;

    @Autowired
    MessageService msg;

    /**
     * 협력업체의 견적서에 암호화된 내용을 재암호화합니다.
     *
     * @param formData
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doUpdateVendorEncQta(Map<String, String> formData) throws Exception {

        List<Map<String, String>> qtdtData = sessionMapper.getQtdtData(formData);
        if (qtdtData == null || qtdtData.size() == 0) {
            throw new EverException(msg.getMessage("0128"));
        }

        Map<String, String> qthdData = sessionMapper.getQthdData(formData);
        if (qthdData == null || qthdData.size() == 0) {
            throw new EverException(msg.getMessage("0128"));
        }

        getLog().info("- Original QTHD DATA: " + qthdData);
        getLog().info("- Original QTDT DATA: " + qtdtData);

        String key = formData.get("VENDOR_CD") + "ENCRIPT" + formData.get("VENDOR_CD");

        for (Map<String, String> datum : qtdtData) {

            Map<String, Object> param = new HashMap<String, Object>();
            param.put("QTA_NUM", datum.get("QTA_NUM"));
            param.put("QTA_SQ", datum.get("QTA_SQ"));

            datum.put("ENC_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(datum.get("UNIT_PRC"))));
            datum.put("ENC_INVEST_AMT", EverEncryption.aes256Encode(key, String.valueOf(datum.get("INVEST_AMT"))));
            datum.put("ENC_Y1_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(datum.get("Y1_UNIT_PRC"))));
            datum.put("ENC_Y2_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(datum.get("Y2_UNIT_PRC"))));
            datum.put("ENC_Y3_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(datum.get("Y3_UNIT_PRC"))));
            datum.put("ENC_ITEM_AMT", EverEncryption.aes256Encode(key, String.valueOf(datum.get("ITEM_AMT"))));

            sessionMapper.doUpdateQtdt(datum);
        }

        formData.put("ENC_QTA_AMT", EverEncryption.aes256Encode(key, String.valueOf(qthdData.get("QTA_AMT"))));
        sessionMapper.doUpdateQthd(formData);
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void changeVendorCd(Map<String, String> param) throws Exception {
        String return_vendor_cd = param.get("VENDOR_CD_A");
        String old_vendro_cd = param.get("VENDOR_CD_B");

        String[][] mmm =
                {{"STOCUSER", "COMPANY_CD"}, {"STOCMTCM", "CM_VENDOR_CD"}, {"STOCMTFM", "FM_VENDOR_CD"}, {"STOCPRDT", "LAST_VENDOR_CD"}
                        , {"STOCRQDT", "NEGO_VENDOR_CD"}, {"STOCRQDT", "REC_VENDOR_CD"}, {"STOCECHB", "VENDOR_CD"}, {"STOCEVVG", "VENDOR_CD"}
                        , {"STOCVNOH", "VENDOR_CD"}, {"STOCVNRG", "VENDOR_CD"}, {"STOCVNRS", "VENDOR_CD"}, {"STOCEVSQ", "VENDOR_CD"}
                        , {"STOCVNTR", "VENDOR_CD"}, {"STOCEVEE", "VENDOR_CD"}, {"STOCEVVQ", "VENDOR_CD"}, {"STOCEVES", "VENDOR_CD"}
                        , {"STOCEVET", "VENDOR_CD"}, {"STOCCPTS", "VENDOR_CD"}, {"STOCEVEU", "VENDOR_CD"}, {"STOCVNPI", "VENDOR_CD"}
                        , {"STOCVNCB", "VENDOR_CD"}, {"STOCVNCA", "VENDOR_CD"}, {"STOCEVVM", "VENDOR_CD"}, {"STOCVNRE", "VENDOR_CD"}
                        , {"STOCGRDT", "VENDOR_CD"}, {"STOCIVHD", "VENDOR_CD"}, {"STOCGPCM", "VENDOR_CD"}, {"STOCEVSD", "VENDOR_CD"}
                        , {"STOCMSRD", "VENDOR_CD"}, {"STOCMTFM", "VENDOR_CD"}, {"STOCRQET", "VENDOR_CD"}, {"STOCSMSH", "VENDOR_CD"}
                        , {"STOCMAIL", "VENDOR_CD"}, {"STOCRQSE", "VENDOR_CD"}, {"STOCRQVN", "VENDOR_CD"}, {"STOCSGVN", "VENDOR_CD"}
                        , {"STOCCNDT", "VENDOR_CD"}, {"STOCCNRG", "VENDOR_CD"}, {"STOCDLHD", "VENDOR_CD"}, {"STOCVNCP", "VENDOR_CD"}
                        , {"STOCVNEV", "VENDOR_CD"}, {"STOCECCT", "VENDOR_CD"}, {"STOCVNGL", "VENDOR_CD"}, {"STOCCNVD", "VENDOR_CD"}
                        , {"STOCQTDT", "VENDOR_CD"}, {"STOCQTHD", "VENDOR_CD"}, {"STOCINFO", "VENDOR_CD"}, {"STOCMTCM", "VENDOR_CD"}
                        , {"STOCPOHB", "VENDOR_CD"}, {"STOCPOHD", "VENDOR_CD"}, {"STOCPRDT", "VENDOR_CD"}, {"STOCVNSK", "VENDOR_CD"}
                        , {"STOCVNDC", "VENDOR_CD"}};

        for (int m = 0; m < mmm.length; m++) {
            param.put("RETURN_VENDOR_CD", return_vendor_cd);
            param.put("OLD_VENDRO_CD", old_vendro_cd);
            param.put("TABLE", mmm[m][0]);
            param.put("COLUMN", mmm[m][1]);

            String oldkey = old_vendro_cd + "ENCRIPT" + old_vendro_cd;
            String newkey = return_vendor_cd + "ENCRIPT" + return_vendor_cd;

            getLog().info("=========old_vendro_cd=" + old_vendro_cd);
            getLog().info("=========newkey=" + newkey);

        }
    }

    public List<Map<String, Object>> getColComments() {
        return sessionMapper.getColComments();
    }
}
