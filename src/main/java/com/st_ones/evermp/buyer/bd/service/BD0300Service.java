package com.st_ones.evermp.buyer.bd.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.bd.BD0300Mapper;
import com.st_ones.evermp.buyer.eval.EV0210Mapper;
import com.st_ones.evermp.buyer.eval.EV0250Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.*;

@Service(value="BD0300Service")
public class BD0300Service extends BaseService {

    @Autowired  private DocNumService docNumService;
    @Autowired  private LargeTextService largeTextService;
	@Autowired  private BD0300Mapper bd0300Mapper;
    @Autowired  private MessageService msg;
    @Autowired  private EverMailService everMailService;
    @Autowired  private EV0210Mapper ev0210Mapper;
    @Autowired  private EV0250Mapper ev0250Mapper;
    @Autowired  private EverSmsService everSmsService;
    @Autowired private BAPM_Service  bapm_Service;
    @Autowired private QueryGenService queryGenService;

    /*****************BD0310******************/
    //엑셀 업로드
    public List<Map<String, Object>> doSetExcelImportItem(List<Map<String,Object>> gridDatas){

        List<Map<String, Object>> rtnGrid = new ArrayList<>();
        for(Map<String,Object> grid : gridDatas){

            double rfxQt = Double.parseDouble(String.valueOf(grid.get("RFX_QT") == null ? 0 : grid.get("RFX_QT")) );
            double unitPrc = Double.parseDouble(String.valueOf(grid.get("UNIT_PRC") == null ? 0 : grid.get("UNIT_PRC")));


            BigDecimal bigDecimal1 = new BigDecimal(rfxQt);
            BigDecimal bigDecimal2= new BigDecimal(unitPrc);
            double rfxAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();
            grid.put("RFX_AMT", rfxAmt);

            Map<String, Object> item = bd0300Mapper.doSetExcelImportItemRfx(grid);
            if(item != null){
                grid.putAll(item);
            }
            rtnGrid.add(grid);
        }

        return rtnGrid;
    }

    //입찰 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> saveBD(Map<String, String> formData, List<Map<String,Object>> gridL, List<Map<String,Object>> gridDEL) throws Exception{
        Map<String, String> rtnMap = new HashMap<>();

        UserInfo userInfo = UserInfoManager.getUserInfo();

        String baseDataType  = formData.get("baseDataType");

        String rfxNum = EverString.nullToEmptyString(formData.get("RFX_NUM"));
        String rfxCnt = EverString.nullToEmptyString(formData.get("RFX_CNT")).equals("") ? "1" : formData.get("RFX_CNT");
        formData.put("RFX_CNT", rfxCnt);

        String signStatus = formData.get("SIGN_STATUS");
        if(signStatus.equals("T")){ formData.put("PROGRESS_CD", "2600");}
        else if(signStatus.equals("E")){ formData.put("PROGRESS_CD", "2650");}

        //이미 기존에 전송한 경우
        String oldSignStatus = "";
        if (!"".equals(rfxNum)) {
            oldSignStatus = EverString.nullToEmptyString(bd0300Mapper.getSignStatus(formData));
            if (!baseDataType.equals("RERFX") && oldSignStatus.equals("E")){
                throw new NoResultException(msg.getMessage("0044"));
            }
        }

        /**
        String noticeTextNum = "";
        String noticeTextNumIn = "";
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
            formData.put("DOC_TYPE", "QT");

            approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        }*/

        //헤더 부분 입력
        if( baseDataType.equals("RERFX") ) {
            //재견적일때
            bd0300Mapper.updateRerfxBdhd(formData);
            bd0300Mapper.updateRerfxBddt(formData);

            rfxCnt = String.valueOf(Integer.parseInt(rfxCnt) + 1);
            formData.put("RFX_CNT", rfxCnt);

            /* 리치텍스트를 사용하는 경우 사용량이 많을 시 데이터베이스 락이 걸려서 Textarea로 변경.
            noticeTextNum = largeTextService.saveLargeText(null, formData.get("RMK_TEXT"));
            noticeTextNumIn = largeTextService.saveLargeText(null, formData.get("RMK_IN_TEXT"));
            formData.put("RMK", noticeTextNum);
            formData.put("RMK_IN", noticeTextNumIn);*/
            insertBddt( formData, gridL,  gridDEL);
            bd0300Mapper.insertBDHD(formData);
        }
        else {
            //최초 견적 저장
            if(EverString.isEmpty(rfxNum) ) {
                rfxNum = docNumService.getDocNumber(userInfo.getCompanyCd(), "RFP");
                formData.put("RFX_NUM", rfxNum);
                /*noticeTextNum = largeTextService.saveLargeText(null, formData.get("RMK_TEXT"));
                noticeTextNumIn = largeTextService.saveLargeText(null, formData.get("RMK_IN_TEXT"));
                formData.put("RMK", noticeTextNum);
                formData.put("RMK_IN", noticeTextNumIn);*/
                insertBddt( formData, gridL,  gridDEL);
                bd0300Mapper.insertBDHD(formData);
            } else {
                /*largeTextService.saveLargeText(formData.get("RMK"), formData.get("RMK_TEXT"));
                largeTextService.saveLargeText(formData.get("RMK_IN"), formData.get("RMK_IN_TEXT"));*/
                insertBddt( formData, gridL,  gridDEL);
                bd0300Mapper.updateBDHD(formData);
            }
        }

        // 입찰설명회 저장
        bd0300Mapper.deleteBDAN(formData);
        if(formData.get("ANN_FLAG").equals("1")){
            bd0300Mapper.insertBDAN(formData);
        }

        // 협력사 전송을 클릭한 경우 협력사 전송
        if (signStatus.equals("T")){
            //저장을 클릭했으나 협력사 전송한 상태인경우
            if (oldSignStatus.equals("E")){
                throw new NoResultException(msg.getMessage("0044"));
            }
        }

        if(formData.get("PROGRESS_CD").equals("2600")){
            rtnMap.put("rtnMsg", msg.getMessage("0031"));   //성공적으로 저장되었습니다.
            rtnMap.put("gateCd",formData.get("GATE_CD"));
            rtnMap.put("buyerCd",formData.get("BUYER_CD"));
            rtnMap.put("rfxNum",rfxNum);
            rtnMap.put("rfxCnt",rfxCnt);
        }
        else if(formData.get("PROGRESS_CD").equals("2650")) {
            rtnMap.put("rtnMsg", msg.getMessageByScreenId("BD0310","0008"));
        }

