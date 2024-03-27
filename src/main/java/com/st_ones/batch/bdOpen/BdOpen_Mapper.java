package com.st_ones.batch.bdOpen;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BdOpen_Mapper {

	List<Map<String, Object>> getBdOpenTargetList();


}
