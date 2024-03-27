<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-10-19
  Scrren ID : DH0680 - 업무진행관리(일반구매)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid, gridSub;
    var baseUrl = "/eversrm/purchase/prMgt/prRequestReg/DH0680";
    var selRow1, selRow2;
    var prNumFlag = false;

    function init() {

      grid = EVF.getComponent('grid');
      gridSub = EVF.getComponent('gridSub');
      grid.setProperty("shrinkToFit", false);
      gridSub.setProperty("shrinkToFit", false);


      grid.setProperty('panelVisible', ${panelVisible});
      gridSub.setProperty('panelVisible', ${panelVisible});



      //grid Column Head Merge
      grid.setProperty('multiselect', true);
      gridSub.setProperty('multiselect', true);

      // Grid AddRow Event
      grid.addRowEvent(function() {
        addParam = [{
        	'CTRL_USER_ID' : '${ses.userId}',
        	'CTRL_USER_NM' : '${ses.userNm}'
		}];
        grid.addRow(addParam);
      });

      gridSub.addRowEvent(function() {
        // 품목선택, + 버튼 Validation
        if(prNumValidation()) {
          var subRowIdx = 0;

          for(var i = 0; i < gridSub.getRowCount(); i++) {
            if(gridSub.getCellValue(i, "INSERT_FLAG") != "I") {
              subRowIdx = gridSub.getRowId(i);
            }
          }

          if(gridSub.getRowCount() == 0) {
            addParam = [{
              'PR_NUM': grid.getCellValue(selRow1, "PR_NUM"),
              'PLANT_CD': '${ses.plantCd}',
              'CTRL_USER_NM': '${ses.userNm}',
              'CTRL_USER_ID': '${ses.userId}',
              'INSERT_FLAG': 'I'
            }];
          } else {
            addParam = [{
              'PR_NUM': grid.getCellValue(selRow1, "PR_NUM"),
              'PLANT_CD': gridSub.getCellValue(subRowIdx, "PLANT_CD"),
              'DUE_DATE': gridSub.getCellValue(subRowIdx, "DUE_DATE"),
              'ABLE_DELY_DATE_TEXT': gridSub.getCellValue(subRowIdx, "ABLE_DELY_DATE_TEXT"),
              'RECEIPT_DATE': gridSub.getCellValue(subRowIdx, "RECEIPT_DATE"),
              'CN_DATE': gridSub.getCellValue(subRowIdx, "CN_DATE"),
              'CTRL_USER_NM': '${ses.userNm}',
              'CTRL_USER_ID': '${ses.userId}',
              'INSERT_FLAG': 'I'
            }];
          }

          gridSub.addRow(addParam);

          validColRequired(false);
        }
      });

      gridSub.delRowEvent(function() {
        var rowData = gridSub.getSelRowId();
        //var LINE_THROUGH = 'line-through';
        for ( var nRow in rowData ) {
          gridSub.setCellValue(rowData[nRow],'INSERT_FLAG','D');
          //gridSub.setRowStyle(nRow, "text-decoration", LINE_THROUGH);
          gridSub.setRowBgColor(rowData[nRow], '#8C8C8C');
        }
      });

      // Grid Excel Event
      grid.excelExportEvent({
        allCol : "${excelExport.allCol}",
        selRow : "${excelExport.selRow}",
        fileType : "${excelExport.fileType }",
        fileName : "${screenName }",
        excelOptions : {
          imgWidth      : 0.12, 		// 이미지 너비
          imgHeight     : 0.26,		    // 이미지 높이
          colWidth      : 20,        	// 컬럼의 넓이
          rowSize       : 500,       	// 엑셀 행에 높이 사이즈
          attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
        }
      });

      // Grid Excel Event
      gridSub.excelExportEvent({
        allCol : "${excelExport.allCol}",
        selRow : "${excelExport.selRow}",
        fileType : "${excelExport.fileType }",
        fileName : "${screenName }",
        excelOptions : {
          imgWidth      : 0.12, 		// 이미지 너비
          imgHeight     : 0.26,		    // 이미지 높이
          colWidth      : 20,        	// 컬럼의 넓이
          rowSize       : 500,       	// 엑셀 행에 높이 사이즈
          attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
        }
      });

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
        selRow1 = rowid;

        switch(celname) {
          case 'PR_NUM':
				if (grid.getCellValue(rowid, "PR_NUM") != '') {
	                doSearchSubGrid();
				}
                break;
          case 'CTRL_USER_NM':
        	  var param = {
					'callBackFunction': 'selectUser'
                };
                everPopup.openCommonPopup(param, "SP0040");
                break;
          case 'RFX_NUM':
        	  if (value == '') {
        		  return;
        	  }
              var param = {
                  'detailView': true,
                  'rfxNum': value,
                  'rfxCnt': grid.getCellValue(rowid, "RFX_CNT")
              };
              everPopup.openPopupByScreenId("BSOX_010", 1300, 1000, param);
              break;

          case 'URL_IMAGE':
            var val = grid.getCellValue(rowid, 'GW_EXEC_URL');

            if (val != '' && val != null && val.length > 200) {
              var param = {
                'GW_EXEC_TEXT': grid.getCellValue(rowid, 'GW_EXEC_TEXT')
              };

              everPopup.openWindowPopup(val, 950, 820, param, 'gwPop');
            }

            break;
        }
      });

      gridSub.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
        selRow2 = rowid;

        switch(celname) {
          case 'CTRL_USER_NM':
        	var progressCode = gridSub.getCellValue(rowid, "PROGRESS_CD");
          	if (progressCode != '' && parseInt(progressCode) > 1100) {
          		return alert("${DH0680_0004}");
          	}

		    var param = {
              'callBackFunction': 'selectUserSub'
            };
            everPopup.openCommonPopup(param, 'SP0040');
            break;
          case 'PLANT_CD':
          	var progressCode = gridSub.getCellValue(rowid, "PROGRESS_CD");
      		if (progressCode != '' && parseInt(progressCode) > 1100) {
      			return alert("${DH0680_0004}");
      		}
			break;
          case 'RFX_NUM':
        	  if (gridSub.getCellValue(rowid, "RFX_NUM") == '') {
        		  return;
        	  }
              var param = {
                  gateCd: gridSub.getCellValue(rowid, "GATE_CD"),
                  rfxNum: gridSub.getCellValue(rowid, "RFX_NUM"),
                  rfxCnt: gridSub.getCellValue(rowid, "RFX_CNT"),
                  rfxType: gridSub.getCellValue(rowid, "RFX_TYPE"),
                  popupFlag: true,
                  detailView: true
              };
              everPopup.openRfxDetailInformation(param);
              break;
          case 'QTA_NUM':
        	  if (gridSub.getCellValue(rowid, "QTA_NUM") == '') {
        		  return;
        	  }
  	          var param = {
		            gateCd: grid.getCellValue(rowid,'${ses.gateCd}'),
		            rfxNum: grid.getCellValue(rowid,'RFX_NUM'),
		            qtaNum : grid.getCellValue(rowid,'QTA_NUM'),
		            rfxCnt: grid.getCellValue(rowid,'RFX_CNT'),
		            popupFlag: true,
		            detailView: true,
		            "isPrefferedBidder": false,
		            "buttonStatus" : 'Y',
		            vendorCd: grid.getCellValue(rowid,'VENDOR_CD')
		      };
		      everPopup.openPopupByScreenId('DH2140', 1000, 800, param);
  			  break;
          case 'VENDOR_NM':
        	  if (gridSub.getCellValue(rowid, "VENDOR_NM") == '') {
        		  return;
        	  }
	          var params = {
		      	VENDOR_CD: gridSub.getCellValue(rowId, "VENDOR_CD"),
		        paramPopupFlag: "Y",
		        detailView : true
		      };
		      everPopup.openSupManagementPopup(params);
  			  break;

          case 'LAST_VENDOR_CD':
            var param = {
              'callBackFunction': 'selectVendor'
            };
            everPopup.openCommonPopup(param, "SP0025");

            break;
        }
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {

      });

      gridSub.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
        if(celname == 'PR_QT' || celname == 'LAST_UNIT_PRC') {
          var cur = gridSub.getCellValue(rowid, 'LAST_PO_CUR');
          var price = everCurrency.getPrice(cur, gridSub.getCellValue(rowid, 'LAST_UNIT_PRC'));
          var qty = everCurrency.getQty(cur, gridSub.getCellValue(rowid, 'PR_QT'));

          gridSub.setCellValue(rowid, 'LAST_ITEM_AMT', everCurrency.getAmount(cur, price * qty));
        }
      });

      EVF.getComponent('PR_TYPE').removeOption('NORMAL');
      //EVF.getComponent('PR_TYPE').removeOption('AS');
      //EVF.getComponent('PR_TYPE').removeOption('NEW');
      EVF.getComponent('PR_TYPE').removeOption('SMT');
      EVF.getComponent('PR_TYPE').removeOption('DMRO');
      EVF.getComponent('PR_TYPE').removeOption('OMRO');

      doSearch();
    }

    function selectUser(data) {
      grid.setCellValue(selRow1, "CTRL_USER_NM", data.CTRL_USER_NM);
      grid.setCellValue(selRow1, "CTRL_USER_ID", data.CTRL_USER_ID);
    }

    function selectUserSub(data) {
      gridSub.setCellValue(selRow2, "CTRL_USER_NM", data.CTRL_USER_NM);
      gridSub.setCellValue(selRow2, "CTRL_USER_ID", data.CTRL_USER_ID);
    }

    function selectVendor(data) {
      gridSub.setCellValue(selRow2, "LAST_VENDOR_CD", data.VENDOR_CD);
      gridSub.setCellValue(selRow2, "LAST_VENDOR_NM", data.VENDOR_NM);
    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
    	  gridSub.delAllRow();
    	  prNumFlag = false;
          $('#subGridPanel .e-panel-titlebar-td').text("${DH0680_gridSubTitle}");
          //store.setGrid([gridSub]);
          //store.load(baseUrl+'/doSearchGridSub', function() {});

          if(grid.getRowCount() == 0) {
            return alert('${msg.M0002}');
          }
      });
    }

    function doSearchSubGrid() {
      var store = new EVF.Store();
      var value = grid.getCellValue(selRow1, "PR_NUM");
      store.setGrid([gridSub]);
      store.setParameter("PR_NUM", value);
      store.load(baseUrl+'/doSearchGridSub', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
        prNumFlag = true;
      });

      $('#subGridPanel .e-panel-titlebar-td').text("[" + value + "]" + " ${DH0680_gridSubTitle}");
    }

    // 저장
    function doSave() {
      	var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

      	if(selRowIds.length == 0) {
        	return alert("${msg.M0004}");
      	}

      	// Grid Validation Check
      	if(!grid.validate().flag) {
        	return alert("${msg.M0014}");
      	}

    	<%--
      	// 수정 및 삭제는 업무지시자만 가능함
	    var allRowIds = grid.getSelRowId();
	    for (var i in allRowIds) {
	        var rowData = grid.getRowValue(allRowIds[i]);

	        if (rowData['CTRL_USER_ID'] != '' && '${ses.userId}' != rowData['CTRL_USER_ID']) {
	        	alert("${msg.M0008}");
	            return;
	        }
	    }
	    --%>

      	if (!confirm("${msg.M0021}")) return;

      	var store = new EVF.Store();
      	store.setGrid([grid]);
      	store.getGridData(grid, 'sel');
      	store.load(baseUrl + '/doSave', function() {
        	alert(this.getResponseMessage());
        	doSearch();
      	});
    }

    // 삭제
    function doDelete() {
      	if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
        	alert("${msg.M0004}");
        	return;
      	}

      	<%--
    	// 수정 및 삭제는 업무지시자만 가능함
	    var allRowIds = grid.getSelRowId();
	    for (var i in allRowIds) {
	        var rowData = grid.getRowValue(allRowIds[i]);

	        if (rowData['CTRL_USER_ID'] != '' && '${ses.userId}' != rowData['CTRL_USER_ID']) {
	        	alert("${msg.M0008}");
	            return;
	        }

	        if (rowData['ITEM_CNT'] != '' && parseInt(rowData['ITEM_CNT']) > 0) {
	        	alert("${DH0680_0005}");
	            return;
	        }
	    }
	    --%>

      	if (!confirm("${msg.M0013 }")) return;

      	var store = new EVF.Store();
      	store.setGrid([grid]);
      	store.getGridData(grid, 'sel');
      	store.load(baseUrl + '/doDelete', function(){
        	alert(this.getResponseMessage());
        	doSearch();
      	});
    }

    function doCtrlUser() {
      var param = {
        callBackFunction: 'selectUserAss'
      };

      everPopup.openCommonPopup(param, 'SP0040');
    }

    // grid 사용자명 팝업 리턴 셋팅
    function selectUserAss(data) {
      //grid.setCellValue(selRow, "USER_ID", data.CTRL_USER_ID);
      EVF.getComponent('CTRL_USER_NM').setValue(data.CTRL_USER_NM);
    }

    function doCatalog() {
      if(prNumValidation()) {
        var param = {
          'callBackFunction': 'itemPopupCallback',
          'popupFlag': true,
          'detailView': false,
          'openerScreen': 'DH0680'
        };

        everPopup.openItemCatalogPopup(param);
      }
    }

    function itemPopupCallback(data) {
      data = JSON.parse(data);

      var arrData = [];
      var subRowIdx = 0;

      for(var i = 0; i < gridSub.getRowCount(); i++) {
        if(gridSub.getCellValue(i, "INSERT_FLAG") != "I")
          subRowIdx = gridSub.getRowId(i);
      }

      for(idx in data) {
        if(gridSub.getRowCount() == 0) {
          arrData.push({
            'PLANT_CD': '${ses.plantCd}',
            'ITEM_CD': data[idx].ITEM_CD,
            'ITEM_DESC': data[idx].ITEM_DESC,
            'PR_NUM': grid.getCellValue(selRow1, "PR_NUM"),
            'ADD_FLAG': 'Y',
            'CTRL_USER_NM': '${ses.userNm}',
            'CTRL_USER_ID': '${ses.userId}',
            'INSERT_FLAG': 'I'
          });
        } else {
          arrData.push({
            'PLANT_CD': gridSub.getCellValue(subRowIdx-1, "PLANT_CD"),
            'ITEM_CD': data[idx].ITEM_CD,
            'ITEM_DESC': data[idx].ITEM_DESC,
            'PR_NUM': grid.getCellValue(selRow1, "PR_NUM"),
            'ADD_FLAG': 'Y',
            'DUE_DATE': gridSub.getCellValue(subRowIdx, "DUE_DATE"),
            'ABLE_DELY_DATE_TEXT': gridSub.getCellValue(subRowIdx, "ABLE_DELY_DATE_TEXT"),
            'RECEIPT_DATE': gridSub.getCellValue(subRowIdx, "RECEIPT_DATE"),
            'CN_DATE': gridSub.getCellValue(subRowIdx, "CN_DATE"),
            'CTRL_USER_NM': '${ses.userNm}',
            'CTRL_USER_ID': '${ses.userId}',
            'INSERT_FLAG': 'I'
          });
        }

      }

      gridSub.addRow(arrData);

      // 품명 수정 불가
      var selRowId = gridSub.getSelRowId();
      for (idx in selRowId) {
        var rowId = selRowId[idx];

        // 품목선택 시 품명 수정 불가
        if(gridSub.getCellValue(rowId, 'ADD_FLAG') == "Y") {
          gridSub.setCellReadOnly(rowId, 'ITEM_DESC', true);
        }
      }
    }

    function doSaveSub() {
      	var store = new EVF.Store();
      	var selRowIds = gridSub.jsonToArray(gridSub.getSelRowId()).value;

      	if(selRowIds.length == 0) {
        	return alert("${msg.M0004}");
      	}

        validColRequired(false);

      	// Grid Validation Check
      	if(!gridSub.validate().flag) {
        	return alert("${msg.M0014}");
      	}

    	// 수정 및 삭제는 업무지시자만 가능함
	    var selRowIds = gridSub.getSelRowId();
	    for (var i in selRowIds) {
	        //if (rowData['HD_CTRL_USER_ID'] != '' && '${ses.userId}' != rowData['HD_CTRL_USER_ID']) {
            //    alert("${msg.M0008}");
	        //    return;
	        //}
          if(gridSub.getCellValue(selRowIds[i], 'INSERT_FLAG') == "D") {
            if(gridSub.getCellValue(selRowIds[i], 'PROGRESS_CD') != '' && gridSub.getCellValue(selRowIds[i], 'PROGRESS_CD') > '1100') {
              alert("${DH0680_0003}");
              return;
            }
          }
	    }

    	store.setGrid([gridSub]);
      	store.getGridData(gridSub, 'sel');
      	if (!confirm("${msg.M0021}")) return;
      	store.load(baseUrl + '/doSaveSub', function() {
        	alert(this.getResponseMessage());

        	doSearchSubGrid();
      	});
    }
