<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
        grid = EVF.C("grid");

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

        EVF.C('PROGRESS_CD').removeOption('100');
        EVF.C('PROGRESS_CD').removeOption('200');
        EVF.C('PROGRESS_CD').removeOption('250');
        EVF.C('PROGRESS_CD').removeOption('150');
        grid.setProperty('panelVisible', ${panelVisible});


        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
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
            if (celName == "QTA_NUM") {
            	if (grid.getCellValue(rowId,'QTA_NUM') == '') return;
    	        var param = {
    		            gateCd: grid.getCellValue(rowId,'GATE_CD'),
    		            rfxNum: grid.getCellValue(rowId,'RFX_NUM'),
    		            qtaNum : grid.getCellValue(rowId,'QTA_NUM'),
    		            rfxCnt: grid.getCellValue(rowId,'RFX_CNT'),
    		            //rfxType: selectedRow['RFX_TYPE'],
    		            popupFlag: true,
    		            //callBackFunction: "doSearch"
    		            detailView: true,
    		            "isPrefferedBidder": false,
    		            "buttonStatus" : 'Y',
    		            vendorCd: "${ses.companyCd}"
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
        store.load(baseUrl + "SSOX_050/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

    function doSearchItemCd() {
        var param = {
            callBackFunction: 'selectItemCd'
        };
        everPopup.openCommonPopup(param, 'SP0018');
	}
	function selectItemCd(dataJsonArray) {
	    EVF.getComponent("ITEM_CD").setValue(dataJsonArray.ITEM_CD);
	    EVF.getComponent("ITEM_DESC").setValue(dataJsonArray.ITEM_DESC);
	}


</script>


    <e:window id="SSOX_050" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">

            <e:row>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
                <e:field>
                    <e:inputDate id="ADD_DATE_FROM" toDate="ADD_DATE_TO" name="ADD_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_R}" disabled="${form_ADD_DATE_D}" readOnly="${form_ADD_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="ADD_DATE_TO" fromDate="ADD_DATE_FROM" name="ADD_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_R}" disabled="${form_ADD_DATE_D}" readOnly="${form_ADD_DATE_RO}" />
                </e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
				<e:field>
					<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
				<e:field>
					<e:inputText id="RFX_NUM" style="ime-mode:inactive" name="RFX_NUM" value="${form.RFX_NUM}" width="${inputTextWidth}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}"/>
				</e:field>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
                <e:field>
                    <e:inputText id="RFX_SUBJECT" style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="90%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
                </e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="90%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
					<e:inputHidden id="ITEM_CD" name="ITEM_CD"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="SEL_STATUS" title="${form_SEL_STATUS_N}"/>
				<e:field>
					<e:select id="SEL_STATUS" name="SEL_STATUS" value="${form.SEL_STATUS}" options="${refSEL_STATUS }" width="${inputTextWidth}" disabled="${form_SEL_STATUS_D}" readOnly="${form_SEL_STATUS_RO}" required="${form_SEL_STATUS_R}" placeHolder="" />
				</e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field colSpan="3">
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${refPROGRESS_CD}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
			</e:row>

        </e:searchPanel>


        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>