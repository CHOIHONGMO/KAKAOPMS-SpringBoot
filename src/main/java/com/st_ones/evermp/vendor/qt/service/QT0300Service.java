package com.st_ones.evermp.vendor.qt.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.evermp.vendor.qt.QT0300Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service(value="QT0310Service")
public class QT0300Service {

    @Autowired  private QT0300Mapper qt0300Mapper;
    @Autowired  private MessageService msg;
    @Autowired  private LargeTextService largeTextService;
    @Autowired  private DocNumService docNumService;
    @Autowired  private EverMailService everMailService;


    public List<Map<String,Object>> getRqList(Map<String,String> formData){

        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PR_BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("PR_BUYER_CD").split(",")));
        }

        return qt0300Mapper.getRqList(paramObj);
    }

    public void receiptRQVN(List<Map<String, Object>> gridDatas){

        for(Map<String,Object> gridData : gridDatas){
            gridData.put("PROGRESS_CD","200");
            qt0300Mapper.receiptRQVN(gridData);
        }

    }

    public Map<String,String> getQtHdSubmitData(Map<String,String> param) throws Exception{
        Map<String, String> returnData = qt0300Mapper.getQtHdSubmitData(param);
        /*String splitStringB = largeTextService.selectLargeText(String.valueOf(returnData.get("B_RMK")));
        returnData.put("B_RMK_TEXT", splitStringB);*/

        if(returnData.get("QTA_NUM") != null){
            /*String splitString = largeTextService.selectLargeText(String.valueOf(returnData.get("RMK")));
            returnData.put("RMK_TEXT", splitString);*/


            //복호화는 협력업체인 경우만 해당.
            UserInfo userInfo = UserInfoManager.getUserInfo();
            String userType = userInfo.getUserType();
            if(userType.equals(Code.SUPPLIER)) {
                String key = returnData.get("VENDOR_CD") + "ENCRIPT" + returnData.get("VENDOR_CD");
                returnData.put("QTA_AMT", EverEncryption.aes256Decode(key, returnData.get("ENC_QTA_AMT")));
            }
        }

        return returnData;
    }

    public List<Map<String,Object>> getQtdtSubmitData(Map<String,String> param) throws Exception{
        List<Map<String,Object>> gridDatas = qt0300Mapper.getQtdtSubmitData(param);

        //복호화는 협력업체인 경우만 해당.
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String userType = userInfo.getUserType();

        if(userType.equals(Code.SUPPLIER)){
            List<Map<String,Object>> rtnList = new ArrayList<>();
            String key = param.get("VENDOR_CD") + "ENCRIPT" + param.get("VENDOR_CD");
            for(Map<String,Object> gridData : gridDatas){
                gridData.put("UNIT_PRC",EverEncryption.aes256Decode(key, String.valueOf(gridData.get("ENC_UNIT_PRC"))));
                gridData.put("QTA_AMT",EverEncryption.aes256Decode(key, String.valueOf(gridData.get("ENC_QTA_AMT"))));
                gridData.remove("ENC_UNIT_PRC");
                gridData.remove("ENC_QTA_AMT");
                rtnList.add(gridData);
            }
            gridDatas = rtnList;
        }

        return gridDatas;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> saveOrSubmitQT(Map<String,String> formData, List<Map<String,Object>> gridDatas) throws Exception{

        //견적 마감일이 지난 경우 처리 불가
        String rfxEndFlag = qt0300Mapper.getRfqCloseFlag(formData);
        if(rfxEndFlag.equals("Y")){
            throw new Exception(msg.getMessage("0049"));
        }

        //이미 제출한 견적서가 있는 경우
        int checkExistQtByRq = qt0300Mapper.getCountExistSubmitQtByRq(formData);
        if(checkExistQtByRq != 0){
            throw new Exception(msg.getMessageByScreenId("QT0320","0005"));
        }

        //이미 저장한 견적서가 있는 경우(QTA_NUM이 다시 생성되는거 방지)
        int cnt = qt0300Mapper.checkExistsQtaCreation_QTHD(formData);
        if(cnt != 0 && EverString.isEmpty(formData.get("QTA_NUM"))){
            throw new Exception(msg.getMessageByScreenId("QT0320","0006"));
        }

        //견적 총 금액을 백단에서 각자 제품의 합으로 다시 구함.
        double totalQtAmt = 0;
        for(Map<String,Object> gridData : gridDatas){

            String rfxQt = gridData.get("RFX_QT") == null ? "0" : String.valueOf(gridData.get("RFX_QT"));
            String unitPrc = gridData.get("UNIT_PRC") == null ? "0" : String.valueOf(gridData.get("UNIT_PRC"));

            BigDecimal bigDecimal1 = new BigDecimal(rfxQt);
            BigDecimal bigDecimal2= new BigDecimal(unitPrc);
            double eachAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();
            totalQtAmt += eachAmt;
        }
        formData.put("QTA_AMT", String.valueOf(totalQtAmt));

        //헤더 암호화
        String key = formData.get("VENDOR_CD") + "ENCRIPT" + formData.get("VENDOR_CD");
        formData.put("ENC_QTA_AMT", EverEncryption.aes256Encode(key, formData.get("QTA_AMT")));
        formData.put("QTA_AMT", "0");

        String qtaNum = formData.get("QTA_NUM");
        if (EverString.isEmpty(qtaNum)){
            qtaNum = docNumService.getDocNumber(formData.get("BUYER_CD"),"QTA");
            formData.put("QTA_NUM", qtaNum);
        }

        /*String qtTextNo = EverString.nullToEmptyString(formData.get("RMK"));
        String textNo = largeTextService.saveLargeText(qtTextNo, EverString.nullToEmptyString(formData.get("RMK_TEXT")));
        formData.put("RMK", textNo);*/
        formData.put("PROGRESS_CD", formData.get("SEND_FLAG").equals("T") ? "250" : "300");

        //RQVN 테이블 업데이트
        qt0300Mapper.updateProgressCdRQVN(formData);

        // 헤더 저장
        if(cnt == 0){
            qt0300Mapper.insertQTHD(formData);
        }else{
            qt0300Mapper.updateQTHD(formData);
        }

        // 품목 저장
        for(Map<String,Object> gridData : gridDatas){
            gridData.put("QTA_NUM", formData.get("QTA_NUM"));
            gridData.put("VENDOR_CD", formData.get("VENDOR_CD"));

            //품목 암호화
            BigDecimal bigDecimal1 = new BigDecimal(String.valueOf(gridData.get("RFX_QT")));
            BigDecimal bigDecimal2= new BigDecimal(String.valueOf(gridData.get("UNIT_PRC")));
            double eachAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();

            gridData.put("ENC_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(gridData.get("UNIT_PRC"))));
            gridData.put("ENC_QTA_AMT", EverEncryption.aes256Encode(key, String.valueOf(eachAmt)));
            gridData.put("UNIT_PRC", "0");
            gridData.put("QTA_AMT", "0");
            gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));

            cnt = qt0300Mapper.checkExistsQtaCreation_QTDT(gridData);
            if(cnt == 0){
                qt0300Mapper.insertQTDT(gridData);
            }else{
                qt0300Mapper.updateQTDT(gridData);
            }
        }

        //협력사 전송
        if(formData.get("SEND_FLAG").equals("S")){
            cnt = qt0300Mapper.checkAlreadySubmitedQTA(formData);
            if(cnt==1){
                qt0300Mapper.submitQTHD(formData);
                qt0300Mapper.submitQTDT(formData);
            }else{
                throw new Exception(msg.getMessage("0044"));
            }
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
            String checkCnt = qt0300Mapper.checkRqvnProgressCd(gridData);
            if ( "300".equals(checkCnt) || "400".equals(checkCnt) || "150".equals(checkCnt) ) {
                throw new NoResultException(msg.getMessage("0044"));
            }
            qt0300Mapper.waiveRQVN(gridData);
        }
        return msg.getMessage("0001");
    }

    /********************************************************************************************
     * 협력사 > 견적관리 > 견적관리 > 견적결과 (QT0220)
     * 처리내용 : (협력사) 견적 진행 결과를 조회하는 화면
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getQtaList(Map<String, String> formData) throws Exception{
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PR_BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("PR_BUYER_CD").split(",")));
        }
        return qt0300Mapper.getQtaListByVendor(paramObj);
    }

	public List<Map<String, Object>> doSearchT(Map<String, String> param) throws Exception {
		List<Map<String, Object>> returnData = null ;
		if(param.get("scrId").equals("0310")) {
			returnData=this.getQtdtSubmitData(param);
		}else {
			returnData=qt0300Mapper.getQtdtSubmitData(param);
		}
		// TODO Auto-generated method stub
		return returnData;
	}


}
