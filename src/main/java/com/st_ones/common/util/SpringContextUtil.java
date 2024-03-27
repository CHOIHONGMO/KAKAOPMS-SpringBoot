package com.st_ones.common.util;

import com.st_ones.common.util.service.UtilService;
import jakarta.servlet.ServletContext;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.servlet.FrameworkServlet;

public class SpringContextUtil {

	private static ServletContext servletContext = null;
	private static ApplicationContext springContext = null;

	public static void setSpringContext(ServletContext _servletContext, WebApplicationContext _springContext) {
		SpringContextUtil.servletContext = _servletContext;
		SpringContextUtil.springContext = _springContext;
	}

	public static <T> T getBean(Class<T> t) {

		if(springContext == null) {
			springContext = WebApplicationContextUtils.getWebApplicationContext(servletContext, FrameworkServlet.SERVLET_CONTEXT_PREFIX+"EverSRM Dispatcher");
		}

		return SpringContextUtil.springContext.getBean(t);
	}

	public static UtilService getUtilService() {
		return getBean(UtilService.class);
	}
}