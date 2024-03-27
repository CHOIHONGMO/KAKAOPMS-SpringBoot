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
            store.load(baseUrl + '/DH1806/doSearch', function () {

                var chartObj = JSON.parse(this.getParameter("chartObj"));
                // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
                var option = {
                    'chartType': 'type',
                    'chartNm': 'column',
                    'singleFlag': true, // single 여부가 false 이면 multi 동작
                    'max': 4,
                    'min': 1,
                    'maxColor': '#ff0000',
                    'minColor': '#0054ff',
                    'leftyNm' : '막대',
                    'RightyNm': '선',
                    'widhtSize' : 35,
                    'Colors' : ['#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1']
                };

                chart.makeHighChart_CombiCharts('Histogram #1','highChart', chartObj, 'column', 'spline', option);  //왼쪽 Y축 타입, 오른쪽 Y축 타입 필수 넘겨줄것.

            });


        }

    </script>

    <e:window id="DH1806" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <div id="highChart" style="width: 900px; height: 600px;"></div>
    </e:window>
</e:ui>
