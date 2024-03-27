<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS03/BS0302/";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {

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
            store.load(baseUrl + 'bs03004_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("S_VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("S_VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }


    </script>
    <e:window id="BS03_004" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:label for="USER_TYPE" title="${form_USER_TYPE_N}"/>
            <e:field>
                <e:select id="USER_TYPE" name="USER_TYPE" value="${form.USER_TYPE}" options="${userTypeOptions }" width="${form_USER_TYPE_W}" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" />
            </e:field>
            <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
            <e:field>
                <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions }" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
            </e:field>
            <e:label for="S_VENDOR_CD" title="${form_S_VENDOR_CD_N}"/>
            <e:field>
                <e:search id="S_VENDOR_CD" style="ime-mode:inactive" name="S_VENDOR_CD" value="" width="40%" maxLength="${form_S_VENDOR_CD_M}" onIconClick="${form_S_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_S_VENDOR_CD_D}" readOnly="${form_S_VENDOR_CD_RO}" required="${form_S_VENDOR_CD_R}" />
                <e:inputText id="S_VENDOR_NM" style="${imeMode}" name="S_VENDOR_NM" value="" width="60%" maxLength="${form_S_VENDOR_NM_M}" disabled="${form_S_VENDOR_NM_D}" readOnly="${form_S_VENDOR_NM_RO}" required="${form_S_VENDOR_NM_R}" />
            </e:field>


        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Reject" name="Reject" label="${Reject_N }" disabled="${Reject_D }" visible="${Reject_V}" onClick="doReject" />

        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />


    </e:window>
</e:ui>