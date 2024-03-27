package com.st_ones.eversrm.system.batch.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.eversrm.system.batch.BatchListMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service(value = "BatchList_Service")
public class BatchListService {

	@Autowired private MessageService msg;

	@Autowired BatchListMapper batchListMapper;

	@Autowired private EverSmsService everSmsService;

	public List<Map<String, Object>> doSearchBatchList(Map<String, String> param) throws Exception {
		return batchListMapper.doSearchBatchList(param);
	}

	public List<Map<String, Object>> doSearchBatchLogList(Map<String, String> param) throws Exception {
		return batchListMapper.doSearchBatchLogList(param);
	}

}
