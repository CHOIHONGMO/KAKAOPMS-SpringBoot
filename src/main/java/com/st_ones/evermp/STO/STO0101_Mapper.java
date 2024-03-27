package com.st_ones.evermp.STO;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface STO0101_Mapper {



	int sto0101_doSave(Map<String, Object> gridDatum);

	List<Map<String, Object>> sto0101_doSearch(Map<String, String> formData);


	List<Map<String, Object>> sto0102_doSearch(Map<String, String> formData);

	void sto0102_doSave(Map<String, Object> gridDatum);


}
