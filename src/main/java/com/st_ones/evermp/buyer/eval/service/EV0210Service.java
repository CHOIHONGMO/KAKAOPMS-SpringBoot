package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.mail.web.MailTemplate;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.evermp.buyer.eval.EV0210Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "EV0210Service")
public class EV0210Service extends BaseService {

	@Autowired
	EV0210Mapper ev0210Mapper;
	@Autowired
	private DocNumService docNumService;
	@Autowired
	private MessageService msg;
	@Autowired
	private EverMailService everMailService;
	@Autowired
	private MailTemplate mailTemplate;

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doSave(Map<String, String> params, List<Map<String, Object>> gridUs, List<Map<String, Object>> gridVendor) throws Exception {
		
		String args[] = new String[2];
		if (EverString.isEmpty(params.get("EV_NUM").toString())) { // Create new EV_NUM and insert EVEM
			String docNo = docNumService.getDocNumber("EV");
			params.put("EV_NUM", docNo);
			params.put("PROGRESS_CD", "100");

			/** 평가담당자만 처리 가능 */
			if (!params.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
				throw new NoResultException(msg.getMessageByScreenId("SRM_210","0013"));
			}

			ev0210Mapper.doInsertEVEM(params);
		}
		else {
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

			if(gridVendorData.get("INSERT_FLAG") == null || "".equals(gridVendorData.get("INSERT_FLAG")) ) { // 엑셀 업로드때문에
				gridVendorData.put("INSERT_FLAG","Y");
			}

			if("Y".equals(gridVendorData.get("INSERT_FLAG"))) {
				ev0210Mapper.doInsertEVES(gridVendorData);
			} else {
				ev0210Mapper.doUpdateEVES(gridVendorData);
			}

			List<Map<String,Object>> gridDataEVEU = EverConverter.readJsonObject(String.valueOf(gridVendorData.get("USER_INFO")), List.class);

			if (gridDataEVEU != null && gridDataEVEU.size() > 0) {
				for(Map<String, Object> gridEVEU : gridDataEVEU) {
					gridEVEU.putAll(gridVendorData);

					if(ev0210Mapper.existsEVEU(gridEVEU) == 0) {
						ev0210Mapper.doInsertEVEU(gridEVEU);
					} else {
						ev0210Mapper.doUpdateEVEU(gridEVEU);
					}
				}
			}
		}

		args[0] = params.get("EV_NUM").toString();
		args[1] = msg.getMessage("0001");
		return args;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doInsertEVET(Map<String, String> param, List<Map<String, Object>> gridVendor) throws Exception {

		for (Map<String, Object> one : gridVendor) {
			param.put("VENDOR_CD", String.valueOf(one.get("VENDOR_CD")));
			param.put("START_DATE", String.valueOf(Integer.parseInt(EverDate.getYear())-1)+"0101");
			param.put("CLOSE_DATE", String.valueOf(Integer.parseInt(EverDate.getYear())-1)+"1231");

			List<Map<String, Object>> data = ev0210Mapper.doSearchDataForEVET(param);
			for (Map<String, Object> oneData : data) {
				oneData.put("EV_NUM", String.valueOf(param.get("EV_NUM")));
				oneData.put("VENDOR_CD", String.valueOf(param.get("VENDOR_CD")));

				ev0210Mapper.doInsertEVET(oneData);
			}
		}

		return msg.getMessage("0001");
	}

	/**
	 * 평가 Master 조회
	 * @param param
	 * @return
	 */
	public Map<String, String> getEvMaster(Map<String, String> param) {
		return ev0210Mapper.doSearchEVEM(param);
	}

	/**
	 * 협력사 조회
	 * @param formData
	 * @return
	 */
	public List<Map<String, Object>> doSearchEVES(Map<String, String> formData) throws Exception {

		List<Map<String, Object>> gridDataVendor = ev0210Mapper.doSearchEVES(formData);
		for (Map<String, Object> gridVendor : gridDataVendor) {
			if (!formData.get("EV_NUM").toString().equals("")) {
				gridVendor.put("EV_NUM", String.valueOf(formData.get("EV_NUM")));
			}
			gridVendor.put("USER_INFO", EverConverter.getJsonString(ev0210Mapper.doSearchEVEU(gridVendor)));
		}

		return gridDataVendor;
	}

	/**
	 * 협력사 조회 (엑셀 업로드용)
	 * @param param
	 * @return
	 */
	public List<Map<String, Object>> doSearchExecelEVES(Map<String, String> param, List<Map<String, Object>> gridData) throws Exception {
		
		Map<String, Object> paramObj = new HashMap<String,Object>();
		paramObj.put("VENDOR_CD_LIST", gridData);
		
		List<Map<String, Object>> gridDataVendor = ev0210Mapper.doSearchExcelEVES(paramObj);
		
		/**
		 * 제외
		if ("ESG".equals(param.get("EV_TYPE"))) {
			for (Map<String, Object> gridVendor : gridDataVendor) {
				gridVendor.put("USER_INFO", EverConverter.getJsonString(ev0210Mapper.doSearchExcelEVEU(gridVendor)));
			}
		}*/
		return gridDataVendor;
	}

	/**
	 * 평가자 조회 (엑셀 업로드용)
	 * @param param
	 * @return
	 */
	public List<Map<String, Object>> doSearchExecelEVEU(Map<String, String> param, List<Map<String, Object>> vendorList, List<Map<String, Object>> userList) throws Exception {
		
		Map<String, Object> vendorObj = new HashMap<String, Object>();
		vendorObj.put("VENDOR_CD_LIST", vendorList);
		
		Map<String, Object> userObj = new HashMap<String, Object>();
		userObj.put("USER_INFO_LIST", userList);
		
		List<Map<String, Object>> gridDataVendor = ev0210Mapper.doSearchExcelEVES(vendorObj);
		List<Map<String, Object>> gridDataUser   = ev0210Mapper.doSearchExcelEVEU(userObj);
		
		for (Map<String, Object> gridVendor : gridDataVendor) {
			gridVendor.put("USER_INFO", EverConverter.getJsonString(gridDataUser));
		}
		
		/**
		 * 제외
		if ("ESG".equals(param.get("EV_TYPE"))) {
			for (Map<String, Object> gridVendor : gridDataVendor) {
				gridVendor.put("USER_INFO", EverConverter.getJsonString(ev0210Mapper.doSearchExcelEVEU(gridVendor)));
			}
		}*/
		return gridDataVendor;
	}


	/**
	 * 평가자 조회
	 * @param param
	 * @return
	 */
	//public List<Map<String, Object>> doSearchEVEU(Map<String, String> param) {
	//	return srm_210_mapper.doSearchEVEU(param);
	//}

	/**
	 * 평가 조회
	 * @param param
	 * @param wuxReq
	 */
	public void doSearch(Map<String, String> param, EverHttpRequest wuxReq) {

		Map<String, String> a = ev0210Mapper.doSearchEVEM(param);

		wuxReq.setAttribute("formData", a);
		param.put("EG_NUM", a.get("EG_NUM"));

		wuxReq.setAttribute("gridVendorData"	, ev0210Mapper.doSearchEVES(param));
		//wuxReq.setAttribute("gridUsData"		, srm_210_mapper.doSearchEVEU(param));
	}

	/**
	 * 평가 삭제
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDelete(Map<String, String> params) throws Exception {

		Map<String, Object> retData = ev0210Mapper.doCheckEVEM(params);

		UserInfo userInfo = UserInfoManager.getUserInfo();
		String user_id = userInfo.getUserId();

		/** 평가 담당자만 처리 가능 */
		if (!retData.get("EV_CTRL_USER_ID").equals(user_id)) {
			throw new NoResultException(msg.getMessageByScreenId("SRM_210","0013"));
		}

		/** 평가요청일이 존재하면 처리불가 */
		if ( retData.get("REQUEST_DATE") !=null && !"".equals(retData.get("REQUEST_DATE")) ) {
			throw new NoResultException(msg.getMessageByScreenId("SRM_210","0011"));
		}

		ev0210Mapper.doDeleteEVEUAll(params);
		ev0210Mapper.doDeleteEVESAll(params);
		ev0210Mapper.doDeleteEVEM(params);

		return msg.getMessage("0017");
	}


