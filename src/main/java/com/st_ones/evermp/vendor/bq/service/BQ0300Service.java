package com.st_ones.evermp.vendor.bq.service;

import com.ktnet.license.LicenseVerifyUtil;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.evermp.buyer.bd.BD0300Mapper;
import com.st_ones.evermp.vendor.bq.BQ0300Mapper;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import tradesign.crypto.cert.validator.ExtendedPKIXParameters;
import tradesign.crypto.cert.validator.PKIXCertPath;
import tradesign.crypto.provider.JeTS;
import tradesign.pki.pkix.SignedData;
import tradesign.pki.pkix.X509CRL;
import tradesign.pki.pkix.X509Certificate;

import java.math.BigDecimal;
import java.net.InetAddress;
import java.security.cert.CertPathValidator;
import java.security.cert.PKIXCertPathValidatorResult;
import java.util.*;

@Service(value="BQ0310Service")
public class BQ0300Service {

    @Autowired  private BQ0300Mapper bq0300Mapper;
    @Autowired  private MessageService msg;
    @Autowired  private LargeTextService largeTextService;
    @Autowired  private DocNumService docNumService;
    @Autowired  private BD0300Mapper bd0300Mapper;
    @Autowired  private EverMailService everMailService;

    /********************************************************************************************
     * 협력사 > 구매관리 > 입찰관리 > 입찰현황 (BQ0310)
     * 처리내용 : (협력사) 입찰 요청 현황을 조회하는 화면
     */

