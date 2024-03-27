package com.st_ones.evermp.IM02.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM02.IM0201_Mapper;
import com.st_ones.evermp.IM03.IM0301_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service(value = "im0201_Service")
public class IM0201_Service extends BaseService {

    @Autowired private IM0201_Mapper im0201_Mapper;
    @Autowired private IM0301_Mapper im0301Mapper;
    @Autowired private EApprovalService approvalService;

    @Autowired private QueryGenService queryGenService;
	@Autowired private DocNumService docNumService;
    @Autowired private MessageService msg;
    @Autowired LargeTextService largeTextService;

    /** *****************
     * 표준납기관리조회
     * ******************/
    public List<Map<String, Object>> im01010_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));

            sParam.put("COL_NM", "MTGL.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("MAKER_NM"));
            sParam.put("COL_NM", "MKBR.MKBR_NM");
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return im0201_Mapper.im01010_doSearch(param);
    }

    /** *****************
     * 표준납기저장
     * ******************/
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01010_doUpdate(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0201_Mapper.im01010_doUpdate(gridData);
        }
        return msg.getMessage("0031");
    }

    /** *****************
     * 품목별 판가관리
     * ******************/
    public List<Map<String, Object>> im02010_doSearch(Map<String, String> param) throws Exception {


        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC||MTGL.ITEM_SPEC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
//        if(!EverString.nullToEmptyString(param.get("ITEM_SPEC")).equals("")) {
//            sParam.put("COL_VAL", param.get("ITEM_SPEC"));
//            sParam.put("COL_NM", "MTGL.ITEM_SPEC");
//            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
//        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
           // param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

    	return im0201_Mapper.im02010_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im02010_doModify(List<Map<String, Object>> gridDatas) throws Exception {

    	for(Map<String, Object> gridData : gridDatas) {
	    	gridData.put("SALES_UNIT_PRC", gridData.get("SALES_UNIT_PRC"));
	    	gridData.put("NEW_SALES_UNIT_PRC", gridData.get("CHANGE_SALES_UNIT_PRC"));
	    	im0201_Mapper.doUpdateUinfo(gridData);
	    	im0201_Mapper.doInsertUinfh(gridData);
    	}
		return msg.getMessage("0016");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im02010_doDelete(List<Map<String, Object>> gridDatas) throws Exception {
    	for(Map<String, Object> gridData : gridDatas) {
    		im0201_Mapper.deleteDeleteUinfo(gridData);
    		im0201_Mapper.deleteDeleteYinfo(gridData);
    	}
		return msg.getMessage("0017");
    }

    /** *****************
     * 판가등록
     * ******************/
    public List<Map<String, Object>> doSearchChkItem(List<Map<String, Object>> gridData) throws Exception {

    	for(Map<String, Object> data : gridData) {

    		String chkText = im0201_Mapper.chkItem(data);
    		if (chkText==null || "".equals(chkText) || "null".equals(chkText)) {
    			data.put("CHK_TEXT","O");
    		} else {
    			data.put("CHK_TEXT",chkText);
    		}
    	}
    	return gridData;
    }

    public List<Map<String, Object>> im02011_doSearch(Map<String, String> param) throws Exception {

    	return im0201_Mapper.im02011_doSearch(param);
    }

    public Map<String, Object> doGetPrice(Map<String, String> param) throws Exception {
        return im0201_Mapper.doGetPrice(param);
    }

    /**
   	 * 상품관리 > 계약단가관리 > 고객판가 관리 (IM02_010) > 고객판가일괄등록 (IM02_011) : 엑셀 업로드
   	 * @param gridDatas
   	 * @return
   	 */
    public List<Map<String, Object>> doSetExcelImportUinfo(List<Map<String,Object>> gridDatas){

    	UserInfo userInfo = UserInfoManager.getUserInfo();

    	List<Map<String, Object>> rtnGrid = new ArrayList<>();
        for(Map<String, Object> grid : gridDatas){

            // 품목코드가 존재하는 경우 품목 기본정보 가져오기
            Map<String, Object> item = new HashMap<String, Object>();
            if( grid.get("ITEM_CD") != null && !"".equals(grid.get("ITEM_CD")) ) {
            	item = im0201_Mapper.doSetExcelImportUinfo(grid);
            }
            grid.putAll(item);

            rtnGrid.add(grid);
        }

        return rtnGrid;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im02011_doSave(Map<String, String> formData, List<Map<String, Object>> gridDataCt) throws Exception  {
        String contNo = "";
    	// 단가가 변경 되면 무조건 결재를 태운다.
        formData.put("SIGN_STATUS","P");
        // 단가등록 or 단가수정시 결재요청
        String appDocNum = docNumService.getDocNumber("AP");
        String appDocCnt = "1";

        formData.put("APP_DOC_NUM", appDocNum);
        formData.put("APP_DOC_CNT", "1");

        for(Map<String, Object> ctData : gridDataCt) {

            // 단가 유효성 검증
            Map<String, String> chkData = im0201_Mapper.chkInfoValid(ctData);
            if("Y".equals(chkData.get("INFO_CHANGING_YN"))) {
            	throw new Exception(ctData.get("ITEM_CD")+" 해당건은 단가가 변경중인 건입니다.");
            }
            // 단가 중복 체크
            if("Y".equals(chkData.get("INFO_F_EXISTS_YN"))) {
            	throw new Exception(ctData.get("ITEM_CD")+" "+ctData.get("BUYER_NM")+" "+ctData.get("PLANT_NM")+" 해당건은 기간이 겹치는 단가가 존재합니다.");
            }

            ctData.put("ERP_IF_FLAG", chkData.get("ERP_IF_FLAG"));
            ctData.put("CUST_ITEM_CD", chkData.get("CUST_ITEM_CD"));
        }

        for(Map<String, Object> ctData : gridDataCt) {

            ctData.put("APPLY_COM",   ctData.get("BUYER_CD"));	// 단가적용 고객사코드
            ctData.put("APPLY_PLANT", ctData.get("PLANT_CD"));	// 매입단가적용 사업장코드
            ctData.put("PLANT_CD",  ((ctData.get("APPLY_PLANT") == null || String.valueOf(ctData.get("APPLY_PLANT")).equals("")) ? "*" : String.valueOf(ctData.get("APPLY_PLANT"))));	// 매출단가적용 사업장코드
            ctData.put("PREV_UNIT_PRICE", ctData.get("SALES_UNIT_PRICE"));		// 변경전 판매단가
            ctData.put("SALES_UNIT_PRICE", ctData.get("NEW_SALES_UNIT_PRICE"));

            // 계약번호 생성.
            if(EverString.nullToEmptyString(ctData.get("CONT_NO")).equals("")){
                contNo = docNumService.getDocNumber("CT");
                ctData.put("CONT_NO", contNo);
                ctData.put("CONT_SEQ", "1");
            }

            ctData.put("CONT_TYPE_CD", "MN");
            ctData.put("TAX_CD", EverString.nullToEmptyString(ctData.get("VAT_CD")));
            ctData.put("APP_DOC_NUM", appDocNum);
            ctData.put("APP_DOC_CNT", appDocCnt);
            ctData.put("SIGN_STATUS", "P");

            // 2023.01.12 HMCHOI 추가
            // DGNS 내부 고객사인 경우 : 표준품목 - 고객사 품목코드 맵핑
            if( EverString.nullToEmptyString(ctData.get("ERP_IF_FLAG")).equals("1") ) {
                im0301Mapper.im03009_doSave_MTGB(ctData);
            }

            // 매입단가(STOYINFO) 등록
            im0301Mapper.im03009_doSave_YINFH(ctData);

            // 매출단가(STOUINFO) 등록
            ctData.put("CUST_CD", ctData.get("APPLY_COM"));
            im0301Mapper.im03009_doSave_UINFH(ctData);

            formData.put("DOC_TYPE", "INFOCHUP");
        }
        approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));

        //if(1==1) throw new Exception("===========================================");
        return msg.getMessage("0023");
    }

    /** *****************
     * 품목검색
     * ******************/
    public List<Map<String, Object>> im02012_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_SPEC"));
            sParam.put("COL_NM", "MTGL.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("MAKER_NM"));
            sParam.put("COL_NM", "A.MAKER_NM");
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

    	return im0201_Mapper.im02012_doSearch(param);
	}

    /** *****************
     * 분류체계별관리
     * ******************/
    public List<Map<String, Object>> im02020_doSearch(Map<String, String> param) throws Exception {
        return im0201_Mapper.im02020_doSearch(param);
    }

    public static Map<String, String> convertObjectMap(Map<?, ?> map) {
		Map<String, String> newMap = new HashMap<String, String>();
		@SuppressWarnings("rawtypes")
		Set keySet = map.keySet();
		for (Object key : keySet) {
			Object value = map.get(key);
			if (key instanceof String && value instanceof String) {
				newMap.put((String)key, (String)value);
			}
		}
		return newMap;
	}

    /** *****************
     * 분류체계별 이력
     * ******************/
    public List<Map<String, Object>> im02021_doSearch(Map<String, String> param) throws Exception {
		return im0201_Mapper.im02021_doSearch(param);
	}

	public String getLabel(Map<String, String> param) throws Exception {
		return im0201_Mapper.getLabel(param);
	}

    /** *****************
     * 분류체계별 수정
     * ******************/
    public List<Map<String, Object>> im02022_doSearch(Map<String, String> param) throws Exception {
    	return im0201_Mapper.im02022_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im02022_doSave(List<Map<String, Object>> gridDatas) throws Exception {

    	for(Map<String, Object> gridData : gridDatas) {
    		im0201_Mapper.doUpdateCATR(gridData);
    		im0201_Mapper.insertCATH(gridData);
    	}
		return msg.getMessage("0001");
    }

    /** *****************
     * 분류체계별 신규등록
     * ******************/
    public Map<String, String> im02023_doSearchData(Map<String, String> param) throws Exception {
    	return im0201_Mapper.im02023_doSearchData(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im02023_doSave(Map<String, String> formData) throws Exception {

    	int cnt = im0201_Mapper.doCheckExist(formData);
		if (cnt > 0) { throw new Exception(msg.getMessageByScreenId("P01_001", "045")); }

		im0201_Mapper.doInsertCATR(formData);
		return msg.getMessage("0001");
    }

    /** *****************
     * 품목별 판가관리 이력
     * ******************/
    public List<Map<String, Object>> im02013_doSearch(Map<String, String> param) throws Exception {
        return im0201_Mapper.im02013_doSearch(param);
    }












    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String block(List<Map<String, Object>> gridDatas) throws Exception {
    	for(Map<String, Object> gridData : gridDatas) {

    		im0201_Mapper.block(gridData);
    	}
		return msg.getMessage("0001");
    }
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String blockCancel(List<Map<String, Object>> gridDatas) throws Exception {
    	for(Map<String, Object> gridData : gridDatas) {

    		im0201_Mapper.blockCancel(gridData);
    	}
		return msg.getMessage("0001");
    }


}