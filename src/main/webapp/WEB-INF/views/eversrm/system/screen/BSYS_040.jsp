<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var addParam = [];
    	var baseUrl = "/eversrm/system/screen/";

		function init() {

            var editor = EVF.C('CONTENTS').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;

		}

        function doSave() {

			if ( EVF.C('CONTENTS').getValue() == '') {
				return alert("${BSYS_040_MSG1 }");
			}

        	if (!confirm("${msg.M0011 }")) return;
	        var store = new EVF.Store();
	        if(!store.validate()) return;

        	store.doFileUpload(function() {
	        	store.load(baseUrl + 'helpInfo/doSave', function(){
	        		alert(this.getResponseMessage());
	        		opener.doSearch();
	        		window.close();
	        	});
            });
        }

        function doDelete() {
        	if (!confirm("${msg.M0013 }")) return;
	        var store = new EVF.Store();
        	store.load(baseUrl + 'helpInfo/doDelete', function(){
        		alert(this.getResponseMessage());
        		opener.doSearch();
        		window.close();
        	});
        }

        function doClose() {
        	window.close();
        }

	</script>
    <e:window id="BSYS_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" />
			<e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="doDelete" />
			<!--<e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="doClose" />-->
		</e:buttonBar>
		<e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
			<e:row>
				<e:label for="CONTENTS" title="${form_CONTENTS_N }" />
				<e:field colSpan="3">
					<e:richTextEditor height="450px" id="CONTENTS" name="CONTENTS" width="100%" required="${form_TEXT_CONTENTS_R }" readOnly="${form_CONTENTS_RO }" disabled="${form_TEXT_CONTENTS_D }" value="${formData.CONTENTS }" useToolbar="${!param.detailView}" />
					<e:inputHidden id="HELP_TEXT_NUM" name="HELP_TEXT_NUM" value="${formData.HELP_TEXT_NUM }" />
					<e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="${formData.SCREEN_ID }" />
 				</e:field>
 			</e:row>
 			<e:row>
 				<e:label for="HELP_ATT_FILE_NUM" title="${form_HELP_ATT_FILE_NUM_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="HELP_ATT_FILE_NUM" name="HELP_ATT_FILE_NUM" readOnly="${param.detailView ? true : false}"  fileId="${formData.HELP_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="SR" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
 				</e:field>
 			</e:row>
		</e:searchPanel>
    </e:window>
</e:ui>