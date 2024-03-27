package com.st_ones.evermp.SY01.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.SY01.SY0101_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;


@Service(value = "sy01_Service")
public class SY0101_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private SY0101_Mapper sy0101Mapper;

    @Autowired
    LargeTextService largeTextService;

    /** ******************************************************************************************
     * 조직정보
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> sy01001_doSearch(Map<String, String> param) throws Exception {
        return sy0101Mapper.sy01001_doSearch(param);
    }
    public List<Map<String, Object>> sy01001_doSearch_parent(Map<String, String> param) throws Exception {
        return sy0101Mapper.sy01001_doSearch_parent(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sy01001_doSave(Map<String, String> formData, List<Map<String, Object>> gridList) throws Exception {

        int checkCnt =0;
        for(Map<String, Object> gridData : gridList) {
            //부서코드 중복체크
            gridData.put("CUST_CD",formData.get("CUST_CD"));
            gridData.put("PLANT_CD",formData.get("PLANT_CD"));

            if(gridData.get("HIDDEN_DEPT_CD") != null) {
            	continue;
            }


            checkCnt = sy0101Mapper.existsOPDP(gridData);
            if (checkCnt > 0) {
                return "이미 등록된 코드가 존재합니다.";
            }
        }

        for(Map<String, Object> gridData : gridList) {

            gridData.put("CUST_CD",formData.get("CUST_CD"));

            gridData.put("PLANT_CD",formData.get("PLANT_CD"));

            gridData.put("DEPT_TYPE", formData.get("DEPT_TYPE_RADIO"));
            gridData.put("LVL", formData.get("LVL"));
            gridData.put("DIVISION_YN", formData.get("DIVISION_YN"));

            sy0101Mapper.sy01001_mergeData(gridData);
        }
        //if(1==1) throw new Exception("============================");
        return msg.getMessage("0031");
    }

    public List<Map<String, Object>> sy01001_doSelect_DP(Map<String, String> param) throws Exception {
        return sy0101Mapper.sy01001_doSelect_DP(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sy01001_doSave_DP(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception{
        for(Map<String,Object> grid : gridData) {
            grid.put("DEPT_CD", formData.get("DEPT_CD"));

            sy0101Mapper.sy01001_doSave_DP(grid);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sy01001_doDelete_DP(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {
            sy0101Mapper.sy01001_doDelete_DP(gridData);
        }
        return msg.getMessage("0017");
    }

    //조직 -트리검색
    public List<Map<String, Object>> sy01001_doSelect_deptTree(Map<String, String> param) throws Exception {

    	/**2022.09.01 HMCHOI 제외
        List<Map<String, Object>> returnList = new ArrayList<Map<String, Object>>();
        List<Map<String, Object>> returnList = sy0101Mapper.sy01001_doSelect_deptTree(param);
        for (Map<String, Object> data : resultList) {
            String userNm =  EverString.nullToEmptyString(data.get("TEAM_LEADER_USER_NM"));
            if(!userNm.equals("")){
                data.put("TEAM_LEADER_USER_NM",userNm.substring(0,1)+"*"+userNm.substring(2,userNm.length()));
            }
            returnList.add(data);
        }*/
        return sy0101Mapper.sy01001_doSelect_deptTree(param);
    }

    //팀검색 tree조회
    public List<Map<String, Object>> sy01003_doSelect_deptTree(Map<String, String> param) throws Exception {
        return sy0101Mapper.sy01001_doSelect_deptTree(param);
    }

    //조직저장 - 트리저장
    //메뉴-직무/사용자 권한등록
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sy01001_doSave_tree(Map<String, String> formData, List<Map<String, Object>> grid) throws Exception {
        for(Map<String, Object> rowData : grid) {
            rowData.put("CUST_CD",formData.get("CUST_CD"));
            sy0101Mapper.sy0101_updateDEPTData(rowData);
        }

        /*
        for(Map<String, Object> Lv1 : deptGrid) {
            Lv1.put("CUST_CD",formData.get("CUST_CD"));
            //트리인 경우 해당 단계별 items의 값의 구조로 가져오기때문에 5LVEL까지 돌면서 저장해야한다.
            if(Lv1.get("items")!=""){
                List<Map<String, Object>> menuGridLv2 = (List<Map<String, Object>>) Lv1.get("items");
                for (Map<String, Object> Lv2 : menuGridLv2) {
                    Lv2.put("CUST_CD",formData.get("CUST_CD"));

                    //팀장대결자가 선택되거나 재무코드가 클릭으로 인하여 바뀐경우 체크YN값을 준다. 해당 수정된 부서만 업데이트.. 아래 레벨도 마찬가지임.
                    if(EverString.nullToEmptyString(Lv2.get("checkYN")).equals("Y")){
                        sy0101Mapper.sy0101_updateDEPTData(Lv2);
                    }

                    if(Lv2.get("items")!=""){
                        List<Map<String, Object>> menuGridLv3 = (List<Map<String, Object>>) Lv2.get("items");
                        for (Map<String, Object> Lv3 : menuGridLv3) {
                            Lv3.put("CUST_CD",formData.get("CUST_CD"));
                            if(EverString.nullToEmptyString(Lv3.get("checkYN")).equals("Y")){
                                sy0101Mapper.sy0101_updateDEPTData(Lv3);
                            }

                            if(Lv3.get("items")!=""){
                                List<Map<String, Object>> menuGridLv4 = (List<Map<String, Object>>) Lv3.get("items");
                                for (Map<String, Object> Lv4 : menuGridLv4) {
                                    Lv4.put("CUST_CD",formData.get("CUST_CD"));
                                    if(EverString.nullToEmptyString(Lv4.get("checkYN")).equals("Y")){
                                        sy0101Mapper.sy0101_updateDEPTData(Lv4);
                                    }

                                    if(Lv4.get("items")!=""){
                                        List<Map<String, Object>> menuGridLv5 = (List<Map<String, Object>>) Lv4.get("items");
                                        for (Map<String, Object> Lv5 : menuGridLv5) {
                                            Lv5.put("CUST_CD",formData.get("CUST_CD"));
                                            if(EverString.nullToEmptyString(Lv5.get("checkYN")).equals("Y")){
                                                sy0101Mapper.sy0101_updateDEPTData(Lv5);
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }
        */
        return msg.getMessage("0031");
    }
	public List<Map<String, Object>> sy01004_doSelect_deptTree(Map<String, String> formTree) {
		// TODO Auto-generated method stub
		return sy0101Mapper.sy01002_doSelect_deptTree(formTree);
	}
	 @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
		public List<Map<String, Object>> findPlant(Map<String, String> formData) throws Exception {
	    	return sy0101Mapper.findPlant(formData);
		}
}
