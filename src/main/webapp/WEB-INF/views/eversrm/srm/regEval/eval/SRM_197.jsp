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

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/regEval/eval/SRM_197';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');
        EVF.C('EV_CTRL_USER_NM').setValue('${ses.userNm}');
        EVF.C('EV_CTRL_USER_ID').setValue('${ses.userId}');
        grid.setProperty('panelVisible', ${panelVisible});

        grid.showCheckBar(false);
        //grid.setProperty('shrinkToFit', true);
        grid.cellClickEvent(function (rowid, celname, value, iRow, iCol) {

        	if(selRow == undefined){
				selRow = rowid;
			}
			if (celname == "multiSelect") {
				if(selRow != rowid) {
					grid.checkRow(selRow, false);
					selRow = rowid;
				}
			}

			if (celname == "EV_SCORE") {


                var param = {
                    evTplNum : grid.getCellValue(rowid, 'EV_TPL_NUM'),
                    evNum : grid.getCellValue(rowid, 'EV_NUM'),
                    vendorCd : grid.getCellValue(rowid, 'VENDOR_CD'),
                    titleName : grid.getCellValue(rowid, 'EV_NM'),
                    progressCd : grid.getCellValue(rowid, 'VENDOR_PROGRESS_CD'),
                    confYN : 'Y',
                    detailView : false
                };

                everPopup.pcEVInfoSearch(param);

//	        	var params = {
//		                EV_NUM : grid.getCellValue(rowid, "EV_NUM")
//		               ,POPUPFLAG : 'Y'
//		               ,detailView    	: true
//	                   ,havePermission : false
//		            };
//		        everPopup.openPopupByScreenId('SRM_045', 950, 580, params);
	        }


	        <%--else if (celname == "VENDOR_CD") {&lt;%&ndash;협력회사 코드 클릭&ndash;%&gt;--%>
	            <%--var params = {--%>
	                <%--VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),--%>
	                <%--popupFlag: true,--%>
	                <%--detailView : true--%>
	            <%--};--%>
	            <%--everPopup.openSupManagementPopup(params);--%>
	        <%--}--%>
	        else if(celname == "EV_CNT"){
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
				 imgWidth      : 0.12
				,imgHeight     : 0.26
				,colWidth      : 20
				,rowSize       : 500
		        ,attachImgFlag : false
		    }
		});

    }


    function doSearch() {

        if(!everDate.checkTermDate('REQ_START_DATE','REQ_END_DATE','${msg.M0073}')) {
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


   	function doComplete(){


   		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
		}
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;


   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			alert('${SRM_197_EV_CTRL_USER}');
   			return;
   		}


   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd == '300' || progress_cd == ''){
   			alert('${SRM_197_PROGRESS_CD}');
   			return;_
   		}


   		var ev_cnt = grid.getCellValue(selRowId, 'EV_CNT');
   		if(ev_cnt.substring(0,1) == 0){
   			alert('${SRM_197_EV_SCORE}');
   			return;
   		}



   		if (confirm("${SRM_197_doConfirm}")) {

            var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doConfirm', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
        }
   	}



   	function doCancle(){
   		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;


   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			alert('${SRM_197_EV_CTRL_USER}');
   			return;
   		}



   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			alert('${SRM_197_PROGRESS_FINISH}');
   			return;
   		}


   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			alert('${SRM_197_SIGN_STATUS}');
   			return;
   		}


   		if(confirm("${SRM_197_doCancle}")){
   			var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doCancle', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
   		}
   	}

   	function doReEval(){
   		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;


   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			alert('${SRM_197_EV_CTRL_USER}');
   			return;
   		}

   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			alert('${SRM_197_PROGRESS_FINISH}');
   			return;
   		}

   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			alert('${SRM_197_SIGN_STATUS}');
   			return;
   		}



   		if(confirm("${SRM_197_doReEval}")){
   			var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doReEval', function() {
            	alert(this.getResponseMessage());
            	SRM_045_POPUP();
            });
   		}
   	}
   	function SRM_045_POPUP(){
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
   	 	var param = {
   	 		 VENDOR_CD : grid.getCellValue(selRowId, "VENDOR_CD")
   	 		,VENDOR_NM : grid.getCellValue(selRowId, "VENDOR_NM")
   	 		,EV_TYPE : "RE"
            ,detailView    : "false"
            ,havePermission : false
   		};
   		everPopup.openPopupByScreenId('SRM_045', 950, 580, param);
   	}


   	function doInconsist(){
   		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;


   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			alert('${SRM_197_EV_CTRL_USER}');
   			return;
   		}

   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			alert('${SRM_197_PROGRESS_FINISH}');
   			return;
   		}

   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			alert('${SRM_197_SIGN_STATUS}');
   			return;
   		}


   		if(confirm("${SRM_197_doInconsist}")){
   			var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doInconsist', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
   		}
   	}

   	function doRequest(){

		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

   		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
		if (selRowId.length > 1) { return alert("${msg.M0006}"); }


   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			alert('${SRM_197_EV_CTRL_USER}');
   			return;
   		}

   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			alert('${SRM_197_PROGRESS_FINISH}');
   			return;
   		}

   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			alert('${SRM_197_SIGN_STATUS}');
   			return;
   		}

        /*var userwidth  = 810; //
		var userheight = (screen.height - 2);
		if (userheight < 780) userheight = 780; // 최소 780
		var LeftPosition = (screen.width-userwidth)/2;
		var TopPosition  = (screen.height-userheight)/2;

		var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

   		if(confirm("${SRM_197_doRequest}")){
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
			screenId: "SRM_197",
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

		EVF.getComponent('approvalFormData').setValue(formData);
		EVF.getComponent('approvalGridData').setValue(gridData);
		EVF.getComponent('attachFileDatas').setValue(attachData);

		var store = new EVF.Store();
		if(!store.validate()) return;

		store.doFileUpload(function() {
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + '/doRequest', function () {
				alert(this.getResponseMessage());
				if (this.getParameter('legacy_key') == 'ERROR') {
					alert(this.getResponseMessage());

				} else {
					window.close();

					doSearch();
				}
			});
		});
	}


   	function doImprove(){

   		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
   		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;


   		var ctrl_user = grid.getCellValue(selRowId, 'EV_CTRL_USER_ID');
   		if(ctrl_user != '${ses.userId}'){
   			alert('${SRM_197_EV_CTRL_USER}');
   			return;
   		}

   		var progress_cd = grid.getCellValue(selRowId, 'PROGRESS_CD');
   		if(progress_cd != '300'){
   			alert('${SRM_197_PROGRESS_FINISH}');
   			return;
   		}

   		var sign_status = grid.getCellValue(selRowId, 'SIGN_STATUS');
   		if(sign_status == 'P' || sign_status == 'E'){
   			alert('${SRM_197_SIGN_STATUS}');
   			return;
   		}

   		if(confirm("${SRM_197_doImprove}")){
   			var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doImprove', function() {
            	alert(this.getResponseMessage());
            	SRM_530_POPUP();
            });
   		}
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
   		everPopup.openPopupByScreenId('SRM_530', 950, 580, param);
   	}



    function searchVendorCd(){
		var param = {
    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0063');
    }
    function selectVendor(param){
    	EVF.getComponent("VENDOR_NM").setValue(param.VENDOR_NM);
    	EVF.getComponent("VENDOR_CD").setValue(param.VENDOR_CD);
    }

    function cleanCustNm() {
        EVF.V("VENDOR_CD","");
    }


    function EV_CTRL_USER(){
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0087');
    }
    function selectEvCtrlUser(param){
    	EVF.getComponent("EV_CTRL_USER_NM").setValue(param.USER_NM);
    	EVF.getComponent("EV_CTRL_USER_ID").setValue(param.USER_ID);
    }

    function cleanCtrlNm() {
        EVF.V("EV_CTRL_USER_ID","");
    }


    </script>
<e:window id="SRM_197" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
	<e:inputHidden id="approvalFormData" name="approvalFormData"/>
	<e:inputHidden id="approvalGridData" name="approvalGridData"/>
	<e:inputHidden id="attachFileDatas" name="attachFileDatas" visible="false" />

    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
    <e:row>
		<e:label for="REQ_START_DATE" title="${form_REQ_START_DATE_N}"/>
		<e:field>
		<e:inputDate id="REQ_START_DATE" toDate="REQ_END_DATE" name="REQ_START_DATE" value="${form.REQ_START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_START_DATE_R}" disabled="${form_REQ_START_DATE_D}" readOnly="${form_REQ_START_DATE_RO}" />
		<e:text>~</e:text>
		<e:inputDate id="REQ_END_DATE" fromDate="REQ_START_DATE" name="REQ_END_DATE" value="${form.REQ_END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_END_DATE_R}" disabled="${form_REQ_END_DATE_D}" readOnly="${form_REQ_END_DATE_RO}" />
		</e:field>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
		</e:field>
		<e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
		<e:field>
		<e:search id="EV_CTRL_USER_ID" style="ime-mode:inactive" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}" width="40%" maxLength="${form_EV_CTRL_USER_ID_M}" onIconClick="${form_EV_CTRL_USER_ID_RO ? 'everCommon.blank' : 'EV_CTRL_USER'}" disabled="${form_EV_CTRL_USER_ID_D}" readOnly="${form_EV_CTRL_USER_ID_RO}" required="${form_EV_CTRL_USER_ID_R}" />
		<e:inputText id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="60%" maxLength="${form_EV_CTRL_USER_NM_M}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}"  />
		</e:field>
    </e:row>
	<e:row>
		<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
		<e:field>
			<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
			<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		</e:field>
		<e:label for="COMPLETE_STATUS_CD" title="${form_COMPLETE_STATUS_CD_N}"/>
		<e:field>
		<e:select id="COMPLETE_STATUS_CD" name="COMPLETE_STATUS_CD" value="${form.COMPLETE_STATUS_CD}" options="${completeStatusCdOptions}" width="${form_COMPLETE_STATUS_CD_W}" disabled="${form_COMPLETE_STATUS_CD_D}" readOnly="${form_COMPLETE_STATUS_CD_RO}" required="${form_COMPLETE_STATUS_CD_R}" placeHolder="" />
		</e:field>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field>
		<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    	<%--<e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>--%>
    	<%--<e:button id="doCancle" name="doCancle" label="${doCancle_N}" onClick="doCancle" disabled="${doCancle_D}" visible="${doCancle_V}"/>--%>
    	<%--<e:button id="doReEval" name="doReEval" label="${doReEval_N}" onClick="doReEval" disabled="${doReEval_D}" visible="${doReEval_V}"/>--%>
    	<%--<e:button id="doInconsist" name="doInconsist" label="${doInconsist_N}" onClick="doInconsist" disabled="${doInconsist_D}" visible="${doInconsist_V}"/>--%>
    	<%--<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>--%>
    	<%--<e:button id="doImprove" name="doImprove" label="${doImprove_N}" onClick="doImprove" disabled="${doImprove_D}" visible="${doImprove_V}"/>--%>
    </e:buttonBar>

    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

</e:window>
</e:ui>
