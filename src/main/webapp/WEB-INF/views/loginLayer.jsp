<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
	<meta charset="utf-8">
	<title>로그인</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<link href="/css/login_layer.css" rel="stylesheet" type="text/css">
</head>
<body>
	<div class="main">
		<div class="divCon">
			<div class="login">
				<div class="commWidth logoImg">
					<img src="/images/kakao/common/logo.svg" width="100%" height="100%" alt="SONO 로고"/>
				</div>
				<div class="commWidth systemTxt">(주)카카오페이증권</div>
				<form action="login" target="" method="post">
					<input type="hidden" id="RSAModulus" value="${RSAModulus}"/>
					<input type="hidden" id="RSAExponent" value="${RSAExponent}"/>
					<input id="userId" value="${userId}" type="text" placeholder="아이디" class="commWidth input" onkeydown="onEnter();" readonly="readonly">
					<input id="password" type="password" placeholder="비밀번호" class="commWidth input" onkeydown="onEnter();">
					<div class="btnWidth input">
						<div class="btnWidth input loginBtn" onclick="doLogin();">로그인</div>
					</div>
					<div style="text-align:left;height:20px; padding-left: 52px;">
						<div>
							<input id="saveUserId" type="checkbox" class="chkBox" onclick="toggleSaveUserId();">아이디저장
						</div>
					</div>
					<div class="footOut">
						<div class="footer">
							<span class="footer1"></span>
							<div style="height:10px;display:block"></div>
								Copyright &copy; (주)카카오페이증권. All rights reserved.
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</body>
<script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
<script type="text/javascript" src="/js/everuxf/lic/licenseKey.js"></script>

<script type="text/javascript" src="/js/RSA/rsa.js"></script>
<script type="text/javascript" src="/js/RSA/jsbn.js"></script>
<script type="text/javascript" src="/js/RSA/prng4.js"></script>
<script type="text/javascript" src="/js/RSA/rng.js"></script>

<script type="text/javascript">

    $(document.body).ready(function() {
	    if($.cookie('siisUserId') != null) {
	        $('#userId').val($.cookie('siisUserId'));
	        $('#saveUserId').prop('checked', true);
		}
	});

    $(window).keyup(function(e) {
        if(e.keyCode == 27) {
            $('#sendMask', parent.document).remove();
            $('iframe#loginLayer', parent.document).remove();
		}
    });

    function onEnter(e) {
        if(event.keyCode == 13) {
            doLogin();
		}
	}

	function doLogin(param) {
        var rsa = new RSAKey();
        rsa.setPublic($('#RSAModulus').val(),$('#RSAExponent').val());

        var store = new EVF.Store();
        store.setParameter("userId", rsa.encrypt($('#userId').val()));
        store.setParameter("password", rsa.encrypt($('#password').val()));
        store.setParameter("userType", "${param.type}");
        if(param != undefined) {
            store.setParameter('invalidate', param.invalidate);
        }

        store.load('/login', function() {
            if( this.getResponseMessage() != null && this.getResponseMessage() != '' ) {
                alert(this.getResponseMessage());
            } else {

                var resCode = this.getResponseCode();
                if(resCode == '200') {

                    alert('로그인되었습니다.');
                    parent.$('#sendMask').remove();
                    parent.$('#loginLayer').remove();
                    $.cookie('siisUserId', ($('#saveUserId').prop('checked') == true ? $('#userId').val() : null));

				} else if(resCode == '201') {

                    if(confirm('다른 IP로 이미 로그인된 사용자가 있습니다.\n로그아웃시키고 다시 로그인하시겠습니까?')) {
                        doLogin({
                            invalidate: true
                        });
                    }
                }
            }
        }, false);
	}

	function toggleSaveUserId() {
        $.cookie('siisUserId', ($('#saveUserId').prop('checked') == true ? $('#userId').val() : null));
	}

</script>
</html>