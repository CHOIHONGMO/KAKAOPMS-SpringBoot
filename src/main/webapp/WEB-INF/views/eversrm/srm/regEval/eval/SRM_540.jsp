<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>



<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/regEval/eval/SRM_540';
    var grid ;
    var selRow;

    function init() {
        grid = EVF.getComponent('grid');
    	EVF.C('RH_USER_NM').setValue('${ses.userNm}');
    	EVF.C('RH_USER_ID').setValue('${ses.userId}');
    	grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			<%--셀 여러개 선택 방지 --%>
        	if(selRow == undefined){
				selRow = rowid;
			}
			if (celname == "multiSelect") {
				if(selRow != rowid) {
					grid.checkRow(selRow, false);
					selRow = rowid;
				}
			}

        	if (celname == "RH_NUM") {
	            var param = {
	                RH_NUM: grid.getCellValue(rowid, "RH_NUM")
	        		   /* ,GATE_CD  : grid.getCellValue(rowid,'GATE_CD')--%>
	                   */
	                   ,detailView    : "true"
	                   ,havePermission : false
	            };
	            everPopup.openPopupByScreenId('SRM_530', 950, 580, param);
	        } else if (celname == "VENDOR_CODE") {
	            var params = {
		                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CODE"),
		                popupFlag: true,
		                detailView : true
		            };
		        everPopup.openSupManagementPopup(params);
		    }

		});

	    grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
	        switch(colId) {
	        case '':

	        default:
	        }
	    });

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


    }
	<%--조회--%>
    function doSearch() {
    	<%-- 날짜 체크--%>
        if(!everDate.checkTermDate('RH_DATE_FROM','RH_DATE_TO','${msg.M0073}')) {
            return;
        }
        var store = new EVF.Store();
        if(!store.validate()) return;

        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }


	<%--/////////////////[완료버튼 event]////////////////--%>
    function doConfirm() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
		}
		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
		var rh_user_id = grid.getCellValue(selRowId, 'RH_USER_ID');
		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');

		if(rh_user_id != '${ses.userId}'){
			alert('${SRM_540_RH_USER_ID}');<%--평가자만 가능합니다.--%>
			return;
		}
		if(progress_cd != '300'){
			if(progress_cd == '100'){
				alert('${SRM_540_PROGRESS_C}'); <%--전송되지않은 상태이면 처리불가--%>
				return;
			}else if(progress_cd == '400'){
				alert('${SRM_540_PROGRESS_A}'); <%--이미 조치완료된 상태이면 처리불가--%>
				return;
			}else{
				alert('${SRM_540_PROGRESS_D}'); <%--협력회사 완료 상태가 아니면 처리불가--%>
				return;
			}
		}

        if (confirm("${msg.M0025}")) {<%--승인하시겠습니까?--%>
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doConfirm', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
        }
    }

    function doReject(){
    	if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

    	var selRowId 	= grid.jsonToArray(grid.getSelRowId()).value;
		var rh_user_id 	= grid.getCellValue(selRowId, 'RH_USER_ID');
		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');

		if(rh_user_id != '${ses.userId}'){
			alert('${SRM_540_RH_USER_ID}');<%--평가자만 가능합니다.--%>
			return;
		}
		if(progress_cd != '400'){
			alert('${SRM_540_PROGRESS_B}'); <%--완료되지 않은 상태이면 처리가 불가능합니다.--%>
			return;
		}

    	if (confirm("${msg.M0022}")) {
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doReject', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
        }

    }

    <%--개선조치현황 수정 팝업--%>
    function doEdit(){
    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
    	var rh_user_id = grid.getCellValue(selRowId, 'RH_USER_ID');

		if (selRowId.length == 0) {
            alert("${msg.M0004}");
            return;
        }
        if (selRowId.length > 1) {
            alert("${msg.M0006}");
            return;
        }

        if(rh_user_id != '${ses.userId}'){
			alert('${SRM_540_RH_USER_ID}');<%--평가자만 가능합니다.--%>
			return;
		}

	    var param = {
	        RH_NUM: grid.getCellValue(selRowId[0], "RH_NUM")
	           ,detailView    : "false"
	           ,havePermission : false
	    };
	    everPopup.openPopupByScreenId('SRM_530', 950, 580, param);
    }


    <%-- 협력회사명 팝업(Form)--%>
    function searchVendorNm() {
      if("${ses.userType}" == 'S'){return;}
      var param = {
        callBackFunction : 'doSetVendorNmForm'
      };
      everPopup.openCommonPopup(param, 'SP0013');
    }

    <%-- 협력회사명 팝업 셋팅(Form)--%>
    function doSetVendorNmForm(data) {
      EVF.getComponent("VENDOR_NM").setValue(data.VENDOR_NM);
      EVF.getComponent("VENDOR_CD").setValue(data.VENDOR_CD);
      alert('nm=='+EVF.getComponent('VENDOR_NM').getValue()+' :  cd=='+EVF.getComponent('VENDOR_CD').getValue());
    }

    <%-- 담당자 검색 팝업(Form)--%>
    function searchRHUser(){
    	var param = {
    		callBackFunction : 'doSetRhUserForm'
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }

    function doSetRhUserForm(data) {
        EVF.getComponent("RH_USER_ID").setValue(data.USER_ID);
        EVF.getComponent("RH_USER_NM").setValue(data.USER_NM);

    }



    </script>
<e:window id="SRM_540" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" >
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
	    <%-- 평가일자 , 진행상태 --%>
	    <e:row>
	    	<%-- 평가일자 --%>
	    	<e:label for="RH_DATE_FROM" title="${form_RH_DATE_FROM_N}"/>
			<e:field>
			<e:inputDate id="RH_DATE_FROM" toDate="RH_DATE_TO" name="RH_DATE_FROM" value="${form.RH_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_RH_DATE_FROM_R}" disabled="${form_RH_DATE_FROM_D}" readOnly="${form_RH_DATE_FROM_RO}" />
			<e:text>~&nbsp;</e:text>
			<e:inputDate id="RH_DATE_TO" fromDate="RH_DATE_FROM" name="RH_DATE_TO" value="${form.RH_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_RH_DATE_TO_R}" disabled="${form_RH_DATE_TO_D}" readOnly="${form_RH_DATE_TO_RO}" />
			</e:field>

			<%-- 진행상태 --%>
			<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
			<e:field>
			<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
			</e:field>
	    <%-- 차종, 평가담당자 --%>
	    	<%-- 차종 --%>
	    	<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}" />
			<e:field>
			<e:inputText id="MAT_GROUP" style="ime-mode:inactive" name="MAT_GROUP" value="${form.MAT_GROUP}" width="100%" maxLength="${form_MAT_GROUP_M}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}"/>
			</e:field>
	    </e:row>
		<e:row>
			<%-- 평가닫당자 --%>
			<e:label for="RH_USER_NM" title="${form_RH_USER_NM_N}"/>
			<e:field>
			<e:search id="RH_USER_NM" style="${imeMode}" name="RH_USER_NM" value="" width="100%" maxLength="${form_RH_USER_NM_M}" onIconClick="${form_RH_USER_NM_RO ? 'everCommon.blank' : 'searchRHUser'}" disabled="${form_RH_USER_NM_D}" readOnly="false" required="${form_RH_USER_NM_R}" />
			</e:field>
			<e:inputHidden id="RH_USER_ID" name="RH_USER_ID" value="${form.RH_USER_ID}"/>
		    <%-- 협력회사 제목 --%>
			<%-- 협력회사  --%>
			<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
			<e:field>
			<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="searchVendorNm" disabled="${form_VENDOR_NM_D}" readOnly="false" required="${form_VENDOR_NM_R}" />
			<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
			</e:field>

			<%-- 제목 --%>
			<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
			<e:field>
			<e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
			</e:field>
	    </e:row>
    </e:searchPanel>

    <e:buttonBar id="buttonBar" width="100%" align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>

    	<e:button id="doEdit" name="doEdit" label="${doEdit_N}" onClick="doEdit" disabled="${doEdit_D}" visible="${doEdit_V}"/>
    	<e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
    	<e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>

    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

</e:window>
</e:ui>
