<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		function doApply(){
			var trans_rmk = EVF.V('CONTENTS');
			if(trans_rmk == '' || trans_rmk == null){
				return alert('${RQ0110P01_0001}');
			}

			if (opener != null) {
				opener['${param.callBackFunction}'](contents);
			} else {
				parent['${param.callBackFunction}'](contents);
			}

			doClose();
		}

		function doClose(){
			if (opener != null) {
				window.close();
			} else {
				new EVF.ModalWindow().close(null);
			}
		}

	</script>

	<e:window id="RQ0110P01" onReady="init" initData="${initData}" title="${fullScreenName}" height="100%">
		<e:buttonBar id="buttonBar" align="right">
			<e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="1" labelWidth="${labelWidth }" useTitleBar="false" height="100%">
			<%--Contents--%>
			<e:label for="CONTENTS" title="${form_CONTENTS_N}"/>
			<e:field>
				<e:textArea id="CONTENTS" name="CONTENTS" value="" height="300px" width="${form_CONTENTS_W}" maxLength="${form_CONTENTS_M}" disabled="${form_CONTENTS_D}" readOnly="${form_CONTENTS_RO}" required="${form_CONTENTS_R}" />
			</e:field>

		</e:searchPanel>
	</e:window>
</e:ui>