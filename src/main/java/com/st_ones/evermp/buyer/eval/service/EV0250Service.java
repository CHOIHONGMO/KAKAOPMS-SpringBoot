package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.bd.BD0300Mapper;
import com.st_ones.evermp.buyer.eval.EV0250Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value="EV0250Service")
public class EV0250Service extends BaseService {
	@Autowired private MessageService msg;
	@Autowired EV0250Mapper ev0250Mapper;


	@Autowired  private BD0300Mapper bd0300Mapper;



	public List<Map<String, Object>> getRegCombo(Map<String, String> param) throws Exception {
		return ev0250Mapper.getRegCombo(param);
	}

	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
		return ev0250Mapper.doSearch(param);
	}

	public List<Map<String, Object>> getEvUserCombo(Map<String, String> param) throws Exception {
		return ev0250Mapper.getEvUserCombo(param);
	}

	public List<Map<String, Object>> doSearchType(Map<String, String> param) throws Exception{
		return ev0250Mapper.doSearchType(param);
	}

	public List<Map<String, Object>> doSearchSubject(Map<String, String> param) throws Exception{
		return ev0250Mapper.doSearchSubject(param);
	}

	public List<Map<String, Object>> doSearchDetail(Map<String, String> param) throws Exception{
		return ev0250Mapper.doSearchDetail(param);
	}

	public Map<String, String> doSearchEveu(Map<String, String> param) throws Exception {
		return ev0250Mapper.doSearchEveu(param);
	}

	/**
	 * 정성평가결과등록 - 저장
	 * @param params
	 * @return String
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSave(Map<String, String> params) throws Exception{
		Map<String,String> data = new HashMap<String,String>();
		UserInfo userInfo = UserInfoManager.getUserInfo();

		String  queryString 	= params.get("QUERY_STR");

		String  ev_num 			= params.get("EV_NUM_L");
		String  ev_tpl_num 		= params.get("EV_TPL_NUM");
		String  ev_user_id 		= params.get("EV_USER_ID");
//		String	ev_score 		= params.get("EV_SCORE_R");
		String	ev_score 		= params.get("TOTAL_SCORE");
		String  att_file_num	= params.get("ATT_FILE_NUM");
		String  vendor_cd		= params.get("VENDOR_CD");
		String vendor_sq = params.get("VENDOR_SQ");
		String	rmk				= params.get("RMK");

		String  ev_type 			= params.get("EV_TYPE");

		String  esgChkType 			= params.get("ESG_CHK_TYPE");


		data.put("EV_NUM"		, ev_num);
		data.put("EV_TPL_NUM"	, ev_tpl_num);
		data.put("EV_USER_ID"	, ev_user_id);
		data.put("EV_SCORE"		, ev_score);
		data.put("ATT_FILE_NUM"	, att_file_num);
		data.put("VENDOR_CD"	, vendor_cd);
		data.put("ESG_CHK_TYPE"	, esgChkType);

		data.put("RMK", rmk);


		Map<String,String> delData = new HashMap<String,String>();
		delData.put("EV_NUM"		, ev_num);
		delData.put("EV_TPL_NUM"	, ev_tpl_num);
		delData.put("EV_USER_ID"	, ev_user_id);
		delData.put("VENDOR_CD"	, vendor_cd);
		delData.put("VENDOR_SQ"	, vendor_sq);

		ev0250Mapper.doDeleteEvee(delData);


		Map<String, String> chkData = ev0250Mapper.doCheck(data);

		if (chkData == null) {
			throw new NoResultException(msg.getMessageByScreenId("EV0250","progressNull"));
		}


		String result_enter_user_cd = chkData.get("RESULT_ENTER_CD").toString();
		String EV_CTRL_USER_ID = chkData.get("EV_CTRL_USER_ID");

		if(!userInfo.getUserId().equals(EV_CTRL_USER_ID)) {
			if( "EVALUSER".equals(result_enter_user_cd) ) { //평가담당자
				if (!chkData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					throw new NoResultException(msg.getMessageByScreenId("EV0250","eval_user")); // 메시지 등록: 평가 담당자만 처리할 수 있습니다.
				}
			} else if( "PERUSER".equals(result_enter_user_cd) ) {//평가자
				if (!chkData.get("EV_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					if(!"ESG".equals(ev_type))
					throw new NoResultException(msg.getMessageByScreenId("EV0250","per_user"));  //메시지 등록: 평가자만 처리할 수 있습니다.
				}
			} else if( "REPUSER".equals(result_enter_user_cd) ) {//대표평가자
				chkData.put("CHK_USER",  UserInfoManager.getUserInfo().getUserId() );
				int repUserCnt = ev0250Mapper.doRepUserCheck(chkData);

				if ( repUserCnt == 0 ) {
					throw new NoResultException(msg.getMessageByScreenId("EV0250","rep_user"));   //메시지 등록: 대표평가자만 처리할 수 있습니다.
				}
			}
		}


		//평가진행상태 확인
		String checkProgress = ev0250Mapper.checkProgress(data);
		if ( "N".equals(checkProgress) && !"ESG".equals(ev_type)) {// y면 평가진행중 //n면 평가완료 ESG 평가는 수정할수있다.
			throw new NoResultException(msg.getMessageByScreenId("EV0250","progress"));
		}

		/*if (chkData.get("PROGRESS_CD") == null) {
			throw new NoResultException(msg.getMessageByScreenId("EV0250","progressNull"));
		}*/
		/*if ( !"".equals(chkData.get("PROGRESS_CD").toString()) && "200".equals(chkData.get("PROGRESS_CD").toString()) ) {
			throw new NoResultException(msg.getMessageByScreenId("EV0250","progress"));
		}*/



		if( queryString != null && !"".equals(queryString)){
			String[] datas = queryString.split("##");

            List<Map<String,String>> getEVScoreByEVT = bd0300Mapper.getEVScoreByEVT(params);
            Map<String,String[]> evInfoMap = new HashMap<>();
            for(Map<String,String> evInfo : getEVScoreByEVT){
                String[] ev = new String[3];
                ev[0] = evInfo.get("EV_ITEM_TYPE_CD");  //가격(OP), 비가격(NP)
                ev[1] = String.valueOf(evInfo.get("WEIGHT")); //가중치
                ev[2] = String.valueOf(evInfo.get("EV_ID_SCORE")); //해당 템플릿 최고점
                evInfoMap.put(evInfo.get("EV_ITEM_NUM"), ev);
            }

			for(int i=0; i<datas.length; i++) {
				String[] items = datas[i].split("@@");
				String item_num 			= items[0];
				String item_id_sq 			= items[1];
				String item_id_score 		= items[2];
				String item_remark 		= items[3];
				data.put("EV_ITEM_NUM"		, item_num);
				data.put("EV_ID_SQ"		, item_id_sq);
				data.put("EV_ID_SCORE"		, item_id_score);
				data.put("VENDOR_CD"		, vendor_cd);
				data.put("VENDOR_SQ", vendor_sq);
				data.put("EV_REMARK"		, EverString.replace(item_remark,"_","")); //평가의견 - 20151217 추가

				String item_att_file_num 		= items[4];
				if("null".equals(item_att_file_num)) item_att_file_num = null;
				String chk_yn 		= items[5];
				data.put("CHK_YN", chk_yn);
				data.put("ATT_FILE_NUM_EE", EverString.replace(item_att_file_num,"_",""));




				if ("ESG".equals(params.get("EV_TYPE"))) { //ESG 평가(협력업체가 평가시)
                    data.put("EV_ID_SCORE"	, String.valueOf(item_id_score));
				} else {
	                String[] str = evInfoMap.get(item_num);
	                BigDecimal weight = new BigDecimal(str[1]);
	                BigDecimal highScore = new BigDecimal(str[2]);
	                BigDecimal thisScore = new BigDecimal(item_id_score).divide(weight,5, BigDecimal.ROUND_DOWN);
	                BigDecimal result = thisScore.divide(highScore, 5, BigDecimal.ROUND_DOWN).multiply(weight);

	                if(new BigDecimal(item_id_score).compareTo(BigDecimal.ZERO) == 0) {
	                    data.put("EV_ID_SCORE"	, "0");
	                } else {
	                    data.put("EV_ID_SCORE"	, String.valueOf(result));
	                }
				}



				ev0250Mapper.doUpdateEvee(data); //정성평가 세부내역 UPDATE
			}
		}

		ev0250Mapper.doUpdateEveu(data); //평가자 정보 UPDATE


		return msg.getMessage("0001");
	}
}
