<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var baseUrl = "/eversrm/eApproval/eApprovalModule/";
    var grid = {};
    var currentRow;
   	var addParam = [];

    function init() {

    	grid = EVF.C("grid");

        grid.excelExportEvent({
        	allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.setProperty('shrinkToFit', true);
        grid.setProperty('sortable', false);

		grid.addRowEvent(function() {
			var addParam = [{}];
			grid.addRow(addParam);
		});

		grid.delRowEvent(function() {
			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
			grid.delRow();
		});
		
		grid.cellClickEvent(function(rowId, colId, value) {
			onCellClick( colId, rowId );
		});

        if ("${param.VALUE}" == "C") {
            doSearch();
        }
    }

    function doSearch() {

        var store = new EVF.Store();        	
        store.setGrid([grid]);
        store.load(baseUrl + 'BAPM_020/selectPathDetail', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
            	EVF.C("MAIN_PATH_FLAG").setChecked(("${param.MAINPATHFLAG}" == "1" ? true : false));
            	grid.checkAll(true);
            }
        });
    }

    function doSave() {

		var store = new EVF.Store();
		if(!store.validate()) { return; }

		if (grid.getSelRowCount() == 0) { return alert("${BAPM_020_001}"); }

		if (!confirm("${msg.M0021}")) return;

        doSetData();

		store.setGrid([grid]);
	    store.getGridData(grid, 'sel');

        if ("${param.VALUE }" == "R") {
	    	store.load(baseUrl + 'BAPM_020/insertPath', function(){
            	alert(this.getResponseMessage());
            	opener.window["${param.onClose}"]();
            	doClose();
		    });
        } else if ("${param.VALUE }" == "C") {
	   	 	store.load(baseUrl + 'BAPM_020/updatePath', function(){
            	alert(this.getResponseMessage());
            	opener.window["${param.onClose}"]();
            	doClose();
		    });
        }
    }

    function doDelLine() {

    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        
		grid.delRow();

		var pathSeq = 1;
		var rowIds  = grid.getAllRowId();
    	for (var i in rowIds) {
        	grid.setCellValue(i, "PATH_SQ", pathSeq++);
    	}
    	grid.checkAll(false);
    }

    function doMoveUp() {

    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

    	if (grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

        var selectedRowId = grid.jsonToArray(grid.getSelRowId()).value[0]
                ,selectedRowData = grid.getRowValue(selectedRowId);

//        var signReqType = selectedRowData['SIGN_REQ_TYPE'];
//        if(signReqType === '4' || signReqType === '7') {
//            return alert('병렬의 건은 이동시키실 수 없습니다.');
//        }

        var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
        /*grid.setProperty("setCheckFlag", false);
        for(var i=0; i < allRowIds.length; i++) {
            grid.setCellValue(allRowIds[i], 'CHECK_FLAG', ' ');
        }
        grid.setProperty("setCheckFlag", true);*/

        grid.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('sortType', 'up');
        store.getGridData(grid, 'all');
        store.load(baseUrl+'/getRealignmentApprovalList', function() {
            grid.checkAll(false);
            recountSignSequence();
        }, false);
    }

    function doMoveDown() {

    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

    	if (grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

        var selectedRowId = grid.jsonToArray(grid.getSelRowId()).value[0]
                ,selectedRowData = grid.getRowValue(selectedRowId);

//        var signReqType = selectedRowData['SIGN_REQ_TYPE'];
//        if(signReqType === '4' || signReqType === '7') {
//            return alert('병렬의 건은 이동시키실 수 없습니다.');
//        }

        var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
        /*grid.setProperty("setCheckFlag", false);
        for(var i=0; i < allRowIds.length; i++) {
            grid.setCellValue(allRowIds[i], 'CHECK_FLAG', ' ');
        }
        grid.setProperty("setCheckFlag", true);*/

        grid.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('sortType', 'down');
        store.getGridData(grid, 'all');
        store.load(baseUrl+'/getRealignmentApprovalList', function() {
            grid.checkAll(false);
            recountSignSequence();
        }, false);
    }

    <%-- 결재 순번 계산 --%>
    function recountSignSequence() {

        var rowIds = grid.jsonToArray(grid.getAllRowId()).value;
        var selectedRowIdx = [];
        for(var i = 0; i < rowIds.length; i++) {

            var rowData = grid.getRowValue(rowIds[i]);
            var checkFlag = rowData['CHECK_FLAG'];
            if(checkFlag == '1') {
                selectedRowIdx.push(rowIds[i]);
            }

            grid.setCellValue(rowIds[i], "CHECK_FLAG", "");
            grid.setCellValue(rowIds[i], 'PATH_SQ', i+1);
        }

        var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
        //grid.setProperty("setCheckFlag", false);
        for(var i=0; i < allRowIds.length; i++) {
            grid.setCellValue(allRowIds[i], 'CHECK_FLAG', '');
        }

        grid.checkAll(false);

        //grid.setProperty("setCheckFlag", true);

        for(var i=0; i < selectedRowIdx.length; i++) {
            grid.checkRow(selectedRowIdx[i], true);
        }
    }

    function doSetData() {

		var rowIds = grid.getAllRowId();
    	for (var i in rowIds) {
            grid.setCellValue(i, "GATE_CD", "${ses.gateCd}");
            grid.setCellValue(i, "PATH_NUM", EVF.C('PATH_NUM').getValue());
    	}
        EVF.C('GATE_CD').setValue("${ses.gateCd}");
    }

    function doAddLine() {
    
        var maxPath = 0;
        for (var i = 0, rowCount = grid.getRowCount(); i < rowCount; i++) {
            if (grid.getCellValue(i, "INSERT_FLAG") != "D") {
                maxPath = maxPath + 1;
            }
        }
		addParam = [{"PATH_SQ": ++maxPath, "SIGN_USER_ID": "0"}];
      	grid.addRow(addParam);
    }

    function doClose() {
        window.close();
    }

    function onCellClick(strColumnKey, nRow) {
        currentRow = nRow;
        if (strColumnKey == 'SIGN_USER_ID') {
            everPopup.userSearchPopup('selectUser', nRow, '', 'buyer', '');
        }
    }

    function selectUser(dataJsonArray) {
       	grid.setCellValue(currentRow, "SIGN_USER_ID", dataJsonArray.USER_ID);
       	grid.setCellValue(currentRow, "USER_NM",      dataJsonArray.USER_NM);
       	grid.setCellValue(currentRow, "DEPT_NM",      dataJsonArray.DEPT_NM);
       	grid.setCellValue(currentRow, "POSITION_NM",  dataJsonArray.POSITION_NM);
       	grid.setCellValue(currentRow, "DUTY_NM",      dataJsonArray.DUTY_NM);
    }

    </script>

    <e:window id="BAPM_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 5px 0 5px">

		<e:inputHidden id="GATE_CD" name="GATE_CD" value="${param.VALUE == 'C' ? param.GATECD : '' }"/>

    	<e:buttonBar id="buttonBarM" align="right" width="100%">
            <e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" />
            <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="doClose" />
        </e:buttonBar>

		<e:searchPanel id="form" title="${form_caption_form_N}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:row>
                <e:label for="PATH_NUM" title="${form_PATH_NUM_N}"></e:label>                				
                <e:field>
					<e:inputText id="PATH_NUM" name="PATH_NUM" width="${inputTextWidth }" maxLength="${form_PATH_NUM_M }" value="${param.VALUE == 'C' ? param.PATHNUM : '' }" required="${form_PATH_NUM_R }" readOnly="${form_PATH_NUM_RO }" disabled="${form_PATH_NUM_D}" visible="${form_PATH_NUM_V}" />
               </e:field>
                <e:label for="MAIN_PATH_FLAG" title="${form_MAIN_PATH_FLAG_N}"></e:label>                				
                <e:field>
					<e:check id="MAIN_PATH_FLAG" name="MAIN_PATH_FLAG" label="${form_MAIN_PATH_FLAG_N }" readOnly="${form_MAIN_PATH_FLAG_RO }" disabled="${form_MAIN_PATH_FLAG_D }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SIGN_PATH_NM" title="${form_SIGN_PATH_NM_N}"></e:label>                				
                <e:field colSpan="3">
					<e:inputText id="SIGN_PATH_NM" name="SIGN_PATH_NM" width="100%" maxLength="${form_SIGN_PATH_NM_M }" value="${param.VALUE == 'C' ? param.SIGNPATHNM : '' }" required="${form_SIGN_PATH_NM_R }" readOnly="${form_SIGN_PATH_NM_RO }" disabled="${form_SIGN_PATH_NM_D}" visible="${form_SIGN_PATH_NM_V}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SIGN_RMK" title="${form_SIGN_RMK_N}"></e:label>                				
                <e:field colSpan="3">
					<e:textArea id="SIGN_RMK" name="SIGN_RMK" disabled="${form_SIGN_RMK_D}" maxLength="${form_SIGN_RMK_M }" required="${form_SIGN_RMK_R }" value="${param.VALUE == 'C' ? param.SIGNRMK : '' }" readOnly="${form_SIGN_RMK_R }" height="100"/>
                </e:field>
            </e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBarS" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
            <e:button id="doMoveUp" name="doMoveUp" label="${doMoveUp_N }" disabled="${doMoveUp_D }" onClick="doMoveUp" />
            <e:button id="doMoveDown" name="doMoveDown" label="${doMoveDown_N }" disabled="${doMoveDown_D }" onClick="doMoveDown" />
        </e:buttonBar>
            
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>

