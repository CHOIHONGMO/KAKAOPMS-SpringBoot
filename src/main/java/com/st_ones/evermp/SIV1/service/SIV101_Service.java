package com.st_ones.evermp.SIV1.service;

import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.BizHttp;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.evermp.SIV1.SIV101_Mapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : SIV101_Service.java
 * @author  개발자
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "siv101_Service")
public class SIV101_Service extends BaseService {

	@Autowired
	SIV101_Mapper siv101_Mapper;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	MessageService msg;

	@Autowired
	private DocNumService docNumService;

	@Autowired
	private EverMailService everMailService;

	@Autowired
	private EverSmsService everSmsService;


	@Autowired
	private RealtimeIF_Service realtimeifService;



	/**
	 * *****************************************************************************************
	 * 공급사 : 주문진행현황
	 *
	 * @param param
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> siv1010_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", param.get("ITEM_DESC"));
			sParam.put("COL_NM", "UPODT.ITEM_DESC");
			param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "UPODT.ITEM_SPEC");
			param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param.put("COL_NM", "UPODT.MAKER_CD");
			param.put("COL_VAL", param.get("MAKER_CD"));
			param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param.put("COL_NM", "UPODT.MAKER_NM");
			param.put("COL_VAL", param.get("MAKER_NM"));
			param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
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

		return siv101_Mapper.siv1010_doSearch(param);
	}

	/**
	 * *****************************************************************************************
	 * 공급사 : 납품서생성
	 *
	 * @param param
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> siv1020_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", param.get("ITEM_DESC"));
			sParam.put("COL_NM", "YPODT.ITEM_DESC");
			param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_SPEC");
			param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param.put("COL_NM", "YPODT.MAKER_CD");
			param.put("COL_VAL", param.get("MAKER_CD"));
			param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		if (!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param.put("COL_NM", "YPODT.MAKER_NM");
			param.put("COL_VAL", param.get("MAKER_NM"));
			param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
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

		return siv101_Mapper.siv1020_doSearch(param);
	}

	/**
	 * 납품생성
	 * @param gridList
	 * @throws Exception 들어오는 건별로 시작해서 CPO_NO가 같다면 채번은 같고 틀리다면 다르게 입력
	 *                   즉, 아예 라인수로 for문으로 데이터 입력 할 수 있게 작성
	 *                   단 한건만 들어오면 한건은 for문을 무시한다.더욱이 PODT에 INV에 입력할때는 주의해서 입력이 필요
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, Object> siv1020_doCreateInvoice(List<Map<String, Object>> gridList, List<Map<String, Object>> reqInList) throws Exception {

		String cpoNo  = gridList.get(0).get("CPO_NO").toString();
		String IV_NO  = ""; // 공급사 납품서 번호
		String INV_NO = ""; // 고객사 납품서 번호
		String invcCd = "";

		int invNoCount = 1;
		int invSeq = 1; // 납품서 항번
		Map<String, Object> respMap = new HashMap<String, Object>();
		respMap.put("IV_NO_0", IV_NO);
		invcCd = docNumService.getDocNumber("VO");

		for (int i = 0; i < gridList.size(); i++) {
			if(siv101_Mapper.chkIvPo(gridList.get(i)) !=0) {
				throw new Exception("이미 종결된 발주입니다.");
			}
			IV_NO  = docNumService.getDocNumber("IV");
			INV_NO = docNumService.getDocNumber("INV");

			Map<String, Object> reqMap = gridList.get(i);
			reqMap.put("IV_NO", IV_NO);
			reqMap.put("INV_NO", INV_NO);
			reqMap.put("IV_SEQ", invSeq);
			reqMap.put("IF_INVC_CD", invcCd); //거레명세서용
			reqInList.add(reqMap);

			siv1020_doCreateDB(reqMap, "wayCode_11");

		}

		respMap.put("invNoCount", Integer.toString(invNoCount));
		return respMap;
	}



	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, Object> siv1020_doCreateInvoice20230103(List<Map<String, Object>> gridList, List<Map<String, Object>> reqInList) throws Exception {

		String cpoNo  = gridList.get(0).get("CPO_NO").toString();
		String IV_NO  = docNumService.getDocNumber("IV"); // 공급사 납품서 번호
		String INV_NO = ""; // 고객사 납품서 번호

		int invNoCount = 1;
		int invSeq = 1; // 납품서 항번
		Map<String, Object> respMap = new HashMap<String, Object>();
		respMap.put("IV_NO_0", IV_NO);
		for (int i = 0; i < gridList.size(); i++) {

			if(siv101_Mapper.chkIvPo(gridList.get(i)) !=0) {
				throw new Exception("이미 종결된 발주입니다.");
			}

			if (i == 0) {
				//if( !"400".equals(gridList.get(0).get("DEAL_CD").toString()) ){
				INV_NO = docNumService.getDocNumber("INV");
				//}

				Map<String, Object> reqMap = gridList.get(0);
				reqMap.put("IV_NO", IV_NO);
				reqMap.put("INV_NO", INV_NO);
				reqMap.put("IV_SEQ", invSeq);
				reqInList.add(reqMap);

				siv1020_doCreateDB(reqMap, "wayCode_11");
			}
			else {
				// 동일 주문건
				if (cpoNo.equals(gridList.get(i).get("CPO_NO").toString()) || 1==1) {
					invSeq = invSeq + 1;

					Map<String, Object> reqMap = gridList.get(i);
					reqMap.put("IV_NO", IV_NO);
					reqMap.put("INV_NO", INV_NO);
					reqMap.put("IV_SEQ", invSeq);
					reqInList.add(reqMap);

					siv1020_doCreateDB(reqMap, "wayCode_00");
				}
			}
		}

		respMap.put("invNoCount", Integer.toString(invNoCount));
		return respMap;
	}

	// DB 등록
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void siv1020_doCreateDB(Map<String, Object> reqMap, String wayCode) throws Exception {
		//1. IVHD 입력
		if ("wayCode_11".equals(wayCode)) {
			// YIVHD (공급사납품)
			siv101_Mapper.siv1020_doCreateYIVHD(reqMap);
			// UIVHD (고객사납품) : 물류(운영사)
			//if( !"400".equals(reqMap.get("DEAL_CD").toString()) ){
			siv101_Mapper.siv1020_doCreateUIVHD(reqMap);
			//}
		}

		// 2. IVDT 입력
		// YIVDT (공급사납품)
		siv101_Mapper.siv1020_doCreateYIVDT(reqMap);
		// UIVDT (고객사납품) : 물류(운영사)
		//if(!"400".equals(reqMap.get("DEAL_CD").toString())){
		siv101_Mapper.siv1020_doCreateUIVDT(reqMap);
		//}

		siv101_Mapper.siv1020_doUpdateUPODT(reqMap);
		// 3. PODT 업데이트
		// YPODT (공급사발주)
		siv101_Mapper.siv1020_doUpdateYPODT(reqMap);

		Map<String, Object> checkMap = siv101_Mapper.getPoQtySumInvQty(reqMap);
		double poQty = Double.parseDouble(String.valueOf(checkMap.get("PO_QTY")));
		double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));

		if(poQty < podtInvQty) {
			throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + reqMap.get("CPO_NO") + ", 품목코드 : " + reqMap.get("ITEM_CD"));
		}

	}

	@Async
	public void siv1020_sendBizNetworkStorageNo(List<Map<String, Object>> gridData, String divYn, List<Map<String, Object>> reqInList) throws Exception{
		int num = 0;
		for (Map<String, Object> grid : gridData) {

			grid.putAll(reqInList.get(num));

			// 입하번호 받아오기 전에 YPODT 의 IF_CPO_NO, SEQ 가 존재하는지 조회
			Map<String, String> cpoInfo = siv101_Mapper.siv1020_doSearch_CPO_INFO(grid);

			if(cpoInfo != null) {
				cpoInfo.put("GR_QTY", String.valueOf(grid.get("INV_QTY")));
				//cpoInfo.put("GR_QTY", "252");
				cpoInfo.put("GR_DT", String.valueOf(grid.get("DELY_APP_DATE")));

				JSONArray jsArr = new JSONArray();

				String url = "";
				if (PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
					url = "http://211.194.150.42:8080/";
				} else {
					url = "http://srm.soulbrain.co.kr/";
				}

				JSONObject jsObj = new JSONObject();
				jsObj.put("PO_NO", cpoInfo.get("PO_NO"));
				jsObj.put("PO_LINE_LN", cpoInfo.get("PO_LINE_LN"));
				jsObj.put("GR_QTY", cpoInfo.get("GR_QTY"));
				jsObj.put("GR_DT", cpoInfo.get("GR_DT"));

				// 일괄/분할 여부 판단
				if(String.valueOf(grid.get("CPO_QTY")).equals(String.valueOf(grid.get("INV_QTY")))) {
					jsObj.put("DIV_YN", "N");
				} else {
					jsObj.put("DIV_YN", "Y");
				}

				jsArr.put(0, jsObj);

				BizHttp http = new BizHttp(url+"srmInBound.jsp", BizHttp.HttpMethod.POST);

				http.addBody("S_PO_NO", cpoInfo.get("PO_NO"));
				http.addBody("ITEMLIST", ""+jsArr);

				JSONObject resultJson = http.getJSONObject();
				JSONArray jsGrlist = resultJson.getJSONArray("GRLIST");

				// 입하번호 update
				String sInvcCd = getStroageNo(jsGrlist);

				grid.put("sInvcCd", sInvcCd);
				siv101_Mapper.siv1020_doUpdateYIVDT(grid);
				siv101_Mapper.siv1020_doUpdateUIVDT(grid);

				num++;
			}
		}
	}

	public String getStroageNo(JSONArray jsArray)
	{
		String sInvcCd = null;
		for(int i=0; i < jsArray.length(); i++)
		{
			JSONObject jsObj = (JSONObject)jsArray.get(i);
			sInvcCd = (String)jsObj.get("S_INVC_CD");
		}
		return sInvcCd;
	}

	/**
	 * SIV1_021 : 분할납품 생성 (메일, SMS 발송 없음)
	 *
	 * @param reqListMap
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> siv1021_doCreateInvoice(Map<String, String> formData, List<Map<String, Object>> reqListMap, List<Map<String, Object>> reqInList) throws Exception {
		int invSeq = 1; // 납품항번
		int invNoCount = 0;
		Map<String, String> respMap = new HashMap<String, String>();
		for (int i = 0; i < reqListMap.size(); i++) {
			String IV_NO = docNumService.getDocNumber("IV"); // 공급사 납품번호
			String INV_NO = ""; // 고객사 납품번호
			//if( !"400".equals(formData.get("DEAL_CD").toString()) ){
			INV_NO = docNumService.getDocNumber("INV");
			//}

			respMap.put("IV_NO_" + i, IV_NO);
			invNoCount = invNoCount + 1;

			Map<String, Object> reqMap = reqListMap.get(i);
			reqMap.put("IV_NO", IV_NO);  // 공급사 납품번호
			reqMap.put("INV_NO", INV_NO); // 고객사 납품번호
			reqMap.put("IV_SEQ", invSeq); // 고객사 납품항번
			reqMap.put("CPO_NO", formData.get("CPO_NO"));
			reqMap.put("CPO_SEQ", formData.get("CPO_SEQ"));
			reqMap.put("PO_NO", formData.get("PO_NO"));
			reqMap.put("PO_SEQ", formData.get("PO_SEQ"));
			reqMap.put("CUST_CD", formData.get("CUST_CD"));
			reqMap.put("PO_UNIT_PRICE", formData.get("PO_UNIT_PRICE"));
			reqMap.put("RECIPIENT_NM", formData.get("RECIPIENT_NM"));
			reqMap.put("RECIPIENT_DEPT_NM", formData.get("RECIPIENT_DEPT_NM"));
			reqMap.put("RECIPIENT_TEL_NUM", formData.get("RECIPIENT_TEL_NUM"));
			reqMap.put("RECIPIENT_CELL_NUM", formData.get("RECIPIENT_CELL_NUM"));
			reqMap.put("DELY_ZIP_CD", formData.get("DELY_ZIP_CD"));
			reqMap.put("DELY_ADDR_1", formData.get("DELY_ADDR_1"));
			reqMap.put("DELY_ADDR_2", formData.get("DELY_ADDR_2"));
			reqMap.put("AGENT_YN", formData.get("AGENT_YN"));

			reqInList.add(reqMap);

			// 1. IVHD 입력
			// YIVHD (공급사납품)
			siv101_Mapper.siv1020_doCreateYIVHD(reqMap);
			// UIVHD (고객사납품) : 물류(운영사)
			//if( !"400".equals(reqMap.get("DEAL_CD").toString()) ){
			siv101_Mapper.siv1020_doCreateUIVHD(reqMap);
			//}

			// 2. IVDT 입력
			// YIVDT (공급사납품)
			siv101_Mapper.siv1020_doCreateYIVDT(reqMap);
			// UIVDT (고객사납품) : 물류(운영사)
			//if(!"400".equals(reqMap.get("DEAL_CD").toString())){
			siv101_Mapper.siv1020_doCreateUIVDT(reqMap);
			//}

			// 3. PODT 업데이트
			// YPODT (공급사납품)
			siv101_Mapper.siv1020_doUpdateYPODT(reqMap);
			// UPODT (고객사납품) : 물류(운영사)
			//if( !"400".equals(reqMap.get("DEAL_CD").toString()) ){
			siv101_Mapper.siv1020_doUpdateUPODT(reqMap);
			//}
		}

		return respMap;
	}

	// 공급사 납품거부
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1020_doRejectInvoice(List<Map<String, Object>> gridList) throws Exception {
		String cpoNo = "";
		String vendorCd = "";
		Map<String, Object> cpoSeqMap = null;
		List<Map<String, Object>> cpoSeqList = new ArrayList<Map<String, Object>>();
		for( Map<String, Object> gridData : gridList ){
			siv101_Mapper.siv1020_doRejectInvoice(gridData);

			if( "".equals(cpoNo) ){
				cpoNo = (String) gridData.get("CPO_NO");
				vendorCd = (String) gridData.get("VENDOR_CD");
			}

			cpoSeqMap = new HashMap<String, Object>();
			cpoSeqMap.put("CPO_SEQ", String.valueOf(gridData.get("CPO_SEQ")));
			cpoSeqList.add(cpoSeqMap);
		}

		// EMAIL 및 SMS 발송
		try {
			Map<String, Object> mailParam = new HashMap<String, Object>();
			mailParam.put("CPO_NO", cpoNo);
			mailParam.put("VENDOR_CD", vendorCd);
			mailParam.put("cpoSeqList", cpoSeqList);
			sendEmailNSms_InvReject(mailParam);
		} catch (Exception ex) {
			System.out.println("=====> 납품거부(SIV1_020) EMAIL, SMS 발송 오류 : " + ex);
		}

		return msg.getMessage("0001");
	}

	// 인수자정보 가져오기
	public Map<String, String> getRecipientUserInfo(Map<String, String> param) throws Exception {
		return siv101_Mapper.getRecipientUserInfo(param);
	}

	// 인수자정보(고객사) 가져오기
	public Map<String, String> getRecipientUserInfoCust(Map<String, String> param) throws Exception {
		return siv101_Mapper.getRecipientUserInfoCust(param);
	}

	// 납품서 생성 : EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public void sendEmailNSms(Map<String, Object> param) throws Exception {
		// 주문헤더(UPOHD) 가져오기
		Map<String, Object> cpoUserInfo = siv101_Mapper.siv1020_doSearchCpoHeaderInfo(param);

		// 고객사 주문자에게 SMS 전송
		if (!cpoUserInfo.get("CUST_CELL_NUM").equals("")) {
			Map<String, String> hdata = new HashMap<String, String>();
			hdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_ID"))); // 보내는 사용자ID(공급사 납품담당자)
			hdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_NM"))); // 보내는사람(공급사 납품담당자)
			hdata.put("SEND_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_CELL_NUM"))); // 보내는 사람 전화번호(공급사 납품담당자)
			hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID"))); // 받는 사용자ID
			hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 받는사람
			hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_CELL_NUM"))); // 받는 사람 전화번호
			hdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM")) + "님. 주문번호(" + EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")) + ")의 납품서가 생성되었습니다. 감사합니다."); // 전송내용
			hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
			hdata.put("REF_MODULE_CD", "IV"); // 참조모듈
			everSmsService.sendSms(hdata);
		}
	}

	// 납품 거부 : EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public void sendEmailNSms_InvReject(Map<String, Object> param) throws Exception {

		// Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_REJECT_TemplateFileName");

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

		// 주문헤더(UPOHD) 가져오기
		String fileContents = "";
		List<Map<String, Object>> cpoUserList = siv101_Mapper.siv1020_getInvRejectCpoHeaderInfo(param);
		// 운영사 품목담당자에게 EMAIL 전송
		for( Map<String, Object> cpoUserInfo : cpoUserList ){
			fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
			fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 주문번호
			fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_DATE"))); // 주문일자
			fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM"))); // 운영사의 품목담당자
			fileContents = EverString.replace(fileContents, "$CUST_NM$", EverString.nullToEmptyString(cpoUserInfo.get("CUST_NM"))); // 고객사
			fileContents = EverString.replace(fileContents, "$CUST_TEL_NUM$", EverString.nullToEmptyString(cpoUserInfo.get("CUST_TEL_NUM"))); // 고객사 주문자 전화번호
			fileContents = EverString.replace(fileContents, "$VENDOR_NM$", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_NM"))); // 공급사
			fileContents = EverString.replace(fileContents, "$VENDOR_TEL_NUM$", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_TEL_NUM"))); // 공급사 납품담당자 전화번호

			String tblBody = "<tbody>";
	        String enter = "\n";
	        // 주문품목(UPODT) 가져오기
	        String rejectNm  = "";
	        String rejectRmk = "";
	        List<Map<String, Object>> itemList = siv101_Mapper.siv1020_getInvRejectCpoDetailInfo(param);
	        if( itemList.size() > 0 ){
	            for( Map<String, Object> itemData : itemList ){
	                // 품목명
	            	String itemDesc = (String)itemData.get("ITEM_DESC");
	                if(itemDesc.length() > 29) { itemDesc = itemDesc.substring(0, 30) + "..."; }
	                // 품목규격
	                String itemSpec = (String)itemData.get("ITEM_SPEC");
	                if(itemSpec.length() > 29) { itemSpec = itemSpec.substring(0, 30) + "..."; }
	                // 납품거부사유
	                if( "".equals(rejectNm) ){
		                rejectNm  = (String)itemData.get("DELY_REJECT_NM");
		                rejectRmk = (String)itemData.get("DELY_REJECT_REASON");
	                }

	                // 품목리스트
	                String tblRow = "<tr>"
	                		+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd' rowspan='2'>" + EverString.nullToEmptyString(itemData.get("ITEM_CD")) + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_NM")) + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:right;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_QTY")) + "</td>"
	                        + enter + "</tr>"
	                        + enter + "<tr>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</td>"
	                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
	                        + enter + "</tr>";
	                tblBody += tblRow;
	            }
	        }
			fileContents = EverString.replace(fileContents, "$REJECT_NM$", rejectNm); // 납품거부유형
			fileContents = EverString.replace(fileContents, "$REJECT_RMK$", rejectRmk); // 납품거부사유
	        fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
			fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
			fileContents = EverString.rePreventSqlInjection(fileContents);

			if (!cpoUserInfo.get("OPER_EMAIL").equals("")) {
				Map<String, String> mdata = new HashMap<String, String>();
				mdata.put("SUBJECT", "[대명소노시즌] 주문번호(" + EverString.nullToEmptyString(cpoUserInfo.get("CUST_NM")) + ", " + EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")) + ")의 납품이 거절되었습니다.");
				mdata.put("CONTENTS_TEMPLATE", fileContents);
				mdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_ID"))); // 주문자
				mdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_NM")));
				mdata.put("SEND_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_EMAIL")));
				mdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID")));
				mdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM")));
				mdata.put("RECV_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("OPER_EMAIL")));
				mdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")));
				mdata.put("REF_MODULE_CD", "IV"); // 참조모듈
				// Mail 발송처리.
				everMailService.sendMail(mdata);
				mdata.clear();
			}

			// 운영사 품목담당자에게 SMS 전송
			if (!cpoUserInfo.get("OPER_CELL_NUM").equals("")) {
				Map<String, String> hdata = new HashMap<String, String>();
				hdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM")) + "님. 주문번호(" + EverString.nullToEmptyString(cpoUserInfo.get("CUST_NM")) + "," + EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")) + ")의 납품이 거부되었습니다. 확인바랍니다."); // 전송내용
				hdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_ID"))); // 보내는 사용자ID(공급사 납품담당자)
				hdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_NM"))); // 보내는사람(공급사 납품담당자)
				hdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 보내는 사람 전화번호(대표전화번호)
				hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 받는 사용자ID(운영사 품목담당자)
				hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM"))); // 받는사람(운영사 품목담당자)
				hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_CELL_NUM"))); // 받는 사람 전화번호(운영사 품목담당자)
				hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
				hdata.put("REF_MODULE_CD", "IV"); // 참조모듈
				// SMS 발송처리.
				everSmsService.sendSms(hdata);
				hdata.clear();
			}
		}
	}

}