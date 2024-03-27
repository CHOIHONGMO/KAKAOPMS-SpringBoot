<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/eversrm/eApproval/eApprovalBox/";
        var grid;

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', true);
            grid.setProperty('multiSelect', false);
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

            doSearch();
        }
        function doSearch() {
            <%--
                    try {
                        wiseValid.assert(formUtil.validHandler(['form'], "${msg.M0054 }"));
                        wiseValid.assert(wiseDate.fromTodateValid('regDateFrom', 'regDateTo', '${ses.dateFormat }'), '${msg.M0073}', EVF.C('regDateTo'));
                    } catch (message) {
                        if (message !== undefined) {
                            alert(message);
                        }
                        return;
                    }
            --%>

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'BAPP_060/getSendReceiveBoxList', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }
        function doSelectUser() {
            var param = {
                GATE_CD:  '${ses.gateCd}'
                , callBackFunction: 'selectUser'
            };
            everPopup.openCommonPopup(param,"SP0011");
        }
        function selectUser(dataJsonArray) {
            //dataJsonArray = $.parseJSON(dataJsonArray);
            EVF.C("USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("USER_NM").setValue(dataJsonArray.USER_NM);
        }
        function onCellClick(strColumnKey, nRow) {

            if(strColumnKey === 'APP_DOC_NUM'){

                var params = {
                    gateCd    :grid.getCellValue(nRow, "GATE_CD"),
                    appDocNum :grid.getCellValue(nRow, "APP_DOC_NUM"),
                    appDocCnt :grid.getCellValue(nRow, "APP_DOC_CNT"),
                    docType   :grid.getCellValue(nRow, "DOC_TYPE"),
                    signStatus:grid.getCellValue(nRow, "SIGN_STATUS"),
                    sendBox	  :false
                };
                everPopup.openApprovalOrRejectPopup(params);

            } else if(strColumnKey == "SUBJECT"){

                consultContentsUrl = grid.getCellValue(nRow, "CONSULTCONTENTSURL");
                screen_id = consultContentsUrl.substring(consultContentsUrl.indexOf('?')+11 ,consultContentsUrl.length );
                consultContentsUrl = consultContentsUrl.substring(0, consultContentsUrl.indexOf('?')+1);

                gateCd = grid.getCellValue(nRow, "GATE_CD");
                appDocNum = grid.getCellValue(nRow, "APP_DOC_NUM");
                appDocCnt = grid.getCellValue(nRow, "APP_DOC_CNT");

                everPopup.openModalPopup(consultContentsUrl, 980, 700, { detailView : true, gateCd : gateCd  , appDocNum : appDocNum   ,  appDocCnt : appDocCnt, SCREEN_ID : screen_id  });

            }else if(strColumnKey == "VIEW_CNT"){

                var params = {
                    GATE_CD     : grid.getCellValue(nRow, "GATE_CD"),
                    APP_DOC_NUM : grid.getCellValue(nRow, "APP_DOC_NUM"),
                    APP_DOC_CNT : grid.getCellValue(nRow, "APP_DOC_CNT"),
                    from: 'mailBox',
                    callBackFunction: ''
                };
                everPopup.approvalPathSearchPopup(params);

            }
        }
    </script>

    <e:window id="BAPP_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999}" onEnter="doSearch" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="regDateFrom" title="${form_RFA_DATE_N}"></e:label>
                <e:field>
                    <e:inputDate id="regDateFrom" name="regDateFrom" toDate="regDateTo" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_regDateFrom_R}" disabled="${form_regDateFrom_D}" readOnly="${form_regDateFrom_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="regDateTo" name="regDateTo" fromDate="regDateFrom" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_regDateTo_R}" disabled="${form_regDateTo_D}" readOnly="${form_regDateTo_RO}" />
                </e:field>
                <e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
                <e:field>
                    <e:select id="SIGN_STATUS" name="SIGN_STATUS" value="${signStatus}" options="${refStatus}" width="100%" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DOCUMENT_NM" title="${form_DOCUMENT_NM_N}"></e:label>
                <e:field>
                    <e:inputText id="DOCUMENT_NM" name="DOCUMENT_NM" width="100%" maxLength="${form_DOCUMENT_NM_M }" required="${form_DOCUMENT_NM_R }" readOnly="${form_DOCUMENT_NM_RO }" disabled="${form_DOCUMENT_NM_D}" visible="${form_DOCUMENT_NM_V}" ></e:inputText>
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
					<e:search id="USER_ID" name="USER_ID" value="" width="40%" maxLength="${form_USER_ID_M}" onIconClick="doSelectUser" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
					<e:inputText id="USER_NM" name="USER_NM" style="${imeMode}" value="" width="60%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
