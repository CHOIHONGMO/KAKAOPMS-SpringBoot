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
      store.load(baseUrl + '/DH1800/doSearch', function () {

        var chartObj = JSON.parse(this.getParameter("chartObj"));
        // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
        var option = {
          'chartType': 'type',
          'chartNm': 'column',
          'singleFlag': true, // single 여부가 false 이면 multi 동작
          'max': 4,
          'min': 1,
          'maxColor': '#ff0000',
          'minColor': '#0054ff'
        };
        chart.makeHighChart_Column('highChart', chartObj, option);



      });

      store.load(baseUrl + '/DH1800/doSearch_multi', function () {

        var chartObj2 = JSON.parse(this.getParameter("chartObj2"));
        // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
        var option2 = {
          'chartType': 'type',
          'chartNm': 'column',
          'singleFlag': false, // single 여부가 false 이면 multi 동작
          'max': 4,
          'min': 1,
          'maxColor': '#ff0000',
          'minColor': '#0054ff'
        };
//        var strData = '[{"A": "서울", "B": 100, "C": 200, "D": 300, "E": 400},{"A": "부산", "B": 200, "C": 300, "D": 400, "E": 100},{"A": "대전", "B": 300, "C": 400, "D": 100, "E": 200},{"A": "대구", "B": 400, "C": 100, "D": 200, "E": 300}]';
//        var data = JSON.parse(strData);
//        console.log(chartObj2);
        chart.makeHighChart_Column('highChart2', chartObj2, option2);


      });

    }

  </script>

  <e:window id="DH1800" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    <e:buttonBar align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>

    <div id="highChart" style="width: 650px; height: 350px;"></div>

    <br><hr><br>
    <div id="highChart2" style="width: 650px; height: 350px;"></div>
  </e:window>
</e:ui>
