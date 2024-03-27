package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0350Controller  extends BaseController {


	@Autowired private CommonComboService commonComboService;

	@Autowired private LargeTextService largeTextService;

	@Autowired private MessageService messageService;

	@Autowired private CT0300Service ct0300service;


	// 계약대기현황
	@RequestMapping(value = "/CT0350/view")
	public String ecoa0040_View(EverHttpRequest req) {


		req.setAttribute("fromDate", EverDate.addDays(-14));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/buyer/cont/CT0350";
	}

	// 계약대기현황 - 조회
	@RequestMapping(value = "/CT0350/doSearch")
	public void ecoa0040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> list = ct0300service.getValidTargetContList(req.getFormData());
		String color = "";
        for(int k=0; k<list.size(); k++) {

            if(  Float.parseFloat( list.get(k).get("REMAIN_DAY").toString()  ) < 14  ){
                color = "#FF0000";
            } else {
                color = "#0000ff";
            }

            resp.setGridCellStyle("grid", String.valueOf(k), "REMAIN_DAY" , "color", color);

        }





		resp.setGridObject("grid", list);
	}

}
