<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/master/item/";

	var attColumn = "";

    function init() {
		grid = EVF.C('grid');
		grid.setProperty('panelVisible', ${panelVisible});
		EVF.C('VALID_PRICE_FLAG').setValue('YES');

		grid.setProperty('panelVisible', ${panelVisible});
		if('${ses.grantedAuthCd}' == 'PF0055') {// 부품이면
			EVF.C('ITEM_KIND_CD').setValue('ROH2');
			EVF.C('ITEM_KIND_CD').setDisabled(true);
		} else if ( '${ses.grantedAuthCd}' == 'PF0054' ) {  // 일반이면
			EVF.C('ITEM_KIND_CD').removeOption('ROH2');
		}

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth     : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
	        switch (celname) {
				case 'ITEM_CD':
					var param = {
						ITEM_CD: grid.getCellValue(rowid, "ITEM_CD"),
						detailView : true
					};
					everPopup.openItemDetailInformation(param);
					break;

				case 'VENDOR_CD':
					var params = {
						VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
						paramPopupFlag: "Y",
						detailView : true
					};
					everPopup.openSupManagementPopup(params);
					break;

				case 'EXEC_NUM':

					var param = {
						gateCd: grid.getCellValue(rowid, "GATE_CD"),
						EXEC_NUM: grid.getCellValue(rowid, "EXEC_NUM"),
						popupFlag: true,
						detailView: true
					};

					//everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
					everPopup.openPopupByScreenId('DH0630', 1200, 800, param);
					break;

				case 'UNIT_PRC_HISTORY_IMG':
					//if (eval(grid.getCellValue(rowid, celname)) > 0) {
						attColumn = "UNIT_PRC_HISTORY_IMG";
						var url = baseUrl + "BBM_090/view.wu";
						var param = {
							PLANT_CD: grid.getCellValue(rowid, "PLANT_CD"),
							BUYER_CD: grid.getCellValue(rowid, "BUYER_CD"),
							ITEM_CD: grid.getCellValue(rowid, "ITEM_CD"),
							ITEM_DESC: grid.getCellValue(rowid, "ITEM_DESC"),
							popupFlag: true,
							detailView : true
						};
						everPopup.openPopupByScreenId('BBM_090', 900, 600, param);
					//}
					break;

				case 'INSPECTION_ATT_FILE_CNT':
					attColumn = "INSPECTION_ATT_FILE_CNT";

					var uuid = grid.getCellValue(rowid, 'INSPECTION_ATT_FILE_NUM');
					var param = {
						havePermission : '${!param.detailView}',
						attFileNum     : uuid,
						rowId          : rowid,
						callBackFunction: '_setAttFiles',
						bizType: 'INFO'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					break;

				case 'GREEN_ATT_FILE_CNT':
					attColumn = "GREEN_ATT_FILE_CNT";

					var uuid = grid.getCellValue(rowid, 'GREEN_ATT_FILE_NUM');
					var param = {
						havePermission : '${!param.detailView}',
						attFileNum     : uuid,
						rowId          : rowid,
						callBackFunction: '_setAttFiles',
						bizType: 'INFO'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					break;

				case 'RAW_ATT_FILE_CNT':
					attColumn = "RAW_ATT_FILE_CNT";

					var uuid = grid.getCellValue(rowid, 'RAW_ATT_FILE_NUM');
					var param = {
						havePermission : '${!param.detailView}',
						attFileNum     : uuid,
						rowId          : rowid,
						callBackFunction: '_setAttFiles',
						bizType: 'INFO'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					break;
            default:
	        }
		});
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BBM_080/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }
    function searchVendorCode() {
        var param = {
            callBackFunction: "selectVendorCode"
        };
        everPopup.openCommonPopup(param, 'SP0013');
    }
    function selectVendorCode(dataJsonArray) {
        EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_NM);
    }
    function doTerminate() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
		}

	    var rowIds = grid.getSelRowId();
	    for(var rowId in rowIds) {
            var terminateFlag = grid.getCellValue(rowIds[rowId], 'TERMINATE_FLAG');

            if (terminateFlag == 'Y') {
            	alert("${msg.M0094}");
            	return;
            }
	    }

	    var param = {
				  'havePermission' : true
				, 'callBackFunction' : 'setTextContents'
				, 'detailView' : false
			};
		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
    }

    function setTextContents(contents) {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

	    var rowIds = grid.getSelRowId();
	    for(var rowId in rowIds) {
            grid.setCellValue(rowIds[rowId], 'TERMINATE_RMK', contents);
            grid.checkRow(rowIds[rowId], true);
	    }

        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
    	store.load(baseUrl + 'BBM_080/doTerminate', function(){
            alert(this.getResponseMessage());

            doSearch();
    	});
     }

    function _setAttFiles(rowid, fileId, fileCount) {

    	if (attColumn == "INSPECTION_ATT_FILE_CNT") {
        	grid.setCellValue(rowid, 'INSPECTION_ATT_FILE_CNT', fileCount);
        	grid.setCellValue(rowid, 'INSPECTION_ATT_FILE_NUM', fileId);
    	} else if (attColumn == "GREEN_ATT_FILE_CNT") {
        	grid.setCellValue(rowid, 'GREEN_ATT_FILE_CNT', fileCount);
        	grid.setCellValue(rowid, 'GREEN_ATT_FILE_NUM', fileId);
    	} else if (attColumn == "RAW_ATT_FILE_CNT") {
        	grid.setCellValue(rowid, 'RAW_ATT_FILE_CNT', fileCount);
        	grid.setCellValue(rowid, 'RAW_ATT_FILE_NUM', fileId);
    	}

    	grid.checkAll(false);
        grid.checkRow(rowid, true);

    	var store = new EVF.Store();
		if(!store.validate()) { return; }

	    store.doFileUpload(function() {
	        store.setGrid([grid]);
	    	store.getGridData(grid, 'sel');
	    	store.setParameter('attColumn', attColumn);
	    	store.load(baseUrl + 'BBM_080/doUpdateAttFiles', function(){
	            alert(this.getResponseMessage());

	            doSearch();
	    	});
	    });
    }

    function doHistory() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

        var url = baseUrl + "BBM_090/view.wu";
        var param = {
            ITEM_CD: grid.getCellValue(selRowId[0], 'ITEM_CD'),
            ITEM_DESC: grid.getCellValue(selRowId[0], 'ITEM_DESC'),
            popupFlag: true
        };

        everPopup.openPopupByScreenId('BBM_090', 900, 600, param);
    }
    function getitem_cls() {
    	var store = new EVF.Store();

    	var cls_type = this.getData();
    	item_cls='';
    	if (cls_type=='2') {
    		item_cls= EVF.C("ITEM_CLS1").getValue();
    		clearX('3');
    		clearX('4');
    	}
    	if (cls_type=='3') {
    		item_cls= EVF.C("ITEM_CLS2").getValue();
    		clearX('4');
    	}
    	if (cls_type=='4') {
    		item_cls= EVF.C("ITEM_CLS3").getValue();
    	}

	    store.load(baseUrl + 'getItem_Cls.so?CLS_TYPE='+cls_type+'&ITEM_CLS='+item_cls, function() {
    		EVF.C('ITEM_CLS'+ cls_type ).setOptions(this.getParameter("item_cls"));
        });
	}

	function clearX( cls_typef ) {
		EVF.C('ITEM_CLS'+ cls_typef ).setOptions(JSON.parse('[]'));
	}

	function doPPC() {
		var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

		if(selRowIds.length == 0) {
			return alert("${msg.M0004}");
		}

		for(idx in selRowIds) {
			// 품목구분이 "부자재, 설비"만 변경품의 가능
			if(grid.getCellValue(selRowIds[idx], "ITEM_KIND_CD") != "ROM1" && grid.getCellValue(selRowIds[idx], "ITEM_KIND_CD") != "EPA0") {
//				alert("${BBM_080_002}");
//				return;
			}

			/*
			// 동일 회사
			if(grid.getCellValue(selRowIds[0], "BUYER_CD") != grid.getCellValue(selRowIds[idx], "BUYER_CD")) {
				alert("${BBM_080_003}");
				return;
			}
			*/

			// 동일 통화
			if(grid.getCellValue(selRowIds[0], "CUR") != grid.getCellValue(selRowIds[idx], "CUR")) {
				alert("${BBM_080_004}");
				return;
			}
		}

		var param = {
			'popupFlag': true,
			'detailView': false,
			//'BUYER_CD': grid.getCellValue(selRowIds[0], "BUYER_CD"),
			'gridList': JSON.stringify(grid.getSelRowValue())
		};

		everPopup.openPopupByScreenId("DH0630", 1200, 800, param);
	}

	function doSapSend() {

		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

		if (selRowId.length == 0) {
			alert("${msg.M0004}");
			return;
		}

		for(idx in selRowId) {
			if (!(grid.getCellValue(selRowId[idx], 'ITEM_KIND_CD') == "ROH2" || grid.getCellValue(selRowId[idx], 'ITEM_KIND_CD') == "ROM1")) {
				alert("${BBM_080_0001}"); //부품, 부자재 인 경우에만 SAP 전송이 가능합니다.
				return;
			}
			if (grid.getCellValue(selRowId[idx], 'SAP_MAPPING_YN') != "N") {
				alert("${BBM_080_0002}"); //SAP전송여부가 'N'인 건만 전송 가능함
				return;
			}
		}

        var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');

    	store.load(baseUrl + 'BBM_080/doSapSend', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});

	}

    </script>
	<e:window id="BBM_080" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="110" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--단가유효여부--%>
				<e:label for="VALID_PRICE_FLAG" title="${form_VALID_PRICE_FLAG_N}"/>
				<e:field>
					<e:select id="VALID_PRICE_FLAG" name="VALID_PRICE_FLAG" value="${form.VALID_PRICE_FLAG}" options="${refValidPrice }" usePlaceHolder="false" width="${inputTextWidth}" disabled="${form_VALID_PRICE_FLAG_D}" readOnly="${form_VALID_PRICE_FLAG_RO}" required="${form_VALID_PRICE_FLAG_R}" placeHolder="" />
				</e:field>
				<%--플랜트--%>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
				<!-- 품목구분 -->
				<e:label for="ITEM_KIND_CD" title="${form_ITEM_KIND_CD_N}"/>
				<e:field>
					<e:select id="ITEM_KIND_CD" name="ITEM_KIND_CD" value="${form.ITEM_KIND_CD}" options="${itemKindCdOptions}" width="${inputTextWidth}" disabled="${form_ITEM_KIND_CD_D}" readOnly="${form_ITEM_KIND_CD_RO}" required="${form_ITEM_KIND_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--자재그룹--%>
				<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
				<e:field>
					<e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${matGroupOptions}" width="${inputTextWidth}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder="" />
				</e:field>
				<%--품번--%>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" style='ime-mode:inactive'/>
				</e:field>
				<%--품명--%>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" style="${imeMode}"/>
				</e:field>
			</e:row>
			<e:row>
				<%--협력회사명--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCode'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" style="${imeMode}"/>
				</e:field>
				<%--품의번호--%>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />
				<e:field>
					<e:inputText id="EXEC_NUM" name="EXEC_NUM" value="${form.EXEC_NUM}" width="${inputTextWidth}" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}" style='ime-mode:inactive'/>
				</e:field>
				<%--적용시작일--%>
				<e:label for="">
					<e:select id="VALID_DATE_TYPE" name="VALID_DATE_TYPE" placeHolder="${placeHolder }" required="false" disabled="false" readOnly="false" visible="true" value="" width="110">
						<e:option text="적용시작일" value="FROM" />
						<e:option text="적용종료일" value="TO" />
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="VALID_DATE_FROM" toDate="VALID_DATE_TO" name="VALID_DATE_FROM" value="${st_default}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="VALID_DATE_TO" fromDate="VALID_DATE_FROM" name="VALID_DATE_TO" value="${st_default}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>
			</e:row>
			<e:row>
				<%--품목분류--%>
				<e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}" />
				<e:field colSpan="3">
					<e:select id="ITEM_CLS1" name="ITEM_CLS1" data="2" onChange="getitem_cls" value="${form.ITEM_CLS}" options="${refITEM_CLASS1 }" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
					<e:text>&nbsp;</e:text>
					<e:select id="ITEM_CLS2" name="ITEM_CLS2" data="3" onChange="getitem_cls" value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
					<e:text>&nbsp;</e:text>
					<e:select id="ITEM_CLS3" name="ITEM_CLS3" data="4" onChange="getitem_cls" value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
					<e:text>&nbsp;</e:text>
					<e:select id="ITEM_CLS4" name="ITEM_CLS4" value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
				</e:field>
				<e:label for="SAP_MAPPING_YN" title="${form_SAP_MAPPING_YN_N}"/>
				<e:field>
					<e:select id="SAP_MAPPING_YN" name="SAP_MAPPING_YN" value="${form.SAP_MAPPING_YN}" options="${sapMappingYnOptions}" width="${inputTextWidth}" disabled="${form_SAP_MAPPING_YN_D}" readOnly="${form_SAP_MAPPING_YN_RO}" required="${form_SAP_MAPPING_YN_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<c:if test="${ses.ctrlCd != null && ses.ctrlCd != '' }">
				<e:button id="doPPC" name="doPPC" label="${doPPC_N}" onClick="doPPC" disabled="${doPPC_D}" visible="${doPPC_V}"/>
				<e:button id="doTerminate" name="doTerminate" label="${doTerminate_N}" onClick="doTerminate" disabled="${doTerminate_D}" visible="${doTerminate_V}" />
				<e:button id="doSapSend" name="doSapSend" label="${doSapSend_N}" onClick="doSapSend" disabled="${doSapSend_D}" visible="${doSapSend_V}"/>
			</c:if>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>
