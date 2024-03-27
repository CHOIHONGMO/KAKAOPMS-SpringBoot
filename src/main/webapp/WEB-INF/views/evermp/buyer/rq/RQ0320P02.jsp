<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/rq/RQ0320P02";
	    function init() {


	    }


        function doClose() {
     		if(opener != null) {
    			<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
	     			opener.doSearch();
				</c:if>
     			window.close();
     		} else {
    			<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
	     			parent.doSearch();
				</c:if>
     			new EVF.ModalWindow().close(null);
     		}
        }



	    function doSave() {

	    	var toDate = new Date(EVF.V('RFX_TO_DATE2'));
	    	var fromDateString = EVF.V('RFX_FROM_DATE').substring(0,4) + '-' + EVF.V('RFX_FROM_DATE').substring(4,6) + '-' + EVF.V('RFX_FROM_DATE').substring(6,8) + ' ' + EVF.V('RFX_HH') + ':' + EVF.V('RFX_MM');
	    	var fromDate = new Date(fromDateString);

	    	var rfxdate = new Date(EVF.V('RFX_DATE_TIME'));

	    	if(fromDate <= rfxdate){
			    return EVF.alert('${RQ0320P02_002}');
			}

	    	if(fromDate >= toDate){
	    		return EVF.alert('${RQ0320P02_001}');
			}

	        var store = new EVF.Store();
	    	if(!store.validate()) return;
			if (!confirm("${msg.M0021 }")) return;

    		var store = new EVF.Store();
    		store.load(baseUrl + '/chgStartDate', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
	    }




	</script>

	<e:window id="RQ0320P02" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="" useTitleBar="false">
        	<e:inputHidden id="CHG_TYPE" name="CHG_TYPE" value="START"/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
        	<e:inputHidden id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}"/>
        	<e:inputHidden id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}"/>
        	<e:inputHidden id="RFX_TO_DATE2" name="RFX_TO_DATE2" value="${form.RFX_TO_DATE2}"/>
			<e:inputHidden id="RFX_DATE_TIME" name="RFX_DATE_TIME" value="${form.RFX_DATE}" />
			<e:inputDate id="RFX_DATE" name="RFX_DATE" value="${RFX_DATE}"  disabled="false" readOnly="true" required="false" style="display:none"/>
            <e:row>
				<%--시작일자--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
				<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" fromDate="RFX_DATE" value="${form.RFX_FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
				<e:text> </e:text>
				<e:select id="RFX_HH" name="RFX_HH" value="${form.FROM_RFX_HH}" options="${rfxHhOptions}" width="${form_RFX_HH_W}" disabled="${form_RFX_HH_D}" readOnly="${form_RFX_HH_RO}" required="${form_RFX_HH_R}" placeHolder="" usePlaceHolder="false"/>
				<e:text>시 </e:text>
				<e:select id="RFX_MM" name="RFX_MM" value="${form.FROM_RFX_MM}" options="${rfxMmOptions}" width="${form_RFX_MM_W}" disabled="${form_RFX_MM_D}" readOnly="${form_RFX_MM_RO}" required="${form_RFX_MM_R}" placeHolder="" usePlaceHolder="false"/>
				<e:text>분 </e:text>
				</e:field>
            </e:row>
            <e:row>
				<%--시작일시변경사유--%>
				<e:label for="FROM_MOD_RMK" title="${form_FROM_MOD_RMK_N}" />
				<e:field>
				<e:textArea height="250" width="100%" disabled="false" maxLength="4000" required="${form_FROM_MOD_RMK_R}"  id="FROM_MOD_RMK" readOnly="${param.detailView}" name="FROM_MOD_RMK"  value="${param.TEXT_CONTENTS }"/>
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

	</e:window>
</e:ui>