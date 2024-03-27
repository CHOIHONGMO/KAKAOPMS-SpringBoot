package com.st_ones.evermp.STO.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.evermp.STO.STO0101_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "sto0101_Service")
public class STO0101_Service {
    @Autowired
    private STO0101_Mapper sto0101Mapper;

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private QueryGenService queryGenService;

    @Autowired private MessageService msg;
    String docNum="";

    /** ****************************************************************************************************************
     * *창고 등록
     * @param req
     * @return
     * @throws Exception
     */
	 @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void sto0101_doSave(List<Map<String, Object>> gridData) throws Exception {
		 for (Map<String, Object> gridDatum : gridData) {
			 EverString.nullToEmptyString(gridDatum.get("WAREHOUSE_CODE"));
			 if(gridDatum.get("WAREHOUSE_CODE")!= null) {
			 sto0101Mapper.sto0101_doSave(gridDatum);
			 }
			 else {
				 docNum= docNumService.getDocNumber("WH");
				 gridDatum.put("WAREHOUSE_CODE",docNum);
				 sto0101Mapper.sto0101_doSave(gridDatum);
			 	}
		 }
	 }


	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> sto0101_doSearch(Map<String, String> formData) throws Exception{

		  return sto0101Mapper.sto0101_doSearch(formData);
	}


	/* *******************************************************************************************************************************
	 * * 안전재고
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> sto0102_doSearch(Map<String, String> formData) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC||MTGL.ITEM_SPEC||MTGL.ITEM_CD||MTGL.CUST_ITEM_CD");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
    	return sto0101Mapper.sto0102_doSearch(formData);
	}


	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String sto0102_doSave(Map<String, String> param, List<Map<String, Object>> gridData) throws Exception {
		 for (Map<String, Object> gridDatum : gridData) {

				 sto0101Mapper.sto0102_doSave(gridDatum);

		 	}
		 return msg.getMessage("0031");

	}
}

