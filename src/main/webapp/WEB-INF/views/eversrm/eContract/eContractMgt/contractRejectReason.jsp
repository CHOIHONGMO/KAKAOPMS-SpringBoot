<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<w:ux debug="${wiseDebug }" theme="${wiseTheme }" locale="${ses.langCode}_${ses.countryCode}">
	<w:loadCSS src="/css/icon.css,/css/contract.css" />
	<w:loadJS src="${jsInclude},/toolkit/tradesign/TSToolkitConfig.js,/toolkit/tradesign/TSToolkitObject.js" />
	<w:dataModel>
		<w:valueObject id="dataForm" type="Map" />
	</w:dataModel>
	<w:script>

    var grid;
    var baseUrl = "/wisepro/eContract/eContractMgt/contractRegistration/";

    function init() {

    };

    function doSave() {
        var reason = WUX.getComponent('REJECT_REMARK').getValue();
        if (reason === '') {
            return alert('BPE_051_0001'); // Please insert the reject reason.
        }

        var result = {};
        result.reason = reason;

        if (confirm('${msg.M0030}')) {
            opener.window['${param.callBackFunction}'](result);
            window.close();
        }

    };

    function doClose() {
        formUtil.close();
    };
	</w:script>
	<w:window id="window" onReady="init" initData="${initData}">
		<w:panel caption="${fullScreenName}" width="1ft" height="1ft" padding="true" scrollable="true" styleName="${wiseStyleName}" breadCrumb="${breadCrumb}">
			<w:fieldPanel value="@{dataForm}" id="form" labelWidth="${labelWidth}" labelAlign="${labelAlign}" height="1ft">
				<w:fieldGroup>
					<w:space width="1ft" />
					<w:button caption='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' userData='${doSave_A }'/>
					<w:button caption='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' userData='${doClose_A }'/>
				</w:fieldGroup>
				<w:fieldGroup height="1ft">
                       <w:textArea id="REJECT_REMARK" height="1ft" width="1ft" placeHolder="${BPE_051_REJECT_REASON }" />
				</w:fieldGroup>
			</w:fieldPanel>
		</w:panel>
	</w:window>
</w:ux>