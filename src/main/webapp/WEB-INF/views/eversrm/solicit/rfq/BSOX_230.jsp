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
            }
        });

        //doSearch();
        //SUMMARY화면에서 넘어올 경우 자동조회
        if ('${param.summary}' == 'Y') {
        	<%-- EVF.getComponent('OPEN_FLAG').setValue('0'); --%>
            doSearch();
        }
    }

    //조회
    function doSearch() {

        if (!everDate.fromTodateValid('ADD_DATE_FROM', 'ADD_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + "BSOX_230/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

    //개봉
	 function doOp() {

		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

		var valid = grid.validate()
			, selRows = grid.getSelRowValue();



		var message = '${BSOX_230_001}';
		for( var i = 0, len = selRows.length; i < len; i++ ) {
			if (selRows[i].OPEN_USER_ID != "${ses.userId}") return alert("${msg.M0008}");

			if (selRows[i].EVAL_STATUS !='X' && selRows[i].EVAL_STATUS !='300') {
				alert('${BSOX_230_005}');
				return;
			}
			var vendor_bid=selRows[i].VENDOR_BID+' ';
			if ( vendor_bid.substring(0,1) == '0'  ) {
				message = '${BSOX_230_008}';
			}

			var a =    vendor_bid.substring(0,   vendor_bid.indexOf('/')  );
			var b =    vendor_bid.substring(vendor_bid.indexOf('/') +1 ,vendor_bid.length -1    );

			if (a != b) {
				message = '${BSOX_230_010}';
			}



		}

    	if (!confirm(message)) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
    	store.load(baseUrl + 'BSOX_230/doOp', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
	}

    function doEval() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

		var valid = grid.validate()
			, selRows = grid.getSelRowValue();

		for( var i = 0, len = selRows.length; i < len; i++ ) {
			if (selRows[i].OPEN_USER_ID != "${ses.userId}") return alert("${msg.M0008}");

			if (selRows[i].EVAL_STATUS !='Y') {
				alert('${BSOX_230_006}');
				return;
			}
		}
    	if (!confirm("${BSOX_230_007}")) return;

        var param = {
        		RFX_NUM: selRows[0]['RFX_NUM'],
        		RFX_CNT: selRows[0]['RFX_CNT'],
        		detailView: false
            };
            everPopup.openPopupByScreenId('BSOX_231', 1250, 800, param);
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
        EVF.getComponent("PURCHASE_NM").setValue(dataJsonArray.USER_NM);
        //EVF.getComponent("INSPECT_USER_ID").setValue(dataJsonArray.USER_ID);
    }
    function doSelectOpenUser() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectOpenUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }
    function selectOpenUser(dataJsonArray) {
	    //dataJsonArray = $.parseJSON(dataJsonArray);
        EVF.getComponent("OP_USER_NM").setValue(dataJsonArray.USER_NM);
        //EVF.getComponent("INSPECT_USER_ID").setValue(dataJsonArray.USER_ID);
    }


    </script>


    <e:window id="BSOX_230" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
        	<e:inputHidden id="summary" name="summary" value="${summary}" />
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
				<e:label for="PURCHASE_NM" title="${form_PURCHASE_NM_N}"/>
				<e:field>
					<e:search id="PURCHASE_NM" style="${imeMode}" name="PURCHASE_NM" value="" width="${inputTextWidth}" maxLength="${form_PURCHASE_NM_M}" onIconClick="${form_PURCHASE_NM_RO ? 'everCommon.blank' : 'doSelectPurchaseUser'}" disabled="${form_PURCHASE_NM_D}" readOnly="${form_PURCHASE_NM_RO}" required="${form_PURCHASE_NM_R}" />
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
			    <e:label for="OP_USER_NM" title="${form_OP_USER_NM_N}"/>
				<e:field>
					<e:search id="OP_USER_NM" style="${imeMode}" name="OP_USER_NM" value="${ses.userNm }" width="${inputTextWidth}" maxLength="${form_OP_USER_NM_M}" onIconClick="${form_OP_USER_NM_RO ? 'everCommon.blank' : 'doSelectOpenUser'}" disabled="${form_OP_USER_NM_D}" readOnly="${form_OP_USER_NM_RO}" required="${form_OP_USER_NM_R}" />
				</e:field>
				<e:label for="EVAL_STATUS" title="${form_EVAL_STATUS_N}"/>
				<e:field>
					<e:select id="EVAL_STATUS" name="EVAL_STATUS" value="${form.EVAL_STATUS}" options="${evalStatusOptions}" width="${inputTextWidth}" disabled="${form_EVAL_STATUS_D}" readOnly="${form_EVAL_STATUS_RO}" required="${form_EVAL_STATUS_R}" placeHolder="" />
				</e:field>
				<e:label for="OPEN_FLAG" title="${form_OPEN_FLAG_N}"/>
				<e:field>
					<e:select id="OPEN_FLAG" name="OPEN_FLAG" value="${form.OPEN_FLAG}" options="${refOpenStatus}" width="${inputTextWidth}" disabled="${form_OPEN_FLAG_D}" readOnly="${form_OPEN_FLAG_RO}" required="${form_OPEN_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>

        </e:searchPanel>


        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doEval" name="doEval" label="${doEval_N}" onClick="doEval" disabled="${doEval_D}" visible="${doEval_V}"/>
        	<e:button id="doOp" name="doOp" label="${doOp_N}" onClick="doOp" disabled="${doOp_D}" visible="${doOp_V}"/>
        </e:buttonBar>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>