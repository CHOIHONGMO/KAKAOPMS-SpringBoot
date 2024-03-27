<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
	String devYn = PropertiesManager.getString("eversrm.system.developmentFlag");
%>

<c:set var="devYn" value="<%=devYn%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<!-- 전자인증 모듈 기본으로 설정 //-->
	<link rel="stylesheet" type="text/css" href="/ccc-sample_v1/unisignweb/rsrc/css/certcommon.css?v=1" />
	<script type="text/javascript" src="/ccc-sample_v1/unisignweb/js/unisignwebclient.js?v=1"></script>
	<!-- 전자인증 모듈 기본으로 설정 //-->

    <script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {

    	if ('${form.RFX_TYPE}' == 'RFQ') {
        	$('.e-window-container-header-text').text('${form_TITLE_CAPTION2_N}');    	
    	} else {
        	$('.e-window-container-header-text').text('${form_TITLE_CAPTION1_N}');    	
    	}
    	
        grid = EVF.getComponent("grid");
        grid.setProperty('panelVisible', ${panelVisible});
        grid.setColEllipsis (['R_ITEM_RMK'], true);
        grid.setColEllipsis (['Q_ITEM_RMK'], true);
        //버튼 제어 - 견적서 제출후 저장못하게 처리
        var buttonStatus = '${buttonStatus}';
        if (buttonStatus == 'Y') {
            //EVF.C('doSubmit').setVisible(true);
            //EVF.C('doDelete').setVisible(true);
            //EVF.C('doSave').setVisible(true);
        }else{
            //EVF.C('doSubmit').setVisible(false);
            //EVF.C('doDelete').setVisible(false);
            //EVF.C('doSave').setVisible(false);
            //EVF.C('EXCELDOWN').setVisible(false);
            //EVF.C('EXCELUP').setVisible(false);
        }

		
		        
	    

	      if(${_gridType eq "RG"}) {
	          <c:if test="${form.PURCHASE_TYPE == 'NORMAL' }">
	          grid.setColGroup([{
	            "groupName": '향후 원가 절감액',
	            "columns": [ "Y1_UNIT_PRC","Y2_UNIT_PRC", "Y3_UNIT_PRC" ]
	          }]);
	  		</c:if>

	      } else {
	    	    grid.setGroupCol(
	    		    	[
	    					{'colName' : 'Y1_UNIT_PRC', 'colIndex' : 3, 'titleText' : '향후 원가 절감액'}
	    		    	]
	    		    );	
	        }		    
	    
	    
	    
        <c:if test="${form.PROGRESS_CD != '2550' && form.PROGRESS_CD != '2500' && form.PROGRESS_CD != '1300'}">
	        grid.hideCol('SETTLE_YN',true);
		</c:if>
	    
        <c:if test="${form.PURCHASE_TYPE != 'NORMAL' }">
	        grid.hideCol('INVEST_CD',true);
	        grid.hideCol('INVEST_AMT',true);
	        grid.hideCol('Y1_UNIT_PRC',true);
	        grid.hideCol('Y2_UNIT_PRC',true);
	        grid.hideCol('Y3_UNIT_PRC',true);

	        grid.hideCol('DPRC_QT',true);
	        
	        grid.setColName('UNIT_PRC','${form_TEXT13_N}');
		</c:if>

		
	    
	    <c:if test="${form.MOLD_YN != '1' && form.RFX_TYPE == 'RFP'}">
	    grid.setColName('UNIT_PRC','${form_TEXT10_N}');
	    grid.setColName('ITEM_AMT','${form_TEXT11_N}');
	    grid.setColName('FIRST_UNIT_PRC','${form_TEXT12_N}');
	    
	    
	    $('#jqgh_grid_table_Y1_UNIT_PRC').text('입찰단가(Y+1)');
	    $('#jqgh_grid_table_Y2_UNIT_PRC').text('입찰단가(Y+2)');
	    $('#jqgh_grid_table_Y3_UNIT_PRC').text('입찰단가(Y+3)');
		</c:if>
		
		
		
		
        <c:if test="${form.MOLD_YN == '1' }">
	        grid.hideCol('Y1_UNIT_PRC',true);
	        grid.hideCol('Y2_UNIT_PRC',true);
	        grid.hideCol('Y3_UNIT_PRC',true);
	        grid.setColName('UNIT_PRC','${form_TEXT1_N}');
	        grid.setColName('ITEM_AMT','${form_TEXT2_N}');
	        grid.setColName('FIRST_UNIT_PRC','${form_TEXT3_N}');
	    </c:if>

	    
	    
	    
	    
        <c:if test="${form.SETTLE_TYPE != 'ITEM' }">
	        grid.hideCol('GIVEUP_FLAG',true);
		</c:if>

        if ('${param.qtaNum}' !== '') {
            EVF.getComponent('QTA_NUM').setValue('${param.qtaNum}');

            if ('${ses.userType}' == 'B') {
            	EVF.getComponent('VENDOR_CD').setDisabled(false);
            }            
            doSearch();

        } else if ('${param.rfxNum}' !== '') {
            var rfxNum = '${param.rfxNum}';
            var rfxCnt = '${param.rfxCnt}';

            EVF.getComponent('RFX_NUM').setValue(rfxNum);
            EVF.getComponent('RFX_CNT').setValue(rfxCnt);

            if ('${ses.userType}' == 'S') {
                EVF.getComponent('VENDOR_CD').setValue('${ses.companyCd}',false);
                EVF.getComponent('VENDOR_CD').setDisabled(true);
            }
            doSearch();
        }

        grid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	
        	
            if (celName === 'GIVEUP_FLAG') {
                if (value === "1") {
                    grid.setCellValue(rowId, "UNIT_PRC", 0);
                }
                calculateSum();
            }
        	
        	
            if (celName === 'SUB_ITEM') {
                if ("${param.detailView }" == 'false') {
                    var param = {
                        rowid: rowId,
                        rfxNo: grid.getCellValue(rowId, 'RFX_NUM'),
                        rfxCnt: grid.getCellValue(rowId, 'RFX_CNT'),
                        rfxSq: grid.getCellValue(rowId, 'RFX_SQ'),
                        qtaNum: grid.getCellValue(rowId, 'QTA_NUM'),
                        itemAmt : grid.getCellValue(rowId, 'ITEM_AMT'),
                        qtaSq: grid.getCellValue(rowId, 'QTA_SQ'),
//                        cur: EVF.getComponent(rowId, 'CUR').getValue(),
                        detailView: 'false',
                        callBackFunction: 'setSubItem'
                    };
                    everPopup.openQuotationSubItem(param);
                }
            } else if (celName === 'RC_ATT_FILE_NUM') {
                var uuid = grid.getCellValue(rowId, 'R_ATT_FILE_NUM');
                var param = {
                        havePermission: false,
                        attFileNum: uuid,
                        rowId: rowId,
                        callBackFunction: '_setFileUuidItemGrid',
                        bizType: 'RFQ'
                    };

                everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

            } else if (celName === 'QC_ATT_FILE_NUM') {
                var uuid = grid.getCellValue(rowId, 'Q_ATT_FILE_NUM');
                var param = {
                        havePermission: '${!param.detailView}',
                        attFileNum: uuid,
                        rowId: rowId,
                        callBackFunction: 'fileAttachPopupCallback',
                        bizType: 'QTA'
                    };

                everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

            } else if (celName === 'COST_ITEM_NEED') {

            	if(grid.getCellValue(rowId, 'COST_ITEM_NEED_FLAG') != 'Yes') {
            		return;
            	}


            	turl = '/eversrm/solicit/rfq/DH2150/view';

            	var detailViewValue = false;

            	if (buttonStatus == 'Y') {
            		detailViewValue = false;
            	} else {
            		detailViewValue = true;
            	}

            	var param = {
            		flag: '',
            		rowid: rowId,
            		COST_NUM : grid.getCellValue(rowId, 'COST_NUM'),
            		COST_CD  : grid.getCellValue(rowId, 'COST_CD'),
            		ITEM_CD : grid.getCellValue(rowId, 'ITEM_CD'),
            		ITEM_DESC : grid.getCellValue(rowId, 'ITEM_DESC'),
            		ITEM_SPEC : grid.getCellValue(rowId, 'ITEM_SPEC'),
            		RFX_QT : grid.getCellValue(rowId, 'RFX_QT'),
            		COST_TEXT : grid.getCellValue(rowId, 'COST_TEXT'),
            		MOLD_YN : '${form.MOLD_YN}',
                    detailView: ${param.detailView},
                    callBackFunction: 'setCostItemNeed',
                    url: turl,
                    "buttonStatus": buttonStatus
                };
                everPopup.openCostItemNeed(param);

            }
            
            if (celName == "Q_ITEM_RMK") {
            	setRowId = rowId;
        	    var param = {
        				  havePermission : true
        				, callBackFunction : 'setTextContents'
        				, TEXT_CONTENTS : grid.getCellValue(rowId, "Q_ITEM_RMK")
        				, detailView : false
        			};
      	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }	            

            if (celName == "R_ITEM_RMK") {
        	    var param = {
        				  havePermission : false
        				, callBackFunction : 'setTextContents'
        				, TEXT_CONTENTS : grid.getCellValue(rowId, "R_ITEM_RMK")
        			};
      	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }	            
            
            

        });


        grid.cellChangeEvent(function(rowId, celName, iRow, iCol, value, oldValue) {
            if (celName === 'UNIT_PRC') {
  
                if (grid.getCellValue(rowId,'COST_ITEM_NEED_FLAG') == 'Yes') {
                	alert('${DH2140_need_cost_item}' + grid.getCellValue(rowId,'ITEM_DESC'));
                    grid.setCellValue(rowId, celName, oldValue);
                    return;
                }
                	  
            	
            	
            	if (EVF.getComponent('CUR').getValue() === '') {
                    grid.setCellValue(rowId, celName, oldValue);
                    return;
                }

                if (Number(value) < 0) {
                    alert('${DH2140_0002}');
                    grid.setCellValue(rowId, celName, oldValue);
                    return;
                }
                calculateSum();
            }

            if (celName === 'VALID_FROM_DATE' || celName == 'QTA_DUE_DATE') {

                everDate.diffWithServerDate(value, function(status, message) {
                    if (status === '-1') {
                        alert('${DH2140_0003}');
                        grid.setCellValue(rowId, celName, oldValue);
                    } else {
                        if (grid.getCellValue(rowId, 'VALID_TO_DATE') < grid.getCellValue(rowId, 'VALID_FROM_DATE') && grid.getCellValue(rowId, 'VALID_TO_DATE') != '') {
                            alert('${DH2140_0004}');
                            grid.setCellValue(rowId, celName, oldValue);
                        }
                    }
                }, "true");
            }

            if (celName === 'VALID_TO_DATE') {
                if (grid.getCellValue(rowId, 'VALID_TO_DATE') < grid.getCellValue(rowId, 'VALID_FROM_DATE')) {
                    alert('${DH2140_0004}');
                    grid.setCellValue(rowId, celName, oldValue);
                }
            }

            if (celName === 'ITEM_CD') {
                var store = new EVF.Store();
                store.setParameter("itemCd", value);
                store.load("/common/util/getItemSearchByCode", function() {
                    if (this.getParameter('result') === 'null') {
                        grid.setCellValue(rowId, 'ITEM_CD', oldValue);
                    } else {
//                    gridUtil.setRowData(grid, nRow, JSON.parse(this.getParameter('result')), [{
//                        source: 'ITEM_DESC_ENG',
//                        target: 'ITEM_DESC'
//                    }]);
                    }
                });
            }

            if (celName === 'GIVEUP_FLAG') {
                if (value === "1") {
                    grid.setCellValue(rowId, "UNIT_PRC", 0);
                }
                calculateSum();
            }
        });

        if(EVF.C('SEND_DATE').getValue() == '') {
//			EVF.C('doSubmit').setVisible(true);
//            EVF.C('doSave').setVisible(true);
        }

		if(EVF.C('SEND_DATE').getValue() >= ' ' || '${param.detailView}' == 'true') {
//			EVF.C('doSubmit').setVisible(false);
//            EVF.C('doSave').setVisible(false);
		}
    }
    
	var setRowId;
	function setTextContents(tests) {
		grid.setCellValue(setRowId, "Q_ITEM_RMK",tests);
	}          
    

    function setCostItemNeed(costNum, rowId, unitPrc) {
    	grid.setCellValue(rowId, 'COST_ITEM_NEED', 'Yes');
    	grid.setCellValue(rowId, 'COST_NUM', costNum);
    	grid.setCellValue(rowId, 'UNIT_PRC', unitPrc);
    	var tQty = grid.getCellValue(rowId, 'RFX_QT');
    	var rawCostAmt = parseFloat(unitPrc) * parseFloat(tQty);
    	grid.setCellValue(rowId, 'ITEM_AMT', rawCostAmt);

    	calculateSum();
    }

    function changeVendor(obj, selectedVendor, oldVendor) {
        var param = {
            "rfxNum" : '${param.rfxNum}',
            "rfxCnt" : '${param.rfxCnt}',
            "vendorCd" : selectedVendor,
            "detailView": false
        };
        location.href=baseUrl+'DH2140/view.so?'+ $.param(param);
    }

    function fileAttachCallback(result) {
        EVF.getComponent('ATT_FILE_NUM').setValue(result.UUID);
    }

    function doSearch() {

        if ('${param.rfxNum}' !== '') {
            var rfxNum = '${param.rfxNum}';
            var rfxCnt = '${param.rfxCnt}';
            var isPreferredBidder = ${empty param.isPrefferedBidder ? false : param.isPrefferedBidder};
        }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "DH2140/doSearch", function() {

            <%--if (EVF.getComponent('VALID_TO_DATE').getValue() === '') {--%>
                    <%--EVF.getComponent('VALID_TO_DATE').setValue('${toDate}');--%>
            <%--}--%>
            //EVF.getComponent('VENDOR_CD').setDisplayText(EVF.getComponent('VENDOR_NM').getValue());
            //EVF.getComponent('isPrefferedBidder').setValue(isPrefferedBidder);

            <%-- 우선협상 대상자 --%>
            if(isPreferredBidder) {
                for(var i=0; i < grid.getRowCount(); i++) {
                    var awardFlag = grid.getCellValue(i, 'AWARD_FLAG');
                    if(awardFlag === '0') {
                        //gridUtil.setCellActivation(grid, 'UNIT_PRC', i, 'activatenoedit');
                        //gridUtil.setCellActivation(grid, 'QTA_DUE_DATE', i, 'activatenoedit');
                        //gridUtil.setCellActivation(grid, 'VALID_FROM_DATE', i, 'activatenoedit');
                        //gridUtil.setCellActivation(grid, 'VALID_TO_DATE', i, 'activatenoedit');
                    }
                }
            }

            grid.checkAll(true);
        });

    }

    function doSubmit() {
        saveSubmit('1');
    }

    function doSave() {
        saveSubmit('0');
    }

    function saveSubmit(saveType) {

    	if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}
		
        var store = new EVF.Store();
        if(!store.validate()) { return; }

        for(var i = 0; i < grid.getRowCount(); i++) {
            if (grid.getCellValue(i, 'GIVEUP_FLAG') == '1') {
            	continue;	
            }

            <%-- 원가계산서 로직 --%>
        	if(grid.getCellValue(i, 'COST_ITEM_NEED_FLAG') === 'Yes' &&
        		grid.getCellValue(i, 'COST_NUM') === '') {
        		<%-- alert('원가계산서가 필요한 품목입니다. 원가계산서를 작성하시기 바랍니다 품명 : ' + grid.getCellValue(i, 'ITEM_DESC')); --%>
        		alert('${DH2140_need_cost_item}' + grid.getCellValue(i, 'ITEM_DESC'));
        		return;
        	}

        	if(Number(grid.getCellValue(i, 'UNIT_PRC')) == 0 || Number(grid.getCellValue(i, 'ITEM_AMT')) == 0 ) {
        		alert('${DH2140_zero_unit_prc}' + grid.getCellValue(i, 'ITEM_DESC'));
        		return;
        	}

        	
        	<c:if test="${form.PURCHASE_TYPE == 'NORMAL' && form.MOLD_YN != '1'}">
	            if(   
	            	  //Number(grid.getCellValue(i, 'INVEST_AMT')) == 0 

	                  Number(grid.getCellValue(i, 'Y1_UNIT_PRC')) == 0 
	               || Number(grid.getCellValue(i, 'Y2_UNIT_PRC')) == 0 
	               || Number(grid.getCellValue(i, 'Y3_UNIT_PRC')) == 0 
	              ) {
	            	alert('${DH2140_1001}');
	            	return;
	            }
			</c:if>
        }

        var valid = grid.validate()
		, selRows = grid.getSelRowValue();

        if (!valid.flag) {
			alert( valid.msg );
		    return;
		}
        
        var settle = EVF.getComponent('SETTLE_TYPE').getValue();
        if (EVF.getComponent('SETTLE_TYPE').getValue() == 'DOC') {

            for (var s = 0; s < grid.getRowCount(); s++) {
            	var giveup = grid.getCellValue(s, 'GIVEUP_FLAG');
                if (grid.getCellValue(s, 'GIVEUP_FLAG') == '1') {
                    alert('${DH2140_0007}');
                    return;
                }
            }
        }

        var a = EVF.getComponent('VALID_TO_DATE').getValue();

        var isPreferedBidder = '${param.isPrefferedBidder}';
        if (isPreferedBidder === true) {
            status = '1';
        }
        if (status === '-1') {
            alert('${DH2140_0003}');
            EVF.getComponent('VALID_TO_DATE').setValue('${toDate}');
        } else {

            var countAward = 0;
    		for( var i = 0, len = selRows.length; i < len; i++ ) {
                if (grid.getCellValue(i, 'GIVEUP_FLAG') == '1') {
                	
                	continue;
                }

    			
    			
    			var giveUpFlag = selRows[i].GIVEUP_FLAG;
    			if (giveUpFlag == '1') {
                    //grid.setCellValue('SELECTED', i, '0');
                    grid.checkRow(i, false);
                } else {
                    if (parseInt(selRows[i].UNIT_PRC) == 0) return alert("${msg.M0014}");
                }
    		}

            // if (!gridUtil.gridRequired(grid, "SELECTED", "${msg.M0014}")) return;
            //if(!grid.validate().flag) { return alert('${msg.M0014}') }

            //if(!grid.validateExcept(["INVEST_AMT", "Y1_UNIT_PRC", "Y2_UNIT_PRC", "Y3_UNIT_PRC"]).flag) { return alert('${msg.M0014}') }
            //if(!grid.validateExcept(['SELECT_CANDIDATE']).flag) 

            
            
            //Excel Upload 유효성 Check
           // excelUploadCheck();

            var msg = saveType == '0' ? "${msg.M0021}" : "${msg.M0060}";
            if (!confirm(msg)) return;


         	// 전송시에만 전자서명 ==========
        	if(saveType == '1' && '${form.PUB_CERT_YN}' == '1')
        	{

    			//RFX_NUM + “/” + RFX_CNT + “/” + RFX_SQ + “/” + QTA_NUM + “/” + QTA_SQ + “/” + 품명 + “/” + 규격 + “/”
				//		+ EverMath.EverNumberType(수량, “#,##0.00”) + “/” + EverMath.EverNumberType(견적단가, “#,##0.00”) + “/” + EverMath.EverNumberType(견적금액, “#,##0.00”)

				var RFX_NUM = EVF.getComponent('RFX_NUM').getValue();
				var RFX_CNT = EVF.getComponent('RFX_CNT').getValue();
				var QTA_NUM = EVF.getComponent('QTA_NUM').getValue();
				// 개발서버인 경우 사업자번호 : 
				var ssn;
				if ('${devYn}' == 'true') {
					ssn = '1234567890';
				} else {
					ssn = EVF.getComponent('IRS_NUM').getValue();
				}
				
				var textBox = "";

				
				
				
//				alert(selRows.length)
				for( var i = 0, len = selRows.length; i < len; i++ ) {
	    			var RFX_SQ = selRows[i].RFX_SQ;
	
	    			
	    			
	    			var QTA_SQ = selRows[i].QTA_SQ;
	    			var ITEM_DESC = selRows[i].ITEM_DESC;
	    			var ITEM_SPEC = selRows[i].ITEM_SPEC;
	    			//var RFX_QT = everMath.EverNumberType(selRows[i].RFX_QT, "#,##0.00");
	    			//var UNIT_PRC = everMath.EverNumberType(selRows[i].UNIT_PRC, "#,##0.00");
	    			//var ITEM_AMT = everMath.EverNumberType(selRows[i].ITEM_AMT, "#,##0.00");

	    			
	    			var RFX_QT = comma(String(selRows[i].RFX_QT));
	    			
	    			var UNIT_PRC = comma(String(selRows[i].UNIT_PRC));
	    			
	    			
	    			var ITEM_AMT = comma(String(selRows[i].ITEM_AMT));

	    			textBox = textBox + RFX_NUM + "/" + RFX_CNT + "/" + RFX_SQ + "/" + QTA_NUM + "/" + QTA_SQ + "/" + ITEM_DESC + "/" + ITEM_SPEC + "/" + RFX_QT + "/" + UNIT_PRC + "/" + ITEM_AMT + "/";
	    		}

				var signedTextBox = document.getElementById('SIGN_VALUE');

                unisign.SignDataNVerifyVID( textBox, null, ssn,
                        function(rv, signedText, certAttrs) {
                            //alert(signedText);
                            //return;
                            signedTextBox.value = signedText;
                            var tSIGN_VALUE = EVF.getComponent('SIGN_VALUE').getValue();
                            //alert("main signedText================"+tSIGN_VALUE);

                            if (
                                    //'${irsnoCheckFlag}' == 'true' &&
                                    (null === signedTextBox.value
                                    || '' === signedTextBox.value || false === rv )) {
                                unisign.GetLastError(
                                        function(errCode, errMsg) {
                                            if (errCode == "43050000") {
                                                alert("${msg.M0116 }"); //인증서 본인확인에 실패했습니다.
                                            } else {
                                                alert('Error code : ' + errCode + '\n\nError Msg : ' + errMsg);
                                            }
                                        }
                                );
                            } else {
                                var store = new EVF.Store();
                                store.setGrid([grid]);
                                store.getGridData(grid, 'all');
                                store.setParameter('saveType', saveType);
                                store.doFileUpload(function() {
                                    store.load(baseUrl + "DH2140/doSave", function() {
                                        EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                                        alert(this.getResponseMessage());

                                        opener['doSearch']();
                                        var param = {
                                            "rfxNum" : '${param.rfxNum}',
                                            "rfxCnt" : '${param.rfxCnt}',
                                            "vendorCd" : EVF.C('VENDOR_CD').getValue(),
                                            "detailView": false
                                        };
                                        window.close();
                                        //   			                    location.href=baseUrl+'DH2140/view.so?'+ $.param(param);
                                    });
                                });
                            }

                        }
                );
            }
        	else //저장
        	{
        		var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'all');
	            store.setParameter('saveType', saveType);
	            store.doFileUpload(function() {
	                store.load(baseUrl + "DH2140/doSave", function() {
	                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');
	                	
	                    alert(this.getResponseMessage());
	                    
	                    opener['doSearch']();
	                    var param = {
	                        "rfxNum" : '${param.rfxNum}',
	                        "rfxCnt" : '${param.rfxCnt}',
	                        "vendorCd" : EVF.C('VENDOR_CD').getValue(),
	                        "detailView": false
	                    };
	                    //window.close();
	                    location.href=baseUrl+'DH2140/view.so?'+ $.param(param);
	                });
	            });
        	}
        }
    }

    function comma(obj) {
        var regx = new RegExp(/(-?\d+)(\d{3})/);
        var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
        var strArr = obj.split('.');
        while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
            //정수 부분에만 콤마 달기
            strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
        }
        if (bExists > -1) {
            //. 소수점 문자열이 발견되지 않을 경우 -1 반환
            obj = strArr[0] + "." + strArr[1];
        } else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
            obj = strArr[0];
        }
        return obj;//문자열 반환
    }


    function doDelete() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}
		
        if (EVF.getComponent("QTA_NUM").getValue() == "") return alert("${msg.M0004 }");

        if (!confirm("${msg.M0013 }")) return;

        var store = new EVF.Store();
        store.load(baseUrl + "DH2140/doDelete", function() {
        	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');
        	
            alert(this.getResponseMessage());
            if (opener !== undefined && opener.doSearch !== undefined) opener.doSearch();
            window.close();
        });
    }

    function setSubItem(subItemJson, rowId) {
        grid.setCellValue(rowId, 'SUB_ITEM_JSON', subItemJson);
    }

    function fileAttachPopupCallback(gridRowId, fileId, fileCount) {
    	grid.setCellValue(gridRowId, 'QC_ATT_FILE_NUM', fileCount);
    	grid.setCellValue(gridRowId, 'Q_ATT_FILE_NUM', fileId);
    }

    //금액 자동계산
    function calculateSum() {
        var qtaATM = 0;
        var currency = EVF.getComponent('CUR').getValue();
        for (var i = 0; i < grid.getRowCount(); i++) {

            if (grid.getCellValue(i, 'GIVEUP_FLAG') == '1') {
            	continue;
            }

        	
        	var price = everCurrency.getPrice(currency, grid.getCellValue(i, 'UNIT_PRC'));
            var qty = everCurrency.getQty(currency, grid.getCellValue(i, 'RFX_QT'));

            grid.setCellValue(i, 'ITEM_AMT', everCurrency.getAmount(currency, price * qty));
            qtaATM = qtaATM + everCurrency.getAmount(currency, price * qty);
        }

        EVF.getComponent('QTA_AMT').setValue(qtaATM);
    }

    function doClose() {
        formUtil.close();
    }

    function doRequest() {
        var param = {
            gateCd: EVF.getComponent('GATE_CD').getValue(),
            rfxNum: EVF.getComponent('RFX_NUM').getValue(),
            rfxCnt: EVF.getComponent('RFX_CNT').getValue(),
            rfxType: 'RFQ',
            detailView: true
        };
        everPopup.openRfxDetailInformation(param);
    }

    function EXCELDOWN() {

    	alert('${DH2140_003}');

		grid.delAllRow();
    	grid.hideCol('IMAGE', true);

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "DH2140/doSearch", function() {
        	 grid.excelExport({
                    allCol : "${excelExport.allCol}",
                    selRow : "${excelExport.selRow}",
                    fileType : "${excelExport.fileType }",
                    fileName : "${screenName }",
                    excelOptions : {
                        imgWidth      : 0.12,       <%-- // 이미지의 너비. --%>
                        imgHeight     : 0.26,      <%-- // 이미지의 높이. --%>
                        colWidth      : 20,        <%-- // 컬럼의 넓이. --%>
                        rowSize       : 500,       <%-- // 엑셀 행에 높이 사이즈. --%>
                        attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                    }
                }).call();
        });
	}

	function EXCELUP() {
		   grid.delAllRow();
		   grid.excelImport(
					{ 'append' : true }
					, excelUploadCallBack
				).call( grid );
	}

	function excelUploadCallBack( msg, code ) {
    	grid.checkAll(true);
    	alert('${msg.M0001}');
    	//엑셀업로드 유효성체크는 저장/전송 시점으로 이관
    	//excelUploadCheck();
    	calculateSum();
    }

	//엑셀업로드 유효성체크
	function excelUploadCheck(){
		for (var i = 0; i < grid.getRowCount(); i++) {
            //var BUYER_REQ_CD = grid.getCellValue(i, 'BUYER_REQ_CD');
            var rfxNum = grid.getCellValue(i, 'RFX_NUM');
            var rfxCnt = grid.getCellValue(i, 'RFX_CNT');
            var rfxSq = grid.getCellValue(i, 'RFX_SQ');
            var vendorCd = grid.getCellValue(i, 'VENDOR_CD');
            var qtaNum = grid.getCellValue(i, 'QTA_NUM');
            var qtaSq = grid.getCellValue(i, 'QTA_SQ');

            var RFX_NUM = EVF.getComponent('RFX_NUM').getValue();
            var QTA_NUM = EVF.getComponent('QTA_NUM').getValue();

            if(RFX_NUM != rfxNum){
            	alert('${DH2140_001}'); 	return;
            }
            if(rfxNum == ''){
            	alert(everString.getMessage("${msg.M0109}", "요청번호")); return;
            }
            if(rfxCnt == ''){
            	alert(everString.getMessage("${msg.M0109}", "요청차수")); return;
            }
            if(rfxSq == ''){
            	alert(everString.getMessage("${msg.M0109}", "요청항번")); return;
            }
            if(vendorCd == ''){
            	alert(everString.getMessage("${msg.M0109}", "협력회사코드")); return;
            }

            if(QTA_NUM != ''){
	            if(qtaNum == ''){
	            	alert(everString.getMessage("${msg.M0109}", "견적서번호")); return;
	            }
	            if(qtaSq == ''){
	            	alert(everString.getMessage("${msg.M0109}", "견적서항번")); return;
	            }
	           	if(QTA_NUM != qtaNum){
	           		alert('${DH2140_002}'); 	return;
	            }
            }
        }
	}
	</script>

    <e:window id="DH2140" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
        <e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.CTRL_USER_ID}"/>

        <e:buttonBar>
		<c:if test="${ses.userType == 'B' }">
            <e:text style="font-weight: bold;">▣ ${form_VENDOR_CD_N} : </e:text>
            <e:select id="VENDOR_CD" name="VENDOR_CD" value="${param.vendorCd}" options="${refVendorValue}" width="300" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" placeHolder="" onChange="changeVendor" usePlaceHolder="false" />
		</c:if>
		<c:if test="${ses.userType != 'B' }">
			<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.vendorCd}"/>
		</c:if>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' align="right" />
            <e:button label='${doSubmit_N }' id='doSubmit' onClick='doSubmit' disabled="${doSubmit_D }" visible="${form.QT_YN == 'Y' ? true : false }" align="right"/>
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled="${doSave_D }" visible="${form.QT_YN == 'Y' ? true : false }" align="right"/>
        </e:buttonBar>
        <e:searchPanel id="form" title="${form_CAPTION1_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
            <c:if test="${ses.userType == 'B'}">
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
                <e:field>
                    <e:inputText id="RFX_NUM" name="RFX_NUM" align="center" value="${form.RFX_NUM}" width="${inputTextWidth }" maxLength="${form_RFX_NUM_M}" disabled="true" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                    <e:text>/</e:text>
                    <e:inputNumber id="RFX_CNT" name="RFX_CNT" align="center" value="${form.RFX_CNT}" maxValue="${form_RFX_CNT_M}" width="30" decimalPlace="${form_RFX_CNT_NF}" disabled="true" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
					<!-- e:button label='${doRequest_N }' id='doRequest' onClick='doRequest' visible='${doRequest_V }' data='${doRequest_A }' align="left"/-->
                    <e:inputHidden id='BUYER_NM' name="BUYER_NM" value="${form.BUYER_NM}" />
                    <e:inputHidden id='SEND_DATE' name="SEND_DATE" value="${form.SEND_DATE}" />
                    <e:inputHidden id='GATE_CD' name="GATE_CD" value="${form.GATE_CD}" />
                    <e:inputHidden id='BUYER_CD' name="BUYER_CD" value="${form.BUYER_CD}" />
                    <e:inputHidden id='VENDOR_NM' name="VENDOR_NM" value="${form.VENDOR_NAME}" />
                    <e:inputHidden id='IRS_NUM' name="IRS_NUM" value="${form.IRS_NUM}" />
                    <e:inputHidden id="SIGN_VALUE" name="SIGN_VALUE" value="" />
                    <e:inputHidden id='SETTLE_TYPE' name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" />
                    <e:inputHidden id='MOLD_YN' name="MOLD_YN" value="${form.MOLD_YN}" />
                    <e:inputHidden id='PUB_CERT_YN' name="PUB_CERT_YN" value="${form.PUB_CERT_YN}" />

                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="true" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
			</c:if>                
            <c:if test="${ses.userType == 'S'}">
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="RFX_NUM" name="RFX_NUM" align="center" value="${form.RFX_NUM}" width="${inputTextWidth }" maxLength="${form_RFX_NUM_M}" disabled="true" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                    <e:text>/</e:text>
                    <e:inputNumber id="RFX_CNT" name="RFX_CNT" align="center" value="${form.RFX_CNT}" maxValue="${form_RFX_CNT_M}" width="30" decimalPlace="${form_RFX_CNT_NF}" disabled="true" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
					<!-- e:button label='${doRequest_N }' id='doRequest' onClick='doRequest' visible='${doRequest_V }' data='${doRequest_A }' align="left"/-->
                    <e:inputHidden id='BUYER_NM' name="BUYER_NM" value="${form.BUYER_NM}" />
                    <e:inputHidden id='SEND_DATE' name="SEND_DATE" value="${form.SEND_DATE}" />
                    <e:inputHidden id='GATE_CD' name="GATE_CD" value="${form.GATE_CD}" />
                    <e:inputHidden id='BUYER_CD' name="BUYER_CD" value="${form.BUYER_CD}" />
                    <e:inputHidden id='VENDOR_NM' name="VENDOR_NM" value="${form.VENDOR_NAME}" />
                    <e:inputHidden id='IRS_NUM' name="IRS_NUM" value="${form.IRS_NUM}" />
                    <e:inputHidden id="SIGN_VALUE" name="SIGN_VALUE" value="" />
                    <e:inputHidden id='SETTLE_TYPE' name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" />
                    <e:inputHidden id='MOLD_YN' name="MOLD_YN" value="${form.MOLD_YN}" />
                </e:field>
			</c:if>
            </e:row>
            <e:row>
					<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}"/>
					<e:field>
					<e:inputText id="RFX_SUBJECT" style="ime-mode:auto" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="90%" maxLength="${form_RFX_SUBJECT_M}" disabled="true" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}"/>
					</e:field>
	                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
	                <e:field>
	                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='true' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
	                    </e:select>
	                </e:field>            
            </e:row>
            <c:if test="${ses.userType == 'B'}">
            
            <e:row>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenType }" width="${inputTextWidth }" disabled="true" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
					<e:text> / </e:text>
                    <e:select id="SUBMIT_TYPE" onChange="clearTplNum" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="${inputTextWidth }" disabled="true" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>              
                
                <e:label for="PRC_STL_TYPE" title="${form_PRC_STL_TYPE_N}"/>
                <e:field>
                    <e:select id="PRC_STL_TYPE" name="PRC_STL_TYPE" value="${form.PRC_STL_TYPE}" options="${prcStlType }" width="${inputTextWidth }" disabled="true" readOnly="${form_PRC_STL_TYPE_RO}" required="${form_PRC_STL_TYPE_R}" placeHolder="" />
                    <e:text> / </e:text>
