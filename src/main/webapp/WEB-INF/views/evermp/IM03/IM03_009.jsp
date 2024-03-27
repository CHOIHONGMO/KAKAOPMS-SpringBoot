<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/IM03/IM0301/";
        var gridct;
        var gridat;
        var gridType;
        var SelectRowIdCt=0;
        var SelectRowIdPr=0;
        var ctSelect=0;
        var APmultiYn;
        var signStatus;
        var addRowYn = 'N';

        function init() {

        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-ATT_FILE_NUM').css('display','none');
        		$('#upload-button-IMG_ATT_FILE_NUM').css('display','none');
        		$('#upload-button-ITEM_DETAIL_FILE_NUM').css('display','none');
        	}

            gridType ="ct";
            gridct = EVF.C("gridct");
            gridat = EVF.C("gridat");

            if ('${formData.ITEM_INFO_CHANGING}' == 'Y') {
            	EVF.C("Approve").setDisabled(true);
            	EVF.C("Approve").setLabel('단가변경중');
            }

            if( '${param.detailView}' != 'true' ) {
                gridct.cellClickEvent(function(rowId, colId, value) {
                    SelectRowIdCt = rowId;

                    if (colId == "APPLY_PLANT_NM") {

	                        if(gridct.getCellValue(rowId, 'CONT_NO') == '') {

	                    	if(gridct.getCellValue(rowId, 'APPLY_COM')=='') return alert('고객사를 선택해주세요.');
	    	                var param = {
	                            callBackFunction: "_setPlant",
	                            rowid: rowId,
	                            custCd: gridct.getCellValue(rowId, 'APPLY_COM')
	                        };
	                        everPopup.openCommonPopup(param, 'SP0901');

                        }
                    }
                    if(colId == 'VENDOR_NM') {
                        if(gridct.getCellValue(rowId, 'CONT_NO') == '') {
	                        var param = {
	                            callBackFunction : "gridct_selectVendorCd"
	                        };
	                        everPopup.openCommonPopup(param, 'SP0063');
                        }
                    }else if(colId == 'CONT_REGION_NM') {

                        var param = {
                            rowId: rowId,
                            callBackFunction: 'CT_setRegionNm',
                            'REGION_CD': gridct.getCellValue(rowId, 'CONT_REGION_CD'),
                            'detailView': false
                        };
                        everPopup.im03_012open(param);

                    }else if(colId == 'APPLY_NM') {
                        if(gridct.getCellValue(rowId, 'CONT_NO') == '') {
                            APmultiYn="N";
                            var param = {
                                callBackFunction : "CT_setApplyNmROW"
                            };
                            everPopup.openCommonPopup(param, 'SP0902');
                        }
                    }else if(colId == 'ATT_FILE_CNT') {
                        var param = {
                            attFileNum: gridct.getCellValue(rowId, 'ATTACH_FILE_NUM2'),
                            rowId: rowId,
                            callBackFunction: 'CT_setAttFile',
                            havePermission: true,
                            bizType: 'IT',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

                    }else if(colId == 'LEAD_TIME_RMK_YN') {

                        var param = {
                            title: "${IM03_009_007}",
                            message: gridct.getCellValue(rowId, 'LEAD_TIME_RMK'),
                            callbackFunction: 'CT_setLeadTimeRmk',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_input/view';
                        everPopup.openModalPopup(url, 500, 320, param);

                    } else if(colId == 'CHANGE_REASON_YN') {
                        var param = {
                            title: "${IM03_009_021}",
                            message: gridct.getCellValue(rowId, 'CHANGE_REASON'),
                            callbackFunction: 'CR_setChangeReasonRmk',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_input/view';
                        everPopup.openWindowPopup(url, 500, 320, param);
                    }

                });

                gridct.cellChangeEvent(function(rowId, colId, iRow, iCol, newVal, oldVal) {
                    SelectRowIdCt = rowId;
                    if(addRowYn == 'Y' && gridct.getCellValue(rowId,'CONT_NO') != '' ) {
                    	alert('${IM03_009_0002}');
                    	gridct.setCellValue(rowId, colId, oldVal);
                    	gridct.checkRow( rowId, false );
                    	return;
                    }


                    if(colId == 'VALID_FROM_DATE'|| colId == 'VALID_TO_DATE') {
                        if(gridct.getCellValue(rowId, 'VALID_FROM_DATE')!="" && gridct.getCellValue(rowId, 'VALID_TO_DATE')!=""){
                            var today = '${today}';
                            if (everDate.compareDateWithSign(today, '>=', gridct.getCellValue(rowId, 'VALID_FROM_DATE'), '${ses.dateFormat }', '${gridDateFormat}')) {
                                if (everDate.compareDateWithSign(today, '<=', gridct.getCellValue(rowId, 'VALID_TO_DATE'), '${ses.dateFormat }', '${gridDateFormat}')) {
                                    gridct.setCellValue(rowId, "CONT_STATUS", "1");
                                }else{
                                    gridct.setCellValue(rowId, "CONT_STATUS", "0");
                                }
                            }else{
                                gridct.setCellValue(rowId, "CONT_STATUS", "0");
                            }
                        }


                        if(gridct.getCellValue(rowId, 'PREV_VALID_FROM_DATE')!="" && gridct.getCellValue(rowId, 'VALID_FROM_DATE')!=""){
                            if(gridct.getCellValue(rowId, 'PREV_VALID_FROM_DATE')!=gridct.getCellValue(rowId, 'VALID_FROM_DATE')){
                                gridct.setCellValue(rowId, "CHANGE_YN", "Y");
                            }
                        }
                        if(gridct.getCellValue(rowId, 'PREV_VALID_TO_DATE')!="" && gridct.getCellValue(rowId, 'VALID_TO_DATE')!=""){
                            if(gridct.getCellValue(rowId, 'PREV_VALID_TO_DATE')!=gridct.getCellValue(rowId, 'VALID_TO_DATE')){
                                gridct.setCellValue(rowId, "CHANGE_YN", "Y");
                            }
                        }
                    }




                    if(colId == 'CONT_UNIT_PRICE'){

						if (gridct.getCellValue(rowId, 'APPLY_COM') == '') {
							gridct.setCellValue(rowId, "CONT_UNIT_PRICE", "");
							return alert('고객사를 선택해주세요.');
						}

						var profitRatio = gridct.getCellValue(rowId, 'PROFIT_RATIO');
						var truncType   = gridct.getCellValue(rowId, 'TRUNC_TYPE');

						var salesUnitPrice = newVal + newVal*profitRatio/100;
						if(truncType == 'RU') {//올림
							salesUnitPrice = Math.ceil(salesUnitPrice);
						} else if(truncType == 'TC') {//반올림
							salesUnitPrice = Math.round(salesUnitPrice);
						} else if(truncType == 'RD') {//절사
							salesUnitPrice = Math.floor(salesUnitPrice);
						}

						gridct.setCellValue(rowId, "SALES_UNIT_PRICE", salesUnitPrice);

                        if(gridct.getCellValue(rowId, 'PREV_VALID_TO_DATE')!=""||gridct.getCellValue(rowId, 'VALID_TO_DATE')!=0){
                            if(gridct.getCellValue(rowId, 'PREV_VALID_TO_DATE')!=gridct.getCellValue(rowId, 'VALID_TO_DATE')){
                                gridct.setCellValue(rowId, "CHANGE_YN", "Y");
                            }
                        }
                    }
                    if(colId =='CONT_UNIT_PRICE' || colId =='SALES_UNIT_PRICE'){
                        var profitRate;
                        if(gridct.getCellValue(rowId, 'SALES_UNIT_PRICE')!="" || gridct.getCellValue(rowId, 'SALES_UNIT_PRICE')>0){
                            profitRate = Number((gridct.getCellValue(rowId, 'SALES_UNIT_PRICE')-gridct.getCellValue(rowId, 'CONT_UNIT_PRICE'))/gridct.getCellValue(rowId, 'SALES_UNIT_PRICE'))*100;
                            gridct.setCellValue(rowId, "PROFIT_RATE", everMath.round_float(profitRate,2));
                        }else{
                            gridct.setCellValue(rowId, "PROFIT_RATE", "");
                        }

                    }
                    if(colId =='PROFIT_RATE'){
                        var profitRate;
                        if(gridct.getCellValue(rowId, 'PROFIT_RATE')!="" || gridct.getCellValue(rowId, 'PROFIT_RATE')>0){
                            stdUnitPrice = Number(gridct.getCellValue(rowId, 'CONT_UNIT_PRICE')+(gridct.getCellValue(rowId, 'SALES_UNIT_PRICE')*(gridct.getCellValue(rowId, 'PROFIT_RATE')/100)));
                            gridct.setCellValue(rowId, "STD_UNIT_PRICE", everMath.round_float(stdUnitPrice,0));
                        }
                    }
                });

                gridct.excelExportEvent({
                    allItems : "${excelExport.allCol}",
                    fileName : "${screenName }"
                });

                gridct.addRowEvent(function() {
					var chkYn = 'N';
                    var rowIds = gridct.getSelRowId();
                    for(var i in rowIds) {
                    	if(gridct.getCellValue(rowIds[i], "CONT_NO") != '') {
                    		 chkYn = 'Y';
                    	}
                    }

        			if (chkYn=='Y') {
						if(confirm('${IM03_009_0001}')) {
	                        var store = new EVF.Store();
	                        store.setGrid([gridct]);
	                        store.load(baseUrl + 'im03009_doSearch_CT', function () {
	                            gridct.setColIconify("LEAD_TIME_RMK_YN", "LEAD_TIME_RMK", "comment", false);

	                        	var applyCom   = '';
	                        	var applyNm   = '';
	                        	var vendorNm   = '';
	                        	var contUnitPrice   = '';
	                        	var prevUnitPrice   = '';
	                        	var salesUnitPrice   = '';
	                        	var moqQty   = '';
	                        	var rvQty   = '';
	                        	var leadTime   = '';
	                        	var cur   = '';
	                        	var vendorCd = '';
	                        	var applyPlant = '';
	                        	var applyPlantNm = '';
	                        	var delyType = '';
	                        	var profitRatio = '';


	                           if(gridct.getRowCount() > 0 && 1==2) {
	                           	 applyCom   = gridct.getCellValue(0,'APPLY_COM');
	                        	 applyNm   = gridct.getCellValue(0,'APPLY_NM');
	                        	 vendorNm   = gridct.getCellValue(0,'VENDOR_NM');
	                        	 contUnitPrice   = gridct.getCellValue(0,'CONT_UNIT_PRICE');
	                        	 prevUnitPrice   = gridct.getCellValue(0,'PREV_UNIT_PRICE');
	                        	 salesUnitPrice   = gridct.getCellValue(0,'SALES_UNIT_PRICE');
	                        	 moqQty   = gridct.getCellValue(0,'MOQ_QTY');
	                        	 rvQty   = gridct.getCellValue(0,'RV_QTY');
	                        	 leadTime   = gridct.getCellValue(0,'LEAD_TIME');
	                        	 cur   = gridct.getCellValue(0,'CUR');
	                        	 vendorCd   = gridct.getCellValue(0,'VENDOR_CD');
	                        	 applyPlant   = gridct.getCellValue(0,'APPLY_PLANT');
	                        	 applyPlantNm   = gridct.getCellValue(0,'APPLY_PLANT_NM');
	                        	 delyType   = gridct.getCellValue(0,'DELY_TYPE');

	                        	 profitRatio   = gridct.getCellValue(0,'PROFIT_RATIO');

	                           }

	                           ctSelect = gridct.addRow({
	                               "APPLY_COM": applyCom,
	                               "APPLY_NM": applyNm,
	                               "VENDOR_NM": vendorNm,
	                               "CONT_UNIT_PRICE": contUnitPrice,
	                               "PREV_UNIT_PRICE": prevUnitPrice,
	                               "SALES_UNIT_PRICE": salesUnitPrice,
	                               "MOQ_QTY": moqQty,
	                               "RV_QTY": rvQty,
	                               "LEAD_TIME": leadTime,
	                               "CUR": (cur == '' ? 'KRW' : cur),
	                               "VENDOR_CD": vendorCd,
	                        	   "DEAL_CD": "200",
	                               "VALID_FROM_DATE": '${today}',
	                               "APPLY_PLANT": applyPlant,
	                               "APPLY_PLANT_NM": applyPlantNm,
	                               "DELY_TYPE": delyType,
	                               "PROFIT_RATIO": profitRatio
	                           });
	                           addRowYn='Y';

	                        });
						}
        			} else {
                    	var applyCom   = '';
                    	var applyNm   = '';
                    	var vendorNm   = '';
                    	var contUnitPrice   = '';
                    	var prevUnitPrice   = '';
                    	var salesUnitPrice   = '';
                    	var moqQty   = '';
                    	var rvQty   = '';
                    	var leadTime   = '';
                    	var cur   = '';
                    	var vendorCd = '';

                    	var applyPlant = '';
                    	var applyPlantNm = '';

                    	var delyType = '';

                    	var profitRatio = '';


                       if(gridct.getRowCount() > 0 && 1==2) {
                       	 applyCom   = gridct.getCellValue(0,'APPLY_COM');
                    	 applyNm   = gridct.getCellValue(0,'APPLY_NM');
                    	 vendorNm   = gridct.getCellValue(0,'VENDOR_NM');
                    	 contUnitPrice   = gridct.getCellValue(0,'CONT_UNIT_PRICE');
                    	 prevUnitPrice   = gridct.getCellValue(0,'PREV_UNIT_PRICE');
                    	 salesUnitPrice   = gridct.getCellValue(0,'SALES_UNIT_PRICE');
                    	 moqQty   = gridct.getCellValue(0,'MOQ_QTY');
                    	 rvQty   = gridct.getCellValue(0,'RV_QTY');
                    	 leadTime   = gridct.getCellValue(0,'LEAD_TIME');
                    	 cur   = gridct.getCellValue(0,'CUR');
                    	 vendorCd   = gridct.getCellValue(0,'VENDOR_CD');
                    	 applyPlant   = gridct.getCellValue(0,'APPLY_PLANT');
                    	 applyPlantNm   = gridct.getCellValue(0,'APPLY_PLANT_NM');
                    	 delyType   = gridct.getCellValue(0,'DELY_TYPE');

                    	 profitRatio   = gridct.getCellValue(0,'PROFIT_RATIO');

                       }

                       ctSelect = gridct.addRow({
                           "APPLY_COM": applyCom,
                           "APPLY_NM": applyNm,
                           "VENDOR_NM": vendorNm,
                           "CONT_UNIT_PRICE": contUnitPrice,
                           "PREV_UNIT_PRICE": prevUnitPrice,
                           "SALES_UNIT_PRICE": salesUnitPrice,
                           "MOQ_QTY": moqQty,
                           "RV_QTY": rvQty,
                           "LEAD_TIME": leadTime,
                           "CUR": (cur == '' ? 'KRW' : cur),
                           "VENDOR_CD": vendorCd,
                    	   "DEAL_CD": "",
                           "VALID_FROM_DATE": '${today}',
                           "APPLY_PLANT": applyPlant,
                           "APPLY_PLANT_NM": applyPlantNm,
                           "DELY_TYPE": delyType,
                           "PROFIT_RATIO": profitRatio
                       });
                       addRowYn='Y';
        			}
                });

                gridct.delRowEvent(function() {
                    if(!gridct.isExistsSelRow()) { return alert("${msg.M0004}"); }
                    var selRowId = gridct.jsonToArray(gridct.getSelRowId()).value;
                    for (var i = 0; i < selRowId.length; i++) {
                        if(gridct.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                            return alert("${msg.M0145}");
                        }
                    }
                    gridct.delRow();
                });
            }

            _setImages();
            _setImages2();

            // 표준화인 경우에만 규격을 선택할 수 있음
            if( EVF.V("STD_FLAG") == "1" ){
                //EVF.C("ITEM_SPEC").setReadOnly(true);
                //EVF.C('NOT_STD_REMARK').setRequired(false);
                //EVF.C('NOT_STD_TYPE').setRequired(false);
            }else{
                //EVF.C("ITEM_SPEC").setReadOnly(false);
              	//EVF.C('NOT_STD_REMARK').setRequired(true);
              	//EVF.C('NOT_STD_TYPE').setRequired(true);
            }

            if(EVF.V("ITEM_CD") == "") {
                EVF.V("VAT_CD","T1");
            }

            if(EVF.V("ITEM_CD") != "") {
                EVF.C("setMng").setVisible(false);
            }

            gridct.setColIconify("LEAD_TIME_RMK_YN", "LEAD_TIME_RMK", "comment", false);
			//정식코드전환 cd구분
            // 품목코드 채번 이후에는 고객사 분류 선택할 수 없음
			if('${formData.ITEM_CD}' != '' && "${param.changeDt}"!="cd") {
	            EVF.C("ITEM_CLS_NM_CUST").setDisabled(true);
			}

            if("${param.changeDt}"=="cd"){
            	changeDt()

            }else{
	            doSearchCT();
            }

            var editor = EVF.C('TEXT_CONTENTS').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;



            var appDocNum = EVF.C("APP_DOC_NUM").getValue();
			if(appDocNum!='') {
				gridct.setColWidth('PREV_CONT_UNIT_PRICE',100);
				gridct.setColWidth('PREV_SALES_UNIT_PRICE',100);
			}


			onChangeStdFlag2();

        }


        function onChangeStdFlag2(){
			var store = new EVF.Store;
			store.setParameter("FLAG", EVF.C("STD_FLAG").getValue());
			store.load(baseUrl + '/getStdType', function() {
				if (this.getParameter("stdTypes") != null) {
					EVF.C('STD_TYPE').setOptions(this.getParameter("stdTypes"));
					EVF.C('STD_TYPE').setValue('${formData.STD_TYPE}');
				}
			});
        }

        //정식코드전환
		function changeDt(){
			var store = new EVF.Store();
            store.setGrid([gridct]);
            store.setAsync(false);
            let reData;
			store.load(baseUrl + 'im03009_doSearch_CT', function () {
                gridct.setColIconify("LEAD_TIME_RMK_YN", "LEAD_TIME_RMK", "comment", false);
                reData = gridct.getAllRowValue()[0];
                btnDisabled();
            });

			reData= gridct.getAllRowValue()[0];
			console.log(reData)
			store.load(baseUrl + 'im03009_doSearch_NmgCust', function () {
				gridct.checkAll(true);
	        });
			//기존 코드 공통고객사 사업장 매핑
			$.each (gridct.getAllRowValue(), function (index, el) {
				gridct.setCellValue(index,'VENDOR_CD' 			 , reData.VENDOR_CD);
				gridct.setCellValue(index,'VENDOR_NM' 			 , reData.VENDOR_NM);
				gridct.setCellValue(index,'CONT_UNIT_PRICE' 	 , reData.CONT_UNIT_PRICE)
				gridct.setCellValue(index,'SALES_UNIT_PRICE' 	 , reData.SALES_UNIT_PRICE);
				gridct.setCellValue(index,'PROFIT_RATE'			 , reData.PROFIT_RATE);
				gridct.setCellValue(index,'PROFIT_RATIO' 		 , reData.PROFIT_RATIO);
				gridct.setCellValue(index,'TRUNC_TYPE' 			 , reData.TRUNC_TYPE);
				gridct.setCellValue(index,'MOQ_QTY' 			 , reData.MOQ_QTY);
				gridct.setCellValue(index,'RV_QTY' 				 , reData.RV_QTY);
				gridct.setCellValue(index,'LEAD_TIME' 			 , reData.LEAD_TIME);
				gridct.setCellValue(index,'CUR' 				 , reData.CUR);
				gridct.setCellValue(index,'DELY_TYPE' 			 , reData.DELY_TYPE);
				gridct.setCellValue(index,'DEAL_CD' 			 , reData.DEAL_CD);
				gridct.setCellValue(index,'VALID_FROM_DATE' 	 , reData.VALID_FROM_DATE);
				gridct.setCellValue(index,'VALID_TO_DATE' 		 , reData.VALID_TO_DATE);
// 				gridct.setCellValue(index,'CONT_NO' 			 , reData.CONT_NO);
				gridct.setCellValue(index,'MOD_USER_NM' 		 , reData.MOD_USER_NM);
				gridct.setCellValue(index,'MOD_DATE' 			 , reData.MOD_DATE);
				gridct.setCellValue(index,'CHANGE_REASON' 		 , reData.CHANGE_REASON );
				gridct.setCellValue(index,'ERP_IF_FLAG'			 , reData.ERP_IF_FLAG);
				gridct.setCellValue(index,'SIGN_DATE' 			 , reData.SIGN_DATE);
// 				gridct.setCellValue(index,'SIGN_STATUS' 		 , reData.SIGN_STATUS)
				gridct.setCellValue(index,'STD_UNIT_PRICE' 		 , reData.STD_UNIT_PRICE );
				gridct.setCellValue(index,'VENDOR_ITEM_CD' 		 , reData.VENDOR_ITEM_CD );
				gridct.setCellValue(index,'RFQ_NUM' 			 , reData.RFQ_NUM);
				gridct.setCellValue(index,'PREV_VENDOR_CD' 		 , reData.PREV_VENDOR_CD);
				gridct.setCellValue(index,'PREV_VALID_TO_DATE' 	 , reData.PREV_VALID_TO_DATE);
				gridct.setCellValue(index,'PREV_VALID_FROM_DATE' , reData.PREV_VALID_FROM_DATE);
				gridct.setCellValue(index,'PREV_UNIT_PRICE'		 , reData.PREV_UNIT_PRICE);
				gridct.setCellValue(index,'PREV_APPLY_COM' 		 , reData.PREV_APPLY_COM);
				gridct.setCellValue(index,'PAST_CONT_UNIT_PRICE' , reData.PAST_CONT_UNIT_PRICE);
				gridct.setCellValue(index,'ORIGIN_VENDOR_CD' 	 , reData.ORIGIN_VENDOR_CD);
				gridct.setCellValue(index,'LEAD_TIME_RMK_YN' 	 , reData.LEAD_TIME_RMK_YN);
				gridct.setCellValue(index,'LEAD_TIME_RMK' 		 , reData.LEAD_TIME_RMK);
// 				gridct.setCellValue(index,'ITEM_CD' 			 , reData.ITEM_CD)
				gridct.setCellValue(index,'INSERT_FLAG' 		 , reData.INSERT_FLAG);
				gridct.setCellValue(index,'EXEC_NUM' 			 , reData.EXEC_NUM);
				gridct.setCellValue(index,'CUST_ITEM_CD' 		 , reData.CUST_ITEM_CD);
// 				gridct.setCellValue(index,'CONT_STATUS' 		 , reData.CONT_STATUS);
// 				gridct.setCellValue(index,'CONT_SEQ' 			 , reData.CONT_SEQ);
				gridct.setCellValue(index,'CONT_REGION_NM' 		 , reData.CONT_REGION_NM);
				gridct.setCellValue(index,'CONT_REGION_CD'		 , reData.CONT_REGION_CD);
				gridct.setCellValue(index,'CHANGE_YN'			 , reData.CHANGE_YN);
				gridct.setCellValue(index,'CHANGE_REASON_YN' 	 , reData.CHANGE_REASON_YN);
				gridct.setCellValue(index,'ATT_FILE_CNT' 		 , reData.ATT_FILE_CNT);
				gridct.setCellValue(index,'ATTACH_FILE_NUM2' 	 , reData.ATTACH_FILE_NUM2);
				gridct.setCellValue(index,'APP_DOC_NUM' 		 , reData.APP_DOC_NUM);
				gridct.setCellValue(index,'APP_DOC_CNT' 		 , reData.APP_DOC_CNT);
				gridct.setCellValue(index,'LEAD_TIME_CD' 		 , reData.LEAD_TIME_CD);
			});
			EVF.V("ITEM_CD"		 ,"");
			EVF.V("ITEM_CLS_NM"	 ,"")
			EVF.V("ITEM_CLS1"	 ,"")
			EVF.V("ITEM_CLS2"	 ,"")
			EVF.V("ITEM_CLS3"	 ,"")
			EVF.V("ITEM_CLS4"	 ,"")
			EVF.V("TEMP_CD_FLAG" ,"")
			$("#Approve").children('div').find(".e-button-text").text('정식코드전환')

		}
        function _setPlant(plantInfo) {
        	gridct.setCellValue(plantInfo.rowid, 'APPLY_PLANT', plantInfo['PLANT_CD']);
        	gridct.setCellValue(plantInfo.rowid, 'APPLY_PLANT_NM', plantInfo['PLANT_NM']);
        }

        function doSearchCT(){
            if(${not empty formData.ITEM_CD}) {
                var store = new EVF.Store();
                store.setGrid([gridct]);
                store.load(baseUrl + 'im03009_doSearch_CT', function () {
                    gridct.setColIconify("LEAD_TIME_RMK_YN", "LEAD_TIME_RMK", "comment", false);
                    //gridct.checkAll(true);
                    btnDisabled();
                });

            }else{
                if(${not empty formData.RP_NO}) {
                    var store = new EVF.Store();
                    store.setGrid([gridct]);
                    store.load(baseUrl + 'im03009_doSearchRP_CT', function () {
                        gridct.setColIconify("LEAD_TIME_RMK_YN", "LEAD_TIME_RMK", "comment", false);
                        gridct.checkAll(true);
                        btnDisabled();
                    });
                }
            }
        }


        function doSearchAT() {
            if(${not empty formData.ITEM_CD}) {
                var store = new EVF.Store();
                store.setGrid([gridat]);
                store.load(baseUrl + 'im03009_doSearch_AT', function () {

                });
            }
        }

        function btnDisabled() {
            var disabled = false;
            for(var i = 0; i < gridct.getRowCount(); i++) {
                if(gridct.getCellValue(i, 'SIGN_STATUS') == 'P' && gridct.getCellValue(i, 'APP_DOC_NUM') != '') {
                    disabled = true;
                }
            }

            if(disabled) {
                $('.e-button').each(function(k, v) {
                   EVF.C(v.id).setDisabled(true);
                });
            }
        }

        function doSave() {
            signStatus = this.getData();
            var store = new EVF.Store();
            if(!store.validate()) { return; }
			var erpIfFlag = false;
            var rowSelIds = gridct.getSelRowId();
            for (var s in rowSelIds) {

				var chkCou = 0;
            	var chkData = gridct.getCellValue(rowSelIds[s], "APPLY_COM")+'-'+gridct.getCellValue(rowSelIds[s], "APPLY_PLANT");
                var rowSelIdX = gridct.getSelRowId();
                for (var x in rowSelIdX) {
                	var chkDataTemp = gridct.getCellValue(rowSelIdX[x], "APPLY_COM")+'-'+gridct.getCellValue(rowSelIdX[x], "APPLY_PLANT");
					if (chkData == chkDataTemp) {
						chkCou++;
					}


                }
                if(chkCou>1) {
                    EVF.alert('동일 고객사,사업장이 존재합니다.');
    				return;
                }


                if(Number(gridct.getCellValue(rowSelIds[s], "MOQ_QTY")) < 0 || EVF.isEmpty(gridct.getCellValue(rowSelIds[s], "MOQ_QTY"))){
                    return alert('${IM03_009_018}');
                }
                if(Number(gridct.getCellValue(rowSelIds[s], "RV_QTY")) < 0 || EVF.isEmpty(gridct.getCellValue(rowSelIds[s], "RV_QTY"))){
                    return alert('${IM03_009_019}');
                }
                if(EVF.isEmpty(gridct.getCellValue(rowSelIds[s], 'APPLY_COM'))) {
                    return alert('${IM03_009_020}');
                }
            	if(gridct.getCellValue(rowSelIds[s], 'ERP_IF_FLAG') == '1') {
            		erpIfFlag = true;
                }
            }
			if(erpIfFlag) {
				if( EVF.C('ITEM_CLS_NM_CUST').getValue() == '') {
                    return alert('${IM03_009_028}');
				}
			} else {
				if( EVF.C('ITEM_CLS3_CUST_BEFORE').getValue() == '') {
		            EVF.C('ITEM_CLS_NM_CUST').setValue('');
		            EVF.C('ITEM_CLS1_CUST').setValue('');
		            EVF.C('ITEM_CLS2_CUST').setValue('');
		            EVF.C('ITEM_CLS3_CUST').setValue('');
		            EVF.C('ITEM_CLS4_CUST').setValue('');
				}
			}

            if (signStatus == 'T') {

                if(gridct.isExistsSelRow()) {
                    // 임시저장시에 단가정보가 변경되면 임시저장안되고 등록으로 진행.
                    var noApp="";
                    var rowAllIds = gridct.getAllRowId();
                    for (var i in rowAllIds) {
                        if(gridct.getCellValue(rowAllIds[i], "SIGN_STATUS") == "P"){
                            return alert('${IM03_009_012}');
                        }
                        // 단가정보가 변경되지않았을 경우 결재없음.
                        if(gridct.getCellValue(rowAllIds[i], 'PAST_CONT_UNIT_PRICE') != gridct.getCellValue(rowAllIds[i], 'CONT_UNIT_PRICE')){
                            noApp = "N";
                        }
                    }
                    if(noApp == "N"){
                        return alert('${IM03_009_013}');
                    }
                }

                if(!confirm("${msg.M0021}")) { return; }
                goApproval();
            }
            else {
                // 계약정보있으면 결재 or 계약정보의 매입단가 수정시 결재
                if(gridct.isExistsSelRow()) {

                    if(!gridct.validate().flag) { return alert(gridct.validate().msg); }

                    var rowIds = gridct.getSelRowId();
                    for( var i in rowIds ) {
                    	/*
                        if(gridct.getCellValue(rowIds[i], "LEAD_TIME_CD")=="50"){
                            if(gridct.getCellValue(rowIds[i], "LEAD_TIME_RMK")==""){
                                return alert('${IM03_009_011}');
                            }
                        }
                        if(gridct.getCellValue(rowIds[i], 'CONT_STATUS') == '0') {
                            return alert(gridct.getCellValue(rowIds[i], 'CONT_NO') + "${IM03_009_017}"); // 는 만료된 상태입니다.
                        }*/
                        var allRowIds = gridct.getAllRowId();
                        for( var j in allRowIds ) {
                            if(rowIds[i] != allRowIds[j]) {
                                if(gridct.getCellValue(rowIds[i], 'CONT_STATUS') == gridct.getCellValue(allRowIds[j], 'CONT_STATUS')) {
                                    if(gridct.getCellValue(rowIds[i], 'CONT_NO') == gridct.getCellValue(allRowIds[j], 'CONT_NO')) {
                                        if(gridct.getCellValue(rowIds[i], 'APPLY_COM') == gridct.getCellValue(allRowIds[j], 'APPLY_COM')) {
                                            if(gridct.getCellValue(rowIds[i], 'APPLY_PLANT') == gridct.getCellValue(allRowIds[j], 'APPLY_PLANT')) {
	                                            return alert("${IM03_009_009}");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 단가적용대상중복체크
                    //if(!CT_APPSameValue_Remove()) {
                        // return alert("${IM03_009_009}")
                    //}

                    var noApp = "";
                    var rowAllIds = gridct.getAllRowId();

                    for (var i in rowAllIds) {
                        if(gridct.getCellValue(rowAllIds[i], "SIGN_STATUS")=="P"){
                            return alert('${IM03_009_012}');
                        }
                        //단가정보가 변경되지않았을경우 결재없음.
		                if(gridct.isExistsSelRow()) {
                            noApp = "N";
                        }
                    }

                    if(noApp == ""){
                        if(!confirm("${msg.M0021}")) { return; }
                        goApproval(); // 결재없이 바로 저장할 수 있도록 넘어감.
                    }
                    else {
                        // 계약정보중 매입단가가 가장큰 값을 기준으로 한다.
                        var rowIds = gridct.getSelRowId();
                        var contUnitPrices = 0;
                        for (var i in rowIds) {
                            if(i > 0){
                                if(contUnitPrices < Number(gridct.getCellValue(rowIds[i], "CONT_UNIT_PRICE"))){
                                    contUnitPrices = Number(gridct.getCellValue(rowIds[i], "CONT_UNIT_PRICE"));
                                }
                            } else {
                                contUnitPrices = Number(gridct.getCellValue(rowIds[i], "CONT_UNIT_PRICE"));
                            }
                        }

                        if(!confirm("${msg.M0021}")) { return; }

                        EVF.V("YINFO_SIGN_STATUS", "P");
                        //결재--
                        let subjectAdd="";
						if("${param.changeDt}"=="cd"){
							subjectAdd="정식코드전환(임시코드)"
						}
                        var param = {
                            subject: subjectAdd+"품목등록 [" + EVF.V("ITEM_DESC") + "]" + "(계약정보 존재)",
                            docType: "INFOCH",
                            signStatus: "P",
                            screenId: "IM03_009",
                            approvalType: 'APPROVAL',
                            attFileNum: "",
                            docNum: EVF.getComponent('ITEM_CD').getValue(),
                            callBackFunction: "goApproval",
                            bizCls1: "04",
                            bizCls2: "05",
                            bizCls3: "07",
                            bizAmt: contUnitPrices
                        };
                        everPopup.openApprovalRequestIIPopup(param);
                    }
                } else {
                    if(!confirm("${msg.M0021}")) { return; }
                    goApproval();
                }
            }
        }

        function goApproval(formData, gridData, attachData) {

            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            EVF.V("YINFO_SIGN_STATUS", "E");

            var store = new EVF.Store();
            store.setGrid([gridct,gridat]);
            store.getGridData(gridct, 'sel');
            store.getGridData(gridat, 'all');
            store.setParameter("signStatus", signStatus);

            if(store.doFileUpload(function() {

                store.setParameter('mainImgSq', $('#mainImgContainer').find('input[type=radio]:checked').prop('id'));

                store.load(baseUrl + 'im03009_doSave', function () {
                    alert(this.getResponseMessage());
                    if (this.getParameter("ITEM_CD") == "" || this.getParameter("ITEM_CD") == null) {

                    } else {
                        if(${param.popupFlag eq 'true'}) {
                            opener.doSearch();
                            var param = {
                                'ITEM_CD': this.getParameter("ITEM_CD"),
                                'popupFlag': true,
                                'detailView': false
                            };
                            window.location.href = '/evermp/IM03/IM0301/IM03_009/view.so?' + $.param(param);
                            if("${param.changeDt}"=="cd"){
                            	if(opener != null) {
                         			window.close();
                         		} else {
                         			new EVF.ModalWindow().close(null);
                         		}
                            }
                        }else{
                            if(confirm('${IM03_009_006}')) {
                                location.href="/evermp/IM03/IM0301/IM03_009/view";
                            }else{
                                var param = {
                                    'ITEM_CD': this.getParameter("ITEM_CD"),
                                    'popupFlag': true,
                                    'detailView': false
                                };
                                location.href = '/evermp/IM03/IM0301/IM03_009/view.so?' + $.param(param);
                            }
                        }
                    }
                });
            }));
        }

        function doDeleteCt() {
            var store = new EVF.Store();
            if ((gridct.jsonToArray(gridct.getSelRowId()).value).length == 0) {
                return alert("${msg.M0004}");
            }

            var selRowId = gridct.jsonToArray(gridct.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(gridct.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                    return alert('${IM03_009_005}');
                }

  				if(gridct.getCellValue(selRowId[i], 'CHANGE_REASON')=="") {
  					return alert("${IM03_009_033}");
  				}

            }

            if (!confirm("${msg.M0013 }")) return;

            store.setGrid([gridct]);
            store.getGridData(gridct, 'sel');
            store.load(baseUrl + 'im03009_doDeletegridct', function() {
                alert(this.getResponseMessage());
                doSearchCT();
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
                'custNm' : '㈜소노인터내셔널'  // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNmCust(data) {
            if(data!=null){

                data = JSON.parse(data);


                EVF.C("ITEM_CLS1_CUST").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2_CUST").setValue("*");}else{EVF.C("ITEM_CLS2_CUST").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3_CUST").setValue("*");}else{EVF.C("ITEM_CLS3_CUST").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4_CUST").setValue("*");}else{EVF.C("ITEM_CLS4_CUST").setValue(data.ITEM_CLS4);}
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
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("*");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("*");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("*");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
                EVF.C("SG_CTRL_USER_ID").setValue(data.SG_CTRL_USER_ID);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }

        // 첨부파일갯수제어-------------------------
        function _doUpload() {
            if(EVF.C('IMG_ATT_FILE_NUM').getFileCount()>4){
                return alert("${IM03_009_001}");
            }
            EVF.C('IMG_ATT_FILE_NUM').uploadFile();
        }

        function _setImages() {

            var fileManager = EVF.C('IMG_ATT_FILE_NUM');
            var store = new EVF.Store();

            store.setParameter('fileManagerId', fileManager.getID());
            store.setParameter('bizType', 'IMG');
            store.setParameter('fileId', fileManager.getFileId());
            store.load('/common/file/fileAttach/getUploadedFileInfo', function() {

                var mainImgSq = EVF.V('MAIN_IMG_SQ');
                var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
                $('#mainImgContainer').empty();
                $.each(fileInfoJson, function(i, datum) {
                    var $itemImage;
                    if(i==0){
                        $itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: 110px; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"><input id="'+datum.UUID_SQ+'" style="display:inline" name="itemImage" type="radio" checked="checked"/></div>');
                    }else{
                        $itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: 110px; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"><input id="'+datum.UUID_SQ+'" style="display:inline" name="itemImage" type="radio" '+(datum.UUID_SQ == mainImgSq ? 'checked="checked"': '')+' /></div>');
                    }
                    $('#mainImgContainer').append($itemImage);
                });
            });
        }

        //첨부파일갯수제어-------------------------
        function _doUpload2() {
            if(EVF.C('ITEM_DETAIL_FILE_NUM').getFileCount()>1){
                return alert("${IM03_009_014}");
            }

            EVF.C('ITEM_DETAIL_FILE_NUM').uploadFile();
        }
        function _setImages2() {

            var detailFileManager = EVF.C('ITEM_DETAIL_FILE_NUM');
            var store = new EVF.Store();

            store.setParameter('fileManagerId', detailFileManager.getID());
            store.setParameter('bizType', 'IMG');
            store.setParameter('fileId', detailFileManager.getFileId());
            store.load('/common/file/fileAttach/getUploadedFileInfo', function() {

                var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
                $('#DetailImgContainer').empty();
                $.each(fileInfoJson, function(i, datum) {
                    var $itemImage;
                    //$itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: auto; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"></div>');
                    $itemImage = $('<div style="overflow:scroll; height:515px; text-align:center;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: auto; cursor: pointer;" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"></div>');
                    $('#DetailImgContainer').append($itemImage);
                });
            });
        }

        function onChangeStdFlag(){
			var store = new EVF.Store;
			store.setParameter("FLAG", EVF.C("STD_FLAG").getValue());
			store.load(baseUrl + '/getStdType', function() {
				if (this.getParameter("stdTypes") != null) {
					EVF.C('STD_TYPE').setOptions(this.getParameter("stdTypes"));
				}
			});



           	return;
                       EVF.V("ITEM_SPEC","");
            if(EVF.V("STD_FLAG")=="1"){
                EVF.C("ITEM_SPEC").setReadOnly(true);
                EVF.V('NOT_STD_REMARK',"");
                EVF.V('NOT_STD_TYPE',"");
                EVF.C('NOT_STD_REMARK').setReadOnly(true);
                EVF.C('NOT_STD_TYPE').setReadOnly(true);
                EVF.C('NOT_STD_REMARK').setRequired(false);
                EVF.C('NOT_STD_TYPE').setRequired(false);

            }else{
                gridat.delAllRow();
                EVF.C("ITEM_SPEC").setReadOnly(false);
                EVF.C('NOT_STD_REMARK').setReadOnly(false);
                EVF.C('NOT_STD_TYPE').setReadOnly(false);
                EVF.C('NOT_STD_REMARK').setRequired(false);
                EVF.C('NOT_STD_TYPE').setRequired(false);

            }
        }

        function _getSpecList(){

            if(EVF.V("STD_FLAG")==""){
                return alert('${IM03_009_002}');
            }
            if(EVF.V("STD_FLAG")=="1"){
                if(EVF.V("ITEM_CLS_NM")==""){
                    EVF.C("ITEM_CLS_NM").setFocus();
                    return alert('${IM03_009_003}');
                }

                var selectedATData;
                var rowIds = gridat.getAllRowId();
                for (var i in rowIds) {
                    if(i>0){
                        selectedATData = selectedATData+"@"+ gridat.getCellValue(rowIds[i], "ATTR_CD")+"|"+gridat.getCellValue(rowIds[i], "ATTR_VALUE")
                    }else{
                        selectedATData = gridat.getCellValue(rowIds[i], "ATTR_CD")+"|"+gridat.getCellValue(rowIds[i], "ATTR_VALUE")
                    }

                }
                var param = {
                    callBackFunction: '_setSpect_Grid',
                    'ITEM_CLS1': EVF.V("ITEM_CLS1"),
                    'ITEM_CLS2': EVF.V("ITEM_CLS2"),
                    'ITEM_CLS3': EVF.V("ITEM_CLS3"),
                    'ITEM_CLS4': EVF.V("ITEM_CLS4"),
                    'AT_DATA' : selectedATData,
                    'detailView': false
                };
                everPopup.im03_011open(param);
            }
        }

        function _setSpect_Grid(data){

            var itemSpecNm="";
            gridat.delAllRow();
            for(idx in data) {

                gridat.addRow();
                gridat.setCellValue(idx, 'ATTR_CD', data[idx].ATTR_CD);
                gridat.setCellValue(idx, 'ATTR_VALUE', data[idx].ATTR_VALUE);
                gridat.setCellValue(idx, 'ATTR_TYPE', "ITEM");

                if(idx >0){
                    itemSpecNm = itemSpecNm + "; "+data[idx].ATTR_VALUE;
                }else{
                    itemSpecNm = data[idx].ATTR_VALUE;
                }
            }
            EVF.V("ITEM_SPEC",itemSpecNm);
        }

        function gridct_selectVendorCd(data) {
            gridct.setCellValue(SelectRowIdCt, "VENDOR_CD" , data.VENDOR_CD );
            gridct.setCellValue(SelectRowIdCt, "VENDOR_NM" , data.VENDOR_NM );

            if (gridct.getCellValue(SelectRowIdCt, 'PREV_VENDOR_CD') != "") {
                if (gridct.getCellValue(SelectRowIdCt, 'PREV_VENDOR_CD') != gridct.getCellValue(SelectRowIdCt, 'VENDOR_CD')) {
                    gridct.setCellValue(SelectRowIdCt, "CHANGE_YN", "Y");
                }
            }

            var cont_no = gridct.getCellValue(SelectRowIdCt, 'CONT_NO');
            for(var i = 0; i < gridct.getRowCount(); i++) {
                if(cont_no == '') {
                    if(gridct.getCellValue(i, 'CONT_NO') == '' && gridct.getCellValue(i, 'VENDOR_CD') != '') {
                        if( data.VENDOR_CD != gridct.getCellValue(i, 'VENDOR_CD')) {
                            gridct.setCellValue(SelectRowIdCt, "VENDOR_CD" , '');
                            gridct.setCellValue(SelectRowIdCt, "VENDOR_NM" , '');
                            return alert('${IM03_009_016}');
                        }
                    }
                } else {
                    if(cont_no == gridct.getCellValue(i, 'CONT_NO')) {
                        gridct.setCellValue(i, "VENDOR_CD" ,data.VENDOR_CD );
                        gridct.setCellValue(i, "VENDOR_NM" ,data.VENDOR_NM );
                    }
                }
            }
        }

        function CT_setAttFile(rowId, fileId, fileCnt) {
            gridct.setCellValue(rowId, 'ATTACH_FILE_NUM2', fileId);
            gridct.setCellValue(rowId, 'ATT_FILE_CNT', fileCnt);
        }
        function CT_setLeadTimeRmk(data) {
            gridct.setCellValue(data.rowId, "LEAD_TIME_RMK", data.message);
            gridct.setColIconify("LEAD_TIME_RMK_YN", "LEAD_TIME_RMK", "comment", false);
        }
        function CR_setChangeReasonRmk(data) {
            gridct.setCellValue(data.rowId, "CHANGE_REASON", data.message);
            gridct.setColIconify("CHANGE_REASON_YN", "CHANGE_REASON", "comment", false);
        }

        function CT_setRegionNm(data){
            gridct.setCellValue(data.rowId, "CONT_REGION_CD", data.REGION_CD);
            gridct.setCellValue(data.rowId, "CONT_REGION_NM", data.REGION_NM);  /// REGION_NM으로 바꿀예정@@@
        }

        function SetApply(){
            var gridValue = gridct.getSelRowValue();
            if(gridct.getSelRowCount() > 1) {
                return alert("단가적용대상을 하나만 선택하여 주시기 바랍니다.");
            }

            for(var i in gridValue) {
                if(gridValue[i].CONT_STATUS == '0') {
                    return alert("만료된 데이터는 단가적용대상을 적용하실 수 없습니다.");
                }

            }

            if(!gridct.isExistsSelRow()) {
                alert("${IM03_009_008}");
                return;
                /*
                gridct.addRow();
                gridct.checkRow(0, true);
                ctSelect = 0;
                */
            }

            APmultiYn="Y";
            var param = {
                callBackFunction: 'CT_setApplyNm',
                callType : 'Multi',
                'detailView': false
            };
            everPopup.im03_013open(param);
        }

        function CT_setApplyNm(data) {

            var rowId = gridct.getSelRowId()[0];

            data = JSON.parse(data);

            var grdhStr = "";
            for (var i = 0; i < gridct.getRowCount(); i++) {
                for (var j in data) {
                    if (gridct.getCellValue(i, 'APPLY_COM') == data[j].BUYER_CD && gridct.getCellValue(i, 'CONT_NO') == gridct.getCellValue(rowId, 'CONT_NO')) {
                        grdhStr += "단가적용대상" +" : " + data[j].BUYER_CD+"\n";

                        // 동일 데이터 삭제
                        data.splice(j, 1);
                    }
                }
            }

            if(grdhStr != "") alert("동일한 데이터가 존재합니다.\n"+grdhStr.substring(0, grdhStr.length -1));


            if(data.length != undefined) {
                var dataArr = [];
                for(var i in data) {
                    if(gridct.getCellValue(ctSelect, 'APPLY_COM') == "" && i == 0){
                        gridct.setCellValue(ctSelect, "APPLY_COM", data[i].BUYER_CD);
                        gridct.setCellValue(ctSelect, "APPLY_NM", data[i].BUYER_NM);
                    }else{
                        var arr = {
                            'APPLY_COM': data[i].BUYER_CD,
                            'APPLY_NM':  data[i].BUYER_NM,
                            'VENDOR_CD' : gridct.getCellValue(rowId, 'VENDOR_CD'),
                            'VENDOR_NM': gridct.getCellValue(rowId, 'VENDOR_NM'),
                            'VENDOR_ITEM_CD': gridct.getCellValue(rowId, 'VENDOR_ITEM_CD'),
                            'CONT_UNIT_PRICE': gridct.getCellValue(rowId, 'CONT_UNIT_PRICE'),
                            'STD_UNIT_PRICE': gridct.getCellValue(rowId, 'STD_UNIT_PRICE'),
                            'PROFIT_RATE': gridct.getCellValue(rowId, 'PROFIT_RATE'),
                            'MOQ_QTY': gridct.getCellValue(rowId, 'MOQ_QTY'),
                            'RV_QTY': gridct.getCellValue(rowId, 'RV_QTY'),
                            'LEAD_TIME': gridct.getCellValue(rowId, 'LEAD_TIME'),
                            'LEAD_TIME_CD': gridct.getCellValue(rowId, 'LEAD_TIME_CD'),
                            'LEAD_TIME_RMK': gridct.getCellValue(rowId, 'LEAD_TIME_RMK'),
                            'LEAD_TIME_RMK_YN': gridct.getCellValue(rowId, 'LEAD_TIME_RMK_YN'),
                            'CONT_REGION_CD': gridct.getCellValue(rowId, 'CONT_REGION_CD'),
                            'CONT_REGION_NM': gridct.getCellValue(rowId, 'CONT_REGION_NM'),
                            'DEAL_CD': gridct.getCellValue(rowId, 'DEAL_CD'),
                            'VALID_FROM_DATE': gridct.getCellValue(rowId, 'VALID_FROM_DATE'),
                            'VALID_TO_DATE': gridct.getCellValue(rowId, 'VALID_TO_DATE'),
                            'CONT_STATUS': gridct.getCellValue(rowId, 'CONT_STATUS'),
                            'CONT_NO': gridct.getCellValue(rowId, 'CONT_NO'),
                        };
                        dataArr.push(arr);
                    }
                }
                gridct.addRow(dataArr);
            }

            gridct.checkRow(rowId, false);
            //중복체크
            //CT_APPSameValue_Remove();
        }

        function CT_APPSameValue_Remove(){
            var rowIds = gridct.getAllRowId();
            var ctKey; var ctKey2;
            var okyn="";
            for( var i in rowIds ) {

                ctKey =  gridct.getCellValue(rowIds[i], "APPLY_COM")+"_"+gridct.getCellValue(rowIds[i], "VENDOR_CD");

                for( var j in rowIds ) {
                    if(i!=j){
                        ctKey2 =  gridct.getCellValue(rowIds[j], "APPLY_COM")+"_"+gridct.getCellValue(rowIds[j], "VENDOR_CD");
                        if(ctKey == ctKey2){
                            okyn="N";
                        }
                    }
                }
            }
            if(okyn=="N"){
                return false;
//                if(APmultiYn="N"){
//                    gridct.setCellValue(SelectRowIdCt, "APPLY_COM", "");
//                    gridct.setCellValue(SelectRowIdCt, "APPLY_NM", "");
//                }
            }

            // 변경되엇으면체크
            if(gridct.getCellValue(SelectRowIdCt, 'PREV_APPLY_COM')!=""){
                if(gridct.getCellValue(SelectRowIdCt, 'APPLY_COM')!=""){
                    if(gridct.getCellValue(SelectRowIdCt, 'PREV_APPLY_COM')!=gridct.getCellValue(SelectRowIdCt, 'APPLY_COM')){
                        gridct.setCellValue(SelectRowIdCt, "CHANGE_YN", "Y");
                    }
                }
            }
        }

        function CT_setApplyNmROW(data){

        	var parseData = [];
            parseData.push(data);
            var grdhStr = "";
            for (var i = 0; i < gridct.getRowCount(); i++) {
                for (var j in parseData) {
                    if (gridct.getCellValue(i, 'APPLY_COM') == parseData[j].CUST_CD && gridct.getCellValue(i, 'CONT_NO') == gridct.getCellValue(SelectRowIdCt, 'CONT_NO')) {
                        grdhStr += "단가적용대상" +" : " + parseData[j].CUST_NM+"\n";

                        // 동일 데이터 삭제
                        parseData.splice(j, 1);
                    }
                }
            }

//            if(grdhStr != "") alert("동일한 데이터가 존재합니다.\n"+grdhStr.substring(0, grdhStr.length -1));


			//for(var i in parseData) {
            //    gridct.setCellValue(SelectRowIdCt, "APPLY_COM", parseData[i].CUST_CD);
            //    gridct.setCellValue(SelectRowIdCt, "APPLY_NM", parseData[i].CUST_NM);
            //}

            gridct.setCellValue(SelectRowIdCt, "PROFIT_RATIO", data.PROFIT_RATIO);
            gridct.setCellValue(SelectRowIdCt, "TRUNC_TYPE", data.TRUNC_TYPE);

            gridct.setCellValue(SelectRowIdCt, "APPLY_COM", data.CUST_CD);
            gridct.setCellValue(SelectRowIdCt, "APPLY_NM", data.CUST_NM);


            gridct.setCellValue(SelectRowIdCt, "APPLY_PLANT", '');
            gridct.setCellValue(SelectRowIdCt, "APPLY_PLANT_NM", '');


            gridct.setCellValue(SelectRowIdCt, "ERP_IF_FLAG", data.ERP_IF_FLAG);

        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        function searchBrandCd(){
            var param = {
                callBackFunction : "selectBrandCd"
            };
            everPopup.openCommonPopup(param, 'SP0088');
        }

        function selectBrandCd(dataJsonArray) {
            EVF.V("BRAND_CD",dataJsonArray.MKBR_CD);
            EVF.V("BRAND_NM",dataJsonArray.MKBR_NM);
        }



        function onError() {
            $('.ui-icon-circle-arrow-w').trigger('click');
        }



		function dosetMng() {
            var store = new EVF.Store();
            store.setGrid([gridct]);
            store.load(baseUrl + 'im03009_doSearch_NmgCust', function () {
				gridct.checkAll(true);
            });


		}

		function dosetAllApy() {
			gridct.checkAll(true);
    		var param = {
       				'detailView': false
    		};
        	everPopup.openPopupByScreenId("IM03_009P", 1000, 500, param);
		}





		function setApplyAll(data) {

	        var rowSelIds = gridct.getSelRowId();
	        for (var s in rowSelIds) {




				if(data.VENDOR_NM!='')
	        	gridct.setCellValue(rowSelIds[s], 'VENDOR_NM',   data.VENDOR_NM  );
				if(data.VENDOR_CD!='')
	        	gridct.setCellValue(rowSelIds[s], 'VENDOR_CD',   data.VENDOR_CD  );
				if(data.CONT_UNIT_PRICE!='')
	        	gridct.setCellValue(rowSelIds[s], 'CONT_UNIT_PRICE',   data.CONT_UNIT_PRICE  );
				if(data.SALES_UNIT_PRICE!='')
	        	gridct.setCellValue(rowSelIds[s], 'SALES_UNIT_PRICE',   data.SALES_UNIT_PRICE  );
				if(data.MOQ_QTY!='')
	        	gridct.setCellValue(rowSelIds[s], 'MOQ_QTY',   data.MOQ_QTY  );
				if(data.RV_QTY!='')
	        	gridct.setCellValue(rowSelIds[s], 'RV_QTY',   data.RV_QTY  );
				if(data.LEAD_TIME!='')
	        	gridct.setCellValue(rowSelIds[s], 'LEAD_TIME',   data.LEAD_TIME  );
				if(data.CUR!='')
	        	gridct.setCellValue(rowSelIds[s], 'CUR',   data.CUR  );
				if(data.DELY_TYPE!='')
	        	gridct.setCellValue(rowSelIds[s], 'DELY_TYPE',   data.DELY_TYPE  );
				if(data.DEAL_CD!='')
	        	gridct.setCellValue(rowSelIds[s], 'DEAL_CD',   data.DEAL_CD  );
				if(data.VALID_FROM_DATE!='')
	        	gridct.setCellValue(rowSelIds[s], 'VALID_FROM_DATE',   data.VALID_FROM_DATE  );
				if(data.VALID_TO_DATE!='')
	        	gridct.setCellValue(rowSelIds[s], 'VALID_TO_DATE',   data.VALID_TO_DATE  );
	        }
		}

		function doopenImg() {
			var url = EVF.C("ITEM_DETAIL_URL").getValue();
			if( url == '' ) return;
            everPopup.openWindowPopup(url, 500, 470, '', 'destUrl', true);
		}



		function doviewHistory() {
    		var param = {
    				 ITEM_CD : '${formData.ITEM_CD}'
       				,'detailView': true
    		};
        	everPopup.openPopupByScreenId("IM03_009Hist", 1100, 500, param);
		}
    </script>

    <e:window id="IM03_009" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar id="buttonTopBottom" title="${IM03_009_CAPTION1 }" align="right" width="100%">
        	<e:button id="Approve" name="Approve" label="${Approve_N}" onClick="doSave" disabled="${Approve_D}" visible="${Approve_V}" data="E"/>
			<e:button id="viewHistory" name="viewHistory" label="${viewHistory_N}" onClick="doviewHistory" disabled="${viewHistory_D}" visible="${viewHistory_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:inputHidden id="SIGN_DATE" name="SIGN_DATE" value="${formData.SIGN_DATE }" />
            <e:inputHidden id="approvalFormData" name="approvalFormData" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" />
            <e:inputHidden id="attachFileDatas" name="attachFileDatas" />
            <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD }" />
            <e:inputHidden id="CONT_NO" name="CONT_NO" value="${formData.CONT_NO }" />
            <e:inputHidden id="RP_NO" name="RP_NO" value="${formData.RP_NO }" />
            <e:inputHidden id="RP_SEQ" name="RP_SEQ" value="${formData.RP_SEQ }" />
            <e:inputHidden id="RP_VENDOR_CD" name="RP_VENDOR_CD" value="${formData.RP_VENDOR_CD }" />
            <e:inputHidden id="YINFO_SIGN_STATUS" name="YINFO_SIGN_STATUS" value="" />
            <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.APP_DOC_NUM }" />
            <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${param.APP_DOC_CNT }" />
            <e:inputHidden id="OLD_ITEM_CD" name="OLD_ITEM_CD" value="${param.ITEM_CD }" />
            <e:inputHidden id="CHANGE_DT" name="CHANGE_DT" value="${param.changeDt }" />
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="${formData.ITEM_CD}" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field colSpan="3">
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="${formData.ITEM_CLS_NM}" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : '_getItemClsNm'}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${formData.ITEM_CLS1}"/>
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${formData.ITEM_CLS2}"/>
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${formData.ITEM_CLS3}"/>
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${formData.ITEM_CLS4}"/>
                    <e:inputHidden id="TEMP_CD_FLAG" name="TEMP_CD_FLAG" value="${formData.TEMP_CD_FLAG}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="CUST_ITEM_CD" name="CUST_ITEM_CD" value="${formData.CUST_ITEM_CD}" width="${form_CUST_ITEM_CD_W}" maxLength="${form_CUST_ITEM_CD_M}" disabled="${form_CUST_ITEM_CD_D}" readOnly="${form_CUST_ITEM_CD_RO}" required="${form_CUST_ITEM_CD_R}" />
                </e:field>
				<e:label for="ITEM_CLS_NM_CUST" title="${form_ITEM_CLS_NM_CUST_N}"/>
				<e:field colSpan="3">
					<e:search id="ITEM_CLS_NM_CUST" name="ITEM_CLS_NM_CUST" value="${formData.ITEM_CLS_NM_CUST}" width="${form_ITEM_CLS_NM_CUST_W}" maxLength="${form_ITEM_CLS_NM_CUST_M}" onIconClick="${param.detailView ? 'everCommon.blank' : '_getItemClsNmCust'}" disabled="${form_ITEM_CLS_NM_CUST_D}" readOnly="${form_ITEM_CLS_NM_CUST_RO}" required="${form_ITEM_CLS_NM_CUST_R}" />
	                <e:inputHidden id="ITEM_CLS1_CUST" name="ITEM_CLS1_CUST" value="${formData.ITEM_CLS1_CUST}"/>
	                <e:inputHidden id="ITEM_CLS2_CUST" name="ITEM_CLS2_CUST" value="${formData.ITEM_CLS2_CUST}"/>
	                <e:inputHidden id="ITEM_CLS3_CUST" name="ITEM_CLS3_CUST" value="${formData.ITEM_CLS3_CUST}"/>
	                <e:inputHidden id="ITEM_CLS3_CUST_BEFORE" name="ITEM_CLS3_CUST_BEFORE" value="${formData.ITEM_CLS3_CUST}"/>
	                <e:inputHidden id="ITEM_CLS4_CUST" name="ITEM_CLS4_CUST" value="${formData.ITEM_CLS4_CUST}"/>
				</e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_KIND_CD" title="${form_ITEM_KIND_CD_N}"/>
                <e:field>
                    <e:select id="ITEM_KIND_CD" name="ITEM_KIND_CD" value="${formData.ITEM_KIND_CD}" options="${itemKindCdOptions}" width="${form_ITEM_KIND_CD_W}" disabled="${form_ITEM_KIND_CD_D}" readOnly="${form_ITEM_KIND_CD_RO}" required="${form_ITEM_KIND_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field colSpan="3">
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${formData.ITEM_DESC}" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="STD_FLAG" title="${form_STD_FLAG_N}"/>
                <e:field>
                    <e:select id="STD_FLAG" name="STD_FLAG" value="${formData.STD_FLAG}" options="${stdFlagOptions}" width="${form_STD_FLAG_W}" disabled="${form_STD_FLAG_D}" readOnly="${form_STD_FLAG_RO}" required="${form_STD_FLAG_R}" placeHolder="" onChange="onChangeStdFlag" usePlaceHolder="false"/>
                </e:field>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
                <e:field colSpan="3">
                    <e:search id="ITEM_SPEC" name="ITEM_SPEC" value="${formData.ITEM_SPEC}" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" onIconClick="${param.detailView ? 'everCommon.blank' : '_getSpecList'}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}"  placeHolder="${IM03_009_0x4}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:search id="MAKER_CD" style="ime-mode:inactive" name="MAKER_CD"  value="${formData.MAKER_CD}" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchMakerCd'}" disabled="${form_MAKER_CD_D}" readOnly="true" required="${form_MAKER_CD_R}" />
                    <e:inputText id="MAKER_NM" style="${imeMode}" name="MAKER_NM" value="${formData.MAKER_NM}" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="true" required="${form_MAKER_NM_R}"/>
                </e:field>

				<e:label for="BRAND_CD" title="${form_BRAND_CD_N}" />
				<e:field>
				<e:inputText id="BRAND_CD" name="BRAND_CD" value="${formData.BRAND_CD}" width="${form_BRAND_CD_W}" maxLength="${form_BRAND_CD_M}" disabled="${form_BRAND_CD_D}" readOnly="${form_BRAND_CD_RO}" required="${form_BRAND_CD_R}" />
				</e:field>

                <e:label for="ORIGIN_CD" title="${form_ORIGIN_CD_N}" />
                <e:field>
                    <e:select id="ORIGIN_CD" name="ORIGIN_CD" value="${formData.ORIGIN_CD}" options="${originCdOptions}" width="${form_ORIGIN_CD_W}" disabled="${form_ORIGIN_CD_D}" readOnly="${form_ORIGIN_CD_RO}" required="${form_ORIGIN_CD_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" singleSelect="true" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
                <e:field>
                    <e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="${formData.MAKER_PART_NO}" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
                </e:field>
                <e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
                <e:field>
                    <e:select id="UNIT_CD" name="UNIT_CD" value="${formData.UNIT_CD}" options="${unitCdOptions}" width="${form_UNIT_CD_W}" disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}" required="${form_UNIT_CD_R}" placeHolder="" usePlaceHolder="true" useMultipleSelect="true" singleSelect="true"/>
                </e:field>
				<e:label for="CONV_QT" title="${form_CONV_QT_N}" />
				<e:field>
					<e:inputText id="CONV_QT" name="CONV_QT" value="${formData.CONV_QT}" width="40%" maxLength="${form_CONV_QT_M}" disabled="${form_CONV_QT_D}" readOnly="${form_CONV_QT_RO}" required="${form_CONV_QT_R}" />
					<e:text>/&nbsp;</e:text>
					<e:select id="GET_UNIT_CD" name="GET_UNIT_CD" value="${formData.GET_UNIT_CD}" options="${getUnitCdOptions}" width="50%" disabled="${form_GET_UNIT_CD_D}" readOnly="${form_GET_UNIT_CD_RO}" required="${form_GET_UNIT_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="VAT_CD" title="${form_VAT_CD_N}" />
                <e:field>
                    <e:select id="VAT_CD" name="VAT_CD" value="${formData.VAT_CD}" options="${vatCdOptions}" width="${form_VAT_CD_W}" disabled="${form_VAT_CD_D}" readOnly="${form_VAT_CD_RO}" required="${form_VAT_CD_R}" placeHolder=""/>
                </e:field>
                <e:label for="CMS_CTRL_USER_ID" title="${form_CMS_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="CMS_CTRL_USER_ID" name="CMS_CTRL_USER_ID" value="${formData.CMS_CTRL_USER_ID}" options="${cmsUserOptions}" width="${form_CMS_CTRL_USER_ID_W}" disabled="${form_CMS_CTRL_USER_ID_D}" readOnly="${form_CMS_CTRL_USER_ID_RO}" required="${form_CMS_CTRL_USER_ID_R}" placeHolder="" usePlaceHolder="true"/>
                </e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${formData.SG_CTRL_USER_ID}" options="${itemUserOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder=""  usePlaceHolder="true"/>
                </e:field>
				<e:inputHidden id="NOT_STD_TYPE" name="NOT_STD_TYPE"/>
				<e:inputHidden id="FI_MNG_NO" name="FI_MNG_NO"/>
				<e:inputHidden id="NOT_STD_REMARK" name="NOT_STD_REMARK"/>
            </e:row>
            <e:row>
                <e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
                <e:field>
                    <e:select id="ITEM_STATUS" name="ITEM_STATUS" value="${formData.ITEM_STATUS}" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
                </e:field>
                <e:label for="STD_TYPE" title="${form_STD_TYPE_N}"/>
                <e:field>
                    <e:select id="STD_TYPE" name="STD_TYPE" value="${formData.STD_TYPE}" options="${stdTypeOptions}" width="${form_STD_TYPE_W}" disabled="${form_STD_TYPE_D}" readOnly="${form_STD_TYPE_RO}" required="${form_STD_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="MOD_INFO" title="${form_MOD_INFO_N}" />
                <e:field>
                    <e:inputText id="MOD_INFO" name="MOD_INFO" value="${formData.MOD_INFO}" width="${form_MOD_INFO_W}" maxLength="${form_MOD_INFO_M}" disabled="${form_MOD_INFO_D}" readOnly="${form_MOD_INFO_RO}" required="${form_MOD_INFO_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CHG_REASON" title="${form_ITEM_CHG_REASON_N}"/>
				<e:field>
					<e:textArea id="ITEM_CHG_REASON" name="ITEM_CHG_REASON" value="${formData.ITEM_CHG_REASON}" height="120px" width="${form_ITEM_CHG_REASON_W}" maxLength="${form_ITEM_CHG_REASON_M}" disabled="${form_ITEM_CHG_REASON_D}" readOnly="${form_ITEM_CHG_REASON_RO}" required="${form_ITEM_CHG_REASON_R}" />
				</e:field>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="IT" height="80px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="searchPanel2" title="${IM03_009_CAPTION2}" labelWidth="${labelWidth}" width="100%" height="150px" columnCount="3" useTitleBar="true">
            <e:row>
                <e:field colSpan="2">
                    <e:fileManager id="IMG_ATT_FILE_NUM" name="IMG_ATT_FILE_NUM" fileId="${formData.IMG_ATT_FILE_NUM}" bizType="IMG" width="100%" height="150px" readOnly="${param.detailView ? true : false }" required="${form_IMG_ATT_FILE_NUM_R}" onFileAdd="_doUpload" onSuccess="_setImages" onAfterRemove="_setImages" maxFileCount="4" onError="onError"/>
                </e:field>
                <e:field colSpan="4">
                    <div id="mainImgContainer" style="width: 100%; height: 100%;"></div>
                    <e:inputHidden id="MAIN_IMG_SQ" name="MAIN_IMG_SQ" value="${formData.MAIN_IMG_SQ}" />
                </e:field>
            </e:row>
        </e:searchPanel>

		<!-- 상품상세이미지 -->
        <e:searchPanel id="searchPanel8" title="${IM03_009_CAPTION8}" labelWidth="${labelWidth}" width="100%" height="350px" columnCount="1" useTitleBar="true">
            <e:row>
                <e:label for="ITEM_DETAIL_URL" title="${form_ITEM_DETAIL_URL_N}" />
                <e:field>
                    <e:inputText id="ITEM_DETAIL_URL" name="ITEM_DETAIL_URL" value="${formData.ITEM_DETAIL_URL}" width="${form_ITEM_DETAIL_URL_W}" maxLength="${form_ITEM_DETAIL_URL_M}" disabled="${form_ITEM_DETAIL_URL_D}" readOnly="${form_ITEM_DETAIL_URL_RO}" required="${form_ITEM_DETAIL_URL_R}" />
					<e:text>&nbsp;</e:text>
					<e:button id="openImg" name="openImg" label="${openImg_N}" onClick="doopenImg" disabled="${openImg_D}" visible="${openImg_V}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2">
                    <e:fileManager id="ITEM_DETAIL_FILE_NUM" name="ITEM_DETAIL_FILE_NUM" fileId="${formData.ITEM_DETAIL_FILE_NUM}" bizType="IMG" width="100%" height="40px" readOnly="${param.detailView ? true : false }" required="${form_ITEM_DETAIL_FILE_NUM_R}" onFileAdd="_doUpload2" onSuccess="_setImages2" onAfterRemove="_setImages2" maxFileCount="1" onError="onError"/>
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2">
                    <div id="DetailImgContainer" style="width: 100%; height: 250px;"></div>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="searchPanel3" title="${IM03_009_CAPTION3}" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="true">
            <e:row>
	            <e:field colSpan="2">
	                <e:inputHidden id="ITEM_DETAIL_TEXT_NUM" name="ITEM_DETAIL_TEXT_NUM" value="${formData.ITEM_DETAIL_TEXT_NUM}" />
	                <e:richTextEditor height="200px" width="100%" disabled="false" required="false" id="TEXT_CONTENTS" readOnly="${param.detailView}" name="TEXT_CONTENTS" value="${TEXT_CONTENTS }"/>
	            </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="searchPanel3X" title="${IM03_009_CAPTION20}" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="true">
            <e:row>

				<e:textArea id="ITEM_RMK" name="ITEM_RMK" value="${formData.ITEM_RMK}" height="100px" width="${form_ITEM_RMK_W}" maxLength="${form_ITEM_RMK_M}" disabled="${form_ITEM_RMK_D}" readOnly="${form_ITEM_RMK_RO}" required="${form_ITEM_RMK_R}" />

            </e:row>
        </e:searchPanel>


        <!-- 상품기본정보 -->
        <e:searchPanel id="searchPanel7" title="${IM03_009_CAPTION7}" labelWidth="350px" width="100%" columnCount="1" useTitleBar="true">
            <e:row>
                <e:label for="ITEM_NOTC_DESC" title="${form_ITEM_NOTC_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_DESC" name="ITEM_NOTC_DESC" value="${formData.ITEM_NOTC_DESC}" width="${form_ITEM_NOTC_DESC_W}" maxLength="${form_ITEM_NOTC_DESC_M}" disabled="${form_ITEM_NOTC_DESC_D}" readOnly="${form_ITEM_NOTC_DESC_RO}" required="${form_ITEM_NOTC_DESC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_CERT" title="${form_ITEM_NOTC_CERT_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_CERT" name="ITEM_NOTC_CERT" value="${formData.ITEM_NOTC_CERT}" width="${form_ITEM_NOTC_CERT_W}" maxLength="${form_ITEM_NOTC_CERT_M}" disabled="${form_ITEM_NOTC_CERT_D}" readOnly="${form_ITEM_NOTC_CERT_RO}" required="${form_ITEM_NOTC_CERT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_ORIGIN" title="${form_ITEM_NOTC_ORIGIN_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_ORIGIN" name="ITEM_NOTC_ORIGIN" value="${formData.ITEM_NOTC_ORIGIN}" width="${form_ITEM_NOTC_ORIGIN_W}" maxLength="${form_ITEM_NOTC_ORIGIN_M}" disabled="${form_ITEM_NOTC_ORIGIN_D}" readOnly="${form_ITEM_NOTC_ORIGIN_RO}" required="${form_ITEM_NOTC_ORIGIN_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_MAKER" title="${form_ITEM_NOTC_MAKER_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_MAKER" name="ITEM_NOTC_MAKER" value="${formData.ITEM_NOTC_MAKER}" width="${form_ITEM_NOTC_MAKER_W}" maxLength="${form_ITEM_NOTC_MAKER_M}" disabled="${form_ITEM_NOTC_MAKER_D}" readOnly="${form_ITEM_NOTC_MAKER_RO}" required="${form_ITEM_NOTC_MAKER_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_AS" title="${form_ITEM_NOTC_AS_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_AS" name="ITEM_NOTC_AS" value="${formData.ITEM_NOTC_AS eq null ? '' : formData.ITEM_NOTC_AS }" width="${form_ITEM_NOTC_AS_W}" maxLength="${form_ITEM_NOTC_AS_M}" disabled="${form_ITEM_NOTC_AS_D}" readOnly="${form_ITEM_NOTC_AS_RO}" required="${form_ITEM_NOTC_AS_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

		<!-- 매입/매출 단가  -->
        <e:buttonBar id="tab2_btn1" align="right" width="100%" title="매입/매출 단가">
			<e:button id="setMng" name="setMng" label="${setMng_N}" onClick="dosetMng" disabled="${setMng_D}" visible="${setMng_V}"/>
			<e:button id="setAllApy" name="setAllApy" label="${setAllApy_N}" onClick="dosetAllApy" disabled="${setAllApy_D}" visible="${setAllApy_V}"/>
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDeleteCt" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridct" name="gridct" height="450px" readOnly="${param.detailView}" columnDef="${gridInfos.gridct.gridColData}"/>

        <e:panel id="hiddenP" height="0" width="0%">
            <e:gridPanel gridType="${_gridType}" id="gridat" name="gridat" height="0px" readOnly="${param.detailView}" columnDef="${gridInfos.gridat.gridColData}"/>
        </e:panel>

    </e:window>
</e:ui>