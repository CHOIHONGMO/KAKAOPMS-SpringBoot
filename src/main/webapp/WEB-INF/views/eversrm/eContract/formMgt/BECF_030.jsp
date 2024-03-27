<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script src="//cdn.ckeditor.com/4.4.5/full/ckeditor.js"></script>
    <script type="text/javascript" src="/js/ckeditor/econt_plugins.js"></script>
	<script type="text/javascript">

		var gridM = {};
		var gridA = {};

		var baseUrl = "/eversrm/eContract/formMgt/";
		var opCBackFn = '${param.openerCallBackFunction}';
		var plantNm = '${param.PLANT_NM}';
		var baseDataType = "manualContract";

		function init() {

//			gridM = EVF.C("gridM");
			gridA = EVF.C("gridA");

// 			gridM.setProperty('shrinkTo100%', true);
//			gridA.setProperty('shrinkTo100%', true);
//			gridM.setProperty('multiSelect', false);

			EVF.C('CONT_REQ_CD').setValue('01');
			EVF.C('MANUAL_CONT_FLAG').setValue('0');

			if(opCBackFn == 'setCallBackPRCont'){
				EVF.C('CONT_DESC').setValue('${param.CONT_DESC}');
				EVF.C('VENDOR_CD').setValue('${param.VENDOR_CD}');
				EVF.C('VENDOR_NM').setValue('${param.VENDOR_NM}');
				EVF.C('CONT_AMT').setValue('${param.CONT_AMT}');
				EVF.C('CONT_WT_NUM').setValue('${param.CONT_WT_NUM}');
			}

/* 			gridM.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if (celname == "SELECTED") {
					gridM.checkAll(false);
					gridM.checkRow(rowid, true);

					var formNum = gridM.getCellValue(rowid, "FORM_NUM");
					doSearchAdditionalForm(formNum);
	            }

				switch (celname) {
					case 'FORM_NM':
						var formNum = gridM.getCellValue(rowid, "FORM_NUM");
						doSearchAdditionalForm(formNum);
						break;

					default:
						return;
				}
			}); */

/* 			doSearch(); */
//			initGuaranteeButtons();
			setForm();
			setFormComponents();

			if(${not empty param.PLANT_CD}) {
				EVF.C('PLANT_CD').setValue('${param.PLANT_CD}');
			}

/*		 	gridM.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth : 0.12, // 이미지의 너비.
					imgHeight : 0.26, // 이미지의 높이.
					colWidth : 20, // 컬럼의 넓이.
					rowSize : 500, // 엑셀 행에 높이 사이즈.
					attachImgFlag : false
				// 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부
				}
			}); */

			gridA.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth : 0.12, // 이미지의 너비.
					imgHeight : 0.26, // 이미지의 높이.
					colWidth : 20, // 컬럼의 넓이.
					rowSize : 500, // 엑셀 행에 높이 사이즈.
					attachImgFlag : false
				// 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부
				}
			});

			 var editor = CKEDITOR.replace('cont_content', {
		            customConfig : '/js/ckeditor/ep_config.js',
		            width: '100%',
		            height: 330
		        });

		        editor.on('instanceReady', function(ev){

		            var editor = ev.editor;
		            editor.resize('100%', 330, true, false);

		            $(window).resize(function() {
		                editor.resize('100%', 330, true, false);
		            });
		        });

		}

        //구매품의서(WM0850)에서 넘어온 경우
		function setForm() {
			if (plantNm != '') {
				EVF.C("MANUAL_CONT_FLAG").setValue("0");
				EVF.C("CONT_DESC").setValue(plantNm);
				EVF.C("CONT_PLACE").setValue(plantNm);
			}
        }
 /*        function doSearch() {
			var store = new EVF.Store();
			store.setGrid([ gridM ]);
			store.setParameter('CONT_PLACE', plantNm);
			store.load(baseUrl + 'BECF_030/doSearchMainForm', function() {
			});
        } */
        function doSearchAdditionalForm(selectedFormNum) {
			var store = new EVF.Store();

			store.setGrid([ gridA ]);
	        store.setParameter('selectedFormNum', selectedFormNum);
			store.load(baseUrl + 'BECF_030/doSearchAdditionalForm', function() {
				gridA.checkAll(true);
				<%--
				if (gridA.getRowCount() > 0) {
					var rowIds = gridA.getAllRowId();
					for ( var rowId in rowIds) {
						var requireFlag = gridA.getCellValue(rowId, 'REQUIRE_FLAG');
						if (requireFlag == '1') {
							gridA.checkRow(rowId, true);
						}
					}
				}
				--%>
			});
        }
        //선택 - 계약서작성화면 호출
		function doSelect() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

		/* 	var gridMData = gridM.getSelRowValue();
			if (gridMData.length > 0) {
				var valid = gridM.validate();
				if (!valid.flag) {
					alert(valid.msg);
					return;
				}
			} else if (gridMData.length == 0) {
				alert('${msg.M0004 }');
				return;
			} */

