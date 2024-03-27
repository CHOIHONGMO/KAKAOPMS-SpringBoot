<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/purchase/prMgt/prRequestList/";

	    function init() {
		grid = EVF.getComponent('grid');
		grid.setProperty('panelVisible', ${panelVisible});

		// 구매유형에서 "수선,제작,품의" 제외하고 나머지 코드값은 Invisible
		EVF.C('PR_TYPE').removeOption('ISP'); // 투자품의
		EVF.C('PR_TYPE').removeOption('SMT'); // 부자재
		EVF.C('PR_TYPE').removeOption('NORMAL'); // 부품
		EVF.C('PR_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PR_TYPE').removeOption('OMRO'); // 해외MRO

		grid.setProperty('multiselect', true);
		grid.setColEllipsis (['REJECT_RMK'], true);


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

		// 구매요청중(1100)은 제외함
		EVF.C('PROGRESS_CD').removeOption('1100'); // 구매요청중
		EVF.C('PROGRESS_CD').removeOption('6200'); // 입고완료

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
	            everPopup.openPopupByScreenId("BPRM_010", 1000, 700, params);
	        }

	        if (celname == "RFX_NUM") {
	            var params = {
	                gateCd: grid.getCellValue(rowid, 'GATE_CD'),
	                rfxNum: grid.getCellValue(rowid,'RFX_NUM'),
	                rfxCnt: grid.getCellValue(rowid, 'RFX_CNT'),
	                rfxType: 'RFQ',
	                detailView: true
	            };
	            everPopup.openRfxDetailInformation(params);
	        }

	        if (celname == "QTA_NUM") {
	            var param = {
	                qtaNum: grid.getCellValue(rowid,"QTA_NUM"),
	                rfxNum: grid.getCellValue(rowid,"RFX_NUM"),
	                rfxCnt: grid.getCellValue(rowid,"RFX_CNT"),
	                popupFlag: true,
	                detailView: true
	            };
	            if (param.qtaNum !== "") everPopup.openPopupByScreenId("SPX_020", 1000, 700, param);
	        }

	        if (celname == "EXEC_NUM") {
	            var param = {
	                execNum: grid.getCellValue(rowid,"EXEC_NUM"),
	                detaiView: true
	            };
	            everPopup.openDraftDetailInformation(param);
	        }

	        if (celname == "PO_NUM") {
	            var param = {
	                poNum: grid.getCellValue(rowid,"PO_NUM"),
	                detaiView: true
	            };
	            everPopup.openPoDetailInformation(param);
	        }

	        if (celname == "PO_QT") {
	            var prNum = grid.getCellValue(rowid,"PR_NUM");
	            var prSq = grid.getCellValue(rowid,"PR_SQ");
	            everPopup.openPoQtyDetailInformation(prNum, prSq);
	        }

	        if (celname == "GR_QT") {
	            var prNum = grid.getCellValue(rowid,"PR_NUM");
	            var prSq = grid.getCellValue(rowid,"PR_SQ");
	            everPopup.openAccumGrQtyDetailInformation(prNum, prSq);
	        }
		});
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BPRP_020/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    function doSearchDept() {
        if ("${ses.userType}" != 'S') {
            var param = {
                callBackFunction: "selectDept",
                BUYER_CD: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0002');

        } else {
            return alert("BPP_030_NOT_DEPT");
        }
    }
    function selectDept(dataJsonArray) {
        EVF.getComponent('REQ_DEPT_NM').setValue(dataJsonArray.DEPT_NM);
    }
    function doSearchUser() {
        everPopup.openCommonPopup({
            callBackFunction: "selectUser"
        }, 'SP0001');
    }
    function selectUser(data) {
		EVF.getComponent("REQ_USER_ID").setValue(data.USER_ID);
        EVF.getComponent("REQ_USER_NM").setValue(data.USER_NM);
        EVF.getComponent("REQ_DEPT_NM").setValue(data.DEPT_NM);
    }
    function removeUserId() {
		EVF.C('REQ_USER_ID').setValue('');
	}

	function doNew() {
		var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

		if(selRowIds.length == 0) {
			return alert('${msg.M0004}');
		}

		var flag = valid.notEqualColValid(grid, 'PR_TYPE', grid.getCellValue(selRowIds[0], 'PR_TYPE'));

		if(flag) {
			return alert('${BPRP_020_0001}');
		}

		var params = {
			'prList': JSON.stringify(grid.getSelRowValue()),
			'PR_TYPE': grid.getCellValue(selRowIds[0], 'PR_TYPE'),
			'popupFlag': true,
			'detailView' : false
		};
		everPopup.openPopupByScreenId("BPRM_010", 1000, 700, params);

	}
</script>
    <e:window id="BPRP_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
        	<e:row>
				<%--요청일자--%>
				<e:label for="REQ_DATE_FROM" title="${form_REQ_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="REQ_DATE_FROM" toDate="REQ_DATE_TO" name="REQ_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_R}" disabled="${form_REQ_DATE_D}" readOnly="${form_REQ_DATE_RO}" />
					<e:text> ~ </e:text>
				<e:inputDate id="REQ_DATE_TO" fromDate="REQ_DATE_FROM" name="REQ_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_R}" disabled="${form_REQ_DATE_D}" readOnly="${form_REQ_DATE_RO}" />
				</e:field>
				<%--플랜트--%>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${refPLANT_CODE }" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
        	<e:row>
				<%--구매요청 번호 / 명--%>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
				<e:field>
					<e:inputText id="PR_NUM" name="PR_NUM" value="${form.PR_NUM}" width="${inputTextWidth }" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="${form.PR_SUBJECT}" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
				<%--구매유형--%>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prTypeOptions}" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
        	<e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth }" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
					<e:text>&nbsp;</e:text>
					<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="50%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
				</e:field>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
        	</e:row>
			<e:row>
				<%--요청자 / 부서명--%>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
				<e:field>
					<e:search id="REQ_USER_NM" style="ime-mode:inactive" name="REQ_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_REQ_USER_NM_M}" onIconClick="${form_REQ_USER_NM_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" onKeyUp="removeUserId"/>
                    <e:inputHidden id="REQ_USER_ID" name="REQ_USER_ID" value="${ses.userId}"/>
					<e:text>&nbsp;</e:text>
					<e:inputText id="REQ_DEPT_NM" style="${imeMode}" name="REQ_DEPT_NM" value="${empty form.REQ_DEPT_NM ? ses.deptNm : form.REQ_DEPT_NM}" width="${inputTextWidth}" maxLength="${form_REQ_DEPT_NM_M}" disabled="${form_REQ_DEPT_NM_D}" readOnly="${form_REQ_DEPT_NM_RO}" required="${form_REQ_DEPT_NM_R}"/>
				</e:field>
				<%--도번--%>
				<e:label for="PLAN_NUM" title="${form_PLAN_NUM_N}"/>
				<e:field>
					<e:inputText id="PLAN_NUM" style="ime-mode:auto" name="PLAN_NUM" value="${form.PLAN_NUM}" width="${inputTextWidth}" maxLength="${form_PLAN_NUM_M}" disabled="${form_PLAN_NUM_D}" readOnly="${form_PLAN_NUM_RO}" required="${form_PLAN_NUM_R}"/>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doNew" name="doNew" label="${doNew_N}" onClick="doNew" disabled="${doNew_D}" visible="${doNew_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>