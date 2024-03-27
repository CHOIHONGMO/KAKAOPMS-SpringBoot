<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/SMY1/SMY101/";
        var userType = '${ses.userType}';
        var clickRowId;

        function init() {
        }

        function doSave() {
        	//필수값 공백체크
        	if(!trimReq()) { return; }
            var presentPass = EVF.C("P_PASSWORD").getValue();
            var newPassCheck1 = EVF.C("PASSWORD_CHECK1").getValue();
            var newPassCheck2 = EVF.C("PASSWORD_CHECK2").getValue();

            if(EVF.isNotEmpty(presentPass)) {
                if (newPassCheck1.trim() == '' || newPassCheck2.trim() == '') {
                    pwValid();
                    return alert("${SMY1_040_003}");
                }

                if(newPassCheck1 != newPassCheck2) {
                    pwValid();
                    return alert('${SMY1_040_004}');
                }
            }

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            if (!confirm("${msg.M0021}")) return;
            store.load(baseUrl+'smy1040_saveUser', function () {
                alert(this.getResponseMessage());
                window.close();
            });
        }



        function doClose() {
            //new EVF.ModalWindow().close(null);
            window.close();
        }

        function pwValid() {
            EVF.C("PASSWORD_CHECK1").setValue("");
            EVF.C("PASSWORD_CHECK2").setValue("");
            $('#PASSWORD_CHECK1').focus();
        }

        function CheckCall(){
            var str;
            if(this.data=="1"){
                str = EVF.V("PASSWORD_CHECK1");
            }else{
                str = EVF.V("PASSWORD_CHECK2");
            }
            if(!chkPwd(str)){
                pwValid();
            }
        }

        <%-- 비밀번호체크 --%>
        function chkPwd(str){
            var SamePass_0 = 0; //동일문자 카운트
            var SamePass_1 = 0; //연속성(+) 카운드
            var SamePass_2 = 0; //연속성(-) 카운드

            var reg_pwd = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[a-zA-Z]).*$/;                     //영문숫자
            var reg_pwd2 = /^.*(?=.{6,12})(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;              //영문특수
            var reg_pwd3 = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[!@#$%^&+=]).*$/;                 //숫자특수
            var reg_pwd4 = /^.*(?=^.{6,12}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;    //영문숫자특수문자
            if(reg_pwd.test(str) || reg_pwd2.test(str)|| reg_pwd3.test(str)|| reg_pwd4.test(str)){

            }else{
                alert("${SMY1_040_021}");
                return false;
            }
            if(str.length >20){
                alert("${SMY1_040_021}");
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
                alert("${SMY1_040_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${SMY1_040_023}");
                return false;
            }

            <%-- 기존비밀번호와 동일하면안됨. --%>
            if(str==EVF.V("P_PASSWORD")){
                alert("${msg.M0153 }");
                return false;
            }
            return true;
        }
        //필수값 공백체크
		function trimReq(){
			let flag=true;
			var htmlData=$(".e-required-badge")
			for(var a=0; a<htmlData.length; a++){
				objectHtml =$(htmlData[a]);
				if(objectHtml.css('visibility') =='visible'){
					let titleVal = objectHtml.prev()[0].innerHTML
					let tdHtml   = objectHtml.closest('td');
					if(tdHtml.next().find('input').val().trim().length==0){
						alert(titleVal+" "+"${SMY1_040_029}");
						flag=false;
						break;
					}

				}
			}
			for(var a=0; a<htmlData.length; a++){
				objectHtml =$(htmlData[a]);
				if(objectHtml.css('visibility') =='visible'){
					let titleVal = objectHtml.prev()[0].innerHTML
					let tdHtml   = objectHtml.closest('td');
					if(tdHtml.next().find('input').val().trim().length==0){
						formUtil.animate(tdHtml.next().find('input')[0].id,'form')
					}
				}
			}
			return flag;
		}

    </script>
    <e:window id="SMY1_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:title title="${SMY1_040_TITLE1}" depth="1" />
        <e:searchPanel id="sp" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2">
            <e:row>
                <e:label for="USER_ID" title="${form_USER_ID_N}"/>
                <e:field>
                    <e:inputText id='USER_ID' name="USER_ID" label='${form_USER_ID_N }' value="${form.USER_ID}" width='100%' maxLength='${form_USER_ID_M }' required='${form_USER_ID_R }' readOnly='${form_USER_ID_RO }' disabled='${form_USER_ID_D }' visible='${form_USER_ID_V }'/>
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:inputText id='USER_NM' name="USER_NM" label='${form_USER_NM_N }' value="${form.USER_NM}" width='100%' maxLength='${form_USER_NM_M }' required='${form_USER_NM_R }' readOnly='${form_USER_NM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_USER_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id='TEL_NUM' name="TEL_NUM" label='${form_TEL_NUM_N }' value="${form.TEL_NUM}" width='100%' maxLength='${form_TEL_NUM_M }' required='${form_TEL_NUM_R }' readOnly='${form_TEL_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_TEL_NUM_V }'/>
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id='EMAIL' name="EMAIL" label='${form_EMAIL_N }' value="${form.EMAIL}" width='100%' maxLength='${form_EMAIL_M }' required='${form_EMAIL_R }' readOnly='${form_EMAIL_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_EMAIL_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"/>
                <e:field>
                    <e:inputText id='FAX_NUM' name="FAX_NUM" label='${form_FAX_NUM_N }' value="${form.FAX_NUM}" width='100%' maxLength='${form_FAX_NUM_M }' required='${form_FAX_NUM_R }' readOnly='${form_FAX_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_FAX_NUM_V }'/>
                </e:field>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"/>
                <e:field>
                    <e:inputText id='CELL_NUM' name="CELL_NUM" label='${form_CELL_NUM_N }' value="${form.CELL_NUM}" width='100%' maxLength='${form_CELL_NUM_M }' required='${form_CELL_NUM_R }' readOnly='${form_CELL_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_CELL_NUM_V }'/>
                </e:field>


                <e:inputHidden id='LANG_CD' name="LANG_CD" value="${form.LANG_CD}"/>
                <e:inputHidden id='COUNTRY_CD' name="COUNTRY_CD" value="${form.COUNTRY_CD}"/>
                <e:inputHidden id='GMT_CD' name="GMT_CD" value="${form.GMT_CD}"/>
                <e:inputHidden id='COMPANY_CD' name="COMPANY_CD" value="${form.COMPANY_CD}"/>
                <e:inputHidden id='PLANT_CD' name="PLANT_CD" value="${form.PLANT_CD}"/>
            </e:row>
            <e:row>
                <e:label for="POSITION_NM" title="${form_POSITION_NM_N}"/>
                <e:field>
                    <e:inputText id='POSITION_NM' name="POSITION_NM" label='${form_POSITION_NM_N }' value="${form.POSITION_NM}" width='100%' maxLength='${form_POSITION_NM_M }' required='${form_POSITION_NM_R }' readOnly='${form_POSITION_NM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_POSITION_NM_V }'/>
                </e:field>
                <e:label for="DUTY_NM" title="${form_DUTY_NM_N}"/>
                <e:field>
                    <e:inputText id='DUTY_NM' name="DUTY_NM" label='${form_DUTY_NM_N }' value="${form.DUTY_NM}" width='100%' maxLength='${form_DUTY_NM_M }' required='${form_DUTY_NM_R }' readOnly='${form_DUTY_NM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_DUTY_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SMS_FLAG" title="${form_SMS_FLAG_N}"/>
                <e:field>
                    <e:select id="SMS_FLAG" name="SMS_FLAG" value="${form.SMS_FLAG}" options="${smsFlagOptions}" width="${form_SMS_FLAG_W}" disabled="${form_SMS_FLAG_D}" readOnly="${form_SMS_FLAG_RO}" required="${form_SMS_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                </e:field>
                <e:label for="MAIL_FLAG" title="${form_MAIL_FLAG_N}"/>
                <e:field>
                    <e:select id="MAIL_FLAG" name="MAIL_FLAG" value="${form.MAIL_FLAG}" options="${mailFlagOptions}" width="${form_MAIL_FLAG_W}" disabled="${form_MAIL_FLAG_D}" readOnly="${form_MAIL_FLAG_RO}" required="${form_MAIL_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                </e:field>
            </e:row>
        </e:searchPanel>
            <e:select id='USER_DATE_FORMAT_CD' name="USER_DATE_FORMAT_CD" value="${form.USER_DATE_FORMAT_CD}"  options="${userDateFormat}" label='${form_USER_DATE_FORMAT_CD_N }' width='0' required='${form_USER_DATE_FORMAT_CD_R }' readOnly='${form_USER_DATE_FORMAT_CD_RO }' disabled='${form_USER_DATE_FORMAT_CD_D }' visible='${form_USER_DATE_FORMAT_CD_V }' placeHolder='${placeHolder }'>
            </e:select>
            <e:select id='USER_NUMBER_FORMAT_CD' name="USER_NUMBER_FORMAT_CD" value="${form.USER_NUMBER_FORMAT_CD}" options="${numCd}" label='${form_USER_NUMBER_FORMAT_CD_N }' width='0' required='${form_USER_NUMBER_FORMAT_CD_R }' readOnly='${form_USER_NUMBER_FORMAT_CD_RO }' disabled='${form_USER_NUMBER_FORMAT_CD_D }' visible='${form_USER_NUMBER_FORMAT_CD_V }' placeHolder='${placeHolder }'>
            </e:select>

        <e:title title="${SMY1_040_TITLE2}" depth="1" />
        <e:searchPanel id="sp2" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2">
            <e:row>
                <e:label for="P_PASSWORD" title="${form_P_PASSWORD_N}"/>
                <e:field colSpan="3">
                    <e:inputPassword id='P_PASSWORD' name="P_PASSWORD" label='${form_P_PASSWORD_N }' width='100%' required='${form_P_PASSWORD_R }' readOnly='${form_P_PASSWORD_RO }' disabled='${form_P_PASSWORD_D }' visible='${form_P_PASSWORD_V }' maxLength="${form_P_PASSWORD_M}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PASSWORD_CHECK1" title="${form_PASSWORD_CHECK1_N}"/>
                <e:field>
                    <e:inputPassword id='PASSWORD_CHECK1' name="PASSWORD_CHECK1" label='${form_PASSWORD_CHECK1_N }' width='100%' required='${form_PASSWORD_CHECK1_R }' readOnly='${form_PASSWORD_CHECK1_RO }' disabled='${form_PASSWORD_CHECK1_D }' visible='${form_PASSWORD_CHECK1_V }' maxLength="${form_PASSWORD_CHECK1_M}" onChange="CheckCall" data="1" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                </e:field>
                <e:label for="PASSWORD_CHECK2" title="${form_PASSWORD_CHECK2_N}"/>
                <e:field>
                    <e:inputPassword id='PASSWORD_CHECK2' name="PASSWORD_CHECK2" label='${form_PASSWORD_CHECK2_N }' width='100%' required='${form_PASSWORD_CHECK2_R }' readOnly='${form_PASSWORD_CHECK2_RO }' disabled='${form_PASSWORD_CHECK2_D }' visible='${form_PASSWORD_CHECK2_V }' maxLength="${form_PASSWORD_CHECK2_M}" onChange="CheckCall" data="2" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar width="100%" align="right">
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }'/>
        </e:buttonBar>

    </e:window>
</e:ui>
