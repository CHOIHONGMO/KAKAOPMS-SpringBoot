<!--
* BSYO_070 : 창고/저장위치
* 시스템관리 > 조직관리 > 창고/저장위치
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    	var baseUrl = "/eversrm/system/org/";
    	var gridL = {};
    	var gridB = {};
    	var addParam = [];
    	var saveBuyerCd;
	    var savePlantCd;
	    var saveWhCd;
	    var currentRow;

		function init() {

			gridL = EVF.C('gridL');
			gridB = EVF.C('gridB');
			gridL.setProperty('multiselect', false);
			gridL.setProperty('shrinkToFit', true);

			gridL.setProperty('panelVisible', ${panelVisible});
			gridL.cellClickEvent(function(rowid, colId, value) {
				if(colId == "WH_CD") {
					setFormData(rowid);
	            }
			});
			gridB.addRowEvent(function() {
				if ((EVF.C('WH_CD').getValue() == "") || (EVF.C('PLANT_CD').getValue() == "") || (EVF.C('BUYER_CD').getValue() == "")) {
		            alert("${BSYO_070_MSG_001 }");
		            return;
		        }
				addParam = [{"INSERT_FLAG": "I"}];
            	gridB.addRow(addParam);
			});
			gridB.delRowEvent(function() {
                if(!gridB.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridB.delRow();
			});
            gridL.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


			doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([gridL]);
            store.load(baseUrl + 'BSYO_070/selectWareHouse', function() {
                if(gridL.getRowCount() == 0){
                	alert("${msg.M0002 }");
                } else {
                	if (saveWhCd != null) {
                		var rowIds = gridL.getSelRowId();
                		for (var i = 0, length = gridL.getSelRowCount(); i < length; i++) {
	                        if ((gridL.getCellValue(rowIds[i], "BUYER_CD") == saveBuyerCd) && (gridL.getCellValue(rowIds[i], "PLANT_CD") == savePlantCd) && (gridL.getCellValue(rowIds[i], "WH_CD").text == saveWhCd)) {
	                            setFormData(rowIds[i]);
	                            return;
	                        }
	                    }
	                }
	                setFormData(0);
	            }
            });
        }

        function doSave() {

			//if (formUtil.validHandler(['form'], "${msg.M0054 }")) {
				if ((EVF.V('WH_CD') == "") || (EVF.V('PLANT_CD') == "") || (EVF.V('BUYER_CD') == "")) {
		            alert("${BSYO_070_MSG_001 }");
		            return;
		        }

		        if(!gridB.validate(['BIN_CD','BIN_NM','BIN_NM_ENG']).flag) {
		        	return alert("${msg.M0014}");
		        }

				if (!confirm("${msg.M0021 }")) return;

				saveWhCd = EVF.V('WH_CD');
		        savePlantCd = EVF.V('PLANT_CD');
		        saveBuyerCd = EVF.V('BUYER_CD');

		        var store = new EVF.Store();
		        if(!store.validate()) return;

		        store.setGrid([gridB]);
	        	store.getGridData(gridB, 'sel');
	        	store.load(baseUrl + 'BSYO_070/saveWareHouse', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	        //}
        }

		function doDelete() {

			//if (formUtil.validHandler(['WH_CODE'], "${msg.M0054 }")) {

				if (!confirm("${msg.M0013 }")) return;

		        //Please check this line of code later
            	EVF.C('INSERT_FLAG').setValue('D');

				saveWhCd = null;
				var store = new EVF.Store();
	        	store.load(baseUrl + 'BSYO_070/deleteWareHouse', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	        //}
	    }

		function doSearchDetail() {

	        var store = new EVF.Store();
	        store.setGrid([gridB]);
			store.load(baseUrl + 'BSYO_070/selectWareHouseDetail', function(){
				gridB.checkAll(true);
        	});
	    }

		function onChangeBuyerCd() {

			EVF.C("PLANT_CD").setOptions({});

			var store = new EVF.Store();
	    	store.load(baseUrl + 'getPlantComboValue', function() {
	    		EVF.C('PLANT_CD').setOptions(this.getParameter("plantList"));
	    		gridB.checkAll(true);
	        	gridB.delRow();
            });

			<%--
        	var param = {
                commonId: "CB0013",
                valueObject: "PLANT_CD",
                GATE_CD: "${ses.gateCd }",
                BUYER_CD: EVF.C('BUYER_CD').getValue()
            };

			var store = new EVF.Store();
			var refPlantCd = "";
			store.setParameter('comboInfo', param);
			store.setParameter('valueObject', 'PLANT_CD');

			store.load( "/common/combo/getMultiComboValue" , function() {
				EVF.C('PLANT_CD').setOptions( JSON.parse(this.getParameter('PLANT_CD')));

	        	gridB.checkAll(true);
	        	gridB.delRow();
 		    });
 		    --%>
	    }

		function onChangePlantCd() {
			EVF.C('PLANT_CD_ORI').setValue(EVF.C('PLANT_CD').getValue());

        	doSearchDetail();
	    }

	    function setPlantCd(nRow) {
	        EVF.C('PLANT_CD').setValue(grid.getCellValue(currentRow, "PLANT_CD"));
	    }

        function doReset() {
	        if (!confirm("${msg.M0029}")) return;

	        EVF.C('GATE_CD').setValue("");
	        EVF.C('BUYER_CD').setValue("");
	        EVF.C('BUYER_CD_ORI').setValue("");
	        EVF.C('PLANT_CD_ORI').setValue("");
	        EVF.C('WH_CD').setValue("");
	        EVF.C('WH_CD_ORI').setValue("");
	        EVF.C('WH_NM').setValue("");
	        EVF.C('WH_NM_ENG').setValue("");
	        EVF.C('ADDR').setValue("");
	        EVF.C('ADDR_ENG').setValue("");
	        EVF.C('REG_DATE').setValue("");
	        EVF.C('REG_USER_NM').setValue("");
	        EVF.C('PLANT_CD').setValue("");
	        EVF.C('PLANT_CD_ORI').setValue("");
	        EVF.C('INSERT_FLAG').setValue("");

	        gridB.checkAll(true);
	        gridB.delRow();
	    }

		function setFormData(rowiId) {

			currentRow = rowiId;

			EVF.C("PLANT_CD").setOptions({});
            EVF.C('GATE_CD').setValue(gridL.getCellValue(currentRow, "GATE_CD"));
            EVF.C('BUYER_CD').setValue(gridL.getCellValue(currentRow, "BUYER_CD")    ,false  );
            EVF.C('BUYER_CD_ORI').setValue(gridL.getCellValue(currentRow, "BUYER_CD")  ,false);
            EVF.C('PLANT_CD_ORI').setValue(gridL.getCellValue(currentRow, "PLANT_CD")  ,false);
            EVF.C('WH_CD').setValue(gridL.getCellValue(currentRow, "WH_CD"), false);
            EVF.C('WH_CD_ORI').setValue(gridL.getCellValue(currentRow, "WH_CD"));
            EVF.C('WH_NM').setValue(gridL.getCellValue(currentRow, "WH_NM"));
            EVF.C('WH_NM_ENG').setValue(gridL.getCellValue(currentRow, "WH_NM_ENG"));
            EVF.C('ADDR').setValue(gridL.getCellValue(currentRow, "ADDR"));
            EVF.C('ADDR_ENG').setValue(gridL.getCellValue(currentRow, "ADDR_ENG"));
            EVF.C('REG_DATE').setValue(gridL.getCellValue(currentRow, "REG_DATE_FORM"));
            EVF.C('REG_USER_NM').setValue(gridL.getCellValue(currentRow, "REG_USER_NM"));
            EVF.C('INSERT_FLAG').setValue("R");

	    	var store = new EVF.Store();
	    	store.load(baseUrl + 'getPlantComboValue', function() {
	    		EVF.C('PLANT_CD').setOptions(this.getParameter("plantList"));
	    		EVF.C('PLANT_CD').setValue(gridL.getCellValue(currentRow, "PLANT_CD"));
	    		doSearchDetail();
            });
		}

		/*
	    function onCellChange(strColumnKey, nRow, oVal, nVal) {

	        if (strColumnKey !== "SELECTED") {
	            gridB.setCellValue("SELECTED", nRow, "1");
	        } else {
	            if (gridB.getCellValue(nRow, "INSERT_FLAG") == "D") {
	                gridB.setCellValue("INSERT_FLAG", nRow, "U");
	                for (var j = 2; j < 6; j++) {
	                    if (gridB.getColType(gridB.getColHDKey(j)) == "t_text") {
	                        gridB.setCellFontCLine(gridB.getColHDKey(j), nRow, false);
	                    }
	                }
	            }
	        }
	    }
	    */

    </script>

    <e:window id="BSYO_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:panel id="leftPanel" width="40%">
            <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="98%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
        </e:panel>

        <e:panel id="rightPanel" width="60%">
		<e:searchPanel id="form" title="${form_caption_form_N}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
	        <e:row>
                <e:label for="BUYER_CD" title="${form_BUYER_CD_N}"></e:label>
                <e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" width="100%" options="${buyerCdOptions}" required="${form_BUYER_CD_R }" disabled="${form_BUYER_CD_D }" readOnly="${form_BUYER_CD_RO }" value="${st_default}" onChange="onChangeBuyerCd"></e:select>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"></e:label>
                <e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" options="" width="100%" required="${form_PLANT_CD_R }" disabled="${form_PLANT_CD_D }" readOnly="${form_PLANT_CD_RO }" value="${st_default}" onChange="onChangePlantCd"></e:select>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="WH_CD" title="${form_WH_CD_N}"></e:label>
                <e:field>
					<e:inputText id="WH_CD" name="WH_CD" width="100%" maxLength="${form_WH_CD_M }" required="${form_WH_CD_R }" readOnly="${form_WH_CD_RO }" disabled="${form_WH_CD_D}" visible="${form_WH_CD_V}" ></e:inputText>
                </e:field>
                <e:label for="WH_NM" title="${form_WH_NM_N}"></e:label>
                <e:field>
					<e:inputText id="WH_NM" name="WH_NM" width="100%" maxLength="${form_WH_NM_M }" required="${form_WH_NM_R }" readOnly="${form_WH_NM_RO }" disabled="${form_WH_NM_D}" visible="${form_WH_NM_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="WH_NM_ENG" title="${form_WH_NM_ENG_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="WH_NM_ENG" name="WH_NM_ENG" width="100%" maxLength="${form_WH_NM_ENG_M }" required="${form_WH_NM_ENG_R }" readOnly="${form_WH_NM_ENG_RO }" disabled="${form_WH_NM_ENG_D}" visible="${form_WH_NM_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="ADDR" title="${form_ADDR_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="ADDR" name="ADDR" width="100%" maxLength="${form_ADDR_M }" required="${form_ADDR_R }" readOnly="${form_ADDR_RO }" disabled="${form_ADDR_D}" visible="${form_ADDR_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="ADDR_ENG" title="${form_ADDR_ENG_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="ADDR_ENG" name="ADDR_ENG" width="100%" maxLength="${form_ADDR_ENG_M }" required="${form_ADDR_ENG_R }" readOnly="${form_ADDR_ENG_RO }" disabled="${form_ADDR_ENG_D}" visible="${form_ADDR_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"></e:label>
                <e:field>
					<e:inputText id="REG_DATE" name="REG_DATE" width="100%" maxLength="${form_REG_DATE_M }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D}" visible="${form_REG_DATE_V}" ></e:inputText>
                </e:field>
                <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"></e:label>
                <e:field>
					<e:inputText id="REG_USER_NM" name="REG_USER_NM" width="100%" maxLength="${form_REG_USER_NM_M }" required="${form_REG_USER_NM_R }" readOnly="${form_REG_USER_NM_RO }" disabled="${form_REG_USER_NM_D}" visible="${form_REG_USER_NM_V}" ></e:inputText>
                </e:field>
	        </e:row>
	    </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Reset" name="Reset" label="${Reset_N }" disabled="${Reset_D }" onClick="doReset" />
        </e:buttonBar>
		<e:inputHidden id="GATE_CD"        name="GATE_CD"/>
		<e:inputHidden id="BUYER_CD_ORI"   name="BUYER_CD_ORI"/>
		<e:inputHidden id="PLANT_CD_ORI"   name="PLANT_CD_ORI"/>
		<e:inputHidden id="WH_CD_ORI"      name="WH_CD_ORI"/>
		<e:inputHidden id="INSERT_FLAG"    name="INSERT_FLAG"/>

        <e:gridPanel gridType="${_gridType}" id="gridB" name="gridB" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridB.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>