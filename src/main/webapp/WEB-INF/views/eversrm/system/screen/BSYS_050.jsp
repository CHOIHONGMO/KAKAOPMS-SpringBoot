<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var addParam = [];
    	var baseUrl = "/eversrm/system/screen/";
    	
		function init() {

        }

		function doSave() {

			var store = new EVF.Store();
			if(!store.validate()) { return;}

			var param = {
                "COPY_SCREEN_ID" : EVF.C("SCREEN_ID").getValue(),
                "COPY_SCREEN_NM" : EVF.C("SCREEN_NM").getValue(),
                "COPY_SCREEN_URL" : EVF.C("SCREEN_URL").getValue()
            };

            if (opener != null) {
                opener['${param.callbackFunction}'](param);
            }
            doClose();
        }

		function doClose() {
            window.close();
        }

    </script>
    <e:window id="BSYS_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false">
        	<e:row>
                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
                <e:field>
                	<e:inputText id="SCREEN_ID" name="SCREEN_ID" width="100%" required="${form_SCREEN_ID_R }" disabled="${form_SCREEN_ID_D }" value="${param.COPY_SCREEN_ID }" readOnly="${form_SCREEN_ID_RO }" maxLength="${form_SCREEN_ID_M}" />
                </e:field>
                <e:label for="SCREEN_NM" title="${form_SCREEN_NM_N }" />
                <e:field>
                	<e:inputText id="SCREEN_NM" name="SCREEN_NM" width="100%" required="${form_SCREEN_NM_R }" disabled="${form_SCREEN_NM_D }" value="${param.COPY_SCREEN_NM }" readOnly="${form_SCREEN_NM_RO }" maxLength="${form_SCREEN_NM_M}" />
                </e:field>
            </e:row>
			<e:row>
				<e:label for="SCREEN_URL" title="${form_SCREEN_URL_N }" />
                <e:field colSpan="3">
                	<e:inputText id="SCREEN_URL" name="SCREEN_URL" width="100%" required="${form_SCREEN_URL_R }" disabled="${form_SCREEN_URL_D }" value="${param.COPY_SCREEN_URL }" readOnly="${form_SCREEN_URL_RO }" maxLength="${form_SCREEN_URL_M}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
        </e:buttonBar>

    </e:window>
</e:ui>