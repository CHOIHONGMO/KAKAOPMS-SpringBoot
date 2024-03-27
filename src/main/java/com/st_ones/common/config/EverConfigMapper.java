package com.st_ones.common.config;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface EverConfigMapper {

	List<Map<String, String>> getConfig(@Param("key") String settingType);

}
