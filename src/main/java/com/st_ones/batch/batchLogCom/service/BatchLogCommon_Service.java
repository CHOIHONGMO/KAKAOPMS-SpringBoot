package com.st_ones.batch.batchLogCom.service;

import com.st_ones.batch.batchLogCom.BatchLogCommon_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 7. 25 오전 11:12
 */
@Service(value = "batchLogCommon_mapper")
public class BatchLogCommon_Service {

	@Autowired
	BatchLogCommon_Mapper batchLogCommon_mapper;

	//인터페이스 배치 한뒤 배치로그 정보 등록
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void doSaveBatchLog(Map<String, Object> logData) throws Exception {
		batchLogCommon_mapper.doSaveBatchLog(logData);
	}
}
