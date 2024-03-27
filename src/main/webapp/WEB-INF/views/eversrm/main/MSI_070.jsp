<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>


    var baseUrl = "/eversrm/main/MSI_070/";

    function init() {
    	EVF.C('WORK_TYPE').setValue("P006");
    	EVF.C('LANG_CD').setValue("KO");
    	EVF.C('COUNTRY_CD').setValue("KR");
    	EVF.C('GMT_CD').setValue("GMT+09:00");
    	EVF.C('USER_DATE_FORMAT_CD').setValue("01");
    	EVF.C('USER_NUMBER_FORMAT_CD').setValue("02");
    }
    function checkPass() {
        var pass = EVF.C('PASSWORD').getValue();
        var passc = EVF.C('PASSWORD_CHECK').getValue();
        pass = pass.replace(/^\s*/, "").replace(/\s*$/, "");
        passc = passc.replace(/^\s*/, "").replace(/\s*$/, "");
        EVF.C('PASSWORD').setValue(pass);
        EVF.C('PASSWORD_CHECK').setValue(passc);

        if (pass == '' || (passc != '' && pass != passc)) {
            alert("${msg.M0028}");
            EVF.C('PASSWORD_CHECK').setValue('');
            return -1;
        }
        return 0;
    }
    function doClose() {
        formUtil.close();
    }

    function doSave() {

        if (EVF.C('PASSWORD').getValue() != EVF.C('PASSWORD_CHECK').getValue()) {
            alert("${msg.M0028}");
            return;
        }

        var store = new EVF.Store();
        if(!store.validate()) return;

    	var formData = {
	        USER_ID: EVF.C('USER_ID').getValue(),
	        WORK_TYPE: EVF.C('WORK_TYPE').getValue(),
	        USER_NM: EVF.C('USER_NM').getValue(),
	        USER_NM_ENG: EVF.C('USER_NM_ENG').getValue(),
	        PASSWORD: EVF.C('PASSWORD').getValue(),
	        PASSWORD_CHECK: EVF.C('PASSWORD_CHECK').getValue(),
	        EMAIL: EVF.C('EMAIL').getValue(),
	        TEL_NUM: EVF.C('TEL_NUM').getValue(),
	        CELL_NUM: EVF.C('CELL_NUM').getValue(),
	        LANG_CD: EVF.C('LANG_CD').getValue(),
	        COUNTRY_CD: EVF.C('COUNTRY_CD').getValue(),
	        GMT_CD: EVF.C('GMT_CD').getValue(),
	        USER_DATE_FORMAT_CD: EVF.C('USER_DATE_FORMAT_CD').getValue(),
	        USER_NUMBER_FORMAT_CD: EVF.C('USER_NUMBER_FORMAT_CD').getValue(),
	        POSITION_NM: EVF.C('POSITION_NM').getValue(),
	        DUTY_NM: EVF.C('DUTY_NM').getValue(),
	        FAX_NUM: EVF.C('FAX_NUM').getValue()
	    };

	    var sformData = JSON.stringify(formData);

	    var scData = '${screenData}';
	    var bsData = '${basicData}';

	    if (parent.parent.${callBackFunction} != undefined) {
	    	//alert("case1:parent.parent.");
	    	parent.parent.${callBackFunction}(sformData,scData,bsData);
	    } else if (parent.parent.parent.${callBackFunction} != undefined) {
	    	//alert("case2:parent.parent.parent.");
	    	parent.parent.parent.${callBackFunction}(sformData,scData,bsData);
	    }
	}

	function doClose() {
		new EVF.ModalWindow().close(null);
	}

	</script>
    <e:window id="MSI_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
        <e:searchPanel id="form" useTitleBar="true" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
			<e:select id="WORK_TYPE" name="WORK_TYPE" options="${workType }" width="${inputTextWidth}" disabled="${form_WORK_TYPE_D}" readOnly="${form_WORK_TYPE_RO}" required="${form_WORK_TYPE_R}" placeHolder="" visible="false"/>
			<e:select id="LANG_CD" name="LANG_CD" options="${langCd }" width="${inputTextWidth}" disabled="${form_LANG_CD_D}" readOnly="${form_LANG_CD_RO}" required="${form_LANG_CD_R}" placeHolder="" visible="false"/>
			<e:select id="COUNTRY_CD" name="COUNTRY_CD" options="${countryCd }" width="${inputTextWidth}" disabled="${form_COUNTRY_CD_D}" readOnly="${form_COUNTRY_CD_RO}" required="${form_COUNTRY_CD_R}" placeHolder="" visible="false"/>
			<e:select id="GMT_CD" name="GMT_CD" options="${gmtCd }" width="${inputTextWidth}" disabled="${form_GMT_CD_D}" readOnly="${form_GMT_CD_RO}" required="${form_GMT_CD_R}" placeHolder="" visible="false"/>
			<e:select id="USER_DATE_FORMAT_CD" name="USER_DATE_FORMAT_CD" options="${userDateFormat }" width="${inputTextWidth}" disabled="${form_USER_DATE_FORMAT_CD_D}" readOnly="${form_USER_DATE_FORMAT_CD_RO}" required="${form_USER_DATE_FORMAT_CD_R}" placeHolder="" visible="false"/>
			<e:select id="USER_NUMBER_FORMAT_CD" name="USER_NUMBER_FORMAT_CD" options="${userNumberFormat }" width="${inputTextWidth}" disabled="${form_USER_NUMBER_FORMAT_CD_D}" readOnly="${form_USER_NUMBER_FORMAT_CD_RO}" required="${form_USER_NUMBER_FORMAT_CD_R}" placeHolder="" visible="false"/>
               <e:row>
					<e:label for="USER_ID" title="${form_USER_ID_N}"/>
					<e:field colSpan="3">
					<e:inputText id="USER_ID" style="ime-mode:inactive" name="USER_ID" value="${form.USER_ID}" width="100%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
					 </e:field>
               </e:row>
               <e:row>
					<e:label for="USER_NM" title="${form_USER_NM_N}"/>
					<e:field>
					<e:inputText id="USER_NM" name="USER_NM" style="${imeMode}" value="${form.USER_NM}" width="100%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
					 </e:field>
					<e:label for="USER_NM_ENG" title="${form_USER_NM_ENG_N}"/>
					<e:field>
					<e:inputText id="USER_NM_ENG" style="ime-mode:inactive" name="USER_NM_ENG" value="${form.USER_NM_ENG}" width="100%" maxLength="${form_USER_NM_ENG_M}" disabled="${form_USER_NM_ENG_D}" readOnly="${form_USER_NM_ENG_RO}" required="${form_USER_NM_ENG_R}" />
					 </e:field>
               </e:row>
               <e:row>
					<e:label for="PASSWORD" title="${form_PASSWORD_N}"/>
					<e:field>
					<e:inputPassword id="PASSWORD" style="ime-mode:inactive" name="PASSWORD" value="${form.PASSWORD}" width="100%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리" />
					 </e:field>
					<e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N}"/>
					<e:field>
					<e:inputPassword id="PASSWORD_CHECK" style="ime-mode:inactive" name="PASSWORD_CHECK" value="${form.PASSWORD_CHECK}" width="100%" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리" />
					 </e:field>
               </e:row>
               <e:row>
					<e:label for="EMAIL" title="${form_EMAIL_N}"/>
					<e:field>
					<e:inputText id="EMAIL" name="EMAIL" style="ime-mode:inactive" value="${form.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" />
					 </e:field>
					<e:label for="TEL_NUM" title="${form_TEL_NUM_N}"/>
					<e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" style="ime-mode:inactive" value="${form.TEL_NUM}" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" />
					 </e:field>
               </e:row>
               <e:row>
					<e:label for="CELL_NUM" title="${form_CELL_NUM_N}"/>
					<e:field>
					<e:inputText id="CELL_NUM" name="CELL_NUM" style="ime-mode:inactive" value="${form.CELL_NUM}" width="100%" maxLength="${form_CELL_NUM_M}" disabled="${form_CELL_NUM_D}" readOnly="${form_CELL_NUM_RO}" required="${form_CELL_NUM_R}" />
					 </e:field>
					<e:label for="FAX_NUM" title="${form_FAX_NUM_N}"/>
					<e:field>
					<e:inputText id="FAX_NUM" name="FAX_NUM" style="ime-mode:inactive" value="${form.FAX_NUM}" width="100%" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" />
					 </e:field>
               </e:row>
               <e:row>
					<e:label for="POSITION_NM" title="${form_POSITION_NM_N}"/>
					<e:field>
					<e:inputText id="POSITION_NM" name="POSITION_NM" style="${imeMode}" value="${form.POSITION_NM}" width="100%" maxLength="${form_POSITION_NM_M}" disabled="${form_POSITION_NM_D}" readOnly="${form_POSITION_NM_RO}" required="${form_POSITION_NM_R}" />
					 </e:field>
					<e:label for="DUTY_NM" title="${form_DUTY_NM_N}"/>
					<e:field>
					<e:inputText id="DUTY_NM" name="DUTY_NM" style="${imeMode}" value="${form.DUTY_NM}" width="100%" maxLength="${form_DUTY_NM_M}" disabled="${form_DUTY_NM_D}" readOnly="${form_DUTY_NM_RO}" required="${form_DUTY_NM_R}" />
					 </e:field>
               </e:row>
        </e:searchPanel>


	</e:window>
</e:ui>