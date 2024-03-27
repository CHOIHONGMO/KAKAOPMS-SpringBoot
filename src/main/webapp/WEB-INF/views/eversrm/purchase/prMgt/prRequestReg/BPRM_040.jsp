<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var baseUrl = "/eversrm/purchase/prMgt/prRequestReg/BPRM_040";

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

		grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
	        if (celName == "PR_NUM") {
	        	everPopup.openPRDetailInformation(grid.getCellValue(rowId, "PR_NUM"));
	        } else if(celName == 'multiSelect') {
                grid.checkAll(false);
                grid.checkRow(rowId, true);
            }
		});

		grid.setColFontColor('PR_NUM', '0|0|255');
		grid.setColFontDeco('PR_NUM', 'underline');

    }

    function doSearch() {
       	if (!everDate.fromTodateValid('PR_FROM_DATE', 'PR_TO_DATE', '${ses.dateFormat }')) return alert('${msg.M0073}');

        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    function doSearchUser() {
        var param = {
            callBackFunction: "selectUser"
        };
        everPopup.openCommonPopup(param, 'SP0001');
    }
    function selectUser(data) {
        EVF.C("REQ_USER_NM").setValue(data.USER_NM);
    }
    function doSelect() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

        <%--
        var rowJsonData = grid.getSelRowValueJSON();

        for(var i in rowJsonData) {
        	alert(rowJsonData[i].PR_NUM);
        }
        --%>

        var prNum = grid.getCellValue(selRowId[0], "PR_NUM");
        opener['${param.callBackFunction}'](prNum);
        doClose();
    }

    function doClose() {
    	window.close();
    }

    </script>
    <e:window id="BPRM_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" onEnter="doSearch">
        	<e:row>
	        	<e:label for="PR_FROM_DATE" title="${form_PR_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="PR_FROM_DATE" name="PR_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_PR_FROM_DATE_R}" disabled="${form_PR_FROM_DATE_D}" readOnly="${form_PR_FROM_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="PR_TO_DATE" name="PR_TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_PR_TO_DATE_R}" disabled="${form_PR_TO_DATE_D}" readOnly="${form_PR_TO_DATE_RO}" />
				</e:field>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
				<e:field>
					<e:inputText id="PR_NUM" name="PR_NUM" value="${form.PR_NUM}" width="100%" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}" />
				</e:field>
				<e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}"/>
				<e:field>
					<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="${form.PR_SUBJECT}" width="100%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
    		</e:row>
    		<e:row>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
				<e:field>
					<e:search id="REQ_USER_NM" name="REQ_USER_NM" value="" width="100%" maxLength="${form_REQ_USER_NM_M}" onIconClick="${form_REQ_USER_NM_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
				</e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field colSpan="3">
					<e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prType }" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
    		</e:row>
    	</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>