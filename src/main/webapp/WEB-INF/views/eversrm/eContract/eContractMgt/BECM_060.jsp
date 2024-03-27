<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    javax.servlet.http.HttpSession hs = request.getSession(false);

    javax.servlet.ServletContext sc = hs.getServletContext();

    org.springframework.web.context.WebApplicationContext springContext = org.springframework.web.context.support.WebApplicationContextUtils.getWebApplicationContext(sc, org.springframework.web.servlet.FrameworkServlet.SERVLET_CONTEXT_PREFIX+"EverSRM Dispatcher");
    com.st_ones.eversrm.eContract.eContractMgt.service.BECM_Service becmService = (com.st_ones.eversrm.eContract.eContractMgt.service.BECM_Service) springContext.getBean("BECM_Service");

    String CONT_NUM = request.getParameter("CONT_NUM");
    String CONT_CNT = request.getParameter("CONT_CNT");

    com.st_ones.everf.serverside.info.BaseInfo baseInfo = (com.st_ones.everf.serverside.info.BaseInfo) hs.getAttribute("ses");
    com.st_ones.everf.serverside.info.UserInfoManager.createUserInfo(baseInfo);

    java.util.Map<String, String> map = new java.util.HashMap<String, String>();
    map.put("CONT_NUM", CONT_NUM);
    map.put("CONT_CNT", CONT_CNT);
    java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<java.util.Map<String, Object>>();

    if (CONT_NUM != null && !"".equals(CONT_NUM)) {
        list = becmService.doSearchAdditionalFormPrint(map);
    }
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>계약서 출력</title>
    <link href="/css/print.css" media="print"/>
    <style type="text/css">


        .Layer2 {
            color: black;
            line-height: 160%;
            font-size: 13px;
            font-family: 맑은 고딕;
        }

        .Layer2 ol, ul, dl {
            margin: 0px 0px 0px 50px;
        }

        .Layer2 td {
            color: black;
            font-family: 맑은 고딕;
            word-break: break-all;
        }

        A:link {
            COLOR: #12110e;
            FONT-SIZE: 12px;
            TEXT-DECORATION: none;
            font-family: "arial", "맑은 고딕"
        }

        A:visited {
            COLOR: #12110e;
            FONT-SIZE: 12px;
            TEXT-DECORATION: none;
            font-family: "arial", "맑은 고딕"
        }

        A:active {
            COLOR: #A20051;
            FONT-SIZE: 12px;
            TEXT-DECORATION: none;
            font-family: "arial", "맑은 고딕"
        }

        A:hover {
            COLOR: #A20051;
            FONT-SIZE: 12px;
            TEXT-DECORATION: none;
            font-family: "arial", "맑은 고딕"
        }

        thead { display: table-header-group; right: 0; bottom: 0px; text-align: right; width: 100%;}
        tfoot { display: table-header-group; }
    </style>
    <script src="/js/everuxf/everuxf.min.js"></script>
    <script type="text/javascript">
        function init() {
            /*
            var bodyHeight = $('body').height()
                    , layer2Tag = $('#Layer2');

            if (bodyHeight > layer2Tag.height()) {
                layer2Tag.height((bodyHeight - 214) + 'px');
            }

            $(window).resize(function () {
                var bodyHeight = $('body').height()
                        , layer2Tag = $('#Layer2');

                layer2Tag.height((bodyHeight - 214) + 'px');
            });*/

            window.print();
        }
    </script>
</head>
<body onload="init();">

<table class="onPrint" border="0" cellpadding="0" cellspacing="1" style="width: 100%; height: 100%; table-layout: fixed;">
    <thead><tr><td style="font-size: 13px; font-family: 맑은 고딕;">* 관리번호: ${formEtc.CONT_NUM}-${formEtc.CONT_CNT}</td></tr></thead>
    <tbody>
    <tr>
      
        <td class="Layer2">
            <%=(((java.util.HashMap) request.getAttribute("form")).get("formContents") + "").replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&quot;", "\"")%>
        </td>
    </tr>
    </tbody>

</table>

<div class="Layer2">

    <br>

    <%
        if (list.size() != 0) {

            for (int k = 0; k < list.size(); k++) {
                java.util.Map data = list.get(k);
                String additionalContents = (String) data.get("ADDITIONAL_CONTENTS");
    %>

    <div class="pageBreak_00" style="width: 100%; page-break-before: always;"></div>

    <table border="0" cellpadding="0" cellspacing="1" style="width: 100%; height: 20px;">
        <thead><tr><td>* 관리번호: ${formEtc.CONT_NUM}-${formEtc.CONT_CNT}</td></tr></thead>
        <tbody>
        <tr>
            <td>
                <%=additionalContents%>
                <strong style="font-size: 11px;">* 관리번호: ${formEtc.CONT_NUM}-${formEtc.CONT_CNT} &nbsp;&nbsp; * 계약서상태 : ${formEtc.PROGRESS_CD} &nbsp;&nbsp;
                    * ${formEtc.VENDOR_NM} 서명일시 : ${formEtc.VENDOR_SIGN_DATE} &nbsp;&nbsp; * ${formEtc.BUYER_NM} 서명일시 : ${formEtc.BUYER_SIGN_DATE} 
                </strong>
            </td>
        </tr>
        </tbody>
    </table>

    <c:if test="${param.progressCd == '4300'}">
        <table border="0" cellpadding="0" cellspacing="1" style="width: 100%; height: 50px;">
            <tbody>
            <tr>
                <td width="100%"><span style="color: rgb(255, 0, 0);"><strong><span style="font-size: 14px;">
							* 본 계약서는 아래 법령에 근거하여 전자서명으로 체결한 전자 계약서이며, 법적으로 보호 받을 수 있습니다.</span></strong><br/>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 전자계약 진위여부는 본 사이트 관리자에게 확인하실 수 있습니다.<br/>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&gt; 전자거래 기본법 제2조, 제5조, 제6조, 제7조, 제18조<br/>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&gt; 전자서명법 제2조, 제3조<br/>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&gt; 전자정부 구현을 위한 행정업무 전자화 촉진에 관한 법률 제5조, 제8조, 제16조 </span>
                </td>
                <td width="20%">&nbsp;</td>
            </tr>
            </tbody>
        </table>
    </c:if>
    <br>

    <%
            }
        }
    %>

</div>
</body>
<script type="text/javascript">

</script>
</html>
