package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0280Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service(value="EV0280Service")
public class EV0280Service extends BaseService {
	@Autowired MessageService msg;
	@Autowired EV0280Mapper srm_280_mapper;

	/**
	 * 조회
	 *
	 * @param param the form data
	 * @return the List
	 * @throws Exception the exception
	 */
	public List<Map<String, Object>> srm280_doSearch(Map<String, String> param) throws Exception {
		return srm_280_mapper.srm280_doSearch(param);
	}

}
