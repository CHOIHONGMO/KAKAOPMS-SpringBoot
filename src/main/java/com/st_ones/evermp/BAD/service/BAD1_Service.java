package com.st_ones.evermp.BAD.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BAD.BAD1_Mapper;
import com.st_ones.evermp.BS03.BS0302_Mapper;
import com.st_ones.eversrm.master.user.BADU_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;


@Service(value = "bad1_Service")
public class BAD1_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private BAD1_Mapper bad1Mapper;

    @Autowired
    LargeTextService largeTextService;

    @Autowired private QueryGenService queryGenService;

    @Autowired
    private BADU_Mapper baduMapper;

    @Autowired
    private BS0302_Mapper bs0302Mapper;

    /** ******************************************************************************************
     * 고객사 사용자 조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bad1020_doSearch(Map<String, String> param) throws Exception {

    	List<Map<String, Object>>  liskt = bad1Mapper.bad1020_doSearch(param);
        return liskt;
    }

    // 고객사 사용자 등록
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1020_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {

            //회사 관리자여부 변경시 기존 회사관리자 삭제 후 업데이트 >>N명으로변경
//            if(EverString.nullToEmptyString(gridData.get("CHANGE_MNG_YN")).equals("Y")){
//                bs0302Mapper.bs03005_doDeleteMngYn(gridData);
//            }

            bad1Mapper.bad1020_doSave(gridData);
        }
        return msg.getMessage("0031");
    }

    // 고객사 사용자 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1020_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bad1Mapper.bad1020_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ******************************************************************************************
     * 사용자(고객사,협력사) 상세
     * @param req
     * @return
     * @throws Exception
     */
    public Map<String, String> bad1021_doSearch(Map<String, String> param) throws Exception {
        return bad1Mapper.bad1021_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> bad1021_doSave(Map<String, String> formData) throws Exception {
    	Map<String, String> rtnMap = new HashMap<String, String>();
        formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(String.valueOf(formData.get("PASSWORD"))));

        String oriUserId = EverString.nullToEmptyString(formData.get("ORI_USER_ID"));
        if(oriUserId.equals("")) {
            //아이디중복체크
            Map<String, String> params = new HashMap<String, String>();
            String userId = EverString.nullToEmptyString(formData.get("USER_ID"));
            params.put("USER_ID",userId);
            int checkCnt = baduMapper.existsUserInformation_VNGL(params);
            if (checkCnt > 0) {
                throw new NoResultException(msg.getMessage("0155"));
            }
        }

    	bad1Mapper.bad1021_doSave(formData);

        if(oriUserId.equals("")) {
            //사용자처음등록시 프로파일 등록
            formData.put("AUTH_CD","PF0131");
            bad1Mapper.bad1021_doInsertUser_USAP(formData);
        }

    	rtnMap.put("USER_ID", formData.get("USER_ID") );
		rtnMap.put("rtnMsg", msg.getMessage("0031") );

    	return rtnMap;
    }

    //사용자아이디 중복체크
    public String bad1021_doCheckUserId(Map<String, String> param) throws Exception {
        return bad1Mapper.bad1021_doCheckUserId(param);
    }

    /** ******************************************************************************************
     * 예산관리 조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bad1040_doSearch(Map<String, String> param) throws Exception {
        return bad1Mapper.bad1040_doSearch(param);
    }

    // 예산관리저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1040_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {

        	// 이월예산
        	if(EverString.nullToEmptyString(String.valueOf(gridData.get("TRANSFERED_AMT"))).equals("") || EverString.nullToEmptyString(String.valueOf(gridData.get("TRANSFERED_AMT"))).equals("null")) {
        		gridData.put("TRANSFERED_AMT", null);
            } else {
            	gridData.put("TRANSFERED_AMT", Double.parseDouble(String.valueOf(gridData.get("TRANSFERED_AMT"))));
            }
        	// 당해예산
        	if(EverString.nullToEmptyString(String.valueOf(gridData.get("BUDGET_AMT"))).equals("") || EverString.nullToEmptyString(String.valueOf(gridData.get("BUDGET_AMT"))).equals("null")) {
        		gridData.put("BUDGET_AMT", null);
            } else {
            	gridData.put("BUDGET_AMT", Double.parseDouble(String.valueOf(gridData.get("BUDGET_AMT"))));
            }
        	// 추가예산
        	if(EverString.nullToEmptyString(String.valueOf(gridData.get("ADDITIONAL_AMT"))).equals("") || EverString.nullToEmptyString(String.valueOf(gridData.get("ADDITIONAL_AMT"))).equals("null")) {
        		gridData.put("ADDITIONAL_AMT", null);
            } else {
            	gridData.put("ADDITIONAL_AMT", Double.parseDouble(String.valueOf(gridData.get("ADDITIONAL_AMT"))));
            }
            bad1Mapper.bad1040_mergeData(gridData);
        }
        return msg.getMessage("0031");
    }

    //예산관리삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1040_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bad1Mapper.bad1040_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ******************************************************************************************
     * 계정관리 조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bad1050_doSearch(Map<String, String> param) throws Exception {
        return bad1Mapper.bad1050_doSearch(param);
    }

    // 계정관리저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1050_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bad1Mapper.bad1050_mergeData(gridData);
        }
        return msg.getMessage("0031");
    }

    // 계정관리삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1050_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bad1Mapper.bad1050_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }


    /** *****************
     * 품목별계정지정
     * ******************/
    public List<Map<String, Object>> bad1030_doSearch(Map<String, String> param) throws Exception {
        //방법 2 - entrySet() : key / value
    	// by sslee
        for(Entry<String, String> elem : param.entrySet()){
            System.out.println("키 : " + elem.getKey() + "값 : " + elem.getValue());
        }

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "A.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_SPEC"));
            sParam.put("COL_NM", "A.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        UserInfo userInfo = UserInfoManager.getUserInfo();
        String mySiteYn = EverString.nullToEmptyString(userInfo.getBuyerMySiteFlag());
        if(mySiteYn.equals("1")){
            param.put("BUYERCD", PropertiesManager.getString("eversrm.default.cust.code"));
        }else{
            param.put("BUYERCD", userInfo.getManageCd());
        }


        return bad1Mapper.bad1030_doSearch(param);
    }

    //품목별계정저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1030_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bad1Mapper.bad1030_doSave(gridData);
        }
        return msg.getMessage("0031");
    }


    //품목별계정삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bad1030_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            gridData.put("ACCOUNT_CD","");
            bad1Mapper.bad1030_doSave(gridData);
        }
        return msg.getMessage("0031");
    }

	/** ******************************************************************************************
	 * 부서별 실적분석
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> bad2010_doSearch(Map<String, String> param) throws Exception {
		return bad1Mapper.bad2010_doSearch(param);
	}

	/** ******************************************************************************************
	 * 주문번호별 실적분석
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> bad2020_doSearch(Map<String, String> param) throws Exception {
		return bad1Mapper.bad2020_doSearch(param);
	}

	/** ******************************************************************************************
	 * 품목별 실적분석
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> bad2030_doSearch(Map<String, String> param) throws Exception {
		return bad1Mapper.bad2030_doSearch(param);
	}

	/** *****************
     * 관리자 > 배송지 현황
     * ******************/
	public List<Map<String, Object>> bad1070_doSearchD(Map<String, String> param) {
		return bad1Mapper.bad1070_doSearchD(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bad1070_doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {
            if("".equals(gridData.get("SEQ"))  || null == gridData.get("SEQ")) {
            	bad1Mapper.insertStocCsdm(gridData);
            } else {
            	bad1Mapper.updateStocCsdm(gridData);
            }
        }

		return msg.getMessageByScreenId("BAD1_070", "003");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bad1070_doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			bad1Mapper.bad1070_doDeleteDT(gridData);
		}

		return msg.getMessage("0017");
	}

	/** *****************
     * 관리자 > 청구지 현황
     * ******************/
	public List<Map<String, Object>> bad1080_doSearchD(Map<String, String> param) {
		return bad1Mapper.bad1080_doSearchD(param);
	}

}
