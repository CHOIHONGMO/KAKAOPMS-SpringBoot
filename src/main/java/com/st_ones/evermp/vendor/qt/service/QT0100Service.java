package com.st_ones.evermp.vendor.qt.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.evermp.vendor.qt.QT0100Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value="QT0110Service")
public class QT0100Service {

    @Autowired  private QT0100Mapper qt0100Mapper;
    @Autowired  private MessageService msg;
    @Autowired  private LargeTextService largeTextService;
    @Autowired  private DocNumService docNumService;
    @Autowired  private EverMailService everMailService;


    public List<Map<String,Object>> getRqList(Map<String,String> formData){
        return qt0100Mapper.getRqList(formData);
    }

    public void receiptRQVN(List<Map<String, Object>> gridDatas){

        for(Map<String,Object> gridData : gridDatas){
            gridData.put("PROGRESS_CD","200");
            qt0100Mapper.receiptRQVN(gridData);
        }

    }

    public Map<String,String> getQtHdSubmitData(Map<String,String> param) throws Exception{
        Map<String, String> returnData = qt0100Mapper.getQtHdSubmitData(param);

        if(returnData.get("QTA_NUM") != null){
            String splitString = largeTextService.selectLargeText(String.valueOf(returnData.get("RMK")));
            returnData.put("RMK_TEXT", splitString);
            String key = returnData.get("VENDOR_CD") + "ENCRIPT" + returnData.get("VENDOR_CD");
            returnData.put("QTA_AMT", EverEncryption.aes256Decode(key, returnData.get("ENC_QTA_AMT")));
        }
        return returnData;
    }

