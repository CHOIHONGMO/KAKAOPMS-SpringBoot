<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <style>
        div.e-window-toolbar{
            display: none;
        }
    </style>

    <script type="text/javascript">

        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {

            // 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
            if('${param.detailView}' == 'true') {
                $('#upload-button-ATT_FILE_NUM').css('display','none');
            }

            var editor = EVF.C('NOTICE_CONTENTS').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;

        }

        function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) return;

            if(EVF.isEmpty(EVF.C('SUBJECT').getValue())) { return alert("${BS03_011P_003 }"); }
            if(EVF.isEmpty(EVF.C('NOTICE_CONTENTS').getValue())) { return alert("${BS03_011P_002 }"); }

            if(!confirm("${msg.M0021 }")) return;
            store.doFileUpload(function() {
                store.load(baseUrl + '/BS03_011P_doSave', function(){
                    alert(this.getResponseMessage());
                    location.href = baseUrl + 'BS03_011P/view.so?NOTICE_NUM=' + this.getParameter('NOTICE_NUM') + '&NOTICE_TYPE=' + EVF.V("NOTICE_TYPE") + '&detailView=false';
                    if(opener != null) {
                        opener.doSearch();
                    }
                });
            });
        }

        function doClear() {
            if(confirm("${BS03_011P_004}")) {
                location.href = baseUrl + 'BS03_011P/view.so?NOTICE_NUM=&detailView=false';
            }
        }

        function doClose(){
            formUtil.close();
        }

    </script>
    <e:window id="BS03_011P" onReady="init" initData="${initData}" title="${formData.title}" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <c:if test="${param.detailView == false}">
                <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
                <e:button id="Clear" name="Clear" label="${Clear_N }" disabled="${Clear_D }" onClick="doClear" />
            </c:if>
        </e:buttonBar>

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${longLabelWidth}" width="100%" columnCount="2">
            <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${BUYER_CD}"/>
            <e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${BUYER_NM}"/>
            <e:inputHidden id="START_DATE" name="START_DATE" value="${formData.START_DATE }"/>
            <e:inputHidden id="END_DATE" name="END_DATE" value="${formData.END_DATE }" />
            <e:inputHidden id="INS_DATE" name="INS_DATE" value="${formData.INS_DATE }" />
            <e:inputHidden id="MOD_DATE" name="MOD_DATE" value="${formData.MOD_DATE }" />
            <e:inputHidden id="NOTICE_TYPE" name="NOTICE_TYPE" value="${formData.NOTICE_TYPE}"/>
            <e:inputHidden id="ctrlFlag" name="ctrlFlag" value="${formData.ctrlFlag}"/>
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                    <e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${formData.SUBJECT }" maxLength="${form_SUBJECT_M}" width="${form_SUBJECT_W }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
                    <e:inputHidden id="NOTICE_NUM" name="NOTICE_NUM" value="${formData.NOTICE_NUM }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VIEW_CNT" title="${form_VIEW_CNT_N }" />
                <e:field>
                    <e:text style="float:left;">&nbsp;${formData.VIEW_CNT}</e:text>
                </e:field>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REG_DATE" name="REG_DATE" value="${formData.REG_DATE}" width="${inputDateWidth}" datePicker="false" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="NOTICE_CONTENTS" title="${form_NOTICE_CONTENTS_N }" />
                <e:field colSpan="3">
                    <e:richTextEditor id="NOTICE_CONTENTS" name="NOTICE_CONTENTS" width="${form_NOTICE_CONTENTS_W }" height="730px" required="${form_NOTICE_CONTENTS_R }" readOnly="${form_NOTICE_CONTENTS_RO }" disabled="${form_NOTICE_CONTENTS_D }" value="${formData.NOTICE_CONTENTS }" useToolbar="${!param.detailView}" />
                    <e:inputHidden id="NOTICE_TEXT_NUM" name="NOTICE_TEXT_NUM" value="${formData.NOTICE_TEXT_NUM }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="80px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>