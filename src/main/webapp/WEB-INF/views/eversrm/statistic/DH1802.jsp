<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

  <!-- Resources -->
  <script src="https://code.highcharts.com/highcharts.js"></script>
  <script src="https://code.highcharts.com/modules/exporting.js"></script>

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
      if(!store.validate()) return;
      store.load(baseUrl+'/DH1800/doSearch', function() {

        var C_Json = JSON.parse(this.getParameter("chartObj"));
        var data = [];
        var datas = [];
        for (var k = 0; k < C_Json.length; k++) {

          data = [C_Json[k].COUNTRY, C_Json[k].VISITS];
          datas.push(data);
        }
        $(function () {
          $('#container').highcharts({
            chart: {
              type: 'column'
            },
            title: {
              text: '테스트 high-Chart'
            },
            xAxis: {
              type: "category",
              crosshair: true
            },
            yAxis: {
              min: 0,
              title: {
                text: 'Rainfall (mm)'
              }
            },
            tooltip: {
              headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
              pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
              '<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>',
              footerFormat: '</table>',
              shared: true,
              useHTML: true
            },
            plotOptions: {
              column: {
                pointPadding: 0.2,
                borderWidth: 0
              }
            },
            series: [{
              name: 'COUNTRY',
              data: datas

            }]
          });
        });
      });
    }

  </script>

  <e:window id="DH1802" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    <e:panel id="amchart" width="1000px" height="50%">
      <e:row>
        <e:field>
          <div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
        </e:field>
      </e:row>
    </e:panel>



  </e:window>
</e:ui>
