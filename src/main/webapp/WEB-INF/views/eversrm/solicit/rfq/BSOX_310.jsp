<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
        grid = EVF.C("grid");
		// 구매유형(M136)의 "국내 및 해외MRO" 제외
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
        		if(grid.getCellValue(rowId, "RFX_NUM").substring(0,2) == 'PR') return;
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
        	else if (celName == "EXEC_NUM") {
                var param = {
                    gateCd: grid.getCellValue(rowId, "GATE_CD"),
                    EXEC_NUM: grid.getCellValue(rowId, "EXEC_NUM"),
                    popupFlag: true,
                    detailView: true
                };

                everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
            }
        	else if (celName == "VENDOR_BID") {
                var param = {
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxSubject: grid.getCellValue(rowId, "RFX_SUBJECT"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openPopupByScreenId('BPX_220', 800, 600, param);
            }
        	else if (celName == "VENDOR_CD") {
        		var params = {
	                VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        } else  if (celName == "QTA_NUM") {
            	if (grid.getCellValue(rowId,'QTA_NUM') == '') return;

            	//alert(grid.getCellValue(rowId,'QTA_NUM').substring(0,2))
            	if (grid.getCellValue(rowId,'QTA_NUM').substring(0,2) == 'PR') return;


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
        	else if (celName == "multiSelect") {




//        		var rfxNum = grid.getCellValue(rowId, "RFX_NUM");
//                var rfxCnt = grid.getCellValue(rowId, "RFX_CNT");

//            	if (grid.isSelected(rowId)) {
//	                grid.checkAll(false);
//	                var gridData = grid.getAllRowValue();
//	                for (var cnt in gridData) {
//						var rowDatas = gridData[cnt];
//						if(rfxNum == rowDatas['RFX_NUM'] && rfxCnt == rowDatas['RFX_CNT']) {
//							grid.checkRow(cnt, true);
//						}
//	                }
//           	} else {
//                	grid.checkRow(rowId, false);
//            	}


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
        store.load(baseUrl + "BSOX_310/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

    //선정취소
	 function doSettleCancel() {

		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

		<%--
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}
		--%>

		var valid = grid.validate()
			, selRows = grid.getSelRowValue();

		for( var i = 0, len = selRows.length; i < len; i++ ) {
			if (selRows[i].CTRL_USER_ID != "${ses.userId}") return alert("${msg.M0008}");
		}

    	//if (!confirm("${BSOX_310_001}")) return;
    	if (!confirm("${msg.M8888}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
    	store.load(baseUrl + 'BSOX_310/doSettleCancel', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
	}

    //선정품의작성
	function doExecCreate() {

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue();

		var temp_rfq_no='';
		var temp_vendor_cd= '';
		var purchase_type = '';
		var temp_purchase_type = '';

        for (var k = 0; k < selectedRow.length; k++) {
        	// 동일한 견적/입찰건에 대해 선정품의서 작성 가능함
        	if (temp_rfq_no != '' && temp_rfq_no != selectedRow[k].RFX_NUM) {
 //       		alert('${BSOX_310_0001}');
 //       		return;
        	}

        	if (temp_purchase_type != '' && temp_purchase_type != selectedRow[k].PURCHASE_TYPE) {
           		alert('${BSOX_310_0004}');
          		return;
        	}



        	temp_rfq_no = selectedRow[k].RFX_NUM;
        	temp_purchase_type  = selectedRow[k].PURCHASE_TYPE;
        	purchase_type = selectedRow[k]['PURCHASE_TYPE'];

        	// 수선/제작/부자재는 1개의 협력회사만 품의서 작성 가능함
//        	if(purchase_type == 'AS' || purchase_type == 'NEW' || purchase_type == 'SMT') {
//	        	if (temp_vendor_cd != '' && temp_vendor_cd != selectedRow[k].VENDOR_CD) {
//	        		alert('${BSOX_310_0003}');
//	        		return;
//	        	}
 //       	}
        	temp_vendor_cd = selectedRow[k].VENDOR_CD;

            if ('${ses.userId}' != selectedRow[k]['CTRL_USER_ID']) {
            	return alert('${msg.M0008}');
            }

            // 협력회사정보 SAP 전송여부(STOCVNGL의 JOB_SQ=1인 경우에만 품의서 작성 가능함)
        	if (selectedRow[k].IF_RSLT_CD == '0') {
//        		alert('${BSOX_310_0002}');
//        		return;
        	}
        }



		var param = {
				rfxNum: selectedRow[0]['RFX_NUM'],
			    rfxCnt: selectedRow[0]['RFX_CNT'],
			    VENDOR_CD: selectedRow[0]['VENDOR_CD'],
			    rqList: JSON.stringify(selectedRow),
	            popupFlag: true,
	            detailView: false
	        };
	    everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
        /*
        return;
        var execNum = selectedRow['EXEC_NUM'];
        if(execNum == ''){
			var param = {
				rfxNum: selectedRow['RFX_NUM'],
			    rfxCnt: selectedRow['RFX_CNT'],
	            popupFlag: true,
	            detailView: false
	        }
	        everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
	    }else{
	    	var param = {
	    		EXEC_NUM: selectedRow['EXEC_NUM'],
	            popupFlag: true,
	            detailView: false
	        }
	        everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
	    }
        */
    }
    function doSelectPurchaseUser() {
        var param = {
				callBackFunction: "selectPurchaseUser",
				BUYER_CD: "${ses.companyCd}"
			};
		everPopup.openCommonPopup(param, 'SP0040');
    }
    function selectPurchaseUser(data) {
        EVF.C("PURCHASE_NM").setValue(data.CTRL_USER_NM);
        EVF.C("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
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

    <e:window id="BSOX_310" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:row>
                <e:label for="">
                    <e:select id="DATE_TYPE" name="DATE_TYPE" usePlaceHolder="false" width="100" required="${form_DATE_TYPE_R}" disabled="${form_DATE_TYPE_D }" readOnly="${form_DATE_TYPE_RO}" >
                        <e:option text="${form_RFQ_CLOSE_DATE_N}" value="C">C</e:option>
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
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_ID" style="ime-mode:inactive" name="CTRL_USER_ID" value="${ses.userId }" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_RO ? 'everCommon.blank' : 'doSelectPurchaseUser'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:search id="PURCHASE_NM" style="${imeMode}" name="PURCHASE_NM" value="${ses.userNm }" width="${inputTextWidth}" maxLength="${form_PURCHASE_NM_M}" onIconClick="${form_PURCHASE_NM_RO ? 'everCommon.blank' : ''}" disabled="${form_PURCHASE_NM_D}" readOnly="${form_PURCHASE_NM_RO}" required="${form_PURCHASE_NM_R}" />
				</e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
					<e:field>
					<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>


			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        	<e:button id="doExecCreate" name="doExecCreate" label="${doExecCreate_N}" onClick="doExecCreate" disabled="${doExecCreate_D}" visible="${doExecCreate_V}"/>
        	<e:button id="doSettleCancel" name="doSettleCancel" label="${doSettleCancel_N}" onClick="doSettleCancel" disabled="${doSettleCancel_D}" visible="${doSettleCancel_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>