package com.st_ones.eversrm.system.migration.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 23 오전 8:46
 */

import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.migration.MIG_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "MIG_Service")
public class MIG_Service extends BaseService {

	@Autowired MIG_Mapper mig_Mapper;
	@Autowired MessageService msg;


	//입력한 querty 실행하기
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> mig010_doSearch(Map<String, String> formData) throws Exception {
		return mig_Mapper.mig010_doSearch(formData);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String mig010_doSave(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			mig_Mapper.mig010_doSave(gridData);
		}
		return msg.getMessage("0031");
	}

}