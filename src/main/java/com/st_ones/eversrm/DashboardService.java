package com.st_ones.eversrm;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "dashboardService")
public class DashboardService {

    @Autowired private MessageService messageService;

    @Autowired DashboardMapper dashboardMapper;

	public List<Map<String, Object>> doNotice(Map<String, String> param) throws Exception {
    	return dashboardMapper.doNotice(param);
    }

    public List<Map<String, Object>> doFaq(Map<String, String> param) throws Exception {
    	return dashboardMapper.doFaq(param);
    }

    public List<Map<String, Object>> doQna(Map<String, String> param) throws Exception {
    	return dashboardMapper.doQna(param);
    }

	public List<Map<String, Object>> doNewgrid(Map<String, String> param) throws Exception {
		return dashboardMapper.doNewgrid(param);
	}

	public List<Map<String, Object>> doBggrid(Map<String, String> param) throws Exception {
		return dashboardMapper.doBggrid(param);
	}

    /**
     * 대시보드 데이터를 가져오는 메서드입니다.
     * 왼쪽트리메뉴의 메뉴명과 동일한 메뉴명을 getTableHtml()의 2번쨰 파라미터에 넘겨야 데이터 클릭 시 해당 메뉴가 새로운 탭으로 열립니다.
     * @param division
     * @return
     */
	public String getTodo(String division) {

		Map<String, String> paramMap = new HashMap<String, String>();
		StringBuilder html = new StringBuilder();
		html.append("<table>");
		html.append("<colgroup><col width='70%'><col></colgroup>");
//		if(StringUtils.equals(division, "1")) {
//			html = getTableHtml(html, "SM","유지보수",
//					new String[]{"관계사 유지보수 등록요청", dashboardMapper.summary01(paramMap)},
//					new String[]{"유지보수 등록 진행현황", dashboardMapper.summary02(paramMap)},
//					new String[]{"유지보수 계약현황", dashboardMapper.summary03(paramMap)},
//					new String[]{"유지보수 계약 중단요청", dashboardMapper.summary04(paramMap)},
//					new String[]{"사전견적 요청현황", dashboardMapper.summary05(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "2")) {
//			html = getTableHtml(html,  "BM","영업관리",
//					new String[]{"발주/계약요청", dashboardMapper.summary06(paramMap)},
//					new String[]{"협력회사서명대기", dashboardMapper.summary07(paramMap)},
//					new String[]{"당사서명대기", dashboardMapper.summary08(paramMap)},
//					new String[]{"발주계약반송", dashboardMapper.summary09(paramMap)},
//					new String[]{"변동계약요청", dashboardMapper.summary10(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "3")) {
//			html = getTableHtml(html, "PR","구매관리",
//					new String[]{"발주/계약요청", dashboardMapper.summary10(paramMap)},
//					new String[]{"협력회사서명대기", dashboardMapper.summary10(paramMap)},
//					new String[]{"당사서명대기", dashboardMapper.summary10(paramMap)},
//					new String[]{"발주계약반송", dashboardMapper.summary10(paramMap)},
//					new String[]{"변동계약요청", dashboardMapper.summary10(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "4")) {
//			html = getTableHtml(html, "STM","재고관리",
//					new String[]{"발주/계약요청", dashboardMapper.summary08(paramMap)},
//					new String[]{"협력회사서명대기", dashboardMapper.summary08(paramMap)},
//					new String[]{"당사서명대기", dashboardMapper.summary08(paramMap)},
//					new String[]{"발주계약반송", dashboardMapper.summary08(paramMap)},
//					new String[]{"변동계약요청", dashboardMapper.summary08(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "5")) {
//			html = getTableHtml(html, "FM","여신/채권 정산",
//					new String[]{"발주/계약요청", dashboardMapper.summary04(paramMap)},
//					new String[]{"협력회사서명대기", dashboardMapper.summary05(paramMap)},
//					new String[]{"당사서명대기", dashboardMapper.summary06(paramMap)},
//					new String[]{"발주계약반송", dashboardMapper.summary07(paramMap)},
//					new String[]{"변동계약요청", dashboardMapper.summary08(paramMap)},
//					new String[]{"변동계약요청2", dashboardMapper.summary08(paramMap)},
//					new String[]{"변동계약요청3", dashboardMapper.summary08(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "6")) {
//			html = getTableHtml(html, "ST","기타업무",
//					new String[]{"발주계약반송", dashboardMapper.summary09(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "7")) {
//			html = getTableHtml(html, "AD","기준정보",
//					new String[]{"발주/계약요청", dashboardMapper.summary01(paramMap)},
//					new String[]{"협력회사서명대기", dashboardMapper.summary02(paramMap)},
//					new String[]{"당사서명대기", dashboardMapper.summary03(paramMap)},
//					new String[]{"발주계약반송", dashboardMapper.summary04(paramMap)},
//					new String[]{"변동계약요청", dashboardMapper.summary05(paramMap)}
//			);
//		} else if(StringUtils.equals(division, "8")) {
//			html = getTableHtml(html, "MA","시스템관리",
//					new String[]{"발주/계약요청", dashboardMapper.summary03(paramMap)},
//					new String[]{"협력회사서명대기", dashboardMapper.summary04(paramMap)},
//					new String[]{"당사서명대기", dashboardMapper.summary05(paramMap)},
//					new String[]{"발주계약반송", dashboardMapper.summary06(paramMap)},
//					new String[]{"변동계약요청", dashboardMapper.summary07(paramMap)}
//			);
//		}
		html.append("</table>");
		return html.toString();
	}

