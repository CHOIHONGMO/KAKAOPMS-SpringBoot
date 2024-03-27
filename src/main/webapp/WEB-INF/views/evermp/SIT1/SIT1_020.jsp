<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SIT1/SIT101/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            	// 반려사유
				if(colId == "REJECT_RMK") {
					if( grid.getCellValue(rowId, 'REJECT_RMK') == '' ) return;
					var param = {
                        title : '반려사유',
                        message : grid.getCellValue(rowId, 'REJECT_RMK'),
                        detailView : true
                    };
            		var url = '/common/popup/common_text_view/view';
            	    everPopup.openModalPopup(url, 500, 320, param);
				}
            	// 품목상세설명
				if(colId == "ITEM_DETAIL_TEXT_FLAG") {
					var param = {
                         rowId : rowId
                        ,havePermission : true
                        ,screenName : '품목 상세설명'
                        ,callBackFunction : 'setItemDetailText'
                        ,largeTextNum : grid.getCellValue(rowId, "ITEM_DETAIL_TEXT_NUM")
                        ,detailView : true
                    };
                    everPopup.openPopupByScreenId('commonRichTextContents', 900, 600, param);
				}
	        	// 이미지 파일 업로드
	        	if(colId == 'IMG_ATT_FILE_NUM_IMG') {
	        		everPopup.readOnlyFileAttachPopup('IMAGE',grid.getCellValue(rowId, 'IMG_ATT_FILE_NUM'),'',rowId);
	        	}
	        	// 첨부파일 업로드
	        	if(colId == 'ATT_FILE_NUM_IMG') {
	        		everPopup.readOnlyFileAttachPopup('RP',grid.getCellValue(rowId, 'ATT_FILE_NUM'),'',rowId);
	        	}
	        	// 표준화담당자
	        	if(colId == 'CMS_USER_NM') {
	        		if( grid.getCellValue(rowId, 'CMS_USER_NM') == '' ) return; // CMS_USER_ID
	        		var param = {
                         callbackFunction : "",
                         USER_ID : grid.getCellValue(rowId, 'CMS_USER_ID'),
                         detailView : true
                     };
                     everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
	        	}
	        	// 품목담당자 - 상품담당자
	        	if(colId == 'SG_USER_NM') {
	        		if( grid.getCellValue(rowId, 'SG_USER_NM') == '' ) return; // SG_USER_ID
	        		var param = {
                         callbackFunction : "",
                         USER_ID : grid.getCellValue(rowId, 'SG_USER_ID'),
                         detailView : true
                     };
                     everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
	        	}
	        	// 공급사담당자 - 제안자
	        	if(colId == 'REG_USER_NM') {
	        		if( grid.getCellValue(rowId, 'REG_USER_NM') == '' ) return; // REG_USER_ID
	        		var param = {
                         callbackFunction : "",
                         USER_ID : grid.getCellValue(rowId, 'REG_USER_ID'),
                         detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
	        	}
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            // 진행상태 : 임시저장 제외
            EVF.C('PROGRESS_CD').removeOption('100');

            if("${param.autoSearchFlag}" == "Y") { doSearch(); }
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("VENDOR_CD", "${ses.companyCd}");
            store.load(baseUrl + "SIT1_020/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                grid.setColIconify("REJECT_RMK", "REJECT_RMK", "comment", false);
            });
        }

        function doCancel() {
        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "200") {
                	return alert("${SIT1_020_002 }");
                }
            }

            if(!confirm("${msg.M0024}")) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
    		store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIT1_020/doCancel', function(){
           		alert(this.getResponseMessage());
           		doSearch();
           	});
        }

    </script>

    <e:window id="SIT1_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
            	<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="ADD_FROM_DATE" name="ADD_FROM_DATE" value="${empty param.fromDate ? oneMonthAgo : param.fromDate}" toDate="ADD_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="ADD_TO_DATE" name="ADD_TO_DATE" value="${empty param.toDate ? today : param.toDate}" fromDate="ADD_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>