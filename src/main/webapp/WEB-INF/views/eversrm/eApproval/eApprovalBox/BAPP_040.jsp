<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var baseUrl = "/eversrm/eApproval/eApprovalBox/";
    var grid;

    function init() {
        grid = EVF.C("grid");
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

		grid.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
			onCellClick( cellName, rowId );
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
        doSelect();
    }

    function doSelect() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'BAPP_040/getSendBoxList', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    function doSearch() {
        doSelect();
    }

    function doCancelRFA() {

    	if( grid.isEmpty( grid.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        var gridCount = grid.getRowCount();
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

        if(selRowId.length > 1) {
        	alert("${msg.M0006}");
            return;
        }

		for(var i = 0;i < selRowId.length;i++) {
			var signStatus = grid.getCellValue(selRowId[i], 'SIGN_STATUS');

		    if(signStatus != 'P') {
				alert('${BAPP_040_incorrect_status}');
				return;
		    }
		}

        if (!confirm("${msg.M0024}")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
		store.getGridData(grid, 'sel');
		store.load(baseUrl + 'BAPP_040/doCancelRFA', function(){
			alert(this.getResponseMessage());
			doSelect();
		});
    }

    function onCellClick(strColumnKey, nRow) {

        if (strColumnKey == "APP_DOC_NUM") {

            var params = {
                gateCd    :grid.getCellValue(nRow, "GATE_CD"),
                appDocNum :grid.getCellValue(nRow, "APP_DOC_NUM"),
                appDocCnt :grid.getCellValue(nRow, "APP_DOC_CNT"),
                docType   :grid.getCellValue(nRow, "DOC_TYPE"),
                signStatus:grid.getCellValue(nRow, "SIGN_STATUS"),
                sendBox   :true
            };
            everPopup.openApprovalOrRejectPopup(params);

        } else  if (strColumnKey == "CNT") {

            var params = {
                GATE_CD     : grid.getCellValue(nRow, "GATE_CD"),
                APP_DOC_NUM : grid.getCellValue(nRow, "APP_DOC_NUM"),
	            APP_DOC_CNT : grid.getCellValue(nRow, "APP_DOC_CNT")
       		};
       		everPopup.approvalPathSearchPopup(params);

        }
    }

    </script>
    <e:window id="BAPP_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="START_DATE" title="${form_START_DATE_N}"></e:label>
                <e:field>
					<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                	<e:text>~</e:text>
 					<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
                <e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"></e:label>
                <e:field>
					<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${approvalStatus}" width="100%" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
                </e:field>
                <e:label for="SIGN_REQ_TYPE" title="${form_SIGN_REQ_TYPE_N}"></e:label>
                <e:field>
					<e:select id="SIGN_REQ_TYPE" name="SIGN_REQ_TYPE"  options="${rfaStatus}" width="100%" disabled="${form_SIGN_REQ_TYPE_D}" readOnly="${form_SIGN_REQ_TYPE_RO}" required="${form_SIGN_REQ_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DOC_TYPE" title="${form_DOC_TYPE_N}"></e:label>
                <e:field>
					<e:select id="DOC_TYPE" name="DOC_TYPE"  options="${docType}" width="100%" disabled="${form_DOC_TYPE_D}" readOnly="${form_DOC_TYPE_RO}" required="${form_DOC_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="SUBJECT" name="SUBJECT" width="100%" maxLength="${form_SUBJECT_M }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D}" visible="${form_SUBJECT_V}" ></e:inputText>
                </e:field>
            </e:row>

        </e:searchPanel>

		<e:inputHidden id="USER_TYPE"        name="USER_TYPE"/>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSelect" />
            <e:button id="cancelRFA" name="cancelRFA" label="${doCancel_N }" disabled="${doCancel_D }" onClick="doCancelRFA" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>