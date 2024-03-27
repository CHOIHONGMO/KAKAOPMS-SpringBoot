package com.st_ones.common.interceptor;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.session.web.EverHttpSessionListener;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.threadlocal.GlobalMapThreadLocal;
import com.st_ones.everf.serverside.util.clazz.SessionIgnore;
import com.st_ones.everf.serverside.web.interceptor.PropertyNotInjectException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import java.io.PrintWriter;

/**
 * @author ST-Ones
 * @version 1.0
 */
public class SessionInterceptor implements HandlerInterceptor {

    private String noSessionRedirectUrl;
    private final String SESSION_ATTRIBUTE_NAME = "ses";
    private Logger logger = LoggerFactory.getLogger(SessionInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        if(handler instanceof HandlerMethod) {

            HandlerMethod method = (HandlerMethod) handler;

            boolean isSessionIgnore = method.getMethod().isAnnotationPresent(SessionIgnore.class)
                    || method.getClass().isAnnotationPresent(SessionIgnore.class);

            if (isSessionIgnore) {
                return HandlerInterceptor.super.preHandle(request, response, handler);
            } else {

                HttpSession httpSession = request.getSession();
                UserInfo userInfo;

                if (this.noSessionRedirectUrl == null) {
                    throw new PropertyNotInjectException("Redirect URL for no session is required!!");
                }

                if(httpSession.getAttribute(SESSION_ATTRIBUTE_NAME) != null) {                                              // 로그인된 상태라면

                    userInfo = (UserInfo) httpSession.getAttribute(SESSION_ATTRIBUTE_NAME);

                    EverHttpSessionListener instance = EverHttpSessionListener.getInstance();
                    if(instance.isUserToLogout(userInfo)) {

                        logger.warn(userInfo.getUserId()+" logged in with another IP!");
                        httpSession.invalidate();

                        if(request.getContentType() == null) { /* Calling page */
                            PrintWriter pw = response.getWriter();
                            response.setContentType("text/html");
                            pw.write("<script>alert('다른 기기에서 로그인되어 로그아웃처리되었습니다.');");
                            pw.write("top.location.href='/';</script>");
                        } else {
                            response.setStatus(441);
                        }

                        instance.removeLogoutTargetUser(userInfo);
                        return false;

                    }
                }

                if (httpSession.getAttribute(SESSION_ATTRIBUTE_NAME) == null) {                                             // 로그아웃된 상태

                    if(request.getContentType() == null) {                                                                  // 화면으로 접근

                        PrintWriter pw = response.getWriter();
                        response.setContentType("text/html");
                        pw.write("<html><script>top.location.href=\"/\";</script></html>");

                    } else {                                                                                                // AJAX로 접근
                        response.setStatus(440);
                    }

                    return false;
                }

                userInfo = (UserInfo) httpSession.getAttribute(SESSION_ATTRIBUTE_NAME);

//                logger.info("세션인터셉터: {}", userInfo);

                GlobalMapThreadLocal.removeAll();
                UserInfoManager.createUserInfo(userInfo);
                if(userInfo.getUserId() != null) {
                    MDC.put("userId", "["+ EverString.setEncryptedString(userInfo.getUserNm(), "N")+"] ");
                }
            }
        }
        return HandlerInterceptor.super.preHandle(request, response, handler);
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

        if(handler instanceof HandlerMethod) {

            HandlerMethod method = (HandlerMethod) handler;
            boolean isSessionIgnore = method.getMethod().isAnnotationPresent(SessionIgnore.class)
                    || method.getClass().isAnnotationPresent(SessionIgnore.class);

            if (isSessionIgnore) {
                GlobalMapThreadLocal.removeAll();
                HandlerInterceptor.super.postHandle(request, response, handler, modelAndView);
            } else {
                HttpSession httpSession = request.getSession();
                UserInfo userInfo = UserInfoManager.getUserInfo();
                boolean isOneShotSession = (userInfo != null && userInfo.getUserId() != null && userInfo.getUserId().equals("SYSTEM"));
                if (isSessionIgnore && isOneShotSession) {
                    httpSession.invalidate();
                }
                GlobalMapThreadLocal.removeAll();
                HandlerInterceptor.super.postHandle(request, response, handler, modelAndView);
            }
        }
    }

    public void setNoSessionRedirectUrl(String noSessionRedirectUrl) {
        this.noSessionRedirectUrl = noSessionRedirectUrl;
    }
}