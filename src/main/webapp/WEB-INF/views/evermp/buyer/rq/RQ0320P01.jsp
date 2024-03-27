<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/rq";
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
	        var store = new EVF.Store();
	    	if(!store.validate()) return;

	    	if(!checkEndChg()){ return alert('${RQ0320P01_0001}') }

			if (!confirm("${msg.M0021 }")) return;

    		var store = new EVF.Store();
    		store.load(baseUrl + '/RQ0320P01/chgEndDate', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
	    }

	    function checkEndChg(){
		    var enddate= EVF.V('RFX_TO_DATE').replace(/^(\d{4})(\d{2})(\d{2})$/, "$1-$2-$3")
		    var endtime = enddate + ' ' + EVF.V('RFX_HH') + ':' + EVF.V('RFX_MM') + ':00';
		    var end = Date.parse(endtime);

		    var cur = new Date();

		    if(end < cur){
		    	return false;
		    }else{
		    	return true;
		    }

		}


	</script>

	<e:window id="RQ0320P01" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch" useTitleBar="false">
        	<e:inputHidden id="CHG_TYPE" name="CHG_TYPE" value="END"/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
        	<e:inputHidden id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}"/>
        	<e:inputHidden id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}"/>
        	<e:inputHidden id="RFX_FROM_DATE" name="RFX_FROM_DATE" value="${form.RFX_FROM_DATE}"/>

            <e:row>
				<%--견적종료일시--%>
				<e:label for="RFX_TO_DATE" title="${form_RFX_TO_DATE_N}"/>
				<e:field>
				<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" fromDate="RFX_FROM_DATE" value="${form.RFX_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
				<e:text> </e:text>
				<e:select id="RFX_HH" name="RFX_HH" value="${form.TO_RFX_HH}" options="${rfxHhOptions}" width="${form_RFX_HH_W}" disabled="${form_RFX_HH_D}" readOnly="${form_RFX_HH_RO}" required="${form_RFX_HH_R}" placeHolder="" usePlaceHolder="false"/>
				<e:text>시 </e:text>
				<e:select id="RFX_MM" name="RFX_MM" value="${form.TO_RFX_MM}" options="${rfxMmOptions}" width="${form_RFX_MM_W}" disabled="${form_RFX_MM_D}" readOnly="${form_RFX_MM_RO}" required="${form_RFX_MM_R}" placeHolder="" usePlaceHolder="false"/>
				<e:text>분 </e:text>
				</e:field>
            </e:row>
            <e:row>
				<%--마감일시연장사유--%>
				<e:label for="TO_EXTEND_RMK" title="${form_TO_EXTEND_RMK_N}"/>
				<e:field>
					<e:textArea id="TO_EXTEND_RMK" name="TO_EXTEND_RMK" value="" height="250" width="${form_TO_EXTEND_RMK_W}" maxLength="${form_TO_EXTEND_RMK_M}" disabled="${form_TO_EXTEND_RMK_D}" readOnly="${form_TO_EXTEND_RMK_RO}" required="${form_TO_EXTEND_RMK_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

	</e:window>
</e:ui>