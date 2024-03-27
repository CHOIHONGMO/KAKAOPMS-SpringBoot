<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri = "http://java.sun.com/jsp/jstl/functions" prefix = "fn" %>

<%
	String devFlag = PropertiesManager.getString("eversrm.system.developmentFlag");
	String gwUrl = "";
	if ("true".equals(devFlag)) {
		  gwUrl = PropertiesManager.getString("gw.dev.url");
	} else {
		  gwUrl = PropertiesManager.getString("gw.real.url");
	}
	String gwParam = PropertiesManager.getString("gw.param");
%>

<c:set var="devFlag" value="<%=devFlag%>" />
<c:set var="gwUrl" value="<%=gwUrl%>" />
<c:set var="gwParam" value="<%=gwParam%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid = {};
		var baseUrl = "/eversrm/eContract/eContractMgt/";
		var selRow;
		function init() {
			grid = EVF.C("grid");
			grid.setProperty('panelVisible', ${panelVisible});
		    grid.setProperty('singleSelect', true);
			grid.cellClickEvent(function (rowid, celname, value, iRow, iCol) {

				selRow = rowid;
				var contUserId = grid.getCellValue(rowid, 'CONT_USER_ID');
				var ctrlUserId = grid.getCellValue(rowid, 'CTRL_USER_ID');

				switch (celname) {

					case 'CONT_NUM':
						everPopup.openContractChangeInformation({
							callBackFunction : 'doSearch',
							CONT_NUM         : grid.getCellValue(rowid, "CONT_NUM"),
							CONT_CNT         : grid.getCellValue(rowid, "CONT_CNT"),
							VENDOR_CD        : grid.getCellValue(rowid, "VENDOR_CD"),
							baseDataType     : grid.getCellValue(rowid,"BASEDATATYPE"), //contract, soContract, exContract
							/* detailView: true, */
							contractEditable : false
						});
						break;

					case 'VENDOR_CD':
						var params = {
							VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
		                    detailView: true,
		                    popupFlag: true

						};
						 everPopup.openPopupByScreenId("M03_003", 1100, 750, params);
						break;

						<%-- ADV_GUAR --%>
					case 'GUR_CNT':
						if(grid.getCellValue(rowid,"GUR_CNT") >= '0'){
							var param = {
								havePermission: (contUserId == '${ses.userId}' || ctrlUserId == '${ses.userId}') ? 'true' : 'false',
								attFileNum: grid.getCellValue(rowid, 'GUAR_ATT_FILE_NUM'),
								rowId: rowid,
								callBackFunction: 'setFileAttachCnt1',
								bizType: 'CT',
								fileExtension: '*'
							};
							everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						}
						break;

						<%-- CONT_GUAR --%>
					case 'GUR_PER_CNT':
						if(grid.getCellValue(rowid,"GUR_PER_CNT") >= '0'){
							var param = {
								havePermission: (contUserId == '${ses.userId}' || ctrlUserId == '${ses.userId}') ? 'true' : 'false',
								attFileNum: grid.getCellValue(rowid, 'GUAR_PERFORM_ATT_FILE_NUM'),
								rowId: rowid,
								callBackFunction: 'setFileAttachCnt2',
								bizType: 'CT',
								fileExtension: '*'
							};
						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						}
						break;

						<%-- PAY_GUAR --%>
					case 'GUR_PAY_CNT':
						if(grid.getCellValue(rowid,"GUR_PAY_CNT") >= '0'){
						var param = {
							havePermission: (contUserId == '${ses.userId}' || ctrlUserId == '${ses.userId}') ? 'true' : 'false',
							attFileNum: grid.getCellValue(rowid, 'GUAR_PAY_ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'setFileAttachCnt3',
							bizType: 'CT',
							fileExtension: '*'
						};
						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						}
						break;

						<%-- WARR_GUAR --%>
					case 'GUR_FIN_CNT':
						if(grid.getCellValue(rowid,"GUR_FIN_CNT") >= '0'){
							var param = {
								havePermission: (contUserId == '${ses.userId}' || ctrlUserId == '${ses.userId}') ? 'true' : 'false',
								attFileNum: grid.getCellValue(rowid, 'GUAR_FINISH_ATT_FILE_NUM'),
								rowId: rowid,
								callBackFunction: 'setFileAttachCnt4',
								bizType: 'CT',
								fileExtension: '*'
							};
							everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						}
						break;

						<%-- VENDOR ATT --%>
					case 'VENDOR_ATT_FILE_CNT':
						var param = {
							havePermission: (contUserId == '${ses.userId}' || ctrlUserId == '${ses.userId}') ? 'true' : 'false',
							attFileNum: grid.getCellValue(rowid, 'VENDOR_ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'setFileAttachCnt5',
							bizType: 'CT',
							fileExtension: '*'
						};
						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
						break;

					default:
						return;
				}

			});

			grid.excelExportEvent({
				allCol: "${excelExport.allCol}",
				selRow: "${excelExport.selRow}",
				fileType: "${excelExport.fileType }",
				fileName: "${screenName }",
				excelOptions: {
					imgWidth: 0.12, // image width
					imgHeight: 0.26, // image height
					colWidth: 20, // column width.
					rowSize: 500, //  excel row hight size.
					attachImgFlag: false
					 // excel imange attach flag : true/false
				}
			});

			/* EVF.C('USER_NM').setValue('${ses.userNm}'); */
			EVF.C('USER_ID').setValue('${ses.userId}');


			if ('${param.summary}' == 'Y' || '${param.summary}' == 'C') {
				doSearch();
			}
		}

		function setFileAttachCnt1(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'GUR_CNT', fileCnt);
			grid.setCellValue(rowId, 'GUAR_ATT_FILE_NUM', fileId);

			doSave();
		}

		function setFileAttachCnt2(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'GUR_PER_CNT', fileCnt);
			grid.setCellValue(rowId, 'GUAR_PERFORM_ATT_FILE_NUM', fileId);

			doSave();
		}

		function setFileAttachCnt3(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'GUR_PAY_CNT', fileCnt);
			grid.setCellValue(rowId, 'GUAR_PAY_ATT_FILE_NUM', fileId);

			doSave();
		}

		function setFileAttachCnt4(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'GUR_FIN_CNT', fileCnt);
			grid.setCellValue(rowId, 'GUAR_FINISH_ATT_FILE_NUM', fileId);

			doSave();
		}

		function setFileAttachCnt5(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'VENDOR_ATT_FILE_CNT', fileCnt);
			grid.setCellValue(rowId, 'VENDOR_ATT_FILE_NUM', fileId);

			doSave();
		}

		function doSearch() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }'))
				return alert('${msg.M0073}');

			store.setGrid([grid]);
			store.load(baseUrl + '/BECM_050/doSearch', function () {
				if (grid.getRowCount() == 0) {
					alert("${msg.M0002 }");
				}
			});
		}

		function doSearchVendor() {
			var param = {
				callBackFunction: "selectVendorSearch",
				BUYER_CD: "${ses.companyCd}"
			};
			everPopup.openCommonPopup(param, "SP0013");
		}

		function selectVendorSearch(data) {
			EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
			EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
		}

		function doSearchUser() {
			var param = {
				callBackFunction: "selectUser" ,

			};
			everPopup.openCommonPopup(param, 'SP0011');
		}

		function selectUser(data) {
			EVF.C("USER_NM").setValue(data.USER_NM);
			EVF.C("USER_ID").setValue(data.USER_ID);
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

		//contract modify
		function doChange() {

			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

            var ctrlCd = '${ses.ctrlCd}';

            if(ctrlCd.indexOf('N100') == -1) {
                if (gridData[0]['CONT_USER_ID'] != '${ses.userId}') {
    				return alert("${msg.M0008 }");
    			}
            }

            if(gridData[0]['CONT_REQ_CD'] != '05'){
				everPopup.openContractChangeInformation({
					callBackFunction : 'doSearch',
					CONT_NUM         : gridData[0]['CONT_NUM'],
					CONT_CNT         : gridData[0]['CONT_CNT'],
					VENDOR_CD        : gridData[0]['VENDOR_CD'],

					baseDataType     : gridData[0]['BASEDATATYPE'], //contract, soContract, exContract
					detailView       : false,
					contractEditable : true
				});
            }else{
            	alert('${BECM_050_0014}');

            }
		}

		//terminate Contract
		function doTerminate(){
			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			if(gridData[0]['PROGRESS_CD'] != '4300') {
				alert('${BECM_050_0010}');
				return;
			}

			if(!confirm('${BECM_050_0012}')) { return; }

			var store = new EVF.Store();
        	store.setGrid([grid]);
			store.getGridData(grid, 'sel');
            store.load(baseUrl + "/BECM_050/doTerminateContract", function(){
            	alert(this.getResponseMessage());
        		doSearch();

            });
		}

		//Resume contract
		function doResume() {

			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}


			if (gridData[0]['CONT_USER_ID'] != '${ses.userId}') {
				return alert("${msg.M0008 }");
			}

			if (gridData[0]['PROGRESS_CD'] == '4300') {

				if(gridData[0]['CONT_REQ_CD'] != '05'){
				everPopup.openContractChangeInformation({
					callBackFunction : 'doSearch',
					CONT_NUM         : gridData[0]['CONT_NUM'],
					CONT_CNT         : gridData[0]['CONT_CNT'],
					VENDOR_CD        : gridData[0]['VENDOR_CD'],

					baseDataType     : gridData[0]['BASEDATATYPE'], //contract, soContract, exContract
					contReqStatus    : 'C',  //변경계약시 C
					contReqFlag      : '04',
					detailView       : false,
					contractEditable : true
				});
				}else{
					alert('${BECM_050_0013}');

				}
			} else {
				alert('${BECM_050_0003}');

			}
		}

		//gurantee save
		function doSave() {

			if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

			if(valid.notEqualColValid(grid, "CONT_USER_ID", '${ses.userId}') && valid.notEqualColValid(grid, "CTRL_USER_ID", '${ses.userId}')) {
				return alert("${msg.M0008 }");
			}

			var store = new EVF.Store();
			if(!confirm('${msg.M0021}')) { return; }

			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/BECM_050/doSave', function() {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doPrint() {
			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			var param = {
				CONT_NUM  : gridData[0]['CONT_NUM'],
				CONT_CNT  : gridData[0]['CONT_CNT'],
				progressCd: gridData[0]['PROGRESS_CD'],
				CONTRACT_TEXT_NUM: gridData[0]['CONTRACT_TEXT_NUM'],
				contents: '', //gridData[0]['CONTENTS'],
				callBackFunction: ''
			};

			var ie_flag = (navigator.appName == 'Microsoft Internet Explorer') || ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null));
			if (!ie_flag) {
				alert("${BECM_050_0009}");
			}
			everPopup.openPopupByScreenId('BECM_060', 1000, 800, param);
		}

