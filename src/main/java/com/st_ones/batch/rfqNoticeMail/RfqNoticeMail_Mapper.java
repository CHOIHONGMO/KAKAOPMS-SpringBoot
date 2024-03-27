package com.st_ones.batch.rfqNoticeMail;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 25 오전 9:28
 */
@Repository
public interface RfqNoticeMail_Mapper {
	
	// D+3일까지 견적 미접수 협력사
    List<Map<String, Object>> doSelectNonPartRfqVendors(Map<String, String> param);

	// D+3일까지 입찰 미접수 협력사
    List<Map<String, Object>> doSelectNonPartBidVendors(Map<String, String> param);
}
