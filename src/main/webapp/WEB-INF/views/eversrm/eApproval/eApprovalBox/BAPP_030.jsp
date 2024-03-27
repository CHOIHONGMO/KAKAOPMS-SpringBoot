<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var grid;
    var baseUrl = "/eversrm/eApproval/eApprovalModule/";

    function init() {

        grid = EVF.C("grid");
        //grid.setProperty('shrinkToFit', true);
        grid.setProperty('panelVisible', "${panelVisible}");
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

        EVF.C('GATE_CD').setValue("${param.GATE_CD}");
        EVF.C('APP_DOC_NUM').setValue("${param.APP_DOC_NUM}");
        EVF.C('APP_DOC_CNT').setValue("${param.APP_DOC_CNT}");

        grid.setProperty('shrinkToFit', true);
        grid.setProperty('multiSelect', false);

        doSearch();
    }

    function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter("userType", "${ses.userType}");
        store.load(baseUrl + 'BAPP_030/selectPathPopup', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
                var rowIds = grid.getAllRowId();
                for(var i in rowIds) {
                    if(grid.getCellValue(rowIds[i], 'SIGN_STATUS_CD') == "E") {
                        grid.setCellFontColor(rowIds[i], 'SIGN_STATUS', "#5b58ff");
                        grid.setCellFontWeight(rowIds[i], 'SIGN_STATUS', true);
                    }
                    if(grid.getCellValue(rowIds[i], 'SIGN_STATUS_CD') == "R") {
                        grid.setCellFontColor(rowIds[i], 'SIGN_STATUS', "#ff4c29");
                        grid.setCellFontWeight(rowIds[i], 'SIGN_STATUS', true);
                    }
                }
            }
        });
    }

    function doClose() {
        window.close();
    }

    </script>

    <e:window id="BAPP_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:inputHidden id="GATE_CD"        name="GATE_CD"/>
		<e:inputHidden id="APP_DOC_NUM"    name="APP_DOC_NUM"/>
		<e:inputHidden id="APP_DOC_CNT"    name="APP_DOC_CNT"/>

<%--     	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
            <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="doClose" />
        </e:buttonBar> --%>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>