<%--

		function doSign() {

			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			if (gridData[0]['CONT_USER_ID'] != '${ses.userId}') {
				return alert("${msg.M0008 }");
			}

			if (gridData[0]['PROGRESS_CD'] != '4230') {
				return alert("");
			}


			everPopup.openContractChangeInformation({
				callBackFunction : 'doSearch',
				CONT_NUM         : gridData[0]['CONT_NUM'],
				CONT_CNT         : gridData[0]['CONT_CNT'],

				baseDataType     : gridData[0]['BASEDATATYPE'], //contract, soContract, exContract
				detailView       : false,
				contractEditable : true
			});
		}


		function doReject() {

			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			if (gridData[0]['CONT_USER_ID'] != '${ses.userId}') {
				return alert("${msg.M0008 }");
			}

			if(gridData[0]['PROGRESS_CD'] == '4230' && gridData[0]['VENDOR_EDIT_FLAG'] == '1' ){
				everPopup.openContractChangeInformation({

					callBackFunction : 'doSearch',
					CONT_NUM         : gridData[0]['CONT_NUM'],
					CONT_CNT         : gridData[0]['CONT_CNT'],

					baseDataType     : gridData[0]['BASEDATATYPE'], //contract, soContract, exContract
					detailView       : false,
					contractEditable : false,
					rejectProcess    : true
				});
			}else{
				alert('${BECM_050_0008}');

			}
		}

		function doApproval() {

			var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
			if (selRowIds.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			var userFlag, progressFlag, signStatusFlag;
			var userArray = [];
			var progressArray = [];
			var signArray = [];


			for (idx in selRowIds) {
				if (grid.getCellValue(selRowIds[idx], 'CONT_USER_ID') != '${ses.userId}') {
					userArray.push(grid._getCellTag(selRowIds[idx], "USER_NM"));

					var td = grid._getCellTag(selRowIds[idx], "USER_NM");
					td.css('color', '#fff').css('background-color', '#ff988c');

					userFlag = true;
				}
			}
			if (userFlag) {
				setAnimate(userArray);
				return alert("${msg.M0008}");
			}*/

			for (idx in selRowIds) {
				if (grid.getCellValue(selRowIds[idx], 'PROGRESS_CD') != '4300') {
					progressArray.push(grid._getCellTag(selRowIds[idx], "PROGRESS_CD"));

					var td = grid._getCellTag(selRowIds[idx], "PROGRESS_CD");
					td.css('color', '#fff').css('background-color', '#ff988c');

					progressFlag = true;
				} else {
					var signStatus = grid.getCellValue(selRowIds[idx], 'SIGN_STATUS');

					if (signStatus == 'P' || signStatus == 'E') {
						signArray.push(grid._getCellTag(selRowIds[idx], "SIGN_STATUS"));

						var td = grid._getCellTag(selRowIds[idx], "SIGN_STATUS");
						td.css('color', '#fff').css('background-color', '#ff988c');

						signStatusFlag = true;
					}
				}
			}

			if (progressFlag) {
				setAnimate(progressArray);
				return alert('${BECM_050_0004}');
			}

			if (signStatusFlag) {
				setAnimate(signArray);
				return alert('${BECM_050_0005}');
			}

			if (!confirm('${BECM_050_0006}')) {
				return;
			}

			var userwidth = 810; //
			var userheight = (screen.height - 2);
			if (userheight < 780) userheight = 780; //
			var LeftPosition = (screen.width - userwidth) / 2;
			var TopPosition = (screen.height - userheight) / 2;
			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width=' + userwidth + ',height=' + userheight + ',left=' + LeftPosition + ',top=' + TopPosition;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + "BECM_050/doApproval", function () {

				var legacyKey = this.getParameter('legacy_key');
				if (legacyKey == 'ERROR') {
					alert(this.getResponseMessage());
					return;
				}

				var url;
				var gwUserId;
				if ('${devFlag}' == 'true') {
					gwUserId = 'hspark03';
				} else {
					gwUserId = '${ses.userId}';
				}
				if (legacyKey != '') {
					url = "${gwUrl}" + gwUserId + "${gwParam}" + legacyKey;
					window.open(url, "signwindow", gwParam);
				}

				doSearch();
			});
		}


		function goApproval(formData, gridData, attachData) {
			EVF.C('approvalFormData').setValue(formData);
			EVF.C('approvalGridData').setValue(gridData);
			EVF.C('attachFileDatas').setValue(attachData);

			var store = new EVF.Store();
			var gridData = grid.getSelRowValue();
			store.setParameter("CONT_NUM", gridData[0]['CONT_NUM']);
			store.setParameter("CONT_CNT", gridData[0]['CONT_CNT']);

			store.doFileUpload(function () {
				store.load(baseUrl + "BECM_050/doApprovalList", function () {
					alert(this.getResponseMessage());
					doSearch();
				});
			});
		}


		function doStop() {

			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			if (gridData[0]['CONT_USER_ID'] != '${ses.userId}') {
				return alert("${msg.M0008 }");
			}

			if (gridData[0]['PROGRESS_CD'] == '4300') {
				everPopup.openContractChangeInformation({
					callBackFunction : 'doSearch',
					CONT_NUM         : gridData[0]['CONT_NUM'],
					CONT_CNT         : gridData[0]['CONT_CNT'],

					baseDataType     : gridData[0]['BASEDATATYPE'], //contract, soContract, exContract
					contReqStatus    : 'C', //계약중단시 C
					contReqFlag      : '02',
					detailView       : false,
					contractEditable : true
				});
			} else {
				alert('${BECM_050_0001}');

			}

		}

		function setAnimate(array) {
			setTimeout(function () {
				for (idxs in array) {
					array[idxs].animate({backgroundColor: "#fff", color: "#333"}, 1000);
				}
			}, 4000);
		}
