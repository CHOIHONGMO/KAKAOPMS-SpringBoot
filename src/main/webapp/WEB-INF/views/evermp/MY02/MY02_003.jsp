<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

	    var baseUrl = "/evermp/MY02/";
	    var grid;

	    function init() {

	    	grid = EVF.C("grid");

	        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

	        	if(colId === 'APP_DOC_NUM'){

		            var params = {
		                gateCd    : grid.getCellValue(rowId, "GATE_CD"),
		                appDocNum : grid.getCellValue(rowId, "APP_DOC_NUM"),
		                appDocCnt : grid.getCellValue(rowId, "APP_DOC_CNT"),
		                docType   : grid.getCellValue(rowId, "DOC_TYPE"),
		                signStatus: grid.getCellValue(rowId, "PER_SIGN_STATUS"),
		                sendBox	  : false
		            };
		            everPopup.openApprovalOrRejectPopup(params);

		       	} else if(colId == "VIEW_CNT"){

		            var params = {
		                GATE_CD     : grid.getCellValue(rowId, "GATE_CD"),
		                APP_DOC_NUM : grid.getCellValue(rowId, "APP_DOC_NUM"),
			            APP_DOC_CNT : grid.getCellValue(rowId, "APP_DOC_CNT"),
			            from: 'mailBox',
			            callBackFunction: ''
		       		};
		       		everPopup.approvalPathSearchPopup(params);

		   		} else if(colId == "ATT_FILE_NUM_DISPLAY") {

		   			var uuid = grid.getCellValue(rowId, 'ATT_FILE_NUM');
					var param = {
						havePermission : false,
						attFileNum     : uuid,
						rowId          : rowId,
						callBackFunction: '',
						bizType: 'APP'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
				}
			});

            grid.setProperty('shrinkToFit', false);
	        grid.setProperty('multiSelect', false);
	        grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});
            if("${ses.userType}" == "C") { grid.setColWidth('APP_AMT', 0); }

            EVF.C('SIGN_STATUS').removeOption('T');
            EVF.C('SIGN_STATUS').removeOption('C');

	        doSearch();
	    }

	    function doSearch() {

	        var store = new EVF.Store();
	        if(!store.validate()) { return; }
	        store.setGrid([grid]);
	        store.load(baseUrl + 'my02003_doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	alert("${msg.M0002 }");
	            }
	        });
	    }

	    function doUserSearch() {
            var userType = "${ses.userType}";
            var custCd = "${ses.companyCd}";

            if(userType == "C") {
                everPopup.openCommonPopup({
                    callBackFunction: 'selectUser'
                }, 'SP0011');
            } else {
                everPopup.openCommonPopup({
                    callBackFunction: 'selectUser',
                    custCd: custCd
                }, 'SP0073');
            }
	    }

	    function selectUser(data) {
	    	EVF.C("USER_ID").setValue(data.USER_ID);
	    	EVF.C("USER_NM").setValue(data.USER_NM);
	    }

	    function clearUser() {
	    	EVF.C("USER_ID").setValue("");
		}

    </script>

    <e:window id="MY02_003" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:inputHidden id="LOGIN_STATUS" name="LOGIN_STATUS" value="${loginStatus }"/>

		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="RFA_FROM_DATE" title="${form_RFA_FROM_DATE_N}"></e:label>
                <e:field>
                    <e:inputDate id="RFA_FROM_DATE" toDate="RFA_TO_DATE" name="RFA_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFA_FROM_DATE_R}" disabled="${form_RFA_FROM_DATE_D}" readOnly="${form_RFA_FROM_DATE_RO}" />
                	<e:text>~</e:text>
                    <e:inputDate id="RFA_TO_DATE" fromDate="RFA_FROM_DATE" name="RFA_TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFA_TO_DATE_R}" disabled="${form_RFA_TO_DATE_D}" readOnly="${form_RFA_TO_DATE_RO}" />
                </e:field>
				<e:label for="DOCUMENT_TYPE" title="${form_DOCUMENT_TYPE_N}"/>
				<e:field>
					<e:select id="DOCUMENT_TYPE" name="DOCUMENT_TYPE" value="" options="${documentTypeOptions}" width="${form_DOCUMENT_TYPE_W}" disabled="${form_DOCUMENT_TYPE_D}" readOnly="${form_DOCUMENT_TYPE_RO}" required="${form_DOCUMENT_TYPE_R}" placeHolder="" />
				</e:field>
                <e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
                <e:field>
                    <e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
                </e:field>
			</e:row>
            <e:row>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:search id="USER_ID" name="USER_ID" value="" width="40%" maxLength="${form_USER_ID_M}" onIconClick="${form_USER_ID_RO ? 'everCommon.blank' : 'doUserSearch'}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
                    <e:inputText id="USER_NM" name="USER_NM" value="" width="60%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                </e:field>
				<e:label for="DOCUMENT_NM" title="${form_DOCUMENT_NM_N}"></e:label>
                <e:field>
					<e:inputText id="DOCUMENT_NM" name="DOCUMENT_NM" width="${form_DOCUMENT_NM_W }" maxLength="${form_DOCUMENT_NM_M }" required="${form_DOCUMENT_NM_R }" readOnly="${form_DOCUMENT_NM_RO }" disabled="${form_DOCUMENT_NM_D}" visible="${form_DOCUMENT_NM_V}" ></e:inputText>
                </e:field>
                <e:label for="" title=""></e:label>
                <e:field>
                </e:field>
            </e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>