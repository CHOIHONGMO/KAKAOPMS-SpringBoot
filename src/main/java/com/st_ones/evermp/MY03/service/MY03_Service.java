package com.st_ones.evermp.MY03.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.MY03.MY03_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
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
 * @File Name : MY03_Service.java
 * @date 2018. 02. 06.
 * @version 1.0
 * @see
 */

@Service(value = "my03_Service")
public class MY03_Service extends BaseService {

	@Autowired private MY03_Mapper my03_Mapper;

	@Autowired private MessageService msg;

    @Autowired private LargeTextService largeTextService;

	@Autowired private QueryGenService queryGenService;

	/** ******************************************************************************************
     * 소싱리드타임
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my03010_doSearch(Map<String, String> param) throws Exception {
		// 조회조건은 6개월을 초과할 수 없습니다.
		if( "0".equals(my03_Mapper.my03010_validDateDiff(param)) ){
			throw new NoResultException(msg.getMessageByScreenId("MY03_010", "DATE_SEARCH_VALID"));
		}
		/*
        Map<String, Object> param2 = new HashMap<String,Object>();
        param2.putAll(param);
		if( param2.get("BUYER_CODE") != null && !"".equals(param2.get("BUYER_CODE")) ){
        	String BUYER_CODE = param2.get("BUYER_CODE").toString();
    		ArrayList<Map> al = new ArrayList<Map>();
    		StringTokenizer  stk = new StringTokenizer (BUYER_CODE,",");
    		while(stk.hasMoreTokens()) {
    			Map<String,String> mm = new LinkedHashMap<String,String>();
    			mm.put("BUYER_CODE", stk.nextToken());
    			al.add(mm);
    		}
    		param2.put("BUYER_CODE_LIST", al);
    		param2.put("BUYER_NAME", "");
		}
		*/
		return my03_Mapper.my03010_doSearch(param);
	}

	/** ******************************************************************************************
     * 품목생성리드타임
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my03020_doSearch(Map<String, String> param) throws Exception {
		Map<String, Object> param2 = new HashMap<String,Object>();
        param2.putAll(param);
		if (param2.get("BUYER_CODE") != null && !"".equals(param2.get("BUYER_CODE")) ) {
        	String BUYER_CODE = param2.get("BUYER_CODE").toString();
    		ArrayList<Map> al = new ArrayList<Map>();
    		StringTokenizer  stk = new StringTokenizer (BUYER_CODE,",");
    		while(stk.hasMoreTokens()) {
    			Map<String,String> mm = new LinkedHashMap<String,String>();
    			mm.put("BUYER_CODE", stk.nextToken());
    			al.add(mm);
    		}
    		param2.put("BUYER_CODE_LIST", al);
    		param2.put("BUYER_NAME", "");
		}

		return my03_Mapper.my03020_doSearch(param);
	}

	/** ******************************************************************************************
     * 납품리드타임
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my03030_doSearch(Map<String, String> param) throws Exception {
		/*
		if( param.get("VENDOR_CODE") != null && !"".equals(param.get("VENDOR_CODE")) ){
            param.put("VENDOR_CODE", EverString.forInQuery(param.get("VENDOR_CODE"), ","));
            param.put("exclusion", "false");
            param.put("VENDOR_NAME", "");
        }
		*/

		Map<String, Object> param2 = new HashMap<String,Object>();
        param2.putAll(param);
		if (param2.get("BUYER_CODE") != null && !"".equals(param2.get("BUYER_CODE")) ) {
        	String BUYER_CODE = param2.get("BUYER_CODE").toString();
    		ArrayList<Map> al = new ArrayList<Map>();
    		StringTokenizer  stk = new StringTokenizer (BUYER_CODE,",");
    		while(stk.hasMoreTokens()) {
    			Map<String,String> mm = new LinkedHashMap<String,String>();
    			mm.put("BUYER_CODE", stk.nextToken());
    			al.add(mm);
    		}
    		param2.put("BUYER_CODE_LIST", al);
    		param2.put("BUYER_NAME", "");
		}


        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_NM", "PODT.ITEM_DESC");
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            param.put("ITEM_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_NM", "PODT.ITEM_SPEC");
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            param.put("ITEM_SP", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

		if(EverString.isNotEmpty(param.get("ITEM_CODE"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CODE"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CODE"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CODE").contains(",") ? "1" : "0");
		}

		return my03_Mapper.my03030_doSearch(param);
	}

	/** ******************************************************************************************
     * 납기준수율
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my03040_doSearch(Map<String, String> param) throws Exception {
		// 조회조건은 6개월을 초과할 수 없습니다.
		if( "0".equals(my03_Mapper.my03040_validDateDiff(param)) ){
			throw new NoResultException(msg.getMessageByScreenId("MY03_040", "MSG_01"));
		}
		/*
		if( param.get("VENDOR_CODE") != null && !"".equals(param.get("VENDOR_CODE")) ){
            param.put("VENDOR_CODE", EverString.forInQuery(param.get("VENDOR_CODE"), ","));
            param.put("exclusion", "false");
            param.put("VENDOR_NAME", "");
        }
		*/
        Map<String, Object> param2 = new HashMap<String,Object>();
        param2.putAll(param);
		if (param2.get("BUYER_CODE") != null && !"".equals(param2.get("BUYER_CODE")) ) {
        	String BUYER_CODE = param2.get("BUYER_CODE").toString();
    		ArrayList<Map> al = new ArrayList<Map>();
    		StringTokenizer  stk = new StringTokenizer (BUYER_CODE,",");
    		while(stk.hasMoreTokens()) {
    			Map<String,String> mm = new LinkedHashMap<String,String>();
    			mm.put("BUYER_CODE", stk.nextToken());
    			al.add(mm);
    		}
    		param2.put("BUYER_CODE_LIST", al);
    		param2.put("BUYER_NAME", "");
		}

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_NM", "PODT.ITEM_DESC");
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            param.put("ITEM_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_NM", "PODT.ITEM_SPEC");
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            param.put("ITEM_SP", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

		if(EverString.isNotEmpty(param.get("ITEM_CODE"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CODE"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CODE"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CODE").contains(",") ? "1" : "0");
		}

		return my03_Mapper.my03040_doSearch(param);
	}

	/**
	 * 고객사별 실적분석
	 */
	public List<Map<String, Object>> my03050_doSearch(Map<String, String> param) {
		Map<String, Object> sParam = new HashMap<String, Object>(param);
		sParam = setDateParam(sParam);

		return my03_Mapper.my03050_doSearch(sParam);
	}

	/**
	 * 공급사별 실적분석
	 */
	public List<Map<String, Object>> my03060_doSearch(Map<String, String> param) {
		Map<String, Object> sParam = new HashMap<String, Object>(param);
		sParam = setDateParam(sParam);

		return my03_Mapper.my03060_doSearch(sParam);
	}

	/**
	 * 품목별 실적분석
	 */
	public List<Map<String, Object>> my03070_doSearch(Map<String, String> param) {
		Map<String, Object> sParam = new HashMap<String, Object>(param);

		if(!"".equals(param.get("ITEM_CD"))) {
			sParam.put("ITEM_CD_LIST", Arrays.asList(param.get("ITEM_CD").split(",")));
		}



		return my03_Mapper.my03070_doSearch(sParam);
	}

	/** ******************************************************************************************
	 * 일자별접속현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03080_doSearch(Map<String, String> param) throws Exception {
		return my03_Mapper.my03080_doSearch(param);
	}

	/** ******************************************************************************************
	 * 고객사별 매출계획
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03090_doSearch(Map<String, String> param) throws Exception {

		Map<String, Object> fParam = new HashMap<String, Object>(param);
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

		List<String> progressList = Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(","));
		for(int i = 0; i < progressList.size(); i++) {
			String progressCd = progressList.get(i);
			if(progressCd.equals("")) {
				fParam.put("PROGRESS_CD", null);
				fParam.put("PROGRESS_CD_LIST", null);
			}
		}

		return my03_Mapper.my03090_doSearch(fParam);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my03090_doSave(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

		String progressCd = formData.get("PROGRESS_CD");
		String oldGubn ="";
		Object seq= new Object();
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));



			if(gridData.get("CUST_CD").equals("NEW") && gridData.get("PLANT_CD").equals("NEW")) {

				if(!gridData.get("NEW_CHECK_SEQ").equals(oldGubn)) {

					seq=my03_Mapper.newSaplSeq(gridData);
					oldGubn=String.valueOf(gridData.get("NEW_CHECK_SEQ"));
				}
				gridData.put("PLANT_CD", seq );
			}
			my03_Mapper.my03090_doMerge(gridData);
		}

		return (progressCd.equals("T") ? msg.getMessage("0031") : (progressCd.equals("P") ? msg.getMessage("0122") : msg.getMessage("0057"))) ;
	}

	/** ******************************************************************************************
	 * 고객사별 매출현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03091_doSearch(Map<String, String> param) throws Exception {
		Map<String, Object> reParam = new HashMap<String, Object>();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		String MYEAR_FROM = param.get("MYEAR_FROM");
		String MONTH_FROM = param.get("MONTH_FROM");
		String MYEAR_TO   = param.get("MYEAR_TO");
		String MONTH_TO   = param.get("MONTH_TO");
		Date startDate = sdf.parse(MYEAR_FROM+MONTH_FROM+"01");
		Date endDate = sdf.parse(MYEAR_TO+MONTH_TO+"01");
		int restMonths = (int)monthsBetween(startDate, endDate);
		int colIdx = 0;
		List<Map<String, Object>> colList = new ArrayList<Map<String, Object>>();
		ArrayList aList= new ArrayList();
		for(int i = 1,j=restMonths+1,Q=Integer.valueOf(MONTH_FROM),t=1; i <= restMonths+1; i++) {
			aList.add(Q);
			//12월달 이면
			if(Q==12) {
				Map<String, Object> colInfo = new HashMap<String, Object>();
				//기준년도 시작년도 +일년증가
				colInfo.put("P_YYYY" , String.valueOf(Integer.valueOf(MYEAR_FROM)+colIdx));
				//월
				colInfo.put("P_MM"	 , aList);
			    colList.add(colIdx	 , colInfo);
				colIdx++;
				aList = new ArrayList();
				Q=0;
				//남은달 마이너스
				j=j-t;
				t=0;
			}
			//12개월 부족하고 남은달 add
			if(j<12 && Integer.valueOf(MONTH_TO) == Q) {
				Map<String, Object> colInfo = new HashMap<String, Object>();
				colInfo.put("P_YYYY", String.valueOf(Integer.valueOf(MYEAR_FROM)+colIdx));
				colInfo.put("P_MM", aList);
				colList.add(colIdx, colInfo);
			}
			t++;
			Q++;

		}
		reParam.putAll(param);
		reParam.put("colList"    , colList);
		reParam.put("MYEAR_FROM" , MYEAR_FROM);
		reParam.put("MONTH_FROM" , MONTH_FROM);
		reParam.put("MYEAR_TO"   , MYEAR_TO);
		reParam.put("MONTH_TO"   , MONTH_TO);

		return my03_Mapper.my03091_doSearch(reParam);

	}

	/** ******************************************************************************************
	 * 고객사별 매출예상현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03095_doSearch(Map<String, String> param) throws Exception {

		Map<String, Object> sParam = new HashMap<String, Object>();
		sParam.putAll(param);
		sParam = setDateParam(sParam);

		List<Map<String, String>> yearList = my03_Mapper.getYearList(sParam);

		String yearStr = "";
		int tabJoinIdx = 0; int colIdx = 0;
		List<Map<String, Object>> tabJoinList = new ArrayList<Map<String, Object>>();

		for(int i = 0; i < yearList.size(); i++) {

			Map<String, String> yearData = yearList.get(i);

			if(!yearStr.equals(String.valueOf(yearData.get("P_YEAR")))) {

				yearStr = String.valueOf(yearData.get("P_YEAR"));

				Map<String, Object> tabJoinInfo = new HashMap<String, Object>();
				tabJoinInfo.put("P_TABLE_AS", "SAPL_" + yearData.get("P_YEAR"));
				tabJoinInfo.put("P_YEAR", yearData.get("P_YEAR"));

				List<Map<String, String>> colList = new ArrayList<Map<String, String>>();
				for(int j = 0; j < yearList.size(); j++) {
					Map<String, String> yData = yearList.get(j);
					if(yearStr.equals(String.valueOf(yData.get("P_YEAR")))) {
						Map<String, String> colInfo = new HashMap<String, String>();
						colInfo.put("P_MONTH", yData.get("P_MONTH"));
						colList.add(colIdx, colInfo);
						colIdx++;
					}
				}
				tabJoinInfo.put("colList", colList);
				colIdx = 0;

				tabJoinList.add(tabJoinIdx, tabJoinInfo);
				tabJoinIdx++;
			}
		}
		sParam.put("tabJoinList", tabJoinList);

		return my03_Mapper.my03095_doSearch(sParam);
	}

	/** ******************************************************************************************
	 * 고객사별 상품 매출현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03092_doSearch(Map<String, String> param) throws Exception {

		Map<String, Object> sParam = new HashMap<String, Object>();
		sParam.putAll(param);
		sParam = setDateParam(sParam);

		return my03_Mapper.my03092_doSearch(sParam);
	}

	/** ******************************************************************************************
	 * 상품별 매출 이익율 관리현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03093_doSearch(Map<String, String> param) throws Exception {

		Map<String, Object> sParam = new HashMap<String, Object>();
		sParam.putAll(param);
		sParam = setDateParam(sParam);

		return my03_Mapper.my03093_doSearch(sParam);
	}

	/** ******************************************************************************************
	 * 매출실적 및 매출이익
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my03094_doSearch(Map<String, String> param) throws Exception {

		DecimalFormat df = new DecimalFormat("#,###");
		DecimalFormat dr = new DecimalFormat("###.#");

		int rtnIdx = 0;
		List<Map<String, Object>> rtnList = new ArrayList<Map<String, Object>>();

		Map<String, Object> sParam = new HashMap<String, Object>();
		sParam.putAll(param);

		// 1월부터 12월까지 동적 쿼리를 위해 parameter를 셋팅한다.
		List<Map<String, Object>> tabJoinList = new ArrayList<Map<String, Object>>();
		for(int j = 0; j < 12; j++) {
			Map<String, Object> colInfo = new HashMap<String, Object>();
			colInfo.put("P_MONTH", j + 1);
			if(j >= 9) {
				colInfo.put("C_MONTH", String.valueOf(j + 1));
			} else {
				colInfo.put("C_MONTH", ("0" + String.valueOf(j + 1)));
			}
			tabJoinList.add(j, colInfo);
		}
		sParam.put("tabJoinList", tabJoinList);

		// 매출목표
		BigDecimal goalMonth1 = BigDecimal.ZERO;
		BigDecimal goalMonth2 = BigDecimal.ZERO;
		BigDecimal goalMonth3 = BigDecimal.ZERO;
		BigDecimal goalMonth4 = BigDecimal.ZERO;
		BigDecimal goalMonth5 = BigDecimal.ZERO;
		BigDecimal goalMonth6 = BigDecimal.ZERO;
		BigDecimal goalMonth7 = BigDecimal.ZERO;
		BigDecimal goalMonth8 = BigDecimal.ZERO;
		BigDecimal goalMonth9 = BigDecimal.ZERO;
		BigDecimal goalMonth10 = BigDecimal.ZERO;
		BigDecimal goalMonth11 = BigDecimal.ZERO;
		BigDecimal goalMonth12 = BigDecimal.ZERO;

		// 매출실적
		BigDecimal salMonth1 = BigDecimal.ZERO;
		BigDecimal salMonth2 = BigDecimal.ZERO;
		BigDecimal salMonth3 = BigDecimal.ZERO;
		BigDecimal salMonth4 = BigDecimal.ZERO;
		BigDecimal salMonth5 = BigDecimal.ZERO;
		BigDecimal salMonth6 = BigDecimal.ZERO;
		BigDecimal salMonth7 = BigDecimal.ZERO;
		BigDecimal salMonth8 = BigDecimal.ZERO;
		BigDecimal salMonth9 = BigDecimal.ZERO;
		BigDecimal salMonth10 = BigDecimal.ZERO;
		BigDecimal salMonth11 = BigDecimal.ZERO;
		BigDecimal salMonth12 = BigDecimal.ZERO;

		// 달성율
		BigDecimal attMonth1 = BigDecimal.ZERO;
		BigDecimal attMonth2 = BigDecimal.ZERO;
		BigDecimal attMonth3 = BigDecimal.ZERO;
		BigDecimal attMonth4 = BigDecimal.ZERO;
		BigDecimal attMonth5 = BigDecimal.ZERO;
		BigDecimal attMonth6 = BigDecimal.ZERO;
		BigDecimal attMonth7 = BigDecimal.ZERO;
		BigDecimal attMonth8 = BigDecimal.ZERO;
		BigDecimal attMonth9 = BigDecimal.ZERO;
		BigDecimal attMonth10 = BigDecimal.ZERO;
		BigDecimal attMonth11 = BigDecimal.ZERO;
		BigDecimal attMonth12 = BigDecimal.ZERO;

		// 매출이익
		BigDecimal profitMonth1 = BigDecimal.ZERO;
		BigDecimal profitMonth2 = BigDecimal.ZERO;
		BigDecimal profitMonth3 = BigDecimal.ZERO;
		BigDecimal profitMonth4 = BigDecimal.ZERO;
		BigDecimal profitMonth5 = BigDecimal.ZERO;
		BigDecimal profitMonth6 = BigDecimal.ZERO;
		BigDecimal profitMonth7 = BigDecimal.ZERO;
		BigDecimal profitMonth8 = BigDecimal.ZERO;
		BigDecimal profitMonth9 = BigDecimal.ZERO;
		BigDecimal profitMonth10 = BigDecimal.ZERO;
		BigDecimal profitMonth11 = BigDecimal.ZERO;
		BigDecimal profitMonth12 = BigDecimal.ZERO;

		// 매출이익율
		BigDecimal profitRateMonth1 = BigDecimal.ZERO;
		BigDecimal profitRateMonth2 = BigDecimal.ZERO;
		BigDecimal profitRateMonth3 = BigDecimal.ZERO;
		BigDecimal profitRateMonth4 = BigDecimal.ZERO;
		BigDecimal profitRateMonth5 = BigDecimal.ZERO;
		BigDecimal profitRateMonth6 = BigDecimal.ZERO;
		BigDecimal profitRateMonth7 = BigDecimal.ZERO;
		BigDecimal profitRateMonth8 = BigDecimal.ZERO;
		BigDecimal profitRateMonth9 = BigDecimal.ZERO;
		BigDecimal profitRateMonth10 = BigDecimal.ZERO;
		BigDecimal profitRateMonth11 = BigDecimal.ZERO;
		BigDecimal profitRateMonth12 = BigDecimal.ZERO;

//		List<Map<String, String>> custList = my03_Mapper.getCustList(sParam);
//		for(int i = 0; i < custList.size(); i++) {
//
//			Map<String, String> custData = custList.get(i);
//
//			// 고객사별 데이터를 조회한다.
//			sParam.put("CUST_CD", custData.get("CUST_CD"));
			List<Map<String, Object>> tmpList = my03_Mapper.my03094_doSearch(sParam);

			for(Map<String, Object> tmpData : tmpList) {
				// 매출목표
				Map<String, Object> rtnData = new HashMap<String, Object>();
				rtnData.put("CUST_NM", tmpData.get("CUST_NM"));
				rtnData.put("RELAT_YN", tmpData.get("RELAT_YN"));
				rtnData.put("MANAGE_NM", tmpData.get("MANAGE_NM"));
				rtnData.put("CPO_YEAR", tmpData.get("CPO_YEAR"));
				rtnData.put("DATA_TYPE", "매출목표");
				for(int p = 1; p < 13; p++) {
					rtnData.put("DATA_" + String.valueOf(p), df.format(new BigDecimal(String.valueOf(tmpData.get("MONTH_" + String.valueOf(p) + "_SALE_PLAN_AMT")))));

					if (p == 1) {
						goalMonth1 = goalMonth1.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 2) {
						goalMonth2 = goalMonth2.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 3) {
						goalMonth3 = goalMonth3.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 4) {
						goalMonth4 = goalMonth4.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 5) {
						goalMonth5 = goalMonth5.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 6) {
						goalMonth6 = goalMonth6.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 7) {
						goalMonth7 = goalMonth7.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 8) {
						goalMonth8 = goalMonth8.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 9) {
						goalMonth9 = goalMonth9.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 10) {
						goalMonth10 = goalMonth10.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 11) {
						goalMonth11 = goalMonth11.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 12) {
						goalMonth12 = goalMonth12.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					}
				}
				rtnData.put("DATA_SUM", df.format(new BigDecimal(String.valueOf(tmpData.get("SUM_SALE_PLAN_AMT")))));
				rtnList.add(rtnIdx, rtnData);
				rtnIdx++;

				// 매출실적
				rtnData = new HashMap<String, Object>();
				rtnData.put("CUST_NM", tmpData.get("CUST_NM"));
				rtnData.put("RELAT_YN", tmpData.get("RELAT_YN"));
				rtnData.put("MANAGE_NM", tmpData.get("MANAGE_NM"));
				rtnData.put("CPO_YEAR", tmpData.get("CPO_YEAR"));
				rtnData.put("DATA_TYPE", "매출실적");

				for(int p = 1; p < 13; p++) {
					rtnData.put("DATA_" + String.valueOf(p), df.format(new BigDecimal(String.valueOf(tmpData.get("MONTH_" + String.valueOf(p) + "_CPO_ITEM_AMT")))));

					if (p == 1) {
						salMonth1 = salMonth1.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 2) {
						salMonth2 = salMonth2.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 3) {
						salMonth3 = salMonth3.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 4) {
						salMonth4 = salMonth4.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 5) {
						salMonth5 = salMonth5.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 6) {
						salMonth6 = salMonth6.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 7) {
						salMonth7 = salMonth7.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 8) {
						salMonth8 = salMonth8.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 9) {
						salMonth9 = salMonth9.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 10) {
						salMonth10 = salMonth10.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 11) {
						salMonth11 = salMonth11.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 12) {
						salMonth12 = salMonth12.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					}
				}

				rtnData.put("DATA_SUM", df.format(new BigDecimal(String.valueOf(tmpData.get("SUM_CPO_ITEM_AMT")))));
				rtnList.add(rtnIdx, rtnData);
				rtnIdx++;

				// 달성율
				rtnData = new HashMap<String, Object>();
				rtnData.put("CUST_NM", tmpData.get("CUST_NM"));
				rtnData.put("RELAT_YN", tmpData.get("RELAT_YN"));
				rtnData.put("MANAGE_NM", tmpData.get("MANAGE_NM"));
				rtnData.put("CPO_YEAR", tmpData.get("CPO_YEAR"));
				rtnData.put("DATA_TYPE", "달성율");
				for(int p = 1; p < 13; p++) {
					rtnData.put("DATA_" + String.valueOf(p), dr.format(new BigDecimal(String.valueOf(tmpData.get("MONTH_" + String.valueOf(p) + "_PLAN_RATE")))) + "%");

					if (p == 1) {
						attMonth1 = attMonth1.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 2) {
						attMonth2 = attMonth2.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 3) {
						attMonth3 = attMonth3.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 4) {
						attMonth4 = attMonth4.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 5) {
						attMonth5 = attMonth5.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 6) {
						attMonth6 = attMonth6.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 7) {
						attMonth7 = attMonth7.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 8) {
						attMonth8 = attMonth8.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 9) {
						attMonth9 = attMonth9.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 10) {
						attMonth10 = attMonth10.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 11) {
						attMonth11 = attMonth11.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 12) {
						attMonth12 = attMonth12.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					}
				}
				rtnData.put("DATA_SUM", dr.format(new BigDecimal(String.valueOf(tmpData.get("AVG_SALE_PLAN_RATE")))) + "%");
				rtnList.add(rtnIdx, rtnData);
				rtnIdx++;

				// 매출이익
				rtnData = new HashMap<String, Object>();
				rtnData.put("CUST_NM", tmpData.get("CUST_NM"));
				rtnData.put("RELAT_YN", tmpData.get("RELAT_YN"));
				rtnData.put("MANAGE_NM", tmpData.get("MANAGE_NM"));
				rtnData.put("CPO_YEAR", tmpData.get("CPO_YEAR"));
				rtnData.put("DATA_TYPE", "매출이익");
				for(int p = 1; p < 13; p++) {
					rtnData.put("DATA_" + String.valueOf(p), df.format(new BigDecimal(String.valueOf(tmpData.get("MONTH_" + String.valueOf(p) + "_PROFIT_AMT")))));

					if (p == 1) {
						profitMonth1 = profitMonth1.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 2) {
						profitMonth2 = profitMonth2.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 3) {
						profitMonth3 = profitMonth3.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 4) {
						profitMonth4 = profitMonth4.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 5) {
						profitMonth5 = profitMonth5.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 6) {
						profitMonth6 = profitMonth6.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 7) {
						profitMonth7 = profitMonth7.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 8) {
						profitMonth8 = profitMonth8.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 9) {
						profitMonth9 = profitMonth9.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 10) {
						profitMonth10 = profitMonth10.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 11) {
						profitMonth11 = profitMonth11.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					} else if (p == 12) {
						profitMonth12 = profitMonth12.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll(",", "")));
					}
				}
				rtnData.put("DATA_SUM", df.format(new BigDecimal(String.valueOf(tmpData.get("SUM_PROFIT_AMT")))));
				rtnList.add(rtnIdx, rtnData);
				rtnIdx++;

				// 매출이익률
				rtnData = new HashMap<String, Object>();
				rtnData.put("CUST_NM", tmpData.get("CUST_NM"));
				rtnData.put("RELAT_YN", tmpData.get("RELAT_YN"));
				rtnData.put("MANAGE_NM", tmpData.get("MANAGE_NM"));
				rtnData.put("CPO_YEAR", tmpData.get("CPO_YEAR"));
				rtnData.put("DATA_TYPE", "매출이익률");
				for(int p = 1; p < 13; p++) {
					rtnData.put("DATA_" + String.valueOf(p), dr.format(new BigDecimal(String.valueOf(tmpData.get("MONTH_" + String.valueOf(p) + "_PROFIT_RATE")))) + "%");

					if (p == 1) {
						profitRateMonth1 = profitRateMonth1.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 2) {
						profitRateMonth2 = profitRateMonth2.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 3) {
						profitRateMonth3 = profitRateMonth3.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 4) {
						profitRateMonth4 = profitRateMonth4.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 5) {
						profitRateMonth5 = profitRateMonth5.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 6) {
						profitRateMonth6 = profitRateMonth6.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 7) {
						profitRateMonth7 = profitRateMonth7.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 8) {
						profitRateMonth8 = profitRateMonth8.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 9) {
						profitRateMonth9 = profitRateMonth9.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 10) {
						profitRateMonth10 = profitRateMonth10.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 11) {
						profitRateMonth11 = profitRateMonth11.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					} else if (p == 12) {
						profitRateMonth12 = profitRateMonth12.add(new BigDecimal(String.valueOf(rtnData.get("DATA_" + p)).replaceAll("%", "")));
					}
				}
				rtnData.put("DATA_SUM", dr.format(new BigDecimal(String.valueOf(tmpData.get("AVG_PROFIT_RATE")))) + "%");
				rtnList.add(rtnIdx, rtnData);
				rtnIdx++;
			}


//		}

		// 매출목표
		Map<String, Object> goalMap = new HashMap<>();
		goalMap.put("MANAGE_NM","합계");
		goalMap.put("CPO_YEAR", param.get("CPO_YEAR"));
		goalMap.put("DATA_TYPE", "매출목표");
		goalMap.put("DATA_1", df.format(goalMonth1));
		goalMap.put("DATA_2", df.format(goalMonth2));
		goalMap.put("DATA_3", df.format(goalMonth3));
		goalMap.put("DATA_4", df.format(goalMonth4));
		goalMap.put("DATA_5", df.format(goalMonth5));
		goalMap.put("DATA_6", df.format(goalMonth6));
		goalMap.put("DATA_7", df.format(goalMonth7));
		goalMap.put("DATA_8", df.format(goalMonth8));
		goalMap.put("DATA_9", df.format(goalMonth9));
		goalMap.put("DATA_10", df.format(goalMonth10));
		goalMap.put("DATA_11", df.format(goalMonth11));
		goalMap.put("DATA_12", df.format(goalMonth12));
		goalMap.put("DATA_SUM", df.format(goalMonth1
				.add(goalMonth2)
				.add(goalMonth3)
				.add(goalMonth4)
				.add(goalMonth5)
				.add(goalMonth6)
				.add(goalMonth7)
				.add(goalMonth8)
				.add(goalMonth9)
				.add(goalMonth10)
				.add(goalMonth11)
				.add(goalMonth12)));
		rtnList.add(rtnIdx, goalMap);
		rtnIdx++;

		// 매출실적 합계
		Map<String, Object> salMap = new HashMap<>();
		salMap.put("MANAGE_NM","합계");
		salMap.put("CPO_YEAR", param.get("CPO_YEAR"));
		salMap.put("DATA_TYPE", "매출실적");
		salMap.put("DATA_1", df.format(salMonth1));
		salMap.put("DATA_2", df.format(salMonth2));
		salMap.put("DATA_3", df.format(salMonth3));
		salMap.put("DATA_4", df.format(salMonth4));
		salMap.put("DATA_5", df.format(salMonth5));
		salMap.put("DATA_6", df.format(salMonth6));
		salMap.put("DATA_7", df.format(salMonth7));
		salMap.put("DATA_8", df.format(salMonth8));
		salMap.put("DATA_9", df.format(salMonth9));
		salMap.put("DATA_10", df.format(salMonth10));
		salMap.put("DATA_11", df.format(salMonth11));
		salMap.put("DATA_12", df.format(salMonth12));
		salMap.put("DATA_SUM", df.format(salMonth1
				.add(salMonth2)
				.add(salMonth3)
				.add(salMonth4)
				.add(salMonth5)
				.add(salMonth6)
				.add(salMonth7)
				.add(salMonth8)
				.add(salMonth9)
				.add(salMonth10)
				.add(salMonth11)
				.add(salMonth12)));
		rtnList.add(rtnIdx, salMap);
		rtnIdx++;

		// 달성율 합계
		Map<String, Object> attMap = new HashMap<>();
		attMap.put("MANAGE_NM","합계");
		attMap.put("CPO_YEAR", param.get("CPO_YEAR"));
		attMap.put("DATA_TYPE", "달성율");
		attMap.put("DATA_1", attMonth1 + "%");
		attMap.put("DATA_2", attMonth2 + "%");
		attMap.put("DATA_3", attMonth3 + "%");
		attMap.put("DATA_4", attMonth4 + "%");
		attMap.put("DATA_5", attMonth5 + "%");
		attMap.put("DATA_6", attMonth6 + "%");
		attMap.put("DATA_7", attMonth7 + "%");
		attMap.put("DATA_8", attMonth8 + "%");
		attMap.put("DATA_9", attMonth9 + "%");
		attMap.put("DATA_10", attMonth10 + "%");
		attMap.put("DATA_11", attMonth11 + "%");
		attMap.put("DATA_12", attMonth12 + "%");
		attMap.put("DATA_SUM", df.format(attMonth1
				.add(attMonth2)
				.add(attMonth3)
				.add(attMonth4)
				.add(attMonth5)
				.add(attMonth6)
				.add(attMonth7)
				.add(attMonth8)
				.add(attMonth9)
				.add(attMonth10)
				.add(attMonth11)
				.add(attMonth12)) + "%");
		rtnList.add(rtnIdx, attMap);
		rtnIdx++;

		// 매출이익 합계
		Map<String, Object> profitMap = new HashMap<>();
		profitMap.put("MANAGE_NM","합계");
		profitMap.put("CPO_YEAR", param.get("CPO_YEAR"));
		profitMap.put("DATA_TYPE", "매출이익");
		profitMap.put("DATA_1", df.format(profitMonth1));
		profitMap.put("DATA_2", df.format(profitMonth2));
		profitMap.put("DATA_3", df.format(profitMonth3));
		profitMap.put("DATA_4", df.format(profitMonth4));
		profitMap.put("DATA_5", df.format(profitMonth5));
		profitMap.put("DATA_6", df.format(profitMonth6));
		profitMap.put("DATA_7", df.format(profitMonth7));
		profitMap.put("DATA_8", df.format(profitMonth8));
		profitMap.put("DATA_9", df.format(profitMonth9));
		profitMap.put("DATA_10", df.format(profitMonth10));
		profitMap.put("DATA_11", df.format(profitMonth11));
		profitMap.put("DATA_12", df.format(profitMonth12));
		profitMap.put("DATA_SUM", df.format(profitMonth1
				.add(profitMonth2)
				.add(profitMonth3)
				.add(profitMonth4)
				.add(profitMonth5)
				.add(profitMonth6)
				.add(profitMonth7)
				.add(profitMonth8)
				.add(profitMonth9)
				.add(profitMonth10)
				.add(profitMonth11)
				.add(profitMonth12)));
		rtnList.add(rtnIdx, profitMap);
		rtnIdx++;

		// 매출이익률 합계
		Map<String, Object> profitRateMap = new HashMap<>();
		profitRateMap.put("MANAGE_NM","합계");
		profitRateMap.put("CPO_YEAR", param.get("CPO_YEAR"));
		profitRateMap.put("DATA_TYPE", "매출이익률");
		profitRateMap.put("DATA_1", profitRateMonth1 + "%");
		profitRateMap.put("DATA_2", profitRateMonth2 + "%");
		profitRateMap.put("DATA_3", profitRateMonth3 + "%");
		profitRateMap.put("DATA_4", profitRateMonth4 + "%");
		profitRateMap.put("DATA_5", profitRateMonth5 + "%");
		profitRateMap.put("DATA_6", profitRateMonth6 + "%");
		profitRateMap.put("DATA_7", profitRateMonth7 + "%");
		profitRateMap.put("DATA_8", profitRateMonth8 + "%");
		profitRateMap.put("DATA_9", profitRateMonth9 + "%");
		profitRateMap.put("DATA_10", profitRateMonth10 + "%");
		profitRateMap.put("DATA_11", profitRateMonth11 + "%");
		profitRateMap.put("DATA_12", profitRateMonth12 + "%");
		profitRateMap.put("DATA_SUM", df.format(profitRateMonth1
				.add(profitRateMonth2)
				.add(profitRateMonth3)
				.add(profitRateMonth4)
				.add(profitRateMonth5)
				.add(profitRateMonth6)
				.add(profitRateMonth7)
				.add(profitRateMonth8)
				.add(profitRateMonth9)
				.add(profitRateMonth10)
				.add(profitRateMonth11)
				.add(profitRateMonth12)) + "%");
		rtnList.add(rtnIdx, profitRateMap);

		return rtnList;
	}

	public Map<String, Object> setDateParam(Map<String, Object> sParam) {

		String dateSel = EverString.nullToEmptyString(sParam.get("DATE_SEL"));
		// 1달
		if(dateSel.equals("D")) {
			String eDay = "";
			if(sParam.get("MONTH").equals("01") || sParam.get("MONTH").equals("03") || sParam.get("MONTH").equals("05")
					|| sParam.get("MONTH").equals("07") || sParam.get("MONTH").equals("08") || sParam.get("MONTH").equals("10") || sParam.get("MONTH").equals("12")) {
				eDay = "31";
			} else if(sParam.get("MONTH").equals("02")) {
				int year = Integer.parseInt(EverDate.getYear());
				GregorianCalendar gc = new GregorianCalendar();
				if (gc.isLeapYear(year)) {
					eDay = "29"; // 윤년
				} else {
					eDay = "28"; // 평년
				}
			} else {
				eDay = "30";
			}
			sParam.put("START_DATE", String.valueOf(sParam.get("MYEAR")) + String.valueOf(sParam.get("MONTH")) + "01");
			sParam.put("END_DATE", String.valueOf(sParam.get("MYEAR")) + String.valueOf(sParam.get("MONTH")) + eDay);
		}
		// 분기
		else if(dateSel.equals("W")) {
			String quarter = EverString.nullToEmptyString(sParam.get("QUARTER"));
			if(quarter.equals("Q1")) {
				sParam.put("START_DATE", sParam.get("QYEAR") + "0101");
				sParam.put("END_DATE", sParam.get("QYEAR") + "0331");
			} else if(quarter.equals("Q2")) {
				sParam.put("START_DATE", sParam.get("QYEAR") + "0401");
				sParam.put("END_DATE", sParam.get("QYEAR") + "0630");
			} else if(quarter.equals("Q3")) {
				sParam.put("START_DATE", sParam.get("QYEAR") + "0701");
				sParam.put("END_DATE", sParam.get("QYEAR") + "0930");
			} else if(quarter.equals("Q4")) {
				sParam.put("START_DATE", sParam.get("QYEAR") + "1001");
				sParam.put("END_DATE", sParam.get("QYEAR") + "1231");
			}
		}
		// 반기
		else if(dateSel.equals("B")) {
			String halfYear = EverString.nullToEmptyString(sParam.get("HALF_YEAR"));
			if(halfYear.equals("H1")) {
				sParam.put("START_DATE", sParam.get("HYEAR") + "0101");
				sParam.put("END_DATE", sParam.get("HYEAR") + "0630");
			} else if(halfYear.equals("H2")) {
				sParam.put("START_DATE", sParam.get("HYEAR") + "0701");
				sParam.put("END_DATE", sParam.get("HYEAR") + "1231");
			}
		}
		// 년
		else if(dateSel.equals("M")) {
			sParam.put("START_DATE", sParam.get("YEAR") + "0101");
			sParam.put("END_DATE", sParam.get("YEAR") + "1231");
		}
		sParam.put("START_RANGE", ((sParam.get("START_RANGE") == null || EverString.nullToEmptyString(sParam.get("START_RANGE")).equals("")) ? "0" : sParam.get("START_RANGE")));
		return sParam;
	}

	public static long monthsBetween(Date baseDate, Date dateToSubstract) {

	    long baseDay = 24 * 60 * 60 * 1000; 	// 일
		long baseMonth = baseDay * 30;		// 월
	    long calDate = dateToSubstract.getTime() - baseDate.getTime();
	    long diffMonth = calDate/baseMonth;

	    return diffMonth;
	}

	public String comboResultSearch() throws JsonProcessingException {
		ObjectMapper om = new ObjectMapper();
		return EverString.rePreventSqlInjection(om.writeValueAsString(my03_Mapper.comboResultSearch()));
	}

}