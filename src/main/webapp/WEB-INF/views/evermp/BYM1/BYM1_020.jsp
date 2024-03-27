<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
 <script type="text/javascript">

	var gridH, gridD;
	var baseUrl = "/evermp/BYM1/BYM1_020/";
	var G_TPL_NO;

	function init(){
        gridH = EVF.C("gridH");
        gridD = EVF.C("gridD");

        gridH.setProperty('shrinkToFit', true);

        gridH.cellClickEvent(function(rowId, colName, value) {
            if(colName === "ITEM_CNT") {
                var TPL_NO = gridH.getCellValue(rowId, "TPL_NO");
                var TPL_NM = gridH.getCellValue(rowId, "TPL_NM");

                G_TPL_NO = TPL_NO;
                EVF.C("TPL_NM_R").setValue(TPL_NM);

                doSearchD(TPL_NO);
            }
        });

        gridD.cellClickEvent(function(rowId, colName, value) {
            if(colName === "ITEM_CD") {
                if(value !== ""){
                    var param = {
                        ITEM_CD: gridD.getCellValue(rowId, "ITEM_CD"),
                        CUST_CD : gridD.getCellValue(rowId, "CUST_CD"),
                        APPLY_COM : gridD.getCellValue(rowId, "APPLY_COM"),
                        CONT_NO : gridD.getCellValue(rowId, "CONT_NO"),
                        CONT_SEQ : gridD.getCellValue(rowId, "CONT_SEQ"),
                        CART_YN : true,
                        popupFlag: true,
                        detailView: false
                    };
                    everPopup.im03_014open(param);
                }
            }
        });

        gridH.addRowEvent(function() {
            var addParam = [{"CUST_CD": "${ses.companyCd}", "USER_ID": "${ses.userId}"}];
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
		store.load(baseUrl + "bym1020_doSearch", function () {
			if(gridH.getRowCount() === 0) {
				return alert('${msg.M0002}');
			}
            if("${param.autoSearchFlag}" == "Y") {
                EVF.V('TPL_NM_R', "${param.TPL_NM_R}");
                doSearchD("${param.TPL_NO}");
            }
		});
	}

	// 품목 조회
    function doSearchD(TPL_NO) {

        var store = new EVF.Store();
        if (!store.validate()) { return; }

        store.setGrid([gridD]);
        store.setParameter("TPL_NO", TPL_NO);
        store.load(baseUrl + "bym1020_doSearchD", function () {
            if(gridD.getRowCount() === 0) {
                <%--return alert('${msg.M0002}');--%>
            }
        });
    }

    // 관심품목그룹 저장
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
		store.load(baseUrl + "bym1020_doSave", function() {
			alert(this.getResponseMessage());
            doSearch();
		});
    }

    // 관심품목그룹 삭제
    function doDelete() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${msg.M0013}")) { return; }

        store.setGrid([gridH]);
        store.getGridData(gridH, "sel");
        store.load(baseUrl + "bym1020_doDelete", function() {
            alert(this.getResponseMessage());
            doSearchD();
        });
    }

    // 카트 담기
    function doAddCart() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${BYM1_020_001}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "bym1020_doAddCart", function() {
            alert(this.getResponseMessage());
            doSearchD(G_TPL_NO);
        });
    }

    // 주문카트 화면으로 이동
    function doMoveCart() {
        var param = {
            MOVE_LINK_YN: "Y"
		};
        // var el = parent.parent.document.getElementById('mainIframe');
        top.pageRedirectByScreenId("BOD1_030", param);
        // top.pageRedirectByScreenId("BOD1_030", param);
    }

    // 관심품목 삭제
    function doDeleteCart() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if(!confirm("${msg.M0013}")) { return; }

        store.setGrid([gridD]);
        store.getGridData(gridD, "sel");
        store.load(baseUrl + "bym1020_doDeleteCart", function() {
            alert(this.getResponseMessage());
            doSearchD(G_TPL_NO);
        });
    }

    function doMove() {
		doMoveCopy('M');
	}

	function doCopy() {
		doMoveCopy('C');
	}

	function doMoveCopy(actionFlag) {
		if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

		let itemInfo = "";
		const rowIds = gridD.getSelRowId();
		for( let i in rowIds ) {
			const itemCd = gridD.getCellValue(rowIds[i], 'ITEM_CD');
			const applyCom = gridD.getCellValue(rowIds[i], 'APPLY_COM');
			const contNum  = gridD.getCellValue(rowIds[i], 'CONT_NO');
			const contSeq  = gridD.getCellValue(rowIds[i], 'CONT_SEQ');
			const oldTplNo  = gridD.getCellValue(rowIds[i], 'TPL_NO');
			const oldTplSq  = gridD.getCellValue(rowIds[i], 'TPL_SQ');

			itemInfo = itemInfo
				+ itemCd + ":"
				+ applyCom + ":"
				+ contNum + ":"
				+ contSeq + ":"
				+ oldTplNo + ":"
				+ oldTplSq + ","
		}

		let param = {
			itemInfo : itemInfo,
			detailView : false,
			ACTION_FLAG : actionFlag
		};
		everPopup.openPopupByScreenId('BOD1_032', 600, 400, param);
	}
 </script>
	<e:window id="BYM1_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
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
				<e:button id="doMove" name="doMove" label="${doMove_N}" onClick="doMove" disabled="${doMove_D}" visible="${doMove_V}"/>
				<e:button id="doCopy" name="doCopy" label="${doCopy_N}" onClick="doCopy" disabled="${doCopy_D}" visible="${doCopy_V}"/>
				<e:button id="AddCart" name="AddCart" label="${AddCart_N}" onClick="doAddCart" disabled="${AddCart_D}" visible="${AddCart_V}"/>
				<e:button id="MoveCart" name="MoveCart" label="${MoveCart_N}" onClick="doMoveCart" disabled="${MoveCart_D}" visible="${MoveCart_V}"/>
				<e:button id="DeleteCart" name="DeleteCart" label="${DeleteCart_N}" onClick="doDeleteCart" disabled="${DeleteCart_D}" visible="${DeleteCart_V}"/>
			</e:buttonBar>

			<e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />
		</e:panel>
	</e:window>
</e:ui>