<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var addParam = [];
        var baseUrl = "";
        
        function init() {
        	
        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if(${param.detailView} || '${param.havePermission}' == '' || ${!param.havePermission}) {
        		$('#upload-button-fileAttach').css('display','none');
        		EVF.C('doApply').setVisible(false);
        	}
        	
            if("${param.attFileNum }" > "") {
                EVF.C("fileAttach").setFileId("${param.attFileNum }");
            }
        }

        function onAfterRemove() {
            if(opener) {
                opener.window.focus();
                opener['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());
            } else if(parent) {
                parent.window.focus();
                parent['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());
            }
        }

        function doApply() {
            var store = new EVF.Store();
            store.doFileUpload(function() {
                if(opener) {
                    opener.window.focus();
                    opener['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());
                } else if(parent) {
                    parent.window.focus();
                    parent['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());
                }
                doClose();
            });
        }

        function doClose() {
        	<c:if test="${! param.isModal}">
        		window.close();
        	</c:if>

            if(opener) {
                window.open("", "_self");
                window.close();
            } else if(parent) {
                new EVF.ModalWindow().close(null);
            }
        }

    </script>
    <e:window id="commonFileAttach" onReady="init" initData="${initData}" title="첨부파일" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doApply" name="doApply" label="적용" onClick="doApply" />
        </e:buttonBar>

        <e:searchPanel useTitleBar="false" id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:row>
                <e:label for="fileAttach" title="첨부파일" />
                <e:field colSpan="3">
                    <e:fileManager id="fileAttach" required="" name="fileAttach"  readOnly="${param.havePermission ? false : true}" fileId="${param.attFileNum}" downloadable="true" width="100%" bizType="${param.bizType}" height="200" onBeforeRemove="onBeforeRemove" onAfterRemove="onAfterRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" fileExtension='${param.fileExtension}' />
                </e:field>
            </e:row>
        </e:searchPanel>

    </e:window>
</e:ui>