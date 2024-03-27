package com.st_ones.evermp.buyer.eval.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.eval.EV0220Mapper;
import com.st_ones.evermp.buyer.eval.EV0240Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service(value="EV0240Service")
public class EV0240Service extends BaseService {

	@Autowired EV0240Mapper eV0240Mapper;
	@Autowired EV0220Mapper eV0220Mapper;
	@Autowired EV0220Service eV0220Service;
	@Autowired private MessageService msg;

	/**
	 * 조회
	 * @param param
	 * @return List<Map<String, Object>>
	 * @throws Exception
	 */
	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception {
		Map<String, Object> paramObj = (Map) param;
		if(EverString.isNotEmpty(param.get("BUYER_CD"))){
			paramObj.put("BUYER_CD_LIST", Arrays.asList(param.get("BUYER_CD").split(",")));
		}
		return eV0240Mapper.doSearch(paramObj);
	}


	/**
	 * 평가상태 확인
	 * @param grid
	 * @return String
	 * @throws Exception
	 */
	public String doCheckCompleteFlag(List<Map<String, Object>> grid) throws Exception{
		UserInfo userInfo = UserInfoManager.getUserInfo();
		String flag = "not";

		for (Map<String, Object> gridData : grid) {

			Map<String, Object> retData = eV0240Mapper.doCheck(gridData);
			String evType = gridData.get("EV_TYPE").toString();

			String result_enter_user_cd = retData.get("RESULT_ENTER_CD").toString();
			String EV_CTRL_USER_ID = EverString.nullToEmptyString(retData.get("EV_CTRL_USER_ID"));

			if(!userInfo.getUserId().equals(EV_CTRL_USER_ID)) {
				if( "EVALUSER".equals(result_enter_user_cd) ) { //평가담당자

					if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
						throw new NoResultException(msg.getMessageByScreenId("EV0240","0001"));
					}

				} else if( "PERUSER".equals(result_enter_user_cd) ) {//평가자

					if (!retData.get("EV_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
						if (!"ESG".equals(evType))
						throw new NoResultException(msg.getMessageByScreenId("EV0240","0002"));
					}

				} else if( "REPUSER".equals(result_enter_user_cd) ) {//대표평가자
					gridData.put("CHK_USER",  UserInfoManager.getUserInfo().getUserId() );
					int repUserCnt = eV0240Mapper.doRepUserCheck(gridData);

					if ( repUserCnt == 0 ) {
						throw new NoResultException(msg.getMessageByScreenId("EV0240","0003"));
					}
				}
			}

			// 평가 진행상태 로직
			String checkProgress = eV0240Mapper.checkProgress(gridData);
			if ( "N".equals(checkProgress) ) {// y면 평가진행중 //n면 평가완료
				throw new NoResultException(msg.getMessageByScreenId("EV0240","0004"));//이미 평가 완료 되었습니다.
			}

			if ( retData.get("COMPLETE_DATE") != null && !EverString.isEmpty(retData.get("COMPLETE_DATE").toString()) ) {
				throw new NoResultException(msg.getMessageByScreenId("EV0240","0005"));//평가가 완료되어 처리할 수 없습니다.
			}



			int all_cnt = eV0240Mapper.checkAllCount(gridData);
			int score_cnt = eV0240Mapper.checkScoreCount(gridData);
			if(all_cnt > 0 && score_cnt == all_cnt){
				flag = "not";
			} else if(all_cnt > 0 && score_cnt != all_cnt && score_cnt > 0){
				flag = "part";
			} else if(all_cnt > 0 && score_cnt == 0){
				flag = "all";
			}
		}//not(평가가아예안됨) part(부분 완료) all(모두완료)
		return flag;
	}

