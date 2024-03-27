<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var addParam = [];
        var baseUrl = "/evermp/TX02/TX0201/";

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', true);
            grid.setProperty('multiSelect', false);

            grid.cellClickEvent(function (rowId, colId, value) {
                switch (colId) {
                    case 'USER_ID':

                        var data = grid.getRowValue(rowId);
                        var selectedData = JSON.stringify(data);
                        opener['${param.callBackFunction}'](selectedData);
                        window.close();
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
            store.load(baseUrl + 'tx02010_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }


    </script>
    <e:window id="TX02_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <%--사업자등록번호--%>
                <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"/>
                <e:field>
                    <e:inputText id="IRS_NUM" name="IRS_NUM" value="${form.IRS_NUM}" width="${form_IRS_NUM_W}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
                </e:field>
                <%--거래처명--%>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.CUST_NM}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <%--이메일--%>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" value="" width="${form_EMAIL_W}" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" />
                </e:field>
                <%--담당자--%>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="USER_NM" name="USER_NM" value="" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonTopBottom" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>