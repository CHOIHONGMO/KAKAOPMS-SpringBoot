<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SIV1/SIV104/";

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
                    if( grid.getCellValue(rowId, 'DELY_DELAY_CD') == "" ) return;
                    param = {
                        title: '납품지연사유',
                        CODE: grid.getCellValue(rowId, 'DELY_DELAY_CD'),
                        TEXT: grid.getCellValue(rowId, 'DELY_DELAY_REASON'),
                        rowId: rowId,
                        detailView: true
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
                        detailView: true
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
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 310, param);
                } else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {
                    case 'DELY_COMPLETE_DATE':
                    	return;
                        if( newValue > '${addToDate}' ) {
                            grid.setCellValue(rowId, 'DELY_COMPLETE_DATE', oldValue);
                            return alert("${SIV1_050_006 }");
                        }
                    default:
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);

            grid.freezeCol("CPO_USER_DEPT_NM");

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "SIV1_050/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }

                grid.setColMerge(['CUST_NM','CPO_USER_DEPT_NM','CPO_USER_NM','CPO_NO','PRIOR_GR_FLAG','PO_NO','REF_MNG_NO',
                    'ITEM_CD','CUST_ITEM_CD','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM','ORIGIN_CD','UNIT_CD','CPO_QTY','BF_GR_QTY',
                    'CUR','PO_UNIT_PRICE','TAX_NM','VENDOR_ITEM_CD','CPO_DATE','LEAD_TIME_DATE','HOPE_DUE_DATE',
                    'RECIPIENT_NM','RECIPIENT_DEPT_NM','RECIPIENT_TEL_NUM','RECIPIENT_CELL_NUM','DELY_ZIP_CD','DELY_ADDR_1','DELY_ADDR_2']);
            });
        }

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var delyDate = EVF.V("DELY_COMPLETE_DATE");
            if( delyDate == "" || delyDate.length != 8 ) {
                EVF.C("DELY_COMPLETE_DATE").setFocus();
                return alert("${SIV1_050_007 }");
            }
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], 'DELY_COMPLETE_DATE', delyDate);
            }
        }

        // 납품완료
        function doComplete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" ) {	// 이미 납품이 완료된 건입니다.
                    return alert("${SIV1_050_004 }");
                }
                if( grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) { 	// 이미 입고가 완료된 건입니다.
                    return alert("${SIV1_050_008 }");
                }
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_DATE') > '${addToDate}' ) {
                    return alert("${SIV1_050_006 }");
                }
            }

            if (!confirm("${SIV1_050_002 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_050/doCompleteDely', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 납품완료 취소
        function doCancel() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') != "1" ) {
                    return alert("${SIV1_050_005 }");
                }
                if( grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${SIV1_050_008 }");
                }
                //DGNS I/F 주문건에 대해서는 납품완료 취소할 수 없음
            	if( grid.getCellValue(rowIds[i], 'IF_CPO_NO') != "" ) {
                    return alert("${SIV1_050_030 }");
            	}
            }

            if (!confirm("${SIV1_050_003 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_050/doCancelDely', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
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
            if( EVF.V("CUST_CD") == "" ) return alert("${SIV1_050_020}");
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
                alert("${SIV1_050_001}");
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
                alert("${SIV1_050_001}");
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

    <e:window id="SIV1_050" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">


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
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">

                        <e:option text="${SIV1_050_019}" value="PO_DATE"/>


                        <e:option text="${SIV1_050_010}" value="REG_DATE"/>
                        <e:option text="${SIV1_050_011}" value="DELY_APP_DATE"/>
                        <e:option text="${SIV1_050_012}" value="CPO_DATE"/>
                        <e:option text="${SIV1_050_013}" value="HOPE_DUE_DATE"/>
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
				<e:text>&nbsp;</e:text>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>

                <e:label for="DELY_COMPLETE_FLAG" title="${form_DELY_COMPLETE_FLAG_N}"/>
                <e:field>
                    <e:select id="DELY_COMPLETE_FLAG" name="DELY_COMPLETE_FLAG" value="${defaultFlagCd }" options="${delyCompleteFlagOptions}" width="${form_DELY_COMPLETE_FLAG_W}" disabled="${form_DELY_COMPLETE_FLAG_D}" readOnly="${form_DELY_COMPLETE_FLAG_RO}" required="${form_DELY_COMPLETE_FLAG_R}" placeHolder="" usePlaceHolder="false" />
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

                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                </e:field>
            </e:row>






        </e:searchPanel>

        <e:panel id="leftP1" height="fit" width="10%">
            <e:text style="color:red;font-weight:bold;font-size:10pt;">※ ${SIV1_050_CAPTION1} : </e:text>
        </e:panel>
        <e:panel id="leftP2" height="fit" width="30%">
            <e:inputDate id="DELY_COMPLETE_DATE" name="DELY_COMPLETE_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_DELY_COMPLETE_DATE_R}" disabled="${form_DELY_COMPLETE_DATE_D}" readOnly="${form_DELY_COMPLETE_DATE_RO}" />
            <e:text>&nbsp;</e:text>
            <e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>
        </e:panel>

        <e:panel id="rightP1" height="fit" width="60%">
            <e:buttonBar align="right" width="100%">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                <e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
                <%-- 2022.12.13 : 출하완료시 dgns i/f, 출하 완료 후 "취소" 불가능--%>
                <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
            </e:buttonBar>
        </e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>