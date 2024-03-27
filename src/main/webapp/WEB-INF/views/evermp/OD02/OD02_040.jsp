<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD02/OD0204/";
        var RowId = "";


        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;

                if(colId === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO")
                        };
                        everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
                    }
                }else if (colId == "CUR_QTY") {
                 	 RowId = rowId;
                    param  = {
                             callBackFunction : "selectWH",
                             rowId            : rowId,
                             ITEM_CD         : grid.getCellValue(rowId, 'ITEM_CD'),
                             popupFlag       : true,
                             detailView      : true
                        };

                        everPopup.openPopupByScreenId("STO03_010", 1100, 700, param);
                }else if (colId === "WH_NM"){
                	  RowId = rowId;
                     param = {
                                DEAL_CD : grid.getCellValue(rowId, 'DEAL_CD'),
                                callBackFunction: "callbackWH_NM",
                                rowId: rowId,
                                detailView: false,
                            };
                            everPopup.openPopupByScreenId("STO02P01", 600, 600, param);
                       } else if (colId == "CPO_SEQ") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                }else if(colId == 'CPO_USER_NM') { // 주문자
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, 'CPO_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == "ITEM_CD") {
                    param = {
                        ITEM_CD: grid.getCellValue(rowId, 'ITEM_CD'),
                        popupFlag: true,
                        detailView: true
                    };
                    everPopup.im03_014open(param);
                }  else if(colId == 'RECIPIENT_NM') { // 인수자
                    if( grid.getCellValue(rowId, 'RECIPIENT_NM') == '' ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowId, 'CPO_NO'),
                        CPO_SEQ: grid.getCellValue(rowId, 'CPO_SEQ'),
                        detailView: 'true'
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colId == 'AGENT_ATTACH_FILE_CNT') {

                   if( grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_CNT') == '0' ) return;
                    everPopup.readOnlyFileAttachPopup('CPO',grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_NO'),'',rowId);

                } else if (colId == "VENDOR_NM") {
                    param  = {
                        VENDOR_CD: grid.getCellValue(rowId, 'VENDOR_CD'),
                        detailView: true,
                        popupFlag: true
                    };

                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 310, param);
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

            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);
            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);

            grid.freezeCol("CPO_NO_SEQ");
            doSearch();
        }
        function selectWH(data){

        	  var ndata = JSON.parse(data);
        	  grid.setCellValue(RowId,"WH_NM", ndata.WH_NM);
              grid.setCellValue(RowId,"WAREHOUSE_CODE",ndata.WAREHOUSE_CODE);
              grid.setCellValue(RowId,"CUR_QTY", ndata.REAL_QTY);
              grid.setCellValue(RowId,"STR_CTRL_CODE", ndata.STR_CTRL_CODE);
              grid.setCellValue(RowId,"WAREHOUSE_TYPE", ndata.WAREHOUSE_TYPE);
         }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "OD02_040/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                var rowIds = grid.getAllRowId();
                for(var i = 0; i < rowIds.length; i++) {
                    var selectedData = grid.getRowValue(rowIds[i]);
                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6120") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#bae3ff");
                    }
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
                   <%--  <%--동일한 주문번호
                    if( grid.getCellValue(rowIds[i], "CPO_NO") != grid.getCellValue(rowIds[j], "CPO_NO") ){
                        return alert("${OD02_040_002}");
                    } --%>
                    <%--동일한 사업장 --%>
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "PLANT_NM")) != everString.lrTrim(grid.getCellValue(rowIds[j], "PLANT_NM")) ){
                        return alert("${OD02_040_003}");
                    }
                    <%--동일한 납품장소
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "DELY_ZIP_CD")) != everString.lrTrim(grid.getCellValue(rowIds[j], "DELY_ZIP_CD")) ){
                        return alert("${OD02_040_004}");
                    }--%>
                    <%--동일한 납품예정일 --%>
                    if( grid.getCellValue(rowIds[i], "DELY_APP_DATE") != grid.getCellValue(rowIds[j], "DELY_APP_DATE") ){
                        return alert("${OD02_040_005}");
                    }
                    <%--동일한 배송방법 --%>
                    if( grid.getCellValue(rowIds[i], "DELY_TYPE") != grid.getCellValue(rowIds[j], "DELY_TYPE") ){
                        return alert("${OD02_040_030}");
                    }
                    <%--창고정보 없을시 --%>
                    if( grid.getCellValue(rowIds[i], "WH_NM") == '' || grid.getCellValue(rowIds[i], "WAREHOUSE_CODE") ==''
                    	 || grid.getCellValue(rowIds[i], "STR_CTRL_CODE") =='' ) {
                        return alert("${OD02_040_035}");
                    }


                }

                cpoQty   = Number(grid.getCellValue(rowIds[i], 'CPO_QTY'));
                bfInvQty = Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY'));
                invQty   = Number(grid.getCellValue(rowIds[i], 'INV_QTY'));
                curQty   = Number(grid.getCellValue(rowIds[i], 'CUR_QTY'));




                if(cpoQty > 0) {
                    <%--납품수량은 0 이상으로 입력 --%>
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) <= 0 ) {
                        return alert("${OD02_040_006}");
                    }
                     if( curQty <= 0 ){
                    	 confirm('${OD02_040_034}');
                    }

                    //alert(bfInvQty+'======'+invQty+'======'+cpoQty);
                    if( (bfInvQty + invQty) > cpoQty ) {
                        return alert("${OD02_040_011}");
                    }
                } else {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) >= 0 ) {
                        return alert("${OD02_040_012}");
                    }

                    if( (bfInvQty + invQty) < cpoQty ) {
                        return alert("${OD02_040_011 }");
                    }
                }

              <%--   납품 약속일이 희망 납기일보다 늦을시
                if( grid.getCellValue(rowIds[i], "DELY_APP_DATE") > grid.getCellValue(rowIds[i], "HOPE_DUE_DATE") ) {
                    if( everString.lrTrim(grid.getCellValue(rowIds[i], "DELY_DELAY_CD")) == "" ) {
                        return alert("${OD02_040_007}");
                    }
                } --%>

                if( grid.getCellValue(rowIds[i], "DELY_TYPE") == '02'
               && grid.getCellValue(rowIds[i], "DELY_COMPANY_NM") == ''
               && grid.getCellValue(rowIds[i], "WAYBILL_NO") == ''

                ){
                    return alert("${OD02_040_031}");
                }
            }

            if(!confirm('${OD02_040_010}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_040/doCreateInvoice', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 븐할납품 [사용안함]
       /*  function doDivideInvoice() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var rowIds = grid.getSelRowId();

            if (grid.getCellValue(rowIds, "IF_CPO_NO_SEQ") != "") {
//                return alert("${OD02_040_026}");
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
                IF_CPO_NO_SEQ : selectedData.IF_CPO_NO_SEQ,
           		ODFLAG: "ODFLAG",
                detailView: 'false'
            };

            var url = '/evermp/SIV1/SIV101/SIV1_021/view';
            everPopup.openModalPopup(url, 800, 500, param);
        } */

        // 납품지연사유
        function setGridDelyText(data){
            grid.setCellValue(data.rowId, "DELY_DELAY_CD", data.code);
            grid.setCellValue(data.rowId, "DELY_DELAY_NM", data.code_nm);
            grid.setCellValue(data.rowId, "DELY_DELAY_REASON", data.text);
        }
		//창고선택
        function callbackWH_NM(data) {
            var whdata = JSON.parse(data);
            grid.setCellValue(RowId, 'WH_NM', whdata.WH_NM);
            grid.setCellValue(RowId, 'WAREHOUSE_CODE', whdata.WAREHOUSE_CODE);
            grid.setCellValue(RowId, 'STR_CTRL_CODE', whdata.STR_CTRL_CODE);
            grid.setCellValue(RowId, 'WAREHOUSE_TYPE', whdata.WAREHOUSE_TYPE);
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
            if( EVF.V("CUST_CD") == "" ) return alert("${OD02_040_001}");
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
                alert("${OD02_040_001}");
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
                alert("${OD02_040_001}");
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

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var dely_app_date = EVF.V("DELY_APP_DATE");

            if(dely_app_date == "") {
                return alert("${OD02_040_013}");
            }

            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                grid.setCellValue(selRowId[i], "DELY_APP_DATE", dely_app_date);
            }
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

        //출하확정취소
    	function doCancel() {

			 if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	            var rowIds = grid.getSelRowId();
	            for(var i in rowIds) {
	                //if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}") {
	                //    return alert("${OD02_040_0001}");
	                //}

	            	if(grid.getCellValue(rowIds[i], "PROGRESS_CD") != "6100") {
	                    grid.checkRow(rowIds[i], false);
	                    return alert("${OD02_040_0002}");
	            	}
	            }

	            if(!confirm('${OD02_040_0004}')) { return; }
	            var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.setParameter("PROGRESS_CD", '5100'); // 확정대기
	            store.load(baseUrl + 'OD02_040/doCancel', function() {
	                alert(this.getResponseMessage());
	                doSearch();
	            });

		}
    	function doPoCancel() {
    		 if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	            var rowIds = grid.getSelRowId();
	            for(var i in rowIds) {
	                if(grid.getCellValue(rowIds[i], 'PROGRESS_NM') == "출고대기") {
		                return alert("${OD02_040_036}");
		            }
	            }
	            var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            EVF.confirm('출하 종결 처리하시겠습니까?',function(){
	            store.load(baseUrl + 'OD02_040/doPoCancel', function() {
	                alert(this.getResponseMessage());
	                doSearch();
	            	});
	            });
		}


    </script>

    <e:window id="OD02_040" onReady="init" initData="${initData}" title="${fullScreenName}">
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
                        <e:option text="${OD02_040_029}" value="PO_DATE"/>
                        <e:option text="${OD02_040_020}" value="CPO_DATE"/>
                        <e:option text="${OD02_040_021}" value="HOPE_DUE_DATE"/>
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
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
                </e:field>
                <%--
                <e:label for="DOC_NUM">
                    <e:select id="DOC_NUM_COMBO" name="DOC_NUM_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD02_040_023}" value="CPO_NO"/>
                        <e:option text="${OD02_040_024}" value="PO_NO"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputText id="DOC_NUM" name="DOC_NUM" value="" width="80%" maxLength="${form_DOC_NUM_M}" disabled="${form_DOC_NUM_D}" readOnly="${form_DOC_NUM_RO}" required="${form_DOC_NUM_R}" />
                    <e:check id="EXCLUDE" name="EXCLUDE" value="1"/><e:text>${msg.M0204}</e:text>
                </e:field>
                --%>
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
               <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                </e:field>


            </e:row>



        </e:searchPanel>

        <e:panel id="leftP1" height="fit" width="10%">
            <e:text style="font-weight: bold;">●&nbsp;${OD02_040_CAPTION1} </e:text>
        </e:panel>
        <e:panel id="leftP2" height="fit" width="30%">
            <e:inputDate id="DELY_APP_DATE" name="DELY_APP_DATE" value="${addToDate}" width="${inputDateWidth}" datePicker="true" required="${form_DELY_APP_DATE_R}" disabled="${form_DELY_APP_DATE_D}" readOnly="${form_DELY_APP_DATE_RO}" />
            <e:text>&nbsp;</e:text>
            <e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>
            <e:button id="doPoCancel" name="doPoCancel" label="${doPoCancel_N}" onClick="doPoCancel" disabled="${doPoCancel_D}" visible="${doPoCancel_V}"/>
        </e:panel>

        <e:panel id="rightP1" height="fit" width="60%">
            <e:buttonBar align="right" width="100%">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                <e:button id="doCreateInvoice" name="doCreateInvoice" label="${doCreateInvoice_N}" onClick="doCreateInvoice" disabled="${doCreateInvoice_D}" visible="${doCreateInvoice_V}"/>
                <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
            </e:buttonBar>
        </e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>