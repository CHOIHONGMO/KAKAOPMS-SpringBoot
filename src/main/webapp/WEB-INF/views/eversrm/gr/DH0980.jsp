<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/DH0980"
                , grid;

        function init() {

            grid = EVF.C('grid');
            grid.setProperty('panelVisible', ${panelVisible});
    		grid.excelExportEvent({
    			allCol : "${excelExport.allCol}",
    			selRow : "${excelExport.selRow}",
    			fileType : "${excelExport.fileType }",
    			fileName : "${screenName }",
    		    excelOptions : {
    				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
    				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
    				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
    				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
    		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
    		    }
    		});

            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'INV_NUM') {

                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('SOG_030', 1000, 800, param);

                } else if(colId == 'PO_NUM') {

                    var param = {
                        "poNum": grid.getCellValue(rowId, 'PO_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('BPOM_020', 1200, 800, param);

                } else if(colId == 'LINK_REJECT_RMK') {

                    var param = {
                        "rowId": rowId,
                        "TEXT_CONTENTS": grid.getCellValue(rowId, "REJECT_RMK"),
                        "callBackFunction": 'setRejectRmk',
                        "havePermission": 'true',
                        "detailView": false
                    };

                    everPopup.openWindowPopup('/common/popup/commonTextContents/view', 700, 320, param, 'common_text_input');


                } else if (colId == 'VENDOR_CD') {

                    var params = {
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        paramPopupFlag: "Y",
                        detailView: true
                    };
                    everPopup.openSupManagementPopup(params);
                }
            });

            EVF.C('PROGRESS_CD').removeOption('50');
            EVF.C('PROGRESS_CD').removeOption('700');
            EVF.C('PURCHASE_TYPE').removeOption('DMRO');
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doAccept() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var ri in gridData) {

                var rowData = gridData[ri];
                var pc = rowData['PROGRESS_CD'];
                if(pc != '100') {
                    return alert('${msg.M0045}');
                }

                var inspectUserId = rowData['INSPECT_USER_ID'];

                <%--공장별 권한 적용 2016.1.8 DAGURI
                if('${ses.userId}' != inspectUserId) {
                    return alert('${DH0980_003}');
                }
                --%>
            }

            if (!confirm('${DH0980_001}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doAccept', function () {
                alert(this.getResponseMessage());
                doSearch();
            });

        }

        function doReject() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var ri in gridData) {
                var rowData = gridData[ri];
                var pc = rowData['PROGRESS_CD'];
                if(pc != '100') {
                    return alert('${msg.M0045}');
                }

                var inspectUserId = rowData['INSPECT_USER_ID'];

                <%--공장별 권한 적용 2016.1.8 DAGURI
				if('${ses.userId}' != inspectUserId) {
                    return alert('${msg.M0008}');
                }
                --%>
            }

            if (!confirm('${DH0980_002}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doReject', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function setRejectRmk(textContents, rowId) {


        	grid.setCellValue(rowId, 'LINK_REJECT_RMK', textContents);

        	grid.setCellValue(rowId, 'REJECT_RMK', textContents);
        }

    </script>
    <e:window id="DH0980" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="SEND_DATE" title="${form_SEND_DATE_N}"/>
                <e:field>
                    <e:inputDate id="SEND_FROM_DATE" toDate="SEND_TO_DATE" name="SEND_FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_SEND_DATE_R}" disabled="${form_SEND_DATE_D}" readOnly="${form_SEND_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="SEND_TO_DATE" fromDate="SEND_FROM_DATE" name="SEND_TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_SEND_DATE_R}" disabled="${form_SEND_DATE_D}" readOnly="${form_SEND_DATE_RO}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="INV_NUM" title="${form_INV_NUM_N}" />
                <e:field>
                    <e:inputText id="INV_NUM" style="ime-mode:inactive" name="INV_NUM" value="${form.INV_NUM}" width="${inputTextWidth}" maxLength="${form_INV_NUM_M}" disabled="${form_INV_NUM_D}" readOnly="${form_INV_NUM_RO}" required="${form_INV_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}" />
                <e:field>
                    <e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="${inputTextWidth}" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
                </e:field>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}" />
                <e:field>
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="${inputTextWidth}" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="INSPECT_USER_NM" title="${form_INSPECT_USER_NM_N}" />
                <e:field>
                    <e:inputText id="INSPECT_USER_NM" style="${imeMode}" name="INSPECT_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_INSPECT_USER_NM_M}" disabled="${form_INSPECT_USER_NM_D}" readOnly="${form_INSPECT_USER_NM_RO}" required="${form_INSPECT_USER_NM_R}"/>
                </e:field>
                <e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
                <e:field>
                    <e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${form.CTRL_USER_NM}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}" style="float: right;" />
            <e:button id="doAccept" name="doAccept" label="${doAccept_N}" onClick="doAccept" disabled="${doAccept_D}" visible="${doAccept_V}" style="float: right; padding-right: 3px;" />
            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">검수일자</e:text>
                <e:inputDate id="INSPECT_DATE_2" name="INSPECT_DATE_2" value="${toDate}" required="true" disabled="false" readOnly="false" />
            </div>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" style="float: right; padding-right: 3px;" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
