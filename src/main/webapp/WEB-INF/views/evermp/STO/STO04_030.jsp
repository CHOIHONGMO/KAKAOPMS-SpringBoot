<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO04_030/";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty("shrinkToFit", true);        			// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});      			// 컬럼 정렬기능 사용여부를 지정한다. [true/false]

		    grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			EVF.C('YEAR_MONTH').setDisabled(true);
            grid.setColGroup([
            	 {
	            	 "groupName" : "기초",
	                 "columns"    :  [ "TRAN_QTY", "TRAN_AMT" ]
                  },{
	                 "groupName" : "입고",
	                 "columns"   : [ "GR_QTY", "GR_AMT" ]
                  },{
	                 "groupName" : "출고",
	                 "columns"   : [ "GI_QTY", "GI_AMT" ]
                  },{
	                 "groupName" : "기말",
	                 "columns"   : [ "CUR_QTY", "CUR_AMT"]
                  }
               ],50);
            doSearch();

        }

        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0403_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

    </script>

    <e:window id="STO04_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
			<e:label for="YEAR_MONTH" title="${form_YEAR_MONTH_N}" />
			<e:field>
				<e:inputText id="YEAR_MONTH" name="YEAR_MONTH" value="${param.YEAR_MONTH}" width="${form_YEAR_MONTH_W}" maxLength="${form_YEAR_MONTH_M}" disabled="${form_YEAR_MONTH_D}" readOnly="${form_YEAR_MONTH_RO}" required="${form_YEAR_MONTH_R}" />
			</e:field>
            <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
            <e:field>
                <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
            </e:field>
            <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
			<e:field>
				<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
			</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>