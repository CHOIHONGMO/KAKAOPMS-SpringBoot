<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var grid;
        var baseUrl = "/evermp/SIV1/SIV101/";

        function init() {
        }
    </script>

    <e:window id="SIV1_024" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:row>
				<e:label for="CUST_NM" title="${form_CUST_NM_N}" />
				<e:field>
					<e:inputText id="CUST_NM" name="CUST_NM" value="${formData.CUST_NM }" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
				<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_NM" name="RECIPIENT_NM" value="${formData.RECIPIENT_NM }" width="${form_RECIPIENT_NM_W}" maxLength="${form_RECIPIENT_NM_M}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO}" required="${form_RECIPIENT_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="RECIPIENT_DEPT_NM" title="${form_RECIPIENT_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" value="${formData.RECIPIENT_DEPT_NM }" width="${form_RECIPIENT_DEPT_NM_W}" maxLength="${form_RECIPIENT_DEPT_NM_M}" disabled="${form_RECIPIENT_DEPT_NM_D}" readOnly="${form_RECIPIENT_DEPT_NM_RO}" required="${form_RECIPIENT_DEPT_NM_R}" />
				</e:field>
				<e:label for="DELY_NM" title="${form_DELY_NM_N}" />
				<e:field>
					<e:inputText id="DELY_NM" name="DELY_NM" value="${formData.DELY_NM} / ${formData.CSDM_SEQ }" width="${form_DELY_NM_W}" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="${form_DELY_NM_RO}" required="${form_DELY_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="RECIPIENT_TEL_NUM" title="${form_RECIPIENT_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" value="${formData.RECIPIENT_TEL_NUM }" width="${form_RECIPIENT_TEL_NUM_W}" maxLength="${form_RECIPIENT_TEL_NUM_M}" disabled="${form_RECIPIENT_TEL_NUM_D}" readOnly="${form_RECIPIENT_TEL_NUM_RO}" required="${form_RECIPIENT_TEL_NUM_R}" />
				</e:field>
				<e:label for="RECIPIENT_FAX_NUM" title="${form_RECIPIENT_FAX_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_FAX_NUM" name="RECIPIENT_FAX_NUM" value="${formData.RECIPIENT_FAX_NUM }" width="${form_RECIPIENT_FAX_NUM_W}" maxLength="${form_RECIPIENT_FAX_NUM_M}" disabled="${form_RECIPIENT_FAX_NUM_D}" readOnly="${form_RECIPIENT_FAX_NUM_RO}" required="${form_RECIPIENT_FAX_NUM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${formData.RECIPIENT_CELL_NUM }" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" />
				</e:field>
				<e:label for="RECIPIENT_EMAIL" title="${form_RECIPIENT_EMAIL_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" value="${formData.RECIPIENT_EMAIL }" width="${form_RECIPIENT_EMAIL_W}" maxLength="${form_RECIPIENT_EMAIL_M}" disabled="${form_RECIPIENT_EMAIL_D}" readOnly="${form_RECIPIENT_EMAIL_RO}" required="${form_RECIPIENT_EMAIL_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="DELY_ADDR_1" title="${form_DELY_ADDR_1_N}" />
				<e:field colSpan="3">
					<e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="(${formData.DELY_ZIP_CD }) ${formData.DELY_ADDR_1 } ${formData.DELY_ADDR_2 }" width="${form_DELY_ADDR_1_W}" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="REQ_RMK" title="${form_REQ_RMK_N}"/>
				<e:field colSpan="3">
					<e:textArea id="REQ_RMK" name="REQ_RMK" value="${formData.REQ_RMK }" height="250px" width="${form_REQ_RMK_W}" maxLength="${form_REQ_RMK_M}" disabled="${form_REQ_RMK_D}" readOnly="${form_REQ_RMK_RO}" required="${form_REQ_RMK_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>