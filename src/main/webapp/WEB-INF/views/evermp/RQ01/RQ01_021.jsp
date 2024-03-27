<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/RQ01/RQ0102/";

        function init() {

        }

        function doClosing() {

            if(EVF.isEmpty(EVF.C("RFQ_CLOSE_DATE").getValue()) || EVF.isEmpty(EVF.C("RFQ_CLOSE_HOUR").getValue()) || EVF.isEmpty(EVF.C("RFQ_CLOSE_MIN").getValue())) {
                return alert("${RQ01_021_006}");
            }
            var validCloseDate = Number(EVF.C("RFQ_CLOSE_DATE").getValue()) + EVF.C("RFQ_CLOSE_HOUR").getValue() + EVF.C("RFQ_CLOSE_MIN").getValue();
            if ("${closeDate.RFQ_CLOSE_DATE}" + "${closeDate.RFQ_CLOSE_HOUR}" + "${closeDate.RFQ_CLOSE_MIN}" + "00" > validCloseDate) { return alert('${RQ01_021_007}'); }
            if ("${today}" + "${todayTime}" > validCloseDate) { return alert('${RQ01_021_005}'); }

            if(EVF.isEmpty(EVF.C("EXTEND_RMK").getValue())) {
                return alert("${RQ01_021_004}");
            }

            if(!confirm('${RQ01_021_001}')) { return; }

            var store = new EVF.Store();
            store.load(baseUrl + 'rq01021_doChangeDeadLine', function() {
                alert(this.getResponseMessage());
                opener.doSearch();
                doClose();
            });
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="RQ01_021" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="RFQ_CLOSE_DATE" title="${form_RFQ_CLOSE_DATE_N}"/>
                <e:field colSpan="3">
                    <e:inputDate id="RFQ_CLOSE_DATE" name="RFQ_CLOSE_DATE" value="${closeDate.RFQ_CLOSE_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_RFQ_CLOSE_DATE_R}" disabled="${form_RFQ_CLOSE_DATE_D}" readOnly="${form_RFQ_CLOSE_DATE_RO}" />
                    <e:text>&nbsp;</e:text>
                    <e:select id="RFQ_CLOSE_HOUR" name="RFQ_CLOSE_HOUR" value="${closeDate.RFQ_CLOSE_HOUR }" options="${rfqCloseHourOptions}" width="75px" disabled="${form_RFQ_CLOSE_HOUR_D}" readOnly="${form_RFQ_CLOSE_HOUR_RO}" required="${form_RFQ_CLOSE_HOUR_R}" placeHolder="" />
                    <e:text>${RQ01_011_001}</e:text>
                    <e:select id="RFQ_CLOSE_MIN" name="RFQ_CLOSE_MIN" value="${closeDate.RFQ_CLOSE_MIN }" options="${rfqCloseMinOptions}" width="75px" disabled="${form_RFQ_CLOSE_MIN_D}" readOnly="${form_RFQ_CLOSE_MIN_RO}" required="${form_RFQ_CLOSE_MIN_R}" placeHolder="" />
                    <e:text>${RQ01_011_002}</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="EXTEND_RMK" title="${form_EXTEND_RMK_N }" />
                <e:field colSpan="3">
                    <e:textArea id="EXTEND_RMK" name="EXTEND_RMK" value="" height="260px" width="100%" maxLength="${form_EXTEND_RMK_M}" disabled="${form_EXTEND_RMK_D}" readOnly="${form_EXTEND_RMK_RO}" required="${form_EXTEND_RMK_R}" />
                    <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="${param.RFQ_NUM}" />
                    <e:inputHidden id="RFQ_CNT" name="RFQ_CNT" value="${param.RFQ_CNT}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="btnG" align="right" width="100%">
            <e:button id="Closing" name="Closing" label="${Closing_N}" disabled="${Closing_D}" visible="${Closing_V}" onClick="doClosing" />
        </e:buttonBar>

    </e:window>
</e:ui>