package com.st_ones.evermp.MY03.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.MY03.service.MY03_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : MY03_Controller.java
 * @date 2018. 02. 06.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/MY03")
public class MY03_Controller extends BaseController {

	@Autowired private MY03_Service my03_Service;

	@Autowired private CommonComboService commonComboService;

	/** ******************************************************************************************
     * 소싱리드타임
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY03_010/view")
	public String MY03_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자

        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/MY03/MY03_010";
	}

	@RequestMapping(value = "/my03010_doSearch")
	public void my03010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03010_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
     * 품목생성 리드타임
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY03_020/view")
	public String MY03_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화담당자

        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/MY03/MY03_020";
	}

	@RequestMapping(value = "/my03020_doSearch")
	public void my03020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03020_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
     * 납품리드타임
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY03_030/view")
	public String MY03_030(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //구매담당자

        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/MY03/MY03_030";
	}

	@RequestMapping(value = "/my03030_doSearch")
	public void my03030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03030_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
     * 납기준수율
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY03_040/view")
	public String MY03_040(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자

        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/MY03/MY03_040";
	}

	@RequestMapping(value = "/my03040_doSearch")
	public void my03040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03040_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 고객사별 실적분석
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_050/view")
	public String MY03_050(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "B100");

		req.setAttribute("MANAGE_ID_OPTIONS", commonComboService.getCodesAsJson("CB0064", param));

		String thisMonth = EverDate.getMonth();
		String thisHalfYear = (thisMonth.equals("01") || thisMonth.equals("02") || thisMonth.equals("03") || thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) ? "H1" : "H2";
		String thisQuarter = "Q1";
		if(thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) {
			thisQuarter = "Q2";
		} else if(thisMonth.equals("07") || thisMonth.equals("08") || thisMonth.equals("09")) {
			thisQuarter = "Q3";
		} else if(thisMonth.equals("10") || thisMonth.equals("11") || thisMonth.equals("12")) {
			thisQuarter = "Q4";
		}

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("thisYear", EverDate.getYear());
		req.setAttribute("thisMonth", thisMonth);
		req.setAttribute("thisHalfYear", thisHalfYear);
		req.setAttribute("thisQuarter", thisQuarter);

		return "/evermp/MY03/MY03_050";
	}

	@RequestMapping(value = "/my03050_doSearch")
	public void my03050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03050_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 공급사별 실적분석
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_060/view")
	public String MY03_060(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "B100");

		req.setAttribute("MANAGE_ID_OPTIONS", commonComboService.getCodesAsJson("CB0064", param));

		String thisMonth = EverDate.getMonth();
		String thisHalfYear = (thisMonth.equals("01") || thisMonth.equals("02") || thisMonth.equals("03") || thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) ? "H1" : "H2";
		String thisQuarter = "Q1";
		if(thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) {
			thisQuarter = "Q2";
		} else if(thisMonth.equals("07") || thisMonth.equals("08") || thisMonth.equals("09")) {
			thisQuarter = "Q3";
		} else if(thisMonth.equals("10") || thisMonth.equals("11") || thisMonth.equals("12")) {
			thisQuarter = "Q4";
		}

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("thisYear", EverDate.getYear());
		req.setAttribute("thisMonth", thisMonth);
		req.setAttribute("thisHalfYear", thisHalfYear);
		req.setAttribute("thisQuarter", thisQuarter);

		return "/evermp/MY03/MY03_060";
	}

	@RequestMapping(value = "/my03060_doSearch")
	public void my03060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03060_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 품목별 실적분석
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_070/view")
	public String MY03_070(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		req.setAttribute("thisYear", EverDate.getYear());

		return "/evermp/MY03/MY03_070";
	}

	@RequestMapping(value = "/my03070_doSearch")
	public void my03070_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03070_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 일자별접속현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_080/view")
	public String MY03_080(EverHttpRequest req) throws Exception {
		req.setAttribute("JOB_DATE_FROM", EverDate.getDate());
		req.setAttribute("JOB_DATE_TO", EverDate.getDate());

		return "/evermp/MY03/MY03_080";
	}

	@RequestMapping(value = "/my03080_doSearch")
	public void my03080_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03080_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 고객사별 매출계획
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_090/view")
	public String MY03_090(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		Map<String, String> codeParam = new HashMap<String, String>();
		codeParam.put("GATE_CD",  userInfo.getGateCd());
		codeParam.put("BUYER_CD", userInfo.getManageCd());
		codeParam.put("CTRL_CD",  "B100");
		req.setAttribute("custMngId", commonComboService.getCodesAsJson("CB0064", codeParam));
		req.setAttribute("comboResult", my03_Service.comboResultSearch());
		req.setAttribute("thisYear", EverDate.getYear());

		return "/evermp/MY03/MY03_090";
	}

	@RequestMapping(value = "/my03090_doSearch")
	public void my03090_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("THIS_YEAR", EverDate.getYear());
		param.put("MANAGE_ID", EverString.nullToEmptyString(req.getParameter("manageId")));

		String searchType = EverString.nullToEmptyString(req.getParameter("searchType"));
		if(searchType.equals("G")) {
			param.put("YEAR", EverString.nullToEmptyString(req.getParameter("year")));
			param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("custCd")));
			param.put("CUST_NM", "");
			param.put("RELAT_YN", "");
			param.put("PROGRESS_CD", "");
			param.put("MANAGE_ID", "");
		}

		List<Map<String, Object>> rtnList = my03_Service.my03090_doSearch(param);

		if(searchType.equals("G")) {
			Map<String, Object> rtnData = new HashMap<String, Object>();
			if (rtnList.size() > 0) {
				rtnData = rtnList.get(0);
				resp.setParameter("rtnData", new ObjectMapper().writeValueAsString(rtnData));
			}
		} else {
			resp.setGridObject("grid", rtnList);
		}
	}

	@RequestMapping(value = "/my03090_doSave")
	public void my03090_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("progressCd")));

		List<Map<String, Object>> gridData = req.getGridData("grid");

		String msg = my03_Service.my03090_doSave(formData, gridData);
		resp.setResponseMessage(msg);
	}

	/** ******************************************************************************************
	 * 고객사별 매출현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_091/view")
	public String MY03_091(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		String thisMonth = EverDate.getMonth();
		String thisHalfYear = (thisMonth.equals("01") || thisMonth.equals("02") || thisMonth.equals("03") || thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) ? "H1" : "H2";
		String thisQuarter = "Q1";
		if(thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) {
			thisQuarter = "Q2";
		} else if(thisMonth.equals("07") || thisMonth.equals("08") || thisMonth.equals("09")) {
			thisQuarter = "Q3";
		} else if(thisMonth.equals("10") || thisMonth.equals("11") || thisMonth.equals("12")) {
			thisQuarter = "Q4";
		}

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("thisYear", EverDate.getYear());
		req.setAttribute("thisMonth", thisMonth);
		req.setAttribute("thisHalfYear", thisHalfYear);
		req.setAttribute("thisQuarter", thisQuarter);
		return "/evermp/MY03/MY03_091";
	}

	@RequestMapping(value = "/my03091_doSearch")
	public void my03091_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03091_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 고객사별 매출예상현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_095/view")
	public String MY03_095(EverHttpRequest req) throws Exception {

		String thisMonth = EverDate.getMonth();
		String thisHalfYear = (thisMonth.equals("01") || thisMonth.equals("02") || thisMonth.equals("03") || thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) ? "H1" : "H2";
		String thisQuarter = "Q1";
		if(thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) {
			thisQuarter = "Q2";
		} else if(thisMonth.equals("07") || thisMonth.equals("08") || thisMonth.equals("09")) {
			thisQuarter = "Q3";
		} else if(thisMonth.equals("10") || thisMonth.equals("11") || thisMonth.equals("12")) {
			thisQuarter = "Q4";
		}

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("thisYear", EverDate.getYear());
		req.setAttribute("thisMonth", thisMonth);
		req.setAttribute("thisHalfYear", thisHalfYear);
		req.setAttribute("thisQuarter", thisQuarter);
		return "/evermp/MY03/MY03_095";
	}

	@RequestMapping(value = "/my03095_doSearch")
	public void my03095_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03095_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 고객사별 상품 매출현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_092/view")
	public String MY03_092(EverHttpRequest req) throws Exception {

		String thisMonth = EverDate.getMonth();
		String thisHalfYear = (thisMonth.equals("01") || thisMonth.equals("02") || thisMonth.equals("03") || thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) ? "H1" : "H2";
		String thisQuarter = "Q1";
		if(thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) {
			thisQuarter = "Q2";
		} else if(thisMonth.equals("07") || thisMonth.equals("08") || thisMonth.equals("09")) {
			thisQuarter = "Q3";
		} else if(thisMonth.equals("10") || thisMonth.equals("11") || thisMonth.equals("12")) {
			thisQuarter = "Q4";
		}

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("thisYear", EverDate.getYear());
		req.setAttribute("thisMonth", thisMonth);
		req.setAttribute("thisHalfYear", thisHalfYear);
		req.setAttribute("thisQuarter", thisQuarter);
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("nowDate", EverDate.getDate());
		return "/evermp/MY03/MY03_092";
	}

	@RequestMapping(value = "/my03092_doSearch")
	public void my03092_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03092_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 상품별 매출 이익율 관리현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_093/view")
	public String MY03_093(EverHttpRequest req) throws Exception {

		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
	    req.setAttribute("addToDate", EverDate.getDate());
		return "/evermp/MY03/MY03_093";
	}

	@RequestMapping(value = "/my03093_doSearch")
	public void my03093_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03093_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 매출실적 및 매출이익
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_094/view")
	public String MY03_094(EverHttpRequest req) throws Exception {
		req.setAttribute("thisYear", EverDate.getYear());
		return "/evermp/MY03/MY03_094";
	}

	@RequestMapping(value = "/my03094_doSearch")
	public void my03094_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my03_Service.my03094_doSearch(req.getFormData()));
	}
	/** ******************************************************************************************
	 * 고객사별 계획대비 매출현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/MY03_096/view")
	public String MY03_096(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		String thisMonth = EverDate.getMonth();
		String thisHalfYear = (thisMonth.equals("01") || thisMonth.equals("02") || thisMonth.equals("03") || thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) ? "H1" : "H2";
		String thisQuarter = "Q1";
		if(thisMonth.equals("04") || thisMonth.equals("05") || thisMonth.equals("06")) {
			thisQuarter = "Q2";
		} else if(thisMonth.equals("07") || thisMonth.equals("08") || thisMonth.equals("09")) {
			thisQuarter = "Q3";
		} else if(thisMonth.equals("10") || thisMonth.equals("11") || thisMonth.equals("12")) {
			thisQuarter = "Q4";
		}

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("thisYear", EverDate.getYear());
		req.setAttribute("thisMonth", thisMonth);
		req.setAttribute("thisHalfYear", thisHalfYear);
		req.setAttribute("thisQuarter", thisQuarter);
		return "/evermp/MY03/MY03_096";
	}
	@RequestMapping(value = "/my03096_doSearch")
	public void my03096_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData= req.getFormData();
		formData.put("SCR_ID","MY03096");
		resp.setGridObject("grid", my03_Service.my03091_doSearch(formData));
	}

}