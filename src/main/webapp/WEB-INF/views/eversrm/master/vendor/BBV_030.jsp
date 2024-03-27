<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

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
	var addParam = [];
	var baseUrl = "/eversrm/master/vendor/";
    var selRow;

    function init() {
		grid = EVF.C('grid');
        grid.setProperty('panelVisible', ${panelVisible});
        grid.setProperty('singleSelect', true);

        var cols = [];
        var col = [];
        var cnt = 0;
        <c:forEach varStatus="status" var="columnx" items="${columnInfos}">
            grid.createColumn('${columnx.EV_NUM}', '${columnx.EV_NUM}', 0, 'center', 'text', 50, false,false, '', 0);
            col.push('${columnx.EV_NUM}');

            grid.createColumn('${columnx.EV_NM}', '${columnx.EV_NM}', 0, 'center', 'text', 50, false,false, '', 0);
            col.push('${columnx.EV_NM}');

            grid.createColumn('${columnx.P_CD}', '${columnx.P_CD}', 0, 'center', 'text', 50, false,false, '', 0);
            col.push('${columnx.P_CD}');

            grid.createColumn('${columnx.SCORE}', '${columnx.EV_TPL_SUBJECT}', 180, 'center', 'textLink', 50, false,false, '', 0);
            col.push('${columnx.SCORE}');

            cols[cnt] = col;
            col = [];
            cnt++;

        </c:forEach>

            grid.createColumn('REG_DATE', '${BBV_030_CAPTION1}', 110, 'center', 'text', 200, false,false, '', 0);
            col.push('REG_DATE');
            grid.createColumn('SIGN_STATUS', '${BBV_030_CAPTION2}', 80, 'center', 'text', 200, false,false, '', 0);
            col.push('SIGN_STATUS');
            grid.createColumn('SIGN_DATE', '${BBV_030_CAPTION0}', 110, 'center', 'text', 200, false,false, '', 0);
            col.push('SIGN_DATE');

        grid._maskDefinitions = ["CEO_USER_NM#N","REP_TEL_NUM#A"];


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

		grid.cellClickEvent(function(rowId,	colId, value) {
	        if (colId == "VENDOR_CD") {
                var param = {
                    'VENDOR_CD': grid.getCellValue(rowId, "VENDOR_CD"),
                    'detailView': true,
                    'popupFlag': true
                };
                everPopup.openPopupByScreenId("M03_003", 1100, 750, param);
	        }

            <c:forEach varStatus="status" var="columnx" items="${columnInfos}">

            if (colId == '${columnx.SCORE}') {
                if(grid.getCellValue(rowId, "${columnx.SCORE}")!=""){
                    var param = {
                        evTplNum : "${columnx.EV_TPL_NUM}",
                        evNum : grid.getCellValue(rowId, "${columnx.EV_NUM}"),
                        vendorCd : grid.getCellValue(rowId, 'VENDOR_CD'),
                        titleName : grid.getCellValue(rowId, "${columnx.EV_NM}"),
                        progressCd : grid.getCellValue(rowId, 'PROGRESS_CD'),
                        confYN : 'Y',
                        detailView : false
                    };
                    everPopup.pcEVInfoSearch(param);
                }
            }

            </c:forEach>

		});

		EVF.C('PROGRESS_CD').setValue('P');
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;

        if(!everDate.checkTermDate('REG_FROM_DATE','REG_TO_DATE','${msg.M0073}')) {
            return;
        }

        store.setGrid([grid]);
        store.load(baseUrl + 'BBV_030/doSelect', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }
    function doEditVendor() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        var vendorCd = "";
        var progress_cd ="";
        var rowIds = grid.getSelRowId();
        var param = {};
        for(var i in rowIds) {
            vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
            progress_cd = grid.getCellValue(rowIds[i],'PROGRESS_CD');
        }

        if(progress_cd=="E") {

            return alert('${BBV_030_0001}');

        }else{
            param = {
                'VENDOR_CD': vendorCd,
                'detailView': false,
                'popupFlag': true
            };
        }

        everPopup.openPopupByScreenId("M03_003", 1100, 750, param);

        <%--var selRowId = grid.jsonToArray(grid.getSelRowId()).value;--%>
        <%--for (var i = 0; i < selRowId.length; i++) {--%>
//            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            <%--var signStatus = grid.getCellValue(selRowId[i], "SIGN_STATUS");--%>
            <%--var vendor_cd = grid.getCellValue(selRowId[i], "VENDOR_CD");--%>
            <%--if (progress_cd == "E" || signStatus == 'P' || signStatus == 'E') {--%>
                <%--alert("${msg.M0047 }");--%>
                <%--return;--%>
            <%--}--%>
            <%--var params = {--%>
                    <%--VENDOR_CD : vendor_cd,--%>
                    <%--paramPopupFlag: 'N',--%>
                    <%--onClose: 'closePopupAndRequeryParent ',--%>
                    <%--detailView : false--%>
                <%--}; --%>
            <%--everPopup.openSupManagementPopup(params);      --%>
            <%--return;--%>
     	<%--}--%>
    }

    function doConfirm() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            if (progress_cd == "E") {
                alert("${msg.M0045 }");
                return;
            }
     	}
        if (confirm("${msg.M0025}")) {
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BBV_030/doConfirm', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
        }
    	<%--
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            if (progress_cd == "E" || progress_cd == 'R' ) {
                alert("${msg.M0045 }");
                return;
            }
     	}

        var userwidth  = 810;
		var userheight = (screen.height - 2);
		if (userheight < 780) userheight = 780; //
        var LeftPosition = (screen.width-userwidth)/2;
        var TopPosition  = (screen.height-userheight)/2;
        var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

        if (confirm("${msg.M0025}")) {
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BBV_030/doConfirm', function() {
            	//alert(this.getResponseMessage());
	    		var url;
	    		var gwUserId;
	    		if ('${devFlag}' == 'true') {
	    			gwUserId = 'hspark03';
	    		} else {
	    			gwUserId = '${ses.userId}';
	    		}
	    		url = "${gwUrl}"+gwUserId+"${gwParam}"+this.getParameter('legacy_key');
                var win = window.open(url, "signwindow", gwParam);

                var interval = window.setInterval(function() {
                    try {
                        if(win == null || win.closed) {
                            window.clearInterval(interval);
                            doSearch();
                        }
                    } catch (e) {}
                }, 1000);
            });
        }
        --%>
    }


