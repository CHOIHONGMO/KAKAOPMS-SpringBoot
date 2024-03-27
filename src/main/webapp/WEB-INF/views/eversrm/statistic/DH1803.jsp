<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <!-- Resources -->
    <link rel="stylesheet" href="https://www.amcharts.com/lib/3/plugins/export/export.css" type="text/css" media="all"/>
    <script src="https://www.amcharts.com/lib/3/amcharts.js"></script>
    <script src="https://www.amcharts.com/lib/3/serial.js"></script>
    <script src="https://www.amcharts.com/lib/3/plugins/export/export.min.js"></script>
    <script src="https://www.amcharts.com/lib/3/themes/none.js"></script>
    <script src="/js/ever-chart.js"></script>

    <style>
        #amChart {
            width: 100%;
            height: 500px;
        }

        .amcharts-export-menu-top-right {
            top: 10px;
            right: 0;
        }
    </style>


    <!-- Chart code -->
    <script>
        var baseUrl = '/eversrm/statistic';
        var selRow;
        var chart;

        function init() {
            doSearch();
        }

        // Search
        // Search
        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) return;
            store.load(baseUrl + '/DH1800/doSearch', function () {

                var chartObj = JSON.parse(this.getParameter("chartObj"));
                var strData = '[{"SUBJECT": "서울", "TEST1": 100, "TEST2": 200, "TEST3": 300, "TEST4": 400},{"SUBJECT": "부산", "TEST1": 200, "TEST2": 300, "TEST3": 400, "TEST4": 100},{"SUBJECT": "대전", "TEST1": 300, "TEST2": 400, "TEST3": 100, "TEST4": 200},{"SUBJECT": "대구", "TEST1": 400, "TEST2": 100, "TEST3": 200, "TEST4": 300}]';
                var data = JSON.parse(strData);

                // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
                var option = {
                    'chartType': 'column',
                    'chartNm': 'serial',
                    'theme': 'light',
                    'singleFlag': true, // single 여부가 false 이면 multi 동작
                    'max': 4,
                    'min': 1,
                    'maxColor': '#ff0000',
                    'minColor': '#0054ff'
                };

                chart.makeAmChart_Column('amChart', chartObj, option);

            });
        }

    </script>

    <e:window id="DH1803" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <div id="amChart"></div>

    </e:window>
</e:ui>
