package com.st_ones.evermp.STO.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.evermp.STO.STO0401_Mapper;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "STO0401_Service")
public class STO0401_Service {
    @Autowired
    private STO0401_Mapper sto0401Mapper;
    @Autowired
	MessageService msg;
    @Autowired
	private QueryGenService queryGenService;



    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> sto0405_doSearch(Map<String, String> formData) throws Exception {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "MMRS.ITEM_DESC");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "MMRS.ITEM_SPEC");
            formData.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
    	return sto0401Mapper.sto0405_doSearch(formData);
	}

  /** ****************************************************************************************************************
    * 재고관리 > 재고수불마감 > 재고수불마감(회계) (STO04_020)
    */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
   	public List<Map<String, Object>> sto0402_doSearch(Map<String, String> formData) throws Exception {
    	String yearMonth =formData.get("YEAR")+formData.get("MONTH");
    	formData.put("YEAR_MONTH",yearMonth);
       	return sto0401Mapper.sto0402_doSearch(formData);
   	}
    //마감 실행
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sto0402_doConfirm(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
    	String yearMonth =gridList.get(0).get("YEAR_MONTH").toString();
    	String reMsg ="";
    	form.put("YEAR_MONTH",yearMonth);
    	String NEXT_MONTH =form.get("NEXT_MONTH");

    	int checkArprData  = sto0401Mapper.APARdataCheck(form);			// 전월에 마감되지않은 데이터 CHECK
    	int checkData2 = sto0401Mapper.IGIMSdataCheck(form);
    	int checkGimsData = sto0401Mapper.IGIMSdataCheck2(form);		 // 이미 완료된 DATA 인지 확인

    	if(checkArprData > 0 && checkData2 == 0) {
    		throw new Exception( "해당 년월 이전에 마감되지않은 데이터가 존재합니다. 이전 데이터 마감 후 진행해주세요. ");
     	}
    	if(checkGimsData > 0) {
    		throw new Exception ("이미 마감된 년월 입니다 다시 조회해주세요! ");
    	}
    	List<Map<String, Object>>  dataMap = sto0401Mapper.getAPARdata(form); // APAR(계산서확정 데이터) + (IGMS)기초재고 불러오기
    	if(dataMap.size() == 0) {
    		throw new Exception ( "해당 년월의 데이터가 존재 하지 않습니다.");
    	}else {
			sto0401Mapper.sto0402_deleteIGIMS(form); // [PK 중복 방지] 등록된 해당년월 기초재고 삭제
			for(Map<String, Object> data : dataMap) {
				data.put("YEAR_MONTH",yearMonth);
				data.put("NEXT_MONTH",NEXT_MONTH);
				sto0401Mapper.sto0402_insertIGIMS(data);
				sto0401Mapper.sto0402_insertIGIMS2(data); //다음달 기초재고 INSERT

				reMsg="마감완료 되었습니다.";
		  }
		}
    	return reMsg;
    }
   //마감삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sto0402_doDelete(Map<String, String> param) throws Exception {

        	sto0401Mapper.sto0402_doDelete(param);
        	sto0401Mapper.sto0402_doDeleteNowData(param);

        return msg.getMessageByScreenId("STO04_020","008");
    }

    /** ****************************************************************************************************************
     * 재고관리 > 재고수불마감 > 월별 재고수불부
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
   	public List<Map<String, Object>> sto0404_doSearch(Map<String, String> formData) throws Exception {
    		String yearMonth = formData.get("RD_DATE_Y")+formData.get("RD_DATE_M");
    		formData.put("YEAR_MONTH",yearMonth);
       	return sto0401Mapper.sto0404_doSearch(formData);
   	}
    //재고수불마감.
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sto0404_doSave(Map<String, String> param) {
    	List<Map<String, Object>> rdList =sto0401Mapper.sto0404_getRdList(param);
    	//익월중복체크
    	int checkM = sto0401Mapper.sto0404_overlapCheck(param);
    	//전월 중복체크
    	List<Map<String, Object>> checkList = sto0401Mapper.sto0404_overlapBefCheck(param);
    	String reMsg ="";
    	List<String> list= new ArrayList<String>();
    	if(checkM == 0 /* && checkList.size()==0 */) {

        	for(Map<String, Object> rdData:rdList) {
        		sto0401Mapper.insertRd(rdData);
        	}
        	reMsg="마감완료 되었습니다.";
    	} else {
    		if(checkM > 0) {
    			reMsg="익월 데이터가 존재합니다. 삭제후 진행 바랍니다.";
    		} else if(checkList.size()>0) {
    			for(Map<String, Object> rdData:checkList ) {
    				list.add(String.valueOf(rdData.get("R_DATE")));
    			}
    			reMsg=StringUtils.join(list,",")+" 전월 데이터가 존재합니다. 삭제후 진행 바랍니다.";
    		}
    	}

		return reMsg;
	}
    //재고수불삭제
    public String sto0404_doDelete(Map<String, String> param) {
    	List<Map<String, Object>> rdList =sto0401Mapper.sto0404_deleteList(param);
    	List<String> list= new ArrayList<String>();
    	for(Map<String, Object> rdData:rdList ) {
    		list.add(String.valueOf(rdData.get("R_DATE")));
    		sto0401Mapper.delRd(rdData);
    	}

    	return StringUtils.join(list,",")+"데이터 삭제되었습니다.";
    }

	public List<Map<String, Object>> sto0401_doSearch(Map<String, String> formData) {
		String toRdDate = formData.get("RD_DATE");
		formData.put("TO_RD_DATE",(toRdDate.substring(0,6)+"01"));   //시작날짜는 해당 월의 1일

       	return sto0401Mapper.sto0401_doSearch(formData);
	}

	public List<Map<String, Object>> sto0403_doSearch(Map<String, String> formData) {

		return sto0401Mapper.sto0403_doSearch(formData);
	}

	public List<Map<String, Object>> sto0401p01_doSearch(Map<String, String> formData) {
		String toRdDate = formData.get("RD_DATE");
		formData.put("TO_RD_DATE",(toRdDate.substring(0,6)+"01"));   //시작날짜는 해당 월의 1일

       	return sto0401Mapper.sto0401p01_doSearch(formData);
	}

	/** ****************************************************************************************************************
	 * 재고관리 > 입출고내역조회(공급사)
	 */

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> sto0406_doSearch(Map<String, String> formData) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
		if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", formData.get("ITEM_DESC"));
			sParam.put("COL_NM", "MMRS.ITEM_DESC");
			formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "MMRS.ITEM_SPEC");
			formData.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}
		return sto0401Mapper.sto0406_doSearch(formData);
	}

}
