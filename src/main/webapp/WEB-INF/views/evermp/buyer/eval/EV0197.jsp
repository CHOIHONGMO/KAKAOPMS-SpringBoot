<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/EV0197';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');
        EVF.C('EV_CTRL_USER_NM').setValue('${ses.userNm}');
        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function (rowid, celname, value, iRow, iCol) {
        	 <%--셀 여러개 선택 방지--%>
        	if(selRow == undefined){
				selRow = rowid;
			}

			if (celname == "multiSelect") {
				if(selRow != rowid) {
					grid.checkRow(selRow, false);
					selRow = rowid;
				}
			}

			<%--평가 번호 클릭--%>
			if (celname == "EV_NUM") {
	        	var params = {
		                EV_NUM : grid.getCellValue(rowid, "EV_NUM")
		               ,POPUPFLAG : 'Y'
		               ,detailView    	: true
	                   ,havePermission : false
		            };
		        everPopup.openPopupByScreenId('EV0045', 950, 700, params);
	        }
	        else if (celname == "VENDOR_CD") {<%--협력사 코드 클릭--%>
	            var params = {
	                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
	                popupFlag: true,
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }
	        else if(celname == "EV_CNT"){<%--평가자 수 클릭 --%>
	        	var param = {
	   	        	EV_NUM :  grid.getCellValue(rowid, "EV_NUM"),
	    	    };
	        	 everPopup.openCommonPopup(param, "SP0043");

	        }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case '':

            default:
            }
        });

        grid.addRowEvent(function () {
            grid.addRow();
        });

        grid.delRowEvent(function () {
            grid.delRow();
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
        if(!everDate.checkTermDate('REQ_START_DATE','REQ_END_DATE','${msg.M0073}')) {
            return;
        }

        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }
        });
    }

	<%--평가완료--%>
   	function doComplete(){

   		<%--그리드 선택 하지 않앗을 경우--%>
        if (!grid.isExistsSelRow()) {
        	EVF.alert("${msg.M0004}"); <%--선택된 데이터가 없습니다.--%>
            return;
		}
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value; <%--선택된 row--%>

   		<%--평가자만 처리할 수 있습니다.--%>
   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			EVF.alert('${EV0197_EV_CTRL_USER}');
   			return;
   		}

   		<%--완료된 건은 처리할 수 없습니다.--%>
   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd == '300' || progress_cd == ''){
   			EVF.alert('${EV0197_PROGRESS_CD}');
   			return;_
   		}

   		<%--한사람 이상 평가가 되어야 합니다.--%>
   		var ev_cnt = grid.getCellValue(selRowId, 'EV_CNT');
   		if(ev_cnt.substring(0,1) == 0){
   			EVF.alert('${EV0197_EV_SCORE}');
   			return;
   		}

   		<%--완료처리--%>
   		EVF.confirm("${EV0197_doConfirm}", function () {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doConfirm', function () {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
   	}

   	<%--완료취소--%>
   	function doCancle(){
   		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

   		<%--평가자만 처리할 수 있습니다.--%>
   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			EVF.alert('${EV0197_EV_CTRL_USER}');
   			return;
   		}


   		<%--진행상태  평가완료--%>
   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			EVF.alert('${EV0197_PROGRESS_FINISH}');
   			return;
   		}

   		<%--결재중이거나 승인된 건은 처리불가--%>
   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			EVF.alert('${EV0197_SIGN_STATUS}');
   			return;
   		}

   		<%--완료 취소 처리--%>
   		EVF.confirm("${EV0197_doCancle}", function () {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doCancle', function () {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
   	}

   	<%--재평가--%>
   	function doReEval(){
   		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

   		<%--평가자만 처리할 수 있습니다.--%>
   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			EVF.alert('${EV0197_EV_CTRL_USER}');
   			return;
   		}

   		<%--진행상태 평가완료--%>
   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			EVF.alert('${EV0197_PROGRESS_FINISH}');
   			return;
   		}

   		<%--결재중이거나 승인된 건은 처리불가--%>
   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			EVF.alert('${EV0197_SIGN_STATUS}');
   			return;
   		}


   		<%--재평가 처리--%>
   		EVF.confirm("${EV0197_doReEval}", function () {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doReEval', function () {
				EVF.alert(this.getResponseMessage(), function() {
					EV0045_POPUP();
					doSearch();
                });
            });
        });
   	}

   	function EV0045_POPUP(){
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
   	 	var param = {
   	 		 VENDOR_CD: grid.getCellValue(selRowId, "VENDOR_CD")
   	 		,VENDOR_NM: grid.getCellValue(selRowId, "VENDOR_NM")
   	 		,EV_TYPE: "RE"
            ,detailView: false
            ,havePermission: false
   		};
   		everPopup.openPopupByScreenId('EV0045', 950, 700, param);
   	}

   	<%--부적합--%>
   	function doInconsist(){
   		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

   		<%--평가자만 처리할 수 있습니다.--%>
   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			EVF.alert('${EV0197_EV_CTRL_USER}');
   			return;
   		}
   		<%--진행상태   평가 완료만 처리가능--%>
   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			EVF.alert('${EV0197_PROGRESS_FINISH}');
   			return;
   		}
   		<%--결재중이거나 승인된 건은 처리불가--%>
   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			EVF.alert('${EV0197_SIGN_STATUS}');
   			return;
   		}

   		<%--완료 취소 처리--%>
   		EVF.confirm("${EV0197_doInconsist}", function () {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doInconsist', function () {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
   	}

   	<%--승인요청--%>
   	function doRequest(){

		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

   		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
		if (selRowId.length > 1) { return EVF.alert("${msg.M0006}"); }

   		<%--평가자만 처리할 수 있습니다.--%>
   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			EVF.alert('${EV0197_EV_CTRL_USER}');
   			return;
   		}
   		<%--진행상태 평가완료만 처리가능--%>
   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			EVF.alert('${EV0197_PROGRESS_FINISH}');
   			return;
   		}
   		<%--결재중이거나 승인된 건은 처리불가--%>
   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			EVF.alert('${EV0197_SIGN_STATUS}');
   			return;
   		}

        /*var userwidth  = 810; // 고정(수정하지 말것)
		var userheight = (screen.height - 2);
		if (userheight < 780) userheight = 780; // 최소 780
		var LeftPosition = (screen.width-userwidth)/2;
		var TopPosition  = (screen.height-userheight)/2;

		var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

   		if(confirm("${EV0197_doRequest}")){
   			var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doRequest', function() {
				doSearch();

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

				/!*
				var interval = window.setInterval(function() {
					try {
						if(win == null || win.closed) {
							window.clearInterval(interval);
							doSearch();
						}
					} catch (e) {}
				}, 1000);
				*!/
            });
   		}*/

		var param = {
			subject: grid.getCellValue(selRowId[0],'EV_NM'),
			docType: "VENDOR",
			signStatus: "P",
			screenId: "EV0197",
			approvalType: 'APPROVAL',
			oldApprovalFlag: grid.getCellValue(selRowId[0],'SIGN_STATUS'),
			attFileNum: "",
			docNum: grid.getCellValue(selRowId[0],'EV_NUM'),
			appDocNum: grid.getCellValue(selRowId[0],'APP_DOC_NUM'),
			callBackFunction: "goApproval"
		};

		everPopup.openApprovalRequestIIPopup(param);
   	}

	function goApproval(formData, gridData, attachData) {

		EVF.C('approvalFormData').setValue(formData);
		EVF.C('approvalGridData').setValue(gridData);
		EVF.C('attachFileDatas').setValue(attachData);

		var store = new EVF.Store();
		if(!store.validate()) return;

		store.doFileUpload(function() {
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + '/doRequest', function () {
				EVF.alert(this.getResponseMessage(), function() {
					doSearch();
                });
			});
		});
	}

   	<%--개선요청--%>
   	function doImprove(){

   		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

   		<%--평가자만 처리할 수 있습니다.--%>
   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			EVF.alert('${EV0197_EV_CTRL_USER}');
   			return;
   		}

   		<%--진행상태   평가완료만 처리가능--%>
   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			EVF.alert('${EV0197_PROGRESS_FINISH}');
   			return;
   		}

   		<%--결재중이거나 승인된 건은 처리불가--%>
   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			alert('${EV0197_SIGN_STATUS}');
   			return;
   		}

   		<%--완료 취소 처리--%>
   		EVF.confirm("${EV0197_doImprove}", function () {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doImprove', function () {
                EVF.alert(this.getResponseMessage(), function() {
                	SRM_530_POPUP();
                });
            });
        });

   	}

   	function SRM_530_POPUP(){
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
   	 	var param = {
   	 		 VENDOR_CD : grid.getCellValue(selRowId, "VENDOR_CD")
   	 		,VENDOR_NM : grid.getCellValue(selRowId, "VENDOR_NM")
   	 		,EV_NUM : grid.getCellValue(selRowId, "EV_NUM")
            ,detailView    : "false"
            ,havePermission : false
   		};
   		everPopup.openPopupByScreenId('EV0530', 950, 580, param);
   	}


    <%--협력사검색--%>
    function VENDOR(){<%--협력사 검색  --%>
		var param = {
    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0013');
    }
    function selectVendor(param){
    	EVF.C("VENDOR_NM").setValue(param.VENDOR_NM);
    	EVF.C("VENDOR_CD").setValue(param.VENDOR_CD);
    }

    <%--평가담당자 검색--%>
    function EV_CTRL_USER(){<%--평가담당자 검색 --%>
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }

    function selectEvCtrlUser(param){
    	EVF.C("EV_CTRL_USER_NM").setValue(param.USER_NM);
    	EVF.C("EV_CTRL_USER_ID").setValue(param.USER_ID);
    }

    </script>
	<e:window id="EV0197" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

		<e:inputHidden id="approvalFormData" name="approvalFormData"/>
		<e:inputHidden id="approvalGridData" name="approvalGridData"/>
		<e:inputHidden id="attachFileDatas" name="attachFileDatas" visible="false" />

		<e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
			<e:row>
				<%-- 요청일 --%>
				<e:label for="REQ_START_DATE" title="${form_REQ_START_DATE_N}"/>
				<e:field>
				<e:inputDate id="REQ_START_DATE" toDate="REQ_END_DATE" name="REQ_START_DATE" value="${form.REQ_START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REQ_START_DATE_R}" disabled="${form_REQ_START_DATE_D}" readOnly="${form_REQ_START_DATE_RO}" />
				<e:text>&nbsp; ~ &nbsp;</e:text>
				<e:inputDate id="REQ_END_DATE" fromDate="REQ_START_DATE" name="REQ_END_DATE" value="${form.REQ_END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REQ_END_DATE_R}" disabled="${form_REQ_END_DATE_D}" readOnly="${form_REQ_END_DATE_RO}" />
				</e:field>

				<%-- 진행상태 --%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<%-- 평가담당자  EV_CTRL_USER_ID--%>
				<e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
				<e:field>
				<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="100%" maxLength="${form_EV_CTRL_USER_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'EV_CTRL_USER'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_R}" required="${form_EV_CTRL_USER_NM_R}" />
				</e:field>
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>
				<%-- EV_CTRL_USER_ID --%>
			</e:row>
			<e:row>
				<%-- 협력사명 VENDOR_CD --%>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'VENDOR'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_R}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
				<%-- VENDOR_CD --%>
				<%-- 평가결과 --%>
				<e:label for="COMPLETE_STATUS_CD" title="${form_COMPLETE_STATUS_CD_N}"/>
				<e:field>
				<e:select id="COMPLETE_STATUS_CD" name="COMPLETE_STATUS_CD" value="${form.COMPLETE_STATUS_CD}" options="${completeStatusCdOptions}" width="${form_COMPLETE_STATUS_CD_W}" disabled="${form_COMPLETE_STATUS_CD_D}" readOnly="${form_COMPLETE_STATUS_CD_RO}" required="${form_COMPLETE_STATUS_CD_R}" placeHolder="" />
				</e:field>
				<%-- 평가구분 --%>
				<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
				<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
			<e:button id="doCancle" name="doCancle" label="${doCancle_N}" onClick="doCancle" disabled="${doCancle_D}" visible="${doCancle_V}"/>
			<e:button id="doReEval" name="doReEval" label="${doReEval_N}" onClick="doReEval" disabled="${doReEval_D}" visible="${doReEval_V}"/>
			<e:button id="doInconsist" name="doInconsist" label="${doInconsist_N}" onClick="doInconsist" disabled="${doInconsist_D}" visible="${doInconsist_V}"/>
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
		</e:buttonBar>

		<%-- 그리드 창 켜줌 --%>
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>
