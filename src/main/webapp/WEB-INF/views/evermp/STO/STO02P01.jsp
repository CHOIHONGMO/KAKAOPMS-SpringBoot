<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO02P01/";
        var selRow;

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', true);
            grid.setProperty("rowNumbers", false);
            grid.setProperty("multiSelect", true);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(selRow == undefined) selRow = rowId;

                if(colId == "multiSelect") {
                    if (selRow != rowId) {
                        grid.checkRow(selRow, false);
                        selRow = rowId;
                    }
                }
            });

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'sto02p01_doSearch', function() {
            });
        }

        function doClose() {
            window.close();
        }

        function doChoice() {
            var selected = grid.getSelRowValue()[0];
            if(opener != null){opener.window['${param.callBackFunction}'](JSON.stringify(selected));}
            else{parent.window['${param.callBackFunction}'](JSON.stringify(selected));}
            doClose();
        }


    </script>

    <e:window id="STO02P01" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
         <e:row>
             <e:inputHidden id="DEAL_CD" name="DEAL_CD" value="${param.DEAL_CD }" />

             <e:label for="STR_CTRL_CODE" title="${form_STR_CTRL_CODE_N}"/>
             <e:field>
                 <e:select id="STR_CTRL_CODE" name="STR_CTRL_CODE" value="" options="${strCtrlCodeOptions}" width="${form_STR_CTRL_CODE_W}" disabled="${form_STR_CTRL_CODE_D}" readOnly="${form_STR_CTRL_CODE_RO}" required="${form_STR_CTRL_CODE_R}" placeHolder="" />
             </e:field>
             <c:if test="${param.DEAL_CD == ''}">
             <e:label for="WAREHOUSE_TYPE" title="${form_WAREHOUSE_TYPE_N}"/>
             <e:field>
                 <e:select id="WAREHOUSE_TYPE" name="WAREHOUSE_TYPE" value="" options="${warehouseTypeOptions}" width="${form_WAREHOUSE_TYPE_W}" disabled="${form_WAREHOUSE_TYPE_D}" readOnly="${form_WAREHOUSE_TYPE_RO}" required="${form_WAREHOUSE_TYPE_R}" placeHolder="" />
             </e:field>
             </c:if>
             <c:if test="${param.DEAL_CD == '400'}">
                 <e:label for="WAREHOUSE_TYPE" title="${form_WAREHOUSE_TYPE_N}"/>
                 <e:field>
                     <e:select id="WAREHOUSE_TYPE" name="WAREHOUSE_TYPE" value="030" options="${warehouseTypeOptions}" width="${form_WAREHOUSE_TYPE_W}" disabled="true" readOnly="${form_WAREHOUSE_TYPE_RO}" required="${form_WAREHOUSE_TYPE_R}" placeHolder="" />
                 </e:field>
             </c:if>
             <c:if test="${param.DEAL_CD == '100'}">
                 <e:label for="WAREHOUSE_TYPE" title="${form_WAREHOUSE_TYPE_N}"/>
                 <e:field>
                     <e:select id="WAREHOUSE_TYPE" name="WAREHOUSE_TYPE" value="010" options="${warehouseTypeOptions}" width="${form_WAREHOUSE_TYPE_W}" disabled="true" readOnly="${form_WAREHOUSE_TYPE_RO}" required="${form_WAREHOUSE_TYPE_R}" placeHolder="" />
                 </e:field>
             </c:if>

         </e:row>
        </e:searchPanel>


        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="Choice" name="Choice" label="${Choice_N}" disabled="${Choice_D}" visible="${Choice_V}" onClick="doChoice" />
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>