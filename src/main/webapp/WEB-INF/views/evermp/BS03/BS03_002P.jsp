<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

    var grid;
    var baseUrl = "/evermp/BS03/BS0301/";

    function init() {
    grid = EVF.C("grid");
    grid.showCheckBar(false);
    grid.setProperty('shrinkToFit', true);

    grid.excelExportEvent({
    allItems : "${excelExport.allCol}",
    fileName : "${screenName }"
    });

    doSearch();
    }

    function doSearch() {
    var store = new EVF.Store();
    if(!store.validate()) { return;}
    store.setGrid([grid]);
    store.load(baseUrl + 'BS03_002P_doSearch', function() {
    if(grid.getRowCount() == 0){
    alert("${msg.M0002 }");
    }
    });
    }

    </script>

    <e:window id="BS03_002P" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <!--공급사코드-->
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
                <e:field>
                    <e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${form_VENDOR_CD_W}" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                </e:field>
                <!--공급사명-->
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <%--
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>
        --%>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>