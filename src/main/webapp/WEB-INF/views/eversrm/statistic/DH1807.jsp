<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script src="/js/ever-chart.js"></script>
    <script>

        var baseUrl = '/eversrm/statistic';
        var selRow;

        function init() {
            doSearch();
        }

        // Search
        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) return;
            store.load(baseUrl + '/DH1807/doSearch', function () {

            	var chartObj = JSON.parse(this.getParameter("chartObj"));
                // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
                var option = {
                    'title': 'Xbar Chart',
                	'chartType': 'type',
                    'chartNm': 'column',
                    'xMax': "46",
                    'yMin': this.getParameter("yMin"),
                    'yMax': this.getParameter("yMax"),
                    'maxVal': this.getParameter("maxVal"),
                    'minVal': this.getParameter("minVal"),
                    'avgVal': this.getParameter("avgVal"),
                    'maxColor': '#ff0000',
                    'minColor': '#0054ff'
                };

                chart.makeHighChart_xBarCharts('highChart', chartObj, option);

            });
        }

    </script>

    <e:window id="DH1807" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <div id="highChart" style="width: 99%; height: 650px;"></div>

    </e:window>
</e:ui>
