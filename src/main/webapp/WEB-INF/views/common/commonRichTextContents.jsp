<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
    	var addParam = [];
    	var baseUrl = "";
		function init() {
			
            if(${not empty param.havePermission and !param.havePermission }) {
            	EVF.C('doApply').setVisible(false);
            }

            var editor = EVF.C('TEXT_CONTENTS').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;
        }

        function doApply() {
	        var store = new EVF.Store();
	        store.load("/common/popup/getLargeTextNum", function() {

	            var largeTextNum = this.getParameter('largeTextNum');
	            var data = {
	                rowId: "${param.rowId}",
	                largeTextNum: largeTextNum
				};

	            data = JSON.stringify(data);

                if(opener) {
                    opener.window.focus();
                    opener['${param.callBackFunction}'](data);
                } else if(parent) {
                    parent.window.focus();
                    parent['${param.callBackFunction}'](data);
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
    <e:window id="commonRichTextContents" onReady="init" initData="${initData}" title="${(param.screenName > ' ') ? param.screenName : screenName }" breadCrumbs="${breadCrumb }">

		<e:inputHidden id="TEXT_NUM" name="TEXT_NUM" value="${param.largeTextNum}" />
		<c:if test="${not empty param.havePermission && param.havePermission }">
			<e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="doApply" name="doApply" label="적용" onClick="doApply" visible="${not param.detailView eq 'true'}" />
				<%-- <e:button id="doClose" name="doClose" label="닫기" onClick="doClose" /> --%>
			</e:buttonBar>
		</c:if>

		<e:richTextEditor height="540" width="100%" disabled="false" required="false" id="TEXT_CONTENTS" readOnly="${param.detailView}" name="TEXT_CONTENTS" value="${TEXT_CONTENTS }"/>

    </e:window>
</e:ui>