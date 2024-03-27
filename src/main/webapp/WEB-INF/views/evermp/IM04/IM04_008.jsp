<!--
* IM04_007 : 분류별 속성 선택
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
<link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
<script type="text/javascript" src="/js/dtree/dtree.js"></script>
<script>

	var grid;
	var gridTree;
    var baseUrl = "/evermp/IM04/IM0407/";
    var selRowId;

    function init() {
    	// Left Grid
    	gridTree = EVF.C("gridTree");

        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.setHeader({visible: true});
        treeViewObj.setCheckBar({visible: false});
        treeViewObj.setIndicator({visible: false});

        gridTree.setProperty('shrinkToFit', true);
        gridTree.setColCursor('ITEM_CLS_NM', 'pointer');

        gridTree.cellClickEvent(function(rowId, colId, value) {
            var data = gridTree.getRowValue(rowId);
            if( data['UPYN'] != "" ) {
                return alert("${IM04_008_001 }");
            }
            selRowId = rowId;

            doSearchAttr();
        });

        // Right Grid
    	grid = EVF.C("grid");
		grid.setProperty('multiSelect', true);
		grid.setProperty('shrinkToFit', true);

		grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

	    grid.addRowEvent(function() {
	        doAdd();
	    	//grid.addRow();
	    });
	    grid.delRowEvent(function() {
	        if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	    	grid.delRow();
	    });

		doSearch();
    }

    // 품목 분류 Tree 조회
    function doSearch() {
        var store = new EVF.Store();
        store.load(baseUrl + 'doSearchTree', function() {
            var treeData = this.getParameter("treeData");
            var jsonTree = JSON.parse(treeData);

            gridTree.getDataProvider().setRows(jsonTree, 'tree', true, '', 'icon');
            var treeViewObj = gridTree.getGridViewObj();
            treeViewObj.expandAll();
        });
    }

    // 품목 분류별 속성 조회
    function doSearchAttr() {
      	var store = new EVF.Store();

    	EVF.C("ITEM_CLS1").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS1'));
    	EVF.C("ITEM_CLS2").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS2'));
    	EVF.C("ITEM_CLS3").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS3'));
    	EVF.C("ITEM_CLS4").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS4'));
    	EVF.C("ITEM_CLS").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS'));
    	EVF.C("ITEM_PATH_NM").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS_PATH_NM'));

      	if(!store.validate()) return;

      	store.setGrid([grid]);
      	store.load(baseUrl + 'doSearch', function() {
      	});
    }

    // 속성 팝업
    function doAdd() {
    	var store = new EVF.Store();
    	if(!store.validate()) return;

    	var param = {
    			callBackFunction : "setAttribution",
    			detailView : false
			};
    	everPopup.openPopupByScreenId('IM04_008P', '600', '400', param);
    }

    function setAttribution(paramData) {
    	var data = valid.equalPopupValid(paramData, grid, "CODE_NM");
        var arrData = [];
        for (var k = 0; k < data.length; k++) {
            var datum = data[k];

            arrData.push({
            	 "INSERT_FLAG" : "I"
            	,"ATTR_TYPE" : "ITEM"
                ,'CODE'    : datum.CODE
                ,'CODE_NM' : datum.CODE_NM
            });
        }
        grid.addRow(arrData);
    }

    function doSave() {
    	if(!grid.isExistsSelRow()) {
    		return alert("${msg.M0004}");
    	}

    	if (!confirm("${msg.M0021}")) return;
      	var store = new EVF.Store();

    	if( !grid.validate().flag ) {
    		return alert(grid.validate().msg);
    	}

      	store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
      	store.load(baseUrl + 'doSave', function(){
      		alert(this.getResponseMessage());
      		doSearchAttr();
      	});
    }

    function doDelete() {
      	var store = new EVF.Store();

      	if(!grid.isExistsSelRow()) {
      		return alert("${msg.M0004}");
      	}

  	  	if( !confirm("${msg.M0013}") ) {
  	  		return;
		}

      	store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
      	store.load(baseUrl + 'doDelete', function(){
      		alert(this.getResponseMessage());
      		doSearchAttr();
      	});
    }

    function doClose() {
        if( ${param.ModalPopup == true} ){
            new EVF.ModalWindow().close(null);
        } else {
            window.close();
        }
    }

</script>

<e:window id="IM04_008" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:panel id="leftPanel" width="30%">
		<e:searchPanel id="form1" title="${msg.M9999}" labelWidth="${labelWidth}" columnCount="1" useTitleBar="false" onEnter="doSearch">
			<e:label for="ITEM_CLS_NM" title="${form1_ITEM_CLS_NM_N}" />
			<e:field>
				<e:inputText id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form1_ITEM_CLS_NM_W}" maxLength="${form1_ITEM_CLS_NM_M}" disabled="${form1_ITEM_CLS_NM_D}" readOnly="${form1_ITEM_CLS_NM_RO}" required="${form1_ITEM_CLS_NM_R}" />
			</e:field>
		</e:searchPanel>

		<e:buttonBar id="buttonBar1" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

    	<e:gridPanel id="gridTree" name="gridTree" width="100%" height="fit" gridType="RGT" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}"/>
    </e:panel>

    <e:panel width="1%">&nbsp;</e:panel>

    <e:panel id="rightPanel" width="68%">
	    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" columnCount="1" useTitleBar="false" onEnter="doSearch">
	    	<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="" />
	    	<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="" />
	    	<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="" />
	    	<e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="" />

			<e:row>
				<e:label for="ITEM_PATH_NM" title="${form_ITEM_PATH_NM_N}" />
				<e:field>
					<e:inputText id="ITEM_CLS" name="ITEM_CLS" value="" width="15%" maxLength="${form_ITEM_CLS_M}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" />
					<e:inputText id="ITEM_PATH_NM" name="ITEM_PATH_NM" value="" width="85%" maxLength="${form_ITEM_PATH_NM_M}" disabled="${form_ITEM_PATH_NM_D}" readOnly="${form_ITEM_PATH_NM_RO}" required="${form_ITEM_PATH_NM_R}" />
				</e:field>
			</e:row>
	    </e:searchPanel>

	    <e:buttonBar id="buttonBar" align="right" width="100%">
	        <e:button id="doAdd" name="doAdd" label="${doAdd_N}" onClick="doAdd" disabled="${doAdd_D}" visible="${doAdd_V}"/>
	        <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
	        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
	    </e:buttonBar>

	    <e:gridPanel id="grid" name="grid" width="100%" height="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:panel>
</e:window>

</e:ui>
