<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var grid;
	var baseUrl = "/evermp/BYM1/BYM1_060/";

	function init(){
        grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colName, value) {
            var USER_ID = "";
            var USER_TYPE = "";

            if(colName === 'VC_NO') {
                doSavePop(value);
            } else if(colName === 'REQ_USER_NM') {
                USER_ID = grid.getCellValue(rowId, "REQ_USER_ID");
            } else if(colName === 'DS_USER_NM') {
                USER_ID = grid.getCellValue(rowId, "DS_USER_ID");
            }

            if(USER_ID !== "") {
                var param = {
                    callbackFunction: "",
                    USER_ID: USER_ID,
                    detailView: true
                };

                everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
            }
        });
        
        doSearch();
	}

	function doSearch() {

		var store = new EVF.Store();
		if (!store.validate()) { return; }

        store.setGrid([grid]);
		store.load(baseUrl + "bym1060_doSearch", function () {
			if(grid.getRowCount() === 0) {
				return alert('${msg.M0002}');
			}
		});
	}

	function doSavePop(vc_no) {
	    if(vc_no.type === "click") {
            vc_no = "";
        }

        var param = {
            callbackFunction: "doSavePop_callback",
            VC_NO: vc_no,
            detailView: false
        };

        everPopup.openPopupByScreenId("BYM1_061", 800, 700, param);
	}

	function doSavePop_callback() {
        doSearch();
    }

    function doSatisSave() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

        var rows = grid.getSelRowValue();
        for( var i = 0; i < rows.length; i++ ) {
            if(rows[i].PROGRESS_CD !== "400") {
                alert("${BYM1_060_001}");
                return;
            } else {
                if("" !== rows[i].ORG_RUB_TYPE) {
                    alert("${msg.M0165}");
                    return;
                }
            }
        }

        if(!grid.validate().flag) { return alert(grid.validate().msg); }

        if(!confirm("${msg.M0163}")) { return; }

        store.setGrid([grid]);
        store.getGridData(grid, "sel");
        store.load(baseUrl + "bym1060_doSatisSave", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }
 </script>
	<e:window id="BYM1_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE}" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE}" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="ORDR_ITEM_NM" title="${form_ORDR_ITEM_NM_N}" />
				<e:field>
					<e:inputText id="ORDR_ITEM_NM" name="ORDR_ITEM_NM" value="" width="${form_ORDR_ITEM_NM_W}" maxLength="${form_ORDR_ITEM_NM_M}" disabled="${form_ORDR_ITEM_NM_D}" readOnly="${form_ORDR_ITEM_NM_RO}" required="${form_ORDR_ITEM_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}" />
				<e:field>
					<e:inputText id="REQ_USER_NM" name="REQ_USER_NM" value="" width="${form_REQ_USER_NM_W}" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
				</e:field>
				<e:label for="VOC_TYPE" title="${form_VOC_TYPE_N}"/>
				<e:field>
					<e:select id="VOC_TYPE" name="VOC_TYPE" value="" options="${vocTypeOptions}" width="${form_VOC_TYPE_W}" disabled="${form_VOC_TYPE_D}" readOnly="${form_VOC_TYPE_RO}" required="${form_VOC_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="DS_USER_NM" title="${form_DS_USER_NM_N}" />
				<e:field>
					<e:inputText id="DS_USER_NM" name="DS_USER_NM" value="" width="${form_DS_USER_NM_W}" maxLength="${form_DS_USER_NM_M}" disabled="${form_DS_USER_NM_D}" readOnly="${form_DS_USER_NM_RO}" required="${form_DS_USER_NM_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
			<e:button id="SavePop" name="SavePop" label="${SavePop_N}" onClick="doSavePop" disabled="${SavePop_D}" visible="${SavePop_V}" style="float: left;" />
			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<e:button id="SatisSave" name="SatisSave" label="${SatisSave_N}" onClick="doSatisSave" disabled="${SatisSave_D}" visible="${SatisSave_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>