<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/customs/customsList/";

    function init() {
        grid = EVF.C("grid");

		grid.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
			onCellClick( cellName, rowId );
		});

        grid.checkAll(true);
    }

    function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'BCSP_010/doSearchCustomsList', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    function onCellClick(strColumnKey, nRow) {
        if (strColumnKey == 'PR_NUM') {
            everPopup.openPRDetailInformation(grid.getCellValue(nRow, "PR_NUM"));
        }
    }
    function doSearchUser() {
        everPopup.openCommonPopup({
            callBackFunction: "selectUser"
        }, 'SP0001');
    }
    function selectUser(dataJsonArray) {
	    dataJsonArray = $.parseJSON(dataJsonArray);

        EVF.C("REQ_USER_NM").setValue(dataJsonArray.USER_NM);
    }
    function doClose() {
        window.close();
    }


    </script>


    <e:window id="BCSP_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${form_caption_form_N}" labelWidth="${labelWidth}" width="80%" columnCount="2">
            <e:row>
                <e:label for="PR_FROM_DATE" title="${form_PR_FROM_DATE_N}"></e:label>
                <e:field>
                	<e:inputDate id="PR_FROM_DATE" name="PR_FROM_DATE"  value='${fromDate}' format='${inputDateFormat }' width='${inputDateWidth }' required='${form_PR_FROM_DATE_R }' readOnly='${form_PR_FROM_DATE_RO }' disabled='${form_PR_FROM_DATE_D }' visible='${form_PR_FROM_DATE_V }' datePicker='true' onKeyDown="formUtil.onFormKeyDown"/>
                	<label style="float : left;">~&nbsp;</label>
                	<e:inputDate id="PR_TO_DATE" name="PR_TO_DATE"  value='${toDate}' format='${inputDateFormat }' width='${inputDateWidth }' required='${form_PR_TO_DATE_R }' readOnly='${form_PR_TO_DATE_RO }' disabled='${form_PR_TO_DATE_D }' visible='${form_PR_TO_DATE_V }' datePicker='true' onKeyDown="formUtil.onFormKeyDown"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"></e:label>
                <e:field>
 					<e:select id="PLANT_CD" name="PLANT_CD" options="${refPlantCd}" required="${form_PLANT_CD_R }" disabled="${form_PLANT_CD_D }" readOnly='${form_PLANT_CD_RO }' value="${st_default}" visible="${everMultiVisible}"></e:select>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"></e:label>
                <e:field>
					<e:inputText id="SUBJECT" name="SUBJECT" width="${inputTextWidth }" maxLength="${form_SUBJECT_M }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D}" visible="${form_SUBJECT_V}" ></e:inputText>
                </e:field>
                <e:label for="PR_NUM" title="${form_PR_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="PR_NUM" name="PR_NUM" width="${inputTextWidth }" maxLength="${form_PR_NUM_M }" required="${form_PR_NUM_R }" readOnly="${form_PR_NUM_RO }" disabled="${form_PR_NUM_D}" visible="${form_PR_NUM_V}" ></e:inputText>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REQ_DEPT_NM" title="${form_REQ_DEPT_NM_N}"></e:label>
                <e:field>
					<e:search id="REQ_DEPT_NM" name="REQ_DEPT_NM" width="${inputTextWidth }" onIconClick="doSearchDept" maxLength="${form_REQ_DEPT_NM_M }" required="${form_REQ_DEPT_NM_R }" readOnly="${form_REQ_DEPT_NM_RO }" disabled="${form_REQ_DEPT_NM_D}" visible="${form_REQ_DEPT_NM_V}"/>
                </e:field>
                <e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"></e:label>
                <e:field>
 					<e:select id="SIGN_STATUS" name="SIGN_STATUS" options="${approvalStatus}" required="${form_SIGN_STATUS_R }" disabled="${form_SIGN_STATUS_D }" readOnly='${form_SIGN_STATUS_RO }' value="${st_default}" visible="${everMultiVisible}"></e:select>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"></e:label>
                <e:field colSpan="3">
					<e:search id="REQ_USER_NM" name="REQ_USER_NM" width="${inputTextWidth }" onIconClick="doSearchUser" maxLength="${form_REQ_USER_NM_M }" required="${form_REQ_USER_NM_R }" readOnly="${form_REQ_USER_NM_RO }" disabled="${form_REQ_USER_NM_D}" visible="${form_REQ_USER_NM_V}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="400px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>