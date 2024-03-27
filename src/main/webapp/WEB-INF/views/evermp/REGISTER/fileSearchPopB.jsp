<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        function init() {
            var param = {
                ATTACH_FILE_NUM: EVF.V('ATTACH_FILE_NUM'),
                ATTACH_FILE1_NUM: EVF.V('ATTACH_FILE1_NUM'),
                CI_FILE_NUM: EVF.V('CI_FILE_NUM'),
                ATTACH_FILE4_NUM: EVF.V('ATTACH_FILE4_NUM')
            };

            parent.setFileUUID(param);
        }

        //첨부파일갯수제어-------------------------
        function onFileAdd() {
            if(EVF.C('ATTACH_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPopB_001}");
            }
            if(EVF.C('ATTACH_FILE1_NUM').getFileCount()>1){
                return alert("${fileSearchPopB_001}");
            }
            if(EVF.C('CI_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPopB_001}");
            }
            if(EVF.C('ATTACH_FILE4_NUM').getFileCount()>1){
                return alert("${fileSearchPopB_001}");
            }
        }

        function doSave() {
            var store = new EVF.Store();
            store.doFileUpload(function() {});
        }
    </script>
    
    <e:window id="fileSearchPopB" onReady="init" initData="${initData}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form3" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
        <e:row>
            <e:label for="ATTACH_FILE_NUM" title="${form_ATTACH_FILE_NUM_N}"/> <!-- 사업자등록증 -->
            <e:field>
                <div style="width: 100%; height: 100px;">
                    <e:fileManager id="ATTACH_FILE_NUM" name="ATTACH_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.ATTACH_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="60px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE_NUM_R}" />
                </div>
            </e:field>
            <e:label for="ATTACH_FILE1_NUM" title="${form_ATTACH_FILE1_NUM_N}"/> <!-- 재무제표 -->
            <e:field>
                <div style="width: 100%; height: 100px;">
                    <e:fileManager id="ATTACH_FILE1_NUM" name="ATTACH_FILE1_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.ATTACH_FILE1_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="60px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE1_NUM_R}" />
                </div>
            </e:field>
        </e:row>
        <e:row>
            <e:label for="CI_FILE_NUM" title="${form_CI_FILE_NUM_N}" />	<!-- 로고이미지 -->
            <e:field>
                <div style="width: 100%; height: 100px;">
                    <e:fileManager id="CI_FILE_NUM" name="CI_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.CI_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="60px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_CI_FILE_NUM_R}" />
                </div>
            </e:field>
            <e:label for="ATTACH_FILE4_NUM" title="${form_ATTACH_FILE4_NUM_N}" />	<!-- 기타첨부파일 -->
            <e:field>
                <div style="width: 100%; height: 100px;">
                    <e:fileManager id="ATTACH_FILE4_NUM" name="ATTACH_FILE4_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.ATTACH_FILE4_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="60px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE4_NUM_R}" />
                </div>
            </e:field>
        </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>