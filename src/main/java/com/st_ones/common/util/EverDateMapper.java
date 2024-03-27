package com.st_ones.common.util;

import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.Map;

@Repository
public interface EverDateMapper {

	//@Select("SELECT SYSDATE FROM DUAL")
	Date getCurrentServerTime();

	String getWorkingDay(Map<String, Object> param);

}