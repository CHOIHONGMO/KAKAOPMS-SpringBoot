<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid = {};
		var baseUrl = "/eversrm/eContract/eContractMgt/";

		function init() {

		}

		function doSave() {
			var reason = EVF.C('REJECT_RMK').getValue();
	        if (reason === '') {
	        	return alert('${SECM_020_0001}'); // Please insert the reject reason.
	        }

	        var result = {};
	        result.reason = reason;

	        if (confirm('${msg.M0022}')) {
	            opener.window['${param.callBackFunction}'](result);
	            window.close();
	        }
        }
        function doClose() {
	        window.close();
        }


    </script>

	<e:window id="SECM_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
			<e:row>
				<e:field>
					<e:textArea id="REJECT_RMK" name="REJECT_RMK" height="260px" value="${param.REJECT_RMK}" width="100%" maxLength="${form_REJECT_RMK_M}" disabled="${form_REJECT_RMK_D}" readOnly="${form_REJECT_RMK_RO}" required="${form_REJECT_RMK_R}" />
				</e:field>
            </e:row>
		</e:searchPanel>

	</e:window>

</e:ui>
