<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<c:set var="type" value="${param.type}" />
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

<body id="e-body">

<div class="ui-layout-center">
	<div class="e-window-container-header-bullet"></div><span class="font-main-title e-window-container-header-text">${screenName }</span>
    <div id="e-tabs" class="e-tabs">
        <ul>
            <li><a href="#ui-tabs-1" onclick="getContentTab('1')">${DH1580_TAB1 }</a></li>
            <li><a href="#ui-tabs-2" onclick="getContentTab('2')">${DH1580_TAB2 }</a></li>
        </ul>
        <iframe id="ui-tabs-1" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" src="/eversrm/statistic/DH1581/view"></iframe>
        <iframe id="ui-tabs-2" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" src=""></iframe>
    </div>
</div>

<script>

	$('document').ready(function() {
	    $('#e-body').layout(EVF.Properties.layout);
	    $('#e-tabs').height( ($('.ui-layout-center').height()-60)).tabs();
	    $(window).resize(function(e) {
	        $('#e-tabs').height( ($('.ui-layout-center').height()-60) ).tabs();
	        $('iframe').css("height", $(window).outerHeight()-60);
	    });
	    getContentTab('1');
	});

    var loadMap = {};

    function getContentTab(uu) { 

    	var params = {
            callback: "${param.callBackFunction}",
            detailView: "${param.detailView}"
        };

        <%-- 표준문서.기본정보 --%>

        var dh1581 = '/eversrm/statistic/DH1581/view';<%-- 집계현황 --%>
        var dh1590 = '/eversrm/statistic/DH1590/view'; <%-- 상세현황 --%>

        var url;

        if(uu == '1') {
            url = dh1581;
        } else if (uu == '2') {
            url = dh1590;
        } 

        loadMap[dh1581] = url;    <%--첫번째 탭은 무조건 방문한 것으로 체크한다. --%>
        <%-- 4개의 탭을 한꺼번에 다 로드하지 말고 방문한 적 없는 탭만 로드하도록 한다. --%>
        if(loadMap[url] != url) {
            $('#ui-tabs-' + uu).attr("src", url);
            loadMap[url] = url;
        } else {
        	//if(url == tt02_017) {
        	//	window['ui-tabs-3'].contentWindow.doSearch();
        	//}	
        }
        $('#e-tabs').tabs("option", "active", eval(uu)-1);
    }

</script>
 
</e:ui>