        return rtnMap;
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void insertBddt(Map<String, String> formData, List<Map<String,Object>> gridL, List<Map<String,Object>> gridDEL) throws Exception{

        double rfxAmt = 0.0;
        String rfxNum = formData.get("RFX_NUM");
        String baseDataType = formData.get("baseDataType");
        String rfxCnt = formData.get("RFX_CNT");

        //삭제된 품목 구매진행현황 복원
        for(Map<String,Object> griddel : gridDEL){
            griddel.put("PROGRESS_CD", "2200");
            bd0300Mapper.updatePrdtProgress(griddel);
        }

        //품목전체 삭제
        bd0300Mapper.deleteBDDT(formData);
        //업체 삭제
        bd0300Mapper.deleteBDVN(formData);
        bd0300Mapper.deleteBDVO(formData);
        int rfxSq=1;
        //품목정보 & 업체 저장
        for(Map<String, Object> gridData : gridL){
            gridData.put("GATE_CD", formData.get("GATE_CD"));
            gridData.put("BUYER_CD", formData.get("BUYER_CD"));
            gridData.put("RFX_NUM", rfxNum);
            gridData.put("CUR", formData.get("CUR"));
            gridData.put("DELY_TYPE", formData.get("DELY_TYPE")); //배송유형 추가 2022-08-04
            gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));
            gridData.put("RFX_SQ", rfxSq);
            gridData.put("RFX_CNT", rfxCnt); //재견적인 경우 이미 +1 된 값으로 들어옴
            rfxSq++;
            String rfxQt = gridData.get("RFX_QT") == null ? "0" : String.valueOf(gridData.get("RFX_QT"));
            String unitPrc = gridData.get("UNIT_PRC") == null ? "0" : String.valueOf(gridData.get("UNIT_PRC"));