    public List<Map<String,Object>> getBdList(Map<String,String> formData){
        return bq0300Mapper.getBdList(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void receiptBDVN(List<Map<String, Object>> gridDatas) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        for(Map<String,Object> gridData : gridDatas){
        	//접수백엔드 체크.
        	int checkPrgressCd = bq0300Mapper.checkPrgressCd(gridData);
        	if (checkPrgressCd > 0) {
                throw new Exception(msg.getMessageByScreenId("BQ0310", "0001"));
            }
            if(gridData.get("VENDOR_OPEN_TYPE").equals("OB")){
                if(!String.valueOf(gridData.get("RFX_CNT")).equals("1")) {
                    //공개 입찰에서 입찰요청 차수가 2 이상일 때 이전 차수에 참여한 업체가 아닌 경우 접수 불가
                    gridData.put("PREV_RFX_CNT", Integer.parseInt(String.valueOf(gridData.get("RFX_CNT"))) - 1);
                    int check = bq0300Mapper.checkParticipationPrevBd(gridData);
                    if (check == 0) {
                        throw new Exception(msg.getMessageByScreenId("BQ0310", "0008"));
                    }

                }

                if(String.valueOf(gridData.get("HIDDEN_QTA_CNT")).equals("1")) {
                    //최초 투찰인 경우 BDVO에 데이터 넣어줌.
                    List<Map<String,Object>> bddtList = bq0300Mapper.getBddtForOBReceipt(gridData);
                    for(Map<String,Object> bddt : bddtList){
                        bddt.put("PROGRESS_CD","200");
                        try{
                            bq0300Mapper.insertBDVNForOBReceipt(bddt);
                        }catch (Exception e){
                            throw new Exception(msg.getMessageByScreenId("BQ0310","0009"));
                        }
                    }
                    gridData.put("VENDOR_CD", userInfo.getCompanyCd());
                    gridData.put("QTA_CNT", gridData.get("HIDDEN_QTA_CNT"));
                    bd0300Mapper.saveBDVO(gridData);
                }else{
                    //투찰 차수가 2 이상인 경우는 BDVN에서 접수상태만 변경해줌. (구매담당자가 재투찰 요청 시 BDVN에 데이터 넣어줌)
                    gridData.put("PROGRESS_CD","200");
                    gridData.put("QTA_CNT", gridData.get("HIDDEN_QTA_CNT"));
                    bq0300Mapper.receiptBDVN(gridData);
                }
            }else{
                gridData.put("PROGRESS_CD","200");
                bq0300Mapper.receiptBDVN(gridData);
                gridData.put("QTA_CNT", gridData.get("HIDDEN_QTA_CNT"));
            }

            bq0300Mapper.receiptBDVO(gridData);
            if(gridData.get("VENDOR_OPEN_TYPE").equals("OB")){
                sendKakaoAndEmailBdReceipt(gridData);
            }

        }

    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void sendKakaoAndEmailBdReceipt(Map<String,Object> param) throws Exception{

        List<Map<String, String>> contactInfo = bq0300Mapper.getInfoForEmail(param);
        boolean firstBid = String.valueOf(param.get("HIDDEN_QTA_CNT")).equals("1");

        for(Map<String,String> contact : contactInfo){

            Map<String,String> receiveUser = new HashMap<>();
            receiveUser.put("DIRECT_TARGET", contact.get("VENDOR_EMAIL"));
            receiveUser.put("DIRECT_USER_NM", contact.get("VENDOR_USER_NM"));
            receiveUser.put("DIRECT_CELL_NUM", contact.get("VENDOR_CELL_NUM"));
            receiveUser.put("VENDOR_CD", contact.get("VENDOR_CD"));


            String ctrlUserNm = contact.get("CTRL_USER_NM") == null ? " " : contact.get("CTRL_USER_NM");
            String ctrlUserPosition = contact.get("CTRL_USER_POSITION") == null ? " " : contact.get("CTRL_USER_POSITION");
            String ctrlUserTel = contact.get("CTRL_USER_TEL") == null ? " " : contact.get("CTRL_USER_TEL");
            String ctrlUserCell = contact.get("CTRL_USER_CELL") == null ? " " : contact.get("CTRL_USER_CELL");
            String ctrlUserEmail = contact.get("CTRL_USER_EMAIL") == null ? " " : contact.get("CTRL_USER_EMAIL");


            //메일 보내기
            StringBuffer contentEmail = new StringBuffer();
            contentEmail.append("안녕하세요.\n");
            if(firstBid){
                contentEmail.append("삼양 [통합구매시스템]에 <span style=\"font-weight:700;color:red;\">입찰 참여요청</span>이 접수되었습니다.\n");
            }else{
                contentEmail.append("삼양 [통합구매시스템]에 <span style=\"font-weight:700;color:red;\">(재)입찰 참여요청</span>이 접수되었습니다.\n");
            }


            StringBuffer sendorInfo = new StringBuffer();
            sendorInfo.append("요청 담당자 : ").append(ctrlUserNm).append(" ").append(ctrlUserPosition);
            sendorInfo.append(" (").append(ctrlUserTel).append(" / ").append(ctrlUserCell).append(")\n");
            sendorInfo.append("요청 담당자 이메일 주소 : ").append(ctrlUserEmail);

            String subject = "[삼양] 견적요청이 접수되었습니다";
            String contents = contentEmail.toString();
            String companyNm = "삼양";
            String destUrl = "http://localhost:8090";


            String emailContents = "";

            receiveUser.put("SUBJECT", subject);
            receiveUser.put("CONTENTS_TEMPLATE", emailContents);

            //if (PropertiesManager.getBoolean("eversrm.system.mail.send.flag")) {
            //    everMailService.sendMessage(receiveUser);
            //}
        }
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String waiveBD(List<Map<String,Object>> gridDatas) throws Exception{

        for(Map<String,Object> gridData : gridDatas){
            String checkCnt = bq0300Mapper.checkBDVN_ProgressCd(gridData);
            if ( "150".equals(checkCnt) || "400".equals(checkCnt) ) {
                throw new Exception(msg.getMessage("0044"));
            }
            bq0300Mapper.waiveBDVN(gridData);
            gridData.put("PROGRESS_CD","150");
            bq0300Mapper.updateProgressCdBQDT((Map)gridData);
        }
        return msg.getMessage("0001");
    }


    /********************************************************************************************
     * 협력사 > 구매관리 > 입찰관리 > 입찰현황 > 입찰요청서 조회 (BQ0310P01)
     * 처리내용 : 구매사에서 입찰요청작성한 내용 상세 조회 팝업
     */

    public Map<String,String> BQ0310P01_getBDDetail(Map<String,String> param){
        return bq0300Mapper.BQ0310P01_getBDDetail(param);
    }



    /********************************************************************************************
     * 협력사 > 구매관리 > 입찰관리 > 입찰서 (BQ0320)
     * 처리내용 : (협력사) 입찰서 저장 또는 전송하는 화면
     */


    public Map<String,String> getBqHdSubmitData(Map<String,String> param) throws Exception{
        Map<String, String> returnData = bq0300Mapper.getBqHdSubmitData(param);
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

    public List<Map<String,Object>> getBqdtSubmitData(Map<String,String> param) throws Exception{
        List<Map<String,Object>> gridDatas = bq0300Mapper.getBqdtSubmitData(param);

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
    public Map<String, String> saveOrSubmitBq(Map<String,String> formData, List<Map<String,Object>> gridDatas) throws Exception{

        //견적 마감일이 지난 경우 처리 불가
        String rfxEndFlag = bq0300Mapper.getBdRfqCloseFlag(formData);
        if(rfxEndFlag.equals("Y")){
            throw new Exception(msg.getMessageByScreenId("BQ0320","0007"));
        }

        //이미 제출한 입찰서가 있는 경우
        int existSubmitBq = bq0300Mapper.getBqSubmitExist(formData);
        if(existSubmitBq != 0){
            throw new Exception(msg.getMessageByScreenId("BQ0320","0005"));
        }

        //이미 저장된 입찰서가 있는 경우(QTA_NUM이 생성된 경우 다시 생성되는거 방지)
        int existSavedBq = bq0300Mapper.getExistBqNum(formData);
        if(existSavedBq != 0 && gridDatas.get(0).get("QTA_SQ") == null){
            throw new Exception(msg.getMessageByScreenId("BQ0320","0006"));
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

        String qtaNum = formData.get("HIDDEN_QTA_NUM");
        if (EverString.isEmpty(qtaNum)){
            qtaNum = docNumService.getDocNumber(formData.get("BUYER_CD"),"QTB");
        }
        formData.put("QTA_NUM", qtaNum);
        formData.put("QTA_CNT", formData.get("HIDDEN_QTA_CNT"));

        /*String qtTextNo = EverString.nullToEmptyString(formData.get("RMK"));
        String textNo = largeTextService.saveLargeText(qtTextNo, EverString.nullToEmptyString(formData.get("RMK_TEXT")));
        formData.put("RMK", textNo);*/
        formData.put("PROGRESS_CD", formData.get("SEND_FLAG").equals("T") ? "250" : "300");
        //BDVN 테이블 업데이트
        bq0300Mapper.updateProgressCdBDVN(formData);
        InetAddress local = InetAddress.getLocalHost();

		String ADDR = local.getHostAddress();
		formData.put("IP_ADDR", ADDR);
        // 헤더 저장
        bq0300Mapper.saveBQHD(formData);

        // 품목 저장
        for(Map<String,Object> gridData : gridDatas){
            gridData.put("QTA_NUM", formData.get("QTA_NUM"));
            gridData.put("QTA_CNT", formData.get("QTA_CNT"));

            //품목 암호화
            BigDecimal bigDecimal1 = new BigDecimal(String.valueOf(gridData.get("RFX_QT")));
            BigDecimal bigDecimal2= new BigDecimal(String.valueOf(gridData.get("UNIT_PRC")));
            double eachAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();

            gridData.put("ENC_UNIT_PRC", EverEncryption.aes256Encode(key, String.valueOf(gridData.get("UNIT_PRC"))));
            gridData.put("ENC_QTA_AMT", EverEncryption.aes256Encode(key, String.valueOf(eachAmt)));
            gridData.put("UNIT_PRC", "0");
            gridData.put("QTA_AMT", "0");
            gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));

            bq0300Mapper.saveBQDT(gridData);

        }

        //협력사 전송
        if(formData.get("SEND_FLAG").equals("S")){

            int cnt = bq0300Mapper.checkAlreadySubmitedBQ(formData);
            if(cnt==1){

            	try {
                    JeTS.installProvider(PropertiesManager.getString("net.tradesign.properties.path"));
                } catch(Exception e) {
                    throw new Exception("서버인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
                }

                System.err.println("========================formData.get(\"SIGN_VALUE\")========="+formData.get("SIGN_VALUE"));
                SignedData sd = new SignedData(String.valueOf(formData.get("SIGN_VALUE")).getBytes("euc-kr"));

        		X509Certificate[] certs = sd.verify();
        		String expreason[] = null;
        		String expyn[] = null;
        		String expday[] = null;

        		expreason  = new String[certs.length];
        		expyn  = new String[certs.length];
        		expday  = new String[certs.length];

        		// 인증서 검증 및 DN 정보 출력
        		for (int i = 0; i < certs.length; i++)
        		{
        			PKIXCertPath cp = new PKIXCertPath(certs[i], "PkiPath");
        			ExtendedPKIXParameters cpp = new ExtendedPKIXParameters(JeTS.getTAnchorSet());
        			CertPathValidator cpvi = CertPathValidator.getInstance("PKIX","JeTS");
        			PKIXCertPathValidatorResult cpvr = (PKIXCertPathValidatorResult) cpvi.validate(cp, cpp);
        			System.err.println("==============cpvr========="+cpvr);
        			System.out.println("검증성공:" + certs[i].getSubjectDNStr());



        			X509CRL crl = new X509CRL(certs[i].getCrlDp(), true);
        			boolean r= crl.isRevoked(certs[i].getSerialNumber());

        			if(r){
        				expyn[i] = "폐지됨";
        				expday[i] = crl.getRevokedDate().toString();
        				if( crl.getRevokedReason() == null ) expreason[i] = "없음";
        				else expreason[i] = crl.getRevokedReason();

        				throw new Exception("해당인증서는 폐지되었습니다.");
        			}
        			else{
        				expyn[i] = "유효함";
        				System.err.println("=============인증서=유효함=========");
        			}

        		}

        		// 유효기간 시작시각(Validity notBefore) 추출
        		Date notBefore = certs[0].getNotBefore();
        		if (notBefore != null) {
        			System.out.println("유효기간 시작시각: " + notBefore);
        		} else {
                    throw new Exception("인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
        		}
        		// 유효기간 종료시각(Validity notAfter) 추출
        		Date notAfter = certs[0].getNotAfter();
        		if (notAfter != null) {
        			System.out.println("유효기간 종료시각: " + notAfter);
        		} else {
                    throw new Exception("인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
        		}
        		System.err.println("===============================notBefore="+notBefore);
        		System.err.println("===============================notAfter="+notAfter);
        		String expireMessage = null;
        		LicenseVerifyUtil.verifyTime(notBefore, notAfter);
        		long validToDate = Long.parseLong(DateFormatUtils.format(DateUtils.addDays(notAfter, -14), "yyyyMMddHHmmss"));
        		long validToDate2 = Long.parseLong(DateFormatUtils.format(DateUtils.addDays(notAfter, 0), "yyyyMMddHHmmss"));
        		long currentDate = Long.parseLong(DateFormatUtils.format(new Date(), "yyyyMMddHHmmss"));
        		if(currentDate > validToDate) {
        			//expireMessage = "서버용 인증서의 만료기한이 얼마남지 않았습니다.\n(만료일자: "+notAfter+")\n관리자에게 문의해 주시기 바랍니다.";
        		}

        		if(currentDate > validToDate2) {
        			throw new Exception("인증서 유효기간이 만료되었습니다.\n관리자에게 문의해주시기 바랍니다.");
        		}

                formData.put("PROGRESS_CD","300");
                bq0300Mapper.submitBQHD(formData);
                bq0300Mapper.updateProgressCdBQDT(formData);
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


    /********************************************************************************************
     * 협력사 > 견적관리 > 견적관리 > 입찰결과 (BQ0330)
     * 처리내용 : (협력사) 견적 진행 결과를 조회하는 화면
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getBqList(Map<String, String> formData) throws Exception{
        return bq0300Mapper.getBqListByVendor(formData);
    }


}
