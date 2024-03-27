package com.st_ones.batch.comPlantIf.service;

import com.st_ones.batch.comPlantIf.ComPlantIf_Mapper;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "ComPlantIf_Service")
public class ComPlantIf_Service {

    @Autowired private MessageService msg;
    @Autowired private ComPlantIf_Mapper comPlantIf_mapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ComPlantIf(Map<String, String> param1) throws Exception {
    	
        List<Map<String, Object>> list = comPlantIf_mapper.getComPlantList();
        for (Map<String, Object> data : list) {
        	// 26(㈜대명소노시즌) : 운영사로 등록(stocogpl)
        	if( "26".equals(data.get("COMPANY_CODE")) ) {
                comPlantIf_mapper.setComPlantOGPL(data); // 사업장 등록
        	} else {
                comPlantIf_mapper.setComPlantCUPL(data); // 사업장 등록
                comPlantIf_mapper.setComPlantCUBL(data); // 청구지 등록
        	}
            comPlantIf_mapper.doUpdateIfResultPlant(data);// 반영결과 등록
        }
        
        return "[고객사 사업장정보: " + (list==null?0:list.size()) + "건] " + msg.getMessage("0001");
    }

}
