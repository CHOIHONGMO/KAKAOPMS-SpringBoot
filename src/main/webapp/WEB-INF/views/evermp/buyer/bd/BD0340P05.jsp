<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0340P05";
	    var gridVendor;
	    var gridItem;

	    function init() {

		    gridVendor = EVF.getComponent("gridVendor");
		    gridVendor.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
		    gridVendor.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
		    gridVendor.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
		    gridVendor.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
		    gridVendor.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
		    gridVendor.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
		    gridVendor.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

		    gridVendor.setColFontSize('QTA_RFX_FROM_TO_DATE','12')
		    gridVendor.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
			    if(colId === 'QTA_NUM' && value !== ''){
			    	let negoStatus = gridVendor.getCellValue(rowId, 'NEGO_RESULT_TYPE');
					if(negoStatus ==='06' || negoStatus === '07' || negoStatus ==='08'){
						return EVF.alert('${BD0340P05_0001}');
					}

				    param = {
					     QTA_NUM 	: gridVendor.getCellValue(rowId,'QTA_NUM')
						,QTA_CNT 	: gridVendor.getCellValue(rowId,'QTA_CNT')
						,VENDOR_CD 	: gridVendor.getCellValue(rowId,'VENDOR_CD')
					    ,popupFlag 	: true
					    ,detailView : true
				    };
				    everPopup.openPopupByScreenId('BQ0320', 1200, 900, param);
			    } else if(colId === 'VENDOR_NM'){
			    	let reQtaNum = gridVendor.getCellValue(rowId, 'QTA_NUM');
			    	if(reQtaNum === ''){
					    gridItem.delAllRow();
			    		return EVF.alert('${BD0340P05_0005}');
				    }
					EVF.V('QTA_NUM', gridVendor.getCellValue(rowId,'QTA_NUM'));
				    EVF.V('QTA_CNT', gridVendor.getCellValue(rowId,'QTA_CNT'));
					doSearchItem();
				} else if(colId === "SLT_RMK") {
				    param = {
					    rowId: rowId
					    , havePermission: true
					    , screenName: '비고'
					    , callBackFunction: 'callback_setSltRmk'
					    , TEXT_CONTENTS: gridVendor.getCellValue(rowId, "SLT_RMK")
					    , detailView: false
				    };
				    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);

			    }else if(colId === 'EV_RESULT'){
				    params = {
					    EV_NUM: EVF.V('EV_NUM'),
					    VENDOR_CD: gridVendor.getCellValue(rowId, "VENDOR_CD"),
					    VENDOR_SQ: '1',
					    POPUPFLAG: "Y",
					    detailView: true,
					    havePermission: false,
					    EV_TYPE : 'BD'
				    };

				    everPopup.openPopupByScreenId("EV0250", 1200, 1000, params);
			    }
			});



		    gridItem = EVF.getComponent("gridItem");
		    gridItem.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
		    gridItem.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
		    gridItem.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
		    gridItem.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
		    gridItem.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
		    gridItem.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
		    gridItem.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

		    gridItem.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
			    if(colId === "BATT_FILE_CNT") {
				    param = {
					    detailView		: true,
					    attFileNum		: gridItem.getCellValue(rowId, "BATT_FILE_NUM"),
					    rowId			: rowId,
					    callBackFunction: "setAttFile",
					    bizType			: "BD",
					    fileExtension	: "*"
				    };
				    everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
			    } else if(colId === "SATT_FILE_CNT") {
				    param = {
					    detailView			: true,
					    attFileNum			: gridItem.getCellValue(rowId, "SATT_FILE_NUM"),
					    rowId				: rowId,
					    callBackFunction	: "setAttFile",
					    bizType				: "BD",
					    fileExtension		: "*"
				    };
				    everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
			    } else if(colId === 'BRMK'){
				    param = {
					    rowId: rowId
					    , havePermission: false
					    , screenName: '비고'
					    , callBackFunction: ''
					    , TEXT_CONTENTS: gridItem.getCellValue(rowId, "BRMK")
					    , detailView: true
				    };
				    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
			    } else if(colId === 'SRMK'){
				    param = {
					    rowId: rowId
					    , havePermission	: false
					    , screenName		: '비고'
					    , callBackFunction	: ''
					    , TEXT_CONTENTS		: gridItem.getCellValue(rowId, "SRMK")
					    , detailView		: true
				    };
				    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
			    }
		    });

		    $('#RFX_NUM').click(function(){
			    var param = {
				    BUYER_CD    : EVF.V('BUYER_CD')
				    ,RFX_NUM    : EVF.V('RFX_NUM')
				    ,RFX_CNT    : EVF.V('RFX_CNT')
				    ,detailView : true
			    };
			    everPopup.openPopupByScreenId('BD0310', 1200, 900, param);
		    });


		    if($('#PROGRESS_CD').val() > '2800'){
			    formUtil.setVisible('doNego', false);
		    }

		    if($('#PROGRESS_CD').val() > '2850' || $('#PROGRESS_CD').val() === '1400'){
			    formUtil.setVisible('doNego', false);
			    formUtil.setVisible('doSettle', false);
			    formUtil.setVisible('doCancelRfq', false);
			    formUtil.setVisible('doReBid', false);
		    }

		    doSearchVendor();
	    }

	    function doSearchVendor(){
		    var store = new EVF.Store();
		    store.setGrid([gridVendor]);
		    store.load(baseUrl + "/doSearchVendor", function() {
			    var gridAll = gridVendor.getAllRowValue();
			    for(var i in gridAll){
			    	if(gridAll[i].NEGO_RESULT_TYPE !== ''){
			    		break;
					}
				    if(gridAll[i].NEGO_RESULT_TYPE === ''){
					    gridVendor.setCellValue(i, 'NEGO_RESULT_TYPE', '01');
					    break;
				    }
			    }

			    for(var i in gridAll){
				    if(gridAll[i].NEGO_RESULT_TYPE === '06' || gridAll[i].NEGO_RESULT_TYPE === '07' || gridAll[i].NEGO_RESULT_TYPE === '08'){
					    formUtil.setVisible('doSettle', false);
					    formUtil.setVisible('doCancelRfq', false);
					    formUtil.setVisible('doReBid', false);
					    break;
				    }
				    if(gridAll[i].NEGO_RESULT_TYPE === '09' && gridAll[i].QTA_NUM === ''){
					    formUtil.setVisible('doSettle', false);
					    break;
					}
				}
			    for(var i in gridAll){

			    	if(gridAll[i].NEGO_RESULT_TYPE == '02' || gridAll[i].QTA_CNT>1){
			    		$("#doReBid").children('div').find(".e-button-text").text('${BD0340P05_0006}')
						$("#doCancelRfq").children('div').find(".e-button-text").text('${BD0340P05_0007}')
			    		break;
			    	}
			    }
			    if(gridVendor.getRowCount() === 0){
				    EVF.C('doNego').setVisible(false);
				    EVF.C('doReBid').setVisible(false);
				    EVF.C('doSettle').setVisible(false);
			    }

		    });
		}

		function doSearchItem(){
			var store = new EVF.Store();
			store.setGrid([gridItem]);
			store.load(baseUrl + "/doSearchItem", function() {

			});
		}

	    function callback_setSltRmk(text, rowId) {
		    gridVendor.setCellValue(rowId, 'SLT_RMK', text);
	    }

		//우선협상자 선정
		function doNego(){
			var store = new EVF.Store();
			store.setGrid([gridVendor]);
			store.getGridData(gridVendor,'all');
			store.load(baseUrl + "/doNego", function() {
				location.href=baseUrl+'/view.so?SCREEN_ID=BD0340P05&BUYER_CD=' + EVF.V('BUYER_CD') + '&RFX_NUM=' + EVF.V('RFX_NUM') + '&RFX_CNT=' + EVF.V('RFX_CNT')+'&popupFlag=true';
			});

		}

		//낙찰
		function doSettle(){

	    	if(!confirm('${BD0340P05_0002}')) return;

			var store = new EVF.Store();
			store.setGrid([gridVendor]);
			store.getGridData(gridVendor,'all');
			store.load(baseUrl + "/doSettle", function() {
				location.href=baseUrl+'/view.so?SCREEN_ID=BD0340P05&BUYER_CD=' + EVF.V('BUYER_CD') + '&RFX_NUM=' + EVF.V('RFX_NUM') + '&RFX_CNT=' + EVF.V('RFX_CNT')+'&popupFlag=true';
			});
		}

		//유찰
		function doCancelRfq(){

	    	var msg1 = EVF.V('PROGRESS_CD') === '2800' ? '${BD0340P05_0003}' : '${BD0340P05_0004}';
			if(!confirm(msg1)) return;

			var store = new EVF.Store();
			store.setGrid([gridVendor]);
			store.getGridData(gridVendor,'all');
			store.load(baseUrl + "/doCancelRfq", function() {
				location.href=baseUrl+'/view.so?SCREEN_ID=BD0340P05&BUYER_CD=' + EVF.V('BUYER_CD') + '&RFX_NUM=' + EVF.V('RFX_NUM') + '&RFX_CNT=' + EVF.V('RFX_CNT')+'&popupFlag=true';
			});
		}

		//재입찰
		function doReBid(){

	    	var rebidOb = '';
			if(EVF.V('VENDOR_OPEN_TYPE') === 'OB'){
				rebidOb = 'ReBid_OB';
			}

	    	if(EVF.V('PROGRESS_CD') === '2800'){
			    var param = {
				     BUYER_CD   	: '${form.BUYER_CD}'
				    ,RFX_NUM    	: '${form.RFX_NUM}'
				    ,RFX_CNT    	: '${form.RFX_CNT}'
					,ReBid_OB		: rebidOb
				    ,baseDataType 	: "RERFX"
				    ,detailView 	: false
			    };
			    everPopup.openPopupByScreenId('BD0310', 1200, 900, param);
			}else if(EVF.V('PROGRESS_CD') === '2850'){
				var qtaNum = '';
				var qtaCnt = '';
			    var vendorCd = '';
	    		var pick = gridVendor.getAllRowValue();
	    		for(var i in pick){

	    			if(pick[i].NEGO_RESULT_TYPE === '02' || pick[i].NEGO_RESULT_TYPE === '09'){ // 협상중 또는 개찰 상태
					    qtaNum = pick[i].QTA_NUM;
					    qtaCnt = pick[i].QTA_CNT;
					    vendorCd = pick[i].VENDOR_CD;
				    }
			    }

				var param = {
					BUYER_CD    : '${form.BUYER_CD}'
					,RFX_NUM    : '${form.RFX_NUM}'
					,RFX_CNT    : '${form.RFX_CNT}'
					,QTA_NUM 	: qtaNum
					,QTA_CNT 	: qtaCnt
					,VENDOR_CD  : vendorCd
					,detailView : false
				}
				console.log(param)
	    		everPopup.openPopupByScreenId('BD0340P06', 600, 400, param);
		    }

		}

	    //입찰비교
	    function doCompareQta(){
		    var param = {
			    BUYER_CD   : EVF.V('BUYER_CD')
			    ,RFX_NUM   : EVF.V('RFX_NUM')
			    ,RFX_CNT     : EVF.V('RFX_CNT')
			    ,detailView : false
		    };
		    everPopup.openPopupByScreenId('BD0340P03', 1200, 600, param);
	    }

	       function doClose(){
	        if(opener != null) {

		        <c:if test="${param.APP_DOBD0340P05C_NUM == '' || param.APP_DOC_NUM == null}">
		        if(opener.doSearch != undefined) {
			        opener.doSearch();
		        }
		        </c:if>

		        window.close();
	        } else {

		        <c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
		        if(parent.doSearch != undefined) {
			        parent.doSearch();
		        }
		        </c:if>

		        new EVF.ModalWindow().close(null);
	        }
		}

	</script>

	<e:window id="BD0340P05" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
			<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS2}" />
			<e:inputHidden id='APP_DOC_NUM' name="APP_DOC_NUM" value="${empty param.appDocNum ? form.APP_DOC_NUM2 : param.appDocNum}" />
			<e:inputHidden id='APP_DOC_CNT' name="APP_DOC_CNT" value="${empty param.appDocCnt ? form.APP_DOC_CNT2 : param.appDocCnt}" />

			<e:inputHidden id="approvalFormData" name="approvalFormData"/>
			<e:inputHidden id="approvalGridData" name="approvalGridData"/>
			<e:inputHidden id="QTA_NUM" name="QTA_NUM" value=""/>
			<e:inputHidden id="QTA_CNT" name="QTA_CNT" value=""/>
			<e:inputHidden id="SLT_RMK" name="SLT_RMK" value=""/>
			<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
			<e:inputHidden id="EV_NUM" name="EV_NUM" value="${form.EV_NUM}" />
			<e:inputHidden id="EXEC_EV_TPL_NUM" name="EXEC_EV_TPL_NUM" value="${form.EXEC_EV_TPL_NUM}" />
			<e:row>
				<%--견적요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}"  style="color:blue; cursor:pointer" />
					<e:text>&nbsp;/&nbsp;</e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<e:label for="dummy"/>
				<e:field colSpan="1" />
			</e:row>
			<e:row>
				<%--견적명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form_VENDOR_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${form.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
					<e:text>/</e:text>
					<e:select id="PRC_SLT_TYPE" name="PRC_SLT_TYPE" value="${form.PRC_SLT_TYPE}" options="${prcSltTypeOptions}" width="${form_PRC_SLT_TYPE_W}" disabled="${form_PRC_SLT_TYPE_D}" readOnly="${form_PRC_SLT_TYPE_RO}" required="${form_PRC_SLT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--입찰기간--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:text> ${form.RFX_FROM_DATE} </e:text>
					<e:text>&nbsp;~&nbsp;</e:text>
					<e:text> ${form.RFX_TO_DATE} </e:text>
				</e:field>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>

		<e:buttonBar align="right">
			<e:button id="doNego" name="doNego" label="${doNego_N}" onClick="doNego" disabled="${doNego_D}" visible="${doNego_V}"/>
			<e:button id="doSettle" name="doSettle" label="${doSettle_N}" onClick="doSettle" disabled="${doSettle_D}" visible="${doSettle_V}"/>
			<e:button id="doCancelRfq" name="doCancelRfq" label="${doCancelRfq_N}" onClick="doCancelRfq" disabled="${doCancelRfq_D}" visible="${doCancelRfq_V}"/>
			<e:button id="doReBid" name="doReBid" label="${doReBid_N}" onClick="doReBid" disabled="${doReBid_D}" visible="${doReBid_V}"/>
			<e:button id="doCompareQta" name="doCompareQta" label="${doCompareQta_N}" onClick="doCompareQta" disabled="${doCompareQta_D}" visible="${doCompareQta_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:searchPanel id="gridVendorTitle" title="${BD0340P05_gridVendorTitle}" />
		<e:gridPanel gridType="${_gridType}" id="gridVendor" name="gridVendor" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.gridV.gridColData}"/>
		<e:searchPanel id="gridItemTitle" title="${BD0340P05_gridItemTitle}" />
		<e:gridPanel gridType="${_gridType}" id="gridItem" name="gridItem" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridItem.gridColData}"/>

	</e:window>
</e:ui>