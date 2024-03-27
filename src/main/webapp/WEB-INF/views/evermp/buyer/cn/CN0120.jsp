<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    	var gridV 		= {};
        var gridItem 	= {};
        var delRows 	= [];
        var baseUrl 	= "/evermp/buyer/cn/CN0120/";
        var alertFlag	= true;
        var flagCount   = 0;

        function init() {
        	// title변경및 변경품의 값 변경
        	titleChangeBosom();
        	if('${form.GW_FLAG}'=='Y' && '${form.EXEC_TYPE_D }' != 'EXEC_CHAGE'){
        		//그룹웨어 전송했을시 구매신청 미리보기.
				$("#doPuSign").children('div').find(".e-button-text").text('구매신청 미리보기')


			//디테일로 열었고 그룹웨어 송신 안했으면 숨기고 그룹웨어 송신안했으면서 내부결재로 올렸을시
			}else if( ('${param.detailView}' == 'true' && '${form.GW_FLAG}'=='N')
					 || ('${form.GW_FLAG}'=='N' && ('${form.SIGN_STATUS}' =='E'))){
				//구매결재 미리보기 버튼숨김
				$("#doPuSign").hide();
			}

        	if('${form.GW_FLAG2}'=='Y' && '${form.EXEC_TYPE_D }' != 'EXEC_CHAGE' ){
        		$("#doLoSign").children('div').find(".e-button-text").text('본사신청 미리보기')

        	}else if(('${param.detailView}' == 'true' && '${form.GW_FLAG2}'=='N')){
				 $("#doLoSign").hide();
        	}
        	gridV = EVF.C("gridV");
        	gridItem = EVF.C("gridItem");

        	gridV.setProperty('panelVisible', ${panelVisible});
//        	gridV.setProperty('shrinkToFit', true);
        	gridItem.setProperty('panelVisible', ${panelVisible});
//        	gridItem.setProperty('shrinkToFit', true);

			gridItem.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
				if(colIdx === "PR_NUM") { // 주문번호
					if( value == '' ) return;
                    var param = {
                        callbackFunction: "",
                        "CPO_NO" : gridItem.getCellValue(rowId, "PR_NUM"),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
                }
				if(colId === 'QTA_NUM') {
					if( value == '' ) return;
					var url = "";
					if(gridItem.getCellValue(rowId, 'EXEC_CREATE_TYPE') == 'RFQ') { // 견적
						url = "QT0320";
					} else { // 입찰
						url = "BQ0320";
					}
					var param = {
						 QTA_NUM   : gridItem.getCellValue(rowId, 'QTA_NUM')
						,QTA_CNT   : gridItem.getCellValue(rowId, 'QTA_CNT')
						,VENDOR_CD : gridItem.getCellValue(rowId, 'VENDOR_CD')
						,popupFlag : true
						,detailView: true
					};
					everPopup.openPopupByScreenId(url, 1100, 800, param);
				}
            });

			gridItem.cellChangeEvent(function(rowId, celname, iRow, iCol, value, oldValue) {

				if (celname == 'TAX_CD') {
					locBuyerVendorSum();
					allChangeGrid('TAX_CD',value);
		            locBuyerVendorSum();

				}else if(celname=='SALES_UNIT_PRC'){
					var itemQt 		= Number(gridItem.getCellValue(rowId,'ITEM_QT'))
					var qtaUnitPrc	= gridItem.getCellValue(rowId,'QTA_UNIT_PRC')
					var cpoUnitPrc	= gridItem.getCellValue(rowId,'CPO_UNIT_PRICE')
					if(value==0 || value==null){
						alert('${CN0120_0005}');
						gridItem.setCellValue(rowId,'SALES_UNIT_PRC',oldValue)
						return;
					}
					gridItem.setCellValue(rowId, 'SALES_UNIT_AMT', value/cpoUnitPrc*100 );
					gridItem.setCellValue(rowId, 'SALES_UNIT_AMT', itemQt*value );
					gridItem.setCellValue(rowId, 'SALES_PROFIT_RATE', (value-qtaUnitPrc)/value*100)
					if(value!=oldValue){
						//금액이바뀌면
						deletePayInfo(); //지급조건 삭제.
					}
					locBuyerVendorSum();
				}else if(celname=='VALID_FROM_DATE'){
					allChangeGrid('VALID_FROM_DATE',value);
				}else if(celname=='VALID_TO_DATE'){
					allChangeGrid('VALID_TO_DATE',value);
				}
			});

			gridV.cellChangeEvent(function(rowId, celname, iRow, iCol, value, oldValue) {
				if (celname == 'VAT_TYPE') {
					locBuyerVendorSum();
				}
				else if(celname == 'INFO_FLAG' || celname == 'CT_PO_TYPE'){
					locBuyerVendorItemRequired();
				}
			});

            gridV.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'PAY_METHOD_NM') {
					var param = {
                        'PAY_TYPE'		: gridV.getCellValue(rowId, 'PAY_TYPE'),
                        'PAY_CNT'		: gridV.getCellValue(rowId, 'PAY_CNT'),
                        'PAY_RMK'		: gridV.getCellValue(rowId, 'PAY_RMK'),
                        'PAY_METHOD'	: gridV.getCellValue(rowId, 'PAY_METHOD'),
                        'PAY_METHOD_NM'	: gridV.getCellValue(rowId, 'PAY_METHOD_NM'),
                        'EXEC_AMT'		: gridV.getCellValue(rowId, 'EXEC_AMT'),
                        'PR_BUYER_CD'	: gridV.getCellValue(rowId, 'PR_BUYER_CD'),
                        'PAY_INFO'		: gridV.getCellValue(rowId, 'PAY_INFO'),
                        'CUR'			: gridV.getCellValue(rowId, 'CUR'),
                        'VAT_TYPE'		: gridV.getCellValue(rowId, 'VAT_TYPE'),
                        rowId 			: rowId ,
                        'detailView'	: ${param.detailView?true:false}
                   	};
 	               everPopup.openPopupByScreenId("CN0120P01", 1000, 430, param); //협력업체 상세page
                }
            });

        	gridV.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

        	gridItem.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

        	doSearchCnvd();
		}
        //일괄적용 그리드 적용
	    function allChangeGrid(colName,newValue){
			EVF.confirm('일괄적용하시겠습니까?',function(){
    			for(k=0;k<gridItem.getRowCount();k++) {
    	            gridItem.setCellValue(k,colName,newValue);
    			}
    		});
		}
        //타이틀변경 및 변경품의 값변경
		function titleChangeBosom(){
			var nmSplit = "${fullScreenName}".split('(');
			var nmChage = '${form.EXEC_TYPE_D }' == "EXEC_CHAGE" ? "변경품의서작성"+"("+nmSplit[1] :"${fullScreenName}"
			document.title =nmChage;
			$(".e-window-container-header-text").text(nmChage);
			if('${form.EXEC_TYPE_D }' == "EXEC_CHAGE"){
				EVF.C("EXEC_DATE").setReadOnly(false);
				EVF.V("EXEC_DATE",new Date());
			}
		}
     	//적용시작일 필수값여부
	  	function locBuyerVendorItemRequired( ) {

			var vIds   = gridV.getAllRowId();
			var iemIds = gridItem.getAllRowId();
		  	for(var i = 0; i < vIds.length; i++){
			  	for(var m = 0; m < iemIds.length; m++){
				  	if(gridV.getCellValue(vIds[i],'PR_BUYER_CD')+gridV.getCellValue(vIds[i],'VENDOR_CD')!= gridItem.getCellValue(iemIds[m],'PR_BUYER_CD')+gridItem.getCellValue(iemIds[m],'VENDOR_CD'))
					  	continue;

			  		gridItem.setCellValue(iemIds[m],"INFO_FLAG", gridV.getCellValue(vIds[i],'INFO_FLAG'));

			  		// 1, 0 : 공통 및 개별단가 생성, X : 단가 미생성
        		  	if(gridV.getCellValue(vIds[i],'INFO_FLAG') == "X"){
        		  		if(gridV.getCellValue(vIds[i],'CT_PO_TYPE') == "CT"){ // 계약서 작성
    						gridItem.setCellRequired(iemIds[m], "VALID_FROM_DATE", true);
    					    gridItem.setCellRequired(iemIds[m], "VALID_TO_DATE", true);
        		  		} else {
            			  	gridItem.setCellRequired(iemIds[m], "VALID_FROM_DATE", false);
    					  	gridItem.setCellRequired(iemIds[m], "VALID_TO_DATE", false);
        		  		}
				  	} else {
				  		// 공통단가 생성
				  		if(gridV.getCellValue(vIds[i],'INFO_FLAG') == "1"){
				  			gridItem.setCellValue(iemIds[m], "COMMON_FLAG", "1");
				  		} else {
				  			gridItem.setCellValue(iemIds[m], "COMMON_FLAG", "0");
				  		}
						gridItem.setCellRequired(iemIds[m], "VALID_FROM_DATE", true);
					    gridItem.setCellRequired(iemIds[m], "VALID_TO_DATE", true);
				  	}
        	  	}
		  	}
		}

		function locBuyerVendorSum() {
			var vdIds = gridV.getAllRowId();

        	for(var k =0; k < vdIds.length;k++){
				var vatType = gridV.getCellValue(vdIds[k],'VAT_TYPE');
				var vdKey = gridV.getCellValue(vdIds[k],'PR_BUYER_CD')+gridV.getCellValue(vdIds[k],'VENDOR_CD');
				gridV.setCellValue(vdIds[k],'EXEC_AMT' ,   locBuyerVendorItemSum(vdKey,vatType));

				if(gridV.getCellValue(vdIds[k],'EXEC_AMT')==0){
					gridV.delRow(vdIds[k]);
				}
				if(gridItem.getAllRowValue()==0){
					gridV.delAllRow();
				}
        	}

        	var rowValues 	= gridItem.getAllRowValue();
        	var totalAmt 	= 0;
        	var totalVatAmt = 0;
        	for(var k =0; k < rowValues.length;k++){

        		totalAmt    +=rowValues[k].SALES_UNIT_AMT
        	}
        	EVF.C('EXEC_AMT').setValue(totalAmt);
		}

		function locBuyerVendorItemSum(vdKey , vatType ) {
			var iemIds = gridItem.getAllRowId();
			var sumAmt = 0;
        	for(var m =0; m < iemIds.length;m++){

        		if (vdKey!= gridItem.getCellValue(iemIds[m],'PR_BUYER_CD')+gridItem.getCellValue(iemIds[m],'VENDOR_CD')  ) continue;

					sumAmt+= gridItem.getCellValue(iemIds[m],'QTA_UNIT_AMT');

        	}
        	return sumAmt;
		}

		function setPayInfoGrid(vat_amt,cont_guar_amt,adv_guar_amt,warr_guar_amt,rowId,pay_type,pay_cnt,pay_method_nm,pay_rmk,vat_type, supply_amt,payInfo   ) {
			gridV.setCellValue(rowId , 'PAY_TYPE'		, pay_type);
			gridV.setCellValue(rowId , 'PAY_CNT'		, pay_cnt);
			gridV.setCellValue(rowId , 'PAY_METHOD_NM'	, pay_method_nm);
// 			gridV.setCellValue(rowId , 'PAY_METHOD'		, pay_method);
			gridV.setCellValue(rowId , 'PAY_RMK'		, pay_rmk);
			gridV.setCellValue(rowId , 'VAT_TYPE'		, vat_type);
			gridV.setCellValue(rowId , 'EXEC_AMT'		, supply_amt);
			gridV.setCellValue(rowId , 'SUPPLY_AMT'		, supply_amt);
			gridV.setCellValue(rowId , 'PAY_INFO'		, payInfo);
			gridV.setCellValue(rowId , 'CONT_GUAR_AMT'	, cont_guar_amt);
			gridV.setCellValue(rowId , 'ADV_GUAR_AMT'	, adv_guar_amt);
			gridV.setCellValue(rowId , 'WARR_GUAR_AMT'	, warr_guar_amt);
			gridV.setCellValue(rowId , 'VAT_AMT'		, vat_amt);
		}

		function deletePayInfo() {

			EVF.V('PAY_TYPE'	 	, '');
			EVF.V('PAY_CNT'		 	, '');
			EVF.V('PAY_METHOD_NM'	, '');
// 			EVF.V('PAY_METHOD'		, '');
			EVF.V('PAY_RMK'			, '');
			EVF.V('VAT_TYPE'		, '');
			EVF.V('EXEC_AMT'		, '');
			EVF.V('SUPPLY_AMT'		, '');
			EVF.V('VAT_AMT'			, '');
			EVF.V('PAY_INFO'		, '');
// 			EVF.V('CONT_GUAR_AMT'	, '');
// 			EVF.V('ADV_GUAR_AMT'	 '');
// 			EVF.V('WARR_GUAR_AMT'	, '');
		}

        function doSearchCnvd() {
            var store = new EVF.Store();
            store.setGrid([gridV]);
            store.load(baseUrl + 'doSearchCnvd', function () {
            	var data = this.data.formData;
            	EVF.V("PAY_INFO",this.data.PAY_INFO[0].PAY_INFO_FORM)
            	gridV.checkAll(true);
            	doSearchCndt();
            });
        }

        function doSearchCndt() {
            var store = new EVF.Store();
            store.setGrid([gridItem]);
            store.load(baseUrl + 'doSearchCndt', function () {
            	gridItem.checkAll(true);
            	locBuyerVendorSum();
            	locBuyerVendorItemRequired();
            });
        }

        function doClose() {
     		if(opener != null) {
     			window.close();
     		} else {
     			new EVF.ModalWindow().close(null);
     		}
        }
		function validationCheck(){
			var store = new EVF.Store();
			gridV.checkAll(true);
			gridItem.checkAll(true);

			if(!store.validate()) {	return;	}
            if(!gridV.validate().flag) { return EVF.alert(gridV.validate().msg); }
            if(!gridItem.validate().flag) { return EVF.alert(gridItem.validate().msg); }
            var rowIds = gridV.getSelRowId();
		    for(var i in rowIds){
				if( gridV.getCellValue(rowIds[i],'PAY_METHOD_NM') == '' ) {
					alert('${CN0120_0003}');
					return;
				}
		    }

			return true ;
		}
		function doSave() {
			if(!validationCheck()) return;


			EVF.V("SIGN_STATUS", "T");
		    EVF.confirm("${msg.M0021}", function(){
		    	goSaveCn();
			});
		}

		function doSign(){
			/*2022-09-20 내부결재로 변경   */
// 			var store = new EVF.Store();
// 			gridV.checkAll(true);
// 			gridItem.checkAll(true);

// 			if(!store.validate()) return;
// 			if(!gridV.validate().flag) { return EVF.alert(gridV.validate().msg); }
//             if(!gridItem.validate().flag) { return EVF.alert(gridItem.validate().msg); }

// 			store.doFileUpload(function() {
// 				store.setGrid([gridV, gridItem]);
// 				store.getGridData(gridV,'all');
// 				store.getGridData(gridItem,'all');
// 				store.load(baseUrl + "doSave", function(){
// 	            	opener.doSearch();
// 	    			param = {
// 	    					FORM_ALIAS : 'SRM_APP_003',
// 	    					SUBJECT: EVF.V("EXEC_SUBJECT"),
// 	    					LEGACY_KEY: EVF.V("EXEC_NUM")
// 	    				};
// 	    			everPopup.openPopupByScreenId('gwView', 1300, 900, param);
// 				});
// 			});
// 			return;

			if(!validationCheck()) return;

            if (!confirm("${msg.M0100}")) return;
			EVF.V("SIGN_STATUS", "P");

			param = {
				subject			: EVF.V("EXEC_SUBJECT"),
				docType			: "EXEP",
				signStatus		: "P",
				screenId		: "CN0120",
				approvalType	: 'APPROVAL',
				oldApprovalFlag	: EVF.V("SIGN_STATUS"),
				attFileNum		: "",
				docNum			: EVF.V("EXEC_NUM"),
				appDocNum		: EVF.V("APP_DOC_NUM"),
				callBackFunction: "goSaveCn"
			};
			everPopup.openApprovalRequestIIPopup(param);
		}

		//구매품의 결재신청
		function doPuSign(){
			if( flagCount== 0 && '${form.GW_FLAG}'=='N'){
				if(!validationCheck()){
					localStorage.setItem('flag', 'true');
					flagCount++;
					return;
				}
			}
			if(localStorage.getItem('flag') == 'true' && flagCount>0){
				return alert("저장후 진행 바랍니댜.");
			}
            openPopupLogic();
		}

		function openPopupLogic(){
			//구매품의결재신청로직
			//1이상이면 변경품의
			var gubn       = EVF.V("EXEC_CNT") >1 ? "CP" : "P";
			var screenName = EVF.V("EXEC_CNT") >1 ? "변경구매품의서 (CN0130P01)" : "구매품의서 (CN0130P01)";
			let param = {
				'EXEC_NUM' 	   : EVF.V('EXEC_NUM'),
				'EXEC_CNT' 	   : EVF.V('EXEC_CNT'),
				'SUBJECT' 	   : EVF.V('EXEC_SUBJECT'),
				'PROGRESS_CD'  : EVF.V('PROGRESS_CD'),
				'APP_DOC_NUM'  : EVF.V('APP_DOC_NUM'),
				'APP_DOC_CNT'  : EVF.V('APP_DOC_CNT'),
				'APP_DOC_NUM2' : EVF.V('APP_DOC_NUM2'),
				'APP_DOC_CNT2' : EVF.V('APP_DOC_CNT2'),
				'SIGN_STATUS'  : EVF.V('SIGN_STATUS'),
				'SIGN_STATUS2' : EVF.V('SIGN_STATUS2'),
				'screenName'   : screenName,
				'pageName'     : 'CN',
				'EXEC_GB'      : gubn
			};
			everPopup.openPopupByScreenId("CN0130P01", 1300, 900, param);
		}
		//본사품의 결재신청
		function doLoSign(){
			//1이상이면 변경품의
			var gubn = EVF.V("EXEC_CNT") >1 ? "CH" : "H";
			var screenName = EVF.V("EXEC_CNT") >1 ? "변경본사품의서 (CN0130P01)" : "본사품의서 (CN0130P01)";
			param = {
				'EXEC_NUM' 	   : EVF.V('EXEC_NUM'),
				'EXEC_CNT' 	   : EVF.V('EXEC_CNT'),
				'SUBJECT' 	   : EVF.V('EXEC_SUBJECT'),
				'PROGRESS_CD'  : EVF.V('PROGRESS_CD'),
				'APP_DOC_NUM'  : EVF.V('APP_DOC_NUM'),
				'APP_DOC_CNT'  : EVF.V('APP_DOC_CNT'),
				'APP_DOC_NUM2' : EVF.V('APP_DOC_NUM2'),
				'APP_DOC_CNT2' : EVF.V('APP_DOC_CNT2'),
				'SIGN_STATUS'  : EVF.V('SIGN_STATUS'),
				'SIGN_STATUS2' : EVF.V('SIGN_STATUS2'),
				'screenName'   : screenName,
				'pageName'     : 'CN',
				'EXEC_GB'      : gubn
			};

			everPopup.openPopupByScreenId("CN0130P01", 1300, 900, param);
		}
		//행삭제
		function doGridDelete(){
			var payFlag=false;

			if(gridItem.getSelRowCount() === 0) { return EVF.alert("${msg.M0004}"); }

			for(var i = gridItem.getRowCount() - 1; i >= 0; i--) {
				if(gridItem.isChecked(i)) {

					gridItem.delRow(i);//로우삭제
				}
			}

			for(var i = gridV.getRowCount() - 1; i >= 0; i--) {
				var vdKey = gridV.getCellValue(i,'PR_BUYER_CD')+gridV.getCellValue(i,'VENDOR_CD')


				if(gridV.getCellValue(i, "PAY_METHOD_NM") !='' && gridV.getCellValue(i, "PAY_METHOD_NM") !=null){payFlag=true;}

			}

			if(EVF.V("PAY_METHOD_NM") !='' && EVF.V("PAY_METHOD_NM") !=null){payFlag=true;}

			if(payFlag){
				deletePayInfo(); //지급조건 삭제.
			}

			locBuyerVendorSum();//금액 재계산
		}

		function goSaveCn(formData, gridData, attachData){

			EVF.V("approvalFormData", formData);
			EVF.V("approvalGridData", gridData);
			//고객사 정보 그리드 인설트
			var custParam={
				 'EXEC_NUM'				: EVF.V('EXEC_NUM'),
				 'EXEC_CNT'				: EVF.V('EXEC_CNT'),
				 'PAY_TYPE'				: EVF.V('PAY_TYPE'),
				 'PAY_CNT'				: EVF.V('PAY_CNT'),
                 'PAY_RMK'				: EVF.V('PAY_RMK'),
                 'PAY_METHOD'			: EVF.V('PAY_METHOD'),
                 'PAY_METHOD_NM'		: EVF.V('PAY_METHOD_NM'),
                 'EXEC_AMT'				: EVF.V('EXEC_AMT'),
                 'PR_BUYER_CD'			: EVF.V('PR_BUYER_CD'),
                 'PAY_INFO'				: EVF.V('PAY_INFO'),
                 'CUR'					: EVF.V('CUR'),
                 'VAT_TYPE'				: EVF.V('VAT_TYPE'),
                 'VAT_AMT'				: EVF.V('VAT_AMT'),
                 'SUPPLY_AMT' 			: EVF.V('EXEC_AMT'),
                 'CONT_GUAR_PERCENT'	: EVF.V('CONT_GUAR_PERCENT'),
                 'ADV_GUAR_PERCENT' 	: EVF.V('ADV_GUAR_PERCENT'),
                 'WARR_GUAR_PERCENT' 	: EVF.V('WARR_GUAR_PERCENT'),
                 'WARR_GUAR_QT'  		: EVF.V('WARR_GUAR_QT'),
                 'CT_PO_TYPE'           : EVF.V('CT_PO_TYPE'),
                 'DELY_DATE'            : EVF.V('DELY_DATE'),
                 'VENDOR_CD'			: "${form.PR_BUYER_CD}",
                 'APAR_TYPE'			:'S',
                 'PR_TYPE'           	: EVF.V('PR_TYPE'),
                 'RMKS'					: EVF.V('SEL_CAUSE')
			}
			gridV.addRow(custParam)
			var store = new EVF.Store();
			store.doFileUpload(function() {
				store.setGrid([gridV, gridItem]);
				store.getGridData(gridV,'all');
				store.getGridData(gridItem,'all');
				store.load(baseUrl + "doSave", function(){
	            	opener.doSearch();
	            	<c:if test="${form.EXEC_TYPE_D=='EXEC_CHAGE'}">
		            	if(opener != null) {
		    				opener.close();
		    			}
					</c:if>
	                 var execNum = this.getParameter('EXEC_NUM');
	                 var execCnt = this.getParameter('EXEC_CNT');
	                 location.href = baseUrl + "view.so?EXEC_NUM=" + execNum+'&EXEC_CNT='+execCnt+'&popupFlag=true';
					//doClose();
				});
			});
		}


        function doDelete() {
            EVF.confirm("${msg.M0013}", function(){
            	var store = new EVF.Store();
	            store.load(baseUrl + '/doDelete', function(){
		            EVF.alert(this.getResponseMessage(),function(){
		            	opener.doSearch();
			            doClose();

		            });
	            });
            });
        }
		function selectPayMethod(){
			var param = {
				 'PAY_TYPE'		: EVF.V('PAY_TYPE'),
				 'PAY_CNT'		: EVF.V('PAY_CNT'),
                 'PAY_RMK'		: EVF.V('PAY_RMK'),
                 'PAY_METHOD'	: EVF.V('PAY_METHOD'),
                 'PAY_METHOD_NM': EVF.V('PAY_METHOD_NM'),
                 'EXEC_AMT'		: EVF.V('EXEC_AMT'),
                 'PR_BUYER_CD'	: EVF.V('PR_BUYER_CD'),
                 'PAY_INFO'		: EVF.V('PAY_INFO'),
                 'CUR'			: EVF.V('CUR'),
                 'VAT_TYPE'		: EVF.V('VAT_TYPE'),
                 'SUPPLY_AMT' 	: EVF.V('EXEC_AMT'),
                 'gubn'         : "formFlag",
                 'detailView'	: ${param.detailView ? true : false}
            };
        	everPopup.openPopupByScreenId("CN0120P01", 1000, 430, param); //협력업체 상세page

		}
		function setPayInfoForm(vat_amt,cont_guar_amt,adv_guar_amt,warr_guar_amt,rowId,pay_type,pay_cnt,pay_method_nm,pay_rmk,vat_type, supply_amt,payInfo   ) {
			EVF.V('PAY_TYPE'	 	, pay_type);
			EVF.V('PAY_CNT'		 	, pay_cnt);
			EVF.V('PAY_METHOD_NM'	, pay_method_nm);
// 			EVF.V('PAY_METHOD'		, pay_method);
			EVF.V('PAY_RMK'			, pay_rmk);
			EVF.V('VAT_TYPE'		, vat_type);
			EVF.V('EXEC_AMT'		, supply_amt);
			EVF.V('SUPPLY_AMT'		, supply_amt);
			EVF.V('VAT_AMT'			, vat_amt);
			EVF.V('PAY_INFO'		, payInfo);
// 			EVF.V('CONT_GUAR_AMT'	, cont_guar_amt);
// 			EVF.V('ADV_GUAR_AMT'	 adv_guar_amt);
// 			EVF.V('WARR_GUAR_AMT'	, warr_guar_amt);
		}
		//프로시저 결과 테스트
		function doTest(){
			var store = new EVF.Store();
            store.load(baseUrl + '/doTest', function(){
	            EVF.alert(this.getResponseMessage(),function(){
	            	opener.doSearch();
		            doClose();

	            });
            });
		}
		function openerFn(){
			opener.doSearch();
			doClose();
		}

		function doDetail(){

			var qtaList = [];
			var rowIds = gridItem.getSelRowId();
			for( var i in rowIds ) {

				qtaList.push(
						{
							'QTA_NUM': gridItem.getCellValue(rowIds[i], 'QTA_NUM')
						}
				);
			}

			var param = {
				'EXEC_NUM': EVF.V('EXEC_NUM'),
				'EXEC_CNT': EVF.V('EXEC_CNT'),
				QTA_NUM_LIST : JSON.stringify(qtaList)
			};

			everPopup.openPopupByScreenId("CN0120P03", 1200, 500, param);
		}
		function doComparisonTable(){

			var qtaList = [];
			var arrDup = gridItem.getAllRowValue();
			const arrUnique = arrDup.filter((character, idx, arr)=>{
				return arr.findIndex((item) => item.RFX_NUM === character.RFX_NUM && item.RFX_CNT === character.RFX_CNT) === idx

				});
// 			for( var i in rowIds ) {

// 				qtaList.push(
// 						{
// 							'EXEC_NUM': EVF.V('EXEC_NUM'),
// 							'QTA_NUM': gridItem.getCellValue(rowIds[i], 'QTA_NUM')
// 						}
// 				);
// 			}

			var param = {
				QTA_NUM_LIST : JSON.stringify(arrUnique)
			};

			everPopup.openPopupByScreenId("CN0120P04", 1200, 600, param);
		}

    </script>

    <e:window id="CN0120" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:buttonBar title="기본정보" id="buttonBar" align="right" width="100%">
        	<!-- 임시저장 -->
			<c:if test="${(empty form.PROGRESS_CD || form.PROGRESS_CD == '3100' ) && (form.GW_FLAG == 'N' || form.GW_FLAG == null) || form.EXEC_TYPE_D == 'EXEC_CHAGE'}">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			</c:if>
			<!-- DGNS 구매품의 -->
			<c:if test="${not empty form.EXEC_NUM}">
				<c:if test="${(not empty form.IF_SIGN_FLAG || form.PROGRESS_CD == '3100') && form.EXEC_TYPE_D != 'EXEC_CHAGE'}">
					<e:button id="doPuSign" name="doPuSign" label="${doPuSign_N}" onClick="doPuSign" disabled="${doPuSign_D}" visible="${doPuSign_V}"/>
				</c:if>
				<!-- DGNS 본사품의 변경품의  -->
				<c:if test="${ form.EXEC_TYPE_D != 'EXEC_CHAGE'}">
					<e:button id="doLoSign" name="doLoSign" label="${doLoSign_N}" onClick="doLoSign" disabled="${doLoSign_D}" visible="${doLoSign_V}"/>
				</c:if>
			</c:if>
			<!-- MRO 내부결재 -->
			<c:if test="${not empty form.EXEC_NUM}">
				<c:if test="${form.PROGRESS_CD == '3100' && form.GW_FLAG == 'N'}">
					<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
				</c:if>
			</c:if>
			<!-- 품의서 삭제 : 임시저장이고 G/W 결재상신 이전 -->
			<c:if test="${form.PROGRESS_CD == '3100' && form.GW_FLAG == 'N' }">
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			</c:if>
			<!-- 닫기 -->
			<%--
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
			--%>
        </e:buttonBar>

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
        	<e:inputHidden id="QTA_NUM_LIST" name="QTA_NUM_LIST" value="${form.QTA_NUM_LIST}"/>
        	<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.SIGN_STATUS}"/>
        	<e:inputHidden id="SIGN_STATUS2" name="SIGN_STATUS2" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.SIGN_STATUS2}"/>
        	<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.APP_DOC_NUM}"/>
        	<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.APP_DOC_CNT}"/>
        	<e:inputHidden id="APP_DOC_NUM2" name="APP_DOC_NUM2" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.APP_DOC_NUM2}"/>
        	<e:inputHidden id="APP_DOC_CNT2" name="APP_DOC_CNT2" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.APP_DOC_CNT2}"/>
        	<e:inputHidden id="approvalFormData" name="approvalFormData" value=""/>
        	<e:inputHidden id="approvalGridData" name="approvalGridData" value=""/>
        	<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}"/>
        	<e:inputHidden id="PAY_TYPE" name="PAY_TYPE" value="${form.PAY_TYPE}"/>
        	<e:inputHidden id="PAY_CNT" name="PAY_CNT" value="${form.PAY_CNT}"/>
        	<e:inputHidden id="PAY_RMK" name="PAY_RMK" value="${form.PAY_RMK}"/>
        	<e:inputHidden id="PAY_METHOD" name="PAY_METHOD" value="${form.PAY_METHOD}"/>
        	<e:inputHidden id="PAY_INFO" name="PAY_INFO" value="${form.PAY_INFO}"/>
        	<e:inputHidden id="CUR" name="CUR" value="KRW"/>
        	<e:inputHidden id="VAT_TYPE" name="VAT_TYPE" value="${form.VAT_TYPE}"/>
        	<e:inputHidden id="VAT_AMT" name="VAT_AMT" value="${form.VAT_AMT}"/>
        	<e:inputHidden id="SUPPLY_AMT" name="SUPPLY_AMT" value="${form.SUPPLY_AMT}"/>
        	<e:inputHidden id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}"/>
        	<e:inputHidden id="EXEC_TYPE_D" name="EXEC_TYPE_D" value="${form.EXEC_TYPE_D}"/>

            <e:row>
				<%--품의번호--%>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />

				<e:field>
					<e:inputText id="EXEC_NUM" name="EXEC_NUM" value="${form.EXEC_NUM}" width="${form_EXEC_NUM_W}" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}" />
					<e:text>&nbsp;/&nbsp;</e:text>
					<e:inputText id="EXEC_CNT" name="EXEC_CNT" value="${form.EXEC_CNT}" width="${form_EXEC_CNT_W}" maxLength="${form_EXEC_CNT_M}" disabled="${form_EXEC_CNT_D}" readOnly="${form_EXEC_CNT_RO}" required="${form_EXEC_CNT_R}" />
				</e:field>
				<%--품의일자--%>
				<e:label for="EXEC_DATE" title="${form_EXEC_DATE_N}"/>
				<e:field>
					<e:inputDate id="EXEC_DATE" name="EXEC_DATE" value="${form.EXEC_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_EXEC_DATE_R}" disabled="${form_EXEC_DATE_D}" readOnly="${form_EXEC_DATE_RO}" />
				</e:field>
				<%--품의금액--%>
				<e:label for="EXEC_AMT" title="${form_EXEC_AMT_N}"/>
				<e:field>
					<e:inputNumber id="EXEC_AMT" name="EXEC_AMT" value="${form.EXEC_AMT}" width="${form_EXEC_AMT_W}" maxValue="${form_EXEC_AMT_M}" decimalPlace="${form_EXEC_AMT_NF}" disabled="${form_EXEC_AMT_D}" readOnly="${form_EXEC_AMT_RO}" required="${form_EXEC_AMT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--품의명--%>
				<e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="${form.EXEC_SUBJECT}" width="100%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
				</e:field>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? form.CH_CTRL_USER_ID : form.CTRL_USER_ID}" width="40%" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${param.detailView ? 'everCommon.blank' : ''}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
					<e:inputText id="CTRL_USER_NM" name="CTRL_USER_NM" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? form.CH_CTRL_USER_NM : form.CTRL_USER_NM}" width="60%" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
				</e:field>
            </e:row>
			<e:row>
             	<%--고객사/사업장--%>
            	<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}" />
				<e:field>
					<e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${form.PR_BUYER_CD}"/>
					<e:inputHidden id="PR_PLANT_CD" name="PR_PLANT_CD" value="${form.PR_PLANT_CD}"/>
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" value="${form.PR_BUYER_NM}" width="50%" maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
					<e:inputText id="PR_PLANT_NM" name="PR_PLANT_NM" value="${form.PR_PLANT_NM}" width="50%" maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--부서/요청자--%>
				<e:label for="REQ_DEPT_INFO" title="${form_REQ_DEPT_INFO_N}" />
				<e:field>
					<e:inputText id="REQ_DEPT_INFO" name="REQ_DEPT_INFO" value="${form.REQ_DEPT_INFO}" width="50%" maxLength="${form_REQ_DEPT_INFO_M}" disabled="${form_REQ_DEPT_INFO_D}" readOnly="${form_REQ_DEPT_INFO_RO}" required="${form_REQ_DEPT_INFO_R}" />
					<e:inputText id="REQ_USER_NM" name="REQ_USER_NM" value="${form.REQ_USER_NM}" width="50%" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
					<e:inputHidden id="REQ_USER_ID" name="REQ_USER_ID" value="${form.REQ_USER_ID}"/>

				</e:field>
				<%--시행품의번호--%>
				<e:label for="ETC_RMK" title="${form_ETC_RMK_N}" />
				<e:field>
					<e:inputText id="ETC_RMK" name="ETC_RMK" value="${form.ETC_RMK}" width="${form_ETC_RMK_W}" maxLength="${form_ETC_RMK_M}" disabled="${form_ETC_RMK_D}" readOnly="${form_ETC_RMK_RO}" required="${form_ETC_RMK_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--구매품의비고--%>
                <e:label for="PR_RMK" title="${form_PR_RMK_N}" />
				<e:field>
					<e:textArea id="PR_RMK" name="PR_RMK" value="${form.PR_RMK}" height="50px" width="100%" maxLength="${form_PR_RMK_M}" disabled="${form_PR_RMK_D}" readOnly="${form_PR_RMK_RO}" required="${form_PR_RMK_R}" />
				</e:field>
				<%--본사품의비고--%>
				<e:label for="EX_RMK" title="${form_EX_RMK_N}" />
				<e:field>
					<e:textArea id="EX_RMK" name="EX_RMK" value="${form.EX_RMK}" height="50px" width="100%" maxLength="${form_EX_RMK_M}" disabled="${form_EX_RMK_D}" readOnly="${form_EX_RMK_RO}" required="${form_EX_RMK_R}" />
				</e:field>
				<%--선정사유--%>
				<e:label for="SEL_CAUSE" title="${form_SEL_CAUSE_N}"/>
				<e:field>
					<e:textArea id="SEL_CAUSE" name="SEL_CAUSE" value="${form.SEL_CAUSE}" height="5px" width="100%" maxLength="${form_SEL_CAUSE_M}" disabled="${form_SEL_CAUSE_D}" readOnly="${form_SEL_CAUSE_RO}" required="${form_SEL_CAUSE_R}" />
				</e:field>


            </e:row>

        </e:searchPanel>
		<e:searchPanel id="form1" title="매출정보" columnCount="3" labelWidth="${labelWidth}" onEnter="" useTitleBar="true">
		 			  <e:row>
            	<%--선급보증율--%>
            	<e:label for="CONT_GUAR_PERCENT" title="${form_CONT_GUAR_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="CONT_GUAR_PERCENT" name="CONT_GUAR_PERCENT" value="${form.CONT_GUAR_PERCENT == null ? 0 : form.CONT_GUAR_PERCENT}" width="${form_CONT_GUAR_PERCENT_W}" maxValue="${form_CONT_GUAR_PERCENT_M}" decimalPlace="${form_CONT_GUAR_PERCENT_NF}" disabled="${form_CONT_GUAR_PERCENT_D}" readOnly="${form_CONT_GUAR_PERCENT_RO}" required="${form_CONT_GUAR_PERCENT_R}" />
				</e:field>

				<%--이행보증율--%>
            	<e:label for="ADV_GUAR_PERCENT" title="${form_ADV_GUAR_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="ADV_GUAR_PERCENT" name="ADV_GUAR_PERCENT" value="${form.ADV_GUAR_PERCENT == null ? 0 : form.ADV_GUAR_PERCENT}" width="${form_ADV_GUAR_PERCENT_W}" maxValue="${form_ADV_GUAR_PERCENT_M}" decimalPlace="${form_ADV_GUAR_PERCENT_NF}" disabled="${form_ADV_GUAR_PERCENT_D}" readOnly="${form_ADV_GUAR_PERCENT_RO}" required="${form_ADV_GUAR_PERCENT_R}" />
				</e:field>
				<%--하자보증율--%>
            	<e:label for="WARR_GUAR_PERCENT" title="${form_WARR_GUAR_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="WARR_GUAR_PERCENT" name="WARR_GUAR_PERCENT" value="${form.WARR_GUAR_PERCENT == null ? 0 : form.WARR_GUAR_PERCENT}" width="${form_WARR_GUAR_PERCENT_W}" maxValue="${form_WARR_GUAR_PERCENT_M}" decimalPlace="${form_WARR_GUAR_PERCENT_NF}" disabled="${form_WARR_GUAR_PERCENT_D}" readOnly="${form_WARR_GUAR_PERCENT_RO}" required="${form_WARR_GUAR_PERCENT_R}" />
				</e:field>
            </e:row>
            <e:row>
            	<%--하자기간--%>
				<e:label for="WARR_GUAR_QT" title="${form_WARR_GUAR_QT_N}"/>
				<e:field>
					<e:inputNumber id="WARR_GUAR_QT" name="WARR_GUAR_QT" value="${form.WARR_GUAR_QT}" width="${form_WARR_GUAR_QT_W}" maxValue="${form_WARR_GUAR_QT_M}" decimalPlace="${form_WARR_GUAR_QT_NF}" disabled="${form_WARR_GUAR_QT_D}" readOnly="${form_WARR_GUAR_QT_RO}" required="${form_WARR_GUAR_QT_R}" />
				</e:field>
				<%--지급조건--%>
				<e:label for="PAY_METHOD_NM" title="${form_PAY_METHOD_NM_N}"/>
				<e:field>
					<e:search id="PAY_METHOD_NM" name="PAY_METHOD_NM" value="${form.EXEC_TYPE_D=='EXEC_CHAGE' ? '' : form.PAY_METHOD_NM}" width="${form_PAY_METHOD_NM_W}" maxLength="${form_PAY_METHOD_NM_M}" onIconClick="selectPayMethod" disabled="${form_PAY_METHOD_NM_D}" readOnly="${form_PAY_METHOD_NM_RO}" required="${form_PAY_METHOD_NM_R}" />
				</e:field>
				<%--계약구분--%>
				<e:label for="CT_PO_TYPE" title="${form_CT_PO_TYPE_N}"/>
				<e:field>
					<e:select id="CT_PO_TYPE" name="CT_PO_TYPE" value="${form.CT_PO_TYPE}" options="${ctPoTypeOptions}" width="${form_CT_PO_TYPE_W}" disabled="${form_CT_PO_TYPE_D}" readOnly="${form_CT_PO_TYPE_RO}" required="${form_CT_PO_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
            	<%--예상집행일--%>
            	<e:label for="BUDGET_EXE_DATE" title="${form_BUDGET_EXE_DATE_N}"/>
				<e:field>
					<e:inputDate id="BUDGET_EXE_DATE" name="BUDGET_EXE_DATE" value="${form.BUDGET_EXE_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_BUDGET_EXE_DATE_R}" disabled="${form_BUDGET_EXE_DATE_D}" readOnly="${form_BUDGET_EXE_DATE_RO}" />
				</e:field>
            	<%--납품일--%>
            	<e:label for="DELY_DATE" title="${form_DELY_DATE_N}"/>
				<e:field>
					<e:inputDate id="DELY_DATE" name="DELY_DATE" value="${form.DELY_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_DELY_DATE_R}" disabled="${form_DELY_DATE_D}" readOnly="${form_DELY_DATE_RO}" />
				</e:field>

            	<%--원가절감유형--%>
				<e:label for="COST_REDUCE_TYPE" title="${form_COST_REDUCE_TYPE_N}"/>
				<e:field>
					<e:select id="COST_REDUCE_TYPE" name="COST_REDUCE_TYPE" value="${form.COST_REDUCE_TYPE}" options="${costReduceTypeOptions}" width="${form_COST_REDUCE_TYPE_W}" disabled="${form_COST_REDUCE_TYPE_D}" readOnly="${form_COST_REDUCE_TYPE_RO}" required="${form_COST_REDUCE_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
            	<%--대표품목명--%>
            	<e:label for="REP_ITEM_NM" title="${form_REP_ITEM_NM_N}" />
				<e:field colSpan="5">
					<e:inputText id="REP_ITEM_NM" name="REP_ITEM_NM" value="${form.REP_ITEM_NM}" width="${form_REP_ITEM_NM_W}" maxLength="${form_REP_ITEM_NM_M}" disabled="${form_REP_ITEM_NM_D}" readOnly="${form_REP_ITEM_NM_RO}" required="${form_REP_ITEM_NM_R}" />
				</e:field>
            </e:row>
		</e:searchPanel>
		<e:title title="매입정보"/>
        <e:gridPanel gridType="${_gridType}" id="gridV" name="gridV" width="100%" height="140px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>


		<e:buttonBar id="buttonBar1" title="품목정보" align="right" width="100%">
			<c:if test="${form.EXEC_TYPE_D=='EXEC_CHAGE'}">
				<e:text style="font-weight: bold; color :red;">●&nbsp;구매요청번호가  없을시 발주생성 되지 않습니다.  &nbsp;&nbsp; </e:text>
				<e:button id="doGridDelete" name="doGridDelete" label="${doGridDelete_N}" onClick="doGridDelete" disabled="${doGridDelete_D}" visible="${doGridDelete_V}"/>
			</c:if>
				<e:button id="doDetail" name="doDetail" label="${doDetail_N}" onClick="doDetail" disabled="${doDetail_D}" visible="${doDetail_V}"/>
				<e:button id="doComparisonTable" name="doComparisonTable" label="${doComparisonTable_N}" onClick="doComparisonTable" disabled="${doComparisonTable_D}" visible="${doComparisonTable_V}"/>
		</e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="gridItem" name="gridItem" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
