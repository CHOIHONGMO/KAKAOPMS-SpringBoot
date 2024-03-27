
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		//var gridVNCS = {};
		var gridVNCP = {}; // 영업담당자정보 Grid
		var gridSSRS = {}; // 동희그룹사납품정보 Grid
		var gridVNRS = {}; // 주요납품고객정보 Grid
		var gridVNTR = {}; // 신용평가정보 Grid
		// 신규추가
		var gridSGVN = {}; // 소싱그룹 Grid
		var gridVNSK = {}; // 지분현황 Grid
		var gridVNPL = {}; // 사업장 Grid
		var gridVNPS = {}; // 주요임원 Grid
		var gridVNFI = {}; // 재무현황 Grid
		var gridVNEQ = {}; // 생산설비 Grid
		var gridVNPI = {}; // 생상품목 Grid
		var gridVNCB = {}; // 협력업체 Grid
		var gridVNRE = {}; // 관계사 Grid
		var gridVNCA = {}; // 완성 차 의존도

		var baseUrl = "/eversrm/master/vendor/";

		var vncpFirstFlag = 0;

		function init() {
			// 경쟁력 form css 제어
			$('#form11 td.e-label-wrapper').attr('style', 'background: rgb(235, 242, 246); text-align: center');

			//gridVNCS = EVF.C('gridVNCS');
			gridVNCP = EVF.C('gridVNCP');
			gridVNTR = EVF.C('gridVNTR');
			gridVNRS = EVF.C('gridVNRS');
			gridSSRS = EVF.C('gridSSRS');
			gridVNSK = EVF.C('gridVNSK');
			gridVNPL = EVF.C('gridVNPL');
			gridVNPS = EVF.C('gridVNPS');
			gridVNFI = EVF.C('gridVNFI');
			gridVNEQ = EVF.C('gridVNEQ');
			gridSGVN = EVF.C('gridSGVN');
			gridVNPI = EVF.C('gridVNPI');
			gridVNCB = EVF.C('gridVNCB');
			gridVNRE = EVF.C('gridVNRE');
			gridVNCA = EVF.C('gridVNCA');

			<%--
			gridVNCP.setProperty('panelVisible', ${panelVisible});
			gridVNTR.setProperty('panelVisible', ${panelVisible});
			gridVNRS.setProperty('panelVisible', ${panelVisible});
			gridSSRS.setProperty('panelVisible', ${panelVisible});
			gridVNSK.setProperty('panelVisible', ${panelVisible});
			gridVNPL.setProperty('panelVisible', ${panelVisible});
			gridVNPS.setProperty('panelVisible', ${panelVisible});
			gridVNFI.setProperty('panelVisible', ${panelVisible});
			gridVNEQ.setProperty('panelVisible', ${panelVisible});
			gridSGVN.setProperty('panelVisible', ${panelVisible});
			gridSGVN.setProperty('panelVisible', ${panelVisible});
			gridVNPI.setProperty('panelVisible', ${panelVisible});
			gridVNCB.setProperty('panelVisible', ${panelVisible});
			gridVNRE.setProperty('panelVisible', ${panelVisible});
			gridVNCA.setProperty('panelVisible', ${panelVisible});
			--%>

			//gridVNCS.setProperty('shrinkToFit', true);
			gridVNCP.setProperty('shrinkToFit', true);
			gridVNTR.setProperty('shrinkToFit', true);
			gridVNRS.setProperty('shrinkToFit', true);
			gridSSRS.setProperty('shrinkToFit', true);
			gridVNSK.setProperty('shrinkToFit', true);
			gridVNPL.setProperty('shrinkToFit', true);
			gridVNPS.setProperty('shrinkToFit', true);
			gridVNFI.setProperty('shrinkToFit', false);
			gridVNEQ.setProperty('shrinkToFit', false);
			gridSGVN.setProperty('shrinkToFit', true);
			gridVNPI.setProperty('shrinkToFit', true);
			gridVNCB.setProperty('shrinkToFit', true);
			gridVNRE.setProperty('shrinkToFit', true);
			gridVNCA.setProperty('shrinkToFit', true);

			//gridVNCS.setProperty('multiselect', false);
			if ('${irsNum}' != '') {
				var irsNum = '${irsNum}';
				EVF.C("IRS_NUM1").setValue(irsNum.substring(0, 3));
				EVF.C("IRS_NUM2").setValue(irsNum.substring(3, 5));
				EVF.C("IRS_NUM3").setValue(irsNum.substring(5, 10));
			}
			if ('${form.IRS_NUM}' != '') {
				var irsNum = '${form.IRS_NUM}';
				EVF.C("IRS_NUM1").setValue(irsNum.substring(0, 3));
				EVF.C("IRS_NUM2").setValue(irsNum.substring(3, 5));
				EVF.C("IRS_NUM3").setValue(irsNum.substring(5, 10));
			}
			if ('${form.COMPANY_REG_NUM}' != '') {
				var irsNum = '${form.COMPANY_REG_NUM}';
				EVF.C("COMPANY_REG_NUM1").setValue(irsNum.substring(0, 6));
				EVF.C("COMPANY_REG_NUM2").setValue(irsNum.substring(6, 13));
			}
			if ('${form.ZIP_CD}' != '') {
				var zip_cd = '${form.ZIP_CD}';
				EVF.C("ZIP_CD1").setValue(zip_cd.substring(0, 3));
				EVF.C("ZIP_CD2").setValue(zip_cd.substring(3, 6));
			}
			if ('${form.VENDOR_CD}' != '') {
				//doSelectVNCS();
				doSelectAllGrid();
			} else {
				gridVNCP.addRow();
				gridVNCP.checkAll(false);
				/*
				gridVNTR.addRow();
				gridSSRS.addRow();
				gridVNRS.addRow();
				gridVNSK.addRow();
				gridVNPL.addRow();
				gridVNPS.addRow();
				gridVNFI.addRow();
				gridVNEQ.addRow();
				gridSGVN.addRow();
				gridVNPI.addRow();
				gridVNCB.addRow();
				gridVNRE.addRow();
				gridVNCA.addRow();

				gridVNTR.checkAll(false);
				gridSSRS.checkAll(false);
				gridVNRS.checkAll(false);
				gridVNSK.checkAll(false);
				gridVNPL.checkAll(false);
				gridVNPS.checkAll(false);
				gridVNFI.checkAll(false);
				gridVNEQ.checkAll(false);
				gridSGVN.checkAll(false);
				gridVNPI.checkAll(false);
				gridVNCB.checkAll(false);
				gridVNRE.checkAll(false);
				gridVNCA.checkAll(false);
				*/
				gridVNCP.setCellValue(0, 'SMS_FLAG', '1');
				gridVNCP.setCellValue(0, 'MAIL_FLAG', '1');
				vncpFirstFlag = 1;
			}
			/*
			 gridVNCS.excelExportEvent({
			 allCol : "${excelExport.allCol}",
			 selRow : "${excelExport.selRow}",
			 fileType : "${excelExport.fileType }",
			 fileName : "${screenName }VNCS",
			 excelOptions : {
			 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
			 ,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
			 ,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
			 ,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
			 ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			 }
			 });

			 gridVNCS.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			 if (celname == "SUBJECT") {
			 setCsInfomation(rowid);
			 }
			 });
			 */
			gridVNCP.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNCP",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNCP.addRowEvent(function() {
				gridVNCP.addRow();
			});
			gridVNCP.delRowEvent(function() {
				if ((gridVNCP.jsonToArray(gridVNCP.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNCP.delRow();
			});

			gridVNTR.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNTR",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNTR.addRowEvent(function() {
				gridVNTR.addRow();
			});

			gridVNTR.delRowEvent(function() {
				if ((gridVNTR.jsonToArray(gridVNTR.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNTR.delRow();
			});

			gridVNRS.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNRS",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNRS.addRowEvent(function() {
				gridVNRS.addRow();
			});

			gridVNRS.delRowEvent(function() {
				if ((gridVNRS.jsonToArray(gridVNRS.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNRS.delRow();
			});

			gridSSRS.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }SSRS",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridSSRS.addRowEvent(function() {
				gridSSRS.addRow();
			});

			gridSSRS.delRowEvent(function() {
				if ((gridSSRS.jsonToArray(gridSSRS.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridSSRS.delRow();
			});

			gridSSRS.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch(celname) {
					case 'ATT_FILE_CNT':
						var param = {
							havePermission: '${!param.detailView}',
							attFileNum: gridSSRS.getCellValue(rowid, 'ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'fileAttachPopupCallbackSSRS',
							bizType: 'VENDOR',
							fileExtension: '*'
						};

						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						break;
				}
			});

			gridVNSK.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNSK",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNSK.addRowEvent(function() {
				gridVNSK.addRow();
			});
			gridVNSK.delRowEvent(function() {
				if ((gridVNSK.jsonToArray(gridVNSK.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNSK.delRow();
			});

			// 사업장
			gridVNPL.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNPL",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNPL.addRowEvent(function() {
				gridVNPL.addRow();
			});
			gridVNPL.delRowEvent(function() {
				if ((gridVNPL.jsonToArray(gridVNPL.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNPL.delRow();
			});

			gridVNPL.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch(celname) {
					case 'ZIP_CD':

						var url = '/common/code/BADV_020/view';
						var param = {
							callBackFunction : "setZipCodeVNPL",
							modalYn : true,
							rowId : rowid
						};
						//everPopup.openModalPopup(url, 700, 600, param, "searchZip");
						everPopup.jusoPop(url, param);

						break;
				}
			});

			gridVNPS.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNPS",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNPS.addRowEvent(function() {
				gridVNPS.addRow();
			});
			gridVNPS.delRowEvent(function() {
				if ((gridVNPS.jsonToArray(gridVNPS.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNPS.delRow();
			});

			gridVNFI.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNFI",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNFI.addRowEvent(function() {
				gridVNFI.addRow();
			});

			gridVNFI.delRowEvent(function() {
				if ((gridVNFI.jsonToArray(gridVNFI.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNFI.delRow();
			});

			gridVNFI.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				/*switch(celname) {
				 case 'ATT_FILE_CNT':
				 var param = {
				 havePermission: '${!param.detailView}',
				 attFileNum: gridVNFI.getCellValue(rowid, 'ATT_FILE_NUM'),
				 rowId: rowid,
				 callBackFunction: 'fileAttachPopupCallbackVNFI',
				 bizType: 'VENDOR',
				 fileExtension: '*'
				 };

				 everPopup.openPopupByScreenId('commonFileAttach', 650, 270, param);
				 break;
				 }*/
			});

			gridVNEQ.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNEQ",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNEQ.addRowEvent(function() {
				gridVNEQ.addRow();
			});
			gridVNEQ.delRowEvent(function() {
				if ((gridVNEQ.jsonToArray(gridVNEQ.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNEQ.delRow();
			});

			gridVNEQ.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch(celname) {
					case 'ATT_FILE_CNT':
						var param = {
							havePermission: '${!param.detailView}',
							attFileNum: gridVNEQ.getCellValue(rowid, 'ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'fileAttachPopupCallbackVNEQ',
							bizType: 'VENDOR',
							fileExtension: '*'
						};

						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						break;
				}
			});

			gridVNPI.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNEQ",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNPI.addRowEvent(function() {
				gridVNPI.addRow();
			});
			gridVNPI.delRowEvent(function() {
				if ((gridVNPI.jsonToArray(gridVNPI.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNPI.delRow();
			});

			gridVNPI.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch(celname) {
					case 'ATT_FILE_CNT':
						var param = {
							havePermission: '${!param.detailView}',
							attFileNum: gridVNPI.getCellValue(rowid, 'ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'fileAttachPopupCallbackVNPI',
							bizType: 'VENDOR',
							fileExtension: '*'
						};

						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						break;
				}
			});

			gridVNCB.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNEQ",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNCB.addRowEvent(function() {
				gridVNCB.addRow();
			});
			gridVNCB.delRowEvent(function() {
				if ((gridVNCB.jsonToArray(gridVNCB.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNCB.delRow();
			});

			gridVNCB.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
				switch(celname) {
					case 'VENDOR_NM':
						var column = {'VENDOR_NM': 'VENDOR_NM'};

						if(valid.equalColValid(gridVNCB, column)) {
							return;
						}
						break;
				}
			});

			gridVNRE.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNEQ",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNRE.addRowEvent(function() {
				gridVNRE.addRow();
			});
			gridVNRE.delRowEvent(function() {
				if ((gridVNRE.jsonToArray(gridVNRE.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNRE.delRow();
			});

			gridVNRE.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch(celname) {
					case 'ZIP_CD':

						var url = '/common/code/BADV_020/view';
						var param = {
							callBackFunction : "setZipCodeVNRE",
							modalYn : true,
							rowId : rowid
						};
						//everPopup.openModalPopup(url, 700, 600, param, "searchZip");
						everPopup.jusoPop(url, param);

						break;
				}
			});

			gridVNRE.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
				switch(celname) {
					case 'VENDOR_NM':
						var column = {'VENDOR_NM': 'VENDOR_NM'};

						if(valid.equalColValid(gridVNRE, column)) {
							return;
						}
						break;

					case 'IRS_NUM':
						checkValidationIrsNo(value);
						break;
				}
			});

			// 우측 타이틀 적용 - [단위 : 비율]
			$('#form18 div.e-panel-button').attr('style', 'right: -30px; width: 100px; margin-top: -4px;').text("${BBV_010_0012}");

			gridVNCA.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }VNEQ",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridVNCA.addRowEvent(function() {
				gridVNCA.addRow();
			});
			gridVNCA.delRowEvent(function() {
				if ((gridVNCA.jsonToArray(gridVNCA.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridVNCA.delRow();
			});

			gridVNCA.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
				switch(celname) {
					case 'DEP_YEAR':
						var column = {'DEP_YEAR': 'DEP_YEAR'};

						if(valid.equalColValid(gridVNCA, column)) {
							return;
						}
						break;
				}
			});

			// 우측 타이틀 적용 - [주간 10Hr 기준]
			$('#form13 div.e-panel-button').attr('style', 'right: -8px; width: 100px; margin-top: -4px;').text("${BBV_010_0007}");

			gridSGVN.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }SGVN",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
					,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			gridSGVN.addRowEvent(function() {
				gridSGVN.addRow();
			});

			gridSGVN.delRowEvent(function() {
				if ((gridSGVN.jsonToArray(gridSGVN.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				gridSGVN.delRow();
			});

			gridSGVN.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch(celname) {
					case 'SG_NM4':
						var param = {
							'detailView' : false,
							'popupFlag'  : true,
							'callBackFunction': 'selectItemClass',
							'rowId': rowid

						};

						everPopup.openCommonPopup(param, 'SP0041');

						break;
				}
			});

			if ('${param.openType}' != null && '${param.openType}' != 'CS') {
				/*
				 if ('${ses.userType}' != 'S') {
				 EVF.C('pnl2').setVisible(false);
				 }
				 */

				if ('${ses.userType}' == 'B' && EVF.C("VENDOR_CD").getValue() != "") {
					//EVF.C('VENDOR_NM').setDisabled(true);
					//EVF.C('VENDOR_NM_ENG').setDisabled(true);
					//EVF.C('CEO_USER_NM').setDisabled(true);
					//EVF.C('CEO_USER_NM_ENG').setDisabled(true);
					EVF.C('IRS_NUM').setDisabled(true);
					EVF.C('IRS_NUM1').setDisabled(true);
					EVF.C('IRS_NUM2').setDisabled(true);
					EVF.C('IRS_NUM3').setDisabled(true);
					//EVF.C('COMPANY_REG_NUM').setDisabled(true);
					//EVF.C('COMPANY_REG_NUM1').setDisabled(true);
					//EVF.C('COMPANY_REG_NUM2').setDisabled(true);
				}
			}
			var regionDatas = ${regionValueList};
			for (k = 0; k < regionDatas.length; k++) {
				if (regionDatas[k].VALUE == "1") {
					EVF.C("REGION_" + regionDatas[k].CODE).setChecked("true");
				}
			}

			if('${ses.userType}' == 'B') {
				var dealTypeDatas = ${dealTypeValueList};
				for (var i = 0; i < dealTypeDatas.length; i++) {
					if (dealTypeDatas[i].VALUE == "1") {
						EVF.C("DEAL_TYPE_" + dealTypeDatas[i].CODE).setChecked("true");
					}
				}
			}
			if('${param.detailView}' == 'true') {
				EVF.C('IRS_NUM1').setDisabled(true);
				EVF.C('IRS_NUM2').setDisabled(true);
				EVF.C('IRS_NUM3').setDisabled(true);
				//EVF.C('COUNSEL_REQ_TEXT').setDisabled(true);
			}
			if ('${param.openType}' != null && '${param.openType}' != 'CS' && '${ses.userType}' == 'S') {
				if ('${param.CS_TYPE}' == 'VN') {
					EVF.C('doReset').setVisible(false);
					//EVF.C('pnl2').setVisible(false);
				} else if ('${param.CS_TYPE}' == 'CS') {
					EVF.C('pnl1').setVisible(false);
				}
			}
			if ('${param.openType}' != null && '${param.openType}' == 'CS') {
				self.window.scroll(1,1);
			}

			// gridVNSK, gridVNPL, gridVNPS, gridVNFI Grid pager Style

			$('#gridVNSK_pager_left').removeAttr('style');
			$('#gridVNPL_pager_left').removeAttr('style');
			$('#gridVNPS_pager_left').removeAttr('style');
			$('#gridVNFI_pager_left').removeAttr('style');


			if ('${ses.userType}' == 'S') {
				EVF.C('DEAL_SQ_CD').removeOption('3'); // 고객
				EVF.C('DEAL_SQ_CD').removeOption('4'); // 관계사
			}

			// 거래구분 체크 여부에 따른 거래차수 셋팅
			dealFlagCheck();

			// 협력회사구분 셋팅
			vendorTypeCheck();

			// 사업자구분 셋팅
			doCountryChange();
		}

		$(document.body).ready(function() {
			$('#e-tabs').height(($('.ui-layout-center').height() - 30)).tabs({
				activate : function(event, ui) {
					<%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
					$(window).trigger('resize');
				}
			});
			$('#e-tabs').tabs('option', 'active', 0);
			//getContentTab('2');

			$('#e-tabs-main').height(($('.ui-layout-center').height() - 30)).tabs({
				activate : function(event, ui) {
					<%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
					$(window).trigger('resize');
				}
			});
			$('#e-tabs-main').tabs('option', 'active', 0);
			//getContentTab('2');
		});

		function getContentTab(uu) {
			if (uu == '1') {
				window.scrollbars = true;
			}
			if (uu == '2') {
				window.scrollbars = true;

				// ie8 Tab 로딩 시 첫번째 화면만 인식하기 때문에 다른 Tab 화면은 refresh 해줘야 한다.
				// setTimeout을 주는 이유는 명령어가 화면 로딩이 끝난 후 적용되기 때문...
				setTimeout(function() {
					EVF.C('CEO_ATT_FILE_NUM').getInstance().refresh();
				}, 1000);
			}
			if (uu == '3') {
				window.scrollbars = true;
			}
			if (uu == '4') {
				window.scrollbars = true;
			}
			if (uu == '5') {
				window.scrollbars = true;
			}
		}

		/*function fileAttachPopupCallbackVNFI(gridRowId, fileId, fileCount) {
		 gridVNFI.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
		 gridVNFI.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
		 }*/

		function fileAttachPopupCallbackVNEQ(gridRowId, fileId, fileCount) {
			gridVNEQ.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
			gridVNEQ.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
		}

		function fileAttachPopupCallbackVNPI(gridRowId, fileId, fileCount) {
			gridVNPI.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
			gridVNPI.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
		}

		function fileAttachPopupCallbackSSRS(gridRowId, fileId, fileCount) {
			gridSSRS.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
			gridSSRS.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
		}

		function setZipCodeVNPL(zipcd) {
			if (zipcd.ZIP_CD != "") {
				gridVNPL.setCellValue(zipcd.rowId, "ZIP_CD", zipcd.ZIP_CD);
				gridVNPL.setCellValue(zipcd.rowId, "ZIP_CD_5", zipcd.ZIP_CD_5);
				gridVNPL.setCellValue(zipcd.rowId, "ADDRESS", zipcd.ADDR);
			}
		}

		function setZipCodeVNRE(zipcd) {
			if (zipcd.ZIP_CD != "") {
				gridVNRE.setCellValue(zipcd.rowId, "ZIP_CD", zipcd.ZIP_CD);
				gridVNRE.setCellValue(zipcd.rowId, "ZIP_CD_5", zipcd.ZIP_CD_5);
				gridVNRE.setCellValue(zipcd.rowId, "ADDRESS", zipcd.ADDR);
			}
		}

		function selectItemClass(data){


			gridSGVN.setCellValue(data.rowId, "SG_NM1" ,data.ITEM_CLS_NM1 );
			gridSGVN.setCellValue(data.rowId, "SG_NM2" ,data.ITEM_CLS_NM2 );
			gridSGVN.setCellValue(data.rowId, "SG_NM3" ,data.ITEM_CLS_NM3 );
			gridSGVN.setCellValue(data.rowId, "SG_NM4" ,data.ITEM_CLS_NM4 );
			gridSGVN.setCellValue(data.rowId, "SG_NUM" ,data.SG_NUM );

		}
		/*
		 function doSelectVNCS() {
		 var store = new EVF.Store();
		 store.setGrid([ gridVNCS ]);
		 store.load(baseUrl + 'BBV_010/getDataOfVNCS', function() {

		 if ('${param.counselReqNum}' != null && '${param.counselReqNum}' != '') {
		 var gridCSData = gridVNCS.getAllRowValue();
		 for ( var idx in gridCSData) {
		 var rowData = gridCSData[idx];

		 if (rowData['COUNSEL_REQ_NUM'] == '${param.counselReqNum}') {
		 setCsInfomation(idx);
		 break;
		 }
		 }

		 }
		 });
		 }
		 */
		function doSelectAllGrid() {
			var store = new EVF.Store();
			store.setGrid([ gridVNCP, gridVNTR, gridVNRS, gridSSRS, gridSGVN, gridVNSK, gridVNPL, gridVNPS, gridVNFI, gridVNEQ, gridVNPI, gridVNCB, gridVNRE, gridVNCA]);
			store.load(baseUrl + 'BBV_010/getDataOfGrid', function() {
				gridVNCP.checkAll(true);
				gridVNTR.checkAll(true);
				gridVNRS.checkAll(true);
				gridSSRS.checkAll(true);
				gridSGVN.checkAll(true);
				gridVNSK.checkAll(true);
				gridVNPL.checkAll(true);
				gridVNPS.checkAll(true);
				gridVNFI.checkAll(true);
				gridVNEQ.checkAll(true);
				gridVNPI.checkAll(true);
				gridVNCB.checkAll(true);
				gridVNRE.checkAll(true);
				gridVNCA.checkAll(true);
			});
		}

		function doReset() {
			//location.href = "/eversrm/master/vendor/BBV_010/view";
			EVF.C("form").iterator(function() {
				EVF.C(this.getID()).setValue('');
			});
		}

		function doSave() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

			EVF.C('IRS_NUM').setValue(EVF.C('IRS_NUM1').getValue() + EVF.C('IRS_NUM2').getValue() + EVF.C('IRS_NUM3').getValue());
			EVF.C('COMPANY_REG_NUM').setValue(EVF.C('COMPANY_REG_NUM1').getValue() + EVF.C('COMPANY_REG_NUM2').getValue());
			EVF.C('ZIP_CD').setValue(EVF.C('ZIP_CD1').getValue() + EVF.C('ZIP_CD2').getValue());

			if (EVF.C('COUNTRY_CD').getValue() != 'KR') {
				EVF.C('SHIPPER_TYPE').setValue('O');
			}

			// Domestic
			if (EVF.C("SHIPPER_TYPE").getValue() == "D" && EVF.C('COUNTRY_CD').getValue() == "KR") {
				if (EVF.C('IRS_NUM1').getValue() == "" || EVF.C('IRS_NUM2').getValue() == "" || EVF.C('IRS_NUM3').getValue() == "") {
					alert("${BBV_010_IRS_NUM_INVALID }");
					return;
				}
			}

			// 거래가능 플랜트 1개 이상 선택
			if (EVF.C('REGION_CD').getValue() == '') {
				alert('${BBV_010_0014}'); // 거래가능 플랜트는 최소1개 이상 선택하시기 바랍니다.

				var id = 'form > tbody > tr:eq(14) > td:eq(1)';

				formUtil.animate(id, 'form');

				return;
			}

			// 경쟁력 Validation
			if (EVF.C("QUALITY").getValue() != '' || EVF.C("QUALITY_DATE").getValue() != '') {
				EVF.C("QUALITY").setRequired(true);
				EVF.C("QUALITY_DATE").setRequired(true);
			}

			if (EVF.C("ENVIRONMENT").getValue() != '' || EVF.C("ENVIRONMENT_DATE").getValue() != '') {
				EVF.C("ENVIRONMENT").setRequired(true);
				EVF.C("ENVIRONMENT_DATE").setRequired(true);
			}

			if (EVF.C("SQ").getValue() != '' || EVF.C("SQ_DATE").getValue() != '') {
				EVF.C("SQ").setRequired(true);
				EVF.C("SQ_DATE").setRequired(true);
			}

			if (EVF.C("MAIN_BANK").getValue() != '' || EVF.C("MAIN_BANK_DATE").getValue() != '') {
				EVF.C("MAIN_BANK").setRequired(true);
				EVF.C("MAIN_BANK_DATE").setRequired(true);
			}


			if('${_gridType}' == 'RG') {

				// 담당자 정보 체크
				if ((gridVNCP.jsonToArray(gridVNCP.getSelRowId()).value).length == 0) {
					alert("${BBV_010_0013}"); // 담당자정보는 반드시 입력하시기 바랍니다.
					return;
				} else {
					if (!gridVNCP.validate().flag) {
						return alert("${BBV_010_0013}"); // 담당자정보는 반드시 입력하시기 바랍니다.
					}
				}

				if (!gridVNTR.validate().flag) {
					alert("${BBV_010_AA004}");
					return;
				}
				if (!gridVNRS.validate().flag) {
					alert("${BBV_010_AA003}");
					return;
				}
				if (!gridSSRS.validate().flag) {
					alert("${BBV_010_AA002}");
					return;
				}

				if (!gridSGVN.validate().flag) {
					alert("${BBV_010_AA001}");
					return;
				}


			} else {

				// 담당자 정보 체크
				if ((gridVNCP.jsonToArray(gridVNCP.getSelRowId()).value).length == 0) {
					alert("${BBV_010_0013}"); // 담당자정보는 반드시 입력하시기 바랍니다.
					return;
				} else {
					if (!gridVNCP.validate().flag) {
						return alert("${BBV_010_0013}"); // 담당자정보는 반드시 입력하시기 바랍니다.
					}
				}

				if (!gridVNTR.validate().flag) {
					alert("${BBV_010_AA004}");
					return;
				}
				if (!gridVNRS.validate().flag) {
					alert("${BBV_010_AA003}");
					return;
				}
				if (!gridSSRS.validate().flag) {
					alert("${BBV_010_AA002}");
					return;
				}

				if (!gridSGVN.validate().flag) {
					alert("${BBV_010_AA001}");
					return;
				}

			}

			var vendorCd = EVF.C("VENDOR_CD").getValue();

			/*
			 //상담요청정보 수동체크
			 var scProgressCd = EVF.C("SC_PROGRESS_CD").getValue();
			 var counselReqNum = EVF.C("COUNSEL_REQ_NUM").getValue();
			 var subject = EVF.C("SUBJECT").getValue();
			 if (scProgressCd != "E") {
			 if ((vendorCd == "") || (scProgressCd == "P") || (counselReqNum == "" && subject != "")) {
			 if (EVF.C("COUNSEL_REQ_CD").getValue() == "" || EVF.C("COUNSEL_REQ_TEXT").getValue() == "" || EVF.C("REQ_USER_NM").getValue() == "" || EVF.C("REQ_DEPT_NM").getValue() == "" || EVF.C("REQ_DUTY_NM").getValue() == "" || EVF.C("REQ_EMAIL").getValue() == "" || EVF.C("REQ_TEL_NUM").getValue() == ""
			 || EVF.C("REQ_CELL_NUM").getValue() == "") {
			 alert("${BBV_010_counsel_enter_info }");
			 return;
			 }
			 }
			 }
			 */

			if (vendorCd == "") {
				if ((gridVNCP.jsonToArray(gridVNCP.getSelRowId()).value).length == 0) {
					alert("${BBV_010_sales_pic_info }" + " ${msg.M0004}");
					return;
				}
			}

			if (EVF.C("GROUP_COMPANY_DEAL_FLAG").getValue() == "1") {
				if ((gridSSRS.jsonToArray(gridSSRS.getSelRowId()).value).length == 0) {
					alert("${BBV_010_ss_customer_info }" + " ${msg.M0004}");
					return;
				}
			}

			var selRowId = gridVNTR.jsonToArray(gridVNTR.getSelRowId()).value;

			for (var i = 0; i < selRowId.length; i++) {
				if (gridVNTR.getCellValue(selRowId[i], "VALID_FROM_DATE") > gridVNTR.getCellValue(selRowId[i], "VALID_TO_DATE")) {
					alert("${BBV_010_credit_rating_info }" + " Invalid From Date/To Date.");
					return;
				}
			}

			// 거래구분 체크박스 제어(NORMAL_PURCHASE_FLAG, ITEM_PURCHASE_FLAG)
			// if (EVF.C("NORMAL_PURCHASE_FLAG").setChecked(true))

			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}
			/*
			 if (EVF.C("SALES_AMT").getValue() == "" || EVF.C("SALES_AMT").getValue() == "0") {
			 alert("${BBV_010_sales_amt_required}");
			 return;
			 }
			 */
			if (EVF.C("portalType").getValue() == "NEW") {
				var screenFlag = "${screeningFlag }";
				var url = "/session/viewContents/view";
				if (screenFlag == "true") {
					var param = {
						realUrl : "/eversrm/srm/screening/vendorRegScreeningMgt/SRM_170/view",
						gateCd : '${gateCd}',
						langCd : '${langCd}',
						callBackFunction : 'getScreenInfo',
						VENDOR_CD : EVF.C('VENDOR_CD').getValue(),
						detailView : false
					};
					everPopup.openModalPopup(url, 1000, 700, param, "vendorRegScreeningMgt");
				} else {
					var param = {
						realUrl : "/eversrm/main/MSI_070/view",
						gateCd : '${gateCd}',
						langCd : '${langCd}',
						callBackFunction : 'getUserInfo',
						detailView : false
					};
					everPopup.openModalPopup(url, 600, 500, param, "userInfoReg");
				}

			} else {
				_save();
			}
		}

		function getUserInfo(userData, screenData, basicData) {
			EVF.C('userParam').setValue(userData);
			EVF.C('screenParam').setValue(screenData);
			EVF.C('basicParam').setValue(basicData);
			_save();
		}

		function _save() {
			if (EVF.C("SHIPPER_TYPE").getValue() == "D") {
				if (!checkValidationIrsNo(EVF.C("IRS_NUM").getValue())) {
					alert("${BBV_010_IRS_NUM_INVALID}");
					return;
				}
			}

			var store = new EVF.Store();
			if (!store.validate())
				return;

			store.setGrid([ gridVNCP, gridVNTR, gridVNRS, gridSSRS, gridSGVN, gridVNSK, gridVNPL, gridVNPS, gridVNFI, gridVNEQ, gridVNPI, gridVNCB, gridVNRE, gridVNCA ]);
			store.getGridData(gridVNCP, 'sel');
			store.getGridData(gridVNTR, 'sel');
			store.getGridData(gridVNRS, 'sel');
			store.getGridData(gridSSRS, 'sel');
			store.getGridData(gridSGVN, 'sel');
			store.getGridData(gridVNSK, 'sel');
			store.getGridData(gridVNPL, 'sel');
			store.getGridData(gridVNPS, 'sel');
			store.getGridData(gridVNFI, 'sel');
			store.getGridData(gridVNEQ, 'sel');
			store.getGridData(gridVNPI, 'sel');
			store.getGridData(gridVNCB, 'sel');
			store.getGridData(gridVNRE, 'sel');
			store.getGridData(gridVNCA, 'sel');

			var confMsg = '${msg.M0011}';

			if (EVF.C("VENDOR_CD").getValue() != "") {
				confMsg = '${msg.M0021}';
			}

			if (confirm(confMsg)) {
				store.doFileUpload(function() {
					store.load(baseUrl + 'BBV_010/doSave', function() {
	                	EVF.C('TRANSACTION_FLAG').setValue('Y');

						alert(this.getResponseMessage());

						if (EVF.C("portalType").getValue() == "NEW" || EVF.C("portalType").getValue() == "CHANGE") {
							window.close();
							return;
						}

						if (opener) {
							opener.doSearch();
							doClose();
						} else if (parent.doSearch != undefined) {
							parent.doSearch();
							doClose();
						} else {
							if ('${param.CS_TYPE}' == 'VN') {
								location.href = baseUrl + 'BBV_010/view.so?SCREEN_ID=BBV_010&CS_TYPE=VN&VENDOR_CD=' + this.getParameter("paramCode");
							} else if ('${param.CS_TYPE}' == 'CS') {
								location.href = baseUrl + 'BBV_010/view.so?SCREEN_ID=BBV_010&CS_TYPE=CS&VENDOR_CD=' + this.getParameter("paramCode");
							} else {
								location.href = baseUrl + 'BBV_010/view.so?SCREEN_ID=BBV_010&VENDOR_CD=' + this.getParameter("paramCode");
							}
						}
					});
				});
			}
		}

		function checkValidationIrsNo(irsNum) {
			var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
			var tmpBizID, i, chkSum = 0, c2, remainder;
			var irsNum = everString.lrTrim(EVF.C("IRS_NUM").getValue());
			irsNum = irsNum.replace(/-/gi, '');

			for (i = 0; i <= 7; i++)
				chkSum += checkID[i] * irsNum.charAt(i);
			c2 = "0" + (checkID[8] * irsNum.charAt(8));
			c2 = c2.substring(c2.length - 2, c2.length);
			chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
			remainder = (10 - (chkSum % 10)) % 10;

			if (Math.floor(irsNum.charAt(9)) == remainder) {
				return true;
			} else {
				return false;
			}
		}

		function doClose() {

			if (opener) {
				window.open("", "_self");
				window.close();
			} else if (parent) {
				new EVF.ModalWindow().close(null);
				//formUtil.close();
			}
 		}

		function searchZipCd() {
			if (EVF.C("portalType").getValue() == "NEW") {
				var url = "/session/viewContents/view";
				var param = {
					realUrl : "/common/code/BADV_020/view",
					gateCd : '${gateCd}',
					langCd : '${langCd}',
					callBackFunction : "setZipCode",
					modalYn : true
				};
				//everPopup.openModalPopup(url, 700, 600, param, "searchZip");
				everPopup.jusoPop(url, param);
			} else {
				var url = '/common/code/BADV_020/view';
				var param = {
					callBackFunction : "setZipCode",
					modalYn : true
				};
				//		    	everPopup.openWindowPopup(url, 600, 550, param);
				//everPopup.openModalPopup(url, 700, 600, param, "searchZip");
				everPopup.jusoPop(url, param);
			}
		}
		function setZipCode(zipcd) {
			if (zipcd.ZIP_CD != "") {
				EVF.C("ZIP_CD1").setValue(zipcd.ZIP_CD.substring(0, 3));
				EVF.C("ZIP_CD2").setValue(zipcd.ZIP_CD.substring(3, 6));
				EVF.C("ZIP_CD_5").setValue(zipcd.ZIP_CD_5);
				EVF.C('ADDR').setValue(zipcd.ADDR1);
				EVF.C('ADDR_ETC').setValue(zipcd.ADDR2);
				document.getElementById('ADDR_ETC').focus();
			}
		}
		function searchVendorCd() {
			var param = {
				callBackFunction : "selectVendorCd"
			};
			everPopup.openCommonPopup(param, 'SP0013');
		}
		function selectVendorCd(dataJsonArray) {
			EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
			location.href = baseUrl + 'BBV_010/view.so?VENDOR_CD=' + EVF.C('VENDOR_CD').getValue();
		}
		function doDelete() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

			if (EVF.C('VENDOR_CD').getValue() == "") {
				alert("${msg.M0004}");
				return;
			}
			gridVNCP.checkAll(true);
			gridVNTR.checkAll(true);
			gridVNRS.checkAll(true);
			gridSSRS.checkAll(true);

			var store = new EVF.Store();

			store.setGrid([ gridVNCP ]);
			store.getGridData(gridVNCP, 'sel');

			store.setGrid([ gridVNTR ]);
			store.getGridData(gridVNTR, 'sel');

			store.setGrid([ gridVNRS ]);
			store.getGridData(gridVNRS, 'sel');

			store.setGrid([ gridSSRS ]);
			store.getGridData(gridSSRS, 'sel');

			if (confirm("${msg.M0013}")) {
				store.doFileUpload(function() {
					store.load(baseUrl + 'BBV_010/doDelete', function() {
	                	EVF.C('TRANSACTION_FLAG').setValue('Y');

						alert(this.getResponseMessage());

						if (EVF.C("portalType").getValue() == "NEW" || EVF.C("portalType").getValue() == "CHANGE") {
							window.close();
							return;
						}

						if (opener) {
							opener.doSearch();
							doClose();
						} else if (parent) {
							parent.doSearch();
							doClose();
						} else {
							location.href = baseUrl + 'BBV_010/view.so?SCREEN_ID=BBV_010';
						}
						//doClose();
					});
				});
			}

		}
		/*
		 function setCsInfomation(rowid) {
		 EVF.C("SUBJECT").setValue(gridVNCS.getCellValue(rowid, "SUBJECT"));
		 EVF.C("COUNSEL_REQ_CD").setValue(gridVNCS.getCellValue(rowid, "COUNSEL_REQ_CD"));
		 EVF.C("COUNSEL_REQ_TEXT").setValue(gridVNCS.getCellValue(rowid, "COUNSEL_REQ_TEXT"));
		 EVF.C("REQ_USER_NM").setValue(gridVNCS.getCellValue(rowid, "REQ_USER_NM"));
		 EVF.C("REQ_DEPT_NM").setValue(gridVNCS.getCellValue(rowid, "REQ_DEPT_NM"));
		 EVF.C("REQ_DUTY_NM").setValue(gridVNCS.getCellValue(rowid, "REQ_DUTY_NM"));
		 EVF.C("REQ_EMAIL").setValue(gridVNCS.getCellValue(rowid, "REQ_EMAIL"));
		 EVF.C("REQ_TEL_NUM").setValue(gridVNCS.getCellValue(rowid, "REQ_TEL_NUM"));
		 EVF.C("REQ_CELL_NUM").setValue(gridVNCS.getCellValue(rowid, "REQ_CELL_NUM"));
		 EVF.C("COUNSEL_REQ_NUM").setValue(gridVNCS.getCellValue(rowid, "COUNSEL_REQ_NUM"));
		 EVF.C("SC_PROGRESS_CD").setValue(gridVNCS.getCellValue(rowid, "PROGRESS_CD"));
		 }
		 */
		function doInsertVNCP() {
			gridVNCP.addRow();
		}

		function doDeleteVNCP() {
			if ((gridVNCP.jsonToArray(gridVNCP.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}
			gridVNCP.delRow();
		}

		function doInsertVNTR() {
			gridVNTR.addRow();
		}

		function doDeleteVNTR() {
			if ((gridVNTR.jsonToArray(gridVNTR.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}
			gridVNTR.delRow();
		}

		function doInsertSSRS() {
			gridSSRS.addRow();
		}

		function doDeleteSSRS() {
			if ((gridSSRS.jsonToArray(gridSSRS.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}
			gridSSRS.delRow();
		}

		function doInsertVNRS() {
			gridVNRS.addRow();
		}

		function doDeleteVNRS() {
			if ((gridVNRS.jsonToArray(gridVNRS.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}
			gridVNRS.delRow();
		}

		function vncpDataChange() {
			if (vncpFirstFlag == 0) return;
			if (gridVNCP.getRowCount() != 1) return;

			var srcId = this.getID();
			var srcValue = this.getValue();

			if (srcId == "REQ_USER_NM") {
				gridVNCP.setCellValue(0, 'USER_NM', srcValue);
			} else if (srcId == "REQ_DEPT_NM") {
				gridVNCP.setCellValue(0, 'DEPT_NM', srcValue);
			} else if (srcId == "REQ_DUTY_NM") {
				gridVNCP.setCellValue(0, 'DUTY_NM', srcValue);
			} else if (srcId == "REQ_EMAIL") {
				gridVNCP.setCellValue(0, 'EMAIL', srcValue);
			} else if (srcId == "REQ_TEL_NUM") {
				gridVNCP.setCellValue(0, 'TEL_NUM', srcValue);
			} else if (srcId == "REQ_CELL_NUM") {
				gridVNCP.setCellValue(0, 'CELL_NUM', srcValue);
			}
		}

		function doCountryChange() {
			if(EVF.C("COUNTRY_CD").getValue() != "KR") {
				EVF.C("ZIP_CD1").setDisabled(false);
				EVF.C("ZIP_CD2").setDisabled(false);
				EVF.C("ZIP_CD1").setRequired(false);
				EVF.C("ZIP_CD2").setRequired(false);
				EVF.C("IRS_NUM1").setRequired(false);
				EVF.C("IRS_NUM2").setRequired(false);
				EVF.C("IRS_NUM3").setRequired(false);
				EVF.C("ADDR").setDisabled(false);
				EVF.C("ADDR").setReadOnly(false);
			} else {
				EVF.C("ZIP_CD1").setDisabled(true);
				EVF.C("ZIP_CD2").setDisabled(true);
				EVF.C("ZIP_CD1").setRequired(true);
				EVF.C("ZIP_CD2").setRequired(true);
				EVF.C("IRS_NUM1").setRequired(true);
				EVF.C("IRS_NUM2").setRequired(true);
				EVF.C("IRS_NUM3").setRequired(true);
				EVF.C("ADDR").setDisabled(true);
				EVF.C("ADDR").setReadOnly(true);
			}
		}

		function doCheck() {
			console.log(EVF.C('NORMAL_PURCHASE_FLAG').getValue());
			console.log(EVF.C('ITEM_PURCHASE_FLAG').getValue());
		}

		function doSelVendor() {
			var param = {
				'detailView' : false,
				'popupFlag'  : true,
				'callBackFunction': 'multiSelVendor'
			};

			everPopup.openCommonPopup(param, 'MP0001');
		}

		function multiSelVendor(data) {

			var dataArr = [];

			for(idx in data) {
				var arr = {
					'SUB_VENDOR_CD': data[idx].SUB_VENDOR_CD,
					'SUB_VENDOR_NM': data[idx].SUB_VENDOR_NM,
					'CEO_USER_NM': data[idx].CEO_USER_NM
				};

				dataArr.push(arr);
			}

			var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridVNRE, "SUB_VENDOR_CD");

			gridVNRE.addRow(validData);
		}

		// 사업자번호 체크
		function checkValidationIrsNo(irsNum) {
			<!--         return true; -->
			var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
			var tmpBizID, i, chkSum = 0,
					c2, remander;
			var irsNum = everString.lrTrim(EVF.C("IRS_NUM").getValue());
			irsNum = irsNum.replace(/-/gi, '');

			for (i = 0; i <= 7; i++) chkSum += checkID[i] * irsNum.charAt(i);
			c2 = "0" + (checkID[8] * irsNum.charAt(8));
			c2 = c2.substring(c2.length - 2, c2.length);
			chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
			remander = (10 - (chkSum % 10)) % 10;

			if (Math.floor(irsNum.charAt(9)) == remander) {
				return true;
			} else {
				return false;
			}
		}

		// 거래차수 체크
		function dealFlagCheck() {
			// 일반구매 체크 시 거래차수 필수 제외
			if(EVF.C("ITEM_PURCHASE_FLAG").getValue() == "1") {
				EVF.C("DEAL_SQ_CD").setRequired(true);
			} else {
				if(EVF.C("NORMAL_PURCHASE_FLAG").getValue() == "1") {
					EVF.C("DEAL_SQ_CD").setRequired(false);
				} else {
					EVF.C("DEAL_SQ_CD").setRequired(false);
				}
			}
		}

		function vendorTypeCheck() {
			if(EVF.C('VENDOR_CD').getValue() == '') {
				EVF.C('VENDOR_TYPE').setValue('P');
				EVF.C('VENDOR_TYPE').setDisabled(true);
			} else {
				if('${param.detailView}' != 'true')
					EVF.C('VENDOR_TYPE').setDisabled(false);
			}
		}
	</script>

	<e:window id="BBV_010" onReady="init" initData="${initData}" title="${(param.CS_TYPE != null && param.CS_TYPE == 'VN') ? '협력회사정보변경' : screenName }" breadCrumbs="${breadCrumb }">
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<c:choose>
				<c:when test="${ses.userType == 'S'}">
					<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />
					<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
				</c:when>
				<c:otherwise>
					<c:choose>
						<c:when test="${not empty portalType}">
							<%--<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />--%>
							<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
							<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" />
						</c:when>
						<c:when test="${param.popupFlag != 'true'}">
							<c:choose>
								<c:when test="${fn:trim(param.VENDOR_CD) != ''}">
									<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />
									<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
									<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
								</c:when>
								<c:otherwise>
									<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />
									<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
								</c:otherwise>
							</c:choose>
						</c:when>
						<c:otherwise>
							<%--<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />--%>
							<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
							<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
							<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" />
						</c:otherwise>
					</c:choose>
				</c:otherwise>
			</c:choose>
		</e:buttonBar>
		<%--
            <e:panel id="pnl2" width="100%">
                <e:searchPanel id="form3" useTitleBar="true" title="${BBV_010_counsel_information }" labelWidth="${labelWidth}" width="100%" columnCount="2">
                    <e:inputHidden id="COUNSEL_REQ_NUM" name="COUNSEL_REQ_NUM" />
                    <e:inputHidden id="SC_PROGRESS_CD" name="SC_PROGRESS_CD" />
                    <e:inputHidden id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="D" />

                    <e:row>
                        <e:label for="SUBJECT" title="${form3_SUBJECT_N}" />
                        <e:field colSpan="3">
                            <e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form3_SUBJECT_M}" disabled="${form3_SUBJECT_D}" readOnly="${form3_SUBJECT_RO}" required="${form3_SUBJECT_R}" style="${imeMode}" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="COUNSEL_REQ_CD" title="${form3_COUNSEL_REQ_CD_N}" />
                        <e:field colSpan="3">
                            <e:select id="COUNSEL_REQ_CD" name="COUNSEL_REQ_CD" value="" options="${refItemCls1 }" width="${inputTextWidth}" disabled="${form3_COUNSEL_REQ_CD_D}" readOnly="${form3_COUNSEL_REQ_CD_RO}" required="${form3_COUNSEL_REQ_CD_R}" placeHolder="" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="COUNSEL_REQ_TEXT" title="${form3_COUNSEL_REQ_TEXT_N}" />
                        <e:field colSpan="3">
                            <e:textArea id="COUNSEL_REQ_TEXT" name="COUNSEL_REQ_TEXT" height="100" value="${form.COUNSEL_REQ_TEXT}" width="100%" maxLength="${form_COUNSEL_REQ_TEXT_M}" disabled="${form_COUNSEL_REQ_TEXT_D}" readOnly="${form_COUNSEL_REQ_TEXT_RO}" required="${form_COUNSEL_REQ_TEXT_R}" style="${imeMode}" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="REQ_USER_NM" title="${form3_REQ_USER_NM_N}" />
                        <e:field>
                            <e:inputText id="REQ_USER_NM" name="REQ_USER_NM" value="${form.REQ_USER_NM}" onKeyUp="vncpDataChange" width="100%" maxLength="${form3_REQ_USER_NM_M}" disabled="${form3_REQ_USER_NM_D}" readOnly="${form3_REQ_USER_NM_RO}" required="${form3_REQ_USER_NM_R}" style="${imeMode}" />
                        </e:field>
                        <e:label for="REQ_DEPT_NM" title="${form3_REQ_DEPT_NM_N}" />
                        <e:field>
                            <e:inputText id="REQ_DEPT_NM" name="REQ_DEPT_NM" value="${form.REQ_DEPT_NM}" onKeyUp="vncpDataChange" width="100%" maxLength="${form3_REQ_DEPT_NM_M}" disabled="${form3_REQ_DEPT_NM_D}" readOnly="${form3_REQ_DEPT_NM_RO}" required="${form3_REQ_DEPT_NM_R}" style="${imeMode}" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="REQ_DUTY_NM" title="${form3_REQ_DUTY_NM_N}" />
                        <e:field>
                            <e:inputText id="REQ_DUTY_NM" name="REQ_DUTY_NM" value="${form.REQ_DUTY_NM}" onKeyUp="vncpDataChange" width="100%" maxLength="${form3_REQ_DUTY_NM_M}" disabled="${form3_REQ_DUTY_NM_D}" readOnly="${form3_REQ_DUTY_NM_RO}" required="${form3_REQ_DUTY_NM_R}" style="${imeMode}" />
                        </e:field>
                        <e:label for="REQ_EMAIL" title="${form3_REQ_EMAIL_N}" />
                        <e:field>
                            <e:inputText id="REQ_EMAIL" name="REQ_EMAIL" value="${form.REQ_EMAIL}" onKeyUp="vncpDataChange" width="100%" maxLength="${form3_REQ_EMAIL_M}" disabled="${form3_REQ_EMAIL_D}" readOnly="${form3_REQ_EMAIL_RO}" required="${form3_REQ_EMAIL_R}" style='ime-mode:inactive' />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="REQ_TEL_NUM" title="${form3_REQ_TEL_NUM_N}" />
                        <e:field>
                            <e:inputText id="REQ_TEL_NUM" name="REQ_TEL_NUM" value="${form.REQ_TEL_NUM}" onKeyUp="vncpDataChange" width="100%" maxLength="${form3_REQ_TEL_NUM_M}" disabled="${form3_REQ_TEL_NUM_D}" readOnly="${form3_REQ_TEL_NUM_RO}" required="${form3_REQ_TEL_NUM_R}" style='ime-mode:inactive' />
                        </e:field>
                        <e:label for="REQ_CELL_NUM" title="${form3_REQ_CELL_NUM_N}" />
                        <e:field>
                            <e:inputText id="REQ_CELL_NUM" name="REQ_CELL_NUM" value="${form.REQ_CELL_NUM}" onKeyUp="vncpDataChange" width="100%" maxLength="${form3_REQ_CELL_NUM_M}" disabled="${form3_REQ_CELL_NUM_D}" readOnly="${form3_REQ_CELL_NUM_RO}" required="${form3_REQ_CELL_NUM_R}" style='ime-mode:inactive' />
                        </e:field>
                    </e:row>
                </e:searchPanel>

                <e:searchPanel id="form4" useTitleBar="true" title="${BBV_010_counsel_history }" labelWidth="${labelWidth}" width="100%">
                    <e:row>
                        <e:field>
                            <e:gridPanel gridType="${_gridType}" id="gridVNCS" name="gridVNCS" width="100%" height="${(param.CS_TYPE != null && param.CS_TYPE == 'CS') ? 'fit' : '160px' }" columnDef="${gridInfos.gridVNCS.gridColData}" />
                        </e:field>
                    </e:row>
                </e:searchPanel>
            </e:panel>
        --%>
		<div id="e-tabs-main" class="e-tabs" style="padding: 0 !important;">
		<ul>
			<li><a href="#ui-tabs-1-main" onclick="getContentTab('1');">${BBV_010_vendor_information }</a></li>
			<li><a href="#ui-tabs-2-main" onclick="getContentTab('2');">${BBV_010_business_general }</a></li>
			<li><a href="#ui-tabs-4-main" onclick="getContentTab('4');">${BBV_010_0008 }</a></li>
			<li><a href="#ui-tabs-3-main" onclick="getContentTab('3');">${BBV_010_equipments }</a></li>
		</ul>

		<div id="ui-tabs-1-main">
			<e:searchPanel id="form" useTitleBar="false" title="${BBV_010_vendor_information }" labelWidth="150" width="100%" columnCount="2">
		        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

				<e:inputHidden id="VENDOR_STATUS_CD" name="VENDOR_STATUS_CD" value="${form.VENDOR_STATUS_CD}" />
				<e:inputHidden id="DEAL_CLOSE_FLAG" name="DEAL_CLOSE_FLAG" value="1" />
				<e:row>
					<%--협력회사코드--%>
					<c:choose>
						<c:when test="${ses.userType == 'B' }">
							<c:choose>
								<c:when test="${param.popupFlag != 'true'}">
									<c:choose>
										<c:when test="${fn:trim(param.VENDOR_CD) != ''}">
											<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
											<e:field>
												<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="150px" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
											</e:field>
										</c:when>
										<c:otherwise>
											<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
											<e:field>
												<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="150px" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
											</e:field>
										</c:otherwise>
									</c:choose>
								</c:when>
								<c:otherwise>
									<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
									<e:field>
										<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="150px" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
									</e:field>
								</c:otherwise>
							</c:choose>
						</c:when>
						<c:otherwise>
							<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
							<e:field colSpan="3">
								<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="150px" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
							</e:field>
						</c:otherwise>
					</c:choose>
					<%--협력회사구분--%>
					<c:choose>
						<c:when test="${ses.userType == 'B' }">
							<e:label for="VENDOR_TYPE" title="${form_VENDOR_TYPE_N}" />
							<e:field>
								<e:select id="VENDOR_TYPE" name="VENDOR_TYPE" value="${form.VENDOR_TYPE}" options="${vendorType}" width="${inputTextWidth}" disabled="${form_VENDOR_TYPE_D}" readOnly="${form_VENDOR_TYPE_RO}" required="${form_VENDOR_TYPE_R}" placeHolder="" />
							</e:field>
						</c:when>
						<c:when test="${form != null && form.VENDOR_CD != null && form.VENDOR_CD != '' }">
							<e:inputHidden id="VENDOR_TYPE" name="VENDOR_TYPE" value="${form.VENDOR_TYPE}" />
						</c:when>
						<c:otherwise>
							<e:inputHidden id="VENDOR_TYPE" name="VENDOR_TYPE" value="P" />
						</c:otherwise>
					</c:choose>
				</e:row>
				<e:row>
					<%--거래구분--%>
					<e:label for="DEAL_FLAG" title="${BBV_010_DEAL_FLAG}"/>
					<e:field>
						<%--일반구매--%>
						<e:check id="NORMAL_PURCHASE_FLAG" name="NORMAL_PURCHASE_FLAG" value="1" disabled="${ses.userType eq 'B' ? false : false}" readOnly="${form_NORMAL_PURCHASE_FLAG_RO}" required="${form_NORMAL_PURCHASE_FLAG_R}" checked="${form.NORMAL_PURCHASE_FLAG eq '1' ? true : form.VENDOR_CD eq null ? true : false }" onClick="dealFlagCheck"/>
						<e:text> ${form_NORMAL_PURCHASE_FLAG_N}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </e:text>
						<%--부품구매--%>
						<e:check id="ITEM_PURCHASE_FLAG" name="ITEM_PURCHASE_FLAG" value="1" disabled="${ses.userType eq 'B' ? false : false}" readOnly="${form_ITEM_PURCHASE_FLAG_RO}" required="${form_ITEM_PURCHASE_FLAG_R}" checked="${form.ITEM_PURCHASE_FLAG eq '1' ? true : false}" onClick="dealFlagCheck"/>
						<e:text> ${form_ITEM_PURCHASE_FLAG_N} </e:text>
					</e:field>
					<%--거래차수--%>
					<e:label for="DEAL_SQ_CD" title="${form_DEAL_SQ_CD_N}"/>
					<e:field>
						<e:select id="DEAL_SQ_CD" name="DEAL_SQ_CD" value="${form.DEAL_SQ_CD}" options="${dealSqCdOptions}" width="${inputTextWidth}" disabled="${form_DEAL_SQ_CD_D}" readOnly="${form_DEAL_SQ_CD_RO}" required="${form_DEAL_SQ_CD_R}" placeHolder="" />
					</e:field>
				</e:row>
				<e:row>
					<%--협력회사명--%>
					<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
					<e:field>
						<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}" onChange="doHistory"/>
					</e:field>
					<%--대표자명--%>
					<e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}" />
					<e:field>
						<e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="${form.CEO_USER_NM}" width="100%" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" style="${imeMode}" />
					</e:field>
				</e:row>
				<e:row>
					<%--협력회사명(영문)--%>
					<e:label for="VENDOR_NM_ENG" title="${form_VENDOR_NM_ENG_N}" />
					<e:field>
						<e:inputText id="VENDOR_NM_ENG" name="VENDOR_NM_ENG" value="${form.VENDOR_NM_ENG}" width="100%" maxLength="${form_VENDOR_NM_ENG_M}" disabled="${form_VENDOR_NM_ENG_D}" readOnly="${form_VENDOR_NM_ENG_RO}" required="${form_VENDOR_NM_ENG_R}" style='ime-mode:inactive'/>
					</e:field>
					<%--대표자명(영문)--%>
					<e:label for="CEO_USER_NM_ENG" title="${form_CEO_USER_NM_ENG_N}" />
					<e:field>
						<e:inputText id="CEO_USER_NM_ENG" name="CEO_USER_NM_ENG" value="${form.CEO_USER_NM_ENG}" width="100%" maxLength="${form_CEO_USER_NM_ENG_M}" disabled="${form_CEO_USER_NM_ENG_D}" readOnly="${form_CEO_USER_NM_ENG_RO}" required="${form_CEO_USER_NM_ENG_R}" style='ime-mode:inactive'/>
					</e:field>
				</e:row>
				<e:row>
					<%--내/외자--%>
					<e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
					<e:field>
						<e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="${form.SHIPPER_TYPE}" options="${shipperTypeOptions}" width="${inputTextWidth}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" />
					</e:field>
					<%--등록형태--%>
					<e:label for="REG_TYPE" title="${form_REG_TYPE_N}" />
					<e:field>
						<e:select id="REG_TYPE" name="REG_TYPE" value="${form.REG_TYPE}" options="${regType }" width="${inputTextWidth}" disabled="${form_REG_TYPE_D}" readOnly="${form_REG_TYPE_RO}" required="${form_REG_TYPE_R}" placeHolder="" />
					</e:field>
				</e:row>
				<e:row>
					<%--사업자등록번호--%>
					<c:choose>
						<c:when test="${ses.userType == 'B'}">
							<e:label for="IRS_NUM" title="${form_IRS_NUM_N}" />
							<e:field>
								<e:inputText id="IRS_NUM1" name="IRS_NUM1" value="" width="40" maxLength="3" disabled="" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
								<e:text>-</e:text>
								<e:inputText id="IRS_NUM2" name="IRS_NUM2" value="" width="30" maxLength="2" disabled="" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
								<e:text>-</e:text>
								<e:inputText id="IRS_NUM3" name="IRS_NUM3" value="" width="50" maxLength="5" disabled="" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
							</e:field>
						</c:when>
						<c:otherwise>
							<e:label for="IRS_NUM" title="${form_IRS_NUM_N}" />
							<e:field>
								<e:inputText id="IRS_NUM1" name="IRS_NUM1" value="" width="40" maxLength="3" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" style='ime-mode:inactive' />
								<e:text>-</e:text>
								<e:inputText id="IRS_NUM2" name="IRS_NUM2" value="" width="30" maxLength="2" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" style='ime-mode:inactive' />
								<e:text>-</e:text>
								<e:inputText id="IRS_NUM3" name="IRS_NUM3" value="" width="50" maxLength="5" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" style='ime-mode:inactive' />
							</e:field>
						</c:otherwise>
					</c:choose>
					<%--Vaatz 코드--%>
					<e:label for="VAATZ_VENDOR_CD" title="${form_VAATZ_VENDOR_CD_N}"/>
					<e:field>
						<e:inputText id="VAATZ_VENDOR_CD" style="ime-mode:inactive" name="VAATZ_VENDOR_CD" value="${form.VAATZ_VENDOR_CD}" width="100%" maxLength="${form_VAATZ_VENDOR_CD_M}" disabled="${form_VAATZ_VENDOR_CD_D}" readOnly="${form_VAATZ_VENDOR_CD_RO}" required="${form_VAATZ_VENDOR_CD_R}"/>
					</e:field>
				</e:row>
				<e:row>
					<%--업태--%>
					<e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}" />
					<e:field>
						<e:inputText id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="${form.BUSINESS_TYPE}" width="100%" maxLength="${form_BUSINESS_TYPE_M}" disabled="${form_BUSINESS_TYPE_D}" readOnly="${form_BUSINESS_TYPE_RO}" required="${form_BUSINESS_TYPE_R}" style="${imeMode}" />
					</e:field>
					<%--법인등록번호--%>
					<e:label for="COMPANY_REG_NUM" title="${form_COMPANY_REG_NUM_N}" />
					<e:field>
						<e:inputText id="COMPANY_REG_NUM1" name="COMPANY_REG_NUM1" value="${form.COMPANY_REG_NUM}" width="60" maxLength="6" disabled="${form_COMPANY_REG_NUM_D}" readOnly="${form_COMPANY_REG_NUM_RO}" required="${form_COMPANY_REG_NUM_R}" style='ime-mode:inactive' />
						<e:text>&nbsp;&nbsp;</e:text>
						<e:inputText id="COMPANY_REG_NUM2" name="COMPANY_REG_NUM2" value="${form.COMPANY_REG_NUM}" width="60" maxLength="7" disabled="${form_COMPANY_REG_NUM_D}" readOnly="${form_COMPANY_REG_NUM_RO}" required="${form_COMPANY_REG_NUM_R}" style='ime-mode:inactive' />
					</e:field>
				</e:row>
				<e:row>
					<%--업종--%>
					<e:label for="INDUSTRY_TYPE" title="${form_INDUSTRY_TYPE_N}" />
					<e:field>
						<e:inputText id="INDUSTRY_TYPE" name="INDUSTRY_TYPE" value="${form.INDUSTRY_TYPE}" width="100%" maxLength="${form_INDUSTRY_TYPE_M}" disabled="${form_INDUSTRY_TYPE_D}" readOnly="${form_INDUSTRY_TYPE_RO}" required="${form_INDUSTRY_TYPE_R}" style="${imeMode}" />
					</e:field>
					<%--대표전화번호--%>
					<e:label for="REP_TEL_NUM" title="${form_REP_TEL_NUM_N}" />
					<e:field>
						<e:inputText id="REP_TEL_NUM" name="REP_TEL_NUM" value="${form.REP_TEL_NUM}" width="${inputTextWidth}" maxLength="${form_REP_TEL_NUM_M}" disabled="${form_REP_TEL_NUM_D}" readOnly="${form_REP_TEL_NUM_RO}" required="${form_REP_TEL_NUM_R}" style='ime-mode:inactive' />
						<e:text> / </e:text>
						<e:inputText id="REP_FAX_NUM" style="ime-mode:inactive" name="REP_FAX_NUM" value="${form.REP_FAX_NUM}" width="${inputTextWidth}" maxLength="${form_REP_FAX_NUM_M}" disabled="${form_REP_FAX_NUM_D}" readOnly="${form_REP_FAX_NUM_RO}" required="${form_REP_FAX_NUM_R}"/>
					</e:field>
				</e:row>
				<e:row>
					<%--대표 Email--%>
					<e:label for="REP_EMAIL" title="${form_REP_EMAIL_N}" />
					<e:field>
						<e:inputText id="REP_EMAIL" name="REP_EMAIL" value="${form.REP_EMAIL}" width="100%" maxLength="${form_REP_EMAIL_M}" disabled="${form_REP_EMAIL_D}" readOnly="${form_REP_EMAIL_RO}" required="${form_REP_EMAIL_R}" style='ime-mode:inactive' />
					</e:field>
					<%--설립일자--%>
					<e:label for="FOUNDATION_DATE" title="${form_FOUNDATION_DATE_N}" />
					<e:field>
						<e:inputDate id="FOUNDATION_DATE" name="FOUNDATION_DATE" value="${form.FOUNDATION_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_FOUNDATION_DATE_R}" disabled="${form_FOUNDATION_DATE_D}" readOnly="${form_FOUNDATION_DATE_RO}" />
					</e:field>
				</e:row>
				<e:row>
					<%--국가--%>
					<e:label for="COUNTRY_CD" title="${form_COUNTRY_CD_N}" />
					<e:field>
						<e:select id="COUNTRY_CD" name="COUNTRY_CD" value="${form.COUNTRY_CD}" options="${countryCode }" width="${inputTextWidth}" disabled="${form_COUNTRY_CD_D}" readOnly="${form_COUNTRY_CD_RO}" required="${form_COUNTRY_CD_R}" placeHolder="" onChange="doCountryChange"/>
					</e:field>
					<%--도시명--%>
					<e:label for="CITY_DESC" title="${form_CITY_DESC_N}" />
					<e:field>
						<e:inputText id="CITY_DESC" name="CITY_DESC" value="${form.CITY_DESC}" width="100%" maxLength="${form_CITY_DESC_M}" disabled="${form_CITY_DESC_D}" readOnly="${form_CITY_DESC_RO}" required="${form_CITY_DESC_R}" style="${imeMode}" />
					</e:field>
				</e:row>
				<e:row>
					<%--매출액--%>
					<e:label for="SALES_AMT" title="${form_SALES_AMT_N}" />
					<e:field>
						<e:inputNumber id='SALES_AMT' name="SALES_AMT" value='${form.SALES_AMT}' align='right' width='110' required='${form_SALES_AMT_R }' readOnly='${form_SALES_AMT_RO }' disabled='${form_SALES_AMT_D }' visible='${form_SALES_AMT_V }' decimalPlace="2" />
						<e:text>${BBV_010_sales_amt_unit}</e:text>
					</e:field>
					<%--동희그룹거래유무--%>
					<e:label for="GROUP_COMPANY_DEAL_FLAG" title="${form_GROUP_COMPANY_DEAL_FLAG_N}" />
					<e:field>
						<e:select id="GROUP_COMPANY_DEAL_FLAG" name="GROUP_COMPANY_DEAL_FLAG" value="${form.GROUP_COMPANY_DEAL_FLAG}" options="${refYN }" width="${inputTextWidth}" disabled="${form_GROUP_COMPANY_DEAL_FLAG_D}" readOnly="${form_GROUP_COMPANY_DEAL_FLAG_RO}" required="${form_GROUP_COMPANY_DEAL_FLAG_R}" placeHolder="" />
					</e:field>
				</e:row>
				<e:row>
					<%--취급품목--%>
					<e:label for="MAJOR_ITEM_TEXT" title="${form_MAJOR_ITEM_TEXT_N}" />
					<e:field colSpan="3">
						<e:inputText id="MAJOR_ITEM_TEXT" name="MAJOR_ITEM_TEXT" value="${form.MAJOR_ITEM_TEXT}" width="100%" maxLength="${form_MAJOR_ITEM_TEXT_M}" disabled="${form_MAJOR_ITEM_TEXT_D}" readOnly="${form_MAJOR_ITEM_TEXT_RO}" required="${form_MAJOR_ITEM_TEXT_R}" style="${imeMode}" />
					</e:field>
				</e:row>
				<e:row>
					<%--이전사업자번호--%>
					<e:label for="PREV_IRS_NO" title="${form_PREV_IRS_NO_N}"/>
					<e:field>
						<e:inputText id="PREV_IRS_NO1" name="PREV_IRS_NO1" value="" width="40" maxLength="3" disabled="${form_PREV_IRS_NO_D}" readOnly="${form_PREV_IRS_NO_RO}" required="${form_PREV_IRS_NO_R}" style='ime-mode:inactive' />
						<e:text>-</e:text>
						<e:inputText id="PREV_IRS_NO2" name="PREV_IRS_NO2" value="" width="30" maxLength="2" disabled="${form_PREV_IRS_NO_D}" readOnly="${form_PREV_IRS_NO_RO}" required="${form_PREV_IRS_NO_R}" style='ime-mode:inactive' />
						<e:text>-</e:text>
						<e:inputText id="PREV_IRS_NO3" name="PREV_IRS_NO3" value="" width="50" maxLength="5" disabled="${form_PREV_IRS_NO_D}" readOnly="${form_PREV_IRS_NO_RO}" required="${form_PREV_IRS_NO_R}" style='ime-mode:inactive' />
					</e:field>
					<%--Duns No--%>
					<e:label for="DUNS_NUM" title="${form_DUNS_NUM_N}"/>
					<e:field>
						<e:inputText id="DUNS_NUM" style="ime-mode:inactive" name="DUNS_NUM" value="${form.DUNS_NUM}" width="100%" maxLength="${form_DUNS_NUM_M}" disabled="${form_DUNS_NUM_D}" readOnly="${form_DUNS_NUM_RO}" required="${form_DUNS_NUM_R}"/>
					</e:field>
				</e:row>
				<e:row>
					<%--본사 주소--%>
					<e:label for="ZIP_CD" title="${form_ZIP_CD_N}" />
					<e:field colSpan="3">
						<e:inputText id="ZIP_CD1" name="ZIP_CD1" value="${form.ZIP_CD}" width="60px" maxLength="3" disabled="${form_ZIP_CD_D}" readOnly="${form_ZIP_CD_RO}" required="${form_ZIP_CD_R}" />
						<e:text>-</e:text>
						<%--<c:choose>
                            <c:when test="${param.popupFlag != 'true'}">
                                <c:choose>
                                    <c:when test="${param.VENDOR_CD != ''}">
                                        <e:search id="ZIP_CD2" name="ZIP_CD2" value="" width="80px" maxLength="3" onIconClick="${form_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_ZIP_CD_D}" readOnly="${form_ZIP_CD_RO}" required="${form_ZIP_CD_R}" />
                                    </c:when>
                                    <c:otherwise>
                                        <e:search id="ZIP_CD2" name="ZIP_CD2" value="" width="80px" maxLength="3" onIconClick="${form_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_ZIP_CD_D}" readOnly="${form_ZIP_CD_RO}" required="${form_ZIP_CD_R}" />
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <e:search id="ZIP_CD2" name="ZIP_CD2" value="" width="80px" maxLength="3" onIconClick="${form_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_ZIP_CD_D}" readOnly="${form_ZIP_CD_RO}" required="${form_ZIP_CD_R}" />
                            </c:otherwise>
                        </c:choose>--%>
						<e:search id="ZIP_CD2" name="ZIP_CD2" value="" width="80px" maxLength="3" onIconClick="${form_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_ZIP_CD_D}" readOnly="${form_ZIP_CD_RO}" required="${form_ZIP_CD_R}" />
						<e:text>&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
						<%--대지--%>
						<e:text>${form_LAND_SIZE_N}</e:text>
						<e:inputText id="LAND_SIZE" style="ime-mode:inactive" name="LAND_SIZE" value="${form.LAND_SIZE}" width="${inputTextWidth}" maxLength="${form_LAND_SIZE_M}" disabled="${form_LAND_SIZE_D}" readOnly="${form_LAND_SIZE_RO}" required="${form_LAND_SIZE_R}"/>
						<e:text>&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
						<%--건물--%>
						<e:text>${form_BUILDING_SIZE_N}</e:text>
						<e:inputText id="BUILDING_SIZE" style="ime-mode:inactive" name="BUILDING_SIZE" value="${form.BUILDING_SIZE}" width="${inputTextWidth}" maxLength="${form_BUILDING_SIZE_M}" disabled="${form_BUILDING_SIZE_D}" readOnly="${form_BUILDING_SIZE_RO}" required="${form_BUILDING_SIZE_R}"/>
						<e:text>&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
						<%--사업장형태(M219)--%>
						<e:text>${form_BUSINESS_FORM_N}</e:text>
						<e:select id="BUSINESS_FORM" name="BUSINESS_FORM" value="${form.BUSINESS_FORM}" options="${businessFormOptions}" width="${inputTextWidth}" disabled="${form_BUSINESS_FORM_D}" readOnly="${form_BUSINESS_FORM_RO}" required="${form_BUSINESS_FORM_R}" placeHolder="" />
						<e:br />
						<e:inputText id="ADDR" name="ADDR" value="${form.ADDR}" width="100%" maxLength="${form_ADDR_M}" disabled="${form_ADDR_D}" readOnly="${form_ADDR_RO}" required="${form_ADDR_R}" />
						<e:inputText id="ADDR_ETC" name="ADDR_ETC" value="${form.ADDR_ETC}" width="100%" maxLength="${form_ADDR_ETC_M}" disabled="${form_ADDR_ETC_D}" readOnly="${form_ADDR_ETC_RO}" required="${form_ADDR_ETC_R}" style="${imeMode}" />
						<e:inputHidden id="ZIP_CD_5" name="ZIP_CD_5" />
					</e:field>
				</e:row>
				<e:row>
					<%--<c:choose>
                        <c:when test="${ses.userType == 'B'}">
                            <e:row>--%>
					<%--거래가능 플랜트--%>
					<e:label for="REGION_CD" title="${form_REGION_CD_N}" />
					<e:field colSpan="3">
						<e:checkGroup disabled="${form_REGION_CD_D}" required="${form_REGION_CD_R}" id="REGION_CD" readOnly="${form_REGION_CD_RO}" name="REGION_CD">
							<c:forEach items="${regionList}" var="region">
								<%--<e:text>&nbsp;</e:text>--%>
								<e:check id="REGION_${region.CODE}" name="REGION_${region.CODE}" value="${region.CODE}" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" required="${form_REGION_CD_R}" />
								<e:text>${region.CODE_DESC}&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
							</c:forEach>
						</e:checkGroup>
					</e:field>
				<%--</e:row>
		                </c:when>
		                <c:otherwise>
		                    <c:forEach items="${regionList}" var="region">
		                        <e:inputHidden id="REGION_${region.CODE}" name="REGION_${region.CODE}" value="" />
		                    </c:forEach>
		                </c:otherwise>
		            </c:choose>--%>
				</e:row>
				<%--
                <e:row>
                    <c:choose>
                        <c:when test="${ses.userType == 'B'}">
                            <e:label for="DUNS_NUM" title="${form_DUNS_NUM_N}" />
                            <e:field colSpan="3">
                                <e:inputText id="DUNS_NUM" name="DUNS_NUM" value="${form.DUNS_NUM}" width="${inputTextWidth }" maxLength="${form_DUNS_NUM_M}" disabled="${form_DUNS_NUM_D}" readOnly="${form_DUNS_NUM_RO}" required="${form_DUNS_NUM_R}" />
                            </e:field>
                            <e:inputHidden id="VENDOR_STATUS_CD" name="VENDOR_STATUS_CD" value="${form.VENDOR_STATUS_CD}" />
                        </c:when>
                        <c:otherwise>
                            <e:label for="DUNS_NUM" title="${form_DUNS_NUM_N}" />
                            <e:field colSpan="3">
                                <e:inputText id="DUNS_NUM" name="DUNS_NUM" value="${form.DUNS_NUM}" width="40%" maxLength="${form_DUNS_NUM_M}" disabled="${form_DUNS_NUM_D}" readOnly="${form_DUNS_NUM_RO}" required="${form_DUNS_NUM_R}" style='ime-mode:inactive'/>
                            </e:field>
                            <e:inputHidden id="VENDOR_STATUS_CD" name="VENDOR_STATUS_CD" value="${form.VENDOR_STATUS_CD}" />
                        </c:otherwise>
                    </c:choose>
                </e:row>
                --%>
				<c:if test="${ses.userType eq 'B'}">
					<e:row>
						<%--계정그룹--%>
						<e:label for="ACCOUNT_GROUP_CD" title="${form_ACCOUNT_GROUP_CD_N}"/>
						<e:field>
							<e:select id="ACCOUNT_GROUP_CD" name="ACCOUNT_GROUP_CD" value="${form.ACCOUNT_GROUP_CD}" options="${accountGroupCdOptions}" width="${inputTextWidth}" disabled="${form_ACCOUNT_GROUP_CD_D}" readOnly="${form_ACCOUNT_GROUP_CD_RO}" required="${form_ACCOUNT_GROUP_CD_R}" placeHolder="" />
						</e:field>
						<%--정렬필드--%>
						<e:label for="SORT_COLUMN" title="${form_SORT_COLUMN_N}"/>
						<e:field>
							<e:inputText id="SORT_COLUMN" style="ime-mode:inactive" name="SORT_COLUMN" value="${form.SORT_COLUMN}" width="100%" maxLength="${form_SORT_COLUMN_M}" disabled="${form_SORT_COLUMN_D}" readOnly="${form_SORT_COLUMN_RO}" required="${form_SORT_COLUMN_R}"/>
						</e:field>
					</e:row>
				</c:if>
				<c:if test="${ses.userType eq 'B'}">
					<e:row>
						<%--지급조건--%>
						<e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
						<e:field colSpan="3">
							<e:select id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" options="${payTermsOptions}" width="200" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder="" />
						</e:field>
					</e:row>
				</c:if>
				<e:row>
					<%--은행--%>
					<e:label for="BANK_CD" title="${form_BANK_CD_N}" />
					<e:field>
						<e:select id="BANK_CD" name="BANK_CD" value="${form.BANK_CD}" options="${bankCode}" width="${inputTextWidth}" disabled="${form_BANK_CD_D}" readOnly="${form_BANK_CD_RO}" required="${form_BANK_CD_R}" placeHolder="" />
					</e:field>
					<%--계좌번호--%>
					<e:label for="BANK_ACCT_NUM" title="${form_BANK_ACCT_NUM_N}" />
					<e:field>
						<e:inputText id="BANK_ACCT_NUM" name="BANK_ACCT_NUM" value="${form.BANK_ACCT_NUM}" width="100%" maxLength="${form_BANK_ACCT_NUM_M}" disabled="${form_BANK_ACCT_NUM_D}" readOnly="${form_BANK_ACCT_NUM_RO}" required="${form_BANK_ACCT_NUM_R}" style='ime-mode:inactive' />
					</e:field>
				</e:row>
				<e:row>
					<%--파일첨부--%>
					<e:label for="fileAttach" title="${form_fileAttach_N}" />
					<e:field colSpan="3">
						<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
					</e:field>

					<e:inputHidden id="VENDOR_CD_ORI" name="VENDOR_CD_ORI" />
					<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" />
					<e:inputHidden id="GATE_CD" name="GATE_CD" value="${gateCd}" />
					<e:inputHidden id="IRS_NUM" name="IRS_NUM" />
					<e:inputHidden id="COMPANY_REG_NUM" name="COMPANY_REG_NUM" />
					<e:inputHidden id="ZIP_CD" name="ZIP_CD" />
					<e:inputHidden id="LANG_CD" name="LANG_CD" value="${langCd}" />
					<e:inputHidden id="portalType" name="portalType" value="${portalType}" />
					<e:inputHidden id="userParam" name="userParam" />
					<e:inputHidden id="screenParam" name="screenParam" />
					<e:inputHidden id="basicParam" name="basicParam" />
				</e:row>
				<c:if test="${ses.userType eq 'B'}">
					<%--거래업종--%>
					<e:row>
						<e:label for="DEAL_TYPE_CD" title="${form_DEAL_TYPE_CD_N}"/>
						<e:field colSpan="3">
							<e:checkGroup disabled="${form_DEAL_TYPE_CD_D}" required="${form_DEAL_TYPE_CD_R}" id="DEAL_TYPE_CD" readOnly="${form_DEAL_TYPE_CD_RO}" name="DEAL_TYPE_CD">
								<c:forEach items="${dealTypeList}" var="dealType" varStatus="idx">
									<e:check id="DEAL_TYPE_${dealType.CODE}" name="DEAL_TYPE_${dealType.CODE}" value="${dealType.CODE}" disabled="${form_DEAL_TYPE_CD_D}" readOnly="${form_DEAL_TYPE_CD_RO}" required="${form_DEAL_TYPE_CD_R}" />
									<e:text>${dealType.CODE_DESC}&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
									<c:set var="m" value="${idx.count mod 8}"/>
									<c:if test="${m eq 0}"><br><br></c:if>
								</c:forEach>
							</e:checkGroup>
						</e:field>
					</e:row>
					<e:row>
						<%--거래시작일자--%>
						<e:label for="DEAL_START_DATE" title="${form_DEAL_START_DATE_N}"/>
						<e:field>
							<e:inputDate id="DEAL_START_DATE" name="DEAL_START_DATE" value="${form.DEAL_START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_START_DATE_R}" disabled="${form_DEAL_START_DATE_D}" readOnly="${form_DEAL_START_DATE_RO}" />
						</e:field>
						<%--거래종결일자--%>
						<e:label for="DEAL_CLOSE_DATE" title="${form_DEAL_CLOSE_DATE_N}"/>
						<e:field>
							<e:inputDate id="DEAL_CLOSE_DATE" name="DEAL_CLOSE_DATE" value="${form.DEAL_CLOSE_DATE}" width="80" datePicker="true" required="${form_DEAL_CLOSE_DATE_R}" disabled="${form_DEAL_CLOSE_DATE_D}" readOnly="${form_DEAL_CLOSE_DATE_RO}" />
						</e:field>
					</e:row>
					<e:row>
						<%--거래종결자--%>
						<e:label for="DEAL_CLOSE_USER_ID" title="${form_DEAL_CLOSE_USER_ID_N}"/>
						<e:field>
							<e:inputText id="DEAL_CLOSE_USER_ID" style="ime-mode:inactive" name="DEAL_CLOSE_USER_ID" value="${form.DEAL_CLOSE_USER_ID}" width="100%" maxLength="${form_DEAL_CLOSE_USER_ID_M}" disabled="${form_DEAL_CLOSE_USER_ID_D}" readOnly="${form_DEAL_CLOSE_USER_ID_RO}" required="${form_DEAL_CLOSE_USER_ID_R}"/>
						</e:field>
						<%--거래종결사유--%>
						<e:label for="DEAL_CLOSE_RMK" title="${form_DEAL_CLOSE_RMK_N}"/>
						<e:field>
							<e:inputText id="DEAL_CLOSE_RMK" style="${imeMode}" name="DEAL_CLOSE_RMK" value="${form.DEAL_CLOSE_RMK}" width="100%" maxLength="${form_DEAL_CLOSE_RMK_M}" disabled="${form_DEAL_CLOSE_RMK_D}" readOnly="${form_DEAL_CLOSE_RMK_RO}" required="${form_DEAL_CLOSE_RMK_R}"/>
						</e:field>
					</e:row>
				</c:if>
			</e:searchPanel>

			<c:if test="${param.detailView != 'true'}">
				<e:panel id="pnl0_sub" width="100%">
					<br>
					<e:text style="color: blue; font-weight: bold">■ 아래의 해당 항목들에 대해서 각 항목 탭을 클릭하여 "행추가" 버튼을 클릭후 정보를 입력하시기 바랍니다. </e:text>
					<br>
				</e:panel>
			</c:if>

			<div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
				<ul>
						<%--
						<li><a href="#ui-tabs-1" onclick="getContentTab('1');">${BBV_010_bank_info }</a></li>
						 --%>
					<li><a href="#ui-tabs-2" onclick="getContentTab('2');">${BBV_010_sales_pic_info }</a></li>
					<li><a href="#ui-tabs-3" onclick="getContentTab('3');">${BBV_010_ss_customer_info }</a></li>
					<li><a href="#ui-tabs-5" onclick="getContentTab('5');">${BBV_010_credit_rating_info }</a></li>
					<li><a href="#ui-tabs-6" onclick="getContentTab('6');">${BBV_010_sourcing_group }</a></li>
				</ul>
				<e:panel id="pnl1_sub" width="100%">
					<e:inputHidden id="DEPOSITOR_NM" name="DEPOSITOR_NM" value="${form.DEPOSITOR_NM}" />
					<%--
                    <div id="ui-tabs-1">

                        <e:searchPanel id="form2" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" height="200px" width="100%" columnCount="2">
                            <e:row>
                                <e:label for="BANK_CD" title="${form_BANK_CD_N}" />
                                <e:field>
                                    <e:select id="BANK_CD" name="BANK_CD" value="${form.BANK_CD}" options="${bankCode}" width="${inputTextWidth}" disabled="${form_BANK_CD_D}" readOnly="${form_BANK_CD_RO}" required="${form_BANK_CD_R}" placeHolder="" />
                                </e:field>
                                <e:label for="DEPOSITOR_NM" title="${form_DEPOSITOR_NM_N}" />
                                <e:field>
                                    <e:inputText id="DEPOSITOR_NM" name="DEPOSITOR_NM" value="${form.DEPOSITOR_NM}" width="100%" maxLength="${form_DEPOSITOR_NM_M}" disabled="${form_DEPOSITOR_NM_D}" readOnly="${form_DEPOSITOR_NM_RO}" required="${form_DEPOSITOR_NM_R}" style="${imeMode}" />
                                </e:field>
                            </e:row>
                            <e:row>
                                <e:label for="BANK_ACCT_NUM" title="${form_BANK_ACCT_NUM_N}" />
                                <e:field>
                                    <e:inputText id="BANK_ACCT_NUM" name="BANK_ACCT_NUM" value="${form.BANK_ACCT_NUM}" width="100%" maxLength="${form_BANK_ACCT_NUM_M}" disabled="${form_BANK_ACCT_NUM_D}" readOnly="${form_BANK_ACCT_NUM_RO}" required="${form_BANK_ACCT_NUM_R}" style='ime-mode:inactive' />
                                </e:field>
                                <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}" />
                                <e:field>
                                    <e:select id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" options="${payTerms}" width="${inputTextWidth}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder="" />
                                </e:field>
                            </e:row>
                        </e:searchPanel>
                        <br>
                        <br>
                        <br>
                        <br>
                        <br>

                    </div>
                    --%>
					<%--영업담당자정보--%>
					<div id="ui-tabs-2">
						<e:buttonBar id="buttonBarVNCP" align="right" width="100%">
							<e:button id="doInsertVNCP" name="doInsertVNCP" label="${doInsertVNCP_N}" onClick="doInsertVNCP" disabled="${doInsertVNCP_D}" visible="${doInsertVNCP_V}" />
							<e:button id="doDeleteVNCP" name="doDeleteVNCP" label="${doDeleteVNCP_N}" onClick="doDeleteVNCP" disabled="${doDeleteVNCP_D}" visible="${doDeleteVNCP_V}" />
						</e:buttonBar>
						<e:gridPanel gridType="${_gridType}" id="gridVNCP" name="gridVNCP" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNCP.gridColData}" />
					</div>
					<%--동희그룹사납품정보--%>
					<div id="ui-tabs-3">
						<e:buttonBar id="buttonBarSSRS" align="right" width="100%">
							<e:button id="doInsertSSRS" name="doInsertSSRS" label="${doInsertSSRS_N}" onClick="doInsertSSRS" disabled="${doInsertSSRS_D}" visible="${doInsertSSRS_V}" />
							<e:button id="doDeleteSSRS" name="doDeleteSSRS" label="${doDeleteSSRS_N}" onClick="doDeleteSSRS" disabled="${doDeleteSSRS_D}" visible="${doDeleteSSRS_V}" />
						</e:buttonBar>
						<e:gridPanel gridType="${_gridType}" id="gridSSRS" name="gridSSRS" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridSSRS.gridColData}" />
					</div>

					<%--신용평가정보--%>
					<div id="ui-tabs-5">
						<e:buttonBar id="buttonBarVNTR" align="right" width="100%">
							<e:button id="doInsertVNTR" name="doInsertVNTR" label="${doInsertVNTR_N}" onClick="doInsertVNTR" disabled="${doInsertVNTR_D}" visible="${doInsertVNTR_V}" />
							<e:button id="doDeleteVNTR" name="doDeleteVNTR" label="${doDeleteVNTR_N}" onClick="doDeleteVNTR" disabled="${doDeleteVNTR_D}" visible="${doDeleteVNTR_V}" />
						</e:buttonBar>
						<e:gridPanel gridType="${_gridType}" id="gridVNTR" name="gridVNTR" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNTR.gridColData}" />
					</div>
					<%--소싱그룹--%>
					<div id="ui-tabs-6">
						<e:gridPanel gridType="${_gridType}" id="gridSGVN" name="gridSGVN" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridSGVN.gridColData}" />
					</div>
				</e:panel>
			</div>
		</div>
		<div id="ui-tabs-2-main">
			<e:searchPanel id="form5" useTitleBar="false" title="" labelWidth="150" width="100%" columnCount="2">
				<e:row>
					<%--대표자 출생년도--%>
					<e:label for="CEO_BIRTH_YEAR" title="${form_CEO_BIRTH_YEAR_N}"/>
					<e:field>
						<e:select id="CEO_BIRTH_YEAR" name="CEO_BIRTH_YEAR" value="${form.CEO_BIRTH_YEAR}" options="${ceoBirthYearOptions}" width="${inputTextWidth}" disabled="${form_CEO_BIRTH_YEAR_D}" readOnly="${form_CEO_BIRTH_YEAR_RO}" required="${form_CEO_BIRTH_YEAR_R}" placeHolder="" />
					</e:field>
					<%--대표자 최종학교--%>
					<e:label for="CEO_LAST_SCHOOL" title="${form_CEO_LAST_SCHOOL_N}"/>
					<e:field>
						<e:inputText id="CEO_LAST_SCHOOL" style="ime-mode:auto" name="CEO_LAST_SCHOOL" value="${form.CEO_LAST_SCHOOL}" width="100%" maxLength="${form_CEO_LAST_SCHOOL_M}" disabled="${form_CEO_LAST_SCHOOL_D}" readOnly="${form_CEO_LAST_SCHOOL_RO}" required="${form_CEO_LAST_SCHOOL_R}"/>
					</e:field>
				</e:row>
				<e:row>
					<%--대표자 주요경력--%>
					<e:label for="CEO_MAJOR_CAREER" title="${form_CEO_MAJOR_CAREER_N}"/>
					<e:field colSpan="3">
						<e:inputText id="CEO_MAJOR_CAREER" style="ime-mode:auto" name="CEO_MAJOR_CAREER" value="${form.CEO_MAJOR_CAREER}" width="100%" maxLength="${form_CEO_MAJOR_CAREER_M}" disabled="${form_CEO_MAJOR_CAREER_D}" readOnly="${form_CEO_MAJOR_CAREER_RO}" required="${form_CEO_MAJOR_CAREER_R}"/>
					</e:field>
				</e:row>
				<e:row>
					<%--대표자 사진첨부--%>
					<e:label for="CEO_ATT_FILE_NUM" title="${form_CEO_ATT_FILE_NUM_N}" />
					<e:field colSpan="3">
						<e:fileManager id="CEO_ATT_FILE_NUM" name="CEO_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.CEO_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
					</e:field>
				</e:row>
				<e:row>
					<%--임원--%>
					<e:label for="EXECUTIVE_EMP_CNT" title="${form_EXECUTIVE_EMP_CNT_N}"/>
					<e:field>
						<e:inputNumber id="EXECUTIVE_EMP_CNT" name="EXECUTIVE_EMP_CNT" value="${form.EXECUTIVE_EMP_CNT}" maxValue="${form_EXECUTIVE_EMP_CNT_M}" decimalPlace="${form_EXECUTIVE_EMP_CNT_NF}" disabled="${form_EXECUTIVE_EMP_CNT_D}" readOnly="${form_EXECUTIVE_EMP_CNT_RO}" required="${form_EXECUTIVE_EMP_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
					<%--관리직--%>
					<e:label for="MANAGEMENT_EMP_CNT" title="${form_MANAGEMENT_EMP_CNT_N}"/>
					<e:field>
						<e:inputNumber id="MANAGEMENT_EMP_CNT" name="MANAGEMENT_EMP_CNT" value="${form.MANAGEMENT_EMP_CNT}" maxValue="${form_MANAGEMENT_EMP_CNT_M}" decimalPlace="${form_MANAGEMENT_EMP_CNT_NF}" disabled="${form_MANAGEMENT_EMP_CNT_D}" readOnly="${form_MANAGEMENT_EMP_CNT_RO}" required="${form_MANAGEMENT_EMP_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
				</e:row>
			</e:searchPanel>
			<e:searchPanel id="form10" useTitleBar="true" title="${BBV_010_production_emp}" labelWidth="150" width="100%" columnCount="2">
				<e:row>
					<%--내국인--%>
					<e:label for="LOCAL_EMP_CNT" title="${form_LOCAL_EMP_CNT_N}"/>
					<e:field>
						<e:inputNumber id="LOCAL_EMP_CNT" name="LOCAL_EMP_CNT" value="${form.LOCAL_EMP_CNT}" maxValue="${form_LOCAL_EMP_CNT_M}" decimalPlace="${form_LOCAL_EMP_CNT_NF}" disabled="${form_LOCAL_EMP_CNT_D}" readOnly="${form_LOCAL_EMP_CNT_RO}" required="${form_LOCAL_EMP_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
					<%--외국인--%>
					<e:label for="FOREIGNER_EMP_CNT" title="${form_FOREIGNER_EMP_CNT_N}"/>
					<e:field>
						<e:inputNumber id="FOREIGNER_EMP_CNT" name="FOREIGNER_EMP_CNT" value="${form.FOREIGNER_EMP_CNT}" maxValue="${form_FOREIGNER_EMP_CNT_M}" decimalPlace="${form_FOREIGNER_EMP_CNT_NF}" disabled="${form_FOREIGNER_EMP_CNT_D}" readOnly="${form_FOREIGNER_EMP_CNT_RO}" required="${form_FOREIGNER_EMP_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
				</e:row>
				<e:row>
					<%--하도급--%>
					<e:label for="SUBCONTRACT_EMP_CNT" title="${form_SUBCONTRACT_EMP_CNT_N}"/>
					<e:field>
						<e:inputNumber id="SUBCONTRACT_EMP_CNT" name="SUBCONTRACT_EMP_CNT" value="${form.SUBCONTRACT_EMP_CNT}" maxValue="${form_SUBCONTRACT_EMP_CNT_M}" decimalPlace="${form_SUBCONTRACT_EMP_CNT_NF}" disabled="${form_SUBCONTRACT_EMP_CNT_D}" readOnly="${form_SUBCONTRACT_EMP_CNT_RO}" required="${form_SUBCONTRACT_EMP_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
					<%--기타--%>
					<e:label for="OTHER_EMP_CNT" title="${form_OTHER_EMP_CNT_N}"/>
					<e:field>
						<e:inputNumber id="OTHER_EMP_CNT" name="OTHER_EMP_CNT" value="${form.OTHER_EMP_CNT}" maxValue="${form_OTHER_EMP_CNT_M}" decimalPlace="${form_OTHER_EMP_CNT_NF}" disabled="${form_OTHER_EMP_CNT_D}" readOnly="${form_OTHER_EMP_CNT_RO}" required="${form_OTHER_EMP_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
				</e:row>
				<e:row>
					<%--노조명--%>
					<e:label for="LABOR_UNION_NM" title="${form_LABOR_UNION_NM_N}"/>
					<e:field>
						<e:inputText id="LABOR_UNION_NM" style="${imeMode}" name="LABOR_UNION_NM" value="${form.LABOR_UNION_NM}" width="140" maxLength="${form_LABOR_UNION_NM_M}" disabled="${form_LABOR_UNION_NM_D}" readOnly="${form_LABOR_UNION_NM_RO}" required="${form_LABOR_UNION_NM_R}"/>
					</e:field>
					<%--노조인원--%>
					<e:label for="LABOR_UNION_CNT" title="${form_LABOR_UNION_CNT_N}"/>
					<e:field>
						<e:inputNumber id="LABOR_UNION_CNT" name="LABOR_UNION_CNT" value="${form.LABOR_UNION_CNT}" maxValue="${form_LABOR_UNION_CNT_M}" decimalPlace="${form_LABOR_UNION_CNT_NF}" disabled="${form_LABOR_UNION_CNT_D}" readOnly="${form_LABOR_UNION_CNT_RO}" required="${form_LABOR_UNION_CNT_R}" />
						<e:text>명</e:text>
					</e:field>
				</e:row>
				<e:row>
					<%--노조비고--%>
					<e:label for="LABOR_UNION_ETC" title="${form_LABOR_UNION_ETC_N}"/>
					<e:field colSpan="3">
						<e:inputText id="LABOR_UNION_ETC" style="ime-mode:auto" name="LABOR_UNION_ETC" value="${form.LABOR_UNION_ETC}" width="100%" maxLength="${form_LABOR_UNION_ETC_M}" disabled="${form_LABOR_UNION_ETC_D}" readOnly="${form_LABOR_UNION_ETC_RO}" required="${form_LABOR_UNION_ETC_R}"/>
					</e:field>
				</e:row>
				<e:row>
					<%--기타현황--%>
					<e:label for="OTHER_STATUS" title="${form_OTHER_STATUS_N}"/>
					<e:field colSpan="3">
						<e:textArea id="OTHER_STATUS" style="ime-mode:auto" name="OTHER_STATUS" height="100px" value="${form.OTHER_STATUS}" width="100%" maxLength="${form_OTHER_STATUS_M}" disabled="${form_OTHER_STATUS_D}" readOnly="${form_OTHER_STATUS_RO}" required="${form_OTHER_STATUS_R}" />
					</e:field>
				</e:row>
			</e:searchPanel>
				<%--지분현황--%>
			<e:searchPanel id="form6" useTitleBar="true" title="${BBV_010_equity_status}" labelWidth="150" width="100%">
				<tr><td><div><e:gridPanel gridType="${_gridType}" id="gridVNSK" name="gridVNSK" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNSK.gridColData}" /></div></td></tr>
			</e:searchPanel>
				<%--주요임원--%>
			<e:searchPanel id="form8" useTitleBar="true" title="${BBV_010_main_office}" labelWidth="150" width="100%">
				<tr><td><div><e:gridPanel gridType="${_gridType}" id="gridVNPS" name="gridVNPS" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNPS.gridColData}" /></div></td></tr>
			</e:searchPanel>
				<%--재무현황(백만원)--%>
			<e:searchPanel id="form9" useTitleBar="true" title="${BBV_010_financial_statements}" labelWidth="150" width="100%">
				<tr><td><div><e:gridPanel gridType="${_gridType}" id="gridVNFI" name="gridVNFI" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNFI.gridColData}" /></div></td></tr>
			</e:searchPanel>
				<%--경쟁력--%>
			<e:searchPanel id="form11" useTitleBar="true" title="${BBV_010_Competitiveness}" labelWidth="20%" width="100%">
				<e:row>
					<%--구분--%>
					<e:label for="DIVISION" title="${BBV_010_0002}" />
					<%--품질--%>
					<e:label for="QUALITY" title="${form_QUALITY_N}" />
					<%--환경--%>
					<e:label for="ENVIRONMENT" title="${form_ENVIRONMENT_N}" />
					<%--SQ--%>
					<e:label for="SQ" title="${form_SQ_N}" />
					<%--주거래은행--%>
					<e:label for="MAIN_BANK" title="${form_MAIN_BANK_N}" />
				</e:row>
				<e:row>
					<%--등급--%>
					<e:label for="RANK" title="${BBV_010_0003}" />
					<e:field>
						<e:inputText id="QUALITY" style="ime-mode:inactive" name="QUALITY" value="${form.QUALITY}" width="100%" maxLength="${form_QUALITY_M}" disabled="${form_QUALITY_D}" readOnly="${form_QUALITY_RO}" required="${form_QUALITY_R}" align="center"/>
					</e:field>
					<e:field>
						<e:inputText id="ENVIRONMENT" style="ime-mode:inactive" name="ENVIRONMENT" value="${form.ENVIRONMENT}" width="100%" maxLength="${form_ENVIRONMENT_M}" disabled="${form_ENVIRONMENT_D}" readOnly="${form_ENVIRONMENT_RO}" required="${form_ENVIRONMENT_R}" align="center"/>
					</e:field>
					<e:field>
						<e:inputText id="SQ" style="ime-mode:inactive" name="SQ" value="${form.SQ}" width="100%" maxLength="${form_SQ_M}" disabled="${form_SQ_D}" readOnly="${form_SQ_RO}" required="${form_SQ_R}" align="center"/>
					</e:field>
					<e:field>
						<e:inputText id="MAIN_BANK" style="ime-mode:inactive" name="MAIN_BANK" value="${form.MAIN_BANK}" width="100%" maxLength="${form_MAIN_BANK_M}" disabled="${form_MAIN_BANK_D}" readOnly="${form_MAIN_BANK_RO}" required="${form_MAIN_BANK_R}" align="center"/>
					</e:field>
				</e:row>
				<e:row>
					<%--인증일자--%>
					<e:label for="CERTIFICATION_DATE" title="${BBV_010_0004}" />
					<e:field>
						<e:inputDate id="QUALITY_DATE" name="QUALITY_DATE" value="${form.QUALITY_DATE}" width="${inputTextDate}" datePicker="true" required="${form_QUALITY_DATE_R}" disabled="${form_QUALITY_DATE_D}" readOnly="${form_QUALITY_DATE_RO}" />
					</e:field>
					<e:field>
						<e:inputDate id="ENVIRONMENT_DATE" name="ENVIRONMENT_DATE" value="${form.ENVIRONMENT_DATE}" width="${inputTextDate}" datePicker="true" required="${form_ENVIRONMENT_DATE_R}" disabled="${form_ENVIRONMENT_DATE_D}" readOnly="${form_ENVIRONMENT_DATE_RO}" />
					</e:field>
					<e:field>
						<e:inputDate id="SQ_DATE" name="SQ_DATE" value="${form.SQ_DATE}" width="${inputTextDate}" datePicker="true" required="${form_SQ_DATE_R}" disabled="${form_SQ_DATE_D}" readOnly="${form_SQ_DATE_RO}" />
					</e:field>
					<e:field>
						<e:inputDate id="MAIN_BANK_DATE" name="MAIN_BANK_DATE" value="${form.MAIN_BANK_DATE}" width="${inputTextDate}" datePicker="true" required="${form_MAIN_BANK_DATE_R}" disabled="${form_MAIN_BANK_DATE_D}" readOnly="${form_MAIN_BANK_DATE_RO}" />
					</e:field>
				</e:row>
			</e:searchPanel>
				<%--사업장--%>
			<e:searchPanel id="form7" useTitleBar="true" title="${BBV_010_business}" labelWidth="150" width="100%">
			<tr><td><div><e:gridPanel gridType="${_gridType}" id="gridVNPL" name="gridVNPL" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNPL.gridColData}" />
				</e:searchPanel>
			</div>
				<div id="ui-tabs-4-main">
						<%--주요납품고객정보--%>
					<e:panel id="form15">
						<%--<e:buttonBar id="buttonBarVNRS" align="right" width="100%">
                            <e:button id="doInsertVNRS" name="doInsertVNRS" label="${doInsertVNRS_N}" onClick="doInsertVNRS" disabled="${doInsertVNRS_D}" visible="${doInsertVNRS_V}" />
                            <e:button id="doDeleteVNRS" name="doDeleteVNRS" label="${doDeleteVNRS_N}" onClick="doDeleteVNRS" disabled="${doDeleteVNRS_D}" visible="${doDeleteVNRS_V}" />
                        </e:buttonBar>--%>
						<e:gridPanel gridType="${_gridType}" id="gridVNRS" name="gridVNRS" width="100%" height="135px" title="${BBV_010_main_customer_info}" useTitleBar="true" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNRS.gridColData}"/>
					</e:panel>
						<%--협력업체--%>
					<e:panel id="form16">
						<e:gridPanel gridType="${_gridType}" id="gridVNCB" name="gridVNCB" width="100%" height="135px" title="${BBV_010_0009}" useTitleBar="true" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNCB.gridColData}"/>
					</e:panel>
						<%--관계사--%>
					<e:panel id="form17">
						<%--<e:buttonBar id="buttonBarVNRE" align="right" width="100%">
                            <e:button id="doSelVendor" name="doSelVendor" label="${doSelVendor_N}" onClick="doSelVendor" disabled="${doSelVendor_D}" visible="${doSelVendor_V}"/>
                        </e:buttonBar>--%>
						<e:gridPanel gridType="${_gridType}" id="gridVNRE" name="gridVNRE" width="100%" height="135px" title="${BBV_010_0010}" useTitleBar="true" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNRE.gridColData}"/>
					</e:panel>
						<%--완성 차 의존도--%>
					<e:panel id="form18">
						<e:gridPanel gridType="${_gridType}" id="gridVNCA" name="gridVNCA" width="100%" height="135px" title="${BBV_010_0011}" useTitleBar="true" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNCA.gridColData}"/>
					</e:panel>
				</div>
				<div id="ui-tabs-3-main">
						<%--생산설비--%>
					<e:panel id="form13">
						<e:gridPanel gridType="${_gridType}" id="gridVNEQ" name="gridVNEQ" width="100%" height="250px" title="${BBV_010_0005}" useTitleBar="true" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNEQ.gridColData}"/>

						<e:searchPanel id="form14" useTitleBar="false" labelWidth="130" width="100%" columnCount="1">
							<e:row>
								<e:label for="TEST_EQUIPMENT" title="${form_TEST_EQUIPMENT_N}"/>
								<e:field>
									<e:textArea id="TEST_EQUIPMENT" style="ime-mode:inactive" name="TEST_EQUIPMENT" height="100px" value="${form.TEST_EQUIPMENT}" width="100%" maxLength="${form_TEST_EQUIPMENT_M}" disabled="${form_TEST_EQUIPMENT_D}" readOnly="${form_TEST_EQUIPMENT_RO}" required="${form_TEST_EQUIPMENT_R}" />
								</e:field>
							</e:row>
						</e:searchPanel>
					</e:panel>
					<e:panel>
						<e:gridPanel gridType="${_gridType}" id="gridVNPI" name="gridVNPI" width="100%" height="250px" title="${BBV_010_0006}" useTitleBar="true" readOnly="${param.detailView}" columnDef="${gridInfos.gridVNPI.gridColData}"/>
					</e:panel>
				</div>
		</div>
	</e:window>
</e:ui>