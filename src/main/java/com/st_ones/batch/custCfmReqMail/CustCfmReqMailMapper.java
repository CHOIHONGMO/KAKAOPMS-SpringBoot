package com.st_ones.batch.custCfmReqMail;
/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 11:40
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface CustCfmReqMailMapper {
	
	// 현재일자 - 마감일자 >= 2
	List<Map<String, Object>> doCustCfmReqMail();

}