<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/statistic/DH1560"
            ,refUrl = "/eversrm/master/bom/DH0521"
           ,grid;

        function init() {
    		grid = EVF.C('grid');
    		grid.setProperty('panelVisible', ${panelVisible});
		    if ('${param.detailView}' != 'true') {
	            grid.addRowEvent(function() {
	    			var matGroup = EVF.getComponent("MAT_GROUP").getValue();
	    			var plantCd = EVF.getComponent("PLANT_CD").getValue();
	    			var itemCls1 = EVF.getComponent("ITEM_CLS1").getValue();
	    			var itemCd = EVF.getComponent("ITEM_CD").getValue();
	    			var moldRev = EVF.getComponent("MOLD_REV").getValue();

	    			var addParam = [{"MAT_GROUP" : matGroup, "PLANT_CD" : plantCd, "ITEM_CLS1" : itemCls1, "ITEM_CD" : itemCd, "MOLD_REV" : moldRev}];
	            	grid.addRow(addParam);
	            });

			    grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {

		        	var processDesc = grid.getCellValue(rowId, "PROCESS_DESC");
		        	if (processDesc == '${DH1560_AMT}' || processDesc == '${DH1560_RATE}') {
		        		return;
		        	}

		  	      if (celName === 'ITEM_CLS2_IMG') {
		          	var itemCls1 = grid.getCellValue(rowId, 'ITEM_CLS1');
		            if (itemCls1 === '') {
		                return;
		            }
					var param = {
							'callBackFunction': 'itemCls2Callback',
							'detailView': false,
							'rowId': rowId,
							'type': '1',
							'ITEM_CLS': itemCls1
						};
						everPopup.openCommonPopup(param, "SP0064");
		        	} else if (celName === 'ITEM_CLS3_IMG') {
		            	var itemCls2 = grid.getCellValue(rowId, 'ITEM_CLS2');
		            	if (itemCls2 === '') {
		                	return;
		            	}
						var param = {
							'callBackFunction': 'itemCls3Callback',
							'detailView': false,
							'rowId': rowId,
							'type': '2',
							'ITEM_CLS': itemCls2
						};
						everPopup.openCommonPopup(param, "SP0064");
		        	}

			    });

			    grid.cellChangeEvent(function (rowId, celname, iRow, iCol, newValue, oldValue) {

		        	var processDesc = grid.getCellValue(rowId, "PROCESS_DESC");
		        	if (celname == "PROCESS_DESC") processDesc = oldValue;
		        	if (processDesc == '${DH1560_AMT}' || processDesc == '${DH1560_RATE}') {
		        		grid.setCellValue(rowId, celname, oldValue);
		        		return;
		        	}

		        	switch (celname) {
	                case 'ITEM_CD':
	                case 'MOLD_REV':
						// form의 Revision 값과 grid의 Revision 값을 비교하여 grid의 값이 클 경우 form에 grid의 값을 셋팅해주고
						// grid 값이 form 값보다 작을 경우 전체 조회 후 MAX 값을 셋팅해준다.
						if(EVF.getComponent('MOLD_REV').getValue() < newValue) {
							EVF.getComponent('MOLD_REV').setValue(newValue);
						} else {
							var allRowArr = [];
							var allRowId = grid.getAllRowId();
							for(var idx in allRowId) {
								allRowArr.push(grid.getCellValue(allRowId[idx], 'MOLD_REV'));
							}

							var maxRev = Math.max.apply(null, allRowArr);

							EVF.getComponent('MOLD_REV').setValue(maxRev);
						}
						break;
	                case 'MOLD_DIV2':
	                case 'PROCESS_CD':
	                case 'PROCESS_DESC':
	                case 'PROCESS_CVT':
	                    break;

	                case 'MOLD_DIV1':
	                    grid.setCellValue(rowId, 'MOLD_DIV2', '');
	                    break;

	                default:
	                	var bidMatAmt = Number(grid.getCellValue(rowId, "BID_CASTING_PRC"))
	                				  + Number(grid.getCellValue(rowId, "BID_STEEL_PRC"))
	                				  + Number(grid.getCellValue(rowId, "BID_PART_PRC"))
	                				  + Number(grid.getCellValue(rowId, "BID_LASER_PRC"))
	                				  + Number(grid.getCellValue(rowId, "BID_HEATING_PRC"))
	                				  + Number(grid.getCellValue(rowId, "BID_MAT_OTHER_PRC"));
		            	var bidProcessAmt = Number(grid.getCellValue(rowId, "BID_PLAN_PRC"))
									  + Number(grid.getCellValue(rowId, "BID_NCDATA_PRC"))
									  + Number(grid.getCellValue(rowId, "BID_PROCESS_PRC"))
									  + Number(grid.getCellValue(rowId, "BID_FINISHING_PRC"))
									  + Number(grid.getCellValue(rowId, "BID_PROCESS_OTHER_PRC"));
		            	var bidSumAmt = bidMatAmt
		            				  + bidProcessAmt
		            				  + Number(grid.getCellValue(rowId, "BID_OTHER_PRC"))
		            				  + Number(grid.getCellValue(rowId, "BID_ECO_PRC"));

						grid.setCellValue(rowId, "BID_MAT_AMT", bidMatAmt);
						grid.setCellValue(rowId, "BID_PROCESS_AMT", bidProcessAmt);
						grid.setCellValue(rowId, "BID_SUM_AMT", bidSumAmt);

	                	var exeMatAmt = Number(grid.getCellValue(rowId, "EXE_CASTING_PRC"))
	 				 				  + Number(grid.getCellValue(rowId, "EXE_STEEL_PRC"))
	 				 				  + Number(grid.getCellValue(rowId, "EXE_PART_PRC"))
	  								  + Number(grid.getCellValue(rowId, "EXE_LASER_PRC"))
	  								  + Number(grid.getCellValue(rowId, "EXE_HEATING_PRC"))
	  								  + Number(grid.getCellValue(rowId, "EXE_MAT_OTHER_PRC"));
	  					var exeProcessAmt = Number(grid.getCellValue(rowId, "EXE_PLAN_PRC"))
									  + Number(grid.getCellValue(rowId, "EXE_NCDATA_PRC"))
									  + Number(grid.getCellValue(rowId, "EXE_PROCESS_PRC"))
									  + Number(grid.getCellValue(rowId, "EXE_FINISHING_PRC"))
									  + Number(grid.getCellValue(rowId, "EXE_PROCESS_OTHER_PRC"));
	  					var exeSumAmt = exeMatAmt
	  								  + exeProcessAmt
	 				 				  + Number(grid.getCellValue(rowId, "EXE_OTHER_PRC"))
	  								  + Number(grid.getCellValue(rowId, "EXE_ECO_PRC"));

	  					grid.setCellValue(rowId, "EXE_MAT_AMT", exeMatAmt);
	  					grid.setCellValue(rowId, "EXE_PROCESS_AMT", exeProcessAmt);
	  					grid.setCellValue(rowId, "EXE_SUM_AMT", exeSumAmt);

						break;
	                }
	            });
		    }

			if(${_gridType eq "RG"}) {
				grid.setColGroup([{
					"groupName": '${DH1560_BID_PRC}',
					"columns": [ "BID_CASTING_PRC","BID_STEEL_PRC","BID_PART_PRC","BID_LASER_PRC","BID_HEATING_PRC","BID_MAT_OTHER_PRC","BID_MAT_AMT","BID_PLAN_PRC","BID_NCDATA_PRC","BID_PROCESS_PRC","BID_FINISHING_PRC","BID_PROCESS_OTHER_PRC","BID_PROCESS_AMT","BID_OTHER_PRC","BID_ECO_PRC","BID_SUM_AMT" ]
				}, {
					"groupName": '${DH1560_EXE_PRC}',
					"columns": [ "EXE_CASTING_PRC","EXE_STEEL_PRC","EXE_PART_PRC","EXE_HEATING_PRC","EXE_LASER_PRC","EXE_MAT_OTHER_PRC","EXE_MAT_AMT","EXE_PLAN_PRC","EXE_NCDATA_PRC","EXE_PROCESS_PRC","EXE_FINISHING_PRC","EXE_PROCESS_OTHER_PRC","EXE_PROCESS_AMT","EXE_OTHER_PRC","EXE_ECO_PRC","EXE_SUM_AMT" ]
				}]);
			} else {
				grid.setGroupCol(
						[
							<%--
                              {'colName' : 'BID_CASTING_PRC',  'colIndex': 7, 'titleText' : '${DH1560_BID_MAT_PRC}'},
                              {'colName' : 'BID_PLAN_PRC',     'colIndex': 6, 'titleText' : '${DH1560_BID_PROCESS_PRC}'},
                              {'colName' : 'EXE_CASTING_PRC',  'colIndex': 7, 'titleText' : '${DH1560_EXE_MAT_PRC}'},
                              {'colName' : 'EXE_PLAN_PRC',     'colIndex': 6, 'titleText' : '${DH1560_EXE_PROCESS_PRC}'}
                            --%>

							{'colName' : 'BID_CASTING_PRC',  'colIndex': 16, 'titleText' : '${DH1560_BID_PRC}'},
							{'colName' : 'EXE_CASTING_PRC',  'colIndex': 16, 'titleText' : '${DH1560_EXE_PRC}'}
						]
				);
			}
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

		    if ('${param.detailView}' != 'true') {
				grid.excelImportEvent({
		  	          'append': false
		  	        }, function (msg, code) {
		  	          if (code) {
		  	            grid.checkAll(true);

		  	          	var itemCls1 = EVF.getComponent('ITEM_CLS1').getValue();

		  	            var allRowArr = [];
						var allRowId = grid.getAllRowId();
						for(var idx in allRowId) {
	                        var rowId = allRowId[idx];

	                        allRowArr.push(grid.getCellValue(allRowId[idx], 'MOLD_REV'));

	                        grid.setCellValue(rowId, 'ITEM_CLS1', itemCls1);
	                        grid.setCellValue(rowId, 'ITEM_CLS2', grid.getCellValue(rowId, 'ITEM_CLS2_IMG'));
	                        grid.setCellValue(rowId, 'ITEM_CLS3', grid.getCellValue(rowId, 'ITEM_CLS3_IMG'));

						}

						var maxRev = Math.max.apply(null, allRowArr);

						EVF.getComponent('MOLD_REV').setValue(maxRev);

						for(var idx in allRowId) {
							if (grid.getCellValue(allRowId[idx], 'MOLD_REV') == maxRev) {
								EVF.getComponent('ITEM_CD').setValue(grid.getCellValue(allRowId[idx], 'ITEM_CD'));
								break;
							}
						}
		  	          }
		 	        });
		    }

	        EVF.getComponent('ITEM_CLS1').setValue('01');

	        if ('${param.itemCd}' !== '') {
		        doSearch();


}

        }

        function doSearch() {

        	if (!('${ses.finCtrlCd}' == 'EM00' || '${ses.finCtrlCd}' == 'EM30' || '${ses.finCtrlCd}' == 'EM50')) { //전체, 금형관련 권한
        		return;
        	}

			if (EVF.getComponent("MAT_GROUP").getValue() == "" && EVF.getComponent("ITEM_CLS2").getValue() == "" && EVF.getComponent("PLANT_CD").getValue() == "" &&
					EVF.getComponent("ITEM_CD").getValue() == "" && EVF.getComponent("MOLD_DIV2").getValue() == "" && EVF.getComponent("PROCESS_CD").getValue() == "") {
	                alert("${msg.M0124 }");
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
	        	var processDesc = grid.getCellValue(id, "PROCESS_DESC");
	        	if (processDesc == '${DH1560_AMT}' || processDesc == '${DH1560_RATE}') {
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

			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
			var itemCd = EVF.getComponent('ITEM_CD').getValue();
			var moldRev = 0;

			for( var idx in selRowId ) {

				if (itemCd == '' || itemCd == grid.getCellValue(selRowId[idx], "ITEM_CD")) {
					if (moldRev < Number(grid.getCellValue(selRowId[idx], "MOLD_REV"))) {
						moldRev = Number(grid.getCellValue(selRowId[idx], "MOLD_REV"));
					}
				}

			}

			EVF.getComponent('MOLD_REV').setValue(moldRev);

            if(!confirm('${msg.M0021}')) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+'/doExcelUpload', function() {
              alert(this.getResponseMessage());
              doSearch();
            });
          }

        function doDelete() {
    		var rowIds = grid.getAllRowId();
			for( var id in rowIds ) {
	        	var processDesc = grid.getCellValue(id, "PROCESS_DESC");
	        	if (processDesc == '${DH1560_AMT}' || processDesc == '${DH1560_RATE}') {
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


        function searchITEM_CD() {
            var param = {
              'callBackFunction': 'selectItemCd',
              'detailView': false
            };

            everPopup.openPopupByScreenId('DH0521', 1000, 550, param);
        }

        function selectItemCd(data) {
            EVF.getComponent("ITEM_CD").setValue(data.ITEM_CD);
            EVF.getComponent("ITEM_NM").setValue(data.ITEM_DESC);
        }

        function onClickItemCd() {
            EVF.getComponent('ITEM_NM').setValue('');
          }

		function itemCls2Callback(result) {
			console.log(result);
		    grid.setCellValue(result.rowId, 'ITEM_CLS2', result.CODE);
		    grid.setCellValue(result.rowId, 'ITEM_CLS2_IMG', result.TEXT);
		}

		function itemCls3Callback(result) {
		    grid.setCellValue(result.rowId, 'ITEM_CLS3', result.CODE);
		    grid.setCellValue(result.rowId, 'ITEM_CLS3_IMG', result.TEXT);
		}

        function doClose() {
            formUtil.close();
        }

	    function getitem_cls() {

	        var store = new EVF.Store();

			console.log(this.getData());
	        var cls_type = this.getData();
	        var item_cls = '';
	        if (cls_type=='2') {
	          item_cls= EVF.getComponent("ITEM_CLS1").getValue();
	          clearX('3');
	        }
	        if (cls_type=='3') {
	          item_cls= EVF.getComponent("ITEM_CLS2").getValue();
	        }
	        if (cls_type=='4') {
	          item_cls= EVF.getComponent("ITEM_CLS3").getValue();
	        }

	        store.load(refUrl + '/getItem_Cls.so?CLS_TYPE='+cls_type+'&ITEM_CLS='+item_cls, function() {
	          EVF.C('ITEM_CLS'+ cls_type ).setOptions(this.getParameter("item_cls"));
	        });


			/*var id = this.getID();
			var store = new EVF.Store();
			var cls_type = "";
			var item_cls = "";

			switch(id) {
				case 'ITEM_CLS1':
					item_cls = EVF.getComponent("ITEM_CLS1").getValue();
					cls_type = "2";
					clearX('3');

					break;
				case 'ITEM_CLS2':
					item_cls = EVF.getComponent("ITEM_CLS2").getValue();
					cls_type = "3";

					break;
				case 'ITEM_CLS3':
					item_cls = EVF.getComponent("ITEM_CLS3").getValue();
					cls_type = "4";

					break;
			}

			store.load(refUrl + '/getItem_Cls.so?CLS_TYPE='+cls_type+'&ITEM_CLS='+item_cls, function() {
				EVF.C('ITEM_CLS'+ cls_type ).setOptions(this.getParameter("item_cls"));
			});*/
	    }

		function clearX( cls_typef ) {
			EVF.C('ITEM_CLS'+ cls_typef ).setOptions( JSON.parse('[]') );
		}

    </script>

    <e:window id="DH1560" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
		        <e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
        		<e:field>
        		  <e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${matGroupOptions}" width="${inputTextWidth}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder="" />
		        </e:field>
		        <e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}" />
        		<e:field colSpan="3">
        			<e:select id="ITEM_CLS1" name="ITEM_CLS1" data="2" onChange="getitem_cls" value="${form.ITEM_CLS1}" options="${refITEM_CLASS1 }" width="${inputTextWidth}" disabled="${form_ITEM_CLS1_D}" readOnly="${form_ITEM_CLS1_RO}" required="${form_ITEM_CLS1_R}" placeHolder="" />
        			<e:text>&nbsp;</e:text>
        			<e:select id="ITEM_CLS2" name="ITEM_CLS2" data="3" onChange="getitem_cls" value="${form.ITEM_CLS2}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
        			<e:text>&nbsp;</e:text>
        			<e:select id="ITEM_CLS3" name="ITEM_CLS3" data="4" value="${form.ITEM_CLS3}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
        		</e:field>
            </e:row>
            <e:row>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
		        <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
        		<e:field>
        			<e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${empty form.ITEM_CD ? param.itemCd : form.ITEM_CD}" width="40%" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onClick="onClickItemCd"/>
		     		<e:text>&nbsp;</e:text>
		   			<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="55%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
		   		</e:field>
				<e:label for="MOLD_REV" title="${form_MOLD_REV_N}"/>
				<e:field>
					<e:inputText id="MOLD_REV" style="ime-mode:inactive" name="MOLD_REV" value="${empty form.MOLD_REV ? param.moldRev : form.MOLD_REV}" width="${inputTextWidth}" maxLength="${form_MOLD_REV_M}" disabled="${form_MOLD_REV_D}" readOnly="${form_MOLD_REV_RO}" required="${form_MOLD_REV_R}"/>
        		</e:field>
            </e:row>
            <e:row>
				<e:label for="MOLD_DIV1" title="${form_MOLD_DIV1_N}"/>
				<e:field>
					<e:select id="MOLD_DIV1" name="MOLD_DIV1" value="${form.MOLD_DIV1}" options="${moldDiv1Options}" width="${inputTextWidth}" disabled="${form_MOLD_DIV1_D}" readOnly="${form_MOLD_DIV1_RO}" required="${form_MOLD_DIV1_R}" placeHolder="" />
				</e:field>
				<e:label for="MOLD_DIV2" title="${form_MOLD_DIV2_N}"/>
				<e:field>
					<e:select id="MOLD_DIV2" name="MOLD_DIV2" value="${form.MOLD_DIV2}" options="${moldDiv2Options}" width="${inputTextWidth}" disabled="${form_MOLD_DIV2_D}" readOnly="${form_MOLD_DIV2_RO}" required="${form_MOLD_DIV2_R}" placeHolder="" />
				</e:field>
				<e:label for="PROCESS_CD" title="${form_PROCESS_CD_N}"/>
				<e:field>
		   			<e:inputText id="PROCESS_CD" style="${imeMode}" name="PROCESS_CD" value="${form.PROCESS_CD}" width="200" maxLength="${form_PROCESS_CD_M}" disabled="${form_PROCESS_CD_D}" readOnly="${form_PROCESS_CD_RO}" required="${form_PROCESS_CD_R}"/>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PRODUCTION_DIV" title="${form_PRODUCTION_DIV_N}"/>
				<e:field colSpan="5">
					<e:select id="PRODUCTION_DIV" name="PRODUCTION_DIV" value="${form.PRODUCTION_DIV}" options="${productionDivOptions}" width="${inputTextWidth}" disabled="${form_PRODUCTION_DIV_D}" readOnly="${form_PRODUCTION_DIV_RO}" required="${form_PRODUCTION_DIV_R}" placeHolder="" />
				</e:field>
           </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<c:if test="${ses.finCtrlCd == 'EM00' || ses.finCtrlCd == 'EM30'  || ses.finCtrlCd == 'EM50'}">
	            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    	        <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        	    <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			</c:if>
			<%--
            <e:button id="doExcelUpload" name="doExcelUpload" label="${doExcelUpload_N}" onClick="doExcelUpload" disabled="${doExcelUpload_D}" visible="${doExcelUpload_V}"/>
			 --%>
			<c:if test="${param.popupFlag eq true}">
            	<e:button label="${doClose_N }" id="doClose" onClick="doClose" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            </c:if>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
