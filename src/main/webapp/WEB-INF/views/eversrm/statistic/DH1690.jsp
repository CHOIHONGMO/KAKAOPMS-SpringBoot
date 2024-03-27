<%@page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

        var baseUrl = "/eversrm/statistic/DH1690"
            ,grid
			,selRow;

        function init() {
    		grid = EVF.C('grid');

            grid.addRowEvent(function() {
            	var itemDiv = EVF.getComponent("ITEM_DIV").getValue();
            	var matGroup = EVF.getComponent("MAT_GROUP").getValue();
            	var grReqDate = EVF.getComponent("GR_FROM_DATE").getValue();
            	var prodCountryCd = EVF.getComponent("PROD_COUNTRY_CD").getValue();
            	var investDiv = EVF.getComponent("INVEST_DIV").getValue();

    			var addParam = [{"ITEM_DIV" : itemDiv, "MAT_GROUP" : matGroup, "GR_REQ_DATE" : grReqDate, "PROD_COUNTRY_CD" : prodCountryCd,"INVEST_DIV" : investDiv}];
            	grid.addRow(addParam);
            });
            grid.setProperty('panelVisible', ${panelVisible});
		    grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {

	        	var matGroup = grid.getCellValue(rowId, "MAT_GROUP");
	        	if (matGroup == '${DH1690_SUBTOTAL}' || matGroup == '${DH1690_TOTAL}') {
	        		return;
	        	}

		    	switch (celName) {
                case 'TARGET_PRC':
				case 'INVEST_PRC':
				case 'UNIT_PRC':
				case 'CONFIRM_UNIT_PRC':

                	var itemDiv = grid.getCellValue(rowId, "ITEM_DIV");
                	var matGroup = grid.getCellValue(rowId, "MAT_GROUP");
                	var grReqDate = grid.getCellValue(rowId, "GR_REQ_DATE");
                	var investDiv = grid.getCellValue(rowId, "INVEST_DIV");

                	if (itemDiv == '' || matGroup == ''|| investDiv == '') {
                		break;
                	}

                	if (investDiv != '7' && grReqDate == '') {
                		break;
                	}

                	var params = {
                			itemDiv: itemDiv,
                			matGroup: matGroup,
                			grReqDate: grReqDate,
                			investDiv: investDiv,
			                popupFlag: true,
			                detailView : false
			        };

                	if (investDiv == '7') { // 투자구분 = EO
                    	everPopup.openPopupByScreenId("DH1710", 1600, 800, params);
                	} else {
                    	everPopup.openPopupByScreenId("DH1700", 1600, 800, params);
                	}
                    break;

                case 'URL_IMAGE':
                    var val = grid.getCellValue(rowId, 'GW_EXEC_URL');

                    if (val != '' && val != null && val.length > 200) {
                      var param = {
                        'GW_EXEC_TEXT': grid.getCellValue(rowId, 'GW_EXEC_TEXT')
                      };

                      everPopup.openWindowPopup(val, 950, 820, param, 'gwPop');
                    }
                    break;

				case 'multiSelect':
					if(selRow == undefined) selRow = rowId;

					if (celName == 'multiSelect') {
						if(selRow != rowId) {
							grid.checkRow(selRow, false);
							selRow = rowId;
						}
					}
					break;

                default:
                    return;
            	}
		    });

		    grid.cellChangeEvent(function (rowId, celname, iRow, iCol, newValue, oldValue) {

	        	var matGroup = grid.getCellValue(rowId, "MAT_GROUP");
	        	if (matGroup == '${DH1690_SUBTOTAL}' || matGroup == '${DH1690_TOTAL}') {
	        		grid.setCellValue(rowId, celname, oldValue);
	        		return;
	        	}

		    	switch (celname) {
                    case 'INVEST_DIV':

                    	if (newValue == '7') {
                            grid.setCellValue(rowId, 'GR_REQ_DATE', '');
                        	grid.setCellValue(rowId, 'INVEST_RECEIPT_DATE', '');
                        	grid.setCellValue(rowId, 'RECEIPT_DATE', '');
                    	}

                        break;

                    case 'GR_REQ_DATE':
                    case 'INVEST_RECEIPT_DATE':
                    case 'RECEIPT_DATE':
                    	if (grid.getCellValue(rowId, 'INVEST_DIV') == '7') {
                            grid.setCellValue(rowId, celname, '');
                    	}

                        break;

                    default:
                        return;

                }
            });

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

			grid.excelImportEvent({
	  	          'append': false
	  	        }, function (msg, code) {
	  	          if (code) {
	  	            grid.checkAll(true);
	  	          }
	 	        });

        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {
    		var rowIds = grid.getAllRowId();
			for( var id in rowIds ) {
	        	var summaryFlag = grid.getCellValue(id, "SUMMARY_FLAG");
	        	if (summaryFlag == 'S' || summaryFlag == 'T') {
					grid.checkRow(id, false);
				}

	        	var matGroup = grid.getCellValue(id, "MAT_GROUP");
	        	if (matGroup == '${DH1690_SUBTOTAL}' || matGroup == '${DH1690_TOTAL}') {
					grid.checkRow(id, false);
				}
			}

			if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
			for( var idx in selRowId ) {
				if (grid.getCellValue(idx, "INVEST_DIV") == '7') {
                    grid.setCellValue(idx, 'GR_REQ_DATE', '');
                	grid.setCellValue(idx, 'INVEST_RECEIPT_DATE', '');
                	grid.setCellValue(idx, 'RECEIPT_DATE', '');
				} else if (grid.getCellValue(idx, "GR_REQ_DATE") == '') {
	        		alert('${DH1690_0001}');
	        		return;
				}
			}

            var store = new EVF.Store();
            if(!store.validate()) { return; }

	        var valid = grid.validate();
			if (!valid.flag) {
				alert(valid.msg);
			    return;
			}

            if(!confirm('${msg.M0021}')) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+'/doSave', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
		}

        function doDelete() {
    		var rowIds = grid.getAllRowId();
			for( var id in rowIds ) {
	        	var summaryFlag = grid.getCellValue(id, "SUMMARY_FLAG");
	        	if (summaryFlag == 'S' || summaryFlag == 'T') {
					grid.checkRow(id, false);
				}
			}

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

            if(!confirm('${msg.M0013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+'/doDelete', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
		}

    </script>

	<e:window id="DH1690" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
			<e:row>
				<e:label for="ITEM_DIV" title="${form_ITEM_DIV_N}" />
				<e:field>
					<e:select id="ITEM_DIV" name="ITEM_DIV" value="${form.ITEM_DIV}" options="${itemDivOptions}" width="${inputTextWidth}" disabled="${form_ITEM_DIV_D}" readOnly="${form_ITEM_DIV_RO}" required="${form_ITEM_DIV_R}" placeHolder="" />
				</e:field>
				<e:label for="GR_REQ_DATE" title="${form_GR_REQ_DATE_N}" />
				<e:field>
					<e:inputDate id="GR_FROM_DATE" toDate="GR_TO_DATE" name="GR_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_GR_REQ_DATE_R}" disabled="${form_GR_REQ_DATE_D}" readOnly="${form_GR_REQ_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="GR_TO_DATE" fromDate="GR_FROM_DATE" name="GR_TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_GR_REQ_DATE_R}" disabled="${form_GR_REQ_DATE_D}" readOnly="${form_GR_REQ_DATE_RO}" />
				</e:field>
				<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}" />
				<e:field>
					<e:inputText id="MAT_GROUP" style="${imeMode}" name="MAT_GROUP" value="${form.MAT_GROUP}" width="${inputTextWidth}" maxLength="${form_MAT_GROUP_M}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="INVEST_DIV" title="${form_INVEST_DIV_N}" />
				<e:field>
					<e:select id="INVEST_DIV" name="INVEST_DIV" value="${form.INVEST_DIV}" options="${investDivOptions}" width="${inputTextWidth}" disabled="${form_INVEST_DIV_D}" readOnly="${form_INVEST_DIV_RO}" required="${form_INVEST_DIV_R}" placeHolder="" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="${inputTextWidth}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="PROD_COUNTRY_CD" title="${form_PROD_COUNTRY_CD_N}" />
				<e:field>
					<e:select id="PROD_COUNTRY_CD" name="PROD_COUNTRY_CD" value="${form.PROD_COUNTRY_CD}" options="${prodCountryCdOptions}" width="${inputTextWidth}" disabled="${form_PROD_COUNTRY_CD_D}" readOnly="${form_PROD_COUNTRY_CD_RO}" required="${form_PROD_COUNTRY_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
