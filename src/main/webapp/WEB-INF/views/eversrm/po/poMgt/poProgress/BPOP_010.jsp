<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

        var grid = {};
        var baseUrl = "/eversrm/po/poMgt/poProgress/BPOP_010/";

        function init() {
            grid = EVF.getComponent("grid");

    		EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
    		grid.setProperty('panelVisible', ${panelVisible});
            grid.excelExportEvent({
                allCol : "${excelExport.allCol}",
                selRow : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }",
                excelOptions : {
                      imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
                    ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                    ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                    ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                    ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
                switch (celname) {
                case 'PO_NUM':
                    var param = {
                        poNum: grid.getCellValue(rowid, "PO_NUM"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BPOM_020", 1200, 800, param);
                    break;

                case 'VENDOR_CD':
                    var param = {
                        VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
                        detailView: true
                    };
                    everPopup.openSupManagementPopup(param);
                    break;

                default:
                    return;
                }
            });

        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if (!everDate.fromTodateValid('PO_FROM_DATE', 'PO_TO_DATE', '${ses.dateFormat }')) return alert('${msg.M0073}');

            store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }

            });
        }

        // 구매담당자 변경
        function doBuyerChange() {

            if (EVF.getComponent("NEW_CTRL_USER_ID").getValue() === '') {
            	return alert("${BPOP_010_002}");
            }

            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length == 0) {
            	return alert("${msg.M0004}");
            }
            if (gridDatas.length > 1) {
            	return alert("${msg.M0006}");
            }

            for(var idx in gridDatas) {
                var rowData = gridDatas[idx];
                if (rowData['CTRL_USER_ID'] != "${ses.userId }") return alert("${msg.M0008}");
            }

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if (!confirm(EVF.C('NEW_CTRL_USER_NM').getValue()+"님을 ${msg.M0082}")) return;

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'doBuyerChange', function(){
                alert(this.getResponseMessage());

                EVF.getComponent("NEW_CTRL_USER_NM").setValue('');
                EVF.getComponent("NEW_CTRL_USER_ID").setValue('');

                doSearch();
            });
        }

        // 발주확정자 변경
        function doChangePoAprv() {

            if (EVF.getComponent("NEW_PO_APRV_ID").getValue() === '') {
                return alert("${BPOP_010_003}");
            }

            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length == 0) {
            	return alert("${msg.M0004}");
            }
            if (gridDatas.length > 1) {
            	return alert("${msg.M0006}");
            }

            /* 구매담당자 혹은 발주확정자만 변경 가능 */
            for(var idx in gridDatas) {
                var rowData = gridDatas[idx];

                var progressCode = rowData['PROGRESS_CD'];
                if (progressCode == '300') /* 진행상태가 "협력회사전송"일 경우 확정자를 변경할 수 없음 */ {
                	return alert("${msg.M0044}");
                }

                var purchaseType = rowData['PURCHASE_TYPE'];
                <%--
                if(purchaseType == 'NORMAL') {
                    return alert('${BPOP_010_009}');
                }
                --%>

                /* 구매담당자 및 발주확정자만 확정자를 변경할 수 있음 */
                if (EVF.isNotEmpty(rowData['PO_APRV_ID']) && (rowData['PO_APRV_ID'] != "${ses.userId }" && rowData['CTRL_USER_ID'] != "${ses.userId }")) {
                    return alert("${msg.M0008}");
                }
            }

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if (!confirm(EVF.C('NEW_PO_APRV_NM').getValue()+"님을 ${msg.M0082}")) return;

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'doPoAprvIdChange', function(){
                alert(this.getResponseMessage());

                EVF.getComponent("NEW_PO_APRV_NM").setValue('');
                EVF.getComponent("NEW_PO_APRV_ID").setValue('');

                doSearch();
            });
        }

        function doChange() {

            var gridData = grid.getSelRowValue();
            if (gridData.length > 1) {
            	return alert("${msg.M0006}");
            }

            if(!grid.isExistsSelRow()) {
            	return alert("${msg.M0004}");
            }

            // 동일한 구매담당자만 발주변경 가능
            var selectedRow = grid.getSelRowValue()[0];
            if ('${ses.userId}' != selectedRow['CTRL_USER_ID']) {
            	return alert('${msg.M0008}');
            }

            // 진행상태가 "작성중(100), 협력회사전송(300), 확정반려(400)"인 경우에만 발주수정 가능
            var progressCode = selectedRow['PROGRESS_CD'];
            if (progressCode != '100' && progressCode != '300' && progressCode != '400') {
            	return alert("${msg.M0044}");
            }

            // 협력회사전송(300) 건에 대해 발주 변경시 발주차수가 1증가하고, 협력회사접수여부 및 접수일자가 초기화된다.
        	if (progressCode == '300') {
        		if (!confirm("${BPOP_010_011}")) {
        			return;
        		}
        	}

            var forceCloseYn = selectedRow['FORCE_CLOSE_DATE'];
            if (forceCloseYn != '') {
            	return alert("${BPOP_010_001}");
            }

            var poNum = selectedRow['PO_NUM'];
            everPopup.openPopupByScreenId("BPOM_020", 1200, 700, {
                poNum: poNum,
                popupFlag : true,
                progressCode : progressCode,
                detailView: false,
                callBackFunction : 'doSearch'
            });
        }

        function doChangePayment() {

            var gridData = grid.getSelRowValue();
            if (gridData.length > 1) {
            	return alert("${msg.M0006}");
            }

            if(!grid.isExistsSelRow()) {
            	return alert("${msg.M0004}");
            }

            // 동일한 구매담당자만 발주변경 가능
            var selectedRow = grid.getSelRowValue()[0];
            var poNum = selectedRow['PO_NUM'];

            if(selectedRow.CTRL_USER_ID != '${ses.userId}' && selectedRow.PO_APRV_ID != '${ses.userId}') {
                return alert('${msg.M0008}'); <%-- 처리할 권한이 없습니다. --%>
            }

            if(EVF.isEmpty(selectedRow.PAY_TYPE)) <%-- 지불방식에 값이 없으면 검수가 아니므로 리턴시킨다. --%> {
                return alert('${BPOP_010_013}');
            }

            everPopup.openPopupByScreenId("BPOM_040", 800, 400, {
                "PO_NUM": poNum,
                "PAY_TYPE": selectedRow.PAY_TYPE,
                "CUR": selectedRow.CUR,
                "PO_AMT": selectedRow.PO_AMT,
                "PURCHASE_TYPE": selectedRow.PURCHASE_TYPE,
                "screenCaller": 'BPOP_010',
                "detailView": false,
                "callBackFunction" : 'doSearch'
            });
        }

        // 발주종결 : 진행상태가 발주확정대상(200), 협력회사전송(300) 인 경우에만 가능함
        function readyToTerminate() {

            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length > 1) {
            	return alert("${msg.M0006}");
            }
            if(!grid.isExistsSelRow()) {
            	return alert("${msg.M0004}");
            }

            var selectedRow = grid.getSelRowValue()[0];
            if ('${ses.userId}' != selectedRow['CTRL_USER_ID']) {
            	return alert('${msg.M0008}');
            }

            var progressCode = selectedRow['PROGRESS_CD'];
            if (progressCode != '200' && progressCode != '300') {
            	return alert("${msg.M0044}");
            }

            var forceCloseYn = selectedRow['FORCE_CLOSE_DATE'];
            if (forceCloseYn != '') {
            	return alert("${BPOP_010_001}");
            }

            var store = new EVF.Store();
            if(!store.validate()) {  }

        }

        function doTerminate(remark) {

            if (!confirm("${BPOP_010_008}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("teminateType", "DOC");
            store.load(baseUrl + 'doTerminate', function(){
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doPrint() {
            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length == 0) return alert("${msg.M0004}");

            var poList = [];
            for(var idx in gridDatas) {
                var rowData = gridDatas[idx];

                poList.push(rowData['PO_NUM']);
            }

            var param1 = {
                poList: JSON.stringify(poList)
            };

            var url = "/eversrm/po/poMgt/poRegistration/printPO.so?#toolbar=1&navpanes=1";

            everPopup.openWindowPopup(url, 1000, 800, param1);
        }

        function doSearchBuyer() {
            everPopup.openCommonPopup({
                callBackFunction: "selectBuyer"
            }, 'SP0040');
        }
        function doSearchPoAprvId() {
            everPopup.openCommonPopup({
                callBackFunction: "selectPoAprvId"
            }, 'SP0040');
        }

        // 구매담당자 조회조건 변경
        function selectBuyer(data) {
            EVF.getComponent("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
            EVF.getComponent("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
        }

        // 발주확정자 조회조건 변경
        function selectPoAprvId(data) {
            EVF.getComponent("PO_APRV_ID").setValue(data.CTRL_USER_ID);
            EVF.getComponent("PO_APRV_NM").setValue(data.CTRL_USER_NM);
        }

        // 구매담당자 변경
        function getNewCtrlUserId() {
            var gridData = grid.getSelRowValue();
            if (gridData.length > 1) {
            	return alert("${msg.M0006}");
            }

            if(!grid.isExistsSelRow()) {
            	return alert("${msg.M0004}");
            }

            var selectedRow = grid.getSelRowValue()[0];
            var purOrgCd = selectedRow['PUR_ORG_CD'];

        	everPopup.openCommonPopup({
                callBackFunction : "setNewCtrlUserId",
                "PUR_ORG_CD" : purOrgCd
            }, 'SP0062');
        }

        function setNewCtrlUserId(data) {
            EVF.getComponent("NEW_CTRL_USER_ID").setValue(data.CTRL_USER_ID);
            EVF.getComponent("NEW_CTRL_USER_NM").setValue(data.CTRL_USER_NM);
        }

        // 발주확정자 변경
        function getNewPoAprvId() {
            var gridData = grid.getSelRowValue();
            if (gridData.length > 1) {
            	return alert("${msg.M0006}");
            }

            if(!grid.isExistsSelRow()) {
            	return alert("${msg.M0004}");
            }

            var selectedRow = grid.getSelRowValue()[0];
            var purOrgCd = selectedRow['PUR_ORG_CD'];

            everPopup.openCommonPopup({
                callBackFunction: "setNewPoAprvId",
                "PUR_ORG_CD" : purOrgCd
            }, 'SP0062');
        }

        function setNewPoAprvId(data) {
            EVF.getComponent("NEW_PO_APRV_ID").setValue(data.CTRL_USER_ID);
            EVF.getComponent("NEW_PO_APRV_NM").setValue(data.CTRL_USER_NM);
        }

        function doSearchVendor() {
            everPopup.openCommonPopup({
                callBackFunction: "selectVendor"
            }, 'SP0016');
        }

        function selectVendor(data) {
            EVF.getComponent("VENDOR_CD").setValue(data['VENDOR_CD']);
            EVF.getComponent("VENDOR_NM").setValue(data['VENDOR_NM']);
        }

        // 발주확정
        function doConfirm() {

            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length > 1) {
            	return alert("${msg.M0006}");
            }
            if(!grid.isExistsSelRow()) {
            	return alert("${msg.M0004}");
            }

            var selectedRow = grid.getSelRowValue()[0];

            if (EVF.isEmpty(selectedRow['PO_APRV_ID'])) {
                return alert('${BPOP_010_003}')
            }

            if ('${ses.userId}' != selectedRow['PO_APRV_ID']) {
            	return alert('${BPOP_010_007}');
            }

            var progressCode = selectedRow['PROGRESS_CD'];
            if (progressCode == '400') {
                return alert('${BPOP_010_012}');
            }

            if (progressCode != '200' && progressCode != '300') {
            	return alert("${msg.M0044}");
            }

            var forceCloseYn = selectedRow['FORCE_CLOSE_DATE'];
            if (forceCloseYn != '') {
            	return alert("${BPOP_010_001}");
            }

            if(!confirm('${BPOP_010_004}')) {
                return;
            }

            var poNum = selectedRow['PO_NUM'];
            everPopup.openPopupByScreenId("BPOM_020", 1200, 700, {
                poNum: poNum,
                progressCode : progressCode,
                popupFlag : true,
                detailView: false,
                callBackFunction : 'doSearch'
            });
			/*
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+'doConfirm', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
            */
        }

    	function doSapSend() {

    		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

    		if (selRowId.length == 0) {
    			alert("${msg.M0004}");
    			return;
    		}

    		for(var idx in selRowId) {
    			if (!(grid.getCellValue(selRowId[idx], 'PURCHASE_TYPE') == "SMT" || grid.getCellValue(selRowId[idx], 'PURCHASE_TYPE') == "OMRO")) {
    				alert("${BPOP_010_010}"); //부자재, 해외MRO 인 경우에만 SAP 전송이 가능합니다.
    				return;
    			}

    			if (grid.getCellValue(selRowId[idx], 'PROGRESS_CD') != '300') {
                	return alert("${msg.M0044}");
                }

    		}

            var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');

        	store.load(baseUrl + '/doSapSend', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});

    	}

        function doReport() {
            var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

            if(selRowIds.length == 0) {
                return alert("${msg.M0004}");
            }

            if(selRowIds.length > 1) {
                return alert("${msg.M0006}");
            }


           everPopup.printPoReport(grid.getCellValue(selRowIds[0], 'PO_NUM'))

        }

        function doSearchChart(){
            var store = new EVF.Store();
            var formData = store._getFormDataAsJson();
            var param = {
                formData : formData,
//                PO_FROM_DATE : EVF.C('PO_FROM_DATE').getValue(),
//                PO_TO_DATE : EVF.C('PO_TO_DATE').getValue(),
//                PURCHASE_TYPE : EVF.C('PURCHASE_TYPE').getValue(),
//                PO_CLOSE_FLAG : EVF.C('PO_CLOSE_FLAG').getValue(),
//                PO_NUM : EVF.C('PO_NUM').getValue(),
//                SUBJECT : EVF.C('SUBJECT').getValue(),
//                VENDOR_NM : EVF.C('VENDOR_NM').getValue(),
//                CTRL_USER_ID : EVF.C('CTRL_USER_ID').getValue(),
//                CTRL_USER_NM : EVF.C('CTRL_USER_NM').getValue(),
//                PO_APRV_ID : EVF.C('PO_APRV_ID').getValue(),
//                PO_APRV_NM : EVF.C('PO_APRV_NM').getValue(),
//                PROGRESS_CD : EVF.C('PROGRESS_CD').getValue(),
//                RECEIPT_STATUS : EVF.C('RECEIPT_STATUS').getValue(),

                detailView : false
            };
            everPopup.openPopupByScreenId('BPOP_011', 1000, 600, param);
        }

    </script>

	<e:window id="BPOP_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="PO_FROM_DATE" title="${form_PO_FROM_DATE_N}" />
				<e:field>
					<e:inputDate id="PO_FROM_DATE" toDate="PO_TO_DATE" name="PO_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_PO_FROM_DATE_R}" disabled="${form_PO_FROM_DATE_D}" readOnly="${form_PO_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="PO_TO_DATE" fromDate="PO_FROM_DATE" name="PO_TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_PO_TO_DATE_R}" disabled="${form_PO_TO_DATE_D}" readOnly="${form_PO_TO_DATE_RO}" />
				</e:field>
				<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
				<e:field>
					<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="PO_CLOSE_FLAG" title="${form_PO_CLOSE_FLAG_N}"/>
				<e:field>
					<e:select id="PO_CLOSE_FLAG" name="PO_CLOSE_FLAG" value="${form.PO_CLOSE_FLAG}" options="${poCloseFlagOptions}" width="${inputTextWidth}" disabled="${form_PO_CLOSE_FLAG_D}" readOnly="${form_PO_CLOSE_FLAG_RO}" required="${form_PO_CLOSE_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PO_NUM" title="${form_PO_NUM_N}" />
				<e:field>
					<e:inputText id="PO_NUM" name="PO_NUM" value="" width="${inputTextWidth }" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}" />
				</e:field>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
				<e:field>
					<e:inputText id="SUBJECT" style="ime-mode:inactive" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
				</e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
			</e:row>
			<e:row>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_ID" style="ime-mode:inactive" name="CTRL_USER_ID" value="${empty ses.ctrlCd ? '' : ses.userId}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_RO ? 'everCommon.blank' : 'doSearchBuyer'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${empty ses.ctrlCd ? '' : ses.userNm}" width="${inputTextWidth }" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
				</e:field>
                <e:label for="PO_APRV_ID" title="${form_PO_APRV_ID_N}"/>
                <e:field>
                    <e:inputText id="PO_APRV_NM" style="${imeMode}" name="PO_APRV_NM" value="${empty ses.ctrlCd ? ses.userNm : ''}" width="${inputTextWidth }" maxLength="${form_PO_APRV_NM_M}" disabled="${form_PO_APRV_NM_D}" readOnly="${form_PO_APRV_NM_RO}" required="${form_PO_APRV_NM_R}"/>
                    <e:inputHidden id="PO_APRV_ID" name="PO_APRV_ID" value="${empty ses.ctrlCd ? ses.userId : '' }"/>
                </e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
            <c:if test="${not empty ses.ctrlCd}">
                <e:text>구매담당자 변경</e:text>
                <e:search id="NEW_CTRL_USER_ID" name="NEW_CTRL_USER_ID" required="false" disabled="true" readOnly="false" maxLength="100" onIconClick="getNewCtrlUserId" width="100" />
                <e:text>&nbsp;</e:text>
                <e:inputText id="NEW_CTRL_USER_NM" name="NEW_CTRL_USER_NM" required="false" disabled="true" readOnly="false" maxLength="100" width="100" />
                <e:button id="doBuyerChange" name="doBuyerChange" label="${doBuyerChange_N}" onClick="doBuyerChange" disabled="${doBuyerChange_D}" visible="${doBuyerChange_V}" align="left" style="padding-left: 3px;" />
                <e:text>&nbsp;</e:text>
                <e:text>발주확정자 변경</e:text>
                <e:search id="NEW_PO_APRV_ID" name="NEW_PO_APRV_ID" required="false" disabled="true" readOnly="false" maxLength="100" onIconClick="getNewPoAprvId" width="100" />
                <e:text>&nbsp;</e:text>
                <e:inputText id="NEW_PO_APRV_NM" name="NEW_PO_APRV_NM" required="false" disabled="true" readOnly="false" maxLength="100" width="100" />
                <e:button id="doChangePoAprv" name="doChangePoAprv" label="${doChangePoAprv_N}" onClick="doChangePoAprv" disabled="${doChangePoAprv_D}" visible="${doChangePoAprv_V}" align="left" style="padding-left: 3px; padding-bottom: 8px;" />
            </c:if>

			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
            <c:if test="${not empty ses.ctrlCd}">
                <e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}" />
            </c:if>
            <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
            <e:button id="doChangePayment" name="doChangePayment" label="${doChangePayment_N}" onClick="doChangePayment" disabled="${doChangePayment_D}" visible="${doChangePayment_V}"/>
            <%--<c:if test="${not empty ses.ctrlCd}">--%>
                <%--<e:button id="doTerminate" name="doTerminate" label="${doTerminate_N}" onClick="readyToTerminate" disabled="${doTerminate_D}" visible="${doTerminate_V}" />--%>
            <%--</c:if>--%>
            <e:button id="doReport" name="doReport" label="${doReport_N}" onClick="doReport" disabled="${doReport_D}" visible="${doReport_V}"/>
			<c:if test="${devFlag}">
				<e:button id="doSapSend" name="doSapSend" label="${doSapSend_N}" onClick="doSapSend" disabled="${doSapSend_D}" visible="${doSapSend_V}"/>
			</c:if>

            <e:button id="doSearchChart" name="doSearchChart" label="${doSearchChart_N}" onClick="doSearchChart" disabled="${doSearchChart_D}" visible="${doSearchChart_V}" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
