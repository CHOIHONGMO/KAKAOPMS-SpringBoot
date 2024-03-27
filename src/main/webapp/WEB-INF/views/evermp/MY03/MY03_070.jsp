<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
	String date_1 = EverDate.getShortDateString();
	String date_7 = EverDate.addDateDay(date_1, -7);
	String date_15 = EverDate.addDateDay(date_1, -15);
	String date_30 = EverDate.addDateMonth(date_1, -1);
%>
<c:set var="date_1" value="<%=date_1%>" />
<c:set var="date_7" value="<%=date_7%>" />
<c:set var="date_15" value="<%=date_15%>" />
<c:set var="date_30" value="<%=date_30%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/evermp/MY03/";
    var grid;

    function init() {
    	grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

        });

        grid.setColGroup([
           	 {"groupName": '1월',"columns": [ "QTY01", "AMT01"]}
           	,{"groupName": '2월',"columns": [ "QTY02", "AMT02"]}
           	,{"groupName": '3월',"columns": [ "QTY03", "AMT03"]}
           	,{"groupName": '4월',"columns": [ "QTY04", "AMT04"]}
           	,{"groupName": '5월',"columns": [ "QTY05", "AMT05"]}
           	,{"groupName": '6월',"columns": [ "QTY06", "AMT06"]}
           	,{"groupName": '7월',"columns": [ "QTY07", "AMT07"]}
           	,{"groupName": '8월',"columns": [ "QTY08", "AMT08"]}
           	,{"groupName": '9월',"columns": [ "QTY09", "AMT09"]}
           	,{"groupName": '10월',"columns": [ "QTY10", "AMT10"]}
           	,{"groupName": '11월',"columns": [ "QTY11", "AMT11"]}
           	,{"groupName": '12월',"columns": [ "QTY12", "AMT12"]}
           	],50);


        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});
        grid.showCheckBar(false);
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + 'my03070_doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }
	function searchCustCd() {
		var param = {
			callBackFunction: "selectCustCd"
		};
		everPopup.openCommonPopup(param, 'SP0067');
	}

	function selectCustCd(dataJsonArray) {
		EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
		EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
	}

</script>
    <e:window id="MY03_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>
				<e:label for="YEAR" title="${form_YEAR_N}"/>
				<e:field>
					<e:select id="YEAR" name="YEAR" value="${thisYear}" options="${yearOptions}" width="${form_YEAR_W}" disabled="${form_YEAR_D}" readOnly="${form_YEAR_RO}" required="${form_YEAR_R}" placeHolder="" usePlaceHolder="false"/>
				</e:field>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field colSpan="3">
				<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onKeyDown="cleanCustCd" />
				</e:field>
				<e:label for="STD_FLAG" title="${form_STD_FLAG_N}"/>
				<e:field>
					<e:select id="STD_FLAG" name="STD_FLAG" value="" options="${stdFlagOptions}" width="${form_STD_FLAG_W}" disabled="${form_STD_FLAG_D}" readOnly="${form_STD_FLAG_RO}" required="${form_STD_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="STD_TYPE" title="${form_STD_TYPE_N}"/>
				<e:field>
					<e:select id="STD_TYPE" name="STD_TYPE" value="" options="${stdTypeOptions}" width="${form_STD_TYPE_W}" disabled="${form_STD_TYPE_D}" readOnly="${form_STD_TYPE_RO}" required="${form_STD_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
