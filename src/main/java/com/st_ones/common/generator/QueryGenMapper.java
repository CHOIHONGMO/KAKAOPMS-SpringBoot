package com.st_ones.common.generator;

import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 27 오전 10:28
 */

@Repository
public interface QueryGenMapper {

    String generateSearchCondition(Map<String, String> param);

}
