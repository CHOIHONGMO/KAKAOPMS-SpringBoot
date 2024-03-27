<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script>
google.charts.load('current', {packages: ['corechart', 'bar']});
google.charts.setOnLoadCallback(drawStacked);

	function drawStacked() {
	    var data = google.visualization.arrayToDataTable([
	        ['Year', 'ESG3', { role: 'style' } ],
	        ['ESG3', 3, 'opacity: 0.2']
	      ]);

	      var options = {
	        title: '지속가능경영을 위한 환경,사회,경영시스템 체계 및 성과가 양호한 수준임',
	        chartArea: {width: '50%',heigth: '10%'},
	        isStacked: true,
	        hAxis: {
	          title: 'Total Population',
	          minValue: 0,
	          minValue: 7,
	        },
	      };
	      var chart = new google.visualization.BarChart(document.getElementById('chart_div1'));
	      chart.draw(data, options);





		var data = google.visualization.arrayToDataTable([
	        ['Year', 'E5', { role: 'style' } ],
	        ['E5', 58, 'color: gray'],
	        ['S2', 71, 'color: #76A7FA'],
	        ['G2', 33, 'opacity: 0.2'],
	      ]);

	      var options = {
	        title: 'Population of Largest U.S. Cities',
	        chartArea: {width: '50%'},
	        isStacked: true,
	        hAxis: {
	          title: 'Total Population',
	          minValue: 0,
	          minValue: 100,
	        },
	        vAxis: {
	          title: 'ESG'
	        }
	      };
	      var chart = new google.visualization.BarChart(document.getElementById('chart_div2'));
	      chart.draw(data, options);
	}
</script>
<div id="chart_div1"></div>
<BR/>
<div id="chart_div2"></div>
