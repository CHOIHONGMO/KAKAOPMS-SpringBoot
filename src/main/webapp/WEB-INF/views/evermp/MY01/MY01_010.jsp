<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">

	var gridH, gridD;
	var baseUrl = "/evermp/MY01/";
	var G_TPL_NO;

	function init(){
        gridH = EVF.C("gridH");
        gridD = EVF.C("gridD");

        gridH.setProperty('shrinkToFit', true);
        gridD.setProperty('shrinkToFit', true);

        gridH.cellClickEvent(function(rowId, colName, value) {

            if(colName === "TPL_NM") {
            	if( value === 0 || value === "" ) return;
                gridH.checkRow(rowId, true);
                var TPL_NO = gridH.getCellValue(rowId, "TPL_NO");
                var TPL_NM = gridH.getCellValue(rowId, "TPL_NM");
                G_TPL_NO = TPL_NO;
                EVF.C("TPL_NM_R").setValue(TPL_NM);
                doSearchD(TPL_NO);
            }
        });

        gridD.cellClickEvent(function(rowId, colName, value) {
            if(colName === "VENDOR_CD") {
                if(value === "") return;

                var param = {
                        'VENDOR_CD' : grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag' : true
                    };
                everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
            }
        });

        gridH.addRowEvent(function() {
            var addParam = [{"USER_ID": "${ses.userId}"}];
            gridH.addRow(addParam);
        });

        gridH.delRowEvent(function() {

            if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var delCnt = 0;
            var rowIds = gridH.getSelRowId();
            for(var i = rowIds.length -1; i >= 0; i--) {
                if(!EVF.isEmpty(gridH.getCellValue(rowIds[i], "TPL_NO"))) {
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
		store.load(baseUrl + "my01010_doSearch", function () {
			if(gridH.getRowCount() === 0) {
				return alert('${msg.M0002}');
			} else {
                var TPL_NO = gridH.getCellValue(0, "TPL_NO");
                var TPL_NM = gridH.getCellValue(0, "TPL_NM");

                G_TPL_NO = TPL_NO;

                EVF.C("TPL_NM_R").setValue(TPL_NM);
                doSearchD(TPL_NO);
			}
		});
	}

	// 업체 조회
    function doSearchD(TPL_NO) {

        var store = new EVF.Store();
        if (!store.validate()) { return; }

        store.setGrid([gridD]);
        store.setParameter("TPL_NO", TPL_NO);
        store.load(baseUrl + "my01010_doSearchD", function () {
            if(gridD.getRowCount() === 0) {
                <%--return alert('${msg.M0002}');--%>
            }
        });
    }

    // 관심업체그룹 저장
    function doSave() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

        var validate = gridH.validate(["TPL_NM"]);
        if (!validate.flag) {
            alert("${msg.M0014}");
            return;
        }

        if(!confirm("${msg.M0021}")) { return; }

        store.setGrid([gridH]);
        store.getGridData(gridH, "sel");
		store.load(baseUrl + "my01010_doSave", function() {
			alert(this.getResponseMessage());

            doSearch();
		});
    }

    // 관심업체 저장
    function doSaveCart() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

        var validate = gridD.validate(["TPL_NM"]);
        if (!validate.flag) {
            alert("${msg.M0014}");
            return;
        }
        if(!confirm("${msg.M0021}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.setParameter("TPL_NO", G_TPL_NO);
		store.load(baseUrl + "my01010_doSaveD", function() {
			alert(this.getResponseMessage());
			doSearch();
			doSearchD(G_TPL_NO);
		});
    }

    // 관심업체그룹 삭제
    function doDelete() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${msg.M0013}")) { return; }

        store.setGrid([gridH]);
        store.getGridData(gridH, "sel");
        store.load(baseUrl + "my01010_doDelete", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

 	// 관심업체 선택
    function doAddVendor() {
    	 if(!gridH.isExistsSelRow()) { return alert("${MY01_010_005}"); }

         var param = {
             callBackFunction: "selectVendor",
             clearButton : "OFF"
         };
         everPopup.openCommonPopup(param, 'MP0001');

    }

    function selectVendor(data) {
        var dataArr = [];
        for(idx in data) {
            var arr = {
                'VENDOR_CD'  : data[idx].VENDOR_CD,
                'VENDOR_NM'  : data[idx].VENDOR_NM,
                'MAKER_NM'   : data[idx].MAKER_NM,
                'IRS_NO'     : data[idx].IRS_NO,
                'BUSINESS_TYPE': data[idx].BUSINESS_TYPE,
                'GROUP_YN'   : data[idx].GROUP_YN,
                'CEO_USER_NM': data[idx].CEO_USER_NM,
                'CRIDIT_CD'  : data[idx].CEO_USER_NM,
                'TPL_NO'     : G_TPL_NO
            };
            dataArr.push(arr);
        }
        var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridD, "VENDOR_CD");
        gridD.addRow(validData);
    }

    // 관심업체 삭제
    function doDeleteCart() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${msg.M0013}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "my01010_doDeleteD", function() {
            alert(this.getResponseMessage());
            doSearchD(G_TPL_NO);
        });
    }

</script>

	<e:window id="MY01_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd}"/>
		<e:inputHidden id="USER_ID" name="USER_ID" value="${ses.userId}"/>

		<e:panel id="panL" width="30%" height="100%">
			<e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false" onEnter="doSearch">
				<e:row>
					<e:label for="TPL_NM_L" title="${formL_TPL_NM_N}" />
					<e:field>
						<e:inputText id="TPL_NM_L" name="TPL_NM_L" value="" width="${formL_TPL_NM_W}" maxLength="${formL_TPL_NM_M}" disabled="${formL_TPL_NM_D}" readOnly="${formL_TPL_NM_RO}" required="${formL_TPL_NM_R}" />
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
					<e:label for="TPL_NM_R" title="${formR_TPL_NM_N}" />
					<e:field>
						<e:inputText id="TPL_NM_R" name="TPL_NM_R" value="" width="${formR_TPL_NM_W}" maxLength="${formR_TPL_NM_M}" disabled="${formR_TPL_NM_D}" readOnly="${formR_TPL_NM_RO}" required="${formR_TPL_NM_R}" />
					</e:field>
				</e:row>
			</e:searchPanel>

			<e:buttonBar align="right" width="100%">
				<e:button id="AddCart" name="AddCart" label="${AddCart_N}" onClick="doAddVendor" disabled="${AddCart_D}" visible="${AddCart_V}"/>
				<e:button id="SaveCart" name="SaveCart" label="${SaveCart_N}" onClick="doSaveCart" disabled="${SaveCart_D}" visible="${SaveCart_V}"/>
				<e:button id="DeleteCart" name="DeleteCart" label="${DeleteCart_N}" onClick="doDeleteCart" disabled="${DeleteCart_D}" visible="${DeleteCart_V}"/>
			</e:buttonBar>

			<e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />
		</e:panel>
	</e:window>
</e:ui>