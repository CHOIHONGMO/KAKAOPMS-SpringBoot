package com.st_ones.eversrm.board.email.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.common.util.service.UtilService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.board.email.BBOE_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : BBOE_Service.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "bboe_Service")
public class BBOE_Service extends BaseService {

	@Autowired DocNumService docNumService;
	@Autowired MessageService msg;
	@Autowired LargeTextService largeTextService;
	@Autowired BBOE_Mapper bboe_Mapper;
	@Autowired UtilService utilService;

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSendLetter(Map<String, String> formData) throws Exception {

		String docNum = docNumService.getDocNumber("LT");
		formData.put("MSG_NUM", docNum);
		String textNum = largeTextService.saveLargeText(null, formData.get("CONTENT"));
		formData.put("MSG_TEXT_NUM", textNum);
		bboe_Mapper.doSendLetterMSGE(formData);

		String user_ids = formData.get("TFT_MEMBER");
		
		Map<String, Object>  param = new HashMap<String, Object>();
		StringTokenizer st = new StringTokenizer(user_ids,",");
		ArrayList<Map<String,String>> al = new ArrayList<Map<String,String>>();
		while(st.hasMoreElements())  {
			Map<String,String> map = new HashMap<String,String>();
			map.put("value", st.nextToken());
			al.add(map);
		}
		param.put("list", al);
		param.put("MSG_NUM", docNum);
		param.put("USER_IDS",user_ids);
		List<Map<String,Object>> mml = bboe_Mapper.doSearchUserMulti(param);
		for(Map<String,Object> mdata : mml) {
			bboe_Mapper.doSendLetterMSRD(mdata);
		}
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateReceiveDate(Map<String, String> formData) throws Exception {
		bboe_Mapper.doUpdateReceiveDate(formData);
		return msg.getMessage("0001");
	}
	
	public List<Map<String, Object>> doSearchInbox(Map<String, String> param) throws Exception {
		return bboe_Mapper.doSearchInbox(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteInbox(List<Map<String, Object>> gridDatas) throws Exception {

		int rtn = -1;

		for (Map<String, Object> gridData : gridDatas) {

			rtn = bboe_Mapper.doDeleteInbox(gridData);
			if (rtn < 1) {
				throw new NoResultException(msg.getMessage("0003"));
			}
		}

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> doSearchOutbox(Map<String, String> param) throws Exception {
		return bboe_Mapper.doSearchOutbox(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteOutbox(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			int rtn = bboe_Mapper.doDeleteOutbox(gridData);
			if (rtn < 1) {
				throw new NoResultException(msg.getMessage("0003"));
			}
		}

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> selectUserSearch(Map<String, String> param) throws Exception {
		return bboe_Mapper.selectUserSearch(param);
	}

	public Map<String, Object> doSelectPopupLetter(Map<String, String> param) throws Exception {
		
		String databaseId = utilService.getDatabaseId();
		Map<String, Object> list = bboe_Mapper.doSelectPopupLetter(param);
		
		//mssql에서는 서브쿼리로 처리할수 없는 로직이고, 다시 쿼리를 실행해야 함.
		if("mssql".equals(databaseId)) {
			list.put("RECV_USER_NM", bboe_Mapper.doRecvUserNameByMssql(param));			
		}
		
		return list;
	}

}