<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
    var baseUrl = "/eversrm/po/poMgt/poRegistration/";

    function init() {
        grid = EVF.getComponent("grid");

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
    })
        grid.addRowEvent(function () {
	        grid.addRow();
	    });

	    grid.delRowEvent(function() {
			grid.delRow();
	    });

		doSearch();
    }

    function doSearch() {

    	var store = new EVF.Store();
		if(!store.validate()) { return; }

		if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');

    	store.setGrid([grid]);
        store.load(baseUrl + 'doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }

        });
    }

    </script>

	<e:window id="BPOM_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" onEnter="doSearch">
			<e:row>
				<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
				</e:field>

				<e:label for="TEST" title="${form_TEST_N}" />
				<e:field>
					<e:inputText id="TEST" name="TEST" value="" width="100%" maxLength="${form_TEST_M}" disabled="${form_TEST_D}" readOnly="${form_TEST_RO}" required="${form_TEST_R}" />
				</e:field>

				<e:label for="DEL_FLAG" title="${form_DEL_FLAG_N}" />
				<e:field>
					<e:select id="DEL_FLAG" name="DEL_FLAG" value="" options="${refYN}" width="${inputTextWidth}" disabled="${form_DEL_FLAG_D}" readOnly="${form_DEL_FLAG_RO}" required="${form_DEL_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
