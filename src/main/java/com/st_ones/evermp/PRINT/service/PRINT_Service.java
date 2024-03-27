package com.st_ones.evermp.PRINT.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 17 오후 5:01
 */

import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.PRINT.PRINT_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "PRINT_Service")
public class PRINT_Service extends BaseService {

	@Autowired
	private PRINT_Mapper print_mapper;

	/**
	 * 거래명세서 HTML 정보 가져오기
	 * @param param
	 * @return
	 */
	public ArrayList<ArrayList<Map<String, Object>>> printHtmlInvoice(Map<String, Object> param) throws Exception {
		String screenId = String.valueOf(param.get("SCREEN_ID"));
		ArrayList<ArrayList<Map<String, Object>>> resultList = new ArrayList<ArrayList<Map<String, Object>>>();
		ArrayList<Map<String, Object>> tempList = new ArrayList<Map<String, Object>>();
		int slicePage = 10;

		// agent코드 = 운영사(1000)
		String DEFAULT_AGENT_CODE = PropertiesManager.getString("eversrm.default.company.code");
		param.put("DEFAULT_AGENT_CODE", DEFAULT_AGENT_CODE);

		List<Map<String, Object>> hdList = new ArrayList<Map<String, Object>>();
		// 1. 납품서 헤더 가져오기
		if("PRT_040".equals(screenId) || "PRT_041".equals(screenId)) {
			hdList = print_mapper.selectIVHD(param);
		} else if("PRT_042".equals(screenId)) {
			hdList = print_mapper.selectUIVHD(param);
		}else if("PRT_041_DGNS".equals(screenId)) {
			hdList = print_mapper.selectIVHD_DGNS(param);
		} else if("PRT_030".equals(screenId)) {
			hdList = print_mapper.selectCPOHD(param);
		} else if("PRT_031".equals(screenId)) {
			hdList = print_mapper.selectPOHD(param);
		} else if("PRT_020".equals(screenId)) {
			ArrayList<Map<String, Object>> rfqList = (ArrayList<Map<String, Object>>) param.get("RFQ_LIST");
			for(Map<String, Object> rfqMap : rfqList) {
				rfqMap.putAll(param);
				hdList.addAll(print_mapper.selectVRQHD(rfqMap));
			}
		} else if("PRT_021".equals(screenId)) {
			ArrayList<Map<String, Object>> rfqList = (ArrayList<Map<String, Object>>) param.get("RFQ_LIST");

			for(Map<String, Object> rfqMap : rfqList) {
				rfqMap.putAll(param);
				hdList.addAll(print_mapper.selectORQHD(rfqMap));
			}
		} else if("PRT_010".equals(screenId)) {
			ArrayList<Map<String, Object>> rfqList = (ArrayList<Map<String, Object>>) param.get("RFQ_LIST");

			for(Map<String, Object> rfqMap : rfqList) {
				rfqMap.putAll(param);
				hdList.addAll(print_mapper.selectNWRQHD(rfqMap));
			}
		} else if("PRT_050".equals(screenId)) {
			hdList = print_mapper.selectUPOHD(param);
		} else if("PRT_060".equals(screenId)) {
			hdList = print_mapper.selectTTIH(param);
		} else if("PRT_070".equals(screenId)) {
			ArrayList<Map<String, Object>> rfqList = (ArrayList<Map<String, Object>>) param.get("RFQ_LIST");
			for(Map<String, Object> rfqMap : rfqList) {
				rfqMap.putAll(param);
				hdList.addAll(print_mapper.selectOCNHD(rfqMap));
			}
		} else if("PRT_090".equals(screenId)) { //매출

			hdList = print_mapper.getTTIH(param);
		} else if("PRT_091".equals(screenId)) { // 매입

			hdList = print_mapper.getTTIH(param);
		}

		// 2. 거래명세서 속성정보 가져오기
		List<Map<String, Object>> langList = print_mapper.selectLANG(param);

		if(hdList.size() > 0) {
            for (Map<String, Object> hdMap : hdList) {
                for (Map<String, Object> langItem : langList) {
                    hdMap.put(langItem.get("MULTI_CD").toString(), langItem.get("MULTI_CONTENTS").toString());
                }

                // IVHDMAP 을 그냥 보낼 경우 _L, _R 데이터를 받아 데이터 파싱이 힘들어짐...
                Map<String, Object> paramMap = new HashMap<String, Object>(hdMap);

                List<Map<String, Object>> dtList = new ArrayList<Map<String, Object>>();
                // 3. 납품서 디테일 가져오기
                if("PRT_040".equals(screenId) || "PRT_041".equals(screenId)) {
                	paramMap.put("IF_INVC_CD",param.get("IF_INVC_CD"));
                    dtList = print_mapper.selectIVDT(paramMap);
                } else if("PRT_042".equals(screenId)) {
                	 paramMap.put("IF_INVC_CD",param.get("IF_INVC_CD"));
        			dtList = print_mapper.selectUIVDT(paramMap);
        		}else if("PRT_041_DGNS".equals(screenId)) {
	               	 paramMap.put("INV_NO",param.get("INV_NO"));
	       			dtList = print_mapper.selectIVDT_DGNS(paramMap);
        		} else if("PRT_030".equals(screenId)) {
                    dtList = print_mapper.selectCPODT(paramMap);
                } else if("PRT_031".equals(screenId)) {
                    dtList = print_mapper.selectPODT(paramMap);
                } else if("PRT_020".equals(screenId)) {
                    paramMap.put("VENDOR_CD", param.get("VENDOR_CD"));
                    dtList = print_mapper.selectVRQDT(paramMap);
                } else if("PRT_021".equals(screenId)) {
                    dtList = print_mapper.selectORQDT(paramMap);
                } else if("PRT_070".equals(screenId)) {
                    dtList = print_mapper.selectOCNDT(paramMap);
                } else if("PRT_010".equals(screenId)) {
                    dtList = print_mapper.selectNWRQDT(paramMap);
                    slicePage = 20;
                } else if("PRT_050".equals(screenId)) {
                    paramMap.putAll(param);
                    dtList = print_mapper.selectUPODT(paramMap);
                } else if("PRT_060".equals(screenId)) {
					tempList = new ArrayList<>();
					tempList.add(hdMap);
					resultList.add(tempList);
				} else if("PRT_090".equals(screenId)) { // 매출
                    slicePage = 15;
                    dtList = print_mapper.getTTID(paramMap);
				} else if("PRT_091".equals(screenId)) { // 매입
                    slicePage = 15;
                    dtList = print_mapper.getTTID(paramMap);
				}

                int i = 0;
                int pageCount = 1;
                double totalCount = dtList.size();
                int totalPageCount = (int) Math.ceil((totalCount / slicePage));
                for (Map<String, Object> dtMap : dtList) {
                    dtMap.putAll(hdMap);
                    dtMap.put("CURRENT_PAGE", pageCount);
                    dtMap.put("TOTAL_PAGE", totalPageCount);
                    dtMap.put("NUM", i + 1);
                    tempList.add(dtMap);

                    if( (i+1) % slicePage == 0 || i == dtList.size()-1) {
                        pageCount++;
                        resultList.add(tempList);
                        tempList = new ArrayList<Map<String, Object>>();
                    }
                    i++;
                }
            }
        } else {
            if("PRT_050".equals(screenId)) {
                List custList = (List) param.get("CUST_NM_LIST");

                for (int i = 0; i < custList.size(); i++) {
					tempList = new ArrayList<Map<String, Object>>();
					Map<String, Object> hdMap = new HashMap<String, Object>();

					for (Map<String, Object> langItem : langList) {
						hdMap.put(langItem.get("MULTI_CD").toString(), langItem.get("MULTI_CONTENTS").toString());
					}

					hdMap.put("H_CUST_NM", custList.get(i));
					tempList.add(hdMap);

                    resultList.add(tempList);
                }
            }
        }

		return resultList;
	}

