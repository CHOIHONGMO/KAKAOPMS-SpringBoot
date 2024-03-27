package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0290Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value="EV0290Service")
public class EV0290Service extends BaseService {
	@Autowired MessageService msg;
	@Autowired EV0290Mapper srm_290_mapper;

	/**
	 * 조회
	 *
	 * @param param the form data
	 * @return the List
	 * @throws Exception the exception
	 */
	public Map<String, Object> srm290_doSearch(Map<String, String> param) throws Exception {
		String EV_USER_ID_LIST = EverString.nullToEmptyString(srm_290_mapper.srm290_doSearch_USER_ID(param));

		if("".equals(EV_USER_ID_LIST)) {
            throw new NoResultException(msg.getMessageByScreenId("SRM_290","001"));
		}

		Map<String, Object> map = new HashMap<>();

		map.put("EV_NUM", param.get("EV_NUM"));
		//map.put("EV_USER_ID_LIST", EverString.forInQueryArrayList(EV_USER_ID_LIST, ","));

		List<Map<String, Object>> list = srm_290_mapper.srm290_doSearch(map);

		map.put("grid", list);

		return map;
	}

	// 평가자 조회, 그리드를 만들기 위해
	public List<Map<String, Object>> srm290_doSearchUSER(Map<String, String> param) throws Exception {
		Map<String, Object> map = new HashMap<>();

		map.put("EV_NUM", param.get("EV_NUM"));

		List<Map<String, Object>> userList = srm_290_mapper.srm290_doSearch_USER_NM(map);

		if(userList == null || userList.size() == 0) {
			throw new NoResultException(msg.getMessageByScreenId("SRM_290","001"));
		}

		List<Map<String, Object>> colList = new ArrayList<>();

		Map<String, Object> colMapV = new HashMap<>();
		colMapV.put("COLUMN_ID", "VENDOR_NM");
		colMapV.put("COLUMN_NM", "파트너사명");
		colList.add(colMapV);

		Map<String, Object> colMapC = new HashMap<>();
		colMapC.put("COLUMN_ID", "CONT_DESC");
		colMapC.put("COLUMN_NM", "계약명");
		colList.add(colMapC);

		for(Map<String, Object> data : userList) {
			Map<String, Object> colMap = new HashMap<>();
			colMap.put("COLUMN_ID", "STONES" + data.get("EV_USER_ID"));
			colMap.put("COLUMN_NM", data.get("EV_USER_NM"));

			colList.add(colMap);
		}

		Map<String, Object> colMap1 = new HashMap<>();
		colMap1.put("COLUMN_ID", "VENDOR_EV_SCORE");
		colMap1.put("COLUMN_NM", "회사현황");
		colList.add(colMap1);

		Map<String, Object> colMap4 = new HashMap<>();
		colMap4.put("COLUMN_ID", "AMEND_SCORE");
		colMap4.put("COLUMN_NM", "조정점수");
		colList.add(colMap4);

		Map<String, Object> colMap2 = new HashMap<>();
		colMap2.put("COLUMN_ID", "VENDOR_EV_SCORE_AVG");
		colMap2.put("COLUMN_NM", "평균");
		colList.add(colMap2);

		Map<String, Object> colMap3 = new HashMap<>();
		colMap3.put("COLUMN_ID", "VENDOR_RMK");
		colMap3.put("COLUMN_NM", "비고");
		colList.add(colMap3);

		return colList;
	}
}
