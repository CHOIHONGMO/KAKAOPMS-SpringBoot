<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0303/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == "ITEM_CD") {
                    if(value!=""){
                        var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupFlag': true,
                            'detailView': true
                        };
                        everPopup.im03_009open(param);
                    }
                }
            	if (colId == "VENDOR_CD") {
                	var param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': true,
                            'popupFlag': true
                        };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
            	// 반려사유
				if(colId == "REJECT_RMK") {
					var param = {
              				title : '반려사유',
              				message : grid.getCellValue(rowId, 'REJECT_RMK'),
              				callbackFunction : 'setRejectText',
                  			detailView : false,
              				rowId : rowId
              			};
            		var url = '/common/popup/common_text_input/view';
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
	        		if( grid.getCellValue(rowId, 'IMG_ATT_FILE_NUM_IMG') == '0' ) return;
	        		everPopup.readOnlyFileAttachPopup('IMAGE',grid.getCellValue(rowId, 'IMG_ATT_FILE_NUM'),'',rowId);
	        	}
	        	// 첨부파일 업로드
	        	if(colId == 'ATT_FILE_NUM_IMG') {
	        		if( grid.getCellValue(rowId, 'ATT_FILE_NUM_IMG') == '0' ) return;
	        		everPopup.readOnlyFileAttachPopup('RP',grid.getCellValue(rowId, 'ATT_FILE_NUM'),'',rowId);
	        	}
	        	// 접수자
	        	if(colId == 'ACPT_USER_NM') {
	        		if( grid.getCellValue(rowId, 'ACPT_USER_NM') == '' ) return;
	        		var param = {
		                     callbackFunction : "",
		                     USER_ID : grid.getCellValue(rowId, 'ACPT_USER_ID'),
		                     detailView : true
		                 };
		                 everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
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
	        	// 품목담당자
	        	if(colId == 'SG_USER_NM') {
	        		if( grid.getCellValue(rowId, 'SG_USER_NM') == '' ) return; // SG_USER_ID
	        		var param = {
		                     callbackFunction : "",
		                     USER_ID : grid.getCellValue(rowId, 'SG_USER_ID'),
		                     detailView : true
		                 };
		                 everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
	        	}
	        	// 공급사담당자
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

            if('${form.autoSearchFlag}' == 'Y') {

            	var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if(v.value == '200' || v.value == '300'|| v.value == '400' || v.value == '500' || v.value == '600' || v.value == '900' ) {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));

                doSearch();

            } else {
				// 22.08.26 progressCd multi-checkbox 수정
            	var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                	 if(v.value == '200' || v.value == '300'|| v.value == '400' || v.value == '500' || v.value == '600' || v.value == '900' ) { // 200 - 요청, 300 - 제안반려, 400 - 접수
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));

                doSearch();
            }
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("VENDOR_CD", "${ses.companyCd}");
            store.load(baseUrl + "IM03_031/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
               	grid.setColIconify("REJECT_RMK", "REJECT_RMK", "comment", false);
            });
        }

        function doItemReg() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if(grid.getSelRowCount()>1){
                return alert("${IM03_031_007}");
            }
            var rowIds = grid.getSelRowId();

            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "500") {
                    return alert("${IM03_031_002 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "200") {
                    return alert("${IM03_031_010 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "300") {
                	return alert("${IM03_031_003 }");
                }
                if(grid.getCellValue(rowIds[i], 'ITEM_CD') != "") {
                	return alert("${IM03_031_002 }");
                }
            }

            var param = {
                'RP_VENDOR_CD': grid.getCellValue(rowIds, 'VENDOR_CD'),
                'RP_NO': grid.getCellValue(rowIds, 'RP_NO'),
                'RP_SEQ': grid.getCellValue(rowIds, 'RP_SEQ'),
                'ITEM_DESC':grid.getCellValue(rowIds, 'ITEM_DESC'),
                'popupFlag': true,
                'detailView': false
            };

            everPopup.im03_009open(param);

        }

        function doAcpt() {
        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "500" || grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "600") {
                	return alert("${IM03_031_002 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "300") {
                	return alert("${IM03_031_003 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "400") {
                	return alert("${IM03_031_005 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "900") {
                    return alert("${IM03_031_008 }");
                }
            }

            if(!confirm("${msg.M0066}")) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
    		store.getGridData(grid, 'sel');
            store.load(baseUrl + 'IM03_031/doAcpt', function(){
           		alert(this.getResponseMessage());
           		doSearch();
           	});
        }

        function doReject() {
        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "500" || grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "600") {
                	return alert("${IM03_031_002 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "300") {
                	return alert("${IM03_031_003 }");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "400") {
                	return alert("${IM03_031_005 }");
                }
                if(grid.getCellValue(rowIds[i], 'REJECT_RMK') == "") {
                	grid.setCellBgColor(rowIds[i], "REJECT_RMK", '#fdd');
                	return alert("${IM03_031_004 }");
                }
            }

            if(!confirm("${msg.M0022}")) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
    		store.getGridData(grid, 'sel');
            store.load(baseUrl + 'IM03_031/doReject', function(){
           		alert(this.getResponseMessage());
           		doSearch();
           	});
        }

        function setRejectText(data){
        	grid.setCellValue(data.rowId, 'REJECT_RMK', data.message);
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        // 견적의뢰
        function doAsk(){
        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
            	if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "600") {
                	return alert("${IM03_031_002 }");
                }
            	if(grid.getCellValue(rowIds[i], 'SIGN_STATUS') == 'P') {
                	return alert("${IM03_031_011 }");
                }
            	if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "300") {
                	return alert("${IM03_031_003 }");
                }
            	if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "900") {
                    return alert("${IM03_031_008 }");
                }
            	if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "200") {
                    return alert("${IM03_031_010 }");
                }
            }

            var param = {
            	baseDataType: "VD",
            	prList: JSON.stringify(grid.getSelRowValue()),
            	CUR: 'KRW',
                detailView: false,
                popupFlag: true
            };
            everPopup.openPopupByScreenId("RQ0310", 1200, 900, param);
        }

        function doDelete(){
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'PROGRESS_CD') != '400' ) {
                    return alert("${IM03_031_012}");
                }

                if(grid.getCellValue(rowIds[i], 'REJECT_RMK') == "") {
                    grid.setCellBgColor(rowIds[i], "REJECT_RMK", '#fdd');
                    return alert("${IM03_031_004 }");
                }
            }

            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'IM03_031/doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }


    </script>

    <e:window id="IM03_031" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
            	<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="ADD_FROM_DATE" name="ADD_FROM_DATE" value="${oneMonthAgo }" toDate="ADD_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="ADD_TO_DATE" name="ADD_TO_DATE" value="${today }" fromDate="ADD_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
                <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
				<e:field>
					<e:inputHidden id="MAKER_CD" name="MAKER_CD" />
					<e:inputText id="MAKER_NM" name="MAKER_NM" value="" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="35%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="65%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false" />
                </e:field>
				<e:label for="ACPT_USER_NM" title="${form_ACPT_USER_NM_N}" />
				<e:field>
				<e:inputText id="ACPT_USER_NM" name="ACPT_USER_NM" value="" width="${form_ACPT_USER_NM_W}" maxLength="${form_ACPT_USER_NM_M}" disabled="${form_ACPT_USER_NM_D}" readOnly="${form_ACPT_USER_NM_RO}" required="${form_ACPT_USER_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doAcpt" name="doAcpt" label="${doAcpt_N}" onClick="doAcpt" disabled="${doAcpt_D}" visible="${doAcpt_V}"/>
            <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
            <e:button id="doItemReg" name="doItemReg" label="${doItemReg_N}" onClick="doItemReg" disabled="${doItemReg_D}" visible="${doItemReg_V}"/>
            <e:button id="doAsk" name="doAsk" label="${doAsk_N}" onClick="doAsk" disabled="${doAsk_D}" visible="${doAsk_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>