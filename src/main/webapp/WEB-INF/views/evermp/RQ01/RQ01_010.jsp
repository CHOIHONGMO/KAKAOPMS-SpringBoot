<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/RQ01/RQ0101/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_REQ_NO') {
                	var param = {
        	    		CUST_CD : grid.getCellValue(rowId, 'CUST_CD'),
        	    		ITEM_REQ_NO : grid.getCellValue(rowId, 'ITEM_REQ_NO'),
        	    		ITEM_REQ_SEQ : grid.getCellValue(rowId, 'ITEM_REQ_SEQ'),
        	    		'detailView': true,
        	    		'popupFlag': true
        			};
                    everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
                }
                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'CUST_NM') {
                    if(grid.getCellValue(rowId, 'CUST_CD') != "1000") {
                        var param = {
                            'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                            'detailView': true,
                            'popupFlag': true
                        };
                        everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                    }
                }
                if(colId == 'CUST_REG_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, 'CUST_REG_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'SG_CTRL_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'CMS_CTRL_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, 'CMS_CTRL_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'CMS_REMARK_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "CMS_REMARK"))) {
                        var param = {
                            title: "${RQ01_010_001}",
                            message: grid.getCellValue(rowId, 'CMS_REMARK')
                        };
                        everPopup.openModalPopup('/common/popup/common_text_view/view', 500, 300, param);
                    }
                }
                if(colId == 'SG_CTRL_CHANGE_RMK_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "SG_CTRL_CHANGE_RMK"))) {
                        var param = {
                            title: "${RQ01_010_002}",
                            message: grid.getCellValue(rowId, 'SG_CTRL_CHANGE_RMK')
                        };
                        everPopup.openModalPopup('/common/popup/common_text_view/view', 500, 300, param);
                    }
                }
                if(colId == 'NWRQ_ATTACH_FILE_CNT') {
                    var param = {
                        havePermission: false,
                        attFileNum: grid.getCellValue(rowId, 'NWRQ_ATTACH_FILE_NO'),
                        rowId: rowId,
                        callBackFunction: '',
                        bizType: 'VENDOR',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'RETURN_REASON_IMG') {
                    var param = {
                        title: "${RQ01_010_011 }",
                        message: grid.getCellValue(rowId, 'RETURN_REASON'),
                        callbackFunction: 'setRMKR',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                if(colId == 'RFQ_NUM') {

               	    var hdnm = grid.getCellValue(rowId, 'HD_PROGRESS_CD');	// 견적 진행상태
               	    if(hdnm==''){
               	    	return;
               	    }
               	    var rfqnum = grid.getCellValue(rowId, 'RFQ_NUM');
            	    var rfqcnt = grid.getCellValue(rowId, 'RFQ_CNT');
            	    if(rfqnum=='') return;
                	for(idx = 0; idx < grid.getRowCount(); idx++){
                   	    if( grid.getCellValue(idx, 'RFQ_NUM')==rfqnum && grid.getCellValue(idx, 'RFQ_CNT')==rfqcnt){
        					grid.checkRow( idx, true );
                   	    }
                   	    else{
        					grid.checkRow( idx,false );
                   	    }
                	}
                    var param = {
                            'ITEM_CD_STR' : getItemCdStr(),
                            'RFQ_NUM'  : rfqnum,
                            'RFQ_CNT'  : rfqcnt,
                            'RFQ_TYPE' : "100",		// 고객사 요청
                            'sendType' : "E",		// 기존 견적서 수정
                            'callBackFunction' : "doSendRFQ",
                            'detailView': (hdnm == '150') ? false : true,	// 견적진행상태(150:작성중)
                            'popupFlag': true
                        };
                     everPopup.openPopupByScreenId("RQ01_011", 1000, 850, param);
                }
            });

            /*
            EVF.C('PROGRESS_CD').removeOption('T');		// 등록요청
            EVF.C('PROGRESS_CD').removeOption('R');		// 요청반려
            EVF.C('PROGRESS_CD').removeOption('100');	// 견적요청
            EVF.C('PROGRESS_CD').removeOption('110');	// 견적요청 반려
             */

            grid.setColIconify("CMS_REMARK_IMG", "CMS_REMARK", "comment", false);
            grid.setColIconify("SG_CTRL_CHANGE_RMK_IMG", "SG_CTRL_CHANGE_RMK", "comment", false);
            grid.setColIconify("RETURN_REASON_IMG", "RETURN_REASON", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            /* Column 그룹
            grid.setColGroup([{
                "groupName": "견적의뢰정보",
                "columns": [ "REQ_DATE", "HD_PROGRESS_CD", "RFQ_NUM", "RFQ_CNT", "RFQ_SUBJECT" ]
            }],55);
             */

            // 진행상태 자동 체크 (300: 접수, 400: 소싱중)

/*
            var chkName = "";
            $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                if(v.value == '150' || v.value == '200') {
                    chkName += v.title + ", ";
                    v.checked = true;
                }
            });
            $('#HD_PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
*/
            if('${form.autoSearchFlag}' == 'Y') {
                EVF.V('REQUEST_FROM_DATE', '${SFromDate}');
                doSearch();
            }
        }

        // 상품담당자 이관
        function doTransferCtrl() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            if(EVF.isEmpty(EVF.C("sSG_CTRL_USER_ID").getValue())) { return alert("${RQ01_010_007}"); }

            var changeRmk = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(${ses.superUserFlag != '1'}) {
                    if(grid.getCellValue(rowIds[i], 'SG_CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                        return alert("${RQ01_010_003}");
                    }
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "300") {
                    return alert("${RQ01_010_005}");
                }
                changeRmk = grid.getCellValue(rowIds[i], 'SG_CTRL_CHANGE_RMK');
            }

            if(!confirm('${RQ01_010_004}')) { return; }

            var param = {
                title: "${RQ01_010_002 }",
                message: changeRmk,
                callbackFunction: 'setRMK',
                rowId: 0
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function setRMK(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${RQ01_010_009}");
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("sSG_CTRL_USER_ID", EVF.C("sSG_CTRL_USER_ID").getValue());
            store.setParameter("SG_CTRL_CHANGE_RMK", data.message);
            store.load(baseUrl + 'rq01010_doTransferCtrl', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "rq01010_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // 견적요청서 작성시 요청할 품목 선택
        function getItemCdStr()
        {
        	var itemCdStr="";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
            	itemCdStr += grid.getCellValue(rowIds[i], 'ITEM_CD') + ",";
            }
            if(itemCdStr.length > 0) {
            	itemCdStr = itemCdStr.substring(0, itemCdStr.length - 1);
            }
            return itemCdStr;
        }

        // 견적의뢰서 작성
        function doRegRFQ() {

            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var custCd  = "";
            var plantCd = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
            	custCd  = grid.getCellValue(rowIds[0], 'CUST_CD');
            	plantCd = grid.getCellValue(rowIds[0], 'PLANT_CD');

                if(grid.getCellValue(rowIds[i], 'SG_CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_010_003}");
                }
                // 동일한 고객 경우에만 견적의뢰 가능
                if(custCd != grid.getCellValue(rowIds[i], 'CUST_CD')) {
                    return alert("${RQ01_010_016}");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "300") {
                    return alert("${RQ01_010_014}");
                }
                if(grid.getCellValue(rowIds[i], 'HD_PROGRESS_CD') == "450") {
                    return alert("${RQ01_010_005}");
                }
            }

            var param = {
                ITEM_CD_STR : getItemCdStr(),
                RFQ_NUM: grid.getCellValue(rowIds[i], 'RFQ_NUM'),
                RFQ_CNT: grid.getCellValue(rowIds[i], 'RFQ_CNT'),
                RFQ_TYPE: "100",	// 고객사요청
                sendType: "F",		// 신규 견적작성
                callBackFunction: "doSendRFQ",
                detailView: false,
                popupFlag: true
            };
            everPopup.openPopupByScreenId("RQ01_011", 1000, 850, param);
        }

        // 견적의뢰서 저장 및 협력사 전송
        function doSendRFQ(dataJsonStr) {

            var rfqData = JSON.parse(dataJsonStr);
            for(idx in rfqData) {
                EVF.C("RFQ_NUM").setValue(rfqData[idx].RFQ_NUM);
                EVF.C("ORI_RFQ_CNT").setValue(rfqData[idx].ORI_RFQ_CNT);
                EVF.C("RFQ_TYPE").setValue(rfqData[idx].RFQ_TYPE);
                EVF.C("VENDOR_LIST").setValue(rfqData[idx].VENDOR_LIST);
                EVF.C("RFQ_SUBJECT").setValue(rfqData[idx].RFQ_SUBJECT);
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
                EVF.C("sendType").setValue(rfqData[idx].sendType);
                EVF.C("signStatus").setValue(rfqData[idx].signStatus); // 임시저장(T), 협력사전송(E)
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("sendType", rfqData[idx].sendType);
            store.load(baseUrl + 'rq01010_doSendRFQ', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 접수취소
        function doReturnItem() {

            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'SG_CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_010_003}");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "300") {
                    return alert("${RQ01_010_005}");
                }
                if(grid.getCellValue(rowIds[i], 'HD_PROGRESS_CD') == "450" || grid.getCellValue(rowIds[i], 'HD_PROGRESS_CD') == "100") {
                    return alert("${RQ01_010_005}");
                }
            }

            if(!confirm('${RQ01_010_008}')) { return; }
            var param = {
                title: "${RQ01_010_011 }",
                message: "",
                callbackFunction: 'setRMKnTransaction'
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function setRMKnTransaction(data) {

            if(EVF.isEmpty(data.message)) { return alert("${RQ01_010_012}"); }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("RETURN_REASON", data.message);
            store.load(baseUrl + 'rq01010_doReturnItem', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function setRMKR(data) {
            grid.setCellValue(data.rowId, 'RETURN_REASON', data.message);
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
        }

        function searchRegUserId() {

            if(EVF.isEmpty(EVF.C("CUST_CD").getValue())) {
            	return alert("${RQ01_010_015}");
            }

            var param = {
                callBackFunction : "callBackRegUserId",
                custCd : EVF.V("CUST_CD"),
                plantCd: EVF.V("ADD_PLANT_CD")
            };
            everPopup.openCommonPopup(param, 'SP0083');
        }

        function callBackRegUserId(dataJsonArray) {
            EVF.C("REG_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("REG_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function onSearchPlant() {
    		if( EVF.V("CUST_CD") == "" ) return alert("${RQ01_010_015}");
    		var param = {
    	           callBackFunction : "callBackPlant",
    	           custCd: EVF.V("CUST_CD")
    		};
    		everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("ADD_PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("ADD_PLANT_NM").setValue(jsondata.PLANT_NM);
        }

    </script>

    <e:window id="RQ01_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="" />
            <e:inputHidden id="ORI_RFQ_CNT" name="ORI_RFQ_CNT" value="" />
            <e:inputHidden id="NEW_RFQ_CNT" name="NEW_RFQ_CNT" value="" />
            <e:inputHidden id="RFQ_TYPE" name="RFQ_TYPE" value="" />
            <e:inputHidden id="VENDOR_LIST" name="VENDOR_LIST" value="" />
            <e:inputHidden id="RFQ_SUBJECT" name="RFQ_SUBJECT" value="" />
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
            <e:inputHidden id="sendType" name="sendType" value="" />	<!-- F:최초등록, E:재작성(수정), R:재견적 -->
            <e:inputHidden id="signStatus" name="signStatus" value="" />	<!-- T:임시저장, E:협력사전송 -->

            <e:row>
            	<e:label for="REQUEST_FROM_DATE" title="${form_REQUEST_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REQUEST_FROM_DATE" name="REQUEST_FROM_DATE" value="${fromDate }" toDate="REQUEST_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_REQUEST_FROM_DATE_R}" disabled="${form_REQUEST_FROM_DATE_D}" readOnly="${form_REQUEST_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="REQUEST_TO_DATE" name="REQUEST_TO_DATE" value="${toDate }" fromDate="REQUEST_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_REQUEST_TO_DATE_R}" disabled="${form_REQUEST_TO_DATE_D}" readOnly="${form_REQUEST_TO_DATE_RO}" />
                </e:field>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="ADD_PLANT_CD" title="${form_ADD_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="ADD_PLANT_CD" name="ADD_PLANT_CD" value="" width="40%" maxLength="${form_ADD_PLANT_CD_M}" disabled="${form_ADD_PLANT_CD_D}" readOnly="${form_ADD_PLANT_CD_RO}" required="${form_ADD_PLANT_CD_R}" onIconClick="onSearchPlant" />
                    <e:inputText id="ADD_PLANT_NM" name="ADD_PLANT_NM" value="" width="60%" maxLength="${form_ADD_PLANT_NM_M}" disabled="${form_ADD_PLANT_NM_D}" readOnly="${form_ADD_PLANT_NM_RO}" required="${form_ADD_DEPT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REG_USER_ID" title="${form_REG_USER_ID_N}"/>
                <e:field>
                    <e:search id="REG_USER_ID" name="REG_USER_ID" value="" width="40%" maxLength="${form_REG_USER_ID_M}" onIconClick="searchRegUserId" disabled="${form_REG_USER_ID_D}" readOnly="${form_REG_USER_ID_RO}" required="${form_REG_USER_ID_R}" />
                    <e:inputText id="REG_USER_NM" name="REG_USER_NM" value="" width="60%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" />
                </e:field>
                <e:label for="HD_PROGRESS_CD" title="${form_HD_PROGRESS_CD_N}"/>
                <e:field colSpan="3">
                    <e:select id="HD_PROGRESS_CD" name="HD_PROGRESS_CD" value="" options="${hdProgressCdOptions}" width="${form_HD_PROGRESS_CD_W}" disabled="${form_HD_PROGRESS_CD_D}" readOnly="${form_HD_PROGRESS_CD_RO}" required="${form_HD_PROGRESS_CD_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${ses.userId}" options="${sgCtrlUserIdOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
				<e:label for="ITEM_REQ_NO" title="${form_ITEM_REQ_NO_N}" />
                <e:field>
                    <e:inputText id="ITEM_REQ_NO" name="ITEM_REQ_NO" value="" width="${form_ITEM_REQ_NO_W}" maxLength="${form_ITEM_REQ_NO_M}" disabled="${form_ITEM_REQ_NO_D}" readOnly="${form_ITEM_REQ_NO_RO}" required="${form_ITEM_REQ_NO_R}" />
                </e:field>
                <e:label for="ITEM_DESC_SPEC" title="${form_ITEM_DESC_SPEC_N}"/>
                <e:field >
                    <e:inputText id="ITEM_DESC_SPEC" name="ITEM_DESC_SPEC" value="" width="${form_ITEM_DESC_SPEC_W}" maxLength="${form_ITEM_DESC_SPEC_M}" disabled="${form_ITEM_DESC_SPEC_D}" readOnly="${form_ITEM_DESC_SPEC_RO}" required="${form_ITEM_DESC_SPEC_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
        	<!-- 표준화담당자 이관 -->
        	<e:text style="font-weight: bold;">●&nbsp;${form_SG_CTRL_USER_NM_N}&nbsp;:&nbsp; </e:text>
            <e:select id="sSG_CTRL_USER_ID" name="sSG_CTRL_USER_ID" value="" options="${sgCtrlUserIdOptions }" width="150px" disabled="${form_sSG_CTRL_USER_ID_D}" readOnly="${form_sSG_CTRL_USER_ID_RO}" required="${form_sSG_CTRL_USER_ID_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
            <e:button id="TransferCtrl" name="TransferCtrl" label="${TransferCtrl_N }" disabled="${TransferCtrl_D }" visible="${TransferCtrl_V}" style="padding-left:3px;" align="left" onClick="doTransferCtrl" />

            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="RegRFQ" name="RegRFQ" label="${RegRFQ_N}" disabled="${RegRFQ_D}" visible="${RegRFQ_V}" onClick="doRegRFQ" />
            <e:button id="ReturnItem" name="ReturnItem" label="${ReturnItem_N}" disabled="${ReturnItem_D}" visible="${ReturnItem_V}" onClick="doReturnItem" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>