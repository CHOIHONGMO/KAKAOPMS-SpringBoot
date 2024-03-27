package com.st_ones.eversrm.basic.user.service;

import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.basic.user.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service(value = "userService")
public class UserService extends BaseService {

//	@Autowired
//	private MessageService msg;

	@Autowired
	private UserMapper userMapper;

	public List<Map<String, Object>> doSearchUserWorkHistory(Map<String, String> param) throws Exception {
		param.put("JOB_TYPE", EverString.forInQuery(param.get("JOB_TYPE"), ","));
		return userMapper.doSearchUserWorkHistory(param);
	}
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public List<Map<String, Object>> doSearchUser(Map<String, Object> param) throws Exception {
		
		String user_ids = (String)param.get("USER_IDS");
		
		StringTokenizer st = new StringTokenizer(user_ids,",");
		ArrayList al = new ArrayList();
		while(st.hasMoreElements())  {
			Map<String,String> map = new HashMap<String,String>();
			map.put("value", st.nextToken());
			al.add(map);
		}
		param.put("list", al);
		return userMapper.doSearchUser(param);

	}	
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public List<Map<String, Object>> doSearchUserMulti(Map<String, Object> param) throws Exception {
		
		String user_ids = (String)param.get("USER_IDS");
		
		StringTokenizer st = new StringTokenizer(user_ids,",");
		ArrayList al = new ArrayList();
		while(st.hasMoreElements())  {
			Map<String,String> map = new HashMap<String,String>();
			map.put("value", st.nextToken());
			al.add(map);
		}
		param.put("list", al);
		return userMapper.doSearchUserMulti(param);

	}

	public List<Map<String, Object>> badu060_doSearch(Map<String, String> param) throws Exception {
		param.put("JOB_TYPE", "");
		return userMapper.badu060_doSearch(param);
	}

	public List<Map<String, Object>> badu070_doSearch(Map<String, String> param) throws Exception {
		param.put("JOB_TYPE", EverString.forInQuery(param.get("JOB_TYPE"), ","));
		return userMapper.badu070_doSearch(param);
	}

}