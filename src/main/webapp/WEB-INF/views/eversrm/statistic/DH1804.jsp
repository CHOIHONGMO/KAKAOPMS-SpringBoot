<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = '/eversrm/statistic';
    var selRow;

    function init() {
        doSearch();
    }

    function doSearch() {

        var store = new EVF.Store();
        if(!store.validate()) return;
        store.load(baseUrl+'/DH1800/doSearch', function() {

            var C_Json = JSON.parse(this.getParameter("chartObj"));

            for (var k = 0; k < C_Json.length; k++) {

                console.log(C_Json[k].USA);
                console.log(C_Json[k].China);
                console.log(C_Json[k].UK);

            }
        });
    }

</script>

    <e:window id="DH1804" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <div id="chartdiv"></div>
    </e:window>
</e:ui>
