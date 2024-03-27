<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/BOG_010";
        var grid;

        function init() {

            grid = EVF.C('gridGR');
            EVF.C('GR_CREATE_TYPE').setValue('INV');
            EVF.C('INSPECT_USER_NM').setValue('${ses.userNm}');
            grid.setProperty('panelVisible', ${panelVisible});

            grid.cellClickEvent(function (rowId, colId) {

                if (colId == 'INV_NUM') {

                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('SOI_020', 1000, 800, param);

                } else if (colId == 'PO_NUM') {

                    var param = {
                        "poNum": grid.getCellValue(rowId, 'PO_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('BPOM_020', 1180, 800, param);

                } else if (colId == 'ITEM_CD') {

                    var param = {
                        'gate_cd': '${ses.gateCd}',
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD')
                    };

                    everPopup.openPopupByScreenId('BBM_040', 1200, 750, param);

                } else if (colId == 'VENDOR_CD') {

                    var params = {
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        paramPopupFlag: "Y",
                        detailView : true
                    };
                    everPopup.openSupManagementPopup(params);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {

                if (colId == 'UNIT_PRC' || colId == 'GR_QT') {
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

            EVF.C('GR_CREATE_TYPE').removeOption('IGH');
            EVF.C('PURCHASE_TYPE').removeOption('DMRO');
        }

        function doSearch() {

            var store = new EVF.Store();

            if (!store.validate()) {
                return;
            }

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
                            /* 단가수정 시에만 INFO와 비교체크한다. (송장 생성 시 SAP에서 단가 오류나면 송장 취소하고 단가 수정 후 다시 송장생성시킨다는 말씀..) */
//                            grid.setCellReadOnly(rowId, 'UNIT_PRC', false);
                        }
                    }
                }
            });
        }

        function doGrConfirm() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var validate = grid.validate();
            if(!validate.flag) {
                return alert(validate.msg);
            }

            var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

            for(var i = 0;i < selRowId.length;i++) {

                var purchase_type = grid.getCellValue(selRowId[i], 'PURCHASE_TYPE');
                var inspectUserId = grid.getCellValue(selRowId[i],'INSPECT_USER_ID');
                var plantCd = grid.getCellValue(selRowId[i],'PLANT_CD');

                <%-- 검수자만 입고 가능한 부분 --%>
                //if(inspectUserId != '${ses.userId}') {
                //    alert('${msg.M0008}'); <%-- 처리할 권한이 없습니다. --%>
                //    return;
                //}

            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();

            if (!store.validate()) {
                return;
            }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doProcess', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>
    <e:window id="BOG_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="COMBO_DATE">
                    <e:select id="COMBO_DATE" name="COMBO_DATE" usePlaceHolder="false" width="100" required="${form_COMBO_DATE_R}" disabled="${form_COMBO_DATE_D }" readOnly="${form_COMBO_DATE_RO}">
                        <e:option text="${BOG_010_DATE1}" value="DUE_DATE">${BOG_010_DATE1}</e:option>
                        <e:option text="${BOG_010_DATE2}" value="PO_CREATE_DATE">${BOG_010_DATE2}</e:option>
                        <e:option text="${BOG_010_DATE3}" value="INV_DATE">${BOG_010_DATE3}</e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
                    <e:text> ~ </e:text>
                    <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
                </e:field>
                <e:label for="INSPECT_USER_NM" title="${form_INSPECT_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="INSPECT_USER_NM" style="${imeMode}" name="INSPECT_USER_NM" value="${form.INSPECT_USER_NM}" width="${inputTextWidth}" maxLength="${form_INSPECT_USER_NM_M}" disabled="${form_INSPECT_USER_NM_D}" readOnly="${form_INSPECT_USER_NM_RO}" required="${form_INSPECT_USER_NM_R}"/>
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder=""/>
                </e:field>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="${inputTextWidth}" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
                <e:field>
                    <e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="${inputTextWidth}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
                </e:field>
                <e:label for="GR_CREATE_TYPE" title="${form_GR_CREATE_TYPE_N}"/>
                <e:field>
                    <e:select id="GR_CREATE_TYPE" name="GR_CREATE_TYPE" value="${form.GR_CREATE_TYPE}" options="${grCreateTypeOptions}" width="${inputTextWidth}" disabled="${form_GR_CREATE_TYPE_D}" readOnly="${form_GR_CREATE_TYPE_RO}" required="${form_GR_CREATE_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doGrConfirm" name="doGrConfirm" label="${doGrConfirm_N}" onClick="doGrConfirm" disabled="${doGrConfirm_D}" visible="${doGrConfirm_V}" style="float: right; padding-right: 3px;"/>
            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">${BOG_010_TITLE_PROOF_DATE}</e:text>
                <e:inputDate id="PROOF_DATE" name="PROOF_DATE" value="${currentDate}" required="true" disabled="false" readOnly="false"/>
            </div>
            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">${BOG_010_TITLE_GR_DATE}</e:text>
                <e:inputDate id="GR_DATE" name="GR_DATE" value="${currentDate}" required="true" disabled="false" readOnly="false"/>
            </div>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" style="float: right;"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridGR" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridGR.gridColData}"/>

    </e:window>
</e:ui>