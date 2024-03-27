<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        function init() {
        }
        function closess() {
            if (opener != null) {
                window.close();
            } else {
                new EVF.ModalWindow().close(null);
            }
        }

        function doApply() {
            var param = {
            		"code"    : EVF.C("CODE").getValue(),
            		"code_nm" : EVF.C("CODE").getText(),
            		"text"    : EVF.C("TEXT").getValue(),
                	"rowId"   : EVF.C("rowId").getValue()
            	};

            if (opener != null) {
                opener['${param.callBackFunction}'](param);
            } else {
                parent['${param.callBackFunction}'](param);
            }
            closess();
        }
    </script>
    
    <e:window id="SIV_022" onReady="init" initData="${initData}" title="${not empty param.title ? param.title : screenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false">
	        <e:inputHidden id="rowId" name="rowId" value="${param.rowId}"/>
	        <e:row>
		        <e:label for="CODE" title="${form_CODE_N}"/>
				<e:field>
					<e:select id="CODE" name="CODE" value="${param.CODE}" usePlaceHolder="false" options="${codeOptions}" width="100%" disabled="${form_CODE_D}" readOnly="${form_CODE_RO}" required="${form_CODE_R}" placeHolder="" />
				</e:field>
	        </e:row>
	        <e:row>
				<e:label for="TEXT" title="${form_TEXT_N}" />
				<e:field>
					<e:textArea id="TEXT" name="TEXT" value="${param.TEXT}" height="250px" width="${form_TEXT_W}" maxLength="${form_TEXT_M}" disabled="${form_TEXT_D}" readOnly="${form_TEXT_RO}" required="${form_TEXT_R}" />
				</e:field>
			</e:row>
	    </e:searchPanel>
	    
        <e:buttonBar align="right">
            <c:if test="${param.detailView != 'true' }">
                <e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${param.detailView}" visible="${doApply_V}"/>
            </c:if>
        </e:buttonBar>
    </e:window>
</e:ui>