            BigDecimal bigDecimal1 = new BigDecimal(rfxQt);
            BigDecimal bigDecimal2= new BigDecimal(unitPrc);
            double eachAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();
            gridData.put("RFX_AMT", eachAmt);
            bd0300Mapper.updatePrdtProgress(gridData);
            bd0300Mapper.insertBDDT(gridData);
            insertBDVN(gridData, formData);
            if(gridData.get("UNIT_PRC") == null){gridData.put("UNIT_PRC","0");}
            rfxAmt += eachAmt;
        }

        DecimalFormat df = new DecimalFormat("#");
        df.setMaximumFractionDigits(4);

        //총 금액 넣어주기
        formData.put("RFX_AMT", df.format(rfxAmt));
    }

    //제품별 협력사 등록
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void insertBDVN(Map<String, Object> gridData, Map<String, String> formData) throws Exception{

        if(gridData.get("VENDOR_JSON") == null) return;

        String vendorList = String.valueOf(gridData.get("VENDOR_JSON"));
        List<Map<String, Object>> list = new ObjectMapper().readValue(vendorList, List.class);

        for(Map<String, Object> map : list){
            map.put("BUYER_CD", formData.get("BUYER_CD"));
            map.put("RFX_NUM", formData.get("RFX_NUM"));
            map.put("RFX_CNT", formData.get("RFX_CNT"));
            map.put("PROGRESS_CD", "100");
            map.put("ITEM_CD", gridData.get("ITEM_CD"));
            map.put("ITEM_DESC", gridData.get("ITEM_DESC"));
            map.put("RFX_SQ", gridData.get("RFX_SQ"));
            bd0300Mapper.insertBDVN(map);

            map.putAll(formData);
            map.put("QTA_CNT","1");
            bd0300Mapper.saveBDVO(map);

        }
    }

    //헤더 정보 불러오기.
    public Map<String, Object> getBdHdDetail(Map<String, String> param) throws Exception{
        Map<String, Object> returnData = bd0300Mapper.getBdHdDetail(param);
        /*String splitString = largeTextService.selectLargeText(String.valueOf(returnData.get("RMK")));
        returnData.put("RMK_TEXT", splitString);
        String splitStringIn = largeTextService.selectLargeText(String.valueOf(returnData.get("RMK_IN")));
        returnData.put("RMK_IN_TEXT", splitStringIn);*/
        return returnData;
    }

    //제품별 해당 협력사 가져오기
    public List<Map<String, Object>> getRfxDtDetail(Map<String, String> formData) throws Exception{
    	
        List<Map<String, Object>> itemList = bd0300Mapper.getBdDtDetail(formData);
        List<Map<String, Object>> vendorList = bd0300Mapper.getVendorListByBdRfx(formData);
        for(Map<String,Object> item : itemList){
            //협력업체를 제품별로 쿼리로 불러오는 부분은 주석처리
            List<Map<String, Object>> vendorlistContainItem = new ArrayList<>();
            for(Map<String,Object> vendor : vendorList){
                if(item.get("RFX_SQ").equals(vendor.get("RFX_SQ"))){
                   vendorlistContainItem.add(vendor);
                }
            }
            item.put("VENDOR_JSON", new ObjectMapper().writeValueAsString(vendorlistContainItem));
        }
        return itemList;
    }

    //구매요청접수에서 접근할 때 업체 정보를 가져옴
    public List<Map<String,Object>> getRfxDtDetailFromPrList(String prList) throws Exception{
        JSONArray jsonArray = new JSONArray(prList);
        List<Map<String,Object>> rtnList = new ArrayList<>();
        for(Object item : jsonArray){
            JSONObject jsonObject = (JSONObject)item;
            Map<String, Object> map = new ObjectMapper().readValue(jsonObject.toString(), Map.class);
            List<Map<String,Object>> vendorListByitem = bd0300Mapper.getVendorListFromVnglCvur(map);
            JSONArray jsonArrayVendor = new JSONArray(vendorListByitem);
            map.put("VENDOR_JSON", jsonArrayVendor);
            rtnList.add(map);
        }
        return rtnList;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> deleteBD(Map<String,String> formData, List<Map<String,Object>> gridDatas) throws Exception{
    	
    	// 작성중, 반려, 상신취소인 경우에만 삭제 가능
    	// 2023.01.17 : 입찰대기(2650)인 경우에도 삭제 가능하도록 함
        String signStatus = bd0300Mapper.getSignStatus(formData);
        if( "T".equals(signStatus) || "R".equals(signStatus) || "C".equals(signStatus) ){
            bd0300Mapper.updateBDHDDEL(formData);
            bd0300Mapper.updateBDDTDEL(formData);
            bd0300Mapper.updateBDVNDEL(formData);
            bd0300Mapper.deleteBDAN(formData);
        } else {
            throw new Exception(msg.getMessage("0044"));
        }

        //삭제된 품목 구매진행현황 복원
        for(Map<String,Object> gridData : gridDatas){
        	if("".equals(EverString.nullToEmptyString(gridData.get("PR_NUM")))) continue;
            gridData.put("PROGRESS_CD", "2200");
            bd0300Mapper.updatePrdtProgress(gridData);
        }

        Map<String, String> rtnMap = new HashMap<>();
        rtnMap.put("rtnMsg", msg.getMessage("0017"));
        return rtnMap;
    }

    // 협력업체 전송 승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endRqApproval(String docNum, String docCnt, String signStatus) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);

        bd0300Mapper.updateBdSignStatus(map);

        //승인 후 바로 협력사로 전송
        if(signStatus.equals("E")){
            Map<String,Object> bdhdList = getBdHdDetail(map);
            bd0300Mapper.sendBD(bdhdList);

        }

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }

    /*******************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 입찰요청현황 (BD0320)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     *
     */
    public List<Map<String, Object>> getBdHdList(Map<String, String> formData) throws IOException {

        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }
        return bd0300Mapper.getBdHdList(paramObj);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String transferBdCtrlUser(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {

        for(Map<String, Object> data :  gridData) {
            data.put("CTRL_USER_ID"	    , formData.get("CTRL_USER_TRANSFER_ID"));
            data.put("CTRL_USER_NM"		, formData.get("CTRL_USER_TRANSFER_NM"));
            data.put("OPEN_BID_USER_ID" , formData.get("OPEN_USER_TRANSFER_ID"));
            bd0300Mapper.transferBdCtrlUser(data);
        }
        return msg.getMessage("0001");
    }

    public List<Map<String, Object>> getRfqQtaList(Map<String, String> formData) throws IOException {
        return bd0300Mapper.getRfqQtaList(formData);
    }

    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 입찰서 현황 (BD0330)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getBqList(Map<String, String> formData) throws Exception{

        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PR_BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("PR_BUYER_CD").split(",")));
        }
        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }

        return bd0300Mapper.getBqList(paramObj);
    }





    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 (BD0340)
     * 처리내용 : (구매사) 개찰,선정 조회하는 화면
     *
     */

    public Map<String,Object> getBdHdForEV(Map<String,String> param){
        return bd0300Mapper.getBdHdForEV(param);
    }

    public List<Map<String, Object>> getBdOpenSettleTargetList(Map<String, String> formData) throws Exception{
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PR_BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("PR_BUYER_CD").split(",")));
        }
        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }

        return bd0300Mapper.getBdOpenSettleTargetList(paramObj);
    }

    // 견적서 개찰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveBQOpen(List<Map<String, Object>> gridData) throws Exception {

        DecimalFormat df = new DecimalFormat("#");
        df.setMaximumFractionDigits(4);

    	for(Map<String, Object> data : gridData) {
    	    if(data.get("PROGRESS_CD").equals("2750")){
                bd0300Mapper.saveBdOpenHd(data);
                bd0300Mapper.saveBdOpenDt(data);

                //개찰 : QTHD 복호화
                List<Map<String, Object>> qtVendorlist = bd0300Mapper.getDecAmtVendorListForBdOpen(data);
                for(Map<String, Object> qtVendor : qtVendorlist){
                    String key = qtVendor.get("VENDOR_CD") + "ENCRIPT" + qtVendor.get("VENDOR_CD");
                    qtVendor.put("HDEC_QTA_AMT",df.format(Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtVendor.get("HENC_QTA_AMT"))))));
                    bd0300Mapper.updateDecodeBqhd(qtVendor);
                }

                //개찰 : QTDT 복호화
                List<Map<String, Object>> qtItemlist = bd0300Mapper.getDecAmtItemListForBdOpen(data);
                for(Map<String, Object> qtItem : qtItemlist) {
                    String key = qtItem.get("VENDOR_CD") + "ENCRIPT" + qtItem.get("VENDOR_CD");
                    qtItem.put("DDEC_UNIT_PRC", df.format((Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DENC_UNIT_PRC")))))));
                    qtItem.put("DDEC_QTA_AMT", df.format((Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DHENC_QTA_AMT")))))));
                    bd0300Mapper.updateDecodeBqdt(qtItem);
                }
            }else{
    	        //우선협상 시작 후 협상중일때 개찰인 경우
                Map<String,Object> qtVendor = bd0300Mapper.getDecAmtVendorListForNego(data);
                if(qtVendor == null){
                    throw new Exception(msg.getMessageByScreenId("BD0340","010"));
                }
                String key = qtVendor.get("VENDOR_CD") + "ENCRIPT" + qtVendor.get("VENDOR_CD");
                qtVendor.put("HDEC_QTA_AMT", df.format((Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtVendor.get("HENC_QTA_AMT")))))));
                bd0300Mapper.updateDecodeBqhd(qtVendor);

                List<Map<String, Object>> qtItemlist = bd0300Mapper.getDecAmtItemListForBdOpen(qtVendor);
                for(Map<String, Object> qtItem : qtItemlist) {
                    key = qtItem.get("VENDOR_CD") + "ENCRIPT" + qtItem.get("VENDOR_CD");
                    qtItem.put("DDEC_UNIT_PRC", df.format((Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DENC_UNIT_PRC")))))));
                    qtItem.put("DDEC_QTA_AMT", df.format((Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DHENC_QTA_AMT")))))));
                    bd0300Mapper.updateDecodeBqdt(qtItem);
                }

                data.put("NEGO_RESULT_TYPE","09");
                data.put("VENDOR_CD",qtVendor.get("VENDOR_CD"));
                bd0300Mapper.BD0340P05_updateBDVN_NegoResultType(data);
            }
    	}
    	return msg.getMessage("0001");
	}

    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 총액별 (BD0340P01)
     * 처리내용 : (구매사) 아이템별 협력사선정 조회하는 화면
     */

    public List<Map<String, Object>> getBqDocVendorListByBd(Map<String, String> formData) throws Exception{
        return bd0300Mapper.getBqDocVendorListByBd(formData);
    }

    public List<Map<String, Object>> getBqDocItemListByBq(Map<String, String> formData) throws Exception{
        return bd0300Mapper.getBqDocItemListByBq(formData);
    }

    //총액별 업체 선정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String setDocSettle(Map<String, String> formData, List<Map<String, Object>> gridV) throws Exception {
        //	formData.put("PROGRESS_CD", "2500"); // 업체선정완료
        //    bd0300Mapper.setDocSettleCancelRqhd(formData); //PRHD PROGRESS CD 업데이트
        //    bd0300Mapper.updateRqdtProgress(formData);  //PRDT PROGRESS CD 업데이트

        /*String signStatus = formData.get("SIGN_STATUS");
        String oldSignStatus = bd0300Mapper.getSignStatus2FromBD(formData);
        String appDocCnt = formData.get("APP_DOC_CNT");
        if (signStatus.equals("P")) {
            if (EverString.isEmpty(formData.get("APP_DOC_NUM"))) {
                formData.put("APP_DOC_NUM", docNumService.getDocNumber("AP"));
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                appDocCnt = "1";
            } else {
                //이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수+1
                if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }
            formData.put("APP_DOC_CNT", appDocCnt);
            formData.put("DOC_TYPE", "EXEC1");

            approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        } else {
            //이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수+1
            if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                formData.put("APP_DOC_CNT", appDocCnt);
            }
        }*/

        for(Map<String,Object> grid : gridV) {
            bd0300Mapper.setDocSettleBqdt(grid);
        }

        //formData.put("PROGRESS_CD","2400");
        //bd0300Mapper.updateBdhdSignStatus2(formData);
        //if(1==1) throw new Exception("XXXXXXXXXXXXXXXXXXXXX");

        //승인부분 주석처리 하고 바로 협력업체 등록
        formData.put("PROGRESS_CD","2900");
        bd0300Mapper.updateBdhdSignStatus2(formData);

        List<Map<String,String>> qtaNumList = bd0300Mapper.getBqNumListByBdNum(formData);

        bd0300Mapper.updateBdhdProgress(formData); //PRHD PROGRESS CD 업데이트
        bd0300Mapper.updateBddtProgress(formData);  //PRDT PROGRESS CD 업데이트

        //승인 후 업체선정날짜 데이터 넣어줌.
        /*for (Map<String, String> qtaNum : qtaNumList) {
            bd0300Mapper.updateBqSltDate(qtaNum);
        }*/

        //이메일 보내기
        //sendEmailBdResult(formData, "2900"); 2022-12-22 입찰 협력업체선정 메일전송 삭제

        return msg.getMessage("0001");
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelBD(Map<String, String> formData) throws Exception {
        formData.put("PROGRESS_CD", "1400"); // 유찰

        bd0300Mapper.updateBdhdProgress(formData);
        bd0300Mapper.updateBddtProgress(formData);
        bd0300Mapper.setCancelPrdt(formData);

        //sendEmailBdResult(formData, "1400"); 2022-12-22 입찰비교 유찰 메일전송 삭제
        return msg.getMessage("0001");
    }


    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 품목별 (BD0340P02)
     * 처리내용 : (구매사) 아이템별 협력사선정 조회하는 화면
     */
    public List<Map<String, Object>> getSettleItemListByBd(Map<String, String> formData) throws Exception{
        return bd0300Mapper.getSettleItemListByBd(formData);
    }




    //협력업체 선정 승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endExecApproval(String docNum, String docCnt, String signStatus) throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);

        bd0300Mapper.updateBdSignStatus2(map);

        UserInfo userInfo = UserInfoManager.getUserInfo();
        map.put("BUYER_CD", userInfo.getCompanyCd());

        Map<String,String> bdHd = (Map)bd0300Mapper.getBdHdDetail(map);
        List<Map<String,String>> qtaNumList = bd0300Mapper.getBqNumListByBdNum(map);
        if(signStatus.equals("E")){
            bdHd.put("PROGRESS_CD", "2900"); // 업체선정완료
            bd0300Mapper.updateBdhdProgress(bdHd); 	//PRHD PROGRESS CD 업데이트
            bd0300Mapper.updateBddtProgress(bdHd);  //PRDT PROGRESS CD 업데이트

            //승인 후 업체선정날짜 데이터 넣어줌.
            for(Map<String,String> qtaNum : qtaNumList){
                bd0300Mapper.updateBqSltDate(qtaNum);
            }
        }
        else if(signStatus.equals("R")){
            bdHd.put("PROGRESS_CD", "2650"); // 승인 올리기 전 상태
            bd0300Mapper.updateBdhdProgress(bdHd); 	//PRHD PROGRESS CD 업데이트
            bd0300Mapper.updateBddtProgress(bdHd);  //PRDT PROGRESS CD 업데이트

            for(Map<String,String> qtaNum : qtaNumList){
                bd0300Mapper.rejectBq(qtaNum);
            }
        }

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }

    //품목별 업체선정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doItemSettle(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {
    	//formData.put("PROGRESS_CD", "2500"); // 업체선정
        //bd0300Mapper.setDocSettleCancelRqhd(formData);
        //bd0300Mapper.updateRqdtProgress(formData);

        /*String signStatus = formData.get("SIGN_STATUS");
        String oldSignStatus = bd0300Mapper.getSignStatus2FromBD(formData);
        String appDocCnt = formData.get("APP_DOC_CNT");
        if (signStatus.equals("P")) {
            if (EverString.isEmpty(formData.get("APP_DOC_NUM"))) {
                formData.put("APP_DOC_NUM", docNumService.getDocNumber("AP"));
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                appDocCnt = "1";
            } else {
                //이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수+1
                if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }
            formData.put("APP_DOC_CNT", appDocCnt);
            formData.put("DOC_TYPE", "EXEC2");

            approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        } else {
            //이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수+1
            if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                formData.put("APP_DOC_CNT", appDocCnt);
            }
        }

        formData.put("PROGRESS_CD","2400");
        bd0300Mapper.updateBdhdSignStatus2(formData);

        for( Map<String, Object> data : gridData) {
            if(String.valueOf(data.get("SLT_FLAG")).equals("1")) {
                bd0300Mapper.setItemSettleBqdt(data);
            }
        }*/

        //if(1==1) throw new Exception("XXXXXXXXXXXXXXXXXXXXX");

        for( Map<String, Object> data : gridData) {
            bd0300Mapper.setItemSettleBqdt(data);
        }

        //승인부분 주석처리 하고 바로 협력업체 등록
        formData.put("PROGRESS_CD","2900");
        bd0300Mapper.updateBdhdSignStatus2(formData);
        bd0300Mapper.updateBddtProgress(formData);  //PRDT PROGRESS CD 업데이트

        List<Map<String,String>> qtaNumList = bd0300Mapper.getBqNumListByBdNum(formData);

        bd0300Mapper.updateBdhdProgress(formData); //PRHD PROGRESS CD 업데이트
        bd0300Mapper.updateBddtProgress(formData);  //PRDT PROGRESS CD 업데이트

        //승인 후 업체선정날짜 데이터 넣어줌.
        /*for (Map<String, String> qtaNum : qtaNumList) {
            bd0300Mapper.updateBqSltDate(qtaNum);
        }*/

        //sendEmailBdResult(formData, "2900"); //2022-12-22 입찰 협력업체선정 메일전송 삭제
        return msg.getMessage("0001");
    }


    /********************************************************************************************
     * 구매사> 구매관리 > 입찰관리 > 입찰비교 (BD0340P03)
     * 처리내용 : 입찰 비교하는 창
     */
    public List<Map<String,Object>> getAdditionalColumnInfos(Map<String,String> param){
        return bd0300Mapper.getAdditionalColumnInfos(param);
    }

    public List<Map<String,Object>> doSearchComparisonTable(Map<String,String> param){
        Map<String, Object> newParam = new HashMap<>(param);
        newParam.put("additionalColumnInfoList", bd0300Mapper.getAdditionalColumnInfos(param));
        return bd0300Mapper.doSearchComparisonTable(newParam);
    }



    /********************************************************************************************
     * 구매사> 구매관리 > 입찰관리 > 평가요청 (BD0340P04)
     * 처리내용 : 평가 요청하는 창
     */
    public List<Map<String,Object>> getEveuListForBD(Map<String, String> param){
        return bd0300Mapper.getEveuListForBD(param);
    }

    public List<Map<String, Object>> BD0340P04_getVendorListForBDEV(Map<String,String> formData){
        return bd0300Mapper.BD0340P04_getVendorListForBDEV(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doReqEVforBD(Map<String,String> params, List<Map<String,Object>> gridUs, List<Map<String,Object>> gridVendor) throws Exception {
        String evNum = params.get("EV_NUM");

        //저장단계
        if(EverString.isEmpty(evNum)){
            String docNo = docNumService.getDocNumber("EV");
            params.put("EV_NUM", docNo);
            params.put("PROGRESS_CD", "100");

            /** 평가담당자만 처리 가능 */
            if (!params.get("EV_CTRL_USER_ID").equals(UserInfoManager.getUserInfo().getUserId())) {
                throw new NoResultException(msg.getMessageByScreenId("SRM_210","0013"));
            }
            ev0210Mapper.doInsertEVEM(params);
            bd0300Mapper.updateEvNumtoBDVN(params);
        } else {
            // check progress/status and update EVEM
            Map<String, Object> retData = ev0210Mapper.doCheckEVEM(params);

            /** 평가담당자만 처리 가능 */
            if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
                throw new NoResultException(msg.getMessageByScreenId("SRM_210","0013"));
            }

            /** 평가요청일이 존재하면 처리불가 */
            if (retData.get("REQUEST_DATE") != null && !retData.get("REQUEST_DATE").toString().equals("")) {
                throw new NoResultException(msg.getMessageByScreenId("SRM_210","0011"));
            }

            ev0210Mapper.doUpdateEVEM(params);

            ev0210Mapper.doDeleteEVESAll(params);
            ev0210Mapper.doDeleteEVEUAll(params);
        }

        for (Map<String, Object> gridVendorData : gridVendor) {
            int VENDOR_SQ = 0;

            gridVendorData.put("EV_NUM", params.get("EV_NUM"));

            if("".equals(gridVendorData.get("VENDOR_SQ")) || gridVendorData.get("VENDOR_SQ") == null) {
                for (Map<String, Object> map : gridVendor) {
                    String map_vendor_cd = String.valueOf(map.get("VENDOR_CD"));

                    if(map_vendor_cd.equals(gridVendorData.get("VENDOR_CD"))) {
                        if("".equals(map.get("VENDOR_SQ")) || map.get("VENDOR_SQ") == null) {
                            map.put("VENDOR_SQ", ++VENDOR_SQ);
                        } else {
                            VENDOR_SQ = Integer.valueOf(String.valueOf(map.get("VENDOR_SQ")));
                        }
                    }
                }
            }


            if(ev0210Mapper.existsEVES(gridVendorData) == 0) {
            	ev0210Mapper.doInsertEVES(gridVendorData);
            } else {
            	ev0210Mapper.doUpdateEVES(gridVendorData);
            }

            for(Map<String, Object> gridEVEU : gridUs){
                gridEVEU.putAll(gridVendorData);
                if(ev0210Mapper.existsEVEU(gridEVEU) == 0) {
                    ev0210Mapper.doInsertEVEU(gridEVEU);
                } else {
                    ev0210Mapper.doUpdateEVEU(gridEVEU);
                }
            }
        }


        //평가요청단계
        params.put("PROGRESS_CD", "100");
        ev0210Mapper.doUpdateProgressEVEU(params);
        ev0210Mapper.doUpdateProgressEVES(params);

        params.put("PROGRESS_CD", "200");
        params.put("REQUEST_DATE", "YES");
        ev0210Mapper.doUpdateProgressEVEM(params);

        return msg.getMessage("0001");
    }

    public List<Map<String,Object>> getEveuByBD(Map<String,String> formData){
        return bd0300Mapper.getEveuByBD(formData);
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveEvResult(Map<String,String> params) throws Exception{
        Map<String,String> data = new HashMap<String,String>();
        UserInfo userInfo = UserInfoManager.getUserInfo();

        String  queryString 	= params.get("QUERY_STR");

        String  ev_num 			= params.get("EV_NUM_L");
        String  ev_tpl_num 		= params.get("EV_TPL_NUM");
        String  ev_user_id 		= params.get("EV_USER_ID");
//		String	ev_score 		= params.get("EV_SCORE_R");
        String	ev_score 		= params.get("TOTAL_SCORE");
        String  att_file_num	= params.get("ATT_FILE_NUM");
        String  vendor_cd		= params.get("VENDOR_CD");
        String vendor_sq = params.get("VENDOR_SQ");
        String	rmk				= params.get("RMK");

        data.put("EV_NUM"		, ev_num);
        data.put("EV_TPL_NUM"	, ev_tpl_num);
        data.put("EV_USER_ID"	, ev_user_id);
        data.put("EV_SCORE"		, ev_score);
        data.put("ATT_FILE_NUM"	, att_file_num);
        data.put("VENDOR_CD"	, vendor_cd);
        data.put("RMK", rmk);
        Map<String, String> chkData = ev0250Mapper.doCheck(data);

        if (chkData == null) {
            throw new NoResultException(msg.getMessageByScreenId("SRM_250","progressNull"));
        }


        String result_enter_user_cd = chkData.get("RESULT_ENTER_CD").toString();
        String EV_CTRL_USER_ID = chkData.get("EV_CTRL_USER_ID");

        //if(!userInfo.getUserId().equals(EV_CTRL_USER_ID)) {
            if( "EVALUSER".equals(result_enter_user_cd) ) { //구매담당자
                if (!chkData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
                    throw new NoResultException(msg.getMessageByScreenId("SRM_250","eval_user")); // 메시지 등록: 평가 담당자만 처리할 수 있습니다.
                }
            } else if( "PERUSER".equals(result_enter_user_cd) ) {//평가자
                if (!chkData.get("EV_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
                    throw new NoResultException(msg.getMessageByScreenId("SRM_250","per_user"));  //메시지 등록: 평가자만 처리할 수 있습니다.
                }
            } else if( "REPUSER".equals(result_enter_user_cd) ) {//대표평가자
                chkData.put("CHK_USER",  UserInfoManager.getUserInfo().getUserId() );
                int repUserCnt = ev0250Mapper.doRepUserCheck(chkData);

                if ( repUserCnt == 0 ) {
                    throw new NoResultException(msg.getMessageByScreenId("SRM_250","rep_user"));   //메시지 등록: 대표평가자만 처리할 수 있습니다.
                }
            }
        //}

        //평가진행상태 확인
        String checkProgress = ev0250Mapper.checkProgress(data);
        if ( "N".equals(checkProgress) ) {// y면 평가진행중 //n면 평가완료
            throw new NoResultException(msg.getMessageByScreenId("SRM_250","progress"));
        }

		/*if (chkData.get("PROGRESS_CD") == null) {
			throw new NoResultException(msg.getMessageByScreenId("SRM_250","progressNull"));
		}*/
		/*if ( !"".equals(chkData.get("PROGRESS_CD").toString()) && "200".equals(chkData.get("PROGRESS_CD").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("SRM_250","progress"));
		}*/


        if( queryString != null && !"".equals(queryString)){

            List<Map<String,String>> getEVScoreByEVT = bd0300Mapper.getEVScoreByEVT(params);
            Map<String,String[]> evInfoMap = new HashMap<>();
            for(Map<String,String> evInfo : getEVScoreByEVT){
                String[] ev = new String[3];
                ev[0] = evInfo.get("EV_ITEM_TYPE_CD");  //가격(OP), 비가격(NP)
                ev[1] = String.valueOf(evInfo.get("WEIGHT")); //가중치
                ev[2] = String.valueOf(evInfo.get("EV_ID_SCORE")); //해당 템플릿 최고점
                evInfoMap.put(evInfo.get("EV_ITEM_NUM"), ev);
            }


            String[] datas = queryString.split("##");

            for(int i=0; i<datas.length; i++) {
                String[] items = datas[i].split("@@");
                String item_num 			= items[0];
                String item_id_sq 			= items[1];
                String item_id_score 		= items[2];
                String item_remark 		= items[3];
                data.put("EV_ITEM_NUM"		, item_num);
                data.put("EV_ID_SQ"		, item_id_sq);
                data.put("EV_ID_SCORE"		, item_id_score);
                data.put("VENDOR_CD"		, vendor_cd);
                data.put("VENDOR_SQ", vendor_sq);
                data.put("EV_REMARK"		, EverString.replace(item_remark,"_","")); //평가의견 - 20151217 추가

                String[] str = evInfoMap.get(item_num);
                BigDecimal weight = new BigDecimal(str[1]);
                BigDecimal highScore = new BigDecimal(str[2]);
                BigDecimal thisScore = new BigDecimal(item_id_score).divide(weight,5, BigDecimal.ROUND_DOWN);

                BigDecimal result = thisScore.divide(highScore, 5, BigDecimal.ROUND_DOWN).multiply(weight);

                if(new BigDecimal(item_id_score).compareTo(BigDecimal.ZERO) == 0) {
                    data.put("EV_ID_SCORE"	, "0");
                } else {
                    data.put("EV_ID_SCORE"	, String.valueOf(result));
                }




				String item_att_file_num 		= items[4];
				if("null".equals(item_att_file_num)) item_att_file_num = null;
				String chk_yn 		= items[5];
				data.put("CHK_YN", chk_yn);
				data.put("ATT_FILE_NUM_EE", EverString.replace(item_att_file_num,"_",""));


                ev0250Mapper.doUpdateEvee(data); //정성평가 세부내역 UPDATE
            }

        }

        ev0250Mapper.doUpdateEveu(data); //평가자 정보 UPDATE

        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void updateEVResultBDVN (List<Map<String,Object>> gridDatas) throws Exception{

        for(Map<String,Object> params : gridDatas){
            if(!params.get("EV_TYPE_CD").equals("BD")) continue;

            BigDecimal HighestNpSum = new BigDecimal(0);
            BigDecimal HighestOpSum = new BigDecimal(0);

            List<Map<String,String>> evScoreInfo = bd0300Mapper.getEVScoreInfoByEVNUM(params);
            Map<String, String[]> evInfoByEVITEMNUM = new HashMap<>();
            for(Map<String, String> map : evScoreInfo){
                String[] str = new String[3];
                str[0] = String.valueOf(map.get("WEIGHT")); //가중치
                str[1] = String.valueOf(map.get("EV_ID_SCORE")); //최고점수
                str[2] = map.get("EV_ITEM_TYPE_CD");   //가격, 비가격
                evInfoByEVITEMNUM.put(map.get("EV_ITEM_NUM"), str);
                if(str[2].equals("NP")){
                    HighestNpSum = HighestNpSum.add(new BigDecimal(str[0]));
                }else{
                    HighestOpSum = HighestOpSum.add(new BigDecimal(str[0]));
                }
            }

            BigDecimal npSum = new BigDecimal(0);
            BigDecimal opSum = new BigDecimal(0);

            List<Map<String, String>> eveeForEVResult = bd0300Mapper.getEveeForEVResult(params);
            Set<String> userSet = new HashSet<>();
            for(Map<String, String> eveeInfo : eveeForEVResult){
                userSet.add(eveeInfo.get("EV_USER_ID"));
                String[] str = evInfoByEVITEMNUM.get(eveeInfo.get("EV_ITEM_NUM"));
                String prcType = str[2];
                BigDecimal weight = new BigDecimal(str[0]);
                BigDecimal highestScore = new BigDecimal(str[1]);
                BigDecimal thisScore = new BigDecimal(String.valueOf(eveeInfo.get("EV_ID_SCORE"))).multiply(weight).divide(highestScore,5, BigDecimal.ROUND_DOWN);

                if(prcType.equals("NP")){
                    npSum = npSum.add(thisScore);
                }else{
                    opSum = opSum.add(thisScore);
                }
            }

            Map<String, String> bdInfoForEV = bd0300Mapper.getBdInfoForEV(params);
            BigDecimal npSumEvg = npSum.divide(new BigDecimal(String.valueOf(userSet.size())), 10, BigDecimal.ROUND_DOWN)
                                       .multiply(new BigDecimal(String.valueOf(bdInfoForEV.get("NPRC_PERCENT"))))
                                       .divide(HighestNpSum,5, BigDecimal.ROUND_DOWN);

            BigDecimal opSumEvg = opSum.divide(new BigDecimal(String.valueOf(userSet.size())), 10, BigDecimal.ROUND_DOWN)
                                       .multiply(new BigDecimal(String.valueOf(bdInfoForEV.get("PRC_PERCENT"))))
                                       .divide(HighestOpSum,5, BigDecimal.ROUND_DOWN);

            params.put("RFX_NUM", bdInfoForEV.get("RFX_NUM"));
            params.put("RFX_CNT", bdInfoForEV.get("RFX_CNT"));
            params.put("NPRC_SCORE", npSumEvg);
            params.put("PRC_SCORE", opSumEvg);

            bd0300Mapper.updateEvResultBDVN(params);

        }
    }


    public List<Map<String,Object>> BD0340P05_getVendorInfoForBDEV(Map<String,String> formData){
        return bd0300Mapper.getVendorInfoForBDEV(formData);
    }

    public List<Map<String,Object>> BD0340P05_getItemInfoForBDEV(Map<String,String> param){
        return bd0300Mapper.getItemInfoForBDEV(param);
    }

    public void BD0340P05_UpdateStatus(Map<String,Object> param){
        bd0300Mapper.BD0340P05_updateBDVN_NegoResultType(param);
        bd0300Mapper.BD0340P05_updateBDHD_progressCd(param);
        bd0300Mapper.BD0340P05_updateBDDT_progressCd(param);
    }

    //BD0340P05 협상에의한선정 -> 우선협상자 선정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BD0340P05_doNego(List<Map<String,Object>> gridData, Map<String,String> formData){
        for(Map<String,Object> grid : gridData){
            if(String.valueOf(grid.get("NEGO_RESULT_TYPE")).equals("01")){
                grid.put("NEGO_RESULT_TYPE","02");
                grid.put("RFX_NUM", formData.get("RFX_NUM"));
                grid.put("RFX_CNT", formData.get("RFX_CNT"));
                grid.put("PROGRESS_CD", "2850");
                BD0340P05_UpdateStatus(grid);
            }
        }
    }

    //BD0340P05 협상에의한선정 -> 낙찰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BD0340P05_doSettle(List<Map<String,Object>> gridData, Map<String,String> formData) throws Exception {
        Map<String,Object> param = new HashMap<>();
        param.put("RFX_NUM", formData.get("RFX_NUM"));
        param.put("RFX_CNT", formData.get("RFX_CNT"));
        //백엔드 밸리데이션 체크
    	List<Map<String,Object>> listRequied= bd0300Mapper.getVendorInfoForBDEV(formData);
    	String progressCd = String.valueOf(listRequied.get(0).get("PROGRESS_CD"));
    	formData.put("PROGRESS_CD",progressCd);
    	if(formData.get("PROGRESS_CD").equals("2800")){
            for(Map<String,Object> grid : gridData){
                if(String.valueOf(grid.get("RANK")).equals("1")){
                    param.putAll(grid);
                    param.put("SLT_FLAG","1");
                    bd0300Mapper.setDocSettleBqdt(param);
                    param.put("NEGO_RESULT_TYPE","05"); //낙찰
                    param.put("PROGRESS_CD", "2900");
                    param.put("SIGN_STATUS","E");
                    BD0340P05_UpdateStatus(param);
                    bd0300Mapper.updateBdhdSignStatus2((Map)param);
                    break;
                }
            }
        }else{
        	int inx =0 ;
            for(Map<String,Object> grid : gridData){
            	if((String.valueOf(grid.get("NEGO_RESULT_TYPE")).equals("02") && String.valueOf(listRequied.get(inx).get("NEGO_RESULT_TYPE")).equals("02"))
                	||
                    (String.valueOf(grid.get("NEGO_RESULT_TYPE")).equals("09") && String.valueOf(listRequied.get(inx).get("NEGO_RESULT_TYPE")).equals("09"))
                    ){
                    param.putAll(grid);
                    param.put("SLT_FLAG","1");
                    bd0300Mapper.setDocSettleBqdt(param);
                    param.put("NEGO_RESULT_TYPE","05"); //낙찰
                    param.put("PROGRESS_CD", "2900");
                    param.put("SIGN_STATUS","E");
                    BD0340P05_UpdateStatus(param);
                    bd0300Mapper.updateBdhdSignStatus2((Map)param);
                    break;
                }
            	inx++;
            }
        }
        //sendEmailBdResult(formData, "2900"); //2022-12-22 입찰 협력업체선정 메일전송 삭제
    }

    //BD0340P05 협상에의한선정 -> 유찰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BD0340P05_doCancelRfq(List<Map<String,Object>> gridData, Map<String,String> formData) throws Exception {
    	//백엔드 밸리데이션 체크
    	List<Map<String,Object>> listRequied= bd0300Mapper.getVendorInfoForBDEV(formData);
    	String progressCd = String.valueOf(listRequied.get(0).get("PROGRESS_CD"));
    	formData.put("PROGRESS_CD",progressCd);
    	if(formData.get("PROGRESS_CD").equals("2800")){
            formData.put("NEGO_RESULT_TYPE","03");  //BDVN 유찰
            formData.put("PROGRESS_CD", "1400");    //입찰 유찰
            BD0340P05_UpdateStatus((Map)formData);
            bd0300Mapper.setCancelPrdt(formData);
            // 2022-12-22 입찰 협력업체선정 메일전송 삭제
            //sendEmailBdResult(formData, "1400");
        }else{
            int curRank = 0;
            int inx =0 ;
            boolean last = true;
            for(Map<String,Object> grid : gridData){
                if((String.valueOf(grid.get("NEGO_RESULT_TYPE")).equals("02") && String.valueOf(listRequied.get(inx).get("NEGO_RESULT_TYPE")).equals("02"))
                	||
                   (String.valueOf(grid.get("NEGO_RESULT_TYPE")).equals("09") && String.valueOf(listRequied.get(inx).get("NEGO_RESULT_TYPE")).equals("09"))
                   ){
                    curRank = Integer.parseInt(String.valueOf(grid.get("RANK"))) + 1;
                    grid.put("NEGO_RESULT_TYPE","03");
                    grid.put("RFX_NUM", formData.get("RFX_NUM"));
                    grid.put("RFX_CNT", formData.get("RFX_CNT"));
                    bd0300Mapper.BD0340P05_updateBDVN_NegoResultType(grid);

                }else if(Integer.parseInt(String.valueOf(grid.get("RANK"))) == curRank && EverString.isNotEmpty(String.valueOf(grid.get("QTA_NUM")))){
                    last = false;
                    grid.put("NEGO_RESULT_TYPE","02");
                    grid.put("RFX_NUM", formData.get("RFX_NUM"));
                    grid.put("RFX_CNT", formData.get("RFX_CNT"));
                    bd0300Mapper.BD0340P05_updateBDVN_NegoResultType(grid);
                }
                inx++;
            }
            if(last){
                formData.put("NEGO_RESULT_TYPE","03");  //BDVN 유찰
                formData.put("PROGRESS_CD", "1400");    //입찰 유찰
                BD0340P05_UpdateStatus((Map)formData);
                bd0300Mapper.setCancelPrdt(formData);
                // 2022-12-22 입찰 협력업체선정 메일전송 삭제
                //sendEmailBdResult(formData, "1400");
            }
        }
    }


    //BD0340P06 협상에의한선정 -> 우선협상시작 이후 재입찰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String chgBidDateForRebid(Map<String,String> formData) throws Exception{
        bd0300Mapper.bd0340P06_updateBDVN_reBid(formData);
        bd0300Mapper.bd0340P06_insertBDVO(formData);
        return msg.getMessage("0001");
    }

    /**
     * 입찰 진행상태에 따른 Mail 보내기
     * @param param
     * @param progressCd
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void sendEmailBdResult(Map<String,String> rqhdData, String progressCd) throws Exception{

        // E-Mail, SMS 발송
        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.RFP_TemplateFileName");

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

        Map<String, String> rfqData = bd0300Mapper.getRfxInfoHD(rqhdData);
        String rfqNumCnt = EverString.nullToEmptyString(rfqData.get("RFX_NUM")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("RFX_CNT")));
        String vendorOpenDealType = EverString.nullToEmptyString(rfqData.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("VENDOR_SLT_TYPE")));
        String rmkText = largeTextService.selectLargeText(EverString.nullToEmptyString(rfqData.get("RMK_TEXT_NUM")));

        String tblBody = "<tbody>";
        String enter = "\n";
        List<Map<String, String>> itemList = bd0300Mapper.getRfxItemList(rqhdData);
        if(itemList.size() > 0) {
            for (Map<String, String> itemData : itemList) {

                String itemDesc = itemData.get("ITEM_DESC");
                if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }

                String itemSpec = itemData.get("ITEM_SPEC");
                if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }

                String tblRow = "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</th>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }

        List<Map<String, String>> vendorList = bd0300Mapper.getRfxVendorList(rqhdData);
        for (Map<String, String> vendorData : vendorList) {

            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", vendorData.get("VENDOR_NM")); // 공급사명
            fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", rfqNumCnt); // 견적의뢰번호/차수
            fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", EverString.nullToEmptyString(rfqData.get("RFQ_SUBJECT"))); // 견적의뢰명
            fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", EverString.nullToEmptyString(rfqData.get("RFQ_CLOSE_DATE"))); // 견적마감일시
            fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", vendorOpenDealType); // 지명방식/거래유형
            fileContents = EverString.replace(fileContents, "$RMK_TEXT$", rmkText); // 요청사항
            fileContents = EverString.replace(fileContents, "$CTRL_USER_NM$", EverString.nullToEmptyString(rfqData.get("CTRL_USER_NM"))); // 품목담당자
            fileContents = EverString.replace(fileContents, "$TEL_NUM$", EverString.nullToEmptyString(rfqData.get("TEL_NUM"))); // 연락처
            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            if(!(vendorData.get("RECV_EMAIL")==null) && !vendorData.get("RECV_EMAIL").equals("")) {
                Map<String, String> mdata = new HashMap<String, String>();
                mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 귀사에 견적을 요청드립니다.");
                mdata.put("CONTENTS_TEMPLATE", fileContents);
                mdata.put("SEND_USER_ID", vendorData.get("SEND_USER_ID"));
                mdata.put("SEND_USER_NM", vendorData.get("SEND_USER_NM"));
                mdata.put("SEND_EMAIL", vendorData.get("SEND_EMAIL"));
                mdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID"));
                mdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM"));
                mdata.put("RECV_EMAIL", vendorData.get("RECV_EMAIL"));
                mdata.put("REF_NUM", rfqData.get("RFX_NUM"));
                mdata.put("REF_MODULE_CD", "RFQ"); // 참조모듈
                // 메일전송.
                everMailService.sendMail(mdata);
                mdata.clear();
            }
            else {
            	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 email 정보가 없습니다.");
            }

            if(!(vendorData.get("RECV_TEL_NUM")==null) && !vendorData.get("RECV_TEL_NUM").equals("")) {
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("CONTENTS", "[대명소노시즌] 견적요청서가 도착했습니다.(" + vendorData.get("RFX_NUM") + ") 빠른 견적진행 부탁드립니다."); // 전송내용
                sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(vendorData.get("SEND_USER_ID")).equals("") ? "SYSTEM" : vendorData.get("SEND_USER_ID"))); // 보내는 사용자ID
                sdata.put("SEND_USER_NM",vendorData.get("SEND_USER_NM")); // 보내는사람
                sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                sdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID")); // 받는 사용자ID
                sdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM")); // 받는사람
                sdata.put("RECV_TEL_NUM", vendorData.get("RECV_TEL_NUM")); // 받는 사람 전화번호
                sdata.put("REF_NUM", rfqData.get("RFX_NUM")); // 참조번호
                sdata.put("REF_MODULE_CD", "RFQ"); // 참조모듈
                // SMS 전송.
                everSmsService.sendSms(sdata);
                sdata.clear();
            }
            else {
            	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 전화번호 정보가 없습니다.");
            }
        }
    }

    /********************************************************************************************
     * BD0340 상세보기
     */
	public List<Map<String, Object>> doSearchT(Map<String, String> param) {
		Map<String, Object> paramObj = (Map) param;

		return bd0300Mapper.getBDdtSubmitDataR_0360(paramObj);
	}
	public List<Map<String, Object>> doSearch0360(Map<String, String> param) {
		Map<String, Object> paramObj = (Map) param;
		if(EverString.isNotEmpty(param.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));
        }
		return bd0300Mapper.getBDdtSubmitData_0360(paramObj);
	}

	/********************************************************************************************
     * BD0350 조회
     */
	public List<Map<String, Object>> getBdHdAnList(Map<String, String> formData) {
		// TODO Auto-generated method stub
		Map<String, Object> paramObj = (Map) formData;

		if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }

		//return bd0300Mapper.getBdHdAnList(formData);
		return bd0300Mapper.getBdHdAnList(paramObj);
	}

	public List<Map<String, Object>> getBdVnList(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return bd0300Mapper.getBdVnList(formData);
	}

	// 입찰설명회 결과 등록
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveBdD0350P01(Map<String, String> formData, List<Map<String, Object>> grid) throws Exception{
		// TODO Auto-generated method stub
		for(Map<String,Object> gridT : grid){;
            bd0300Mapper.updateBdVn(gridT);
        }
		bd0300Mapper.updateBdAn(formData);
		return  msg.getMessage("0031");
	}

	public int gbunFlag(Map<String, String> formData) {

		return bd0300Mapper.gbunFlag(formData);
	}

	public List<Map<String, Object>> getVendorListHtml(Map<String, String> param) {
		// TODO Auto-generated method stub
		return bd0300Mapper.getVendorListHtml(param);
	}

	/**
	 * 대명소노시즌 DGNS 그룹웨어 결재 상신전 STOCSCTM 저장
	 * @param formData
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> doSign(Map<String, String> formData) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> signData = new HashMap<String, String>();
		Map<String, String> reData   = new HashMap<String, String>();
		String APP_NUM = "";
		formData.put("RFX_NUM" 		    , formData.get("EXEC_NUM"));
		formData.put("RFX_CNT" 		    , formData.get("EXEC_CNT"));
        if(this.getBlsmHtml(formData) != null) {
        	bapm_Service.updateBeforGwSTOCSCTM(formData);
        	APP_NUM = formData.get("APP_DOC_NUM")+formData.get("APP_DOC_CNT");
        }else {
        	String appDocNum = docNumService.getDocNumber(userInfo.getCompanyCd(),"AP");
        	signData.put("APP_DOC_NUM" 	    , appDocNum);
        	signData.put("APP_DOC_CNT" 	    , "1");
        	signData.put("RFX_NUM" 		    , formData.get("EXEC_NUM"));
            signData.put("RFX_CNT" 		    , formData.get("EXEC_CNT"));
            signData.put("SIGN_STATUS" 	    , "T");
            signData.put("PROGRESS_CD" 	    , "2600");
            bd0300Mapper.gwSignResult(signData);
            signData.put("APP_DOC_NUM" 		, appDocNum);
        	signData.put("APP_DOC_CNT" 		, "1");
            signData.put("DOC_TYPE" 		, "AP");
            signData.put("SUBJECT" 			, formData.get("SUBJECT"));
            signData.put("BLSM_HTML" 		, formData.get("xmlParam"));
            signData.put("BLSM_USE_FALG"	, "1");
            signData.put("BLSM_STATUS"		, "1"); // 품의신청(01)
            signData.put("BLSM_APPLY_FLAG"	, "0");
            bapm_Service.insertSTOCSCTM(signData);
            APP_NUM = appDocNum + "1";
        }

        reData.put("APP_DON_NUM2" , APP_NUM);
        reData.put("REMSG"		  , "'확인' Click 시 그룹웨어(G/W) 결재 상신창이 열립니다. 결재상신을 완료해 주세요.");
        //reData.put("REMSG"		  , msg.getMessage("0023"));

        //그룹웨어 결재 신청 된건 밸리데이션 체크
        int checkelctRequied = bapm_Service.elctRequiedCheck(reData);
        if (checkelctRequied > 0) {
            throw new Exception(msg.getMessageByScreenId("CN0130P01", "0002"));
        }
        return reData;

	}

	public Map<String, Object>  getBlsmHtml(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return bd0300Mapper.getBlsmHtml(formData);
	}

}
