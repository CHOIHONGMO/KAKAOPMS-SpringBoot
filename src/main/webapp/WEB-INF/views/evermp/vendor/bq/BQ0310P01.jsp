<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>


		var baseUrl = "/evermp/vendor/bq";

		function init(){

			$('#upload-button-ATT_FILE_NUM').css('display','none');
			<c:if test="${form.ANN_FLAG eq '0'}">
				$('#form2').find('.e-searchpanel-content').css('border-top','none');
			</c:if>
			$('#form3').find('.e-searchpanel-content').css('border-top','none');
			$('#form4').find('.e-searchpanel-content').css('border-top','none');
			$('#form5').find('.e-searchpanel-content').css('border-top','none');
			$('#form6').find('.e-searchpanel-content').css('border-top','none');
			$('.e-searchpanel-content ').css('margin-bottom','15px');


		}


		function doClose(){
			if(opener != null) {
				window.close();
			} else {
				new EVF.ModalWindow().close(null);
			}
		}


	</script>
	<e:window id="BQ0310P01" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:searchPanel id="form1" columnCount="2" labelWidth="200" useTitleBar="true" title="1.일반">
			<e:row>
				<%--입찰명--%>
				<e:label for="RFX_SUBJECT" title="${form1_RFX_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${form1_RFX_SUBJECT_W}" maxLength="${form1_RFX_SUBJECT_M}" disabled="${form1_RFX_SUBJECT_D}" readOnly="${form1_RFX_SUBJECT_RO}" required="${form1_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--법인--%>
				<e:label for="PR_BUYER_NM" title="${form1_PR_BUYER_NM_N}" />
				<e:field>
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" value="${form.PR_BUYER_NM}" width="${form1_PR_BUYER_NM_W}" maxLength="${form1_PR_BUYER_NM_M}" disabled="${form1_PR_BUYER_NM_D}" readOnly="${form1_PR_BUYER_NM_RO}" required="${form1_PR_BUYER_NM_R}" />
				</e:field>
				<%--입찰기간--%>
				<e:label for="QTA_FROM_TO_DATE" title="${form1_QTA_FROM_TO_DATE_N}" />
				<e:field>
					<e:inputText id="QTA_FROM_TO_DATE" name="QTA_FROM_TO_DATE" value="${form.QTA_FROM_TO_DATE}" width="${form1_QTA_FROM_TO_DATE_W}" maxLength="${form1_QTA_FROM_TO_DATE_M}" disabled="${form1_QTA_FROM_TO_DATE_D}" readOnly="${form1_QTA_FROM_TO_DATE_RO}" required="${form1_QTA_FROM_TO_DATE_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form1_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenTypeOptions}" width="${form1_VENDOR_OPEN_TYPE_W}" disabled="${form1_VENDOR_OPEN_TYPE_D}" readOnly="${form1_VENDOR_OPEN_TYPE_RO}" required="${form1_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
				<%--업체선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form1_VENDOR_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${form.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form1_VENDOR_SLT_TYPE_W}" disabled="${form1_VENDOR_SLT_TYPE_D}" readOnly="${form1_VENDOR_SLT_TYPE_RO}" required="${form1_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--낙찰자 결정방법--%>
				<e:label for="BID_RESULT_WAY" title="${form1_BID_RESULT_WAY_N}"/>
				<e:field colSpan="3" style="height:120px;">
					<e:text>
						<e:select id="PRC_SLT_TYPE" name="PRC_SLT_TYPE" value="${form.PRC_SLT_TYPE}" options="${prcSltTypeOptions}" width="${form1_PRC_SLT_TYPE_W}" disabled="${form1_PRC_SLT_TYPE_D}" readOnly="${form1_PRC_SLT_TYPE_RO}" required="${form1_PRC_SLT_TYPE_R}" placeHolder="" />
						<c:if test="${form.PRC_SLT_TYPE eq 'PRI'}">
							<e:text>- 최저가격으로 입찰한 자를 낙찰자로 결정</e:text>
						</c:if>
						<c:if test="${form.PRC_SLT_TYPE eq 'NGO'}">
							<e:text>
								- 기술평가점수(<span style="color:blue">${form.NPRC_PERCENT}</span>점)와 가격평가점수(<span style="color:blue">${form.PRC_PERCENT}</span>점)를 종합 평가한 결과 최고득점 업체를 협상적격자로 선정<br>
								- 협상방법 : 최고득점 업체를 대상으로 협상을 진행하되, 협상결과 적합하지 않을 경우 순차적으로 차 순위 업체와 협상<br>
								- 세부평가항목과 방법은 제안요청서 참조
							</e:text>
						</c:if>
					</e:text>
				</e:field>
			</e:row>
			<e:row>
				<%--입찰참가자격--%>
				<e:label for="BID_PREQ_RMK" title="${form1_BID_PREQ_RMK_N}"/>
				<e:field colSpan="3" style="height:120px;">
					<%--<e:textArea id="BID_PREQ_RMK" name="BID_PREQ_RMK" value="${form.BID_PREQ_RMK}" height="100px" width="${form1_BID_PREQ_RMK_W}" maxLength="${form1_BID_PREQ_RMK_M}" disabled="${form1_BID_PREQ_RMK_D}" readOnly="${form1_BID_PREQ_RMK_RO}" required="${form1_BID_PREQ_RMK_R}" />--%>
					<e:text>${form.BID_PREQ_RMK}</e:text>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:searchPanel id="form2" columnCount="2" labelWidth="200" useTitleBar="true" title="2.입찰설명회 일정">
			<c:if test="${form.ANN_FLAG eq '1'}">
				<e:row>
					<%--일시--%>
					<e:label for="ANN_DATE" title="${form2_ANN_DATE_N}" />
					<e:field>
						<e:inputText id="ANN_DATE" name="ANN_DATE" value="${form.ANN_DATE}" width="${form2_ANN_DATE_W}" maxLength="${form2_ANN_DATE_M}" disabled="${form2_ANN_DATE_D}" readOnly="${form2_ANN_DATE_RO}" required="${form2_ANN_DATE_R}"/>
					</e:field>
					<%--장소--%>
					<e:label for="ANN_PLACE_NM" title="${form2_ANN_PLACE_NM_N}" />
					<e:field>
						<e:inputText id="ANN_PLACE_NM" name="ANN_PLACE_NM" value="${form.ANN_PLACE_NM}" width="${form2_ANN_PLACE_NM_W}" maxLength="${form2_ANN_PLACE_NM_M}" disabled="${form2_ANN_PLACE_NM_D}" readOnly="${form2_ANN_PLACE_NM_RO}" required="${form2_ANN_PLACE_NM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<%--필수참석여부--%>
					<e:label for="ANN_ATTEND_FLAG" title="${form2_ANN_ATTEND_FLAG_N}"/>
					<e:field>
						<e:select id="ANN_ATTEND_FLAG" name="ANN_ATTEND_FLAG" value="${form.ANN_ATTEND_FLAG}" options="${annAttendFlagOptions}" width="${form2_ANN_ATTEND_FLAG_W}" disabled="${form2_ANN_ATTEND_FLAG_D}" readOnly="${form2_ANN_ATTEND_FLAG_RO}" required="${form2_ANN_ATTEND_FLAG_R}" placeHolder="" />
					</e:field>
					<%--담당자--%>
					<e:label for="ANN_USER_NM" title="${form2_ANN_USER_NM_N}" />
					<e:field>
						<e:inputText id="ANN_USER_NM" name="ANN_USER_NM" value="${form.ANN_USER_NM}" width="${form2_ANN_USER_NM_W}" maxLength="${form2_ANN_USER_NM_M}" disabled="${form2_ANN_USER_NM_D}" readOnly="${form2_ANN_USER_NM_RO}" required="${form2_ANN_USER_NM_R}" />
						<e:text>/</e:text>
						<e:inputText id="ANN_USER_TEL_NM" name="ANN_USER_TEL_NM" value="${form.ANN_USER_TEL_NM}" width="${form2_ANN_USER_TEL_NM_W}" maxLength="${form2_ANN_USER_TEL_NM_M}" disabled="${form2_ANN_USER_TEL_NM_D}" readOnly="${form2_ANN_USER_TEL_NM_RO}" required="${form2_ANN_USER_TEL_NM_R}" />
					</e:field>
				</e:row>
				<e:row>
					<%--비고--%>
					<e:label for="ANN_RMK" title="${form2_ANN_RMK_N}"/>
					<e:field colSpan="3" style="height:120px;">
						<%--<e:textArea id="ANN_RMK" name="ANN_RMK" value="${form.ANN_RMK}" height="100px" width="${form2_ANN_RMK_W}" maxLength="${form2_ANN_RMK_M}" disabled="${form2_ANN_RMK_D}" readOnly="${form2_ANN_RMK_RO}" required="${form2_ANN_RMK_R}" style="border:none;"/>--%>
						<e:text>${form.ANN_RMK}</e:text>
					</e:field>

				</e:row>
			</c:if>
			<c:if test="${form.ANN_FLAG eq '0'}">
				<e:text>○ 입찰설명회 없음.</e:text>
			</c:if>
		</e:searchPanel>

		<e:searchPanel id="form3" columnCount="2" labelWidth="200" useTitleBar="true" title="3.입찰 무효">
			<e:text>○ 입찰참가자격이 없는 자가 행한 입찰 또는 입찰조건에 위배되는 입찰은 무효로 함.</e:text>
		</e:searchPanel>

		<e:searchPanel id="form4" columnCount="2" labelWidth="200" useTitleBar="true" title="4.본 계약은 청렴계약 이행 대상 계약임.">
		</e:searchPanel>

		<e:searchPanel id="form5" columnCount="2" labelWidth="200" useTitleBar="true" title="5.참고사항">
			<e:text>
				○ 제안요청내용, 계약조건, 입찰유의서 등 본 입찰에 관한 제반 사항을 완전히 숙지하고 입찰에 응해야 하며, 숙지하지 못하여 발생한 책임은 입찰자에 있음.<br>
				○ 평가와 관련해서 발생되는 모든 사안에 대하여 대외비로 취급하며, 제출된 모든 문서는 심의평가를 위한 경우를 제외하고는 공개 및 반환하지 않음.
			</e:text>
		</e:searchPanel>

		<e:searchPanel id="form6" columnCount="2" labelWidth="200" useTitleBar="true" title="6.기타사항">
			<e:text>${form.RMK}</e:text>
		</e:searchPanel>

		<e:searchPanel id="form7" columnCount="1" labelWidth="200" useTitleBar="true" title="7.붙임파일">
			<%--첨부파일--%>
			<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
			<e:field>
				<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${form.ATT_FILE_NUM}" width="${form_ATT_FILE_NUM_W}"  readOnly="true" bizType="BD" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
			</e:field>
		</e:searchPanel>

		<e:panel style="width:100%;left: 50%;text-align: center;">
			<e:text style="font-size:15px;line-height:35px;">이상과 같이 공고합니다.
			<br>${form.RFX_DATE_YEAR}년 ${form.RFX_DATE_MM}월 ${form.RFX_DATE_DD}일
			<br>카카오페이증권
			<br></e:text>
		</e:panel>
		<e:buttonBar align="right" id="buttonBar" style="margin-bottom: 50px;">
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
	</e:window>
</e:ui>