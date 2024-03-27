<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO01_020/";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_009open(param);
                }
            });
            console.log("${form}")
            EVF.C('DEAL_CD').removeOption("200");

           <c:if test= "${form.searchFlag == 'Y'}">
           	  EVF.C('DEAL_CD').setDisabled(true);
           	  $("#Save").hide();
           	  grid.hideCol("SAFE_QTY",true);
           	  grid.hideCol("SAVE_QTY",true);
           </c:if>
           <c:if test= "${form.searchFlag != 'Y'}">
          	  $("#doChoice").hide();
           </c:if>
            doSearch();
        }

        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0102_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }
        function doSave() {

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if (!confirm("${msg.M0021}")) return;

            var rowIds = grid.getSelRowId();

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "sto0102_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }


        function searchVendorCd(){
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }
        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

	    function doChoice() {
            var selected = grid.getSelRowValue()[0];
            opener.window['${form.callBackFunction}'](JSON.stringify(selected));
            window.close();
        }




    </script>

    <e:window id="STO01_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
					<e:select id="DEAL_CD" name="DEAL_CD" value="${form.DEAL_CD}" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
              	<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
				<e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
					<e:inputHidden id="MAKER_CD" name="MAKER_CD"/>
					<e:inputHidden id="MAKER_PART_NO" name="MAKER_PART_NO"/>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        	<e:button id="doChoice" name="doChoice" label="${doChoice_N}" onClick="doChoice" disabled="${doChoice_D}" visible="${doChoice_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>