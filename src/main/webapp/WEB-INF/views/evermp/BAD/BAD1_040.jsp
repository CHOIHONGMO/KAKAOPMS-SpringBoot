<%-- 공급사 > Admin > 예산관리 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

<script type="text/javascript">
    var grid;
    var gridTree;
    var baseUrl = "/evermp/BAD/BAD1/";
    var eventRowId = 0;
    var selRowId = 0;

    function init() {

        gridTree = EVF.C("gridTree");

        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.setHeader({visible: true});
        treeViewObj.setCheckBar({visible: false});
        treeViewObj.setIndicator({visible: false});

        gridTree.setProperty('shrinkToFit', true);
        gridTree.setColCursor('DEPT_NM', 'pointer');

        gridTree.cellClickEvent(function(rowId, colId, value) {
            var data = gridTree.getRowValue(rowId);
            if( data['LVL'] == "2" ) {
                return alert("${BAD1_040_002 }");
            }
            selRowId = rowId;
            doSearchRightPanel();
        });

        grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value) {
            eventRowId = rowId;
            /* if(colId == "DEPT_NM") {
                if((grid.getCellValue(rowId, 'CUST_CD')!="")&&grid.getCellValue(rowId, 'DIVISION_CD')!="") {
                    var param = {
                        callBackFunction: "setgridDeptCd",
                        CUST_CD: grid.getCellValue(rowId, 'CUST_CD'),
                        PARENT_DEPT_CD: grid.getCellValue(rowId, 'DIVISION_CD')
                    };
                    everPopup.openCommonPopup(param, 'SP0084');
                }
            } */
            if (colId == "ACCOUNT_CD") {
                if((grid.getCellValue(rowId, 'CUST_CD')!="")) {
                    var param = {
                        callBackFunction: "setgridAccountCd",
                        custCd: grid.getCellValue(rowId, 'CUST_CD'),
                    };
                    everPopup.openCommonPopup(param, 'SP0085');
                }
            }
        });

        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        grid.addRowEvent(function() {
        	if( EVF.V("IN_CUST_CD") == "" ) {
                return alert("${BAD1_040_001}");
            }

        	if( EVF.V("IN_PARENTS_YN") != "" ) {
                return alert("${BAD1_040_002}");
            }

            var addParam = [{
            		 'CUST_CD' : EVF.V("IN_CUST_CD")
				    ,'CUST_NM' : EVF.V("IN_CUST_NM")
                	,'YEAR_MONTH' : EVF.V("YEAR_MONTH")
                	,'PLANT_CD' : gridTree.getCellValue(selRowId, 'ITEM_CLS1')
                	,'PLANT_NM' : gridTree.getCellValue(selRowId, 'PLANT_NM')
                	,'DIVISION_CD' : gridTree.getCellValue(selRowId, 'ITEM_CLS2')
                	,'DIVISION_NM' : gridTree.getCellValue(selRowId, 'DIVISION_NM')
                	,'DEPT_CD' : gridTree.getCellValue(selRowId, 'DEPT_CD')
                	,'DEPT_NM' : gridTree.getCellValue(selRowId, 'DEPT_NM')
                	,'ACCOUNT_CD' : EVF.V("ACCOUNT_CD")
                	,'ACCOUNT_NM' : EVF.V("ACCOUNT_NM")
                	,'BLOCK_FLAG' : '0'
                }];

            grid.addRow(addParam);
        });


