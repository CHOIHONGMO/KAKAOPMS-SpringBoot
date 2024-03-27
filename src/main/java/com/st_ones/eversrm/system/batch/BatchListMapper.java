package com.st_ones.eversrm.system.batch;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BatchListMapper {

	List<Map<String, Object>> doSearchBatchList(Map<String, String> param);

	List<Map<String, Object>> doSearchBatchLogList(Map<String, String> param);

	List<Map<String, String>> getBatchManagerSms(Map<String, String> param);

	int doSaveBatchLog(Map<String, Object> gridData);

}
