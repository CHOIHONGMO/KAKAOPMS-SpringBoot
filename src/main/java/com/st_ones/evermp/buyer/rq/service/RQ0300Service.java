package com.st_ones.evermp.buyer.rq.service;


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
import com.st_ones.evermp.buyer.rq.RQ0300Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.*;

@Service(value="RQ0300Service")
public class RQ0300Service extends BaseService {

    @Autowired  private DocNumService docNumService;
    @Autowired  private LargeTextService largeTextService;
	@Autowired  private RQ0300Mapper rq0300mapper;
    @Autowired  private MessageService msg;
    @Autowired  private EverMailService everMailService;
    @Autowired  private EApprovalService eApprovalService;
    @Autowired  private EverSmsService everSmsService;
	@Autowired
	private QueryGenService queryGenService;

    /*****************RQ0310******************/

   	/**
   	 * 소싱관리 > 견적관리 > 견적의뢰 작성 (RQ0310) : 엑셀 업로드
   	 * @param gridDatas
   	 * @return
   	 */
    public List<Map<String, Object>> doSetExcelImportItem(List<Map<String,Object>> gridDatas){

    	UserInfo userInfo = UserInfoManager.getUserInfo();

    	List<Map<String, Object>> rtnGrid = new ArrayList<>();
        for(Map<String, Object> grid : gridDatas){

        	grid.put("BUYER_CD", userInfo.getCompanyCd());
            /*String prBuyerCd = rq0300mapper.getCompanyCdByName(grid);
            if(prBuyerCd==null){
                continue;
            }*/

            double rfxQt   = Double.parseDouble(String.valueOf(grid.get("RFX_QT") == null ? 0 : grid.get("RFX_QT")) );
            double unitPrc = Double.parseDouble(String.valueOf(grid.get("UNIT_PRC") == null ? 0 : grid.get("UNIT_PRC")));

            // 품목코드가 존재하는 경우 품목 기본정보 가져오기
            Map<String, Object> item = new HashMap<String, Object>();
            if( grid.get("ITEM_CD") != null && !"".equals(grid.get("ITEM_CD")) ) {
            	item = rq0300mapper.doSetExcelImportItemRfx(grid);

            	unitPrc = Double.parseDouble(String.valueOf(grid.get("UNIT_PRC") == null ? 0 : grid.get("UNIT_PRC")));
            }

            BigDecimal bigDecimal1 = new BigDecimal(rfxQt);
            BigDecimal bigDecimal2 = new BigDecimal(unitPrc);
            //소수점 둘째자리까지 반올림 수량
            bigDecimal1=bigDecimal1.setScale(2, RoundingMode.HALF_UP);
            //정수 반올림 단가
            bigDecimal2=bigDecimal2.setScale(0, RoundingMode.HALF_UP);
            BigDecimal bigDecimal3 = bigDecimal1.multiply(bigDecimal2);
            //정수반올림 금액
            bigDecimal3=bigDecimal3.setScale(0, RoundingMode.HALF_UP);
            grid.put("RFX_AMT", bigDecimal3);

            // 품목이 없는 경우 제외함
        	//if(item == null || item.size() == 0) continue;

            grid.putAll(item);

            rtnGrid.add(grid);
        }

        return rtnGrid;
    }

    //견적 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> insertRq(Map<String, String> formData, List<Map<String,Object>> gridL, List<Map<String,Object>> gridDEL) throws Exception{
    	
        Map<String, String> rtnMap = new HashMap<>();

        UserInfo userInfo = UserInfoManager.getUserInfo();

        String baseDataType = formData.get("baseDataType");
        String rfxNum = formData.get("RFX_NUM");
        String rfxCnt = EverString.nullToEmptyString(formData.get("RFX_CNT")).equals("") ? "1" : formData.get("RFX_CNT");
        formData.put("RFX_CNT", rfxCnt);
        formData.put("PR_REQ_TYPE", "G");

