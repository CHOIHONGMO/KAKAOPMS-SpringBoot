<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/RQ01/RQ0102/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
				
            	if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
            	if(colId == 'VENDOR_NM') {
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
            	if(colId == 'ITEM_REQ_NO') {
					var progressCd = grid.getCellValue(rowId, 'PROGRESS_CD');
                	var param = {
        	    		CUST_CD: grid.getCellValue(rowId, 'CUST_CD'),
        	    		ITEM_REQ_NO: grid.getCellValue(rowId, 'ITEM_REQ_NO'),
        	    		ITEM_REQ_SEQ: grid.getCellValue(rowId, 'ITEM_REQ_SEQ'),
        	    		detailView: (progressCd == "T" || progressCd == "R") ? false : true,
        	    		popupFlag: true
        			};
                    everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
                }
            	if(colId == 'RFQ_NUM') {
                    var param = {
                            RFQ_NUM : grid.getCellValue(rowId, 'RFQ_NUM'),
                            RFQ_CNT : grid.getCellValue(rowId, 'RFQ_CNT'),
                            sendType: 'E',
                            callBackFunction : '',
                            detailView: true,
                            popupFlag : true
                        };
                     everPopup.openPopupByScreenId("RQ01_011", 1000, 850, param);
                }
                if(colId == 'QTA_FILE_CNT') {
                    var param = {
                        havePermission: false,
                        attFileNum: grid.getCellValue(rowId, 'QTA_FILE_NUM'),
                        callBackFunction: '',
                        bizType: 'QTA',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'LEADTIME_RMK') {
                	if(!EVF.isEmpty(grid.getCellValue(rowId, "LEADTIME_RMK"))) {
	                	var param = {
	                        title : "표준납기사유",
	                        message : grid.getCellValue(rowId, "LEADTIME_RMK"),
	                        callbackFunction : "",
	                        detailView : true,
	                        rowId : rowId
	                    };
	                    var url = "/common/popup/common_text_input/view";
	                    everPopup.openModalPopup(url, 500, 320, param);
                	}
                }
                if(colId === "QTA_REMARK") {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "QTA_REMARK"))) {
                    	var param = {
    	                        title : "공급사특이사항",
    	                        message : grid.getCellValue(rowId, "QTA_REMARK"),
    	                        callbackFunction : "",
    	                        detailView : true,
    	                        rowId : rowId
    	                    };
   	                    var url = "/common/popup/common_text_input/view";
   	                    everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
             	// 상품담당자
                if(colId == 'CTRL_USER_NM') {
                    if( grid.getCellValue(rowId, 'CTRL_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.setProperty('shrinkToFit', false);
            grid.setProperty('singleSelect', false);
            grid.setColIconify("RMK_TEXT_NUM_IMG", "RMK_TEXT_NUM", "comment", false);
            grid.setColIconify("SOURCING_REJECT_RMK", "SOURCING_REJECT_RMK", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            EVF.C("PROGRESS_CD").removeOption("T");
            EVF.C("PROGRESS_CD").removeOption("R");
            EVF.C("PROGRESS_CD").removeOption("100");
            EVF.C("PROGRESS_CD").removeOption("110");
            EVF.C("PROGRESS_CD").removeOption("300");
            EVF.C("PROGRESS_CD").removeOption("400");
            EVF.C("PROGRESS_CD").removeOption("440");
            EVF.C("PROGRESS_CD").removeOption("450");
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "rq01030_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doConfirm() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if (grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${RQ01_030_005}");
                }
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "500") {
                    return alert("${RQ01_030_002}");
                }
                if(grid.getCellValue(rowIds[i], 'ERP_IF_FLAG') == "T" && EVF.isEmpty(grid.getCellValue(rowIds[i], 'CUST_ITEM_CD'))) {
                    return alert("${RQ01_030_008}");
                }
            }

            if(confirm("${RQ01_030_007 }")) {
	            var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.doFileUpload(function() {
	                store.load(baseUrl + 'rq01030_doConfirm', function() {
	                    alert(this.getResponseMessage());
	                    doSearch();
	                });
	            });
            }
        }

      	//고객사 팝업
	    function selectBuyer(){

			var param = {
					callBackFunction : 'callback_setBuyer'
				}
			everPopup.openCommonPopup(param, 'SP0902');
		}

		function callback_setBuyer(data){
			EVF.V("CUST_CD", data.CUST_CD);
			EVF.V("CUST_NM", data.CUST_NM);
		}

		// 공급사 팝업
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

    </script>

    <e:window id="RQ01_030" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="COMBO_BOX">
                    <e:select id="COMBO_BOX" name="COMBO_BOX" usePlaceHolder="false" width="99" required="${form_COMBO_BOX_R}" disabled="${form_COMBO_BOX_D }" readOnly="${form_COMBO_BOX_RO}" >
                        <e:option text="${RQ01_030_003}" value="E">E</e:option>
                        <e:option text="${RQ01_030_004}" value="C">C</e:option>
                    </e:select>
                </e:label>
                <e:field>
					<e:inputDate id="FROM_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="${toDate }" fromDate="FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserIdOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="500" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
                <e:label for="ITEM_NM" title="${form_ITEM_NM_N}" />
				<e:field>
					<e:inputText id="ITEM_NM" name="ITEM_NM" value="" width="${form_ITEM_NM_W}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="btn" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Confirm" name="Confirm" label="${Confirm_N}" onClick="doConfirm" disabled="${Confirm_D}" visible="${Confirm_V}"/>
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>