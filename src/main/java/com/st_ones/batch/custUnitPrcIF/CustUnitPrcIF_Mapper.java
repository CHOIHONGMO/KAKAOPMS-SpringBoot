package com.st_ones.batch.custUnitPrcIF;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface CustUnitPrcIF_Mapper {

	List<Map<String, Object>> getIfSendList();

	void insCustUinfo(Map<String, Object> data);

	void updateDgnsIfFlag(Map<String, Object> data);

}
