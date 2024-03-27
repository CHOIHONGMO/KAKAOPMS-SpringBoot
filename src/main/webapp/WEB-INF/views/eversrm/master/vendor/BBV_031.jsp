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
		grid = EVF.getComponent('grid');
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

		if(selRow == undefined) selRow = rowid;

	        if (celname == 'multiSelect') {
	          // cell 1개만 클릭
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
		});

		EVF.getComponent('PROGRESS_CD').setValue('P');
    }

    <%-- 조회 --%>
    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;

        // 날짜 체크
        if(!everDate.checkTermDate('REG_FROM_DATE','REG_TO_DATE','${msg.M0073}')) {
            return;
        }

        store.setGrid([grid]);
        store.load(baseUrl + 'BBV_031/doSelect', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    <%-- 수정 --%>
    function doEditVendor() {
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
            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            var signStatus = grid.getCellValue(selRowId[i], "SIGN_STATUS");
            var vendor_cd = grid.getCellValue(selRowId[i], "VENDOR_CD");
            if (progress_cd == "E" || signStatus == 'P' || signStatus == 'E') {
                alert("${msg.M0047 }");
                return;
            }
            var params = {
                    VENDOR_CD : vendor_cd,
                    paramPopupFlag: 'N',
                    onClose: 'closePopupAndRequeryParent',
                    detailView : false
                };
            everPopup.openSupManagementPopup(params);
            return;
     	}
    }

    <%-- 승인요청 --%>
    function doRequestConf() {
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
            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
            var signStatus = grid.getCellValue(selRowId[i],'SIGN_STATUS');
            var vendor_cd = grid.getCellValue(selRowId[i],'VENDOR_CD');

            if (signStatus == "P" || signStatus == "E") {
                alert("${msg.M0047 }");
                return;
            }

            if (progress_cd == "E" || progress_cd == 'R' ) {
                alert("${msg.M0045 }");
                return;
            }
     	}

        var param = {
            subject: grid.getCellValue(selRowId[0],'VENDOR_NM'),
            docType: "VENDOR",
            signStatus: "P",
            screenId: "BBV_031",
            approvalType: 'APPROVAL',
            oldApprovalFlag: grid.getCellValue(selRowId[0],'SIGN_STATUS'),
            attFileNum: "",
            docNum: grid.getCellValue(selRowId[0],'VENDOR_CD'),
            appDocNum: grid.getCellValue(selRowId[0],'APP_DOC_NUM'),
            callBackFunction: "goApproval"
        };

        everPopup.openApprovalRequestIIPopup(param);

        /*var userwidth  = 810; // 고정(수정하지 말것)
		var userheight = (screen.height - 2);
		if (userheight < 780) userheight = 780; // 최소 780
        var LeftPosition = (screen.width-userwidth)/2;
        var TopPosition  = (screen.height-userheight)/2;
        var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

        if (confirm("${msg.M0053}")) {
            var store = new EVF.Store();
            if(!store.validate()) return;
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BBV_031/doConfirm', function() {

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
            store.load(baseUrl + 'BBV_031/doConfirm', function () {
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

    <%-- 등록평가 --%>
     function doVendorEval() {
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
            var sign_status 	= grid.getCellValue(selRowId[i],'SIGN_STATUS');
            var progress_cd 	= grid.getCellValue(selRowId[i],'PROGRESS_CD');
            var vendor_cd 	= grid.getCellValue(selRowId[i], "VENDOR_CD");
            var vendor_nm 	= grid.getCellValue(selRowId[i], "VENDOR_NM");
            var gate_cd 		= grid.getCellValue(selRowId[i], "GATE_CD");
            var ev_num 			= grid.getCellValue(selRowId[i], "EV_NUM");

            <%-- 결재상태가 승인, 진행중인것 제외 --%>
            if (sign_status == "E" || sign_status == 'P' ) {
                alert("${msg.M0045 }");
                return;
           }

	        var params = {
	                GATE_CD : gate_cd
	               ,VENDOR_CD : vendor_cd
	               ,VENDOR_NM : vendor_nm
	               ,EV_NUM : ev_num
	               ,POPUPFLAG : 'Y'
	               ,detailView : false
                   ,havePermission : false
	            };

	        everPopup.openPopupByScreenId('SRM_045', 950, 580, params);
	        return;

     	}

    }


    </script>
    <e:window id="BBV_031" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="approvalFormData" name="approvalFormData"/>
        <e:inputHidden id="approvalGridData" name="approvalGridData"/>
        <e:inputHidden id="attachFileDatas" name="attachFileDatas" visible="false" />

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
        	<e:row>
                <%--협력회사명--%>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />

                    <e:inputHidden id="APPROVAL_FLAG" name="APPROVAL_FLAG"/>

                </e:field>
                <%--등록형태--%>
                <e:label for="REG_TYPE" title="${form_REG_TYPE_N}"/>
                <e:field>
                    <e:select id="REG_TYPE" name="REG_TYPE" value="${form.REG_TYPE}" options="${regType }" width="${inputTextWidth}" disabled="${form_REG_TYPE_D}" readOnly="${form_REG_TYPE_RO}" required="${form_REG_TYPE_R}" placeHolder="" />
                </e:field>
                <%--대표자명--%>
                <e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="CEO_USER_NM" style="${imeMode}" name="CEO_USER_NM" value="${form.CEO_USER_NM}" width="100%" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}"/>
                </e:field>
			</e:row>
        	<e:row>
                <%--사업자등록번호--%>
                <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"/>
                <e:field>
                    <e:inputText id="IRS_NUM" name="IRS_NUM" value="${form.IRS_NUM}" width="100%" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
                </e:field>
                <%--승인여부--%>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressStatus }" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
                <%--결재상태--%>
                <e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
				<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}" options="${signStatusOptions}" width="${inputTextWidth}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
                <%--거래구분--%>

				<e:label for="ITEM_PURCHASE_FLAG" title="${form_ITEM_PURCHASE_FLAG_N}"/>
				<e:field>
				<e:select id="ITEM_PURCHASE_FLAG" name="ITEM_PURCHASE_FLAG" value="${form.ITEM_PURCHASE_FLAG}" options="${itemPurchaseFlagOptions}" width="${inputTextWidth}" disabled="${form_ITEM_PURCHASE_FLAG_D}" readOnly="${form_ITEM_PURCHASE_FLAG_RO}" required="${form_ITEM_PURCHASE_FLAG_R}" placeHolder="" />
				</e:field>


                <%--등록일자--%>
                <e:label for="REG_FROM_DATE" title="${form_REG_FROM_DATE_N}"/>
                <e:field >
                    <e:inputDate id="REG_FROM_DATE" toDate="REG_TO_DATE" name="REG_FROM_DATE" value="${form.REG_FROM_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_FROM_DATE_R}" disabled="${form_REG_FROM_DATE_D}" readOnly="${form_REG_FROM_DATE_RO}" />
                <e:text> ~ </e:text>
                    <e:inputDate id="REG_TO_DATE" fromDate="REG_FROM_DATE" name="REG_TO_DATE" value="${form.REG_TO_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_TO_DATE_R}" disabled="${form_REG_TO_DATE_D}" readOnly="${form_REG_TO_DATE_RO}" />
                </e:field>
                 <e:field colSpan="2"></e:field>
            </e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">

			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doEditVendor" name="doEditVendor" label="${doEditVendor_N}" onClick="doEditVendor" disabled="${doEditVendor_D}" visible="${doEditVendor_V}"/>
            <e:button id="doRequestConf" name="doRequestConf" label="${doRequestConf_N}" onClick="doRequestConf" disabled="${doRequestConf_D}" visible="${doRequestConf_V}"/>
            <e:button id="doVendorEval" name="doVendorEval" label="${doVendorEval_N}" onClick="doVendorEval" disabled="${doVendorEval_D}" visible="${doVendorEval_V}"/>

		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>