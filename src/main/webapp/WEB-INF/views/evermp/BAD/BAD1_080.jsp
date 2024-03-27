<%-- 고객사 > Admin > 사용자관리 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">
<!--
		var gridD;
		var baseUrl = "/evermp/BAD/BAD1/";
		var eventRowId = 0;

		function init(){
		    gridD = EVF.C("gridD");

		    gridD.setProperty('shrinkToFit', false);
			gridD.showCheckBar(false);

		    gridD.cellClickEvent(function(rowId, colName, value) {
		    	eventRowId = rowId;

		    	if (colName == "DELY_RMK") {
		    		var url = '/common/popup/common_text_input/view';
		    		var param = {
		      				title : '요청사항',
		      				message : gridD.getCellValue(rowId, 'DELY_RMK'),
		      				callbackFunction : 'setGridDelyText',
		          			detailView : false,
		      				rowId : rowId
		      			};
		    	    everPopup.openModalPopup(url, 500, 320, param);
		        }

		    });

		    gridD.excelExportEvent({
		        allItems : "${excelExport.allCol}",
		        fileName : "${screenName }"
		    });

		}

		// 고객사 청구지조회
		function doSearch() {

		    var store = new EVF.Store();
		    if (!store.validate()) { return; }

		    store.setGrid([gridD]);
		    store.setParameter("CUBL_NM", EVF.C('CUBL_NM').getValue());
		    store.setParameter("COMPANY_NM", EVF.C('COMPANY_NM').getValue());
		    store.setParameter("IRS_NUM", EVF.C('IRS_NUM').getValue());
		    store.load(baseUrl + "bad1080_doSearchD", function () {
		        if(gridD.getRowCount() === 0) {
		           return alert('${msg.M0002}');
		        }
		    });
		}
// -->
</script>

    <e:window id="BAD1_080" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="CUBL_NM" title="${form_CUBL_NM_N}" />
				<e:field>
					<e:inputText id="CUBL_NM" name="CUBL_NM" value="" width="${form_CUBL_NM_W}" maxLength="${form_CUBL_NM_M}" disabled="${form_CUBL_NM_D}" readOnly="${form_CUBL_NM_RO}" required="${form_CUBL_NM_R}" />
				</e:field>
				<e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}" />
				<e:field>
					<e:inputText id="COMPANY_NM" name="COMPANY_NM" value="" width="${form_COMPANY_NM_W}" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="${form_COMPANY_NM_RO}" required="${form_COMPANY_NM_R}" />
				</e:field>
				<e:label for="IRS_NUM" title="${form_IRS_NUM_N }" />
				<e:field>
					<e:inputText id="IRS_NUM" name="IRS_NUM" value="" width="${form_IRS_NUM_W}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
        </e:buttonBar>

        <e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />

    </e:window>
</e:ui>