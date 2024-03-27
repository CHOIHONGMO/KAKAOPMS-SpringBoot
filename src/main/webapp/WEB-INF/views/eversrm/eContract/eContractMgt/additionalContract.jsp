<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<w:ux debug="${wiseDebug }" theme="${wiseTheme }" locale="${ses.langCode}_${ses.countryCode}">
	<w:loadCSS src="/css/icon.css,/css/contract.css" />
	<w:loadJS src="${jsInclude},/toolkit/tradesign/TSToolkitConfig.js,/toolkit/tradesign/TSToolkitObject.js" />
	<w:dataModel>
		<w:valueObject initByTags="true" id="searchTerms" type="List<com.icompia.wisec.common.util.domain.GeneralCombo>" />
		<w:valueObject initByTags="true" id="refYN" type="List<com.icompia.wisec.common.util.domain.GeneralCombo>" />
	</w:dataModel>
	<w:script>

    var grid;
    var baseUrl = "/wisepro/eContract/eContractMgt/contractRegistration/";
    var userType = '${ses.userType}';
    var toolkit;
    var contractEditable = WUX.bool('${param.contractEditable}');
    var mainContractContentsAfter;
    var mainContractContentsBefore;
    var detailView = WUX.bool('${empty param.detailView ? false : param.detailView}');

    function init() {
        setButton();
    };

    function setButton() {
        if (!detailView) {
            switch (userType) {
            case 'C':
                if (contractEditable) {
                    formUtil.setVisible(['doSave'], true);
                }
                break;
            case 'S':
                if (contractEditable) {
                    formUtil.setVisible(['doConfirm'], true);
                }
                break;
            }
        }
        formUtil.setVisible(['doClose'], true);
    };

    function doConfirm() {
        return doSave();
    };

    function doSave() {

        var isValidForm = true;$ ('#additionalContractContents input').each(function() {
            var langCode = '${ses.langCode}'.toLowerCase();
            var formValue = eval('contUtil.langCode.' + langCode + '.' + this.name);
            if (formValue == this.value) {
                alert('${BPE_052_0001}');
                this.focus();
                isValidForm = false;
                return false;
            }
            this.setAttribute('value', this.value);
        });

        if (!isValidForm) {
            return;
        }

        $ ('#additionalContractContents textarea').each(function() {$ (this).html($ (this).val());
        });

        var params = {
            rowIndex: '${param.rowIndex}',
            relFormNo: '${param.relFormNo}',
            formTextNo: '${param.formTextNo}',
            contents: $ ('#additionalContractContents').html()
        };
        opener.window['${param.callBackFunction}'](params);
        doClose();
    };

    function doClose() {
        formUtil.close();
    };
	</w:script>
	<w:window id="window" onReady="init" initData="${initData}">
		<w:panel caption="${fullScreenName}" width="1ft" height="1ft" padding="true" scrollable="true" styleName="${wiseStyleName}" breadCrumb="${breadCrumb}">
			<w:fieldPanel value="@{dataForm}" id="form" labelWidth="${labelWidth}" labelAlign="${labelAlign}">
				<w:fieldGroup>
					<w:space width="1ft" />
					<w:button caption='${doConfirm_N }' id='doConfirm' onClick='doConfirm' disabled='${doConfirm_D }' visible='${doConfirm_V }' userData='${doConfirm_A }'/>
					<w:button caption='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' userData='${doSave_A }' />
					<w:button caption='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' userData='${doClose_A }' />
				</w:fieldGroup>
				<w:fieldPanel scrollable="true" height="700" styleName="plain">
					<w:html height="1ft" width="1ft">
					<div id="additionalContractContents" style="width: 100%; height: 100%; overflow: scroll;">
					   ${contents}
					</div>
					</w:html>
				</w:fieldPanel>
				<w:space height="10" />
			</w:fieldPanel>
		</w:panel>
	</w:window>
</w:ux>