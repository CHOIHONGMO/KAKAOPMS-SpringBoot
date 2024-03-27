package com.st_ones.evermp.BOD1.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BOD1.service.BOD105_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : BOD105_Controller.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/BOD1/BOD105")
public class BOD105_Controller extends BaseController {

	@Autowired private BOD105_Service bod105_Service;
	@Autowired private MessageService msg;

    /** ******************************************************************************************
     * 고객사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BOD1_050/view")
	public String BOD1_050(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	       return "/eversrm/noSuperAuth";
	  	      }

		// 2022.10.23 시스템관리자 권한(mng_yn=Y), 직무=T100(구매담당자), 직무=M100(업무관리자) 추가
		boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
		boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
		req.setAttribute("superUserFlag", superUserFlag);
		req.setAttribute("havePermission", havePermission);

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());

		return "/evermp/BOD1/BOD1_050";
	}

	@RequestMapping(value = "/BOD1_050/doSearch")
	public void bod1050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bod105_Service.bod1050_doSearch(req.getFormData()));
	}

	/**
	 * 주문이력관리(구.MP)
	 */
	@RequestMapping(value="/BOD1_060/view")
	public String BOD1_060(EverHttpRequest req) throws Exception {
		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("form", req.getParamDataMap());

		return "/evermp/BOD1/BOD1_060";
	}

	@RequestMapping(value = "/bod1060_doSearch")
	public void bod1060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", bod105_Service.bod1060_doSearch(param));
	}
}
