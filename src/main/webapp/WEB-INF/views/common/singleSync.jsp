<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/eApproval/";

		function init() {

		}


		function sync() {
		            var store = new EVF.Store();
                    if(!store.validate()) return;

		        	if (!confirm("결재싱크를 하시겠습니까?")) return;
	        var store = new EVF.Store();
        	store.load(baseUrl + 'singleSync', function(){
        		alert(this.getResponseMessage());
        	});

		}

    </script>
    <e:window id="singleSync" onReady="init" initData="${initData}" title="싱글결재수신" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3">
           <e:row>
               <e:label for="START_RECV_DATE" title="결재기간" />
                <e:field>
                    <e:inputDate id="START_RECV_DATE" disabled="" readOnly="" name="START_RECV_DATE"   value="${fromDate}" width="${inputTextDate }" required="true"  datePicker="true" />
						<e:text> ~ </e:text>
                    <e:inputDate id="END_RECV_DATE" disabled="" readOnly="" name="END_RECV_DATE"   value="${toDate}" width="${inputTextDate }" required="true"  datePicker="true" />
                </e:field>

	               <e:label for="APP_DOC_NUM" title="결재번호" />
	                <e:field>
	            	                <e:inputText id="APP_DOC_NUM" disabled="" readOnly="" required="" name="APP_DOC_NUM" value=""  maxLength="100"  width="90%"  onFocus="onFocus" />
					</e:field>

	               <e:label for="APP_DOC_CNT" title="결재차수" />
	                <e:field>
	            	                <e:inputText id="APP_DOC_CNT" disabled="" readOnly="" required="" name="APP_DOC_CNT" value=""  maxLength="100"  width="90%"  onFocus="onFocus" />
					</e:field>
			</e:row>
		</e:searchPanel>
         <e:buttonBar id="buttonBar1" align="right" width="100%">
            <e:button id="doSync" name="doSync" label="싱크"  onClick="sync" />
        </e:buttonBar>
    </e:window>
</e:ui>