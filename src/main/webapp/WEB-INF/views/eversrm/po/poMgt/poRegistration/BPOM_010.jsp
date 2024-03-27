<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
    var baseUrl = "/eversrm/po/poMgt/poRegistration/";

    function init() {
        grid = EVF.getComponent("grid");
        grid.setProperty('panelVisible', ${panelVisible});
		EVF.C('PURCHASE_TYPE').removeOption('NORMAL'); // 부품
		EVF.C('PURCHASE_TYPE').removeOption('SMT'); // 부자재
		EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PURCHASE_TYPE').removeOption('OMRO'); // 해외MRO

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
			switch (colId) {

				case 'multiSelect':

					var selExecNum = grid.getCellValue(rowId, 'EXEC_NUM');
					var selVendorCd = grid.getCellValue(rowId, 'VENDOR_CD');
					var selPlantCd = grid.getCellValue(rowId, 'PLANT_CD');
					var allRowId = grid.getAllRowId();

					for (var i in allRowId) {
						var ri = allRowId[i];
						if (rowId != ri && selExecNum == grid.getCellValue(ri, 'EXEC_NUM') && selVendorCd == grid.getCellValue(ri, 'VENDOR_CD') && selPlantCd == grid.getCellValue(ri, 'PLANT_CD')) {
							grid.checkRow(ri, !grid.ischeckRowed(ri));
						}
					}

					break;

				case 'VENDOR_CD':
		            var screenId = 'BBV_010';

		            param = {
		                VENDOR_CD: grid.getCellValue(rowId, colId),
		                detailView: true
		            };

		            everPopup.openPopupByScreenId(screenId, 1200, 700, param);
					break;

				case 'ITEM_CD':
		            param = {
		                GATE_CD: grid.getCellValue(rowId, "GATE_CD"),
		                ITEM_CD: grid.getCellValue(rowId, colId),
		                detailView: true
		            };
		            everPopup.openItemDetailInformation(param);
					break;

				case 'PR_NUM':
		            everPopup.openPRDetailInformation(grid.getCellValue(rowId, colId));
					break;

				case 'RFX_NUM':

					var param = {
						gateCd: grid.getCellValue(rowId, "GATE_CD"),
						rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
						rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
						rfxType: grid.getCellValue(rowId, "RFX_TYPE"),
						popupFlag: true,
						detailView: true
					};
					everPopup.openRfxDetailInformation(param);

					break;

				case 'QTA_NUM':

					if (grid.getCellValue(rowId,'QTA_NUM') == '') return;
					var param = {
						gateCd: grid.getCellValue(rowId,'${ses.gateCd}'),
						rfxNum: grid.getCellValue(rowId,'RFX_NUM'),
						qtaNum : grid.getCellValue(rowId,'QTA_NUM'),
						rfxCnt: grid.getCellValue(rowId,'RFX_CNT'),
						popupFlag: true,
						detailView: true,
						"isPrefferedBidder": false,
						"buttonStatus" : 'Y',
						vendorCd: grid.getCellValue(rowId,'VENDOR_CD')
					};
					everPopup.openPopupByScreenId('DH2140', 1000, 800, param);

					break;

				case 'EXEC_NUM':

					var param = {
						gateCd: '${ses.gateCd}',
						EXEC_NUM: grid.getCellValue(rowId, "EXEC_NUM"),
						popupFlag: true,
						detailView: true
					};

					var exec_type = grid.getCellValue(rowId,'EXEC_TYPE');

					var screenId='';
					if(exec_type == "G") {
						screenId='BFAR_020';
					} else if(exec_type == "C") {
						screenId='DH0630';
					} else if(exec_type == "O") {
						screenId='DH0600';
					} else if(exec_type == "S") {
						screenId='DH0540';
					} else if(exec_type == "U") {
						screenId='DH0550';
					}


					if(grid.getCellValue(rowId, "EXEC_NUM").substring(0,2)=='PR') {
						everPopup.openPRDetailInformation(grid.getCellValue(rowId, "EXEC_NUM"));
					} else {
						everPopup.openPopupByScreenId(screenId, 1200, 800, param);
					}



				default:
					return;
			}
		});
    }

    function doSearch() {

    	var store = new EVF.Store();
		if(!store.validate()) { return; }

		if (!everDate.fromTodateValid('EXEC_FROM_DATE', 'EXEC_TO_DATE', '${ses.dateFormat }')) return alert('${msg.M0073}');

    	store.setGrid([grid]);
        store.load(baseUrl + 'BPOM_010/doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

	function doForceClose() {

		if(EVF.isEmpty('${ses.ctrlCd}')) {
			return alert('${msg.M0008}');
		}

		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

		var selRowId = grid.getSelRowId();
		for(var i in selRowId) {

			var rowId = selRowId[i];
			if ("${ses.userId }" != grid.getCellValue(rowId, "CTRL_USER_ID")) {
				return alert("${BPOM_010_001}");
			}
		}

		if (!confirm("${BPOM_010_002}")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
		store.getGridData(grid, 'sel');
		store.load(baseUrl+'BPOM_010/doForceClose', function() {
			alert(this.getResponseMessage());
			doSearch();
		});

	}

    function doCreatePO() {

		if(EVF.isEmpty('${ses.ctrlCd}')) {
			return alert('${msg.M0008}');
		}

		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

        var idx = 0;
		var selRowId = grid.getSelRowId();
		for(var i in selRowId) {
			var baseRowId;
			if(idx == 0) {
				baseRowId = selRowId[i];
			}

			/* 일반구매는 발주담당자가 자신이 아니더다도 발주서 작성 가능함
			if ("${ses.userId }" != grid.getCellValue(baseRowId, "CTRL_USER_ID")) {
				return alert("${BPOM_010_001}");
			}*/
			//if(grid.getSelRowCount() > 1) {

			var rowId = selRowId[i];
			if (grid.getCellValue(rowId, "PLANT_CD") != grid.getCellValue(baseRowId, "PLANT_CD") ||
				grid.getCellValue(rowId, "PUR_ORG_CD") != grid.getCellValue(baseRowId, "PUR_ORG_CD") ||
				grid.getCellValue(rowId, "EXEC_NUM") != grid.getCellValue(baseRowId, "EXEC_NUM") ||
				grid.getCellValue(rowId, "VENDOR_CD") != grid.getCellValue(baseRowId, "VENDOR_CD") ||
				grid.getCellValue(rowId, "PURCHASE_TYPE") != grid.getCellValue(baseRowId, "PURCHASE_TYPE")) {

				alert("${BPOM_010_CANNOT_PROCESS}");
				return;
			}
			idx++;
			/*
			} else {
				if ("${ses.userId }" != grid.getCellValue(baseRowId, "CTRL_USER_ID")) {
					return alert("${BPOM_010_001}");
				}
			}*/
		}

        if (!confirm("${BPOM_010_MSG_001}")) return;

		var paramList = [];
		var selRowId = grid.getSelRowId();
		for(var i in selRowId) {

			var rowId = selRowId[i];
			var gateCd = grid.getCellValue(rowId, 'GATE_CD');
			var poWtNum = grid.getCellValue(rowId, 'PO_WT_NUM');
			var exec_num = grid.getCellValue(rowId, 'EXEC_NUM');

			paramList.push({
				"GATE_CD": gateCd,
				"PO_WT_NUM": poWtNum,
				"EXEC_NUM" : exec_num
			})
		}

//		alert(JSON.stringify(grid.getSelRowValue()));
//		alert(JSON.stringify(paramList))

        var params = {
            poWaitingList: JSON.stringify(paramList),
            popupFlag : true,
            detailView: 'false',
            callBackFunction : 'doSearch'
        };

        everPopup.openPopupByScreenId('BPOM_020', 1200, 700, params);
    }

    function doSearchVendor() {
        var param = {
            callBackFunction: "selectVendor",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0025');
    }

    function selectVendor(dataJsonArray) {
        EVF.getComponent('VENDOR_CD').setValue(dataJsonArray['VENDOR_CD']);
        EVF.getComponent('VENDOR_NM').setValue(dataJsonArray['VENDOR_NM']);
    }

    function doSearchPurchaseGroup() {
        var param = {
            callBackFunction: "selectPurGroup",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0021');
    }

    function selectPurGroup(dataJsonArray) {
        EVF.getComponent('CTRL_NM').setValue(dataJsonArray.CTRL_NM);
    }

    function doSearchBuyer() {
    	everPopup.openCommonPopup({
            callBackFunction: "selectBuyer",
            BUYER_CD: "${ses.companyCd}"
        }, 'SP0040');
	}

	function selectBuyer(data) {
        EVF.getComponent("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
        EVF.getComponent("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
	}

	</script>

	<e:window id="BPOM_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="EXEC_FROM_DATE" title="${form_EXEC_DATE_N}"/>
				<e:field>
					<e:inputDate id="EXEC_FROM_DATE" toDate="EXEC_TO_DATE" name="EXEC_FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_R}" disabled="${form_EXEC_DATE_D}" readOnly="${form_EXEC_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="EXEC_TO_DATE" fromDate="EXEC_FROM_DATE" name="EXEC_TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_R}" disabled="${form_EXEC_DATE_D}" readOnly="${form_EXEC_DATE_RO}" />
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
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="35%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
					<e:text>&nbsp;</e:text>
                    <e:inputText id="ITEM_DESC" style="ime-mode:auto" name="ITEM_DESC" value="${form.ITEM_CD}" width="55%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                </e:field>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_ID" style="ime-mode:inactive" name="CTRL_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_RO ? 'everCommon.blank' : 'doSearchBuyer'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${ses.userNm }" width="${inputTextWidth }" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth }" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}"/>
				<e:field>
					<e:inputText id="EXEC_NUM" style="ime-mode:inactive" name="EXEC_NUM" value="${form.EXEC_NUM}" width="${inputTextWidth}" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}"/>
				</e:field>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
				<e:field>
					<e:inputText id="RFX_NUM" style="ime-mode:inactive" name="RFX_NUM" value="${form.RFX_NUM}" width="${inputTextWidth}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}"/>
				</e:field>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
				<e:field>
					<e:inputText id="PR_NUM" style="ime-mode:inactive" name="PR_NUM" value="${form.PR_NUM}" width="${inputTextWidth}" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}"/>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<e:button id="doCreatePO" name="doCreatePO" label="${doCreatePO_N}" onClick="doCreatePO" disabled="${doCreatePO_D}" visible="${doCreatePO_V}" />
			<e:button id="doForceClose" name="doForceClose" label="${doForceClose_N}" onClick="doForceClose" disabled="${doForceClose_D}" visible="${doForceClose_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
