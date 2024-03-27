<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};
        var selRow;
        var newMode = false;

        function init() {

        	grid = EVF.C('grid');

            grid.cellClickEvent(function(rowId, colId, value) {

            	if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': false
                    };
                    everPopup.im03_009open(param);
				}
                if(colId == 'CHANGE_REASON_NEW') {

                    var param = {
                        title: "${IM02_010_003}",
                        message: grid.getCellValue(rowId, 'CHANGE_REASON_NEW'),
                        callbackFunction: 'setChangeReason',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);

                }
                if(colId =='CUST_HISTORY_YN'){
            	    if(value!=""){
                        var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                            'popupFlag': true,
                            'detailView': true
                        };
                        everPopup.uinfoHistory(param);
					}
				}
                if(colId == 'SG_CTRL_USER_NM') {
                    if( grid.getCellValue(rowId, 'SG_CTRL_USER_NM') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'VENDOR_NM') {
                    if( grid.getCellValue(rowId, 'VENDOR_CD') == '' ) return;
                    var param = {
                            VENDOR_CD: grid.getCellValue(rowId, 'VENDOR_CD'),
                            detailView: true,
                            popupFlag: true
                        };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if (colId == 'ITEM_CHG_REASON') {

                    var param = {
                        rowId: rowId
                        , havePermission: true
                        , screenName: '품목상태 변경사유'
                        , callBackFunction: 'setItemChgReason'
                        , TEXT_CONTENTS: grid.getCellValue(rowId, "ITEM_CHG_REASON")
                        , detailView: false
                    };
                    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);

                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
	            if(colId == "NEW_SALES_UNIT_PRICE" || colId == "CONT_UNIT_PRICE"  ){
					var contUnitPrc = Number(EVF.isEmpty(grid.getCellValue(rowId, 'CONT_UNIT_PRICE')) ? 0 : grid.getCellValue(rowId, 'CONT_UNIT_PRICE'));
	                var changeSalesUnitPrc = Number(EVF.isEmpty(grid.getCellValue(rowId, 'NEW_SALES_UNIT_PRICE')) ? 0 : grid.getCellValue(rowId, 'NEW_SALES_UNIT_PRICE'));
	                var calSalesRate = ((changeSalesUnitPrc - contUnitPrc) / changeSalesUnitPrc) * 100;
	                var salesRate = everMath.round_float(calSalesRate, 1);
	                grid.setCellValue(rowId, 'SALES_RATE', salesRate);
	            }
            });

            grid.setColIconify("CUST_HISTORY_YN", "CUST_HISTORY_YN", "detail", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            if('${form.autoSearchFlag}' == 'Y') {
                //EVF.V('DATE_CONDITION', "M");
                EVF.V('SG_CTRL_USER', '${ses.userId}');
                doSearch();
            }
        }

        function setChangeReason(data) {
            grid.setCellValue(data.rowId, "CHANGE_REASON", data.message);
            grid.setCellValue(data.rowId, 'CHANGE_REASON_NEW', data.message);

			EVF.alert('경고 (단가,계약기간)은 그리드에서 수정하면 해당 고객사건만 수정됩니다.<BR>나머지 고객사 부분도 수정하실려면 상단 고객사 조회조건을 빈칸으로 하시고<BR> 다시 조회 후 나머지 고객사 건과 같이 수정바랍니다.',function(){
				if(confirm('일괄 적용 하시겠습니까?')) {
			        var rowSelIds = grid.getSelRowId();
			        for (var s in rowSelIds) {
			            grid.setCellValue(rowSelIds[s], "CHANGE_REASON", data.message);
			            grid.setCellValue(rowSelIds[s], 'CHANGE_REASON_NEW', data.message);
			        }
				}
			});







        }
        function setItemChgReason(datum, rowId) {
            grid.setCellValue(rowId, 'ITEM_CHG_REASON', datum);

			if(confirm('일괄 적용 하시겠습니까?')) {
		        var rowSelIds = grid.getSelRowId();
		        for (var s in rowSelIds) {
		            grid.setCellValue(rowSelIds[s], 'ITEM_CHG_REASON', datum);
		        }
			}


        }

        function doSearch() {
			var flag = true;
			$('input').each(function (k, v) {
				if (!(v.type == 'hidden' || v.type == 'radio' || v.type == 'checkbox' || v.id == 'grid_line' || v.id == 'grid-search')) {
					if (v.value != '') {
						flag = false;
					}
				}
			});

			if(flag) {
				alert("${IM02_010_009}"); // 검색조건을 한개 이상 입력하여 주시기 바랍니다.
				return;
			}

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'im02010_doSearch', function() {
            	if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doRegistration() {

  			var param = {};
  			if(grid.getSelRowCount() == 1 && 1==2) {
  				var rowIds = grid.getSelRowId();
	  			for(var i = 0; i < rowIds.length; i++) {
	  				param = {
		        		BUYER_CD : grid.getCellValue(rowIds[i], 'BUYER_CD'),
		             	ITEM_CD : grid.getCellValue(rowIds[i], 'ITEM_CD'),
		                'detailView': false,
		                'popupFlag': true
					};
				}
  			} else {
  				param = {
  					BUYER_CD : "",
	             	ITEM_CD : "",
	             	'detailView': false,
	                'popupFlag': true
				};
  			}
            everPopup.openPopupByScreenId("IM02_011", 1200, 600, param);
        }

        function doModify() {
			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	    	if (!grid.validate().flag) { return alert(grid.validate().msg); }

			var rowIds = grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
  				if(grid.getCellValue(rowIds[i], 'CHANGE_REASON_NEW')=="") {
  					return alert("${IM02_010_004}");
  				}
			}

            EVF.V("YINFO_SIGN_STATUS", "P");


			EVF.alert('경고 (단가,계약기간)은 그리드에서 수정하면 해당 고객사건만 수정됩니다.<BR>나머지 고객사 부분도 수정하실려면 상단 고객사 조회조건을 빈칸으로 하시고<BR> 다시 조회 후 나머지 고객사 건과 같이 수정바랍니다.',function(){
	            //결재--
	            var param = {
	                subject: "매입,매출단가변경",
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
			store.load(baseUrl + 'im02011_doSave', function(){
           		alert(this.getResponseMessage());
           		doSearch();
           	});
        }

        function doDelete() {
			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			var rowIds = grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
  				if(grid.getCellValue(rowIds[i], 'CHANGE_REASON_NEW')=="") {
  					return alert("${IM02_010_004}");
  				}
			}
            if(!confirm('${msg.M0013}')) { return; }

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.getGridData(grid, 'sel');
			store.load(baseUrl + 'im02010_doDelete', function(){
           		alert(this.getResponseMessage());
           		doSearch();
           	});
        }

        function getCustCd() {
        	var param = {
				callBackFunction : "setCustCd"
			};
			everPopup.openCommonPopup(param, 'SP0067');
        }

		function setCustCd(dataJsonArray) {
			EVF.C("BUYER_CD").setValue(dataJsonArray.CUST_CD);
			EVF.C("BUYER_NM").setValue(dataJsonArray.CUST_NM);
		}


        function getBuyerInfo() {
            var param = {
                callBackFunction : "setBuyerInfo"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function setBuyerInfo(data) {
            EVF.V("BUYER_CD",data.CUST_CD);
            EVF.V("BUYER_NM",data.CUST_NM);

            EVF.V("CUST_CD",data.CUST_CD);
            //chgCustCd();
        }

		function getVendorInfo() {
	        var param = {
	            callBackFunction: "setVendorInfo"
	        };
	        everPopup.openCommonPopup(param, 'SP0063');
	    }

	    function setVendorInfo(jsonData) {

	    	/*var vendorCdStr = "";
	    	var vendorNmStr = "";
	        for(idx in jsonData) {
	        	vendorCdStr = vendorCdStr + jsonData[idx].VENDOR_CD + ",";
	        	vendorNmStr = vendorNmStr + jsonData[idx].VENDOR_NM + ",";
	        }
	        if(vendorCdStr.length > 0) { vendorCdStr = vendorCdStr.substring(0, vendorCdStr.length - 1); }
	        if(vendorNmStr.length > 0) { vendorNmStr = vendorNmStr.substring(0, vendorNmStr.length - 1); }

	        EVF.C("VENDOR_CD").setValue(vendorCdStr);
	        EVF.C("VENDOR_NM").setValue(vendorNmStr);
	        */
            EVF.V("VENDOR_CD", jsonData.VENDOR_CD);
            EVF.V("VENDOR_NM", jsonData.VENDOR_NM);
	    }

		function cleanValue() {
			var colType = this.getData();
			if(colType == "B") { EVF.C("BUYER_CD").setValue(""); }
			if(colType == "V") {
				EVF.C("VENDOR_CD").setValue("");
				//EVF.C("VENDOR_NM").setValue("");
			}
		}

		function setReason(data){
        	grid.setCellValue(data.rowId, 'CHANGE_REASON_NEW', data.message);
        }

        function doSearchDept() {
        	var custCd = EVF.V("BUYER_CD");

        	if(custCd == "") {
        		return alert("${IM02_010_007}");
			}

	        var param = {
		        callBackFunction: "setDept",
				CUST_CD: custCd
	        };
	        <%-- everPopup.openCommonPopup(param, 'SP0084'); --%>
	        everPopup.openCommonPopup(param, 'SP0071');
		}

		function setDept(data) {
			EVF.V("DEPT_CD", data.DEPT_CD);
			EVF.V("DEPT_NM", data.DEPT_NM);
		}



        function chgCustCd() {
            var store = new EVF.Store;
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
            	}
            });
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

		function onSearchPlant() {
			if( EVF.V("BUYER_CD") == "" ) return alert("${IM02_010_008}");
			var param = {
				callBackFunction : "callBackPlant",
				custCd: EVF.V("BUYER_CD")
			};
			everPopup.openCommonPopup(param, 'SP0005');
		}

		function callBackPlant(data) {
			jsondata = JSON.parse(JSON.stringify(data));
			EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
			EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
		}

		function doBlock() {
            var store = new EVF.Store();
            if (!store.validate()) {
//                return;
            }
            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!grid.validate().flag) {
                return alert(grid.validate().msg);
            }

            var allRowId = grid.getSelRowId();
            for(var i in allRowId) {
                var rowId = allRowId[i];
				if(grid.getCellValue(rowId, "ITEM_STATUS")!='10') {
                	EVF.alert('상품상태가 사용이 아닌 건입니다.');
					return;
				}
                if(grid.getCellValue(rowId, "ITEM_CHG_REASON") == '') {
                	EVF.alert('변경사유를 입력해주세요.');
                	return;
                }
            }
            if (!confirm("단종처리 하시겠습니까?")) return;
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "block", function () {
                alert(this.getResponseMessage());
                doSearch();
            });



		}
		function doBlockCancel() {
            var store = new EVF.Store();
            if (!store.validate()) {
                //return;
            }
            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!grid.validate().flag) {
                return alert(grid.validate().msg);
            }

            var allRowId = grid.getSelRowId();
            for(var i in allRowId) {
                var rowId = allRowId[i];
				if(grid.getCellValue(rowId, "ITEM_STATUS")=='10') {
                	EVF.alert('상품상태가 사용인 건입니다.');
					return;
				}
            }
            if (!confirm("단종해체처리 하시겠습니까?")) return;
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "blockCancel", function () {
                alert(this.getResponseMessage());
                doSearch();
            });



		}

		function onChangeStdFlag(){
        	var baseUrl2 ="/evermp/IM03/IM0301/";
			var store = new EVF.Store;
			store.setParameter("FLAG", EVF.C("STD_FLAG").getValue());
			store.load(baseUrl2 + '/getStdType', function() {
				if (this.getParameter("stdTypes") != null) {
					EVF.C('STD_TYPE').setOptions(this.getParameter("stdTypes"));
				}
			});
		}

	</script>

    <e:window id="IM02_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<%--
				<e:label for="DATE_CONDITION">
					<e:select id="DATE_CONDITION" name="DATE_CONDITION" required="${form_DATE_CONDITION_R}" disabled="${form_DATE_CONDITION_D}" readOnly="${form_DATE_CONDITION_RO}" usePlaceHolder="false" width="100%" height="27px">
						<e:option text="${IM02_010_005}" value="C"/>
						<e:option text="${IM02_010_006}" value="M"/>
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="FROM_DATE" name="FROM_DATE" toDate="TO_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_R}" disabled="${form_DATE_D}" readOnly="${form_DATE_RO}"/>
					<e:text>~</e:text>
					<e:inputDate id="TO_DATE" name="TO_DATE" fromDate="FROM_DATE" value="${nowDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_R}" disabled="${form_DATE_D}" readOnly="${form_DATE_RO}"/>
				</e:field>
				--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
					<e:search id="BUYER_CD" style="ime-mode:inactive" name="BUYER_CD" value="21" width="40%" maxLength="${form_BUYER_CD_M}" onIconClick="${form_BUYER_CD_RO ? 'everCommon.blank' : 'getBuyerInfo'}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
					<e:inputText id="BUYER_NM" style="${imeMode}" name="BUYER_NM" value="㈜소노인터내셔널" width="60%" maxLength="${form_BUYER_NM_M}" disabled="${form_BUYER_NM_D}" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}"  onChange="cleanValue"  data="B" />
					<e:inputHidden id="CUST_CD" name="CUST_CD"/>
					<e:inputHidden id="DEPT_CD" name="DEPT_CD"/>
				</e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'getVendorInfo'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"  onChange="cleanValue"  data="V" />
				</e:field>
			</e:row>
			<e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W }" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
				<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="SG_CTRL_USER" title="${form_SG_CTRL_USER_N}"/>
				<e:field>
					<e:select id="SG_CTRL_USER" name="SG_CTRL_USER" value="" options="${sgCtrlUserOptions }" width="${form_SG_CTRL_USER_W }" disabled="${form_SG_CTRL_USER_D}" readOnly="${form_SG_CTRL_USER_RO}" required="${form_SG_CTRL_USER_R}" placeHolder="" />
				</e:field>
            </e:row>
			<e:row>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field>
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
                </e:field>
				<e:label for="ITEM_CLS_NM_CUST" title="${form_ITEM_CLS_NM_CUST_N}"/>
				<e:field>
				<e:search id="ITEM_CLS_NM_CUST" name="ITEM_CLS_NM_CUST" value="" width="${form_ITEM_CLS_NM_CUST_W}" maxLength="${form_ITEM_CLS_NM_CUST_M}" onIconClick="_getItemClsNmCust" disabled="${form_ITEM_CLS_NM_CUST_D}" readOnly="${form_ITEM_CLS_NM_CUST_RO}" required="${form_ITEM_CLS_NM_CUST_R}" />
                    <e:inputHidden id="ITEM_CLS1_CUST" name="ITEM_CLS1_CUST" />
                    <e:inputHidden id="ITEM_CLS2_CUST" name="ITEM_CLS2_CUST" />
                    <e:inputHidden id="ITEM_CLS3_CUST" name="ITEM_CLS3_CUST" />
                    <e:inputHidden id="ITEM_CLS4_CUST" name="ITEM_CLS4_CUST" />
				</e:field>
				<e:label for="SEARCH_COUNT_CD" title="${form_SEARCH_COUNT_CD_N}"/>
				<e:field>
					<e:select id="SEARCH_PAGE_NO" name="SEARCH_PAGE_NO" value="1" options="${searchPageNoOptions}" width="40%" disabled="${form_SEARCH_PAGE_NO_D}" readOnly="${form_SEARCH_PAGE_NO_RO}" required="${form_SEARCH_PAGE_NO_R}" placeHolder="" usePlaceHolder="false"/>
					<e:select id="SEARCH_COUNT_CD" name="SEARCH_COUNT_CD" value="500" options="${searchCountCdOptions}" width="60%" disabled="${form_SEARCH_COUNT_CD_D}" readOnly="${form_SEARCH_COUNT_CD_RO}" required="${form_SEARCH_COUNT_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
				<e:field>
					<e:select id="ITEM_STATUS" name="ITEM_STATUS" value="10" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
				</e:field>
				<e:label for="UNIT_PRC_VALID_YN" title="${form_UNIT_PRC_VALID_YN_N}"/>
				<e:field>
					<e:select id="UNIT_PRC_VALID_YN" name="UNIT_PRC_VALID_YN" value="1" options="${unitPrcValidYnOptions}" width="40%" disabled="${form_UNIT_PRC_VALID_YN_D}" readOnly="${form_UNIT_PRC_VALID_YN_RO}" required="${form_UNIT_PRC_VALID_YN_R}" placeHolder="" />
					<e:select id="TEMP_CD_FLAG" name="TEMP_CD_FLAG" value="0" options="${tempCdFlagOptions}" width="60%" disabled="${form_TEMP_CD_FLAG_D}" readOnly="${form_TEMP_CD_FLAG_RO}" required="${form_TEMP_CD_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="STD_FLAG" title="${form_STD_FLAG_N}"/>
				<e:field>
					<e:select id="STD_FLAG" name="STD_FLAG" value="" onChange="onChangeStdFlag" options="${stdFlagOptions}" width="40%" disabled="${form_STD_FLAG_D}" readOnly="${form_STD_FLAG_RO}" required="${form_STD_FLAG_R}" placeHolder="" />
					<e:select id="STD_TYPE" name="STD_TYPE" value="" options="${stdTypeOptions}" width="60%" disabled="${form_STD_TYPE_D}" readOnly="${form_STD_TYPE_RO}" required="${form_STD_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
	        <e:inputHidden id="approvalFormData" name="approvalFormData" />
	        <e:inputHidden id="approvalGridData" name="approvalGridData" />
	        <e:inputHidden id="attachFileDatas" name="attachFileDatas" />
	        <e:inputHidden id="YINFO_SIGN_STATUS" name="YINFO_SIGN_STATUS" />
	        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value=""/>
	        <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="" />
        </e:searchPanel>
        	<e:text style="color:#FF0000;font-size: 13px;">
					<B>경고 (단가,계약기간)은 그리드에서 수정하면 해당 고객사건만 수정됩니다.
					나머지 고객사 부분도 수정하실려면 상단 고객사 조회조건을 빈칸으로 하시고
					다시 조회 후 나머지 고객사 건과 같이 수정바랍니다.
        	</e:text>

        <e:buttonBar id="buttonBar" align="right" width="100%">
			<e:panel>
			<e:button id="doBlock" name="doBlock" label="${doBlock_N}" onClick="doBlock" disabled="${doBlock_D}" visible="${doBlock_V}"/>
			<e:button id="doBlockCancel" name="doBlockCancel" label="${doBlockCancel_N}" onClick="doBlockCancel" disabled="${doBlockCancel_D}" visible="${doBlockCancel_V}"/>
			</e:panel>
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Registration" name="Registration" label="${Registration_N}" disabled="${Registration_D}" visible="${Registration_V}" onClick="doRegistration" />
            <e:button id="Modify" name="Modify" label="${Modify_N}" disabled="${Modify_D}" visible="${Modify_V}" onClick="doModify" />
            <e:button id="Delete" name="Delete" label="${Delete_N}" disabled="${Delete_D}" visible="${Delete_V}" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>