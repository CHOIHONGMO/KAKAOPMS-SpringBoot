<%--기준정보 > 고객사정보관리 > 마감일자 관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">
        var baseUrl = "/evermp/BS01/BS0101/";

        function init() {

        }

        function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            parent['${param.callBackFunction}'](EVF.V("AMEND_REASON") ,EVF.V("REQ_USER_NM"));
            new EVF.ModalWindow().close(null);
        }


    </script>
    <e:window id="BS01_006" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="rightPanelB" height="fit" width="100%">
            <e:buttonBar id="buttonTopBottom" align="right" width="100%">
                <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            </e:buttonBar>
        </e:panel>
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="1" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="AMEND_REASON" title="${form_AMEND_REASON_N}"/>
                <e:field>
                    <e:inputText id="AMEND_REASON" style="${imeMode}" name="AMEND_REASON" value="" width="100%" maxLength="${form_AMEND_REASON_M}" disabled="${form_AMEND_REASON_D}" readOnly="${form_AMEND_REASON_RO}" required="${form_AMEND_REASON_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="REQ_USER_NM" style="${imeMode}" name="REQ_USER_NM" value="" width="100%" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}"/>
                </e:field>
            </e:row>

        </e:searchPanel>

    </e:window>
</e:ui>