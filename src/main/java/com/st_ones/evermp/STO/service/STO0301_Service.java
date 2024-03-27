package com.st_ones.evermp.STO.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.evermp.STO.STO0301_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "STO0301_Service")
public class STO0301_Service {
    @Autowired
    private STO0301_Mapper sto0301Mapper;
    @Autowired
    private QueryGenService queryGenService;

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> sto0301_doSearch(Map<String, String> formData) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC||MTGL.ITEM_SPEC");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
    	return sto0301Mapper.sto0301_doSearch(formData);
	}
}
