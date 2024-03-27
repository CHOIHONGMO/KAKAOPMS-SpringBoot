<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/ckeditor/econt_plugins.js"></script>
    <script type="text/javascript">
		
		var baseUrl = "/eversrm/eContract/eContractMgt/BECMSO_010";
		var detailViewFlag = '${param.detailView}';
		//var userType = '${ses.userType}';
		
		function init() {
		    var editor = CKEDITOR.replace('SoApprovalData', {
                customConfig: '/js/ckeditor/ep_config.js',
                width: '100%',
                height: 550
            });

            editor.on('instanceReady', function (ev) {

                var editor = ev.editor;
                editor.resize('100%', 550, true, false);

                $(window).resize(function () {
                    editor.resize('100%', 550, true, false);
                });
                //editor.setData(EVF.C('formContents').getValue());
                //alert("detailViewFlag====="+detailViewFlag);
                 editor.setReadOnly(true);
              
            });
		}
	</script>
 <e:window id="BECMSO_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 4px">
<%--  	<e:buttonBar id="buttonBar" align="right" width="100%"> --%>
 		<%-- <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidthy}"  useTitleBar="false"> --%>
            <e:row>
                <e:field >
                    <textarea id=SoApprovalData name="SoApprovalData" style="width:100%; ">${form.SoApprovalData}</textarea>
                </e:field>
            </e:row>
   <%--      </e:searchPanel> --%>
<%--     </e:buttonBar> --%>
	</e:window>
</e:ui>