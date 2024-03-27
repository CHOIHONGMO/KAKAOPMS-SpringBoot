<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<w:ux debug="${wiseDebug }" theme="${wiseTheme }" locale="${ses.langCode}_${ses.countryCode}">
	<w:loadCSS src="/css/icon.css" />
	<w:loadJS src="${jsInclude}" />  
	<w:dataModel>
		<w:valueObject initByTags="true" id="popupIds" type="List<Map>" />
		<w:valueObject initByTags="true" id="comboIds" type="List<Map>" />
		<w:valueObject initByTags="true" id="codeTypes" type="List<Map>" />
		<w:valueObject initByTags="true" id="comboData" type="List<Map>" />
		<w:valueObject initByTags="true" id="codeData" type="List<Map>" />
		<w:valueObject initByTags="true" id="comboFormData" type="Map" />
	</w:dataModel>
	<w:script>

    var baseUrl = '/wisec/common/commonPopup/commonPopupSample';

    function init() {
        var param = {
            HOUSE_CODE: '100',
            BUYER_CODE: '900',
            callBackFunction: 'callbackFunction'
        }
        WUX.getComponent('parameters').setValue(JSON.stringify(param));
    }

    function openPopup() {
        var param = JSON.parse(WUX.getComponent('parameters').getValue());
        var commmonId = WUX.getComponent('popupIds').getValue();
        if (commmonId === '') {
            alert('Select Popup Id');
            return;
        }
        wisePopup.openCommonPopup(param, commmonId);
    }

    function callbackFunction(selectedData) {
        var data = JSON.stringify(selectedData);
        WUX.getComponent('textArea').setValue(data);
    }

    function doSearch() {
        var store = new WUX.data.Store();
        store.setProxy(baseUrl + '/doSearch.wu');
        store.setValueObject('searchCondition');
        WUX.getValueObject('searchCondition').mark();
        store.load(function() {});
    }

    function changeComboId() {
        var store = new WUX.data.Store();
        store.setProxy(baseUrl + '/changeComboId.wu');
        store.setValueObject('comboFormData');
        WUX.getValueObject('comboFormData').mark();
        store.load(function() {});
    }

    function changeCodeType() {
        var codeType = WUX.getComponent('codeTypes').getValue()
        var store = new WUX.data.Store();
        store.setProxy(baseUrl + '/changeCodeType.wu');
        store.setParameter('codeType', codeType);
        store.load(function() {});
    }

    function codeDataChange() {
        alert(this.getValue());
    }

    function comboDataChange() {
        alert(this.getValue());
    }

    function doInit() {}

    function doChoose() {}

    function doClose() {
        window.close();
    }
	</w:script>

	<w:window height="1ft" width="1ft" id="window" onReady="init" initData="${initData}">
		<w:panel caption="Common Popup" padding="true" spacing="true" scrollable="true" width="1ft" styleName="light">
			<w:fieldPanel labelWidth="130">
				<w:select id="popupIds" label="Popup ID" width="600" placeHolder="==SELECT==">
					<w:options value="@{popupIds}">
						<w:optionText value="@{.text}" />
						<w:optionVal value="@{.value}" />
					</w:options>
				</w:select>
				<w:textArea id="parameters" label="Parameters" width="600" height="100" />
				<w:button caption="Common Popup" onClick="openPopup" />
				<w:textArea id="textArea" width="600" height="100" label="Result" />
			</w:fieldPanel>
		</w:panel>

		<w:panel caption="Common Combo from sql" padding="true" spacing="true" scrollable="true" width="1ft" styleName="light">
			<w:fieldPanel labelWidth="130" value="@{comboFormData}">
				<w:select id="comboIds" label="COMMON ID" width="600" placeHolder="==SELECT==" onChange="changeComboId">
					<w:options value="@{comboIds}">
						<w:optionText value="@{.text}" />
						<w:optionVal value="@{.value}" />
					</w:options>
				</w:select>
				<w:select id="comboData" label="Result ID" width="600" onChange="comboDataChange">
					<w:options value="@{comboData}">
						<w:optionText value="@{.text}" />
						<w:optionVal value="@{.value}" />
					</w:options>
				</w:select>
			</w:fieldPanel>
		</w:panel>
		<w:panel caption="Common Combo from ICOMCODD" padding="true" spacing="true" scrollable="true" width="1ft" height="1ft" styleName="light">
			<w:fieldPanel labelWidth="130" value="@{comboFormData}">
				<w:select id="codeTypes" label="Code Type" width="600" placeHolder="==SELECT==" onChange="changeCodeType">
					<w:options value="@{codeTypes}">
						<w:optionText value="@{.text}" />
						<w:optionVal value="@{.value}" />
					</w:options>
				</w:select>
				<w:select id="codeData" label="Result ID" width="600" onChange="codeDataChange">
					<w:options value="@{codeData}">
						<w:optionText value="@{.text}" />
						<w:optionVal value="@{.value}" />
					</w:options>
				</w:select>
			</w:fieldPanel>
		</w:panel>
	</w:window>
</w:ux>