	private StringBuilder getTableHtml(StringBuilder html, String moduleType, String moduleTypeTitle, String[]... detail) {

	    int count = 0;

        StringBuilder itemHtml = new StringBuilder();
        for (String[] dtl : detail) {
            count += Integer.parseInt(dtl[1]);
//            itemHtml.append("<tr><td>").append(dtl[0]).append("</td><td id=\"").append(moduleType).append("\">").append(ContStringUtil.toPositionalNumber(dtl[1])).append("</td></tr>");
        }


//		html.append("<tr><th colspan='2'>").append("<a href=\"javascript:top.fetchLeftMenu('"+moduleType+"');\">").append(moduleTypeTitle).append("</a>").append("<div>")
//				.append(ContStringUtil.toPositionalNumber(String.valueOf(count)))
//				.append("</div>").append("</th></tr>");
//        html.append(itemHtml);

		return html;
	}

	// 공급사 대쉬보드의 관리현황 건수
	public Map<String, String> mypageTypeB(Map<String, String> param) throws Exception {
		param.put("summary1_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary1_dateTo",EverDate.getDate());
		param.put("summary2_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary2_dateTo",EverDate.getDate());
		param.put("summary3_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary3_dateTo",EverDate.getDate());
		param.put("summary4_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary4_dateTo",EverDate.getDate());


		param.put("summary5_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary5_dateTo",EverDate.getDate());

		param.put("summary6_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary6_dateTo",EverDate.getDate());






		return dashboardMapper.mypageTypeB(param);
	}

