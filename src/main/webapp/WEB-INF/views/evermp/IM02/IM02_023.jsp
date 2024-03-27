<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";

        function init() {

        }

        function doSave() {

        	var store = new EVF.Store();
			if(!store.validate()) { return; }

			store.load(baseUrl + 'im02023_doSave', function(){
           		alert(this.getResponseMessage());
				opener.doSearch();
				doClose();
           	});
        }


		function doClose() {
			window.close();
        }

    </script>

    <e:window id="IM02_023" onReady="init" initData="${initData}" title="${formData.ITEM_CLS_NM }" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false">
            <e:row>
            	<e:label for="TIER_A_RATE" title="${form_TIER_A_RATE_N}"/>
		        <e:field>
		        	<e:inputNumber id="TIER_A_RATE" name="TIER_A_RATE" value="" width="${form_TIER_A_RATE_W}" maxValue="${form_TIER_A_RATE_M}" decimalPlace="${form_TIER_A_RATE_NF}" disabled="${form_TIER_A_RATE_D}" readOnly="${form_TIER_A_RATE_RO}" required="${form_TIER_A_RATE_R}" />
		        </e:field>
            	<e:label for="TIER_B_RATE" title="${form_TIER_B_RATE_N}"/>
		        <e:field>
		        	<e:inputNumber id="TIER_B_RATE" name="TIER_B_RATE" value="" width="${form_TIER_B_RATE_W}" maxValue="${form_TIER_B_RATE_M}" decimalPlace="${form_TIER_B_RATE_NF}" disabled="${form_TIER_B_RATE_D}" readOnly="${form_TIER_B_RATE_RO}" required="${form_TIER_B_RATE_R}" />
		        </e:field>
		        <e:label for="TIER_C_RATE" title="${form_TIER_C_RATE_N}"/>
		        <e:field>
		        	<e:inputNumber id="TIER_C_RATE" name="TIER_C_RATE" value="" width="${form_TIER_C_RATE_W}" maxValue="${form_TIER_C_RATE_M}" decimalPlace="${form_TIER_C_RATE_NF}" disabled="${form_TIER_C_RATE_D}" readOnly="${form_TIER_C_RATE_RO}" required="${form_TIER_C_RATE_R}" />
		        </e:field>
            </e:row>
            <e:row>
            	<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
		        <e:field>
		        	<e:text>${formData.REG_DATE }</e:text>
		        </e:field>
            	<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
		        <e:field>
		        	<e:text>${formData.REG_USER_NM }</e:text>
		        </e:field>
            	<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
		        <e:field>
		        	<e:text>${formData.REQ_USER_NM }</e:text>
		        	<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${formData.ITEM_CLS1 }"/>
		        	<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${formData.ITEM_CLS2 }"/>
		        	<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${formData.ITEM_CLS3 }"/>
		        	<e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${formData.ITEM_CLS4 }"/>
		        	<e:inputHidden id="TIER_CD" name="TIER_CD" value="${formData.TIER_CD }"/>
		        	<e:inputHidden id="REG_USER_ID" name="REG_USER_ID" value="${formData.REG_USER_ID }"/>
		        	<e:inputHidden id="REQ_USER_ID" name="REQ_USER_ID" value="${formData.REQ_USER_ID }"/>
		        </e:field>
            </e:row>
            <e:row>
                <e:label for="AMEND_REASON" title="${form_AMEND_REASON_N}"/>
                <e:field colSpan="5">
                    <e:textArea id="AMEND_REASON" name="AMEND_REASON" value="" width="100%" height="200px" disabled="${form_AMEND_REASON_D }" maxLength="${form_AMEND_REASON_M }" required="${form_AMEND_REASON_R }" readOnly="${form_AMEND_REASON_RO }" />
                </e:field>
            </e:row>
        </e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
            <e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" />
        </e:buttonBar>

    </e:window>
</e:ui>