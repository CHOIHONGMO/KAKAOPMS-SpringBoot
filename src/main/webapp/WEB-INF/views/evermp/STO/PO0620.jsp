<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl ="/evermp/STO/PO0620/";
        var autoSearchFlag = '${form.autoSearchFlag}';
        var callType = '${form.callType}';
        var ROW_IDX;
        var footerSum_PO;
        var footerSum_CPO;
        var CONFIRM_POP_YN = "N";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('multiSelect', true);
            grid.setProperty('sortable', false);
            EVF.C('VENDOR_CD').setDisabled(true);
            EVF.C('VENDOR_NM').setDisabled(true);

            grid.cellClickEvent(function(rowId, colIdx, value) {
                var param;

                ROW_IDX = rowId;

                // 주문자
                if(colIdx == 'CPO_USER_NM') {
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: true
                    };

                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if (colIdx == "ITEM_CD") {
                	param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupFlag': true,
                            'detailView': false
                        };
                    everPopup.im03_014open(param);
                }else if(colIdx === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                            CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                        };
                        everPopup.openPopupByScreenId("BOD1_041", 1100, 800, param);
                    }
                } else if (colIdx == "VENDOR_NM") {
                	var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: true,
                            popupFlag: true
                        };
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }  else if(colIdx == 'RECIPIENT_NM') {
                    if( grid.getCellValue(rowId, 'RECIPIENT_NM') == '' ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowId, 'CPO_NO'),
                        CPO_SEQ: grid.getCellValue(rowId, 'CPO_SEQ'),
                        detailView: 'true'
                    };
                    everPopup.openPopupByScreenId("SIV1_026", 700, 450, param);
                }  else if(colIdx == "REQ_TEXT") {
                	return;
                    if(value != "") {
                        param = {
                            title: "요청사항",
                            message: grid.getCellValue(rowId, "REQ_TEXT"),
                            callbackFunction: "callbackGridREQ_TEXT",
                            detailView: true,
                            rowId: rowId
                        };
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    }
                } else if(colIdx == "AM_USER_CHANGE_RMK") {
                    if(value != "") {
                        param = {
                            title: "이관사유",
                            message: grid.getCellValue(rowId, "AM_USER_CHANGE_RMK"),
                            callbackFunction: "callbackGridREQ_TEXT",
                            detailView: true,
                            rowId: rowId
                        };
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    }
                } else if(colIdx == "ATTACH_FILE_CNT") {
                    if(value > 0) {
                        param = {
                            attFileNum: grid.getCellValue(rowId, "ATTACH_FILE_NO"),
                            rowId: rowId,
                            callBackFunction: "callbackGridATTACH_FILE_CNT",
                            havePermission: false,
                            bizType: "OM",
                            fileExtension: "*"
                        };
                        everPopup.openPopupByScreenId("commonFileAttach", 650, 310, param);
                    }
                }
            });

            grid.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {
                if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "PO_UNIT_PRICE" || colIdx == "CPO_ITEM_AMT" || colIdx == "PO_ITEM_AMT") {
                    if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "CPO_ITEM_AMT") {
                        if(grid.getCellValue(rowIdx, "BUDGET_USE_FLAG") == "1") {
                            alert("${PO0620_0026}");
                            grid.setCellValue(rowIdx, colIdx, oldValue);
                            return;
                        }
                    }
                    EXEC(rowIdx, colIdx);
                }
            });

            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });

            var val = {"visible": true, "count": 1, "height": 40};
            var footerTxt = {
                "styles": {
                    "textAlignment": "far",
                    "font": "굴림,12",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": ["합 계 "]
            };
            footerSum_PO = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['PO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

            footerSum_CPO = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['CPO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

            var footerRateZero = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": ["0%"]
            };

            grid.setProperty('footerVisible', val);
            grid.setRowFooter('CPO_UNIT_PRICE', footerTxt);
            grid.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);
            grid.setRowFooter('PROFIT_RATE', footerRateZero);

            grid.setColIconify("AM_USER_CHANGE_RMK_IMG", "AM_USER_CHANGE_RMK", "comment", false);
            // grid.setColIconify("CONFIRM_REQ_RMK_IMG", "CONFIRM_REQ_RMK", "comment", false);
            grid.setColIconify("PO_CONFIRM_REJECT_RMK_IMG", "PO_CONFIRM_REJECT_RMK", "comment", false);
//            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);

            grid.setColIconify("AM_USER_CHANGE_RMK", "AM_USER_CHANGE_RMK", "comment", false);
            grid.setColIconify("PO_CHANGE_REASON", "PO_CHANGE_REASON", "comment", false);

            grid._gvo.setHeader({height:36});
            doSearch();
        }


        function EXEC(rowIdx, colIdx) {
            if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "PO_UNIT_PRICE") {
                var CPO_QTY = grid.getCellValue(rowIdx, "CPO_QTY");
                var CPO_UNIT_PRICE = grid.getCellValue(rowIdx, "CPO_UNIT_PRICE");
                var PO_UNIT_PRICE = grid.getCellValue(rowIdx, "PO_UNIT_PRICE");

                grid.setCellValue(rowIdx, "CPO_ITEM_AMT", CPO_QTY * CPO_UNIT_PRICE);
                grid.setCellValue(rowIdx, "HDN_CPO_ITEM_AMT", CPO_QTY * CPO_UNIT_PRICE);

                grid.setCellValue(rowIdx, "PO_ITEM_AMT", CPO_QTY * PO_UNIT_PRICE);
                grid.setCellValue(rowIdx, "HDN_PO_ITEM_AMT", CPO_QTY * PO_UNIT_PRICE);
            }

            var CPO_ITEM_AMT = grid.getCellValue(rowIdx, "CPO_ITEM_AMT");
            var PO_ITEM_AMT = grid.getCellValue(rowIdx, "PO_ITEM_AMT");

            grid.setCellValue(rowIdx, "HDN_CPO_ITEM_AMT", CPO_ITEM_AMT);
            grid.setCellValue(rowIdx, "HDN_PO_ITEM_AMT", PO_ITEM_AMT);


            var PROFIT_RATE;
            if(CPO_ITEM_AMT == "0" || PO_ITEM_AMT == "0") {
                PROFIT_RATE = 0;
            } else {
                PROFIT_RATE = everMath.round_float(((CPO_ITEM_AMT - PO_ITEM_AMT) / CPO_ITEM_AMT) * 100, 1);
            }

            grid.setCellValue(rowIdx, "PROFIT_RATE", PROFIT_RATE);

            grid.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);

            var CPO_ITEM_AMT_SUM = Number(grid._gvo.getSummary("CPO_ITEM_AMT", "SUM"));
            var PO_ITEM_AMT_SUM = Number(grid._gvo.getSummary("PO_ITEM_AMT", "SUM"));

            if(!EVF.isEmpty(CPO_ITEM_AMT_SUM) && CPO_ITEM_AMT_SUM > 0) {
                if(!EVF.isEmpty(PO_ITEM_AMT_SUM) && PO_ITEM_AMT_SUM > 0) {
                    var salesRate = everMath.round_float(((CPO_ITEM_AMT_SUM - PO_ITEM_AMT_SUM) / CPO_ITEM_AMT_SUM) * 100, 1);
                    var footerRate = {
                        "styles": {
                            "textAlignment": "far",
                            "suffix": " ",
                            "numberFormat": "###,###.##",
                            "background":"#ffffff",
                            "foreground":"#FF0000",
                            "fontBold": true
                        },
                        "text": [salesRate + "%"]
                    };
                    grid.setRowFooter('PROFIT_RATE', footerRate);
                }
            }

            if(grid.getCellValue(rowIdx, "ORG_CPO_ITEM_AMT") != grid.getCellValue(rowIdx, "CPO_ITEM_AMT") ||
                grid.getCellValue(rowIdx, "ORG_PO_ITEM_AMT") != grid.getCellValue(rowIdx, "PO_ITEM_AMT")) {
                grid.setCellValue(rowIdx, "CHANGE_YN", "Y");
//                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", true);
            } else {
                grid.setCellValue(rowIdx, "CHANGE_YN", "N");
            }

            if(grid.getCellValue(rowIdx, "CHANGE_YN") == "Y" || grid.getCellValue(rowIdx, "CHANGE2_YN") == "Y") {
//                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", true);
            } else {
                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", false);
            }



        }
        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("autoSearchFlag", autoSearchFlag);
            store.setParameter("callType", callType);
            store.load(baseUrl + "PO0620_doSearch", function () {
                var footerRateZero = {
                    "styles": {
                        "textAlignment": "far",
                        "suffix": " ",
                        "numberFormat": "###,###.##",
                        "background":"#ffffff",
                        "foreground":"#FF0000",
                        "fontBold": true
                    },
                    "text": ["0%"]
                };
                grid.setRowFooter('PROFIT_RATE', footerRateZero);

                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                grid.setColIconify("AM_USER_CHANGE_RMK_IMG", "AM_USER_CHANGE_RMK", "comment", false);
                // grid.setColIconify("CONFIRM_REQ_RMK_IMG", "CONFIRM_REQ_RMK", "comment", false);
                grid.setColIconify("PO_CONFIRM_REJECT_RMK_IMG", "PO_CONFIRM_REJECT_RMK", "comment", false);

                var cpoItemAmt = Number(grid._gvo.getSummary('CPO_ITEM_AMT', 'SUM'));
                var poItemAmt = Number(grid._gvo.getSummary('PO_ITEM_AMT', 'SUM'));

                if(!EVF.isEmpty(cpoItemAmt) && cpoItemAmt > 0) {
                    if(!EVF.isEmpty(poItemAmt) && poItemAmt > 0) {
                        var salesRate = everMath.round_float(((cpoItemAmt - poItemAmt) / cpoItemAmt) * 100, 1);
                        var footerRate = {
                            "styles": {
                                "textAlignment": "far",
                                "suffix": " ",
                                "numberFormat": "###,###.##",
                                "background":"#ffffff",
                                "foreground":"#FF0000",
                                "fontBold": true
                            },
                            "text": [salesRate + "%"]
                        };
                        grid.setRowFooter('PROFIT_RATE', footerRate);
                    }
                }
                autoSearchFlag = "";
                callType = "";

                var rowIds = grid.getAllRowId();
                for(var i = 0; i < rowIds.length; i++) {
                    var selectedData = grid.getRowValue(rowIds[i]);
                    if(selectedData.PROGRESS_CD == '10' || selectedData.PROGRESS_CD == '20') {
                        grid._gvo.setCheckable(rowIds[i], false);
                    }
                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6100") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#bae3ff");
                    }

                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6120") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#ffaed3");
                    }

                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6300") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#abffaf");
                    }

                    if(selectedData.IF_CPO_NO != "") {
                        grid.setCellRequired(rowIds[i], "REQ_USER_NM", true);
                        grid.setCellRequired(rowIds[i], "REQ_USER_TEL_NUM", true);
                    }
                    //인터페이스 데이타 붉은색 표시
                    grid.setCellFontColor(rowIds[i], 'IF_CPO_NO_SEQ', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_CPO_NO_SEQ', true);
                    grid.setCellFontColor(rowIds[i], 'IF_ITEM_CD', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_ITEM_CD', true);
                    grid.setCellFontColor(rowIds[i], 'IF_ITEM_DESC', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_ITEM_DESC', true);
                    grid.setCellFontColor(rowIds[i], 'IF_ITEM_SPEC', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_ITEM_SPEC', true);
                    grid.setCellFontColor(rowIds[i], 'IF_DELY_ADDR_1', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_DELY_ADDR_1', true);
                    grid.setCellFontColor(rowIds[i], 'IF_UNIT_CD', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_UNIT_CD', true);
                    grid.setCellFontColor(rowIds[i], 'IF_CPO_UNIT_PRICE', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_CPO_UNIT_PRICE', true);

                    if(grid.getCellValue(rowIds[i], "CONFIRM_REQ_RMK") != "") {
//                        grid.setCellRequired(rowIds[i], "CONFIRM_REQ_RMK", true);
                    } else {
                        grid.setCellRequired(rowIds[i], "CONFIRM_REQ_RMK", false);
                    }
                }
            });
        }


        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                cpoList.push( grid.getCellValue(rowIds[i], 'CPO_NO') );
            }

            // 중복 값 제거
            var cpouniq = cpoList.reduce(function(a,b){
                if (a.indexOf(b) < 0 ) a.push(b);
                return a;
            },[]);

            var param = {
                CPO_LIST : JSON.stringify(cpouniq)
            };
            everPopup.openPopupByScreenId("PRT_030", 976, 800, param);
        }


    </script>

    <e:window id="PO0620" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
             <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="${ses.companyCd }" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${ses.companyNm} " width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${PO0620_0001}" value="CPO_DATE"/>
                        <e:option text="${PO0620_0002}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${empty param.yesterday ? addFromDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${empty param.yesterday ? addToDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>