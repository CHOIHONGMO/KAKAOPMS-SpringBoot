<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid = {};
		var addParam = [];
		var baseUrl = "/eversrm/purchase/prMgt/prReceipt/";

		function init() {
			grid = EVF.getComponent('grid');

			// 구매유형에서 "수선,제작" 제외하고 나머지 코드값은 Invisible
			EVF.C('PR_TYPE').removeOption('DC'); // 품의
			EVF.C('PR_TYPE').removeOption('ISP'); // 투자품의
			EVF.C('PR_TYPE').removeOption('SMT'); // 부자재
			EVF.C('PR_TYPE').removeOption('NORMAL'); // 부품
			EVF.C('PR_TYPE').removeOption('DMRO'); // 국내MRO
			EVF.C('PR_TYPE').removeOption('OMRO'); // 해외MRO
			grid.setProperty('panelVisible', ${panelVisible});
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

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if (celname == "VENDOR_CD") {
					var params = {
						VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
						popupFlag: true,
						detailView : true
					};
					everPopup.openSupManagementPopup(params);
				}

				if (celname=='ITEM_CD') {
					var param = {
						ITEM_CD: grid.getCellValue(rowid,"ITEM_CD")
					};
					everPopup.openItemDetailInformation(param);
				}

				if (celname == "PR_NUM") {
					var params = {
						prNum: grid.getCellValue(rowid, "PR_NUM"),
						popupFlag: true,
						detailView : true
					};
					everPopup.openPopupByScreenId("BPRM_010", 1100, 700, params);

				}

				if (celname == "REC_VENDOR_CD") {
					alert('not worked');
					return;
					var params = {
						VENDOR_CD: grid.getCellValue(rowidm , "REC_VENDOR_CD"),
						paramPopupFlag: "Y",
						onClose: ''
					};
					everPopup.openSupManagementPopup(params);
				}


			});
		}

		function doSearch() {
			var store = new EVF.Store();
			if(!store.validate()) return;
			store.setGrid([grid]);
			store.load(baseUrl + 'BPRR_010/doSearch', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doAssign() {
			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}

			if (EVF.getComponent("BUYER_CD").getValue() == "") {
				return alert("${BPRR_010_0001}"); // 구매담당자를 지정하시기 바랍니다.
			}

			if (!confirm("${msg.M0082}")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'BPRR_010/doAssign', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
        }
        function doSearchReqDept() {
			var param = {
				callBackFunction: "selectDept",
				BUYER_CD: "${ses.companyCd}"
			};
			everPopup.openCommonPopup(param, 'SP0002');
		}

		function selectDept(dataJsonArray) {
			EVF.getComponent('REQ_USER_NM').setValue(dataJsonArray.DEPT_NM);
		}

		function doSearchUserAssign() {
			// 데이터가 미존재 시 조회를 먼저한다.
			if(grid.getRowCount() == 0) {
				alert("${BPRR_010_0004}"); // 구매담당자를 지정하기 위해 조회 후 데이터를 선택하여 주시기 바랍니다.
				return;
			}

			// 데이터 선택 여부
			var rowIdx = grid.jsonToArray(grid.getSelRowId()).value;

			if (rowIdx.length == 0) {
				alert("${msg.M0004}");
				return;
			}

			// 구매그룹 동일여부 판단
			/*
			var ctrl_cd;
			for(idx in rowIdx) {
				var ctrlValue = grid.getRowValue(rowIdx[idx]);

				if(grid.getRowValue(rowIdx[0]).CTRL_CD != ctrlValue.CTRL_CD) {
					alert("${BPRR_010_0005}"); // 동일한 구매그룹을 선택 후 구매담당자를 지정하시기 바랍니다.
					return;
				} else {
					ctrl_cd = ctrlValue.CTRL_CD;
				}
			}*/

			// 동일 플랜트에 대해 담당자 지정
			var plantCd;
			for(idx in rowIdx) {
				var plantCdValue = grid.getRowValue(rowIdx[idx]);

				if(grid.getRowValue(rowIdx[0]).PLANT_CD != plantCdValue.PLANT_CD) {
					alert("${BPRR_010_0005}"); // 동일한 플랜트 선택 후 구매담당자를 지정하시기 바랍니다.
					return;
				} else {
					plantCd = plantCdValue.PLANT_CD;
				}
			}

			var param = {
				'callBackFunction': "selectUserAss",
				'PLANT_CD': plantCd
			};
			everPopup.openCommonPopup(param, 'SP0040');
		}

		function doSearchUser() {
			everPopup.openCommonPopup({
				callBackFunction: "selectUser"
			}, 'SP0001');
		}

		function selectUser(data) {
			EVF.getComponent("REQ_USER_ID").setValue(data.USER_ID);
	        EVF.getComponent("REQ_USER_NM").setValue(data.USER_NM);
		}

		function selectUserAss(data) {
			EVF.getComponent("BUYER_NM").setValue(data.CTRL_USER_NM);
			EVF.getComponent("BUYER_CD").setValue(data.CTRL_USER_ID);
			//EVF.getComponent("CTRL_CD").setValue(data.CTRL_CD);
			//EVF.getComponent("PUR_ORG_CD").setValue(data.PUR_ORG_CD);
		}

		function doSearchCtrlCd() {
			/*if(EVF.getComponent("PLANT_CD").getValue() == "") {
				alert("${BPRR_010_0002}"); // 플랜트 코드를 선택하여 주시기 바랍니다.

				// Validation effect
				formUtil.animate("PLANT_CD");

				return;
			}*/

			// 플랜트 코드 존재 시 조회, 미 존재 시 조회
			if(EVF.getComponent("PLANT_CD").getValue() == "") {
				var param = {
					'callBackFunction': 'ctrlCodeCallback',
					'detailView': false,
					'CTRL_TYPE' : 'NPUR'
				};
				everPopup.openCommonPopup(param, "SP0038");
			} else {
				var param = {
					'callBackFunction': 'ctrlCodeCallback',
					'detailView': false,
					'PLANT_CD': EVF.getComponent("PLANT_CD").getValue(),
					'CTRL_TYPE' : 'NPUR'
				};
				everPopup.openCommonPopup(param, "SP0037");
			}
		}

		function ctrlCodeCallback(data) {
			EVF.getComponent("CTRL_NM").setValue(data.CTRL_NM);
			EVF.getComponent("CTRL_CD").setValue(data.CTRL_CD);
		}
    </script>
    <e:window id="BPRR_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" useTitleBar="false" onEnter="doSearch">
        	<e:row>
				<%--구매요청일자--%>
				<e:label for="REQ_DATE_FROM" title="${form_REQ_DATE_N}"/>
				<e:field>
					<e:inputDate id="REQ_DATE_FROM" toDate="REQ_DATE_TO" name="REQ_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_R}" disabled="${form_REQ_DATE_D}" readOnly="${form_REQ_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="REQ_DATE_TO" fromDate="REQ_DATE_FROM" name="REQ_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_R}" disabled="${form_REQ_DATE_D}" readOnly="${form_REQ_DATE_RO}" />
				</e:field>
				<%--플랜트--%>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
				<%--구매유형--%>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prTypeOptions}" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--구매요청번호--%>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
				<e:field>
					<e:inputText id="PR_NUM" style="ime-mode:inactive" name="PR_NUM" value="${form.PR_NUM}" width="${inputTextWidth}" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}"/>
				</e:field>
				<%--요청명--%>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
				<e:field>
					<e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="98%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
				</e:field>
				<%--요청자--%>
				<e:label for="REQ_USER_ID" title="${form_REQ_USER_ID_N}"/>
				<e:field>
					<e:search id="REQ_USER_ID" style="ime-mode:inactive" name="REQ_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_REQ_USER_ID_M}" onIconClick="${form_REQ_USER_ID_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_REQ_USER_ID_D}" readOnly="${form_REQ_USER_ID_RO}" required="${form_REQ_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="REQ_USER_NM" style="${imeMode}" name="REQ_USER_NM" value="${form.REQ_USER_NM}" width="${inputTextWidth }" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}"/>
				</e:field>
			</e:row>
			<e:row>
				<%--담당자지정--%>
				<e:label for="BUYER_FLAG" title="${form_BUYER_FLAG_N}"/>
				<e:field>
					<e:select id="BUYER_FLAG" name="BUYER_FLAG" value="${empty form.BUYER_FLAG ? 'N' : form.BUYER_FLAG}" options="${buyerFlagOptions}" width="${inputTextWidth}" disabled="${form_BUYER_FLAG_D}" readOnly="${form_BUYER_FLAG_RO}" required="${form_BUYER_FLAG_R}" placeHolder="" />
				</e:field>
				<%--구매그룹--%>
				<e:label for="CTRL_CD" title="${form_CTRL_CD_N}"/>
				<e:field colSpan="3">
					<e:search id="CTRL_CD" style="ime-mode:inactive" name="CTRL_CD" value="" width="${inputTextWidth}" maxLength="${form_CTRL_CD_M}" onIconClick="${form_CTRL_CD_RO ? 'everCommon.blank' : 'doSearchCtrlCd'}" disabled="${form_CTRL_CD_D}" readOnly="${form_CTRL_CD_RO}" required="${form_CTRL_CD_R}" />
					<e:inputHidden id="CTRL_NM" name="CTRL_NM" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:panel id="xxxx" name="xxxx">
				<e:text>&nbsp;&nbsp;${form_BUYER_CD_N } : &nbsp;</e:text>
				<e:search id="BUYER_NM" name="BUYER_NM"  height="30" value="" width="${inputTextWidth }" maxLength="${form_BUYER_CD_M}" onIconClick="${form_BUYER_CD_RO ? 'everCommon.blank' : 'doSearchUserAssign'}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
				<e:text>&nbsp;</e:text>
				<e:button id="doAssign" name="doAssign" label="${doAssign_N}" onClick="doAssign" disabled="${doAssign_D}" visible="${doAssign_V}"/>
				<e:inputHidden id="BUYER_CD" name="BUYER_CD"/>
				<e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD"/>
			</e:panel>

			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>