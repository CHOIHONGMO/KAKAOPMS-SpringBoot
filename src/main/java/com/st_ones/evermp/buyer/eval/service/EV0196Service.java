package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.multiLanguage.service.MultiLanguageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0196Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "sRM_196_Service")
public class EV0196Service extends BaseService {

	@Autowired
	EV0196Mapper srm_196_mapper;

	@Autowired
	private MessageService msg;

	@Autowired
	LargeTextService largeTextService;

	@Autowired
	private DocNumService docNumService;

	@Autowired
	MultiLanguageService multiLanguageService;

	public List<Map<String, Object>> doSearchType(Map<String, String> param) throws Exception {
		return srm_196_mapper.doSearchType(param);
	}
	public List<Map<String, Object>> doSearchSubject(Map<String, String> param) throws Exception {
		return srm_196_mapper.doSearchSubject(param);
	}
	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
		return srm_196_mapper.doSearch(param);
	}

	public Map<String, Object> doSearchEvvu(Map<String, String> param) throws Exception {
		return srm_196_mapper.doSearchEvvu(param);
	}


	/**
	 * 평가결과등록 - 저장
	 * @param grid
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String srm196_doSave(Map<String, String> params) throws Exception {
		String args="";

		Map<String,String> data = new java.util.HashMap<String,String>();

		String  queryString 	= params.get("QUERY_STR");

		String  ev_num 			= params.get("EV_NUM");
		String  ev_tpl_num 		= params.get("EV_TPL_NUM");
		String  ev_user_id 		= params.get("EV_USER_ID");
		String  eval_score 		= params.get("EVAL_SCORE");
		String  att_file_num	= params.get("ATT_FILE_NUM");
		String  rmk 					= params.get("RMK");

		data.put("EV_NUM"			, ev_num);
		data.put("EV_TPL_NUM"	, ev_tpl_num);
		data.put("EV_USER_ID"		, ev_user_id);
		data.put("EVAL_SCORE"	, eval_score);
		data.put("ATT_FILE_NUM"	, att_file_num);
		data.put("RMK"					, rmk);

		Map<String,String> chkData = srm_196_mapper.doCheck(data);

		if ( !"-".equals(chkData.get("PROGRESS_CD").toString()) && "200".equals(chkData.get("PROGRESS_CD").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("EV0196","0001"));
		}

		if ( !"-".equals(chkData.get("COMPLETE_DATE").toString()) && !EverString.isEmpty(chkData.get("COMPLETE_DATE").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("EV0196","0002"));
		}

		srm_196_mapper.doUpdateEvvu(data);

		if( queryString != null && !"".equals(queryString) ) {

			String[] datas = queryString.split("##");

			for(int i=0; i<datas.length; i++) {

				 String[]  items =datas[i].split("@@");

				 String item_num 			= items[0];
				 String item_id_sq 			= items[1];
				 String item_id_score 		= items[2];
				 String item_remark 		= items[3];

				 data.put("EV_ITEM_NUM"		, item_num);
				 data.put("EV_ID_SQ"			, item_id_sq);
				 data.put("EV_ID_SCORE"		, item_id_score);
				 data.put("EV_REMARK"		, EverString.replace(item_remark, "_", ""));

				 srm_196_mapper.doUpdateEvur(data);

			}


		}

		args = msg.getMessage("0001");

		return args;

	}

    public Map<String, Object> srm196prt_searchEVVM(Map<String, String> param) throws Exception {
        return srm_196_mapper.srm196prt_searchEVVM(param);
    }
}