        String signStatus = formData.get("SIGN_STATUS");
        String oldSignStatus = "";
        if(signStatus.equals("T")){ formData.put("PROGRESS_CD", "2300");}
        else if(signStatus.equals("E")){ formData.put("PROGRESS_CD", "2350");}

        //헤더 부분 입력
        if( baseDataType.equals("RERFX") ) {
            //재견적일때
            rq0300mapper.updateRerfxRqhd(formData);
            rq0300mapper.updateRerfxRqdt(formData);

            rfxCnt = String.valueOf(Integer.parseInt(rfxCnt) + 1);
            formData.put("RFX_CNT", rfxCnt);
            oldSignStatus = EverString.nullToEmptyString(rq0300mapper.getSignStatus(formData));
            
            insertRqdt( formData, gridL,  gridDEL);
            rq0300mapper.insertRQHD(formData);
        }
        else {
            //최초 견적 저장
            if(EverString.isEmpty(rfxNum) ) {
                rfxNum = docNumService.getDocNumber(userInfo.getCompanyCd(), "RFQ");
                formData.put("RFX_NUM", rfxNum);
                
                insertRqdt( formData, gridL,  gridDEL);
                rq0300mapper.insertRQHD(formData);
            } else {
                oldSignStatus = EverString.nullToEmptyString(rq0300mapper.getSignStatus(formData));
                
                insertRqdt( formData, gridL,  gridDEL);
                rq0300mapper.updateRQHD(formData);
            }
        }
        
        // APPROVAL_PFX=true
        // 전자결재 시작
        String appDocNum = EverString.nullToEmptyString(formData.get("APP_DOC_NUM"));
        String appDocCnt = EverString.nullToEmptyString(formData.get("APP_DOC_CNT"));
        if(signStatus.equals("P")) {
            if(EverString.isEmpty(appDocCnt)){
            	appDocNum = docNumService.getDocNumber("AP");
                formData.put("APP_DOC_NUM", appDocNum);
            }
            if(EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")){
                appDocCnt = "1";
            } else {
                if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }
            formData.put("APP_DOC_CNT", appDocCnt);
            formData.put("DOC_TYPE", "RFQ");

            eApprovalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
            progressApproval(appDocNum, appDocCnt, signStatus, formData.get("RFX_NUM"));
        }
        
        // APPROVAL_PFX=false
        // 협력사 전송을 클릭한 경우 협력사 전송
        if(signStatus.equals("E")) {
            if(!oldSignStatus.equals("E")){
                rq0300mapper.sendRQ((Map)formData);

                // 협력사 메일발송
                sendEmail(formData);
            }else{
                throw new NoResultException(msg.getMessage("0044"));
            }
        } else if(signStatus.equals("T")) {
            //저장을 클릭했으나 협력사 전송한 상태인경우
            if(oldSignStatus.equals("E")){
                throw new NoResultException(msg.getMessage("0044"));
            }
        }
        
        // 진행상태 : 견적진행중(=2300)
        if(formData.get("PROGRESS_CD").equals("2300")){
            rtnMap.put("rtnMsg", msg.getMessage("0031"));
            rtnMap.put("gateCd",formData.get("GATE_CD"));
            rtnMap.put("buyerCd",formData.get("BUYER_CD"));
            rtnMap.put("rfxNum",rfxNum);
            rtnMap.put("rfxCnt",rfxCnt);
        } else if(formData.get("PROGRESS_CD").equals("2350")) {
            rtnMap.put("rtnMsg", msg.getMessageByScreenId("RQ0310","0008"));
        }