	/**
	 * 평가요청
	 * @param params
	 * @param typeUpdate
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateProgressEVEM(Map<String, String> params, String typeUpdate) throws Exception {

		Map<String, Object> retData = ev0210Mapper.doCheckEVEM(params);

		UserInfo userInfo = UserInfoManager.getUserInfo();
		String user_id = userInfo.getUserId();

		/** 평가 담당자만 처리 가능 */

		if (!retData.get("EV_CTRL_USER_ID").equals(user_id)) {
			throw new NoResultException(msg.getMessageByScreenId("EV0210","0013"));
		}

		/** 평가요청 */
		if (typeUpdate.equals("doRequest")) {

			//if (!progress.equals("100")) {
			/** 평가일이 존재하면 처리 불가 */
			if ( retData.get("REQUEST_DATE") !=null && !"".equals(retData.get("REQUEST_DATE")) ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0210","0011"));
			}

			params.put("PROGRESS_CD", "100");

			ev0210Mapper.doUpdateProgressEVEU(params);
			ev0210Mapper.doUpdateProgressEVES(params);

			params.put("PROGRESS_CD", "200");
			params.put("REQUEST_DATE", "YES");
		}

		/** 요청취소 */
		if (typeUpdate.equals("doCancel")) {

			/** 요청일이 존재하지 않으면 처리불가 */
			if ( retData.get("REQUEST_DATE") ==null || "".equals(retData.get("REQUEST_DATE")) ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0210","0012"));
			}

			params.put("PROGRESS_CD", "");
			ev0210Mapper.doUpdateProgressEVEU(params);
			ev0210Mapper.doUpdateProgressEVES(params);



			params.put("PROGRESS_CD", "050");
			params.put("REQUEST_DATE", "NO");
		}



//		if (typeUpdate.equals("doComplete")) {
//			if (!progress.equals("200")) {
//				throw new NoResultException(msg.getMessage("0044"));
//			}
//
//			params.put("PROGRESS_CD", "300");
//			params.put("COMPLETE_DATE", "YES");
//		}
//		if (typeUpdate.equals("doCancelCom")) {
//			if (!progress.equals("300")) {
//				throw new NoResultException(msg.getMessage("0044"));
//			}
//
//			params.put("PROGRESS_CD", "200");
//			params.put("COMPLETE_DATE", "NO");
//		}

		//else {
		ev0210Mapper.doUpdateProgressEVEM(params);
		//}

		//MAIL 전송
		if (typeUpdate.equals("doRequest")) {
			//doSendSmsMail(params);
		}

		return msg.getMessage("0001");
	}

}

