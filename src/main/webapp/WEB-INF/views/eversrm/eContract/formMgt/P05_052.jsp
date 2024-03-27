<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var baseUrl      = "/eversrm/eContract/formMgt/";
		var gridM = {};
		var gridA = {};

		var opCBackFn     = '${param.openerCallBackFunction}';
		var rfx_ryq       = '${param.RFX_RYQ}';

		var baseDataType  = "${empty param.baseDataType? 'contract' : param.baseDataType}";

		function init() {

			gridM = EVF.C("gridM");
			gridA = EVF.C("gridA");


			gridM.setProperty('shrinkToFit', true);
			gridM.setProperty('singleSelect', true);
			gridA.setProperty('shrinkToFit', true);

			EVF.C('MANUAL_CONT_FLAG').setValue('0'); //수기계약여부

			gridM.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch (celname) {
					case 'multiSelect':
						var formNum = gridM.getCellValue(rowid, "FORM_NUM");
						doSearchAdditionalForm(formNum);
						break;

					case 'FORM_NM':
						var formNum = gridM.getCellValue(rowid, "FORM_NUM");
						gridM.checkRow(rowid, true, true, false);
						doSearchAdditionalForm(formNum);
						break;

					default:
						return;
				}

			});

			doSearch();
			setFormComponents();

			gridM.excelExportEvent({
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
		}

        function doSearch() {
			var store = new EVF.Store();
			store.setGrid([ gridM ]);
			store.load(baseUrl + 'BECF_030/doSearchMainForm', function() {


	        	if(gridM.getRowCount() == 0){
    	        	alert("${msg.M0002 }");
        	    	gridA.delAllRow();
            	}else {
         			gridM.checkRow(0, true);
		        }
			});
        }

        function doSearchAdditionalForm(selectedFormNum) {
			var store = new EVF.Store();

			store.setGrid([ gridA ]);
	        store.setParameter('selectedFormNum', selectedFormNum);
			store.load(baseUrl + 'BECF_030/doSearchAdditionalForm', function() {
			gridA.checkAll(true);

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

			var gridMData = gridM.getSelRowValue();
			if (gridMData.length > 0) {
				var valid = gridM.validate();
				if (!valid.flag) {
					alert(valid.msg);
					return;
				}
			} else if (gridMData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			var selectedRow = gridM.getSelRowValue()[0];

			var selformNum = selectedRow['FORM_NUM'];

		    EVF.C("SELECT_FORM_NUM").setValue(selformNum);

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

			var gridAData          = gridA.getSelRowValue();
			var contractFormJson   = store._getFormDataAsJson();
			var mainFormJson       = JSON.stringify(gridMData);
			var additionalFormJson = JSON.stringify(gridAData);

			var soNum    ='${param.SO_NUM}';
			var soCnt    ='${param.SO_CNT}';
			var execNum  ='${param.EXEC_NUM}';
			var contNum  ='${param.CONT_NUM}';
			var contCnt  ='${param.CONT_CNT}';
			var accAttr  ='${param.ACC_ATTR}';
			var itemCls4 ='${param.ITEM_CLS4}';
			var soType   ='${param.SO_TYPE}';

			EVF.C("contractForm").setValue(contractFormJson.replace(/"/gi, '\''));
			EVF.C("mainForm").setValue(mainFormJson.replace(/"/gi, '\''));
			EVF.C("additionalForm").setValue(additionalFormJson.replace(/"/gi, '\''));
			EVF.C("contractEditable").setValue("true");
			EVF.C("detailView").setValue("false");
			EVF.C('TRANSACTION_FLAG').setValue('Y');

			EVF.C("baseDataType").setValue(baseDataType.replace(/"/gi, '\''));

		   	var param = {
		   			 'baseDataType'  : EVF.C("baseDataType").getValue()
		   			,'contReqFlag'   : EVF.C("contReqFlag").getValue()
		   			,'contReqStatus' : EVF.C("CONT_REQ_STATUS").getValue()
		   		 	,'SO_NUM'        : soNum
		   			,'SO_CNT'        : soCnt
		   		 	,'EXEC_NUM'      : execNum
		   		 	,'CONT_NUM'      : contNum
		   		 	,'CONT_CNT'      : contCnt
		   		 	,'ACC_ATTR'      : accAttr
		   		 	,'ITEM_CLS4'     : itemCls4
		   		 	,'SO_TYPE'       : soType
		   		 	,'RFX_RYQ'		 : rfx_ryq
		   		 	//,'RFXTYPE' :rfxType
		   			,'openerCallBackFunction': EVF.C("openerCallBackFunction").getValue()
		   			,'SELECT_FORM_NUM':selformNum
		   			,'contractForm': EVF.C("contractForm").getValue()
		   			,'mainForm': EVF.C("mainForm").getValue()
		   			,'additionalForm': EVF.C("additionalForm").getValue()
		   			,'contractEditable': EVF.C("contractEditable").getValue()
		   			,'VENDOR_PIC_USER_NM': EVF.C("VENDOR_PIC_USER_NM").getValue()
		   			,'CONT_WT_NUM': EVF.C("CONT_WT_NUM").getValue()
		   			,'CONT_DESC': EVF.C("CONT_DESC").getValue()
		   			,'CONT_DATE': EVF.C("CONT_DATE").getValue()
		   			,'CONT_USER_ID': EVF.C("CONT_USER_ID").getValue()
		   			,'SUPPLY_AMT': EVF.C("SUPPLY_AMT").getValue()
		   			,'VENDOR_CD': EVF.C("VENDOR_CD").getValue()
		   			,'VENDOR_NM' : EVF.C("VENDOR_NM").getValue()
		   			,'CONT_REQ_CD': EVF.C("CONT_REQ_CD").getValue()
		   			,'MANUAL_CONT_FLAG': EVF.C("MANUAL_CONT_FLAG").getValue()
		   			,'BUYER_CD': EVF.C("BUYER_CD").getValue()
		   			,'CONT_REQ_RMK':  EVF.C("CONT_REQ_RMK").getValue()
		   			,'detailView': EVF.C("detailView").getValue()
				};

			var url ='/eversrm/eContract/eContractMgt/BECM_030/view.so?';
			window.location.href = url + $.param(param);
	    }

        function setFormComponents() {
        	if (baseDataType === 'exContract' || baseDataType === 'soContract') {
				EVF.C("VENDOR_NM").setDisabled(true);
			}
        }

        function doSelectVendor() {
			everPopup.openCommonPopup({
				callBackFunction : "setVendor"
			}, 'SP0016');
        }

        function setVendor(vendor) {
			EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
			EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
        }

        function doClose() {
            window.close();
        }

	</script>
<!--  margin="0 4px" -->
	<e:window id="P05_052" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
<%-- 	<e:searchPanel id ="formData" name ="formData">   --%>
	<!-- 	<form id="formData" name="formData">  -->
        <e:inputHidden id="CONT_WT_NUM" name="CONT_WT_NUM" value="${param.CONT_WT_NUM}" />
		<e:inputHidden id="contReqFlag" name="contReqFlag" value="${empty form.CONT_REQ_CD ? (empty param.contReqFlag ? '01' : param.contReqFlag) : form.CONT_REQ_CD}"/>
		<e:inputHidden id="CONT_REQ_CD" name="CONT_REQ_CD" value="${empty form.CONT_REQ_CD ? (empty param.contReqFlag ? '01' : param.contReqFlag) : form.CONT_REQ_CD}"  />
		<e:inputHidden id="CONT_REQ_STATUS" name="CONT_REQ_STATUS" value="${empty form.CONT_REQ_STATUS ? (empty param.contReqStaus ? 'C' : param.contReqStatus) : form.CONT_REQ_STATUS}"  />


        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
        <e:inputHidden id="SELECT_FORM_NUM" name="SELECT_FORM_NUM" value="" />
        <e:inputHidden id="contractForm" name="contractForm"  value=""/>
		 <e:inputHidden id="mainForm" name="mainForm" />
		<e:inputHidden id="additionalForm" name="additionalForm" />
		<e:inputHidden id="baseDataType" name="baseDataType" />
		<e:inputHidden id="contractEditable" name="contractEditable" />
		<e:inputHidden id="detailView" name="detailView" />
        <e:inputHidden id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="" />
        <e:inputHidden id="openerCallBackFunction" name="openerCallBackFunction" value="${param.openerCallBackFunction}" />
        <e:inputHidden id="CONT_DESC" style="${imeMode}" name="CONT_DESC" value="${param.CONT_DESC}" />
        <e:inputHidden id="CONT_DATE" name="CONT_DATE" value="${toDate }"/>
	    <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId }" />
	 	<e:inputHidden id="SUPPLY_AMT" name="SUPPLY_AMT"  value="${param.SUPPLY_AMT}" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"  />
		<e:inputHidden id="VENDOR_NM" name="VENDOR_NM" value="${param.VENDOR_NM}"  />
		<e:inputHidden id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="${form.MANUAL_CONT_FLAG}"/>
        <e:inputHidden id="CONT_REQ_RMK"  name="CONT_REQ_RMK"  value="${form.CONT_REQ_RMK}"/>

        <e:inputHidden id="GATE_CD" name="GATE_CD" value="${ses.gateCd}" />
		<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" />

<%--
		<e:inputHidden id="CONT_START_DATE" name="CONT_START_DATE" value="" />
		<e:inputHidden id="CONT_END_DATE"  name="CONT_END_DATE" value=""  />
 --%>

		<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSelect" name="doSelect" label="${doSelect_N }" disabled="${doSelect_D }" onClick="doSelect" />
         	<%-- <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/> --%>
        </e:buttonBar>
		<e:panel width="100%">
            <e:panel width="49%" >
                <e:gridPanel gridType="${_gridType}" id="gridM" name="gridM" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridM.gridColData}" />
            </e:panel>
            <e:panel width="1%">&nbsp;</e:panel>
            <e:panel width="50%">
                <e:gridPanel gridType="${_gridType}" id="gridA" name="gridA" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridA.gridColData}" />
            </e:panel>
        </e:panel>
	</e:window>

</e:ui>