/*
    // 삭제
    function doDeleteSub() {
      	if ((gridSub.jsonToArray(gridSub.getSelRowId()).value).length == 0) {
        	alert("${msg.M0004}");
        	return;
      	}

    	// 수정 및 삭제는 업무지시자만 가능함
	    var allRowIds = gridSub.getSelRowId();
	    for (var i in allRowIds) {
	        var rowData = gridSub.getRowValue(allRowIds[i]);

	        //if (rowData['HD_CTRL_USER_ID'] != '' && '${ses.userId}' != rowData['HD_CTRL_USER_ID']) {
	        //	alert("${msg.M0008}");
	        //    return;
	        //}

	        if (rowData['PROGRESS_CD'] != '' && parseInt(rowData['PROGRESS_CD']) > 1100) {
	      		alert("${DH0680_0003}");
	      		return;
	        }
	    }

      	if (!confirm("${msg.M0013 }")) return;

      	var store = new EVF.Store();
      	store.setGrid([gridSub]);
      	store.getGridData(gridSub, 'sel');
      	store.load(baseUrl + '/doDeleteSub', function(){
        	alert(this.getResponseMessage());

        	doSearch();
        	doSearchSubGrid();
      	});
    }
*/
    function prNumValidation() {
      if(!prNumFlag) {
        alert("${DH0680_0001}"); //문서번호를 선택하여 주시기 바랍니다.
        formUtil.animate("grid_table_PR_NUM", "grid");
        //doSearch();
        return false;
      } else {
        return true;
      }
    }

    function doEstimateBidding() {

      	var selRowIds = gridSub.jsonToArray(gridSub.getSelRowId()).value;

      	if(selRowIds.length == 0) {
        	return alert("${msg.M0004}");
      	}

        validColRequired(false);

      	for (var i in selRowIds) {
        	if (selRowIds.hasOwnProperty(i)) {
          		var gridData = gridSub.getRowValue(selRowIds[i]);

          		if ('${ses.userId}' != gridData.CTRL_USER_ID) {
            		return alert("${msg.M0008}");
          		}
        	}
      	}

      	var selectedRow = gridSub.getSelRowValue()[0];
      	var progressCode = selectedRow['PROGRESS_CD'];
      	if (progressCode == '') {
      		return alert("${msg.M0044}");
      	} else {
          	if (parseInt(progressCode) == 2300) {
          		return alert("${DH0680_0002}");
          	} else if (parseInt(progressCode) > 2300) {
      			return alert("${msg.M0044}");
      		}
      	}

      	var params = {
        	'prList': JSON.stringify(gridSub.getSelRowValue()),
        	'rfxType': 'RFQ',
        	'baseDataType': 'PR',
        	'callBackFunction': 'doSearchSubGrid',
        	'detailView': false,
        	'screenFlag': '1',
        	'purcharseType': gridSub.getCellValue(selRowIds[0], 'PR_TYPE'),
        	'popupFlag' : 'true',
        	'ctrlUserId': gridSub.getCellValue(selRowIds[0], 'CTRL_USER_ID')
      	};

      	everPopup.openPopupByScreenId("BSOX_010", 1300, 1000, params);
    }

    function doWait() {

      	var selRowIds = gridSub.jsonToArray(gridSub.getSelRowId()).value;
      	if(selRowIds.length == 0) {
        	return alert("${msg.M0004}");
      	}

      	// 요청품의업체, 통화, 요청품의수량, 요충품의단가, 단위, 요청품의금액
      	validColRequired(true);

      	// Grid Validation Check
	      if(!gridSub.validate(['ITEM_DESC','LAST_VENDOR_CD','UNIT_CD','PR_QT','LAST_PO_CUR','LAST_UNIT_PRC','LAST_ITEM_AMT']).flag) {
	          return alert("${msg.M0014}");
	      }

    	for (var i in selRowIds) {
        	if (selRowIds.hasOwnProperty(i)) {
          		var gridData = gridSub.getRowValue(selRowIds[i]);

          		if ('${ses.userId}' != gridData.CTRL_USER_ID) {
            		return alert("${msg.M0008}");
          		}

              	var progressCode = gridData.PROGRESS_CD;
              	if (progressCode == '') {
              		return alert("${msg.M0044}");
              	} else {
                  	if (parseInt(progressCode) >= 2300) {
              			return alert("${msg.M0044}");
              		}
              	}
        	}
      	}

//      	var selectedRow = gridSub.getSelRowValue()[0];
//      	var progressCode = selectedRow['PROGRESS_CD'];
//      	if (progressCode == '') {
//      		return alert("${msg.M0044}");
//      	} else {
//          	if (parseInt(progressCode) >= 2300) {
//      			return alert("${msg.M0044}");
//      		}
//      	}

      	var store = new EVF.Store();
      	store.setGrid([gridSub]);
      	store.getGridData(gridSub, 'sel');
      	if (!confirm("${DH0680_0009}")) return;
      	store.load(baseUrl + '/doWait', function() {
        	alert(this.getResponseMessage());

        	doSearchSubGrid();
      	});
    }

    function doContractWait() {

      var selRowIds = gridSub.jsonToArray(gridSub.getSelRowId()).value;
      if(selRowIds.length == 0) {
        return alert("${msg.M0004}");
      }

      // 요청품의업체, 통화, 요청품의수량, 요충품의단가, 단위, 요청품의금액
      validColRequired(true);

      // Grid Validation Check

      if(!gridSub.validate(['ITEM_DESC','LAST_VENDOR_CD','UNIT_CD','PR_QT','LAST_PO_CUR','LAST_UNIT_PRC','LAST_ITEM_AMT']).flag) {
          return alert("${msg.M0014}");
      }



      for (var i in selRowIds) {
        if (selRowIds.hasOwnProperty(i)) {
          var gridData = gridSub.getRowValue(selRowIds[i]);

          if ('${ses.userId}' != gridData.CTRL_USER_ID) {
            return alert("${msg.M0008}");
          }

        	var progressCode = gridData.PROGRESS_CD;
          	if (progressCode == '') {
          		return alert("${msg.M0044}");
          	} else {
              	if (parseInt(progressCode) >= 2300) {
          			//return alert("${msg.M0044}");
          		}
          	}


        }
      }


      var store = new EVF.Store();
      store.setGrid([gridSub]);
      store.getGridData(gridSub, 'sel');
      if (!confirm("${DH0680_0011}")) return;
      store.load(baseUrl + '/doContractWait', function() {
        alert(this.getResponseMessage());

        doSearchSubGrid();
      });
    }

    function doOrderWait() {

      var selRowIds = gridSub.jsonToArray(gridSub.getSelRowId()).value;
      if(selRowIds.length == 0) {
        return alert("${msg.M0004}");
      }

      // 요청품의업체, 통화, 요청품의수량, 요충품의단가, 단위, 요청품의금액
      validColRequired(true);

      // Grid Validation Check
      if(!gridSub.validate(['ITEM_DESC','LAST_VENDOR_CD','UNIT_CD','PR_QT','LAST_PO_CUR','LAST_UNIT_PRC','LAST_ITEM_AMT']).flag) {
          return alert("${msg.M0014}");
      }

      for (var i in selRowIds) {
        if (selRowIds.hasOwnProperty(i)) {
          var gridData = gridSub.getRowValue(selRowIds[i]);

          if ('${ses.userId}' != gridData.CTRL_USER_ID) {
            return alert("${msg.M0008}");
          }

        	var progressCode = gridData.PROGRESS_CD;
          	if (progressCode == '') {
          		return alert("${msg.M0044}");
          	} else {
              	if (parseInt(progressCode) >= 2300) {
          			//return alert("${msg.M0044}");
          		}
          	}

        }
      }


      var store = new EVF.Store();
      store.setGrid([gridSub]);
      store.getGridData(gridSub, 'sel');
      if (!confirm("${DH0680_0012}")) return;
      store.load(baseUrl + '/doOrderWait', function() {
        alert(this.getResponseMessage());

        doSearchSubGrid();
      });
    }

    function validColRequired(flag) {
      gridSub.setColRequired("ITEM_DESC", flag);
      gridSub.setColRequired("LAST_VENDOR_CD", flag);
      gridSub.setColRequired("UNIT_CD", flag);
      gridSub.setColRequired("PR_QT", flag);
      gridSub.setColRequired("LAST_PO_CUR", flag);
      gridSub.setColRequired("LAST_UNIT_PRC", flag);
      gridSub.setColRequired("LAST_ITEM_AMT", flag);
    }
  </script>

  <e:window id="DH0680" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <%--양산기간--%>
        <e:label for="MANU_DATE_FROM" title="${form_MANU_DATE_FROM_N}"/>
        <e:field>
          <e:inputDate id="MANU_DATE_FROM" toDate="MANU_DATE_TO" name="MANU_DATE_FROM" value="${manuDateFrom}" width="80" datePicker="true" required="${form_MANU_DATE_FROM_R}" disabled="${form_MANU_DATE_FROM_D}" readOnly="${form_MANU_DATE_FROM_RO}" />
          <e:text> ~ </e:text>
          <e:inputDate id="MANU_DATE_TO" fromDate="MANU_DATE_FROM" name="MANU_DATE_TO" value="${manuDateTo}" width="80" datePicker="true" required="${form_MANU_DATE_TO_R}" disabled="${form_MANU_DATE_TO_D}" readOnly="${form_MANU_DATE_TO_RO}" />
        </e:field>
        <%--입고처--%>
        <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
        <e:field>
          <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
        </e:field>
        <%--문서명--%>
        <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
        <e:field>
          <e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--요청부서--%>
        <e:label for="REQ_DEPT_NM" title="${form_REQ_DEPT_NM_N}"/>
        <e:field>
          <e:inputText id="REQ_DEPT_NM" style="${imeMode}" name="REQ_DEPT_NM" value="${form.REQ_DEPT_NM}" width="100%" maxLength="${form_REQ_DEPT_NM_M}" disabled="${form_REQ_DEPT_NM_D}" readOnly="${form_REQ_DEPT_NM_RO}" required="${form_REQ_DEPT_NM_R}"/>
        </e:field>
        <%--업무요청번호--%>
        <e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
        <e:field>
          <e:inputText id="PR_NUM" style="ime-mode:inactive" name="PR_NUM" value="${form.PR_NUM}" width="${inputTextWidth}" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}"/>
        </e:field>
        <%--진행자--%>
        <e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}"/>
        <e:field>
          <e:search id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="${form_CTRL_USER_NM_RO ? 'everCommon.blank' : 'doCtrlUser'}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
        </e:field>
      </e:row>
      <e:row>
        <%--품의종류--%>
        <e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
        <e:field >
          <e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prTypeOptions}" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
        </e:field>
        <%--가격결정기준--%>
        <e:label for="PRICE_DECISION_TYPE" title="${form_PRICE_DECISION_TYPE_N}"/>
        <e:field colSpan="3">
          <e:select id="PRICE_DECISION_TYPE" name="PRICE_DECISION_TYPE" value="${form.PRICE_DECISION_TYPE}" options="${priceDecisionTypeOptions}" width="${inputTextWidth}" disabled="${form_PRICE_DECISION_TYPE_D}" readOnly="${form_PRICE_DECISION_TYPE_RO}" required="${form_PRICE_DECISION_TYPE_R}" placeHolder="" />
        </e:field>
      </e:row>
    </e:searchPanel>

    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
      <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
    </e:buttonBar>

    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="250" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	<e:buttonBar width="100%" align="right">
        <e:button id="doCatalog" name="doCatalog" label="${doCatalog_N}" onClick="doCatalog" disabled="${doCatalog_D}" visible="${doCatalog_V}"/>
        <e:button id="doSaveSub" name="doSaveSub" label="${doSaveSub_N}" onClick="doSaveSub" disabled="${doSaveSub_D}" visible="${doSaveSub_V}"/>
        <%--<e:button id="doDeleteSub" name="doDeleteSub" label="${doDeleteSub_N}" onClick="doDeleteSub" disabled="${doDeleteSub_D}" visible="${doDeleteSub_V}"/>--%>
        <e:button id="doEstimateBidding" name="doEstimateBidding" label="${doEstimateBidding_N}" onClick="doEstimateBidding" disabled="${doEstimateBidding_D}" visible="${doEstimateBidding_V}"/>
        <%--품의대기--%>
        <e:button id="doWait" name="doWait" label="${doWait_N}" onClick="doWait" disabled="${doWait_D}" visible="${doWait_V}"/>
        <%--계약대기--%>
        <e:button id="doContractWait" name="doContractWait" label="${doContractWait_N}" onClick="doContractWait" disabled="${doContractWait_D}" visible="${doContractWait_V}"/>
        <%--발주대기--%>
        <e:button id="doOrderWait" name="doOrderWait" label="${doOrderWait_N}" onClick="doOrderWait" disabled="${doOrderWait_D}" visible="${doOrderWait_V}"/>
    </e:buttonBar>

    <e:searchPanel id="subGridPanel" title="${DH0680_gridSubTitle}" labelWidth="100" width="100%" useTitleBar="true">
      <e:gridPanel gridType="${_gridType}" id="gridSub" name="gridSub" width="100%" height="350" readOnly="${param.detailView}" columnDef="${gridInfos.gridSub.gridColData}"/>
    </e:searchPanel>

  </e:window>
</e:ui>