<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid = {};
		var baseUrl = "/eversrm/system/task/";
		var ID;

		function init() {

			grid = EVF.C('grid');

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if(celname == "USER_ID") {
					opener.window["${param.callBackFunction}"](grid.getRowValue(rowid));
					doClose();
				}
			});
			EVF.C("buyerCode").setValue('${param.BUYER_CD}');
			ID = '${param.ID}';

			grid.setProperty('shrinkToFit', true);
		}

		function doSearch() {

			<%--
            if((EVF.C('USER_NM').getValue() == '' || EVF.C('USER_NM').getValue() == null) && (EVF.C('DEPT_NM').getValue() == '' || EVF.C('DEPT_NM').getValue() == null)) {
                alert("${msg.M0035 }");
                return;
            }
            --%>

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + 'selectUserInCharge', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doClose() {
			window.close();
		}

		function doSearchDept() {
			var param = {
				callBackFunction: "selectParentDept",
				BUYER_CD: EVF.C("buyerCode").getValue(),
				searchConN: "${form_DEPT_NM_N }"
			};
			everPopup.openCommonPopup(param, 'SP0002');
		}

		function selectParentDept(data) {
			EVF.C('DEPT_NM').setValue(data.DEPT_NM);
		}

	</script>
	<e:window id="BSYT_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" onEnter="doSearch" columnCount="2" labelWidth="${labelWidth }">
			<e:row>
				<e:label for="buyerCode" title="${form_buyerCode_N }" />
				<e:field>
					<e:select id="buyerCode" name="buyerCode" value="" options="${refBuyerCode }" width="${inputTextWidth }" required="${form_buyerCode_R }" readOnly="${form_buyerCode_RO }" disabled="${form_buyerCode_D }" />
				</e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N }" />
				<e:field>
					<e:inputText id="USER_NM" name="USER_NM" width="${inputTextWidth }" maxLength="${form_USER_NM_M }" required="${form_USER_NM_R }" readOnly="${form_USER_NM_RO }" disabled="${form_USER_NM_D }" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N }" />
				<e:field colSpan="3">
					<e:inputText id="DEPT_NM" name="DEPT_NM" width="${inputTextWidth }" maxLength="${form_DEPT_NM_M }"  required="${form_DEPT_NM_R }" readOnly="${form_DEPT_NM_RO }" disabled="${form_DEPT_NM_D }" />
				</e:field>
			</e:row>
		</e:searchPanel>
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
			<e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>