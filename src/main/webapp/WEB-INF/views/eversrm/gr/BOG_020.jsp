<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/BOG_020"
                , grid;

        function init() {
            grid = EVF.C('grid');
            EVF.C('GR_REG_USER_NM').setValue('${ses.userNm}');
            grid.setProperty('panelVisible', ${panelVisible});
            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'INV_NUM') {
					if (grid.getCellValue(rowId, 'INV_NUM') == '') {
						return;
					}
                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('SOI_020', 1000, 800, param);

                } else if(colId == 'PO_NUM') {

                    if (grid.getCellValue(rowId, 'PO_NUM') == '') {
                        return;
                    }
                    var param = {
                        "poNum": grid.getCellValue(rowId, 'PO_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('BPOM_020', 1200, 800, param);

                } else if (colId == 'ITEM_CD') {

                    if (grid.getCellValue(rowId, 'ITEM_CD') == '') {
                        return;
                    }
                    var param = {
                        'gate_cd': '${ses.gateCd}',
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD')
                    };

                    everPopup.openPopupByScreenId('BBM_040', 1200, 750, param);

                } else if (colId == 'VENDOR_CD') {

                    if (grid.getCellValue(rowId, 'VENDOR_CD') == '') {
                        return;
                    }
                    var params = {
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        paramPopupFlag: "Y",
                        detailView : true
                    };
                    everPopup.openSupManagementPopup(params);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {
            	if (colId == 'UNIT_PRC') {

                    var pt = grid.getCellValue(rowId, 'PURCHASE_TYPE');
                    if(pt != 'SMT') /* 부자재인 경우 단가 수정 가능 */ {
                    	grid.setCellValue(rowId,'UNIT_PRC',oldValue);
                        setTimeout(function() {
                            grid.checkRow(rowId,false);

                        }, 100);
                    }

					var cur = grid.getCellValue(rowId, 'CUR');
					var unitPrc = Number(grid.getCellValue(rowId, 'UNIT_PRC'));
					var grQt = Number(grid.getCellValue(rowId, 'GR_QT'));
					var grAmt = everCurrency.getPrice(cur, unitPrc * grQt);
					grid.setCellValue(rowId, 'GR_AMT', grAmt);
                }
            });

            grid.excelExportEvent({
                allCol : "${excelExport.allCol}",
                selRow : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }",
                excelOptions : {
                    imgWidth      : 0.12, 		// 이미지 너비
                    imgHeight     : 0.26,		    // 이미지 높이
                    colWidth      : 20,        	// 컬럼의 넓이
                    rowSize       : 500,       	// 엑셀 행에 높이 사이즈
                    attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
                }
            });

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {

                if (code) {
                    grid.checkAll(true);

                    var allRowId = grid.getAllRowId();
                    for(var i in allRowId) {

                        var rowId = allRowId[i];

                        grid.setCellValue(rowId, 'PURCHASE_TYPE', 'DMRO');
                        grid.setCellValue(rowId, 'REG_USER_ID', '${ses.userId}');
                        grid.setCellValue(rowId, 'REG_USER_NM', '${ses.userNm}');
                    }
                }
            });

            EVF.C('PURCHASE_TYPE').removeOption('DMRO');
        }

        function doSearch() {

            var store = new EVF.Store();

            if(!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                } else {

                    var allRowId = grid.getAllRowId();
                    for(var i in allRowId) {

                        var rowId = allRowId[i];
                        var pt = grid.getCellValue(rowId, 'PURCHASE_TYPE');
                        if(pt == 'SMT') /* 부자재인 경우 단가 수정 가능 */ {
//                            grid.setCellReadOnly(rowId, 'UNIT_PRC', false);
                        }
                    }
                }
            });
        }

        function doCreateExcelGR() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var ri in gridData) {
                var item = gridData[ri];
                if(!EVF.isEmpty(item['GR_YEAR'])) {
                    return alert('${BOG_020_0004}');
                }
            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doCreateExcelGR', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doCheckAuth() {

            var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

            for(var i = 0;i < selRowId.length;i++) {
                var purchase_type = grid.getCellValue(selRowId[i], 'PURCHASE_TYPE');
                var inspectUserId = grid.getCellValue(selRowId[i],'REG_USER_ID');
                var plantCd = grid.getCellValue(selRowId[i],'PLANT_CD');

                //if(inspectUserId != '${ses.userId}') {
                //    return alert('${msg.M0008}'); <%-- 처리할 권한이 없습니다. --%>
                //}
            }

            return true;
        }

        function doGrCancel() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var ri in gridData) {

                var item = gridData[ri];
                if(EVF.isEmpty(item['GR_YEAR'])) {
                    return alert('${BOG_020_0005}');
                }

                if(EVF.isNotEmpty(item['DEAL_NUM'])) {
                    return alert('${BOG_020_0007}');
                }

                if(item['CANCEL_FLAG'] == 'Y') {
                    return alert('${BOG_020_0006}');
                }

                //if(item['INSPECT_USER_ID'] != '${ses.userId}') {
                //    return alert('${msg.M0008}'); <%-- 처리할 권한이 없습니다. --%>
                //}
            }


            if(! doCheckAuth()) {
            	return;
            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doGrCancel', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doUpdateUnitPrc() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var ri in gridData) {
                var item = gridData[ri];
                if(EVF.isEmpty(item['GR_YEAR'])) {
                    return alert('${BOG_020_0005}');
                }
                if(EVF.isNotEmpty(item['DEAL_NUM'])) {
                    return alert('${BOG_020_0007}');
                }
                if(item['CANCEL_FLAG'] == 'Y') {
                    return alert('${BOG_020_0006}');
                }
            }

            if(! doCheckAuth()) {
            	return;
            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doUpdateUnitPrc', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    	function doSapSend() {

    		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

    		if (selRowId.length == 0) {
    			alert("${msg.M0004}");
    			return;
    		}

    		for(idx in selRowId) {
    			//if (!(grid.getCellValue(selRowId[idx], 'PURCHASE_TYPE') == "SMT" || grid.getCellValue(selRowId[idx], 'PURCHASE_TYPE') == "OMRO")) {
    			if (!(grid.getCellValue(selRowId[idx], 'PURCHASE_TYPE') == "OMRO")) {
    				alert("${BOG_020_0001}"); //해외MRO 인 경우에만 SAP 전송이 가능합니다. => 2016/03/07 : 부자재는 송장전송시 생성함.
    				return;
    			}

    			if (Number(grid.getCellValue(selRowId[idx], 'GR_QT')) < 0) {
                	return alert("${msg.M0061}");
                }

    		}

            if(! doCheckAuth()) {
            	return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');

        	store.load(baseUrl + '/doSapSend', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});

    	}

        function doDownTemplate() {
            top.hidden_workspace.src = '/resource/template/MRO_UPLOAD_TEMPLATE.xlsx';
        }

    </script>
    <e:window id="BOG_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="GR_FROM_DATE" title="${form_GR_DATE_N}"/>
                <e:field>
                    <e:inputDate id="GR_FROM_DATE" toDate="GR_TO_DATE" name="GR_FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_GR_DATE_R}" disabled="${form_GR_DATE_D}" readOnly="${form_GR_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="GR_TO_DATE" fromDate="GR_FROM_DATE" name="GR_TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_GR_DATE_R}" disabled="${form_GR_DATE_D}" readOnly="${form_GR_DATE_RO}" />
                </e:field>
                <e:label for="GR_NUM" title="${form_GR_NUM_N}"/>
                <e:field>
                    <e:inputText id="GR_NUM" style="ime-mode:inactive" name="GR_NUM" value="${form.GR_NUM}" width="${inputTextWidth}" maxLength="${form_GR_NUM_M}" disabled="${form_GR_NUM_D}" readOnly="${form_GR_NUM_RO}" required="${form_GR_NUM_R}"/>
                </e:field>
                <e:label for="GR_REG_USER_NM" title="${form_GR_REG_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="GR_REG_USER_NM" style="${imeMode}" name="GR_REG_USER_NM" value="${form.GR_REG_USER_NM}" width="${inputTextWidth}" maxLength="${form_GR_REG_USER_NM_M}" disabled="${form_GR_REG_USER_NM_D}" readOnly="${form_GR_REG_USER_NM_RO}" required="${form_GR_REG_USER_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="COMBO_NUM">
                    <e:select id="COMBO_DATA" name="COMBO_DATA" disabled="false" readOnly="false" required="false" >
                        <e:option text="발주번호" value="PO_NUM"></e:option>
                        <e:option text="입고번호" value="GR_NUM"></e:option>
                        <e:option text="거래명세서번호" value="INV_NUM"></e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputText id="COMBO_NUM" style="ime-mode:inactive" name="COMBO_NUM" value="${form.COMBO_NUM}" width="${inputTextWidth}" maxLength="${form_COMBO_NUM_M}" disabled="${form_COMBO_NUM_D}" readOnly="${form_COMBO_NUM_RO}" required="${form_COMBO_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
                <e:field>
                    <e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
                </e:field>
                <e:label for="DEAL_FLAG" title="${form_DEAL_FLAG_N}"/>
                <e:field>
                    <e:select id="DEAL_FLAG" name="DEAL_FLAG" value="${form.DEAL_FLAG}" options="${dealFlagOptions}" width="${inputTextWidth}" disabled="${form_DEAL_FLAG_D}" readOnly="${form_DEAL_FLAG_RO}" required="${form_DEAL_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" useMultipleSelect="true" />
                </e:field>
                <e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
                <e:field>
                    <e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${matGroupOptions}" width="${inputTextWidth}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder="" />
                </e:field>
                <e:label for="PLAN_NUM" title="${form_PLAN_NUM_N}"/>
                <e:field>
                    <e:inputText id="PLAN_NUM" style="ime-mode:inactive" name="PLAN_NUM" value="${form.PLAN_NUM}" width="${inputTextWidth}" maxLength="${form_PLAN_NUM_M}" disabled="${form_PLAN_NUM_D}" readOnly="${form_PLAN_NUM_RO}" required="${form_PLAN_NUM_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">

            <e:button id="doDownTemplate" name="doDownTemplate" label="${doDownTemplate_N}" onClick="doDownTemplate" disabled="${doDownTemplate_D}" visible="${doDownTemplate_V}" align="left" />
            <e:button id="doCreateExcelGR" name="doCreateExcelGR" label="${doCreateExcelGR_N}" onClick="doCreateExcelGR" disabled="${doCreateExcelGR_D}" visible="${doCreateExcelGR_V}" align="left" />
            <e:button id="doUpdateUnitPrc" name="doUpdateUnitPrc" label="${doUpdateUnitPrc_N}" onClick="doUpdateUnitPrc" disabled="${doUpdateUnitPrc_D}" visible="${doUpdateUnitPrc_V}"  style="float: right;" />
            <e:button id="doGrCancel" name="doGrCancel" label="${doGrCancel_N}" onClick="doGrCancel" disabled="${doGrCancel_D}" visible="${doGrCancel_V}" style="float: right; padding-right: 3px;" />
			<c:if test="${devFlag}">
				<e:button id="doSapSend" name="doSapSend" label="${doSapSend_N}" onClick="doSapSend" disabled="${doSapSend_D}" visible="${doSapSend_V}" style="float: right; padding-right: 3px;"/>
			</c:if>

            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">취소일자</e:text>
                <e:inputDate id="CANCEL_DATE" name="CANCEL_DATE" value="${toDate}" required="true" disabled="false" readOnly="false" />
            </div>

            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" style="padding-right: 3px;" align="right" />

            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">${form_CANCEL_FLAG_N}:</e:text>
                <e:select id="CANCEL_FLAG" name="CANCEL_FLAG" value="${form.CANCEL_FLAG}" options="${cancelFlagOptions}" width="40" disabled="${form_CANCEL_FLAG_D}" readOnly="${form_CANCEL_FLAG_RO}" required="${form_CANCEL_FLAG_R}" placeHolder="" />
            </div>

        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
