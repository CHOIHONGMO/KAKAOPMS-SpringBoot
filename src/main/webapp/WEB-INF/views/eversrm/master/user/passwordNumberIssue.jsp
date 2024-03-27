<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    	var baseUrl = "/eversrm/master/user/passwordNumberIssue/";

    	function init() {
        	EVF.C('GATE_CD').setValue('${param.GATE_CD}');
        	EVF.C('USER_ID').setValue('${param.USER_ID}');
            EVF.C('USER_TYPE').setValue('${param.USER_TYPE}');
            //EVF.C('PASSWORD').setValue('${param.PASSWORD}') ;
        	//EVF.C('PASSWORD_CHECK').setValue('${param.PASSWORD_CHECK}') ;
        }
        function doIssue() {
			var pass = passChk = ''
				, gateCd = EVF.C('GATE_CD').getValue()
				, userId = EVF.C('USER_ID').getValue();
			
			<%--if (checkPass() == -1) { return; }			--%>
			<%--if (checkPass() == -2) { alert("${BSB_070_0001}"); return; }			--%>
			if (!confirm("${msg.M0021}")) { return; }
		
			pass = EVF.C('PASSWORD').getValue();
			passChk = EVF.C('PASSWORD_CHECK').getValue();
			
			if ( !/\S/.test(pass) 
				|| !/\S/.test(passChk)
				|| !/\S/.test(gateCd)
				|| !/\S/.test(userId) 
			) {
            	alert("${msg.M0054}");
            	return;
        	}

            var store = new EVF.Store();

            if(EVF.V("USER_TYPE")=="C"){
                //운영사/구매사 : 사용자테이블 비밀번호업데이트
                store.load(baseUrl + "doSave", function() {
                    alert(this.getResponseMessage());
                    opener.${param.onClose}();
                    window.close();
                });

			}else{
                //협력사 : 협력사_사용자테이블 비밀번호업데이트
                store.load(baseUrl + "doSave_CVUR", function() {
                    alert(this.getResponseMessage());
                    opener.${param.onClose}();
                    window.close();
                });
			}


        }
        function checkPass() {
			var pass = EVF.C('PASSWORD').getValue().replace(/^\s+/,'').replace(/\s+$/,'')
				, passc = EVF.C('PASSWORD_CHECK').getValue().replace(/^\s+/,'').replace(/\s+$/,'');
			
			EVF.C('PASSWORD').setValue(pass);
			EVF.C('PASSWORD_CHECK').setValue(passc);
			
			if ( !/\S/.test(pass) || !/\S/.test(passc) ) { return -2; }
			if ( (!/\S/.test(pass) || !/\S/.test(passc)) || (pass != passc)  ) { alert("${msg.M0028}"); return -1; }

			return 0;
        }


        //비밀번호체크
        function CheckCall(){
            var str;
            if(this.data=="1"){
                str = EVF.V("PASSWORD");
            }else{
                str = EVF.V("PASSWORD_CHECK");
            }
            if(!chkPwd(str)){
                EVF.C("PASSWORD").setValue("");
                EVF.C("PASSWORD_CHECK").setValue("");
                $('#PASSWORD').focus();
            }
        }
        //비밀번호체크
        function chkPwd(str){
            var SamePass_0 = 0; //동일문자 카운트
            var SamePass_1 = 0; //연속성(+) 카운드
            var SamePass_2 = 0; //연속성(-) 카운드

            if(str.length >20){
                return false;
            }
			var reg_pwd = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[a-zA-Z]).*$/;                     //영문숫자
			var reg_pwd2 = /^.*(?=.{6,12})(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;              //영문특수
			var reg_pwd3 = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[!@#$%^&+=]).*$/;                 //숫자특수
			var reg_pwd4 = /^.*(?=^.{6,12}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;    //영문숫자특수문자
            if(reg_pwd.test(str) || reg_pwd2.test(str)|| reg_pwd3.test(str)|| reg_pwd4.test(str)){

            }else{
                alert("${msg.M0150 }");
                return false;
            }

			//동일문자 카운트
			for(var i=0; i < str.length; i++) {
				var chr_pass_0 = str.charAt(i);
				var chr_pass_1 = str.charAt(i+1);
				var chr_pass_2 = str.charAt(i+2);
				if(chr_pass_0 == chr_pass_1 && chr_pass_1 == chr_pass_2) {
					SamePass_0 = SamePass_0 + 1
				}

                var chr_pass_2 = str.charAt(i+2);
                //연속성(+) 카운드
                if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == 1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == 1) {
                    SamePass_1 = SamePass_1 + 1
                }
                //연속성(-) 카운드
                if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == -1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == -1) {
                    SamePass_2 = SamePass_2 + 1
                }
            }
            if(SamePass_0 > 0) {
                alert("${msg.M0151 }");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${msg.M0152 }");
                return false;
            }

            return true;
        }
    </script>
	
	<e:window id="BSB_070" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
		<e:buttonBar id="BSB_070_Button" width="100%" align="right">
			<e:button label='${doIssue_N }' id='doIssue' onClick='doIssue' disabled='${doIssue_D }' visible='${doIssue_V }' />
		</e:buttonBar>
	
		<e:searchPanel id="BSB_070_Panel" title="${fullScreenName}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
			<e:row>
				<e:label for="PASSWORD" title="${form_PASSWORD_N }"></e:label>
				<e:field>
					<e:inputPassword id="PASSWORD" name="PASSWORD" value="${form.PASSWORD}" width="100%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}"  onChange="CheckCall" data="1" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
				</e:field>
				
				<e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N }"></e:label>
				<e:field>
					<e:inputPassword id="PASSWORD_CHECK" name="PASSWORD_CHECK" value="${form.PASSWORD_CHECK}" width="100%" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리" />
					<e:inputHidden id="USER_ID" name="USER_ID" visible="false" width="0"/>
                    <e:inputHidden id="GATE_CD" name="GATE_CD" visible="false" width="0"/>
					<e:inputHidden id="USER_TYPE" name="USER_TYPE" visible="false" width="0" onChange="CheckCall" data="2"/>
				</e:field>
			</e:row>			
		</e:searchPanel>
	</e:window>
</e:ui>                                                                             	