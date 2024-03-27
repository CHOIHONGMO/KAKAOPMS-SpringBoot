package com.st_ones.evermp.BS01.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 07 kkj
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS01.BS0102_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "bs0102_Service")
public class BS0102_Service extends BaseService {

    @Autowired private DocNumService docNumService;

    @Autowired private MessageService msg;

    @Autowired private BS0102_Mapper bs0102Mapper;

    /** ******************************************************************************************
     * 전결현황
     * @param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs01010_doSearch(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01010_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01010_doSave(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01010_doSave(gridData);
        }
        return msg.getMessage("0031");
    }

    public List<Map<String, Object>> bs01010_doSearchLineCd(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01010_doSearchLineCd(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01010_doSaveLine(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01010_doSaveLine(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01010_doDelLine(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01010_doDelLine(gridData);
        }
        return msg.getMessage("0017");
    }

    public List<Map<String, Object>> bs01010_doSearchAppAgr(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01010_doSearchAppAgr(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveAppAgr(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            gridData.put("DML_TYPE", formData.get("DML_TYPE"));
            gridData.put("LINE_CD", formData.get("LINE_CD"));
            bs0102Mapper.doSaveAppAgr(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01010_doDelAppAgr(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01010_doDelAppAgr(gridData);
        }
        return msg.getMessage("0017");
    }

    public List<Map<String, Object>> bs01010_doSearchUR3(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01010_doSearchUR3(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01010_doSaveREF(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01010_doSaveREF(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01010_doDelRef(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01010_doDelRef(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ******************************************************************************************
     * 합의 / 참조자 매핑
     * @param
     * @return
     * @throws Exception
     */

