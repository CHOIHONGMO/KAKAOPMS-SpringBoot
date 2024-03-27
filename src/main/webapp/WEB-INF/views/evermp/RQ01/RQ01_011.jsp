<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/RQ01/RQ0101/";
        var sendType;

        function init() {

        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-ATT_FILE_NUM').css('display','none');
        	}

            sendType = "${param.sendType}";

            grid = EVF.C("grid");

        	gridL = EVF.C("gridL");
            gridL.showCheckBar(false);

            grid.setProperty("shrinkToFit", ${shrinkToFit});

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            });

            grid.delRowEvent(function() {

                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var rowIds = grid.getSelRowId();
                for(var i in rowIds) {
                    if(grid.getCellValue(rowIds[i], 'REQUIRED_FLAG') == "Y") {
                        return alert("${RQ01_011_010}");
                    }
                }
                grid.delRow();
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridL.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        ITEM_CD: gridL.getCellValue(rowId, 'ITEM_CD'),
                        detailView: true,
                        popupYn: "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'CUST_NM') {
                    var param = {
                        CUST_CD: gridL.getCellValue(rowId, 'CUST_CD'),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
                if(colId == 'REQUEST_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: gridL.getCellValue(rowId, 'REQUEST_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            changeVendorOpenType();

            var store = new EVF.Store();
            store.setParameter("sendType", sendType);
            store.setParameter("ITEM_CD_STR", "${param.ITEM_CD_STR}");
            store.setGrid([gridL]);
            store.load(baseUrl + "rq01011_doSearchItems", function() {
                setSubject();
            });

         	// 재 작성(수정)
            if(sendType == "E") {
                store = new EVF.Store();
                store.setParameter("RFQ_NUM", "${formData.RFQ_NUM}");
                store.setParameter("RFQ_CNT", "${formData.ORI_RFQ_CNT}");
                store.load(baseUrl + "getPreRfqVendorList", function() {setVendor(this.getParameter("vendorList"));}, false);
 	        } // 재 견적
            else if(sendType == "R"){
                store = new EVF.Store();
                store.setParameter("RFQ_NUM", "${formData.RFQ_NUM}");
                store.setParameter("RFQ_CNT", "${formData.ORI_RFQ_CNT}");
                store.load(baseUrl + "getPreRfqVendorList", function() {setVendor(this.getParameter("vendorList"));}, false);
                EVF.C('TempSave').setVisible(false);
            }
        }

        // 견적 요청서 임시저장(T), 협력업체 전송(E)
        function doSave() {
        	grid.checkAll(true);
        	gridL.checkAll(true);
            var store = new EVF.Store();
            if(!store.validate()) { return; }

            var validCloseDate = Number(EVF.C("RFQ_CLOSE_DATE").getValue()) + EVF.C("RFQ_CLOSE_HOUR").getValue() + EVF.C("RFQ_CLOSE_MIN").getValue();
            if ("${today}" + "${todayTime}" > validCloseDate) { return alert('${RQ01_011_005}'); }
            if (EVF.C("RFQ_CLOSE_DATE").getValue() > EVF.C("CONT_START_DATE").getValue()) { return alert('${RQ01_011_006}'); }

            if (grid.getSelRowCount() == 0) { return alert("${RQ01_011_004}"); }

            var rowIds = grid.getSelRowId();
            var vendorCnt = 0;
            var vendorCdStr = "";
            for(var i in rowIds) {
                vendorCdStr = vendorCdStr + grid.getCellValue(rowIds[i], 'VENDOR_CD') + ",";
                vendorCnt++;
            }
            if(vendorCdStr.length > 0) { vendorCdStr = vendorCdStr.substring(0, vendorCdStr.length-1); }
            EVF.C("VENDOR_LIST").setValue(vendorCdStr);

            if(EVF.C("VENDOR_OPEN_TYPE").getValue() == "QN") {
                if(vendorCnt > 1) { return alert("${RQ01_011_008}"); }
            } else {
                if(vendorCnt == 1) { return alert("${RQ01_011_009}"); }
            }

            // T:임시저장, E:협력업체전송
            var signStatus = this.data;
            if (signStatus == "E") {
            	if(!confirm('${RQ01_011_003}')) return;
            }

            store.doFileUpload(function() {
                var rtnData = [{
                    "VENDOR_LIST" : EVF.C("VENDOR_LIST").getValue(),
                    "RFQ_SUBJECT" : EVF.C("RFQ_SUBJECT").getValue(),
                    "VENDOR_OPEN_TYPE" : EVF.C("VENDOR_OPEN_TYPE").getValue(),
                    "RFQ_CLOSE_DATE" : EVF.C("RFQ_CLOSE_DATE").getValue(),
                    "RFQ_CLOSE_HOUR" : EVF.C("RFQ_CLOSE_HOUR").getValue(),
                    "RFQ_CLOSE_MIN" : EVF.C("RFQ_CLOSE_MIN").getValue(),
                    "DEAL_TYPE" : EVF.C("DEAL_TYPE").getValue(),
                    "CONT_START_DATE" : EVF.C("CONT_START_DATE").getValue(),
                    "CONT_END_DATE" : EVF.C("CONT_END_DATE").getValue(),
                    "RMK_TEXT" : EVF.C("RMK_TEXT").getValue(),
                    "ATT_FILE_NUM" : EVF.C("ATT_FILE_NUM").getValue(),
                    "OPTION_RFQ_REASON" : EVF.C("OPTION_RFQ_REASON").getValue(),
                    "RFQ_NUM" : EVF.C("RFQ_NUM").getValue(),
                    "NEW_RFQ_CNT" : EVF.C("NEW_RFQ_CNT").getValue(),
                    "ORI_RFQ_CNT" : EVF.C("ORI_RFQ_CNT").getValue(),
                    "RFQ_TYPE" : EVF.C("RFQ_TYPE").getValue(),
                    /*"DELY_EXPECT_REGION" : EVF.C("DELY_EXPECT_REGION").getValue(),*/
                    "sendType" : sendType,
                    "signStatus" : signStatus
                }];
                opener.window['${param.callBackFunction}'](JSON.stringify(rtnData));
                doClose();
            });
        }

        function doSearchVendor() {
            var param = {
                ITEM_CD_STR: "${param.ITEM_CD_STR}",
                'callBackFunction': "setVendor",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_012", 1000, 700, param);
        }

        function dosearchVendorMy() {
            var param = {
                ITEM_CD_STR: "${param.ITEM_CD_STR}",
                'callBackFunction': "setVendor",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_013", 1000, 700, param);
        }

        function setVendor(dataJsonStr) {
            var vendors = JSON.parse(dataJsonStr);
            for(idx in vendors) {
                var addParam = [{
                    "VENDOR_CD" : vendors[idx].VENDOR_CD,
                    "VENDOR_NM" : vendors[idx].VENDOR_NM,
                    "REGION_CD" : vendors[idx].REGION_CD,
                    "REGION_NM" : vendors[idx].REGION_NM,
                    "CEO_USER_NM" : vendors[idx].CEO_USER_NM,
                    "INDUSTRY_TYPE" : vendors[idx].INDUSTRY_TYPE,
                    "MAJOR_ITEM_NM" : vendors[idx].MAJOR_ITEM_NM,
                    "MAKER_NM" : vendors[idx].MAKER_NM,
                    "BUSINESS_TYPE" : vendors[idx].BUSINESS_TYPE,
                    "CREDIT_CD" : vendors[idx].CREDIT_CD,
                    "SG_TXT" : vendors[idx].SG_TXT,
                    "REQUIRED_FLAG" : (EVF.isEmpty(vendors[idx].REQUIRED_FLAG) ? "N" : vendors[idx].REQUIRED_FLAG)
                }];
                var validData = valid.equalPopupValid(JSON.stringify(addParam), grid, "VENDOR_CD");
                grid.addRow(validData);
            }
            var vendorCdStr = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                vendorCdStr = vendorCdStr + grid.getCellValue(rowIds[i], 'VENDOR_CD') + ",";
            }
            if(vendorCdStr.length > 0) { vendorCdStr = vendorCdStr.substring(0, vendorCdStr.length-1); }
            EVF.C("VENDOR_LIST").setValue(vendorCdStr);
        }

        function setItem(dataJsonStr) {
            var items = JSON.parse(dataJsonStr);
            for(idx in items) {
                var addParam = [{
                    "VENDOR_CD" : items[idx].VENDOR_CD,
                    "VENDOR_NM" : items[idx].VENDOR_NM,
                    "REGION_CD" : items[idx].REGION_CD,
                    "REGION_NM" : items[idx].REGION_NM,
                    "SG_NUM" : items[idx].SG_NUM,
                    "SG_TXT" : items[idx].SG_TXT,
                    "REQUIRED_FLAG" : (EVF.isEmpty(vendors[idx].REQUIRED_FLAG) ? "N" : vendors[idx].REQUIRED_FLAG)
                }];
                var validData = valid.equalPopupValid(JSON.stringify(addParam), grid, "VENDOR_CD");
                grid.addRow(validData);
            }
            var vendorCdStr = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                vendorCdStr = vendorCdStr + grid.getCellValue(rowIds[i], 'VENDOR_CD') + ",";
            }
            if(vendorCdStr.length > 0) { vendorCdStr = vendorCdStr.substring(0, vendorCdStr.length-1); }
            EVF.C("VENDOR_LIST").setValue(vendorCdStr);
        }

        // 단독수의 인 경우에만 활성화
        function changeVendorOpenType() {
            if(EVF.C("VENDOR_OPEN_TYPE").getValue() == "QN") {
                EVF.C('OPTION_RFQ_REASON').setRequired(true);
                EVF.C('OPTION_RFQ_REASON').setDisabled(false);
            } else {
                EVF.C('OPTION_RFQ_REASON').setRequired(false);
                EVF.C('OPTION_RFQ_REASON').setDisabled(true);
            }
        }

        function doClose() {
            formUtil.close();
        }

        function setSubject(){
            if("${formData.sendType}" == 'R'){
                let subjectR = '[' + "재견적" + '] ' + '[' + "코드상품" + '] ' + gridL.getCellValue('0','ITEM_DESC') + ' 外 ' + String(gridL.getRowCount()-1).padStart(4,'0') + '건';
                EVF.V('RFQ_SUBJECT', subjectR);
            } else {
            let subject = '[' + "코드상품" + '] ' + gridL.getCellValue('0','ITEM_DESC') + ' 外 ' + String(gridL.getRowCount()-1).padStart(4,'0') + '건';
                EVF.V('RFQ_SUBJECT', subject);
            }
        }

    </script>

    <e:window id="RQ01_011" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar id="btnT" align="right" width="100%" title="요청정보">
			<e:button id="TempSave" name="TempSave" label="${TempSave_N}" disabled="${TempSave_D}" visible="${TempSave_V}" onClick="doSave" data="T" />
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" data="E" />
			<e:button id="Close" name="Close" label="${Close_N}" onClick="doClose" disabled="${Close_D}" visible="${Close_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="${formData.RFQ_NUM}" />
            <e:inputHidden id="ORI_RFQ_CNT" name="ORI_RFQ_CNT" value="${formData.ORI_RFQ_CNT}" />	<!-- 기존견적 수정에서 사용 -->
            <e:inputHidden id="NEW_RFQ_CNT" name="NEW_RFQ_CNT" value="${formData.NEW_RFQ_CNT}" />	<!-- 재견적에서 사용 -->
            <e:inputHidden id="RFQ_TYPE" name="RFQ_TYPE" value="${formData.RFQ_TYPE}" />
            <e:inputHidden id="VENDOR_LIST" name="VENDOR_LIST" value="" />
            <e:inputHidden id="sendType" name="sendType" value="${formData.sendType}" /> <!-- F:최초작성, E:재작성(수정), R(재견적) -->

            <e:row>
                <e:label for="RFQ_SUBJECT" title="${form_RFQ_SUBJECT_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="RFQ_SUBJECT" name="RFQ_SUBJECT" value="" width="${form_RFQ_SUBJECT_W}" maxLength="${form_RFQ_SUBJECT_M}" disabled="${form_RFQ_SUBJECT_D}" readOnly="${form_RFQ_SUBJECT_RO}" required="${form_RFQ_SUBJECT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="RFQ_NUM_CNT" title="${form_RFQ_NUM_CNT_N}"/>
                <e:field>
                	<!-- 최초 견적 -->
                    <c:if test="${empty formData.RFQ_NUM }">
                        <e:text>&nbsp;</e:text>
                    </c:if>
                    <!-- 재 작성 : 기존 작성중인 견적서 수정 -->
                    <c:if test="${not empty formData.RFQ_NUM && formData.sendType == 'E' }">
   	                    <e:text style="font-weight: bold;"> ${formData.RFQ_NUM}&nbsp;/&nbsp;${formData.ORI_RFQ_CNT}</e:text>
                    </c:if>
                    <!-- 재 견적 : 이전 차수의 견적정보를 가져와서 재견적서 작성 -->
                    <c:if test="${not empty formData.RFQ_NUM && formData.sendType == 'R' }">
   	                    <e:text style="font-weight: bold;"> ${formData.RFQ_NUM}&nbsp;/&nbsp;${formData.NEW_RFQ_CNT }</e:text>
                    </c:if>
                </e:field>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${formData.VENDOR_OPEN_TYPE }" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" onChange="changeVendorOpenType" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="RFQ_CLOSE_DATE" title="${form_RFQ_CLOSE_DATE_N}"/>
                <e:field>
                    <e:inputDate id="RFQ_CLOSE_DATE" name="RFQ_CLOSE_DATE"  value="${empty formData.RFQ_CLOSE_DATE ? rfqCloseDate : formData.RFQ_CLOSE_DATE }"  width="${inputDateWidth}" datePicker="true" required="${form_RFQ_CLOSE_DATE_R}" disabled="${form_RFQ_CLOSE_DATE_D}" readOnly="${form_RFQ_CLOSE_DATE_RO}" />
                    <e:text>&nbsp;</e:text>
                    <e:select id="RFQ_CLOSE_HOUR" name="RFQ_CLOSE_HOUR" value="${empty formData.RFQ_CLOSE_HOUR ? '12' : formData.RFQ_CLOSE_HOUR }" options="${rfqCloseHourOptions}" width="75px" disabled="${form_RFQ_CLOSE_HOUR_D}" readOnly="${form_RFQ_CLOSE_HOUR_RO}" required="${form_RFQ_CLOSE_HOUR_R}" placeHolder="" />
                    <e:text>${RQ01_011_001}</e:text>
                    <e:select id="RFQ_CLOSE_MIN" name="RFQ_CLOSE_MIN" value="${empty formData.RFQ_CLOSE_MIN ? '00' : formData.RFQ_CLOSE_MIN }" options="${rfqCloseMinOptions}" width="75px" disabled="${form_RFQ_CLOSE_MIN_D}" readOnly="${form_RFQ_CLOSE_MIN_RO}" required="${form_RFQ_CLOSE_MIN_R}" placeHolder="" />
                    <e:text>${RQ01_011_002}</e:text>
                </e:field>
                <e:label for="DEAL_TYPE" title="${form_DEAL_TYPE_N}"/>
                <e:field>
                    <e:select id="DEAL_TYPE" name="DEAL_TYPE" value="${empty formData.DEAL_TYPE ? '01' : formData.DEAL_TYPE}" options="${dealTypeOptions}" width="${form_DEAL_TYPE_W}" disabled="${form_DEAL_TYPE_D}" readOnly="${form_DEAL_TYPE_RO}" required="${form_DEAL_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N}"/>
                <e:field>
                    <e:inputDate id="CONT_START_DATE" name="CONT_START_DATE" toDate="CONT_END_DATE" value="${empty formData.CONT_START_DATE ? contStartDate : formData.CONT_START_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_CONT_START_DATE_R}" disabled="${form_CONT_START_DATE_D}" readOnly="${form_CONT_START_DATE_RO}" />
                </e:field>
                <e:label for="CONT_END_DATE" title="${form_CONT_END_DATE_N}"/>
                <e:field>
                    <e:inputDate id="CONT_END_DATE" name="CONT_END_DATE" fromDate="CONT_START_DATE" value="${empty formData.CONT_END_DATE ? contEndDate : formData.CONT_END_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_CONT_END_DATE_R}" disabled="${form_CONT_END_DATE_D}" readOnly="${form_CONT_END_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="RMK_TEXT" title="${form_RMK_TEXT_N }" />
                <e:field colSpan="3">
                    <e:richTextEditor id="RMK_TEXT" name="RMK_TEXT" width="100%" height="150px" value="${formData.RMK_TEXT }" required="${form_RMK_TEXT_R }" readOnly="${form_RMK_TEXT_RO }" disabled="${form_RMK_TEXT_D }" useToolbar="${!param.detailView}" />
                    <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${formData.RMK_TEXT_NUM }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
                <e:field>
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="RFQ" fileId="${formData.ATT_FILE_NUM}" readOnly="${param.detailView }" downloadable="true" width="100%" height="80px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
                </e:field>
	            <e:label for="OPTION_RFQ_REASON" title="${form_OPTION_RFQ_REASON_N}"/>
	            <e:field  >
	                <e:textArea id="OPTION_RFQ_REASON" name="OPTION_RFQ_REASON" value="${formData.OPTION_RFQ_REASON }" height="120px" width="100%" maxLength="${form_OPTION_RFQ_REASON_M}" disabled="${form_OPTION_RFQ_REASON_D}" readOnly="${form_OPTION_RFQ_REASON_RO}" required="${form_OPTION_RFQ_REASON_R}" />
	            </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="btnG" align="right" width="100%">
			<e:button id="searchVendorMy" name="searchVendorMy" label="${searchVendorMy_N}" onClick="dosearchVendorMy" disabled="${searchVendorMy_D}" visible="${searchVendorMy_V}"/>
	    	<e:button id="SearchVendor" name="SearchVendor" label="${SearchVendor_N}" disabled="${SearchVendor_D}" visible="${SearchVendor_V}" onClick="doSearchVendor" />
        </e:buttonBar>

        <e:panel id="panelLeft" width="70%" height="fit">
            <e:gridPanel id="gridL" name="gridL" width="100%" height="fit" gridType="${_gridType}" readOnly="${empty param.detailView ? false :  param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
		</e:panel>

        <e:panel id="blank_pn" height="100%" width="1%">&nbsp;</e:panel>

        <e:panel id="panelRight" width="29%" height="fit">
             <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</e:panel>

    </e:window>
</e:ui>