        return rtnMap;
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void insertRqdt(Map<String, String> formData, List<Map<String,Object>> gridL, List<Map<String,Object>> gridDEL) throws Exception{

        double rfxAmt = 0.0;
        String rfxNum = formData.get("RFX_NUM");
        String rfxCnt = formData.get("RFX_CNT");
        String baseDataType = formData.get("baseDataType");

        //삭제된 품목 구매진행현황 복원
        for(Map<String,Object> griddel : gridDEL){
        	//주문번호가 존재하는 경우에만 진행상태 변경
        	if( griddel.get("PR_NUM") != null && griddel.get("PR_SQ") != null ) {
                griddel.put("PROGRESS_CD", "2200");
                rq0300mapper.updatePrdtProgress(griddel);
        	}
        }

        //품목전체 삭제
        rq0300mapper.deleteRQDT(formData);
        //업체 삭제
        rq0300mapper.deleteRQVN(formData);
        
        int rfxSq=1;
        //품목정보 & 업체 저장
        for(Map<String, Object> gridData : gridL){
            gridData.put("GATE_CD", formData.get("GATE_CD"));
            gridData.put("BUYER_CD", formData.get("BUYER_CD"));
            gridData.put("RFX_NUM", rfxNum);
            gridData.put("CUR", formData.get("CUR"));
            gridData.put("RFX_SQ", rfxSq);
            gridData.put("DELY_TYPE", formData.get("DELY_TYPE")); //배송유형 추가 2022-08-04
            gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));
            gridData.put("RFX_CNT", rfxCnt); //재견적인 경우 이미 +1 된 값으로 들어옴
            rfxSq++;
            String rfxQt = gridData.get("RFX_QT") == null ? "0" : String.valueOf(gridData.get("RFX_QT"));
            String unitPrc = gridData.get("UNIT_PRC") == null ? "0" : String.valueOf(gridData.get("UNIT_PRC"));

            BigDecimal bigDecimal1 = new BigDecimal(rfxQt);
            BigDecimal bigDecimal2= new BigDecimal(unitPrc);
            double eachAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();
            gridData.put("RFX_AMT", eachAmt);

            // 구매요청번호가 존재하는 경우
            if( gridData.get("PR_NUM") != null && gridData.get("PR_SQ") != null ) {
            	rq0300mapper.updatePrdtProgress(gridData);
            }
            rq0300mapper.insertRQDT(gridData);

