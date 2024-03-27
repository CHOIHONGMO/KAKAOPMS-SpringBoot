<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
        grid = EVF.C("grid");grid.setProperty('panelVisible', ${panelVisible});
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
        grid.setColEllipsis (['SETTLE_RMK'], true);

		if(${_gridType eq "RG"}) {
			grid.setColGroup([{
				"groupName": '향후 원가 절감액',
				"columns": [ "Y1_UNIT_PRC", "Y2_UNIT_PRC", "Y3_UNIT_PRC" ]
			}])
		} else {
			grid.setGroupCol(
					[
						{'colName': 'Y1_UNIT_PRC', 'colIndex': 3, 'titleText': '향후 원가 절감액'}
					]
			);
		}
        
        // 진행상태가 "유찰, 재견적, 업체선정완료"이면 "유찰, 재견적, 협력회사선정" 버튼 보이지 않도록 함

        
        var progress_cd = EVF.getComponent('PROGRESS_CD').getValue();
        if (//progress_cd == '2500' || 부분 업체 선정을 위해서 버튼이 나오게 한다. 
        		progress_cd == '2550' || progress_cd == '1300') {
        	EVF.C('doPRRestore').setVisible(false);
        	EVF.C('doRe').setVisible(false);
        	EVF.C('doFinal').setVisible(false);
        }
        
        <c:if test="${form.PURCHASE_TYPE != 'NORMAL' }">
        grid.hideCol('INVEST_AMT',true);
        grid.hideCol('Y1_UNIT_PRC',true);
        grid.hideCol('Y2_UNIT_PRC',true);
        grid.hideCol('Y3_UNIT_PRC',true);
		</c:if>
	
	    <c:if test="${form.SUBMIT_TYPE != 'RO' }">
	    grid.hideCol('APERABPER',true);
	    grid.hideCol('TOTAL_JUMSU',true);
	    grid.hideCol('AMT_JUMSU',true);
	    grid.hideCol('EVAL_JUMSU',true);
		</c:if>
	    <c:if test="${form.PRC_STL_TYPE != 'LMT' }">
	    grid.hideCol('LIMIT_PRC',true);
		</c:if>
        

        <c:if test="${form.MOLD_YN == '1' }">
        grid.hideCol('Y1_UNIT_PRC',true);
        grid.hideCol('Y2_UNIT_PRC',true);
        grid.hideCol('Y3_UNIT_PRC',true);
		grid.setColName('Q_UNIT_PRC','${form_TEXT1_N}');
		grid.setColName('Q_ITEM_AMT','${form_TEXT2_N}');
		</c:if>
		
		
		
		
        grid.cellChangeEvent(function(rowId, celName, iRow, iCol, value, oldValue) {
        	if (celName == "AWARD") {
        		
        		if (grid.getCellValue(rowId,'GIVEUP_FLAG')  ==  '1') {
					alert('${BSOX_290_005}');
        			grid.setCellValue(rowId,'AWARD',oldValue);
        			return;
        		}

        		
        		if (grid.getCellValue(rowId,'EXEC_YN')  ==  'Y') {
					alert('${BSOX_290_006}');
        			grid.setCellValue(rowId,'AWARD',oldValue);

        		}
        		
        		
        	}        	
        });
        
        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	if (celName == "VENDOR_NM") {
        		var params = {
	                VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }
        	else if (celName == "QTA_NUM") {

    	        var param = {
    		            gateCd: grid.getCellValue(rowId,'${ses.gateCd}'),
    		            rfxNum: EVF.getComponent('RFX_NUM').getValue(),
    		            qtaNum : grid.getCellValue(rowId,'QTA_NUM'),
    		            rfxCnt: EVF.getComponent('RFX_CNT').getValue(),
    		            //rfxType: selectedRow['RFX_TYPE'],
    		            popupFlag: true,
    		            //callBackFunction: "doSearch"
    		            detailView: true,
    		            "isPrefferedBidder": false,
    		            "buttonStatus" : 'Y',
    		            vendorCd: grid.getCellValue(rowId,'VENDOR_CD')
    		    };
    		    everPopup.openPopupByScreenId('DH2140', 1000, 800, param);                  
        	
        	}
        	else if (celName == "ITEM_CD") {
	            var param = {
			        	ITEM_CD: grid.getCellValue(rowId,"ITEM_CD")
			        };

		        everPopup.openItemDetailInformation(param);
	        }
        	else if (celName === 'COST_ITEM_NEED') {
        		var costNeed = grid.getCellValue(rowId, "COST_ITEM_NEED");

        		if(costNeed == 'Yes'){
        			var itemC = grid.getCellValue(rowId, 'ITEM_CLASS_CD');

                	if( itemC == 'IMPORT' || itemC == 'SPEC' || itemC == 'ISP' || 1==1)
                	{
                		var turl = '';
                    	turl = '/eversrm/solicit/rfq/DH2150/view';

                		var param = {
                			flag: itemC,
                			rowid: rowId,
                			COST_NUM: grid.getCellValue(rowId, 'COST_NUM'),
                			COST_CD: '',

                    		ITEM_CD : grid.getCellValue(rowId, 'ITEM_CD'),
                    		ITEM_DESC : grid.getCellValue(rowId, 'ITEM_DESC'),
                    		ITEM_SPEC : grid.getCellValue(rowId, 'ITEM_SPEC'),
                    		RFX_QT : grid.getCellValue(rowId, 'RFX_QT'),
                			
                			
                			detailView: 'true',
                            callBackFunction: 'setCostItemNeed',
                            url: turl,
                            "buttonStatus": 'N'
                        };
                        everPopup.openCostItemNeed(param);
                	}else{
                		//alert("품목구분이 수입품,제작품,ISP 가 아닐 경우 원가계산서 대상이 아닙니다.");
                		alert('${BSOX_290_001}');
                	}
        		}
            }
        	
        	if (celName == "SETTLE_RMK") {
            	setRowId = rowId;
        	    var param = {
        				  havePermission : true
        				, callBackFunction : 'setTextContents2'
        				, TEXT_CONTENTS : grid.getCellValue(rowId, "SETTLE_RMK")
        				, detailView : false
        			};
      	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }	
        });

        <%--
        if ('${param.detailView}' == 'true') {
            WUX.getComponent("doAward").setVisible(false);
        }
        --%>

        if ('${param.rfxNum}' !== '') {
            EVF.getComponent('RFX_NUM').setValue('${param.rfxNum}');
            EVF.getComponent('RFX_CNT').setValue('${param.rfxCnt}');

            doSearch();
        }

        //if ('${param.negoFlag}' === '1') {
        //    formUtil.setVisible(['doQuotecomparison', 'doTable', 'doPRRestore', 'doRe', 'doAward', 'doFinal'], false);
        //    formUtil.setVisible(['doFailBid', 'doSelect'], true);
        //}

    }
	var setRowId;
	function setTextContents2(tests) {
		grid.setCellValue(setRowId, "SETTLE_RMK",tests);
	}          

    //조회
    function doSearch() {

        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + "BSOX_290/doSearch", function() {
        	/*
        	if (currenEvalType != '') {
                WUX.getComponent('EVAL_TYPE').setValue(currenEvalType);
            }
            doQuotecomparison();
            if ('${param.negoFlag}' === '1') {
                grid.setColCellActivation("AWARD", "activatenoedit");
            }
            */

            if (grid.getRowCount() != 0) {
            	//var vcd = grid.getCellValue("0", "VENDOR_CD");
            	//doSearchItem();
            }

    	    <c:if test="${form.PRC_STL_TYPE != 'LMT' }">
    	    grid.hideCol('LIMIT_PRC',true);
            //setCellMerge.call(grid, ['ITEM_CD','ITEM_DESC', 'ITEM_SPEC', 'UNIT_CD','RFX_QT', 'CUR', 'UNIT_PRC', 'TRGT_PRC'], true);
    		</c:if>
    	    <c:if test="${form.PRC_STL_TYPE == 'LMT' }">
            //setCellMerge.call(grid, ['ITEM_CD','ITEM_DESC', 'ITEM_SPEC', 'UNIT_CD','RFX_QT', 'CUR', 'UNIT_PRC', 'TRGT_PRC', 'LIMIT_PRC'], true);
    		</c:if>

        });

    }

  	//유찰 - 구매요청복구
    function doPRRestore() {

        if (!confirm("${msg.M0111 }")) return; //M0065
        openContentsPopup()
    }

  	//유찰 - 구매요청복구
    function doRestore() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}
		
    	if (!confirm("${msg.M0111 }")) return; //M0065

        var store = new EVF.Store();
        store.load(baseUrl + "BSOX_290/doPRRestore", function() {
        	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');
        	
            alert(this.getResponseMessage());
            if (opener !== undefined && opener.doSearch !== undefined) opener.doSearch();
            window.close();
        });
  	}

    function openContentsPopup() {
    	var param = {
				  havePermission : true
				, callBackFunction : 'setTextContents'
				, detailView : false
				, screenName : '유찰사유'
		};

		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
    }

    function setTextContents(contents) {
    	EVF.C('FAIL_BID_RMK').setValue(contents);
    	doRestore();
    }

    //업체선정
    function doFinal() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}
		
        var countAward = 0;
        for (var i = 0; i < grid.getRowCount(); i++) {
        	var iRFX_NUM = grid.getCellValue(i, 'RFX_NUM');
        	var iRFX_CNT = grid.getCellValue(i, 'RFX_CNT');
        	var iRFX_SQ = grid.getCellValue(i, 'RFX_SQ');
        	//var cnt = 0;
        	
        	if ( grid.getCellValue(i, 'GIVEUP_FLAG') == '1' ) {
        		continue;
        	}
        	
        	
        	

        	//품목별 업체선정여부 체크
        	var countAward = 0;
        	for (var j = 0; j < grid.getRowCount(); j++) {
        		if(
        				grid.getCellValue(j, 'AWARD') === "1" && grid.getCellValue(j, 'RFX_NUM') === iRFX_NUM && grid.getCellValue(j, 'RFX_CNT') === iRFX_CNT && grid.getCellValue(j, 'RFX_SQ') === iRFX_SQ
        		){
        			countAward++;
        		}
        	}

        	
        	
        	if (countAward > 1) {
        		alert('${BSOX_290_002}'); //업체선정여부는 한건만 입력하시기 바랍니다.
                return;
            }
        	if (countAward == 0) {
        		alert('${BSOX_290_003}'); //품목별로 한 업체를 꼭 선정하셔야 합니다.
                return;
            }
        }

        for (var i = 0; i < grid.getRowCount(); i++) {
        	if(grid.getCellValue(i, 'AWARD') == "1" && grid.getCellValue(i, 'SETTLE_RMK') == ''
        		&& grid.getCellValue(i, 'PRICE_RANK') != '1'		
        	){
        		alert(everString.getMessage("${msg.M0109}", "선정사유")); return;//선정사유는 필수입력사항입니다.
        	}
        }

        if (!confirm("${msg.M0079}"))	return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'all');
        if(!store.validate()) return;
        store.load(baseUrl + "BSOX_290/doFinal", function() {
        	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');
        	
            alert(this.getResponseMessage());
            if (opener !== undefined && opener.doSearch !== undefined) opener.doSearch();
            window.close();
        });
  	}


  	//재견적/입찰
    function doRe() {
    	if (!confirm("${BSOX_290_004}"))	return;
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'all');
        if(!store.validate()) return;
        store.load(baseUrl + "BSOX_290/doFinalRe", function() {
        	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');
            alert(this.getResponseMessage());

        	var param = {
            		gateCd: '100',
                    rfxNum: EVF.getComponent('RFX_NUM').getValue(),
                    rfxCnt: EVF.getComponent('RFX_CNT').getValue(),
                    rfxType: EVF.getComponent('RFX_TYPE').getValue(),
                    baseDataType: 'RERFX',
                    settleType: 'total',
                    passedVendors: '',
                    detailView: 'false',
                    popupFlag: true,
                    callBackFunction: 'doReClose'
                };
            	everPopup.openPopupByScreenId('BSOX_010', 1100, 800, param);
        
        
        
        });  		
  		

  	}

    function doReClose() {
    	if (opener !== undefined && opener.doSearch !== undefined) opener.doSearch();
    	window.close();
    }


  	//견적비교표
    function doQuotation() {
    	var param = {
            RFXNUM: EVF.getComponent('RFX_NUM').getValue(),
            RFXCNT: EVF.getComponent('RFX_CNT').getValue(),
            RFXSUBJECT: EVF.getComponent('RFX_SUBJECT').getValue(),
            detailView: 'false'
        };
        everPopup.openPopupByScreenId('BSOX_270', 1200, 600, param);
  	}


  	//닫기
    function doClose() {
    	if (opener !== undefined && opener.doSearch !== undefined) opener.doSearch();
    	window.close();
  	}

    //우선협상업체지정
    //function doAward() {
  	//
  	//}

  	//업체선정
    //function doSelect() {
  	//
  	//}
  	//유찰
    //function doFailBid() {
  	//
  	//}


