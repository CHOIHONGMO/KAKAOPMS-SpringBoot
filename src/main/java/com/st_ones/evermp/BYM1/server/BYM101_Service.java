package com.st_ones.evermp.BYM1.server;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */


import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BYM1.BYM101_Mapper;
import com.st_ones.eversrm.system.code.service.BSYC_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "bym1_Service")
public class BYM101_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

	@Autowired
	private QueryGenService queryGenService;

    @Autowired
    private MessageService msg;

    @Autowired
    private BYM101_Mapper bym101Mapper;

	@Autowired private EverSmsService everSmsService;

	@Autowired private EverMailService everMailService;

	@Autowired private BSYC_Service bsycService;

	/** *****************
	 * My Page > 고객의소리
	 * ******************/
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bym1060_doSatisSave(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			bym101Mapper.bym1060_doSatisSave(gridData);
		}

		return msg.getMessage("0164");
    }

    public List<Map<String, Object>> bym1060_doSearch(Map<String, String> param) {
    	
    	return bym101Mapper.bym1060_doSearch(param);
    }

	/** *****************
	 * My Page > 고객의소리 > 고객의소리 등록/수정 팝업
	 * ******************/
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bym1061_doSave(Map<String, String> param) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfoImpl();

		String REQ_USER_ID = userInfo.getUserId();
		String msgNo = "";
		String PROGRESS_CD = "";
		String newReg ="";

		if("S".equals(param.get("EXC_TYPE"))) {
			msgNo = "0015";
			PROGRESS_CD = "100";
		} else if("U".equals(param.get("EXC_TYPE"))) {
			msgNo = "0016";
			PROGRESS_CD = "100";
		} else if("R".equals(param.get("EXC_TYPE"))) {
			msgNo = "0156";
			PROGRESS_CD = "200";
		} else if("I".equals(param.get("EXC_TYPE"))) {
			msgNo = "0158";
			PROGRESS_CD = "300";
		} else if("C".equals(param.get("EXC_TYPE"))) {
			msgNo = "0160";
			PROGRESS_CD = "400";
		} else {
			msgNo = "";
		}

		param.put("REQ_USER_ID", REQ_USER_ID);
		param.put("PROGRESS_CD", PROGRESS_CD);

		if("".equals(param.get("VC_NO"))  || null == param.get("VC_NO")) {
			String VC_NO = docNumService.getDocNumber("VC");
			newReg ="Y";
			param.put("VC_NO", VC_NO);
		}

		//등록및 수정
		bym101Mapper.bym1061_doSave(param);



		return msg.getMessage(msgNo);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bym1061_doDelete(Map<String, String> param) throws Exception {

		bym101Mapper.bym1061_doDelete(param);

		return msg.getMessage("0017");
	}

	/** *****************
	 * 사용자정보 팝업
	 * ******************/
	public List<Map<String, Object>> bym1062_doSearch(Map<String, String> param) {
		return bym101Mapper.bym1062_doSearch(param);
	}

	/** *****************
	 * My Page > 관심품목관리
	 * ******************/
	public List<Map<String, Object>> bym1020_doSearch(Map<String, String> param) {
		return bym101Mapper.bym1020_doSearch(param);
	}

	public List<Map<String, Object>> bym1020_doSearchD(Map<String, String> param) {
		return bym101Mapper.bym1020_doSearchD(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bym1002_doSave(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			if("".equals(gridData.get("TPL_NO"))  || null == gridData.get("TPL_NO")) {
				String TPL_NO = docNumService.getDocNumber("DCF");

				gridData.put("TPL_NO", TPL_NO);
			}

			bym101Mapper.bym1002_doSave(gridData);
		}

		return msg.getMessage("0166");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bym1020_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			bym101Mapper.bym1020_doDelete(gridData);
		}

		return msg.getMessage("0017");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bym1020_doAddCart(List<Map<String, Object>> gridDatas) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("USER_ID", userInfo.getUserId());
			bym101Mapper.bym1020_doAddCart(gridData);
		}
		return msg.getMessageByScreenId("BYM1_020", "002");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bym1020_doDeleteCart(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			bym101Mapper.bym1020_doDeleteCart(gridData);
		}

		return msg.getMessage("0017");
	}
}