	/**
	 * 수기견적서 HTML 정보 가공
	 * @param param
	 * @return
	 */
	public ArrayList<ArrayList<Map<String, Object>>> printHtmlDirectInvoice(Map<String, Object> param) throws Exception {

		String screenId = String.valueOf(param.get("SCREEN_ID"));
		ArrayList<ArrayList<Map<String, Object>>> resultList = new ArrayList<ArrayList<Map<String, Object>>>();
		ArrayList<Map<String, Object>> tempList = new ArrayList<Map<String, Object>>();
		int slicePage = 10;

		// agent코드 = 운영사(1000)
		String DEFAULT_AGENT_CODE = PropertiesManager.getString("eversrm.default.company.code");
		param.put("DEFAULT_AGENT_CODE", DEFAULT_AGENT_CODE);

		List<Map<String, Object>> hdList = new ArrayList<Map<String, Object>>();

		//헤더정보
		hdList = print_mapper.selectHD(param);

		// 2. 거래명세서 속성정보 가져오기
		List<Map<String, Object>> langList = print_mapper.selectLANG(param);

		for (Map<String, Object> hdMap : hdList) {
			for (Map<String, Object> langItem : langList) {
				hdMap.put(langItem.get("MULTI_CD").toString(), langItem.get("MULTI_CONTENTS").toString());
			}

			// IVHDMAP 을 그냥 보낼 경우 _L, _R 데이터를 받아 데이터 파싱이 힘들어짐...
			Map<String, Object> paramMap = new HashMap<String, Object>(hdMap);

			List<Map<String, Object>> dtList = new ArrayList<Map<String, Object>>();
			// 3. 품목 가져오기

			ArrayList<Map<String, Object>> itemList = (ArrayList<Map<String, Object>>) param.get("ITEM_LIST");

			int j = 1;
			int totalSum =0;
			int prcSum =0;
			for(Map<String, Object> listMap : itemList) {
				listMap.put("GRID_ITEM_NO",j);
				listMap.put("DT_ITEM_CD",listMap.get("ITEM_CD"));
				listMap.put("DT_ITEM_DESC",listMap.get("ITEM_DESC"));
				listMap.put("DT_UNIT_CD",listMap.get("UNIT_CD"));
				listMap.put("DT_ITEM_SPEC",listMap.get("ITEM_SPEC"));
				listMap.put("DT_ITEM_QTY", EverMath.EverNumberType(String.valueOf(listMap.get("ITEM_QTY")), "###,###"));
				listMap.put("DT_UNIT_PRC", EverMath.EverNumberType(String.valueOf(listMap.get("UNIT_PRICE")), "###,###"));
				listMap.put("DT_ITEM_PRC", EverMath.EverNumberType(String.valueOf(listMap.get("ITEM_PRC")), "###,###"));
				if(j>1){
					prcSum = prcSum + Integer.parseInt(String.valueOf(listMap.get("ITEM_PRC")));
					totalSum = totalSum + Integer.parseInt(String.valueOf(listMap.get("ITEM_QTY")));
				}else{
					prcSum = Integer.parseInt(String.valueOf(listMap.get("ITEM_PRC")));
					totalSum = Integer.parseInt(String.valueOf(listMap.get("ITEM_QTY")));
				}
				j++;
			}


			dtList.addAll(itemList);

			int i = 0;
			int pageCount = 1;
			double totalCount = dtList.size();
			int totalPageCount = (int) Math.ceil((totalCount / slicePage));
			for (Map<String, Object> dtMap : dtList) {
				dtMap.putAll(hdMap);
				dtMap.put("CURRENT_PAGE", pageCount);
				dtMap.put("TOTAL_PAGE", totalPageCount);
				dtMap.put("NUM", i + 1);
				dtMap.put("GROUP_AMT", EverMath.EverNumberType(String.valueOf(prcSum), "###,###"));
				dtMap.put("GROUP_CNT", EverMath.EverNumberType(String.valueOf(totalSum), "###,###"));
				dtMap.put("H_RMK", EverString.nToBr(EverString.nullToEmptyString(hdMap.get("H_REMARK"))));

				tempList.add(dtMap);

				if( (i+1) % slicePage == 0 || i == dtList.size()-1) {
					pageCount++;
					resultList.add(tempList);
					tempList = new ArrayList<Map<String, Object>>();
				}
				i++;
			}

		}

		return resultList;

	}
}
