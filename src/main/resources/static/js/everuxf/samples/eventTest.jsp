<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script>
        function onChangeAlert(obj) {
            alert(obj+' changed!');
        }

        function viewKeyCode(e) {
            console.log(e.keyCode);
        }
    </script>

    <e:window id="EVENT_TEST" onReady="init" title="${screenName }" icon="icon-blue-document-table" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
            <e:row>
                <e:label for="START_GR_DATE" title="${form_START_GR_DATE_N}"/>
                <e:field>
                    <e:inputDate id="START_GR_DATE" name="START_GR_DATE" value="20140101" width="${inputTextDate}" datePicker="true" required="${form_START_GR_DATE_R}" disabled="${form_START_GR_DATE_D}" readOnly="${form_START_GR_DATE_RO}" />
                    <e:text> ~ </e:text>
                    <e:inputDate id="END_GR_DATE" name="END_GR_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_END_GR_DATE_R}" disabled="${form_END_GR_DATE_D}" readOnly="${form_END_GR_DATE_RO}" />
                </e:field>
                <e:label for="TAX_YN" title="${form_TAX_YN_N}"/>
                <e:field>
                    <e:select id="TAX_YN" name="TAX_YN" value="" options="${taxYn}" width="${inputTextWidth}" disabled="${form_TAX_YN_D}" readOnly="${form_TAX_YN_RO}" required="${form_TAX_YN_R}" placeHolder="" />
                </e:field>
                <e:label for="PO_TYPE" title="${form_PO_TYPE_N}"/>
                <e:field>

                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:panel width="30%">
                <e:text> </e:text>
            </e:panel>
            <e:panel width="70%">
                <e:button id="doCancelGr" name="doCancelGr" label="${doCancelGr_N}" onClick="doCancelGr" disabled="${doCancelGr_D}" visible="${doCancelGr_V}" align="right" />
                <div style="float: right;">
                    <e:text> 취소일자 : </e:text>
                    <e:inputDate id="CANCEL_GR_DATE" name="CANCEL_GR_DATE" width="${inputDateWidth }" value="20141212" datePicker="true" required="${form_CANCEL_GR_DATE_R}" disabled="${form_CANCEL_GR_DATE_D}" readOnly="${form_CANCEL_GR_DATE_RO}" />
                </div>
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" align="right" />
            </e:panel>
        </e:buttonBar>
    </e:window>
</e:ui>