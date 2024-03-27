package com.st_ones.common.interceptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.cache.data.ScrnCache;
import com.st_ones.common.interceptor.service.ScreenInterceptorService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

@Component
public class ScreenInterceptor implements HandlerInterceptor {

    private Logger logger = LoggerFactory.getLogger(ScreenInterceptor.class);

    private final ApplicationContext applicationContext;

    private final ScrnCache scrnCache;

    public ScreenInterceptor(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
        this.scrnCache = applicationContext.getBean(ScrnCache.class);
    }

    @Override
    public boolean preHandle(jakarta.servlet.http.HttpServletRequest request, jakarta.servlet.http.HttpServletResponse response, Object handler) throws Exception {
        return HandlerInterceptor.super.preHandle(request, response, handler);
    }

    @Override
    public void postHandle(jakarta.servlet.http.HttpServletRequest request, jakarta.servlet.http.HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

        if(request instanceof EverHttpRequest) {

            EverHttpRequest req = (EverHttpRequest) request;
            doNormalProcess(request, modelAndView, req);
        }

        HandlerInterceptor.super.postHandle(request, response, handler, modelAndView);
    }

    @Override
    public void afterCompletion(jakarta.servlet.http.HttpServletRequest request, jakarta.servlet.http.HttpServletResponse response, Object handler, Exception ex) throws Exception {
        HandlerInterceptor.super.afterCompletion(request, response, handler, ex);
    }

	private void doNormalProcess(HttpServletRequest request, ModelAndView modelAndView, EverHttpRequest req) throws Exception {

        logger.info("스크린인터셉터 - {}", request.getRequestURI());

    	request.setCharacterEncoding("UTF-8");

		if (PropertiesManager.getBoolean("eversrm.system.urlDirectInputPermission", false)) {
            //if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag", false)) {
                if (EverString.isEmpty(req.getHeader("referer"))) {
//                    throw new InternetSecurityException(msg.getMessage("0043"));
                }
            //}
		}

		String screenURL = request.getRequestURI();
		String screenId = request.getParameter("SCREEN_ID");

        ScreenInterceptorService screenInterceptorService = applicationContext.getBean(ScreenInterceptorService.class);

        // show.so 첨부파일용...
		int screenURLExceptionCnt = screenURL.indexOf("show.so");

		if (screenURLExceptionCnt < 0) {

			screenInterceptorService.checkScreenURL(screenURL);

			// Screen attribute setting.
			if (screenId == null || "".equals(screenId)) {
				screenId = screenInterceptorService.getScreenId(screenURL);
			}

			String moduleType = request.getParameter("moduleType");
			String screenName = request.getParameter("screen_name");
			boolean popupFlag = Boolean.parseBoolean(request.getParameter("popupFlag"));
			boolean detailView = Boolean.parseBoolean(request.getParameter("detailView"));
			if(request.getAttribute("detailView") != null) {
				detailView = Boolean.parseBoolean(String.valueOf(request.getAttribute("detailView")));
			}
			String tmplMenuCd = request.getParameter("tmpl_menu_cd");

			if(modelAndView != null) {
                String viewName = modelAndView.getViewName();

                Map<String, String> tmp = screenInterceptorService.getBreadCrumbs(screenId, moduleType, popupFlag, viewName, detailView, tmplMenuCd, screenName);
                modelAndView.addAllObjects(tmp);

                Map<String, String> screenMessageMap = screenInterceptorService.getScreenMessage(screenId);
                modelAndView.addAllObjects(screenMessageMap);

                Map<String, String> formInfoMap = screenInterceptorService.getFormInfo(req, screenId, detailView);
                modelAndView.addAllObjects(formInfoMap);

                Map<String, String> buttonInfoMap = screenInterceptorService.getButtonInfo(req, screenId, detailView, popupFlag);
                modelAndView.addAllObjects(buttonInfoMap);

                Map<String, Object> toolbarInfo = screenInterceptorService.getToolbarInfo(screenId, tmplMenuCd);

                // grid 정보를 가져온다.
                String[] gridIdArr = String.valueOf(toolbarInfo.get("gridId")).split(",");
                Map<String, Object> gridInfos = new HashMap<>();
                for (String gridId : gridIdArr) {
                    Map<Object, Object> gridInfo = screenInterceptorService.gridGen2(gridId, screenId, detailView);
                    gridInfos.put(gridId, gridInfo);
                }

//                logger.info("그리드 컬럼 정보: {}", gridInfos);

                req.setAttribute("gridInfos", gridInfos);

                Properties props = new Properties();
                try {
                    props.load(new InputStreamReader(getClass().getResourceAsStream("/everuxf.properties"), "MS949"));
                } catch (IOException e) {
                    logger.error("/WEB-INF 디렉토리 밑에 everuxf.properties 파일이 존재하지 않습니다.", e);
                }

                Map<String, Object> initDataMap = new HashMap<String, Object>();
                initDataMap.put("langCd", UserInfoManager.getUserInfo().getLangCd());
                initDataMap.put("sessionType", ("VIRTUAL".equals(UserInfoManager.getUserInfo().getUserId()) ? "virtual" : "normal"));
                initDataMap.put("screenCd", screenId);
                initDataMap.put("templateMenuCd", tmplMenuCd);
                initDataMap.put("theme", props.getProperty("evf.theme", "sbsrm"));
                initDataMap.put("realGrid2_theme", props.getProperty("evf.realGrid2.theme", "dark"));
                initDataMap.put("userId", UserInfoManager.getUserInfo().getUserId());
                initDataMap.put("userType", UserInfoManager.getUserInfo().getUserType());
                initDataMap.putAll(toolbarInfo);
                req.setAttribute("initData", new JSONObject(initDataMap).toJSONString());

                modelAndView.addObject("st_default", PropertiesManager.getString("eversrm.style.multiSearchDefaultValue"));

                String excelDownMode = screenInterceptorService.getExcelDownMode(screenId);
                excelDownMode = EverString.nullToEmptyString(excelDownMode);

                tmp.clear();
                tmp.put("allCol", (excelDownMode.equals("B") || excelDownMode.equals("D")) ? "true" : "false");
                tmp.put("selRow", (excelDownMode.equals("C") || excelDownMode.equals("D")) ? "true" : "false");
                tmp.put("fileType", PropertiesManager.getString("everF.excel.fileType"));
                modelAndView.addObject("excelExport", tmp);

                // Common comboBox setting.
                ObjectMapper om = new ObjectMapper();
                ServletContext servletContext = req.getSession().getServletContext();
                String port = Character.isDigit(request.getServerPort()) ?  ":" + request.getServerPort() : "";
                req.setAttribute("searchTerms", om.writeValueAsString(servletContext.getAttribute("searchTerms")));
                req.setAttribute("refYN", om.writeValueAsString(servletContext.getAttribute("refYN")));
                req.setAttribute("refTF", om.writeValueAsString(servletContext.getAttribute("refTF")));
                req.setAttribute("_gridType", scrnCache.getGridTypeByScreenId(screenId));
                req.setAttribute("_url", request.getScheme() + "://"+request.getServerName() + port);
            }
		}
	}
}