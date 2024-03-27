<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui>
<script>
    var baseUrl = "/evermp/buyer/eval/";
    var gridVendor;
    var gridUs;
	var tplFlag = true;
	var idx = 0;
	var selRow;
    function init() {
		
    	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
    	if('${param.detailView}' == 'true') {
    		$('#upload-button-ATT_FILE_NUM').css('display','none');
    	}
    	
    	gridVendor = EVF.C("gridVendor");
		gridUs = EVF.C("gridUs");
    	
		gridVendor.setProperty('panelVisible', ${panelVisible});
		gridUs.setProperty('panelVisible', ${panelVisible});
    	
		if( '${param.detailView}' == "") {
    		EVF.C('doClose').setVisible(false);
		}

		//EVF.C('EV_TYPE').removeOption('R');
		
		// 평가 협력업체
		gridVendor.excelImportEvent({
			'append': false
		}, function (msg, code) {
			if (code) {
				var store = new EVF.Store();
				store.setGrid([gridVendor]);
				store.getGridData(gridVendor, 'all');
		        store.load(baseUrl + "EV0210/doSearchExecelEVES", function() {
		        	
				});
			}
		});
		
		// 평가자
		gridUs.excelImportEvent({
			'append': false
		}, function (msg, code) {
			if (code) {
				if(gridVendor.getRowCount()==0) {
					gridUs.delAllRow();
					return EVF.alert("협력업체를 추가해 주세요.");
				} else {
					var store = new EVF.Store();
					store.setGrid([gridVendor,gridUs]);
					store.getGridData(gridVendor, 'all');
					store.getGridData(gridUs, 'all');
			        store.load(baseUrl + "EV0210/doSearchExecelEVEU", function() {
			        	gridUs.delAllRow();
			        	
			        	gridUs.addRow(JSON.parse(gridVendor.getCellValue(0, "USER_INFO")));
						
						var resultEnterCd = EVF.V("RESULT_ENTER_CD");
				    	var allRowId = gridUs.getAllRowId();
				    	for(var i in allRowId) {
				    		var rowIdx = allRowId[i];
				    		if(resultEnterCd == 'REPUSER') {
				    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", false);
				    		} else {
				    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", true);
				    			gridUs.setCellValue(rowIdx, "REP_FLAG", "0");
				    		}
						}
					});
				}
			}
		});
		
		/* gridVendor.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });
        gridUs.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        }); */

    	if ( "${form.EV_NUM}" == "" || "${form.PROGRESS_CD}" == "") {
	    	EVF.C('PURCHASE_TYPE').setValue('NPUR');
	    	EVF.C('EV_TYPE').setValue('CLASS');
	    	EVF.C('RESULT_ENTER_CD').setValue('PERUSER');
	    	
    		EVF.C('doDelete').setVisible(false);
    		EVF.C('doRequest').setVisible(false);
    		EVF.C('doCancel').setVisible(false);
		} else if( '${form.PROGRESS_CD}' == "100" || '${form.PROGRESS_CD}' == "150"){
    		EVF.C('doCancel').setVisible(false);
		} else if( '${form.PROGRESS_CD}' == "200"){
    		EVF.C('doSave').setVisible(false);
    		EVF.C('doDelete').setVisible(false);
    		EVF.C('doRequest').setVisible(false);
		} else if( '${form.PROGRESS_CD}' == "300"){
    		EVF.C('doSave').setVisible(false);
    		EVF.C('doDelete').setVisible(false);
    		EVF.C('doRequest').setVisible(false);
    		EVF.C('doCancel').setVisible(false);
		}

		if ( '${param.detailView}' == "true" || '${form.PROGRESS_CD}' == "200" || '${form.PROGRESS_CD}' == "300") {
    		EVF.C('doAddVendor').setVisible(false);
    		EVF.C('doDelVendor').setVisible(false);
    		EVF.C('doAddUs').setVisible(false);
    		EVF.C('doDelUs').setVisible(false);
		}

    	gridUs.setProperty('shrinkToFit', true);
    	gridVendor.setProperty('shrinkToFit', true);

    	gridVendor.cellClickEvent(function (rowIdx, colIdx, value, iRow, iCol) {

    		if (rowIdx == -1 ) return;

			idx = rowIdx;
			gridUs.delAllRow();

   			var USER_INFO = gridVendor.getCellValue(rowIdx, "USER_INFO");
   			if(USER_INFO == "") {
   				//gridUs.addRow(param);
			} else {
				gridUs.addRow(JSON.parse(USER_INFO));

				var resultEnterCd = EVF.V("RESULT_ENTER_CD");
		    	var allRowId = gridUs.getAllRowId();
		    	for(var i in allRowId) {
		    		var rowIdx = allRowId[i];
		    		if(resultEnterCd == 'REPUSER') {
		    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", false);
		    		}else {
		    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", true);
		    			gridUs.setCellValue(rowIdx, "REP_FLAG", "0");
		    		}
				}
			}
    	});

    	gridUs.cellChangeEvent(function (rowIdx, colIdx, value, iRow, iCol) {
    		switch (colIdx) {
				case "REP_FLAG":
	    			USER_COPY(idx);
	    			break;
    		}
    	});

	    gridVendor.hideCol('CONT_NUM', true);
	    gridVendor.hideCol('CONT_DESC', true);

    	doSearchEVES(); <%--협력사조회--%>
    }

    //결과입력 협력업체담당자일 경우 협력업체담당자 필드 필수
    function chgResult() {

    	var resultEnterCd = EVF.V("RESULT_ENTER_CD");
    	var allRowId = gridUs.getAllRowId();
    	for(var i in allRowId) {
    		var rowIdx = allRowId[i];
    		if(resultEnterCd == 'REPUSER') {
    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", false);
    		}else {
    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", true);
    			gridUs.setCellValue(rowIdx, "REP_FLAG", "0");
    		}
		}
		
    	var allRowIdVendor = gridVendor.getAllRowId();
    	for(var i in allRowIdVendor) {
    		if(resultEnterCd != 'REPUSER') {
	    		var vendorInfoList = JSON.parse(gridVendor.getCellValue(allRowIdVendor[i], 'USER_INFO'));
	    		for(var j in vendorInfoList) {
	    			var vendorGridInfo = vendorInfoList[j];
	    			vendorGridInfo.REP_FLAG = 0;
	    		}
	    		CHANGE_COPY(i, vendorInfoList);
    		}
    	}

    }

	<%-- 협력사 조회 --%>
    function doSearchEVES() {
        var store = new EVF.Store();
        store.setGrid([gridVendor]);
        store.load(baseUrl + "EV0210/doSearchEVES", function() {
			if (gridVendor.getRowCount() > 0) {
				var USER_INFO = gridVendor.getCellValue(0, "USER_INFO");
				if (USER_INFO != "") {
					gridUs.addRow(JSON.parse(USER_INFO));
					
					var resultEnterCd = EVF.V("RESULT_ENTER_CD");
			    	var allRowId = gridUs.getAllRowId();
			    	for(var i in allRowId) {
			    		var rowIdx = allRowId[i];
			    		if(resultEnterCd == 'REPUSER') {
			    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", false);
			    		}else {
			    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", true);
			    			gridUs.setCellValue(rowIdx, "REP_FLAG", "0");
			    		}
					}

				}
        	}
        });
    }

	<%-- 평가자 조회 --%>
    function doSearchEVEU() {
        var store = new EVF.Store();
        store.setGrid([gridUs]);
        store.load(baseUrl + "EV0210/doSearchEVEU", function() {
        	
        });
    }

    $(document.body).ready(function() {
     	var winHeight=document.all?document.body.clientHeight:window.innerHeight; //브라우저 세로폭 사이즈 가져오기
    	if( winHeight <= 768 ) {
    		 var fHeight = $("#file_container_ATT_FILE_NUM").parent().parent().parent().parent().height();
    		 $("#file_container_ATT_FILE_NUM").parent().parent().height(fHeight-30);
    		 $("#file_container_ATT_FILE_NUM").parent().height(fHeight-30);
    		 $("#file_container_ATT_FILE_NUM").height(fHeight-30);
    		 $("#file_container_ATT_FILE_NUM").parent().parent().parent().parent().height(fHeight-30);
    	}
	});

    <%-- 평가담당자 선택 팝업 --%>
    function doSelectUser() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }

    <%-- 평가담당자 세팅 --%>
    function selectUser(dataJsonArray) {
        EVF.C("EV_CTRL_NM").setValue(dataJsonArray.USER_NM);
        EVF.C("EV_CTRL_USER_ID").setValue(dataJsonArray.USER_ID);
    }

    <%-- 템플릿 팝업 --%>
    function doSearchTempl() {
    	var evType = EVF.C("EV_TYPE").getValue();
    	var ev_tpl_type_cd = '';

		if(evType == 'E') {
			ev_tpl_type_cd = 'E';
		} else if(evType == 'R') {
			ev_tpl_type_cd = 'R';
		}

        var param = {
            callBackFunction: "selectTemplAfter",
            EV_TYPE: ev_tpl_type_cd
        };
        everPopup.openCommonPopup(param, 'SP0034');
    }

    <%-- 템플릿 세팅 --%>
    function selectTemplAfter(dataJsonArray) {
        EVF.C("EXEC_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.C("EV_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);
    }

    <%-- 평가자 추가 --%>
    function doAddUs() {

    	if(gridVendor.getRowCount() == 0) {
    	 	EVF.alert("협력업체를 추가해 주세요.");
            return;
		}
		
		var popupUrl = "/eversrm/master/user/BADU_050/view.so?";
		var param = {
			callBackFunction: "selectUs",
			detailView: false,
			multiYN: true,
		};
		everPopup.openModalPopup(popupUrl, 800, 700, param);
	}

    <%-- 평가자 세팅 --%>
    function selectUs(userList) {
    	
		var existUser = true;
		var itemdata  = JSON.parse(userList);
    	$(itemdata).each(function(idx, data){
	     	if(data.USER_ID == ''){
	     		return;
	     	}

	 		for (var i = 0, length = gridUs.getRowCount(); i < length; i++) {
	             if (gridUs.getCellValue(i,"EV_USER_ID") == data.USER_ID) {
	 				existUser = false;
	             }
	 	    }

	 	    if(existUser){
	 	    	addParam = [{
	     	            		 EV_USER_ID : data.USER_ID
	     	            		,USER_NM    : data.USER_NM
	     	            		,DEPT_NM    : data.DEPT_NM
	     	            		,REP_FLAG   : data.REP_FLAG != undefined ? data.REP_FLAG : ''
	     	            	}];

	 	    	gridUs.addRow(addParam);

	 	    	var resultEnterCd = EVF.V("RESULT_ENTER_CD");
	 	    	var allRowId = gridUs.getAllRowId();
	 	    	for(var i in allRowId) {
	 	    		var rowIdx = allRowId[i];
	 	    		if(resultEnterCd == 'REPUSER') {
	 	    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", false);
	 	    		}else {
	 	    			gridUs.setCellReadOnly(rowIdx, "REP_FLAG", true);
	 	    		}
				}
	 	    } else {
	 	    	EVF.alert("동일한 평가자가 존재합니다.");
	 	    }
    	});
    	
		// 선택한 모든 협력사에 동일한 평가자 세팅
    	USER_COPY(idx);
    }

    function USER_COPY(rowIdx) {
    	
		EVF.confirm('모든 협력업체의 평가자에 일괄적용 하시겠습니까?',function(){
	    	var allRowValue = gridUs.getAllRowValue();
			for ( k = 0; k < gridVendor.getRowCount(); k++) {
				gridVendor._gdp.setValue(k, "USER_INFO", JSON.stringify(allRowValue));
			}
		});
		
		//gridVendor._gdp.setValue(rowIdx, "USER_INFO", JSON.stringify(allRowValue));
    }

    function CHANGE_COPY(rowIdx, vendorInfoList) {
		gridVendor._gdp.setValue(rowIdx, "USER_INFO", JSON.stringify(vendorInfoList));
	}

    <%-- 평가자 삭제 --%>
    function doDelUs() {
    	
    	if (gridUs.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
    	
     	var selRowId = gridUs.jsonToArray(gridUs.getSelRowId()).value;
        for (var i = selRowId.length; 0 < i; i--) {
        	gridUs.delRow(selRowId[i-1]);
        }
        USER_COPY(idx);
    }

    <%--협력사 추가 --%>
	function doAddVendor() {
		
		var param = {
			EV_TYPE : EVF.V('EV_TYPE'),
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'MP0054');
    }

    <%--협력사 세팅 --%>
	function selectVendorCd(vendorList) {
		
		var existVendor = true;
		var first = 1;
     	$(vendorList).each(function(idx, data){
     		if(data.VENDOR_CD == ""){
	     		return;
	     	}

	 		for (var i = 0, length = gridVendor.getRowCount(); i < length; i++) {
	             if (gridVendor.getCellValue(i, "VENDOR_CD") == data.VENDOR_CD) {
	            	 existVendor = false;
	             }
	 	    }
			
	 		// 평가종류
 			var evType = EVF.V("EV_TYPE");
 			var userInfo = '';
	 	    if(existVendor){
	 	    	if (evType == 'ESG') {
		 	    	var evUserInfo = [{
		     	    	  EV_USER_ID : data.USER_ID
		     	        , USER_NM : data.USER_NM
					}];
	 				userInfo = JSON.stringify(evUserInfo)
		 	    	if(first == 1) {
		 	    		if(gridUs.getRowCount()==0) {
			 	    		gridUs.addRow(evUserInfo);
		 	    		}
		 	    	}
	 	    	}
				
	 	    	var addParam = [{
					  INSERT_FLAG: "Y"
	     	    	, VENDOR_CD: data.VENDOR_CD
	     	        , VENDOR_NM: data.VENDOR_NM
	     	        , CEO_USER_NM: data.CEO_USER_NM
	     	        , USER_ID: data.USER_ID
	     	        , USER_NM: data.USER_NM
	     	        , EMAIL: data.EMAIL
	     	        , EV_USER_ID: data.USER_ID
	     	        , USER_INFO: userInfo
				}];
	 	    	
	 	    	gridVendor.addRow(addParam);
	 	    }

			existVendor = true;
	 	   	gridVendor.checkAll(false);
	 	   	first++;
     	});
    }

    <%--협력사 삭제 --%>
    function doDelVendor() {
    	
    	if (gridVendor.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
    	
    	var selRowId = gridVendor.jsonToArray(gridVendor.getSelRowId()).value;
    	for (var i = selRowId.length; i > 0 ; i--) {
        	gridVendor.delRow(selRowId[i]);
        }
    }

    function clearGridA(){
    	gridUs.delAllRow();
    	gridVendor.delAllRow();
    }

    <%-- 조회 --%>
    function doSearch() {
		var ev_num = EVF.C("EV_NUM").getValue();
		if( ev_num == "" ) {
			return;
		}
		location.href="/evermp/buyer/eval/EV0210/view.so?EV_NUM="+ev_num;
    }

    <%-- 저장 --%>
    function doSave() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		gridVendor.checkAll(true);

        if (!gridVendor.isExistsSelRow()) {
            EVF.alert("${EV0210_0009}");
            return;
        }

        if (!checkValidation()) { return; }

        EVF.confirm("${msg.M0021 }", function () {
            store.setGrid([gridUs, gridVendor]);
    		store.getGridData(gridUs, 'sel');
    		store.getGridData(gridVendor, 'sel');

    		store.doFileUpload(function() {
    			store.load(baseUrl + 'EV0210/doSave', function() {
    				var evNum = this.getParameter('ev_num');
	                EVF.alert(this.getResponseMessage(), function() {
	                	EVF.getComponent("EV_NUM").setValue(evNum);
	                	//EVF.getComponent("EV_NUM").setValue(this.getParameter('ev_num'));
	                	//EVF.C("EV_NUM").setValue(this.getParameter('ev_num'));
	    				doSearch();
	                });
	            });
    		});
        });
    }

    function checkValidation() {

    	var allRowIdVendor = gridVendor.getAllRowId();
    	var resultEnterCd = EVF.V("RESULT_ENTER_CD");
    	for(var i in allRowIdVendor) {
    		
    		var vendorNm = gridVendor.getCellValue(allRowIdVendor[i], "VENDOR_NM");
    		if (gridVendor.getCellValue(allRowIdVendor[i], "USER_INFO") == "") {
				return EVF.alert(vendorNm +" 파트너사 ${EV0210_0010}");
			}

    		if(resultEnterCd == 'REPUSER') {
    			var checkedCnt = 0;
	    		var vendorInfoList = JSON.parse(gridVendor.getCellValue(allRowIdVendor[i], 'USER_INFO'));
	    		for(var j in vendorInfoList) {
	    			var vendorGridInfo = vendorInfoList[j];
	    			console.log(vendorGridInfo.REP_FLAG);

	    			if(vendorGridInfo.REP_FLAG == "1") {
	    				checkedCnt++;
	    			}
	    		}

	    		if(checkedCnt == 0) {
	    			return EVF.alert(vendorNm + " 파트너사의 대표평가자를 선택하시기 바랍니다.");
	    		}

	    		if(checkedCnt > 1) {
	    			return EVF.alert(vendorNm + " 파트너사의 대표평가자는 한명만 가능합니다..");
	    		}
    		}

			var VENDOR_CD = gridVendor.getCellValue(allRowIdVendor[i], "VENDOR_CD");
			var CONT_NUM = gridVendor.getCellValue(allRowIdVendor[i], "CONT_NUM");
			var VENDOR_CONT = VENDOR_CD + CONT_NUM;
			var cnt = 0;

			for(var k in allRowIdVendor) {
				var rowid = allRowIdVendor[k];

				if(VENDOR_CONT == (gridVendor.getCellValue(rowid, "VENDOR_CD") + gridVendor.getCellValue(rowid, "CONT_NUM"))) {
					cnt++;
				}
			}

			if(cnt > 1) {
				return EVF.alert("${EV0210_0018}");
			}
    	}

    	return true;

    }

    <%-- 삭제 --%>
    function doDelete() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		gridUs.checkAll(true);
		gridVendor.checkAll(true);

		EVF.confirm("${msg.M0013 }", function () {
            store.setGrid([gridUs, gridVendor]);
    		store.getGridData(gridUs, 'sel');
    		store.getGridData(gridVendor, 'sel');

    		store.doFileUpload(function() {
    			store.load(baseUrl + 'EV0210/doDelete', function() {
	                EVF.alert(this.getResponseMessage(), function() {
	    				doSearch();
	                });
	            });
    		});
        });
    }

    <%-- 메일전송 --%>
    function doMailSend() {
    	gridVendor.checkAll(true);

    	var store = new EVF.Store();
		if (!store.validate())
			return;

		if(!gridVendor.isExistsSelRow()) { return alert("${msg.M0004}"); }

		var arrayVendorInfo = [];
		var selRowId = gridVendor.getSelRowId();

		for(var i in selRowId) {
			var vendorInfo = {
					'RECV_USER_ID' : gridVendor.getCellValue(selRowId[i], 'USER_ID'),
        			'RECV_USER_NM' : gridVendor.getCellValue(selRowId[i], 'USER_NM'),
        			'RECV_EMAIL'   : gridVendor.getCellValue(selRowId[i], 'EMAIL'),
           			'BUYER_CD'     : gridVendor.getCellValue(selRowId[i], 'VENDOR_CD'),
        			'COMPANY_NM'   : gridVendor.getCellValue(selRowId[i], 'VENDOR_NM')
           		}
			arrayVendorInfo.push(vendorInfo);
		}

		var param = {
			vendorList: JSON.stringify(arrayVendorInfo),
			popupFlag: true,
			detailView: false
		};
		everPopup.openPopupByScreenId("BSN_040", 1200, 800, param);
    }

    <%-- 평가요청 --%>
    function doRequest() {
		
		var store = new EVF.Store();
		if (!store.validate())
			return;

		EVF.confirm("${EV0210_0016}", function () {
			store.load(baseUrl + 'EV0210/doRequest', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

    <%-- 요청취소 --%>
    function doCancel() {

		var store = new EVF.Store();
		if (!store.validate())
			return;

		EVF.confirm("${EV0210_0017}", function () {
			store.load(baseUrl + 'EV0210/doCancel', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

    <%-- 닫기 --%>
    function doClose() {
    	if( opener != null) {
    		opener.doSearch();
    	}
    	self.close();
    }

	function chgEvType() {
		gridUs.delAllRow(true);
		gridVendor.delAllRow(true);
		
		var evType = EVF.V("EV_TYPE");
		if (evType == 'ESG') {
    		EVF.C('doAddUs').setVisible(false);
    		EVF.C('doDelUs').setVisible(false);
    		EVF.V('RESULT_ENTER_CD', 'PERUSER');
    		EVF.C('RESULT_ENTER_CD').setReadOnly(true);
		}
		else {
    		EVF.C('doAddUs').setVisible(true);
    		EVF.C('doDelUs').setVisible(true);
    		EVF.C('RESULT_ENTER_CD').setReadOnly(false);
		}
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
	
	function doDownloadExcelUser(){
		var attFileNum = '${USER_TEMP_ATT_FILE_NUM}';
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

	<e:window id="EV0210" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
        	<!--  e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/-->
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
			<e:row>
				<%--회사명--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" usePlaceHolder="false"/>
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
			</e:row>
            <e:row>
            	<%-- 평가번호 --%>
				<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
					<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="${form_EV_NUM_W}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				</e:field>
            	<%-- 진행상태 --%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:inputText id="PROGRESS_NM" style="ime-mode:inactive" name="PROGRESS_NM" value="${form.PROGRESS_NM}" width="${form_PROGRESS_NM_W}"  maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}"/>
					<e:inputHidden id="PROGRESS_CD" style="ime-mode:inactive" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
				</e:field>
            </e:row>
            <e:row>
            	<%-- 평가명 --%>
				<e:label for="EV_NM" title="${form_EV_NM_N}"/>
				<e:field>
					<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
				</e:field>
            	<%-- 파트너사 담당자 --%>
				<e:label for="EV_CTRL_NM" title="${form_EV_CTRL_NM_N}"/>
				<e:field>
					<e:select id="EV_CTRL_NM" name="EV_CTRL_NM" value="${form.EV_CTRL_USER_ID }" options="${evCtrlNmOptions}" width="${form_EV_CTRL_NM_W}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" placeHolder="" />
					<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
				</e:field>
			</e:row>
            <e:row>
            	<%-- 평가구분 --%>
				<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
					<e:select id="EV_TYPE" name="EV_TYPE" onChange="chgEvType" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
				</e:field>
				<e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE"/>
            	<%-- 템플릿 --%>
				<e:label for="EV_TPL_SUBJECT" title="${form_EV_TPL_SUBJECT_N}"/>
				<e:field>
					<e:search id="EV_TPL_SUBJECT" style="ime-mode:auto" name="EV_TPL_SUBJECT" value="${form.EV_TPL_SUBJECT }" width="${form_EV_TPL_SUBJECT_W}" maxLength="${form_EV_TPL_SUBJECT_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'doSearchTempl'}" disabled="${form_EV_TPL_SUBJECT_D}" readOnly="${form_EV_TPL_SUBJECT_RO}" required="${form_EV_TPL_SUBJECT_R}" />
					<e:inputHidden id="EXEC_EV_TPL_NUM" name="EXEC_EV_TPL_NUM" value="${form.EXEC_EV_TPL_NUM }"/>
				</e:field>
			</e:row>
            <e:row>
            	<%-- 평가기간 --%>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="START_DATE" toDate="CLOSE_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="CLOSE_DATE" fromDate="START_DATE" name="CLOSE_DATE" value="${form.CLOSE_DATE}" width="${inputTextDate}" datePicker="true" required="${form_CLOSE_DATE_R}" disabled="${form_CLOSE_DATE_D}" readOnly="${form_CLOSE_DATE_RO}" />
				</e:field>
            	<%-- 결과입력 --%>
				<e:label for="RESULT_ENTER_CD" title="${form_RESULT_ENTER_CD_N}"/>
				<e:field>
					<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${form.RESULT_ENTER_CD}" onChange="chgResult" options="${resultEnterCdOptions }" width="${form_RESULT_ENTER_CD_W}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" usePlaceHolder="false"/>
				</e:field>
			</e:row>
            <e:row>
            	<%-- 평가생성일 --%>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
				<e:field>
					<e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="false" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>
            	<%-- 평가생성자 --%>
				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
				<e:field>
					<e:inputText id="REG_USER_NM" style="ime-mode:auto" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${form_REG_USER_NM_W}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
				</e:field>
			</e:row>
            <e:row>
            	<%-- 평가요청일 --%>
				<e:label for="REQUEST_DATE" title="${form_REQUEST_DATE_N}"/>
				<e:field>
					<e:inputDate id="REQUEST_DATE" name="REQUEST_DATE" value="${form.REQUEST_DATE}" width="${inputTextDate}" datePicker="false" required="${form_REQUEST_DATE_R}" disabled="${form_REQUEST_DATE_D}" readOnly="${form_REQUEST_DATE_RO}" />
				</e:field>
            	<%-- 평가완료일 --%>
				<e:label for="COMPLETE_DATE" title="${form_COMPLETE_DATE_N}"/>
				<e:field>
					<e:inputDate id="COMPLETE_DATE" name="COMPLETE_DATE" value="${form.COMPLETE_DATE}" width="${inputTextDate}" datePicker="false" required="${form_COMPLETE_DATE_R}" disabled="${form_COMPLETE_DATE_D}" readOnly="${form_COMPLETE_DATE_RO}" />
				</e:field>
			</e:row>
            <e:row>
				<%--평가안내--%>
				<e:label for="RMK" title="${form_RMK_N}"/>
				<e:field colSpan="3">
					<e:richTextEditor id="RMK" name="RMK" width="100%" height="450px" required="${form_RMK_R }" readOnly="${form_RMK_RO }" disabled="${form_RMK_D }" value="${form.RMK}" useToolbar="${!param.detailView}" />
				</e:field>
			</e:row>
            <e:row>
				<%-- 첨부파일 --%>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
				<e:field colSpan="3">
			        <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM"  readOnly="${param.detailView ? true : false}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="EV" height="80px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
        </e:searchPanel>
        
		<e:panel id="leftPanel" height="fit" width="59%">
			<e:buttonBar align="right" title="협력업체">
				<div style="float: left; display: inline-block; margin-bottom: 2px;">
					<e:button id="doDownloadExcel" name="doDownloadExcel" label="${doDownloadExcel_N}" onClick="doDownloadExcel" disabled="${doDownloadExcel_D}" visible="${doDownloadExcel_V}"/>
				</div>
				<e:button id="doAddVendor" name="doAddVendor" label="${doAddVendor_N}" onClick="doAddVendor" disabled="${doAddVendor_D}" visible="${doAddVendor_V}"/>
				<e:button id="doDelVendor" name="doDelVendor" label="${doDelVendor_N}" onClick="doDelVendor" disabled="${doDelVendor_D}" visible="${doDelVendor_V}"/>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridVendor" name="gridVendor" height="400px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVendor.gridColData}"/>
		</e:panel>
		
		<e:panel width="1%">&nbsp;</e:panel>
	
		<e:panel id="righttPanel" height="fit" width="39%">
			<e:buttonBar align="right" title="평가자">
				<div style="float: left; display: inline-block; margin-bottom: 2px;">
					<e:button id="doDownloadExcelUser" name="doDownloadExcelUser" label="${doDownloadExcelUser_N}" onClick="doDownloadExcelUser" disabled="${doDownloadExcelUser_D}" visible="${doDownloadExcelUser_V}"/>
				</div>
				<e:button id="doAddUs" name="doAddUs" label="${doAddUs_N}" onClick="doAddUs" disabled="${doAddUs_D}" visible="${doAddUs_V}"/>
				<e:button id="doDelUs" name="doDelUs" label="${doDelUs_N}" onClick="doDelUs" disabled="${doDelUs_D}" visible="${doDelUs_V}"/>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" height="400px" readOnly="${param.detailView}" columnDef="${gridInfos.gridUs.gridColData}"/>
		</e:panel>
	</e:window>
</e:ui>