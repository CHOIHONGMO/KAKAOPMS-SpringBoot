<!--
* BSYC_010 : 코드관리
* 시스템관리 > 기본정보 > 코드관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var gridHD = {};
    	var gridDT = {};
    	var addParamHD = [];
    	var addParamDT = [];
    	var baseUrl = "/eversrm/system/code/";
    	var flag = "";

		function init() {

			gridHD = EVF.C('gridHD');
			gridDT = EVF.C('gridDT');
			gridHD.setProperty('panelVisible', ${panelVisible});
			gridDT.setProperty('panelVisible', ${panelVisible});
			gridHD.addRowEvent(function() {
				addParamHD = [{}];
            	gridHD.addRow(null);
			});

			gridHD.delRowEvent(function() {
                if (gridHD.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
				gridHD.delRow();
			});

			gridHD.cellClickEvent(function(rowid, colId, value) {

				if(!EVF.isEmpty(gridHD.getCellValue(rowid, 'CODE_TYPE'))) {

					if (colId == 'CODE_TYPE') {
			            EVF.C('CODE_TYPE_DT').setValue(gridHD.getCellValue(rowid, 'CODE_TYPE'));
			            EVF.C('LANG_CD_DT').setValue(gridHD.getCellValue(rowid, 'LANG_CD'));
			            EVF.C('CODE_DT').setValue('');
			            EVF.C('CODE_DESC_DT').setValue('');
			            doSearchDT();
			        }
				}
			});

            gridHD.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			gridDT.addRowEvent(function() {
				addParamDT = [{"GATE_CD": "${ses.gateCd}", "LANG_CD": EVF.C('LANG_CD_DT').getValue() == "" ? "${ses.langCd}" : EVF.C('LANG_CD_DT').getValue(), "CODE_TYPE": EVF.C('CODE_TYPE_DT').getValue() == "" ? '' : EVF.C('CODE_TYPE_DT').getValue(), "USE_FLAG": "1"}];
            	gridDT.addRow(addParamDT);
 			});

			gridDT.delRowEvent(function() {
                if (gridDT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
				gridDT.delRow();
			});

            gridDT.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridDT.dupRowEvent(function(rowId) {

            }, ["LANG_CD",
                "CODE_TYPE",
                "CODE",
                "CODE_DESC",
                "SORT_SQ",
                "USE_FLAG",
                "TEXT1",
                "TEXT2",
                "TEXT3",
                "TEXT4",
                "FLAG",
                "DB_FLAG",
                "GATE_CD"]);

			EVF.C('LANG_CD').setValue("KO");
        }

        function doSearchHD() {

			var store = new EVF.Store();
        	store.setGrid([gridHD]);
            store.load(baseUrl + 'doSearchHD', function() {
                if(gridHD.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

		function doCopyHD() {


            if (gridHD.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	        var copyArgs = [];
	        var checkCnt = 0;

			var rowIds = gridHD.getSelRowId();

			for(var i = 0; i < rowIds.length; i++) {
                var tmp = [];
                tmp[0] = gridHD.getCellValue(rowIds[i], "GATE_CD");
                tmp[1] = gridHD.getCellValue(rowIds[i], "CODE_TYPE");
                tmp[2] = gridHD.getCellValue(rowIds[i], "CODE_TYPE_DESC");
                tmp[3] = gridHD.getCellValue(rowIds[i], "CODE_TYPE_RMK");
                tmp[4] = gridHD.getCellValue(rowIds[i], "DETAIL_DESC");
                copyArgs[checkCnt] = tmp;
                checkCnt++;
                gridHD.checkRow(i, false);
	        }

	        for (var i = 0; i < copyArgs.length; i++) {
	        	addParamHD = [{"USE_FLAG": "1", "LANG_CD": "${ses.langCd}", "GATE_CD": copyArgs[i][0], "CODE_TYPE": copyArgs[i][1], "CODE_TYPE_DESC": copyArgs[i][2], "CODE_TYPE_RMK": copyArgs[i][3], "DETAIL_DESC": copyArgs[i][4]}];
            	gridHD.addRow(addParamHD);
	        }
	    }

        function doSaveHD() {

            if(gridHD.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(!gridHD.validate().flag) { return alert(gridHD.validate().msg); }

            var rowIds = gridHD.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                for (var j = 0; j < i; j++) {
                    if (gridHD.getCellValue(rowIds[i], "CODE_TYPE") == gridHD.getCellValue(rowIds[j], "CODE_TYPE")) {
                        if (gridHD.getCellValue(rowIds[i], "LANG_CD") == gridHD.getCellValue(rowIds[j], "LANG_CD")) {
                            alert("${msg.M0033}");
                            gridHD.setCellValue(rowIds[i], 'LANG_CD', '');
                            return;
                        }
                    }
                }
            }

            if (!confirm("${msg.M0021 }")) return;

            var store = new EVF.Store();
            store.setGrid([gridHD]);
            store.getGridData(gridHD, 'sel');
            store.load(baseUrl + 'doSaveHD', function(){
                alert(this.getResponseMessage());
                doSearchHD();
            });
        }

        function doDeleteHD() {

			if (gridHD.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([gridHD]);
            store.getGridData(gridHD, 'sel');
            store.load(baseUrl + 'doDeleteHD', function(){
                alert(this.getResponseMessage());
                doSearchHD();
            });
        }

        function doSearchDT() {

        	if ((EVF.C('CODE_TYPE_DT').getValue() == "" || EVF.C('CODE_TYPE_DT').getValue() == null)
                && (EVF.C('CODE_DT').getValue() == "" || EVF.C('CODE_DT').getValue() == null)
                && (EVF.C('CODE_DESC_DT').getValue() == "" || EVF.C('CODE_DESC_DT').getValue() == null)) {
                return alert("${msg.M0035 }");
            }

            var store = new EVF.Store();
            store.setGrid([gridDT]);
            store.load(baseUrl + 'doSearchDT', function() {
                if(gridDT.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSaveDT() {

            if (gridDT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(!gridDT.validate().flag) { return alert(gridDT.validate().msg); }

            var rowIds = gridDT.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                for (var j = 0; j < i; j++) {
                    if (gridDT.getCellValue(rowIds[i], "CODE_TYPE") == gridDT.getCellValue(rowIds[j], "CODE_TYPE")) {
                        if (gridDT.getCellValue(rowIds[i], "CODE") == gridDT.getCellValue(rowIds[j], "CODE")) {
                            if (gridDT.getCellValue(rowIds[i], "LANG_CD") == gridDT.getCellValue(rowIds[j], "LANG_CD")) {
                                alert("${msg.M0033}");
                                gridDT.setCellValue(rowIds[i], 'LANG_CD', '');
                                return;
                            }
                        }
                    }
                }
                // 수량단위
                if (gridDT.getCellValue(rowIds[i], "CODE_TYPE") == 'M037' && gridDT.getCellValue(rowIds[i], "TEXT1") == '') {
                    alert("수량단위 등록시 DGNS와 연동할 연동 KEY(TEXT1)가 입력되지 않았습니다.");
                    return;
                }
            }

            if (!confirm("${msg.M0021 }")) return;

            var store = new EVF.Store();
            store.setGrid([gridDT]);
            store.getGridData(gridDT, 'sel');
            store.load(baseUrl + 'doSaveDT', function(){
                alert(this.getResponseMessage());
                doSearchDT();
            });
        }

        function doDeleteDT() {

            if (gridDT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            
            var rowIds = gridDT.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                // 수량단위
                if (gridDT.getCellValue(rowIds[i], "CODE_TYPE") == 'M037') {
                    alert("수량단위 공통코드(M037)는 삭제할 수 없습니다.");
                    return;
                }
            }
            
            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([gridDT]);
            store.getGridData(gridDT, 'sel');
            store.load(baseUrl + 'doDeleteDT', function(){
                alert(this.getResponseMessage());
                doSearchDT();
            });
        }

        function commonPopup() {
            var param = {
                callBackFunction: "setCodeType"
            };
            everPopup.openCommonPopup(param, 'SP0019');
        }

        function setCodeType(data) {
            EVF.C("CODE_TYPE_DT").setValue(data.CODE);
        }

    </script>
    <e:window id="BSYC_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="leftPanel" height="100%" width="39%">
            <e:searchPanel id="formHD" title="${formHD_CAPTION_N }" labelWidth="120" width="100%" columnCount="2" onEnter="doSearchHD" useTitleBar="false">
                <e:row>
                    <e:label for="LANG_CD" title="${formHD_LANG_CD_N }" />
                    <e:field>
                        <e:select id="LANG_CD" name="LANG_CD" value="" readOnly="${formHD_LANG_CD_RO }" options="${langCdOptions}" width="100%" required="${formHD_LANG_CD_R }" disabled="${formHD_LANG_CD_D }" />
                    </e:field>
                    <e:label for="CODE_TYPE" title="${formHD_CODE_TYPE_N }" />
                    <e:field>
                        <e:inputText id="CODE_TYPE" name="CODE_TYPE" label="${formHD_CODE_TYPE_N }" readOnly="${formHD_CODE_TYPE_RO }" disabled="${formHD_CODE_TYPE_N }" maxLength="${formHD_CODE_TYPE_M}" width="100%" required="${formHD_CODE_TYPE_R }" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="CODE_DESC" title="${formHD_CODE_DESC_N }" />
                    <e:field colSpan="3">
                        <e:inputText id="CODE_DESC" name="CODE_DESC" label="${formHD_CODE_DESC_N }" readOnly="${formHD_CODE_DESC_RO }" disabled="${formHD_CODE_DESC_N }" maxLength="${formHD_CODE_DESC_M}" width="100%" required="${formHD_CODE_DESC_R }" />
                    </e:field>
                </e:row>
            </e:searchPanel>
            <e:buttonBar id="buttonBarHDTop" align="right" width="100%">
                <e:button id="SearchHD" name="SearchHD" label="${SearchHD_N }" disabled="${SearchHD_D }" onClick="doSearchHD" />
	            <e:button id="SaveHD" name="SaveHD" label="${SaveHD_N }" disabled="${SaveHD_D }" onClick="doSaveHD" />
	            <e:button id="DeleteHD" name="DeleteHD" label="${DeleteHD_N }" disabled="${DeleteHD_D }" onClick="doDeleteHD" />
	        </e:buttonBar>
	        <e:gridPanel id="gridHD" name="gridHD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridHD.gridColData}" />
        </e:panel>
        <e:panel id="middlePanel" height="100%" width="1%">&nbsp;</e:panel>
	    <e:panel id="rightPanel" height="100%" width="60%">
	        <e:searchPanel id="formDT" title="${formDT_CAPTION_DT_N }" columnCount="2" labelWidth="120" onEnter="doSearchDT" useTitleBar="false">
	        	<e:row>
	            	<e:label for="CODE_TYPE_DT" title="${formDT_CODE_TYPE_DT_N }" />
	            	<e:field>
		                <e:inputText id="CODE_TYPE_DT" name="CODE_TYPE_DT" disabled="${formDT_CODE_TYPE_DT_D}"  readOnly="${formDT_CODE_TYPE_DT_RO}" maxLength="${formDT_CODE_TYPE_DT_M}" label="${formDT_CODE_TYPE_DT_N }" width="100%" required="${formDT_CODE_TYPE_DT_R }" />
	            	</e:field>
	            	<e:label for="CODE_DT" title="${formDT_CODE_DT_N }" />
	            	<e:field>
		                <e:inputText id="CODE_DT" name="CODE_DT" label="${formDT_CODE_DT_N }" width="100%" required="${formDT_CODE_DT_R }" readOnly="${formDT_CODE_DT_RO }" maxLength="${formDT_CODE_DT_M}" disabled="${formDT_CODE_DT_N }"/>
	            	</e:field>
	            </e:row>
	            <e:row>
					<e:label for="CODE_DESC_DT" title="${formDT_CODE_DESC_DT_N}"/>
					<e:field>
						<e:inputText id="CODE_DESC_DT" name="CODE_DESC_DT" value="${form.CODE_DESC_DT}" width="100%" maxLength="${formDT_CODE_DESC_DT_M}" disabled="${formDT_CODE_DESC_DT_D}" readOnly="${formDT_CODE_DESC_DT_RO}" required="${formDT_CODE_DESC_DT_R}" />
					</e:field>
	            	<e:label for="LANG_CD_DT" title="${formDT_LANG_CD_DT_N }" />
	            	<e:field>
	            		<e:select id="LANG_CD_DT" name="LANG_CD_DT" label="${formDT_LANG_CD_DT_N }" value="" options="${langCdDtOptions}" required="${formDT_LANG_CD_DT_R }" width="100%" disabled="${formDT_LANG_CD_DT_D }" readOnly="${formDT_LANG_CD_RO }"/>
	            	</e:field>
	            </e:row>
	        </e:searchPanel>
	        <e:buttonBar id="buttonBarDTTop" align="right" width="100%">
	            <e:button id="SearchDT" name="SearchDT" label="${SearchDT_N }" disabled="${SearchDT_D }" onClick="doSearchDT" />
	        	<e:button id="CopyDT" name="CopyDT" label="${CopyDT_N }" disabled="${CopyDT_D }" onClick="doCopyDT" />
	            <e:button id="SaveDT" name="SaveDT" label="${SaveDT_N }" disabled="${SaveDT_D }" onClick="doSaveDT" />
	            <e:button id="DeleteDT" name="DeleteDT" label="${DeleteDT_N }" disabled="${DeleteDT_D }" onClick="doDeleteDT" />
	        </e:buttonBar>
	        <e:gridPanel id="gridDT" name="gridDT" width="100%" height="fit" virtualScroll="true" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridDT.gridColData}" />
	    </e:panel>
    </e:window>
</e:ui>