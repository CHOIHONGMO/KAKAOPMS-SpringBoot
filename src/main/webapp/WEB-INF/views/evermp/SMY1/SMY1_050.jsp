<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/SMY1/SMY101/";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {
                if (colId == "USER_ID") {
                    var param = {
                        'USER_ID': grid.getCellValue(rowId, 'ORI_USER_ID'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("SMY1_051", 800, 460, param);
                }
            });


            //동일 회사에 관리자여부 1명이상 존재 할 수 없음>> 체크
            grid.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "MNG_YN") {
                    if (value == "1") {
                        if(grid.getCellValue(rowid, 'BLOCK_FLAG')=="1"){
                            grid.setCellValue(rowid, 'MNG_YN', "0");
                            return alert("${SMY1_050_006}");
                        }
                        <%--if(grid.getCellValue(rowid, 'MNG_USER_ID')!=""){--%>
                            <%--if(grid.getCellValue(rowid, 'USER_ID')!=grid.getCellValue(rowid, 'MNG_USER_ID')){--%>
                                <%--if(confirm("${SMY1_050_002}"+"("+grid.getCellValue(rowid, 'MNG_USER_NM')+")\n"+"${BS03_005_003}")) {--%>
                                    <%--grid.setCellValue(rowid, 'CHANGE_MNG_YN', "Y");--%>
                                    <%--alert("${SMY1_050_004}");--%>
                                <%--}else{--%>
                                    <%--grid.setCellValue(rowid, 'MNG_YN', "0");--%>
                                <%--}--%>
                            <%--}--%>
                        <%--}--%>
                    }

                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'smy1050_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doInsert() {

            var param = {
                'USER_ID': '',
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("SMY1_051", 800, 460, param);
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'MNG_YN') == "1" && grid.getCellValue(rowIds[i], 'BLOCK_FLAG') == "1" ) {
                    return alert("${SMY1_050_005}");
                }
            }

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'smy1050_doUpdate', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            <%--var rowIds = grid.getSelRowId();--%>
            <%--for( var i in rowIds ) {--%>
                <%--if( grid.getCellValue(rowIds[i], 'MNG_YN') == "1" ) {--%>
                    <%--return alert("${SMY1_050_001}");--%>
                <%--}--%>
            <%--}--%>

            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'smy1050_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }



    </script>
    <e:window id="SMY1_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">

            <e:row>
                <e:inputHidden id="USER_TYPE" name="USER_TYPE" value="${ses.userType}" />
                <e:label for="COMPANY_NM" title="${form_COMPANY_NM_N }" />
                <e:field>
                    <e:inputText id="COMPANY_NM" name="COMPANY_NM" value="${ses.companyNm}"   readOnly="${form_COMPANY_NM_RO }"   maxLength="${form_COMPANY_NM_M}"  width="${form_COMPANY_NM_W }" required="${form_COMPANY_NM_R }" disabled="${form_COMPANY_NM_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="USER_ID" title="${form_USER_ID_N }" />
                <e:field>
                    <e:inputText id="USER_ID" name="USER_ID" value=""   readOnly="${form_USER_ID_RO }"   maxLength="${form_USER_ID_M}"  width="${form_USER_ID_W }" required="${form_USER_ID_R }" disabled="${form_USER_ID_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N }" />
                <e:field>
                    <e:inputText id="USER_NM" name="USER_NM" value=""   readOnly="${form_USER_NM_RO }"   maxLength="${form_USER_NM_M}"  width="${form_USER_NM_W }" required="${form_USER_NM_R }" disabled="${form_USER_NM_D }" onFocus="onFocus" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N }" />
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N }" />
                <e:field>
                    <e:inputText id="DEPT_NM" name="DEPT_NM" value=""   readOnly="${form_DEPT_NM_RO }"   maxLength="${form_DEPT_NM_M}"  width="${form_DEPT_NM_W }" required="${form_DEPT_NM_R }" disabled="${form_DEPT_NM_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="BLOCK_YN" title="${form_BLOCK_YN_N}"/>
                <e:field>
                    <e:select id="BLOCK_YN" name="BLOCK_YN" value="" options="${blockYnOptions}" width="100%" disabled="${form_BLOCK_YN_D}" readOnly="${form_BLOCK_YN_RO}" required="${form_BLOCK_YN_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${Insert_V}" onClick="doInsert" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />


    </e:window>
</e:ui>