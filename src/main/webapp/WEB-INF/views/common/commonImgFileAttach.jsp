<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var addParam = [];
        var baseUrl = "";
        function init() {
        	<c:if test="${empty param.havePermission}">
        		EVF.C('doApply').setVisible(false);
        	</c:if>

        	<c:if test="${null eq param.havePermission}">
        		EVF.C('doApply').setVisible(false);
        	</c:if>

        	<c:if test="${! param.havePermission}">
    			EVF.C('doApply').setVisible(false);
    		</c:if>

            if("${param.attFileNum }" > "") {
                EVF.C("fileAttach").setFileId("${param.attFileNum }");
            }

            _setImages();

            <%--$(window).off('unload');--%>
            <%--window.onbeforeunload = function() {--%>
                <%--console.log('AAAAAAAAAAAAAAAAAAA');--%>
                <%--if(opener) {--%>
                    <%--opener.window.focus();--%>
                    <%--opener['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());--%>
                <%--} else if(parent) {--%>
                    <%--parent['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());--%>
                    <%--parent.window.focus();--%>
                <%--}--%>
            <%--}--%>
        }

        <%--function onAfterRemove() {--%>
            <%--if(opener) {--%>
                <%--opener.window.focus();--%>
                <%--opener['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());--%>
            <%--} else if(parent) {--%>
                <%--parent.window.focus();--%>
                <%--parent['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount());--%>
            <%--}--%>
        <%--}--%>


        function _setImages() {

            var fileManager = EVF.C('fileAttach');
            var store = new EVF.Store();

            store.setParameter('fileManagerId', fileManager.getID());
            store.setParameter('bizType', '${param.bizType}');
            store.setParameter('fileId', fileManager.getFileId());
            store.load('/common/file/fileAttach/getUploadedFileInfo', function() {

                var mainImgSq = EVF.V('MAIN_IMG_SQ');
                var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
                $('#mainImgContainer').empty();
                $.each(fileInfoJson, function(i, datum) {
                    var $itemImage;
                    if(i==0){
                        $itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: 110px; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"><input id="'+datum.UUID_SQ+'" name="itemImage" type="radio" checked="checked"/></div>');
                    }else{
                        $itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: 110px; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"><input id="'+datum.UUID_SQ+'" name="itemImage" type="radio" '+(datum.UUID_SQ == mainImgSq ? 'checked="checked"': '')+' /></div>');
                    }
                    $('#mainImgContainer').append($itemImage);
                });
            });
        }

        //첨부파일갯수제어-------------------------
        function _doUpload() {
            if(EVF.C('fileAttach').getFileCount()>4){
                return alert("${commonImgFileAttach_001}");
            }

            EVF.C('fileAttach').uploadFile();
        }

        function doApply() {
            var store = new EVF.Store();
            store.doFileUpload(function() {
                store.setParameter('mainImgSq', $('#mainImgContainer').find('input[type=radio]:checked').prop('id'));
                EVF.V('MAIN_IMG_SQ',$('#mainImgContainer').find('input[type=radio]:checked').prop('id'));

                if(opener) {
                    opener.window.focus();
                    opener['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount(),EVF.V('MAIN_IMG_SQ'));
                } else if(parent) {
                    parent.window.focus();
                    parent['${param.callBackFunction}']('${param.rowId}' ,EVF.C('fileAttach').getFileId() ,EVF.C('fileAttach').getFileCount(),EVF.V('MAIN_IMG_SQ'));
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
    <e:window id="commonImgFileAttach" onReady="init" initData="${initData}" title="첨부파일" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doApply" name="doApply" label="적용" onClick="doApply" />
            <!--<e:button id="doClose" name="doClose" label="닫기" onClick="doClose" />-->
        </e:buttonBar>

        <e:searchPanel useTitleBar="false" id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3">
            <e:row>
                <e:field colSpan="4">
                    <e:fileManager id="fileAttach" required="" name="fileAttach" readOnly="${param.havePermission ? false : true}" fileId="${param.attFileNum}"  downloadable="true" width="100%"  height="240"  onBeforeRemove="onBeforeRemove" onSuccess="_setImages" onAfterRemove="_setImages"  onError="onError" onFileClick="onFileClick"  bizType="${param.bizType}" onFileAdd="_doUpload" fileExtension='${param.fileExtension}' />
                </e:field>
                <e:field colSpan="4">
                    <div id="mainImgContainer" style="width: 100%; height: 100%;"></div>

                    <e:inputHidden id="MAIN_IMG_SQ" name="MAIN_IMG_SQ" value="${param.mainImgSq}" />


                </e:field>
            </e:row>
        </e:searchPanel>

    </e:window>
</e:ui>