<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var baseUrl = "/evermp/MY01/";

    	function init() {



            var editor = EVF.C('NOTICE_CONTENTS').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;


        }

        function doSave() {

        	var store = new EVF.Store();
	        if(!store.validate()) return;

            if(EVF.isEmpty(EVF.C('NOTICE_CONTENTS').getValue())) { return alert("${MY01_004_002 }"); }

            if(!confirm("${msg.M0021 }")) return;
        	store.doFileUpload(function() {
	        	store.load(baseUrl + 'my01004_doSave', function(){
	        		alert(this.getResponseMessage());
 	        		location.href = baseUrl + 'MY01_004/view.so?NOTICE_NUM=' + this.getParameter('NOTICE_NUM') + '&detailView=false';
 	        		if(opener != null) {
 	        			opener.doSearch();
 	        		}
	        	});
            });
        }

        function doDelete() {
	        var store = new EVF.Store();
        	if (!confirm("${msg.M0013 }")) return;
        	store.load(baseUrl + 'my01004_doDelete', function(){
        		alert(this.getResponseMessage());
        		 if(opener != null) {
        			opener.doSearch();
        		 }
        		 formUtil.close();
        	});
        }

        function doClear() {
        	if(confirm("${MY01_004_005}")) {
        		location.href = baseUrl + 'MY01_004/view.so?NOTICE_NUM=&detailView=false';
        	}
        }

        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(dataJsonArray) {
            EVF.C("BUYER_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("BUYER_NM").setValue(dataJsonArray.CUST_NM);
        }

        function doClose(){
        	formUtil.close();
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }



    </script>
    <e:window id="MY01_004" onReady="init" initData="${initData}" title="${MY01_004_001 }" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<c:if test="${param.detailView == false}">
				<e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
				<c:if test="${formData.NOTICE_NUM != null}">
					<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
				</c:if>
				<e:button id="Clear" name="Clear" label="${Clear_N }" disabled="${Clear_D }" onClick="doClear" />
			</c:if>
			<%-- <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" /> --%>
		</e:buttonBar>

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${longLabelWidth}" width="100%" columnCount="2">
			<e:row>
				<e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                	<e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${formData.SUBJECT }" maxLength="${form_SUBJECT_M}" width="${form_SUBJECT_W }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
		            <e:inputHidden id="NOTICE_NUM" name="NOTICE_NUM" value="${formData.NOTICE_NUM }" />
		            <e:inputHidden id="NOTICE_TEXT_NUM" name="NOTICE_TEXT_NUM" value="${formData.NOTICE_TEXT_NUM }" />
                </e:field>
            </e:row>
			<e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field colSpan="3">
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${formData.VENDOR_CD}" width="20%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RD ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${formData.VENDOR_NM}" width="30%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
			</e:row>

			<e:row>
				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N }" />
				<e:field colSpan="3">
					<e:text>&nbsp;${formData.REG_USER_NM }</e:text>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="NOTICE_CONTENTS" title="${form_NOTICE_CONTENTS_N }" />
				<e:field colSpan="3">
					<e:richTextEditor id="NOTICE_CONTENTS" name="NOTICE_CONTENTS" width="${form_NOTICE_CONTENTS_W }" height="400px" required="${form_NOTICE_CONTENTS_R }" readOnly="${form_NOTICE_CONTENTS_RO }" disabled="${form_NOTICE_CONTENTS_D }" value="${formData.NOTICE_CONTENTS }" useToolbar="${!param.detailView}" />
 				</e:field>
 			</e:row>
 			<e:row>
 				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="130px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
 				</e:field>
 			</e:row>
		</e:searchPanel>
    </e:window>
</e:ui>