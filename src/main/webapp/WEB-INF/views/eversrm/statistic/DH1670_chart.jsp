<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>
  <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawVisualization);
      function drawVisualization() {

        var data = google.visualization.arrayToDataTable([
          ['Month',${param.CDATA}],
          ${param.DATA}
        ]);

        var options = {
          title: '${param.TITLE}',
          seriesType: 'bars',
          chartArea : {left : 40, width : 1170 , height : 600},
          series: { '${param.CZLINE}': {type: 'line'}, '${param.CRLINE}' : {type: 'line'}}
        };

        var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div id="chart_div" style="width: 1340px; height: 710px;"></div>
  </body>
</html>