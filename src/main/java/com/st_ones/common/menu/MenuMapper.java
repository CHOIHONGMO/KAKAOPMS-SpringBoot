package com.st_ones.common.menu;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Mapper
public interface MenuMapper {

	List<Map<String, Object>> getScreenInfo(Map<String, String> param);

	List<Map<String, Object>> getLeftMenu(Map<String, String> param);

	List<Map<String, Object>> getScreenInfo2(Map<String, String> param);

	List<Map<String, String>> getTopMenu(Map<String, String> param);

    int insertBookmark(@Param("templateMenuCd") String templateMenuCd) throws SQLException;

	int deleteBookmark(@Param("templateMenuCd") String templateMenuCd);
}