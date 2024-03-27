<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/RQ01/RQ0102/";

        function init() {

        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-PROOF_FILE_NUM').css('display','none');
        	}

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'VENDOR_REGION_NM') {

                    var param = {
                        VENDOR_REGION_CD : grid.getCellValue(rowId, 'VENDOR_REGION_CD'),
                        QTA_UNIT_PRC : grid.getCellValue(rowId, 'QTA_UNIT_PRC'),
                        LEADTIME : grid.getCellValue(rowId, 'LEADTIME'),
                        LEADTIME_CD : grid.getCellValue(rowId, 'LEADTIME_CD'),
                        MOQ_QT : grid.getCellValue(rowId, 'MOQ_QT'),
                        RV_QT : grid.getCellValue(rowId, 'RV_QT'),
                        TAX_CD : grid.getCellValue(rowId, 'TAX_CD'),
                        QTA_REMARK : grid.getCellValue(rowId, 'QTA_REMARK'),
                        LEADTIME_RMK : grid.getCellValue(rowId, 'LEADTIME_RMK'),
                        callbackFunction: 'setRegionInfo',
                        'rowId': rowId,
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("SSO1_011", 1000, 300, param);
                }
                if(colId == 'LEADTIME_RMK_IMG') {
                    var param = {
                        title: "${RQ01_022_001 }",
                        message: grid.getCellValue(rowId, 'LEADTIME_RMK'),
                        callbackFunction: 'setRMKL',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                if(colId == 'RQDT_ATT_FILE_CNT') {
                    var param = {
                        havePermission: false,
                        attFileNum: grid.getCellValue(rowId, 'RQDT_ATT_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: '',
                        bizType: 'VENDOR',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'QTA_FILE_CNT') {
                    var param = {
                        havePermission: true,
                        attFileNum: grid.getCellValue(rowId, 'QTA_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: 'fileAttachPopupCallback',
                        bizType: 'QTA',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'QTA_REMARK_IMG') {
                    var param = {
                        title: "${RQ01_022_002 }",
                        message: grid.getCellValue(rowId, 'QTA_REMARK'),
                        callbackFunction: 'setRMKQ',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                if(colId == 'GIVEUP_REASON_IMG') {
                    var param = {
                        title: "${RQ01_022_003 }",
                        message: grid.getCellValue(rowId, 'GIVEUP_REASON'),
                        callbackFunction: 'setRMKG',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            });

            grid.setProperty('multiSelect', false);
            grid.setColIconify("LEADTIME_RMK_IMG", "LEADTIME_RMK", "comment", false);
            grid.setColIconify("QTA_REMARK_IMG", "QTA_REMARK", "comment", false);
            grid.setColIconify("GIVEUP_REASON_IMG", "GIVEUP_REASON", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            // STOCRQVN 의 진행상태=견적서 미제출(RFQ_PROGRESS_CD IN ('100','200')
			if($('#VENDOR_CD option[value != ""]').length == 0) {
                alert("${RQ01_022_019}");
                opener.openVendorListPopup("${param.RFQ_NUM}", "${param.RFQ_CNT}");
                doClose();
            }
 		}

        function doSearch() {

            if(!EVF.isEmpty(EVF.C("VENDOR_CD").getValue()) && !EVF.isEmpty(EVF.C("VENDOR_USER").getValue())) {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.load(baseUrl + "rq01022_doSearch", function () {
                });
            }
        }

        // 견적서 제출
        function doSave() {

            if(EVF.isEmpty(EVF.C("VENDOR_CD").getValue())) { return alert("${RQ01_022_018}"); }
            if(EVF.isEmpty(EVF.C("VENDOR_USER").getValue())) { return alert("${RQ01_022_020}"); }

            grid.checkAll(true);

            var firstSendFlag = "Y";
            var qtaNum;
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(!EVF.isEmpty(grid.getCellValue(rowIds[i], 'QTA_NUM'))) {
                    firstSendFlag = "N";
                    qtaNum = grid.getCellValue(rowIds[i], 'QTA_NUM');
                }
                if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'GIVEUP_FLAG'))) {
                    return alert("'" + grid.getCellValue(rowIds[i], 'ITEM_DESC') + "'" + "${RQ01_022_004}");
                }
                if(grid.getCellValue(rowIds[i], 'GIVEUP_FLAG') == "0") {
                	<%-- 납품지역을 선택하세요. --%>
                	//if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'VENDOR_REGION_CD')) || grid.getCellValue(rowIds[i], 'VENDOR_REGION_NM') == "N") {
                    //    return alert("${RQ01_022_005}");
                    //}
                    if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'QTA_UNIT_PRC')) || grid.getCellValue(rowIds[i], 'QTA_UNIT_PRC') == 0 || grid.getCellValue(rowIds[i], 'QTA_UNIT_PRC') == "0") {
                        return alert("${RQ01_022_006}"); <%-- 견적단가를 입력하세요. --%>
                    }
                    if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'LEADTIME')) || grid.getCellValue(rowIds[i], 'LEADTIME') == 0 || grid.getCellValue(rowIds[i], 'LEADTIME') == "0") {
                        return alert("${RQ01_022_007}"); <%-- 표준납기를 입력하세요. --%>
                    }
                    <%-- 표준납기 Type을 선택하세요. --%>
                    //if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'LEADTIME_CD'))) {
                    //    return alert("${RQ01_022_008}");
                    //}
                    <%--if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'LEADTIME_RMK'))) {--%>
                    <%--    return alert("${RQ01_022_009}"); &lt;%&ndash; 표준납기사유를 입력하셔야합니다. &ndash;%&gt;--%>
                    <%--}--%>
                    if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'MOQ_QT')) || grid.getCellValue(rowIds[i], 'MOQ_QT') == 0 || grid.getCellValue(rowIds[i], 'MOQ_QT') == "0") {
//                        return alert("${RQ01_022_010}"); <%-- 최소발주량을 입력하세요. --%>
                    }
                    if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'RV_QT')) || grid.getCellValue(rowIds[i], 'RV_QT') == 0 || grid.getCellValue(rowIds[i], 'RV_QT') == "0") {
//                        return alert("${RQ01_022_011}"); <%-- 발주배수를 입력하세요. --%>
                    }
                    if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'TAX_CD'))) {
                        return alert("${RQ01_022_012}"); <%-- 과세구분을 선택하세요. --%>
                    }
                }
                if(grid.getCellValue(rowIds[i], 'GIVEUP_FLAG') == "1" && EVF.isEmpty(grid.getCellValue(rowIds[i], 'GIVEUP_REASON'))) {
                    return alert("${RQ01_022_013}"); <%-- 견적포기시 포기사유를 입력하셔야 합니다. --%>
                }
            }


            if(!confirm('${RQ01_022_017}')) { return; }

            var store = new EVF.Store();
            store.doFileUpload(function() {
                store.setGrid([grid]);
                store.getGridData(grid, 'all');
                store.setParameter("firstSendFlag", firstSendFlag);
                store.setParameter("QTA_NUM", qtaNum);
                store.load(baseUrl + 'rq01022_doSave', function() {
                    alert(this.getResponseMessage());
                    opener.doSearch();
                    doClose();
                });
            });
        }

        function setRegionInfo(data) {
            grid.setCellValue(data.rowId, 'VENDOR_REGION_CD', data.VENDOR_REGION_CD);
            grid.setCellValue(data.rowId, 'VENDOR_REGION_NM', (EVF.isEmpty(data.VENDOR_REGION_CD) ? "N" : "Y"));
            grid.setCellValue(data.rowId, 'QTA_UNIT_PRC', data.QTA_UNIT_PRC);
            grid.setCellValue(data.rowId, 'LEADTIME', data.LEADTIME);
            grid.setCellValue(data.rowId, 'LEADTIME_CD', data.LEADTIME_CD);
            grid.setCellValue(data.rowId, 'MOQ_QT', data.MOQ_QT);
            grid.setCellValue(data.rowId, 'RV_QT', data.RV_QT);
            grid.setCellValue(data.rowId, 'TAX_CD', data.TAX_CD);
            grid.setCellValue(data.rowId, 'QTA_REMARK', data.QTA_REMARK);
            grid.setCellValue(data.rowId, 'LEADTIME_RMK', data.LEADTIME_RMK);
        }

        function setRMKL(data) {
            grid.setCellValue(data.rowId, 'LEADTIME_RMK', data.message);
        }

        function setRMKQ(data) {
            grid.setCellValue(data.rowId, 'QTA_REMARK', data.message);
        }

        function setRMKG(data) {
            grid.setCellValue(data.rowId, 'GIVEUP_REASON', data.message);
        }

        function fileAttachPopupCallback(rowId, fileId, fileCount) {
            grid.setCellValue(rowId, 'QTA_FILE_CNT', fileCount);
            grid.setCellValue(rowId, 'QTA_FILE_NUM', fileId);
        }

        function getVendorUser() {
            if(!EVF.isEmpty(EVF.C("VENDOR_CD").getValue())) {
                var store = new EVF.Store();
                store.setParameter('vendorCd', EVF.C("VENDOR_CD").getValue());
                store.load(baseUrl + "rq01022_getVendorUsers", function () {
                    EVF.C('VENDOR_USER').setOptions(this.getParameter('vendorUserOptions'));
                }, false);
            }
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="RQ01_022" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false">
            <e:row>
                <e:label for="RFQ_SUBJECT" title="${form_RFQ_SUBJECT_N}"/>
                <e:field>
                    <e:text>${param.RFQ_SUBJECT}</e:text>
                    <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="${param.RFQ_NUM}" />
                    <e:inputHidden id="RFQ_CNT" name="RFQ_CNT" value="${param.RFQ_CNT}" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:select id="VENDOR_CD" name="VENDOR_CD" value="" options="${vendorListOptions}" width="${form_VENDOR_CD_W}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" placeHolder="" onChange="getVendorUser" />
                </e:field>
                <e:label for="VENDOR_USER" title="${form_VENDOR_USER_N}"/>
                <e:field>
                    <e:select id="VENDOR_USER" name="VENDOR_USER" value="" options="" width="${form_VENDOR_USER_W}" disabled="${form_VENDOR_USER_D}" readOnly="${form_VENDOR_USER_RO}" required="${form_VENDOR_USER_R}" placeHolder="" onChange="doSearch" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PROOF_FILE_NUM" title="${form_PROOF_FILE_NUM_N }" />
                <e:field colSpan="5">
                    <e:fileManager id="PROOF_FILE_NUM" name="PROOF_FILE_NUM" bizType="QTA" fileId="${formData.PROOF_FILE_NUM}" readOnly="${param.detailView }" downloadable="true" width="100%" height="200px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_PROOF_FILE_NUM_R }" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

        <e:buttonBar id="btnB" align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
        </e:buttonBar>

    </e:window>
</e:ui>