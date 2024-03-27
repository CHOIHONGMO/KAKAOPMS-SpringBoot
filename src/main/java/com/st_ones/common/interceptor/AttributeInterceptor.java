package com.st_ones.common.interceptor;

import com.st_ones.everf.serverside.config.PropertiesManager;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

public class AttributeInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        request.setAttribute("labelWidth", PropertiesManager.getString("eversrm.style.labelWidth"));
        request.setAttribute("longLabelWidth", PropertiesManager.getString("eversrm.style.longLabelWidth"));
        request.setAttribute("labelAlign", PropertiesManager.getString("eversrm.style.labelAlign"));
        request.setAttribute("everMultiWidth", PropertiesManager.getString("eversrm.style.everMultiWidth"));
        request.setAttribute("everMultiVisible", PropertiesManager.getString("eversrm.style.everMultiVisible"));
        request.setAttribute("inputTextWidth", PropertiesManager.getString("eversrm.style.inputTextWidth"));
        request.setAttribute("inputNumberWidth", PropertiesManager.getString("eversrm.style.inputNumberWidth"));
        request.setAttribute("inputDateWidth", PropertiesManager.getString("eversrm.style.inputDateWidth"));
        request.setAttribute("imeMode", "ime-mode:" + PropertiesManager.getString("eversrm.style.ime-mode") + ";");
        request.setAttribute("isDev", PropertiesManager.getString("eversrm.system.developmentFlag"));
        request.setAttribute("fileExtension", PropertiesManager.getString("everf.fileUpload.extension.type"));

        return HandlerInterceptor.super.preHandle(request, response, handler);
    }
}
