<%--기준정보 > 예산관리 > 계정관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS02/BS0201/";

        function init() {
            grid = EVF.C("grid");

            grid.setProperty('shrinkToFit', true);


            if ('${ses.userType}' != 'C') {
    			EVF.C("CUST_CD").setDisabled(true);
    			EVF.C("CUST_NM").setDisabled(true);
    			EVF.C("CUST_CD").setValue('${ses.companyCd}');
    			EVF.C("CUST_NM").setValue('${ses.companyNm}');
    			doSearch();
            }



            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == 'CUST_CD') {
                    var param = {
                        'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
                if(colId === 'MOD_USER_NM') {
                	return;
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "MOD_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.addRowEvent(function() {

                if(EVF.V("CUST_CD")==""){
                    EVF.C('CUST_CD').setFocus();
                    return alert("${BS02_002_001}");
                }

                var addParam = [{'CUST_CD': EVF.V("CUST_CD"),'CUST_NM': EVF.V("CUST_NM"), 'USE_FLAG': '1'}];
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });

        }

        function doSearch() {
            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs02002_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }


        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }
            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs02002_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs02002_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
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
            doSearch();
        }

    </script>
    <e:window id="BS02_002" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}"/>
                <e:field>
                    <e:inputText id="ACCOUNT_CD" name="ACCOUNT_CD" value="${form.ACCOUNT_CD}" width="${form_ACCOUNT_CD_W}" maxLength="${form_ACCOUNT_CD_M}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
                </e:field>
                <e:label for="ACCOUNT_NM" title="${form_ACCOUNT_NM_N}"/>
                <e:field>
                    <e:inputText id="ACCOUNT_NM" name="ACCOUNT_NM" value="${form.ACCOUNT_NM}" width="${form_ACCOUNT_NM_W}" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />


    </e:window>
</e:ui>