--%>

	</script>

	<e:window id="BECM_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="summary" name="summary" value="${summary}" />

			<e:inputHidden id="approvalFormData" name="approvalFormData"/>
	    	<e:inputHidden id="approvalGridData" name="approvalGridData"/>
	    	<e:inputHidden id="attachFileDatas" name="attachFileDatas"/>



			<e:row>
				<e:label for="REG_DATE_FROM" title="${form_REG_DATE_N }" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="CONT_NUM" title="${form_CONT_NUM_N}"/>
				<e:field>
					<e:inputText id="CONT_NUM" style="ime-mode:inactive" name="CONT_NUM" value="${form.CONT_NUM}" width="40%" maxLength="${form_CONT_NUM_M}" disabled="${form_CONT_NUM_D}" readOnly="${form_CONT_NUM_RO}" required="${form_CONT_NUM_R}"/>
					<e:text>&nbsp;</e:text>
					<e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="57%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="100%" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>

			 	<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="doSearchVendor" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
				<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:label for="CONTRACT_TYPE" title="${form_CONTRACT_TYPE_N}"/>
				<e:field>
				<e:select id="CONTRACT_TYPE" name="CONTRACT_TYPE" value="" options="${contractTypeOptions}" width="100%" disabled="${form_CONTRACT_TYPE_D}" readOnly="${form_CONTRACT_TYPE_RO}" required="${form_CONTRACT_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
				<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="100%" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
	    		<e:label for="USER_ID" title="${form_USER_ID_N }" />
				<e:field>
					<c:choose>
						<c:when test="${fn:indexOf(ses.ctrlCd, 'N100') != -1}">
                            <e:search id="USER_ID" style="${imeMode}" name="USER_ID" value="${ses.userId}" width="40%" maxLength="${form_USER_ID_M}" onIconClick="${form_USER_ID_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
						</c:when>
						<c:otherwise>
						    <e:search id="USER_ID" style="${imeMode}" name="USER_ID" value="${ses.userId}" width="40%" maxLength="${form_USER_ID_M}" onIconClick="" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
						</c:otherwise>
					</c:choose>
					<c:choose>
						<c:when test="${fn:indexOf(ses.ctrlCd, 'N100') != -1}">
							<e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" width="60%" maxLength="${form_USER_NM_M }" required="${form_USER_NM_R }" disabled="${form_USER_NM_D }" readOnly="${form_USER_NM_RO }" value="${ses.userNm}"/>
						</c:when>
						<c:otherwise>
							<e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" width="60%" maxLength="${form_USER_NM_M }" required="${form_USER_NM_R }" disabled="${form_USER_NM_D }" readOnly="true" value="${ses.userNm}" />
						</c:otherwise>
					</c:choose>
				</e:field>



				<e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"/>
				<e:field>
				<e:select id="CONT_REQ_CD" name="CONT_REQ_CD" value="" options="${contReqCdOptions}" width="100%" disabled="${form_CONT_REQ_CD_D}" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="BS_CD" title="${form_BS_CD_N}"/>
				<e:field>
				<e:search id="BS_CD" name="BS_CD" value="" style="ime-mode:inactive" width="40%" maxLength="${form_BS_CD_M}" onIconClick="${form_BS_CD_RO ? 'everCommon.blank' : 'getBsCd'}" disabled="${form_BS_CD_D}" readOnly="${form_BS_CD_RO}" required="${form_BS_CD_R}" />
				<e:inputText id="BS_NM" name="BS_NM" value="" width="60%" maxLength="${form_BS_NM_M}" disabled="${form_BS_NM_D}" readOnly="${form_BS_NM_RO}" required="${form_BS_NM_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<e:button id="doChange" name="doChange" label="${doChange_N }" disabled="${doChange_D }" onClick="doChange" />
		 	<e:button id="doResume" name="doResume" label="${doResume_N}" onClick="doResume" disabled="${doResume_D}" visible="${doResume_V}"/>
			<e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
			<e:button id="doTerminate" name="doTerminate" label="${doTerminate_N}" onClick="doTerminate" disabled="${doTerminate_D}" visible="${doTerminate_V}"/>
			<%--<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/> --%>
			<%--<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/> --%>
			<%--<e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/> --%>
			<%--<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doApproval" disabled="${doApproval_D}" visible="${doApproval_V}"/> --%>
			<%--<e:button id="doStop" name="doStop" label="${doStop_N}" onClick="doStop" disabled="${doStop_D}" visible="${doStop_V}"/> --%>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<c:if test="${ses.userType == 'C'}">
			<jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true" >
		    <jsp:param value="${form.APP_DOC_NUM}" name="APP_DOC_NUM"/>
		    <jsp:param value="${form.APP_DOC_CNT}" name="APP_DOC_CNT"/>
		    </jsp:include>
		</c:if>

	</e:window>

</e:ui>
