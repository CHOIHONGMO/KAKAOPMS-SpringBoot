package com.st_ones.evermp.buyer.rq.service;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.rq.RQ0100Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value="RQ0100Service")
public class RQ0100Service extends BaseService {

    @Autowired  private DocNumService docNumService;
    @Autowired  private LargeTextService largeTextService;
	@Autowired  private RQ0100Mapper rq0100mapper;
    @Autowired  private MessageService msg;
    @Autowired  private BAPM_Service approvalService;
    @Autowired  private EverMailService everMailService;

    public List<Map<String, Object>> getRfqHdList(Map<String, String> formData) throws IOException {
        return rq0100mapper.getRfqHdList(formData);
    }
    public List<Map<String, Object>> getRfqQtaList(Map<String, String> formData) throws IOException {
        return rq0100mapper.getRfqQtaList(formData);
    }




    public Map<String, Object> getRfqHd(Map<String, String> formData) throws IOException {
        return rq0100mapper.getRfqHd(formData);
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String chgRfqDate(Map<String, String> formData) throws Exception {
		String chgDate = "";
		String chgType = formData.get("CHG_TYPE");
		String rfxFromDate = formData.get("RFX_FROM_DATE");
		String rfxToDate = formData.get("RFX_TO_DATE");
		String rfxHh = formData.get("RFX_HH");
		String rfxMm = formData.get("RFX_MM");

		if ("START".equals(chgType)) {
			formData.put("CHG_DATE", " "+rfxFromDate+" "+rfxHh+":"+rfxMm+":00");
		} else {
			formData.put("CHG_DATE", " "+rfxToDate+" "+rfxHh+":"+rfxMm+":00");
		}



    	rq0100mapper.chgRfqDate(formData);
    	return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String transfer(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {

    	for(Map<String, Object> data :  gridData) {
    		data.put("CTRL_USER_ID", formData.get("CTRL_USER_TRANSFER_ID"));
    		data.put("CTRL_USER_NM", formData.get("CTRL_USER_TRANSFER_NM"));
        	rq0100mapper.transfer(data);
    	}

    	return msg.getMessage("0001");
    }




    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String closeRfq(List<Map<String, Object>> gridData) throws Exception {
    	for(Map<String, Object> data :  gridData) {
        	rq0100mapper.closeRfq(data);
    	}
    	return msg.getMessage("0001");
    }






    //-------------------------------------------------------------------------------------------

    //견적 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> insertRq(Map<String, String> formData, List<Map<String,Object>> gridL) throws Exception{
        Map<String, String> rtnMap = new HashMap<>();

        UserInfo userInfo = UserInfoManager.getUserInfo();

        String baseDataType  = formData.get("baseDataType");
        String rfxNum = formData.get("RFX_NUM");

        String rfxCnt = EverString.nullToEmptyString(formData.get("RFX_CNT")).equals("") ? "1" : formData.get("RFX_CNT");
        formData.put("RFX_CNT", rfxCnt);

        String signStatus = formData.get("SIGN_STATUS");
        String oldSignStatus = EverString.nullToEmptyString(rq0100mapper.getSignStatus(formData));
        String noticeTextNum = "";


        String appDocCnt = formData.get("APP_DOC_CNT");
        if(signStatus.equals("P")){
            if(EverString.isEmpty(appDocCnt)){
                formData.put("APP_DOC_NUM", docNumService.getDocNumber("AP"));
            }
            if(EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")){
                appDocCnt = "1";
            }else{
                if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }
            formData.put("APP_DOC_CNT", appDocCnt);
            formData.put("DOC_TYPE", "RQ");

            approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        }



        //재견적일때
        if( baseDataType.equals("RERFX") ) {
            formData.put("PROGRESS_CD","2550");
            rfxCnt = String.valueOf(Integer.parseInt(rfxCnt) + 1);
            formData.put("RFX_CNT", rfxCnt);
            rq0100mapper.insertRQHD(formData);
        } else {
            //최초 견적 저장
            if(EverString.isEmpty(rfxNum) ) {
                rfxNum = docNumService.getDocNumber(userInfo.getCompanyCd(), "RQ");
                formData.put("RFX_NUM", rfxNum);
                noticeTextNum = largeTextService.saveLargeText(null, formData.get("RMK_TEXT"));
                formData.put("RMK", noticeTextNum);
                rq0100mapper.insertRQHD(formData);
            } else {

                largeTextService.saveLargeText(formData.get("RMK"), formData.get("RMK_TEXT"));
                rq0100mapper.updateRQHD(formData);

            }

        }


        //업체 삭제
        rq0100mapper.deleteRQVN(formData);

        //품목정보 & 업체 저장
        for(Map<String, Object> data : gridL){
            data.put("GATE_CD", formData.get("GATE_CD"));
            data.put("BUYER_CD", formData.get("BUYER_CD"));
            data.put("PROGRESS_CD", formData.get("PROGRESS_CD"));
            data.put("RFX_NUM", rfxNum);
            data.put("RFX_CNT", rfxCnt);
            data.put("CUR", formData.get("CUR"));

            //재견적인 경우
            if(baseDataType.equals("RERFX")){
                data.put("INSERT_FLAG","I");
            }

            insertOrupdateRQDT(formData, data);
            insertRQVN(data, formData);
        }

        if(formData.get("PROGRESS_CD").equals("2300")){
            rtnMap.put("rtnMsg", msg.getMessage("0031"));
            rtnMap.put("gateCd",formData.get("GATE_CD"));
            rtnMap.put("buyerCd",formData.get("BUYER_CD"));
            rtnMap.put("rfxNum",rfxNum);
            rtnMap.put("rfxCnt",rfxCnt);
        }

        return rtnMap;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void insertOrupdateRQDT(Map<String,String> formData, Map<String,Object> gridData){

        String flag = String.valueOf(gridData.get("INSERT_FLAG"));

        if(flag.equals("I")){
            rq0100mapper.insertRQDT(gridData);
            if(!"".equals(gridData.get("PR_NUM"))) {
                gridData.put("PROGRESS_CD", "2300");
                rq0100mapper.updatePrdtProgress(gridData);
            }
        }else if(flag.equals("D")){
            rq0100mapper.deleteRQDT(gridData);
            if(!"".equals(gridData.get("PR_NUM"))){
                gridData.put("PROGRESS_CD","2200");
                rq0100mapper.updatePrdtProgress(gridData);
            }
        }else{
            rq0100mapper.updateRQDT(gridData);
        }

    }


    //제품별 협력사 등록
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void insertRQVN(Map<String, Object> gridData, Map<String, String> formData) throws Exception{

        if(gridData.get("VENDOR_CD_JSON") == null) return;

        String vendorList = String.valueOf(gridData.get("VENDOR_CD_JSON"));
        List<Map<String, Object>> list = new ObjectMapper().readValue(vendorList, List.class);

        for(Map<String, Object> map : list){
            map.put("BUYER_CD", formData.get("BUYER_CD"));
            map.put("RFX_NUM", formData.get("RFX_NUM"));
            map.put("RFX_CNT", formData.get("RFX_CNT"));
            map.put("PROGRESS_CD", "100");
            map.put("ITEM_CD", gridData.get("ITEM_CD"));
            map.put("ITEM_DESC", gridData.get("ITEM_DESC"));
            map.put("RFX_SQ", gridData.get("RFX_SQ"));
            rq0100mapper.insertRQVN(map);
        }
    }

    public Map<String, Object> getRfxHdDetail(Map<String, String> param) throws Exception{
        Map<String, Object> returnData = rq0100mapper.getRfxHdDetail(param);
        String splitString = largeTextService.selectLargeText(String.valueOf(returnData.get("RMK")));
        returnData.put("RMK_TEXT", splitString);
        return returnData;
    }

    public List<Map<String, Object>> getRfxDtDetail(Map<String, String> formData) throws Exception{
        List<Map<String, Object>> itemList = rq0100mapper.getRfxDtDetail(formData);

        for(Map<String,Object> item : itemList){
            List<Map<String,Object>> vendorListByitem = rq0100mapper.getRqvnByItem(item);
            item.put("VENDOR_CD_JSON", new ObjectMapper().writeValueAsString(vendorListByitem));
        }

        return itemList;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> deleteRFX(Map<String,String> formData) throws Exception{

        formData.put("_TABLE_NM", "STOPRQHD");
        rq0100mapper.deleteRFX(formData);

        formData.put("_TABLE_NM", "STOPRQDT");
        rq0100mapper.deleteRFX(formData);

        formData.put("_TABLE_NM", "STOPRQVN");
        rq0100mapper.deleteRFX(formData);

        Map<String, String> rtnMap = new HashMap<>();
        rtnMap.put("rtnMsg", msg.getMessage("0017"));
        return rtnMap;
    }


    //협력사 선택 창(RQ0110P02)
    public List<Map<String, Object>> getVendorListDefault(Map<String, Object> param){
        param.put("prBuyerCdList", Arrays.asList(String.valueOf(param.get("PR_BUYER_CD")).split(",")));
        return rq0100mapper.getVendorListDefault(param);
    }

    // 승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endRqApproval(String docNum, String docCnt, String signStatus) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);

        rq0100mapper.updateRqSignStatus(map);

        //승인 후 바로 협력사로 전송
        if(signStatus.equals("E")){
            Map<String,Object> rqdtList = getRfxHdDetail(map);
            rq0100mapper.sendRQ(rqdtList);

            //이메일 전송
            //Map<String,Object> formData = rq0100mapper.getRfxHdDetail(map);
            //sendEmail(formData);
        }
        
        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }
    
    /*
     * 2020.09.05 (미사용)
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void sendEmail(Map<String,Object> formData) throws Exception{

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.RFQ_TemplateFileName");

        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
		
		String maintainUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { maintainUrl = "https://"; }
		else { maintainUrl = "http://"; }
		if ("80".equals(domainPort)) {
			maintainUrl += domainNm;
		} else {
			maintainUrl += domainNm + ":" + domainPort;
		}
		maintainUrl += contextNm;
		
        // 협력업체 사용자 조회
        List<String> vendorCdList = rq0100mapper.getVendorCdListByRfx(formData);
        formData.put("VENDOR_LIST", vendorCdList);
        List<Map<String, Object>> vendorUserList = rq0100mapper.getVendorUserList(formData);
        
        String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        for (Map<String, Object> userList : vendorUserList) {
            String subject = userList.get("VENDOR_NM") + " 님. 귀사에 견적을 요청드립니다.";
            String trStart = "<tr>";
            String trEnd = "</tr>";
            String tdStart = "<td style=\"font-family:'나눔고딕',NanumGothic,'맑은고딕',Malgun Gothic,'돋움',Dotum,Helvetica,'Apple SD Gothic Neo',Sans-serif;position: relative;font-size: 15px; padding-left: 20px;font-weight: normal;font-stretch: normal;font-style: normal;line-height: 1.73;letter-spacing: -0.75px;text-align: left;color: #303030;\">";
            String tdEnd = "</td>";
            String spanCircle = "<span style=\"font-size:10px;vertical-align: text-top;\">●</span>";
            String contents  = trStart + tdStart;
            contents    += spanCircle + "<span style=\"font-weight: bold;\"> 견적번호 : </span>" + userList.get("RFX_NUM");
            contents    += tdEnd + trEnd;
            contents	+= trStart + tdStart;
            contents	+= spanCircle + "<span style=\"font-weight: bold;\"> 요청명 : </span>" + userList.get("RFX_SUBJECT");
            contents    += tdEnd + trEnd;
            contents	+= trStart + tdStart;
            contents	+= spanCircle + "<span style=\"font-weight: bold;\"> 견적요청자 : </span>" + userList.get("BUYER_NM") + " / " + userList.get("CTRL_USER_DEPT") + " / " + userList.get("CTRL_USER_NM") + " / " + userList.get("CTRL_USER_EMAIL");
            contents    += tdEnd + trEnd;
            contents	+= trStart + tdStart;
            contents	+= spanCircle + "<span style=\"font-weight: bold;\"> 마감일시 : </span>" + userList.get("RFX_TO_DATE");
            contents    += tdEnd + trEnd;

            fileContents = EverString.replace(fileContents, "$SUBJECT$", subject);
            fileContents = EverString.replace(fileContents, "$CONTENTS$", contents);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            if (!userList.get("EMAIL").equals("")) {
                Map<String, String> mdata = new HashMap<String, String>();
                mdata.put("SUBJECT", subject);
                mdata.put("CONTENTS_TEMPLATE", fileContents);
                mdata.put("RECV_USER_ID", String.valueOf(userList.get("USER_ID")));
                mdata.put("RECV_USER_NM", String.valueOf(userList.get("USER_NM")));
                mdata.put("RECV_EMAIL", String.valueOf(userList.get("EMAIL")));
                mdata.put("REF_NUM", "");
                mdata.put("REF_MODULE_CD", "BRQ");
                // 메일발송
                everMailService.sendMail(mdata);
                mdata.clear();
            }
        }
    }*/


    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0130)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getQtaList(Map<String, String> formData) throws Exception{
        return rq0100mapper.getQtaList(formData);
    }





    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 (RQ0140)
     * 처리내용 : (구매사) 개찰,선정 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getOpenSettleTargetList(Map<String, String> formData) throws Exception{
        return rq0100mapper.getOpenSettleTargetList(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveQtaOpen(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {
    	for(Map<String, Object> data : gridData) {
    		rq0100mapper.saveQtaOpen(data);

    		List<Map<String, Object>> qtItemlist = rq0100mapper.getDecAmtVendorList(data);

            int cou = 0;
        	for(Map<String, Object> qtItem : qtItemlist) {
                String key = qtItem.get("VENDOR_CD") + "ENCRIPT" + qtItem.get("VENDOR_CD");
                qtItem.put("HDEC_QTA_AMT",EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("HENC_QTA_AMT"))));
                qtItem.put("DDEC_UNIT_PRC",EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DENC_UNIT_PRC"))));
                qtItem.put("DDEC_QTA_AMT",EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DHENC_QTA_AMT"))));
                if (cou==0) {
               	 	rq0100mapper.updateDecodeQthd(qtItem);
                	cou = 1;
                }
           	 	rq0100mapper.updateDecodeQtdt(qtItem);
        	}



    	}
    	return msg.getMessage("0001");
	}



    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 (RQ0140P02)
     * 처리내용 : (구매사) 아이템별 협력사선정 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getSettleItemList(Map<String, String> formData) throws Exception{
        return rq0100mapper.getSettleItemList(formData);
    }



    public List<Map<String, Object>> getTargetVendor(Map<String, String> formData) throws Exception{
        return rq0100mapper.getTargetVendor(formData);
    }
    public List<Map<String, Object>> getTargetItemList(Map<String, String> formData) throws Exception{
        return rq0100mapper.getTargetItemList(formData);
    }













    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String setDocSettle(Map<String, String> formData) throws Exception {
    	formData.put("PROGRESS_CD", "2500"); // 업체선정
        rq0100mapper.setDocSettleCancelRqhd(formData);
        rq0100mapper.setDocSettleQtdt(formData);
//        if(1==1) throw new Exception("XXXXXXXXXXXXXXXXXXXXX");
    	return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelRfq(Map<String, String> formData) throws Exception {
    	formData.put("PROGRESS_CD", "1300"); // 유찰
        rq0100mapper.setDocSettleCancelRqhd(formData);
        rq0100mapper.setCancelPrdt(formData);
 //       if(1==1) throw new Exception("XXXXXXXXXXXXXXXXXXXXX");
    	return msg.getMessage("0001");
    }




    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String reRfq(Map<String, String> formData) throws Exception {
    	formData.put("PROGRESS_CD", "2550"); // 재견적
		formData.put("RFX_FROM_DATE2", " "+formData.get("RFX_FROM_DATE")+" "+formData.get("RFX_FROM_HOUR")+":"+formData.get("RFX_FROM_MIN")+":00");
		formData.put("RFX_TO_DATE2", " "+formData.get("RFX_TO_DATE")+" "+formData.get("RFX_TO_HOUR")+":"+formData.get("RFX_TO_MIN")+":00");

		Map<String, Object> hd = rq0100mapper.getRfqHd(formData);
		String rfqType = String.valueOf(hd.get("VENDOR_SLT_TYPE"));


		if("DOC".equals(rfqType)) {
			rq0100mapper.reRfqRqhd(formData);
	        rq0100mapper.reRfqRqdt(formData);
	        rq0100mapper.reRfqRqvn(formData);
	    	rq0100mapper.setDocSettleCancelRqhd(formData);
		} else {
			rq0100mapper.reRfqRqhd(formData);
	        rq0100mapper.reRfqRqdt(formData);
	        rq0100mapper.reRfqRqvn(formData);
	    	rq0100mapper.setDocSettleCancelRqhd(formData);
		}


        //if(1==1) throw new Exception("XXXXXXXXXXXXXXXXXXXXX");
    	return msg.getMessage("0001");
    }








    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doItemSettle(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {
    	formData.put("PROGRESS_CD", "2500"); // 업체선정
        rq0100mapper.setDocSettleCancelRqhd(formData);

        for (Map<String,Object> data : gridData) {
            rq0100mapper.setItemSettleQtdt(data);
        }


        //if(1==1) throw new Exception("XXXXXXXXXXXXXXXXXXXXX");
    	return msg.getMessage("0001");
    }




}