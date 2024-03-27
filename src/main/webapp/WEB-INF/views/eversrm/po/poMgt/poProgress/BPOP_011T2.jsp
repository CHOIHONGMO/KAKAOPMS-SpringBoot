<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

        var grid = {};
        var baseUrl = "/eversrm/po/poMgt/poProgress/BPOP_011T1/";

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
                    ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }else{
                    dodrawChart();
                }

            });
        }

        function dodrawChart(){
            console.log("ㄹ?");

            grid.setProperty('highChart', true);
            grid.setHighCharts('StockChart', ['VENDOR_NM', 'PO_AMT'], false);
            grid.makeHighChart();
        }




    </script>

	<e:window id="BPOP_011T2" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="PO_FROM_DATE" name="PO_FROM_DATE" value="${param.PO_FROM_DATE}"/>
        <e:inputHidden id="PO_TO_DATE" name="PO_TO_DATE" value="${param.PO_TO_DATE}"/>
        <e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${param.PURCHASE_TYPE}"/>
        <e:inputHidden id="PO_CLOSE_FLAG" name="PO_CLOSE_FLAG" value="${param.PO_CLOSE_FLAG}"/>
        <e:inputHidden id="PO_NUM" name="PO_NUM" value="${param.PO_NUM}"/>
        <e:inputHidden id="SUBJECT" name="SUBJECT" value="${param.SUBJECT}"/>
        <e:inputHidden id="VENDOR_NM" name="VENDOR_NM" value="${param.VENDOR_NM}"/>
        <e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${param.CTRL_USER_ID}"/>
        <e:inputHidden id="CTRL_USER_NM" name="CTRL_USER_NM" value="${param.CTRL_USER_NM}"/>
        <e:inputHidden id="PO_APRV_ID" name="PO_APRV_ID" value="${param.PO_APRV_ID}"/>
        <e:inputHidden id="PO_APRV_NM" name="PO_APRV_NM" value="${param.PO_APRV_NM}"/>
        <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${param.PROGRESS_CD}"/>
        <e:inputHidden id="RECEIPT_STATUS" name="RECEIPT_STATUS" value="${param.RECEIPT_STATUS}"/>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
