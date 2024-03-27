<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/evermp/MY03/";
    var grid;
	
    function init() {
    	grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

		});

        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.showCheckBar(false);
        grid.setProperty('shrinkToFit', true);
    }

    function doSearch() {
        var store = new EVF.Store();    
        if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + 'my03080_doSearch', function() {
        	if(grid.getRowCount() == 0) {
            	alert("${msg.M0002 }");
            } else {

            }
        });
    }

    function changeUSER_TYPE() {
        EVF.V("COMPANY_CD", "");
        EVF.V("COMPANY_NM", "");
    }

    function searchCOMPANY_CD() {

        var COMPANY_TYPE = EVF.V("USER_TYPE");
        var param = {
            callBackFunction: "callbackCOMPANY_CD"
        };

        if(COMPANY_TYPE === "") {
            alert("${MY03_080_001}");
            return;
        }

        if (COMPANY_TYPE == "C") {
            COMPANY_TYPE = "SP0004";
        } else if (COMPANY_TYPE == "S") {
            COMPANY_TYPE = "SP0063";
        } else if (COMPANY_TYPE == "B") {
            COMPANY_TYPE = "SP0067";
        }
        everPopup.openCommonPopup(param, COMPANY_TYPE);
    }

    function callbackCOMPANY_CD(data) {
        if (EVF.V("USER_TYPE") == "C") {
            EVF.V("COMPANY_CD", data.BUYER_CD);
            EVF.V("COMPANY_NM", data.BUYER_NM);
        } else if (EVF.V("USER_TYPE") == "S") {
            EVF.V("COMPANY_CD", data.VENDOR_CD);
            EVF.V("COMPANY_NM", data.VENDOR_NM);
        } else if (EVF.V("USER_TYPE") == "B") {
            EVF.V("COMPANY_CD", data.CUST_CD);
            EVF.V("COMPANY_NM", data.CUST_NM);
        }
    }
</script>

    <e:window id="MY03_080" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>
                <e:label for="JOB_DATE_FROM" title="${form_JOB_DATE_FROM_N}"/>
                <e:field>
                    <e:inputDate id="JOB_DATE_FROM" name="JOB_DATE_FROM" value="${JOB_DATE_FROM}" toDate="JOB_DATE_TO" width="${inputDateWidth}" datePicker="true" required="${form_JOB_DATE_FROM_R}" disabled="${form_JOB_DATE_FROM_D}" readOnly="${form_JOB_DATE_FROM_RO}" />
                    <e:text> ~ </e:text>
                    <e:inputDate id="JOB_DATE_TO" name="JOB_DATE_TO" value="${JOB_DATE_TO}" fromDate="JOB_DATE_FROM" width="${inputDateWidth}" datePicker="true" required="${form_JOB_DATE_TO_R}" disabled="${form_JOB_DATE_TO_D}" readOnly="${form_JOB_DATE_TO_RO}" />
                </e:field>
                <e:label for="USER_TYPE" title="${form_USER_TYPE_N}"/>
                <e:field>
                    <e:select id="USER_TYPE" name="USER_TYPE" value="" onChange="changeUSER_TYPE" options="${userTypeOptions}" width="${form_USER_TYPE_W}" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="COMPANY_CD" title="${form_COMPANY_CD_N}"/>
                <e:field>
                    <e:search id="COMPANY_CD" name="COMPANY_CD" value="" width="40%" maxLength="${form_COMPANY_CD_M}" onIconClick="${form_COMPANY_CD_RO ? 'everCommon.blank' : 'searchCOMPANY_CD'}" disabled="${form_COMPANY_CD_D}" readOnly="${form_COMPANY_CD_RO}" required="${form_COMPANY_CD_R}" />
                    <e:inputText id="COMPANY_NM" name="COMPANY_NM" value="" width="60%" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="${form_COMPANY_NM_RO}" required="${form_COMPANY_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        
    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
