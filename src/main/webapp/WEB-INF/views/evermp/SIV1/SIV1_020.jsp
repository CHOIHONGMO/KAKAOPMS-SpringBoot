<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SIV1/SIV101/";

        function init() {

            grid = EVF.C("grid");

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
                    param = {
                        title: '납품지연사유',
                        CODE: grid.getCellValue(rowId, 'DELY_DELAY_CD'),
                        TEXT: grid.getCellValue(rowId, 'DELY_DELAY_REASON'),
                        rowId: rowId,
                        callBackFunction: 'setGridDelyText',
                        detailView: 'false'
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
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 310, param);
                } else if(colId == "REQ_TEXT") {
                    if(value != "") {
                        param = {
                            title: "요청사항",
                            message: grid.getCellValue(rowId, "REQ_TEXT"),
                            detailView: true,
                            rowId: rowId
                        };
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    }
                } else if(colId == 'AGENT_ATTACH_FILE_CNT') {
                    if (grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_CNT') == '0') return;
                    everPopup.readOnlyFileAttachPopup('CPO', grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_NO'), '', rowId);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {
                    case 'INV_QTY':
                        var unitPrice = Number(grid.getCellValue(rowId, 'PO_UNIT_PRICE'));
                        var invQty    = Number(grid.getCellValue(rowId, 'INV_QTY'));
                        grid.setCellValue(rowId, 'IV_ITEM_AMT', unitPrice * invQty);
                    case 'DELY_APP_DATE' :
                    	allChangeGrid('DELY_APP_DATE',newValue);
                    default:
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);
            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);

            grid.freezeCol("CPO_USER_DEPT_NM");
            doSearch();
        }
        //일괄적용 그리드 적용
	    function allChangeGrid(colName,newValue){
	        var rowIds = grid.getSelRowId();
			EVF.confirm('일괄적용하시겠습니까?',function(){
    			for( var i in rowIds){
    	            grid.setCellValue(rowIds[i],colName,newValue);
    			}
    		});
		}

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "SIV1_020/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // 납품서생성
        function doCreateInvoice() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var cpoQty   = 0; // 주문수량
            var bfInvQty = 0; // 기납품수량
            var invQty   = 0; // 납품수량
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                for( var j in rowIds ) {
                    <%--동일한 주문번호 --%>
                    if( grid.getCellValue(rowIds[i], "CPO_NO") != grid.getCellValue(rowIds[j], "CPO_NO") ){
//                        return alert("${SIV1_020_002}");
                    }
                    <%--동일한 납품예정일 --%>
                    if( grid.getCellValue(rowIds[i], "DELY_APP_DATE") != grid.getCellValue(rowIds[j], "DELY_APP_DATE") ){
//                        return alert("${SIV1_020_005}");
                    }
                    <%--동일한 납품장소 --%>
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "DELY_ZIP_CD")) != everString.lrTrim(grid.getCellValue(rowIds[j], "DELY_ZIP_CD")) ){
//                        return alert("${SIV1_020_004}");
                    }



                    <%--동일한 고객사 --%>
                    if( grid.getCellValue(rowIds[i], "CUST_CD") != grid.getCellValue(rowIds[j], "CUST_CD") ){
                        return alert("${SIV1_020_030}");
                    }

                    <%--동일한 인수자 --%>
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "RECIPIENT_NM")) != everString.lrTrim(grid.getCellValue(rowIds[j], "RECIPIENT_NM")) ){
                        return alert("${SIV1_020_003}");
                    }

                    <%--동일한 배송방법 --%>
                    if( grid.getCellValue(rowIds[i], "DELY_TYPE") != grid.getCellValue(rowIds[j], "DELY_TYPE") ){
                        return alert("${SIV1_020_028}");
                    }
                }

                cpoQty   = Number(grid.getCellValue(rowIds[i], 'CPO_QTY'));
                bfInvQty = Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY'));
                invQty   = Number(grid.getCellValue(rowIds[i], 'INV_QTY'));

                if(cpoQty > 0) {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) <= 0 ) {
                        return alert("${SIV1_020_006}");
                    }

                    <%--납품수량 + 기납품수량 < 주문수량 --%>
                    if( (bfInvQty + invQty) > cpoQty ) {
                        return alert("${SIV1_020_011 }");
                    }
                } else {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) >= 0 ) {
                        return alert("${SIV1_020_013}");
                    }

                    if( (bfInvQty + invQty) < cpoQty ) {
                        return alert("${SIV1_020_011 }");
                    }
                }

                <%--납품 약속일이 희망 납기일보다 늦을시 --%>
                if( grid.getCellValue(rowIds[i], "DELY_APP_DATE") > grid.getCellValue(rowIds[i], "HOPE_DUE_DATE") ) {
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "DELY_DELAY_CD")) == "" ) {
                        //return alert("${SIV1_020_007 }");
                    }
                }

                if( grid.getCellValue(rowIds[i], "DELY_TYPE") == '02'
					&& grid.getCellValue(rowIds[i], "DELY_COMPANY_NM") == ''
					&& grid.getCellValue(rowIds[i], "WAYBILL_NO") == ''

                ){
                    return alert("${SIV1_020_027}");
                }

                var grFlag = grid.getCellValue(rowIds[i], "PRIOR_GR_FLAG");

            }

            if(grFlag != "N") {
                if(!confirm('${SIV1_020_014}')) {
                    return;
                } else {
                    var store = new EVF.Store();
                    store.setGrid([grid]);
                    store.getGridData(grid, 'sel');
                    store.load(baseUrl + 'SIV1_020/doCreateInvoice', function() {
                        alert(this.getResponseMessage());
                        doSearch();
                    });
                }
            } else {
                if(!confirm('${SIV1_020_010}')) {
                    return;
                } else {
                    var store = new EVF.Store();
                    store.setGrid([grid]);
                    store.getGridData(grid, 'sel');
                    store.load(baseUrl + 'SIV1_020/doCreateInvoice', function() {
                        alert(this.getResponseMessage());
                        doSearch();
                    });
                }
            }
        }

        // 븐할납품
        function doDivideInvoice() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var rowIds = grid.getSelRowId();

            if (grid.getCellValue(rowIds, "IF_CPO_NO_SEQ") != "") {
                return alert("${OD02_010_026}");
            }

            var selectedData = grid.getRowValue(rowIds[0]);
            var param = {
                callBackFunction : 'doSearch',
                CPO_NO : selectedData.CPO_NO,
                CPO_SEQ : selectedData.CPO_SEQ,
                PO_NO : selectedData.PO_NO,
                PO_SEQ : selectedData.PO_SEQ,
                CUST_CD : selectedData.CUST_CD,
                CUST_NM : selectedData.CUST_NM,
                CPO_USER_NM : selectedData.CPO_USER_NM_ORI,
                CPO_USER_DEPT_NM : selectedData.CPO_USER_DEPT_NM,
                DELY_APP_DATE : selectedData.DELY_APP_DATE,
                HOPE_DUE_DATE : selectedData.HOPE_DUE_DATE_ORI,
                ITEM_CD : selectedData.ITEM_CD,
                ITEM_DESC : selectedData.ITEM_DESC,
                ITEM_SPEC : selectedData.ITEM_SPEC,
                MAKER_NM : selectedData.MAKER_NM,
                MAKER_PART_NO : selectedData.MAKER_PART_NO,
                BRAND_NM : selectedData.BRAND_NM,
                UNIT_CD : selectedData.UNIT_CD,
                CPO_QTY : selectedData.CPO_QTY,
                INV_QTY : selectedData.INV_QTY,
                PO_UNIT_PRICE : selectedData.PO_UNIT_PRICE,
                RECIPIENT_NM : selectedData.RECIPIENT_NM,
                RECIPIENT_DEPT_NM : selectedData.RECIPIENT_DEPT_NM,
                RECIPIENT_TEL_NUM : selectedData.RECIPIENT_TEL_NUM,
                RECIPIENT_CELL_NUM : selectedData.RECIPIENT_CELL_NUM,
                DELY_ZIP_CD : selectedData.DELY_ZIP_CD,
                DELY_ADDR_1 : selectedData.DELY_ADDR_1,
                DELY_ADDR_2 : selectedData.DELY_ADDR_2,
                DEAL_CD : selectedData.DEAL_CD,
                detailView: 'false'
            };

            var url = '/evermp/SIV1/SIV101/SIV1_021/view';
            everPopup.openModalPopup(url, 800, 500, param);
        }

        // 납품거부
        function doRejectInvoice() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            // 기존 납품한 이력이 있으면 납품 거부 안됨
            var bfCpoNo = "";
            var cpoQty = 0;

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                cpoQty   = Number(grid.getCellValue(rowIds[i], 'CPO_QTY'));

                if(cpoQty  > 0) {
                    if( Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY')) > 0 ) {
                        return alert("${SIV1_020_008}");
                    }
                } else {
                    if( Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY')) < 0 ) {
                        return alert("${SIV1_020_008}");
                    }
                }

                if( bfCpoNo != '' && bfCpoNo != grid.getCellValue(rowIds[i], 'CPO_NO') ) {
                    return alert("${SIV1_020_012}");
                }
                bfCpoNo = grid.getCellValue(rowIds[i], 'CPO_NO');
            }

            var param = {
                callBackFunction : 'setRejectText',
                detailView : 'false'
            };
            var url = '/evermp/SIV1/SIV101/SIV1_023/view';
            everPopup.openModalPopup(url, 600, 360, param);
        }

        function setRejectText(data){
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], "DELY_REJECT_CD", data.code);
                grid.setCellValue(rowIds[i], "DELY_REJECT_REASON", data.text);
            }

            doRejectSer();
        }

        function doRejectSer() {
            if (!confirm("${SIV1_020_009 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_020/doRejectInvoice', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 납품지연사유
        function setGridDelyText(data){
            grid.setCellValue(data.rowId, "DELY_DELAY_CD", data.code);
            grid.setCellValue(data.rowId, "DELY_DELAY_NM", data.code_nm);
            grid.setCellValue(data.rowId, "DELY_DELAY_REASON", data.text);
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
            if( EVF.V("CUST_CD") == "" ) return alert("${SIV1_020_001}");
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
                alert("${SIV1_020_001}");
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
                alert("${SIV1_020_001}");
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

        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

			/* if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
				return alert("${msg.M0006}");
			} */


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

    <e:window id="SIV1_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${SIV1_020_029}" value="PO_DATE"/>
                        <e:option text="${SIV1_020_020}" value="CPO_DATE"/>
                        <e:option text="${SIV1_020_021}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${addFromDate}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${addToDate}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
					<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="60%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="" options="${itemUserOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
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
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
        	<e:text><b>배송방법이 택배일 경우 택배사만 선택하고 운송장번호는 추후에 입력 바랍니다.(납품현황에서 수정가능)</e:text>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="createInvoice" name="createInvoice" label="${createInvoice_N}" onClick="doCreateInvoice" disabled="${createInvoice_D}" visible="${createInvoice_V}"/>
			<e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
            <!-- e:button id="rejectInvoice" name="rejectInvoice" label="${rejectInvoice_N}" onClick="doRejectInvoice" disabled="${rejectInvoice_D}" visible="${rejectInvoice_V}"/-->
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>