<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
    	var addParam = [];
    	var baseUrl = "";
		function init() {
			
            if(${not empty param.havePermission && !param.havePermission }){
            	EVF.C('doApply').setVisible(false);
            }
        }

        function doApply() {
	        var store = new EVF.Store();
        	store.doFileUpload(function() {
                if(opener) {
                    opener.window.focus();
                    opener['${param.callBackFunction}'](EVF.C('TEXT_CONTENTS').getValue(), '${param.rowId}');
                } else if(parent) {
                    parent.window.focus();
                    parent['${param.callBackFunction}'](EVF.C('TEXT_CONTENTS').getValue(), '${param.rowId}');
                }
                doClose();
            });
        }

        function doClose() {
            if(opener) {
                formUtil.close();
            } else if(parent) {
                new EVF.ModalWindow().close(null);
            }
        }

    </script>
    <e:window id="commonTextContents" onReady="init" initData="${initData}" title="${(param.screenName > ' ') ? param.screenName : screenName }" breadCrumbs="${breadCrumb }">
    
		<c:if test="${not empty param.havePermission && param.havePermission }">
			<e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doApply" name="doApply" label="적용" onClick="doApply" visible="${not param.detailView eq 'true'}" />
				<%-- <e:button id="doClose" name="doClose" label="닫기" onClick="doClose" /> --%>
			</e:buttonBar>
		</c:if>
    


        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
           <e:row>
               <e:label for="textContents" title="Contents" />
                <e:field colSpan="3">
                	<e:textArea height="250" width="100%" disabled="false" maxLength="4000" required="false" id="TEXT_CONTENTS" readOnly="${param.detailView}" name="TEXT_CONTENTS" value="${param.TEXT_CONTENTS }"/>
 				</e:field>
 			</e:row>
		</e:searchPanel>

    </e:window>
</e:ui>