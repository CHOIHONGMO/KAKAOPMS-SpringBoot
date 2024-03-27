package com.st_ones.evermp.SY02.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.SY02.SY0201_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "sy02_Service")
public class SY0201_Service extends BaseService {

	@Autowired
	private DocNumService docNumService;

	@Autowired
	private MessageService msg;

	@Autowired
	private SY0201_Mapper sy0201Mapper;

	@Autowired
	LargeTextService largeTextService;

	/** ******************************************************************************************
	 * 휴일관리
	 * @param req
	 * @return
	 * @throws Exception
	 */

	public List<Map<String, Object>> sy02001_doSearch(Map<String, String> param) throws Exception {

		if(EverString.isNotEmpty(param.get("YEAR"))) { param.put("YEAR", EverString.forInQuery(param.get("YEAR"), ",")); }
		if(EverString.isNotEmpty(param.get("MONTH"))) { param.put("MONTH", EverString.forInQuery(param.get("MONTH"), ",")); }
		if(EverString.isNotEmpty(param.get("HOLYDAY_TYPE"))) { param.put("HOLYDAY_TYPE", EverString.forInQuery(param.get("HOLYDAY_TYPE"), ",")); }

		return sy0201Mapper.sy02001_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> sy02001_doSave(List<Map<String, Object>> gridDatas) throws Exception {
		Map<String, String> rtnMap = new HashMap<String, String>();
		for(Map<String, Object> gridData : gridDatas) {
			int checkID = sy0201Mapper.sy02001_doCheck(gridData);
			if (checkID > 0) {
				rtnMap.put("rtnMsg", msg.getMessage("0034"));
				//rtnMap.put("rtnMsg", "이미 등록된 정보가 있습니다. "+ gridData.get("YEAR") +"년 / BAND : "+gridData.get("BAND_CD")+" / "+gridData.get("YEAR_CNT")+"연차");
				return rtnMap;
			}
			sy0201Mapper.sy02001_doSave(gridData);
		}
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String sy02001_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			sy0201Mapper.sy02001_doDelete(gridData);
		}
		return msg.getMessage("0017");
	}

	/** ******************************************************************************************
	 * 휴일관리
	 * @param req
	 * @return
	 * @throws Exception
	 */

	public List<Map<String, Object>> sy02001_doSearchTx(Map<String, String> param) throws Exception {

		if(EverString.isNotEmpty(param.get("YEARTX"))) { param.put("YEARTX", EverString.forInQuery(param.get("YEARTX"), ",")); }

		return sy0201Mapper.sy02001_doSearchTx(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> sy02001_doSaveTx(List<Map<String, Object>> gridDatas) throws Exception {
		Map<String, String> rtnMap = new HashMap<String, String>();
		for(Map<String, Object> gridData : gridDatas) {
			int checkID = sy0201Mapper.sy02001_doCheckTx(gridData);
			if (checkID > 0) {
				rtnMap.put("rtnMsg", msg.getMessage("0034"));
				//rtnMap.put("rtnMsg", "이미 등록된 정보가 있습니다. "+ gridData.get("YEAR") +"년 / BAND : "+gridData.get("BAND_CD")+" / "+gridData.get("YEAR_CNT")+"연차");
				return rtnMap;
			}
			sy0201Mapper.sy02001_doSaveTx(gridData);
		}
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String sy02001_doDeleteTx(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			sy0201Mapper.sy02001_doDeleteTx(gridData);
		}
		return msg.getMessage("0017");
	}




}
