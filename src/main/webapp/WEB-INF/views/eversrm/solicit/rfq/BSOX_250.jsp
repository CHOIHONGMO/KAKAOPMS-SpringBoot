<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
        grid = EVF.C("grid");
		// 진행상태[M062]
        EVF.C('PROGRESS_CD').removeOption('2300'); // 작성중
        EVF.C('PROGRESS_CD').removeOption('2350'); // 가격입찰중
        EVF.C('PROGRESS_CD').removeOption('2355'); // 가격입찰마감
        EVF.C('PROGRESS_CD').removeOption('2330'); // 종합입찰중
        EVF.C('PROGRESS_CD').removeOption('2335'); // 종합입찰마감
		// 구매유형[M136]
		EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PURCHASE_TYPE').removeOption('OMRO'); // 해외MRO
		grid.setProperty('panelVisible', ${panelVisible});
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
        	else if (celName == "VENDOR_BID") {
                var param = {
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxSubject: grid.getCellValue(rowId, "RFX_SUBJECT"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openPopupByScreenId('BPX_220', 850, 600, param);
            } else if (celName == "multiSelect") {
            	grid.setProperty('singleSelect', true);
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
        store.load(baseUrl + "BSOX_250/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

    //견적비교
    function doCompare() {
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];
        if ('${ses.userId}' != selectedRow['CTRL_USER_ID']) return alert('${msg.M0008}');
        var progress_cd = selectedRow.PROGRESS_CD;
        // 진행상태 : 유찰, 재견적, 업체선정완료 => 견적비교는 가능함. 견적비교 화면에서 버튼 없앨 것
        /*
        if (progress_cd == '2500' || progress_cd == '2550' || progress_cd == '1300') {
        	alert('${BSOX_250_001}');
        	return;
        }
        */
        if (selectedRow['SETTLE_TYPE'] == 'DOC') {
            var params = {
            	rfxNum: selectedRow['RFX_NUM'],
                rfxCnt: selectedRow['RFX_CNT'],
                popupFlag: true,
                detailView: false,
                callBackFunction: "doSearch",
                negoFlag: selectedRow['NEGO_DATE']
            };
            everPopup.openPopupByScreenId("BSOX_260", 1200, 800, params); //BPX_260
        } else {
            var params = {
            	rfxNum: selectedRow['RFX_NUM'],
                rfxCnt: selectedRow['RFX_CNT'],
                popupFlag: true,
                detailView: false,
                callBackFunction: "doSearch",
                negoFlag: selectedRow['NEGO_DATE']
            };
            everPopup.openPopupByScreenId("BSOX_290", 1200, 800, params); //BPX_290
        }
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

    </script>


    <e:window id="BSOX_250" onReady="init" initData="${initData}" title="${fullScreenName}">
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
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" style='ime-mode:inactive' name="RFX_NUM" value="${form.RFX_NUM}" width="35%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="RFX_SUBJECT" style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="SUBMIT_TYPE" title="${form_SUBMIT_TYPE_N}"/>
				<e:field>
				<e:select id="SUBMIT_TYPE" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitTypeOptions}" width="${inputTextWidth}" disabled="${form_SUBMIT_TYPE_D}" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
				</e:field>

			    <e:label for="PURCHASE_NM" title="${form_PURCHASE_NM_N}"/>
				<e:field>
					<e:search id="PURCHASE_NM" style="${imeMode}" name="PURCHASE_NM" value="${ses.userNm }" width="${inputTextWidth}" maxLength="${form_PURCHASE_NM_M}" onIconClick="${form_PURCHASE_NM_RO ? 'everCommon.blank' : 'doSelectPurchaseUser'}" disabled="${form_PURCHASE_NM_D}" readOnly="${form_PURCHASE_NM_RO}" required="${form_PURCHASE_NM_R}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="2400" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        	<e:button id="doCompare" name="doCompare" label="${doCompare_N}" onClick="doCompare" disabled="${doCompare_D}" visible="${doCompare_V}"/>
        </e:buttonBar>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>