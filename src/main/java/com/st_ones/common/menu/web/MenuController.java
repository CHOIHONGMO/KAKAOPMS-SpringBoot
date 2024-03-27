package com.st_ones.common.menu.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.menu.service.MenuService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/common/menu")
public class MenuController extends BaseController {

	@Autowired private MenuService menuService;

	@RequestMapping(value = "/getScreenInfo")
	public void getScreenInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> params = req.getFormData();
		params.put("SCREEN_ID", req.getParameter("SCREEN_ID"));

		List<Map<String, Object>> data = menuService.getScreenInfo(params);
		String screen_id = "";
		if (data.size() != 0) {
			screen_id = (String) data.get(0).get("SCREEN_URL");
		} else {
			screen_id = "NOTFOUNDSCRRENID";
		}

		resp.setParameter("SCREEN_URL", screen_id);
		resp.setParameter("screenInfo", new ObjectMapper().writeValueAsString(data));
	}

	@RequestMapping(value = "/getScreenInfo2")
	public void getScreenInfo2(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> params = req.getFormData();
		params.put("tmpl_menu_cd", req.getParameter("tmpl_menu_cd"));

		List<Map<String, Object>> data = menuService.getScreenInfo2(params);

		ObjectMapper om = new ObjectMapper();
		resp.setParameter("SCREENINFO", om.writeValueAsString(data));
	}

	@RequestMapping(value = "/getLeftMenu")
	public void getLeftMenu(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> params = req.getFormData();
		params.put("moduleType", req.getParameter("moduleType"));
		params.put("menuType", req.getParameter("menuType"));

		List<Map<String, Object>> data = menuService.getLeftMenu(params);

		ObjectMapper om = new ObjectMapper();
		resp.setParameter("treeRawData", om.writeValueAsString(data));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/setBookmark")
	public void setBookmark(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		menuService.setBookmark(req.getParameter("templateMenuCd"), req.getParameter("bookmarkMode"));
		resp.setContentType("application/json");
		resp.getWriter().write("{}");
	}
}