package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.bd.service.BD0300Service;
import com.st_ones.evermp.buyer.eval.EV0270Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service(value="EV0270Service")
public class EV0270Service extends BaseService {
	@Autowired MessageService msg;
	@Autowired EV0270Mapper ev0270Mapper;
	@Autowired BD0300Service bd0300Service;

	/**
	 * doSearch
	 *
	 * @param param the form data
	 * @return the List
	 * @throws Exception the exception
	 */
	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
		Map<String, Object> paramObj = (Map) param;
		if(EverString.isNotEmpty(param.get("BUYER_CD"))){
			paramObj.put("BUYER_CD_LIST", Arrays.asList(param.get("BUYER_CD").split(",")));
		}
		return ev0270Mapper.doSearch(paramObj);
	}


	public List<Map<String, Object>> doSearchEsgSummaryList(Map<String, String> param) throws Exception {
		return ev0270Mapper.doSearchEsgSummaryList(param);
	}



	public Map<String, String> getEsgValueInfo(Map<String, String> param) throws Exception {
		return ev0270Mapper.getEsgValueInfo(param);
	}






	/**
	 * doComplete
	 *
	 * @param gridDatas the list
	 * @return the String
	 * @throws Exception the exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String srm270_doComplete(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object>gridData : gridDatas){
			ev0270Mapper.srm270_doComplete(gridData);

			String check = ev0270Mapper.check(gridData);

			if(check.equals("TRUE")) {
				ev0270Mapper.emFinish(gridData);
			}


		}

		bd0300Service.updateEVResultBDVN(gridDatas);

		return msg.getMessage("0001");
	}

	/**
	 * doCancel
	 *
	 * @param gridDatas the list
	 * @return the String
	 * @throws Exception the exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCancel(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object>gridData : gridDatas){
			ev0270Mapper.doCancel(gridData);
			ev0270Mapper.doCancelEm(gridData);
		}
		return msg.getMessage("0001");
	}

	/**
	 * doEdit
	 *
	 * @param gridDatas the list
	 * @return the String
	 * @throws Exception the exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doEdit(List<Map<String, Object>> gridDatas) throws Exception{
		for(Map<String, Object>gridData : gridDatas){
			ev0270Mapper.doEdit(gridData);
		}
		return msg.getMessage("0001");
	}


	public List<Map<String, Object>> EV0270P03_doSearch(Map<String, String> formData) throws Exception {
		return ev0270Mapper.EV0270P03_doSearch(formData);
	}
}
