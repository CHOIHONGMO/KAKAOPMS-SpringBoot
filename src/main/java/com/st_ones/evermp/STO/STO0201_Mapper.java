package com.st_ones.evermp.STO;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface STO0201_Mapper {



	void sto0202_InsertGIAD(Map<String, Object> gridData);

	void sto0202_insertMMRS(Map<String, Object> gridData);

	List<Map<String, Object>> sto02p01_doSearch(Map<String, String> param);

	void sto0201_InsertTRANFROM(Map<String, Object> gridData);
	void sto0201_InsertTRANTO(Map<String, Object> gridData);
	void sto0201_InsertMMRSFROM(Map<String, Object> gridData);
	void sto0201_insertMMRSTO(Map<String, Object> gridData);
}
