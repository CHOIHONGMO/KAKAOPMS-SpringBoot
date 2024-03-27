<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS01/BS0101/";

        function init() {
            grid = EVF.C("grid");
            grid.showCheckBar(true);
            grid.setProperty("singleSelect", true);        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

            grid.cellClickEvent(function(rowId, colId, value) {
                if (colId == "CUST_CD") {
                    var param = {
                        'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
                if (colId == "CUTS_CNT") {
                    if(grid.getCellValue(rowId, 'CUTS_CNT') != '0') {
                        var param = {
                            'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                            'CUST_NM': grid.getCellValue(rowId, 'CUST_NM'),
                            'detailView': true,
                            'popupFlag': true
                        };
                        everPopup.openPopupByScreenId("BS01_005", 700, 450, param);
                    }
                }
                if (colId == "CHANGE_CNT") {
                    if( Number(grid.getCellValue(rowId, 'CHANGE_CNT')) > 0 ) {
                        var param = {
                            'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                            'CUST_NM': grid.getCellValue(rowId, 'CUST_NM'),
                            'detailView': true,
                            'popupFlag': true
                        };
                        everPopup.openPopupByScreenId("BS01_001P", 800, 450, param);
                    }
                }
                if(colId === 'MOD_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "MOD_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId === 'STOP_REMARK' && value != '') {
                    var param = {
                        title: "${BS01_001_0004}",
                        message: grid.getCellValue(rowId, 'STOP_REMARK')
                    };
                    everPopup.openModalPopup('/common/popup/common_text_view/view', 500, 300, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }",
                /*masking: true,
                SCREEN_ID: "BS01_001",
                gridID: "grid"*/
            });

            $('#SEARCH_COMBO').next('button').css('padding-top','5px').height('100%');
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs01001_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doInsert() {
            var param = {
                'CUST_CD': '',
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
        }

        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function selectCust(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
        }

        var blockYN = '';
        function doSuspensionOrTrading(){
            if(grid.getSelRowCount() === 0){
                return EVF.alert("${msg.M0004}");
            }
            if(grid.getSelRowCount() > 1){
                return EVF.alert("${msg.M0006}");
            }

            var selected = grid.getSelRowValue()[0];
            var ynData = this.getData();
            if(selected.STOP_FLAG === ynData){
                if(ynData==='1'){
                    EVF.alert("${BS01_001_0001}");
                }else{
                    EVF.alert("${BS01_001_0002}");
                }
                return;
            }
            blockYN = ynData;
            var param = {
                rowId: grid.getSelRowId()
                , havePermission: true
                , screenName: '거래정지/해제 사유'
                , callBackFunction: 'setStopRemark'
                , TEXT_CONTENTS: ''
                , detailView: false
            };
            everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);

        }

        function setStopRemark(data, rowId){
            if(data===''){
                return EVF.alert("${BS01_001_0003}");
            }

            grid.setCellValue(rowId, 'STOP_FLAG', blockYN);
            grid.setCellValue(rowId, 'STOP_REMARK', data);
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs01001_doSuspensionOrTrading', function() {
                blockYN = '';
                EVF.alert('${msg.M0001}');
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }



    </script>

    <e:window id="BS01_001" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="IRS_NO" title="${form_IRS_NO_N}"/>
                <e:field>
                    <e:inputText id="IRS_NO" name="IRS_NO" value="" width="100%" maxLength="${form_IRS_NO_M}" disabled="${form_IRS_NO_D}" readOnly="${form_IRS_NO_RO}" required="${form_IRS_NO_R}" />
                </e:field>
                <e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="CEO_USER_NM" style="${imeMode}" name="CEO_USER_NM" value="" width="100%" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" />
                </e:field>

				<e:inputHidden id="SH_VALUE_COMBO" name="SH_VALUE_COMBO"/>
				<e:inputHidden id="COMPANY_TYPE" name="COMPANY_TYPE"/>
				<e:inputHidden id="CORP_TYPE" name="CORP_TYPE"/>

            </e:row>
            <e:row>
                <%--
                <e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
                <e:field>
                    <e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" value="${fromDate}" toDate="REG_DATE_TO" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
                    <e:text>&nbsp;~&nbsp;</e:text>
                    <e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" value="${toDate}" fromDate="REG_DATE_FROM" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
                </e:field>
                --%>
				<e:label for="RELAT_YN" title="${form_RELAT_YN_N}"/>
				<e:field>
				<e:select id="RELAT_YN" name="RELAT_YN" value="" options="${relatYnOptions}" width="${form_RELAT_YN_W}" disabled="${form_RELAT_YN_D}" readOnly="${form_RELAT_YN_RO}" required="${form_RELAT_YN_R}" placeHolder="" />
				</e:field>

                <e:label for="" title="" />
                <e:field> </e:field>
                <e:label for="" title="" />
                <e:field> </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <%--<e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${Insert_V}" onClick="doInsert" />--%>
            <e:button id="Suspension" name="Suspension" label="${Suspension_N}" onClick="doSuspensionOrTrading" disabled="${Suspension_D}" visible="${Suspension_V}" data="1"/>
            <e:button id="Trading" name="Trading" label="${Trading_N}" onClick="doSuspensionOrTrading" disabled="${Trading_D}" visible="${Trading_V}" data="0"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>