package com.st_ones.evermp.OD03.service;

import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.evermp.OD03.OD03_Mapper;
import com.st_ones.evermp.SIV1.SIV103_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "od03_Service")
public class OD03_Service extends BaseService {

	@Autowired private QueryGenService queryGenService;
	@Autowired private DocNumService docNumService;

	@Autowired OD03_Mapper od03_Mapper;

	@Autowired MessageService msg;

	@Autowired	SIV103_Mapper siv103_Mapper;

	@Autowired
	private EverMailService everMailService;

	@Autowired
    private EverSmsService everSmsService;

	@Autowired
	private RealtimeIF_Service realtimeifService;

	/** ******************************************************************************************
     * 운영사 > 주문관리 > 입고현황 > 미입고현황
     * @param param
     * @return List
     * @throws Exception
     */
	public List<Map<String, Object>> od03010_doSearch(Map<String, String> param) throws Exception {
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}


		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return od03_Mapper.od03010_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void od03010_doGrSave(Map<String, Object> gridData, Map<String, String> form) throws Exception {
		String PROGRESS_CD = "";
		String GR_COMPLETE_FLAG = "0";

		float CPO_QTY = Float.valueOf(String.valueOf(gridData.get("CPO_QTY")));
		float GR_QTY = Float.valueOf(String.valueOf(gridData.get("GR_QTY")));
		String DEAL_CD = String.valueOf(String.valueOf(gridData.get("DEAL_CD")));
		String VENDOR_CD= String.valueOf(String.valueOf(gridData.get("VENDOR_CD")));
		String CUST_CD= String.valueOf(String.valueOf(gridData.get("CUST_CD")));
		String MMRS =form.get("MMRS");

		if(!EverString.isEmpty(MMRS)){
			if(DEAL_CD.equals("400")){
				gridData.put("CUST_CD", VENDOR_CD);
			}
			od03_Mapper.od03030_doMMRSInsert(gridData);

		}
		gridData.put("GR_DATE", form.get("GR_DATE"));
		gridData.put("CANCEL_YN", "N");
		gridData.put("CUST_CD", CUST_CD);

		od03_Mapper.od03010_doGrSaveGRDT(gridData);
		od03_Mapper.od03010_doGrSaveUIVDT(gridData);
		od03_Mapper.od03010_doGrSaveYIVDT(gridData);

		int TOT_GR_QTY = od03_Mapper.od03010_doSearchTOT_GR_QTY(gridData);


		if(CPO_QTY < (TOT_GR_QTY + GR_QTY)) throw new Exception("주문수량을 초과했습니다. 조회 후 다시 시도 하세요.");


		if(CPO_QTY == (TOT_GR_QTY + GR_QTY)) {
			PROGRESS_CD = "6300";
			GR_COMPLETE_FLAG = "1";
		} else {
			PROGRESS_CD = "6120";
		}

		gridData.put("PROGRESS_CD", PROGRESS_CD);
		gridData.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);

		od03_Mapper.od03010_doGrSaveUPODT(gridData);
		od03_Mapper.od03010_doGrSaveYPODT(gridData);


		Map<String, Object> chkPoGrData = od03_Mapper.chkPoGr(gridData);
		float totGrQty = Float.valueOf(String.valueOf(chkPoGrData.get("TOT_GR_QTY")));
		float cpoQty = Float.valueOf(String.valueOf(chkPoGrData.get("CPO_QTY")));

		if ( cpoQty < totGrQty ) {
			throw new Exception("주문수량을 초과했습니다. 조회 후 다시 시도 하세요.");
		}

