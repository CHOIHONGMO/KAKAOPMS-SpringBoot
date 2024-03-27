package com.st_ones.evermp.buyer.cont;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
@Repository
public interface CT0400Mapper {
	List<Map<String, Object>> getContPoList(Map<String, Object> param);

	void cancelPohd(Map<String, Object> gridRow);
	void cancelPodt(Map<String, Object> gridRow);





	List<Map<String, Object>> getContPoReadyList(Map<String, Object> param);


	List<Map<String, Object>> getContPoDetailList(Map<String, Object> param);


}
