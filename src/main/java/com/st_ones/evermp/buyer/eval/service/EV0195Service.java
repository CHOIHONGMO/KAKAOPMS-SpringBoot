package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.multiLanguage.service.MultiLanguageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0195Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "sRM_195_Service")
public class EV0195Service extends BaseService {

	@Autowired
	EV0195Mapper srm_195_mapper;

	@Autowired
	private MessageService msg;

	@Autowired
	LargeTextService largeTextService;

	@Autowired
	private DocNumService docNumService;

	@Autowired
	MultiLanguageService multiLanguageService;

	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
		return srm_195_mapper.doSearch(param);
	}


	/**
	 * 평가완료
	 * @param grid
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doComplete(List<Map<String, Object>> grid) throws Exception {
		String args="";

		for (Map<String, Object> gridData : grid) {

			Map<String, Object> retData = srm_195_mapper.doCheck(gridData);

			String result_enter_user_cd = retData.get("RESULT_ENTER_CD").toString();

			if( "EVALUSER".equals(result_enter_user_cd) ) { //평가담당자

				if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					throw new NoResultException(msg.getMessageByScreenId("EV0195","0001"));
				}

			} else if( "PERUSER".equals(result_enter_user_cd) ) {//평가자

				if (!retData.get("EV_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					throw new NoResultException(msg.getMessageByScreenId("EV0195","0002"));
				}

			} else if( "REPUSER".equals(result_enter_user_cd) ) {//대표평가자
				gridData.put("CHK_USER",  UserInfoManager.getUserInfo().getUserId() );
				int repUserCnt = srm_195_mapper.doRepUserCheck(gridData);

				if ( repUserCnt == 0 ) {
					throw new NoResultException(msg.getMessageByScreenId("EV0195","0003"));
				}
			}

			if ( "200".equals(retData.get("PROGRESS_CD").toString()) ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0195","0004"));
			}

			if ( retData.get("COMPLETE_DATE") != null && !EverString.isEmpty(retData.get("COMPLETE_DATE").toString()) ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0195","0005"));
			}

			String evalScore = retData.get("EVAL_SCORE") == null ? "":retData.get("EVAL_SCORE").toString();

			if ( EverString.isEmpty(evalScore) || Float.parseFloat(evalScore) == 0 ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0195","0006"));
			}

			srm_195_mapper.doCompleteEvvu(gridData);

			/** 평가 마스터 평가점수 Update */
			srm_195_mapper.doUpdateEvScore(gridData);

		}

		args = msg.getMessage("0001");

		return args;

	}


	/**
	 * 완료취소
	 * @param grid
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCancel(List<Map<String, Object>> grid) throws Exception {
		String args="";

		for (Map<String, Object> gridData : grid) {

			Map<String, Object> retData = srm_195_mapper.doCheck(gridData);

			String result_enter_user_cd = retData.get("RESULT_ENTER_CD").toString();

			if( "EVALUSER".equals(result_enter_user_cd) ) { //평가담당자

				if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					throw new NoResultException(msg.getMessageByScreenId("SRM_195","0001"));
				}

			} else if( "PERUSER".equals(result_enter_user_cd) ) {//평가자

				if (!retData.get("EV_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					throw new NoResultException(msg.getMessageByScreenId("SRM_195","0002"));
				}

			} else if( "REPUSER".equals(result_enter_user_cd) ) {//대표평가자
				gridData.put("CHK_USER",  UserInfoManager.getUserInfo().getUserId() );
				int repUserCnt = srm_195_mapper.doRepUserCheck(gridData);

				if ( repUserCnt == 0 ) {
					throw new NoResultException(msg.getMessageByScreenId("SRM_195","0003"));
				}
			}

			if ( !"200".equals(retData.get("PROGRESS_CD").toString()) ) {
				throw new NoResultException(msg.getMessageByScreenId("SRM_195","0007"));
			}

			if ( retData.get("COMPLETE_DATE") != null && !EverString.isEmpty(retData.get("COMPLETE_DATE").toString()) ) {
				throw new NoResultException(msg.getMessageByScreenId("SRM_195","0005"));
			}

			srm_195_mapper.doCancelEvvu(gridData);

			/** 평가 마스터 평가점수 Update */
			srm_195_mapper.doUpdateEvScore(gridData);

		}

		args = msg.getMessage("0001");

		return args;

	}


}