/*         if( gridTree.getCellValue(selRowId, 'LVL') == '0' ){ // 최상위
            EVF.C("IN_CUST_CD").setValue(gridTree.getCellValue(selRowId, 'CUST_CD'));
    	} else if(  gridTree.getCellValue(selRowId, 'LVL') == '1'  ){
            EVF.C("IN_CUST_CD").setValue(gridTree.getCellValue(selRowId, 'CUST_CD'));
            EVF.C("IN_PLANT_CD").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS1'));
    	} else if(  gridTree.getCellValue(selRowId, 'LVL') == '2'  ){
            EVF.C("IN_CUST_CD").setValue(gridTree.getCellValue(selRowId, 'CUST_CD'));
            EVF.C("IN_PLANT_CD").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS1'));
            EVF.C("IN_DIVISION_CD").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS2'));
    	}
    	else{

    	}

 */        grid.delRowEvent(function() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            grid.delRow();
        });

     	// 예산 마감여부 체크
        isBudgetCloseFlag();
        doSearch();
    }

 	// 예산 마감여부 체크
    function isBudgetCloseFlag() {
    	var store = new EVF.Store();
    	store.load(baseUrl + 'isBudgetCloseFlag', function() {
        	var isBudgetCloseFlag = this.getParameter("isBudgetCloseFlag");
            EVF.C("isBudgetCloseFlag").setValue(isBudgetCloseFlag);
            doClear();
        });
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) { return;}

        store.load(baseUrl + 'bad1040_doSearchDept', function() {
        	var treeData = this.getParameter("treeData");
            var jsonTree = JSON.parse(treeData);
            gridTree.getDataProvider().setRows(jsonTree, 'tree', '', '', 'icon');
            var treeViewObj = gridTree.getGridViewObj();
            treeViewObj.expandAll();
        });

        var accountCd = EVF.C("ACCOUNT_CD").getValue();
        if( accountCd != "" ) {
        	doSearchRightPanel('X');
        }
    }

    function doSearchRightPanel(rowId) {
        var store = new EVF.Store();
        if( rowId != 'X' ) {
        	EVF.C("IN_CUST_CD").setValue("");
			EVF.C("IN_CUST_NM").setValue("");
        	EVF.C("IN_PLANT_CD").setValue("");
        	EVF.C("IN_DIVISION_CD").setValue("");
			EVF.C("IN_DIVISION_NM").setValue("");
            EVF.C("IN_DEPT_CD").setValue("");
			EVF.C("IN_DEPT_NM").setValue("");
            EVF.C("IN_PARENTS_YN").setValue("");
            EVF.C("DEPT_PATH_NM").setValue("");

			EVF.C("IN_CUST_CD").setValue(gridTree.getCellValue(selRowId, 'CUST_CD'));
			EVF.C("IN_CUST_NM").setValue(gridTree.getCellValue(selRowId, 'CUST_NM'));
			EVF.C("IN_PLANT_CD").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS1'));
			EVF.C("IN_DIVISION_CD").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS2'));
			EVF.C("IN_DIVISION_NM").setValue(gridTree.getCellValue(selRowId, 'DIVISION_NM'));
			EVF.C("IN_DEPT_CD").setValue(gridTree.getCellValue(selRowId, 'DEPT_CD'));
			EVF.C("IN_DEPT_NM").setValue(gridTree.getCellValue(selRowId, 'DEPT_NM'));
			EVF.C("IN_PARENTS_YN").setValue(gridTree.getCellValue(selRowId, 'PARENTS_YN'));
			EVF.C("DEPT_PATH_NM").setValue(gridTree.getCellValue(selRowId, 'ITEM_CLS_PATH_NM'));
        }
        if(!store.validate()) { return;}
        store.setGrid([grid]);
        store.load(baseUrl + 'bad1040_doSearch', function() {
            if(grid.getRowCount() == 0){
                //alert("${msg.M0002 }");
            }
        });
    }

    function doSave() {
    	// 예산 마감 체크
    	// 예산이 마감된 경우 등록/수정/삭제할 수 없음
    	var isBudgetCloseFlag = EVF.C("isBudgetCloseFlag").getValue();
    	if( isBudgetCloseFlag == "Y" ) {
    		return alert("${BS02_001_011}");
    	}

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        if(!grid.validate().flag) { return alert(grid.validate().msg); }

        var rowIds = grid.getSelRowId();
        for( var i in rowIds ) {
            if( Number(grid.getCellValue(rowIds[i], 'TRANSFERED_AMT')) > 0 && grid.getCellValue(rowIds[i], 'TRANSFERED_REASON') == "" ) {
				return alert("${BAD1_040_004}");
			}
            if( Number(grid.getCellValue(rowIds[i], 'BUDGET_AMT')) <= 0 ) {
				return alert("${BAD1_040_009}");
			}
            if( Number(grid.getCellValue(rowIds[i], 'TRANSFERED_AMT')) < 0 || Number(grid.getCellValue(rowIds[i], 'ADDITIONAL_AMT')) < 0 ) {
				return alert("${BAD1_040_010}");
			}
		    if( grid.getCellValue(rowIds[i], 'BLOCK_FLAG') == "1" && grid.getCellValue(rowIds[i], 'BLOCK_REMARK') == "" ) {
				return alert("${BAD1_040_006}");
			}
      		// 사용금액 > 0 경우 = 계정코드를 변경할 수 없음
            if( Number(grid.getCellValue(rowIds[i], 'EXHAUST_AMT')) > 0 ) {
            	if( grid.getCellValue(rowIds[i], 'ACCOUNT_CD') != grid.getCellValue(rowIds[i], 'ACCOUNT_CD_ORI') ) {
					return alert("${BS02_001_008}");
				}
			}
		}

        var dupCnt = 0;
        var allRowIds = grid.getAllRowId();
        for( var i in allRowIds ) {
           	for( var j in allRowIds ) {
               	if( i != j && grid.getCellValue(allRowIds[i], 'ACCOUNT_CD') == grid.getCellValue(allRowIds[j], 'ACCOUNT_CD') ) {
               		dupCnt++;
               	}
           	}
		}
        if( dupCnt > 1 ) {
        	return alert("${BAD1_040_007}");
        }

        if(!confirm('${msg.M0021}')) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + 'bad1040_doSave', function() {
            alert(this.getResponseMessage());
            doSearchRightPanel();
        });
    }

    function doDelete() {
    	// 예산 마감 체크
    	// 예산이 마감된 경우 등록/수정/삭제할 수 없음
    	var isBudgetCloseFlag = EVF.C("isBudgetCloseFlag").getValue();
    	if( isBudgetCloseFlag == "Y" ) {
    		return alert("${BS02_001_011}");
    	}

        var store = new EVF.Store();
        var rowIds = grid.getSelRowId();
        for( var i in rowIds ) {
            if(Number(grid.getCellValue(rowIds[i], 'EXHAUST_AMT')) > 0) {
				return alert("${BAD1_040_005}");
			}
		}

        if (!confirm("${msg.M0013 }")) return;

        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + 'bad1040_doDelete', function() {
            alert(this.getResponseMessage());
            doSearchRightPanel();
        });
    }

    function doClear() {
    	EVF.C("IN_CUST_CD").setValue("");
        EVF.C("IN_PLANT_CD").setValue("");
        EVF.C("IN_DIVISION_CD").setValue("");
        EVF.C("IN_DEPT_CD").setValue("");

        EVF.C("IN_PARENT_DEPT_CD").setValue("");
    	EVF.C("IN_PARENTS_YN").setValue("");
    	grid.delAllRow();
    }

    function searchAccount(){
        var param = {
       		custCd : EVF.V("CUST_CD"),
           	callBackFunction : "selectAccount"
       	};
        everPopup.openCommonPopup(param, 'SP0085');
    }

    function selectAccount(data){
        EVF.V("ACCOUNT_CD",data.ACCOUNT_CD);
        EVF.V("ACCOUNT_NM",data.ACCOUNT_NM);
    }

    function setgridDeptCd(dataJsonArray) {
        grid.setCellValue(eventRowId, 'DEPT_CD', dataJsonArray.DEPT_CD);
        grid.setCellValue(eventRowId, 'DEPT_NM', dataJsonArray.DEPT_NM);
    }

    function setgridAccountCd(dataJsonArray) {
        grid.setCellValue(eventRowId, 'ACCOUNT_CD', dataJsonArray.ACCOUNT_CD);
        grid.setCellValue(eventRowId, 'ACCOUNT_NM', dataJsonArray.ACCOUNT_NM);
    }
