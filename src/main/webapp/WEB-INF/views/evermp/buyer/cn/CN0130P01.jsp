<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@page import="com.st_ones.common.util.clazz.EverString" %>
<%@page import="com.st_ones.everf.serverside.config.PropertiesManager" %>

<%@ page import="com.nets.sso.agent.AuthCheck" %>
<%@ page import="com.nets.sso.agent.CookieInfo" %>
<%@ page import="com.nets.sso.agent.SSOConfig" %>
<%@ page import="com.nets.sso.agent.enums.AuthStatus" %>
<%@ page import="com.nets.sso.agent.exception.AgentException" %>
<%@ page import="com.nets.sso.agent.exception.ErrorCode" %>
<%@ page import="com.nets.sso.agent.utils.Util" %>
<%@ page import="com.nets.sso.agent.utils.DateUtil" %>
<%@ page import="com.nets.sso.agent.utils.StrUtil" %>
<%@ page import="java.util.Date" %>

<%
	String gwUrl = PropertiesManager.getString("eversrm.dm.gw.url");				// 그룹웨어 url
	String bKey  = PropertiesManager.getString("eversrm.dm.gw.bid.key");			// 입찰시행품의 key값
	String pKey  = PropertiesManager.getString("eversrm.dm.gw.pcn.key");			// 구매품의 key값
	String hKey  = PropertiesManager.getString("eversrm.dm.gw.hcn.key");			// 본사품의 key값
	String isDev = PropertiesManager.getString("eversrm.system.developmentFlag");	// 개발여부

	String logonUrl  = "";
	String logoffUrl = "";
	String returnUrl = "";
	boolean isLogon  = false;
	String logonId   = "";
	String errorMsg  = "";

	String iDTagName  = "";
	String pwdTagName = "";
	String credTypeTagName  = "";
	String returnURLTagName = "";

	//대명 CS 인증값
	String siteDns  = "";
	String tokenUrl = "";
	String deptCode = "";

	try {
		//인증객체생성 및 인증확인
		AuthCheck auth = new AuthCheck(request, response);
		AuthStatus status = auth.checkLogon();

		//Token 가져오기
		String toKen = EverString.nullToEmptyString(request.getParameter("token"));
		if (EverString.isNotEmpty(toKen)) {
			String tokenReturnUrl = request.getRequestURL().toString() + "?token=";
			String useSSLYN = (SSOConfig.isProviderSecureOpt()? "https://" : "http://");
			tokenUrl = useSSLYN + SSOConfig.providerDomain() + ":" + SSOConfig.getProviderPortNumber() + "/nsso-authweb/tokencheck.do?token=" + toKen
		    					+ "&" + SSOConfig.returnURLTagName() + "=" + Util.uRLEncode(tokenReturnUrl, "UTF8")
		    					+ "&" + SSOConfig.REQUESTSSOSITEPARAM + "=" + SSOConfig.siteDomain(request);

			response.sendRedirect(tokenUrl);
		}

		//기본 URL설정
		logonUrl  = SSOConfig.logonPage(request)  + "?" + SSOConfig.REQUESTSSOSITEPARAM + "=" + SSOConfig.siteDomain(request);
		logoffUrl = SSOConfig.logoffPage(request) + "?" + SSOConfig.returnURLTagName()  + "=" + Util.uRLEncode(auth.thisURL(), "UTF-8") + "&" + SSOConfig.REQUESTSSOSITEPARAM + "=" + SSOConfig.siteDomain(request);

		//인증상태별 처리
		/**
		 * 2022.11.14 : 해당 부분은 제외 (= 처리안됨)
		if(status == AuthStatus.SSOFirstAccess) {
			auth.trySSO(); 	//최초 접속
		} else*/
		if(status == AuthStatus.SSOSuccess) {
			isLogon = true; //인증성공

			//이동할 곳이 있는지 여부
			if (StrUtil.isNullOrEmpty(request.getParameter(SSOConfig.returnURLTagName())) == false){
			    returnUrl = Util.uRLEncode(request.getParameter(SSOConfig.returnURLTagName()), "UTF-8");
			    //response.sendRedirect(returnUrl);
			}

			//로그인 아이디
			logonId = auth.userID();
			siteDns = SSOConfig.siteDomain(request);
			returnUrl = Util.uRLEncode(auth.thisURL(), "UTF8");

			Cookie c = Util.getCookie(request.getCookies(), "cToken");
			deptCode = auth.getSSODomainCookieValue("user_id");
		}
		else if(status == AuthStatus.SSOFail){
			//인증실패
			if (StrUtil.isNullOrEmpty(request.getParameter(SSOConfig.returnURLTagName())) == false){
			    returnUrl = Util.uRLEncode(request.getParameter(SSOConfig.returnURLTagName()), "UTF-8");
			} else {
				returnUrl = Util.uRLEncode(auth.thisURL(), "UTF-8");
			}

			//SSO 실패 시 정책에 따라 자체 로그인 페이지로 이동 시키거나, SSO 인증을 위한 포탈 로그인 페이지로 이동
			if (auth.errorNumber() != 0){
				errorMsg = "[" + auth.errorNumber() + "]";
				if (auth.errorNumber() == ErrorCode.Duplication_Last_Priority.getValue()) {
					errorMsg += " Duplication Last Priority";
				}
				if (auth.errorNumber() == ErrorCode.TokenIdleTimeout.getValue()) {
					errorMsg += " Token Idle Timeout";
				}
				if (auth.errorNumber() == ErrorCode.TokenExpired.getValue()) {
					errorMsg += " Token Expired";
				}
				errorMsg += " : " + auth.errorString();
			}

			iDTagName  = SSOConfig.iDTagName();
			pwdTagName = SSOConfig.pwdTagName();
			credTypeTagName  = SSOConfig.credentialTypeTagName();
			returnURLTagName = SSOConfig.returnURLTagName();
		}
		else if(status == AuthStatus.SSOUnAvaliable){
			errorMsg = " " + auth.errorString(); //SSO 장애 시 정책에 따라 자체 로그인 페이지로 이동 시키거나, SSO 인증을 위한 포탈 로그인 페이지로 이동
		}
		else if(status == AuthStatus.SSOAccessDenied){
			errorMsg = " " + auth.errorString(); //접근제한
		}
		else {
			errorMsg = " " + "SSO 체크시 오류가 발생하였습니다.\\n동일한 오류가 지속적으로 발생시 관리자에게 문의하세요."; //알수없는 오류
		}
	}
	catch(AgentException ex) {
		errorMsg = "그룹웨어(G/W)를 통한 SSO 로그인을 하지 않은 경우 결재상신이 불가합니다.\\n동일한 오류가 지속적으로 발생시 관리자에게 문의하세요.";
	}
