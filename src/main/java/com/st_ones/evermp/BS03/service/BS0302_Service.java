package com.st_ones.evermp.BS03.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS03.BS0302_Mapper;
import com.st_ones.eversrm.master.user.BADU_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "bs0302_Service")
public class BS0302_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private BS0302_Mapper bs0302Mapper;

    @Autowired
    LargeTextService largeTextService;

    @Autowired
    private BADU_Mapper baduMapper;


    /** ******************************************************************************************
     * 승인조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs03004_doSearch(Map<String, String> param) throws Exception {
        return bs0302Mapper.bs03004_doSearch(param);
    }

    /** ******************************************************************************************
     * 사용자 조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs03005_doSearch(Map<String, String> param) throws Exception {
        return bs0302Mapper.bs03005_doSearch(param);
    }

    //사용자수정_그리드
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs03005_doUpdate(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {

            //회사 관리자여부 변경시 기존 회사관리자 삭제 후 업데이트 >> 관리자 N명으로 변경
//            if(EverString.nullToEmptyString(gridData.get("CHANGE_MNG_YN")).equals("Y")){
//                bs0302Mapper.bs03005_doDeleteMngYn(gridData);
//            }

            bs0302Mapper.bs03005_doUpdate(gridData);
        }
        return msg.getMessage("0031");
    }


    //사용자삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs03005_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bs0302Mapper.bs03005_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ******************************************************************************************
     * 사용자(고객사,협력사) 상세
     * @param req
     * @return
     * @throws Exception
     */
    public Map<String, String> bs03005_doSearchInfo(Map<String, String> param) throws Exception {

        Map<String, String> rtnMap = bs0302Mapper.bs03005_doSearchInfo(param);
        return rtnMap;
    }

    //사용자수정.
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs03006_doSave(Map<String, String> formData) throws Exception {

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

            String userType = EverString.nullToEmptyString(formData.get("USER_TYPE"));

        //해당 회사코드에 관리자여부가 있으면 중복체크  >> 관리자N명으로변경
//        String mngYn = EverString.nullToEmptyString(formData.get("MNG_YN"));
//        int checkCnt = 0;
//        if(mngYn.equals("1")) {
//            Map<String, String> params2 = new HashMap<String, String>();
//            params2.put("COMPANY_CD",EverString.nullToEmptyString(formData.get("COMPANY_CD")));
//            params2.put("USER_ID",EverString.nullToEmptyString(formData.get("USER_ID")));
//
//            if(userType.equals("S")){
//                checkCnt = baduMapper.existsMYNUser_VNGL(params2);
//            }else{
//                checkCnt = baduMapper.existsMYNUser_CUST(params2);
//            }
//            if (checkCnt > 0) {
//                throw new NoResultException(msg.getMessage("0173"));
//            }
//        }


       //사용자등록.수정
        bs0302Mapper.bs03006_doSave(formData);

        //고객사일때 처음등록시 배송지정보 저장
        if(userType.equals("B")){
            if(oriUserId.equals("")) {
                //bs0302Mapper.bs03006_doSave_custDM(formData);
            }
        }

        if(oriUserId.equals("")) {
            //사용자처음등록시 프로파일 등록
            if(EverString.nullToEmptyString(formData.get("USER_TYPE")).equals("B")){
                formData.put("AUTH_CD","PF0131");
            }else if(EverString.nullToEmptyString(formData.get("USER_TYPE")).equals("S")){
                formData.put("AUTH_CD","PF0132");
            }else{
                formData.put("AUTH_CD","");
            }
            bs0302Mapper.bs03006_doInsertUser_USAP(formData);
        }

        return msg.getMessage("0031");
    }

    //사용자아이디 중복체크
    public String bs01002_doCheckUserId(Map<String, String> param) throws Exception {
        return bs0302Mapper.bs01002_doCheckUserId(param);
    }

    public String bs01002_doCheckIrsNo(Map<String, String> param) throws Exception {
        return bs0302Mapper.bs01002_doCheckIrsNo(param);
    }




}