<%--
    function doReject() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            if (progress_cd == "E" || progress_cd == 'R' ) {
                alert("${msg.M0045 }");
                return;
            }

            if(grid.getCellValue(selRowId[i], 'REJECT_RMK') == "") {
                //grid.setCellStyle(selRowId[i], "REJECT_RMK", 'background-color', '#fdd');
                grid.setCellBgColor(selRowId[i], "REJECT_RMK", '#fdd');
                alert("${BBV_030_0001}");
                return;
            }
     	}
        if (confirm("${msg.M0022}")) {
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BBV_030/doReject', function() {
            	alert(this.getResponseMessage());
            	doSearch();
            });
        }
    }--%>
    function doRequestApp() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
		}
        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        var gate_cdl              ='';
        var subjectl               ='';
        var oldApprovalFlagl ='';
        var app_doc_num     ='';
        var app_doc_cnt       ='';
        for (var i = 0; i < selRowId.length; i++) {
            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            var signStatus = grid.getCellValue(selRowId[i], "SIGN_STATUS");
            if (signStatus == "E"    ) {
                alert("${BBV_030_finish_approved }");
                return;
            }
            if (signStatus == "P"    ) {
                alert("${BBV_030_prosessing_approval }");
                return;
            }

            gate_cdl              = grid.getCellValue(selRowId[i] , 'GATE_CD');
            subjectl               = grid.getCellValue(selRowId[i]  , 'VENDOR_NM');
            oldApprovalFlagl = grid.getCellValue(selRowId[i], 'SIGN_STATUS');
            app_doc_num     = grid.getCellValue(selRowId[i]   , 'APP_DOC_NUM');
            app_doc_cnt       = grid.getCellValue(selRowId[i]   , 'APP_DOC_CNT');
     	}
        var param = {
                subject: subjectl,
                oldApprovalFlag: oldApprovalFlagl,
                gateCd: gate_cdl,
                docNum: app_doc_num,
                docCnt: app_doc_cnt
            };
            everPopup.openApprovalRequestPopup(param);
    }

    function doSendConf() {
        var	selectFormNnum = this.getData();

        if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
        var store = new EVF.Store();

        var rowIds = grid.getSelRowId();
        for(var i in rowIds) {

            if(grid.getCellValue(rowIds[i], 'PROGRESS_CD')=="C"){
                return alert('${BBV_030_0003}');
            }

            <c:forEach varStatus="status" var="columnx" items="${columnInfos}">
                if(grid.getCellValue(rowIds[i], "${columnx.P_CD}")=='100'){
                    return alert('${BBV_030_0002}');
                }
            </c:forEach>
            EVF.V("VENDOR_PIC_USER_NM",selectFormNnum);
            EVF.V("VENDOR_CD",grid.getCellValue(rowIds[i], 'VENDOR_CD'));
            EVF.V("VENDOR_NM",grid.getCellValue(rowIds[i], 'VENDOR_NM'));
            EVF.V("VENDOR_PROGRESS_CD",grid.getCellValue(rowIds[i], 'PROGRESS_CD'));
        }

        EVF.V("SELECT_FORM_NUM",'');
        var contractFormJson = store._getFormDataAsJson();
        EVF.V("contractForm",contractFormJson.replace(/"/gi, '\''));
        if(selectFormNnum=='FORM2017080100001'){
            EVF.C("mainForm").setValue("[{'FORM_GUBUN':'TBA','FORM_NM':'${BBV_030_CAPTION3}','GATE_CD':'100','FORM_NUM':'FORM2017080100001','FORM_TYPE':'100','DEPT_NM':''}]");
            EVF.V("CONT_DESC","${BBV_030_CAPTION4}["+EVF.V("VENDOR_NM")+"]");
        }else if(selectFormNnum=='FORM2017080300004'){
            EVF.C("mainForm").setValue("[{'FORM_GUBUN':'TBA','FORM_NM':'${BBV_030_CAPTION5}','GATE_CD':'100','FORM_NUM':'FORM2017080300004','FORM_TYPE':'100','DEPT_NM':''}]");
            EVF.V("CONT_DESC","${BBV_030_CAPTION6}["+EVF.V("VENDOR_NM")+"]");
        }else{
            EVF.C("mainForm").setValue("[{}]");
        }

        EVF.V("additionalForm",[]);
        EVF.V("baseDataType","contract");
        EVF.V("contractEditable",true);
        EVF.V("detailView",false);



        var param = {
            'GATE_CD'  : '${ses.gateCd}'
            ,'EXEC_NUM' : EVF.V("EXEC_NUM")
            ,'EXEC_CNT' : ""
            //,'RFXTYPE' :rfxType
            ,'SELECT_FORM_NUM': EVF.V("SELECT_FORM_NUM")
            ,'contractForm': EVF.V("contractForm")
            ,'mainForm': EVF.V("mainForm")
            ,'additionalForm': EVF.V("additionalForm")
            ,'baseDataType':EVF.V("baseDataType")
            ,'contractEditable':EVF.V("contractEditable")
            ,'detailView': EVF.V("detailView")
            ,'contReqFlag': EVF.V("contReqFlag")
            ,'VENDOR_PIC_USER_NM': EVF.V("VENDOR_PIC_USER_NM")
            ,'CONT_WT_NUM': EVF.V("CONT_WT_NUM")
            ,'openerCallBackFunction': ""
            ,'CONT_PLACE': ""
            ,'CONT_DESC': EVF.V("CONT_DESC")
            ,'CONT_DATE': EVF.V("CONT_DATE")
            ,'CONT_USER_ID':EVF.V("CONT_USER_ID")
            ,'CONT_AMT': ""
            ,'VENDOR_CD': EVF.V("VENDOR_CD")
            ,'VENDOR_NM' : EVF.V("VENDOR_NM")
            ,'VENDOR_PROGRESS_CD' : EVF.V("VENDOR_PROGRESS_CD")
            ,'st_CONT_REQ_CD': "L"
            ,'CONT_REQ_CD': "01"
            ,'MANUAL_CONT_FLAG': "0"
            ,'PLANT_CD': ""
            ,'BUYER_CD': '${ses.companyCd}'
            ,'CONT_REQ_RMK':  ""
            ,'VENDOR_CONF_Y' :"Y"
            ,'DATATYPEFLAG': EVF.V("DATATYPEFLAG")
        };

        //console.log(param);
        var url ='/eversrm/eContract/eContractMgt/BECM_030/view.so?';
        //window.location.href = url + $.param(param);
        everPopup.openWindowPopup(url, 1200, 800, param);

        EVF.V("contractForm","");
        EVF.V("mainForm","");
    }


    function approvalCallBack(dataJsonArray) {
	    dataJsonArray = JSON.parse(dataJsonArray);
        EVF.C('approvalFormData').setValue(dataJsonArray.formData);
        EVF.C('approvalGridData').setValue(dataJsonArray.gridData);
        EVF.C('APPROVAL_FLAG').setValue('P');
    }
    function getApproval() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
        store.load(baseUrl + 'BBV_030/getApproval', function() {
        	alert(this.getResponseMessage());
        	doSearch();
        });
    }

    function searchVendorCd() {
        var param = {
            callBackFunction : "selectVendorCd"
        };
        everPopup.openCommonPopup(param, 'SP0079');
    }

    function selectVendorCd(dataJsonArray) {
        EVF.C("S_VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
        EVF.C("S_VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
    }

    </script>
    <e:window id="BBV_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
            <e:inputHidden id="GATE_CD" name="GATE_CD" value="${ses.gateCd}" />
            <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="" />
            <e:inputHidden id="SELECT_FORM_NUM" name="SELECT_FORM_NUM" value="" />
            <e:inputHidden id="contractForm" name="contractForm"  value=""/>
            <e:inputHidden id="mainForm" name="mainForm"  value=""/>
            <e:inputHidden id="additionalForm" name="additionalForm"/>
            <e:inputHidden id="baseDataType" name="baseDataType" />
            <e:inputHidden id="contractEditable" name="contractEditable"/>
            <e:inputHidden id="detailView" name="detailView" />
            <e:inputHidden id="contReqFlag" name="contReqFlag" value="01"/>
            <e:inputHidden id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="" />
            <e:inputHidden id="CONT_WT_NUM" name="CONT_WT_NUM" value="" />
            <e:inputHidden id="openerCallBackFunction" name="openerCallBackFunction" value="" />
            <e:inputHidden id="CONT_PLACE" name="CONT_PLACE" value="" />
            <e:inputHidden id="CONT_DESC" style="${imeMode}" name="CONT_DESC" value="" />
            <e:inputHidden id="CONT_DATE" name="CONT_DATE" value="${toDate }"/>
            <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId }" />
            <e:inputHidden id="CONT_AMT" name="CONT_AMT"  value="" />
            <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"  />
            <e:inputHidden id="VENDOR_NM" name="VENDOR_NM" value="${param.VENDOR_NM}"  />
            <e:inputHidden id="VENDOR_PROGRESS_CD" name="VENDOR_PROGRESS_CD" value="${param.VENDOR_PROGRESS_CD}"  />
            <e:inputHidden id="st_CONT_REQ_CD" name="st_CONT_REQ_CD" value="L"  />
            <e:inputHidden id="CONT_REQ_CD" name="CONT_REQ_CD" value="01"  />
            <e:inputHidden id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="0"/>
            <e:inputHidden id="PLANT_CD" name="PLANT_CD" onChange="getBuyerCd" value="" />
            <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" />
            <e:inputHidden id="CONT_REQ_RMK"  name="CONT_REQ_RMK"  value=""/>
            <e:inputHidden id="DATATYPEFLAG"  name="DATATYPEFLAG"  value="manual"/>




        	<e:row>
                <e:label for="S_VENDOR_CD" title="${form_S_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="S_VENDOR_CD" style="ime-mode:inactive" name="S_VENDOR_CD" value="" width="40%" maxLength="${form_S_VENDOR_CD_M}" onIconClick="${form_S_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_S_VENDOR_CD_D}" readOnly="${form_S_VENDOR_CD_RO}" required="${form_S_VENDOR_CD_R}" />
                    <e:inputText id="S_VENDOR_NM" style="${imeMode}" name="S_VENDOR_NM" value="" width="60%" maxLength="${form_S_VENDOR_NM_M}" disabled="${form_S_VENDOR_NM_D}" readOnly="${form_S_VENDOR_NM_RO}" required="${form_S_VENDOR_NM_R}" />
                    <e:inputHidden id="approvalFormData" name="approvalFormData"/>
                    <e:inputHidden id="approvalGridData" name="approvalGridData"/>
                    <e:inputHidden id="APPROVAL_FLAG" name="APPROVAL_FLAG"/>
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions }" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="REG_TYPE" title="${form_REG_TYPE_N}" />
                <e:field>
                    <e:select id="REG_TYPE" name="REG_TYPE" value="${formData.REG_TYPE }" options="${regTypeOptions }" width="${form_REG_TYPE_W}" disabled="${form_REG_TYPE_D}" readOnly="${form_REG_TYPE_RO}" required="${form_REG_TYPE_R}" placeHolder="" />
                </e:field>
			</e:row>
        	<e:row>
                <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"/>
                <e:field>
                    <e:inputText id="IRS_NUM" name="IRS_NUM" value="${form.IRS_NUM}" width="${form_IRS_NUM_W}"  maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" style='ime-mode:inactive'/>
                </e:field>
                <e:label for="PAY_CD" title="${form_PAY_CD_N}"/>
                <e:field>
                    <e:inputText id="PAY_CD" name="PAY_CD" value="${form.PAY_CD}" width="${form_PAY_CD_W}" maxLength="${form_PAY_CD_M}" disabled="${form_PAY_CD_D}" readOnly="${form_PAY_CD_RO}" required="${form_PAY_CD_R}" style='ime-mode:inactive'/>
                </e:field>
                <e:label for="REG_FROM_DATE" title="${form_REG_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REG_FROM_DATE" toDate="REG_TO_DATE" name="REG_FROM_DATE" value="${form.REG_FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_REG_FROM_DATE_R}" disabled="${form_REG_FROM_DATE_D}" readOnly="${form_REG_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="REG_TO_DATE" fromDate="REG_FROM_DATE" name="REG_TO_DATE" value="${form.REG_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_REG_TO_DATE_R}" disabled="${form_REG_TO_DATE_D}" readOnly="${form_REG_TO_DATE_RO}" />
                </e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doEditVendor" name="doEditVendor" label="${doEditVendor_N}" onClick="doEditVendor" disabled="${doEditVendor_D}" visible="${doEditVendor_V}"/>
				<c:if test="${approvalVendorFlag == true}">
					<e:button id="doRequestApp" name="doRequestApp" label="${doRequestApp_N}" onClick="doRequestApp" disabled="${doRequestApp_D}" visible="${doRequestApp_V}"/>
				</c:if>

				<c:if test="${approvalVendorFlag != true}">
					<%--<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doConfirm" disabled="${doApproval_D}" visible="${doApproval_V}"/>--%>
					<%--<e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>--%>
                    <e:button id="doSendConf" name="doSendConf" label="${doSendConf_N}" onClick="doSendConf" data="FORM2017080100001" disabled="${doSendConf_D}" visible="${doSendConf_V}"/>
                    <e:button id="doSendConf2" name="doSendConf2" label="${doSendConf2_N}" onClick="doSendConf" data="FORM2017080300004" disabled="${doSendConf2_D}" visible="${doSendConf2_V}"/>
				</c:if>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>