package com.st_ones.evermp.buyer.eval.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0110Controller  extends BaseController {
	@Autowired
	private CommonComboService commonComboService;

	@Autowired private EV0100Service ev0100service;



	@RequestMapping(value = "/EV0110/view")
	public String EV0110(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		req.setAttribute("itemKindCode", commonComboService.getCodeComboAsJson("M115"));
		req.setAttribute("itemMethodCode", commonComboService.getCodeComboAsJson("M116"));
		req.setAttribute("scaleTypeCode", commonComboService.getCodeComboAsJson("M117"));
		return "/evermp/buyer/eval/EV0110";
	}

	@RequestMapping(value = "/EV0110/doSearch")
	public void doSearchEvalItemMgt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		resp.setGridObject("gridMain", ev0100service.doSearchEvalItemMgt(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0110/doSearchDetail")
	public void doSearchEvalItemMgtDetail(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("EV_ITEM_NUM", req.getParameter("EV_ITEM_NUM"));

		if ("QUA".equals(param.get("EV_ITEM_METHOD_CD_R").toString())) {
			List<Map<String,Object>> gridQlyList = ev0100service.doSearchEvalItemMgtDetail(param);

			for(int i = 0; i < gridQlyList.size(); i++) {
				resp.setGridRowStyle("gridQly", String.valueOf(i), "text-decoration", "inherit");
				resp.setGridRowStyle("gridQly", String.valueOf(i), "background-color", "#fdd");
			}

			resp.setGridObject("gridQly", gridQlyList);

		} else {
			List<Map<String,Object>> gridQtyList = ev0100service.doSearchEvalItemMgtDetail2(param);

			for(int i = 0; i < gridQtyList.size(); i++) {
				resp.setGridRowStyle("gridQty", String.valueOf(i), "text-decoration", "inherit");
				resp.setGridRowStyle("gridQty", String.valueOf(i), "background-color", "#fdd");
			}

			resp.setGridObject("gridQty", gridQtyList);
		}
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0110/doSave")
	public void doSaveEvalItemMgt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();

		formData.put("exclusion", "true");

		List<Map<String, Object>> gridDatas = new ArrayList<Map<String, Object>>();


		System.err.println("================EV_ITEM_METHOD_CD_R="+formData.get("EV_ITEM_METHOD_CD_R"));
		System.err.println("================gridQly="+req.getGridData("gridQly").size());
		System.err.println("================gridQty="+req.getGridData("gridQty").size());




		if ("QUA".equals(formData.get("EV_ITEM_METHOD_CD_R").toString())) {
			gridDatas = req.getGridData("gridQly");
		} else {
			gridDatas = req.getGridData("gridQty");
		}




		String[] msg = ev0100service.doSaveEvalItemMgt(formData, gridDatas);
		resp.setParameter("paramEV_ITEM_NO", msg[0]);
		resp.setResponseMessage(msg[1]);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0110/changeComboItemKindL")
	public void changeComboItemKindL(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		if ("E".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M114")  );
		} else if("S".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M113")  );
		} else if("R".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P091")  );
		} else if("G".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P094")  );
		}
		resp.setResponseCode("true");
	}


	@RequestMapping(value = "/EV0110/getEvimType")
	public void getEvimType(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getParamDataMap();
        ObjectMapper om = new ObjectMapper();
        resp.setParameter("evimType",om.writeValueAsString(   ev0100service.getEvimType(param)   ));
		resp.setResponseCode("true");
	}







	@RequestMapping(value = "/EV0110/changeComboItemKindR")
	public void changeComboItemKindR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		if ("E".equals(param.get("EV_ITEM_KIND_CD_R").toString())) {
			resp.setParameter("itemTypeCode", commonComboService.getCodeComboAsJson("M114"));
		} else if("S".equals(param.get("EV_ITEM_KIND_CD_R"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M113")  );
		} else if("R".equals(param.get("EV_ITEM_KIND_CD_R"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P091")  );
		} else if("G".equals(param.get("EV_ITEM_KIND_CD_R"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P094")  );
		}

		resp.setResponseCode("true");
	}


	@RequestMapping(value = "/EV0110/changeComboItemKindValue")
	public void changeComboItemKindValue(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("EV_ITEM_KIND_CD", req.getParameter("EV_ITEM_KIND_CD"));

		if ("E".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M114")  );
		} else if("S".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M113")  );
		} else if("R".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P091")  );
		} else if("G".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P094")  );
		}

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0110/doDelete")
	public void doDeleteEvalItemMgt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		List<Map<String,Object>> gridData = req.getGridData("gridMain");
		String msg = ev0100service.doDeleteEvalItemMgt(gridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}




	@RequestMapping(value = "/EV0110/chgEVAL_KIND02")
	public void EVAL_KIND02(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		if ("E".equals(param.get("EVAL_KIND02"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M114")  );
		} else if("S".equals(param.get("EVAL_KIND02"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("M113")  );
		} else if("R".equals(param.get("EVAL_KIND02"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P091")  );
		} else if("G".equals(param.get("EV_ITEM_KIND_CD"))) {
			resp.setParameter("itemTypeCode",  commonComboService.getCodeComboAsJson("P094")  );
		}
		resp.setResponseCode("true");
	}

}
