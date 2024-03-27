<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
    function closess() {
        if (opener != null) {
            window.close();
        } else {
            new EVF.ModalWindow().close(null);
        }
    }

    function apply() {
        var param = {
            "message": EVF.C("mmm").getValue(),
            "rowId": EVF.C("rowId").getValue()
        };

        if (opener != null) {
            opener['${param.callbackFunction}'](param);
        } else {
            parent["${param.callbackFunction}"](param);
        }
        closess();
    }
	</script>
    <e:window id="COMMON_TEXT_VIEW" onReady="init" initData="${initData}" title="${not empty param.title ? param.title : screenName}" breadCrumbs="${breadCrumb }">
		<e:textArea id="mmm" name="mm" width="100%" height="250px" value="${param.message}" required="" disabled="false" maxLength="" readOnly="true"/>
		<e:inputHidden id="rowId" name="rowId" value="${param.rowId}"/>
<%--  		<e:buttonBar id="buttonBar" align="right" width="100%">
		 	<e:button id="doApply" name="doApply" label="적용" onClick="apply"/>
            <e:button id="doClose" name="doClose" label="닫기" onClick="closess"/>
        </e:buttonBar> --%>
    </e:window>
</e:ui>