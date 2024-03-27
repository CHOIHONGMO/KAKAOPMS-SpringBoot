package com.st_ones.batch.batchLogCom;
/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public interface BatchLogCommon_Mapper {
	// Batch 로그 기록하기
	void doSaveBatchLog(Map<String, Object> gridData);
}