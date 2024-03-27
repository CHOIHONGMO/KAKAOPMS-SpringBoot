<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};

        function init() {

        	grid = EVF.C('grid');

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == "BUYER_NM") {
                    var param = {
                        rowId : rowId,
                        callBackFunction : "PR_setCustNm"
                    };
                    everPopup.openCommonPopup(param, 'SP0902');
                }

                if(colId == 'PLANT_NM') {

                    if(EVF.isEmpty(grid.getCellValue(rowId, 'BUYER_CD'))) { return alert("${IM02_011_006}"); }

                    var param = {
                        rowId : rowId,
                        callBackFunction: "setGridPlantCd",
                        custCd: grid.getCellValue(rowId, 'BUYER_CD')
                    };
                    everPopup.openCommonPopup(param, 'SP0901');
                }

	          	if (colId=='VENDOR_NM') {
					everPopup.openCommonPopup({
						rowId : rowId,
	        	        callBackFunction: "selectVendor"
	        	    }, 'SP0063');
	        	}

            	if(colId == "ITEM_DESC") {
					everPopup.openCommonPopup({
						rowId : rowId,
        	            callBackFunction: "selectItem"
        	        }, 'SP0092');
				}
            	if(colId == "CHANGE_REASON") {
            		var param = {
          				 title : "${IM02_011_005}"
          				,message : grid.getCellValue(rowId, "CHANGE_REASON")
          				,callbackFunction : 'setReason'
          				,detailView : false
          				,rowId : rowId
          			};
            		var url = '/common/popup/common_text_input/view';
    				everPopup.openModalPopup(url, 500, 330, param);
				}
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
            	if(colId == "AFTER_TIER_RATE") {

            	}
	    	});

            grid.addRowEvent(function() {
				var addParam = [{}];
            	grid.addRow(addParam);
			});

			grid.delRowEvent(function() {
				if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
				grid.delRow();
			});

            /* grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            }); */

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);

                    var store = new EVF.Store();
					store.setGrid([grid]);
					/* $.each(grid.getAllRowValue(),function(index, item){
						grid.setCellValue(index, 'PR_BUYER_CD', EVF.V('PR_BUYER_CD'), true);
						grid.setCellValue(index, 'PR_PLANT_CD', EVF.V('PR_PLANT_CD'), true);
					}); */
					store.getGridData(grid, 'all')
					store.load(baseUrl + '/doSetExcelImportItemUinfo', function () {

					});
                }
            });

            if(!EVF.isEmpty("${param.APP_DOC_NUM}")) {
            	grid.hideCol('CHK_TEXT', true);
            	doSearch2();
            }
        }

        function doSearch2() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'im02011_doSearch', function() {
            	grid.checkAll(true);
            });
        }

        // 결재상신 : 유효서 체크 선행
        function doSave() {
        	if (grid.getSelRowCount() == 0) { return alert("${IM02_011_001}"); }
        	if (!grid.validate().flag) { return alert(grid.validate().msg); }

        	var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');

        	grid.checkAll(true);
        	var rowIds = grid.getSelRowId();
	    	for(var i in rowIds) {
	    		var buyerCd  = grid.getCellValue(rowIds[i], 'BUYER_CD');
	    		var plantCd  = grid.getCellValue(rowIds[i], 'PLANT_CD');
	    		var vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
	    		var itemCd   = grid.getCellValue(rowIds[i], 'ITEM_CD');
				var tempStr  = buyerCd+plantCd+vendorCd+itemCd;

	        	var rowIdsk = grid.getSelRowId();
	        	var chkCou = 0;
		    	for(var k in rowIds) {
		    		var buyerCdK = grid.getCellValue(rowIds[k], 'BUYER_CD');
		    		var plantCdK = grid.getCellValue(rowIds[k], 'PLANT_CD');
		    		var vendorCdK = grid.getCellValue(rowIds[k], 'VENDOR_CD');
		    		var itemCdK = grid.getCellValue(rowIds[k], 'ITEM_CD');
					var tempStrK = buyerCdK+plantCdK+vendorCdK+itemCdK;

					if(tempStr == tempStrK) {
						chkCou++;
					}
		    	}
				if(chkCou > 1) {
					return alert("${IM02_011_010}");
				}
	    	}

            store.load(baseUrl + 'IM02_011/doSearch', function() {
            	grid.checkAll(true);
            	var rowIds = grid.getSelRowId();
    	    	for(var i in rowIds) {
    	    		if(grid.getCellValue(rowIds[i], 'NEW_SALES_UNIT_PRICE') == 0 || grid.getCellValue(rowIds[i], 'CONT_UNIT_PRICE') == 0) {
    	    			return alert("${IM02_011_003}");
    	    		}
                    if (grid.getCellValue(rowIds[i], 'CHK_TEXT') != 'O') {
    	    			return alert("${IM02_011_009}");
                    }
        		}

                EVF.V("YINFO_SIGN_STATUS", "P");
                var param = {
                    subject: "매입,매출단가(업로드)",
                    docType: "INFOCHUP",
                    signStatus: "P",
                    screenId: "IM02_011",
                    approvalType: 'APPROVAL',
                    attFileNum: "",
                    docNum: '',
                    callBackFunction: "goApproval"
                };
                everPopup.openApprovalRequestIIPopup(param);
            });
        }

        function goApproval(formData, gridData, attachData) {

            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            EVF.V("YINFO_SIGN_STATUS", "P");

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("signStatus", 'P');

            if(store.doFileUpload(function() {
                store.setParameter('mainImgSq', $('#mainImgContainer').find('input[type=radio]:checked').prop('id'));
    			store.load(baseUrl + 'im02011_doSave', function(){
                    alert(this.getResponseMessage());
                    window.close();
                });
            }));
        }


        function setItemInfo(jsonData, rowId) {
            var setRow = rowId;

        	for(idx in jsonData) {


        	    if(idx >0){
                    var addParam = [{"BUYER_CD" : grid.getCellValue(rowId, "BUYER_CD")}];
                    setRow = grid.addRow(addParam);
                }
                //grid.setCellValue(rowId, 'TIER_CD', jsonData[idx].TIER_CD);
	        	grid.setCellValue(setRow, 'ITEM_CD', jsonData[idx].ITEM_CD);
	        	grid.setCellValue(setRow, 'ITEM_DESC', jsonData[idx].ITEM_DESC);
	        	grid.setCellValue(setRow, 'ITEM_SPEC', jsonData[idx].ITEM_SPEC);
	        	grid.setCellValue(setRow, 'MAKER_NM', jsonData[idx].MAKER_NM);
	        	grid.setCellValue(setRow, 'MODEL_NM', jsonData[idx].MAKER_PART_NO);
	        	grid.setCellValue(setRow, 'ITEM_CLS1', jsonData[idx].ITEM_CLS1);
	        	grid.setCellValue(setRow, 'ITEM_CLS2', jsonData[idx].ITEM_CLS2);
	        	grid.setCellValue(setRow, 'ITEM_CLS3', jsonData[idx].ITEM_CLS3);
	        	grid.setCellValue(setRow, 'ITEM_CLS4', jsonData[idx].ITEM_CLS4);

                doGetPrice(setRow);
	        }
        }

        function doGetPrice(nRow) {

            if(EVF.isEmpty(grid.getCellValue(nRow, 'BUYER_CD')) || EVF.isEmpty(grid.getCellValue(nRow, 'ITEM_CD'))) return;

            var store = new EVF.Store();
            store.setParameter("BUYER_CD", grid.getCellValue(nRow, 'BUYER_CD'));
            store.setParameter("ITEM_CD", grid.getCellValue(nRow, 'ITEM_CD'));
            store.load(baseUrl + 'im02011_doGetPrice', function() {
            	grid.setCellValue(nRow, "CONT_UNIT_PRICE", this.getParameter("CONT_UNIT_PRICE"));
                //grid.setCellValue(nRow, "UNIT_PRICE", this.getParameter("UNIT_PRICE"));
                grid.setCellValue(nRow, "CUR", this.getParameter("CUR"));
                //grid.setCellValue(nRow, "TIER_CD", this.getParameter("TIER_CD"));
            }, false);
        }

        function setReason(data){
        	grid.setCellValue(data.rowId, 'CHANGE_REASON', data.message);
        }

        function doClose() {
			window.close();
        }

        function PR_setCustNm(data){
            grid.setCellValue(data.rowId, "BUYER_CD", data.CUST_CD);
            grid.setCellValue(data.rowId, "BUYER_NM", data.CUST_NM);
            grid.setCellValue(data.rowId, "DEPT_PRICE_FLAG", data.DEPT_PRICE_FLAG);
        }

        function setGridPlantCd(data) {
            var parseData = [];
            parseData.push(data);
            var grdhStr = "";
            for (var i = 0; i < grid.getRowCount(); i++) {
                for (var j in parseData) {
                    if (grid.getCellValue(i, 'BUYER_CD') == grid.getCellValue(parseData[j].rowId, 'BUYER_CD')) {
                        if(grid.getCellValue(i, 'PLANT_CD') == parseData[j].PLANT_CD) {
                            grdhStr += "사업장" + " : " + parseData[j].PLANT_NM + "\n";
                            // 동일 데이터 삭제
                            parseData.splice(j, 1);
                        }
                    }
                }
            }
            if(grdhStr != "") alert("동일한 데이터가 존재합니다.\n" + grdhStr.substring(0, grdhStr.length -1));
            for(var i in parseData) {
                grid.setCellValue(parseData[i].rowId, "PLANT_CD", parseData[i].PLANT_CD);
                grid.setCellValue(parseData[i].rowId, "PLANT_NM", parseData[i].PLANT_NM);
            }
        }

        function selectVendor(data) {
            grid.setCellValue(data.rowId,'VENDOR_CD', data['VENDOR_CD'] );
            grid.setCellValue(data.rowId,'VENDOR_NM', data['VENDOR_NM'] );
        }


        function selectItem(data) {
            grid.setCellValue(data.rowId,'ITEM_CD', data['ITEM_CD'] );
            grid.setCellValue(data.rowId,'ITEM_DESC', data['ITEM_DESC'] );
        }

        function doSearch() {
        	grid.checkAll(true);
        	var store = new EVF.Store();
            if(!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            store.setGrid([grid]);
            store.getGridData(grid, 'all');

            store.load(baseUrl + 'IM02_011/doSearch', function() {
            	grid.checkAll(true);
            });
        }

        function doDownloadExcel(){
			var attFileNum = '${TEMP_ATT_FILE_NUM}';
            if (attFileNum != '') {
                var param = {
                    havePermission: false,
                    attFileNum: attFileNum,
                    bizType: "BI",
                    fileExtension: '*'
                };
                everPopup.openPopupByScreenId('commonFileAttach', 650, 340, param);
            }
		}

    </script>

    <e:window id="IM02_011" onReady="init" initData="${initData}" title="${param.TITLE }" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<div style="float: left; display: inline-block; margin-bottom: 2px;">
				<e:button id="doDownloadExcel" name="doDownloadExcel" label="${doDownloadExcel_N}" onClick="doDownloadExcel" disabled="${doDownloadExcel_D}" visible="${doDownloadExcel_V}"/>
			</div>
			<e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
            <e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" />
        </e:buttonBar>

        <e:inputHidden id="approvalFormData" name="approvalFormData" />
        <e:inputHidden id="approvalGridData" name="approvalGridData" />
        <e:inputHidden id="attachFileDatas" name="attachFileDatas" />
        <e:inputHidden id="YINFO_SIGN_STATUS" name="YINFO_SIGN_STATUS" />

        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.APP_DOC_NUM}"/>
        <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${param.APP_DOC_CNT}" />

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>