<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui>
<e:window id="EV0270P01" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    <script type="text/javascript">
	    var baseUrl = '/evermp/buyer/eval/EV0270P01';
	    var grid;
	    function init() {
	        grid = EVF.C('grid');
			grid.setColGroup([{
				"groupName": '구분',
				"columns": [ "GUBUN1", "GUBUN2" ]
			}]) // 헤더 그룹
			grid._gvo.setColumnProperty('구분', "hideChildHeaders", true); //헤더 그룹 차일드 제거
			grid.setProperty('sortable', false);
			doSearch();
	    }

	    function doSearch() {
	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + '/doSearch', function() {
				grid.setColMerge(['GUBUN1']); // 데이터 머징
				grid.setColMerge(['GUBUN2']);
				grid.setColMerge(['ESG_GROUP']);

				grid._gvo.setIndicator({ // real grid 번호 없애기
					 visible: false
				});
				grid._gvo.setCheckBar({ // 체크박스 없에기
					 visible: false
				});
				setBgColor();

	        });
	    }

	    function setBgColor(){
	    	var allgrid = grid.getAllRowValue();
	    		    var bgE = '#89aa30';
	    			var bgS = '#41a1ab';
	    			var bgG = '#cb3a25';

	    		    var cnt = 0;
	    		    for(var i in allgrid){
	    			    if(allgrid[i].GUBUN1 === 'E'){
	    				    grid.setCellBgColor(i,'GUBUN1',bgE);
	    			    }
	    				if(allgrid[i].GUBUN1 === 'S'){
	    				    grid.setCellBgColor(i,'GUBUN1',bgS);
	    			    }
	    				if(allgrid[i].GUBUN1 === 'G'){
	    				    grid.setCellBgColor(i,'GUBUN1',bgG);
	    			    }
	    		    }
	    }

	</script>
<html>
<style>
	.progress-barESG {
	    width: 100%;
	    height: 30px;
	    background-color: #dedede;
	    font-weight: 600;
	    font-size: .8rem;
	}
	.progress-barESG .progressESG {
	    width: 43.8%;
	    height: 30px;
	    padding: 0;
	    text-align: center;
	    background-color: #4F98FF;
	    color: #111;
	}



	.progress-barE {
	    width: 100%;
	    height: 30px;
	    background-color: #edf2e0;
	    font-weight: 600;
	    font-size: .8rem;
	}
	.progress-barE .progressE {
	    width: ${form.E_SCORE}%;
	    height: 30px;
	    padding: 0;
	    text-align: center;
	    background-color: #89aa30;
	    color: #111;
	    display: table;
	}




	.progress-barS {
	    width: 100%;
	    height: 30px;
	    background-color: #e3f1f2;
	    font-weight: 600;
	    font-size: .8rem;
	}
	.progress-barS .progressS {
	    width: ${form.S_SCORE}%;
	    height: 30px;
	    padding: 0;
	    text-align: center;
	    background-color: #41a1ab;
	    color: #111;
	    display: table;
	}




	.progress-barG {
	    width: 100%;
	    height: 30px;
	    background-color: #f9e7e4;
	    font-weight: 600;
	    font-size: .8rem;
	}
	.progress-barG .progressG {
	    width: ${form.G_SCORE}%;
	    height: 30px;
	    padding: 0;
	    text-align: center;
	    background-color: #cb3a25;
	    color: #111;
	    display: table;
	}
