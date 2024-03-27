package com.st_ones.common.combo;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface CommonComboMapper {

	@SuppressWarnings("rawtypes")
    List<Map> getCodesBySQL(Map<String, String> param);

    List<Map> getCodesBySQL2(Map<String, Object> param);

}