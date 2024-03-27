package com.st_ones.batch.grRequestDelaySms;
/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface GrRequestDelaySmsMapper {

	List<Map<String, Object>> doGrRequestDelaySmsSELECT(Map<String, String> param);
}