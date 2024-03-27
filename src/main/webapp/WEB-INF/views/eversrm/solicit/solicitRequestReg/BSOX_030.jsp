<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var grid;
    var baseUrl = "/eversrm/solicit/solicitRequestReg/";

    function init() {
        grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            if (celName == "RFX_NUM") {
                var param = {
                    gateCd: grid.getCellValue(rowId, "GATE_CD"),
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxType: "RFQ",
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openRfxDetailInformation(param);
            } else if (celName == "BIDDING_VENDOR") {
                var param = {
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxSubject: grid.getCellValue(rowId, "RFX_SUBJECT"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openBiddingVendorList(param);
            }
        });

        grid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                 imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        grid.setProperty('shrinkToFit', true);
    }

    function doSearch() {
        if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "BSOX_030/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002}");
            }
        });
    }

    function doDeptSearch() {
        var param = {
            callBackFunction: "selectDept",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0002');
    }

    function selectDept(dataJsonArray) {
        EVF.C('DEPT_NM').setValue(dataJsonArray.DEPT_NM);
    }

    function doUserSearch() {
        var param = {
            callBackFunction: "selectUser",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0001');
    }
    function selectUser(data) {
        EVF.C("USER_NM").setValue(data.USER_NM);
    }
    function doSelect() {

        if(!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if(grid.getSelRowCount() !== 1) { return alert('${msg.M0006}'); }

        var selectedRowJson = JSON.stringify(grid.getSelRowValue()[0]);
        opener.window['${param.callBackFunction}'](selectedRowJson);
        doClose();
    }

    function doClose() {
        formUtil.close();
    }

</script>

    <e:window id="BSOX_030" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">

        <e:inputHidden id='RFX_TYPE' name="RFX_TYPE" value="RFQ" />

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
                </e:field>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
                <e:field>
                    <e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="100%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
                <e:field>
                    <e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="100%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
                <e:field>
                    <e:search id="DEPT_NM" name="DEPT_NM" value="" width="${inputTextWidth}" maxLength="${form_DEPT_NM_M}" onIconClick="${form_DEPT_NM_RO ? '' : 'doDeptSearch'}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field colSpan="3">
                    <e:search id="USER_NM" name="USER_NM" value="" width="${inputTextWidth}" maxLength="${form_USER_NM_M}" onIconClick="${form_USER_NM_RO ? '' : 'doUserSearch'}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button label="${doSearch_N }" id="doSearch" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V }" data="${doSearch_A }"/>
            <e:button label='${doSelect_N }' id='doSelect' onClick='doSelect' disabled='${doSelect_D }' visible='${doSelect_V }' data='${doSelect_A }'/>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }'/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>