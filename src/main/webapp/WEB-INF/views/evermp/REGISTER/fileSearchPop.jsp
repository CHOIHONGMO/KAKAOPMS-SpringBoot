<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        function init() {
            var param = {
                // BASIC_ATT_FILE_NUM: EVF.V('BASIC_ATT_FILE_NUM'),
                BIZ_ATT_FILE_NUM: EVF.V('BIZ_ATT_FILE_NUM'),
                ID_ATT_FILE_NUM: EVF.V('ID_ATT_FILE_NUM'),
                PRICE_ATT_FILE_NUM: EVF.V('PRICE_ATT_FILE_NUM'),
                CERTIFI_ATT_FILE_NUM: EVF.V('CERTIFI_ATT_FILE_NUM'),
                BANKBOOK_ATT_FILE_NUM: EVF.V('BANKBOOK_ATT_FILE_NUM'),
                // SIGN_ATT_FILE_NUM: EVF.V('SIGN_ATT_FILE_NUM'),
                // CONTRACT_ATT_FILE_NUM: EVF.V('CONTRACT_ATT_FILE_NUM'),
                //SECRET_ATT_FILE_NUM: EVF.V('SECRET_ATT_FILE_NUM'),
                //IMGAGREE_ATT_FILE_NUM: EVF.V('IMGAGREE_ATT_FILE_NUM'),
                ATTACH_FILE_NO: EVF.V('ATTACH_FILE_NO')
            };

            parent.setFileUUID(param);
        }

        //첨부파일갯수제어-------------------------
        function onFileAdd() {
            /*if(EVF.C('BASIC_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }*/
            if(EVF.C('BIZ_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }
            if(EVF.C('ID_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }
            if(EVF.C('PRICE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }
            if(EVF.C('CERTIFI_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }
            if(EVF.C('BANKBOOK_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }
            /*if(EVF.C('SIGN_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }*/
            /*if(EVF.C('CONTRACT_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }*/
            /*if(EVF.C('SECRET_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }*/
            /*if(EVF.C('IMGAGREE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }*/
            if(EVF.C('ATTACH_FILE_NO').getFileCount()>1){
                return alert("${fileSearchPop_001}");
            }
        }

        function doSave() {
            var store = new EVF.Store();
            store.doFileUpload(function() {});
        }
    </script>
    <e:window id="fileSearchPop" onReady="init" initData="${initData}" breadCrumbs="${breadCrumb }">
        <!-- 4. 첨부파일정보 -->
        <e:searchPanel id="form3" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <%--
            <e:buttonBar id="btn" align="right" width="100%">
                <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            </e:buttonBar>
            --%>
            <e:row>
                <%-- 거래기본계약서 --%>
                <%-- <e:label for="BASIC_ATT_FILE_NUM" title="${form_BASIC_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 50px;">
                        <e:fileManager id="BASIC_ATT_FILE_NUM" name="BASIC_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.BASIC_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="0px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_BASIC_ATT_FILE_NUM_R}" />
                    </div>
                </e:field> --%>
                <%-- 사업자등록증 --%>
                <e:label for="BIZ_ATT_FILE_NUM" title="${form_BIZ_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="BIZ_ATT_FILE_NUM" name="BIZ_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.BIZ_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_BIZ_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                <%-- 재무제표 --%>
                <e:label for="ID_ATT_FILE_NUM" title="${form_ID_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="ID_ATT_FILE_NUM" name="ID_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ID_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ID_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            </e:row>
            <e:row>
                <%-- 등기부등록 --%>
                <%--<e:label for="ID_ATT_FILE_NUM" title="${form_ID_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 50px;">
                        <e:fileManager id="ID_ATT_FILE_NUM" name="ID_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ID_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="0px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ID_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>--%>
                <%-- 대금수령신청서 --%>
                <e:label for="PRICE_ATT_FILE_NUM" title="${form_PRICE_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="PRICE_ATT_FILE_NUM" name="PRICE_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.PRICE_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_PRICE_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                <%-- 대금수령통장사본 --%>
                <e:label for="BANKBOOK_ATT_FILE_NUM" title="${form_BANKBOOK_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="BANKBOOK_ATT_FILE_NUM" name="BANKBOOK_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.BANKBOOK_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_BANKBOOK_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            </e:row>
            <e:row>
                <%-- 인감증명서 --%>
                <e:label for="CERTIFI_ATT_FILE_NUM" title="${form_CERTIFI_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="CERTIFI_ATT_FILE_NUM" name="CERTIFI_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.CERTIFI_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_CERTIFI_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            <%--<e:row>
                &lt;%&ndash; 사용인감계 &ndash;%&gt;
                <e:label for="SIGN_ATT_FILE_NUM" title="${form_SIGN_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 50px;">
                        <e:fileManager id="SIGN_ATT_FILE_NUM" name="SIGN_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.SIGN_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="0px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_SIGN_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                &lt;%&ndash; 하도급거래계약서 &ndash;%&gt;
                <e:label for="CONTRACT_ATT_FILE_NUM" title="${form_CONTRACT_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 50px;">
                        <e:fileManager id="CONTRACT_ATT_FILE_NUM" name="CONTRACT_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.CONTRACT_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="0px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_CONTRACT_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            </e:row>--%>
                <%-- 비밀유지협약서
                <e:label for="SECRET_ATT_FILE_NUM" title="${form_SECRET_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 50px;">
                        <e:fileManager id="SECRET_ATT_FILE_NUM" name="SECRET_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.SECRET_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="0px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_SECRET_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                --%>
				<%-- 추가서류 --%>
				<e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATTACH_FILE_NO_R}" />
                    </div>
                </e:field>
            </e:row>
                <%-- 추가서류 --%>
                <%-- <e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}" />
                <e:field colSpan="3">
                    <div style="width: 100%; height: 104px;">
                        <e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="VENDOR" height="105px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATTACH_FILE_NO_R}" />
                    </div>
                </e:field> --%>
        </e:searchPanel>
    </e:window>
</e:ui>