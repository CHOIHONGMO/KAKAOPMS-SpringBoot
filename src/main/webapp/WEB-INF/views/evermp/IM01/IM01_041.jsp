<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/IM03/IM0303/";

        function init() {

        }

        function doApply() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if(!confirm('${IM01_041_001}')) { return; }

            store.doFileUpload(function() {
                var rtnData = [{
                    "VENDOR_CD" : EVF.C("VENDOR_CD").getValue(),
                    "VALID_FROM_DATE" : EVF.C("VALID_FROM_DATE").getValue(),
                    "VALID_TO_DATE" : EVF.C("VALID_TO_DATE").getValue(),
                    "PRICE_CHANGE_REASON" : EVF.C("PRICE_CHANGE_REASON").getValue()
                }];
                opener.window['${param.callBackFunction}'](JSON.stringify(rtnData));
                doClose();
            });
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="IM01_041" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar id="btnT" align="right" width="100%">
            <e:button id="Apply" name="Apply" label="${Apply_N}" disabled="${Apply_D}" visible="${Apply_V}" onClick="doApply" />
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field colSpan="3">
                    <e:search id="VENDOR_NM" style="ime-mode:inactive" name="VENDOR_NM" value="${param.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VALID_FROM_DATE" title="${form_VALID_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="VALID_FROM_DATE" name="VALID_FROM_DATE" toDate="VALID_TO_DATE" value="${param.VALID_FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_VALID_FROM_DATE_R}" disabled="${form_VALID_FROM_DATE_D}" readOnly="${form_VALID_FROM_DATE_RO}" />
                </e:field>
                <e:label for="VALID_TO_DATE" title="${form_VALID_TO_DATE_N}"/>
                <e:field>
                    <e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE" fromDate="VALID_FROM_DATE" value="${param.VALID_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_VALID_TO_DATE_R}" disabled="${form_VALID_TO_DATE_D}" readOnly="${form_VALID_TO_DATE_RO}" />
                </e:field>
            </e:row>
            <e:label for="PRICE_CHANGE_REASON" title="${form_PRICE_CHANGE_REASON_N}"/>
            <e:field  colSpan="3">
                <e:textArea id="PRICE_CHANGE_REASON" name="PRICE_CHANGE_REASON" value="" height="270px" width="100%" maxLength="${form_PRICE_CHANGE_REASON_M}" disabled="${form_PRICE_CHANGE_REASON_D}" readOnly="${form_PRICE_CHANGE_REASON_RO}" required="${form_PRICE_CHANGE_REASON_R}" />
            </e:field>
        </e:searchPanel>

    </e:window>
</e:ui>