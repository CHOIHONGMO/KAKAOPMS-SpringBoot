package com.st_ones.common.generator.service;

import com.st_ones.common.generator.QueryGenMapper;
import com.st_ones.everf.serverside.service.BaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 27 오전 10:27
 */

@Service(value = "queryGenService")
public class QueryGenService extends BaseService {

    @Autowired
    QueryGenMapper queryGenMapper;

    public String generateSearchCondition(Map<String, String> param) {
        return queryGenMapper.generateSearchCondition(param);
    }

}