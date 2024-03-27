<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/rq/RQ0140P03";
	    function init() {


	    }

        function doClose2() {
     		if(opener != null) {
    			<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
	     			opener.doClose();
				</c:if>
     			window.close();
     		} else {
    			<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
	     			parent.doClose();
				</c:if>
     			new EVF.ModalWindow().close(null);
     		}
        }

        function doClose() {
     		if(opener != null) {
     			window.close();
     		} else {
     			new EVF.ModalWindow().close(null);
     		}
        }


	    function doReRfq() {
	        var store = new EVF.Store();
	    	if(!store.validate()) return;



			if(!checkTimeToServer()){
				return;
			}


			if (!confirm("${RQ0140P03_0001}")) return;

    		var store = new EVF.Store();
    		store.load(baseUrl + '/doReRfq', function(){
        		alert(this.getResponseMessage());
    			doClose2();
        	});

	    }




		function checkTimeToServer() {
			var validStartDate = EVF.V("RFX_FROM_DATE") + EVF.V("RFX_FROM_HOUR") + EVF.V("RFX_FROM_MIN");
			if ("${fromDate}" + "${todayTime}" > validStartDate) {
				alert("${RQ0140P03_0003}");
				return false
			}

			var validStartDate = EVF.V("RFX_TO_DATE") + EVF.V("RFX_TO_HOUR") + EVF.V("RFX_TO_MIN");
			if (EVF.V("RFX_FROM_DATE") + EVF.V("RFX_FROM_HOUR") + EVF.V("RFX_FROM_MIN") > validStartDate) {
				alert("${RQ0140P03_0002}");
				return false
			}
			return true;
		}


	</script>

	<e:window id="RQ0140P03" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch" useTitleBar="false">
        	<e:inputHidden id="CHG_TYPE" name="CHG_TYPE" value="END"/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
        	<e:inputHidden id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}"/>
        	<e:inputHidden id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}"/>

            <e:row>
				<%--견적종료일시--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
				<e:text> </e:text>
					<e:select id="RFX_FROM_HOUR" name="RFX_FROM_HOUR" value="" options="${rfxFromHourOptions}" width="${form_RFX_FROM_HOUR_W}" disabled="${form_RFX_FROM_HOUR_D}" readOnly="${form_RFX_FROM_HOUR_RO}" required="${form_RFX_FROM_HOUR_R}" placeHolder=""  usePlaceHolder="false"/>
				<e:text>시 </e:text>
					<e:select id="RFX_FROM_MIN" name="RFX_FROM_MIN" value="" options="${rfxFromMinOptions}" width="${form_RFX_FROM_MIN_W}" disabled="${form_RFX_FROM_MIN_D}" readOnly="${form_RFX_FROM_MIN_RO}" required="${form_RFX_FROM_MIN_R}" placeHolder=""  usePlaceHolder="false"/>
				<e:text>분 </e:text>
				<e:text> ~  </e:text>
					<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
				<e:text> </e:text>
					<e:select id="RFX_TO_HOUR" name="RFX_TO_HOUR" value="" options="${rfxToHourOptions}" width="${form_RFX_TO_HOUR_W}" disabled="${form_RFX_TO_HOUR_D}" readOnly="${form_RFX_TO_HOUR_RO}" required="${form_RFX_TO_HOUR_R}" placeHolder=""  usePlaceHolder="false"/>
				<e:text>시 </e:text>
					<e:select id="RFX_TO_MIN" name="RFX_TO_MIN" value="" options="${rfxToMinOptions}" width="${form_RFX_TO_MIN_W}" disabled="${form_RFX_TO_MIN_D}" readOnly="${form_RFX_TO_MIN_RO}" required="${form_RFX_TO_MIN_R}" placeHolder=""  usePlaceHolder="false"/>
				<e:text>분 </e:text>
				</e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doReRfq" name="doReRfq" label="${doReRfq_N}" onClick="doReRfq" disabled="${doReRfq_D}" visible="${doReRfq_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

	</e:window>
</e:ui>