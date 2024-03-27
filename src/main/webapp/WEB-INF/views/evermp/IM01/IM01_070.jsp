<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM01/IM0101/";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "ITEM_CD") {
                	if( value == '' ) return;
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': false
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'ATT_FILE_CNT') {
                    if( value > 0 ){
                        var param = {
                            attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
                            rowId: rowId,
                            detailView: true,
                            bizType: 'IT',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == 'IMG_FILE_CNT') {
                    if( value > 0 ){
                        var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'IMG_ATT_FILE_NUM': grid.getCellValue(rowId, 'IMG_ATT_FILE_NUM'),
                            'MAIN_IMG_SQ': grid.getCellValue(rowId, 'MAIN_IMG_SQ'),
                            'popupFlag': true,
                            'detailView': true
                        };
                        everPopup.imgReadOnlyView(param);
                    }
                }
                if (colId == "VENDOR_NM") {
                	if( value == '' ) return;
                	var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
                if (colId == "SG_CTRL_USER_NM") {
                	if( value == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if (colId == 'PERIOD_CHANGE_REASON') {
		    		var param = {
		      				title : '기간변경사유',
		      				message : grid.getCellValue(rowId, 'PERIOD_CHANGE_REASON'),
		      				callbackFunction : 'callbackGridCHANGE_TEXT',
		          			detailView : false,
		      				rowId : rowId
		      			};
                	var url = '/common/popup/common_text_input/view';
		    	    everPopup.openModalPopup(url, 500, 320, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch(){
            var flag = true;
            $('input').each(function (k, v) {
                if (!(v.type == 'hidden' || v.type == 'radio' || v.id == 'grid_line' || v.id == 'grid-search')) {
                    if (v.value != '') {
                        flag = false;
                    }
                }
            });

            if(flag) {
                alert("${IM01_070_004}"); // 검색조건을 한개 이상 입력하여 주시기 바랍니다.
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "im01070_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds  = grid.getSelRowId();
            for( var i in rowIds ) {
            	if( grid.getCellValue(rowIds[0], 'SG_CTRL_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0 ) {
                    return alert("${IM01_070_007}"); // 상품담당자가 아닙니다.
                }
            }

            if (!confirm("${IM01_070_006}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im01070_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 견적의뢰
        function doEstimate(){

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	if( grid.getCellValue(rowIds[0], 'SG_CTRL_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0 ) {
                    return alert("${IM01_070_007}"); // 상품담당자가 아닙니다.
                }
            }

            var param = {
                	baseDataType: "GL",
                	prList: JSON.stringify(grid.getSelRowValue()),
                	CUR: 'KRW',
                    detailView: false,
                    popupFlag: true
                };
            everPopup.openPopupByScreenId("RQ0310", 1200, 900, param);

        }

        function callbackGridCHANGE_TEXT(data) {
            grid.setCellValue(data.rowId, "PERIOD_CHANGE_REASON", data.message);
        }

        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNm",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '${ses.companyCd}',  // 고객사코드or회사코드
                'custNm' : '${ses.companyNm}'  // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _getItemClsNmCust()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNmCust",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '21',  // 고객사코드or회사코드
                'custNm' : '㈜소노인터내셔널' // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }


        function _setItemClassNmCust(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1_CUST").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2_CUST").setValue("");}else{EVF.C("ITEM_CLS2_CUST").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3_CUST").setValue("");}else{EVF.C("ITEM_CLS3_CUST").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4_CUST").setValue("");}else{EVF.C("ITEM_CLS4_CUST").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM_CUST").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1_CUST").setValue("");
                EVF.C("ITEM_CLS2_CUST").setValue("");
                EVF.C("ITEM_CLS3_CUST").setValue("");
                EVF.C("ITEM_CLS4_CUST").setValue("");
                EVF.C("ITEM_CLS_NM_CUST").setValue("");
            }
        }

        function _setItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }
        function _getSGClsNm(){

            var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
            var param = {
                callBackFunction: '_setSg',
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
        }

        function _setSg(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("SG_NUM1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("SG_NUM2").setValue("");}else{EVF.C("SG_NUM2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("SG_NUM3").setValue("");}else{EVF.C("SG_NUM3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("SG_NUM4").setValue("");}else{EVF.C("SG_NUM4").setValue(data.ITEM_CLS4);}
                EVF.C("SG_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("SG_NUM1").setValue("");
                EVF.C("SG_NUM2").setValue("");
                EVF.C("SG_NUM3").setValue("");
                EVF.C("SG_NUM4").setValue("");
                EVF.C("SG_NM").setValue("");
            }
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        function searchBrandCd(){
            var param = {
                callBackFunction : "selectBrandCd"
            };
            everPopup.openCommonPopup(param, 'SP0088');
        }

        function selectBrandCd(dataJsonArray) {
            EVF.V("BRAND_CD",dataJsonArray.MKBR_CD);
            EVF.V("BRAND_NM",dataJsonArray.MKBR_NM);
        }

        function doPrint(){
            var param = {
                'detailView': false
            };
            everPopup.DirectEstimate(param);
        }

        function doapplyDate() {
        	var validFromDate = EVF.C("VALID_FROM_DATE").getValue();
			var validToDate = EVF.C("VALID_TO_DATE").getValue();

	        var rowIds = grid.getSelRowId();
	        for(var i = rowIds.length -1; i >= 0; i--) {
	        	if(validFromDate!='') {
		            grid.setCellValue(rowIds[i], "VALID_FROM_DATE",validFromDate);
	        	}
	        	if(validToDate!='') {
		            grid.setCellValue(rowIds[i], "VALID_TO_DATE",validToDate);
	        	}
	        }
        }
        //정식코드전환
		function doChangeDt(){
			var selectedRow = grid.getSelRowValue()[0];

			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

			if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
				return alert("${msg.M0006}"); //하나 이상 선택할 수 없습니다.
			}
			//임시품목만 전환가능.
			if (selectedRow.TEMP_CD_FLAG !='1'){
				return alert('${IM01_070_008}');
			}
			//상품상태 사용일시.
			if (selectedRow.ITEM_STATUS !='10'){
				return alert('${IM01_070_009}');
			}
			//임시품목 정식전환 결재 신청이나 승인일시.
			if (selectedRow.SIGN_STATUS =='E' || selectedRow.SIGN_STATUS =='P'){
				return alert('${IM01_070_010}');
			}
			var param = {
					'ITEM_CD' 	  : selectedRow.ITEM_CD,
                    'changeDt'	  : 'cd',
                    'popupFlag'	  : true,
                    'detailView'  : false
                };
                everPopup.im03_009open(param);
		}
    </script>

    <e:window id="IM01_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field>
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
                </e:field>

				<e:label for="ITEM_CLS_NM_CUST" title="${form_ITEM_CLS_NM_CUST_N}"/>
				<e:field>
				<e:search id="ITEM_CLS_NM_CUST" name="ITEM_CLS_NM_CUST" value="" width="${form_ITEM_CLS_NM_CUST_W}" maxLength="${form_ITEM_CLS_NM_CUST_M}" onIconClick="_getItemClsNmCust" disabled="${form_ITEM_CLS_NM_CUST_D}" readOnly="${form_ITEM_CLS_NM_CUST_RO}" required="${form_ITEM_CLS_NM_CUST_R}" />
                    <e:inputHidden id="ITEM_CLS1_CUST" name="ITEM_CLS1_CUST" />
                    <e:inputHidden id="ITEM_CLS2_CUST" name="ITEM_CLS2_CUST" />
                    <e:inputHidden id="ITEM_CLS3_CUST" name="ITEM_CLS3_CUST" />
                    <e:inputHidden id="ITEM_CLS4_CUST" name="ITEM_CLS4_CUST" />
				</e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:inputHidden id="MAKER_CD" name="MAKER_CD"/>
                <e:inputHidden id="MAKER_PART_NO" name="MAKER_PART_NO"/>
                <e:inputHidden id="BRAND_CD" name="BRAND_CD"/>
                <e:inputHidden id="BRAND_NM" name="BRAND_NM"/>
            </e:row>
            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD"  value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
                <e:field>
                    <e:select id="ITEM_STATUS" name="ITEM_STATUS" value="10" options="${itemStatusOptions}" width="40%" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
					<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="60%" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="TEMP_CD_FLAG" title="${form_TEMP_CD_FLAG_N}"/>
                <e:field>
                    <e:select id="TEMP_CD_FLAG" name="TEMP_CD_FLAG" value="0" options="${tempCdFlagOptions}" width="40%" disabled="${form_TEMP_CD_FLAG_D}" readOnly="${form_TEMP_CD_FLAG_RO}" required="${form_TEMP_CD_FLAG_R}" placeHolder="" />
                    <e:select id="UNIT_PRC_VALID_YN" name="UNIT_PRC_VALID_YN" value="1" options="${unitPrcValidYnOptions}" width="60%" disabled="${form_UNIT_PRC_VALID_YN_D}" readOnly="${form_UNIT_PRC_VALID_YN_RO}" required="${form_UNIT_PRC_VALID_YN_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${formData.SG_CTRL_USER_ID}" options="${itemUserOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
				<e:label for="DATE_TYPE">
					<e:select id="DATE_TYPE" name="DATE_TYPE" value="02" options="${dateTypeOptions}" readOnly="${form_DATE_TYPE_RO }" width="99" required="${form_DATE_TYPE_R }" disabled="${form_DATE_TYPE_D }"  usePlaceHolder="false">
						<e:option text="등록일자" value="01">등록일자</e:option>
						<e:option text="계약종료일자" value="02">계약종료일자</e:option>
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${not empty param.FROM_DATE ? param.FROM_DATE : fromDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${not empty param.TO_DATE ? param.TO_DATE : toDate}" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>
                <e:label for="SEARCH_COUNT_CD" title="${form_SEARCH_COUNT_CD_N}"/>
                <e:field>
                    <e:select id="SEARCH_PAGE_NO" name="SEARCH_PAGE_NO" value="1" options="${searchPageNoOptions}" width="40%" disabled="${form_SEARCH_PAGE_NO_D}" readOnly="${form_SEARCH_PAGE_NO_RO}" required="${form_SEARCH_PAGE_NO_R}" placeHolder="" usePlaceHolder="false"/>
                    <e:select id="SEARCH_COUNT_CD" name="SEARCH_COUNT_CD" value="500" options="${searchCountCdOptions}" width="60%" disabled="${form_SEARCH_COUNT_CD_D}" readOnly="${form_SEARCH_COUNT_CD_RO}" required="${form_SEARCH_COUNT_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:text style="color:black;font-weight:bold;">${IM01_070_TITLE1}&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
            <%--
			<e:inputDate id="VALID_FROM_DATE" name="VALID_FROM_DATE" toDate="VALID_TO_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_VALID_FROM_DATE_R}" disabled="${form_VALID_FROM_DATE_D}" readOnly="${form_VALID_FROM_DATE_RO}" />
			<e:text>~</e:text>
			<e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE"  fromDate="VALID_FROM_DATE"  value="" width="${inputDateWidth}" datePicker="true" required="${form_VALID_TO_DATE_R}" disabled="${form_VALID_TO_DATE_D}" readOnly="${form_VALID_TO_DATE_RO}" />
			<e:text>&nbsp;&nbsp;</e:text>
			<e:button id="applyDate" name="applyDate" label="${applyDate_N}" onClick="doapplyDate" disabled="${applyDate_D}" align="left"  visible="${applyDate_V}"/>
            --%>
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Estimate" name="Estimate" label="${Estimate_N}" onClick="doEstimate" disabled="${Estimate_D}" visible="${Estimate_V}"/>
			<e:button id="doChangeDt" name="doChangeDt" label="${doChangeDt_N}" onClick="doChangeDt" disabled="${doChangeDt_D}" visible="${doChangeDt_V}"/>
            <%--
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
            --%>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>