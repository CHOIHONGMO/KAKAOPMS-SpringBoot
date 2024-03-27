<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/purchase/prMgt/prRequestList/";
	var selRow;

	    function init() {
		grid = EVF.getComponent('grid');
		grid.setProperty('panelVisible', ${panelVisible});
		// 구매유형에서 "수선,제작,품의" 제외하고 나머지 코드값은 Invisible
		EVF.C('PR_TYPE').removeOption('ISP'); // 투자품의
		EVF.C('PR_TYPE').removeOption('SMT'); // 부자재
		EVF.C('PR_TYPE').removeOption('NORMAL'); // 부품
		EVF.C('PR_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PR_TYPE').removeOption('OMRO'); // 해외MRO

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
			if(selRow == undefined) selRow = rowid;

			if (celname == "multiSelect") {
				if(selRow != rowid) {
					grid.checkRow(selRow, false);
					selRow = rowid;
				}
			}

	        if (celname == "VENDOR_CD") {
	            var params = {
	                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
	                popupFlag: true,
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }


	        if (celname == "PR_NUM") {
	            var params = {
	            		prNum: grid.getCellValue(rowid, "PR_NUM"),
		                popupFlag: true,
		                detailView : true
		        };

	            everPopup.openPopupByScreenId("BPRM_010", 1100, 700, params);

	        }

			if (celname == "ITEM_RETURN") {
				if(value > 0) {
					var param = {
						'detailView': true,
						'PR_NUM': grid.getCellValue(rowid, 'PR_NUM'),
						'popupFlag': true
					};
					everPopup.openPopupByScreenId("BPRP_040", 600, 300, param);
				}
			}
		});

		if(${_gridType eq "RG"}) {
			grid.setColGroup([{
				"groupName": '요청품목',
				"columns": [ "ITEM_ALL", "ITEM_RETURN" ]
			}]);
		} else {
			grid.setGroupCol(
					[
						{'colName' : 'ITEM_ALL',  'colIndex': 2, 'titleText' : '요청품목'}
					]
			);
		}

    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BPRP_010/doSearchPrStatus', function() {
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
    function doChange() {

		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            var reg_user_id = grid.getCellValue(selRowId[i],'REG_USER_ID');
            var progress_cd = grid.getCellValue(selRowId[i], "PROGRESS_CD");
            var sign_cd = grid.getCellValue(selRowId[i], "SIGN_CD");
            var pr_num = grid.getCellValue(selRowId[i], "PR_NUM");

            if (reg_user_id != '${ses.userId }') {
            	 return alert("${msg.M0008}"); // 처리할 권한이 없습니다.
            }
			/*
            if (  progress_cd >= '2100' ) {
            	return alert("${msg.M0044}"); // 진행상태가 정확하지 않아, 처리할 수 없습니다. ( 승인 된 데이터는 수정 불가 )
            }
            */
            if (sign_cd == 'P' || sign_cd == 'E') {
            	 return alert("${msg.M0047}"); //결재상태가 정확하지 않아, 처리할 수 없습니다. ( 결재중이면 수정 불가 )
            }

            everPopup.openPRChageInformation(pr_num);
            return;
     	}

    }

	function removeUserId() {
		EVF.C('REQ_USER_ID').setValue('');
	}
    </script>

    <e:window id="BPRP_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
        	<e:row>
				<%--구매요청일자--%>
				<e:label for="PR_FROM_DATE" title="${form_PR_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="PR_FROM_DATE" toDate="PR_TO_DATE" name="PR_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_PR_FROM_DATE_R}" disabled="${form_PR_FROM_DATE_D}" readOnly="${form_PR_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="PR_TO_DATE" fromDate="PR_FROM_DATE" name="PR_TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_PR_TO_DATE_R}" disabled="${form_PR_TO_DATE_D}" readOnly="${form_PR_TO_DATE_RO}" />
				</e:field>
				<%--플랜트--%>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCode }" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
        	<e:row>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}" />
				<e:field>
					<e:inputText id="PR_NUM" name="PR_NUM" value="${form.PR_NUM}" width="${inputTextWidth }" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="50%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				</e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prTypeOptions}" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
        	<e:row>
				<%--요청자 / 부서명--%>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
				<e:field>
					<e:search id="REQ_USER_NM" style="ime-mode:auto" name="REQ_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_REQ_USER_NM_M}" onIconClick="${form_REQ_USER_NM_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" onKeyUp="removeUserId"/>
                    <e:inputHidden id="REQ_USER_ID" name="REQ_USER_ID" value="${ses.userId}"/>
					<e:text>&nbsp;</e:text>
					<e:inputText id="REQ_DEPT_NM" style="${imeMode}" name="REQ_DEPT_NM" value="${empty form.REQ_DEPT_NM ? ses.deptNm : form.REQ_DEPT_NM}" width="${inputTextWidth}" maxLength="${form_REQ_DEPT_NM_M}" disabled="${form_REQ_DEPT_NM_D}" readOnly="${form_REQ_DEPT_NM_RO}" required="${form_REQ_DEPT_NM_R}"/>
				</e:field>
				<%--진행상태--%>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
					<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}" options="${signStatusOptions}" width="${inputTextWidth}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
        	</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>