<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/statistic/DH1700"
           ,grid;

        function init() {
    		grid = EVF.C('grid');

            grid.addRowEvent(function() {
            	var itemDiv = EVF.getComponent("ITEM_DIV").getValue();
            	var grReqDate = EVF.getComponent("GR_FROM_DATE").getValue();
            	var matGroup = EVF.getComponent("MAT_GROUP").getValue();
            	var investDiv = EVF.getComponent("INVEST_DIV").getValue();

    			var addParam = [{"ITEM_DIV" : itemDiv, "GR_REQ_DATE" : grReqDate, "MAT_GROUP" : matGroup, "INVEST_DIV" : investDiv}];
            	grid.addRow(addParam);
            });
            grid.setProperty('panelVisible', ${panelVisible});
		    grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {

	        	var itemDesc = grid.getCellValue(rowId, "ITEM_DESC");
	        	if (itemDesc == '${DH1700_SUBTOTAL}' || itemDesc == '${DH1700_TOTAL}') {
	        		return;
	        	}

		    	switch (celName) {

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

					/*
					var allRowArr = new Array();
					var allRowId = grid.getAllRowId();
					for(var idx in allRowId) {
                      var rowId = allRowId[idx];

						allRowArr.push(grid.getCellValue(rowId, 'EQUIP_REV'));

                      grid.setCellValue(rowId, 'EQUIP_DIV2', grid.getCellValue(rowId, 'EQUIP_DIV2_NM'));
					}

					var maxRev = Math.max.apply(null, allRowArr);

					if (maxRev != "") {
						EVF.getComponent('ITEM_CD').setValue(grid.getCellValue(allRowId[0], 'ITEM_CD'));
						EVF.getComponent('EQUIP_REV').setValue(maxRev);
						EVF.getComponent('HD_EQUIP_REV').setValue(maxRev);
					}
					*/
	  	          }
	 	    });

		    if ('${param.itemDiv}' !== '') {
		        doSearch();
		    }
        }

        function doSearch() {

        	if (!('${ses.finCtrlCd}' == 'EM00' || '${ses.finCtrlCd}' == 'EM10' || '${ses.finCtrlCd}' == 'EM50')) { //전체, 설비관련 권한
        		return;
        	}

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

	        	var itemDesc = grid.getCellValue(id, "ITEM_DESC");
	        	if (itemDesc == '${DH1700_SUBTOTAL}' || itemDesc == '${DH1700_TOTAL}') {
					grid.checkRow(id, false);
				}
			}

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

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

	        	var itemDesc = grid.getCellValue(id, "ITEM_DESC");
	        	if (itemDesc == '${DH1700_SUBTOTAL}' || itemDesc == '${DH1700_TOTAL}') {
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


	    function doClose() {
	        formUtil.close();
	    }

    </script>

    <e:window id="DH1700" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
			<e:row>
				<e:label for="ITEM_DIV" title="${form_ITEM_DIV_N}" />
				<e:field>
					<e:select id="ITEM_DIV" name="ITEM_DIV" value="${empty form.ITEM_DIV ? param.itemDiv : form.ITEM_DIV}" options="${itemDivOptions}" width="${inputTextWidth}" disabled="${form_ITEM_DIV_D}" readOnly="${form_ITEM_DIV_RO}" required="${form_ITEM_DIV_R}" placeHolder="" />
				</e:field>
				<e:label for="GR_REQ_DATE" title="${form_GR_REQ_DATE_N}" />
				<e:field>
					<e:inputDate id="GR_FROM_DATE" toDate="GR_TO_DATE" name="GR_FROM_DATE" value="${empty form.GR_FROM_DATE ? param.grReqDate : form.GR_FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_GR_REQ_DATE_R}" disabled="${form_GR_REQ_DATE_D}" readOnly="${form_GR_REQ_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="GR_TO_DATE" fromDate="GR_FROM_DATE" name="GR_TO_DATE" value="${empty form.GR_TO_DATE ? param.grReqDate : form.GR_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_GR_REQ_DATE_R}" disabled="${form_GR_REQ_DATE_D}" readOnly="${form_GR_REQ_DATE_RO}" />
				</e:field>
				<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}" />
				<e:field>
					<e:inputText id="MAT_GROUP" style="${imeMode}" name="MAT_GROUP" value="${empty form.MAT_GROUP ? param.matGroup : form.MAT_GROUP}" width="${inputTextWidth}" maxLength="${form_MAT_GROUP_M}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="INVEST_DIV" title="${form_INVEST_DIV_N}" />
				<e:field>
					<e:select id="INVEST_DIV" name="INVEST_DIV" value="${empty form.INVEST_DIV ? param.investDiv : form.INVEST_DIV}" options="${investDivOptions}" width="${inputTextWidth}" disabled="${form_INVEST_DIV_D}" readOnly="${form_INVEST_DIV_RO}" required="${form_INVEST_DIV_R}" placeHolder="" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field colSpan="3">
					<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="${inputTextWidth}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
			</e:row>
    	</e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
   	        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<c:if test="${param.popupFlag eq true}">
            	<e:button label="${doClose_N }" id="doClose" onClick="doClose" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            </c:if>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
