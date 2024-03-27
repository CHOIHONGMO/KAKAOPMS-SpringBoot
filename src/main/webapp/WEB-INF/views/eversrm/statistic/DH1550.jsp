<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/statistic/DH1550"
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
	    			var equipRev = EVF.getComponent("EQUIP_REV").getValue();

	    			var addParam = [{"MAT_GROUP" : matGroup, "PLANT_CD" : plantCd, "ITEM_CLS1" : itemCls1, "ITEM_CD" : itemCd, "EQUIP_REV" : equipRev}];
	            	grid.addRow(addParam);
	            });

			    grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {

			        if ('${param.detailView}' === 'true' && (celName === 'EQUIP_DIV2')) {
			            return;
			        }

		        	var equipDesc = grid.getCellValue(rowId, "EQUIP_DESC");
		        	if (equipDesc == '${DH1550_CHANGE_REASON_0}' || equipDesc == '${DH1550_CHANGE_REASON_1}' || equipDesc == '${DH1550_CHANGE_REASON_2}' || equipDesc == '${DH1550_CHANGE_REASON_3}') {
		        		return;
		        	}

			        if (celName === 'EQUIP_DIV2_NM') {
			        	var equipDiv1 = grid.getCellValue(rowId, "EQUIP_DIV1");

			        	if (equipDiv1 == "") {
		                    alert("${msg.M0121 }");
		                    return;
			        	}
						var param = {
							'callBackFunction': 'equipDiv2CodeCallback',
							'detailView': false,
							'rowId': rowId,
							'codeType': 'M209',
							'text1': equipDiv1
						};
						everPopup.openCommonPopup(param, "SP0047");
			        } else if (celName === 'ITEM_CLS2_IMG') {
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
		        	var equipDesc = grid.getCellValue(rowId, "EQUIP_DESC");
		        	if (celname == "EQUIP_DESC") equipDesc = oldValue;
		        	if (equipDesc == '${DH1550_CHANGE_REASON_0}' || equipDesc == '${DH1550_CHANGE_REASON_1}' || equipDesc == '${DH1550_CHANGE_REASON_2}' || equipDesc == '${DH1550_CHANGE_REASON_3}') {
		        		grid.setCellValue(rowId, celname, oldValue);
		        		return;
		        	}

			    	switch (celname) {
	                    case 'EQUIP_DIV1':

	                        grid.setCellValue(rowId, 'EQUIP_DIV2', '');
	                    	grid.setCellValue(rowId, 'EQUIP_DIV2_NM', '');

	                        break;

						case 'EQUIP_REV':

							// form의 Revision 값과 grid의 Revision 값을 비교하여 grid의 값이 클 경우 form에 grid의 값을 셋팅해주고
							// grid 값이 form 값보다 작을 경우 전체 조회 후 MAX 값을 셋팅해준다.
							if(EVF.getComponent('EQUIP_REV').getValue() < newValue) {
								EVF.getComponent('EQUIP_REV').setValue(newValue);
								EVF.getComponent('HD_EQUIP_REV').setValue(newValue);
							} else {
								var allRowArr = [];
								var allRowId = grid.getAllRowId();
								for(var idx in allRowId) {
									allRowArr.push(grid.getCellValue(allRowId[idx], 'EQUIP_REV'));
								}

								var maxRev = Math.max.apply(null, allRowArr);

								EVF.getComponent('EQUIP_REV').setValue(maxRev);
								EVF.getComponent('HD_EQUIP_REV').setValue(maxRev);
							}
							break;

						case 'EQUIP_CD':

							<%-- grid.setCellValue(rowId, "EQUIP_YEAR", "");--%>
							grid.setCellValue(rowId, "EQUIP_DESC", "");
							grid.setCellValue(rowId, "MAKER", "");
							grid.setCellValue(rowId, "EXE_PRC", "0");
							grid.setCellValue(rowId, "EXE_QT", "0");
							grid.setCellValue(rowId, "EXE_COMMON_PRC", "0");

							break;

						case 'EQUIP_DESC':
						case 'MAKER':
						case 'EXE_PRC':
						case 'EXE_QT':
						case 'EXE_COMMON_PRC':

				            var equipCd = grid.getCellValue(rowId, 'EQUIP_CD');
				            if (everString.isNotEmpty(equipCd)) {
				                alert('${msg.CAN_NOT_EDIT}');
				                grid.setCellValue(rowId, celname, oldValue);
				                return;
				            }

							break;

	                    default:
	                        return;

	                }
	            });
		    }

		    if ('${ses.finCtrlCd}' == 'EM10' || '${ses.finCtrlCd}' == 'EM50') {

		    	grid.hideCol('MAKER', true);
		    	grid.hideCol('EXE_QT', true);
		    	grid.hideCol('EXE_PRC', true);
		    	grid.hideCol('EXE_EXCLUSIVE_PRC', true);
		    	grid.hideCol('EXE_COMMON_PRC', true);

				if(${_gridType eq "RG"}) {
					grid.setColGroup([{
						"groupName": '${DH1550_BID_PRC}',
						"columns": [ "BID_QT", "BID_PRC", "BID_EXCLUSIVE_PRC", "BID_COMMON_PRC" ]
					}, {
						"groupName": '${DH1550_EST_PRC}',
						"columns": [ "EST_QT", "EST_PRC", "EST_EXCLUSIVE_PRC", "EST_COMMON_PRC" ]
					}]);
				} else {
					grid.setGroupCol(
							[
								{'colName' : 'BID_QT',    'colIndex': 4, 'titleText' : '${DH1550_BID_PRC}'},
								{'colName' : 'EST_QT',    'colIndex': 4, 'titleText' : '${DH1550_EST_PRC}'}
							]
					);
				}
		    } else {
				if(${_gridType eq "RG"}) {
					grid.setColGroup([{
						"groupName": '${DH1550_BID_PRC}',
						"columns": [ "BID_QT", "BID_PRC", "BID_EXCLUSIVE_PRC", "BID_COMMON_PRC" ]
					}, {
						"groupName": '${DH1550_EST_PRC}',
						"columns": [ "EST_QT", "EST_PRC", "EST_EXCLUSIVE_PRC", "EST_COMMON_PRC" ]
					}, {
						"groupName": '${DH1550_EXE_PRC}',
						"columns": [ "MAKER", "EXE_QT", "EXE_PRC", "EXE_EXCLUSIVE_PRC", "EXE_COMMON_PRC" ]
					}]);
				} else {
					grid.setGroupCol(
							[
								{'colName' : 'BID_QT',    'colIndex': 4, 'titleText' : '${DH1550_BID_PRC}'},
								{'colName' : 'EST_QT',    'colIndex': 4, 'titleText' : '${DH1550_EST_PRC}'},
								{'colName' : 'MAKER',     'colIndex': 5, 'titleText' : '${DH1550_EXE_PRC}'}
							]
					);
				}

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

							allRowArr.push(grid.getCellValue(rowId, 'EQUIP_REV'));

	                        grid.setCellValue(rowId, 'ITEM_CLS1', itemCls1);
	                        grid.setCellValue(rowId, 'ITEM_CLS2', grid.getCellValue(rowId, 'ITEM_CLS2_IMG'));
	                        grid.setCellValue(rowId, 'ITEM_CLS3', grid.getCellValue(rowId, 'ITEM_CLS3_IMG'));

	                        grid.setCellValue(rowId, 'EQUIP_DIV2', grid.getCellValue(rowId, 'EQUIP_DIV2_NM'));
						}

						var maxRev = Math.max.apply(null, allRowArr);

						if (maxRev != "") {
							EVF.getComponent('ITEM_CD').setValue(grid.getCellValue(allRowId[0], 'ITEM_CD'));
							EVF.getComponent('EQUIP_REV').setValue(maxRev);
							EVF.getComponent('HD_EQUIP_REV').setValue(maxRev);
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

        	if (!('${ses.finCtrlCd}' == 'EM00' || '${ses.finCtrlCd}' == 'EM10' || '${ses.finCtrlCd}' == 'EM50')) { //전체, 설비관련 권한
        		return;
        	}

			var itemCd = EVF.getComponent("ITEM_CD").getValue();
			var equipRev = EVF.getComponent("EQUIP_REV").getValue();

			if (EVF.getComponent("MAT_GROUP").getValue() == "" && EVF.getComponent("ITEM_CLS2").getValue() == "" && EVF.getComponent("PLANT_CD").getValue() == "" &&
				EVF.getComponent("ITEM_CD").getValue() == "" && EVF.getComponent("EQUIP_DIV1").getValue() == "" && EVF.getComponent("CHANGE_REASON_CD").getValue() == "" &&
				EVF.getComponent("EQUIP_CD").getValue() == "") {
                alert("${msg.M0124 }");
                return;
			}

			var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {

            	var formValue = JSON.parse(this.getParameter("form"));

            	if( formValue != null && formValue != "" ) {
    	      		var formKey = Object.keys(formValue);
    	        	for(var i = 0; i <formKey.length; i++){
    	        		EVF.getComponent(formKey[i]).setValue(formValue[formKey[i]]);
    	        	}
            	}

                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {
    		var rowIds = grid.getAllRowId();

			for( var id in rowIds ) {
	        	var equipDesc = grid.getCellValue(id, "EQUIP_DESC");
	        	if (equipDesc == '${DH1550_CHANGE_REASON_0}' || equipDesc == '${DH1550_CHANGE_REASON_1}' || equipDesc == '${DH1550_CHANGE_REASON_2}' || equipDesc == '${DH1550_CHANGE_REASON_3}') {
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

			// 한개의 품번만 업로드 가능하게 설정
			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
			var equipRev = 0;

			for( var idx in selRowId ) {
				if(grid.getCellValue(selRowId[0], "MAT_GROUP") != grid.getCellValue(selRowId[idx], "MAT_GROUP")) {
					alert('${DH1550_0001}');
					return;
				} else if(grid.getCellValue(selRowId[0], "PLANT_CD") != grid.getCellValue(selRowId[idx], "PLANT_CD")) {
					alert('${DH1550_0002}');
					return;
				} else if(!(grid.getCellValue(selRowId[0], "ITEM_CLS1") == grid.getCellValue(selRowId[idx], "ITEM_CLS1") &&
						    grid.getCellValue(selRowId[0], "ITEM_CLS2") == grid.getCellValue(selRowId[idx], "ITEM_CLS2") &&
						    grid.getCellValue(selRowId[0], "ITEM_CLS3") == grid.getCellValue(selRowId[idx], "ITEM_CLS3"))) {
					alert('${DH1550_0003}');
					return;
				} else if(grid.getCellValue(selRowId[0], "ITEM_CD") != grid.getCellValue(selRowId[idx], "ITEM_CD")) {
					alert('${DH1550_0004}');
					return;
				} else {
					//EVF.getComponent('ITEM_CD').setValue(grid.getCellValue(selRowId[0], "ITEM_CD"));
				}

				if (equipRev < Number(grid.getCellValue(selRowId[idx], "EQUIP_REV"))) {
					equipRev = Number(grid.getCellValue(selRowId[idx], "EQUIP_REV"));
				}

			}

			EVF.getComponent('EQUIP_REV').setValue(equipRev);
			EVF.getComponent('HD_EQUIP_REV').setValue(equipRev);

            if(!confirm('${msg.M0021}')) { return; }

			EVF.getComponent('HD_MAT_GROUP').setValue(grid.getCellValue(selRowId[0], "MAT_GROUP"));
			EVF.getComponent('HD_PLANT_CD').setValue(grid.getCellValue(selRowId[0],  "PLANT_CD"));
			EVF.getComponent('HD_ITEM_CLS1').setValue(EVF.getComponent('ITEM_CLS1').getValue());
			EVF.getComponent('HD_ITEM_CLS2').setValue(grid.getCellValue(selRowId[0], "ITEM_CLS2"));
			EVF.getComponent('HD_ITEM_CLS3').setValue(grid.getCellValue(selRowId[0], "ITEM_CLS3"));
			EVF.getComponent('HD_ITEM_CD').setValue(grid.getCellValue(selRowId[0],   "ITEM_CD"));

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
	        	var equipDesc = grid.getCellValue(id, "EQUIP_DESC");
	        	if (equipDesc == '${DH1550_CHANGE_REASON_0}' || equipDesc == '${DH1550_CHANGE_REASON_1}' || equipDesc == '${DH1550_CHANGE_REASON_2}' || equipDesc == '${DH1550_CHANGE_REASON_3}') {
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

		function equipDiv2CodeCallback(result) {
		    grid.setCellValue(result.rowId, 'EQUIP_DIV2', result.CODE);
		    grid.setCellValue(result.rowId, 'EQUIP_DIV2_NM', result.CODE_DESC);
		}


		function itemCls2Callback(result) {
		    grid.setCellValue(result.rowId, 'ITEM_CLS2', result.CODE);
		    grid.setCellValue(result.rowId, 'ITEM_CLS2_IMG', result);
		}

		function itemCls3Callback(result) {
		    grid.setCellValue(result.rowId, 'ITEM_CLS3', result.CODE);
		    grid.setCellValue(result.rowId, 'ITEM_CLS3_IMG', result);
		}

	    function doClose() {
	        formUtil.close();
	    }
/*
		function doSearchMatCds() {
			var param = {
				'detailView' : false,
				'popupFlag'  : true,
				'callBackFunction': 'setMatCd'
			};

			everPopup.openCommonPopup(param, 'MP0002');
		}

		function setMatCd(data) {
			var code = "";

			for(var i = 0; i < data.length; i++) {
				if(i+1 != data.length ) {
					code += data[i].CODE +", ";
				} else {
					code += data[i].CODE;
				}
			}

			EVF.getComponent('MAT_CDS').setValue(code);
		}
*/
	    function getitem_cls() {
	        var store = new EVF.Store();

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
	      }

		function clearX( cls_typef ) {
			EVF.C('ITEM_CLS'+ cls_typef ).setOptions( JSON.parse('[]') );
		}

		function getequip_div2() {
		    var store = new EVF.Store();

    var equip_div1 = EVF.getComponent("EQUIP_DIV1").getValue();
            if (equip_div1 == "") {
		    	EVF.C('EQUIP_DIV2').setOptions( JSON.parse('[]') );
		    	return;
		    }

		    store.load(baseUrl + '/getEquipDiv2.so?EQUIP_DIV1=' + equip_div1, function() {
		    	EVF.C('EQUIP_DIV2').setOptions(this.getParameter("equip_div2"));
	    	});
		}


    </script>

    <e:window id="DH1550" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="formSearch" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
			<e:inputHidden id="HD_MAT_GROUP" name="HD_MAT_GROUP" value="${form.HD_MAT_GROUP}"/>
			<e:inputHidden id="HD_PLANT_CD" name="HD_PLANT_CD" value="${form.HD_PLANT_CD}"/>
			<e:inputHidden id="HD_ITEM_CLS1" name="HD_ITEM_CLS1" value="${form.HD_ITEM_CLS1}"/>
			<e:inputHidden id="HD_ITEM_CLS2" name="HD_ITEM_CLS2" value="${form.HD_ITEM_CLS2}"/>
			<e:inputHidden id="HD_ITEM_CLS3" name="HD_ITEM_CLS3" value="${form.HD_ITEM_CLS3}"/>
			<e:inputHidden id="HD_ITEM_CD" name="HD_ITEM_CD" value="${form.HD_ITEM_CD}"/>
			<e:inputHidden id="HD_EQUIP_REV" name="HD_EQUIP_REV" value="${form.HD_EQUIP_REV}"/>
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
				<e:label for="EQUIP_REV" title="${form_EQUIP_REV_N}"/>
				<e:field>
					<e:inputText id="EQUIP_REV" style="ime-mode:inactive" name="EQUIP_REV" value="${empty form.EQUIP_REV ? param.equipRev : form.EQUIP_REV}" width="${inputTextWidth}" maxLength="${form_EQUIP_REV_M}" disabled="${form_EQUIP_REV_D}" readOnly="${form_EQUIP_REV_RO}" required="${form_EQUIP_REV_R}"/>
        		</e:field>
            </e:row>
            <e:row>
				<e:label for="EQUIP_DIV1" title="${form_EQUIP_DIV1_N}"/>
				<e:field>
					<e:select id="EQUIP_DIV1" name="EQUIP_DIV1" onChange="getequip_div2" value="${form.EQUIP_DIV1}" options="${equipDiv1Options}" width="${inputTextWidth}" disabled="${form_EQUIP_DIV1_D}" readOnly="${form_EQUIP_DIV1_RO}" required="${form_EQUIP_DIV1_R}" placeHolder="" />
					<e:select id="EQUIP_DIV2" name="EQUIP_DIV2" value="${form.EQUIP_DIV2}" options="${equipDiv2Options}" width="${inputTextWidth}" disabled="${form_EQUIP_DIV2_D}" readOnly="${form_EQUIP_DIV2_RO}" required="${form_EQUIP_DIV2_R}" placeHolder="" />
				</e:field>
				<e:label for="CHANGE_REASON_CD" title="${form_CHANGE_REASON_CD_N}"/>
				<e:field>
					<e:select id="CHANGE_REASON_CD" name="CHANGE_REASON_CD" value="${form.CHANGE_REASON_CD}" options="${changeReasonCdOptions}" width="${inputTextWidth}" disabled="${form_CHANGE_REASON_CD_D}" readOnly="${form_CHANGE_REASON_CD_RO}" required="${form_CHANGE_REASON_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="EQUIP_CD" title="${form_EQUIP_CD_N}"/>
				<e:field>
					<e:select id="EQUIP_CD" name="EQUIP_CD" value="${form.EQUIP_CD}" options="${equipCdOptions}" width="${inputTextWidth}" disabled="${form_EQUIP_CD_D}" readOnly="${form_EQUIP_CD_RO}" required="${form_EQUIP_CD_R}" placeHolder="" />
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
			<c:if test="${ses.finCtrlCd == 'EM00' || ses.finCtrlCd == 'EM10'  || ses.finCtrlCd == 'EM50'}">
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

    	<e:searchPanel id="form" title="${DH1550_GENERAL_INFO}" labelWidth="135" labelAlign="${labelAlign}" columnCount="3">
            <e:row>
		        <e:label for="OUTPUT_QT" title="${form_OUTPUT_QT_N}"/>
        		<e:field>
					<e:inputNumber id="OUTPUT_QT" name="OUTPUT_QT" value="${form.OUTPUT_QT}" maxValue="${form_OUTPUT_QT_M}" decimalPlace="${form_OUTPUT_QT_NF}" disabled="${form_OUTPUT_QT_D}" readOnly="${form_OUTPUT_QT_RO}" required="${form_OUTPUT_QT_R}" width="${inputTextWidth }"/>
        		</e:field>
		        <e:label for="WORK_HOURS" title="${form_WORK_HOURS_N}"/>
        		<e:field>
					<e:inputNumber id="WORK_HOURS" name="WORK_HOURS" value="${form.WORK_HOURS}" maxValue="${form_WORK_HOURS_M}" decimalPlace="${form_WORK_HOURS_NF}" disabled="${form_WORK_HOURS_D}" readOnly="${form_WORK_HOURS_RO}" required="${form_WORK_HOURS_R}" width="${inputTextWidth }"/>
        		</e:field>
		        <e:label for="OUTPUT_RATE" title="${form_OUTPUT_RATE_N}"/>
        		<e:field>
        			<e:inputText id='OUTPUT_RATE' name="OUTPUT_RATE" value="${form.OUTPUT_RATE}" label='${form_OUTPUT_RATE_N }' width='${inputTextWidth }' maxLength='${form_OUTPUT_RATE_M }' required='${form_OUTPUT_RATE_R }' readOnly='${form_OUTPUT_RATE_RO }' disabled='${form_OUTPUT_RATE_D }' visible='${form_OUTPUT_RATE_V }'/>
        		</e:field>
            </e:row>
            <e:row>
		        <e:label for="WORK_DAYS" title="${form_WORK_DAYS_N}"/>
        		<e:field>
        			<e:inputText id='WORK_DAYS' name="WORK_DAYS" value="${form.WORK_DAYS}" label='${form_WORK_DAYS_N }' width='${inputTextWidth }' maxLength='${form_WORK_DAYS_M }' required='${form_WORK_DAYS_R }' readOnly='${form_WORK_DAYS_RO }' disabled='${form_WORK_DAYS_D }' visible='${form_WORK_DAYS_V }'/>
        		</e:field>
		        <e:label for="WORK_PERSONS" title="${form_WORK_PERSONS_N}"/>
        		<e:field colSpan="3">
        			<e:inputText id='WORK_PERSONS' name="WORK_PERSONS" value="${form.WORK_PERSONS}" label='${form_WORK_PERSONS_N }' width='100%' maxLength='${form_WORK_PERSONS_M }' required='${form_WORK_PERSONS_R }' readOnly='${form_WORK_PERSONS_RO }' disabled='${form_WORK_PERSONS_D }' visible='${form_WORK_PERSONS_V }'/>
        		</e:field>
            </e:row>
    	</e:searchPanel>

    	<e:br/>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
