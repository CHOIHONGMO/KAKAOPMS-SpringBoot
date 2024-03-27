package com.st_ones.evermp.OD02.service;

import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.OD02.OD0204_Mapper;
import com.st_ones.evermp.SIV1.SIV103_Mapper;
import com.st_ones.evermp.SIV1.SIV104_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 *
 * @File Name : OD0204_Service.java
 * @author 최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "OD0204_Service")
public class OD0204_Service extends BaseService {

	@Autowired
	private RealtimeIF_Service realtimeifService;

	@Autowired
	OD0204_Mapper od02_Mapper;

	@Autowired
	SIV103_Mapper siv103_Mapper;

	@Autowired
	SIV104_Mapper siv104_Mapper;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	MessageService msg;

	@Autowired
	private DocNumService docNumService;

	/**
	 * ******************************************************************************************
	 * 운영사 : 출하대상목록
	 *
	 * @param param
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> OD02040_doSearch(Map<String, String> param) throws Exception {
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

		if (EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if (EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return od02_Mapper.od0204_doSearch(param);
	}

	/**
	 *  출하대상목록
	 *
	 * @param gridList
	 * @throws Exception 들어오는 건별로 시작해서 CPO_NO가 같다면 채번은 같고 틀리다면 다르게 입력 동일한 주문 CPO
	 *                   이더라도 공급사가 다르면 다르게 채번 즉, 아예 라인수로 for문으로 데이터 입력 할 수 있게 작성 단
	 *                   한건만 들어오면 한건은 for문을 무시한다.더욱이 PODT에 INV에 입력할때는 주의해서 입력이 필요
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, Object> OD02040_doCreateInvoice(List<Map<String, Object>> gridList, List<Map<String, Object>> reqInList) throws Exception {
		String cpoNo = gridList.get(0).get("CPO_NO").toString();
		String vendorCd = gridList.get(0).get("VENDOR_CD").toString();
		String INV_NO = "";
		String invcCd = "";

		int docSeq=1;
		int invNoCount = 1;
		int invSeq = 1; // 납품서 항번
		Map<String, Object> respMap = new HashMap<String, Object>();
		respMap.put("INV_NO_0", INV_NO);
		invcCd = docNumService.getDocNumber("DO");

		for (int i = 0; i < gridList.size(); i++) {

			if(od02_Mapper.chkInvPo(gridList.get(i)) !=0) {
				throw new Exception("이미 종결된 발주입니다.");
			}
			INV_NO = docNumService.getDocNumber("INV");

			Map<String, Object> reqMap = gridList.get(i);
			reqMap.put("DOC_SEQ", docSeq);
			reqMap.put("IF_INVC_CD", invcCd); //거레명세서용
			reqMap.put("INV_NO", INV_NO);
			reqMap.put("INV_SEQ", invSeq);
			reqMap.put("DOC_NO", INV_NO); //수불테이블에 넣을 납품번호
			reqInList.add(reqMap);

			od0204_doCreateDB(reqMap, "wayCode_11");
		}

		respMap.put("invNoCount", Integer.toString(invNoCount));

		return respMap;
	}




	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, Object> OD02040_doCreateInvoice20230103(List<Map<String, Object>> gridList, List<Map<String, Object>> reqInList) throws Exception {
		String cpoNo = gridList.get(0).get("CPO_NO").toString();
		String vendorCd = gridList.get(0).get("VENDOR_CD").toString();
		String INV_NO = docNumService.getDocNumber("INV");
		String invcCd = "";

		int docSeq=1;
		int invNoCount = 1;
		int invSeq = 1; // 납품서 항번
		Map<String, Object> respMap = new HashMap<String, Object>();
		respMap.put("INV_NO_0", INV_NO);

		for (int i = 0; i < gridList.size(); i++) {

			if(od02_Mapper.chkInvPo(gridList.get(i)) !=0) {
				throw new Exception("이미 종결된 발주입니다.");
			}

			if (i == 0) {
				invcCd = docNumService.getDocNumber("DO");

				Map<String, Object> reqMap = gridList.get(0);
				reqMap.put("DOC_SEQ", docSeq);
				reqMap.put("IF_INVC_CD", invcCd); //거레명세서용
				reqMap.put("INV_NO", INV_NO);
				reqMap.put("INV_SEQ", invSeq);
				reqMap.put("DOC_NO", INV_NO); //수불테이블에 넣을 납품번호
				reqInList.add(reqMap);

				od0204_doCreateDB(reqMap, "wayCode_11");
			} else {
				 if (cpoNo.equals(gridList.get(i).get("CPO_NO").toString()) || 1==1) {
					// 동일한 공급사면 납품서 동일
					if (vendorCd.equals(gridList.get(i).get("VENDOR_CD").toString())) {
						invSeq = invSeq + 1;
						docSeq = docSeq + 1;

						Map<String, Object> reqMap = gridList.get(i);
						reqMap.put("DOC_SEQ", docSeq);
						reqMap.put("IF_INVC_CD", invcCd); //거레명세서용
						reqMap.put("INV_NO" , INV_NO);
						reqMap.put("DOC_NO" , INV_NO); //수불테이블에 넣을 납품번호
						reqMap.put("INV_SEQ", invSeq);
						reqInList.add(reqMap);

						od0204_doCreateDB(reqMap, "wayCode_00");
					}// 공급사가 다르면 납품서도 다르게
					else {
						vendorCd = gridList.get(i).get("VENDOR_CD").toString();

						INV_NO = docNumService.getDocNumber("INV"); // 고객사 납품번호
						invSeq = 1;
						invNoCount = invNoCount + 1;

						Map<String, Object> reqMap = gridList.get(i);

						reqMap.put("DOC_SEQ", docSeq);
						reqMap.put("IF_INVC_CD", invcCd); //거레명세서용
						reqMap.put("INV_NO" , INV_NO);
						reqMap.put("DOC_NO" , INV_NO); //수불테이블에 넣을 납품번호
						reqMap.put("INV_SEQ", invSeq);
						reqInList.add(reqMap);

						od0204_doCreateDB(reqMap, "wayCode_11");

					}
				}
			}
		}

		respMap.put("invNoCount", Integer.toString(invNoCount));

		return respMap;
	}


	// DB 등록
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void od0204_doCreateDB(Map<String, Object> reqMap, String wayCode) throws Exception {
		reqMap.put("AGENT_YN", "0"); // 납품서 대행여부

		// 1. IVHD 입력
		if ("wayCode_11".equals(wayCode)) {
			od02_Mapper.od0204_doCreateUIVHD(reqMap);
		}
		od02_Mapper.od0204_doCreateUIVDT(reqMap);

		String dealCd=(String)reqMap.get("DEAL_CD");   //[VMI]일 때 AGENT_CODE 에 VENDOR_CD
		if(dealCd.equals("400")){
			String vendorCd = (String)reqMap.get("VENDOR_CD");
			reqMap.put("AGENT_CODE" ,vendorCd );
		  }
		if(dealCd.equals("100")){
			UserInfo userInfo = UserInfoManager.getUserInfo();
			reqMap.put("AGENT_CODE",userInfo.getManageCd() ); //[먀입]일때 AGENT_CODE '2518'
		  }

		od02_Mapper.od0204_doUpdateYPODT(reqMap);
		od02_Mapper.od0204_doUpdateUPODT(reqMap);
		od02_Mapper.od0204_doinsertMMRS(reqMap);  // 수불테이블 INSERT

		Map<String, Object> checkMap = od02_Mapper.getPoQtySumInvQty(reqMap);
		double poQty = Double.parseDouble(String.valueOf(checkMap.get("PO_QTY")));
		double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));

		if(poQty < podtInvQty) {
			throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + reqMap.get("CPO_NO") + ", 품목코드 : " + reqMap.get("ITEM_CD"));
		}
	}

	 //출하취소
	 @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	 public String OD0204_doCancel(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
	 	String progressCdF = formData.get("PROGRESS_CD");
	 	for (Map<String, Object> gridData : gridDatas) {
        	String progressCd = od02_Mapper.checkProgressCd(gridData);
        	if (!"6100".equals(progressCd)) {
        		throw new Exception(msg.getMessageByScreenId("OD02_040", "0002"));
            }
            gridData.put("PROGRESS_CD", progressCdF);
            od02_Mapper.doConfirmRejectUpo(gridData);
            od02_Mapper.doConfirmRejectYpo(gridData);
        }
        return msg.getMessageByScreenId("OD02_040", "0005");
    }
	 // 출하종결
	 @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	    public String OD0204_doPoCancel(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
	    	String progressCdF = formData.get("PROGRESS_CD");
	        for (Map<String, Object> gridData : gridDatas) {
	        	od02_Mapper.setUPoClose(gridData);
	        	od02_Mapper.setYPoClose(gridData);
	        }

	        return msg.getMessageByScreenId("PO0240", "0033");
	    }

}
