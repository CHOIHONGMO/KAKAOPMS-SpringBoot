package com.st_ones.eversrm.eApproval.eApprovalBox.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.ApprovalException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.eApproval.eApprovalBox.BAPP_Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
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
 * @File Name : BAPP_Service.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Service(value = "bapp_Service")
public class BAPP_Service extends BaseService {

	@Autowired
	BAPP_Mapper bapp_Mapper;

	@Autowired
	BAPM_Service bapm_Service;

	public List<Map<String, Object>> searchMailBox(Map<String, String> param) throws Exception {
		return bapp_Mapper.searchMailBox(param);
	}

	public List<Map<String, Object>> getSendBoxList(Map<String, String> param) throws Exception {
		return bapp_Mapper.getSendBoxList(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCancelRFA(Map<String, Object> gridDatas) throws Exception {

		Map<String, String> data = new HashMap<String, String>();

		for (Map.Entry<String, Object> entry : gridDatas.entrySet()) {
			data.put(entry.getKey(), entry.getValue().toString());
		}

		return bapm_Service.cancelApprovalProcess(data);
	}

	public Map<String, String> selectPreviousInfoForm(Map<String, String> approvalInfoKey) throws Exception {

		Map<String, String> selectSTOCSCTM = bapp_Mapper.selectSTOCSCTM(approvalInfoKey);
		if (selectSTOCSCTM == null) {
			return null;
		}

		String appDocCnt = bapp_Mapper.getCurrentDocCount(approvalInfoKey);
		approvalInfoKey.put("APP_DOC_CNT", appDocCnt);
		if (!isAuthorized(approvalInfoKey)) {
			throw new ApprovalException("Un Authorized Access");
		}
		return selectSTOCSCTM;
	}

	public List<Map<String, Object>> selectPreviousInfoGrid(Map<String, String> approvalInfoKey) throws Exception {
		String appDocCnt = bapp_Mapper.getCurrentDocCount(approvalInfoKey);
		approvalInfoKey.put("APP_DOC_CNT", appDocCnt);
		return bapp_Mapper.selectSTOCSCTP(approvalInfoKey);
	}

	public List<Map<String, Object>> selectLULP(HashMap<String, String> approvalPathKey) {
		return bapp_Mapper.selectLULP(approvalPathKey);
	}

	public String getMatchUserInfoByName(String userNm) throws ApprovalException, IOException {
		int count = matchUserCountByName(userNm);

		if (count != 1) {
			if (count > 1) {
				ApprovalException e = new ApprovalException("More Than 1 Result");
				e.setSelectedUserCount(count);
				throw e;
			}
			ApprovalException e = new ApprovalException("No Result");
			e.setSelectedUserCount(count);
			throw e;
		}

		Map<String, String> userInfo = getUserInfoByName(userNm);
		return new ObjectMapper().writeValueAsString(userInfo);
	}

	public boolean isAuthorized(Map<String, String> approvalInfoKey) throws Exception {
		int authorizedUserCount = bapp_Mapper.getAuthorizedCount(approvalInfoKey);
        return authorizedUserCount > 0;
    }

	private int matchUserCountByName(String userNm) {
		HashMap<String, String> hashMap = new HashMap<String, String>();
		hashMap.put("USER_NM", userNm);

		return bapp_Mapper.matchUserCountByName(hashMap);
	}

	private Map<String, String> getUserInfoByName(String userNm) {
		HashMap<String, String> hashMap = new HashMap<String, String>();
		hashMap.put("USER_NM", userNm);
		return bapp_Mapper.getUserInfoByName(hashMap);
	}

	// BAPP_550
	public List<Map<String, Object>> userSearch(Map<String, String> param) throws Exception {
		return bapp_Mapper.userSearch(param);
	}

	public List<Map<String, Object>> doSearchDecideArbitrarily(Map<String, Object> param) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		String inCustCd = PropertiesManager.getString("eversrm.default.inCustCd");
		String custCd = userInfo.getCompanyCd();

		// DB에서 가져온 결재자/합의자/참조자 List
		List<Map<String, Object>> rtnList = new ArrayList<Map<String, Object>>();

		// view에서 전결규정을 array로 입력할 경우 콤마 단위로 달라 쓸수 있어 콤마로 split처리 하여 loop 돌림
		// 전결규정의 우선순위는 array의 순서의 오름차순으로 적용됨
		String bizClsArr1[] = String.valueOf(param.get("BIZ_CLS1")).split(",", -1);
		String bizClsArr2[] = String.valueOf(param.get("BIZ_CLS2")).split(",", -1);
		String bizClsArr3[] = String.valueOf(param.get("BIZ_CLS3")).split(",", -1);

		int rowIdx = 0;
		for(int i = 0, arrCnt = bizClsArr1.length; i < arrCnt; i++) {

			param.put("BIZ_CLS1", bizClsArr1[i]);
			param.put("BIZ_CLS2", bizClsArr2[i]);
			param.put("BIZ_CLS3", bizClsArr3[i]);
			param.put("CUST_CD", custCd);
			param.put("BIZ_AMT", param.get("BIZ_AMT"));

			// Parameter로 전달받은 해당 문서의 전결규정에 대한 결재, 합의라인 코드를 가져온다.
			Map<String, String> lineData = bapp_Mapper.getAppLineCd(param);
			if (lineData != null) {
				String bizCls1 = bizClsArr1[i];
				String bizCls2 = bizClsArr2[i];
				String bizCls3 = bizClsArr3[i];
				String bizSeq = String.valueOf(lineData.get("BIZ_SEQ"));
				String appLineCd = lineData.get("APP_LINE");
				String agrLineCd = lineData.get("AGR_LINE");
				// 조회된 결재, 합의라인 코드의 결재자/합의자/참조자들을 가져온다.
				List<Map<String, Object>> tmpList = setAppLines(inCustCd, custCd, bizCls1, bizCls2, bizCls3, bizSeq, appLineCd, agrLineCd, param);
				for(int t = 0; t < tmpList.size(); t++) {
					rtnList.add(rowIdx, tmpList.get(t));
					rowIdx++;
				}
			}				
		}

		// LVL를 기준으로 부서장 -> 전결라인의 결재자 -> 합의자 -> 참조자 순으로 순서를 바꾼다.
		Collections.sort(rtnList, new Comparator<Map<String, Object>>() {
			@Override
			public int compare(Map<String, Object> first, Map<String, Object> second) {
			Double firstVal = Double.parseDouble(String.valueOf(first.get("LVL")));
			Double secondVal = Double.parseDouble(String.valueOf(second.get("LVL")));
			return secondVal.compareTo(firstVal);
			}
		});

		// 중첩된 결재자를 제외시킨 후, 최종 결재자/합의자/참조자 List를 Return 한다.
		int idxTrans = 0;
		List<Map<String, Object>> transList = new ArrayList<Map<String, Object>>();
		if(rtnList.size() > 0) {
			for(int t = 0; t < rtnList.size(); t++) {
				Map<String, Object> rtnMapO = rtnList.get(t);
				int sameCnt = 0;
				for(int p = 0; p < transList.size(); p++) {
					Map<String, Object> rtnMapL = transList.get(p);
					if(String.valueOf(rtnMapO.get("SIGN_USER_ID")).equals(String.valueOf(rtnMapL.get("SIGN_USER_ID")))) {
						sameCnt++;
					}
				}
				if(sameCnt == 0) {
					transList.add(idxTrans, rtnMapO);
					idxTrans++;
				}
			}
		}

		// 등록된 전결규칙이 없으면, 나의 결재경로를 가져온다.
		// 단, 주결재경로가 1개인 경우에만 Default로 나의 결재경로를 보여준다.
		if(transList.size() == 0) {
			List<Map<String, String>> myPathList = bapp_Mapper.getMyPath(new HashMap<String, String>());
			if (myPathList.size() == 1) {
				Map<String, String> pParam = myPathList.get(0);
//				transList = bapp_Mapper.getMyPathList(pParam);
			}
		}

		return transList;
	}

	public List<Map<String, Object>> setAppLines(String inCustCd, String custCd, String bizCls1, String bizCls2, String bizCls3, String bizSeq, String appLineCd, String agrLineCd, Map<String, Object> sParam) throws Exception {

		String reqUserId = (String)sParam.get("REQ_USER_ID");
		String chiefIncludeFlag = ""; // 팀장(부서장) 포함여부

		System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		System.out.println(">>>>>>>>>>>>> appLineCd : " + appLineCd);
		System.out.println(">>>>>>>>>>>>> agrLineCd : " + agrLineCd);
		System.out.println(">>>>>>>>>>>>> bizCls1 : " + bizCls1);
		System.out.println(">>>>>>>>>>>>> bizCls2 : " + bizCls2);
		System.out.println(">>>>>>>>>>>>> bizCls3 : " + bizCls3);
		System.out.println(">>>>>>>>>>>>> bizSeq : " + bizSeq);
		System.out.println(">>>>>>>>>>>>> inCustCd : " + inCustCd);
		System.out.println(">>>>>>>>>>>>> custCd : " + custCd);
		System.out.println(">>>>>>>>>>>>> reqUserId : " + reqUserId);
		System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

		/*	01	대표이사		02	팀장/대표이사		03	팀장

		custCd = session's CompanyCd

		[ 전결 ]
		전결라인은 STOCDMUR.DML_TYPE = 'APP'의 값을 순서대로 return 한다.
		데이터가 없는(미등록) 경우에는 null을 return하여 행추가 후, 상신하도록 한다.

		[ 합의 ]
		합의라인은 STOCDMUR.DML_TYPE = 'AGR'의 값을 순서대로 return 한다.
		그 이외의 경우에는 null을 return하여 행추가 후, 상신하도록 한다.

		[ 참조 ]
		참조라인은 STOCDMUR.DML_TYPE = 'REF'의 값을 순서대로 return 한다.
		그 이외의 경우에는 null을 return하여 행추가 후, 상신하도록 한다. */

		int addIdx = 0;
		List<Map<String, Object>> rtnLines = new ArrayList<Map<String, Object>>();

		// 합의/참조라인에 '팀장'이 포함된 경우(STOCDMLC.CHIEF_INCLUDE_FLAG = '1'), 팀장정보를 포함시킨다.
		Map<String, String> param = new HashMap<String, String>();
		param.put("CUST_CD", custCd);
		param.put("LINE_CD", agrLineCd);
		param.put("DML_TYPE", "AGR");
		chiefIncludeFlag = bapp_Mapper.getChiefIncludeFlag(param);

		// 합의/참조라인에 대한 결재자를 가져온다.
		Map<String, Object> aParam = new HashMap<String, Object>();
		aParam.put("CUST_CD", custCd);
		aParam.put("LINE_CD", agrLineCd);
		aParam.put("REF_LINE_CD", bizCls1 + bizCls2 + bizCls3 + bizSeq);
		aParam.put("REF_BIZ_AMT", sParam.get("BIZ_AMT"));
		aParam.put("DML_TYPE", "AGR");
		aParam.put("chiefIncludeFlag", chiefIncludeFlag);

		List<Map<String, Object>> agrLine = bapp_Mapper.getAgrLines(aParam);
		if (agrLine.size() > 0) {
			for (Map<String, Object> agrData : agrLine) {
				Map<String, Object> tmpMap = new HashMap<String, Object>();
				tmpMap.put("DOC_SQ", "");
				tmpMap.put("SIGN_REQ_TYPE", agrData.get("SIGN_REQ_TYPE"));
				tmpMap.put("SIGN_PATH_SQ", addIdx + 1);
				tmpMap.put("SIGN_USER_ID", agrData.get("SIGN_USER_ID"));
				tmpMap.put("SIGN_USER_NM", agrData.get("SIGN_USER_NM"));
				tmpMap.put("SIGN_USER_NM_$TP", agrData.get("SIGN_USER_NM"));
				tmpMap.put("SIGN_USER_NM_IMG", agrData.get("SIGN_USER_NM_IMG"));
				tmpMap.put("POSITION_NM", agrData.get("POSITION_NM"));
				tmpMap.put("COMPANY_NM", agrData.get("COMPANY_NM"));
				tmpMap.put("DEPT_NM", agrData.get("DEPT_NM"));
				tmpMap.put("DEPT_CD", agrData.get("DEPT_CD"));
				tmpMap.put("DUTY_NM", agrData.get("DUTY_NM"));
				tmpMap.put("CHECK_FLAG", "");
				tmpMap.put("LVL", agrData.get("SIGN_REQ_TYPE").equals("CC") ? "1" : "2"); // 2 : 합의자, 1 : 참조자
				tmpMap.put("DECIDE_FLAG", "Y"); // 화면에서 삭제할 수 없도록 하는 Flag 값.
				rtnLines.add(addIdx, tmpMap);
				addIdx++;
			}
		}

		// 결재라인에 '팀장'이 포함된 경우(STOCDMLC.CHIEF_INCLUDE_FLAG = '1'), 팀장정보를 포함시킨다.
		param.put("LINE_CD", appLineCd);
		param.put("DML_TYPE", "APP");
		param.put("REG_USER_ID", reqUserId);
		chiefIncludeFlag = bapp_Mapper.getChiefIncludeFlag(param);
		param.put("REG_USER_ID", reqUserId);

		// 결재라인에 대한 결재자를 가져온다.
		List<Map<String, Object>> tmpLines = new ArrayList<Map<String, Object>>();
        if(chiefIncludeFlag.equals("1")) {
			tmpLines = bapp_Mapper.getAppLinesWithChief(param);
		}
		else {
			tmpLines = bapp_Mapper.getAppLines(param);
		}

		if(tmpLines.size() > 0) {
			for(int t = 0; t < tmpLines.size(); t++) {
				Map<String, Object> tmpMap = tmpLines.get(t);
				tmpMap.put("SIGN_PATH_SQ", addIdx + 1);
				tmpMap.put("CHECK_FLAG", "");
				tmpMap.put("LVL", "3"); // 3 : 전결라인에 있는 결재자
				tmpMap.put("DECIDE_FLAG", "Y"); // 화면에서 삭제할 수 없도록 하는 Flag 값.
				rtnLines.add(addIdx, tmpMap);
				addIdx++;
			}
		}
		return rtnLines;
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	public List<Map<String, Object>> doSearchSync(Map<String, Object> param) throws Exception {
		
		String user_ids = (String)param.get("USER_IDS");
		
		// 9#20130717#1,9#20130815#2,
		StringTokenizer st = new StringTokenizer(user_ids,",");
		ArrayList al = new ArrayList();
		int kk = 1;
		while(st.hasMoreElements())  {
			Map<String,String> map = new HashMap<String,String>();
			
			String kkk = st.nextToken();
			StringTokenizer dataA = new StringTokenizer(kkk,"#");
			map.put("SIGN_TYPE", dataA.nextToken());
			map.put("USER_ID", dataA.nextToken());
			map.put("SIGN_PATH_SQ", String.valueOf(kk++));
			
			getLog().error("SING_TYPE ---> " + map.get("SIGN_TYPE"));
			getLog().error("USER_ID ---> " + map.get("USER_ID"));
			getLog().error("SIGN_PATH_SQ ---> " + map.get("SIGN_PATH_SQ"));
			
			al.add(map);
		}
		param.put("list", al);
		
		return bapp_Mapper.doSearchSync(param);
	}
	
	
	public List<Map<String, Object>> getSendReceiveBoxList(Map<String, String> param) throws Exception {
		
		UserInfo userInfo = UserInfoManager.getUserInfo();
		param.put("superUserFlag", userInfo.getSuperUserFlag());
		
		return bapp_Mapper.getSendReceiveBoxList(param);
	}

	public List<Map<String, Object>> getSendReceiveBoxListA(Map<String, String> param) throws Exception {
		return bapp_Mapper.getSendReceiveBoxListA(param);
	}
}
