<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
 <script type="text/javascript">

	var gridH, gridD;
	var baseUrl = "/evermp/BS01/BS0102/";
	var G_MG_CD;

	function init(){
        gridH = EVF.C("gridH");
        gridD = EVF.C("gridD");

        gridH.setProperty('shrinkToFit', true);
        gridD.setProperty('shrinkToFit', true);

        gridH.cellClickEvent(function(rowId, colName, value) {
            if(colName === "CUST_CNT") {

                var MG_CD = gridH.getCellValue(rowId, "MG_CD");
                var MG_NM = gridH.getCellValue(rowId, "MG_NM");

                G_MG_CD = MG_CD;
                EVF.C("MG_NM_R").setValue(MG_NM);

                doSearchD(MG_CD);
            }
        });

        gridD.cellClickEvent(function(rowId, colName, value) {
        	if (colName == "CUST_CD") {
                var param = {
                    'CUST_CD': gridD.getCellValue(rowId, 'CUST_CD'),
                    'detailView': false,
                    'popupFlag': true
                };
                everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
            }

        });

        gridH.addRowEvent(function() {
            gridH.addRow();
        });

        gridH.delRowEvent(function() {

            if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var delCnt = 0;
            var rowIds = gridH.getSelRowId();
            for(var i = rowIds.length -1; i >= 0; i--) {
                if(!EVF.isEmpty(gridH.getCellValue(rowIds[i], "MG_CD"))) {
                    delCnt++;
                } else {
                    gridH.delRow(rowIds[i]);
                }
            }
            if(delCnt > 0) {
                doDelete();
            }
        });
        doSearch();
    }

	function doSearch() {


		var store = new EVF.Store();
		if (!store.validate()) { return; }

        store.setGrid([gridH]);
		store.load(baseUrl + "bs01020_doSearch", function () {
			if(gridH.getRowCount() === 0) {
				return alert('${msg.M0002}');
			}

            if("${param.autoSearchFlag}" == "Y") {
                EVF.V('MG_NM_R', "${param.MG_NM_R}");
                doSearchD("${param.MG_NM}");
            }


		});
	}

	// 관리그룹 상세조회
    function doSearchD(MG_CD) {
        var store = new EVF.Store();
        if (!store.validate()) { return; }

        store.setGrid([gridD]);
        store.setParameter("MG_CD", MG_CD);
        store.load(baseUrl + "bs01020_doSearchD", function () {
            if(gridD.getRowCount() === 0) {
                <%--return alert('${msg.M0002}');--%>
            }
        });
    }

    // 관리그룹 저장
    function doSave() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

        var validate = gridH.validate(["MG_NM"]);
        if (!validate.flag) {
            alert("${msg.M0014}");
            return;
        }

        if(!confirm("${msg.M0021}")) { return; }

        store.setGrid([gridH]);
        store.getGridData(gridH, "sel");
		store.load(baseUrl + "bs01020_doSave", function() {
			alert(this.getResponseMessage());
            doSearch();
		});
    }

    // 관리그룹 삭제
    function doDelete() {

        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

        var rowIds = gridH.getSelRowId();
        for( var i in rowIds ) {
            var custCnt = gridH.getCellValue(rowIds[i], "CUST_CNT");
            if( custCnt > 0 ) {
                return alert("${BS01_020_001}");
            }
        }

        if(!confirm("${msg.M0013}")) { return; }

        store.setGrid([gridH]);
        store.getGridData(gridH, "sel");
        store.load(baseUrl + "bs01020_doDelete", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    // 고객사 추가
    function doCustAdd() {

    	var MG_NM_R = EVF.C('MG_NM_R').getValue();

		if (MG_NM_R == "") {
			alert("${BS01_020_002 }");
			return;
		}

        var param = {
                callBackFunction : "setCustMulti"
            };
            everPopup.openCommonPopup(param, 'MP0018');
    }
    function setCustMulti(data) {
        if(data.length != undefined) {
            var dataArr = [];
            for(idx in data) {
                var arr = {
                	'MG_CD': G_MG_CD,
                    'CUST_CD': data[idx].CUST_CD,
                    'CUST_NM': data[idx].CUST_NM,
                    'IRS_NUM': data[idx].IRS_NUM,
                    'CEO_NM': data[idx].CEO_USER_NM
                };
                dataArr.push(arr);
            }
            var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridD, "CUST_CD");
            gridD.addRow(validData);
        }
    }

    // 고객사 매핑저장
    function doSaveDT() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${BS01_020_003}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "bs01020_doSaveCust", function() {
            alert(this.getResponseMessage());
            doSearch();
            doSearchD(G_MG_CD);
        });
    }

    // 고객사 매핑삭제
    function doDeleteDT() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${msg.M0013}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "bs01020_doDeleteCust", function() {
            alert(this.getResponseMessage());
            doSearch();
            doSearchD(G_MG_CD);
        });
    }
 </script>
	<e:window id="BS01_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:panel id="panL" width="30%" height="100%">
			<e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false" onEnter="doSearch">
				<e:row>
					<e:label for="MG_NM_L" title="${formL_MG_NM_N}" />
					<e:field>
						<e:inputText id="MG_NM_L" name="MG_NM_L" value="" width="${formL_MG_NM_W}" maxLength="${formL_MG_NM_M}" disabled="${formL_MG_NM_D}" readOnly="${formL_MG_NM_RO}" required="${formL_MG_NM_R}" />
					</e:field>
				</e:row>
			</e:searchPanel>

			<e:buttonBar align="right" width="100%">
				<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
				<e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
				<e:button id="Delete" name="Delete" label="${Delete_N}" onClick="doDelete" disabled="${Delete_D}" visible="${Delete_V}"/>
			</e:buttonBar>

			<e:gridPanel id="gridH" name="gridH" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridH.gridColData}" />
		</e:panel>

		<e:panel id="panBlank" width="1%">&nbsp;</e:panel>

		<e:panel id="panR" width="69%" height="100%">
			<e:searchPanel id="formR" title="" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false" onEnter="doSearch">
				<e:row>
					<e:label for="MG_NM_R" title="${formR_MG_NM_N}" />
					<e:field>
						<e:inputText id="MG_NM_R" name="MG_NM_R" value="" width="${formR_MG_NM_W}" maxLength="${formR_MG_NM_M}" disabled="${formR_MG_NM_D}" readOnly="${formR_MG_NM_RO}" required="${formR_MG_NM_R}" />
					</e:field>
				</e:row>
			</e:searchPanel>

		<e:panel id="leftP2" height="fit" width="40%">
			<e:button id="CustAdd" name="CustAdd" label="${CustAdd_N}" onClick="doCustAdd" disabled="${CustAdd_D}" visible="${CustAdd_V}"/>
        </e:panel>

		<e:panel id="rightP1" height="fit" width="60%">
	        <e:buttonBar align="right" width="100%">
	            <e:button id="SaveDT" name="SaveDT" label="${SaveDT_N}" onClick="doSaveDT" disabled="${SaveDT_D}" visible="${SaveDT_V}"/>
				<e:button id="DeleteDT" name="DeleteDT" label="${DeleteDT_N}" onClick="doDeleteDT" disabled="${DeleteDT_D}" visible="${DeleteDT_V}"/>
	        </e:buttonBar>
	    </e:panel>

			<e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />
		</e:panel>
	</e:window>
</e:ui>