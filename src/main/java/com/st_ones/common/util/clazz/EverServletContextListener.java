package com.st_ones.common.util.clazz;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import com.st_ones.common.util.SpringContextUtil;
import com.st_ones.everf.serverside.domain.BaseCombo;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.servlet.FrameworkServlet;

import java.util.ArrayList;
import java.util.List;

public class EverServletContextListener implements ServletContextListener {

	public void contextDestroyed(ServletContextEvent arg0) {
		return ;
	}

	public void contextInitialized(ServletContextEvent event) {

		ServletContext sc = event.getServletContext();
		List<BaseCombo> refYNlist = new ArrayList<BaseCombo>();
		List<BaseCombo> trueFalseList = new ArrayList<BaseCombo>();
		List<BaseCombo> searchTermList = new ArrayList<BaseCombo>();

		// 순서 : TEXT, VALUE
		refYNlist.add(new BaseCombo("Y", "1"));
		refYNlist.add(new BaseCombo("N", "0"));
		sc.setAttribute("refYN", refYNlist);

		trueFalseList.add(new BaseCombo("True", "1"));
		trueFalseList.add(new BaseCombo("False", "0"));
		sc.setAttribute("refTF", trueFalseList);

		searchTermList.add(new BaseCombo("=", "E"));
		searchTermList.add(new BaseCombo("!=", "D"));
		searchTermList.add(new BaseCombo("Like", "L"));
		searchTermList.add(new BaseCombo("Not Like", "NL"));
		searchTermList.add(new BaseCombo(">", "B"));
		searchTermList.add(new BaseCombo(">=", "BE"));
		searchTermList.add(new BaseCombo("<", "S"));
		searchTermList.add(new BaseCombo("<=", "SE"));
		searchTermList.add(new BaseCombo("In", "I"));
		searchTermList.add(new BaseCombo("Not In", "NI"));
		searchTermList.add(new BaseCombo("is Null", "IN"));
		searchTermList.add(new BaseCombo("is Not Null", "INN"));
		sc.setAttribute("searchTerms", searchTermList);

		ServletContext ctx = event.getServletContext();
		WebApplicationContext springContext = WebApplicationContextUtils.getWebApplicationContext(ctx, FrameworkServlet.SERVLET_CONTEXT_PREFIX+"EverSRM Dispatcher");
		SpringContextUtil.setSpringContext(ctx, springContext);
	}
}