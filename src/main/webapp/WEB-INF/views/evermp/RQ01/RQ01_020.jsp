<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var gridT; var gridB;
        var baseUrl = "/evermp/RQ01/RQ0102/";
        var rfqNum; var rfqCnt; var progressCd;
        var eventRow = -1;

        function gridBLoad(rowId){
            rfqNum = gridT.getCellValue(rowId, 'RFQ_NUM');
            rfqCnt = gridT.getCellValue(rowId, 'RFQ_CNT');
            progressCd = gridT.getCellValue(rowId, 'PROGRESS_CD');
            if(rowId!=eventRow){
    			gridT.checkRow(eventRow, false);
                eventRow = rowId;
            }
            var store = new EVF.Store();
            store.setParameter("RFQ_NUM", gridT.getCellValue(rowId, 'RFQ_NUM'));
            store.setParameter("RFQ_CNT", gridT.getCellValue(rowId, 'RFQ_CNT'));
            store.setGrid([gridB]);
            store.load(baseUrl + "rq01020_doSearchB", function () {

                gridB.setColMerge(['CUSTNAME','PLANTNAME','USERNAME','ITEM_CD','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM','ORIGIN_NM','UNIT_CD','REGION_NM', 'QTY']);

                var allRowId = gridB.getAllRowId();
                for (var i in allRowId) {
                    if(gridB.getCellValue(allRowId[i], 'SETTLE_POSSIBLE_FLAG') == "X") {
                        gridB.setCellValue(allRowId[i], 'SETTLE_FLAG', "0");
                        gridB.setCellReadOnly(allRowId[i], 'SETTLE_FLAG', true);
                    }
                    if(gridB.getCellValue(allRowId[i], 'GIVEUP_FLAG') == "1") {
                        gridB.setCellFontColor(allRowId[i], 'GIVEUP_FLAG_NM', "#ff6928");
                        gridB.setCellFontWeight(allRowId[i], "GIVEUP_FLAG_NM", true);
                    }
                    if(gridB.getCellValue(allRowId[i], 'SEND_FLAG_CD') == "300") {
                        gridB.setCellFontColor(allRowId[i], 'SEND_FLAG_NM', "#ff6928");
                        gridB.setCellFontWeight(allRowId[i], "SEND_FLAG_NM", true);
                    }
                    if(gridB.getCellValue(allRowId[i], 'SEND_FLAG_CD') == "150") {
                        gridB.setCellFontColor(allRowId[i], 'SEND_FLAG_NM', "#4448ff");
                        gridB.setCellFontWeight(allRowId[i], "SEND_FLAG_NM", true);
                    }
                    if(gridB.getCellValue(allRowId[i], 'RANK') == "1") {
                        gridB.setCellFontColor(allRowId[i], 'QTA_UNIT_PRC', "#ff6928");
                        gridB.setCellFontWeight(allRowId[i], "QTA_UNIT_PRC", true);
                    }
                    if(gridB.getCellValue(allRowId[i], 'SETTLE_FLAG') == "1") {
                        gridB.setCellFontColor(allRowId[i], 'CONT_UNIT_PRC', "#ff5b12");
                        gridB.setCellFontWeight(allRowId[i], "CONT_UNIT_PRC", true);
                    }
                }
            });
        }

        function init() {

            gridT = EVF.C("gridT");
            gridB = EVF.C("gridB");

            gridT.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'multiSelect' && value =='1') {
					gridBLoad(rowId);
                }
                if(colId == 'RFQ_NUM') {
                    var rfqnum = gridT.getCellValue(rowId, 'RFQ_NUM');
                    var rfqcnt = gridT.getCellValue(rowId, 'RFQ_CNT');
                    var param = {
                        'RFQ_NUM'  : rfqnum,
                        'RFQ_CNT'  : rfqcnt,
                        'RFQ_TYPE' : "100",
                        'sendType' : "E",		// 기존 견적서 수정
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("RQ01_011", 1400, 800, param);
                }
                if(colId == 'CTRL_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: gridT.getCellValue(rowId, 'CTRL_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'VENDOR_LIST') {
                    openVendorListPopup(gridT.getCellValue(rowId, 'RFQ_NUM'), gridT.getCellValue(rowId, 'RFQ_CNT'));
                }
                if(colId == 'ATT_FILE_CNT') {
                    if(Number(gridT.getCellValue(rowId, "ATT_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridT.getCellValue(rowId, 'ATT_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'RFQ',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == 'RMK_TEXT_NUM_IMG') {
                    if(!EVF.isEmpty(gridT.getCellValue(rowId, "RMK_TEXT_NUM"))) {
                        var param = {
                             rowId : rowId
                            ,havePermission : true
                            ,screenName : "요청 및 특기사항"
                            ,callBackFunction : ''
                            ,largeTextNum : gridT.getCellValue(rowId, "RMK_TEXT_NUM")
                            ,detailView : true
                        };
                        everPopup.openPopupByScreenId('commonRichTextContents', 900, 600, param);
                    }
                }
                if(colId === "SOURCING_REJECT_RMK") {
                    if(!EVF.isEmpty(gridT.getCellValue(rowId, "SOURCING_REJECT_RMK"))) {
                        var param = {
                            title : "${RQ01_020_037}",
                            message : gridT.getCellValue(rowId, "SOURCING_REJECT_RMK"),
                            callbackFunction : "",
                            detailView : true,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId === "EXTEND_RMK") {
                    if(!EVF.isEmpty(gridT.getCellValue(rowId, "EXTEND_RMK"))) {
                        var param = {
                            title : "마감일시 변경사유",
                            message : gridT.getCellValue(rowId, "EXTEND_RMK"),
                            callbackFunction : "",
                            detailView : true,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId === "FAIL_BID_RMK") {
                    if(!EVF.isEmpty(gridT.getCellValue(rowId, "FAIL_BID_RMK"))) {
                        var param = {
                            title : "유찰사유",
                            message : gridT.getCellValue(rowId, "FAIL_BID_RMK"),
                            callbackFunction : "",
                            detailView : true,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId === "RFQ_SUBJECT"){
                    gridT.checkRow(rowId, true);
                    gridBLoad(rowId);
                }
            });

            gridB.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': gridB.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': false,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'VENDOR_NM') {
                    var param = {
                        'VENDOR_CD': gridB.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
                if(colId == 'LEADTIME_RMK_IMG') {
                    if(!EVF.isEmpty(gridB.getCellValue(rowId, "LEADTIME_RMK"))) {
                        var param = {
                            title: "${RQ01_020_003 }",
                            message: gridB.getCellValue(rowId, 'LEADTIME_RMK')
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'RQDT_ATT_FILE_CNT') {
                    if(Number(gridB.getCellValue(rowId, "RQDT_ATT_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridB.getCellValue(rowId, 'RQDT_ATT_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'VENDOR',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == 'QTA_FILE_CNT') {
                    if(Number(gridB.getCellValue(rowId, "QTA_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridB.getCellValue(rowId, 'QTA_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'QTA',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == 'QTA_REMARK_IMG') {
                    if(!EVF.isEmpty(gridB.getCellValue(rowId, "QTA_REMARK"))) {
                        var param = {
                            title: "${RQ01_020_004 }",
                            message: gridB.getCellValue(rowId, 'QTA_REMARK')
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'GIVEUP_REASON_IMG') {
                    if(!EVF.isEmpty(gridB.getCellValue(rowId, "GIVEUP_REASON"))) {
                        var param = {
                            title: "${RQ01_020_005 }",
                            message: gridB.getCellValue(rowId, 'GIVEUP_REASON')
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'SETTLE_RMK_IMG') {
                    var param = {
                        title: "${RQ01_020_006 }",
                        message: gridB.getCellValue(rowId, 'SETTLE_RMK'),
                        callbackFunction: 'setRMKG',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                if(colId == 'PROOF_FILE_CNT') {
                    if(Number(gridB.getCellValue(rowId, "PROOF_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridB.getCellValue(rowId, 'PROOF_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'QTA',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == 'USERNAME') {
                	if(!EVF.isEmpty(gridB.getCellValue(rowId, 'REQUEST_USER_ID'))) {
                        var param = {
                                callbackFunction: "",
                                USER_ID: gridB.getCellValue(rowId, 'REQUEST_USER_ID'),
                                detailView: true
                            };
                            everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                	}
                }
            });

            gridT.setProperty('shrinkToFit', false);
            gridT.setColIconify("RMK_TEXT_NUM_IMG", "RMK_TEXT_NUM", "comment", false);

            gridB.setProperty('multiSelect', false);
            gridB.setColIconify("LEADTIME_RMK_IMG", "LEADTIME_RMK", "comment", false);	// 표준납기사유[미사용]
            gridB.setColIconify("QTA_REMARK_IMG", "QTA_REMARK", "comment", false);		// 공급사 특이사항
            gridB.setColIconify("GIVEUP_REASON_IMG", "GIVEUP_REASON", "comment", false);// 포기사유
            gridB.setColIconify("SETTLE_RMK_IMG", "SETTLE_RMK", "comment", false);		// 선정사유

            gridT.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            gridB.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            gridT._gvo.setColumnProperty("RFQ_CNT", "styles", {numberFormat: "#,###.##"});

            if('${form.autoSearchFlag}' == 'Y') {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if(v.value == '300') { // 견적마감
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                EVF.V('FROM_DATE', '${SFromDate}');
            } else if ('${param.dashBoardFlag}' == 'Y'){
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if(v.value == '300') { // 견적중, 견적마감, 업체선정완료, 부분선정, 품의중
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            } else {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if(v.value == '200' || v.value == '300'|| v.value == '400'|| v.value == '390' ||v.value == '500' ) { // 견적중, 견적마감, 업체선정완료, 부분선정, 품의중
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            }

            doSearch();
        }

        function doSearch() {

            gridB.delAllRow();

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridT]);
            store.load(baseUrl + "rq01020_doSearchT", function () {
                if(gridT.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doClosing() {

            if (gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (gridT.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var confirmFlag = false;
            var rowIds = gridT.getSelRowId();
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') == "100") {	// 이미 유찰되었습니다.
                    return alert("${RQ01_020_016}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "200") {	// 견적 진행중인 건만 변경 가능합니다.
                    return alert("${RQ01_020_007}");
                }
                var vendorArgs = gridT.getCellValue(rowIds[i], 'VENDOR_LIST').split("/");
                if(vendorArgs.length == 2) {
                    if(vendorArgs[0] != vendorArgs[1]) {
                        confirmFlag = true;
                    }
                }
            }

            if(!confirm((confirmFlag ? "${RQ01_020_017}" : "${RQ01_020_008}"))) { return; }

            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.getGridData(gridT, 'sel');
            store.load(baseUrl + 'rq01020_doClosing', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doChangeDeadline() {

            if (gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (gridT.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var rowIds = gridT.getSelRowId();
            var rfqNum; var rfqCnt;
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') == "100") {
                    return alert("${RQ01_020_016}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "200") {
                    return alert("${RQ01_020_007}");
                }
                rfqNum = gridT.getCellValue(rowIds[i], 'RFQ_NUM');
                rfqCnt = gridT.getCellValue(rowIds[i], 'RFQ_CNT');
            }

            var param = {
                'RFQ_NUM': rfqNum,
                'RFQ_CNT': rfqCnt,
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_021", 800, 360, param);
        }

        function validateReRFQ(rfqNum, rfqCnt) {
        	var validate  = true;
            for(var i = 0; i < gridT.getRowCount(); i++){
                num = gridT.getCellValue(i, 'RFQ_NUM');
                cnt = gridT.getCellValue(i, 'RFQ_CNT');
              /*   console.log("num:"+num+"  cnt:"+cnt+"  rfqNum:"+rfqNum+"  rfqCnt:"+rfqCnt); */
                if(rfqNum==num && Number(cnt) > Number(rfqCnt)){
                	validate = false;
                }
            }
            return validate;
        }

        // 재견적
        function doReRFQ() {

            if(gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if(gridT.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var rfqNum = ""; var rfqCnt = ""; var rfqType = "";
            var rowIds = gridT.getSelRowId();
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if((gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "390" && gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "300")) {
                    return alert("${RQ01_020_030}");
                }
                if(gridT.getCellValue(eventRow, 'OPEN_DATE') == '' || gridT.getCellValue(eventRow, 'OPEN_DATE') == null) {
                    return alert("${RQ01_020_052}");
                }

                rfqNum = gridT.getCellValue(rowIds[i], 'RFQ_NUM');
                rfqCnt = gridT.getCellValue(rowIds[i], 'RFQ_CNT');
                rfqType = gridT.getCellValue(rowIds[i], 'RFQ_TYPE');
                if(!validateReRFQ(rfqNum,rfqCnt)){
                    return alert("${RQ01_020_039}");
                }
            }

            var param = {
                RFQ_NUM : rfqNum,
                RFQ_CNT : rfqCnt,
                ITEM_CD_STR: "",
                'RFQ_TYPE' : rfqType,
                'sendType' : "R", // 재견적
                'callBackFunction' : "doReSendRFQ",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_011", 1000, 850, param);
        }

        // 재견적 Callback
        function doReSendRFQ(dataJsonStr) {

            var rfqData = JSON.parse(dataJsonStr);
            for(idx in rfqData) {
                EVF.C("RFQ_NUM").setValue(rfqData[idx].RFQ_NUM);
                EVF.C("NEW_RFQ_CNT").setValue(rfqData[idx].NEW_RFQ_CNT);
                EVF.C("ORI_RFQ_CNT").setValue(rfqData[idx].ORI_RFQ_CNT);
                EVF.C("RFQ_TYPE").setValue(rfqData[idx].RFQ_TYPE);
                EVF.C("VENDOR_LIST").setValue(rfqData[idx].VENDOR_LIST);
                EVF.C("F_RFQ_SUBJECT").setValue(rfqData[idx].RFQ_SUBJECT);
                EVF.C("VENDOR_OPEN_TYPE").setValue(rfqData[idx].VENDOR_OPEN_TYPE);
                EVF.C("RFQ_CLOSE_DATE").setValue(rfqData[idx].RFQ_CLOSE_DATE);
                EVF.C("RFQ_CLOSE_HOUR").setValue(rfqData[idx].RFQ_CLOSE_HOUR);
                EVF.C("RFQ_CLOSE_MIN").setValue(rfqData[idx].RFQ_CLOSE_MIN);
                EVF.C("DEAL_TYPE").setValue(rfqData[idx].DEAL_TYPE);
                EVF.C("CONT_START_DATE").setValue(rfqData[idx].CONT_START_DATE);
                EVF.C("CONT_END_DATE").setValue(rfqData[idx].CONT_END_DATE);
                EVF.C("RMK_TEXT").setValue(rfqData[idx].RMK_TEXT);
                EVF.C("ATT_FILE_NUM").setValue(rfqData[idx].ATT_FILE_NUM);
                EVF.C("OPTION_RFQ_REASON").setValue(rfqData[idx].OPTION_RFQ_REASON);
                EVF.C("DELY_EXPECT_REGION").setValue(rfqData[idx].DELY_EXPECT_REGION);
                EVF.C("signStatus").setValue(rfqData[idx].signStatus); // 임시저장(T), 협력사전송(E)
            }

            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.getGridData(gridT, 'sel');
            store.setParameter("sendType", "R");
            store.load("/evermp/RQ01/RQ0101/rq01010_doReSendRFQ", function() {
                alert(this.getResponseMessage());
                EVF.C("RFQ_NUM").setValue("");
                doSearch();
            });
        }

        function doSubstituteWrite() {

            if (gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (gridT.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var rowIds = gridT.getSelRowId();
            var rfqNum; var rfqCnt; var rfqSubject;
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') == "100") {
                    return alert("${RQ01_020_016}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "200") {
                    return alert("${RQ01_020_010}");
                }
                rfqNum = gridT.getCellValue(rowIds[i], 'RFQ_NUM');
                rfqCnt = gridT.getCellValue(rowIds[i], 'RFQ_CNT');
                rfqSubject = gridT.getCellValue(rowIds[i], 'RFQ_SUBJECT');
            }

            var param = {
                'RFQ_NUM': rfqNum,
                'RFQ_CNT': rfqCnt,
                'RFQ_SUBJECT': rfqSubject,
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_022", 1100, 700, param);
        }

     // 공급사 선정 취소
        function doChoiceCancel() {
            if(EVF.isEmpty(rfqNum) || EVF.isEmpty(rfqCnt)) {
                return alert("${RQ01_020_045}");
            }
            if(progressCd != "400" && progressCd != "390") {
            	return alert("${RQ01_020_046}");
            }


            if(!confirm("${RQ01_020_047}")) { return; }
            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'all');
            store.setParameter("RFQ_NUM", rfqNum);
            store.setParameter("RFQ_CNT", rfqCnt);
            store.load(baseUrl + 'rq01020_doChoiceCancel', function() {
                alert(this.getResponseMessage());
                doSearch();
            });



        }
    	//개찰
		function doQtOpen() {
			if(EVF.isEmpty(rfqNum) || EVF.isEmpty(rfqCnt)) {
	           return alert("${RQ01_020_045}");
	        }
			var rowIds = gridT.getSelRowId();
	           for(var i in rowIds) {
	               if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
	                   return alert("${RQ01_020_029}");
	               }
	               if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') == "100") {
	                   return alert("${RQ01_020_016}");
	               }
	               if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "300") {
	                   return alert("${RQ01_020_050}");
	               }
	                if( gridT.getCellValue(rowIds[i], 'OPEN_DATE') !=  '') {
	                   return alert("${RQ01_020_051}");
	               }
	          }
			if(!confirm("${RQ01_020_049}")) { return; }

			var store = new EVF.Store();
	        store.setGrid([gridB]);
	        store.getGridData(gridB, 'all');
	        store.setParameter("RFQ_NUM", rfqNum);
	        store.setParameter("RFQ_CNT", rfqCnt);
			store.load(baseUrl + 'rq01020_doQtOpen', function(){
				EVF.alert(this.getResponseMessage(),function(){
				doSearch();
				});
			});
		}

        // 공급사 선정
        function doChoiceVendor() {

            if(EVF.isEmpty(rfqNum) || EVF.isEmpty(rfqCnt)) {
                return alert("${RQ01_020_020}");
            }
            if(!gridB.validate().flag) { return EVF.alert(gridB.validate().msg); }

            if(gridT.getCellValue(eventRow, 'OPEN_DATE') == '' || gridT.getCellValue(eventRow, 'OPEN_DATE') == null) {
                return alert("${RQ01_020_052}");
            }

            if(gridT.getCellValue(eventRow, 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                return alert("${RQ01_020_029}");
            }

            if(progressCd == "100") { return alert("${RQ01_020_016}"); }
            if(progressCd == "200") { return alert("${RQ01_020_018}"); }
            if(progressCd == "400" || progressCd > "450") { return alert("${RQ01_020_019}"); }
            if(progressCd == "390") { return alert("${RQ01_020_036}"); }


            var partSettleFlag = false;
            var rowIds = gridB.getAllRowId();
            var settleCnt = 0;
            for(var i in rowIds) {

                var iRFQ_NUM = gridB.getCellValue(rowIds[i], 'RFQ_NUM');
                var iRFQ_CNT = gridB.getCellValue(rowIds[i], 'RFQ_CNT');
                var iRFQ_SQ = gridB.getCellValue(rowIds[i], 'RFQ_SQ');
                if (gridB.getCellValue(rowIds[i], 'GIVEUP_FLAG') == '1' ) {
                    continue;
                }
                if (gridB.getCellValue(rowIds[i], 'SETTLE_FLAG') == '1' ) {
                    settleCnt++;
                }

                if(gridB.getCellValue(rowIds[i], 'SETTLE_FLAG') == '' || gridB.getCellValue(rowIds[i], 'SETTLE_FLAG') == null ){
                    return alert("${RQ01_020_041}");
                }

                if (gridB.getCellValue(rowIds[i], 'SETTLE_FLAG') === "1" && gridB.getCellValue(rowIds[i], 'SEND_FLAG_NM') != "제출" ) {
                    return alert("'" + gridB.getCellValue(rowIds[i], 'VENDOR_NM')+ "'" +"${RQ01_020_040}");
                }

                var countAward = 0;
                for(var j in rowIds) {
                    if(gridB.getCellValue(rowIds[j], 'SETTLE_FLAG') === "1"
                        && gridB.getCellValue(rowIds[j], 'RFQ_NUM') === iRFQ_NUM
                        && gridB.getCellValue(rowIds[j], 'RFQ_CNT') === iRFQ_CNT
                        && gridB.getCellValue(rowIds[j], 'RFQ_SQ') === iRFQ_SQ){
                        countAward++;
                    }
                }
                if (countAward > 1) { return alert("${RQ01_020_021}"); }
                if (countAward == 0) { partSettleFlag = true; }

                for(var j in rowIds) {
                    if(gridB.getCellValue(rowIds[j], 'SETTLE_FLAG') === "1" && gridB.getCellValue(rowIds[j], 'SETTLE_POSSIBLE_FLAG') != "Y"
                        && EVF.isEmpty(gridB.getCellValue(rowIds[j], 'SETTLE_RMK'))) {
                        return alert("'" + gridB.getCellValue(rowIds[j], 'VENDOR_NM') + "'" + "${RQ01_020_022}");
                    }
                }

            }
            if(settleCnt == 0) { return alert("${RQ01_020_023}"); }

            if(!confirm((partSettleFlag ? "${RQ01_020_024}" : "${RQ01_020_025}"))) { return; }
            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'all');
            store.setParameter("RFQ_NUM", rfqNum);
            store.setParameter("RFQ_CNT", rfqCnt);
            store.setParameter("partSettleFlag", partSettleFlag);
            store.load(baseUrl + 'rq01020_doChoiceVendor', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doContract() {

            if (gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if (gridT.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var rfqSubject = "";
            var searchType = "";
            var rowIds = gridT.getSelRowId();
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if(gridT.getCellValue(rowIds[i], 'CONT_POSSIBLE_FLAG') != "Y" &&gridT.getCellValue(rowIds[i], 'SIGN_STATUS') !="T") {
                    return alert("${RQ01_020_028}");
                }
                rfqNum = gridT.getCellValue(rowIds[i], 'RFQ_NUM');
                rfqCnt = gridT.getCellValue(rowIds[i], 'RFQ_CNT');
                rfqSubject = gridT.getCellValue(rowIds[i], 'RFQ_SUBJECT');
                searchType = (gridT.getCellValue(rowIds[i], 'PROGRESS_CD') == "999" ? "NEO" : "RFQ");
                progressCd = gridT.getCellValue(rowIds[i], 'PROGRESS_CD');

				if(progressCd == '390'){
                	if(validateReRFQ(rfqNum,rfqCnt)){
                	    return alert("${RQ01_020_053}");
                	}
                }
            }
            var param = {
                'RFQ_NUM': rfqNum,
                'RFQ_CNT': rfqCnt,
                'RFQ_SUBJECT': rfqSubject,
                'SEARCH_TYPE': searchType,
                'EXEC_NUM': "",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_023", 1500, 900, param);
        }

        // 견적 취소
        function doDelete() {
            if(gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = gridT.getSelRowId();
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "200") {
                    return alert("${RQ01_020_027}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "200" && gridT.getCellValue(rowIds[i],'SUBMIT_VENDOR_CNT') != "0"){
                    return alert("${RQ01_020_032}");
                }
                if(gridT.getCellValue(rowIds[i], 'DELETE_POSSIBLE_FLAG') == "N") {
                    return alert("${RQ01_020_032}");
                }
            }

            if(!confirm('${msg.M0013}')) { return; }

            var param = {
                title: "${RQ01_020_038 }",
                message: "",
                callbackFunction: 'setDelTransaction'
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function setDelTransaction(data) {

            if(EVF.isEmpty(data.message)) { return alert("${RQ01_020_034}"); }

            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.getGridData(gridT, 'sel');
            store.setParameter("MOVE_REASON", data.message);
            store.load(baseUrl + 'rq01020_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 유찰
        function doFailRFQ() {

            if(gridT.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = gridT.getSelRowId();
            for(var i in rowIds) {
                if(gridT.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_020_029}");
                }
                if(gridT.getCellValue(eventRow, 'OPEN_DATE') == '' || gridT.getCellValue(eventRow, 'OPEN_DATE') == null) {
                    return alert("${RQ01_020_052}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') == "100") {
                    return alert("${RQ01_020_016}");
                }
                if(gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != "300") {
                    return alert("${RQ01_020_014}");
                }
            }

            if(!confirm('${RQ01_020_011}')) { return; }

            var param = {
                title: "${RQ01_020_015 }",
                message: "",
                callbackFunction: 'setRMKnTransaction'
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function setRMKnTransaction(data) {

            if(EVF.isEmpty(data.message)) { return alert("${RQ01_020_012}"); }

            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.getGridData(gridT, 'sel');
            store.setParameter("MOVE_REASON", data.message);
            store.load(baseUrl + 'rq01020_doFailRFQ', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function setRMKG(data) {
            gridB.setCellValue(data.rowId, 'SETTLE_RMK', data.message);
        }

        function fileAttachPopupCallback(rowId, fileId, fileCount) {
            gridB.setCellValue(rowId, 'QTA_FILE_CNT', fileCount);
            gridB.setCellValue(rowId, 'QTA_FILE_NUM', fileId);
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
        }

        function cleanCustCd() {
            EVF.C("CUST_CD").setValue("");
        }

        function searchRegUserId() {

            if(EVF.isEmpty(EVF.C("CUST_CD").getValue())) { return alert("${RQ01_020_031}"); }

            var param = {
                "custCd" : EVF.C("CUST_CD").getValue(),
                callBackFunction : "selectRegUserId"
            };
            everPopup.openCommonPopup(param, 'SP0083');
        }

        function selectRegUserId(dataJsonArray) {
            EVF.C("CUST_REG_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CUST_REG_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function cleanRegUserId() {
            EVF.C("CUST_REG_USER_ID").setValue("");
        }

        function openVendorListPopup(rfqNum, rfqCnt) {
            var param = {
                RFQ_NUM: rfqNum,
                RFQ_CNT: rfqCnt,
                detailView: true
            };
            everPopup.openPopupByScreenId("RQ01_025", 800, 400, param);
        }

        function doPrint() {

            var checkType = this.getData();
            if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rfqList = [];
            var rowIds = gridT.getSelRowId();
            for( var i in rowIds ) {
                if(checkType == 'P' && gridT.getCellValue(rowIds[i], 'PROGRESS_CD') != '600') {
                    return alert("${RQ01_020_035}"); // 계약완료된 건에 대해 견적서 출력이 가능합니다.
                }
                rfqList.push({
                    'RFQ_NUM': gridT.getCellValue(rowIds[i], 'RFQ_NUM'),
                    'RFQ_CNT': gridT.getCellValue(rowIds[i], 'RFQ_CNT')
                });
            }

            var param = {
                RFQ_LIST : JSON.stringify(rfqList)
            };

            if(checkType == 'R') {
                everPopup.openPopupByScreenId("PRT_010", 976, 800, param);
            } else {
                everPopup.openPopupByScreenId("PRT_021", 976, 800, param);
            }
        }

        function doPrintOZ() {

            var checkType = this.getData();
            if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var searchParam = "'";
            var rows  = gridT.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                searchParam = searchParam + rows[i].RFQ_NUM + "','";
            }
            if(searchParam.length > 0) {
                searchParam = searchParam.substring(0, searchParam.length - 2);
            }

            var localFlag = ${localFlag};
            var host_info;
            var oz80_url;

            if(localFlag) {
                host_info = location.protocol + "//" + location.hostname + ":" + location.port;
                oz80_url = location.protocol + "//" + location.hostname + ":" + "7070/oz80";
            } else {
                host_info = location.protocol + "//" + location.hostname;
                oz80_url = location.protocol + "//" + location.hostname + ":" + "7071/oz80";
            }


            var ozIdx = 0; var itemArgs = []; var custArgs = [];
            var store = new EVF.Store();
            store.setParameter("searchParam", searchParam);
            store.load(baseUrl + 'rq01020_doSearchOzParam', function() {
                var ozParamArgs = JSON.parse(this.getParameter("ozParam"));
                for(idx in ozParamArgs) {
                    itemArgs[ozIdx] = ozParamArgs[idx].RFQ_NUM_CNT_SQ;
                    custArgs[ozIdx] = ozParamArgs[idx].CUST_NM;
                    ozIdx++;
                }

                var param = {
                     RFQ_NUM_CNT_SQ : JSON.stringify(itemArgs)
                    ,CUST_NMS : JSON.stringify(custArgs)
                    ,HOST_INFO: oz80_url
                    ,OZ80_URL: oz80_url
                };

                var url = oz80_url + "/ozhviewer/SMP_SourcingEstimate.jsp";
                everPopup.openWindowPopup(url, 1000, 700, param, "", true);
            });
        }

    </script>

    <e:window id="RQ01_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="" />
            <e:inputHidden id="ORI_RFQ_CNT" name="ORI_RFQ_CNT" value="" />
            <e:inputHidden id="NEW_RFQ_CNT" name="NEW_RFQ_CNT" value="" />
            <e:inputHidden id="RFQ_TYPE" name="RFQ_TYPE" value="" />
            <e:inputHidden id="VENDOR_LIST" name="VENDOR_LIST" value="" />
            <e:inputHidden id="F_RFQ_SUBJECT" name="F_RFQ_SUBJECT" value="" />
            <e:inputHidden id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="" />
            <e:inputHidden id="RFQ_CLOSE_DATE" name="RFQ_CLOSE_DATE" value="" />
            <e:inputHidden id="RFQ_CLOSE_HOUR" name="RFQ_CLOSE_HOUR" value="" />
            <e:inputHidden id="RFQ_CLOSE_MIN" name="RFQ_CLOSE_MIN" value="" />
            <e:inputHidden id="DEAL_TYPE" name="DEAL_TYPE" value="" />
            <e:inputHidden id="CONT_START_DATE" name="CONT_START_DATE" value="" />
            <e:inputHidden id="CONT_END_DATE" name="CONT_END_DATE" value="" />
            <e:inputHidden id="RMK_TEXT" name="RMK_TEXT" value="" />
            <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="" />
            <e:inputHidden id="ATT_FILE_NUM" name="ATT_FILE_NUM" value="" />
            <e:inputHidden id="OPTION_RFQ_REASON" name="OPTION_RFQ_REASON" value="" />
            <e:inputHidden id="DELY_EXPECT_REGION" name="DELY_EXPECT_REGION" value="" />
            <e:inputHidden id="signStatus" name="signStatus" value="" />	<!-- T:임시저장, E:협력사전송 -->

            <e:row>
                <e:label for="COMBO_BOX">
                    <e:select id="COMBO_BOX" name="COMBO_BOX" usePlaceHolder="false" width="99" required="${form_COMBO_BOX_R}" disabled="${form_COMBO_BOX_D }" readOnly="${form_COMBO_BOX_RO}" >
                        <e:option text="${RQ01_020_002}" value="S">S</e:option>
                        <e:option text="${RQ01_020_001}" value="R">R</e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="${fromDate }" toDate="TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="${toDate }" fromDate="FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
				<e:label for="RFQ_SUBJECT" title="${form_RFQ_SUBJECT_N}" />
				<e:field>
                    <e:inputText id="RFQ_SUBJECT" name="RFQ_SUBJECT" value="" width="${form_RFQ_SUBJECT_W}" maxLength="${form_RFQ_SUBJECT_M}" disabled="${form_RFQ_SUBJECT_D}" readOnly="${form_RFQ_SUBJECT_RO}" required="${form_RFQ_SUBJECT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId }" options="${ctrlUserIdOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="btn" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Closing" name="Closing" label="${Closing_N}" disabled="${Closing_D}" visible="${Closing_V}" onClick="doClosing" />
            <e:button id="ChangeDeadline" name="ChangeDeadline" label="${ChangeDeadline_N}" disabled="${ChangeDeadline_D}" visible="${ChangeDeadline_V}" onClick="doChangeDeadline" />
            <e:button id="SubstituteWrite" name="SubstituteWrite" label="${SubstituteWrite_N}" disabled="${SubstituteWrite_D}" visible="${SubstituteWrite_V}" onClick="doSubstituteWrite" />
            <e:button id="Delete" name="Delete" label="${Delete_N}" disabled="${Delete_D}" visible="${Delete_V}" onClick="doDelete" />
			<%--
			<e:button id="doPrintRequest" name="doPrintRequest" label="${doPrintRequest_N}" onClick="doPrint" disabled="${doPrintRequest_D}" visible="${doPrintRequest_V}" data="R"/>
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}" data="P"/>
            <e:button id="doPrintOZ" name="doPrintOZ" label="${doPrintOZ_N}" onClick="doPrintOZ" disabled="${doPrintOZ_D}" visible="${doPrintOZ_V}" data="P"/>
 			--%>
        </e:buttonBar>
        <e:gridPanel id="gridT" name="gridT" width="100%" height="250px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<e:buttonBar id="btn1" title="${RQ01_020_CAPTION}" align="right" width="100%">
			<e:button id="doQtOpen" name="doQtOpen" label="${doQtOpen_N}" onClick="doQtOpen" disabled="${doQtOpen_D}" visible="${doQtOpen_V}"/>
            <e:button id="ChoiceVendor" name="ChoiceVendor" label="${ChoiceVendor_N}" disabled="${ChoiceVendor_D}" visible="${ChoiceVendor_V}" onClick="doChoiceVendor" />
			<e:button id="ChoiceCancel" name="ChoiceCancel" label="${ChoiceCancel_N}" onClick="doChoiceCancel" disabled="${ChoiceCancel_D}" visible="${ChoiceCancel_V}"/>
            <e:button id="Contract" name="Contract" label="${Contract_N}" disabled="${Contract_D}" visible="${Contract_V}" onClick="doContract" />
            <e:button id="ReRFQ" name="ReRFQ" label="${ReRFQ_N}" disabled="${ReRFQ_D}" visible="${ReRFQ_V}" onClick="doReRFQ" />
            <e:button id="FailRFQ" name="FailRFQ" label="${FailRFQ_N}" disabled="${FailRFQ_D}" visible="${FailRFQ_V}" onClick="doFailRFQ" />
        </e:buttonBar>
        <e:gridPanel id="gridB" name="gridB" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>