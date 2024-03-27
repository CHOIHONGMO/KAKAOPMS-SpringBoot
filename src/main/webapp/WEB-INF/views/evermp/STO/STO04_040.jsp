<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO04_040/";
        var RowId = 0;

        function init() {

            grid = EVF.C("grid");
            EVF.C("DEAL_CD").removeOption("200");


            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.cellClickEvent(function(rowId, colId, value) {
             if(colId === "ITEM_CD") {
	                if(value !== ""){
	                    var param = {
	                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
	                        popupFlag: true,
	                        detailView: true
	                    };
	                    everPopup.im03_014open(param);
	                }
             }

            });
            grid.setColGroup([
               {
                 "groupName" : "입고",
                 "columns": [{
                    "groupName" : "구매입고",
                    "columns"    :  [ "S_GR_QTY", "S_GR_AMT" ]
                     },{
                    "groupName" : "이동입고",
                    "columns"   : [ "M_GR_QTY", "M_GR_AMT" ]
                     },{
                    "groupName" : "샘플입고",
                    "columns"   : [ "SP_GR_QTY", "SP_GR_AMT"]
                     },{
                    "groupName" : "재고조정입고",
                    "columns"   : [ "J_GR_QTY", "J_GR_AMT"]
                     },{
                    "groupName" : "기타입고",
                    "columns"   : [ "O_GR_QTY", "O_GR_AMT"]
                     }
                   ]
               },
               {
            	 "groupName" : "출고",
                 "columns": [{
                	 "groupName" : "판매출고",
                     "columns"   : [ "S_GI_QTY", "S_GI_AMT" ]
                   },{
                     "groupName" : "불량/폐기출고",
                     "columns"   : [ "F_GI_QTY", "F_GI_AMT" ]
                    },{
                     "groupName" : "재고조정출고",
                     "columns"   : [ "J_GI_QTY", "J_GI_AMT" ]
                    },{
                     "groupName" : "기타출고",
                     "columns"   : [ "O_GI_QTY", "O_GI_AMT" ]
                    },{
                     "groupName" : "이동출고",
                     "columns"   : [ "M_GI_QTY", "M_GI_AMT" ]
                    }
              	 ]
               },
               {
                 "groupName" : "기초재고",
                 "columns"   : [ "BASE_QTY", "BASE_AMT" ]
                 },{
                 "groupName" : "기말재고",
                 "columns"   : [ "CUR_QTY", "CUR_AMT" ]
                 }
               ],70);
            doSearch();

        }

        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0404_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }
        function doSave(){

            var store = new EVF.Store();
            store.setParameter("RD_DATE",grid.getCellValue(0,"RD_DATE"));
            EVF.confirm('재고수불마감(자재)을 진행 하시겠습니까?',function(){
            	store.load(baseUrl + "sto0404_doSave", function () {

           			alert(this.getResponseMessage());
            	});
            });
        }
        function doDelete(){

            var store = new EVF.Store();
            store.setParameter("RD_DATE",grid.getCellValue(0,"RD_DATE"));
            EVF.confirm('삭제시 당월 이후 데이터는 모두 삭제됩니다 진행 하시겠습니까?',function(){
            	store.load(baseUrl + "sto0404_doDelete", function () {

               		alert(this.getResponseMessage());
					doSearch();
                });
            });
        }

    </script>

    <e:window id="STO04_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="RD_DATE_Y" title="${form_RD_DATE_Y_N}"/>
            <e:field>
               <e:select id="RD_DATE_Y" name="RD_DATE_Y" value="${YYYY}" options="${rdDateYOptions}" width="98" disabled="${form_RD_DATE_Y_D}" readOnly="${form_RD_DATE_Y_RO}" required="${form_RD_DATE_Y_R}" placeHolder="" />
               <e:text>년</e:text>
               <e:select id="RD_DATE_M" name="RD_DATE_M" value="${MM}" options="${rdDateMOptions}" width="90" disabled="${form_RD_DATE_M_D}" readOnly="${form_RD_DATE_M_RO}" required="${form_RD_DATE_M_R}" placeHolder="" />
            </e:field>
            <e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
            <e:field>
               <e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
            </e:field>
            <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
               <e:field>
                     <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                 </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>