package com.st_ones.evermp.STO;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface STO0301_Mapper {

	List<Map<String, Object>> sto0301_doSearch(Map<String, String> formData);

}
