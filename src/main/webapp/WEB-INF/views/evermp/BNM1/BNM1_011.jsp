<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/BNM1/BNM101/";

        function init() {
			
        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-IMAGE_UUID').css('display','none');
        		$('#upload-button-ATTACH_FILE_NO').css('display','none');
        	}
        	
            <%--
            EVF.C('Request').setVisible(false);
            if(("${formData.REG_USER_ID == ses.userId}") && ("${ses.ctrlCd}".indexOf("T100") != -1)){
                EVF.C('Request').setVisible(true);
            } --%>

        	if(!EVF.isEmpty(everString.lrTrim(EVF.C("PROGRESS_CD").getValue())) && everString.lrTrim(EVF.C("PROGRESS_CD").getValue()) != "" && everString.lrTrim(EVF.C("PROGRESS_CD").getValue()) != "100" && everString.lrTrim(EVF.C("PROGRESS_CD").getValue()) != "200") {
        	    EVF.C('Request').setVisible(false);
        	}
        	<%--
            if("${ses.buyerApproveUseFlag}" == "1" || "${ses.buyerBudgetUseFlag}" == "1") {
                EVF.C('AUTO_PO_FLAG').setDisabled(true);
            } --%>
            EVF.V("AUTO_PO_FLAG", "0");
        	_onChangeAutoPoYn();
        }

        function doRequest() {
            var store = new EVF.Store();

            if(EVF.C("AUTO_PO_FLAG").getValue() == "1") {
            	if(EVF.isEmpty(EVF.C("RECIPIENT_NM").getValue()) || EVF.isEmpty(EVF.C("RECIPIENT_TEL_NUM").getValue())
                    || EVF.isEmpty(EVF.C("RECIPIENT_CELL_NUM").getValue()) || EVF.isEmpty(EVF.C("DELY_ZIP_CD").getValue()) || EVF.isEmpty(EVF.C("DELY_ADDR_1").getValue())) {
            		return alert("${BNM1_011_ALERT1}");
            	}
            	if(EVF.isEmpty(EVF.C("HOPE_DUE_DATE").getValue())) {
            		return alert("${BNM1_011_ALERT2}");
            	}
            }

            if(!store.validate()) { return; }
            if(!confirm("${msg.M0053}")) { return; }

            var store = new EVF.Store();
        	store.doFileUpload(function() {
            	store.load(baseUrl + 'bnm1011_doSave', function () {
            		if(EVF.isEmpty(EVF.C("ITEM_REQ_NO").getValue())) {
            			// opener.location.href = baseUrl + 'BNM1_030/view';
                        // var el = opener.parent.parent.document.getElementById('mainIframe');
                        opener.top.pageRedirectByScreenId("BNM1_040", {});
            		}
            		else { opener.doSearch(); }
            		doClose();
                });
            });
        }

        function getAccDeptInfo() {
        	var param = {
                callBackFunction: "setAccDeptInfo",
                CUST_CD: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0087');
        }

        function setAccDeptInfo(data) {
        	EVF.C("BUDGET_DEPT_CD").setValue(data.DEPT_CD);
        	EVF.C("BUDGET_DEPT_NM").setValue(data.DEPT_NM);
        }

        function getAcountInfo() {
        	var param = {
                callBackFunction: "setAcountInfo",
                custCd: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0085');
        }

        function setAcountInfo(data) {
        	EVF.C("ACCOUNT_CD").setValue(data.ACCOUNT_CD);
        	EVF.C("ACCOUNT_NM").setValue(data.ACCOUNT_NM);
        }

        function getRecipientInfo() {
        	var param = {
                callBackFunction: "setRecipientInfo",
                CUST_CD: "${ses.companyCd}",
                USER_ID: "${ses.userId}",
                detailView: false
            };
        	everPopup.openPopupByScreenId("MY01_006", 800, 450, param);
        }

        function setRecipientInfo(data) {
        	EVF.C("RECIPIENT_DEPT_NM").setValue(data.RECIPIENT_DEPT_NM);
        	EVF.C("RECIPIENT_NM").setValue(data.HIDDEN_RECIPIENT_NM);
        	EVF.C("RECIPIENT_TEL_NUM").setValue(data.HIDDEN_RECIPIENT_TEL_NUM);
        	EVF.C("RECIPIENT_CELL_NUM").setValue(data.HIDDEN_RECIPIENT_CELL_NUM);
        	EVF.C("DELY_ZIP_CD").setValue(data.DELY_ZIP_CD);
        	EVF.C("DELY_ADDR_1").setValue(data.DELY_ADDR_1);
        	EVF.C("DELY_ADDR_2").setValue(data.DELY_ADDR_2);
        	EVF.C("REQ_TXT").setValue(data.DELY_RMK);
        }

        function searchZipCd() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode",
                modalYn : false
            };
            //everPopup.openWindowPopup(url, 700, 600, param);
            everPopup.jusoPop(url, param);
        }

        function setZipCode(zipcd) {
            if (zipcd.ZIP_CD != "") {
                EVF.C("DELY_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('DELY_ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('DELY_ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('DELY_ADDR_2').setFocus();
            }
        }

        function _onChangeAutoPoYn() {

        	var requiredFalg = false;
        	<%--
            if(EVF.C("AUTO_PO_FLAG").getValue() == '1') {
                EVF.C('form2').collapse(false);
                requiredFalg = true;
            } else {
                EVF.C('form2').collapse(true);
            } --%>

            EVF.C('HOPE_DUE_DATE').setRequired(requiredFalg);
            <%--
            EVF.C('EST_PO_QT').setRequired(requiredFalg);
            EVF.C('RECIPIENT_NM').setRequired(requiredFalg);
            EVF.C('RECIPIENT_DEPT_NM').setRequired(requiredFalg);
            EVF.C('RECIPIENT_TEL_NUM').setRequired(requiredFalg);
            EVF.C('RECIPIENT_CELL_NUM').setRequired(requiredFalg);
            EVF.C('DELY_ZIP_CD').setRequired(requiredFalg);
            EVF.C('DELY_ADDR_1').setRequired(requiredFalg);
            --%>
        }

        function _setRecipientNm() {
            EVF.C('RECIPIENT_DEPT_NM').setValue(this.getText());
        }

        function _checkTelNum() {
        	if(!everString.isTel(EVF.C("RECIPIENT_TEL_NUM").getValue())) {
        		alert("${msg.M0128}");
        		EVF.C("RECIPIENT_TEL_NUM").setValue("");
        	}
        }

        function _checkCellNum() {
        	if(!everString.isTel(EVF.C("RECIPIENT_CELL_NUM").getValue())) {
        		alert("${msg.CELL_NUM_INVALID}");
        		EVF.C("RECIPIENT_CELL_NUM").setValue("");
        	}
        }

        function doClose() {
            window.close();
        }
        
        function imageOpen() {
        	var url = EVF.V("REFER_URL");
        	if(url != "") {
            	everPopup.openWindowPopup(url, 500, 470, '', 'destUrl', true);
        	}
        }

    </script>
    
    <e:window id="BNM1_011" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="FIbuttonBar" title="${BNM1_011_CAPTION1 }" align="right" width="100%">
			<e:button id="Request" name="Request" label="${Request_N }" disabled="${Request_D }" visible="${Request_V}" onClick="doRequest" />
			<e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" visible="${Close_V}" onClick="doClose" />
		</e:buttonBar>

        <e:searchPanel id="form1" title="" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:inputHidden id="ITEM_REQ_NO" name="ITEM_REQ_NO" value="${formData.ITEM_REQ_NO }"/>
            <e:inputHidden id="ITEM_REQ_SEQ" name="ITEM_REQ_SEQ" value="${formData.ITEM_REQ_SEQ }"/>
            <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD }"/>
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${formData.CUST_CD }"/>
            <e:inputHidden id="DEPT_CD" name="DEPT_CD" value="${formData.DEPT_CD }"/>
            <e:inputHidden id="CUST_ITEM_CD" name="CUST_ITEM_CD" value="${formData.CUST_ITEM_CD }"/>
            <e:inputHidden id="AUTO_PO_FLAG" name="AUTO_PO_FLAG" value="${formData.AUTO_PO_FLAG }"/>
            <e:row>
                <e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}"/>
                <e:field>
                    <e:text> ${formData.CUST_ITEM_CD == '' ? formData.ITEM_CD : formData.CUST_ITEM_CD} </e:text>
                </e:field>
                <e:label for="REQ_INFO" title="${form_REQ_INFO_N}"/>
                <e:field>
                    <e:text> ${formData.REQ_INFO } </e:text>
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${formData.ITEM_DESC }" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
                <e:field colSpan="1">
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="${formData.ITEM_SPEC }" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
				<e:label for="HOPE_UNIT_PRICE" title="${form_HOPE_UNIT_PRICE_N}"/>
				<e:field>
					<e:inputNumber id="HOPE_UNIT_PRICE" name="HOPE_UNIT_PRICE" value="${formData.HOPE_UNIT_PRICE}"  width="${form_HOPE_UNIT_PRICE_W}" maxValue="${form_HOPE_UNIT_PRICE_M}" decimalPlace="${form_HOPE_UNIT_PRICE_NF}" disabled="${form_HOPE_UNIT_PRICE_D}" readOnly="${form_HOPE_UNIT_PRICE_RO}" required="${form_HOPE_UNIT_PRICE_R}" />
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="MAKER_NM" title="${form_MAKER_NM_N}"/>
                <e:field>
                    <e:inputText id="MAKER_NM" name="MAKER_NM" value="${formData.MAKER_NM }" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
                </e:field>
                <e:label for="MODEL_NM" title="${form_MODEL_NM_N}"/>
                <e:field>
                    <e:inputText id="MODEL_NM" name="MODEL_NM" value="${formData.MODEL_NM }" width="${form_MODEL_NM_W}" maxLength="${form_MODEL_NM_M}" disabled="${form_MODEL_NM_D}" readOnly="${form_MODEL_NM_RO}" required="${form_MODEL_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
				<e:label for="ORIGIN_NM" title="${form_ORIGIN_NM_N}" />
				<e:field>
					<e:inputText id="ORIGIN_NM" name="ORIGIN_NM" value="${formData.ORIGIN_NM }" width="${form_ORIGIN_NM_W}" maxLength="${form_ORIGIN_NM_M}" disabled="${form_ORIGIN_NM_D}" readOnly="${form_ORIGIN_NM_RO}" required="${form_ORIGIN_NM_R}" />
				</e:field>
				<e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
                <e:field>
                    <e:select id="UNIT_CD" name="UNIT_CD" value="${empty formData.UNIT_CD ? 'EA': formData.UNIT_CD}" options="${unitCdOptions }" width="${form_UNIT_CD_W}" disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}" required="${form_UNIT_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="EST_PO_QT" title="${form_EST_PO_QT_N}"/>
                <e:field>
                    <e:inputNumber id="EST_PO_QT" name="EST_PO_QT" value="${formData.EST_PO_QT }" width="${form_EST_PO_QT_W}" maxValue="${form_EST_PO_QT_M}" decimalPlace="${form_EST_PO_QT_NF}" disabled="${form_EST_PO_QT_D}" readOnly="${form_EST_PO_QT_RO}" required="${form_EST_PO_QT_R}" />
                </e:field>
                <e:label for="EST_PO_DATE" title="${form_EST_PO_DATE_N}"/>
               <e:field>
                   <e:inputDate id="EST_PO_DATE" name="EST_PO_DATE" value="${formData.EST_PO_DATE }" width="${inputDateWidth }" datePicker="true" required="${form_EST_PO_DATE_R}" disabled="${form_EST_PO_DATE_D}" readOnly="${form_EST_PO_DATE_RO}" />
               </e:field>
			</e:row>
            <e:row>
            	<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
                <e:field>
                    <e:inputDate id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="${formData.HOPE_DUE_DATE }" width="${inputDateWidth }" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
                </e:field>
                <e:label for="CUR" title="${form_CUR_N}" />
                <e:field>
                    <e:select id="CUR" name="CUR" value="${empty formData.CUR ? 'KRW' : formData.CUR }" options="${curOptions }" width="${form_CUR_W}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PREV_VENDOR_NM" title="${form_PREV_VENDOR_NM_N}"/>
                <e:field >
                    <e:inputText id="PREV_VENDOR_NM" name="PREV_VENDOR_NM" value="${formData.PREV_VENDOR_NM }" width="${form_PREV_VENDOR_NM_W}" maxLength="${form_PREV_VENDOR_NM_M}" disabled="${form_PREV_VENDOR_NM_D}" readOnly="${form_PREV_VENDOR_NM_RO}" required="${form_PREV_VENDOR_NM_R}" />
               	</e:field>
            	<e:label for="PIC_USER_NM" title="${form_PIC_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="PIC_USER_NM" name="PIC_USER_NM" value="${formData.PIC_USER_NM }" width="${form_PIC_USER_NM_W}" maxLength="${form_PIC_USER_NM_M}" disabled="${form_PIC_USER_NM_D}" readOnly="${form_PIC_USER_NM_RO}" required="${form_PIC_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PIC_TEL_NO" title="${form_PIC_TEL_NO_N}"/>
                <e:field>
                    <e:inputText id="PIC_TEL_NO" name="PIC_TEL_NO" value="${formData.PIC_TEL_NO }" width="${form_PIC_TEL_NO_W}" maxLength="${form_PIC_TEL_NO_M}" disabled="${form_PIC_TEL_NO_D}" readOnly="${form_PIC_TEL_NO_RO}" required="${form_PIC_TEL_NO_R}" />
                </e:field>
                <e:label for="REFER_URL" title="${form_REFER_URL_N}"/>
                <e:field>
                    <e:search id="REFER_URL" name="REFER_URL" value="${formData.REFER_URL }" width="${form_REFER_URL_W}" maxLength="${form_REFER_URL_M}" onIconClick="imageOpen" disabled="${form_REFER_URL_D}" readOnly="${form_REFER_URL_RO}" required="${form_REFER_URL_R}" />
               </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_RMK" title="${form_ITEM_RMK_N}" />
                <e:field>
                    <e:textArea id="ITEM_RMK" name="ITEM_RMK" height="120px" value="${formData.ITEM_RMK }" width="${form_ITEM_RMK_W}" maxLength="${form_ITEM_RMK_M}" disabled="${form_ITEM_RMK_D}" readOnly="${form_ITEM_RMK_RO}" required="${form_ITEM_RMK_R}" style="${imeMode}"/>
                </e:field>
            	<e:label for="IMAGE_UUID" title="${form_IMAGE_UUID_N}"/>
                <e:field>
                    <e:fileManager id="IMAGE_UUID" name="IMAGE_UUID" fileId="${formData.IMAGE_UUID}" downloadable="true" width="100%" bizType="VENDOR" height="80px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REQ_TXT" title="${form_REQ_TXT_N}" />
                <e:field>
                    <e:textArea id="REQ_TXT" name="REQ_TXT" height="120px" value="${formData.REQ_TXT }" width="${form_REQ_TXT_W}" maxLength="${form_REQ_TXT_M}" disabled="${form_REQ_TXT_D}" readOnly="${form_REQ_TXT_RO}" required="${form_REQ_TXT_R}" style="${imeMode}"/>
                </e:field>
            	<e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}"/>
                <e:field>
                    <e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" fileId="${formData.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="VENDOR" height="80px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        
        <%-- 2022.09.23 주문정보 제외
        <e:searchPanel id="form2" title="${BNM1_011_CAPTION2 }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="true" >
            <e:row>
            	<e:label for="BUDGET_DEPT_NM" title="${form_BUDGET_DEPT_NM_N}"/>
                <e:field>
                    <e:search id="BUDGET_DEPT_NM" name="BUDGET_DEPT_NM" value="${formData.BUDGET_DEPT_NM }" width="${form_BUDGET_DEPT_NM_W }" maxLength="${form_BUDGET_DEPT_NM_M }" onIconClick="${param.detailView ? 'everCommon.blank' : 'getAccDeptInfo'}" disabled="${form_BUDGET_DEPT_NM_D}" readOnly="${form_BUDGET_DEPT_NM_RO }" required="${form_BUDGET_DEPT_NM_R}" />
                    <e:inputHidden id="BUDGET_DEPT_CD" name="BUDGET_DEPT_CD" value="${formData.BUDGET_DEPT_CD }" />
                </e:field>
                <e:label for="ACCOUNT_NM" title="${form_ACCOUNT_NM_N}" />
                <e:field>
                    <e:search id="ACCOUNT_NM" name="ACCOUNT_NM" value="${formData.ACCOUNT_NM }" width="${form_ACCOUNT_NM_W }" maxLength="${form_ACCOUNT_NM_M }" onIconClick="${param.detailView ? 'everCommon.blank' : 'getAcountInfo'}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO }" required="${form_ACCOUNT_NM_R}" />
                    <e:inputHidden id="ACCOUNT_CD" name="ACCOUNT_CD" value="${formData.ACCOUNT_CD }"/>
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}"/>
                <e:field>
                    <e:search id="RECIPIENT_NM" name="RECIPIENT_NM" value="${formData.RECIPIENT_NM }" width="${form_RECIPIENT_NM_W }" maxLength="${form_RECIPIENT_NM_M }" onIconClick="${param.detailView ? 'everCommon.blank' : 'getRecipientInfo'}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO }" required="${form_RECIPIENT_NM_R}" />
                </e:field>
                <e:label for="RECIPIENT_DEPT_NM" title="${form_RECIPIENT_DEPT_NM_N}" />
                <e:field>
                    <e:inputText id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" value="${formData.RECIPIENT_DEPT_NM }" width="100%" maxLength="${form_RECIPIENT_DEPT_NM_M}" disabled="${form_RECIPIENT_DEPT_NM_D}" readOnly="${form_RECIPIENT_DEPT_NM_RO}" required="${form_RECIPIENT_DEPT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="RECIPIENT_TEL_NUM" title="${form_RECIPIENT_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" value="${formData.RECIPIENT_TEL_NUM }" width="${form_RECIPIENT_TEL_NUM_W}" maxLength="${form_RECIPIENT_TEL_NUM_M}" disabled="${form_RECIPIENT_TEL_NUM_D}" readOnly="${form_RECIPIENT_TEL_NUM_RO}" required="${form_RECIPIENT_TEL_NUM_R}" onChange="_checkTelNum" />
                </e:field>
                <e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}"/>
                <e:field>
                    <e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${formData.RECIPIENT_CELL_NUM }" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" onChange="_checkCellNum" />
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="DELY_ZIP_CD" title="${form_DELY_ZIP_CD_N}" rowSpan="2" />
                <e:field>
                    <e:search id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${formData.DELY_ZIP_CD }" width="${form_DELY_ZIP_CD_W }" maxLength="${form_DELY_ZIP_CD_M }" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_DELY_ZIP_CD_D}" readOnly="${form_DELY_ZIP_CD_RO }" required="${form_DELY_ZIP_CD_R}" />
                </e:field>
                <e:field colSpan="2">
                    <e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="${formData.DELY_ADDR_1 }" width="${form_DELY_ADDR_1_W}" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
                </e:field>
            </e:row>
            <e:row>
            	<e:field colSpan="3">
                    <e:inputText id="DELY_ADDR_2" name="DELY_ADDR_2" value="${formData.DELY_ADDR_2 }" width="${form_DELY_ADDR_2_W}" maxLength="${form_DELY_ADDR_2_M}" disabled="${form_DELY_ADDR_2_D}" readOnly="${form_DELY_ADDR_2_RO}" required="${form_DELY_ADDR_2_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REQ_TXT" title="${form_REQ_TXT_N}" />
                <e:field colSpan="3">
                    <e:textArea id="REQ_TXT" name="REQ_TXT" height="100" value="${formData.REQ_TXT }" width="${form_REQ_TXT_W}" maxLength="${form_REQ_TXT_M}" disabled="${form_REQ_TXT_D}" readOnly="${form_REQ_TXT_RO}" required="${form_REQ_TXT_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
        </e:searchPanel>
        --%>

    </e:window>
</e:ui>