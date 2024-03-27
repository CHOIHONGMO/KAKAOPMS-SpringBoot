<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="com.st_ones.everf.serverside.config.PropertiesManager" %>

<%
String devFlag = PropertiesManager.getString("eversrm.system.developmentFlag");
%>

<c:set var="devFlag" value="<%=devFlag%>"/>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="Referrer" content="origin"/>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    <meta name="apple-mobile-web-app-title" content="카카오페이증권"/>
    <meta name="robots" content="index,nofollow"/>
    <meta name="description" content="카카오페이증권"/>
    <meta name="keywords" content="카카오페이증권"/>
    <link type="text/css" rel="stylesheet" href="css/style.css"/>
    <title>KAKAOPAY SECURITIES</title>

    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script type="text/javascript" src="/js/everuxf/lic/licenseKey.js"></script>
    <script type="text/javascript" src="/js/ever-popup.js"></script>
    <script type="text/javascript" src="/js/ever-string.js"></script>
    <script type="text/javascript" src="/js/ever-cookie.js"></script>

    <script type="text/javascript" src="/js/RSA/rsa.js"></script>
    <script type="text/javascript" src="/js/RSA/jsbn.js"></script>
    <script type="text/javascript" src="/js/RSA/prng4.js"></script>
    <script type="text/javascript" src="/js/RSA/rng.js"></script>

	<%-- KTNET 공인인증서 모듈 연결(SCORE_PKI_for_OpenWeb_v1.0.1.5_2.0.7.8) : 로그인시 : 범용, 특수목적용, "세금계산서 발행용 공인인증서" 사용 가능
    <script src="/toolkit/tradesign/js/nxts/nxts.min.js"></script>
    <script src="/toolkit/tradesign/js/nxts/nxtspki_config01.js"></script>
    <script src="/toolkit/tradesign/js/nxts/nxtspki.js"></script>
    <script src="/toolkit/tradesign/js/demo.js"></script>
	--%>

    <script type="text/javascript">
	    $(window).ready(function () {

	        $('#userId').keydown(function (e) {
	            e.stopPropagation();
	            if (e.keyCode === 13) {
	                doLogin();
	            }
	        });

	        $('#password').keydown(function (e) {
	            e.stopPropagation();
	            if (e.keyCode === 13) {
	                doLogin();
	            }
	        });

	        $('#formData').keypress(function (e) {
	            if (e.keyCode == 13) return false;
	        });

	        if ($.cookie('savedUserId') != null) {
	            $('#userId').val($.cookie('savedUserId'));
	            $('#id_save_check').prop('checked', true);
	        }

	        <c:forEach var="noticePopup" items="${noticeListPopup}">
	        	alert('${noticePopup.NOTICE_NUM }');
	        	noticeCookieCheck('${noticePopup.NOTICE_NUM }', 'loginPopupNotice');
	        </c:forEach>

	        <%-- TradeSign 공인인증서
	        nxTSPKI.onInit(function () {});
            nxTSPKI.init(true);
            --%>
	    });

        function doLogin(param) {

            var rsa = new RSAKey();
            rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());

            var store = new EVF.Store();
            if (document.formData.userId.value != "") {
                store.setParameter("userId", rsa.encrypt($('#userId').val()));
                store.setParameter("checkUserId", $('#userId').val());
            } else {
                alert("아이디를 입력하세요.");
                document.formData.userId.focus();
                return;
            }

            if (document.formData.password.value == "") {
                alert("비밀번호를 입력하세요.");
                document.formData.password.focus();
                return;
            } else {
                store.setParameter("password", rsa.encrypt($('#password').val()));
            }

            toggleSaveUserId();

            store.setParameter("userType", "A");
            if (param != undefined) {
                store.setParameter('invalidate', param.invalidate);
            }
            store.load('/login', function () {
                if (this.getResponseMessage() != null && this.getResponseMessage() != '') {
                    alert(this.getResponseMessage());
                } else {
                	var resCode = this.getResponseCode();
                	if (resCode == '900') {
                        var url = '/userAgreeCheck';
                        var params = {
                            title: '개인정보 이용약관',
                            USER_ID: $('#userId').val(),
                            callBackFunction: 'chekLoginY'
                        };
                        everPopup.openWindowPopup(url, 710, 500, params, '개인정보 이용약관');
                    } else {
                        location.href = "/home";
                    }
                	<%--Multi Login
                    var resCode = this.getResponseCode();
                    if (resCode == '201') {// Multi 로그인 안됨
                        if (confirm('다른 IP로 이미 로그인된 사용자가 있습니다.\n\n기존 로그인을 로그아웃하고 다시 로그인 하시겠습니까?')) {
                            doLogin({
                                invalidate: true
                            });
                        }
                    } else if (resCode == '200') {
                        location.href = "/home";
                    }--%>
                }
            }, false);
        }

        function chekLoginY(data) {

            if (data == "Y") {
                var rsa = new RSAKey();
                rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());

                var store = new EVF.Store();
                store.setParameter("userId", rsa.encrypt($('#userId').val()));
                store.setParameter("checkUserId", $('#userId').val());
                store.setParameter("password", rsa.encrypt($('#password').val()));
                store.setParameter("userType", "A");

                store.load('/login', function () {
                    if (this.getResponseMessage() != null && this.getResponseMessage() != '') {
                        alert(this.getResponseMessage());
                    } else {
                        var resCode = this.getResponseCode();
                        if (resCode == '201') {
                            if (confirm('다른 IP로 이미 로그인된 사용자가 있습니다.\n로그아웃시키고 다시 로그인하시겠습니까?')) {
                                doLogin({
                                    invalidate: true
                                });
                            }
                        } else if (resCode == '200') {
                            location.href = "/home";
                        }
                    }
                }, false);
            } else {
                var store = new EVF.Store();
                store.load('/sessionCut', function() {
                    location.href = "/welcome";
                });
            }
        }

      	<%--협력사 공인인증서 로그인
        function doCertLogin() {

            document.formData.userId.value = document.formData.userId.value.replace(/[^0-9]/gi, "");

            toggleSaveUserId();
            document.formData.userId.value = document.formData.userId.value;
            if (document.formData.userId.value == "") {
                alert("사업자번호를 입력하세요.");
                document.formData.userId.focus();
                return;
            }
            $("#verifyCertInfo").empty();
            var ssn = document.formData.userId.value;
            nxTSPKI.verifyVID(ssn, {}, verify_complete_callback);
        }

        function verify_complete_callback(res) {

            var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : window.screenX;
            var dualScreenTop = window.screenTop != undefined ? window.screenTop : window.screenY;

            var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
            var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

            var left = ((width / 2) - (710 / 2)) + dualScreenLeft;
            var top = ((height / 2) - (500 / 2)) + dualScreenTop;

            if (res.code == 0) {
                if (res.data.result == true) {
                    //사업자번호로 로그인(동시에 아이디 체크)
                    var store = new EVF.Store();
                    store.setParameter("userId", $('#companyType').val() + $('#userId').val());
                    store.setParameter("CertLogin", true);
                    store.load('/login', function () {
                        if (this.getResponseMessage() != null && this.getResponseMessage() != '') {
                            alert(this.getResponseMessage());
                        } else {
	                        var resCode = this.getResponseCode();
	                        if (resCode == '201') {// Multi 로그인 안됨
	                            if (confirm('다른 IP로 이미 로그인된 사용자가 있습니다.\n로그아웃시키고 다시 로그인하시겠습니까?')) {
	                                doLogin({
	                                    invalidate: true
	                                });
	                            }
	                        } else if (resCode == '200') {
	                            location.href = "/home";
	                        }
                        }
                    }, false);
                }
            }
        }
		--%>

        function noticeCookieCheck(noticeNum, loginPopupNotice) {

            var blnCookie = cookie.getCookie('div_laypopup' + noticeNum); // 공지사항 팝업ID
            if (!blnCookie) {
                openNotice(noticeNum, loginPopupNotice);
            }
        }

        function openNotice(noticeNum, loginPopupNotice) {
            var url = "/session/viewContents/view";
            var param = {
                realUrl: '/evermp/MY01/screenNotice/view',
                NOTICE_NUM: noticeNum,
                popupFlag: true,
                detailView: true,
                mainYn: 'Y',
                loginPopupNotice: loginPopupNotice
            };
            everPopup.openWindowPopup(url, 800, 600, param, 'NOTICE' + noticeNum);
        }

        function toggleSaveUserId() {
            $.cookie('savedUserId', ($('#id_save_check').prop('checked') ? $('#userId').val() : null));
        }

        function capslockevt(e) {
            userStrokes = true;
            var myKeyCode = 0;
            var myShiftKey = false;
            if (window.event) { // IE
                myKeyCode = e.keyCode;
                myShiftKey = e.shiftKey;
            } else if (e.which) { // netscape ff opera
                myKeyCode = e.which; // myShiftKey=( myKeyCode == 16 ) ? true :
                // false;
                myShiftKey = isshift;
            }
            if ((myKeyCode >= 65 && myKeyCode <= 90) && !myShiftKey) {
                is_capslockon=true;
                show('err_capslock');
                setTimeout("hide('err_capslock')",3000);
            } else if ((myKeyCode >= 97 && myKeyCode <= 122) && myShiftKey) {
                is_capslockon=true;
                show('err_capslock');
                setTimeout("hide('err_capslock')",3000);
            } else {
                is_capslockon=false;
                setTimeout("hide('err_capslock')",1500);
            }
        }

        var isshift = false;
        var userStrokes = false;
        function checkShiftUp(e) {
            if (e.which && e.which == 16) {
                isshift = false;
            }
        }

        function checkShiftDown(e) {
            var down_keyCode=0;
            if (e.which && e.which == 16) {
                isshift = true;
            }
            if (window.event) {
                down_keyCode = e.keyCode;
            } else if (e.which) {
                down_keyCode = e.which;
            }

            if (down_keyCode && down_keyCode == 20) {
                if (!is_capslockon) {
                    is_capslockon=true;
                    show('err_capslock');
                    setTimeout("hide('err_capslock')",1500);
                } else {
                    is_capslockon=false;
                    hide('err_capslock');
                }
            }
        }

        var is_capslockon = false;
        function show(id) {
            $('#'+id).css('display', 'block');
        }

        function hide(id) {
            $('#'+id).css('display', 'none');
        }

        <%--택배사 조회
        function openCourierSearch() {
            var param = {
           		code: '04',	// 택배사코드
           		value: '551619232101'	// 송장번호
            };
            everPopup.CourierPop(param);
        }
        --%>

        function goTms() {
            var url = "/session/viewContents/view";
            var params = {
            	realUrl: '/nosession/FIND01/view'
            };
            everPopup.openWindowPopup(url, 590, 250, params, 'POLIST', true);
        }

        function goRequest(){
            var url = "/session/viewContents/view";
            var param = {
                gateCd : '100',
                realUrl: '/nosession/BS03_012/view'
            };
            everPopup.openWindowPopup(url, 1000, 900, param, 'BUSINESS', true);
        }

    </script>