</script>

    <e:window id="BAD1_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd }" />
            <e:inputHidden id="CUST_NM" name="CUST_NM" value="${ses.companyNm }" />
            <e:row>
                <e:label for="YEAR_MONTH" title="${form_YEAR_MONTH_N}" />
                <e:field>
                    <e:inputDate id="YEAR_MONTH" name="YEAR_MONTH" value="${yyyymmTo }" width="${yearMonthYyyyMmWidth }" datePicker="true" required="${form_YEAR_MONTH_R}" disabled="${form_YEAR_MONTH_D}" readOnly="${form_YEAR_MONTH_RO}" format="yyyy-mm" onChange="isBudgetCloseFlag" />
                </e:field>
                <e:label for="isBudgetCloseFlag" title="${form_isBudgetCloseFlag_N}" />
				<e:field>
					<e:inputText id="isBudgetCloseFlag" name="isBudgetCloseFlag" value="" width="${form_isBudgetCloseFlag_W}" maxLength="${form_isBudgetCloseFlag_M}" disabled="${form_isBudgetCloseFlag_D}" readOnly="${form_isBudgetCloseFlag_RO}" required="${form_isBudgetCloseFlag_R}" />
				</e:field>
                <e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}"/>
                <e:field>
                    <e:search id="ACCOUNT_CD" style="ime-mode:inactive" name="ACCOUNT_CD" value="" width="35%" maxLength="${form_ACCOUNT_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchAccount'}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
                    <e:inputText id="ACCOUNT_NM" style="${imeMode}" name="ACCOUNT_NM" value="" width="65%" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
            <e:button id="OverNext" name="OverNext" label="${OverNext_N }" disabled="${OverNext_D }" visible="${OverNext_V}" onClick="doOverNext" />
        </e:buttonBar>

		<!-- 좌측 부서 트리 패널 -->
		<e:panel id="leftPanel" width="20%">
    		<e:gridPanel id="gridTree" name="gridTree" width="100%" height="fit" gridType="RGT" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}"/>
    	</e:panel>

    	<e:panel width="1%">&nbsp;</e:panel>

    	<!-- 우측 패널 -->
    	<e:panel id="rightPanel" width="78%">
	    	<e:searchPanel id="form1" title="${msg.M9999}" labelWidth="${labelWidth}" columnCount="1" useTitleBar="false" onEnter="doSearch">
		    	<e:inputHidden id="IN_CUST_CD" name="IN_CUST_CD" value="" />
				<e:inputHidden id="IN_CUST_NM" name="IN_CUST_NM" value="" />
		    	<e:inputHidden id="IN_PLANT_CD" name="IN_PLANT_CD" value="" />
		    	<e:inputHidden id="IN_DIVISION_CD" name="IN_DIVISION_CD" value="" />
				<e:inputHidden id="IN_DIVISION_NM" name="IN_DIVISION_NM" value="" />
		    	<e:inputHidden id="IN_DEPT_CD" name="IN_DEPT_CD" value="" />
				<e:inputHidden id="IN_DEPT_NM" name="IN_DEPT_NM" value="" />
		    	<e:inputHidden id="IN_PARENT_DEPT_CD" name="IN_PARENT_DEPT_CD" value="" />
		    	<e:inputHidden id="IN_PARENTS_YN" name="IN_PARENTS_YN" value="" />

				<e:row>
					<e:label for="DEPT_PATH_NM" title="${form_DEPT_PATH_NM_N}" />
					<e:field>
						<e:inputText id="DEPT_PATH_NM" name="DEPT_PATH_NM" value="" width="${form_DEPT_PATH_NM_W}" maxLength="${form_DEPT_PATH_NM_M}" disabled="${form_DEPT_PATH_NM_D}" readOnly="${form_DEPT_PATH_NM_RO}" required="${form_DEPT_PATH_NM_R}" />
					</e:field>
				</e:row>
		    </e:searchPanel>

	        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
		</e:panel>
    </e:window>
</e:ui>