</style>
<body>
	<table border="0" width=100%>
		<tr>
			<td align="center">
				<font size="6px"><b>ESG 종합등급</b></font>
			</td>
		</tr>
	</table>
	<table border="0" width="900px">
		<tr>
			<td width="100px" align="center" rowspan="2"  style="font-style:Poppins,SemiBold;font-size:28px;">
			<!-- font color="#1DDB16">E</font><font color="blue">S</font><font color="red">G</font>3-->
			</td>
			<td width="700px">
			    <font size="3px">${form.TOTAL_SCORE_TEXT} </font>
			</td>
			<td width="100px">
			    <font size="3px" color="orange">(업체평균 : ${form.TOTAL_AVG_SCORE_DEGREE}) </font>
			</td>
		</tr>
		<tr>
			<td width="900px" colspan="3">
				<table border="0" width="100%" height="60px">
					<tr>
						<td width="25%" align="center" bgcolor="#2fb82a">${form.TOTAL_SCORE_DEGREE == 'A' ? '<b><font size="6">A</b></font>' : 'A'}</td>
						<td width="25%" align="center" bgcolor="#dcf78f">${form.TOTAL_SCORE_DEGREE == 'B+' ? '<b><font size="6">B+</b></font>' : 'B+'}</td>
						<td width="25%" align="center" bgcolor="#fdf353">${form.TOTAL_SCORE_DEGREE == 'B' ? '<b><font size="6">B</b></font>' : 'B'}</td>
						<td width="25%" align="center" bgcolor="#db1900">${form.TOTAL_SCORE_DEGREE == 'C' ? '<b><font size="6">C</b></font>' : 'C'}</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br/>

	<table border="0" width="900px">
		<tr>
			<td width="100px">
			</td>
			<td width="900px">
				<hr style="border: solid 1px #222222;"/>
			</td>
		</tr>
	</table>
	<br/>
	<table border="0" width="900px">
		<tr>
			<td width="100px" align="center" rowspan="3"  style="font-style:Poppins,SemiBold;font-size:28px;color:#89aa30;">
			E-${form.E_SCORE_DEGREE}
			</td>
			<td width="700px">
			    ${form.E_SCORE_TEXT} &nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<td width="130px">
				<font size="3px" color="orange">(업체평균 : ${form.E_AVG_SCORE}) </font>
			</td>
		</tr>
		<tr>
			<td width="900px"  colspan="3">
				<table border="0" width="100%" height="30px">
					<tr>
						<div class="progress-barE" >
						   <div class="progressE">
							   <div class="progressAE" style="display: table-cell; vertical-align: middle;">
						   			${form.E_SCORE}
						   	   </div>
						   </div>
						</div>
					</tr>
					<tr>
						<td width="20%" align="left"><font size="2px">0</font></td>
						<td width="20%" align="left"><font size="2px">20</font></td>
						<td width="20%" align="left"><font size="2px">40</font></td>
						<td width="20%" align="left"><font size="2px">60</font></td>
						<td width="20%" align="left"><font size="2px">80</font></td>
						<td width="20%" align="left"><font size="2px">100</font></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
		<br>

	<table border="0" width="900px">
		<tr>
			<td width="100px" align="center" rowspan="2"  style="font-style:Poppins,SemiBold;font-size:28px;color:#41a1ab;">
			S-${form.S_SCORE_DEGREE}
			</td>
			<td width="700px">
			    ${form.S_SCORE_TEXT} &nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<td width="130px">
				<font size="3px" color="orange">(업체평균 : ${form.S_AVG_SCORE}) </font>
			</td>
		</tr>
		<tr>
			<td width="900px"  colspan="3">
				<table border="0" width="100%" height="30px">
					<tr>
						<div class="progress-barS" >
						   <div class="progressS">
							   <div class="progressAS" style="display: table-cell; vertical-align: middle;">
						   			${form.S_SCORE}
						   	   </div>
						   </div>
						</div>
					</tr>
					<tr>
						<td width="20%" align="left"><font size="2px">0</font></td>
						<td width="20%" align="left"><font size="2px">20</font></td>
						<td width="20%" align="left"><font size="2px">40</font></td>
						<td width="20%" align="left"><font size="2px">60</font></td>
						<td width="20%" align="left"><font size="2px">80</font></td>
						<td width="20%" align="left"><font size="2px">100</font></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br>
	<table border="0" width="900px">
		<tr>
			<td width="100px" align="center" rowspan="2" style="font-style:Poppins,SemiBold;font-size:28px;color:#cb3a25;">
			G-${form.G_SCORE_DEGREE}
			</td>
			<td width="700px">
			    ${form.G_SCORE_TEXT} &nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<td width="130px">
				<font size="3px" color="orange">(업체평균 : ${form.G_AVG_SCORE}) </font>
			</td>
		</tr>
		<tr>
			<td width="900px" colspan="3">
				<table border="0" width="100%" height="30px">
					<tr>
						<div class="progress-barG" >
						   <div class="progressG">
							   <div class="progressAG" style="display: table-cell; vertical-align: middle;">
						   			${form.G_SCORE}
						   	   </div>
						   </div>
						</div>
					</tr>
					<tr>
						<td width="20%" align="left"><font size="2px">0</font></td>
						<td width="20%" align="left"><font size="2px">20</font></td>
						<td width="20%" align="left"><font size="2px">40</font></td>
						<td width="20%" align="left"><font size="2px">60</font></td>
						<td width="20%" align="left"><font size="2px">80</font></td>
						<td width="20%" align="left"><font size="2px">100</font></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>
	<div align="center">
	<e:inputHidden id="EV_NUM" name="EV_NUM" value="${param.EV_NUM}"/>
	<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"/>

	<table border="0">
		<tr>
			<td>
				<font size="6px"><b>ESG 평가요약</b></font>
			</td>
		</tr>
	</table>

    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="90%" height="550" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</div>

</e:window>
</e:ui>