            insertRQVN(gridData, formData);
            if(gridData.get("UNIT_PRC") == null){gridData.put("UNIT_PRC","0");}
            rfxAmt += eachAmt;
        }

        DecimalFormat df = new DecimalFormat("#");
        df.setMaximumFractionDigits(4);

        //총 금액 넣어주기
        formData.put("RFX_AMT", df.format(rfxAmt));
    }

    /**
     * 견적요청 : 품목별 협력업체 등록
     * @param gridData
     * @param formData
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void insertRQVN(Map<String, Object> gridData, Map<String, String> formData) throws Exception{

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
            rq0300mapper.insertRQVN(map);
        }
    }

    //견적요청 헤더 정보 불러오기.
    public Map<String, Object> getRfxHdDetail(Map<String, String> param) throws Exception{
    	
        return rq0300mapper.getRfxHdDetail(param);
    }

    //품목별 해당 협력사 가져오기
    public List<Map<String, Object>> getRfxDtDetail(Map<String, String> formData) throws Exception{

        List<Map<String, Object>> itemList = rq0300mapper.getRfxDtDetail(formData);
        List<Map<String, Object>> vendorList = rq0300mapper.getVendorListByRfx(formData);
        for(Map<String,Object> item : itemList){
            //협력업체를 제품별로 쿼리로 불러오는 부분은 주석처리
            //List<Map<String,Object>> vendorListByitem = rq0300mapper.getRqvnByItem(item);
            //item.put("VENDOR_JSON", new ObjectMapper().writeValueAsString(vendorListByitem));
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

    /**
     * 구매요청(PR), 공급사 제안상품(VD), 상품마스터(GL) 기준 견적서 작성
     * @param prList
     * @return
     * @throws Exception
     */
    public List<Map<String,Object>> getRfxDtDetailFromPrList(String prList) throws Exception{

        JSONArray jsonArray = new JSONArray(prList);
        List<Map<String,Object>> rtnList = new ArrayList<>();

        for(Object item : jsonArray){
            JSONObject jsonObject = (JSONObject)item;
            Map<String, Object> map = new ObjectMapper().readValue(jsonObject.toString(), Map.class);

            // 기존 공급사정보 가져오기
            List<Map<String,Object>> vendorListByitem = rq0300mapper.getVendorListFromVnglCvur(map);
            JSONArray jsonArrayVendor = new JSONArray(vendorListByitem);
            map.put("VENDOR_JSON", jsonArrayVendor);
            rtnList.add(map);
        }
        return rtnList;
    }
    
    /**
     * 견적 요청서 삭제
     * @param formData
     * @param gridDatas
     * @param gridDel
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> deleteRFX(Map<String,String> formData, List<Map<String,Object>> gridDatas, List<Map<String,Object>> gridDel) throws Exception{

        String prevSignStatus = rq0300mapper.getSignStatus(formData);
        if(!formData.get("SIGN_STATUS").equals(prevSignStatus)){
            throw new NoResultException(msg.getMessage("0044"));
        }

        formData.put("_TABLE_NM", "STOPRQHD");
        rq0300mapper.deleteRFX(formData);

        formData.put("_TABLE_NM", "STOPRQDT");
        rq0300mapper.deleteRFX(formData);

        formData.put("_TABLE_NM", "STOPRQVN");
        rq0300mapper.deleteRFX(formData);


        //삭제된 품목 구매진행현황 복원(2200: 접수완료)
        for(Map<String,Object> gridData : gridDatas){
            gridData.put("PROGRESS_CD", "2200");
            rq0300mapper.updatePrdtProgress(gridData);
        }

        for(Map<String,Object> grid : gridDel){
            grid.put("PROGRESS_CD", "2200");
            rq0300mapper.updatePrdtProgress(grid);
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

        rq0300mapper.updateRqSignStatus(map);

        //승인 후 바로 협력사로 전송
        if(signStatus.equals("E")){
            Map<String, Object> rqdtList = getRfxHdDetail(map);
            rq0300mapper.sendRQ(rqdtList);

            //협력사에게 견적요청 메일 발송
            //sendEmail(rqdtList);

        }

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }

    /*******************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적요청현황 (RQ0320)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     *
     */
    public List<Map<String, Object>> getRfqHdList(Map<String, String> formData) throws IOException {

        Map<String, Object> paramObj = (Map) formData;

        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }

        return rq0300mapper.getRfqHdList(paramObj);
    }

    public Map<String, Object> getRfqHd(Map<String, String> formData) throws IOException {
        return rq0300mapper.getRfqHd(formData);
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



        rq0300mapper.chgRfqDate(formData);
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String transfer(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {

        for(Map<String, Object> data :  gridData) {
            data.put("CTRL_USER_ID", formData.get("CTRL_USER_TRANSFER_ID"));
            data.put("CTRL_USER_NM", formData.get("CTRL_USER_TRANSFER_NM"));
            rq0300mapper.transfer(data);
        }

        return msg.getMessage("0001");
    }




    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String closeRfq(List<Map<String, Object>> gridData) throws Exception {
        for(Map<String, Object> data :  gridData) {
            rq0300mapper.closeRfq(data);
        }
        return msg.getMessage("0001");
    }





    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0330)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getQtaList(Map<String, String> formData) throws Exception{

        Map<String, Object> paramObj = (Map) formData;

        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }
        return rq0300mapper.getQtaList(paramObj);
    }





    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 (RQ0340)
     * 처리내용 : (구매사) 개찰,선정 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getOpenSettleTargetList(Map<String, String> formData) throws Exception{
        Map<String, Object> paramObj = (Map) formData;

        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }
        return rq0300mapper.getOpenSettleTargetList(paramObj);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveQtaOpen(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {

        DecimalFormat df = new DecimalFormat("#");
        df.setMaximumFractionDigits(4);

    	for(Map<String, Object> data : gridData) {
    		rq0300mapper.saveQtaOpen(data);
            rq0300mapper.saveQtaOpenDt(data);

    		//개찰 : QTHD 복호화
    		List<Map<String, Object>> qtVendorlist = rq0300mapper.getDecAmtVendorList(data);
    		for(Map<String, Object> qtVendor : qtVendorlist){
                String key = qtVendor.get("VENDOR_CD") + "ENCRIPT" + qtVendor.get("VENDOR_CD");
                qtVendor.put("HDEC_QTA_AMT", df.format(Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtVendor.get("HENC_QTA_AMT"))))));
                rq0300mapper.updateDecodeQthd(qtVendor);
            }

    		//개찰 : QTDT 복호화
    		List<Map<String, Object>> qtItemlist = rq0300mapper.getDecAmtItemList(data);
        	for(Map<String, Object> qtItem : qtItemlist) {
                String key = qtItem.get("VENDOR_CD") + "ENCRIPT" + qtItem.get("VENDOR_CD");
                qtItem.put("DDEC_UNIT_PRC",df.format(Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DENC_UNIT_PRC"))))));
                qtItem.put("DDEC_QTA_AMT",df.format(Double.parseDouble(EverEncryption.aes256Decode(key, String.valueOf(qtItem.get("DHENC_QTA_AMT"))))));
           	 	rq0300mapper.updateDecodeQtdt(qtItem);
        	}

    	}
    	return msg.getMessage("0001");
	}



    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적/입찰관리 > 협력사선정 (RQ0340P02)
     * 처리내용 : (구매사) 아이템별 협력사선정 조회하는 화면
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> getSettleItemList(Map<String, String> formData) throws Exception{
    	Map<String, Object> paramObj = (Map) formData;
    	Map<String, String> sParam = new HashMap<String, String>();

    	if (!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
    		sParam.put("COL_VAL", formData.get("ITEM_DESC"));
    		sParam.put("COL_NM", "B.ITEM_DESC||B.ITEM_SPEC||B.ITEM_CD");
    		paramObj.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}
        if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
            paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
        }
        formData.put("SCREEN_TYPE", "RQ0340");
        return rq0300mapper.getSettleItemList(paramObj);
    }

    public List<Map<String, Object>> getTargetVendor(Map<String, String> formData) throws Exception{
        return rq0300mapper.getTargetVendor(formData);
    }
    public List<Map<String, Object>> getTargetItemList(Map<String, String> formData) throws Exception{
        return rq0300mapper.getTargetItemList(formData);
    }

    //협력업체 선정 승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endExecApproval(String docNum, String docCnt, String signStatus) throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);

        rq0300mapper.updateRqSignStatus2(map);

        UserInfo userInfo = UserInfoManager.getUserInfo();
        map.put("BUYER_CD", userInfo.getCompanyCd());

        Map<String,String> rqHd = (Map)rq0300mapper.getRfqHd(map);
        if(signStatus.equals("E")){
            rqHd.put("PROGRESS_CD", "2500"); // 업체선정완료
            rq0300mapper.setDocSettleCancelRqhd(rqHd); //PRHD PROGRESS CD 업데이트
            rq0300mapper.updateRqdtProgress(rqHd);  //PRDT PROGRESS CD 업데이트

            //승인 후 업체선정날짜 데이터 넣어줌.
            List<Map<String,String>> qtaNumList = rq0300mapper.getQtaNumByRfxnum(map);
            for(Map<String,String> qtaNum : qtaNumList){
                rq0300mapper.updateSltDate(qtaNum);

            }


        }else if(signStatus.equals("R")){
            rqHd.put("PROGRESS_CD", "2400"); // 승인 올리기 전 상태
            rq0300mapper.setDocSettleCancelRqhd(rqHd); //PRHD PROGRESS CD 업데이트
            rq0300mapper.updateRqdtProgress(rqHd);  //PRDT PROGRESS CD 업데이트

            List<Map<String,String>> qtaNumList = rq0300mapper.getQtaNumByRfxnum(map);
            for(Map<String,String> qtaNum : qtaNumList){
                rq0300mapper.rejectExec(qtaNum);
            }

        }

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));

    }

    //총액별 업체 선정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String setDocSettle(Map<String, String> formData, List<Map<String, Object>> gridV) throws Exception {

        for(Map<String,Object> grid : gridV) {
            rq0300mapper.setDocSettleQtdt(grid);
        }

        formData.put("PROGRESS_CD","2500");
        rq0300mapper.updateRqhdSignStatus2(formData);
        rq0300mapper.updateRqdtProgress(formData);  //PRDT PROGRESS CD 업데이트

        //승인 후 업체선정날짜 데이터 넣어줌.
        List<Map<String,String>> qtaNumList = rq0300mapper.getQtaNumByRfxnum(formData);
        for(Map<String,String> qtaNum : qtaNumList){
            rq0300mapper.updateSltDate(qtaNum);
        }

    	return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelRfq(Map<String, String> formData) throws Exception {
    	formData.put("PROGRESS_CD", "1300"); // 유찰
        rq0300mapper.setDocSettleCancelRqhd(formData);
        rq0300mapper.updateRqdtProgress(formData);
        rq0300mapper.setCancelPrdt(formData);

    	return msg.getMessage("0001");
    }

    //품목별 업체선정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doItemSettle(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {

        formData.put("PROGRESS_CD","2500");
        rq0300mapper.updateRqhdSignStatus2(formData);
        rq0300mapper.updateRqdtProgress(formData);  //PRDT PROGRESS CD 업데이트

        for( Map<String, Object> data : gridData) {
            rq0300mapper.setItemSettleQtdt(data);
        }

        //승인 후 업체선정날짜 데이터 넣어줌.
        List<Map<String,String>> qtaNumList = rq0300mapper.getQtaNumByRfxnum(formData);
        for(Map<String,String> qtaNum : qtaNumList){
            rq0300mapper.updateSltDate(qtaNum);
        }

    	return msg.getMessage("0001");
    }


    /****************************************************************q****************************
     * 구매사> 구매관리 > 견적관리 > 견적비교 (RQ0340P03)
     * 처리내용 : 견적 비교하는 창
     */
    public List<Map<String,Object>> getAdditionalColumnInfos(Map<String,String> param){
        return rq0300mapper.getAdditionalColumnInfos(param);
    }

    public List<Map<String,Object>> doSearchComparisonTable(Map<String,String> param){
        Map<String,Object> newParam = new HashMap<>();
        newParam.putAll(param);
        newParam.put("additionalColumnInfoList", rq0300mapper.getAdditionalColumnInfos(param));
        return rq0300mapper.doSearchComparisonTable(newParam);
    }

    // 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void progressApproval(String docNum, String docCnt, String signStatus, String rfxNum) throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);
        map.put("RFX_NUM", rfxNum);
        rq0300mapper.updateSignStatus(map);

    }

    // 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
	public String endApproval(String appDocNum, String appDocCnt, String signStatus) throws Exception {
		 Map<String, String> map = new HashMap<String, String>();
		map.put("APP_DOC_NUM", appDocNum);
        map.put("APP_DOC_CNT", appDocCnt);
        map.put("SIGN_STATUS", signStatus);
        String progressCd ="";
        String rtnmsg="";
        if(signStatus.equals("E")){
            progressCd = "2350";
            rtnmsg = msg.getMessage("0057"); // 승인이 완료되었습니다
        }else if(signStatus.equals("R")){
            progressCd = "2300";
            rtnmsg = msg.getMessage("0058"); // 반려 처리되었습니다.
        }else {
        	 progressCd = "2300";
             rtnmsg = msg.getMessage("0061"); // 취소 처리되었습니다.
        }

        map.put("PROGRESS_CD",progressCd);
        rq0300mapper._doUpdateSignStatus(map);
		return rtnmsg;
	}

	/**
	 * 견적요청서 업체 전송 후 메일, sms 발송
	 * @param rqhdData
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void sendEmail(Map<String, String> rqhdData) throws Exception {
		// E-Mail, SMS 발송
        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
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

        Map<String, String> rfqData = rq0300mapper.getRfxInfoHD(rqhdData);
        String rfqNumCnt = EverString.nullToEmptyString(rfqData.get("RFX_NUM")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("RFX_CNT")));
        String vendorOpenDealType = EverString.nullToEmptyString(rfqData.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("DELY_TYPE")));
//        String rmkText = largeTextService.selectLargeText(EverString.nullToEmptyString(rfqData.get("RMK_TEXT_NUM")));

//        String tblBody = "<tbody>";
//        String enter = "\n";
//        List<Map<String, String>> itemList = rq0300mapper.getRfxItemList(rqhdData);
//        if(itemList.size() > 0) {
//            for (Map<String, String> itemData : itemList) {
//
//                String itemDesc = itemData.get("ITEM_DESC");
//                if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }
//
//                String itemSpec = itemData.get("ITEM_SPEC");
//                if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }
//
//                String tblRow = "<tr>"
//                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
//                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
//                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</th>"
//                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</th>"
//                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</th>"
//                        + enter + "</tr>";
//                tblBody += tblRow;
//            }
//        }

        List<Map<String, String>> vendorList = rq0300mapper.getRfxVendorList(rqhdData);
        for (Map<String, String> vendorData : vendorList) {

            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", (vendorData.get("VENDOR_NM") == null ? "" : vendorData.get("VENDOR_NM"))); // 공급사명
            fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", (rfqNumCnt == null ? "" : rfqNumCnt)); // 견적의뢰번호/차수
            fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", (rfqData.get("RFX_SUBJECT") == null ? "" : rfqData.get("RFX_SUBJECT"))); // 견적의뢰명
            fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", rfqData.get("RFQ_CLOSE_DATE") == null ? "" : rfqData.get("RFQ_CLOSE_DATE")); // 견적마감일시
            fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", (vendorOpenDealType == null ? "" : vendorOpenDealType)); // 지명방식/거래유형
            fileContents = EverString.replace(fileContents, "$RMK_TEXT$", (rfqData.get("RMK") == null ? "" : rfqData.get("RMK"))); // 요청사항
            fileContents = EverString.replace(fileContents, "$CTRL_USER_NM$", (rfqData.get("CTRL_USER_NM") == null ? "" : rfqData.get("CTRL_USER_NM"))); // 품목담당자
            fileContents = EverString.replace(fileContents, "$TEL_NUM$", (rfqData.get("TEL_NUM") == null ? "" : rfqData.get("TEL_NUM"))); // 연락처
            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
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
                mdata.put("REF_NUM", rfqData.get("RFQ_NUM"));
                mdata.put("REF_MODULE_CD","RFQ"); // 참조모듈
                // 메일전송.
                everMailService.sendMail(mdata);
                mdata.clear();
            }
            else {
            	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 email 정보가 없습니다.");
            }

            if(!(vendorData.get("RECV_TEL_NUM")==null) && !vendorData.get("RECV_TEL_NUM").equals("")) {
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("SMS_SUBJECT", "[대명소노시즌] 견적요청서가 도착했습니다."); // SMS 제목
                sdata.put("CONTENTS", "[대명소노시즌] 견적요청서가 도착했습니다.(" + vendorData.get("RFX_NUM") + ") 빠른 견적진행 부탁드립니다."); // 전송내용
                sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(vendorData.get("SEND_USER_ID")).equals("") ? "SYSTEM" : vendorData.get("SEND_USER_ID"))); // 보내는 사용자ID
                sdata.put("SEND_USER_NM",vendorData.get("SEND_USER_NM")); // 보내는사람
                sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                sdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID")); // 받는 사용자ID
                sdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM")); // 받는사람
                sdata.put("RECV_TEL_NUM", vendorData.get("RECV_TEL_NUM")); // 받는 사람 전화번호
                sdata.put("REF_NUM", rfqData.get("RFX_NUM")); // 참조번호
                sdata.put("REF_MODULE_CD","RFQ"); // 참조모듈
                // SMS 전송.
                everSmsService.sendSms(sdata);
                sdata.clear();
            }
            else {
            	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 전화번호 정보가 없습니다.");
            }
        }
	}

	public List<Map<String, Object>> getSettleItemListP02(Map<String, String> formData) {
		// TODO Auto-generated method stub
		return rq0300mapper.getSettleItemListP02(formData);
	}

}