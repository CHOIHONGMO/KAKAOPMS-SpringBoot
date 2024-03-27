<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var baseUrl = "/eversrm/eContract/eContractMgt/";

		var grid    = {};
		var gridP    = {};
        var flag    = 0;

		function init() {
			grid = EVF.C("grid");
			gridP = EVF.C("gridP");
	        grid.setProperty('panelVisible', ${panelVisible});
	        grid.setProperty('shrinkToFit', true);
	        grid.setProperty('singleSelect', true);
	        gridP.setProperty('multiSelect', false);

	        grid.cellClickEvent(function(rowIdx, colKey, value, iRow, iCol) {

				switch (colKey) {
				case 'VENDOR_CD':
					var params = {
						VENDOR_CD: grid.getCellValue(rowIdx, "VENDOR_CD"),
	                    detailView: true,
	                    popupFlag: true

					};
					 everPopup.openPopupByScreenId("M03_003", 1100, 750, params);
					break;
				case 'RFX_NUM':
					rfxType = grid.getCellValue(rowIdx, 'RFX_TYPE');
					var params = {
						gateCd : grid.getCellValue(rowIdx, 'GATE_CD'),
						rfxNum : grid.getCellValue(rowIdx, 'RFX_NUM'),
						rfxCnt : grid.getCellValue(rowIdx, 'RFX_CNT'),
						rfxType : grid.getCellValue(rowIdx, 'RFX_TYPE'),
						popupFlag: true,
	                    detailView: true
					};
					switch (rfxType) {
					case 'RFP':
					case 'RFQ':
						everPopup.openRfxDetailInformation(params);
						break;
					case 'RA':
						param = {
							gateCd : grid.getCellValue(rowIdx, 'GATE_CD'),
							rfxNum : grid.getCellValue(rowIdx, 'RFX_NUM'),
							rfxCnt : grid.getCellValue(rowIdx, 'RFX_CNT'),
							rfxType : grid.getCellValue(rowIdx, 'RFX_TYPE'),
							popupFlag: true,
		                    detailView: true
						};
						everPopup.openPopupByScreenId('BPQ_010', 1200, 700, param);
						break;
					}
					break;

				case 'EXEC_NUM':
					var param = {
						gateCd: '${ses.gateCd}',
						EXEC_NUM: grid.getCellValue(rowIdx, "EXEC_NUM").substring(0,2),
						popupFlag: true,
						detailView: true
					};


					switch (param.EXEC_NUM){
			        case 'EX' :
			        	var param = {
			        		gateCd: '${ses.gateCd}',
			        		EXEC_NUM: grid.getCellValue(rowIdx, 'EXEC_NUM'),
			        		EXEC_TYPE: grid.getCellValue(rowIdx, 'EXEC_TYPE'),
			        		RFX_NUM : grid.getCellValue(rowIdx, 'RFX_NUM'),
			        		RFX_CNT : grid.getCellValue(rowIdx, 'RFX_CNT'),
			        		VENDOR_CD: grid.getCellValue(rowIdx, 'VENDOR_CD'),
							popupFlag: true,
		                    detailView: true

			        	};
			            everPopup.QtaDetail(param);
			        	break;
			        case 'SO' :
			        	var param = {
			        		'SO_NUM': grid.getCellValue(rowIdx ,'EXEC_NUM'),
							'SO_CNT': grid.getCellValue(rowIdx ,'EXEC_CNT'),
							'TYPE': "R",
							'SO_TYPE':grid.getCellValue(rowIdx ,'SO_TYPE'),
							'detailView': true,
							'popupFlag': true
			        	};

			        	switch(param.SO_TYPE){
			        	case 'PRO' :
			        		everPopup.so02(param);
			        		break;
			        	case 'SIN' :
			        		everPopup.so04(param);
			        		break;
			        	case 'IBS' :
			        		everPopup.so06(param);
			        		break;
			        	case 'ITM' :
			          		everPopup.so08(param);
			        		break;
			        	case 'ASS' :
			          		everPopup.so10(param);
			        		break;
			        	}
					}
					break;

				case 'multiSelect':
	                var vendorCd = grid.getCellValue(rowIdx, "VENDOR_CD");


					var gridData = grid.getAllRowValue();
					var baseDataType = '';
					var contWtType = grid.getCellValue(rowIdx, "CONT_WT_TYPE");
					EVF.C("VENDOR_CD").setValue(vendorCd) ;

					if (contWtType == 'SO') {
			    		baseDataType = 'soContract';

			    		EVF.C("SO_NUM").setValue(grid.getCellValue(rowIdx,"EXEC_NUM")) ;
			    		EVF.C("SO_CNT").setValue(grid.getCellValue(rowIdx,"EXEC_CNT")) ;
			    		EVF.C("ACC_ATTR").setValue(grid.getCellValue(rowIdx,"ACC_ATTR")) ;
			    		EVF.C("ITEM_CLS4").setValue(grid.getCellValue(rowIdx,"ITEM_CLS4")) ;

			    		var store = new EVF.Store();
						store.setGrid([ gridP ]);
						store.load(baseUrl + '/BECM_030/doSelectContractKPECInfo', function() {
							if (grid.getRowCount() == 0) {
								alert("${msg.M0002 }");
							}
					    });

					}else {
						baseDataType = 'exContract';
						EVF.C("EXEC_NUM").setValue(grid.getCellValue(rowIdx,"EXEC_NUM")) ;
			    		EVF.C("ACC_ATTR").setValue(grid.getCellValue(rowIdx,"ACC_ATTR")) ;
			    		var store = new EVF.Store();
				        store.setGrid([gridP]);
			            store.load(baseUrl + '/BECM_030/doSelectContractCNHDInfo', function () {
			            	if (grid.getRowCount() == 0) {
								alert("${msg.M0002 }");
							}

					    });
					}
					EVF.C("VENDOR_CD").setValue("") ;

			    	if (grid.isChecked(rowIdx)) {
	            		return;
	            		grid.checkAll(false);
		                var gridData = grid.getAllRowValue();
		                for (var cnt in gridData) {
							var rowDatas = gridData[cnt];
							if(execNum == rowDatas['EXEC_NUM'] && vendorCd == rowDatas['VENDOR_CD']) {
								grid.checkRow(cnt, true);
							}

					        if (gridData.length == parseInt(cnt) + 1) {
                                flag = 0;
                            } else {
                                flag = 1;
                            }
		                }
		            } else {
		            	grid.checkRow(rowIdx, false);
	            	}

			    }
			});

	        grid.excelExportEvent({
	            allCol : "${excelExport.allCol}",
	            selRow : "${excelExport.selRow}",
	            fileType : "${excelExport.fileType }",
	            fileName : "${screenName }",
	            excelOptions : {
	                 imgWidth      : 0.12      // image width
	                ,imgHeight     : 0.26      // image height
	                ,colWidth      : 20        // column width.
	                ,rowSize       : 500       // excel row hight size.
	                ,attachImgFlag : false     // excel imange attach flag : true/false
	            }
	        });

	        gridP.excelExportEvent({
	            allCol : "${excelExport.allCol}",
	            selRow : "${excelExport.selRow}",
	            fileType : "${excelExport.fileType }",
	            fileName : "${screenName }",
	            excelOptions : {
	                 imgWidth      : 0.12      // image width
	                ,imgHeight     : 0.26      // image height
	                ,colWidth      : 20        // column width.
	                ,rowSize       : 500       // excel row hight size.
	                ,attachImgFlag : false      // excel imange attach flag : true/false
	            }
	        });
		}

		function doSearch() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			store.setGrid([ grid ]);
			store.load(baseUrl + 'BECM_010/doSearch', function() {
				if (grid.getRowCount() == 0) {

					var store = new EVF.Store();
					EVF.C("SO_NUM").setValue("0");
		    		EVF.C("SO_CNT").setValue("0");
		    		EVF.C("EXEC_NUM").setValue("0");
		    	//	EVF.C("CONT_CNT").setValue("0");
		    	//  EVF.C("CONT_NUM").setValue("0");
		    		store.setGrid([ gridP ]);
					store.load(baseUrl + '/BECM_030/doSelectContractKPECInfo', function() {
					});

					alert("${msg.M0002 }");

				} else {
					grid.checkRow(0, true);
				}
			});
		}

		function doSearchVendor() {
			var param = {
				BUYER_CD : "${ses.companyCd}",
				callBackFunction : "_setVendor"
			};
			everPopup.openCommonPopup(param, 'SP0013');
		}

		function _setVendor(data) {
			<%-- EVF.C("VENDOR_CD").setValue(data.VENDOR_CD); --%>
			EVF.C("VENDOR_CD").setValue(data.VENDOR_NM);
		}

		function _setVendor(data) {
	        EVF.C("VENDOR_NM").setValue(data['VENDOR_NM']);
	        EVF.C("VENDOR_CD").setValue(data['VENDOR_CD']);
	    }

		function getBsCd() {
			var param = {
					'detailView': false,
					callBackFunction : "setBsCd"
				};
	    	everPopup.getBsCd(param);
		}

	    function setBsCd(dataJsonArray) {
			EVF.C("BS_CD").setValue(dataJsonArray.CODE);
			EVF.C("BS_NM").setValue(dataJsonArray.TEXT);
		}

	    /*
		function createManualContract() {
			everPopup.openContractFormSelection({
				'callBackFunction' : 'setSelectedForm',
				'baseDataType' : 'soContract'
			});
		}

		function setSelectedForm(contractFormJson, mainForm, additionalForm, baseDataType) {
            everPopup.openContractCreation({
                contractForm : contractFormJson,
                mainForm : mainForm,
                additionalForm : additionalForm,
                baseDataType : baseDataType,
                contractEditable : true
            });
		}
		*/

		function createContract() {

			var gridData = grid.getSelRowValue();
			if (gridData.length > 0) {
				var valid = grid.validate();
				if (!valid.flag) {
					alert(valid.msg);
					return;
				}
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			var baseDataType = '';
			var contWtType = gridData[0]['CONT_WT_TYPE'];

			var soNum      = '';
			var soCnt      = '';
			var execNum    = '';
			var contNum    = '';
			var contCnt    = '';
			var accAttr    = '';
			var itemCls4   = '';
			var soType     = '';
			var rfx_ryq    = '';

	    	if (contWtType == 'SO') {
		   		baseDataType = 'soContract';
				soNum        = gridData[0]['EXEC_NUM'];
				soCnt        = gridData[0]['EXEC_CNT'];
				exNum        = '';
				contNum      = gridData[0]['CONT_NUM'];
				contCnt      = gridData[0]['CONT_CNT'];
				accAttr      = gridData[0]['ACC_ATTR'];
				itemCls4     = gridData[0]['ITEM_CLS4'];
				soType       = gridData[0]['SO_TYPE'];


	    	} else {
	    		baseDataType = 'exContract';
	    		soNum        = '';
	    		soCnt        = '';
				execNum      = gridData[0]['EXEC_NUM'];
	    		contNum      = '';
	    		contCnt      = '';
	    		accAttr      = gridData[0]['ACC_ATTR'];
	    		itemCls4     = '';
	    		soType       = '';
	    		rfx_ryq      = gridData[0]['RFX_RYQ'];
			}

 			var rfx_type = gridData[0]['RFX_TYPE'];
 			if(rfx_type == '01'){
 				var param = {
 			        	openerCallBackFunction : 'doSearch',
 			        	CONT_WT_NUM      : gridData[0]['CONT_WT_NUM'],
 			        	CONT_DESC        : gridData[0]['EXEC_SUBJECT'].replace(/'/gi, '’').replace(/"/gi, '”'),
 			        	SUPPLY_AMT       : gridData[0]['EXEC_AMT'],
 			        	VENDOR_CD        : gridData[0]['VENDOR_CD'],
 			        	VENDOR_NM        : gridData[0]['VENDOR_NM'],
 			        	RFX_TYPE         : gridData[0]['RFX_TYPE'],
 			        	baseDataType     : baseDataType,
 						contReqStatus    : 'C',
 						contReqFlag      : '01',
 			        	SO_NUM           : soNum,
 			        	SO_CNT           : soCnt,
 			        	EXEC_NUM         : execNum,
 			        	CONT_NUM         : contNum,
 			        	CONT_CNT         : contCnt,
 			        	ACC_ATTR         : accAttr,
 			        	ITEM_CLS4        : itemCls4,
 			        	SO_TYPE          : soType,
 			        	RFX_RYQ          : rfx_ryq,
 						detailView       : false,
 						contractEditable : true
 		       	 };

 			 	everPopup.openWindowPopup('/eversrm/eContract/formMgt/P05_052/view', 1200, 750, param);

 			}else if(rfx_type=='04'){
				everPopup.openContractChangeInformation({
 					openercallBackFunction : 'doSearch',
		        	CONT_WT_NUM      : gridData[0]['CONT_WT_NUM'],
		        	CONT_DESC        : gridData[0]['EXEC_SUBJECT'].replace(/'/gi, '’').replace(/"/gi, '”'),
					SUPPLY_AMT       : gridData[0]['EXEC_AMT'],
					VENDOR_CD        : gridData[0]['VENDOR_CD'],
		        	VENDOR_NM        : gridData[0]['VENDOR_NM'],
		        	RFX_TYPE         : gridData[0]['RFX_TYPE'],

					baseDataType     : baseDataType,
					contReqStatus    : 'C',
					contReqFlag      : '04',
					SO_NUM           : soNum,
					SO_CNT           : soCnt,
		        	EXEC_NUM         : execNum,
					CONT_NUM         : contNum,
					CONT_CNT         : contCnt,
		        	ACC_ATTR         : accAttr,
		        	ITEM_CLS4        : itemCls4,
		        	SO_TYPE          : soType,
		        	RFX_RYQ          : rfx_ryq,
					detailView       : false,
					contractEditable : true
 				});
 			 }
		}

		function doTerminate() {

			if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

			var store = new EVF.Store();
			if(!confirm('${BECM_010_0001}')) { return; }

			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'BECM_010/doTerminate', function() {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

	</script>

	<e:window id="BECM_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:inputHidden id="mainForm" name="mainForm" value="" />
		<e:inputHidden id="additionalForm" name="additionalForm" value="" />
		<e:inputHidden id="DEPT_CD" name="DEPT_CD" value="" />
		<e:inputHidden id="DEPT_NM" name="DEPT_NM" value="" />
		<e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId }" />
	    <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" />
	    <e:inputHidden id="SO_NUM" name ="SO_NUM" value =""/>
	    <e:inputHidden id="SO_CNT" name ="SO_CNT" value =""/>
	    <e:inputHidden id="ACC_ATTR" name ="ACC_ATTR" value =""/>
	    <e:inputHidden id="ITEM_CLS4" name ="ITEM_CLS4" value =""/>
	    <e:inputHidden id="baseDataType" name ="baseDataType" value =""/>
	    <e:inputHidden id="EXEC_NUM" name ="EXEC_NUM" value=""/>


		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="RFA_FROM_DATE" title="${form_RFA_FROM_DATE_N }" />
				<e:field>
					<e:inputDate id="RFA_FROM_DATE" toDate="RFA_TO_DATE" name="RFA_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" required="${form_RFA_FROM_DATE_R }" readOnly="${form_RFA_FROM_DATE_RO }" disabled="${form_RFA_FROM_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="RFA_TO_DATE" fromDate="RFA_FROM_DATE" name="RFA_TO_DATE" value="${toDate }" width="${inputDateWidth}" required="${form_RFA_TO_DATE_R }" readOnly="${form_RFA_TO_DATE_RO }" disabled="${form_RFA_TO_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N }" />
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="doSearchVendor" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:label for="BS_CD" title="${form_BS_CD_N}"/>
				<e:field>
				<e:search id="BS_CD" name="BS_CD" value="" style="ime-mode:inactive" width="40%" maxLength="${form_BS_CD_M}" onIconClick="${form_BS_CD_RO ? 'everCommon.blank' : 'getBsCd'}" disabled="${form_BS_CD_D}" readOnly="${form_BS_CD_RO}" required="${form_BS_CD_R}" />
				<e:inputText id="BS_NM" name="BS_NM" value="" width="60%" maxLength="${form_BS_NM_M}" disabled="${form_BS_NM_D}" readOnly="${form_BS_NM_RO}" required="${form_BS_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PC_TYPE" title="${form_PC_TYPE_N}"/>
				<e:field>
					<e:select id="PC_TYPE" name="PC_TYPE" value="${form.PC_TYPE}" options="${pcType}" width="100%" disabled="${form_PC_TYPE_D}" readOnly="${form_PC_TYPE_RO}" required="${form_PC_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="RFA_NM" title="${form_RFA_NM_N }" />
				<e:field>
					<e:inputText id="RFA_NM" name="RFA_NM" width="100%" required="${form_RFA_NM_R }" disabled="${form_RFA_NM_D }" value="" readOnly="${form_RFA_NM_RO }" maxLength="${form_RFA_NM_M}" />
				</e:field>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
				<e:field>
					<e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<%--
			<e:button id="createManualContract" name="createManualContract" label="${createManualContract_N }" disabled="${createManualContract_D }" onClick="createManualContract" />
			--%>
			<%-- <e:button id="doTerminate" name="doTerminate" label="${doTerminate_N}" onClick="doTerminate" disabled="${doTerminate_D}" visible="${doTerminate_V}"/> --%>
			<e:button id="createContract" name="createContract" label="${createContract_N }" disabled="${createContract_D }" onClick="createContract" />
		</e:buttonBar>
		<e:row>
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</e:row>
		<e:row>
		<e:gridPanel gridType="${_gridType}" id="gridP" name="gridP" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridP.gridColData}" />
		</e:row>
	</e:window>

</e:ui>
