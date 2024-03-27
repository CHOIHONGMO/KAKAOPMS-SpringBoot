<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
		var baseUrl = '/eversrm/purchase/rfiMgt/BPP_040/';
		
		function init() {
			EVF.getComponent('RFI_NUM').setValue("${param.RFI_NUM}");
	        getCurCloseDate();
		}

	    function getCurCloseDate() {
	        var store = new EVF.Store();
	        
	        store.load(baseUrl + 'getCloseDate', function() {
	            var curCloseDate = this.getParameter('curCloseDate');
	            curCloseDate = curCloseDate.replace(/\//g, "");
	            var date = curCloseDate.split(" ", 2);
	            var hour = date[1].split(":", 2);
	            EVF.getComponent("CLOSE_DATE").setValue(date[0]);
	            EVF.getComponent("CLOSE_HOUR").setValue(hour[0]);
	            EVF.getComponent("CLOSE_MINUTE").setValue(hour[1]);
	        });
	    }

	    function doSave() {
	    	var store = new EVF.Store();
	    	if(!store.validate()) return;
	    	
            var date = EVF.getComponent('CLOSE_DATE').getValue();
            var hour = EVF.getComponent('CLOSE_HOUR').getValue();
            var minute = EVF.getComponent('CLOSE_MINUTE').getValue();

            everDate.diffWithServerTime(date, hour, minute, '00', function(diff, message) {
                if (diff < 0) {
                    alert(message);

                } else {
                    if (!confirm("${msg.M0021}")) return;
                    store.load(baseUrl + 'doSaveExtendDeadline', function(){
                        alert(this.getResponseMessage());
                        opener.${param.onClose}();
			            doClose();
			        });
	            }
	        });
        }                      
	        
        function doClose() {
			window.close();      
        }
        
		
    </script>
    <e:window id="BPP_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="1">
			<e:row>
				<e:label for="CLOSE_DATE" title="${form_CLOSE_DATE_N}"/>
				<e:field>
					<e:inputDate id="CLOSE_DATE" name="CLOSE_DATE" value="${form.CLOSE_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_CLOSE_DATE_R}" disabled="${form_CLOSE_DATE_D}" readOnly="${form_CLOSE_DATE_RO}" />
					<e:select id="CLOSE_HOUR" name="CLOSE_HOUR" value="${form.CLOSE_HOUR}" options="${hour }" width="50" disabled="${form_CLOSE_HOUR_D}" readOnly="${form_CLOSE_HOUR_RO}" required="${form_CLOSE_HOUR_R}" usePlaceHolder="false" placeHolder="" />
					<e:text>${BPP_040_Hour}</e:text>
					<e:select id="CLOSE_MINUTE" name="CLOSE_MINUTE" value="${form.CLOSE_MINUTE}" options="${minute }" width="50" disabled="${form_CLOSE_MINUTE_D}" readOnly="${form_CLOSE_MINUTE_RO}" required="${form_CLOSE_MINUTE_R}" usePlaceHolder="false" placeHolder="" />
					<e:text>${BPP_040_Minute}</e:text>
					<e:inputHidden id="RFI_NUM" name="RFI_NUM" />
					<e:inputHidden id="currCloseDate" name="currCloseDate"/>
				</e:field>
			</e:row>
		</e:searchPanel>    

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>			
    </e:window>
</e:ui>    