    public List<Map<String, Object>> bs01011_doSearch(Map<String, String> formData) {

        List<Map<String, Object>> rtnList = bs0102Mapper.bs01011_doSearch(formData);
        if(EverString.nullToEmptyString(formData.get("gridType")).equals("R")) {
            if(rtnList.size() > 0) {
                for(Map<String, Object> rtnData : rtnList) {
                    String refCd = EverString.nullToEmptyString(rtnData.get("REF_CD"));
                    rtnData.put("REF_CD", (refCd.length() >= 2 ? refCd.substring(0, 2) : ""));
                    rtnData.put("REF_CD2", (refCd.length() >= 4 ? refCd.substring(2, 4) : ""));
                    rtnData.put("REF_CD3", (refCd.length() >= 6 ? refCd.substring(4, 6) : ""));
                }
            }
        }
        return rtnList;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs01011_doSave(List<Map<String, Object>> gridData) {
        for (Map<String, Object> gridDatum : gridData) {
            String refCd1 = EverString.nullToEmptyString(gridDatum.get("REF_CD"));
            String refCd2 = EverString.nullToEmptyString(gridDatum.get("REF_CD2"));
            String refCd3 = EverString.nullToEmptyString(gridDatum.get("REF_CD3"));
            gridDatum.put("REF_CD", refCd1 + refCd2 + refCd3);
            bs0102Mapper.bs01011_doSave(gridDatum);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs01011_doDelete(List<Map<String, Object>> gridData) {
        for (Map<String, Object> gridDatum : gridData) {
            String refCd1 = EverString.nullToEmptyString(gridDatum.get("REF_CD"));
            String refCd2 = EverString.nullToEmptyString(gridDatum.get("REF_CD2"));
            String refCd3 = EverString.nullToEmptyString(gridDatum.get("REF_CD3"));
            gridDatum.put("REF_CD", refCd1 + refCd2 + refCd3);
            bs0102Mapper.bs01011_doDelete(gridDatum);
        }
    }

    /** *****************
     * 운영사 > 관리그룹
     * ******************/
    public List<Map<String, Object>> bs01020_doSearch(Map<String, String> param) {
        return bs0102Mapper.bs01020_doSearch(param);
    }

    public List<Map<String, Object>> bs01020_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01020_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01020_doSave(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            if("".equals(gridData.get("MG_CD"))  || null == gridData.get("MG_CD")) {
                String MG_CD = docNumService.getDocNumber("BMG");

                gridData.put("MG_CD", MG_CD);
            }

            bs0102Mapper.bs01020_doSave(gridData);
        }

        return msg.getMessage("0200");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01020_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01020_doDelete(gridData);
        }

        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01020_doSaveCust(List<Map<String, Object>> gridDatas) throws Exception {

        int checkCnt =0;
        for(Map<String, Object> gridData : gridDatas) {
            //고객사코드 중복체크
            checkCnt = bs0102Mapper.existsMNGD(gridData);
            if (checkCnt > 0) {
                return msg.getMessage("0201");
            }
        }

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01020_doSaveCust(gridData);
        }

        //return msg.getMessageByScreenId("BS01_020", "002");
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01020_doDeleteCust(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01020_doDeleteCust(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 결재그룹
     * ******************/
    public List<Map<String, Object>> bs01021_doSearch(Map<String, String> param) {
        return bs0102Mapper.bs01021_doSearch(param);
    }

    public List<Map<String, Object>> bs01021_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01021_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01021_doSave(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            if("".equals(gridData.get("APG_CD"))  || null == gridData.get("APG_CD")) {
                String APG_CD = docNumService.getDocNumber("APG");

                gridData.put("APG_CD", APG_CD);
            }

            bs0102Mapper.bs01021_doSave(gridData);
        }

        return msg.getMessage("0202");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01021_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01021_doDelete(gridData);
        }

        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01021_doSaveCust(List<Map<String, Object>> gridDatas) throws Exception {

        int checkCnt =0;
        for(Map<String, Object> gridData : gridDatas) {
            //고객사코드 중복체크
            checkCnt = bs0102Mapper.existsAPGD(gridData);
            if (checkCnt > 0) {
                return msg.getMessage("0203");
            }
        }

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01021_doSaveCust(gridData);
        }

        //return msg.getMessageByScreenId("BS01_020", "002");
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01021_doDeleteCust(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01021_doDeleteCust(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 고객사별 코스트센터
     * ******************/
    public List<Map<String, Object>> bs01030_doSearch(Map<String, String> param) {
        return bs0102Mapper.bs01030_doSearch(param);
    }

    public List<Map<String, Object>> bs01030_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01030_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01030_doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {

        int checkCnt =0;
        for(Map<String, Object> gridData : gridDatas) {
            //코스트센터 중복체크
            checkCnt = bs0102Mapper.existsCOST(gridData);
            if (checkCnt == 0) {
                bs0102Mapper.insertStouCost(gridData);
            } else {
                bs0102Mapper.updateStouCost(gridData);
            }
        }

        return msg.getMessageByScreenId("BS01_030", "003");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01030_doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01030_doDeleteDT(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 고객사별 플랜트관리
     * ******************/
    public List<Map<String, Object>> bs01040_doSearch(Map<String, String> param) {

    	param.put("CUST_CD",param.get("CUST_CD_L"));
    	param.put("CUST_NM",param.get("CUST_NM_L"));


        return bs0102Mapper.bs01040_doSearch(param);
    }

    public List<Map<String, Object>> bs01040_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01040_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String,Object> bs01040_doSearchPlant(Map<String,String> param){
        return bs0102Mapper.bs01040_doSearchPlant(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs01040_doSaveCUPLAndCUBL(Map<String,String> formData) throws Exception{
        String plantCd = formData.get("PLANT_CD");
        if(plantCd == null || plantCd.equals("")){
            String maxPlantCd = bs0102Mapper.bs01040_getPrevPlantCd(formData);
            String nextPlantCd = String.format("%03d",Integer.valueOf(maxPlantCd) + 1);
            formData.put("PLANT_CD", nextPlantCd);
        }

        if(formData.get("CUBL_SQ").equals("")){
            formData.put("CUBL_SQ",null);
        }
        bs0102Mapper.bs01040_doSaveCUPL(formData);
        bs0102Mapper.bs01040_doSaveCUBL(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs01040_doDeletePlantAndAcc(Map<String,String> formData) throws Exception {
        bs0102Mapper.bs01040_doDeleteCUPL(formData);
        bs0102Mapper.bs01040_doDeleteCUBL(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01040_doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {

        int checkCnt =0;
        for(Map<String, Object> gridData : gridDatas) {
            //코스트센터 중복체크
            checkCnt = bs0102Mapper.existsCUPL(gridData);
            if (checkCnt == 0) {
                bs0102Mapper.insertStocCupl(gridData);
            } else {
                bs0102Mapper.updateStocCupl(gridData);
            }
        }

        return msg.getMessageByScreenId("BS01_040", "003");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01040_doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01040_doDeleteDT(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 고객사별 배송지관리
     * ******************/
    public List<Map<String, Object>> bs01050_doSearch(Map<String, String> param) {
        return bs0102Mapper.bs01050_doSearch(param);
    }
    public List<Map<String, Object>> bs01050_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01050_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01050_doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {
        for(Map<String, Object> gridData : gridDatas) {
            if("".equals(gridData.get("SEQ")) || null == gridData.get("SEQ")) {
                bs0102Mapper.insertStocCsdm(gridData);
            } else {
                bs0102Mapper.updateStocCsdm(gridData);
            }
        }

        return msg.getMessageByScreenId("BS01_050", "003");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01050_doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
//            bs0102Mapper.bs01050_doDeleteDT(gridData);
            bs0102Mapper.bs01050_doDeleteCSDM(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 고객사별 청구지관리
     * ******************/
    public List<Map<String, Object>> bs01060_doSearch(Map<String, String> param) {
        return bs0102Mapper.bs01060_doSearch(param);
    }
    public List<Map<String, Object>> bs01060_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01060_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01060_doSaveDT(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {
            if("".equals(gridData.get("CUBL_SQ"))  || null == gridData.get("CUBL_SQ")) {
                bs0102Mapper.insertStocCubl(gridData);
            } else {
                bs0102Mapper.updateStocCubl(gridData);
            }
        }

        return msg.getMessageByScreenId("BS01_060", "003");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01060_doDeleteDT(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
//            bs0102Mapper.bs01060_doDeleteDT(gridData);
            bs0102Mapper.bs01060_doDeleteCUBL(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 그룹관리자매핑
     * ******************/
    public List<Map<String, Object>> bs01022_doSearch(Map<String, String> param) {
        return bs0102Mapper.bs01022_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs01022_doSave(List<Map<String, Object>> gridH) {
        for (Map<String, Object> grid : gridH) {
            bs0102Mapper.bs01022_doSave(grid);
        }
    }

    public List<Map<String, Object>> bs01022_doSearchD(Map<String, String> param) {
        return bs0102Mapper.bs01022_doSearchD(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01022_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01022_doDeleteH(gridData);
            bs0102Mapper.bs01022_doDeleteD(gridData);
        }

        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01022_doSaveUser(List<Map<String, Object>> gridDatas) throws Exception {

        int checkCnt =0;
        for(Map<String, Object> gridData : gridDatas) {
            //고객사코드 중복체크
            checkCnt = bs0102Mapper.existsMUCD(gridData);
            if (checkCnt > 0) {
                return msg.getMessage("0203");
            }
        }

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01022_doSaveUser(gridData);
        }

        //return msg.getMessageByScreenId("BS01_020", "002");
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01022_doDeleteUser(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bs0102Mapper.bs01022_doDeleteUser(gridData);
        }

        return msg.getMessage("0017");
    }

    /** *****************
     * 운영사 > 고객사 결재경로관리
     * ******************/
    public List<Map<String, Object>> bs01080_doSearchUser(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01080_doSearchUser(param);
    }

    public Map<String, String> bs01080_doSearchPathInfo(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01080_doSearchPathInfo(param);
    }

    public List<Map<String, Object>> bs01080_doSearchPathList(Map<String, String> param) throws Exception {
        return bs0102Mapper.bs01080_doSearchPathList(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01080_doSave(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        String pathNum = EverString.nullToEmptyString(formData.get("PATH_NUM"));
        if(pathNum.equals("")) {
            pathNum = bs0102Mapper.getPathNo(formData);
            formData.put("PATH_NUM", pathNum);
        }

        bs0102Mapper.bs01080_doMerge(formData);

        bs0102Mapper.bs01080_doDeleteLULP(formData);
        for (Map<String, Object> gridData : gridDatas) {
            gridData.put("PATH_NUM", pathNum);
            bs0102Mapper.bs01080_doInsertPathDetail(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01080_doDelete(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        bs0102Mapper.bs01080_doDeleteRULM(formData);
        bs0102Mapper.bs01080_doDeleteLULP(formData);
        return msg.getMessage("0017");
    }


    public List<Map<String,Object>> bS01_090_doSearch(Map<String,String> formData){
    	  Map<String, Object> paramObj =  new HashMap<String, Object>(formData);
    	  if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
              paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
    	  }
        return bs0102Mapper.bS01_090_doSearch(paramObj);
    }

    public void bS01_090_doReject(List<Map<String,Object>> gridDatas){
        bs0102Mapper.bS01_090_doReject(gridDatas.get(0));
    }

}