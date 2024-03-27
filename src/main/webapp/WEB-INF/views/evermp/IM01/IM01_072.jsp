<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/IM01/IM0101/";

        document.oncontextmenu = function () { alert("우클릭 버튼을 사용할 수 없습니다."); return false; } // 우클릭 방지

        function init() {

            _setImages();
        }

        function _setImages(){

            var fileManager = EVF.V("IMG_ATT_FILE_NUM");

            if(fileManager!=""){
                var store = new EVF.Store();
                store.setParameter('fileManagerId', 'MTGL_IMG_MAIN');
                store.setParameter('bizType', 'IMG');
                store.setParameter('fileId', fileManager);

                var mainId ="";

                store.load('/common/file/fileAttach/getUploadedFileInfo', function() {
                    var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
                    $('#MTGL_IMG_MAIN').empty();
                    $('#MTGL_IMG1').empty();
                    $('#MTGL_IMG2').empty();
                    $('#MTGL_IMG3').empty();
                    console.log(fileInfoJson);

                    $.each(fileInfoJson, function(i, datum) {
                        if(EVF.V("MAIN_IMG_SQ")==datum.UUID_SQ){
                            var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id="IMG0" data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width: 320px; height:320px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                            var $hiddenMain = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id="ORIGIN" data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width: 100%; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                            $('#MTGL_IMG_MAIN').append($itemImage);
                            $('#HIDDEN_IMG_MAIN').append($hiddenMain);
                            mainId = i;
                        }
                    });
                    var k=0;
                    $.each(fileInfoJson, function(i, datum) {
                        if(i!=mainId){
                            if(k==0){
                                var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id=IMG1 data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width:135px; height:135px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                $('#MTGL_IMG1').append($itemImage);
                            }else if(k==1){
                                var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id=IMG2 data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width:135px; height:135px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                $('#MTGL_IMG2').append($itemImage);
                            }else if(k==2){
                                var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img id=IMG3 data-uuid="' + datum.UUID + '" data-uuid_sq="' + datum.UUID_SQ + '" style="width:135px; height:135px; cursor: pointer; display: block;" src="data:image/' + datum.FILE_EXTENSION + ';base64,' + datum.BYTE_ARRAY + '"></div>');
                                $('#MTGL_IMG3').append($itemImage);
                            }
                            k++;
                        }
                    });
                });
            }else{
                $('#MTGL_IMG_MAIN').empty();
                var $itemImage = $('<div style="width: 100%; vertical-align: middle;" align="center"><img src="/images/noimage_02.jpg" id="MAIN_IMAGE" style="width: 320px; height: 320px; cursor: pointer; display: block;"/></div>');
                $('#MTGL_IMG_MAIN').append($itemImage);
            }
        }
        function detail_IMG_MAIN(){
            var img_width = document.getElementById("ORIGIN").naturalWidth +10;
            var img_height = document.getElementById('ORIGIN').naturalHeight +10;
            var OpenWindow=window.open('','_blank', 'width='+img_width+', height='+img_height+', menubars=no, scrollbars=auto');
            OpenWindow.document.write("<style>body{margin:0px;}</style><img src='"+jQuery('#ORIGIN').attr("src")+"' width='"+img_width+"'>");

        }

        function detail_IMG1() {
            var main = jQuery('#IMG0').attr("src");
            var item = jQuery('#IMG1').attr("src");
            jQuery("#IMG0").attr("src", item);
            jQuery("#ORIGIN").attr("src", item);
            jQuery("#IMG1").attr("src", main);
        }

        function detail_IMG2() {
            var main = jQuery('#IMG0').attr("src");
            var item = jQuery('#IMG2').attr("src");
            jQuery("#ORIGIN").attr("src", item);
            jQuery("#IMG0").attr("src", item);
            jQuery("#IMG2").attr("src", main);
        }

        function detail_IMG3() {
            var main = jQuery('#IMG0').attr("src");
            var item = jQuery('#IMG3').attr("src");
            jQuery("#ORIGIN").attr("src", item);
            jQuery("#IMG0").attr("src", item);
            jQuery("#IMG3").attr("src", main);
        }

    </script>

    <e:window id="IM01_072" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="false">
            <e:row>
                <e:field colSpan="2" align="center" style="height:325px">
                    <e:inputHidden id="IMG_ATT_FILE_NUM" name="IMG_ATT_FILE_NUM" value="${param.IMG_ATT_FILE_NUM}" />
                    <e:inputHidden id="MAIN_IMG_SQ" name="MAIN_IMG_SQ" value="${param.MAIN_IMG_SQ}" />
                    <div style="vertical-align: center">
                        <a href="javascript:detail_IMG_MAIN();">
                            <div id="MTGL_IMG_MAIN" name="MTGL_IMG_MAIN" style="width: 100%; height: 100%; display: block; margin-left: auto; margin-right: auto;"></div>
                        </a>
                    </div>
                    <e:panel width="0px" height="0px">
                        <div id="HIDDEN_IMG_MAIN" name="HIDDEN_IMG_MAIN" ></div>
                    </e:panel>
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2" style="height:140px">
                    <e:panel height="fit" width="100%">
                        <e:panel width="33%">
                            <a href="javascript:detail_IMG1();">
                                <div id="MTGL_IMG1" name="MTGL_IMG1" style="width: 100%; display: block; margin-left: auto; margin-right: auto; border-right: 1px solid; border-right-color: grey"></div>
                            </a>
                        </e:panel>
                        <e:panel width="33%">
                            <a href="javascript:detail_IMG2();">
                                <div id="MTGL_IMG2" name="MTGL_IMG2" style="width: 100%; display: block; margin-left: auto; margin-right: auto; border-right: 1px solid; border-right-color: grey"></div>
                            </a>
                        </e:panel>
                        <e:panel width="33%">
                            <a href="javascript:detail_IMG3();">
                                <div id="MTGL_IMG3" name="MTGL_IMG3" style="width: 100%; display: block; margin-left: auto; margin-right: auto;"></div>
                            </a>
                        </e:panel>
                    </e:panel>
                </e:field>
            </e:row>

        </e:searchPanel>

    </e:window>
</e:ui>