</head>

<body>

<div class="ds-main">
	<!--header_wrap-->
    <%--
    <c:import url="/mainHtml/header/header.jsp" charEncoding="UTF-8"/>
    --%>
    <!--슬라이드-->
    <div class="contents">
        <div class="inner">
            <div class="cont">
                <div class="visual-text">
                    <div class="text-1">카카오페이증권</div>
                    <div class="text-2">대한민국에 없던 새로운 플랫폼 금융회사</div>
                    <div class="text-3">
                        생활금융 플랫폼과 만나 새로운 금융 투자 문화를 만듭니다.<br/>
                        어려운 금융 문법을 깨고 일상에서 누구나 누릴 수 있는 투자서비스를 고민합니다.<br/><br/>
                        개인금융 고객의 투자자산 관리뿐만 아니라 기업금융을 통한 모험 자본의 공급까지<br/>
                        누구나 안심하고 투자할 수 있는 금융 서비스를 만듭니다.
                    </div>
                </div>
            </div>
            <div class="cont">
                <div class="login">
                	<form id="formData" name="formData" onsubmit="return false;">
	                    <div class="title">회원사 로그인</div>
	                    <div class="inputs">
	                    	<input type="hidden" id="RSAModulus"  value="${RSAModulus}"/>
	                        <input type="hidden" id="RSAExponent" value="${RSAExponent}"/>
	                        <input type="text" id="userId" name="userId" title="아이디" placeholder="아이디를 입력해주세요." tabindex="1"/>
	                        <input type="password" id="password" name="password" title="비밀번호" placeholder="비밀번호를 입력해주세요." tabindex="2"
	                        		onkeypress="capslockevt(event);" onkeyup="checkShiftUp(event);" onkeydown="checkShiftDown(event);"/>
	                        <div class="ly_v2" id="err_capslock" style="display: none;">
			                	<div class="ly_box">
			                    	<p role="alert"><strong>Caps Lock</strong>이 켜져 있습니다.</p></div>
			                   	<span class="sp ly_point"></span>
			                </div>
	                    </div>
	                    <div class="row-btn"><a href="javascript:doLogin();" class="btn-login">로그인</a></div>
	                    <div class="row-check">
	                        <div class="checkbox">
	                            <input type="checkbox" id="id_save_check"/>
	                            <span></span>
	                            <label for="id_save_check">아이디 저장</label>
	                        </div>
	                    </div>
	                    <div class="row-new">
	                        <a href="javascript:doMainHtmlView('06_register', 'sigin_in_01', '1220', '800');" class="btn-new btn-left">회원가입</a>
	                        <a href="javascript:doMainHtmlView('07_search_id_n_pw', 'find_id_pw', '1100', '700');" class="btn-new btn-right">ID/PW 찾기</a>
	                    </div>
	                    <%--
	                    <div class="row-search">
	                        <a href="javascript:goTms();" class="btn-search">발주내역 조회</a>
	                    </div>
	                    --%>
                    </form>
                </div>
                <div class="notice">
                    <div class="list">
                        <div class="title">공지사항</div>
                        <ul>
	                        <c:forEach items="${noticeListMain }" var="C">
	                            <li><a href="javascript:noticeCookieCheck('${C.NOTICE_NUM }', 'loginPopupNotice');"><span class="title">${C.SUBJECT}</span><span class="date">${C.REG_DATE}</span></a></li>
	                        </c:forEach>
                        </ul>
                    </div>
                    <%--
                    <div class="btn-wrap">
                        <a href="https://www.tradesign.net/ra/sonomro" target="TRADESIGN" class="btn-large btn-blue">공동인증센터</a>
                        <a href="javascript:goRequest();" class="btn-large btn-green">협력사 신규거래 요청</a>
                    </div>
                    --%>
                </div>
            </div>
        </div>
    </div>

    <!--footer_wrap-->
    <%--
    <c:import url="/mainHtml/footer/footer.jsp" charEncoding="UTF-8"/>
    --%>
</div>

<style>
    .ly_v2 {
        position: absolute;
        z-index: 10;
        display: block;
        zoom: 1;
    }

    .ly_v2 .ly_box {
        font-size: 11px;
        line-height: 14px;
        position: static;
        margin-top: 8px;
        padding: 9px 9px 7px;
        letter-spacing: -1px;
        color: #777;
        border: solid 1px #d8d1aa;
        background: #fffadc;
    }

    .sp{
        background: url(https://static.nid.naver.com/images/ui/login/pc_sp_login_170424.png) no-repeat;
    }

    .ly_v2 .ly_point {
        position: absolute;
        top: 0;
        left: 8px;
        display: block;
        width: 12px;
        height: 10px;
        background-position: -41px -48px;
    }
</style>

</body>
</html>