    public List<Map<String,Object>> getQtdtSubmitData(Map<String,String> param) throws Exception{
        List<Map<String,Object>> gridDatas = qt0100Mapper.getQtdtSubmitData(param);
        List<Map<String,Object>> rtnList = new ArrayList<>();
        String key = param.get("VENDOR_CD") + "ENCRIPT" + param.get("VENDOR_CD");
        for(Map<String,Object> gridData : gridDatas){
            String sss = EverEncryption.aes256Decode(key, String.valueOf(gridData.get("ENC_UNIT_PRC")));
            gridData.put("UNIT_PRC",EverEncryption.aes256Decode(key, String.valueOf(gridData.get("ENC_UNIT_PRC"))));
            gridData.put("QTA_AMT",EverEncryption.aes256Decode(key, String.valueOf(gridData.get("ENC_QTA_AMT"))));
            gridData.remove("ENC_UNIT_PRC");
            gridData.remove("ENC_QTA_AMT");
            rtnList.add(gridData);
        }
        return rtnList;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> saveOrSubmitQT(Map<String,String> formData, List<Map<String,Object>> gridDatas) throws Exception{

        //견적 마감일이 지난 경우 처리 불가
        String rfxEndFlag = qt0100Mapper.getRfqCloseFlag(formData);
        if(rfxEndFlag.equals("Y")){
            throw new Exception(msg.getMessage("0049"));
        }

        //헤더 암호화
        String key = formData.get("VENDOR_CD") + "ENCRIPT" + formData.get("VENDOR_CD");
        formData.put("ENC_QTA_AMT", EverEncryption.aes256Encode(key, formData.get("QTA_AMT")));
        formData.put("QTA_AMT", "0");


        String qtTextNo = EverString.nullToEmptyString(formData.get("RMK")).toString();
        String textNo = largeTextService.saveLargeText(qtTextNo, EverString.nullToEmptyString(formData.get("RMK_TEXT")).toString());

        String qtaNum = formData.get("QTA_NUM");
        if (EverString.isEmpty(qtaNum)){
            qtaNum = docNumService.getDocNumber(formData.get("BUYER_CD"),"QTA");
            formData.put("QTA_NUM", qtaNum);
        }

        formData.put("RMK", textNo);
        formData.put("PROGRESS_CD", formData.get("SEND_FLAG").equals("T") ? "250" : "300");

        //RQVN 테이블 업데이트
        qt0100Mapper.updateProgressCdRQVN(formData);

        // 헤더 저장
        int cnt = qt0100Mapper.checkExistsQtaCreation_QTHD(formData);
        if(cnt == 0){
            qt0100Mapper.insertQTHD(formData);
        }else{
            qt0100Mapper.updateQTHD(formData);
        }

        // 품목 저장
        for(Map<String,Object> gridData : gridDatas){
            gridData.put("QTA_NUM", formData.get("QTA_NUM"));

            //품목 암호화
            gridData.put("ENC_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(gridData.get("UNIT_PRC"))));
            gridData.put("ENC_QTA_AMT", EverEncryption.aes256Encode(key, String.valueOf(gridData.get("QTA_AMT"))));
            gridData.put("UNIT_PRC", "0");
            gridData.put("QTA_AMT", "0");

            cnt = qt0100Mapper.checkExistsQtaCreation_QTDT(gridData);
            if(cnt == 0){
                qt0100Mapper.insertQTDT(gridData);
            }else{
                qt0100Mapper.updateQTDT(gridData);
            }
        }

        //협력사 전송
        if(formData.get("SEND_FLAG").equals("S")){
            qt0100Mapper.submitQTHD(formData);
            qt0100Mapper.submitQTDT(formData);

            //sendEmail((Map)formData);

        }


        Map<String,String> rtnMap = new HashMap<>();
        rtnMap.put("BUYER_CD",formData.get("BUYER_CD"));
        rtnMap.put("RFX_NUM", formData.get("RFX_NUM"));
        rtnMap.put("RFX_CNT", formData.get("RFX_CNT"));
        rtnMap.put("rtnMsg", (formData.get("SEND_FLAG").equals("T") ? msg.getMessage("0031") : msg.getMessageByScreenId("QT0120", "0001")));

        return rtnMap;
    }

    public String waiveRFQ(List<Map<String,Object>> gridDatas) throws Exception{

        for(Map<String,Object> gridData : gridDatas){
            String checkCnt = qt0100Mapper.checkRqvnProgressCd(gridData);
            if (!("100".equals(checkCnt) || "200".equals(checkCnt) || "250".equals(checkCnt))) {
                throw new NoResultException(msg.getMessage("0044"));
            }
            qt0100Mapper.waiveRQVN(gridData);
            //sendEmail(gridData);
        }
        return msg.getMessage("0001");
    }
    
    // 다시 체크하세요.
    // 메일 템플릿 사용해야 합니다...
    public void sendEmail(Map<String,Object> param) throws Exception{

        Map<String, String> mdata = new HashMap<>();
        mdata.put("BUYER_CD", String.valueOf(param.get("BUYER_CD")));
        mdata.put("QTA_NUM",  String.valueOf(param.get("QTA_NUM")));

        // 메일 발송정보 가져오기
        mdata = qt0100Mapper.getMailInfo(mdata);

        // 발송내용
        String contents = "<BR> 안녕하십니까!" +
                "<BR> [" + mdata.get("BUYER_NM") + "] [" + mdata.get("RECV_USER_NM") + "]님" +
                "<BR>" +
                "<BR> 아래와 같이 협력사에서 Quatation을 등록 하였습니다." +
                "<BR>" +
                "<BR> 협력사 : " + mdata.get("VENDOR_NM") +
                "<BR> 요청명 : " + mdata.get("RFX_SUBJECT") +
                "<BR> 등록일 : " + mdata.get("SEND_DATE") +
                "<BR> 등록결과 : " + mdata.get("SEND_TYPE_LOC") +
                "<BR>" +
                "<BR> 전자구매시스템에 로그인 하시어, 세부내용을 확인 해주십시오." +
                "<BR>" +
                "<BR> 감사합니다.";

        if( !EverString.nullToEmptyString(mdata.get("RECV_EMAIL")).equals("") ) {
            mdata.put("SUBJECT", "[전자구매시스템] 협력사[" + mdata.get("VENDOR_NM") + "]가 [" + mdata.get("RFX_SUBJECT") + "] 관련 Quatation을 등록 하였습니다.");
            mdata.put("CONTENTS", contents);
            mdata.put("RECV_USER_ID", String.valueOf(mdata.get("RECV_USER_ID")));
            mdata.put("RECV_USER_NM", String.valueOf(mdata.get("RECV_USER_NM")));
            mdata.put("RECV_EMAIL",   String.valueOf(mdata.get("RECV_EMAIL")));
            mdata.put("REF_NUM", null);
            mdata.put("REF_MODULE_CD", "RFQ");
            // 메일전송.
            //everMailService.sendMail(mdata);
        }
    }




    /********************************************************************************************
     * 협력사 > 견적관리 > 견적관리 > 견적결과 (QT0220)
     * 처리내용 : (협력사) 견적 진행 결과를 조회하는 화면
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getQtaList(Map<String, String> formData) throws Exception{
        return qt0100Mapper.getQtaList(formData);
    }


}
