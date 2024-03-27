<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BNM1/BNM101/";
        var mngYn = "${ses.mngYn}";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_REQ_NO') {

                	var param = {
        	    		CUST_CD: grid.getCellValue(rowId, 'CUST_CD'),
        	    		ITEM_REQ_NO: grid.getCellValue(rowId, 'ITEM_REQ_NO'),
        	    		ITEM_REQ_SEQ: grid.getCellValue(rowId, 'ITEM_REQ_SEQ'),
        	    		detailView: true,
        	    		popupFlag: true
        			};
                    everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
                }
                if(colId === "ITEM_CD") {
                    if(value !== "" && Number(grid.getCellValue(rowId, 'PROGRESS_CD')) >= '500'){	// 합의완료(500) 이상인 경우에만 품목 상세정보 팝업
                        param = {
                                ITEM_CD: grid.getCellValue(rowId, 'ITEM_CD'),
                                popupFlag: true,
                                detailView: false
                            };
                            everPopup.im03_014open(param);
						return;


                        var param = {
                            ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                            CUST_CD : grid.getCellValue(rowId, "CUST_CD"),
                            APPLY_COM : grid.getCellValue(rowId, "APPLY_COM"),
                            CONT_NO : grid.getCellValue(rowId, "CONT_NO"),
                            CONT_SEQ : grid.getCellValue(rowId, "CONT_SEQ"),
                            CART_YN : true,
                            popupFlag: true,
                            detailView: true
                        };
                        everPopup.im03_014open(param);
                    }
                }
                // 고객사 전달사항
                if(colId === "SETTLE_RMK") {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "SETTLE_RMK"))) {
                        var param = {
                            title : "${BNM1_030_021}",
                            message : grid.getCellValue(rowId, "SETTLE_RMK"),
                            callbackFunction : "",
                            detailView : true,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                // 반려사유
                if(colId === "SOURCING_REJECT_RMK") {
                    var param = {
                        title : "견적합의 반려사유",
                        message : grid.getCellValue(rowId, "SOURCING_REJECT_RMK"),
                        callbackFunction : "setSourcingRejectRmk",
                        detailView : (grid.getCellValue(rowId, "PROGRESS_CD") == '450') ? false : true,
                        rowId : rowId
                    };
                    var url = "/common/popup/common_text_input/view";
                    everPopup.openModalPopup(url, 500, 320, param);
                }
             	// 의뢰자
                if(colId == 'REQUEST_USER_NM') {
                    if( grid.getCellValue(rowId, 'REQUEST_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'REQUEST_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
             	// 품목담당
                if(colId == 'SG_CTRL_USER_NM') {
                    if( grid.getCellValue(rowId, 'SG_CTRL_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            EVF.C("PROGRESS_CD").removeOption("T");
            EVF.C("PROGRESS_CD").removeOption("R");
            EVF.C("PROGRESS_CD").removeOption("100");
            EVF.C("PROGRESS_CD").removeOption("300");
            EVF.C("PROGRESS_CD").removeOption("400");

            if("${param.autoSearchFlag}" == "Y") {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if(v.value != '') {
                        if("${param.progressCd}" == "ALL") {
                            if (v.value == '450') {
                                chkName += v.title + ", ";
                                v.checked = true;
                            }
                        }
                        if("${param.progressCd}" == "TYPE1") {
                            if (v.value != '500' && v.value != '200' && v.value != '250' && v.value != '400' && v.value != '600') {
                                chkName += v.title + ", ";
                                v.checked = true;
                            }
                        }
                        if("${param.progressCd}" == "TYPE2") {
                            if (v.value == '200') {
                                chkName += v.title + ", ";
                                v.checked = true;
                            }
                        }
                        if ("${param.progressCd}" == "TYPE3") {
                            if (v.value == '400') {
                                chkName += v.title + ", ";
                                v.checked = true;
                            }
                        }
                        if ("${param.progressCd}" == "TYPE4") {
                            if (v.value == '500') {
                                chkName += v.title + ", ";
                                v.checked = true;
                            }
                        }
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));

                EVF.C("ADD_FROM_DATE").setValue("");
                EVF.C("ADD_TO_DATE").setValue("");

                doSearch();
            } else {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '450' || v.value == '500' || v.value == '440') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            }

            if( '${superUserFlag}' != 'true' ) {
                EVF.C('ADD_PLANT_CD').setDisabled(true);
                EVF.C('ADD_PLANT_NM').setDisabled(true);
                if( '${havePermission}' == 'true' ) {
                    EVF.C('DDP_CD').setDisabled(false);// 사업부

                    EVF.C("ADD_USER_ID").setDisabled(false);// 주문자ID
                    EVF.C("ADD_USER_NM").setDisabled(false);// 주문자명
                } else {
                    EVF.C('DDP_CD').setDisabled(true);	// 사업부

                    EVF.C("ADD_USER_ID").setDisabled(true);
                    EVF.C("ADD_USER_NM").setDisabled(true);
                }
            }

            if(('${superUserFlag}' != 'true') && ('${havePermission}' !='true')){
                EVF.C("Confirm").setVisible(false);
                EVF.C("Reject").setVisible(false);
            } else {
                EVF.C("Confirm").setVisible(true);
                EVF.C("Reject").setVisible(true);
            }

            /*
            grid.setColGroup([{
                "groupName": "계약정보",
                "columns": [ "SALES_UNIT_PRICE", "CUR", "VALID_FROM_DATE", "VALID_TO_DATE", "VENDOR_CD", "VENDOR_NM" ]
            }],55);
             */
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.setParameter("CUST_CD", "${ses.companyCd}");
            store.load(baseUrl + "BNM1_031/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                //grid.setColIconify("SOURCING_REJECT_RMK", "SOURCING_REJECT_RMK", "comment", false);
            });
        }

        // 견적서 합의
        function doConfirm() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
            	// DGNS 시스템에서 I/F 받은 신규상품 요청건은 처리 불가
                if(grid.getCellValue(rowIds[i], 'PR_NO') != "") {
                    return alert("${BNM1_031_022}"); // DGNS 시스템에서 요청된 신규 상품 요청건은 DGNS 시스템에서 처리해야 합니다.
                }
                /*
                if(mngYn != "1" && grid.getCellValue(rowIds[i], 'REQUEST_USER_ID') != "${ses.userId}") {
                    return alert("${BNM1_031_019}");
                }
                */
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "450") {
                    return alert("${BNM1_031_012}");
                }
            }

            if(confirm("${BNM1_031_017 }")) {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.doFileUpload(function () {
                    store.load(baseUrl + 'bnm1031_doConfirm', function () {
                        alert(this.getResponseMessage());
                        doSearch();
                    });
                });
            }
        }

        // 견적서 합의거절
        function doReject() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            var rowIds = grid.getSelRowId();
            var itemRowId;
            for(var i in rowIds) {
            	// DGNS 시스템에서 I/F 받은 신규상품 요청건은 처리 불가
                if(grid.getCellValue(rowIds[i], 'PR_NO') != "") {
                    return alert("${BNM1_031_022}"); // DGNS 시스템에서 요청된 신규 상품 요청건은 DGNS 시스템에서 처리해야 합니다.
                }
                /*
                if(mngYn != "1" && grid.getCellValue(rowIds[i], 'REQUEST_USER_ID') != "${ses.userId}") {
                    return alert("${BNM1_031_020}");
                }
                */
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "450") {
                    return alert("${BNM1_031_012}");
                }
                itemRowId = rowIds[i];
            }

            if(confirm("${BNM1_031_015 }")) {
                var param = {
                    title : "합의반려사유",
                    message : grid.getCellValue(itemRowId, "SOURCING_REJECT_RMK"),
                    callbackFunction : "doRejectExec",
                    detailView : false,
                    rowId : itemRowId
                };
                var url = "/common/popup/common_text_input/view";
                everPopup.openModalPopup(url, 500, 320, param);
            };
        }

        function doRejectExec(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${BNM1_030_014}");
            }

            grid.setCellValue(data.rowId, "SOURCING_REJECT_RMK", data.message);

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.doFileUpload(function() {
                store.load(baseUrl + 'bnm1031_doRejectExec', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
            });
        }

        function onSearchUser() {
            var param = {
            	custCd: "${ses.companyCd}",
                callBackFunction: "setUser"
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function setUser(data) {
            EVF.C("ADD_USER_ID").setValue(data.USER_ID);
            EVF.C("ADD_USER_NM").setValue(data.USER_NM);
        }

        function onSearchDept() {
        	if( mngYn != '1' ) { return; }
            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setDept",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : "${ses.companyCd}",
                'custNm' : "${ses.companyNm}"
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
        }

        function setDept(data) {
            data = JSON.parse(data);
            EVF.C("ADD_DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("ADD_DEPT_NM").setValue(data.DEPT_NM);
        }

        function onSearchPlant() {
            var param = {
                    callBackFunction: "_setPlant",
                    custCd: "${ses.companyCd}"
                };
                everPopup.openCommonPopup(param, 'SP0005');
        }

        function _setPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("ADD_PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("ADD_PLANT_NM").setValue(jsondata.PLANT_NM);
        }

        function setSourcingRejectRmk(data) {
            grid.setCellValue(data.rowId, "SOURCING_REJECT_RMK", data.message);
            grid.setColIconify("SOURCING_REJECT_RMK", "SOURCING_REJECT_RMK", "comment", false);
        }

    </script>

    <e:window id="BNM1_031" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
            	<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="ADD_FROM_DATE" name="ADD_FROM_DATE" value="${oneMonthAgo}" toDate="ADD_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="ADD_TO_DATE" name="ADD_TO_DATE" value="${today}" fromDate="ADD_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
                </e:field>
                <e:label for="ADD_PLANT_CD" title="${form_ADD_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="ADD_PLANT_CD" name="ADD_PLANT_CD" value="${ses.mngYn eq '1' ? '' : ses.plantCd }" width="40%" maxLength="${form_ADD_PLANT_CD_M}" disabled="${form_ADD_PLANT_CD_D}" readOnly="${form_ADD_PLANT_CD_RO}" required="${form_ADD_PLANT_CD_R}" onIconClick="onSearchPlant" />
                    <e:inputText id="ADD_PLANT_NM" name="ADD_PLANT_NM" value="${ses.mngYn eq '1' ? '' : ses.plantNm }" width="60%" maxLength="${form_ADD_PLANT_NM_M}" disabled="${form_ADD_PLANT_NM_D}" readOnly="${form_ADD_PLANT_NM_RO}" required="${form_ADD_DEPT_NM_R}" />
                </e:field>
                <e:label for="DDP_CD" title="${form_DDP_CD_N}" />
                <e:field>
                    <e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ADD_USER_ID" title="${form_ADD_USER_ID_N}"/>
                <e:field>
                    <e:search id="ADD_USER_ID" name="ADD_USER_ID" value="${ses.mngYn eq '1' ? '' : ses.userId }" width="40%" maxLength="${form_ADD_USER_ID_M}" disabled="${form_ADD_USER_ID_D}" readOnly="${form_ADD_USER_ID_RO}" required="${form_ADD_USER_ID_R}" onIconClick="onSearchUser" />
                    <e:inputText id="ADD_USER_NM" name="ADD_USER_NM" value="${ses.mngYn eq '1' ? '' : ses.userNm }" width="60%" maxLength="${form_ADD_USER_NM_M}" disabled="${form_ADD_USER_NM_D}" readOnly="${form_ADD_USER_NM_RO}" required="${form_ADD_USER_NM_R}" />
                </e:field>
                <e:label for="ITEM_NM" title="${form_ITEM_NM_N}" />
				<e:field>
					<e:inputText id="ITEM_NM" name="ITEM_NM" value="" width="${form_ITEM_NM_W}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}" />
				</e:field>
            	<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" useMultipleSelect="true" usePlaceHolder="false" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Confirm" name="Confirm" label="${Confirm_N}" disabled="${Confirm_D}" visible="${Confirm_V}" onClick="doConfirm" />
            <e:button id="Reject" name="Reject" label="${Reject_N}" disabled="${Reject_D}" visible="${Reject_V}" onClick="doReject" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>