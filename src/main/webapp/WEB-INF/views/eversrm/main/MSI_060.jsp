<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
    var baseUrl = "/eversrm/main/";

    function init() {
        window.resizeTo(800, 300);
    }

    function checkPass() {
        var pass = EVF.C('PASSWORD').getValue();
        var passc = EVF.C('PASSWORD_CHECK').getValue();
        pass = pass.replace(/^\s*/, "").replace(/\s*$/, "");
        passc = passc.replace(/^\s*/, "").replace(/\s*$/, "");
        EVF.C('PASSWORD').setValue(pass);
        EVF.C('PASSWORD_CHECK').setValue(passc);

        if (pass == '' || passc == '' || pass != passc) {
            alert("${msg.M0028}");
            EVF.C('PASSWORD_CHECK').setValue('');
            return false;
        }
        return true;
    }
    function doRegister() {
    	
    	var store = new EVF.Store();        	
        store.load(baseUrl + 'checkUserInfo/doRegister', function() {
        	 var formValues = JSON.parse(this.getParameter('formDatas'));

             if (formValues != null) {
                 var url = "/session/viewContents/view";
                 var param = {
                     realUrl: "/eversrm/master/vendor/BBV_010/view.so?SCREEN_ID=BBV_010",
                     irsNum: formValues.irsNum,
                     langCd: formValues.langCd,
                     gateCd: formValues.gateCd,
                     portalType: "NEW",
                     openType: "CS",
                     detailView: false
                 };
                 everPopup.openWindowPopup(url, 1000, 800, param, "vendorReginfo");
                 window.close();
             }
        });
    	
    }

    function doChange() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        
    	EVF.C("USER_ID").setValue(everString.lrTrim(EVF.C("USER_ID").getValue()));
        EVF.C("PASSWORD").setValue(everString.lrTrim(EVF.C("PASSWORD").getValue()));
        EVF.C("USER_ID").setValue(everString.lrTrim(EVF.C("USER_ID").getValue()).toUpperCase());

        
    	var store = new EVF.Store();        	
        store.load(baseUrl + 'checkUserInfo/doChange', function() {
        	 var formValues = JSON.parse(this.getParameter('formDatas'));

        	 //alert( JSON.stringify(formValues) );	
        	 
        	 if (formValues != null) {
                 var url = "/session/viewContents/view";
                 var param = {
                     realUrl: "/eversrm/master/vendor/BBV_010/view.so?SCREEN_ID=BBV_010",
                     irsNum: formValues.irsNum,
                     langCd: formValues.langCd,
                     gateCd: formValues.gateCd,
                     userId: formValues.userId,
                     vendorCd: formValues.vendorCd,
                     VENDOR_CD: formValues.vendorCd,
                     portalType: "CHANGE",
                     openType: "CS",
                     detailView: false
                 };
                 everPopup.openWindowPopup(url, 1000, 800, param, "vendorinfo");
                 window.close();
             }
        });        

    }
	</script>
    
    
    
    
      <e:window id="MSI_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" useTitleBar="false" title="${MSI_040_CAPTION_LINE2}" onEnter="doSearch" columnCount="1" labelWidth="120">
        	<e:row>
        	    <e:field colSpan="2">
					<e:text><b>*${MSI_060_LINE_02}</b></e:text>
	            </e:field>
	    	</e:row>  
	    </e:searchPanel>   
        <e:buttonBar id="buttonBar" align="center" width="100%">
			<e:button id="doRegister" name="doRegister" label="${doRegister_N}" onClick="doRegister" disabled="${doRegister_D}" visible="${doRegister_V}"/>
		</e:buttonBar>        
		
		<e:searchPanel id="form2" useTitleBar="false" title="${MSI_040_CAPTION_LINE2}" onEnter="doSearch" columnCount="1" labelWidth="120">
        	<e:row>
        	    <e:field colSpan="2">
					<e:text><b>*${MSI_060_LINE_01}</b></e:text>
	            </e:field>
	     	</e:row>              
	     
        	<e:row>
				<e:label for="USER_ID" title="${form_USER_ID_N}"/>
				<e:field>
				<e:inputText id="USER_ID" name="USER_ID" value="${form.USER_ID}" width="50%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
				 </e:field>
	     	</e:row>  	     
	     
	        <e:row>
				<e:label for="PASSWORD" title="${form_PASSWORD_N}"/>
				<e:field>
					<e:inputText id="PASSWORD" name="PASSWORD" value="${form.PASSWORD}" width="50%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}" />
					<e:inputHidden id="PASSWORD_CHECK" name="PASSWORD_CHECK"/>
					<e:inputHidden id="GATE_CD" name="GATE_CD" value="${searchParam.GATE_CD }"  />
					<e:inputHidden id="LANG_CD" name="LANG_CD" value="${searchParam.LANG_CD }" />
					<e:inputHidden id="IRS_NUM" name="IRS_NUM"  value="${searchParam.IRS_NUM }"  />
					<e:inputHidden id="userType" name="userType"/>
			    </e:field>
		   </e:row>	     
	     
        </e:searchPanel>
        <e:buttonBar id="buttonBar1" align="center" width="100%">
			<e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}"/>
		</e:buttonBar>        
    </e:window>
    
</e:ui>        