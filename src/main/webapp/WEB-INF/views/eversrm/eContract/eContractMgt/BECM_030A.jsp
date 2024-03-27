
<%@page import="com.st_ones.everf.serverside.config.PropertiesManager"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri = "http://java.sun.com/jsp/jstl/functions" prefix = "fn" %>
<%
	String devYn = PropertiesManager.getString("eversrm.system.developmentFlag");
%>
<c:set var="devYn" value="<%=devYn%>"/>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/ckeditor/econt_plugins_n.js?var=1"></script>
	 <!-- 정보인증 관련 js  -->
 	<link rel="stylesheet" type="text/css" href="/toolkit/SecuKitNXS/WebUI/css/base.css" />
	<script type="text/javascript" src="/toolkit/SecuKitNXS/KICA/config/nx_config.js"></script>
 	<script type="text/javascript" src="/toolkit/SecuKitNXS/KICA/config/LoadSecukitnx.js"></script>

	<script type="text/javascript">
        var grid = {};
        var gridP ={};
        var gridU ={};
        var addGrid;
        var rejectGrid;
        var gridF ={};
        var toolkit;

        var baseUrl        = "/eversrm/eContract/eContractMgt/BECM_030/";
        var userType       = '${ses.userType}';
        var userId         = '${ses.userId}';

        var baseDataType   = '${param.baseDataType}';
        var additionalForm = "${param.additionalForm}".replace(/'/gi, '"');
        var contReqFlag    = '${param.contReqFlag}';  //Cont Request - M163 -  New : 01, Stop : 02, Restart : 03, Change : 04
        var contReqStatus  = '${param.contReqStatus}';//Cont Stop/Restart - at first createion
        var opCBackFn      = '${param.openerCallBackFunction}';//call from purchase exec. : CALL BACK Function
        var contReqRmk     = '${param.contReqRmk}';
		var vvvCd          = '${param.VENDOR_CD}';
		var rfxType        = '${param.RFXTYPE}';
        var contNum        = '${param.CONT_NUM}';
        var contCnt        = '${param.CONT_CNT}';
        var accAttr        = '${param.ACC_ATTR}';
        var itemCls4       = '${param.ITEM_CLS4}';

        var soType         = '${param.SO_TYPE}';
		var soNum          = '${param.SO_NUM}';
		var soCnt          = '${param.SO_CNT}';
		var execNum        = '${param.EXEC_NUM}';
		var sel_form_num   = '${param.SELECT_FORM_NUM}';
		var rfx_ryq        = '${param.RFX_RYQ}';

		var changeGridPValue = "0";

		var messg          = "";
        var type           = "";
      	var UserSignCert = null;

		function SecuKitNX_Ready(res) {
             if (res) {
                 console.log('SecuKitNX Ready');
             }
         }

		function init() {

			grid  = EVF.C("grid");
         	gridP = EVF.C("gridP");
         	gridU = EVF.C("gridU");
           	gridF = EVF.C("gridF");
            rejectGrid = EVF.C("rejectGrid");

			gridP.setProperty('shrinkToFit', true);
			gridU.setProperty('shrinkToFit', true);
            rejectGrid.setProperty('shrinkToFit', true);
			addGrid = EVF.C("grid");

            grid.checkAll(true);
            gridP.checkAll(true);
            gridU.checkAll(true);
            gridF.checkAll(true);

          	//  EVF.C("CONT_REQ_CD").setValue(contReqFlag);

            if(EVF.C("ADV_GUAR_PERCENT").getValue()>'0'){
            	EVF.C("ADV_GUAR_FLAG").setValue("1");
            }else{
            	EVF.C("ADV_GUAR_FLAG").setValue("0");
            }

		    if(EVF.C("CONT_GUAR_PERCENT").getValue()>'0'){
		       EVF.C("CONT_GUAR_FLAG").setValue("1");
		    }else{
		       EVF.C("CONT_GUAR_FLAG").setValue("0");
		    }

 		    if(EVF.C("WARR_GUAR_PERCENT").getValue()>'0'){
   				EVF.C("WARR_GUAR_FLAG").setValue("1");
   		    }else{
   				EVF.C("WARR_GUAR_FLAG").setValue("0");
   		    }

 		    /* KICA certification  */
  			$('#KICA_SECUKITNXDIV_ID').append(KICA_SECUKITNXDIV);
            secunx_Loading();

     	 	gridP.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

           		if(userType == 'C' && baseDataType == 'contract') {
	                  gridP.setCellReadOnly(rowid, 'UNIT_PRC', false);
	                  gridP.setCellReadOnly(rowid, 'PO_QT', false);
	            	  gridP.setCellReadOnly(rowid, 'DELY_YM', false);

	            }else if(userType=='S' && baseDataType == 'contract'){
		              gridP.setCellReadOnly(rowid, 'UNIT_PRC', false);
		              gridP.setCellReadOnly(rowid, 'PO_QT', true);
	             	  gridP.setCellReadOnly(rowid, 'DELY_YM', true);

	       		}else if(userType=='C' && baseDataType != 'contract'){
	             	  gridP.setCellReadOnly(rowid, 'DELY_YM', true);
		        }

	        });

            grid.cellClickEvent(function (rowid, celname, value, iRow, iCol) {

                if (celname == "REL_FORM_NM") {
                    var detailViewFlag = "true";
                    if (contReqFlag == '02' || userType == 'S' || '${param.appDocNum}' !== '') {
                        detailViewFlag = "false";
                    }

                    if (${ses.userType == 'S' and form.VENDOR_EDIT_FLAG == '1' and form.PROGRESS_CD == '4210'}) {
                        detailViewFlag = "false";
                    }

                    var txt = grid.getCellValue(rowid, "CONTRACT_TEXT_NUM");
                    var param = {
                        relFormNum: grid.getCellValue(rowid, "REL_FORM_NUM"),
                        formTextNum: grid.getCellValue(rowid, "FORM_TEXT_NUM"),
                        CONT_NUM: '${param.CONT_NUM}',
                        CONT_CNT: '${param.CONT_CNT}',
                        BUYER_CD: EVF.C('BUYER_CD').getValue(),
                        VENDOR_CD: EVF.C('VENDOR_CD').getValue(),
                        CONT_DATE: EVF.C('CONT_START_DATE').getValue(),
                        PROGRESS_CD: EVF.C('PROGRESS_CD').getValue(),
                        contents: grid.getCellValue(rowid, "ADDITIONAL_CONTENTS"),
                        contReqFlag: contReqFlag,
                        //callBackFunction: 'doCheckAdditionalContractStatus',
                        rowIndex: rowid,
                        contractEditable: true,
                        popupFlag: true,
                        detailView: detailViewFlag,
                        vendorEditFlag: '${form.VENDOR_EDIT_FLAG}'
                    };
                    everPopup.openPopupByScreenId('BECM_040', 1000, 800, param);
                }
            });

            //CKEDITOR Setting
            var editor = CKEDITOR.replace('cont_content', {
                customConfig: '/js/ckeditor/ep_config.js',
                width: '100%',
                height: 330
            });

            editor.on('instanceReady', function (ev) {
                var editor = ev.editor;
                editor.resize('100%', 380, true, false);

                $(window).resize(function () {
                    editor.resize('100%', 380, true, false);
                });
                //editor.setData(EVF.C('formContents').getValue());
                var progressCd = EVF.C('PROGRESS_CD').getValue();
                if (userType == 'S') {

                    if (progressCd == '4210' && ${form.VENDOR_EDIT_FLAG eq "1"}) {
                        editor.setReadOnly(false);
                    } else {
                        editor.setReadOnly(true);
                    }

                } else if (contReqFlag == '02' || '${param.appDocNum}' !== '' || '${param.detailView}' == 'true' || !( progressCd == '4220' )) {
                    editor.setReadOnly(true);
                }
            });

   			//Component control
            setCompAll();

			if ('${param.CONT_NUM}' !== ''  ){

				doSearchAdditionalForm();
			 	doSelectContractKPECInfo();

			} else if ('${param.appDocNum}' !== '') {

				doSearchAdditionalForm();
                doSelectContractKPECInfo();

            } else if ('${param.CONT_NUM}' == ''  ){
        		if(baseDataType==='exContract'){
			        doSelectContractCNHDInfo();
			     	doSearchAdditionalForm();

				}else if(baseDataType==='soContract') {
			    	  doSelectContractKPECInfo();
			    	  doSearchAdditionalForm();

				}else {
					doSearchAdditionalForm();
					gridcheck();
				}

			} else {
   				// additional form row insert
                if (additionalForm !== '[]') {
                	doSearchAdditionalForm();
                }
            }

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,  // image width
                    imgHeight: 0.26, // image height
                    colWidth: 20,    // column width.
                    rowSize: 500,    // excel row hight size.
                    attachImgFlag: false
                    // excel imange attach flag : true/false
                }
            });

            rejectGrid.excelExportEvent({
                allCol : "${excelExport.allCol}",
                selRow : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }",
                excelOptions : {
                    imgWidth: 0.12,  // image width
                    imgHeight: 0.26, // image height
                    colWidth: 20,    // column width.
                    rowSize: 500,    // excel row hight size.
                    attachImgFlag: false
                    // excel imange attach flag : true/false
                }
            });

            gridP.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,  // image width
                    imgHeight: 0.26, // image height
                    colWidth: 20,    // column width.
                    rowSize: 500,    // excel row hight size.
                    attachImgFlag: false
                    // excel imange attach flag : true/false
                }
            });

            gridU.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,  // image width
                    imgHeight: 0.26, // image height
                    colWidth: 20,    // column width.
                    rowSize: 500,    // excel row hight size.
                    attachImgFlag: false
                    // excel imange attach flag : true/false
                }
            });

            if (baseDataType == 'contract') {
            	gridP.delRowEvent(function() {
					if ((gridP.jsonToArray(gridP.getSelRowId()).value).length == 0) {

						alert("${msg.M0004}");
						return;
					}

					if (!confirm("${msg.M0009 }"))
						return;

					var rowData = gridP.getSelRowId();
					for ( var nRow in rowData) {
						if (gridP.getCellValue(rowData[nRow], 'INSERT_FLAG') == 'R') {
							gridP.setCellValue(rowData[nRow], 'INSERT_FLAG', 'D');
							delRows.push(gridP.getRowValue(nRow));
						}
					}

					gridP.delRow();

					if (gridP.getRowCount() == 0) {
						EVF.V("ACC_ATTR", "");
					}

					changeSupplyAmt();
				});

			}

            gridP.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

            	gridP.checkRow(rowId, true);

            	if (colId == "UNIT_PRC" || colId == "PO_QT") {
            		var poQt = Number(gridP.getCellValue(rowId, 'PO_QT'));
        			var unitPrc = Number(gridP.getCellValue(rowId, 'UNIT_PRC'));

        			gridP.setCellValue(rowId, 'ITEM_AMT', (poQt * unitPrc));

        			changeSupplyAmt();
		        }

            	if (colId == "DELY_YM")	{

            		if (baseDataType != "contract") {
                    	gridP.setCellValue(rowId, 'DELY_YM', oldValue);

                    	return alert('${BECM_030_0025}');
	        		}

                	var delyYM	   = gridP.getCellValue(rowId, 'DELY_YM');
                	var set_delyYM = delyYM.substring(0,6);

                	gridP.setCellValue(rowId, 'DELY_YM', set_delyYM);
            	}

            	changeGridPValue = "1";
            });

        }

		//baseDataType or etc. condition Component readOnly processing
        function setCompAll() {

        	if (userType == 'S') {

                EVF.C('CONT_DESC').setReadOnly(true);
                EVF.C('SUPPLY_AMT').setReadOnly(true);
                EVF.C('CONT_DATE').setReadOnly(true);
                EVF.C('CONT_START_DATE').setReadOnly(true);
                EVF.C('CONT_END_DATE').setReadOnly(true);
                EVF.C('CONT_USER_ID').setReadOnly(true);
                EVF.C('CONT_USER_NM').setReadOnly(true);
                EVF.C('VENDOR_CD').setDisabled(true);
                EVF.C('VENDOR_NM').setDisabled(true);

                EVF.C('VENDOR_PIC_USER_NM').setDisabled(true);
                EVF.C('CONTRACT_TYPE').setDisabled(true);
                EVF.C('CONT_REQ_CD').setDisabled(true);
                //EVF.C('MANUAL_CONT_FLAG').setDisabled(true);
				//EVF.C('APPROVAL_FLAG').setDisabled(true);
                EVF.C('PROGRESS_CD').setDisabled(true);
                EVF.C('VENDOR_EDIT_FLAG').setDisabled(true);
				EVF.C('BUYER_ATT_FILE_NUM').setReadOnly(true);
				/* EVF.C('CONT_REQ_RMK').setReadOnly(true); */
				EVF.C('DELAY_NUME_RATE').setReadOnly(true);
				EVF.C('DELAY_DENO_RATE').setReadOnly(true);
				EVF.C('DELAY_AMT').setReadOnly(true);
				EVF.C('STAMP_DUTY_NUM').setReadOnly(false);
				EVF.C('STAMP_ATT_FILE_NUM').setReadOnly(false);

				EVF.C('ADV_GUAR_PERCENT').setReadOnly(true);
				EVF.C('ADV_GUAR_FLAG').setReadOnly(true);
				EVF.C('ADV_VAT_FLAG').setReadOnly(true);
				EVF.C('CONT_GUAR_PERCENT').setReadOnly(true);
				EVF.C('CONT_GUAR_FLAG').setReadOnly(true);
				EVF.C('CONT_VAT_FLAG').setReadOnly(true);
				EVF.C('WARR_GUAR_PERCENT').setReadOnly(true);
				EVF.C('WARR_GUAR_FLAG').setReadOnly(true);
				EVF.C('WARR_VAT_FLAG').setReadOnly(true);
	    		EVF.C('WARR_GUAR_QT').setReadOnly(true);

	    		EVF.C('RFQ_ATT_FILE_NUM').setReadOnly(true);
	    		EVF.C('BIZ_ATT_FILE_NUM').setReadOnly(true);
	    		EVF.C('SC_ATT_FILE_NUM').setReadOnly(true);
	    		EVF.C('ATT_FILE_NUM').setReadOnly(true);
	    		EVF.C('ETC_ATT_FILE_NUM').setReadOnly(true);

	    		EVF.C('PRE_RATE').setReadOnly(true);
	    		EVF.C('MID_RATE').setReadOnly(true);
	    		EVF.C('BAL_RATE').setReadOnly(true);
	    		EVF.C('COM_RATE').setReadOnly(true);

	    		EVF.C('ALLOWANCE_RATE').setReadOnly(true);

	    		if(baseDataType == 'contract') {
	    			rowIds = gridP.getAllRowId();
	                for(var rowIdx in rowIds ){
	                	gridP.setCellReadOnly(rowIdx, 'UNIT_PRC', false);
	                }
				}

	    	} else /* if buyer */ {

			    /* contReqFlag = (New: 01, Stop: 02, Restart: 03, Change: 04) */
                if (contReqFlag == '02') {

                    EVF.C('CONT_DESC').setDisabled(true);
                    EVF.C('SUPPLY_AMT').setDisabled(true);
                    EVF.C('CONT_DATE').setDisabled(true);
                    EVF.C('CONT_START_DATE').setDisabled(true);
                    EVF.C('CONT_END_DATE').setDisabled(true);
                    EVF.C('CONT_USER_ID').setDisabled(true);
                    EVF.C('CONT_USER_NM').setDisabled(true);
                    EVF.C('VENDOR_CD').setDisabled(true);
                    EVF.C('VENDOR_NM').setDisabled(true);
                    EVF.C('CONTRACT_TYPE').setDisabled(true);
                    EVF.C('CONT_REQ_CD').setDisabled(true);
                    EVF.C('APPROVAL_FLAG').setDisabled(true);
                    EVF.C('PROGRESS_CD').setDisabled(true);

                } else {

                    var progressCd = EVF.C('PROGRESS_CD').getValue();

                    if (!(progressCd == '' || progressCd == '4200' || progressCd == '4220')) { // '' : first, 4200 : temp save, 4220 : vendor return,  -- 4210 : vendor wait for signing, 4230 : buyer wait for signing, 4300 : cont complete
                        EVF.C('SUPPLY_AMT').setDisabled(true);
                        EVF.C('CONT_DATE').setDisabled(true);
                        EVF.C('CONT_START_DATE').setDisabled(true);
                        EVF.C('CONT_END_DATE').setDisabled(true);
                        EVF.C('CONT_USER_ID').setDisabled(true);
                        EVF.C('CONT_USER_NM').setDisabled(true);
                        EVF.C('VENDOR_NM').setDisabled(true);
                        EVF.C('VENDOR_PIC_USER_NM').setDisabled(true);

                    } else {
                        EVF.C('CONT_REQ_CD').setDisabled(true);
                    }

                    if (contReqFlag == '03' && progressCd == '4300') /* modify CONT_REQ_CD for change cont. */ {
                        EVF.C('CONT_REQ_CD').setDisabled(false);
                        EVF.C('CONT_REQ_CD').setRequired(true);
                    }

                }

				if(contReqFlag == '04'){
					EVF.C('CONT_START_DATE').setReadOnly(true);
					EVF.C('VENDOR_NM').setReadOnly(true);
				}

			}

    	 	EVF.C('STAMP_DUTY_FLAG').setDisabled(true);
			EVF.C('STAMP_DUTY_AMT').setReadOnly(true);

			if ('${param.detailView}' === 'true') {
                EVF.C('BUYER_ATT_FILE_NUM').setReadOnly(true);
            }

            <%-- buyer wait for signing --%>
            if (EVF.C('PROGRESS_CD').getValue() == '4230') {
                //EVF.C('VENDOR_ATT_FILE_NUM').setReadOnly(true);
            }

            var vContCnt = EVF.C('VCONT_CNT').getValue();
            if (!(vContCnt == '' || vContCnt == '1')) {
            	EVF.C('CONT_START_DATE').setReadOnly(true);
            }

            if (!opener) {
                //EVF.C('doClose').setVisible(false);
            }
        }

        // auto row insert for additional form
        function setAdditionalForm(selectedData) {

        	if (selectedData == null || selectedData == '') {
        		return;
        	}

            var resultData = [];
            selectedData = JSON.parse(selectedData);
            for (var x in selectedData) {
                var data = {};

                data['FORM_NUM']            = selectedData[x]['FORM_NUM']; //;
                data['REL_FORM_SQ']         = parseInt(x) + 1;
                data['REL_FORM_NUM']        = selectedData[x]['REL_FORM_NUM'];
                data['REQUIRE_FLAG']        = selectedData[x]['REQUIRE_FLAG'];
                data['REL_FORM_NM']         = selectedData[x]['REL_FORM_NM'];
                data['FORM_TEXT_NUM']       = selectedData[x]['FORM_TEXT_NUM'];
                data['CONTRACT_TEXT_NUM']   = ''; //  selectedData[x]['FORM_TEXT_NUM'];
                data['ADDITIONAL_CONTENTS'] = '';
                data['FORM_CHECK_FLAG']     = '';

                resultData.push(data);
            }
            addGrid.addRow(resultData);
        }

        //change char for additional form
        function gridcheck(idx) {
             var contents =  grid.getCellValue(idx, 'ADDITIONAL_CONTENTS').replace(/%/gi, '&#37;').replace(/'/gi, '&#39;');
              grid.setCellValue(idx,'ADDITIONAL_CONTENTS',contents);
        }


        //additional form popup callBackFunction
        function doCheckAdditionalContractStatus(params) {
            grid.checkRow(params.rowIndex, true);
            grid.setCellValue(params.rowIndex, 'ADDITIONAL_CONTENTS', params.contents);
            grid.setCellValue(params.rowIndex, 'FORM_CHECK_FLAG', '1');
        }

        //search for additional form
        function doSearchAdditionalForm() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.setParameter("FORM_NUM", sel_form_num);
            //store.setParameter('additionalForm', additionalForm);
            store.load(baseUrl + 'doSearchAdditionalForm', function () {
                grid.checkAll(true);
                rowIds = grid.getAllRowId();
                for(var rowIdx in rowIds ){
    				gridcheck(rowIdx);
                }
                if (!(contReqFlag == '02' && contReqStatus == 'C')) {
                    doSearchContractRejectInfo();
                }

            });

        }

        function doSelectContractKPECInfo() {

            var store = new EVF.Store();

            store.setGrid([gridP, gridU]);
            store.load(baseUrl + 'doSelectContractKPECInfo', function () {
                gridP.checkAll(true);
                gridU.checkAll(true);

                //ssjj
                if (baseDataType==='contract' && contReqFlag == '04' && (form.SOTYPE ='SIN' || soType == 'SIN')) {
					EVF.C("SO_NUM").setValue("");
					EVF.C("SO_CNT").setValue("");

					var rowData = gridP.getSelRowId();
					for ( var nRow in rowData) {
						gridP.setCellValue(rowData[nRow], 'SO_NUM', '');
						gridP.setCellValue(rowData[nRow], 'SO_CNT', '');
					}
                }
            });
        }

        //calculate stamp duty amount
        function doSelect_stamp_duty_AMT() {

        	if(EVF.V("SUPPLY_AMT") == '' || EVF.V("ACC_ATTR") != "02") {
              	EVF.C("STAMP_DUTY_FLAG").setChecked(false);
    			EVF.C('STAMP_DUTY_AMT').setValue("0");

  	        } else {
  	        	var store = new EVF.Store();
  	        	store.load(baseUrl + 'doSelect_stamp_duty_AMT', function () {
  	        		var stamp_amt     = this.getParameter("STAMP_DUTY_AMT");
  	        		var sum_stamp_amt = this.getParameter("SUM_STAMP_DUTY_AMT");

  	        		if (stamp_amt == 0 || stamp_amt <= sum_stamp_amt) {
  	                  	EVF.C("STAMP_DUTY_FLAG").setChecked(false);
  	        			EVF.C('STAMP_DUTY_AMT').setValue("0");
  	        		} else {
  	                  	EVF.C("STAMP_DUTY_FLAG").setChecked(true);
	        			EVF.C('STAMP_DUTY_AMT').setValue(stamp_amt - sum_stamp_amt);
  	        		}
  	            });
  	        }

        }

        function doSelectContractCNHDInfo() {

            var store = new EVF.Store();

            store.setGrid([gridP]);
            store.load(baseUrl + 'doSelectContractCNHDInfo', function () {
            });
        }

        function doSelectContractFileInfo() {

        	var verify = true;
            var store = new EVF.Store();

      		store.setGrid([gridF]);
            store.load(baseUrl + 'doSelectContractFileInfo', function () {
    			var rowIds = gridF.getSelRowId();
    	    	for(var i in rowIds) {
    	    		var hashValue = gridF.getCellValue(rowIds[i], 'HASH_VALUE');
    	    		if (hashValue == null || hashValue == '') {
    	    			verify = false;
    	    			break;
    	    		}
        		}
            });

            return verify;
        }

        function doSearchContractRejectInfo() {

            var store = new EVF.Store();
            store.setGrid([rejectGrid]);
            store.load(baseUrl + 'doSearchContractRejectInfo', function () {

            });
        }

        function doAuthUserCheck() {
            var flag = 'Y';
            var progressCd = EVF.V('PROGRESS_CD');
            var ctrlCd = '${ses.ctrlCd}';

            if(ctrlCd.indexOf('N100') !== -1) {
            	flag = 'Y';
            } else if (contNum != '' && progressCd == '4200') {
           		var regUserId = EVF.V('REG_USER_ID');
                if (regUserId != userId) {
                    flag = 'N';
                }
            }

            return flag;
        }

        //Save
        function doSave() {

            type = this.getData();
            var messg = '${msg.M0021}';

            setSave(type, messg);
        }

        //Send
        function doSend() {
			type = 'SEND';
			var manualContFlag = EVF.C('MANUAL_CONT_FLAG').getValue();

			if (manualContFlag != '0') {
				messg = '${BECM_030_0016}';

            } else {
            	 if ('${ses.userId}' != EVF.C("CONT_USER_ID").getValue()){
            	    messg = '${BECM_030_0027}';
            	}else {
            		messg = '${msg.M0060}';
            	}
            }

			if (!everDate.fromTodateValid('DATE', 'CONT_START_DATE', '${ses.dateFormat }')) {
	            if (EVF.C('VCONT_CNT').getValue() == '1' || EVF.C('VCONT_CNT').getValue() == '') {
					return alert('${BECM_030_0020}');
	            }
			}

			setSave(type, messg);
        }

        //Save-Send
        function setSave(type, messg) {

			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
		    	return;
			}

            var mflag = doAuthUserCheck();
            if (mflag == 'N') {
                alert('${BECM_030_0018}');
                return;
            }


			var gridData = grid.getSelRowValue();
            /*
            if (gridData.length != grid.getRowCount()) {
            	return alert('${BECM_030_0013}');
            }
   			*/
            for (var i = 0, len = gridData.length; i < len; i++) {
                var formChkFlag = gridData[i].FORM_CHECK_FLAG;
                if (formChkFlag != '1') {
                    alert('${BECM_030_0013}');
                    return;
                }
            }

            var store = new EVF.Store();
            var stamp_duty_Flag = EVF.C("STAMP_DUTY_FLAG").isChecked();

            if(stamp_duty_Flag==true){
            	EVF.C("STAMP_DUTY_AMT").setRequired(true);
            }

  			if (!store.validate()) {
  		        return;
            }

	  		if(EVF.C('RFQ_ATT_FILE_NUM').getFileCount()>1){return alert("${BECM_030_0030}");}
	        if(EVF.C('BIZ_ATT_FILE_NUM').getFileCount()>1){return alert("${BECM_030_0031}");}
	        if(EVF.C('SC_ATT_FILE_NUM').getFileCount()>1){return alert("${BECM_030_0032}");}
	        if(EVF.C('ETC_ATT_FILE_NUM').getFileCount()>1){return alert("${BECM_030_0033}");}

     		var msg = checkEdit();
            if (msg == 'NO') return;

          	if (!confirm(messg)) return;

           	if (type == "SEND") {
			    //select vendor user
                var popupUrl = "/eversrm/master/vendor/BBV_060/view";
                var param = {
                    'callBackFunction': '_setvendormaster',
                    'onClose': 'closePopup',
                    'detailView' : false,
                    'vendorCdParams': EVF.C("VENDOR_CD").getValue(),
                    'vendorNmParams': EVF.C("VENDOR_NM").getValue(),
                    'vendorConfY': EVF.C("vendorConfY").getValue()
                };
                //everPopup.openPopupByScreenId('BBV_060', 1100, 380, param);
                 everPopup.openWindowPopup(popupUrl, 1100, 380, param, '');
            }else{
           		doSaveE(type);
            }
        }

    	function doSearchVendor() {

    		if (EVF.V("CONT_NUM") != '') {
    			alert('${BECM_030_0026}');
    			return;
    		}

			var param = {
				BUYER_CD : "${ses.companyCd}",
				callBackFunction : "_setVendor"
			};
			//everPopup.openCommonPopup(param, 'SP0013'); -- All
			everPopup.openCommonPopup(param, 'SP0110');
		}

        function _setVendor(data) {

    		 EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
    		 EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
 		}

        function doSaveE(type){
    		var store = new EVF.Store();
    		var stamp_duty_FlagVal = EVF.C("STAMP_DUTY_FLAG").isChecked() == true ? "1" : "0";
    		var signStatus = 'T'; //this.getData();
            EVF.C("SIGN_STATUS").setValue(signStatus);
    		var cont_date =EVF.C("CONT_START_DATE").getValue();
    		var vendor_cd=EVF.C("VENDOR_CD").getValue();

		    //var responsecode ="";
    		store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.setGrid([gridP]);
            store.getGridData(gridP, 'all');
            store.setGrid([gridU]);
            store.getGridData(gridU, 'all');
            store.setParameter('SEND_TYPE', type);
            store.setParameter('CONT_REQ_FLAG', contReqFlag);
            store.setParameter('RFX_RYQ' , rfx_ryq);
            store.setParameter('CONT_REQ_STATUS', contReqStatus);
            store.setParameter('mainContractContents', CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
			store.setParameter("STAMP_DUTY_FLAG", stamp_duty_FlagVal);
			store.setParameter("VENDOR_CD",vendor_cd);
            store.setParameter("VENDOR_PROGRESS_CD",EVF.V("VENDOR_PROGRESS_CD"));
			store.setParameter("CONT_DATE",cont_date);
			store.doFileUpload(function () {
			store.load(baseUrl + 'doSaveContract', function () {
				EVF.C('TRANSACTION_FLAG').setValue('Y');
                changeGridPValue = "0";

				alert(this.getResponseMessage());
                //CASE : puchase exec. call
                if (opCBackFn == 'setCallBackPRCont') {
                    opener.setCallBackPRCont(contNum, contCnt);
                    //window.close();
                }
                //cont. Stop
                if (contReqFlag == '02') {
                        var param = {
                            baseDataType  : baseDataType,
                            CONT_NUM      : this.getParameter('CONT_NUM'),
                            CONT_CNT      : EVF.V('VCONT_CNT'),
                            ACC_ATTR      : EVF.V('ACC_ATTR'),
                            ITEM_CLS4     : EVF.V('ITEM_CLS4'),
                            SO_TYPE       : EVF.V('SO_TYPE'),
                            contReqFlag   : '02',
                            contReqStatus : '',
                            detailView    : true,
                            contractEditable : false,
                        };
                        location.href = baseUrl + 'view.so?' + $.param(param);

                } else {
                        var param = {
                            baseDataType  : baseDataType,
                            CONT_NUM      : this.getParameter('CONT_NUM'),
                            CONT_CNT      : this.getParameter('CONT_CNT'),
                            ACC_ATTR      : EVF.V('ACC_ATTR'),
                            ITEM_CLS4     : EVF.V('ITEM_CLS4'),
                            SO_TYPE       : EVF.V('SO_TYPE'),
                            SO_NUM        : EVF.V('SO_NUM'),
                            SO_CNT        : EVF.V('SO_CNT'),
                            EXEC_NUM      : EVF.V('EXEC_NUM'),
                            detailView    : false,
                            contractEditable : false,
                            signStatus: "T",
                            VENDOR_CD : vendor_cd
                         };

               			location.href = baseUrl + 'view.so?' + $.param(param);

				}

				if (opener) {
                	if (opener['doSearch'] && typeof opener['doSearch'] === 'function') {
                    	opener['doSearch']();
                    }
                }

		        });
			});
		}

        function _setvendormaster(selectedData) {
        	EVF.C('vendorMasterList').setValue(selectedData);
            doSaveE(type);
        }

		function checkEdit() {

            var rtnMsg = "YES";
            var $contents = $((CKEDITOR.instances.cont_content.getData()).replace(/&nbsp;/g, ''));
            var fields = $contents.addBack().find('input, textarea');
            fields.each(function (idx) {
                var $t = $(this);
                var name = $t.attr('name'); // difference method : name, value
                var value = $t.val();

                if (name != 'changeVal_61' &&
                	name != 'DELY_TERMS_DESC' &&
                	name != 'DELY_PLACE' &&
            		name != 'PAY_TERMS_DESC' &&
            		name != 'PRE_RATE' &&
            		name != 'MID_RATE' &&
            		name != 'BAL_RATE' &&
            	    name != 'COM_RATE' &&
            	    name != 'ADV_GUAR_PERCENT' &&
            		name != 'CONT_GUAR_PERCENT' &&
            		name != 'WARR_GUAR_PERCENT'	&&
            		value == '') { //Except for signature completed
                    var rename = strReplaceRtn('', name);
                    alert('${BECM_030_0036}' + rename + '${BECM_030_0037}');
                    rtnMsg = "NO";
                    return false; // - break, return true - continue;
                }
            });
            return rtnMsg;
        }

        function strReplaceRtn(formNum, code) {

            var name = "";
            if (code == 'CONT_START_DATE') {
                name = '${BECM_030_0038}';
                return name;
            }
            if (code == 'CONT_END_DATE') {
                name = '${BECM_030_0039}';
                return name;
            }
            if (code == 'CONT_DATE') {
                name = '${BECM_030_0040}';
                return name;
            }
            if (code == 'CONT_NUM') {
                name = '${BECM_030_0041}';
                return name;
            }
            if (code == 'CONT_DESC') {
                name = '${BECM_030_0042}';
                return name;
            }
            if (code == 'SUPPLY_AMT') {
                name = '${BECM_030_0043}';
                return name;
            }
            if (code == 'CONT_AMT') {
                name = '${BECM_030_0043}';
                return name;
            }
            if (code == 'CONT_AMT_KR') {
                name = '${BECM_030_0044}';
                return name;
            }
            if (code == 'changeVal_00') {
                name = '${BECM_030_0045}';
                return name;
            }
            if (code == 'changeVal_99') {
                name = '${BECM_030_0046}';
                return name;
            }
            if (code == 'changeTxt_00') {
                name = '${BECM_030_0047}';
                return name;
            }

            if (name == '') name = code;
            return name;
        }

        //Delete
        function doDelete() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            if (EVF.C("CONT_NUM").getValue() === "") return;

            var mflag = doAuthUserCheck();
            if (mflag == 'N') {
                alert('${BECM_030_0018}');
                return;
            }

            if (confirm('${msg.M0013}')) {
                var store = new EVF.Store();

                store.load(baseUrl + "doDeleteContractNew", function () {
                	EVF.C('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());
                    if (opener) {
                        opener.doSearch();
                        doClose();
                    } else {
                        location.href = '/eversrm/eContract/formMgt/BECF_030/view';
                    }
                });
            }
        }

		function doSign(){

			var stamp_duty_flag = EVF.C("STAMP_DUTY_FLAG").isChecked();

		    //select Hash value for additional files
		    var verify = doSelectContractFileInfo();
		    if (verify == false) {
				alert('${BECM_030_0048}');
				return ;
		    }

			if(stamp_duty_flag==true){
             	EVF.C("STAMP_DUTY_NUM").setRequired(true);
            	EVF.C("STAMP_ATT_FILE_NUM").setRequired(true);
            }

        	if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

        	var stamp_duty_num = EVF.C("STAMP_DUTY_NUM").getValue();
			var textSize = stamp_duty_num.length;

			if(stamp_duty_flag==true){
				if(textSize != '16'  ){
					alert('${BECM_030_0028}');
					return ;
				}
			}

        	var store = new EVF.Store();
        	if (!store.validate()) {
                return;
            }
        	var unit_check = '';
        	rowIds = gridP.getAllRowId();
            for(var rowIdx in rowIds ){
            	unit_check = gridP.getCellValue(rowIdx, 'UNIT_PRC');
            	if(unit_check == '0'){
        			if (!confirm('${BECM_030_0051}'))
            		return;
            	}
            }

        	if (!everDate.fromTodateValid('DATE', 'CONT_START_DATE', '${ses.dateFormat }')) {
	            if (EVF.C('VCONT_CNT').getValue() == '1') {
	        		return alert('${BECM_030_0021}');
	            }
        	}

            if (baseDataType == "contract" && changeGridPValue == "1") {
        		return alert('${BECM_030_0052}');
            }

     		processLogic.init();
     		processLogic.setProcessLogic('Check_SSN');
            NX_ShowDialog();
   		}

		// Digital Signature Related parameter
        var vidRandom  = '';
        var rsaVersion = 'V15';				// RSA Version (V15 / V21)
        var keyName    = '${ses.userId}';	// Key Name
        var algorithm  ='SEED/CBC/PADDING';

		var signType   = '';				// Sign Type : M(Main) , S(Sub), F(File)
		var dataRowCnt = [];				// Sign cnt  : 0(M),     1(S),   2(F)
		var gridIdx    = 0;					// Sign Idx  :           IDX,    IDX

        function SecuKitNXS_RESULT(cmd, res) {
			// Error Check
			var Err = 999;
            var certType = 'SignCert';
            var sourceString = '';
            //alert("cmd : res =====>[" + cmd + "] : [" + res);

            var kmServerCert = EVF.C("ServerKmCert").getValue(); // Server Certificates Info.
            var certID = certListInfo.getCertID();	// Selected Certificates ID
            try {
                Err = res.ERROR_CODE;
            } catch (e) {
                console.log(e);
            }

            if (Err !== undefined) {
            	// Error Message print
				$('.nx-cert-select').hide();
				$('#nx-pki-ui-wrapper').hide();
				KICA_Error.init();

				KICA_Error.setError(res.ERROR_CODE, res.ERROR_MESSAGE);

				var errorMsg = KICA_Error.getError();
				if(res.ERROR_CODE == '366411776') {
					return alert('BECM_030_0034');
				} else if(res.ERROR_CODE == '338821120') {
					return alert('BECM_030_0035');
				}
            }

			// cmd : call function, res : return value(obj)
			var val = null;
			switch (cmd) {

				// Identification : Check for Biz. number and selected Certificates ID
				case 'Check_SSN':
					var ssn;

					if ("${devYn}" == "true") { // developement server : 1111111119
						ssn = '1111111119';
					} else {
						ssn = EVF.C("IRS_NUM").getValue();
					}
					var Data = {
							'ssn'          : ssn.replace(/[^0-9]/gi, ''),
							'certID'       : certID
							};
					var param = JSON.stringify(Data);
					var cmd  = 'Check_SSN_Result.verifyVID';

					secukitnxInterface.SecuKitNXS(cmd, param);

					break;

				// Identification Result
				case 'Check_SSN_Result':

					//alert("case Check_SSN_Result");
					val = res.verifyVID;

	           		var Data = {
	                        'certType'     : certType,
	                        'certID'       : certID,
	                        'isViewVID'    : '1'				// 0 : VID not extract,  1 : VID extract
	                    };
	           		var param = JSON.stringify(Data);
					var cmd  = 'Get_CertInfo_Result.viewCertInfomationWithVID';

					secukitnxInterface.SecuKitNXS(cmd, param);
					//console.log('Check_SSN_Result',val);

					break;

				case 'Get_CertInfo_Result':

					vidRandom = res.vidRandom ;
					UserSignCert = res.certPEM;
					EVF.V('UserSignCert', UserSignCert);

					signType = "M";
					dataRowCnt[0] = 1;
					dataRowCnt[1] = grid.getRowCount();
					dataRowCnt[2] = gridF.getRowCount();

					doSignCert(certType, certID, 1, "");

					break;

				case 'KICA_USE_P7Sign_Result':

					var val = res.generatePKCS7SignedData;

					doSignCert(certType, certID, 2, val);

					break;

				case 'EncVID':

					var EncryptedUserRandomNumber = res.symmetricEncryptData;
					EVF.V("EncryptedUserRandomNumber",EncryptedUserRandomNumber);

					var cmd  = 'GetKeyIV.getSymmetricKeyIV';
	            	var Data ={
	            		       'serverCert' : removePEMHeader(removeCRLF(kmServerCert)),
                               'rsaVersion' : rsaVersion,
                               'keyName'    : keyName
	    			};

	                var param = JSON.stringify(Data);
	                secukitnxInterface.SecuKitNXS(cmd, param);

					break;

				case 'GetKeyIV' :

					var EncryptedSessionKeyForServer = res.getSymmetricKeyIV;   // server Certificates RSA encrypted key info

					EVF.V("EncryptedSessionKeyForServer", EncryptedSessionKeyForServer);

					var main_SIGN_VALUE = EVF.C('SIGN_VALUE').getValue();

					signType = "M";
					dataRowCnt[0] = 1;
					dataRowCnt[1] = grid.getRowCount();
					dataRowCnt[2] = gridF.getRowCount();

					doEncSignCert(1, "");

		        	break;


				case 'EncVID_Result' :
					val = res.symmetricEncryptData;

					doEncSignCert(2, val);

					break;

				default :

					alert("Check cmd : " + cmd);
					break;
			}

		}

        function doSignCert(certType, certID, signDiv, val) {

        	if (signDiv == 1) {

        		var strSource = "";
        		var formNum   = "";

        		switch (signType) {

        			case 'M':
						formNum   = EVF.V('CONTRACT_TYPE');
						//strSource = EVF.V('mainContents');
						strSource = CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;');
					break;

					case 'S':
						if (gridIdx <= dataRowCnt[1] - 1) {
							formNum   = grid.getCellValue(gridIdx, 'REL_FORM_NUM');
							strSource = grid.getCellValue(gridIdx, 'ADDITIONAL_CONTENTS');
						}
					break;

					case 'F':
						if (gridIdx <= dataRowCnt[2] - 1) {
							formNum   = gridF.getCellValue(gridIdx, 'UUID_SQ');
							strSource = gridF.getCellValue(gridIdx, 'HASH_VALUE');
						}
					break;
        		}

				var jsonSource = {
						GATE_CD  : '${ses.gateCd}',
						CONT_NUM : EVF.V('CONT_NUM'),
						CONT_CNT : EVF.V('VCONT_CNT'),
						FORM_NUM : formNum,
						CONTENTS : strSource
	        		};

				var str = JSON.stringify(jsonSource);

				var Data = {
						'certType'     : certType,
						'sourceString' : str,
						'certID'       : certID
					};
       			var param = JSON.stringify(Data);
				var cmd = 'KICA_USE_P7Sign_Result.generatePKCS7SignedData';

				secukitnxInterface.SecuKitNXS(cmd, param);

        	} else {
        		if (val == null || val == '') {
    				alert('${BECM_030_0049}');
    				return ;
        		}

        		switch (signType) {
        		case 'M':
					EVF.V('SIGN_VALUE', val);

					dataRowCnt[0] = -1;

					if (dataRowCnt[1] == 0) {
						dataRowCnt[1] = -1;

						if (dataRowCnt[2] == 0) {
							dataRowCnt[2] = -1;
						} else {
							signType = 'F';
							gridIdx  = 0;
						}
					} else {
						signType = 'S';
						gridIdx  = 0;
					}

					break;

				case 'S':
					grid.setCellValue(gridIdx, 'SIGN_VALUE', val);
					//console("grid\n"+grid.getCellValue(gridIdx,'SIGN_VALUE'));

					if (gridIdx >= dataRowCnt[1] - 1) {
						dataRowCnt[1] = -1;

						if (dataRowCnt[2] == 0) {
							dataRowCnt[2] = -1;
						} else {
							signType = 'F';
							gridIdx  = 0;
						}
					} else {
						gridIdx++;
					}
					break;

				case 'F':
					gridF.setCellValue(gridIdx, 'SIGN_VALUE', val);

					if (gridIdx >= dataRowCnt[2] - 1) {
						dataRowCnt[2] = -1;
					} else {
						gridIdx++;
					}
					break;
        		}

        		if (dataRowCnt[0] == -1 && dataRowCnt[1] == -1 && dataRowCnt[2] == -1) {

				   	var cmd  = 'EncVID.symmetricEncryptData';
				   	var Data = {
						   		  	'algorithm'   : algorithm,
		                            'keyName'     : keyName,
		                            'sourceString': vidRandom
                               };
			        var param = JSON.stringify(Data);
			        secukitnxInterface.SecuKitNXS(cmd, param);

				} else {
					doSignCert(certType, certID, 1, '');
				}

        	}
        }
		function doEncSignCert(signDiv, val) {

			if (signDiv == 1) {
        		var strSource = "";
        		switch (signType) {

        			case 'M':
						strSource = EVF.V('SIGN_VALUE');
					break;

					case 'S':

						if (gridIdx <= dataRowCnt[1] - 1) {
							strSource = grid.getCellValue(gridIdx, 'SIGN_VALUE');
						}
					break;

					case 'F':
						if (gridIdx <= dataRowCnt[2] - 1) {
							strSource = gridF.getCellValue(gridIdx, 'SIGN_VALUE');
						}
					break;
        		}

				var cmd  = 'EncVID_Result.symmetricEncryptData';
		        var Data = {
     		 				'algorithm'    : algorithm,
                			'keyName'      : keyName,
                			'sourceString' : strSource
     						};

		        var param = JSON.stringify(Data);
                secukitnxInterface.SecuKitNXS(cmd, param);

        	} else {
        		//console.log(signType + " signValue :" + val + "\n");
        		switch (signType) {

        		case 'M':
					EVF.V('SIGN_VALUE', val);

					dataRowCnt[0] = -1;

					if (dataRowCnt[1] == 0) {
						dataRowCnt[1] = -1;

						if (dataRowCnt[2] == 0) {
							dataRowCnt[2] = -1;
						} else {
							signType = 'F';
							gridIdx  = 0;
						}
					} else {
						signType = 'S';
						gridIdx  = 0;
					}

					break;

				case 'S':
					grid.setCellValue(gridIdx, 'SIGN_VALUE', val);

					if (gridIdx >= dataRowCnt[1] - 1) {
						dataRowCnt[1] = -1;

						if (dataRowCnt[2] == 0) {
							dataRowCnt[2] = -1;
						} else {
							signType = 'F';
							gridIdx  = 0;
						}
					} else {
						gridIdx++;
					}
					break;

				case 'F':
					gridF.setCellValue(gridIdx, 'SIGN_VALUE', val);

					if (gridIdx >= dataRowCnt[2] - 1) {
						dataRowCnt[2] = -1;
					} else {
						gridIdx++;
					}
					break;
        		}

        		if (dataRowCnt[0] == -1 && dataRowCnt[1] == -1 && dataRowCnt[2] == -1) {

        			var store = new EVF.Store();
        			store.setParameter('mainContractContents', CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                	store.setGrid([grid]);
                    store.getGridData(grid, 'all');
                    store.setGrid([gridP]);
                    store.getGridData(gridP, 'all');
                    store.setGrid([gridU]);
                    store.getGridData(gridU, 'all');
                    store.setGrid([gridF]);
                    store.getGridData(gridF, 'all');
                    store.doFileUpload(function () {
	                    store.load(baseUrl + "doSignContract", function(){
	                    	EVF.C('TRANSACTION_FLAG').setValue('Y');
	                    	alert(this.getResponseMessage());

	                    	if (opener){
	    	                     opener['doSearch']();
	                     	}
	                         doClose();
	                    });
                    });
				} else {
					doEncSignCert(1, '');
				}
        	}
		}

        function getRejectPopup() {
            var params =
            {
                callBackFunction: 'doReject'
            };
            everPopup.openContractRejectReason(params);
        }
        // parteners Refuse
        function doReject(resultJson) {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            store.setParameter('reason', resultJson.reason);
            store.doFileUpload(function () {
                store.load(baseUrl + "doReject", function () {
                	EVF.C('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    opener.doSearch();
                    doClose();
                });
            });
        }

        function doClose() {
            if ('${param.appDocNum}' == '') {
                window.close();
            } else {
                doClose2();
            }
        }

        function doClose2() {
            new EVF.ModalWindow().close(null);
        }

        function doSelectDrafter() {
            if (userType != 'S') { //contReqFlag != '02' &&
            	everPopup.openCommonPopup({
                    callBackFunction: "setDrafter"
                }, 'SP0040');
            }
        }

        function setDrafter(drafter) {
        	EVF.C("CONT_USER_ID").setValue(drafter.CTRL_USER_ID);
            EVF.C("CONT_USER_NM").setValue(drafter.CTRL_USER_NM);
        }

        function doSelectVendor() {
            if (userType != 'S') { //contReqFlag != '02' &&
                everPopup.openCommonPopup({
                    callBackFunction: "setVendor"
                }, 'SP0016');
            }
        }

        function setVendor(vendor) {
            EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
        }


        function doApproval() {

            var signStatus = 'P'; //this.getData();
            var store = new EVF.Store();

            if (!store.validate()) return;
            EVF.C("SIGN_STATUS").setValue(signStatus);


            if (signStatus == 'P') { //CASE : approval
                if (EVF.C('CONT_NUM').getValue() == '') {
                    alert('${BECM_030_004}');
                    return;
                }

            	var param = {
    				subject:  EVF.C('CONT_DESC').getValue(),
    				//docType: "CONT",
    				docType: "EC",
    				signStatus: "P",
    				screenId: "BECM_030",
    				approvalType: 'APPROVAL',
    				oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
    				attFileNum: "",
    				docNum: EVF.C('CONT_NUM').getValue(),
    				appDocNum: EVF.C('APP_DOC_NUM').getValue(),
    				bizCls1: "01", <%-- Classification(large) --%>
    				bizCls2: "02"/* (EVF.C("BS_TYPE").getValue() == "100" ? "01" : (EVF.C("BS_TYPE").getValue() == "200" ? "02" : "")) */, <%-- Classification(medium) --%>
    				bizCls3: "05", <%-- Classification(small) --%>
    				bizAmt: EVF.C("SUPPLY_AMT").getValue(), <%-- Classification Amount --%>
    				callBackFunction: "goApproval"
    			};
                everPopup.openApprovalRequestIIPopup(param);

            }
        }

        //approvel Popup return
        function goApproval(formData, gridData, attachData) {
            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            var store = new EVF.Store();

            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.setParameter('mainContractContents', CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
        	store.setParameter('CONT_DATE',EVF.C("CONT_START_DATE").getValue());
            store.doFileUpload(function () {
                store.load(baseUrl + "/doApproval", function () {
                    alert(this.getResponseMessage());
                    //location.href='/eversrm/eContract/eContractMgt/BECM_030/view.so?SCREEN_ID=BECM_030&popupFlag=true&CONT_NUM='+this.getParameter("CONT_NUM");
                    if (opener) {
                        opener.doSearch();
                        doClose();
                    } else {
                        var param = {
                            baseDataType: baseDataType,
                            contNum: EVF.C('CONT_NUM').getValue(),
                            contCnt: EVF.C('VCONT_CNT').getValue(),
                            detailView: true,
                            contractEditable: false
                        };
                        location.href = baseUrl + 'view.so?' + $.param(param);
					 }
                });
            });
        }

        //buyer sign
        function doBuyerSign(formData, gridData, attachData) {

        	var store = new EVF.Store();
           	store.doFileUpload(function () {
           		store.load(baseUrl + "/doBuyerSign", function () {
            		EVF.C('TRANSACTION_FLAG').setValue('Y');

            		alert(this.getResponseMessage());

            		if (opener) {
            			opener.doSearch();
                		doClose();
            		} else {
            			var param = {baseDataType     : 'soContract',
                    		         contNum          : EVF.C('CONT_NUM').getValue(),
                        		     contCnt          : EVF.C('VCONT_CNT').getValue(),
	                            	 detailView       : true,
	    	                         contractEditable : false
    	    	                	};
                        location.href = baseUrl + 'view.so?' + $.param(param);
                	}
                });
            });
        }

        function onChangeSendApproval() {

        	alert ("onChangeSendApproval");
        	var mFlag = EVF.C('MANUAL_CONT_FLAG').getValue();
            if (mFlag == '0') { 	    //system cont.
                EVF.C('doSend').setVisible(true);
                EVF.C('doApproval').setVisible(false);
            } else {					//manual cont.
                EVF.C('doApproval').setVisible(true);
            }
        }

        function _onChangeManualContFlag() {
            var mContFlag = EVF.C('MANUAL_CONT_FLAG').getValue();
            if (mContFlag == '1') {
                EVF.C('doSend').setLabel('계약완료');
            } else {
                EVF.C('doSend').setLabel('전송');
            }
        }

        function doRejectFromBuyer() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if (!confirm('${BECM_030_0019}')) {
                return;
            }

            store.doFileUpload(function () {
                store.load(baseUrl + "doRejectFromBuyer", function () {
                	EVF.C('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());
                    if (opener) {
                        opener['doSearch']();
                    }
                    doClose();
                });
            });
        }

    	function doSearchItem() {
    		var stockItemYn = "";
    		var soleItemYn  = "0";
    		var disabledId  = "";

    		if(baseDataType == 'contract') {
        		//stockItemYn = "1";
        		soleItemYn  = "1";
    			//disabledId  = "STOCK_ITEM_YN";
    		}

	    	var param = {
                callBackFunction : "setItems",
                BUSINESS_TYPE: '100',
	            PACKAGE_TYPE: '100',
	            stockItemYn : stockItemYn,      /* 재고여부 Y:1, N:0 */
	            soleItemYn  : soleItemYn,       /* 총판품목여부 Y:1, N:0 */
	            disabledId  : disabledId,       /* 비활성화(변경못함) 필드 콤마(,)구분 */
	            ITEM_CLS1: 'S1',
	            ITEM_CLS2: '',
	            ITEM_CLS3: '',
	            ITEM_CLS4: '',
                detailView : false
            };

            everPopup.openPopupByScreenId("BPR_041", 1300, 700, param);
	    }

    	function setItems(data) {

 	    	var itemData = JSON.parse(data);
 	    	var dataArr = [];

 	    	var dupItem = false;
			for(idx in itemData) {
 				var arr = {
                     'ITEM_CD'        : itemData[idx].ITEM_CD,
                     'ITEM_DESC'      : itemData[idx].ITEM_DESC,
                     'ITEM_SPEC'      : itemData[idx].ITEM_SPEC,
                     'PO_QT'          : 0,
                     'UNIT_CD'        : itemData[idx].UNIT_CD,
                     'UNIT_PRC'       : 0 ,
                     'ITEM_AMT'       : 0 ,
                     'VENDOR_CD'      : "",
                     'VENDOR_NM'      : "",
                     'ITEM_RMK'       : "",
                     'ADD_VENDOR_FLAG': "N",
                     'ACC_ATTR'       : itemData[idx].ACC_ATTR,
                     'ITEM_CLS4'      : itemData[idx].ITEM_CLS4
                	};

	    		if(EVF.V('ACC_ATTR') == ''){
 		    		EVF.V('ACC_ATTR',itemData[idx].ACC_ATTR);
 		    	}

				if(EVF.V('ACC_ATTR') == itemData[idx].ACC_ATTR){
					dataArr.push(arr);
				} else {
					dupItem = true;
				}
			}

			gridP.addRow(dataArr);

			if (dupItem) {
				alert('${BECM_030_0029}');
			}

			if(baseDataType == 'contract') {
				gridP_readOnly_F();
			}
		}

    	function gridP_readOnly_F(){
			var allRowId = gridP.getAllRowId();
	    	 for(var i in allRowId) {
	         	var rowId = allRowId[i];
	            gridP.setCellReadOnly(rowId, 'DELY_YM', false);
	            gridP.setCellReadOnly(rowId, 'UNIT_PRC', false);
	            gridP.setCellReadOnly(rowId, 'PO_QT', false);
			}
		}

		function getSalesUserId() {
  			var param = {
  				callBackFunction : "setSalesUserId"
  			};

  			if(userType == 'C'){
  				everPopup.openCommonPopup(param, 'SP0067');
			}
  			else {

  			}

  		}

    	function setSalesUserId(dataJsonArray) {
   			EVF.C("CONT_USER_ID").setValue(dataJsonArray.USER_ID);
   			EVF.C("CONT_USER_NM").setValue(dataJsonArray.USER_NM);
   		}

    	function changeSupplyAmt() {
			var totItemAmt = 0;
			var rowIds = gridP.getAllRowId();

			for(var rowId in rowIds) {
				totItemAmt = totItemAmt + Number(gridP.getCellValue(rowId, 'ITEM_AMT'));
    		}

			EVF.C("SUPPLY_AMT").setValue(totItemAmt);

    		changePreRate(); 			// payment condition
			doSelect_stamp_duty_AMT();	// stamp duty
    		changeDelayRate();			// delay rate
    	}

    	function changePreRate() {
    		changeGuaranteeRate();
    	}

    	function changeGuaranteeRate(){

			var adv_guar_percent  = EVF.V("ADV_GUAR_PERCENT");
	   	  	var cont_guar_percent = EVF.V('CONT_GUAR_PERCENT');
	      	var warr_guar_percent = EVF.V('WARR_GUAR_PERCENT');

			var pre_rate   = EVF.V("PRE_RATE");
	      	var supply_amt = EVF.V('SUPPLY_AMT');

	    	if (userType == 'C') {
	    	    if(adv_guar_percent > 0 && pre_rate > 0){
		    		EVF.C("ADV_GUAR_FLAG").setValue("1");
		    		EVF.C('ADV_VAT_FLAG').setValue("1");
	         		EVF.C('ADV_VAT_FLAG').setReadOnly(true);

	         		adv_guar_amt = (supply_amt * pre_rate / 100) * (adv_guar_percent / 100) ;
	         		adv_guar_vat = adv_guar_amt * 1.1;

		    		EVF.V('ADV_GUAR_AMT', adv_guar_vat);

	    		} else {
		    		EVF.C("ADV_GUAR_FLAG").setValue("0");
		    		EVF.C("ADV_VAT_FLAG").setValue("");
		    		EVF.C('ADV_VAT_FLAG').setReadOnly(true);

		    		EVF.C("ADV_GUAR_AMT").setValue("");
	    		}

	    		if(cont_guar_percent > 0 ){
	        		EVF.C('CONT_GUAR_FLAG').setValue("1");
	        		EVF.C('CONT_VAT_FLAG').setValue("1");
	         		EVF.C('CONT_VAT_FLAG').setReadOnly(true);

	         		cont_guar_amt = supply_amt * (cont_guar_percent / 100) ;
	         		cont_guar_vat = cont_guar_amt * 1.1;

		    		EVF.V('CONT_GUAR_AMT',cont_guar_vat);

		       	} else {
	        		EVF.C("CONT_GUAR_FLAG").setValue("0");
	    			EVF.C("CONT_VAT_FLAG").setValue("");
	        		EVF.C('CONT_VAT_FLAG').setReadOnly(true);

	        		EVF.C("CONT_GUAR_AMT").setValue("");
		       	}

				if (warr_guar_percent > 0 ){
		    		EVF.C("WARR_GUAR_FLAG").setValue("1");
		    		EVF.C('WARR_VAT_FLAG').setValue("1");
	         		EVF.C('WARR_VAT_FLAG').setReadOnly(true);

	         		warr_guar_amt = supply_amt * (warr_guar_percent / 100) ;
	         		warr_guar_vat = warr_guar_amt * 1.1;

		    		EVF.V('WARR_GUAR_AMT',warr_guar_vat);
		    		EVF.C('WARR_GUAR_QT').setReadOnly(false);
				} else {
		    		EVF.C("WARR_GUAR_FLAG").setValue("0");
					EVF.C("WARR_VAT_FLAG").setValue("");
		    		EVF.C('WARR_VAT_FLAG').setReadOnly(true);

		    		EVF.C("WARR_GUAR_AMT").setValue("");
		    		EVF.C('WARR_GUAR_QT').setValue("");
		    		EVF.C('WARR_GUAR_QT').setReadOnly(true);
				}
	    	}
		}

		function changeDelayRate() {
			var delay_nume_rate = EVF.V("DELAY_NUME_RATE");
			var delay_deno_rate = EVF.V("DELAY_DENO_RATE");

			if (delay_nume_rate > 0 && delay_deno_rate > 0) {
		      	var supply_amt = EVF.V('SUPPLY_AMT');

		      	var delay_amt = supply_amt * (delay_nume_rate / delay_deno_rate);
		      	EVF.V('DELAY_AMT', delay_amt);
			} else {
				EVF.V('DELAY_AMT', "0");
			}
		}

		function doGuarNotify(){

	    	var guarantee_flag = this.getData();
	 		var vendor_cd = EVF.C("VENDOR_CD").getValue();
    		var store = new EVF.Store();
            store.setParameter('guarantee_flag',   guarantee_flag);
            store.setParameter('CONT_NUM',   contNum);
            store.setParameter('CONT_CNT',   EVF.C('VCONT_CNT').getValue());
			store.doFileUpload(function () {
				store.load(baseUrl + 'guaranteeNotify', function () {
					alert(this.getResponseMessage());
					var param = {
                            baseDataType:baseDataType,
                            CONT_NUM  : contNum,
                            CONT_CNT  : contCnt,
                            detailView: false,
                            contractEditable: false,
                            signStatus: EVF.V("SIGN_STATUS"),
                            VENDOR_CD : vendor_cd
                         };

           			location.href = baseUrl + 'view.so?' + $.param(param);
				});
			});
        }

        function doGuarCancel(){

        	var guarantee_flag = this.getData();
        	var vendor_cd=EVF.C("VENDOR_CD").getValue();
        	if (guarantee_flag == '004') {
        		insurance_number = EVF.V('ADV_GUAR_NUM');
        	} else if (guarantee_flag == '002') {
        		insurance_number = EVF.V('CONT_GUAR_NUM');
        	} else if (guarantee_flag == '003') {
        		insurance_number = EVF.V('WARR_GUAR_NUM');
        	}

    		var store = new EVF.Store();
            store.setParameter('guarantee_flag',   guarantee_flag);
            store.setParameter('insurance_number', insurance_number);

			store.doFileUpload(function () {
				store.load(baseUrl + 'guaranteeCancel', function () {
					alert(this.getResponseMessage());

                    var param = {
                            baseDataType:baseDataType,
                            CONT_NUM: contNum,
                            CONT_CNT: contCnt,
                            detailView: false,
                            contractEditable: false,
                            signStatus: EVF.V("SIGN_STATUS"),
                            VENDOR_CD : vendor_cd
                         };

           			location.href = baseUrl + 'view.so?' + $.param(param);
				});
            });
        }

        /*
        function doGuarComplete(){

        	var guarantee_flag = this.getData();

        	if (guarantee_flag == '004') {
        		insurance_number = EVF.V('ADV_GUAR_NUM');
        	} else if (guarantee_flag == '002') {
        		insurance_number = EVF.V('CONT_GUAR_NUM');
        	} else if (guarantee_flag == '003') {
        		insurance_number = EVF.V('WARR_GUAR_NUM');
        	}

    		var store = new EVF.Store();
            store.setParameter('guarantee_flag',   guarantee_flag);
            store.setParameter('insurance_number', insurance_number);

			store.doFileUpload(function () {
				store.load(baseUrl + 'guaranteeComplete', function () {
					alert(this.getResponseMessage());

                    var param = {
                            baseDataType:baseDataType,
                            CONT_NUM   : contNum,
                            CONT_CNT   : contCnt,
                            detailView : false,
                            contractEditable: false,
                            signStatus : EVF.V("SIGN_STATUS"),
                            VENDOR_CD  : vendor_cd
                         };

           			location.href = baseUrl + 'view.so?' + $.param(param);
				});
            });
        }
		*/

		function onChangeStartDate() {
			var contStartDate = EVF.V("CONT_START_DATE");

			if (contStartDate != null && contStartDate != '') {

				if (!everDate.fromTodateValid('DATE', 'CONT_START_DATE', '${ses.dateFormat }')) {
					EVF.C("CONT_START_DATE").setValue("");
					return alert('${BECM_030_0024}');
				}

			}
		}
    </script>

    <c:choose>
    <c:when test="${ses.userType == 'C'}">
       <c:set value="전자계약서 생성" var="screenName"/>
       <c:set value= "5" var ="colCnt"/>
    </c:when>
    <c:otherwise>
 	   <c:set value="전자계약서 상세" var="screenName"/>
 	   <c:set value= "1" var ="colCnt"/>
    </c:otherwise>
    </c:choose>
   	<e:window id="BECM_030" onReady="init" initData="${initData}" title ="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 4px">
		<%--
		<e:searchPanel id="form" labelWidth="${labelWidth}" width="100%"  useTitleBar="false">
		<e:buttonBar id="buttonBar" align="right" width="100%">

            <c:if test="${param.detailView == 'false'}">
                <c:if test="${ses.userType == 'C' && ses.ctrlCd != ''}">
                    <c:if test="${form.PROGRESS_CD !='4300'}">
                        <e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" data="${ses.userType}_SAVE" visible="${doSave_V}"/>
                    </c:if>
                    <c:if test="${form.PROGRESS_CD !='4230' and form.PROGRESS_CD !='4300'}">
                        <e:button id="doSend" name="doSend" label="${form.MANUAL_CONT_FLAG == '1' ? '계약완료' : doSend_N}" onClick="doSend" disabled="${doSend_D}" visible="${doSend_V}"/>
                    </c:if>
                    <c:if test="${form.CONT_NUM != null && !(param.contReqFlag == '02' && param.contReqStatus == 'C') && (form.PROGRESS_CD =='4200' or form.PROGRESS_CD =='4220') }"> 작성중이거나 반려일 경우만
                        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
                    </c:if>
                    <c:if test="${form.PROGRESS_CD =='4230' and not param.rejectProcess}">
                        <e:button id="doBuyerSign" name="doBuyerSign" label="${doSign_N}" onClick="doBuyerSign" disabled="${doBuyerSign_D}" visible="${doBuyerSign_V}"/>
                    </c:if>
                    <c:if test="${form.PROGRESS_CD =='4230' and param.rejectProcess}">
                        <e:button id="doRejectFromBuyer" name="doRejectFromBuyer" label="${doRejectFromBuyer_N}" onClick="doRejectFromBuyer" disabled="${doRejectFromBuyer_D}" visible="${doRejectFromBuyer_V}"/>
                    </c:if>

                </c:if>
                <c:if test="${ses.userType == 'S' && form.PROGRESS_CD =='4210'}">
                    <e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
                    <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="getRejectPopup" disabled="${doReject_D}" visible="${doReject_V}"/>
                </c:if>
            </c:if>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>

        </e:buttonBar>
        <e:button id="doBuyerSign" name="doBuyerSign" label="${doSign_N}" onClick="doBuyerSign" disabled="${doBuyerSign_D}" visible="${doBuyerSign_V}"/>
        <e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doApproval" disabled="${doApproval_D}" visible="${doApproval_V}" />
        <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" width="0" disabled="${doClose_D}" visible="false" />
        --%>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<c:if test="${ses.userType == 'C'}">
				<c:if test="${form.PROGRESS_CD =='4200' || form.PROGRESS_CD =='4210' || form.PROGRESS_CD =='4220' || form.PROGRESS_CD ==null}">
			 		<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" data="${ses.userType}_SAVE" />
            			<c:if test="${fn:indexOf(ses.ctrlCd, 'N100') != -1}">
 							<e:button id="doSend" name="doSend" label="${doSend_N}" onClick="doSend" disabled="${doSend_D}" visible="${doSend_V}"/>
           				</c:if>
				</c:if>
			</c:if>
            <c:if test="${ses.userType == 'S' && form.PROGRESS_CD =='4210'}">
            	<c:if test="${param.baseDataType =='contract'}">
            		<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" data="${ses.userType}_SAVE" />
            	</c:if>
				<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
				<e:button id="doReject" name="doReject" label="${doReject_N}" onClick="getRejectPopup" disabled="${doReject_D}" visible="${doReject_V}"/>
			</c:if>
			<c:if test="${ses.userId == 'MASTER'}">
			</c:if>
               <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="false" visible="true"/>
		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="150" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id='baseDataType' name='baseDataType' value='${param.baseDataType}' />
			<e:inputHidden id='DOC_TYPE' name='DOC_TYPE' value='${form.DOC_TYPE}' />
	        <e:inputHidden id="CONT_WT_NUM" name="CONT_WT_NUM" value="${param.CONT_WT_NUM}" />
			<e:inputHidden id='SO_NUM' name='SO_NUM' value="${empty form.SO_NUM ? param.SO_NUM : form.SO_NUM}"/>
			<e:inputHidden id='SO_CNT' name ='SO_CNT' value ="${empty form.SO_CNT ? param.SO_CNT : form.SO_CNT}"/>
			<e:inputHidden id='EXEC_NUM' name='EXEC_NUM' value='${empty form.EXEC_NUM ? param.EXEC_NUM : form.EXEC_NUM}' />
			<e:inputHidden id="devYn" name="devYn" value="${devYn}" />
			<e:inputHidden id="vendorConfY" name="vendorConfY" value="${vendorConfY}" />
			<e:inputHidden id='serverSignYN' name='serverSignYN' value='${form.serverSignYN}' />
			<e:inputHidden id="irsnoCheckFlag" name="irsnoCheckFlag" value="${irsnoCheckFlag}" />
			<e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N" />
			<e:inputHidden id="VENDOR_EDIT_FLAG" name="VENDOR_EDIT_FLAG" value="0" />

			<e:inputHidden id='mainForm' name='mainForm' value='${param.mainForm}' />
			<e:inputHidden id='additionalForm' name='additionalForm' value='${param.additionalForm}' />
			<e:inputHidden id='formContents' name='formContents' value='${form.formContents}' />
			<e:inputHidden id='signFormContents' name='signFormContents' value='${form.signFormContents}' />
			<e:inputHidden id='mainContents' name='mainContents' value='${form.mainContents}' />
			<e:inputHidden id='approvalFormData' name='approvalFormData' />
			<e:inputHidden id='approvalGridData' name='approvalGridData' />
			<e:inputHidden id='attachFileDatas' name='attachFileDatas' />
			<e:inputHidden id="vendorMasterList" name="vendorMasterList" />

			<e:inputHidden id='CONT_CNT' name='CONT_CNT' value="${empty form.CONT_CNT ? param.CONT_CNT : form.CONT_CNT}" />
			<e:inputHidden id='ACC_ATTR' name='ACC_ATTR' value="${empty form.ACC_ATTR ? param.ACC_ATTR : form.ACC_ATTR}" />
			<e:inputHidden id='ITEM_CLS4' name='ITEM_CLS4' value="${empty form.ITEM_CLS4 ? param.ITEM_CLS4 : form.ITEM_CLS4}" />
			<e:inputHidden id='SO_TYPE' name='SO_TYPE' value="${empty form.SO_TYPE ? param.SO_TYPE : form.SO_TYPE}" />
			<e:inputHidden id='MAIN_FORM_NUM' name='MAIN_FORM_NUM' value='${form.MAIN_FORM_NUM}' />
			<e:inputHidden id='CONTRACT_TEXT_NUM' name='CONTRACT_TEXT_NUM' value='${form.CONTRACT_TEXT_NUM}' />
			<e:inputHidden id='IRS_NUM' name='IRS_NUM' value='${form.IRS_NUM}' />
			<e:inputHidden id="RFXTYPE" name ="RFXTYPE" value ="${empty form.RFXTYPE ? param.RFXTYPE : form.RFXTYPE }"/>
			<e:inputHidden id="RFX_RYQ" name ="RFX_RYQ" value ="${empty form.RFX_RYQ ? param.RFX_RYQ : form.RFX_RYQ }"/>
			<e:inputHidden id="CONT_DATE" name="CONT_DATE" value="${empty form.CONT_START_DATE ? param.CONT_START_DATE : form.CONT_START_DATE}" />
  		    <e:inputHidden id="CONT_AMT" name="CONT_AMT" value="${empty form.CONT_AMT ? param.CONT_AMT : form.CONT_AMT}"/>
			<e:inputHidden id='VAT_FLAG' name='VAT_FLAG' value="${empty form.VAT_FLAG ? '1' : form.VAT_FLAG}" />
			<e:inputHidden id='REG_USER_ID' name='REG_USER_ID' value='${form.REG_USER_ID}' />
			<e:inputHidden id='APP_DOC_NUM' name='APP_DOC_NUM' value='${form.APP_DOC_NUM}' />
			<e:inputHidden id='APP_DOC_CNT' name='APP_DOC_CNT' value='${form.APP_DOC_CNT}' />
			<e:inputHidden id='SIGN_STATUS' name='SIGN_STATUS' value='${form.SIGN_STATUS}' />
			<e:inputHidden id='SIGN_VALUE' name='SIGN_VALUE' value='' />
			<e:inputHidden id="ADV_GUAR_NUM" name ="ADV_GUAR_NUM" value ="${form.ADV_GUAR_NUM}"/>
			<e:inputHidden id="CONT_GUAR_NUM" name ="CONT_GUAR_NUM" value ="${form.CONT_GUAR_NUM}"/>
			<e:inputHidden id="WARR_GUAR_NUM" name ="WARR_GUAR_NUM" value ="${form.WARR_GUAR_NUM}"/>
			<e:inputHidden id="DATE" name="DATE"  value ="${yyyymmdd}"/>
			<e:inputHidden id="UserSignCert" name= "UserSignCert" value=""/>
			<e:inputHidden id="ServerKmCert" name ="ServerKmCert" value="${form.ServerKmCert}" />
			<e:inputHidden id="EncryptedSessionKeyForServer" name ="EncryptedSessionKeyForServer" value="" />
			<e:inputHidden id="EncryptedUserRandomNumber" name ="EncryptedUserRandomNumber"/>
			<e:inputHidden id="VENDOR_PROGRESS_CD" name="VENDOR_PROGRESS_CD" value="${param.VENDOR_PROGRESS_CD}"  />
			<e:inputHidden id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="${empty form.MANUAL_CONT_FLAG ? 0 : form.MANUAL_CONT_FLAG }"/>

			<e:row>
				<e:label for="CONT_NUM" title="${form_CONT_NUM_N }" />
				<e:field>
					<e:inputText id="CONT_NUM" name="CONT_NUM" value="${empty form.CONT_NUM ? param.CONT_NUM : form.CONT_NUM}" width="70%" required="${form_CONT_NUM_R }" disabled="${form_CONT_NUM_D}" readOnly="${form_CONT_NUM_RO }" maxLength="${form_CONT_NUM_M}" />
					<e:text> / </e:text>
					<e:inputNumber id="VCONT_CNT" name="VCONT_CNT" value="${empty form.VCONT_CNT ? param.CONT_CNT : form.VCONT_CNT}" width="25" required="${form_VCONT_CNT_R }" disabled="${form_CONT_CNT_D}" readOnly="${form_CONT_NUM_RO }" />
					<%-- <e:inputNumber id="CONT_CNT" name="CONT_CNT" value="" width="${form_CONT_CNT_W}" disabled="${form_CONT_CNT_D}" readOnly="${form_CONT_CNT_RO}" required="${form_CONT_CNT_R}" /> --%>
				</e:field>
				<e:label for="CONT_DESC" title="${form_CONT_DESC_N }" />
				<e:field colSpan="3">
					<%--  <e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="${empty form.CONT_DESC ? param.CONT_DESC : form.CONT_DESC}" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}"/> --%>
					<e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="${empty form.CONT_DESC ? param.CONT_DESC : form.CONT_DESC}" readOnly="" maxLength="${form_CONT_DESC_M}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="SUPPLY_AMT" title="${form_SUPPLY_AMT_N}" />
				<e:field>
					<e:inputNumber id="SUPPLY_AMT" name="SUPPLY_AMT" value="${empty form.SUPPLY_AMT ? supplyAmt : form.SUPPLY_AMT}" width="90%" maxValue="${form_SUPPLY_AMT_M}" decimalPlace="${form_SUPPLY_AMT_NF}" disabled="${form_SUPPLY_AMT_D }" readOnly="${form_SUPPLY_AMT_RO}" required="${form_SUPPLY_AMT_R}" onChange="changeSupplyAmt"/>
					<e:text>원</e:text>
				</e:field>
				<e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N }" />
			 	<e:field>
					<e:inputDate id="CONT_START_DATE" toDate="CONT_END_DATE" width="${inputDateWidth}" name="CONT_START_DATE" value="${empty kphdinfo.CONT_START_DATE ? form.CONT_START_DATE : kphdinfo.CONT_START_DATE}" required="${form_CONT_START_DATE_R }" readOnly="${form_CONT_START_DATE_RO }" disabled="${form_CONT_START_DATE_D }" datePicker="true"  format="yyyy-MM-dd" onChange="onChangeStartDate"/>
					<e:text>~</e:text>
			 		<e:inputDate id="CONT_END_DATE" fromDate="CONT_START_DATE" name="CONT_END_DATE" value="${empty kphdinfo.CONT_END_DATE ? form.CONT_END_DATE : kphdinfo.CONT_END_DATE}" width="${inputDateWidth}"  required="${form_CONT_END_DATE_R }" readOnly="${form_CONT_END_DATE_RO }" disabled="${form_CONT_END_DATE_D }" datePicker="true"  format="yyyy-MM-dd"  />
				</e:field>
				<e:label for="CONT_USER_ID" title="${form_CONT_USER_ID_N}" />
				<e:field>
					<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${empty form.BUYER_CD ? param.BUYER_CD : form.BUYER_CD}" />
					<e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${empty form.BUYER_NM ? param.BUYER_NM : form.BUYER_NM}" />
					<e:search id="CONT_USER_ID" style="ime-mode:inactive" name="CONT_USER_ID" value="${empty form.CONT_USER_ID ? ses.userId : form.CONT_USER_ID}" width="${form_CONT_USER_ID_W}" maxLength="${form_CONT_USER_ID_M}" disabled="${form_CONT_USER_ID_D}" readOnly="${form_CONT_USER_ID_RO}" required="${form_CONT_USER_ID_R}" onIconClick="${(!param.detailView || param.detailView == null) ? 'getSalesUserId' : 'everCommon.blank'}" />
					<e:inputText id="CONT_USER_NM" style="${imeMode}" name="CONT_USER_NM" value="${empty form.CONT_USER_NM ? ses.userNm : form.CONT_USER_NM}" width="${form_CONT_USER_NM_W}" maxLength="${form_CONT_USER_NM_M}" disabled="${form_CONT_USER_NM_D}" readOnly="${form_CONT_USER_NM_RO}" required="${form_CONT_USER_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
			<c:if test="${ses.userType == 'C'}">
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N }" width="100%" />
				<e:field>
					<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${empty form.VENDOR_CD ? param.VENDOR_CD : form.VENDOR_CD}" width="${form_VENDOR_CD_W}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:search id="VENDOR_NM" name="VENDOR_NM" value="${empty form.VENDOR_NM ? param.VENDOR_NM : form.VENDOR_NM}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onIconClick="doSearchVendor" />
					<e:inputHidden id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="" width="${form_VENDOR_PIC_USER_NM_W}" disabled="${form_VENDOR_PIC_USER_NM_D}" readOnly="${form_VENDOR_PIC_USER_NM_RO}" required="${form_VENDOR_PIC_USER_NM_R}" />
				</e:field>
			</c:if>

			<c:if test="${ses.userType == 'S'}">
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${empty form.VENDOR_CD ? param.VENDOR_CD : form.VENDOR_CD}" width="${form_VENDOR_CD_W}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
				<e:inputHidden id="VENDOR_NM" name="VENDOR_NM" value="${st_default}"  visible="${everMultiVisible}" required="false" readOnly="false" disabled="false" />
				<e:inputHidden id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="" width="${form_VENDOR_PIC_USER_NM_W}" disabled="${form_VENDOR_PIC_USER_NM_D}" readOnly="${form_VENDOR_PIC_USER_NM_RO}" required="${form_VENDOR_PIC_USER_NM_R}" />
			</c:if>
				<e:label for="BUYER_SIGN_DATE" title="${form_BUYER_SIGN_DATE_N}" />
				<e:field>
					<e:inputDate id="BUYER_SIGN_DATE" name="BUYER_SIGN_DATE" value="${form.BUYER_SIGN_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_BUYER_SIGN_DATE_R}" disabled="${form_BUYER_SIGN_DATE_D}" readOnly="${form_BUYER_SIGN_DATE_RO}" />
				</e:field>
				<e:label for="VENDOR_SIGN_DATE" title="${form_VENDOR_SIGN_DATE_N}" width="100%" />
			<c:if test="${ses.userType == 'C'}">
				<e:field>
					<e:inputDate id="VENDOR_SIGN_DATE" name="VENDOR_SIGN_DATE" value="${form.VENDOR_SIGN_DATE}" width="${inputDateWidth}"  datePicker="true" required="${form_VENDOR_SIGN_DATE_R}" disabled="${form_VENDOR_SIGN_DATE_D}" readOnly="${form_VENDOR_SIGN_DATE_RO}" />
				</e:field>
			</c:if>
			<c:if test="${ses.userType == 'S'}">
				<e:field colSpan="3">
					<e:inputDate id="VENDOR_SIGN_DATE" name="VENDOR_SIGN_DATE" value="${form.VENDOR_SIGN_DATE}" width="${inputDateWidth}"  datePicker="true" required="${form_VENDOR_SIGN_DATE_R}" disabled="${form_VENDOR_SIGN_DATE_D}" readOnly="${form_VENDOR_SIGN_DATE_RO}" />
				</e:field>
			</c:if>
			</e:row>

			<c:if test="${ses.userType == 'C'}">
			<e:row>
				<e:label for="CONTRACT_TYPE" title="${form_CONTRACT_TYPE_N}" width="100%" />
				<e:field>
					<e:select id="CONTRACT_TYPE" name="CONTRACT_TYPE" value="${empty form.CONTRACT_TYPE ? param.SELECT_FORM_NUM : form.CONTRACT_TYPE}" options="${contractTypeOptions}" width="${form_CONTRACT_TYPE_W}" disabled="${form_CONTRACT_TYPE_D}" readOnly="${form_CONTRACT_TYPE_RO}" required="${form_CONTRACT_TYPE_R}" placeHolder=""  />
				</e:field>
				<e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"/>
				<e:field>
					<e:select id="CONT_REQ_CD" name="CONT_REQ_CD" value="${empty form.CONT_REQ_CD ? param.contReqFlag : form.CONT_REQ_CD}" options="${contReqCdOptions}" width="${form_CONT_REQ_CD_W}" disabled="${form_CONT_REQ_CD_D}" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${empty form.PROGRESS_CD ? param.PROGRESS_CD : form.PROGRESS_CD}" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" usePlaceHolder="false"  />
				</e:field>
			</e:row>
			</c:if>

			<c:if test="${ses.userType == 'S'}">
			<e:row>
				<e:inputHidden id="CONTRACT_TYPE" name="CONTRACT_TYPE" value="${empty form.CONTRACT_TYPE ? param.SELECT_FORM_NUM : form.CONTRACT_TYPE}"  width="${form_CONTRACT_TYPE_W}" disabled="${form_CONTRACT_TYPE_D}" readOnly="${form_CONTRACT_TYPE_RO}" required="${form_CONTRACT_TYPE_R}" placeHolder=""  />
				<e:inputHidden id="CONT_REQ_CD" name="CONT_REQ_CD" value="${form.CONT_REQ_CD}"  width="${inputTextWidth}" disabled="true" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder=""  />
				<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${empty form.PROGRESS_CD ? param.PROGRESS_CD : form.PROGRESS_CD}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder=""  />
			</e:row>
			</c:if>
			<e:row>
				<e:label for="PAY_TERMS_CAPTION" title="${form_PAY_TERMS_CAPTION_N }" />
				<e:field colSpan="5">
					<e:text>${form_PRE_RATE_N }</e:text>
					<e:inputNumber id="PRE_RATE" name="PRE_RATE" value="${empty kphdinfo.PRE_RATE ? form.PRE_RATE : kphdinfo.PRE_RATE }" width="${form_PRE_RATE_W}" maxValue="${form_PRE_RATE_M}" decimalPlace="${form_PRE_RATE_NF}" disabled="${form_PRE_RATE_D}" readOnly="${form_PRE_RATE_RO}" required="${form_PRE_RATE_R}" onChange="changePreRate"/>
					<e:text>%&nbsp;/&nbsp;&nbsp;${form_MID_RATE_N }</e:text>
					<e:inputNumber id="MID_RATE" name="MID_RATE" value="${empty kphdinfo.MID_RATE ? form.MID_RATE : kphdinfo.MID_RATE }" width="${form_MID_RATE_W}" maxValue="${form_MID_RATE_M}" decimalPlace="${form_MID_RATE_NF}" disabled="${form_MID_RATE_D}" readOnly="${form_MID_RATE_RO}" required="${form_MID_RATE_R}" />
					<e:text>%&nbsp;/&nbsp;&nbsp;${form_BAL_RATE_N }</e:text>
					<e:inputNumber id="BAL_RATE" name="BAL_RATE" value="${empty kphdinfo.BAL_RATE ? form.BAL_RATE : kphdinfo.BAL_RATE }" width="${form_BAL_RATE_W}" maxValue="${form_BAL_RATE_M}" decimalPlace="${form_BAL_RATE_NF}" disabled="${form_BAL_RATE_D}" readOnly="${form_BAL_RATE_RO}" required="${form_BAL_RATE_R}" />
					<e:text>%&nbsp;/&nbsp;&nbsp;${form_COM_RATE_N }</e:text>
					<e:inputNumber id="COM_RATE" name="COM_RATE" value="${empty kphdinfo.COM_RATE ? form.COM_RATE : kphdinfo.COM_RATE }" width="${form_COM_RATE_W}" maxValue="${form_COM_RATE_M}" decimalPlace="${form_COM_RATE_NF}" disabled="${form_COM_RATE_D}" readOnly="${form_COM_RATE_RO}" required="${form_COM_RATE_R}" />
					<e:text>%&nbsp;</e:text>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ADV_GUAR_PERCENT" title="${form_ADV_GUAR_PERCENT_N }" />
				<e:field>
					<e:inputNumber id="ADV_GUAR_PERCENT" name="ADV_GUAR_PERCENT" width="${form_ADV_GUAR_PERCENT_W }" required="${form_ADV_GUAR_PERCENT_R }" disabled="${form_ADV_GUAR_PERCENT_D }" value="${empty kphdinfo.ADV_GUAR_PERCENT ? form.ADV_GUAR_PERCENT : kphdinfo.ADV_GUAR_PERCENT }" readOnly="${form_ADV_GUAR_PERCENT_RO }" onChange="changeGuaranteeRate"  />
				</e:field>

				<e:label for="ADV_GUAR_AMT" title="${form_ADV_GUAR_AMT_N }" />
				<e:field colSpan="3">
					<e:select id="ADV_VAT_FLAG" name="ADV_VAT_FLAG" value="${empty kphdinfo.ADV_VAT_FLAG ? form.ADV_VAT_FLAG : kphdinfo.ADV_VAT_FLAG}" options="${advVatFlagOptions}" width="13%" disabled="${form_ADV_VAT_FLAG_D}" readOnly="${form_ADV_VAT_FLAG_RO}" required="${form_ADV_VAT_FLAG_R}" placeHolder=""  />
					<e:inputNumber id="ADV_GUAR_AMT" name="ADV_GUAR_AMT" value="${empty kphdinfo.ADV_GUAR_AMT ? form.ADV_GUAR_AMT : kphdinfo.ADV_GUAR_AMT}" width="${form_ADV_GUAR_AMT_W}" maxValue="${form_ADV_GUAR_AMT_M}" decimalPlace="${form_ADV_GUAR_AMT_NF}" disabled="${form_ADV_GUAR_AMT_D}" readOnly="${form_ADV_GUAR_AMT_RO}" required="${form_ADV_GUAR_AMT_R}" />

				 	<e:inputHidden id="ADV_GUAR_FLAG" name="ADV_GUAR_FLAG" value="${empty kphdinfo.ADV_GUAR_FLAG ? form.ADV_GUAR_FLAG : kphdinfo.ADV_GUAR_FLAG }"  readOnly="${form_ADV_GUAR_FLAG_RO }" width="${form_ADV_GUAR_FLAG_W}" required="${form_ADV_GUAR_FLAG_R }" disabled="${form_ADV_GUAR_FLAG_D }"   />
			 		<c:if test="${(ses.userType == 'S') and (form.PROGRESS_CD == '4210' or form.PROGRESS_CD == '4230' or form.PROGRESS_CD == '4300')}">
						<c:if test="${form.ADV_INSU_STATUS == 'T' and form.ADV_GUAR_AMT > 0}">
							<e:button id="doAdvNotify" name="doAdvNotify" label="${doAdvNotify_N}" onClick="doGuarNotify" disabled="${doAdvNotify_D}" visible="${doAdvNotify_V}" data="004"/>
						</c:if>
						<c:if test="${form.ADV_INSU_STATUS == 'P' and form.ADV_GUAR_AMT > 0}">
							<e:button id="doAdvCancel" name="doAdvCancel" label="${doAdvCancel_N}" onClick="doGuarCancel" disabled="${doAdvCancel_D}" visible="${doAdvCancel_V}" data="004"/>
						</c:if>
						<c:if test="${form.ADV_INSU_STATUS == 'A' and form.ADV_GUAR_AMT > 0}">
						</c:if>
					</c:if>
				</e:field>
			</e:row>

			<e:row>
				<e:label for="CONT_GUAR_PERCENT" title="${form_CONT_GUAR_PERCENT_N }" />
				<e:field>
					<e:inputNumber id="CONT_GUAR_PERCENT" name="CONT_GUAR_PERCENT" width="${form_CONT_GUAR_PERCENT_W}" required="${form_CONT_GUAR_PERCENT_R }" disabled="${form_CONT_GUAR_PERCENT_D }"
					value="${empty kphdinfo.CONT_GUAR_PERCENT ?form.CONT_GUAR_PERCENT : kphdinfo.CONT_GUAR_PERCENT }" readOnly="${form_CONT_GUAR_PERCENT_RO }" onChange="changeGuaranteeRate"  />
				</e:field>
				<e:label for="CONT_GUAR_AMT" title="${form_CONT_GUAR_AMT_N }" />
				<e:field colSpan="3">
					<e:select id="CONT_VAT_FLAG" name="CONT_VAT_FLAG" value="${empty kphdinfo.CONT_VAT_FLAG ? form.CONT_VAT_FLAG : kphdinfo.CONT_VAT_FLAG}" options="${contVatFlagOptions}" width="13%" disabled="${form_CONT_VAT_FLAG_D}" readOnly="${form_CONT_VAT_FLAG_RO}" required="${form_CONT_VAT_FLAG_R}" placeHolder=""/>
					<e:inputNumber id="CONT_GUAR_AMT" name="CONT_GUAR_AMT" value="${empty kphdinfo.CONT_GUAR_AMT ? form.CONT_GUAR_AMT : kphdinfo.CONT_GUAR_AMT}" width="${form_CONT_GUAR_AMT_W}" maxValue="${form_CONT_GUAR_AMT_M}" decimalPlace="${form_CONT_GUAR_AMT_NF}" disabled="${form_CONT_GUAR_AMT_D}" readOnly="${form_CONT_GUAR_AMT_RO}" required="${form_CONT_GUAR_AMT_R}" />

					<e:inputHidden id="CONT_GUAR_FLAG" name="CONT_GUAR_FLAG" value="${empty kphdinfo.CONT_GUAR_FLAG ? form.CONT_GUAR_FLAG :kphdinfo.CONT_GUAR_FLAG }"  readOnly="${form_CONT_GUAR_FLAG_RO }" width="${form_CONT_GUAR_FLAG_W}" required="${form_CONT_GUAR_FLAG_R }" disabled="${form_CONT_GUAR_FLAG_D }" />
					<c:if test="${(ses.userType == 'S') and (form.PROGRESS_CD == '4210' or form.PROGRESS_CD == '4230' or form.PROGRESS_CD == '4300')}">
						<c:if test="${form.CONT_INSU_STATUS == 'T' and form.CONT_GUAR_AMT > 0}">
							<e:button id="doContNotify" name="doContNotify" label="${doContNotify_N}" onClick="doGuarNotify" disabled="${doContNotify_D}" visible="${doContNotify_V}" data="002"/>
						</c:if>
						<c:if test="${form.CONT_INSU_STATUS == 'P' and form.CONT_GUAR_AMT > 0}">
							<e:button id="doContCancel" name="doContCancel" label="${doContCancel_N}" onClick="doGuarCancel" disabled="${doContCancel_D}" visible="${doContCancel_V}" data="002"/>
						</c:if>

						<c:if test="${form.CONT_INSU_STATUS == 'A' and form.CONT_GUAR_AMT > 0}">
						</c:if>

					</c:if>
				</e:field>
			</e:row>
			<e:row>
		<e:label for="WARR_GUAR_PERCENT" title="${form_WARR_GUAR_PERCENT_N}" />
				<e:field>
					<e:inputNumber id="WARR_GUAR_PERCENT" name="WARR_GUAR_PERCENT" width="${form_WARR_GUAR_PERCENT_W}" required="${form_WARR_GUAR_PERCENT_R }" disabled="${form_WARR_GUAR_PERCENT_D }" value="${empty kphdinfo.WARR_GUAR_PERCENT ? form.WARR_GUAR_PERCENT : kphdinfo.WARR_GUAR_PERCENT}" readOnly="${form_WARR_GUAR_PERCENT_RO }" onChange="changeGuaranteeRate" />
					<e:text>/</e:text>
					<e:inputNumber id="WARR_GUAR_QT" name="WARR_GUAR_QT" width="${form_WARR_GUAR_QT_W}" required="${form_WARR_GUAR_QT_R }" disabled="${form_WARR_GUAR_QT_D }" value="${empty kphdinfo.WARR_GUAR_QT ? form.WARR_GUAR_QT : kphdinfo.WARR_GUAR_QT}" readOnly="${form_WARR_GUAR_QT_RO }" />
				</e:field>
				<e:label for="WARR_GUAR_AMT" title="${form_WARR_GUAR_AMT_N }" />
				<e:field  colSpan="3">
					<e:select id="WARR_VAT_FLAG" name="WARR_VAT_FLAG" value="${empty kphdinfo.WARR_VAT_FLAG ? form.WARR_VAT_FLAG : kphdinfo.WARR_VAT_FLAG}" options="${warrVatFlagOptions}" width="13%" disabled="${form_WARR_VAT_FLAG_D}" readOnly="${form_WARR_VAT_FLAG_RO}" required="${form_WARR_VAT_FLAG_R}" placeHolder=""  />
					<e:inputNumber id="WARR_GUAR_AMT" name="WARR_GUAR_AMT" value="${empty kphdinfo.WARR_GUAR_AMT ? form.WARR_GUAR_AMT : kphdinfo.WARR_GUAR_AMT}" width="${form_WARR_GUAR_AMT_W}" maxValue="${form_WARR_GUAR_AMT_M}" decimalPlace="${form_WARR_GUAR_AMT_NF}" disabled="${form_WARR_GUAR_AMT_D}" readOnly="${form_WARR_GUAR_AMT_RO}" required="${form_WARR_GUAR_AMT_R}" />

					<e:inputHidden id="WARR_GUAR_FLAG" name="WARR_GUAR_FLAG" value="${empty kphdinfo.WARR_GUAR_FLAG ? form.WARR_GUAR_FLAG :kphdinfo.WARR_GUAR_FLAG }"  readOnly="${form_WARR_GUAR_FLAG_RO }" width="${form_WARR_GUAR_FLAG_W}" required="${form_WARR_GUAR_FLAG_R }" disabled="${form_WARR_GUAR_FLAG_D }"   />
					<c:if test="${(ses.userType == 'S') and (form.PROGRESS_CD == '4210' or form.PROGRESS_CD == '4230' or form.PROGRESS_CD == '4300')}">
						<c:if test="${form.WARR_INSU_STATUS == 'T' and form.WARR_GUAR_AMT > 0}">
							<e:button id="doWarrNotify" name="doWarrNotify" label="${doWarrNotify_N}" onClick="doGuarNotify" disabled="${doWarrNotify_D}" visible="${doWarrNotify_V}" data="003"/>
						</c:if>
						<c:if test="${form.WARR_INSU_STATUS == 'P' and form.WARR_GUAR_AMT > 0}">
							<e:button id="doWarrCancel" name="doWarrCancel" label="${doWarrCancel_N}" onClick="doGuarCancel" disabled="${doWarrCancel_D}" visible="${doWarrCancel_V}" data="003"/>
						</c:if>

						<c:if test="${form.WARR_INSU_STATUS == 'A' and form.WARR_GUAR_AMT > 0}">
						</c:if>

					</c:if>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="STAMP_DUTY_FLAG" title="${form_STAMP_DUTY_FLAG_N}" />
				&nbsp;&nbsp;&nbsp;&nbsp;
				<e:field colSpan='${colCnt}'>
					<e:text> 인지세 여부&nbsp;&nbsp; </e:text>
				 	&nbsp;
					<e:check id="STAMP_DUTY_FLAG" name="STAMP_DUTY_FLAG" value="1" checked="${form.STAMP_DUTY_FLAG == '1' ? true : false }" width="${form_STAMP_DUTY_FLAG_W}" disabled="${form_STAMP_DUTY_FLAG_D}" readOnly="${form_STAMP_DUTY_FLAG_RO}" required="${form_STAMP_DUTY_FLAG_R}" placeHolder="" />
					<e:text>/&nbsp; </e:text>
					<e:inputNumber id="STAMP_DUTY_AMT" name="STAMP_DUTY_AMT" value="${empty form.STAMP_DUTY_AMT ? stamp_duty_flag.STAMP_DUTY_AMT : form.STAMP_DUTY_AMT}" width="${form_STAMP_DUTY_AMT_W}" maxValue="${form_STAMP_DUTY_AMT_M}" decimalPlace="${form_STAMP_DUTY_AMT_NF}" disabled="${form_STAMP_DUTY_AMT_D}" readOnly="${form_STAMP_DUTY_AMT_RO}" required="${form_STAMP_DUTY_AMT_R}" />
				</e:field>
				<c:if test="${(ses.userType == 'S')}">
				<e:label for="STAMP_DUTY_NUM" title="${form_STAMP_DUTY_NUM_N}" />
 				<e:field>
					<e:inputText id="STAMP_DUTY_NUM" name="STAMP_DUTY_NUM" value="${form.STAMP_DUTY_NUM}" width="${form_STAMP_DUTY_NUM_W}" maxLength="${form_STAMP_DUTY_NUM_M}" disabled="${form_STAMP_DUTY_NUM_D}" readOnly="${form_STAMP_DUTY_NUM_RO}" required="${form_STAMP_DUTY_NUM_R}" />
				</e:field>
				<e:label for="STAMP_ATT_FILE_NUM" title="${form_STAMP_ATT_FILE_NUM_N}" />
 				<e:field>
					<div style="width: 100%; height: 50px;">
					<e:fileManager id="STAMP_ATT_FILE_NUM"  name ="STAMP_ATT_FILE_NUM" height="20" width="" fileId="${form.STAMP_ATT_FILE_NUM}" readOnly="true" bizType="CT" required="${form_STAMP_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick"  />
					</div>
				</e:field>
				</c:if>
			</e:row>
			<e:row>
				<e:label for="DELAY_NUME_RATE" title="${form_DELAY_NUME_RATE_N}" />
				<e:field>
					<e:inputNumber id="DELAY_NUME_RATE" name="DELAY_NUME_RATE" value="${empty kphdinfo.DELAY_NUME_RATE ? form.DELAY_NUME_RATE : kphdinfo.DELAY_NUME_RATE }" width="${form_DELAY_NUME_RATE_W}" maxValue="${form_DELAY_NUME_RATE_M}" decimalPlace="${form_DELAY_NUME_RATE_NF}" disabled="${form_DELAY_NUME_RATE_D}" readOnly="${form_DELAY_NUME_RATE_RO}" required="${form_DELAY_NUME_RATE_R}" onChange="changeDelayRate"/>
					<e:text>/&nbsp; </e:text>
					<e:inputNumber id="DELAY_DENO_RATE" name="DELAY_DENO_RATE" value="${empty kphdinfo.DELAY_DENO_RATE ? form.DELAY_DENO_RATE : kphdinfo.DELAY_DENO_RATE }" width="${form_DELAY_DENO_RATE_W}" maxValue="${form_DELAY_DENO_RATE_M}" decimalPlace="${form_DELAY_DENO_RATE_NF}" disabled="${form_DELAY_DENO_RATE_D}" readOnly="${form_DELAY_DENO_RATE_RO}" required="${form_DELAY_DENO_RATE_R}" onChange="changeDelayRate"/>
				</e:field>
				<e:label for="DELAY_AMT" title="${form_DELAY_AMT_N}" />
				<e:field>
					<e:inputNumber id="DELAY_AMT" name="DELAY_AMT" value="${empty kphdinfo.DELAY_AMT ? form.DELAY_AMT : kphdinfo.DELAY_AMT }" width="${form_DELAY_AMT_W}" maxValue="${form_DELAY_AMT_M}" decimalPlace="${form_DELAY_AMT_NF}" disabled="${form_DELAY_AMT_D}" readOnly="${form_DELAY_AMT_RO}" required="${form_DELAY_AMT_R}" />

					<e:text>원</e:text>
				</e:field>

				<c:if test="${form.MAIN_FORM_NUM == 'FORM2017080300004'}">
					<e:label for="ALLOWANCE_RATE" title="${form_ALLOWANCE_RATE_N}" />
					<e:field>
						<e:inputNumber id="ALLOWANCE_RATE" name="ALLOWANCE_RATE" value="${form.ALLOWANCE_RATE}" width="${form_ALLOWANCE_RATE_W}" maxValue="${form_ALLOWANCE_RATE_M}" decimalPlace="${form_ALLOWANCE_RATE_NF}" disabled="${form_ALLOWANCE_RATE_D}" readOnly="${form_ALLOWANCE_RATE_RO}" required="${form_ALLOWANCE_RATE_R}" />
					</e:field>
				</c:if>
				<c:if test="${form.MAIN_FORM_NUM != 'FORM2017080300004'}">
					<e:label for=""><e:field></e:field></e:label>
					<e:inputHidden id='ALLOWANCE_RATE' name='ALLOWANCE_RATE' value='${form.ALLOWANCE_RATE}' />
				</c:if>
			</e:row>

			<c:if test="${ses.userType == 'C'}">
			<e:row>
				<e:label for="DELY_TERMS_DESC" title="${form_DELY_TERMS_DESC_N}" width="100%" />
				<e:field>
					<e:inputText id="DELY_TERMS_DESC" name="DELY_TERMS_DESC" value="${form.DELY_TERMS_DESC}" width="${form_DELY_TERMS_DESC_W}" maxLength="${form_DELY_TERMS_DESC_M}" disabled="${form_DELY_TERMS_DESC_D}" readOnly="${form_DELY_TERMS_DESC_RO}" required="${form_DELY_TERMS_DESC_R}" />
				</e:field>
				<e:label for="DELY_PLACE" title="${form_DELY_PLACE_N}" width="100%" />
				<e:field>
					<e:inputText id="DELY_PLACE" name="DELY_PLACE" value="${form.DELY_PLACE}" width="${form_DELY_PLACE_W}" maxLength="${form_DELY_PLACE_M}" disabled="${form_DELY_PLACE_D}" readOnly="${form_DELY_PLACE_RO}" required="${form_DELY_PLACE_R}" />
				</e:field>
				<e:label for="PAY_TERMS_DESC" title="${form_PAY_TERMS_DESC_N}" />
				<e:field>
					<e:inputText id="PAY_TERMS_DESC" name="PAY_TERMS_DESC" value="${empty form.PAY_TERMS_DESC ? kphdinfo.PAY_TERMS_DESC : form.PAY_TERMS_DESC }" width="${form_PAY_TERMS_DESC_W}" maxLength="${form_PAY_TERMS_DESC_M}" disabled="${form_PAY_TERMS_DESC_D}" readOnly="${form_PAY_TERMS_DESC_RO}" required="${form_PAY_TERMS_DESC_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_REQ_RMK" title="${form_CONT_REQ_RMK_N}" />
				<e:field colSpan="5">
					<e:textArea id="CONT_REQ_RMK" name="CONT_REQ_RMK" value="${form.CONT_REQ_RMK}" height="100px" width="${form_CONT_REQ_RMK_W}" maxLength="${form_CONT_REQ_RMK_M}" disabled="${form_CONT_REQ_RMK_D}" readOnly="${form_CONT_REQ_RMK_RO}" required="${form_CONT_REQ_RMK_R}" />
				</e:field>
			</e:row>
			</c:if>

			<c:if test="${ses.userType == 'S'}">
			<e:row>
				<e:inputHidden id="DELY_TERMS_DESC" name="DELY_TERMS_DESC" value="${form.DELY_TERMS_DESC}" width="${form_DELY_TERMS_DESC_W}"  disabled="${form_DELY_TERMS_DESC_D}" readOnly="${form_DELY_TERMS_DESC_RO}" required="${form_DELY_TERMS_DESC_R}" />
				<e:inputHidden id="DELY_PLACE" name="DELY_PLACE" value="${form.DELY_PLACE}" width="${form_DELY_PLACE_W}"  disabled="${form_DELY_PLACE_D}" readOnly="${form_DELY_PLACE_RO}" required="${form_DELY_PLACE_R}" />
				<e:inputHidden id="PAY_TERMS_DESC" name="PAY_TERMS_DESC" value="${form.PAY_TERMS_DESC}" width="${form_PAY_TERMS_DESC_W}"  disabled="${form_PAY_TERMS_DESC_D}" readOnly="${form_PAY_TERMS_DESC_RO}" required="${form_PAY_TERMS_DESC_R}" />
			</e:row>
			</c:if>

			<e:row>
			<c:if test="${ses.userType == 'C'}">
			<e:field colSpan="6">
				<e:buttonBar id="buttonBar4" align="right" width="100%" title="${form_CAPTION2_N }">
				<c:if test="${param.baseDataType eq 'contract'}">
					<e:button id="SearchItem" name="SearchItem" label="${SearchItem_N}" onClick="doSearchItem" disabled="${SearchItem_D}" visible="${SearchItem_V}" />
				</c:if>
				</e:buttonBar>
			</e:field>
			</c:if>
			</e:row>
			<e:row>
			<c:if test="${param.SO_TYPE != 'ITM' && form.SO_TYPE != 'ITM'}">
				<e:field colSpan="6">
				<e:gridPanel gridType="${_gridType}" id="gridP" name="gridP" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.gridP.gridColData}" />
				</e:field>
			    <e:panel width = "0" height="0">
					<e:gridPanel  gridType="${_gridType}" id="gridU" name="gridU" width="0" height="0" readOnly="${param.detailView}" columnDef="${gridInfos.gridU.gridColData}"/>
				</e:panel>
			</c:if>
			<c:if test="${param.SO_TYPE == 'ITM' || form.SO_TYPE == 'ITM'}">
			    <e:panel width = "0" height="0">
					<e:gridPanel  gridType="${_gridType}" id="gridP" name="gridP" width="0" height="0" readOnly="${param.detailView}" columnDef="${gridInfos.gridP.gridColData}" />
				</e:panel>
				<e:field colSpan="6">
				<e:gridPanel gridType="${_gridType}" id="gridU" name="gridU" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.gridU.gridColData}" />
				</e:field>
			</c:if>
			</e:row>
			<e:row>
			<c:if test="${ses.userType == 'C'}">
				<e:field colSpan="3" rowSpan="3">
					<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="140" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
				</e:field>
			</c:if>
			<c:if test="${ses.userType == 'S'}">
				<e:field colSpan="3" rowSpan="5">
					<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="270" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
				</e:field>
			</c:if>
				<e:label for="RFQ_ATT_FILE_NUM" title="${form_RFQ_ATT_FILE_NUM_N}"/>
				<e:field colSpan="2">
					<div style="width: 100%; height: 50px;">
						<e:fileManager id="RFQ_ATT_FILE_NUM" name ="RFQ_ATT_FILE_NUM" width="100%" fileId="${form.RFQ_ATT_FILE_NUM}" readOnly="${form_RFQ_ATT_FILE_NUM_RO}" bizType="CT" required="${form_RFQ_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" />
					</div>
 				</e:field>
			</e:row>

			<e:row>
 				<e:label for="BIZ_ATT_FILE_NUM" title="${form_BIZ_ATT_FILE_NUM_N}"/>
				<e:field colSpan="2">
					<div style="width: 100%; height: 50px;">
					<e:fileManager id="BIZ_ATT_FILE_NUM" name ="BIZ_ATT_FILE_NUM" width="100%" fileId="${form.BIZ_ATT_FILE_NUM}" readOnly="${form_BIZ_ATT_FILE_NUM_RO}" bizType="CT" required="${form_BIZ_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1"/>
					</div>
 				</e:field>
 			</e:row>
			<e:row>
 				<e:label for="SC_ATT_FILE_NUM" title="${form_SC_ATT_FILE_NUM_N}"/>
				<e:field colSpan="2">
					<div style="width: 100%; height: 50px;">
					<e:fileManager id="SC_ATT_FILE_NUM" name ="SC_ATT_FILE_NUM" width="100%" fileId="${form.SC_ATT_FILE_NUM}" readOnly="${form_SC_ATT_FILE_NUM_RO}" bizType="CT" required="${form_SC_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" />
					</div>
 				</e:field>
			</e:row>

			<e:row>
			<c:if test="${ses.userType == 'C'}">
				<e:label for="BUYER_ATT_FILE_NUM" title="${form_BUYER_ATT_FILE_NUM_N}" rowSpan="2"/>
				<e:field colSpan="2" rowSpan="2">
					<div style="width: 100%; height : 80px;">
				    <e:fileManager id="BUYER_ATT_FILE_NUM" width="100%" fileId="${form.BUYER_ATT_FILE_NUM}" readOnly="${form_BUYER_ATT_FILE_NUM_RO}" bizType="CT" required="${form_BUYER_ATT_FILE_NUM_R}"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick"  />
					</div>
				</e:field>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
				<e:field colSpan="2">
					<div style="width: 100%; height: 75px;">
					<e:fileManager id="ATT_FILE_NUM" name ="ATT_FILE_NUM" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${form_ATT_FILE_NUM_RO}" bizType="CT" required="${form_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick"  />
					</div>
 				</e:field>
			</c:if>

			<c:if test="${ses.userType == 'S'}">
			    <e:inputHidden id="BUYER_ATT_FILE_NUM" name="BUYER_ATT_FILE_NUM" height="120" width="100%" readOnly="${form_BUYER_ATT_FILE_NUM_RO}" required="${form_BUYER_ATT_FILE_NUM_R}"  />
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
				<e:field colSpan="2">
					<div style="width: 100%; height: 75px;">
					<e:fileManager id="ATT_FILE_NUM" name ="ATT_FILE_NUM" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${form_ATT_FILE_NUM_RO}" bizType="CT" required="${form_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" />
					</div>
 				</e:field>
			</c:if>
			</e:row>

 			<e:row>
 				<e:label for="ETC_ATT_FILE_NUM" title="${form_ETC_ATT_FILE_NUM_N}"/>
				<e:field colSpan="2">
					<div style="width: 100%; height: 50px;">
					<e:fileManager id="ETC_ATT_FILE_NUM" name ="ETC_ATT_FILE_NUM" width="100%" fileId="${form.ETC_ATT_FILE_NUM}" readOnly="${form_ETC_ATT_FILE_NUM_RO}" bizType="CT" required="${form_ETC_ATT_FILE_NUM_R}" downloadable="true"  onBeforeRemove="onBeforeRemove" onError="onError" maxFileCount="1" onFileClick="onFileClick" />
					</div>
 				</e:field>
			</e:row>

		</e:searchPanel>

		<e:row>
			<e:gridPanel gridType="${_gridType}" id="rejectGrid" name="rejectGrid" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.rejectGrid.gridColData}" />
		</e:row>
		<c:if test="${ses.userType == 'C'}">
		<%-- approvl path --%>
		<jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true" >
			<jsp:param value="${form.APP_DOC_NUM}" name="APP_DOC_NUM"/>
			<jsp:param value="${form.APP_DOC_CNT}" name="APP_DOC_CNT"/>
		</jsp:include>
		</c:if>
	    <e:panel width = "0" height="0">
			<e:gridPanel  gridType="${_gridType}" id="gridF" name="gridF" width="0" height="0" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</e:panel>
		<e:row>
			<e:field colSpan="6">
				<textarea id=cont_content name="cont_content" style="width: 100%;">${form.formContents}</textarea>
			</e:field>
		</e:row>
		<!-- KICA WebUI DIV Area -->
	    <div id="KICA_SECUKITNXDIV_ID"></div>
	</e:window>
</e:ui>
