<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/regEval/eval/SRM_510';
    var grid;

    function init() {
        grid = EVF.C('grid');
        grid.setProperty('shrinkToFit', true);
        EVF.C('EV_TYPE').removeOption('S');
        EVF.C('EV_TYPE').removeOption('R');
        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
            if(colId == '') {

            }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case '':

            default:
            }
        });

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

    }

    function doSearch() {

    	<%-- 날짜 체크 --%>
        if(!everDate.checkTermDate('REG_DATE_FROM','REG_DATE_TO','${msg.M0073}')) {
            return;
        }

        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }


    </script>
<e:window id="SRM_510" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch">
    <e:row>
    	<%-- 평가생성일 --%>
		<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
		<e:text>~&nbsp;</e:text>
		<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
		</e:field>

		<%-- 평가구분 --%>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field>
		<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${inputTextWidth}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

</e:window>
</e:ui>
