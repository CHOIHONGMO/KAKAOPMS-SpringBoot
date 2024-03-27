package com.st_ones.evermp.buyer.cont.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.cont.CT0400Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service(value = "CT0400Service")
public class CT0400Service  extends BaseService {
	
	@Autowired MessageService msg;
	@Autowired LargeTextService largeTextService;
	
	@Autowired private CT0400Mapper ct0400mapper;

    public List<Map<String, Object>> getContPoDetailList(Map<String, String> formData) {
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PUR_ORG_CD"))) {
            paramObj.put("PUR_ORG_CD_LIST", Arrays.asList(formData.get("PUR_ORG_CD").split(",")));
        }
        return ct0400mapper.getContPoDetailList(paramObj);
    }

    public List<Map<String, Object>> getContPoReadyList(Map<String, String> formData) {
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PUR_ORG_CD"))) {
            paramObj.put("PUR_ORG_CD_LIST", Arrays.asList(formData.get("PUR_ORG_CD").split(",")));
        }
        return ct0400mapper.getContPoReadyList(paramObj);
    }

    public List<Map<String, Object>> getContPoList(Map<String, String> formData) {
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PUR_ORG_CD"))) {
            paramObj.put("PUR_ORG_CD_LIST", Arrays.asList(formData.get("PUR_ORG_CD").split(",")));
        }
        return ct0400mapper.getContPoList(paramObj);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelPo(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {
        	ct0400mapper.cancelPohd(rowData);
        	ct0400mapper.cancelPodt(rowData);
        }
        return msg.getMessage("0001");
    }

}