	// 공급사 대쉬보드의 관리현황 건수
	public Map<String, String> mypageTypeS(Map<String, String> param) throws Exception {
		param.put("summary1_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -3));
		param.put("summary1_dateTo",EverDate.addDateMonth(EverDate.getDate(), 1));

		param.put("summary2_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary2_dateTo",EverDate.addDays(5));

		param.put("summary3_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary3_dateTo",EverDate.addDays(14));

		param.put("summary4_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary4_dateTo",EverDate.getDate());

		param.put("summary5_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary5_dateTo",EverDate.getDate());

		param.put("summary6_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -2));
		param.put("summary6_dateTo",EverDate.getDate());



		Map<String, String> dashBoardMap = dashboardMapper.mypageTypeS(param);

		return dashBoardMap;
	}

	// 고객사 대쉬보드의 관리현황 건수
	public Map<String, String> mypageTypeC(Map<String, String> param) throws Exception {
		param.put("summary1_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -3));
		param.put("summary1_dateTo",EverDate.getDate());
		param.put("summary2_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -3));
		param.put("summary2_dateTo",EverDate.addDateMonth(EverDate.getDate(), 1));
		param.put("summary3_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -3));
		param.put("summary3_dateTo",EverDate.addDateMonth(EverDate.getDate(), 1));
		param.put("summary4_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary4_dateTo",EverDate.getDate());
		param.put("summary5_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary5_dateTo",EverDate.getDate());
		param.put("summary6_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary6_dateTo",EverDate.getDate());
		param.put("summary7_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary7_dateTo",EverDate.getDate());

		param.put("summary8_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary8_dateTo",EverDate.addDays(7));

		param.put("summary9_dateFrom",EverDate.addMonths(-12));
		param.put("summary9_dateTo",EverDate.getDate());

		param.put("summary10_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary10_dateTo",EverDate.getDate());

		param.put("summary11_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary11_dateTo",EverDate.getDate());

		param.put("summary12_dateFrom",EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("summary12_dateTo",EverDate.getDate());

		return dashboardMapper.mypageTypeC(param);
	}

	public List<Map<String, String>> getNoitceListMain(Map<String, String> param) throws Exception {
		return dashboardMapper.getNoitceListMain(param);
	}

	public List<Map<String, String>> getVoiceListMain(Map<String, String> param) throws Exception {
		return dashboardMapper.getVoiceListMain(param);
	}
	
	// 내 메뉴 목록 가져오기
	public String getMyScreenId(Map<String, Object> param){
        return dashboardMapper.getMyScreenId(param);
    }

	// 고객사 대쉬보드의 취급품목(품목분류조회)
	public List<Map<String, String>> getItemClsList(Map<String, String> param) throws Exception {
		return dashboardMapper.getItemClsList(param);
	}

    public List<Map<String, Object>> doMygrid(Map<String, String> param) throws Exception {
		return dashboardMapper.doMygrid(param);
    }

    public List<Map<String, Object>> doOpGrid1(Map<String, String> param) throws Exception {
	    return dashboardMapper.doOpGrid1(param);
    }

    public List<Map<String, Object>> doOpGrid2(Map<String, String> param) throws Exception {
        return dashboardMapper.doOpGrid2(param);
    }

    public List<Map<String, Object>> doOpGrid3(Map<String, String> param) throws Exception {
		List<Map<String, Object>> list = dashboardMapper.doOpGrid3(param);
		List<Map<String, Object>> stock = dashboardMapper.doOpGrid3_1(param);
		List<Map<String, Object>> stock2 = dashboardMapper.doOpGrid3_2(param);

		Map<String, Object> map = stock.get(0);
		Map<String, Object> ma2 = new HashMap<>();
		String amt2 = EverString.nullToEmptyString(map.get("AMT"));
		ma2.put("AMT_TITLE", "");
		ma2.put("AMT", amt2);
		list.add(ma2);
		String amt = map.get("AMT") + "(" + stock2.get(0).get("AMT") + ") 원";
		map.put("AMT", amt);
		list.add(map);



        return list;
    }

    public List<Map<String, Object>> doOpGrid4(Map<String, String> param) throws Exception {
        return dashboardMapper.doOpGrid4(param);
    }

    public List<Map<String, Object>> doOpGrid5(Map<String, String> param) throws Exception {
        return dashboardMapper.doOpGrid5(param);
    }

	public List<Map<String, Object>> doOpGrid6(Map<String, String> param) throws Exception {
		return dashboardMapper.doOpGrid6(param);
	}

	public List<Map<String, Object>> doOpGrid7(Map<String, String> param) throws Exception {
		return dashboardMapper.doOpGrid7(param);
	}
}
