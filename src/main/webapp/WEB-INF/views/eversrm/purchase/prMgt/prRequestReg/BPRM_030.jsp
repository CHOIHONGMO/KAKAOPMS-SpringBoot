<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/purchase/prMgt/prRequestReg/";

	    function init() {
		grid = EVF.getComponent('grid');
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
	        if (celname == "RFI_NUM") {
				selectedData = grid.getRowValue(rowid);
                opener.${param.callBackFunction}(selectedData);
		        doClose();
	        }


	        if (celname == "VENDOR_ANSWER") {
	            var params = {
	            	RFI_NUM: grid.getCellValue(rowid,"RFI_NUM"),
	                detailView: true
	            };

	            everPopup.openSearchVendorReplyInfomationPopup(params);
	        }
		});

    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BPRM_030/doSearch', function() {
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
        EVF.getComponent("REQ_USER_NM").setValue(data.USER_NM);
    }
    function doClose() {
    	window.close();
    }


    </script>
    <e:window id="BPRM_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" onEnter="doSearch">
        	<e:row>
				<e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
				<e:field>
				<e:inputDate id="FROM_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
				<e:text> ~ </e:text>
				<e:inputDate id="TO_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
				</e:field>

				<e:label for="RFI_NUM" title="${form_RFI_NUM_N}"/>
				<e:field>
				<e:inputText id="RFI_NUM" name="RFI_NUM" value="${form.RFI_NUM}" width="100%" maxLength="${form_RFI_NUM_M}" disabled="${form_RFI_NUM_D}" readOnly="${form_RFI_NUM_RO}" required="${form_RFI_NUM_R}" />
				</e:field>
				<e:label for="RFI_SUBJECT" title="${form_RFI_SUBJECT_N}"/>
				<e:field>
				<e:inputText id="RFI_SUBJECT" name="RFI_SUBJECT" value="${form.RFI_SUBJECT}" width="100%" maxLength="${form_RFI_SUBJECT_M}" disabled="${form_RFI_SUBJECT_D}" readOnly="${form_RFI_SUBJECT_RO}" required="${form_RFI_SUBJECT_R}" />
				</e:field>

			</e:row>
        	<e:row>
				<e:label for="RFI_TYPE" title="${form_RFI_TYPE_N}"/>
				<e:field>
				<e:select id="RFI_TYPE" name="RFI_TYPE" value="${form.RFI_TYPE}" options="${refRfiType}" width="${inputTextWidth}" disabled="${form_RFI_TYPE_D}" readOnly="${form_RFI_TYPE_RO}" required="${form_RFI_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="REQ_DEPT_NM" title="${form_REQ_DEPT_NM_N}"/>
				<e:field>
				<e:search id="REQ_DEPT_NM" name="REQ_DEPT_NM" value="" width="${inputTextWidth}" maxLength="${form_REQ_DEPT_NM_M}" onIconClick="${form_REQ_DEPT_NM_RO ? 'everCommon.blank' : 'doSearchDept'}" disabled="${form_REQ_DEPT_NM_D}" readOnly="${form_REQ_DEPT_NM_RO}" required="${form_REQ_DEPT_NM_R}" />
				</e:field>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
				<e:field>
				<e:search id="REQ_USER_NM" name="REQ_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_REQ_USER_NM_M}" onIconClick="${form_REQ_USER_NM_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>