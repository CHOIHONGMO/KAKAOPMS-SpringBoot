package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0197Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value="EV0197Service")
public class EV0197Service extends BaseService{
	@Autowired EV0197Mapper srm_197_mapper;
	@Autowired MessageService msg;
	@Autowired private DocNumService docNumService;
//	@Autowired private BBV_Service bbv_service;
	@Autowired private BAPM_Service approvalService;
//	@Autowired BBV_Mapper bbv_mapper;
	/**
	 * doSearch
	 *
	 * @param param the form data
	 * @return the List
	 * @throws Exception the exception
     */
	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception{

		return srm_197_mapper.doSearch(param);
	}

	/**
	 * doConfirm
	 *
	 * @param gridDatas the grid data
	 * @return the String
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doConfirm(List<Map<String, Object>> gridDatas) throws Exception{

		double score;
		for(Map<String, Object> gridData : gridDatas){

			score = srm_197_mapper.getScore(gridData);
			gridData.put("EV_SCORE", score);

			srm_197_mapper.doConfirm(gridData);
		}

		return msg.getMessage("0001");
	}

	/**
	 * doCancle
	 *
	 * @param gridDatas the grid data
	 * @return the string
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCancle(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object> gridData : gridDatas){
			srm_197_mapper.doCancle(gridData);
		}
		return msg.getMessage("0001");
	}

	/**
	 * doReEval
	 *
	 * @param gridDatas the grid data
	 * @return the string
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doReEval(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object> gridData : gridDatas){
			srm_197_mapper.doReEval(gridData);
		}
		return msg.getMessage("0001");
	}

	/**
	 * doInconsist
	 *
	 * @param gridDatas the grid data
	 * @return the string
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doInconsist(List<Map<String, Object>> gridDatas) throws Exception{
		Map<String, String> newMap = new HashMap<String, String>();

		for(Map<String, Object> gridData : gridDatas){
			srm_197_mapper.doInconsist(gridData);
			srm_197_mapper.doInconsistVngl(gridData);


		}
		return msg.getMessage("0001");
	}

	/**
	 * doRequest
	 *
	 * @param gridDatas the grid data
	 * @return the string
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> doRequest(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception{
        HashMap<String, String> hashMap = new HashMap<String, String>();

        String oldSignStatus = "";
        String legacy_key = "";

		for(Map<String, Object> gridData : gridDatas){
			oldSignStatus = EverString.nullToEmptyString(srm_197_mapper.getSignStatus(gridData));

	        if (oldSignStatus.equals("P") || oldSignStatus.equals("E")) {
	        	hashMap.put("message", msg.getMessage("0047"));
	        	hashMap.put("legacy_key", "ERROR");

	        	return hashMap;
	        }

//			if (EverString.isEmpty(EverString.nullToEmptyString(gridData.get("APP_DOC_NUM")))) {
				gridData.put("APP_DOC_NUM", docNumService.getDocNumber("AP"));
//			}

			String appDocCnt = EverString.nullToEmptyString(gridData.get("APP_DOC_CNT"));
//			if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0") || appDocCnt.equals("null")) {
				appDocCnt = "1";
//			} else {
//				if (oldSignStatus.equals("C")) {
//					appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
//				}
//			}

			gridData.put("PROGRESS_CD", "P");
			gridData.put("SIGN_STATUS", "P");
			gridData.put("APP_DOC_CNT", appDocCnt);
			gridData.put("DOC_TYPE", "VENDOR");

			// EVVM의 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS UPDATE
			srm_197_mapper.doRequest(gridData);
			// VNGL의 APP_DOC_NUM, APP_DOC_CNT update
			srm_197_mapper.doUpdateAppDoc(gridData);

			Map<String, String> newMap = new HashMap<String, String>();
			for (String colNm : gridData.keySet()) {
				newMap.put(colNm, String.valueOf(gridData.get(colNm)));
			}
			newMap.put("SUBJECT", String.valueOf(gridData.get("EV_NM")));

			//legacy_key = bbv_service.doApprovalResponse(newMap);
			legacy_key = "success";

			// formData APP_DOC_NUM 담기
			formData.put("APP_DOC_NUM", String.valueOf(gridData.get("APP_DOC_NUM")));
			formData.put("APP_DOC_CNT", appDocCnt);
			formData.put("SIGN_STATUS", "P");
		}

		// STOCSCTM,STOCSCTP Approval
		approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));

    	hashMap.put("message", msg.getMessage("0001"));
    	hashMap.put("legacy_key", legacy_key);

		return hashMap;
	}

	/**
	 * doImprove
	 *
	 * @param gridDatas the grid data
	 * @return the string
	 * @throws Exception the exception
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doImprove(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object> gridData : gridDatas){
			srm_197_mapper.doImprove(gridData);
		}
		return msg.getMessage("0001");
	}
}


