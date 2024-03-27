package com.st_ones.evermp.BGA2.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BGA2.service.BGA2_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/evermp/BGA2")
public class BGA2_Controller extends BaseController{

	@Autowired private CommonComboService commonComboService;
	@Autowired private BGA2_Service bga2_Service;
	@Autowired private MessageService msg;
	@Autowired private DocNumService docNumService;


	/** ******************************************************************************************
     * 재고관리 > 출하관리 > 출하 확정 (BGA2_010)
     * @param req
     * @return String
     * @throws Exception
     */
	@RequestMapping(value="/BGA2_010/view")
	public String BGA2_010(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
	       if(!"C".equals(userInfo.getUserType())) {
	          return "/eversrm/noSuperAuth";
	        }

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("form", req.getParamDataMap());

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

		return "/evermp/BGA2/BGA2_010";
	}

	@RequestMapping(value = "/bga2010_doSearch")
	public void bga2010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		 resp.setGridObject("grid", bga2_Service.bga2010_doSearch(req.getFormData()));

	}
	//출하확정
	@RequestMapping(value = "/bga2010_doGiSave")
	public void bga2010_doGrSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String GI_NO = docNumService.getDocNumber("GI"); //출고번호채번

		for(Map<String, Object> gridData : gridList) {
			gridData.put("GI_NO", GI_NO);

			bga2_Service.bga2010_doGiSave(gridData, form);
		}

		String rtnMsg = msg.getMessageByScreenId("BGA2_010", "005");
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
	 * 재고관리 > 출하관리 > 출하 상세 내역 (BGA2_020)
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/BGA2_020/view")
	public String BGA2_020(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
	    if(!"C".equals(userInfo.getUserType())) {
	       return "/eversrm/noSuperAuth";
	       }

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

		return "/evermp/BGA2/BGA2_020";
	}
	@RequestMapping(value = "/bga2020_doSearch")
	public void bga2020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bga2_Service.bga2020_doSearch(req.getFormData()));
	}

	//출하확정취소
	@RequestMapping(value = "/BGA2020_doGiCancel")
	public void bga2020_doGrCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		String rtnMsg = bga2_Service.bga2020_doGrCancel(gridList, form);

		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
	 * 재고관리 >  VMI출하내역조회(공급사)
	 * @param req
	 * @return String
	 * @throws Exception
	 */

	@RequestMapping(value="/BGA2_030/view")
	public String BGA2_030(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());

		return "/evermp/BGA2/BGA2_030";
	}
	@RequestMapping(value = "/bga2030_doSearch")
	public void bga2030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bga2_Service.bga2030_doSearch(req.getFormData()));
	}
}
