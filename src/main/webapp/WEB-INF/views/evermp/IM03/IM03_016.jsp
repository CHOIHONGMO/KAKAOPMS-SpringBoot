<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var grid;
	var baseUrl = "/evermp/IM03/IM0301/";

	function init(){

        grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value) {
            if (colId == "ITEM_RMK") {
                var param = {
                    title: "품목상세설명",
                    message: value,
                    callbackFunction: "callbackGridITEM_RMK",
                    rowId: rowId
                };
                var url = '/common/popup/common_text_input/view';
                everPopup.openModalPopup(url, 500, 310, param);
            } else if(colId == "RFQ_REQ_TXT") {
                var param = {
                    title: "요청사항",
                    message: value,
                    callbackFunction: "callbackGridRFQ_REQ_TXT",
                    rowId: rowId
                };
                var url = '/common/popup/common_text_input/view';
                everPopup.openModalPopup(url, 500, 310, param);
            } else if(colId == 'IMAGE_UUID_IMG') {
                everPopup.fileAttachPopup("IMAGE", grid.getCellValue(rowId, "IMAGE_UUID"), "callbackGridIMAGE_UUID_IMG", rowId, false);
            } else if(colId == 'ATTACH_FILE_NO_IMG') {
                everPopup.fileAttachPopup("IMAGE", grid.getCellValue(rowId, "ATTACH_FILE_NO"), "callbackGridATTACH_FILE_NO_IMG", rowId, false);
            }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            if(colId == 'ORIGIN_NM') {
            }
        });

        grid.addRowEvent(function() {
            grid.addRow([{
                UNIT_CD: "EA",
                CUR: "KRW"
            }]);
        });

        grid.delRowEvent(function() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            grid.delRow();
        });

        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        grid.excelImportEvent({
            append: false
        }, function (msg, code) {
            if (code) {
                grid.checkAll(true);
            }
        });
	}

	function callbackGridITEM_RMK(data) {
        if(!EVF.isEmpty(data.message)) {
            grid.setCellValue(data.rowId, 'ITEM_RMK', data.message);
        }
    }

    function callbackGridRFQ_REQ_TXT(data) {
        if(!EVF.isEmpty(data.message)) {
            grid.setCellValue(data.rowId, 'RFQ_REQ_TXT', data.message);
        }
    }

    function callbackGridIMAGE_UUID_IMG(rowId, uuid, fileCount) {
        if(fileCount > 0) {
            grid.setCellValue(rowId, 'IMAGE_UUID', uuid);
            grid.setCellValue(rowId, 'IMAGE_UUID_IMG', 'Y');
        }
    }

    function callbackGridATTACH_FILE_NO_IMG(rowId, uuid, fileCount) {
        if(fileCount > 0) {
            grid.setCellValue(rowId, 'ATTACH_FILE_NO', uuid);
            grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', 'Y');
        }
    }

    function doRequest() {
        var store = new EVF.Store();
        if (!store.validate()) { return; }

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        var rows = grid.getSelRowValue();
        for( var i = 0; i < rows.length; i++ ) {

        }

        if (!confirm("${IM03_016_001}")) return;

        store.setGrid([grid]);
        store.getGridData(grid, "sel");
        store.load(baseUrl + "im03016_doRequest", function () {
            alert(this.getResponseMessage());

            if(parent["${param.callbackFunction}"]) {
                parent["${param.callbackFunction}"]();
                new EVF.ModalWindow().close(null);
            } else if(opener) {
                opener["${param.callbackFunction}"]();
                window.close();
            }
        });
    }

    function searchCUST_CD() {
        var param = {
            callBackFunction : "callbackCUST_CD"
        };
        everPopup.openCommonPopup(param, 'SP0902');
    }

    function callbackCUST_CD(data) {
        EVF.C("CUST_CD").setValue(data.CUST_CD);
        EVF.C("CUST_NM").setValue(data.CUST_NM);

        EVF.C("ADD_PLANT_CD").setValue("");
        EVF.C("ADD_PLANT_NM").setValue("");
        EVF.C("ADD_USER_ID").setValue("");
        EVF.C("ADD_USER_NM").setValue("");
    }

    function onSearchPlant() {
		if( EVF.V("CUST_CD") == "" ) return alert("${IM03_016_002}");
		var param = {
	           callBackFunction : "callback_Plant",
	           custCd: EVF.V("CUST_CD")
		};
		everPopup.openCommonPopup(param, 'SP0005');
    }

    function callback_Plant(data) {
        jsondata = JSON.parse(JSON.stringify(data));
        EVF.C("ADD_PLANT_CD").setValue(jsondata.PLANT_CD);
        EVF.C("ADD_PLANT_NM").setValue(jsondata.PLANT_NM);

        EVF.C("ADD_USER_ID").setValue("");
        EVF.C("ADD_USER_NM").setValue("");
    }

    function searchADD_USER_ID() {
	    if(EVF.V("CUST_NM") === "") {
	        alert("${IM03_016_002}");
	        return;
        }

        var param = {
            callBackFunction : "callbackADD_USER_ID",
            custCd : EVF.V("CUST_CD"),
            plantCd: EVF.V("ADD_PLANT_CD")
        };
        everPopup.openCommonPopup(param, 'SP0083');
    }

    function callbackADD_USER_ID(data) {
        EVF.C("ADD_USER_ID").setValue(data.USER_ID);			// 신청자ID
        EVF.C("ADD_USER_NM").setValue(data.USER_NM);			// 신청자명
        EVF.C("ADD_PLANT_CD").setValue(data.PLANT_CD);			// 사업장코드
        EVF.C("ADD_PLANT_NM").setValue(data.PLANT_NM);			// 사업장명
        EVF.C("REQ_DIVISION_CD").setValue(data.DIVISION_CD);	// 사업부코드
        EVF.C("REQ_DEPT_CD").setValue(data.DEPT_CD);			// 부서코드
        EVF.C("REQ_PART_CD").setValue(data.PART_CD);			// 파트코드
        EVF.C("BUDGET_DEPT_CD").setValue(data.BUDGET_DEPT_CD);	// 예산부서코드
    }

 </script>
	<e:window id="IM03_016" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="REQ_DIVISION_CD" name="REQ_DIVISION_CD" value="" />	<!-- 요청 사업부 -->
			<e:inputHidden id="REQ_DEPT_CD" name="REQ_DEPT_CD" value="" />	<!-- 요청 부서 -->
			<e:inputHidden id="REQ_PART_CD" name="REQ_PART_CD" value="" />	<!-- 요청 파트(영업장) -->
			<e:inputHidden id="BUDGET_DEPT_CD" name="BUDGET_DEPT_CD" value="" />	<!-- 요청자 예산부서코드 -->

			<e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCUST_CD" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="ADD_PLANT_CD" title="${form_ADD_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="ADD_PLANT_CD" name="ADD_PLANT_CD" value="" width="40%" maxLength="${form_ADD_PLANT_CD_M}" disabled="${form_ADD_PLANT_CD_D}" readOnly="${form_ADD_PLANT_CD_RO}" required="${form_ADD_PLANT_CD_R}" onIconClick="onSearchPlant" onChange="onChangePlant" />
                    <e:inputText id="ADD_PLANT_NM" name="ADD_PLANT_NM" value="" width="60%" maxLength="${form_ADD_PLANT_NM_M}" disabled="${form_ADD_PLANT_NM_D}" readOnly="${form_ADD_PLANT_NM_RO}" required="${form_ADD_DEPT_NM_R}" />
                </e:field>
                <e:label for="ADD_USER_ID" title="${form_ADD_USER_ID_N}"/>
                <e:field>
                    <e:search id="ADD_USER_ID" name="ADD_USER_ID" value="" width="40%" maxLength="${form_ADD_USER_ID_M}" onIconClick="searchADD_USER_ID" disabled="${form_ADD_USER_ID_D}" readOnly="${form_ADD_USER_ID_RO}" required="${form_ADD_USER_ID_R}" />
                    <e:inputText id="ADD_USER_NM" name="ADD_USER_NM" value="" width="60%" maxLength="${form_ADD_USER_NM_M}" disabled="${form_ADD_USER_NM_D}" readOnly="${form_ADD_USER_NM_RO}" required="${form_ADD_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REQUEST_DATE" title="${form_REQUEST_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REQUEST_DATE" name="REQUEST_DATE" value="${REQUEST_DATE}" toDate="HOPE_DUE_DATE" width="${inputDateWidth}" datePicker="true" required="${form_REQUEST_DATE_R}" disabled="${form_REQUEST_DATE_D}" readOnly="${form_REQUEST_DATE_RO}" />
                </e:field>
				<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
				<e:field>
					<e:inputDate id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="" fromDate="REQUEST_DATE" width="${inputDateWidth}" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
				</e:field>
				<e:label for="RFQ_REQ_TXT" title="${form_RFQ_REQ_TXT_N}" />
				<e:field>
					<e:inputText id="RFQ_REQ_TXT" name="RFQ_REQ_TXT" value="" width="${form_RFQ_REQ_TXT_W}" maxLength="${form_RFQ_REQ_TXT_M}" disabled="${form_RFQ_REQ_TXT_D}" readOnly="${form_RFQ_REQ_TXT_RO}" required="${form_RFQ_REQ_TXT_R}" />
				</e:field>
			 </e:row>
		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
            <e:button id="Request" name="Request" label="${Request_N}" onClick="doRequest" disabled="${Request_D}" visible="${Request_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>