<%--
                    <e:select id="SETTLE_TYPE"  name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" options="${settleType}" width='${inputTextWidth }' required='${form_SETTLE_TYPE_R }' readOnly='${form_SETTLE_TYPE_RO }' disabled='true' visible='${form_SETTLE_TYPE_V }' placeHolder='${placeHolder }' />
 --%>
                </e:field>
                
            </e:row>

			</c:if>

            <e:row>
				<e:label for="RFQ_START_END_DATE" title="${form_RFQ_START_END_DATE_N}"/>
				<e:field colSpan="3">
					<e:text> ${form.RFQ_START_END_DATE } </e:text>
				</e:field>
			</e:row>
        </e:searchPanel>
        <e:searchPanel id="form2" title="${form_CAPTION2_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>


            <c:if test="${form.RFX_TYPE == 'RFQ'}">
                <e:label for="QTA_NUM" title="${form_QTA_NUM_N}"/>
			</c:if>
            <c:if test="${form.RFX_TYPE == 'RFP'}">
                <e:label for="QTA_NUM" title="${form_QTA_NUM2_N}"/>
			</c:if>


                <e:field colSpan="3">
                    <e:inputText id="QTA_NUM" name="QTA_NUM" value="${form.QTA_NUM}" width="${inputTextWidth }" maxLength="${form_QTA_NUM_M}" disabled="${form_QTA_NUM_D}" readOnly="${form_QTA_NUM_RO}" required="${form_QTA_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PIC_USER_NM" title="${form_PIC_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="PIC_USER_NM" style="${imeMode}" name="PIC_USER_NM" value="${form.PIC_USER_NM}" width="${inputTextWidth }" maxLength="${form_PIC_USER_NM_M}" disabled="${form_PIC_USER_NM_D}" readOnly="${form_PIC_USER_NM_RO}" required="${form_PIC_USER_NM_R}" />
                </e:field>
                <e:label for="PIC_TEL_NUM" title="${form_PIC_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id="PIC_TEL_NUM" name="PIC_TEL_NUM" value="${form.PIC_TEL_NUM}" width="${inputTextWidth }" maxLength="${form_PIC_TEL_NUM_M}" disabled="${form_PIC_TEL_NUM_D}" readOnly="${form_PIC_TEL_NUM_RO}" required="${form_PIC_TEL_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="QTA_AMT" title="${form_QTA_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="QTA_AMT" name="QTA_AMT" value="${form.QTA_AMT}" maxValue="${form_QTA_AMT_M}" width="${inputTextWidth}" decimalPlace="${form_QTA_AMT_NF}" disabled="${form_QTA_AMT_D}" readOnly="${form_QTA_AMT_RO}" required="${form_QTA_AMT_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id='CUR' name="CUR" value="${form.CUR}" width='50' disabled="true" maxLength="10" required="false" readOnly="true"/>
					<e:text>&nbsp;</e:text>
					<e:select id="VAT_TYPE" name="VAT_TYPE" value="${form.VAT_TYPE}" options="${vatTypeOptions}" width="${inputTextWidth}" disabled="${form_VAT_TYPE_D}" readOnly="${form_VAT_TYPE_RO}" required="${form_VAT_TYPE_R}" placeHolder="" />
                </e:field>

                <e:label for="VALID_TO_DATE" title="${form_VALID_TO_DATE_N}"/>
                <e:field>
                    <e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE" value="${form.VALID_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_VALID_TO_DATE_R}" disabled="${form_VALID_TO_DATE_D}" readOnly="${form_VALID_TO_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="QTA_RMK_TEXT_NUM" title="${form_QTA_RMK_TEXT_NUM_N}"/>
                <e:field colSpan="3">
                    <e:richTextEditor height="200" id="QTA_REMARK_TEXT" name="QTA_REMARK_TEXT" value="${form.QTA_RMK_TEXT}" width="100%" maxLength="${form_QTA_RMK_TEXT_NUM_M}" disabled="${form_QTA_RMK_TEXT_NUM_D}" readOnly="${form_QTA_RMK_TEXT_NUM_RO}" required="${form_QTA_RMK_TEXT_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="QTA" fileId="${form.ATT_FILE_NUM}" width="100%" height="120px" readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}" />
                    <e:inputHidden id='isPrefferedBidder' name="isPrefferedBidder" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>
<script type="text/javascript" src="/ccc-sample_v1/UniSignWeb_Multi_Init_Nim.js?v=1"></script>