	/**
	 * 평가완료
	 * @param grid
	 * @return String
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doComplete(List<Map<String, Object>> grid) throws Exception {
		String args="";
		for (Map<String, Object> gridData : grid) {
			//모든 협력사 점수 존재시 eveu 통합 완료처리
			eV0240Mapper.doCompleteEveu(gridData);
		}
		updateEves(grid);

		args = msg.getMessage("0001");
		return args;
	}

	/**
	 * 개별완료처리
	 * @param grid
	 * @return String
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doIndivisualComplete(List<Map<String, Object>> grid) throws Exception{
		//  [STOCEVEU]  grid : EV_NUM, EV_CTRL_USER_ID, EV_USER_ID,
		// 해당 평가자 EU중에 점수는 있고 평가가 완료되지 않은 협력사코드 리스트 조회
		String vendorList = " \n";
		for(Map<String, Object>gridData : grid){
			List<Map<String, Object>>euLists = eV0240Mapper.getEuVendor(gridData);
			if(euLists.size() == 0){//평가된 협력업체가 존재하지않습니다.
				throw new NoResultException(msg.getMessageByScreenId("EV0240","0009"));
			}else{
				// 해당평가자가 평가한(점수가 있는) 협력사 EU  PROGRESS_CD = '200'
				for(Map<String, Object>euList : euLists){
					euList.put("EV_NUM", gridData.get("EV_NUM").toString());
					eV0240Mapper.doIndivisualComplete(euList);
					vendorList += euList.get("VENDOR_NM").toString()+"\n";
				}
			}
		}
		updateEves(grid);
		// 평가완료된 협력사 목록 반환
		return vendorList;
	}

	public void updateEves(List<Map<String, Object>>gridDatas)throws Exception{
		String evNum = "";
		for (Map<String, Object> gridData : gridDatas) {

			//Map<String, Object> retData = eV0240Mapper.doCheck(gridData);


//			if(evNum.equals(gridData.get("EV_NUM").toString())) {// 동일 평가번호면 패스
//				continue;
//			} else {
//				evNum = gridData.get("EV_NUM").toString();
//			}

			//EVES update
			//협력사 코드 조회 - VENDOR_CD
			List<Map<String, String>> lists = eV0240Mapper.getVendorCd(gridData);



			//해당 점수 평균 및 ES update
			for(Map<String, String> list : lists){
				gridData.put("VENDOR_CD", list.get("VENDOR_CD"));
				gridData.put("VENDOR_SQ", list.get("VENDOR_SQ"));

				//ES용 ET EE 점수합산
				String euScore = eV0240Mapper.getEuScore(gridData);
				String etScore = eV0240Mapper.getEtScore(gridData);
				if(euScore == null){euScore = "0";}
				if(etScore == null){etScore = "0";}
				BigDecimal sum = new BigDecimal(euScore).add(new BigDecimal(etScore));

				gridData.put("EV_SCORE", sum.toString());

				eV0240Mapper.updateEsScore(gridData);
			}
		}
	}

	/**
	 * 완료취소
	 * @param grid
	 * @return String
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCancel(List<Map<String, Object>> grid) throws Exception {
		String args="";

		for (Map<String, Object> gridData : grid) {

			Map<String, Object> retData = eV0240Mapper.doCheck(gridData);

			String result_enter_user_cd = retData.get("RESULT_ENTER_CD").toString();

			if( "EVALUSER".equals(result_enter_user_cd) ) { //평가담당자

				if (!retData.get("EV_CTRL_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					throw new NoResultException(msg.getMessageByScreenId("EV0240","0001"));
				}

			} else if( "PERUSER".equals(result_enter_user_cd) ) {//평가자

				if (!retData.get("EV_USER_ID").toString().equals(UserInfoManager.getUserInfo().getUserId())) {
					if(!"ESG".equals(gridData.get("EV_TYPE"))) {
						throw new NoResultException(msg.getMessageByScreenId("EV0240","0002"));
					}
				}

			} else if( "REPUSER".equals(result_enter_user_cd) ) {//대표평가자
				gridData.put("CHK_USER",  UserInfoManager.getUserInfo().getUserId() );
				int repUserCnt = eV0240Mapper.doRepUserCheck(gridData);

				if ( repUserCnt == 0 ) {
					throw new NoResultException(msg.getMessageByScreenId("EV0240","0003"));
				}
			}

			if( "0".equals(gridData.get("VENDOR_COMP_CNT").toString())){ // 완료취소할 업체가없습니다.
				throw new NoResultException(msg.getMessageByScreenId("EV0240", "0013"));
			}

			if ( retData.get("COMPLETE_DATE") != null && !EverString.isEmpty(retData.get("COMPLETE_DATE").toString()) ) { //평가가 완료되어 처리할 수 없습니다.
				throw new NoResultException(msg.getMessageByScreenId("EV0240","0005"));
			}

			eV0240Mapper.doCancelEveu(gridData);

		}

		args = msg.getMessage("0001");

		return args;

	}

}