		//if(1==1) throw new Exception("===============================================");
	}

	/** ******************************************************************************************
	 * 운영사 > 주문관리 > 입고현황 > 입고현황
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> od03020_doSearch(Map<String, String> param) throws Exception {
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return od03_Mapper.od03020_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od03020_doGrCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
		String PROGRESS_CD = "";
		String GR_COMPLETE_FLAG = "0";

		for(Map<String, Object> gridData : gridList) {


			int chkCount = od03_Mapper.chkGrdt(gridData); // 이미 처리된건 continue
			if(chkCount==0) {
				throw new Exception("이미 처리된 건 입니다.");
			}


			int chkCountSubul = od03_Mapper.chkGrdtSubul(gridData); // 확청처리 된건
			if(chkCountSubul==0) {
				throw new Exception("마감여부를 확인해주세요.");
			}

			String grNo = String.valueOf(gridData.get("GR_NO"));
			if("X".equals(grNo.substring(0,1))) { // 정산용은 일괄 주문까지 삭제
				od03_Mapper.deleteUpoHD(gridData);
				od03_Mapper.deleteUpoDT(gridData);
				od03_Mapper.deleteYpoHD(gridData);
				od03_Mapper.deleteYpoDT(gridData);
				od03_Mapper.deleteIvHD(gridData);
				od03_Mapper.deleteIvDT(gridData);
				od03_Mapper.deleteInvHD(gridData);
				od03_Mapper.deleteInvDT(gridData);
				od03_Mapper.deleteGrDT(gridData);


			} else {

	            String MMRS =form.get("MMRS");
	            if(!EverString.isEmpty(MMRS)){
	    			od03_Mapper.od03040_doDeleteMMRS(gridData);
	    		}

				gridData.put("CANCEL_YN", "Y");

				od03_Mapper.od03020_doGrCancelGRDT(gridData);
				od03_Mapper.od03010_doGrSaveUIVDT(gridData);
				od03_Mapper.od03010_doGrSaveYIVDT(gridData);

				PROGRESS_CD = "6120";


				gridData.put("PROGRESS_CD", PROGRESS_CD);
				gridData.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);

				od03_Mapper.od03010_doGrSaveYPODT(gridData);
				od03_Mapper.od03010_doGrSaveUPODT(gridData);


				Map<String, Object> chkPoGrData = od03_Mapper.chkPoGr(gridData);
				float totGrQty = Float.valueOf(String.valueOf(chkPoGrData.get("TOT_GR_QTY")));

				if ( totGrQty < 0) {
					throw new Exception("조회 후 다시 시도 하세요.");
				}

			}

			//if (1==1) throw new Exception("==========================================");
		}

		return msg.getMessageByScreenId("OD03_020", "004");
	}

	public Map<String,String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
		param.put("COL_NM", COL_NM);
		param.put("COL_VAL", COL_VAL);

		param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

		return param;
	}



	public List<Map<String, Object>> od03030_doSearch(Map<String, String> param) throws Exception {
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return od03_Mapper.od03030_doSearch(param);
	}

	/** ******************************************************************************************
	 * 재고관리 > 재고입고관리 > 물류센터 입고현황 (OD03_040) (OD03_030)
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> od03040_doSearch(Map<String, String> param) throws Exception {
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return od03_Mapper.od03040_doSearch(param);
	}


	// 운영사 납품서 수정
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od03030_doSave(List<Map<String, Object>> gridList) throws Exception {

		// 1. IVHD 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			od03_Mapper.od03030_doUpdateUIVHD(gridData);
			// STOY 업데이트
			od03_Mapper.od03030_doUpdateYIVHD(gridData);
		}

		// 2. IVDT 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			od03_Mapper.od03030_doUpdateUIVDT(gridData);
			// STOY 업데이트
			od03_Mapper.od03030_doUpdateYIVDT(gridData);

			Map<String, Object> checkMap = od03_Mapper.getPoQtySumInvQty(gridData);
			double poQty  = Double.parseDouble(String.valueOf(checkMap.get("PO_QTY")));
			double invQty = Double.parseDouble(String.valueOf(checkMap.get("INV_QTY")));
			if(poQty > 0) {
				if(poQty < invQty) {
					throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CODE"));
				}
			} else {
				if(poQty > invQty) {
					throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CODE"));
				}
			}
		}

		// 3. PODT 업데이트
		boolean isChangeFlag = false;
		String cpoNo = "";
		Map<String, Object> ivSeqMap = null;
		List<Map<String, Object>> ivSeqList = new ArrayList<Map<String, Object>>();
		for( Map<String, Object> gridData : gridList ) {
			// 3-1. STOU 업데이트
			od03_Mapper.od03030_doUpdateUPODT(gridData);
			// 3-2. STOY 업데이트
			od03_Mapper.od03030_doUpdateYPODT(gridData);

			// 납품예정일이 변경되는 경우에만 메일 발송
			if( gridData.get("DELY_APP_DATE") != gridData.get("DELY_APP_DATE_RES") ){
				isChangeFlag = true;
				cpoNo = gridData.get("CPO_NO").toString();

				ivSeqMap = new HashMap<String, Object>();
				ivSeqMap.put("IV_NO_SEQ", String.valueOf(gridData.get("IV_NO")) + String.valueOf(gridData.get("IV_SEQ")));
				ivSeqList.add(ivSeqMap);
			}
		}

		// 납품서 변경 EMAIL 및 SMS 발송
		/*try {
			if( !"".equals(cpoNo) && isChangeFlag ){
				Map<String, Object> mailParam = new HashMap<String, Object>();
				mailParam.put("CPO_NO", cpoNo);
				mailParam.put("ivSeqList", ivSeqList);
				sendEmailNSms_Change(mailParam);
			}
		} catch ( Exception ex ){
			System.out.println("=====>  물류센터 입고대상목록 (OD03_030) EMAIL, SMS 발송 오류 : " + ex);
		}
		 2022 12 22 납품일 변경시 메일발송 삭제
		 */
		return msg.getMessage("0001");
	}

	@AuthorityIgnore
	public void sendEmailNSms_Change(Map<String, Object> param) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_CHNG_TemplateFileName");

        String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm  = PropertiesManager.getString("eversrm.system.contextName");
		
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

		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		// 주문헤더(UPOHD) 가져오기
        Map<String, Object> cpoUserInfo = siv103_Mapper.getInvChangeHeaderInfo(param);
        // 고객사 주문자에게 EMAIL 전송
        fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 주문번호
        fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_DATE"))); // 주문일자
        fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 주문자명
        fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

        String tblBody = "<tbody>";
        String enter = "\n";
        // 주문품목(UPODT) 가져오기
        List<Map<String, Object>> itemList = siv103_Mapper.getInvChangeDetailInfo(param);
        if( itemList.size() > 0 ){
            for( Map<String, Object> itemData : itemList ){
                // 품목명
            	String itemDesc = (String)itemData.get("ITEM_DESC");
                if(itemDesc.length() > 29) { itemDesc = itemDesc.substring(0, 30) + "..."; }
                // 품목규격
                String itemSpec = (String)itemData.get("ITEM_SPEC");
                if(itemSpec.length() > 29) { itemSpec = itemSpec.substring(0, 30) + "..."; }

                // 품목리스트
                String tblRow = "<tr>"
                		+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd' rowspan='2'>" + EverString.nullToEmptyString(itemData.get("ITEM_CD")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
                        + enter + "</tr>"
                        + enter + "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("DELY_DELAY_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("DELY_APP_DATE")) + "</td>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }

        fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
        fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
        fileContents = EverString.rePreventSqlInjection(fileContents);

        // 운영사 진행관리담당자 -> 고객사 주문자
    	if( !"".equals(cpoUserInfo.get("CUST_EMAIL")) ){
            Map<String, String> mdata = new HashMap<String, String>();
            mdata.put("SUBJECT", "[대명소노시즌] 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납기일이 변경되었습니다.");
            mdata.put("CONTENTS_TEMPLATE", fileContents);
            mdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 주문자
            mdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM")));
            mdata.put("SEND_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("OPER_EMAIL")));
            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID")));
            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM")));
            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("CUST_EMAIL")));
            mdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")));
            mdata.put("REF_MODULE_CD","IV"); // 참조모듈
			// 메일발송
			everMailService.sendMail(mdata);
			mdata.clear();
        }

    	// 운영사 진행관리담당자 -> 고객사 주문자
        if( !"".equals(cpoUserInfo.get("CUST_CELL_NUM")) ){
            Map<String, String> hdata = new HashMap<String, String>();
            hdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))+"님. 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납기일이 변경되었습니다. 확인바랍니다."); // 전송내용
            hdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 보내는 사용자ID(운영사 품목담당자)
            hdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM"))); // 보내는사람(운영사 품목담당자)
            hdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 보내는 사람 전화번호(대표전화번호)
            hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID"))); // 받는 사용자ID(고객사 주문자)
            hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 받는사람(고객사 주문자)
            hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_CELL_NUM"))); // 받는 사람 전화번호(고객사 주문자)
            hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
            hdata.put("REF_MODULE_CD","IV"); // 참조모듈
			// SMS 발송
			everSmsService.sendSms(hdata);
			hdata.clear();
        }
	}

	// 운영사 납품취소
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od03030_doDelete(List<Map<String, Object>> gridList) throws Exception {

		for( Map<String, Object> gridData : gridList ) {

			int chkCount = od03_Mapper.chkUivdt(gridData);
			if(chkCount == 0) continue;

			int chkGrCount = od03_Mapper.chkGrdt(gridData);
			if(chkGrCount != 0) continue;

			// 1. IVDT 삭제
			od03_Mapper.od03030_doDeleteUIVDT(gridData);
			od03_Mapper.od03030_doDeleteYIVDT(gridData);
			// 2. PODT 업데이트
			od03_Mapper.od03030_doDeleteUPODT(gridData);
			od03_Mapper.od03030_doDeleteYPODT(gridData);
		}

		return msg.getMessage("0001");
	}

}
