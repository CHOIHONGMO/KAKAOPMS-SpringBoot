<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<link rel="stylesheet" href="/css/richText.css" type="text/css"/>
    <script>

        var baseUrl = "/evermp/IM03/IM0301/";
        var gridat;

        function init() {

            _setImages2();
        }
        function _doUpload2() {
            if(EVF.C('ITEM_DETAIL_FILE_NUM').getFileCount()>1){
                return alert("${IM03_009_014}");
            }

            EVF.C('ITEM_DETAIL_FILE_NUM').uploadFile();
        }
        function _setImages2() {

            var detailFileManager = EVF.C('ITEM_DETAIL_FILE_NUM');
            var store = new EVF.Store();

            store.setParameter('fileManagerId', detailFileManager.getID());
            store.setParameter('bizType', 'IMG');
            store.setParameter('fileId', detailFileManager.getFileId());
            store.load('/common/file/fileAttach/getUploadedFileInfo', function() {

                var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
                $('#DetailImgContainer').empty();
                $.each(fileInfoJson, function(i, datum) {
                    var $itemImage;
                    //$itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: auto; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"></div>');
                    $itemImage = $('<div style="overflow:scroll; height:490px; text-align:center;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: auto; cursor: pointer;" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"></div>');
                    $('#DetailImgContainer').append($itemImage);
                });
            });
        }

        function doSave(){
        	var store = new EVF.Store();
            var params = {
                rowId: '${param.rowId}',
                'ITEM_DETAIL_FILE_NUM': EVF.V('ITEM_DETAIL_FILE_NUM')
            };


            store.doFileUpload(function() {
                store.setParameter('mainImgSq', $('#DetailImgContainer').find('input[type=radio]:checked').prop('id'));
              //EVF.V('MAIN_IMG_SQ',$('#DetailImgContainer').find('input[type=radio]:checked').prop('id'));


	            if(${param.ModalPopup == true}){
	                parent['${param.callBackFunction}'](params);
	                doClose();
	            }else{
	                opener['${param.callBackFunction}'](params);
	                doClose();
	            }
            });

        }


        function doClose() {
            if(${param.ModalPopup == true}){
                new EVF.ModalWindow().close(null);
            } else {
                window.close();
            }
        }

        function onError() {
            $('.ui-icon-circle-arrow-w').trigger('click');
        }

    </script>

    <e:window id="IM03_017" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        </e:buttonBar>
        <e:searchPanel id="searchPanel8" title="" labelWidth="${labelWidth}" width="100%" height="100%" columnCount="1" useTitleBar="false">
            <e:row>
                <e:field colSpan="2">
                    <e:fileManager id="ITEM_DETAIL_FILE_NUM" name="ITEM_DETAIL_FILE_NUM" fileId="${param.ITEM_DETAIL_FILE_NUM}" bizType="IMG" width="100%" height="40px" readOnly="${form_IMG_ATT_FILE_NUM_RO}" required="${form_IMG_ATT_FILE_NUM_R}" onFileAdd="_doUpload2" onSuccess="_setImages2" onAfterRemove="_setImages2" maxFileCount="1" onError="onError"/>
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2">
                    <div id="DetailImgContainer" style="width: 100%; height: 490px;"></div>
                </e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>