<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SIV1/SIV103/";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('sortable', false);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;
                // 주문자
                if(colId == 'CPO_USER_NM') {
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, 'CPO_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId === "ITEM_CD") {
                    if(value !== ""){
                        param = {
                            ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                            popupFlag: true,
                            detailView: true
                        };
                        everPopup.im03_014open(param);
                    }
                } else if(colId == "DELY_DELAY_NM") { // 납품지연상세사유
                    var detailView = false;
                    if( grid.getCellValue(rowId, 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowId, 'GR_COMPLETE_FLAG') == "1" ) {
                        detailView = true;
                    }
                    param = {
                        title: '납품지연사유',
                        CODE: grid.getCellValue(rowId, 'DELY_DELAY_CD'),
                        TEXT: grid.getCellValue(rowId, 'DELY_DELAY_REASON'),
                        rowId: rowId,
                        callBackFunction: 'setGridDelyText',
                        detailView: detailView
                    };
                    var url = '/evermp/SIV1/SIV101/SIV1_022/view';
                    everPopup.openModalPopup(url, 600, 360, param);
                } else if(colId == 'SG_CTRL_USER_NM') { // 표준화담당자
                    if( grid.getCellValue(rowId, 'MANAGE_ID') == '' ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, 'MANAGE_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == 'RECIPIENT_NM') { // 인수자
                    if( grid.getCellValue(rowId, 'RECIPIENT_NM') == '' ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowId, 'CPO_NO'),
                        CPO_SEQ: grid.getCellValue(rowId, 'CPO_SEQ'),
                        detailView: 'true'
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colId == 'DELY_RMK') { // 주문요청사항
                    if( grid.getCellValue(rowId, 'DELY_RMK') == '' ) return;
                    param = {
                        title: '주문요청사항',
                        message: grid.getCellValue(rowId, 'DELY_RMK'),
                        detailView: true,
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_view/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                } else if(colId == 'AGENT_ATTACH_FILE_CNT') {
                    if (grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_CNT') == '0') return;
                    everPopup.readOnlyFileAttachPopup('CPO', grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_NO'), '', rowId);
                } else if(colId == "IF_INVC_CD") {
                    var invList = [];
                    invList.push( grid.getCellValue(rowId, 'IF_INVC_CD') );

                    // 공급사용 거래명세서
                    param = {
                    		IF_INVC_CD: grid.getCellValue(rowId, "IF_INVC_CD"),
                        invType: 'V'
                    };
                    var url = "/evermp/print/PRT_040/view.so?#toolbar=1&navpanes=1";
                    everPopup.openWindowPopup(url, 1076, 850, param, 'vendInvoice', true, true);

                    // 고객사용 거래명세서
                    param = {
                    		IF_INVC_CD: grid.getCellValue(rowId, "IF_INVC_CD"),
                        invType: 'C'
                    };
                    url = "/evermp/print/PRT_040/view.so?#toolbar=1&navpanes=1";
                    everPopup.openWindowPopup(url, 976, 800, param, 'custInvoice', true, true);
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 310, param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {
                    case 'INV_QTY':
                        var unitPrice = Number(grid.getCellValue(rowId, 'PO_UNIT_PRICE'));
                        var invQty    = Number(grid.getCellValue(rowId, 'INV_QTY'));
                        grid.setCellValue(rowId, 'IV_ITEM_AMT', unitPrice * invQty);
                    default:
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('sortable', false);

            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);

            grid.freezeCol("CPO_USER_DEPT_NM");
            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "SIV1_030/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }


                grid.setColMerge(['PR_SUBJECT','CUST_CD','CUST_NM','CPO_USER_DEPT_NM','CPO_USER_NM','PLANT_NM','CPO_NO','PRIOR_GR_FLAG','PO_NO','CPO_SEQ','PO_SEQ','REF_MNG_NO',
                    'ITEM_CD','CUST_ITEM_CD','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM','ORIGIN_CD','UNIT_CD','CPO_QTY',
                    'CUR','PO_UNIT_PRICE','TAX_NM','VENDOR_ITEM_CD','CPO_DATE','LEAD_TIME_DATE','HOPE_DUE_DATE',
                    'RECIPIENT_NM','RECIPIENT_DEPT_NM','RECIPIENT_TEL_NUM','RECIPIENT_CELL_NUM','DELY_ZIP_CD','DELY_ADDR_1','DELY_ADDR_2','BF_INV_QTY']);


            });
        }
        function doSave2() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if (!confirm("저장 하시겠습니까?")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_030/doSave2', function() {
                alert(this.getResponseMessage());
                doSearch();
            });

        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var cpoNo    = ""; // 주문번호
            var cpoQty   = 0;  // 주문수량
            var bfInvQty = 0;  // 기납품수량
            var invQty   = 0;  // 납품수량
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'FORCE_CLOSE_YN') == "1" ) {
                    return alert("${SIV1_030_021 }");
                }

            	<%--동일한 주문에 대해 납품서 변경 가능 --%>
                if( cpoNo != "" && cpoNo != grid.getCellValue(rowIds[i], 'CPO_NO') ) {
                    return alert("${SIV1_030_008 }");
                }
                cpoNo = grid.getCellValue(rowIds[i], 'CPO_NO');
                <%--납품완료시 오류 --%>
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${SIV1_030_004 }");
                }

                <%--납품 약속일이 희망 납기일보다 늦을시 --%>
                if( grid.getCellValue(rowIds[i], "DELY_APP_DATE") > grid.getCellValue(rowIds[i], "HOPE_DUE_DATE") ) {
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "DELY_DELAY_CD")) == "" ) {
                        //return alert("${SIV1_030_006 }");
                    }
                }

                cpoQty   = Number(grid.getCellValue(rowIds[i], 'CPO_QTY'));
                bfInvQty = Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY'));
                invQty   = Number(grid.getCellValue(rowIds[i], 'INV_QTY'));

                if(cpoQty > 0) {
                    <%--납품수량 > 0 --%>
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) <= 0 ) {
                        return alert("${SIV1_030_005}");
                    }

                    <%--납품수량 + 기납품수량 < 주문수량 --%>
                    if( (bfInvQty + invQty) > cpoQty ) {
                        //return alert("${SIV1_030_007 }");
                    }
                } else {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) >= 0 ) {
                        return alert("${SIV1_030_005}");
                    }

                    if( (bfInvQty + invQty) < cpoQty ) {
                        //return alert("${SIV1_030_007 }");
                    }
                }

            }

            if (!confirm("${SIV1_030_002 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_030/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'GR_NO') != '') {
                    return alert("${SIV1_030_020}");
                }
                <%--납품완료시 오류 --%>
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${SIV1_030_004 }");
                }
            }

            if (!confirm("${SIV1_030_003 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_030/doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        <%--프린트 --%>
        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var invList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                invList.push( grid.getCellValue(rowIds[i], 'IV_NO') );
            }

            // 공급사용 거래명세서
            var param = {
                printList: JSON.stringify(invList),
                invType  : 'V'
            };
            var url = "/evermp/print/PRT_040/view.so?#toolbar=1&navpanes=1";
            everPopup.openWindowPopup(url, 976, 800, param, 'vendInvoice', true, true);

            // 고객사용 거래명세서
            param = {
                printList: JSON.stringify(invList),
                invType  : 'C'
            };
            url = "/evermp/print/PRT_040/view.so?#toolbar=1&navpanes=1";
            everPopup.openWindowPopup(url, 976, 800, param, 'custInvoice', true, true);
        }

        function doPoprint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var poList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                poList.push( grid.getCellValue(rowIds[i], 'PO_NO') );
            }

            // 중복 값 제거
            var pouniq = poList.reduce(function(a,b){
                if (a.indexOf(b) < 0 ) a.push(b);
                return a;
            },[]);

            var param = {
                PO_LIST : JSON.stringify(pouniq)
            };
            everPopup.openPopupByScreenId("PRT_031", 976, 800, param);
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
            //chgCustCd();
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${SIV1_030_001}");
            var param = {
                callBackFunction : "callBackPlant",
                custCd: EVF.V("CUST_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
        }

        function searchCustDeptCd() {
            var custCd = EVF.V("CUST_CD");
            var custNm = EVF.V("CUST_NM");
            if( custCd == "" ) {
                alert("${SIV1_030_001}");
                return;
            }

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "selectCustDeptCd",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : custCd,
                'custNm' : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function selectCustDeptCd(dataJsonArray) {
            data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS3);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCustUserId() {
            var custCd = EVF.V("CUST_CD");
            if( custCd == "" ) {
                alert("${SIV1_030_001}");
                return;
            }

            var param = {
                callBackFunction: "selectCustUserId",
                custCd: custCd
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function selectCustUserId(dataJsonArray) {
            EVF.C("CPO_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CPO_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        // 납품지연사유
        function setGridDelyText(data){
            grid.setCellValue(data.rowId, "DELY_DELAY_CD", data.code);
            grid.setCellValue(data.rowId, "DELY_DELAY_NM", data.code_nm);
            grid.setCellValue(data.rowId, "DELY_DELAY_REASON", data.text);
        }

        function doPrintOZ() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowValue = grid.getSelRowValue();
            var IV_NO = "";

            for( var i in selRowValue) {
                if(IV_NO.indexOf(selRowValue[i].IV_NO) < 0) {
                    if(i == 0) {
                        IV_NO = selRowValue[i].IV_NO;
                    } else {
                        IV_NO += "," + selRowValue[i].IV_NO;
                    }
                }
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


            var param = {
                IV_NO: IV_NO,
                HOST_INFO: oz80_url,
                OZ80_URL: oz80_url
            };

            var url = oz80_url + "/ozhviewer/IV_SourcingEstimate.jsp";
            everPopup.openWindowPopup(url, 1000, 700, param, "", true);
        }









        function chgCustCd() {
            var store = new EVF.Store;
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
                    EVF.C('DIVISION_CD').setOptions([]);
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);

            	}
            });
        }

        function chgPlantCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "100");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DIVISION_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }
        function chgDivisionCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "200");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DEPT_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }
        function chgDeptCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "300");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('PART_CD').setOptions(this.getParameter("divisionDeptPartCd"));
            	}
            });
        }











    </script>

    <e:window id="SIV1_030" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <%--
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                </e:field>
                <e:label for="DDP_CD" title="${form_DDP_CD_N}" />
                <e:field>
                    <e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
                </e:field>
            </e:row>
            --%>
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${SIV1_030_019}" value="PO_DATE"/>
                        <e:option text="${SIV1_030_010}" value="REG_DATE"/>
                        <e:option text="${SIV1_030_011}" value="DELY_APP_DATE"/>
                        <e:option text="${SIV1_030_012}" value="CPO_DATE"/>
                        <e:option text="${SIV1_030_013}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${addFromDate }" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${addToDate }" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
					<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="60%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
                <e:label for="GR_COMPLETE_FLAG" title="${form_GR_COMPLETE_FLAG_N}"/>
                <e:field>
                    <e:select id="GR_COMPLETE_FLAG" name="GR_COMPLETE_FLAG" value="${defaultGrFlag }" options="${grCompleteFlagOptions}" width="${form_GR_COMPLETE_FLAG_W}" disabled="${form_GR_COMPLETE_FLAG_D}" readOnly="${form_GR_COMPLETE_FLAG_RO}" required="${form_GR_COMPLETE_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                    <e:inputHidden id="MAKER_CD" name="MAKER_CD"/>
                    <e:inputHidden id="MAKER_NM" name="MAKER_NM"/>
                </e:field>
                <e:label for="" title="" />
                <e:field> </e:field>
                <%--
                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                </e:field>
                --%>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
			<e:button id="doSave2" name="doSave2" label="${doSave2_N}" onClick="doSave2" disabled="${doSave2_D}" visible="${doSave2_V}"/>

            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <!-- e:button id="printInvoice" name="printInvoice" label="${printInvoice_N}" onClick="doPrint" disabled="${printInvoice_D}" visible="${printInvoice_V}"/-->
            <!-- e:button id="doPoprint" name="doPoprint" label="${doPoprint_N}" onClick="doPoprint" disabled="${doPoprint_D}" visible="${doPoprint_V}"/-->
            <!-- e:button id="doPrintOZ" name="doPrintOZ" label="${doPrintOZ_N}" onClick="doPrintOZ" disabled="${doPrintOZ_D}" visible="${doPrintOZ_V}"/-->
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>