%>

<c:set var="logonId"  value="<%=logonId%>"/>
<c:set var="errorMsg" value="<%=errorMsg%>"/>
<c:set var="gwUrl"    value="<%=gwUrl%>"/>
<c:set var="bKey"     value="<%=bKey%>"/>
<c:set var="pKey"     value="<%=pKey%>"/>
<c:set var="hKey"     value="<%=hKey%>"/>
<c:set var="isDev"    value="<%=isDev%>"/>

<e:ui>
	<script type="text/javascript" src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/econt_plugins_n.js"></script>
	<script type="text/javascript">

		var grid;
		var baseUrl = "/evermp/buyer/cn/";
		var gwUseFlag = 'N';   <%-- GW 결재여부--%>

        CKEDITOR.disableAutoInline = true;  // 인라인에디터를 자동으로 초기화하는 것을 방지(원하는 영역만 수동으로 에디터를 로드하기 위해)

		function init() {
			console.log('${errorMsg}');
			console.log("${formData.APP_DOC_NUM}")
			console.log("${formData.APP_DOC_CNT}")
			if( '${isDev}' !== 'true' && ('${logonId}' === '' || '${errorMsg}' !== '') ){
            	alert('${errorMsg}');
            	window.close();
            } else {
            	// title변경
    			$(".e-window-container-header-text").text("${formData.screenName}")
    			document.title ="${formData.screenName}"
    			<%-- CK editor를 textarea안에 넣는 부분 --%>
                var editor = CKEDITOR.replace('cont_content', {
                    customConfig : '/js/everuxf/lib/ckeditor/ep_configs_p.js?var=3',

                    width: '100%',
                    height: 330
                });

                editor.on('instanceReady', function(ev){
                    var editor = ev.editor;
                    editor.resize('100%', $('body').height() - 230, true, false);
                    $(window).resize(function() {
                        editor.resize('100%', $('body').height() - 230, true, false);
                    });
                });
            }
        }

		function doSign(val){

			var store = new EVF.Store();
			EVF.V("xmlParam",CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'))
			var urlGubn = "";
			if("${formData.pageName}" =="BD"){
				urlGubn ="/evermp/buyer/bd/doSign"
			}else{
				urlGubn ="/evermp/buyer/cn/doSign"

			}

			var formDocId = "";
			var gubnName  = "${param.EXEC_GB}";
			var titleGw   = "";
			if(gubnName == "CP" || gubnName == "P") {

				formDocId = "${pKey}"; //구매품의
				//밸리데이션 체크위함.
				if(opener ==null){
					alert("품의작성 팝업창이 꺼져있습니다 켜신후 다시 작업바랍니다").
					doClose();
					return;
				}
				if(!opener.validationCheck()){
					alert("저장후 다시 진행하십시오");
					doClose()
					return;
				}
				titleGw = gubnName=="CP" ? "[(변경)매입/매출]"+EVF.V("SUBJECT") : "[매입/매출]"+EVF.V("SUBJECT")

			} else if(gubnName == "CH" || gubnName == "H") {

				formDocId = "${hKey}"; //본사품의
				titleGw = gubnName=="CH" ? "[(변경)본사/품의]"+EVF.V("SUBJECT") : "[본사/품의]"+EVF.V("SUBJECT")

			} else {
				titleGw = '[입찰시행품의]'+EVF.V("SUBJECT")
				console.log(titleGw)
				formDocId = "${bKey}"; //입찰시행
				if(opener ==null){
					alert("입찰작성 팝업창이 꺼져있습니다 켜신후 다시 작업바랍니다");
					doClose();
					return;
				}
				if(!opener.validationCheck()){
					alert("저장후 다시 진행하십시오");
					doClose();
					return;
				}
			}
			//console.log(formDocId, "formDocId");
			store.load(urlGubn, function () {
				var appNum = this.getParameter('APP_DON_NUM2')
				document.getElementById("xmlParam").value= "<?xml version='1.0' encoding='euc-kr'?><root>    <title>"+titleGw+"</title>    <approvalline></approvalline>    <htmlcontent><![CDATA["+document.getElementById("xmlParam").value+"]]></htmlcontent></root>";

				EVF.alert(this.getResponseMessage(), function() {
					//console.log(appNum, "appNum");
					//console.log("${gwUrl}", "gwUrl");
					var objForm = document.forms["form1"];
				 	objForm.method = "post";
				 	objForm.target = "POP";
					objForm.action = "${gwUrl}" + "?formId=" + formDocId 	// 품의문서종류 120017001126
												+ "&appKey01=" + appNum 	// 결재번호
												+ "&popupYn=true"
												+ "&appSystem=si" 			// 업무구분 = si(ISN)
												+ "&appModule=purchase";

				   	var popup = window.open('','POP','width=1000, height=750, menubar=no, status=no, scollbars=yes,  resizable=yes');
				  	popup.focus();

					objForm.submit();
					opener.openerFn();
					doClose();
				});
			});
		}

		function doClose() {
			window.close();
		}
	</script>

	<e:window id="CN0130P01" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">

		<e:buttonBar id="buttonBar" align="right" width="100%">
		<!--구매품의 버튼 -->
		<c:if test="${(formData.PROGRESS_CD =='3100' && (formData.IF_SIGN_FLAG =='CP' || formData.IF_SIGN_FLAG =='P') && (formData.COFM_FLAG == 0 || formData.COFM_FLAG == null || formData.COFM_FLAG == ''))}">
			<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
		</c:if>
		<!--본사품의 버튼 -->
		<c:if test="${((formData.IF_SIGN_FLAG =='H' || formData.IF_SIGN_FLAG =='CH')  && (formData.COFM_FLAG == 0 || formData.COFM_FLAG == null || formData.COFM_FLAG == ''))}">
			<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
		</c:if>
		<!--입찰품의 버튼 -->
		<c:if test="${formData.PROGRESS_CD =='2600' && (formData.COFM_FLAG == 0 || formData.COFM_FLAG == null || formData.COFM_FLAG == '') }">
			<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}" />
		</c:if>

		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="140" onEnter="doSearch" useTitleBar="false">
			<form id="form1" name="form1" method="post" action="">
				<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD}" />
				<e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${formData.EXEC_NUM}" />
				<e:inputHidden id="EXEC_CNT" name="EXEC_CNT" value="${formData.EXEC_CNT}" />
				<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${formData.APP_DOC_NUM}" />
				<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${formData.APP_DOC_CNT}" />
				<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS}" />
				<e:inputHidden id="SIGN_STATUS2" name="SIGN_STATUS2" value="${formData.SIGN_STATUS2}" />
				<e:inputHidden id="APP_DOC_NUM2" name="APP_DOC_NUM2" value="${formData.APP_DOC_NUM2}" />
				<e:inputHidden id="APP_DOC_CNT2" name="APP_DOC_CNT2" value="${formData.APP_DOC_CNT2}" />
				<e:inputHidden id="IF_SIGN_FLAG" name="IF_SIGN_FLAG" value="${formData.IF_SIGN_FLAG}" />
				<e:inputHidden id="EXEC_GB" name="EXEC_GB" value="${param.EXEC_GB}" />
				<e:inputHidden id="pageName" name="pageName" value="${formData.pageName}" />
				<e:inputHidden id="SUBJECT" name="SUBJECT" value="${param.SUBJECT}" />
				<!--그룹웨어 연동 필요할 값  -->
				<e:inputHidden id="add_user_name_loc" name="add_user_name_loc" value="${ses.userNm}" />
				<e:inputHidden id="dept_code" name="dept_code" value="${ses.deptCd}" />
				<e:inputHidden id="req_user_id" name="req_user_id" value="${ses.userId}" />
				<e:inputHidden id="fnc_name" name="fnc_name" value="getApproval" />
				<e:inputHidden id="bd_tot_amt" name="bd_tot_amt" />
				<e:inputHidden id="status" name="status" />
				<e:inputHidden id="xmlParam" name="xmlParam" value="${formData.BLSM_HTML}"/>
				<e:inputHidden id="EVAL_DATA" name="EVAL_DATA" />
	            <e:row>
	                <e:field colSpan="4">
	                    <textarea id=cont_content style="${imeMode}" name="cont_content" style="width:100%;">${formData.BLSM_HTML}</textarea>
	                </e:field>
	            </e:row>
			</form>
		</e:searchPanel>

	</e:window>
</e:ui>
