<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <c:import url="/WEB-INF/include/commonInclude.jsp" />
        <style>
            .ui-layout-center {
                padding: 0 !important;
            }
        </style>
    </head>
    <title>발주실적KPI</title>
    <body id="e-body">
    <input type="hidden" id="PJT_NM" value="${param.PJT_NM }">
    <div class="ui-layout-center">
        <div id="e-tabs" class="e-tabs">
            <ul>
                <li><a href="#ui-tabs-1" onclick="getContentTab('1')">[Fusion]</a></li>
                <li><a href="#ui-tabs-2" onclick="getContentTab('2')">[HighCharts]</a></li>
            </ul>
            <iframe id="ui-tabs-1" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" src="/eversrm/po/poMgt/poProgress/BPOP_011T1/view"></iframe>
            <iframe id="ui-tabs-2" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" src=""></iframe>

        </div>
    </div>

    <script type="text/javascript">

        $('document').ready(function() {
            $('#e-body').layout(EVF.Properties.layout);
            $('#e-tabs').height( ($('.ui-layout-center').height()-40)).tabs();

            $(window).resize(function(e) {
                $('#e-tabs').height( ($('.ui-layout-center').height()-40) ).tabs();
                $('iframe').css("height", $(window).outerHeight()-40);
            });
            getContentTab('1');
        });

        var loadMap = {};
        function getContentTab(uu) {

            var params = {
                formData: ${param.formData},
                <%--PO_TO_DATE: "${param.PO_TO_DATE}",--%>
                <%--PURCHASE_TYPE: "${param.PURCHASE_TYPE}",--%>
                <%--PO_CLOSE_FLAG: "${param.PO_CLOSE_FLAG}",--%>
                <%--PO_NUM: "${param.PO_NUM}",--%>
                <%--SUBJECT: "${param.SUBJECT}",--%>
                <%--VENDOR_NM: "${param.VENDOR_NM}",--%>
                <%--CTRL_USER_ID: "${param.CTRL_USER_ID}",--%>
                <%--CTRL_USER_NM: "${param.CTRL_USER_NM}",--%>
                <%--PO_APRV_ID: "${param.PO_APRV_ID}",--%>
                <%--PO_APRV_NM: "${param.PO_APRV_NM}",--%>
                <%--PROGRESS_CD: "${param.PROGRESS_CD}",--%>
                <%--RECEIPT_STATUS: "${param.RECEIPT_STATUS}",--%>
                callback: "${param.callBackFunction}",
                detailView: "${param.detailView}"
            };

            <%-- 표준문서.기본정보 --%>
            var BPOP_011T1 = '/eversrm/po/poMgt/poProgress/BPOP_011T1/view.so?' + $.param(params); /* tab1 */
            var BPOP_011T2 = '/eversrm/po/poMgt/poProgress/BPOP_011T2/view.so?' + $.param(params); /* tab2 */

            var url;
            if(uu == '1') {
                url = BPOP_011T1;
            } else if (uu == '2') {
                url = BPOP_011T2;
            }

            loadMap[BPOP_011T1] = '';
            loadMap[BPOP_011T2] = '';

            $('#ui-tabs-' + uu).attr("src", url);
            loadMap[url] = url;

            $('#e-tabs').tabs("option", "active", eval(uu)-1);
        }

    </script>
</e:ui>
