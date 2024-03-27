<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var gridB;
        var gridimg;
        var baseUrl = "/evermp/IM01/IM0101/";
	    var currRow;
        function init() {
        	gridB = EVF.C("gridB");

			<c:if test="${param.APP_DOC_NUM != null}">
	            gridB.hideCol("CHK_TEXT", true);
	            gridB.hideCol("STATUS", true);
	            gridB.hideCol("SEQ", true);
			</c:if>

            gridB.addRowEvent(function() {
				var addParam = [{}];
            	gridB.addRow(addParam);
			});

            /* gridB.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            }); */

            gridB.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    checkAll();

					var store = new EVF.Store();
					store.setGrid([gridB]);
					$.each(gridB.getAllRowValue(), function(index, item){
						gridB.setCellValue(index, 'ITEM_STATUS', '10');	// 상품상태 : 사용중(10)
					});
					store.getGridData(gridB, 'all')
					store.load(baseUrl + '/doSetExcelImportItemItem', function () {

					});
                }
            });

            gridB.cellClickEvent(function(rowId, colId, value) {
                if(colId == 'VENDOR_NM') {
                    var param = {
                    	rowId : rowId,
                        callBackFunction : "gridct_selectVendorCd"
                    };
                    everPopup.openCommonPopup(param, 'SP0063');
                }
                if(colId == 'CUST_NM') {
                    var param = {
                        rowId : rowId,
                        callBackFunction: "PR_setCustNm"
                    };
                    everPopup.openCommonPopup(param, 'SP0902');
                }
                if(colId == 'PLANT_NM') {
                    if(EVF.isEmpty(gridB.getCellValue(rowId, 'CUST_CD'))) { return alert("${IM01_060_013}"); }

                    var param = {
                        rowId : rowId,
                        callBackFunction: "setGridPlantCd",
                        custCd: gridB.getCellValue(rowId, 'CUST_CD')
                    };
                    everPopup.openCommonPopup(param, 'SP0901');
                }
                if(colId == 'MAKER_NM') {
                    var param = {
                            rowId : rowId,
                            callBackFunction: "setGridMakeCd",
                        };
                        everPopup.openCommonPopup(param, 'SP0068');
                }

                if(colId == 'ITEM_CLS_NM') {
                    currRow = rowId;
                    var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                    var param = {
                        callBackFunction : "_setItemClassNmGrid",
                        'detailView': false,
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true,
                        'custCd' : '${ses.companyCd}',  // 고객사코드or회사코드
                        'custNm' : '${ses.companyNm}'  // 고객사코드or회사코드
                    };
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
                }
                if(colId == 'ITEM_CLS_NM_CUST') { // 고객사
                    currRow = rowId;
                    var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                    var param = {
                        callBackFunction : "_setItemClassNmCustGrid",
                        'detailView': false,
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true,
                        'custCd' : '21',  // 고객사코드or회사코드
                        'custNm' : '㈜소노인터내셔널' // 고객사코드or회사코드
                    };
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
                }
            });

            gridB.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

            	if( colId == "ITEM_CLS1"
           			|| colId == "ITEM_CLS2"
       				|| colId == "ITEM_CLS3"
   					|| colId == "ITEM_CLS4"
					|| colId == "ITEM_KIND_CD"
	           	    || colId == "ITEM_DESC"
	           	    || colId == "ITEM_SPEC"
	           	    || colId == "MAKER_CD"
					|| colId == "MAKER_PART_NO"
	           		|| colId == "BRAND_NM"
	           	    || colId == "ORIGIN_CD"
	           	    || colId == "SG_CTRL_USER_ID"
				) {
            		if (gridB.getCellValue(rowId, "ITEM_CD") != '') {
						gridB.setCellValue(rowId, colId, oldValue);
						return alert("${IM01_060_019}");
					}
				}
            	if(colId == "SALES_UNIT_PRICE" || colId == "CONT_UNIT_PRC"  ){
					var contUnitPrc = Number(EVF.isEmpty(gridB.getCellValue(rowId, 'CONT_UNIT_PRC')) ? 0 : gridB.getCellValue(rowId, 'CONT_UNIT_PRC'));
	                var changeSalesUnitPrc = Number(EVF.isEmpty(gridB.getCellValue(rowId, 'SALES_UNIT_PRICE')) ? 0 : gridB.getCellValue(rowId, 'SALES_UNIT_PRICE'));

	                if(changeSalesUnitPrc==0 || changeSalesUnitPrc==0) return;

	                var calSalesRate = ((changeSalesUnitPrc - contUnitPrc) / changeSalesUnitPrc) * 100;
	                var salesRate = everMath.round_float(calSalesRate, 1);
	                gridB.setCellValue(rowId, 'SALES_RATE', salesRate);
	            }
            });

            doSearch();
        }

        function _setItemClassNmCustGrid(data) {
            if(data!=null){
                data = JSON.parse(data);
            	gridB.setCellValue(currRow, "ITEM_CLS1_CUST", data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){gridB.setCellValue(currRow, "ITEM_CLS2_CUST", '');}else{gridB.setCellValue(currRow, "ITEM_CLS2_CUST", data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){gridB.setCellValue(currRow, "ITEM_CLS3_CUST", '');}else{gridB.setCellValue(currRow, "ITEM_CLS3_CUST", data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){gridB.setCellValue(currRow, "ITEM_CLS4_CUST", '');}else{gridB.setCellValue(currRow, "ITEM_CLS4_CUST", data.ITEM_CLS4);}
                gridB.setCellValue(currRow, "ITEM_CLS_NM_CUST", data.ITEM_CLS_PATH_NM);
            } else {
            	gridB.setCellValue(currRow, "ITEM_CLS1_CUST", '');
            	gridB.setCellValue(currRow, "ITEM_CLS2_CUST", '');
            	gridB.setCellValue(currRow, "ITEM_CLS3_CUST", '');
            	gridB.setCellValue(currRow, "ITEM_CLS4_CUST", '');
            	gridB.setCellValue(currRow, "ITEM_CLS_NM_CUST", '');
            }
        }

        function _setItemClassNmGrid(data) {
            if(data!=null){
                data = JSON.parse(data);
            	gridB.setCellValue(currRow, "ITEM_CLS1", data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){gridB.setCellValue(currRow, "ITEM_CLS2", '');}else{gridB.setCellValue(currRow, "ITEM_CLS2", data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){gridB.setCellValue(currRow, "ITEM_CLS3", '');}else{gridB.setCellValue(currRow, "ITEM_CLS3", data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){gridB.setCellValue(currRow, "ITEM_CLS4", '');}else{gridB.setCellValue(currRow, "ITEM_CLS4", data.ITEM_CLS4);}
                gridB.setCellValue(currRow, "ITEM_CLS_NM", data.ITEM_CLS_PATH_NM);
            } else {
            	gridB.setCellValue(currRow, "ITEM_CLS1", '');
            	gridB.setCellValue(currRow, "ITEM_CLS2", '');
            	gridB.setCellValue(currRow, "ITEM_CLS3", '');
            	gridB.setCellValue(currRow, "ITEM_CLS4", '');
            	gridB.setCellValue(currRow, "ITEM_CLS_NM", '');
            }
        }





        function setGridPlantCd(data) {
            var parseData = [];
            parseData.push(data);
            var grdhStr = "";
            for (var i = 0; i < gridB.getRowCount(); i++) {
                for (var j in parseData) {
                    if (gridB.getCellValue(i, 'CUST_CD') == gridB.getCellValue(parseData[j].rowId, 'CUST_CD')) {
                        if(gridB.getCellValue(i, 'PLANT_CD') == parseData[j].PLANT_CD) {
                            grdhStr += "사업장" + " : " + parseData[j].PLANT_NM + "\n";
                            // 동일 데이터 삭제
                            parseData.splice(j, 1);
                        }
                    }
                }
            }
            if(grdhStr != "") alert("동일한 데이터가 존재합니다.\n" + grdhStr.substring(0, grdhStr.length -1));
            for(var i in parseData) {
            	gridB.setCellValue(parseData[i].rowId, "PLANT_CD", parseData[i].PLANT_CD);
            	gridB.setCellValue(parseData[i].rowId, "PLANT_NM", parseData[i].PLANT_NM);
            }
        }

        function gridct_selectVendorCd(dataJsonArray) {
        	gridB.setCellValue(dataJsonArray.rowId, "VENDOR_CD" ,dataJsonArray.VENDOR_CD );
            gridB.setCellValue(dataJsonArray.rowId, "VENDOR_NM" ,dataJsonArray.VENDOR_NM );
        }

        function PR_setCustNm(data){
        	gridB.setCellValue(data.rowId, "CUST_CD", data.CUST_CD);
        	gridB.setCellValue(data.rowId, "CUST_NM", data.CUST_NM);
			gridB.setCellValue(data.rowId, "ITEM_CLS_NM_CUST", "");
			gridB.setCellValue(data.rowId, "ITEM_CLS1_CUST", "");
			gridB.setCellValue(data.rowId, "ITEM_CLS2_CUST", "");
			gridB.setCellValue(data.rowId, "ITEM_CLS3_CUST", "");
			gridB.setCellValue(data.rowId, "ITEM_CLS4_CUST", "");
        }

        function setGridMakeCd(data){
        	gridB.setCellValue(data.rowId, "MAKER_CD", data.MKBR_CD);
        	gridB.setCellValue(data.rowId, "MAKER_NM", data.MKBR_NM);
        }


        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(data) {
            EVF.V('APPLY_COM', data.CUST_CD);
            EVF.V('APPLY_NM', data.CUST_NM);
        }

        function cleanCustCd() {
            EVF.V('APPLY_COM', "");
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function cleanVendorCd() {
            EVF.V('VENDOR_CD', "");
        }


        function chgCustCd() {
            var store = new EVF.Store;
            store.load('/evermp/SY01/SY0101/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
            	}
            });
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
            //chgCustCd();
        }

		function onSearchPlant() {
			if( EVF.V("CUST_CD") == "" ) return alert("${IM01_060_018}");
			var param = {
				callBackFunction : "callBackPlant",
				custCd: EVF.V("CUST_CD")
			};
			everPopup.openCommonPopup(param, 'SP0005');
		}

		function callBackPlant(data) {
			jsondata = JSON.parse(JSON.stringify(data));
			EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
			EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
		}

        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNm",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '${ses.companyCd}',  // 고객사코드or회사코드
                'custNm' : '${ses.companyNm}'  // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _getItemClsNmCust()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNmCust",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '21',  // 고객사코드or회사코드
                'custNm' : '㈜소노인터내셔널' // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNmCust(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1_CUST").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2_CUST").setValue("");}else{EVF.C("ITEM_CLS2_CUST").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3_CUST").setValue("");}else{EVF.C("ITEM_CLS3_CUST").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4_CUST").setValue("");}else{EVF.C("ITEM_CLS4_CUST").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM_CUST").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1_CUST").setValue("");
                EVF.C("ITEM_CLS2_CUST").setValue("");
                EVF.C("ITEM_CLS3_CUST").setValue("");
                EVF.C("ITEM_CLS4_CUST").setValue("");
                EVF.C("ITEM_CLS_NM_CUST").setValue("");
            }
        }

        function _setItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }

		function doTempSave() {
            if(gridB.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if(!gridB.validate().flag) { return alert(gridB.validate().msg); }

            var rowIds = gridB.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                if (gridB.getCellValue(rowIds[i], 'STATUS') == 'P' || gridB.getCellValue(rowIds[i], 'STATUS') == 'E' ) {
	    			return alert("${IM01_060_016}");
                }
            }

            if (!confirm("${msg.M0021 }")) return;

            EVF.V("YINFO_SIGN_STATUS", "T");

            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'sel');
            store.load(baseUrl + 'im01060_doSave', function(){
                alert(this.getResponseMessage());
                doSearch();
            });
		}

        function doSearch() {
            var store = new EVF.Store();
        	store.setGrid([gridB]);
            store.load(baseUrl + 'im01060_doSearch', function() {
            	checkAll();
            });
        }










        function doSave() {
            if (gridB.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if(!gridB.validate().flag) { return alert(gridB.validate().msg); }

            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'sel');
            EVF.V("YINFO_SIGN_STATUS", "T");

            var rowIds = gridB.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                if (gridB.getCellValue(rowIds[i], 'STATUS') == 'P' || gridB.getCellValue(rowIds[i], 'STATUS') == 'E' ) {
	    			return alert("${IM01_060_016}");
                }
            }

            store.load(baseUrl + 'im01060_doSave', function(){
	            store.load(baseUrl + 'im01060_doSearch', function() {
	            	checkAll();
	            	var rowIds = gridB.getSelRowId();
	    	    	for(var i in rowIds) {
	    	    		if(gridB.getCellValue(rowIds[i], 'SALES_UNIT_PRICE') == 0
							|| gridB.getCellValue(rowIds[i], 'CONT_UNIT_PRICE') == 0
	    	    		) {
	    	    			return alert("${IM01_060_014}");
	    	    		}
	                    if (gridB.getCellValue(rowIds[i], 'CHK_TEXT') != 'O') {
	    	    			return alert("${IM01_060_015}");
	                    }
	        		}
	                EVF.V("YINFO_SIGN_STATUS", "P");
	                //결재--
	                var param = {
	                    subject: "폼목,단가(업로드)",
	                    docType: "INFONEWUP",
	                    signStatus: "P",
	                    screenId: "IM02_011",
	                    approvalType: 'APPROVAL',
	                    attFileNum: "",
	                    docNum: '',
	                    callBackFunction: "goApproval"
	                };
	                everPopup.openApprovalRequestIIPopup(param);
	            });



            });
        }

        function goApproval(formData, gridData, attachData) {
            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            EVF.V("YINFO_SIGN_STATUS", "P");

            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'sel');
            store.setParameter("signStatus", 'P');

            if(store.doFileUpload(function() {
    			store.load(baseUrl + 'im01060_doSave', function(){
                    alert(this.getResponseMessage());
                    doSearch();
                });
            }));
        }

		function checkAll() {
	    	var rowIds = gridB.getAllRowId();
	    	for(var i in rowIds) {
	            if (gridB.getCellValue(rowIds[i], 'STATUS') == 'T'
	            	|| gridB.getCellValue(rowIds[i], 'STATUS') == ''
		            	|| gridB.getCellValue(rowIds[i], 'STATUS') == 'R'
			            	|| gridB.getCellValue(rowIds[i], 'STATUS') == 'C'
	            ) {
	            	gridB.checkRow( rowIds[i], true );
	            }
			}
		}

		function doDelete() {
            if (gridB.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            var rowIds = gridB.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                if (gridB.getCellValue(rowIds[i], 'STATUS') == 'P' || gridB.getCellValue(rowIds[i], 'STATUS') == 'E' ) {
	    			return alert("${IM01_060_016}");
                }
            }


            if (!confirm("${msg.M0013}")) return;

            var delCnt = 0;
            for(var i = rowIds.length -1; i >= 0; i--) {
                if(!EVF.isEmpty(gridB.getCellValue(rowIds[i], "SEQ"))) {
                    delCnt++;
                } else {
                    gridB.delRow(rowIds[i]);
                }
            }
            if(delCnt > 0) {
                doDeleteX();
            }
		}

		function doDeleteX() {

            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'sel');
            store.load(baseUrl + 'im01060_doDelete', function() {
                alert(this.getResponseMessage());

                var rowIds = gridB.getSelRowId();
                for(var i = rowIds.length -1; i >= 0; i--) {
                    gridB.delRow(rowIds[i]);
                }
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

    <e:window id="IM01_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearchGrid">

			<c:if test="${param.APP_DOC_NUM==null}">

	            <e:row>
					<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
					<e:field>
					<e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" toDate="REG_DATE_TO" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" fromDate="REG_DATE_FROM" value="${nowDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
					</e:field>
	                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
	                <e:field>
	                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
	                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
	                </e:field>
					<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
					<e:field>
						<e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
						<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
					</e:field>
	            </e:row>
	            <e:row>
					<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
					<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
					</e:field>
					<e:label for="ITEM_DESC_SPEC" title="${form_ITEM_DESC_SPEC_N}" />
					<e:field>
					<e:inputText id="ITEM_DESC_SPEC" name="ITEM_DESC_SPEC" value="" width="${form_ITEM_DESC_SPEC_W}" maxLength="${form_ITEM_DESC_SPEC_M}" disabled="${form_ITEM_DESC_SPEC_D}" readOnly="${form_ITEM_DESC_SPEC_RO}" required="${form_ITEM_DESC_SPEC_R}" />
					</e:field>
	                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
	                <e:field>
	                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
	                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onChange="cleanVendorCd" />
	                </e:field>
	            </e:row>
	            <e:row>
					<e:label for="STATUS" title="${form_STATUS_N}"/>
					<e:field>
					<e:select id="STATUS" name="STATUS" value="T" options="${statusOptions}" width="200" disabled="${form_STATUS_D}" readOnly="${form_STATUS_RO}" required="${form_STATUS_R}" placeHolder="" />
					</e:field>
	                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
	                <e:field colSpan="3">
	                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${formData.SG_CTRL_USER_ID}" options="${itemUserOptions}" width="200" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
	                </e:field>
	            </e:row>

			</c:if>


	        <e:inputHidden id="approvalFormData" name="approvalFormData" />
	        <e:inputHidden id="approvalGridData" name="approvalGridData" />
	        <e:inputHidden id="attachFileDatas" name="attachFileDatas" />

	        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.APP_DOC_NUM}"/>
	        <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${param.APP_DOC_CNT}" />

	        <e:inputHidden id="YINFO_SIGN_STATUS" name="YINFO_SIGN_STATUS" />


        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
        	<div style="float: left; display: inline-block; margin-bottom: 2px;">
				<e:button id="Exceldown" name="Exceldown" label="${Exceldown_N}" onClick="doDownloadExcel" disabled="${Exceldown_D}" visible="${Exceldown_V}"/>
			</div>
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<e:button id="TempSave" name="TempSave" label="${TempSave_N}" onClick="doTempSave" disabled="${TempSave_D}" visible="${TempSave_V}"/>
			<e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
			<e:button id="Delete" name="Delete" label="${Delete_N}" onClick="doDelete" disabled="${Delete_D}" visible="${Delete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridB" name="gridB" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridB.gridColData}" />

    </e:window>
</e:ui>