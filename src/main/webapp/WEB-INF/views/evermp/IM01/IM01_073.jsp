<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM01/IM0101/";

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('multiselect', false);
            grid.setProperty("shrinkToFit", true);

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == "ITEM_IMG") {
                    if(EVF.V("CUST_CD")=="") {
                        EVF.C('CUST_CD').setFocus();
                        return alert("${IM01_073_001}");
                    }

                    var param = {
                        BUYER_CD : EVF.V("CUST_CD")
                        ,callBackFunction : "setItemInfo"
                        ,rowId : rowId
                        ,multiFlag : true
                        ,detailView : false
                        ,popupFlag : true
                    };
                    everPopup.openPopupByScreenId("IM02_012", 1200, 600, param);
                }
            });


            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {

                if (colId == 'UNIT_PRICE' || colId == 'ITEM_QTY') {
                    var cur = grid.getCellValue(rowId, 'CUR');
                    var unitPrc = Number(grid.getCellValue(rowId, 'UNIT_PRICE'));
                    var grQt = Number(grid.getCellValue(rowId, 'ITEM_QTY'));
                    var grAmt = everCurrency.getPrice(cur, unitPrc * grQt);
                    grid.setCellValue(rowId, 'ITEM_PRC', grAmt);
                }
            });
            grid.addRowEvent(function() {
                var addParam = [{}];
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function setItemInfo(jsonData, rowId) {
            var setRow = rowId;

            for(idx in jsonData) {


                if(idx >0){
                    var addParam = [{"ITEM_QTY" : "1"}];
                    setRow = grid.addRow(addParam);
                }
                //grid.setCellValue(rowId, 'TIER_CD', jsonData[idx].TIER_CD);
                grid.setCellValue(setRow, 'ITEM_CD', jsonData[idx].ITEM_CD);
                grid.setCellValue(setRow, 'ITEM_DESC', jsonData[idx].ITEM_DESC);
                grid.setCellValue(setRow, 'ITEM_SPEC', jsonData[idx].ITEM_SPEC);
                grid.setCellValue(setRow, 'MAKER_NM', jsonData[idx].MAKER_NM);
                grid.setCellValue(setRow, 'MODEL_NM', jsonData[idx].MAKER_PART_NO);
                grid.setCellValue(setRow, 'ITEM_QTY', "1");
                grid.setCellValue(setRow, 'UNIT_CD', jsonData[idx].UNIT_NM);
                doGetPrice(setRow);

            }

        }


        function doGetPrice(nRow) {

            var store = new EVF.Store();
            store.setParameter("BUYER_CD", EVF.V("CUST_CD"));
            store.setParameter("ITEM_CD", grid.getCellValue(nRow, 'ITEM_CD'));
            store.load('/evermp/IM02/IM0201/im02011_doGetPrice', function() {
                grid.setCellValue(nRow, "CONT_UNIT_PRC", this.getParameter("CONT_UNIT_PRICE"));
                grid.setCellValue(nRow, "UNIT_PRICE", this.getParameter("UNIT_PRICE"));
                grid.setCellValue(nRow, "ITEM_PRC", this.getParameter("UNIT_PRICE"));

                //grid.setCellValue(nRow, "CUR", this.getParameter("CUR"));
            }, false);
        }



        function doPrint() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var gridData =grid.getAllRowValue();

            var itemList = [];
            var rowIds = grid.getAllRowId();
            for( var i in rowIds ) {
                itemList.push(
                    {
                        'ITEM_CD': grid.getCellValue(rowIds[i], 'ITEM_CD'),
                        'ITEM_DESC': grid.getCellValue(rowIds[i], 'ITEM_DESC'),
                        'ITEM_SPEC': grid.getCellValue(rowIds[i], 'ITEM_SPEC'),
                        'MAKER_NM': grid.getCellValue(rowIds[i], 'MAKER_NM'),
                        'MODEL_NM': grid.getCellValue(rowIds[i], 'MODEL_NM'),
                        'UNIT_CD': grid.getCellValue(rowIds[i], 'UNIT_CD'),
                        'ITEM_QTY': grid.getCellValue(rowIds[i], 'ITEM_QTY'),
                        'UNIT_PRICE': grid.getCellValue(rowIds[i], 'UNIT_PRICE'),
                        'ITEM_PRC': grid.getCellValue(rowIds[i], 'ITEM_PRC')
                    }
                );
            }

            var param = {
                CUST_NM : EVF.V("CUST_NM"),
                REC_USER_NM : EVF.V("CUST_REG_USER_NM"),
                DEPT_NM : EVF.V("DEPT_NM"),
                POSITION_NM : EVF.V("POSITION_NM"),
                TEL_NUM : EVF.V("TEL_NUM"),
                EMAIL : EVF.V("EMAIL"),
                FAX_NUM : EVF.V("FAX_NUM"),
                REMARK : EVF.V("REMARK"),
                ITEM_LIST : JSON.stringify(itemList)
            };

            everPopup.openPopupByScreenId("PRT_022", 976, 800, param);
        }



        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
        }

        function searchRegUserId() {

            if(EVF.isEmpty(EVF.C("CUST_CD").getValue())) { return alert("${IM01_073_031}"); }

            var param = {
                custCd: EVF.C("CUST_CD").getValue(),
                callBackFunction : "selectRegUserId"
            };
            everPopup.openCommonPopup(param, 'SP0083');
        }

        function selectRegUserId(dataJsonArray) {
            EVF.C("CUST_REG_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CUST_REG_USER_NM").setValue(dataJsonArray.USER_NM);
            EVF.C("POSITION_NM").setValue(dataJsonArray.POSITION_NM);
            EVF.C("DEPT_NM").setValue(dataJsonArray.DEPT_NM);
            EVF.C("TEL_NUM").setValue(dataJsonArray.CELL_NUM);
            EVF.C("EMAIL").setValue(dataJsonArray.EMAIL);
        }
        function checkEmail(){
            if(!everString.isValidEmail(EVF.V("EMAIL"))) {
                alert("${msg.EMAIL_INVALID}");

                EVF.V("EMAIL","");
            }
        }

        function checkTelNo() {

            var checkType = this.getData();
            if(checkType == "FAX_NUM") {
                if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("FAX_NUM").setValue("");
                    EVF.C('FAX_NUM').setFocus();
                }
            }
            if(checkType == "TEL_NUM") {
                if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("TEL_NUM").setValue("");
                    EVF.C('TEL_NUM').setFocus();
                }
            }
        }
    </script>

    <e:window id="IM01_073" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:buttonBar align="right" width="100%">
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="">

            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="${form.CUST_NM}" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="true" required="${form_CUST_NM_R}"/>
                </e:field>
                <e:field colSpan="2">
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CUST_REG_USER_NM" title="${form_CUST_REG_USER_NM_N}"/>
                <e:field>
                    <e:inputHidden id="CUST_REG_USER_ID" name="CUST_REG_USER_ID" value="" />
                    <e:search id="CUST_REG_USER_NM" name="CUST_REG_USER_NM" value="" width="100%" maxLength="${form_CUST_REG_USER_NM_M}" onIconClick="searchRegUserId" disabled="${form_CUST_REG_USER_NM_D}" readOnly="${form_CUST_REG_USER_NM_RO}" required="${form_CUST_REG_USER_NM_R}" />
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
                <e:field>
                    <e:inputText id="DEPT_NM" name="DEPT_NM" value="" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="POSITION_NM" title="${form_POSITION_NM_N}" />
                <e:field>
                    <e:inputText id="POSITION_NM" name="POSITION_NM" value="" width="${form_POSITION_NM_W}" maxLength="${form_POSITION_NM_M}" disabled="${form_POSITION_NM_D}" readOnly="${form_POSITION_NM_RO}" required="${form_POSITION_NM_R}" />
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}" />
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" value="" width="${form_EMAIL_W}" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" onChange="checkEmail"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}" />
                <e:field>
                    <e:inputText id="TEL_NUM" name="TEL_NUM" value="" width="${form_TEL_NUM_W}" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" onChange="checkTelNo" data="TEL_NUM"/>
                </e:field>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}" />
                <e:field>
                    <e:inputText id="FAX_NUM" name="FAX_NUM" value="" width="${form_FAX_NUM_W}" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" onChange="checkTelNo" data="FAX_NUM"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REMARK" title="${form_REMARK_N}" />
                <e:field colSpan="3">
                    <e:textArea id="REMARK" name="REMARK" height="60" value="" width="${form_REMARK_W}" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}" style="${imeMode}"/>
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:panel id="Panel3" height="fit" width="85%">
            <e:title title="${IM01_073_CAPTION1 }" depth="1"/>
        </e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>