package com.st_ones.nosession.error.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ExceptionController extends BaseController {

	@RequestMapping("/errors")
	public String processException(EverHttpRequest req, HttpServletResponse resp) {

		String requestUri = (String) req.getAttribute("javax.servlet.error.request_uri");
		Integer statusCode = (Integer) req.getAttribute("javax.servlet.error.status_code");
		String exceptionType = (String) req.getAttribute("javax.servlet.error.exception_type");
		String message = EverString.nullToEmptyString((String) req.getAttribute("javax.servlet.error.message")).trim();
		String messageFromEverFrameworkServletFilter = EverString.nullToEmptyString((String) req.getAttribute("errorMessage")).trim();
		String stackTraceFromEverFrameworkServletFilter = EverString.nullToEmptyString((String) req.getAttribute("stackTrace")).trim();
		statusCode = (statusCode == null) ? 500 : statusCode;
				
		String errorDisplay = PropertiesManager.getString("eversrm.message.stackTrace.error");
		
		if (errorDisplay.equals("true")) {
			req.setAttribute("stackTrace", EverString.nToBr(stackTraceFromEverFrameworkServletFilter));
			req.setAttribute("errorMessage", (message.length() <= 0) ? messageFromEverFrameworkServletFilter : message);
		} else {
			req.setAttribute("stackTrace", "N/A");
			req.setAttribute("errorMessage", "N/A");
		}
		
		req.setAttribute("requestUri", requestUri);
		req.setAttribute("statusCode", statusCode);
		
		getLog().error(requestUri);
		getLog().error(statusCode.toString());
		getLog().error(exceptionType);
		getLog().error((message.length() <= 0) ? messageFromEverFrameworkServletFilter : message);
		getLog().error(">>>>> exception !!!!!");
		getLog().error(">>>>> statusCode: " + statusCode);
		getLog().error(">>>>> requestUri: " + requestUri);

		return "/error/errorPage";
	}

	@RequestMapping("/pageNotFound")
	public String pageNotFound(HttpServletRequest req, HttpServletResponse resp) {
		
		String requestUri = (String) req.getAttribute("javax.servlet.error.request_uri");
		Integer statusCode = (Integer) req.getAttribute("javax.servlet.error.status_code");
		req.setAttribute("requestUri", requestUri);
		req.setAttribute("statusCode", statusCode);
		
		getLog().error("The requested resource is not available.");
		getLog().error("statusCode: " + statusCode);
		getLog().error("requestUri: " + requestUri);
		resp.setStatus(200);
		
		return "/error/pageNotFound";
	}
	
	@RequestMapping("/exception")
	public String exception(HttpServletRequest req, HttpServletResponse resp) {
		String requestUri = (String) req.getAttribute("javax.servlet.error.request_uri");
		Integer statusCode = (Integer) req.getAttribute("javax.servlet.error.status_code");
		Throwable throwable = (Throwable) req.getAttribute("javax.servlet.error.exception");
		String exceptionType = (String) req.getAttribute("javax.servlet.error.exception_type");
		String message = (String) req.getAttribute("javax.servlet.error.message");
		req.setAttribute("requestUri", requestUri);
		req.setAttribute("statusCode", statusCode);

		getLog().error(requestUri);
		getLog().error(statusCode.toString());
		getLog().error(throwable.getMessage());
		getLog().error(exceptionType);
		getLog().error(message);

		getLog().error("exception !!!!!");
		getLog().error("statusCode: " + statusCode);
		getLog().error("requestUri: " + requestUri);
		resp.setStatus(300);
		return "/error/errorPage";
	}
}