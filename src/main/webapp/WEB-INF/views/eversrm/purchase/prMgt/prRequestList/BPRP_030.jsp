<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/purchase/prMgt/prRequestList/BPRP_030/";

	function init() {
		grid = EVF.getComponent('grid');
		grid.setProperty('multiselect', false);
		grid.setProperty('shrinkToFit', true);

		grid.setColFooter(
		{
	        'merge'      : true
		   ,'groupField' :
				 [
					  'PO_NUM'
					, 'PO_SQ'
					, 'PO_CREATE_DATE'
					, 'DUE_DATE'
					, 'PO_QT'
				 ]
			}
		);

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
	        if (celname == "PO_NUM") {
	            var param = {
	                poNum: grid.getCellValue(rowid, "PO_NUM"),
	                detaiView: true
                };
	            everPopup.openPoDetailInformation(param);
	        }
		});

        if (opener != null) {
            EVF.getComponent("PR_NUM").setValue("${param.prNum}");
            EVF.getComponent("PR_SQ").setValue("${param.prSq}");

            doSearch();
        }
    }

    function doClose() {
        window.close();
    }
    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    </script>
    <e:window id="BPRP_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="${labelWidth }" onEnter="doSearch">
        	<e:row>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
				<e:field>
					<e:inputText id="PR_NUM" name="PR_NUM" value="${form.PR_NUM}" width="100%" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}" />
				</e:field>
				<e:label for="PR_SQ" title="${form_PR_SQ_N}"/>
				<e:field>
					<e:inputNumber id="PR_SQ" name="PR_SQ" align="left" value="${form.PR_SQ}" maxValue="${form_PR_SQ_M}" width="100%" decimalPlace="${form_PR_SQ_NF}" disabled="${form_PR_SQ_D}" readOnly="${form_PR_SQ_RO}" required="${form_PR_SQ_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
				<e:field>
					<e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="${form.ITEM_SPEC}" width="100%" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
				</e:field>
				<e:label for="PR_QT" title="${form_PR_QT_N}"/>
				<e:field>
					<e:inputNumber id="PR_QT" name="PR_QT" value="${form.PR_QT}" maxValue="${form_PR_QT_M}" width="130" decimalPlace="${form_PR_QT_NF}" disabled="${form_PR_QT_D}" readOnly="${form_PR_QT_RO}" required="${form_PR_QT_R}" />
					<e:text>&nbsp;&nbsp;${form.UNIT_CD}</e:text>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>