/* 			var selectedRow = gridM.getSelRowValue()[0];
			var selformNum = selectedRow['FORM_NUM'];

			EVF.C("SELECT_FORM_NUM").setValue(selformNum);
 */
			if (gridA.getRowCount() > 0) {
				var rowIds = gridA.getAllRowId();
				for ( var rowId in rowIds) {
					var requireFlag = gridA.getCellValue(rowId, 'REQUIRE_FLAG');
					if (requireFlag == '1') {
						gridA.checkRow(rowId, true);
					}
				}
			}

			// CONT_DESC, CONT_REQ_RMK 변환
			EVF.C('CONT_DESC').setValue(EVF.C('CONT_DESC').getValue().replace(/'/gi, '’').replace(/"/gi, '”'));
			EVF.C('CONT_REQ_RMK').setValue(EVF.C('CONT_REQ_RMK').getValue().replace(/'/gi, '’').replace(/"/gi, '”'));

			var gridAData = gridA.getSelRowValue();
			var contractFormJson = store._getFormDataAsJson();
			var mainFormJson = JSON.stringify(gridMData);
			var additionalFormJson = JSON.stringify(gridAData);

			//opener.window['${param.callBackFunction}'](contractFormJson, mainFormJson, additionalFormJson, '${param.baseDataType}');
			//doClose();
			//setSelectedForm(contractFormJson, mainFormJson, additionalFormJson, baseDataType);

			EVF.C("contractForm").setValue(contractFormJson.replace(/"/gi, '\''));
			EVF.C("mainForm").setValue(mainFormJson.replace(/"/gi, '\''));
			EVF.C("additionalForm").setValue(additionalFormJson.replace(/"/gi, '\''));
			EVF.C("baseDataType").setValue(baseDataType.replace(/"/gi, '\''));
			EVF.C("contractEditable").setValue("true");
			EVF.C("detailView").setValue("false");

        	EVF.C('TRANSACTION_FLAG').setValue('Y');

			//location.href='/eversrm/eContract/eContractMgt/BECM_030/view.so?contractForm='+contractFormJson+'&mainForm='+mainFormJson+'&additionalForm='+additionalFormJson+'&baseDataType='+baseDataType+'&contractEditable=true';
			formData.action='/eversrm/eContract/eContractMgt/BECM_030/view';
			formData.submit();
        }
        //계약서작성화면 호출 - 미사용(기존 팝업으로 호출할때)
		function setSelectedForm(contractFormJson, mainForm, additionalForm, baseDataType) {
            everPopup.openContractCreation({
                contractForm : contractFormJson,
                mainForm : mainForm,
                additionalForm : additionalForm,
                baseDataType : baseDataType,
                contractEditable : true
            });
        }

        function doSend() {

        	alert("doSend");
        }
        function doSave() {
        	alert("doSave");
        }
        function doApproval() {
        	alert("doApproval");
        }
		function doClose() {
			window.close();
        }
        function setFormComponents() {
        	if (baseDataType === 'consultation') {
				EVF.C("VENDOR_NM").setDisabled(true);
			}
        }
        function doSelectDrafter() {
			everPopup.openCommonPopup({
				callBackFunction : "setDrafter"
			}, 'SP0040');
        }
        function setDrafter(drafter) {
			EVF.C("CONT_USER_ID").setValue(drafter.CTRL_USER_ID);
			EVF.C("CONT_USER_NM").setValue(drafter.CTRL_USER_NM);
			EVF.C("BUYER_CD").setValue(drafter.BUYER_CD);
			EVF.C("BUYER_NM").setValue(drafter.BUYER_NM);
        }
/*  	function doSearchVendor() {
			everPopup.openCommonPopup({
				callBackFunction : "setVendor"
			}, 'SP0016');
        }*/
    	function doSearchVendor() {

			var param = {
				BUYER_CD : "${ses.companyCd}",
				callBackFunction : "_setVendor"
			};
			everPopup.openCommonPopup(param, 'SP0013');
		}

        function setVendor(vendor) {
			EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
			EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
        }
        function doSelectPIC() {
			var vendorCd = EVF.C('VENDOR_CD').getValue();
			if (vendorCd === '') {
				return alert('${BECF_030_0001}');
			}
			everPopup.openCommonPopup({
				callBackFunction : "setVendorPIC",
				companyCd : vendorCd
			}, 'SP0028');
        }
        function setVendorPIC(pic) {
			EVF.C("VENDOR_PIC_USER_NM").setValue(pic.USER_NM);
        }
        function getBuyerCd() {
	    	var store = new EVF.Store();

	    	var plant_cd= EVF.C("PLANT_CD").getValue();
	    	//alert("PLANT_CD"+plant_cd);
	    	store.load(baseUrl + 'getBuyerCd.so?PLANT_CD='+plant_cd, function() {
	    		EVF.C("BUYER_CD").setValue(this.getParameter("buyer_cd"));
	    		//alert("BUYER_CD"+this.getParameter("buyer_cd"));
            });
		}
	</script>

	<e:window id="BECF_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 4px">
	<e:buttonBar id="buttonBar" align="right" width="100%">
    <e:button id="doSend" name="doSend" label="${doSend_N}" onClick="doSend" disabled="${doSend_D}" visible="${doSend_V}"/>
	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 </e:buttonBar>
	<e:buttonBar id="buttonBar2" align="right" width="100%">
		<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="" data="${ses.userType}_SAVE" />
		<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="" disabled="${doApproval_D}" visible="${doApproval_V}"/>
		<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
 	</e:buttonBar>
	<form id="formData" name="formData">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
        <e:inputHidden id="GATE_CD" name="GATE_CD" value="${ses.gateCd}" />
        <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${param.execNum}" />
        <e:inputHidden id="SELECT_FORM_NUM" name="SELECT_FORM_NUM" value="" />
        <e:inputHidden id="contractForm" name="contractForm" />
		<e:inputHidden id="mainForm" name="mainForm" />
		<e:inputHidden id="additionalForm" name="additionalForm" />
		<e:inputHidden id="baseDataType" name="baseDataType" />
		<e:inputHidden id="contractEditable" name="contractEditable" />
		<e:inputHidden id="detailView" name="detailView" />
		<e:inputHidden id="contReqFlag" name="contReqFlag" value="01"/>
        <e:inputHidden id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="" />
        <e:inputHidden id="CONT_WT_NUM" name="CONT_WT_NUM" value="" />
        <e:inputHidden id="openerCallBackFunction" name="openerCallBackFunction" value="${param.openerCallBackFunction}" />
		<e:inputHidden id="CONT_PLACE" name="CONT_PLACE" value="${param.PLANT_NM}" />

		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidth }"   width="100%" onEnter=""  useTitleBar="false">
			<e:row>
			<e:label for="CONT_NUM" title="${form_CONT_NUM_N }" width="100%" />
				<e:field>
					<e:inputText id="CONT_NUM" name="CONT_NUM" value="${form.CONT_NUM}" width="90px" required="${form_CONT_NUM_R }" disabled="${form_CONT_NUM_D }" readOnly="${form_CONT_NUM_RO }" maxLength="${form_CONT_NUM_M}" />
					<e:text> / </e:text>
					<e:inputNumber id="CONT_CNT" name="CONT_CNT" value="${form.CONT_CNT}" width="40px" required="${form_CONT_CNT_R }" disabled="${form_CONT_CNT_D }" readOnly="${form_CONT_CNT_RO }" />
				</e:field>
		    	<e:label for="CONT_DESC" title="${form_CONT_DESC_N }" width="100%" />
				<e:field colSpan="3">
					<e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="${param.CONT_DESC}" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_AMT" title="${form_CONT_AMT_N }"   width="100%" />
				<e:field>
					<e:inputNumber id="CONT_AMT" name="CONT_AMT" width="100%" required="${form_CONT_AMT_R }" disabled="${form_CONT_AMT_D }" value="${param.CONT_AMT}" readOnly="${form_CONT_AMT_RO }" onChange="calculateGuarantee" />
				</e:field>
				<%-- <e:label for="CONT_DATE" title="${form_CONT_DATE_N }" />
				<e:field>
					<e:inputDate id="CONT_DATE" name="CONT_DATE" value="${toDate }" width="${inputTextDate }" required="${form_CONT_DATE_R }" readOnly="${form_CONT_DATE_RO }" disabled="${form_CONT_DATE_D }" datePicker="true" />
				</e:field> --%>
				<e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N }" width="100%" />
				<e:field>
					<e:inputDate id="CONT_START_DATE" toDate="CONT_END_DATE" name="CONT_START_DATE" value="" width="${inputTextDate }" required="${form_CONT_START_DATE_R }" readOnly="${form_CONT_START_DATE_RO }" disabled="${form_CONT_START_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="CONT_END_DATE" fromDate="CONT_START_DATE" name="CONT_END_DATE" value="" width="${inputTextDate }" required="${form_CONT_END_DATE_R }" readOnly="${form_CONT_END_DATE_RO }" disabled="${form_CONT_END_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="CONT_USER_NM" title="${form_CONT_USER_NM_N }" width="100%" />
				<e:field>
					<e:search id="CONT_USER_NM" name="CONT_USER_NM" width="${inputTextWidth}" maxLength="${form_CONT_USER_NM_M }" required="${form_CONT_USER_NM_R }" disabled="${form_CONT_USER_NM_D }" readOnly="${form_CONT_USER_NM_RO }" value="${ses.userNm }" onIconClick="doSelectDrafter" />
					<e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" width="0" value="${ses.userId }" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N }"  width="100%" />
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" width="100%" maxLength="${form_VENDOR_CD_M }" required="${form_VENDOR_CD_R }" disabled="${form_VENDOR_CD_D }" readOnly="${form_VENDOR_CD_RO }" value="" onIconClick="doSearchVendor" />
				</e:field>
				<e:label for="BUYER_SIGN_DATE"  title="${form_BUYER_SIGN_DATE_N}" width="100%"/>
				<e:field>
					<e:inputDate id="BUYER_SIGN_DATE" name="BUYER_SIGN_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_BUYER_SIGN_DATE_R}" disabled="${form_BUYER_SIGN_DATE_D}" readOnly="${form_BUYER_SIGN_DATE_RO}" />
				</e:field>
				<e:label for="VENDOR_SIGN_DATE"  title="${form_VENDOR_SIGN_DATE_N}"  width="100%"/>
				<e:field>
					<e:inputDate id="VENDOR_SIGN_DATE" name="VENDOR_SIGN_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_VENDOR_SIGN_DATE_R}" disabled="${form_VENDOR_SIGN_DATE_D}" readOnly="${form_VENDOR_SIGN_DATE_RO}" />
				</e:field>
				<%--  --%>
			</e:row>
			<e:row>
				<e:label for="CONTRACT_TYPE" title="${form_CONTRACT_TYPE_N}"  width="100%"/>
				<e:field>
					<e:select id="CONTRACT_TYPE" name="CONTRACT_TYPE" value="" options="${contractTypeOptions}" width="${form_CONTRACT_TYPE_W}" disabled="${form_CONTRACT_TYPE_D}" readOnly="${form_CONTRACT_TYPE_RO}" required="${form_CONTRACT_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"  width="100%"/>
				<e:field>
					<e:select id="CONT_REQ_CD" name="CONT_REQ_CD" value="${form.CONT_REQ_CD}" options="${contReqCd}" width="${inputTextWidth}" disabled="${form_CONT_REQ_CD_D}" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N }"  width="100%" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCd}" readOnly="${form_PROGRESS_CD_RO }" width="160" required="${form_PROGRESS_CD_R }" disabled="${form_PROGRESS_CD_D }" />
				</e:field>
			</e:row>
			<e:row>
			<e:label for="DELY_TERMS_DESC" title="${form_DELY_TERMS_DESC_N}"  width="100%"/>
			<e:field>
				<e:inputText id="DELY_TERMS_DESC" name="DELY_TERMS_DESC" value="" width="${form_DELY_TERMS_DESC_W}" maxLength="${form_DELY_TERMS_DESC_M}" disabled="${form_DELY_TERMS_DESC_D}" readOnly="${form_DELY_TERMS_DESC_RO}" required="${form_DELY_TERMS_DESC_R}" />
			</e:field>

			<e:label for="DELY_PLACE" title="${form_DELY_PLACE_N}"  width="100%"/>
			<e:field>
				<e:inputText id="DELY_PLACE" name="DELY_PLACE" value="" width="${form_DELY_PLACE_W}" maxLength="${form_DELY_PLACE_M}" disabled="${form_DELY_PLACE_D}" readOnly="${form_DELY_PLACE_RO}" required="${form_DELY_PLACE_R}" />
			</e:field>

			<e:label for="PAY_TERMS_DESC" title="${form_PAY_TERMS_DESC_N}"/>
			<e:field>
				<e:inputText id="PAY_TERMS_DESC" name="PAY_TERMS_DESC" value="" width="${form_PAY_TERMS_DESC_W}" maxLength="${form_PAY_TERMS_DESC_M}" disabled="${form_PAY_TERMS_DESC_D}" readOnly="${form_PAY_TERMS_DESC_RO}" required="${form_PAY_TERMS_DESC_R}" />
			</e:field>

			</e:row>
			<e:row>
				<e:label for="MANUAL_CONT_FLAG" title="${form_MANUAL_CONT_FLAG_N}"/>
				<e:field colSpan="5">
					<e:select id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="" options="${manualContFlagOptions}" width="${form_MANUAL_CONT_FLAG_W}" disabled="${form_MANUAL_CONT_FLAG_D}" readOnly="${form_MANUAL_CONT_FLAG_RO}" required="${form_MANUAL_CONT_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_REQ_RMK" title="${form_CONT_REQ_RMK_N}"/>
				<e:field colSpan="5">
					<e:textArea id="CONT_REQ_RMK" name="CONT_REQ_RMK" value="" height="100px" width="${form_CONT_REQ_RMK_W}" maxLength="${form_CONT_REQ_RMK_M}" disabled="${form_CONT_REQ_RMK_D}" readOnly="${form_CONT_REQ_RMK_RO}" required="${form_CONT_REQ_RMK_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:field colSpan="6">
                    <textarea id=cont_content name="cont_content" style="width:100%;"></textarea>
				</e:field>
			</e:row>

	 		<e:row>
				<e:field colSpan="3" rowSpan="2">
					 <e:gridPanel gridType="${_gridType}" id="gridA" name="gridA" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
				</e:field>
				<e:label for="BUYER_ATT_FILE_NUM" title="${form_BUYER_ATT_FILE_NUM_N}"/>
				<e:field colSpan="2">
					<e:fileManager id="BUYER_ATT_FILE_NUM" height="80" width="100%" fileId="${form.BUYER_ATT_FILE_NUM}" readOnly="${form_BUYER_ATT_FILE_NUM_RO}" bizType="CT" required="${form_BUYER_ATT_FILE_NUM_R}" />
				</e:field>
			</e:row>
			<e:row>
			 	<e:label for="BUYER_ATT_FILE_NUM2" title="${form_BUYER_ATT_FILE_NUM2_N}"/>
				<e:field colSpan="2">
					<e:fileManager id="BUYER_ATT_FILE_NUM2" height="80" width="100%" fileId="${form.BUYER_ATT_FILE_NUM2}" readOnly="${form_BUYER_ATT_FILE_NUM2_RO}" bizType="CT" required="${form_BUYER_ATT_FILE_NUM2_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DELAY_RATE" title="${form_DELAY_RATE_N}"/>
				<e:field >
					<e:inputNumber id="DELAY_RATE" name="DELAY_RATE" value="" width="${form_DELAY_RATE_W}" maxValue="${form_DELAY_RATE_M}" decimalPlace="${form_DELAY_RATE_NF}" disabled="${form_DELAY_RATE_D}" readOnly="${form_DELAY_RATE_RO}" required="${form_DELAY_RATE_R}" />
				</e:field>
				<e:label for="DELAY_RATE" title="인지세 여부 /금액"/>
			</e:row>
			<e:row>
				<e:label for="ADV_GUAR_FLAG" title="${form_ADV_GUAR_FLAG_N }" />
				<e:field>
					<e:select id="ADV_GUAR_FLAG" name="ADV_GUAR_FLAG" value="0" options="${refYN}" readOnly="${form_ADV_GUAR_FLAG_RO }" width="160" required="${form_ADV_GUAR_FLAG_R }" disabled="${form_ADV_GUAR_FLAG_D }" onChange='setGuaranteeButtons' />
				</e:field>
				<e:label for="ADV_GUAR_AMT" title="${form_ADV_GUAR_AMT_N }" />
				<e:field>
					<e:select id="ADV_VAT_FLAG" name="ADV_VAT_FLAG" value="0" options="${vatFlag}" readOnly="${form_ADV_VAT_FLAG_RO }" width="160" required="${form_ADV_VAT_FLAG_R }" disabled="${form_ADV_VAT_FLAG_D }" onChange='setGuaranteeButtons' />
					<e:inputNumber id="ADV_GUAR_AMT" name="ADV_GUAR_AMT" width="${inputTextWidth }" required="${form_ADV_GUAR_AMT_R }" disabled="${form_ADV_GUAR_AMT_D }" value="" readOnly="${form_ADV_GUAR_AMT_RO }" onChange="calculateGuarantee" />
				</e:field>
				<e:label for="ADV_GUAR_PERCENT" title="${form_ADV_GUAR_PERCENT_N }" />
				<e:field>
					<e:inputNumber id="ADV_GUAR_PERCENT" name="ADV_GUAR_PERCENT" width="${inputTextWidth }" required="${form_ADV_GUAR_PERCENT_R }" disabled="${form_ADV_GUAR_PERCENT_D }" value="" readOnly="${form_ADV_GUAR_PERCENT_RO }" onChange="calculateGuarantee" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_GUAR_FLAG" title="${form_CONT_GUAR_FLAG_N }" />
				<e:field>
					<e:select id="CONT_GUAR_FLAG" name="CONT_GUAR_FLAG" value="0" options="${refYN}" readOnly="${form_CONT_GUAR_FLAG_RO }" width="160" required="${form_CONT_GUAR_FLAG_R }" disabled="${form_CONT_GUAR_FLAG_D }" onChange='setGuaranteeButtons' />
				</e:field>
				<e:label for="CONT_GUAR_AMT" title="${form_CONT_GUAR_AMT_N }" />
				<e:field>
					<e:select id="CONT_VAT_FLAG" name="CONT_VAT_FLAG" value="0" options="${vatFlag}" readOnly="${form_CONT_GUAR_AMT_RO }" width="160" required="${form_CONT_GUAR_AMT_R }" disabled="${form_CONT_GUAR_AMT_D }" onChange='setGuaranteeButtons' />
					<e:inputNumber id="CONT_GUAR_AMT" name="CONT_GUAR_AMT" width="${inputTextWidth }" required="${form_CONT_GUAR_AMT_R }" disabled="${form_CONT_GUAR_AMT_D }" value="" readOnly="${form_CONT_GUAR_AMT_RO }" onChange="calculateGuarantee" />
				</e:field>
				<e:label for="CONT_GUAR_PERCENT" title="${form_CONT_GUAR_PERCENT_N }" />
				<e:field>
					<e:inputNumber id="CONT_GUAR_PERCENT" name="CONT_GUAR_PERCENT" width="${inputTextWidth }" required="${form_CONT_GUAR_PERCENT_R }" disabled="${form_CONT_GUAR_PERCENT_D }" value="" readOnly="${form_CONT_GUAR_PERCENT_RO }" onChange="calculateGuarantee" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="WARR_GUAR_FLAG" title="${form_WARR_GUAR_FLAG_N }" />
				<e:field>
					<e:select id="WARR_GUAR_FLAG" name="WARR_GUAR_FLAG" value="0" options="${refYN}" readOnly="${form_WARR_GUAR_FLAG_RO }" width="160" required="${form_WARR_GUAR_FLAG_R }" disabled="${form_WARR_GUAR_FLAG_D }" onChange='setGuaranteeButtons' />
				</e:field>

				<e:label for="WARR_GUAR_AMT" title="${form_WARR_GUAR_AMT_N }" />
				<e:field>
					<e:select id="WARR_VAT_FLAG" name="WARR_VAT_FLAG" value="0" options="${vatFlag}" readOnly="${form_WARR_GUAR_AMT_RO }" width="160" required="${form_WARR_GUAR_AMT_R }" disabled="${form_WARR_GUAR_AMT_D }" onChange='setGuaranteeButtons' />
					<e:inputNumber id="WARR_GUAR_AMT" name="WARR_GUAR_AMT" width="${inputTextWidth }" required="${form_WARR_GUAR_AMT_R }" disabled="${form_WARR_GUAR_AMT_D }" value="" readOnly="${form_WARR_GUAR_AMT_RO }" onChange="calculateGuarantee" />
				</e:field>
				<e:label for="WARR_GUAR_PERCENT" title="${form_WARR_GUAR_PERCENT_N}" />
				<e:field>
					<e:inputNumber id="WARR_GUAR_PERCENT" name="WARR_GUAR_PERCENT" width="${inputTextWidth }" required="${form_WARR_GUAR_PERCENT_R }" disabled="${form_WARR_GUAR_PERCENT_D }" value="" readOnly="${form_WARR_GUAR_PERCENT_RO }" onChange="calculateGuarantee" />
					<e:text>/</e:text>
					<e:inputNumber id="WARR_GUAR_QTY" name="WARR_GUAR_QTY" width="${inputTextWidth }" required="${form_WARR_GUAR_QTY_R }" disabled="${form_WARR_GUAR_QTY_D }" value="" readOnly="${form_WARR_GUAR_QTY_RO }" />
				</e:field>
				<%-- <e:label for="WARR_GUAR_QTY" title="${form_WARR_GUAR_QTY_N }" /> --%>
				<%-- <e:field>
					<e:inputNumber id="WARR_GUAR_QTY" name="WARR_GUAR_QTY" width="${inputTextWidth }" required="${form_WARR_GUAR_QTY_R }" disabled="${form_WARR_GUAR_QTY_D }" value="" readOnly="${form_WARR_GUAR_QTY_RO }" />
				</e:field> --%>
			</e:row>
		</e:searchPanel>

        <e:buttonBar id="buttonBar3" align="right" width="98%">
            <e:button id="doSelect" name="doSelect" label="${doSelect_N }" disabled="${doSelect_D }" onClick="doSelect" />
        </e:buttonBar>

        	<e:row><e:text>물품정보</e:text></e:row>
			<e:row>
		  	 	<e:gridPanel gridType="${_gridType}" id="gridP" name="gridP" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.gridP.gridColData}" />
			</e:row>
			 <e:row>
		  		<e:gridPanel gridType="${_gridType}" id="rejectGrid" name="rejectGrid" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.rejectGrid.gridColData}" />
			</e:row>
			</form>
		</e:window>
</e:ui>
