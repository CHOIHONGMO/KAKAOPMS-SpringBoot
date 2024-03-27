package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.mail.web.MailTemplate;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.multiLanguage.service.MultiLanguageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0045Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "EV0045_Service")
public class EV0045Service extends BaseService {

	@Autowired EV0045Mapper srm_045_mapper;
	@Autowired private MessageService msg;
	@Autowired LargeTextService largeTextService;
	@Autowired private DocNumService docNumService;
	@Autowired MultiLanguageService multiLanguageService;
	@Autowired private EverMailService everMailService;
	@Autowired private MailTemplate mailTemplate;

	public Map<String, Object> srm045_doSearch(Map<String, String> param) throws Exception {
		return srm_045_mapper.srm045_doSearch(param);
	}

	public List<Map<String, Object>> srm045_doSearchEVTM(Map<String, String> param) throws Exception {
		return srm_045_mapper.srm045_doSearchEVTM(param);
	}

	public List<Map<String, Object>> doSearchSg(Map<String, String> param) throws Exception {
		return srm_045_mapper.doSearchSg(param);
	}

	public List<Map<String, Object>> doSearchUs(Map<String, String> param) throws Exception {
		return srm_045_mapper.doSearchUs(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] srm045_doSave(Map<String, String> params, List<Map<String, Object>> gridUs) throws Exception {
		String args[] = new String[2];

		String ev_tpl_num = params.get("SITE_EV_TPL_NUM");
		String ev_item_num = " ";

		if (EverString.isEmpty(params.get("EV_NUM").toString())) {
			String docNo = docNumService.getDocNumber("EV");

			params.put("EV_NUM", docNo);
			params.put("PROGRESS_CD", "100");

			srm_045_mapper.srm045_doSaveINSERT_EVVM(params);
		} else {
			Map<String, Object> retData = srm_045_mapper.doCheckMaster(params);

			if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
				throw new NoResultException(msg.getMessageByScreenId("EV0045","0001"));
			}

			if ( retData.get("REQUEST_DATE") != null && !EverString.isEmpty(retData.get("REQUEST_DATE").toString()) ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0045","0002"));
			}

			srm_045_mapper.srm045_doSaveUPDATE_EVVM(params);
		}

		Map<String,Object> param1 = new java.util.HashMap<String,Object>();
		param1.put("EV_NUM", params.get("EV_NUM"));

		srm_045_mapper.doDeleteAllEvvu(param1);//평가자 전체 삭제처리
		for (Map<String, Object> gridUsData : gridUs) {
			gridUsData.put("EV_NUM", params.get("EV_NUM"));
			gridUsData.put("EV_TPL_NUM", ev_tpl_num);

			int ret = srm_045_mapper.existsEvvu(gridUsData);

			if (ret == 0) {
				srm_045_mapper.doInsertEvvu(gridUsData);
			} else {
				if (gridUsData.get("DEL_FLAG")== null) {
					gridUsData.put("DEL_FLAG", "");
				}

				if (gridUsData.get("DEL_FLAG").equals("1")) {
					srm_045_mapper.doDeleteEvvu(gridUsData);
				} else {
					srm_045_mapper.doUpdateEvvu(gridUsData);
				}
			}
		}

		args[0] = params.get("EV_NUM").toString();
		args[1] = msg.getMessage("0001");

		return args;

	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doDelete(Map<String, String> params, List<Map<String, Object>> gridUs) throws Exception {
		String args[] = new String[2];

		String ev_tpl_num 		= params.get("SITE_EV_TPL_NUM");
		String ev_item_num 	= " ";

		Map<String, Object> retData = srm_045_mapper.doCheckMaster(params);

		if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0001"));
		}

		if ( retData.get("REQUEST_DATE") != null && !EverString.isEmpty(retData.get("REQUEST_DATE").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0002"));
		}

		srm_045_mapper.doDeleteMaster(params);

		Map<String,Object> param1 = new java.util.HashMap<String,Object>();
		param1.put("EV_NUM", params.get("EV_NUM"));

		srm_045_mapper.doDeleteAllEvvu(param1);

		args[0] = "";
		args[1] = msg.getMessage("0001");

		return args;

	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] srm045_doRequest(Map<String, String> params, List<Map<String, Object>> gridUs) throws Exception {
		String args[] = new String[2];
		String ev_tpl_num = params.get("SITE_EV_TPL_NUM");

		srm045_doSave(params, gridUs);

		Map<String, Object> retData = srm_045_mapper.doCheckMaster(params);

		if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0001"));
		}

		if ( retData.get("REQUEST_DATE") != null && !EverString.isEmpty(retData.get("REQUEST_DATE").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0002"));
		}

		params.put("PROGRESS_CD", "200");
		srm_045_mapper.srm045_doRequestUPDATE_EVVM(params);


		for (Map<String, Object> gridUsData : gridUs) {
			gridUsData.put("EV_NUM", params.get("EV_NUM"));
			gridUsData.put("EV_TPL_NUM", ev_tpl_num);

			gridUsData.put("PROGRESS_CD", "100");

			srm_045_mapper.srm045_doRequestUPDATE_EVVU(gridUsData);
		}


		args[0] = params.get("EV_NUM").toString();
		args[1] = msg.getMessage("0001");

		return args;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] srm045_doCancel(Map<String, String> params, List<Map<String, Object>> gridUs) throws Exception {
		String args[] = new String[2];
		String ev_tpl_num 		= params.get("SITE_EV_TPL_NUM");
		String progress_cd 	= "100";

		Map<String, Object> retData = srm_045_mapper.doCheckMaster(params);

		if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0001"));
		}

		if ( retData.get("REQUEST_DATE") == null || EverString.isEmpty(retData.get("REQUEST_DATE").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0005"));
		}

		if(Float.valueOf(String.valueOf(retData.get("EV_ID_SCORE"))) > 0) {
			throw new NoResultException(msg.getMessageByScreenId("EV0045","0007"));
		}

		params.put("PROGRESS_CD", progress_cd);
		srm_045_mapper.srm045_doCancelEVVM(params);

		for (Map<String, Object> gridUsData : gridUs) {
			gridUsData.put("EV_NUM", params.get("EV_NUM"));
			gridUsData.put("EV_TPL_NUM", ev_tpl_num);

			srm_045_mapper.srm045_doCancelEVVU(gridUsData);
		}

		srm_045_mapper.srm045_doCancelEVET(params);
		srm_045_mapper.srm045_doCancelEVES(params);

		args[0] = params.get("EV_NUM").toString();
		args[1] = msg.getMessage("0001");

		return args;
	}

}