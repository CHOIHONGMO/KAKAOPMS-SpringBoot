<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
		var gridL;
		var gridR;
		var baseUrl = "/evermp/buyer/rq";

		var vendorOptnType = '${param.VENDOR_OPEN_TYPE}';
		var selectedVendorlist = '${param.vendorArray}';

		function init(){

			gridL = EVF.C("gridL");
			gridR = EVF.C("gridR");

			/*if (vendorOptnType === 'QN') {
				gridL.setProperty('singleSelect', true);
				gridR.setProperty('singleSelect', true);
			} else {
				gridL.setProperty('multiSelect', true);
				gridR.setProperty('multiSelect', true);
			}*/

			gridL.cellClickEvent(function(rowId, colId, value) {
				if (colId === "VENDOR_NM") {
					var param = {
						'VENDOR_CD': gridL.getCellValue(rowId, 'VENDOR_CD'),
						'IRS_NUM' : gridL.getCellValue(rowId, 'IRS_NO'),
						'buttonAuth' : false,
						'detailView': true
					};
					everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
				}
			});

			gridR.cellClickEvent(function(rowId, colId, value) {
				if (colId === "VENDOR_NM") {
					var param = {
						'VENDOR_CD': gridR.getCellValue(rowId, 'VENDOR_CD'),
						'IRS_NUM' : gridR.getCellValue(rowId, 'IRS_NO'),
						'buttonAuth' : false,
						'detailView': true
					};
					everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
				}
			});

			if(selectedVendorlist != null && selectedVendorlist !== ''){
				var vendorSelected = JSON.parse(selectedVendorlist);
				for(var i in vendorSelected) {
					var addParam = [{
						"VENDOR_CD" : vendorSelected[i].VENDOR_CD
						, "VENDOR_NM" : vendorSelected[i].VENDOR_NM
						, "CEO_USER_NM" : vendorSelected[i].CEO_USER_NM
						, "IRS_NO" : vendorSelected[i].IRS_NO
						, "USER_NM" : vendorSelected[i].USER_NM
						, "TEL_NUM" : vendorSelected[i].TEL_NUM
						, "EMAIL" : vendorSelected[i].EMAIL
						, "CELL_NUM" : vendorSelected[i].CELL_NUM
						, "USER_ID" : vendorSelected[i].USER_ID
						, "MAKER_NM" : vendorSelected[i].MAKER_NM
					}];
					gridR.addRow(addParam);
				}
			}


			if('${param.MODIFIABILITY}' === 'true'){
				gridR.setColReadOnly('CELL_NUM',false);
				gridR.setColReadOnly('EMAIL',false);
				//gridR.setColRequired('CELL_NUM', true);
				gridR.setColRequired('EMAIL', true);
			}

			doSearch();
		}

		function doSearchVendor(){
			param = {
				callBackFunction: "_selectVendor"
			};
			everPopup.openCommonPopup(param, "SP0064");
		}

		function _selectVendor(data){
			EVF.V("VENDOR_CD", data.VENDOR_CD);
			EVF.V("VENDOR_NM", data.VENDOR_NM);
		}

		function doSearch(){
			var store = new EVF.Store();
			store.setGrid([gridL]);
			store.load(baseUrl + '/RQ0110P02/doSearch', function(){
				if (gridL.getRowCount() === 0) {
					alert("${msg.M0002 }");
				}
				if (gridL.getRowCount() === 1) {
					gridL.checkAll(true);
					doSendRight();
				}
			});
		}

		function doSendRight(){

			if( gridL.isEmpty( gridL.getSelRowId() ) ) {
				return alert("${msg.M0004}");
			}

			var rowIds = gridL.getSelRowId();
			for(var i in rowIds) {
				var addParam = [{
					  "VENDOR_CD" : gridL.getCellValue(rowIds[i], 'VENDOR_CD')
					, "VENDOR_NM" : gridL.getCellValue(rowIds[i], 'VENDOR_NM')
					, "CEO_USER_NM" : gridL.getCellValue(rowIds[i], 'CEO_USER_NM')
					, "IRS_NO" : gridL.getCellValue(rowIds[i], 'IRS_NO')
					, "USER_NM" : gridL.getCellValue(rowIds[i], 'USER_NM')
					, "TEL_NUM" : gridL.getCellValue(rowIds[i], 'TEL_NUM')
					, "EMAIL" : gridL.getCellValue(rowIds[i], 'EMAIL')
					, "USER_ID" : gridL.getCellValue(rowIds[i], 'USER_ID')
					, "CELL_NUM" : gridL.getCellValue(rowIds[i], 'CELL_NUM')
					, "MAKER_NM" : gridL.getCellValue(rowIds[i], 'MAKER_NM')
				}];
				var validData = valid.equalPopupValid(JSON.stringify(addParam), gridR, "VENDOR_CD");
				gridR.addRow(validData);
			}

			/*if(vendorOptnType == 'QN') {
				gridR.checkAll(false)
			}*/

			for(var x = rowIds.length - 1; x >= 0; x--) {
				gridL.delRow(rowIds[x]);
			}
		}

		function doSendLeft(){
			if( gridR.isEmpty( gridR.getSelRowId() ) ) {
				return alert("${msg.M0004}");
			}

			var selRowIdR = gridR.getSelRowId();
			for(var x = selRowIdR.length - 1; x >= 0; x--) {
				gridR.delRow(selRowIdR[x]);
			}
		}

		function doChoice() {

			//if(!gridR.isExistsSelRow()) { return alert('${msg.M0004}'); }

			//견적요청에서 넘어온 경우, 이메일과 핸드폰번호 입력 필수
			if('${param.MODIFIABILITY}' === 'true'){

				if(!gridR.validate().flag) { return alert(gridR.validate().msg); }

				var regExpEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
				//var regExpCell = /^01(?:0|1|[6-9])(?:\d{3}|\d{4})\d{4}$/;

				var vendorInfo = gridR.getSelRowValue();
				for(var i in vendorInfo){

					if(vendorInfo[i].EMAIL == null || vendorInfo[i].EMAIL === '' ){
						return EVF.alert("${RQ0110P02_0003}");
					}
					if(vendorInfo[i].EMAIL.match(regExpEmail) == null){
						return EVF.alert("${RQ0110P02_0004}");
					}
					/*if(vendorInfo[i].CELL_NUM.match(regExpCell) == null){
						return EVF.alert("${RQ0110P02_0005}");
					}*/
				}

			}

			var selRowDataR = gridR.getSelRowValue();
			opener.window['${param.callBackFunction}'](JSON.stringify(selRowDataR), EVF.V('ROW_DATA'));
			doClose();
		}

		function doClose(){
			formUtil.close();
		}
		getVendorListDefault

	</script>

	<e:window id="RQ0110P02" onReady="init" initData="${initData}" title="${fullScreenName}" height="100%">
		<e:inputHidden id="vendorListJson" name="vendorListJson" />
		<e:inputHidden id="CUST_CD" name="CUST_CD" value="${param.CUST_CD}" />
		<e:inputHidden id="ROW_DATA" name="ROW_DATA" value="${param.ROW_DATA}" />
		<e:inputHidden id="VENDOR_TYPE" name="VENDOR_TYPE" value="${param.VENDOR_TYPE}"/>
		<e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${param.PR_BUYER_CD}"/>
		<e:searchPanel id="form" columnCount="2" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--협력사--%>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="30%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:text>&nbsp;/&nbsp;</e:text>
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<%--조회유형--%>
				<e:label for="TYPE" >
					<e:select id="TYPE" name="TYPE" value="" options="${typeOptions}" width="${form_TYPE_W}" disabled="${form_TYPE_D}" readOnly="${form_TYPE_RO}" required="${form_TYPE_R}" placeHolder="" usePlaceHolder="false" >
						<e:option text="${RQ0110P02_MAJOR_ITEM_NM}" value="MAJOR_ITEM_NM">${RQ0110P02_MAJOR_ITEM_NM}</e:option>
						<e:option text="${RQ0110P02_MAJOR_VENDOR_RMK}" value="MAJOR_VENDOR_RMK">${RQ0110P02_MAJOR_VENDOR_RMK}</e:option>
						<e:option text="${RQ0110P02_MAJOR_CERT_RMK}" value="MAJOR_CERT_RMK">${RQ0110P02_MAJOR_CERT_RMK}</e:option>
					</e:select>
				</e:label>
				<e:field>
					<e:inputText id="MAJOR_SEARCH" name="MAJOR_SEARCH" value="" width="${form_MAJOR_SEARCH_W}" maxLength="${form_MAJOR_SEARCH_M}" disabled="${form_MAJOR_SEARCH_D}" readOnly="${form_MAJOR_SEARCH_RO}" required="${form_MAJOR_SEARCH_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--대표자명--%>
				<e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}" />
				<e:field>
					<e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="" width="${form_CEO_USER_NM_W}" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" />
				</e:field>
				<%--사업자등록번호--%>
				<e:label for="IRS_NO" title="${form_IRS_NO_N}" />
				<e:field>
					<e:inputText id="IRS_NO" name="IRS_NO" value="" width="${form_IRS_NO_W}" maxLength="${form_IRS_NO_M}" disabled="${form_IRS_NO_D}" readOnly="${form_IRS_NO_RO}" required="${form_IRS_NO_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doChoice" name="doChoice" label="${doChoice_N}" onClick="doChoice" disabled="${doChoice_D}" visible="${doChoice_V}"/>
		</e:buttonBar>

		<e:panel height="fit" width="100%">
			<e:panel width="49%">
				<e:title title="${RQ0110P02_0001}" />
				<e:gridPanel id="gridL" name="gridL" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
			</e:panel>

			<e:panel width="2%">
				<div style="width: 100%; margin-top: 200px; vertical-align: middle;" align="center">
					<div id="doSendRight" style="background: url(/images/eversrm/button/thumb_next.png) no-repeat; width: 13px; height: 22px; display: inline-block; cursor: pointer;" onclick="doSendRight();">&nbsp;</div>
					<br />
					<div id="doSendLeft" style="background: url(/images/eversrm/button/thumb_prev.png) no-repeat; width: 13px; height: 22px; display: inline-block; margin-top: 10px; cursor: pointer;" onclick="doSendLeft();">&nbsp;</div>
				</div>
			</e:panel>

			<e:panel width="49%">
				<e:title title="${RQ0110P02_0002}" />
				<e:gridPanel id="gridR" name="gridR" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
			</e:panel>
		</e:panel>

	</e:window>
</e:ui>