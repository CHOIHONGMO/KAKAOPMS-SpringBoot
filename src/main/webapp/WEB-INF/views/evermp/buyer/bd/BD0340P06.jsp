<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd";
	    function init() {


	    }

        function doClose() {
     		if(opener != null) {
    			<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
	     			opener.doSearchVendor();
				</c:if>
     			window.close();
     		} else {
    			<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
	     			parent.doSearchVendor();
				</c:if>
     			new EVF.ModalWindow().close(null);
     		}
        }


	    function doSave() {
	        var store = new EVF.Store();
	    	if(!store.validate()) return;

	    	if(!checkTimeToServer()){
	    		return;
			}

			if (!confirm("${msg.M0021 }")) return;

			var nextQtaCnt = Number(EVF.V('QTA_CNT')) + 1;
			EVF.V('QTA_CNT',nextQtaCnt);

    		var store = new EVF.Store();
    		store.load(baseUrl + '/BD0340P06/chgBidDateForRebid', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
	    }


	    function checkTimeToServer() {

		    //시작날짜가 오늘 날짜와 지금 시각보다 커야 함.
		    if (!EVF.isEmpty(EVF.V("RFX_FROM_DATE")) && !EVF.isEmpty(EVF.V("RFX_FROM_HOUR"))){
			    var now = new Date();
			    var month = (now.getMonth()+1) < 10 ? '0' + (now.getMonth()+1).toString() : (now.getMonth()+1).toString();
			    var date = now.getDate() < 10 ? '0' + (now.getDate()).toString() : now.getDate().toString();
			    var hour = now.getHours() < 10 ? '0' + now.getHours().toString() : now.getHours().toString();
			    var validStartDate = now.getFullYear().toString() + month + date + hour;
			    var curStartDate = EVF.V('RFX_FROM_DATE') + EVF.V('RFX_FROM_HOUR');
			    if ( curStartDate < validStartDate) {
				    EVF.alert("${BD0340P06_0001}");
				    return false;
			    }
		    }

		    //견적이 끝나는 날짜가 시작날짜보다 커야 함
		    if (!EVF.isEmpty(EVF.V("RFX_TO_DATE")) && !EVF.isEmpty(EVF.V("RFX_TO_HOUR")) && !EVF.isEmpty(EVF.V("RFX_TO_MIN"))) {
			    let settledfromtime = EVF.V("RFX_FROM_DATE") + EVF.V("RFX_FROM_HOUR") + EVF.V("RFX_FROM_MIN");
			    let settledtotime = EVF.V("RFX_TO_DATE") + EVF.V("RFX_TO_HOUR") + EVF.V("RFX_TO_MIN");
			    if (settledfromtime > settledtotime) {
				    EVF.alert("${BD0340P06_0002}");
				    return false;
			    }
		    }

		    return true;
	    }


	</script>

	<e:window id="BD0340P06" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
		<e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch" useTitleBar="false">
        	<e:inputHidden id="CHG_TYPE" name="CHG_TYPE" value="END"/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
        	<e:inputHidden id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}"/>
        	<e:inputHidden id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}"/>
			<e:inputHidden id="QTA_NUM" name="QTA_NUM" value="${form.QTA_NUM}"/>
			<e:inputHidden id="QTA_CNT" name="QTA_CNT" value="${form.QTA_CNT}"/>
			<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" />

			<e:row>
				<%--입찰시작일시--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" toDate="RFX_TO_DATE" value="${form.RFX_FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
					<e:text> </e:text>
					<e:select id="RFX_FROM_HOUR" name="RFX_FROM_HOUR" value="${form.RFX_FROM_HOUR}" options="${rfxFromHourOptions}" width="${form_RFX_FROM_HOUR_W}" disabled="${form_RFX_FROM_HOUR_D}" readOnly="${form_RFX_FROM_HOUR_RO}" required="${form_RFX_FROM_HOUR_R}" placeHolder="" />
					<e:text>시 </e:text>
					<e:select id="RFX_FROM_MIN" name="RFX_FROM_MIN" value="${form.RFX_FROM_MIN}" options="${rfxFromMinOptions}" width="${form_RFX_FROM_MIN_W}" disabled="${form_RFX_FROM_MIN_D}" readOnly="${form_RFX_FROM_MIN_RO}" required="${form_RFX_FROM_MIN_R}" placeHolder="" />
					<e:text>분 </e:text>
				</e:field>
			</e:row>
            <e:row>
				<%--입찰종료일시--%>
				<e:label for="RFX_TO_DATE" title="${form_RFX_TO_DATE_N}"/>
				<e:field>
				<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" fromDate="RFX_FROM_DATE" value="${form.RFX_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
				<e:text> </e:text>
				<e:select id="RFX_TO_HOUR" name="RFX_TO_HOUR" value="${form.RFX_TO_HOUR}" options="${rfxToHourOptions}" width="${form_RFX_TO_HOUR_W}" disabled="${form_RFX_TO_HOUR_D}" readOnly="${form_RFX_TO_HOUR_RO}" required="${form_RFX_TO_HOUR_R}" placeHolder="" />
				<e:text>시 </e:text>
				<e:select id="RFX_TO_MIN" name="RFX_TO_MIN" value="${form.RFX_TO_MIN}" options="${rfxToMinOptions}" width="${form_RFX_TO_MIN_W}" disabled="${form_RFX_TO_MIN_D}" readOnly="${form_RFX_TO_MIN_RO}" required="${form_RFX_TO_MIN_R}" placeHolder="" />
				<e:text>분 </e:text>
				</e:field>
            </e:row>
        </e:searchPanel>


	</e:window>
</e:ui>