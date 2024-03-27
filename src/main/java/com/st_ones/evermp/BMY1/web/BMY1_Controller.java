package com.st_ones.evermp.BMY1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BMY1.service.BMY1_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : BMY1_Controller.java 
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see 
 */

@Controller
@RequestMapping(value = "/evermp/BMY1")
public class BMY1_Controller extends BaseController {

	@Autowired private BMY1_Service bmy1_Service;
	
	@Autowired private CommonComboService commonComboService;
	
	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 고객사, 협력사 공지사항
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BMY1_050/view")
	public String my01001_view(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.addDateMonth(EverDate.getDate(), 2));
		
		return "/evermp/BMY1/BMY1_050";
	}

	@RequestMapping(value = "/bmy1050_doSearch")
	public void bmy1050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bmy1_Service.bmy1050_doSearch(req.getFormData()));
	}


	/** ******************************************************************************************
	 * 고객사, Mysite관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/BMY1_040/view")
	public String bmy1_040_view(EverHttpRequest req) throws Exception {

		return "/evermp/BMY1/BMY1_040";
	}

	@RequestMapping(value = "/bmy1040_doSearch")
	public void bmy1040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bmy1_Service.bmy1040_doSearch(req.getFormData()));
	}

}
