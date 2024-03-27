package com.st_ones.evermp.BGA1.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BGA1.BGA1_Mapper;
import com.st_ones.evermp.OD03.OD03_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "bga1_Service")
public class BGA1_Service extends BaseService {

	@Autowired BGA1_Mapper bga1_Mapper;
	@Autowired OD03_Mapper od03_Mapper;
	@Autowired MessageService msg;

	@Autowired private EverMailService everMailService;
	@Autowired private QueryGenService queryGenService;

	/**
	 * *****************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 미입고관리
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga1010_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();
		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
		}

		if (!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if (!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}
		if (!EverString.nullToEmptyString(param.get("BRAND_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.BRAND_NM", param.get("BRAND_NM"), "BRAND_NM");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "YPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "YPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

		if(EverString.isNotEmpty(param.get("INV_NO"))) {
			param.put("INV_NO_ORG", param.get("INV_NO"));
			param.put("INV_NO", EverString.forInQuery(param.get("INV_NO"), ","));
			param.put("INV_CNT", param.get("INV_NO").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return bga1_Mapper.bga1010_doSearch(param);
	}

	/**
	 * 입고처리 : 입고/정산 > 입고관리 > 입고대상 조회 (BGA1_010)
	 * @param gridData
	 * @param form
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void bga1010_doGrSave(Map<String, Object> gridData, Map<String, String> form) throws Exception {

		String PROGRESS_CD = "";
		String GR_COMPLETE_FLAG = "0";

		float CPO_QTY = Float.valueOf(String.valueOf(gridData.get("CPO_QTY")));
		float GR_QTY  = Float.valueOf(String.valueOf(gridData.get("GR_QTY")));

		gridData.put("GR_DATE", form.get("GR_DATE"));
		gridData.put("CANCEL_YN", "N");





		bga1_Mapper.bga1010_doGrSaveGRDT(gridData);	 // STOCGRDT
		bga1_Mapper.bga1010_doGrSaveUIVDT(gridData); // STOUIVDT
		bga1_Mapper.bga1010_doGrSaveYIVDT(gridData); // STOYIVDT

		// 주문수량을 초과했습니다. 조회 후 다시 시도 하세요.
		int TOT_GR_QTY = bga1_Mapper.bga1010_doSearchTOT_GR_QTY(gridData);
		if(CPO_QTY < (TOT_GR_QTY + GR_QTY)) throw new Exception("주문수량을 초과했습니다. 조회 후 다시 시도 하세요.");





		if (CPO_QTY == (TOT_GR_QTY + GR_QTY)) {
			PROGRESS_CD = "6300"; 	// 입고완료
			GR_COMPLETE_FLAG = "1";
		} else {
			PROGRESS_CD = "6120";	// 부분입고
		}

		gridData.put("PROGRESS_CD", PROGRESS_CD);
		gridData.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);

		// 공급사, 운영사 발주 및 납품
		bga1_Mapper.bga1010_doGrSaveYPODT(gridData);	// STOYPODT

		// 고객사 주문
		bga1_Mapper.bga1010_doGrSaveUPODT(gridData);	// STOUPODT







		Map<String, Object> chkPoGrData = od03_Mapper.chkPoGr(gridData);
		float totGrQty = Float.valueOf(String.valueOf(chkPoGrData.get("TOT_GR_QTY")));
		float cpoQty = Float.valueOf(String.valueOf(chkPoGrData.get("CPO_QTY")));

		if ( cpoQty < totGrQty ) {
			throw new Exception("주문수량을 초과했습니다. 조회 후 다시 시도 하세요.");
		}

	}

	/**
	 * *****************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 입고관리
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga1030_doSearch(Map<String, String> param) throws Exception {

		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}
		if (!EverString.nullToEmptyString(param.get("BRAND_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.BRAND_NM", param.get("BRAND_NM"), "BRAND_NM");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("INV_NO"))) {
			param.put("INV_NO_ORG", param.get("INV_NO"));
			param.put("INV_NO", EverString.forInQuery(param.get("INV_NO"), ","));
			param.put("INV_CNT", param.get("INV_NO").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return bga1_Mapper.bga1030_doSearch(param);
	}

	public String bga1030_SELECT_CODD() {

		return bga1_Mapper.bga1030_SELECT_CODD();
	}

	public List<Map<String, Object>> bga1030_doSearchEXCEL(Map<String, String> param) throws Exception {

		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "UPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}
		if (!EverString.nullToEmptyString(param.get("BRAND_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.BRAND_NM", param.get("BRAND_NM"), "BRAND_NM");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("INV_NO"))) {
			param.put("INV_NO_ORG", param.get("INV_NO"));
			param.put("INV_NO", EverString.forInQuery(param.get("INV_NO"), ","));
			param.put("INV_CNT", param.get("INV_NO").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return bga1_Mapper.bga1030_doSearchEXCEL(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bga1030_doGrCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
		String PROGRESS_CD = "";
		String GR_COMPLETE_FLAG = "0";
		String CPO = "";

		for (Map<String, Object> gridData : gridList) {


			int chkCount = od03_Mapper.chkGrdt(gridData); // 이미 처리된건 continue
			if(chkCount==0) {
				throw new Exception("이미처리된건입니다.");
			}
			int chkCountSubul = od03_Mapper.chkGrdtSubul(gridData); // 확청처리 된건
			if(chkCountSubul==0) {
				throw new Exception("마감여부를 확인해주세요.");
			}




			float GR_QTY = Float.valueOf(String.valueOf(gridData.get("GR_QTY")));

			gridData.put("CANCEL_YN", "Y");

			bga1_Mapper.bga1030_doGrCancelGRDT(gridData);
			bga1_Mapper.bga1010_doGrSaveUIVDT(gridData);
			bga1_Mapper.bga1010_doGrSaveYIVDT(gridData);


			PROGRESS_CD = "6120";

			gridData.put("PROGRESS_CD", PROGRESS_CD);
			gridData.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);

			bga1_Mapper.bga1010_doGrSaveYPODT(gridData);
			bga1_Mapper.bga1010_doGrSaveUPODT(gridData);



			Map<String, Object> chkPoGrData = od03_Mapper.chkPoGr(gridData);
			float totGrQty = Float.valueOf(String.valueOf(chkPoGrData.get("TOT_GR_QTY")));

			if ( totGrQty < 0) {
				throw new Exception("조회 후 다시 시도 하세요.");
			}
			//if (1==1) throw new Exception("===================================================");
		}

		return msg.getMessageByScreenId("BGA1_030", "004");
	}

	/**
	 * *****************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 매입확정
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga1040_doSearch(Map<String, String> param) throws Exception {
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
		return bga1_Mapper.bga1040_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bga1040_doConfirm(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
		for (Map<String, Object> gridData : gridList) {

			if(bga1_Mapper.chkCloseAgree(gridData) !=0 ) {
				throw new Exception(msg.getMessageByScreenId("BGA1_040", "100"));
			}

			gridData.put("GR_CLOSE_YN", "1");
			bga1_Mapper.upsGrClose(gridData);

		}

		return msg.getMessageByScreenId("BGA1_040", "021");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bga1040_doCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
		for (Map<String, Object> gridData : gridList) {
			if(bga1_Mapper.chkCloseCancel(gridData) !=0 ) {
				throw new Exception(msg.getMessageByScreenId("BGA1_040", "100"));
			}

			gridData.put("GR_CLOSE_YN", "0");
			bga1_Mapper.upsGrClose(gridData);


		}

		return msg.getMessageByScreenId("BGA1_040", "022");
	}

	public List<Map<String, Object>> bga1040_doSearchEXCEL(Map<String, String> param) throws Exception {
		return bga1_Mapper.bga1040_doSearchEXCEL(param);
	}

	/**
	 * *****************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 정산현황
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga1050_doSearch(Map<String, String> param) throws Exception {


		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
		}




		return bga1_Mapper.bga1050_doSearch(param);
	}


	/**
	 * *****************************************************************************************
	 * 고객사 > 입고/정산 > 납품지연현황
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga1060_doSearch(Map<String, String> param) throws Exception {

		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "UPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
			param = getQueryParam(param, "UPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
			param = getQueryParam(param, "UPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}
		if (!EverString.nullToEmptyString(param.get("BRAND_NM")).trim().equals("")) {
			param = getQueryParam(param, "YPODT.BRAND_NM", param.get("BRAND_NM"), "BRAND_NM");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("INV_NO"))) {
			param.put("INV_NO_ORG", param.get("INV_NO"));
			param.put("INV_NO", EverString.forInQuery(param.get("INV_NO"), ","));
			param.put("INV_CNT", param.get("INV_NO").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return bga1_Mapper.bga1060_doSearch(param);
	}

	/**
     * 납기지연 선택하여 메일 보내기
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doAlarmInvoiceDelay(List<Map<String, Object>> gridList) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_DELAY_TemplateFileName");

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

        // 납품지연 주문의 운영사 품목담당자 가져오기
		String fileContents   = "";
        for( Map<String, Object> gridData : gridList ){

    		Map<String, Object> rowData = bga1_Mapper.getInvoiceDelayItemList(gridData);

            // 공급사 품목담당자에게 mail 발송하기
    		fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
    		fileContents = EverString.replace(fileContents, "$CURRENT_DATE$", EverString.nullToEmptyString(rowData.get("CUR_DATE"))); 	// 현재일자
        	fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(rowData.get("VENDOR_USER_NM"))); 	// 메일 수신자
            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

            String tblBody = "<tbody>";
            String enter = "\n";

            // 품목정보 가져오기
            String tblRow = "<tr>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>[" + EverString.nullToEmptyString(rowData.get("CUST_CD")) + "] " + EverString.nullToEmptyString(rowData.get("CUST_NM")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(rowData.get("CPO_NO")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(rowData.get("CPO_USER_NM")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(rowData.get("PO_NO")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(rowData.get("HOPE_DUE_DATE")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>[" + EverString.nullToEmptyString(rowData.get("VENDOR_CD")) + "] " + EverString.nullToEmptyString(rowData.get("VENDOR_NM")) + "</th>"
                    + enter + "</tr>";
            tblBody += tblRow;

            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            Map<String, String> mdata = new HashMap<String, String>();
            mdata.put("SUBJECT", "[대명소노시즌] 금일(" + EverString.nullToEmptyString(rowData.get("CUR_DATE")) + ")부로 납품이 '지연'되는 주문건이 있습니다.");
            mdata.put("CONTENTS_TEMPLATE", fileContents);
            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VENDOR_USER_ID")));
            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VENDOR_USER_NM")));
            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(rowData.get("VENDOR_USER_EMAIL")));
            mdata.put("REF_NUM", "");
            mdata.put("REF_MODULE_CD", "PO"); // 참조모듈
			// SMS 발송
			everMailService.sendMail(mdata);
			mdata.clear();
        }
        return msg.getMessage("0001");
	}

	/**
	 * 입력값의 유사어를 찾아서 like로 묶어서 리턴
	 * @param param 파라메터
	 * @param COL_NM 컬럼명
	 * @param COL_VAL 컬럼값
	 * @param key 바인딩명
	 * @return map
	 */
	public Map<String, String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
		param.put("COL_NM", COL_NM);
		param.put("COL_VAL", COL_VAL);

		param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

		return param;
	}
}