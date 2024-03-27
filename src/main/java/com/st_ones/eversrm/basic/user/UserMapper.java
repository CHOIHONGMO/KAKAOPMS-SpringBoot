package com.st_ones.eversrm.basic.user;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface UserMapper {

	List<Map<String, Object>> doSearchUserWorkHistory(Map<String, String> param);

	List<Map<String, Object>> doSearchUser(Map<String, Object> param);

	List<Map<String, Object>> doSearchUserMulti(Map<String, Object> param);

	Map<String, Object> doGetUser(Map<String, Object> param);

	List<Map<String, Object>> badu060_doSearch(Map<String, String> param);

	List<Map<String, Object>> badu070_doSearch(Map<String, String> param);

}