package com.st_ones.configuration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.EverString;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;

@WebFilter(urlPatterns = "*")
public class EverServletFilter implements Filter {

    private Logger logger = LoggerFactory.getLogger(EverServletFilter.class);
    private static final String DATA_REQUEST_TYPE = "EVER_REQUEST_DATA_TYPE";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        Filter.super.init(filterConfig);
    }

    @Override
    public void destroy() {
        Filter.super.destroy();
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {

        EverHttpRequest everRequest = null;
        EverHttpResponse everResponse = null;
        HttpServletRequest httpRequest = (HttpServletRequest) servletRequest;
        HttpServletResponse httpResponse = (HttpServletResponse) servletResponse;
        String requestType = servletRequest.getParameter("EVER_REQUEST_DATA_TYPE");

        String message;
        try {

            String requestURI = ((HttpServletRequest) servletRequest).getRequestURI();
            boolean isPageRequest = requestURI.endsWith("/view");

            httpRequest.setCharacterEncoding("UTF-8");

//            logger.info("({}) {} - {} - {}", requestType, httpRequest.getRequestURI(), httpRequest.getContentType());

            if("AJAX".equals(requestType) || isPageRequest) {

                logger.info("{} - {} - {}", "프레임웍 요청 처리", httpRequest.getRequestURI());

                everRequest = new EverHttpRequest((HttpServletRequest)servletRequest);
                everRequest.setCharacterEncoding("UTF-8");
                everResponse = new EverHttpResponse((HttpServletResponse)servletResponse);

                filterChain.doFilter(everRequest, everResponse);

                if (!everResponse.isCommitted()) {
                    HttpSession httpSession = everRequest.getSession();
                    if (!httpSession.isNew() && httpSession.getAttribute("ses") != null) {
                        StringBuilder ips = new StringBuilder();
                        Enumeration<NetworkInterface> networkInter = NetworkInterface.getNetworkInterfaces();

                        while(true) {
                            if (!networkInter.hasMoreElements()) {
                                everResponse.setParameter("stOnesLicense", ips + "h@t=" + servletRequest.getServerName() + "*^*" + (new SimpleDateFormat("yyyyMMdd")).format(new Date()));
                                break;
                            }

                            NetworkInterface ntInter = (NetworkInterface)networkInter.nextElement();
                            Enumeration<InetAddress> inetAddresses = ntInter.getInetAddresses();

                            while(inetAddresses.hasMoreElements()) {
                                InetAddress addr = (InetAddress)inetAddresses.nextElement();
                                ips.append("i!p=").append(addr.getHostAddress()).append("^*^");
                            }
                        }
                    }
                }

                ObjectMapper mapper;
                if (EverString.equals(requestType, "AJAX")) {
                    mapper = new ObjectMapper();
                    everResponse.setContentType("application/json");
                    everResponse.getWriter().write(mapper.writeValueAsString(everResponse.getParameterMap()));
                } else if (EverString.equals(requestType, "FILE")) {
                    mapper = new ObjectMapper();
                    everResponse.setContentType("application/json");
                    everResponse.getWriter().write(mapper.writeValueAsString(everResponse.getParameterMap()));
                }

            } else {

//                logger.info("{} - {}", "리소스 요청 처리", httpRequest.getRequestURI());
                filterChain.doFilter(servletRequest, servletResponse);
            }

//            this.logger.debug("-[EverFrameworkServletFilter Debugging Info]--------------------------");
//            this.logger.debug("AuthType: " + req.getAuthType());
//            this.logger.debug("ContentType: " + req.getContentType());
//            this.logger.debug("Headers");
//            Enumeration<String> headerNames = req.getHeaderNames();
//
//            String auth;
//            while(headerNames.hasMoreElements()) {
//                auth = (String)headerNames.nextElement();
//                message = req.getHeader(auth);
//                this.logger.debug("-> {}: {}", auth, message);
//            }
//
//            this.logger.debug("ContextPath: " + req.getContextPath());
//            this.logger.debug("Protocol: " + req.getProtocol());
//            this.logger.debug("RequestedSessionId: " + req.getRequestedSessionId());
//            this.logger.debug("QueryString: " + req.getQueryString());
//            this.logger.debug("RequestURL: " + req.getRequestURL());
//            this.logger.debug("CharacterEncoding: " + req.getCharacterEncoding());
//            this.logger.debug("---------------------------------------------------------------------");
//            auth = req.getHeader("Authorization");
//            if (StringUtils.startsWith(auth, "NTLM")) {
//                byte[] msg = (new BASE64Decoder()).decodeBuffer(auth.substring(5));
//                if (msg[8] == 1) {
//                    byte z = 0;
//                    byte[] msg1 = new byte[]{78, 84, 76, 77, 83, 83, 80, z, 2, z, z, z, z, z, z, z, 40, z, z, z, 1, -126, z, z, z, 2, 2, 2, z, z, z, z, z, z, z, z, z, z, z, z};
//                    resp.setStatus(401);
//                    resp.setHeader("WWW-Authenticate", "NTLM " + (new BASE64Encoder()).encodeBuffer(msg1).trim());
//                    this.logger.debug("NTLM Auth Status: Unauthorized.");
//                    return;
//                }
//
//                if (msg[8] == 3) {
//                    this.logger.debug("NTLM Auth Status: OK.");
//                    resp.setStatus(200);
//                } else {
//                    this.logger.debug("NTLM Auth Status: Unrecognized.");
//                }
//            }


        } catch (Exception e) {

            this.logger.error(e.getMessage(), e);
            HttpServletResponse httpServletResponse = (HttpServletResponse)servletResponse;
            if (EverString.equals(requestType, "AJAX")) {
                String exceptionMessage = e.getMessage();
                if (exceptionMessage.lastIndexOf("Exception") != -1) {
                    message = StringUtils.substringAfterLast(e.getCause() + "", "Exception:");
                    if (exceptionMessage.indexOf("java.lang.Exception") == -1) {
                        if (PropertiesManager.getBoolean("eversrm.message.database.error")) {
                            message = "관리자에게 문의 하시기 바랍니다.\n(세부내용: " + message + ")";
                        } else {
                            message = "관리자에게 문의 하시기 바랍니다.";
                        }
                    }
                } else {
                    message = exceptionMessage;
                }

                if (everResponse != null) {
                    everResponse.setStatus(200);
                    everResponse.setResponseCode("0");
                    everResponse.setResponseMessage(message);
                    everResponse.getWriter().write(message);
                    everResponse.flushBuffer();
                } else {
                    httpServletResponse.setStatus(200);
                    httpServletResponse.sendRedirect("/error/500.html");
                }
            } else if (everRequest != null) {

                everRequest.setAttribute("errorMessage", e.getMessage());
                StringBuilder sb = new StringBuilder();
                StackTraceElement[] var10 = e.getStackTrace();
                int var11 = var10.length;

                for(int var12 = 0; var12 < var11; ++var12) {
                    StackTraceElement element = var10[var12];
                    sb.append(element.toString());
                    sb.append("\n");
                }

                everRequest.getRequestDispatcher("/error/500.html").forward(everRequest, everResponse);

            } else {
                httpServletResponse.setStatus(200);
                httpServletResponse.sendRedirect("/error/500.html");
            }
        }

    }
}
