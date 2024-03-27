<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
        grid = EVF.C("grid");

		EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PURCHASE_TYPE').removeOption('OMRO'); // 해외MRO

		grid.setProperty('multiselect', false);grid.setProperty('panelVisible', ${panelVisible});

        EVF.C('PROGRESS_CD').removeOption('2300');
        EVF.C('PROGRESS_CD').removeOption('2350');
        EVF.C('PROGRESS_CD').removeOption('2355');
        EVF.C('PROGRESS_CD').removeOption('2330');
        EVF.C('PROGRESS_CD').removeOption('2335');



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

        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	//alert("celName===="+celName);
        	if (celName == "RFX_NUM") {
                var param = {
                    gateCd: grid.getCellValue(rowId, "GATE_CD"),
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxType: grid.getCellValue(rowId, "RFX_TYPE"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openRfxDetailInformation(param);
            }
        	else if (celName == "VENDOR_NM") {
	            var params = {
	                VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }
        	else if (celName == "QTA_NUM") {
            	if (grid.getCellValue(rowId,'QTA_NUM') == '') return;
    	        var param = {
    		            gateCd: grid.getCellValue(rowId,'${ses.gateCd}'),
    		            rfxNum: grid.getCellValue(rowId,'RFX_NUM'),
    		            qtaNum : grid.getCellValue(rowId,'QTA_NUM'),
    		            rfxCnt: grid.getCellValue(rowId,'RFX_CNT'),
    		            //rfxType: selectedRow['RFX_TYPE'],
    		            popupFlag: true,
    		            //callBackFunction: "doSearch"
    		            detailView: true,
    		            "isPrefferedBidder": false,
    		            "buttonStatus" : 'Y',
    		            vendorCd: grid.getCellValue(rowId,'VENDOR_CD')
    		    };
    		    everPopup.openPopupByScreenId('DH2140', 1000, 800, param);



        	}

        });

        //doSearch();
    }

    //조회
    function doSearch() {

        if (!everDate.fromTodateValid('ADD_DATE_FROM', 'ADD_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + "BSOX_240/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }



	function doSelectPurchaseUser() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectPurchaseUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }
    function selectPurchaseUser(dataJsonArray) {
	    //dataJsonArray = $.parseJSON(dataJsonArray);
        EVF.getComponent("OP_USER_NM").setValue(dataJsonArray.USER_NM);
        //EVF.getComponent("INSPECT_USER_ID").setValue(dataJsonArray.USER_ID);
    }
    function doSearchVendor() {
    	everPopup.openCommonPopup({
            callBackFunction: "selectVendor"
        }, 'SP0013');
    }
    function selectVendor(data) {
        EVF.getComponent("VENDOR_NM").setValue(data['VENDOR_NM']);
    }


    </script>


    <e:window id="BSOX_240" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:row>
                <e:label for="">
                    <e:select id="DATE_TYPE" name="DATE_TYPE" usePlaceHolder="false" width="100" required="${form_DATE_TYPE_R}" disabled="${form_DATE_TYPE_D }" readOnly="${form_DATE_TYPE_RO}" >
                        <e:option text="${form_RFQ_CLOSE_DATE_N}" value="C">C</e:option>
                        <e:option text="${form_REG_DATE_N}" value="R">R</e:option>
                        <e:option text="${form_RFQ_START_DATE_N}" value="S">S</e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="ADD_DATE_FROM" toDate="ADD_DATE_TO" name="ADD_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_R}" disabled="${form_ADD_DATE_D}" readOnly="${form_ADD_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="ADD_DATE_TO" fromDate="ADD_DATE_FROM" name="ADD_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_R}" disabled="${form_ADD_DATE_D}" readOnly="${form_ADD_DATE_RO}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
					<e:field>
					<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" style='ime-mode:inactive' name="RFX_NUM" value="${form.RFX_NUM}" width="${inputTextWidth }" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				</e:field>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
                    <e:inputText id="RFX_SUBJECT" style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="90%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<e:label for="SUBMIT_TYPE" title="${form_SUBMIT_TYPE_N}"/>
				<e:field>
					<e:select id="SUBMIT_TYPE" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitTypeOptions}" width="${inputTextWidth}" disabled="${form_SUBMIT_TYPE_D}" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
			    <e:label for="PURCHASE_NM" title="${form_PURCHASE_NM_N}"/>
				<e:field>
					<e:search id="PURCHASE_NM" style="${imeMode}" name="PURCHASE_NM" value="${ses.userNm }" width="${inputTextWidth}" maxLength="${form_PURCHASE_NM_M}" onIconClick="${form_PURCHASE_NM_RO ? 'everCommon.blank' : 'doSelectPurchaseUser'}" disabled="${form_PURCHASE_NM_D}" readOnly="${form_PURCHASE_NM_RO}" required="${form_PURCHASE_NM_R}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field colSpan="3">
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>


        </e:searchPanel>


        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>