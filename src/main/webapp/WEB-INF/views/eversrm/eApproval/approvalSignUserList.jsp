<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.st_ones.common.util.clazz.EverString" %>
<%@ page import="org.springframework.web.servlet.FrameworkServlet" %>
<%
    javax.servlet.http.HttpSession hs = request.getSession(false);
    javax.servlet.ServletContext sc = hs.getServletContext();
    org.springframework.web.context.WebApplicationContext appContext = org.springframework.web.context.support.WebApplicationContextUtils.getWebApplicationContext(sc, FrameworkServlet.SERVLET_CONTEXT_PREFIX+"EverSRM Dispatcher");
    com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service eApprovalService = (com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service) appContext.getBean("bapm_Service");
    com.st_ones.everf.serverside.info.BaseInfo baseInfo = (com.st_ones.everf.serverside.info.BaseInfo) hs.getAttribute("ses");
    com.st_ones.everf.serverside.info.UserInfoManager.createUserInfo(baseInfo);

    String app_doc_num = request.getParameter("APP_DOC_NUM");
    String app_doc_cnt = request.getParameter("APP_DOC_CNT");

    java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<java.util.Map<String, Object>>();
    java.util.Map<String, String> map = new java.util.HashMap<String, String>();
    map.put("APP_DOC_NUM", app_doc_num);
    map.put("APP_DOC_CNT", app_doc_cnt);

     if (app_doc_num != null && !"".equals(app_doc_num)) {
        //list = eApprovalService.singerList(map);
    }
    if (list.size() != 0) {

    	for (int k = 0; k < list.size(); k++) {
    		java.util.Map data = list.get(k);
    	}
%>

<style>
    td {
        font-family: "맑은 고딕";
        font-size: 12px;
    }
</style>
<div id="list" style="width:100%; height:177px; overflow:auto">

    <div style="padding-bottom: 5px; padding-top: 5px;">
        <div class="e-title-bullet-h1" style="padding-bottom: 3px;"></div><div class="e-title-text">결재정보</div>
    </div>

    <table style="table-LAYOUT: fixed" cellSpacing=0 cellPadding=0 width="100%" border=0>
        <tbody>
        <tr align=center>
            <td style="font-size: 9pt; height: 28px; font-weight: bold; color: #ffffff; text-align: center; background-color: #92a0a6" width="60px" noWrap>순번</td>
            <td style="font-size: 9pt; height: 28px; font-weight: bold; color: #ffffff; text-align: center; background-color: #92a0a6" width="120px" padding-left: 15px; noWrap>구분</td>
            <td style="font-size: 9pt; height: 28px; font-weight: bold; color: #ffffff; text-align: center; background-color: #92a0a6" width="240px" noWrap>성명</td>
            <td style="font-size: 9pt; height: 28px; font-weight: bold; color: #ffffff; text-align: center; background-color: #92a0a6" width="240px" noWrap>처리일시</td>
            <td style="font-size: 9pt; height: 28px; font-weight: bold; color: #ffffff; text-align: center; background-color: #92a0a6" width="*" noWrap>부서명</td>
        </tr>
        <tr>
            <td bgcolor=#d9d9d9 height=1 colSpan=5></td>
        </tr>
        </tbody>
    </table>

    <table cellSpacing=0 cellPadding=0 width="100%" border=0>
        <tbody>
        <%
            for (int k = 0; k < list.size(); k++) {
                java.util.Map data = list.get(k);
                String doc_sub_type = (String) data.get("DOC_SUB_TYPE");
                String signName = (String) data.get("SIGN_NAME");
        %>
        <tr>
            <td style="font-size: 9pt; height: 28px; border-bottom: #cccccc 1px solid; font-weight: bold; color: #7a5e4b; padding-top: 1px; padding-left: 10px; PADDING-RIGHT: 5px; WIDTH: 60px; background-color: #f1f1f1"
                rowSpan=<%="NOTICE".equals(doc_sub_type) ? "1" : "2"%> width="10%" align='center'><%=data.get("SIGN_PATH_SQ") %></td>
            <td style="background-color: #dbdbdb" width=1 ></td>
            <td style="font-size: 9pt; height: 28px; border-bottom: #cccccc 1px solid; color: #333333; padding-top: 2px; padding-left: -2px; text-align: center; background-color: #f1f1f1"
                width="120px" ><span style="font-family: '맑은 고딕'; font-size:9pt; font-weight:bold; color:#0072b5;"><%=data.get("SIGN_REQ_TYPE_NAME") %></span>
            </td>
            <td style="background-color: #dbdbdb" width=1 ></td>
            <td style="font-size: 9pt; height: 28px; border-bottom: #cccccc 1px solid; color: #333333; padding-top: 2px; padding-left: 10px; background-color: #f1f1f1"
                width="240px" title="<%=data.get("SIGN_NAME")%>"><%=signName %> <%=data.get("POSITION_NM") %></A></td>
            <td style="background-color: #dbdbdb" width=1 ></td>
            <td style="font-size: 9pt; height: 28px; border-bottom: #cccccc 1px solid; color: #755232; padding-top: 2px; padding-left: 10px; background-color: #f1f1f1"
                width="240px" ><%=data.get("SIGN_DATE") %>
            </td>
            <td style="background-color: #dbdbdb" width=1 ></td>
            <td style="font-size: 9pt; height: 28px; border-bottom: #cccccc 1px solid; color: #333333; padding-top: 2px; padding-left: 10px; background-color: #f1f1f1"
                width="*" ><%=data.get("DEPT_NM") %>
            </td>
        </tr>
        <%
            if (!"NOTICE".equals(doc_sub_type)) {
        %>
        <tr>
            <td style="background-color: #dbdbdb" width=1 ></td>
            <td style="workd-wrap: break-word; font-size: 9pt; height: 28px; border-bottom: #cccccc 1px solid; workd-break: break-all; color: #666666; padding-top: 2px; padding-left: 10px; background-color: #ffffff"
                colSpan=8><%=EverString.nToBr((String) data.get("SIGN_RMK")) %>
            </td>
        </tr>

        <% }
        }
        %>

        </tbody>
    </table>
</div>
<%
    }
%>

<% if (list.size() != 0) { %>

<table width="100%" border=0>
    <tbody>
    <tr>
        <td bgcolor=#ffffff height=3></td>
    </tr>
    </tbody>
</table>

<% } %>