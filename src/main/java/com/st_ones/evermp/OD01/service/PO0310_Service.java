package com.st_ones.evermp.OD01.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.OD01.OD0101_Mapper;
import com.st_ones.evermp.OD01.PO0310_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "po0310_Service")
public class PO0310_Service extends BaseService {

	@Autowired private QueryGenService queryGenService;
	@Autowired PO0310_Mapper po0310_Mapper;
	@Autowired OD0101_Mapper od0101_Mapper;
	@Autowired MessageService msg;
	@Autowired private DocNumService docNumService;
	@Autowired private EApprovalService approvalService;



	public List<Map<String, Object>> PO0310_doSearch(Map<String, String> param) {
		 Map<String, String> sParam = new HashMap<String, String>();

	        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
	            sParam.put("COL_VAL", param.get("ITEM_DESC"));
	            sParam.put("COL_NM", "UPODT.ITEM_DESC");
	            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
	            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
	            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
				sParam.put("COL_NM", "UPODT.ITEM_CD");
				param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
				sParam.put("COL_NM", "UPODT.CUST_ITEM_CD");
				param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
	        }
	        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
	            param.put("COL_NM", "UPODT.MAKER_CD");
	            param.put("COL_VAL", param.get("MAKER_CD"));
	            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
	        }
	        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
	            param.put("COL_NM", "UPODT.MAKER_NM");
	            param.put("COL_VAL", param.get("MAKER_NM"));
	            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
	        }

	        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
	            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
	            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
	            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
	        }

	        /*
	        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
	            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
	            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
	            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
	        }
	         */

	        Map<String, Object> fParam = new HashMap<String, Object>(param);
	        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

	        return po0310_Mapper.PO0310_doSearch(fParam);
	}

	 @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	    public String po0310_doPoConfirmXX(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
	    	String progressCdF = formData.get("PROGRESS_CD");
	        for (Map<String, Object> gridData : gridDatas) {
	            String progressCd = po0310_Mapper.checkProgressCd(gridData);
	            if (!"5100".equals(progressCd)) {
	                throw new Exception(msg.getMessageByScreenId("PO0310", "0022"));
	            }
	            gridData.put("PROGRESS_CD", progressCdF);
	            po0310_Mapper.doPoConfirmUpo(gridData);

	            if("2100".equals(progressCdF)) { // 접수취소일시 YPO 삭제
	            	po0310_Mapper.doDelYPO(gridData);
	            } else {
	            	po0310_Mapper.doPoConfirmYPODT(gridData);
	            	//po0310_Mapper.doPoConfirmYPOHD(gridData); 미사용
				}
	       }
	        if("6100".equals(progressCdF)) {
	            return msg.getMessageByScreenId("PO0310", "0038");
	        } else {
	            return msg.getMessageByScreenId("PO0310", "0040");
	        }

	    }

	  @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String YPODTChange(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
        String appDocNum = "";
        String appDocCnt = "";

        formData.put("SIGN_STATUS","P");
        if (EverString.isEmpty(appDocNum)) {
            appDocNum = docNumService.getDocNumber("AP");
        }
        formData.put("APP_DOC_NUM", appDocNum);
        if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
            appDocCnt = "1";
            formData.put("APP_DOC_CNT", appDocCnt);
        } else {
            appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
            formData.put("APP_DOC_CNT", appDocCnt);
        }


        for(Map<String, Object> data : gridDatas) {
        	data.put("APP_DOC_NO", appDocNum);
        	data.put("APP_DOC_CNT", appDocCnt);
            data.put("SIGN_STATUS","P");
        	po0310_Mapper.YPODTChange(data); //출하지시수정
        }


        formData.put("DOC_TYPE", "DOCH"); //결재보내기
        approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
    	return msg.getMessage("0023");
    }


	   @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	    public String endApprovalDoCh(String docNo, String docCnt, String signStatus) throws Exception {
	        Map<String, String> param = new HashMap<String, String>();
	        param.put("APP_DOC_NUM", docNo);
	        param.put("APP_DOC_CNT", docCnt);
	        param.put("SIGN_STATUS", signStatus);
	        po0310_Mapper.YPODTSignUpdate(param);

			if("E".equals(signStatus)) {
				List<Map<String, Object>> list = po0310_Mapper.PO0311_doSearch(param); //결제정보상세

		        for(Map<String, Object> data : list) {
		        	po0310_Mapper.uPoSignApply(data); // 주문변경
	        		po0310_Mapper.yPoSignApply(data); // 발주변경
		        }
			}
	        return msg.getMessage("0057"); // 승인이 완료되었습니다
	    }

	//[담당자변경]
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String po0310_doTransferCtrl(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

        	   String progressCd = po0310_Mapper.checkProgressCd(gridData);
            if (!"2200".equals(progressCd) && !"5100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("PO0310", "0006"));
            }
            gridData.put("AM_USER_ID", formData.get("AM_USER_ID"));
            gridData.put("AM_USER_CHANGE_RMK", formData.get("AM_USER_CHANGE_RMK"));
            po0310_Mapper.doTransferAmUserUpo(gridData);
            po0310_Mapper.doTransferAmUserYPODT(gridData);
        }
        return msg.getMessageByScreenId("PO0310", "0012");
    }

	   public List<Map<String, Object>> PO0311_doSearch(Map<String, String> param) throws Exception {
	        return po0310_Mapper.PO0311_doSearch(param);
	    }


}