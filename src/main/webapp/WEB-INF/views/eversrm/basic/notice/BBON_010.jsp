<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
        var grid2 = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/board/notice/";

        function init() {
            <%--<c:if test="${param.isFromLoginScreen != 'Y' }">--%>


            <%--if("${param.isFromLoginScreen}" == "Y") {--%>
            <%--EVF.C('doSave').setVisible(false);--%>
            <%--EVF.C('doDelete').setVisible(false);--%>
            <%--}--%>
            <%--</c:if>--%>

            <%--if("${param.isFromLoginScreen}" == "Y" || '${ses.userType}' == 'C') {--%>
            <%--EVF.C('doSave').setVisible(false);--%>
            <%--EVF.C('doDelete').setVisible(false);--%>
            <%--}--%>
            if (! ${havePermission }) {
                EVF.C('doSave').setVisible(false);
                EVF.C('doDelete').setVisible(false);
            }
            if ('${ses.userType}' != 'C') {
                EVF.C('doSave').setVisible(false);
                EVF.C('doDelete').setVisible(false);
            }

            <c:if test="${param.popupFlag == true and detailView == false}">
            EVF.C('doSave').setVisible(false);
            </c:if>
            <c:if test="${param.popupFlag != true}">
            EVF.C('doUpate').setVisible(false);
            EVF.C('doDelete').setVisible(false);
            /* EVF.C('doClose').setVisible(false); */
            </c:if>
            <c:if test="${detailView == 'true'}">
            EVF.C('doSave').setVisible(false);
            EVF.C('doUpate').setVisible(false);
            EVF.C('doDelete').setVisible(false);

            // 공백창 제거를 위해 사용
			$('.e-buttonbar').remove();
            </c:if>
        }

        function search() {
            var store = new EVF.Store();
            if(!store.validate()) return;
        	store.setGrid([grid1]);
            store.load(baseUrl + 'doSearch', function() {
                if(grid1.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function save() {


            if (EVF.V('START_DATE') == '') {return alert("${BBON_010_MSG2 }");}



	        var store = new EVF.Store();
	        if(!store.validate()) return;
	        if (EVF.V('CONTENTS') == '') {return alert("${BBON_010_MSG1 }");}

	        if (!confirm("${msg.M0021 }")) return;

        	store.doFileUpload(function() {
	        	store.load(baseUrl + 'postNotice/saveNotice', function(){
	        		alert(this.getResponseMessage());
	        		if ('${param.popupFlag}'){
		        		opener.search();
	        		}
	        		location.href = baseUrl + 'BBON_010/view.so?popupFlag=${param.popupFlag}&NOTICE_NUM=' + encodeURIComponent(this.getParameter('NOTICE_NUM'));
	        	});
            });
        }

        function delete2() {
        	if (!confirm("${msg.M0013 }")) return;
	        var store = new EVF.Store();
        	store.load(baseUrl + 'postNotice/deleteNotice', function(){
        		alert(this.getResponseMessage());
        		if ('${param.popupFlag}'){
	        		opener.search();
	        		window.close();
        		}
        	});
        }

        function do2Close() {
        	window.close();
        }

        function getScreenId() {
        	everPopup.openScreenIdPopup();
        }

        $(window).on('beforeunload', function() {
        	<c:if test="${param.loginPopupNotice == 'loginPopupNotice' }">
				var cookieChk = EVF.C('cookieChk').getValue();

				if(cookieChk == 'on') {
					opener.closeWinAt00('div_laypopup' + '${param.NOTICE_NUM}', 1);
				}
			</c:if>
        });


        function selectScreen(selectedData) {
            EVF.C('SCREEN_ID').setValue(selectedData.SCREEN_ID);
        }


        </script>
    <e:window id="BBON_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${longLabelWidth}" width="100%" columnCount="2">
        	<c:if test="${havePermission == true}">
	           <e:row>
					<e:label for="NOTICE_TYPE" title="${form_NOTICE_TYPE_N}"/>
					<e:field>
					<e:select id="NOTICE_TYPE" name="NOTICE_TYPE" value="${empty formData.NOTICE_TYPE ? 'PCN' : formData.NOTICE_TYPE }" options="${noticeTypeOptions}" width="${form_NOTICE_TYPE_W}" disabled="${form_NOTICE_TYPE_D}" readOnly="${form_NOTICE_TYPE_RO}" required="${form_NOTICE_TYPE_R}" placeHolder="" />
					</e:field>
					<e:label for="USER_TYPE" title="${form_USER_TYPE_N}"/>
					<e:field>
					<e:select id="USER_TYPE" name="USER_TYPE" value="${formData.USER_TYPE }" options="${userTypeOptions}" width="${form_USER_TYPE_W}" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="START_DATE" title="${form_START_DATE_N }" />
					<e:field>
						<e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${empty formData.START_DATE ? today : formData.START_DATE}" width="${inputDateWidth }" required="${form_START_DATE_R }" readOnly="${form_START_DATE_RO }" disabled="${form_START_DATE_D }" datePicker="true" />
						<e:text>~</e:text>
						<e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${empty formData.END_DATE ? today : formData.END_DATE}" width="${inputDateWidth }" required="${form_END_DATE_R }" readOnly="${form_END_DATE_RO }" disabled="${form_END_DATE_D }" datePicker="true" />
					</e:field>
					<e:label for="FIXED_TOP_FLAG" title="${form_FIXED_TOP_FLAG_N}"/>
					<e:field>
						<e:select id="FIXED_TOP_FLAG" name="FIXED_TOP_FLAG" value="${formData.FIXED_TOP_FLAG}" options="${fixedTopFlagOptions }" width="${form_FIXED_TOP_FLAG_W}" disabled="${form_FIXED_TOP_FLAG_D}" readOnly="${form_FIXED_TOP_FLAG_RO}" required="${form_FIXED_TOP_FLAG_R}" placeHolder="" />
					</e:field>
				</e:row>
			</c:if>
			<c:if test="${havePermission != true}">
				<e:inputHidden id="NOTICE_TYPE" name="NOTICE_TYPE"/>
				<e:inputHidden id="USER_TYPE" name="USER_TYPE"/>
				<e:inputHidden id="FIXED_TOP_FLAG" name="FIXED_TOP_FLAG"/>
				<e:row>
					<e:label for="START_DATE" title="${form_START_DATE_N }" />
					<e:field colSpan="3">
						<e:text>&nbsp;${formData.START_DATE } ~ &nbsp;${formData.END_DATE } </e:text>
					</e:field>
				</e:row>

			</c:if>


			<c:if test="${param.popupFlag == true}">
				<e:row>
					<e:label for="REG_INFO" title="${form_REG_INFO_N }" />
					<e:field>
						<e:text>&nbsp;${formData.REG_INFO }</e:text>
					</e:field>

					<e:label for="VIEW_CNT" title="${form_VIEW_CNT_N }" />
					<e:field>
						<e:text>&nbsp;${formData.VIEW_CNT }</e:text>
					</e:field>
				</e:row>
			</c:if>
   			<e:inputHidden id="SCREEN_ID" name="SCREEN_ID"/>

           <e:row>
               <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                    <e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${formData.SUBJECT }" maxLength="${form_SUBJECT_M}" width="100%" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
                    <e:inputHidden id="NOTICE_NUM" name="NOTICE_NUM" value="${formData.NOTICE_NUM }" />
                    <e:inputHidden id="GATE_CD" name="GATE_CD" value="${formData.GATE_CD }" />
                    <e:inputHidden id="NOTICE_TEXT_NUM" name="NOTICE_TEXT_NUM" value="${formData.NOTICE_TEXT_NUM }" />
		            <e:inputHidden id="NOTICE_NO_ORI" name="NOTICE_NO_ORI" value="" />
		            <e:inputHidden id="INSERT_FLAG" name="INSERT_FLAG" value="" />
                </e:field>
 			</e:row>
			<e:row>
				<e:label for="SUBJECT_OUT" title="${form_SUBJECT_OUT_N }" />
				<e:field colSpan="3">
				<e:inputText id="SUBJECT_OUT" style="${imeMode}" name="SUBJECT_OUT" value="${formData.SUBJECT_OUT }" maxLength="${form_SUBJECT_OUT_M}" width="100%" required="${form_SUBJECT_OUT_R }" readOnly="${form_SUBJECT_OUT_RO }" disabled="${form_SUBJECT_OUT_D }" />
				</e:field>
			</e:row>

           <e:row>
               <e:label for="SUBJECT_OUT" title="${form_CONTENTS_N }" />
                <e:field colSpan="3">
                	<e:richTextEditor height="330px" id="CONTENTS" name="CONTENTS" width="100%" required="${form_TEXT_CONTENTS_R }" readOnly="${form_CONTENTS_RO }" disabled="${form_TEXT_CONTENTS_D }" value="${formData.CONTENTS }" useToolbar="${!param.detailView}" />
 				</e:field>
 			</e:row>

           <e:row>
               <e:label for="fileAttach" title="${form_fileAttach_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="fileAttach" name="fileAttach" readOnly="${param.detailView ? true : (havePermission ? false : true)}"  fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
 				</e:field>
 			</e:row>

		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="save" />
			<e:button id="doUpate" name="doUpate" label="${doUpate_N }" disabled="${doUpate_D }" onClick="save" />
			<e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="delete2" />
			<%-- <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="do2Close" /> --%>
		</e:buttonBar>

		<c:if test="${param.loginPopupNotice == 'loginPopupNotice' }">
			<e:check id="cookieChk" name="cookieChk" /><font size="2">${BBON_010_MSG3 }</font>
		</c:if>
    </e:window>
</e:ui>