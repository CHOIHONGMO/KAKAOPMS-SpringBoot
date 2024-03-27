<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/common/sample/";

		function init() {

			grid = EVF.C('grid');

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

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'doSearchForTestPage', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function doRegister() {

        	var checkRowData = grid.getSelRowId();
        	var argData = grid.jsonToArray(checkRowData).value;
        	var rowData = {};
        	var subject = "";
        	var docNum = "";
        	var attFileNum = "";
        	var approvalType = "";

        	if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
	        if(argData.length > 1) {
	        	alert("${msg.M0006 }");
	        	return;
	        }

			for(var i = 0; i < argData.length; i++) {
	        	rowData = grid.getRowValue(argData[i]);
	        	subject = rowData.SUBJECT;
	        	docNum = rowData.TEST_NUM;
	        	attFileNum = rowData.ATT_FILE_NUM;
	        	approvalType = eval(rowData.TEST_NUM.substring(10, 13)) % 2 == 1 ? 'APPROVAL' : 'NOTICE';
	        }

	        var param = {
                subject: subject,
                docType: "SAM",
                screenId: "SAM_029",
                approvalType: approvalType,
                oldApprovalFlag: "P",
                houseCode: '${ses.gateCd}',
                docNum: docNum,
                attFileNum: attFileNum,
                callBackFunction: "goApproval"
            };
            everPopup.openApprovalRequestPopup(param);
	    }

	    function goApproval(formData, gridData, attachData) {

			for(var i = 0; i < gridData.length; i++) {
				delete gridData[i].SIGN_USER_NM_IMG;
			}

			EVF.C('approvalFormData').setValue(formData);
			EVF.C('approvalGridData').setValue(gridData);
			EVF.C('attachFileDatas').setValue(attachData);

			var store = new EVF.Store();
        	store.load('/eversrm/eApproval/doApprovalCreate', function(){
        		alert(this.getResponseMessage());
        		EVF.C('approvalFormData').setValue();
				EVF.C('approvalGridData').setValue();
				EVF.C('attachFileDatas').setValue();
        		doSearch();
        	});
		}

		function getUserSearch() {
	        var param = {
	        	BUYER_CODE: "T01",
	            callBackFunction: "setUserNm"
	        };
	        everPopup.openCommonPopup(param, "SP0001");
	    }

	    function setUserNm(data) {
	        EVF.C("REG_USER_NM").setValue(data.USER_NM);
	    }

    </script>
    <e:window id="SAM_913" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Register" name="Register" label="${Register_N }" disabled="${Register_D }" onClick="doRegister" />
            <e:button id="UserNm" name="UserNm" label="사용자조회 Popup" disabled="false" onClick="getUserSearch" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>