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
            store.load(baseUrl + '/DH1809/doSearch', function () {

            	var chartObjH = JSON.parse(this.getParameter("chartObjH"));
                // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
                var optionH = {
                    'title': "data의 Xbar-R 관리도",
                	'chartType': 'type',
                    'chartNm': 'column',
                    'xMax': "25",
                    'yMin': this.getParameter("yMinH"),
                    'yMax': this.getParameter("yMaxH"),
                    'maxVal': this.getParameter("maxValH"),
                    'avgVal': this.getParameter("avgValH"),
                    'minVal': this.getParameter("minValH"),
                    'maxColor': '#ff0000',
                    'minColor': '#0054ff'
                };
                chart.makeHighChart_xbarRcharts('highChartH', chartObjH, optionH);

                var chartObjB = JSON.parse(this.getParameter("chartObjB"));
                // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
                var optionB = {
                    'title': "",
                	'chartType': 'type',
                    'chartNm': 'column',
                    'xMax': "25",
                    'yMin': this.getParameter("yMinB"),
                    'yMax': this.getParameter("yMaxB"),
                    'maxVal': this.getParameter("maxValB"),
                    'avgVal': this.getParameter("avgValB"),
                    'minVal': this.getParameter("minValB"),
                    'maxColor': '#ff0000',
                    'minColor': '#0054ff'
                };
                chart.makeHighChart_xbarRcharts('highChartB', chartObjB, optionB);

            });
        }

    </script>

    <e:window id="DH1809" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <div id="highChartH" style="width: 90%; height: 300px;"></div>

		<br><br><br><br><br>

        <div id="highChartB" style="width: 90%; height: 300px;"></div>

    </e:window>
</e:ui>