</script>


    <e:window id="BSOX_290" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
		
    	<e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty form.GATE_CD ? param.gateCd : form.GATE_CD}" />
		<e:inputHidden id="FAIL_BID_RMK" name="FAIL_BID_RMK" value="${form.FAIL_BID_RMK}" />
	    <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
	    <e:inputHidden id="rqvnCnt" name="rqvnCnt" value="${form.rqvnCnt}" />
	    <e:inputHidden id="itemCnt" name="itemCnt" value="${form.itemCnt}" />

        <e:searchPanel id="form" useTitleBar="false" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">

            <e:row>
            <e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
                <e:field>
                    <e:inputText id="RFX_NUM" name="RFX_NUM" align="center" value="${form.RFX_NUM}" width="100" maxLength="${form_RFX_NUM_M}" disabled="true" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                    <e:text>/</e:text>
                    <e:inputNumber id="RFX_CNT" name="RFX_CNT" align="center" value="${form.RFX_CNT}" maxValue="${form_RFX_CNT_M}" width="30" decimalPlace="${form_RFX_CNT_NF}" disabled="true" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="true" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>

            </e:row>
            <e:row>
					<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}"/>
					<e:field>
					<e:inputText id="RFX_SUBJECT" style="ime-mode:auto" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="100%" maxLength="${form_RFX_SUBJECT_M}" disabled="true" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}"/>
					</e:field>
	                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
	                <e:field>
	                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='true' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
	                    </e:select>
	                </e:field>            
            </e:row>
            <e:row>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenType }" width="45%" disabled="true" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
					<e:text> / </e:text>
                    <e:select id="SUBMIT_TYPE" onChange="clearTplNum" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="45%" disabled="true" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>
                
                
                <e:label for="PRC_STL_TYPE" title="${form_PRC_STL_TYPE_N}"/>
                <e:field>
                    <e:select id="PRC_STL_TYPE" name="PRC_STL_TYPE" value="${form.PRC_STL_TYPE}" options="${prcStlType }" width="45%" disabled="true" readOnly="${form_PRC_STL_TYPE_RO}" required="${form_PRC_STL_TYPE_R}" placeHolder="" />
                    <e:text> / </e:text>
                    <e:select id="SETTLE_TYPE"  name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" options="${settleType}" width='45%' required='${form_SETTLE_TYPE_R }' readOnly='${form_SETTLE_TYPE_RO }' disabled='true' visible='${form_SETTLE_TYPE_V }' placeHolder='${placeHolder }' />
                </e:field>
                
            </e:row>
            <e:row>
				<e:label for="RFQ_START_END_DATE" title="${form_RFQ_START_END_DATE_N}"/>
				<e:field colSpan="3">
				<e:text> ${form.RFQ_START_END_DATE } </e:text>
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="doQuotation" name="doQuotation" label="${doQuotation_N}" onClick="doQuotation" disabled="${doQuotation_D}" visible="${doQuotation_V}"/>
        	<e:button id="doPRRestore" name="doPRRestore" label="${doPRRestore_N}" onClick="doPRRestore" disabled="${doPRRestore_D}" visible="${doPRRestore_V}"/>
        	<e:button id="doRe" name="doRe" label="${doRe_N}" onClick="doRe" disabled="${doRe_D}" visible="${doRe_V}"/>
        	<e:button id="doFinal" name="doFinal" label="${doFinal_N}" onClick="doFinal" disabled="${doFinal_D}" visible="${doFinal_V}"/>
        	<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>

        	<!-- <e:button id="doAward" name="doAward" label="${doAward_N}" onClick="doAward" disabled="${doAward_D}" visible="${doAward_V}"/> -->
        	<!-- <e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}"/> -->
        	<!-- <e:button id="doFailBid" name="doFailBid" label="${doFailBid_N}" onClick="doFailBid" disabled="${doFailBid_D}" visible="${doFailBid_V}"/> -->
        </e:buttonBar>



        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />



	</e:window>
</e:ui>