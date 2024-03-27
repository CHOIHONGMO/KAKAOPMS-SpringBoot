<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
	    
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var baseUrl = "/evermp/BYM1/BYM1_062/";

	function init() {
	}

 </script>
	<e:window id="BYM1_061" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="USER_NM" title="${form_USER_NM_N}" />
				<e:field>
					<e:inputText id="USER_NM" name="USER_NM" value="${DATA.USER_NM}" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				</e:field>
				<e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}" />
				<e:field>
					<e:inputText id="COMPANY_NM" name="COMPANY_NM" value="${DATA.COMPANY_NM}" width="${form_COMPANY_NM_W}" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="${form_COMPANY_NM_RO}" required="${form_COMPANY_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="USER_ID" title="${form_USER_ID_N}" />
				<e:field>
					<e:inputText id="USER_ID" name="USER_ID" value="${DATA.USER_ID}" width="${form_USER_ID_W}" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
				</e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="DEPT_NM" name="DEPT_NM" value="${DATA.DEPT_NM}" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
   			    <e:label for="CELL_NUM" title="${form_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="CELL_NUM" name="CELL_NUM" value="${DATA.CELL_NUM}" width="${form_CELL_NUM_W}" maxLength="${form_CELL_NUM_M}" disabled="${form_CELL_NUM_D}" readOnly="${form_CELL_NUM_RO}" required="${form_CELL_NUM_R}" />
				</e:field>
				<e:label for="TEL_NUM" title="${form_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" value="${DATA.TEL_NUM}" width="${form_TEL_NUM_W}" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="EMAIL" title="${form_EMAIL_N}" />
				<e:field colSpan="3">
					<e:inputText id="EMAIL" name="EMAIL" value="${DATA.EMAIL}" width="${form_EMAIL_W}" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

	</e:window>
</e:ui>