<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/SMY1/SMY101/";

        function init() {
            if(EVF.V("USER_ID") != "") {
                EVF.C('Idcheck').setDisabled(true);
                EVF.C("USER_ID").setReadOnly(true);
                EVF.C("PASSWORD").setRequired(false);
                EVF.C("PASSWORD_CHECK").setRequired(false);
            }else{
            	EVF.V("SMS_FLAG","1");
            	EVF.V("MAIL_FLAG","1");
                //EVF.V("BLOCK_FLAG","0");
            }

        }

        function doSave() {

            var btnData = this.getData();
            var btnMsg = (btnData == "I" ? "${msg.M0011}" : "${msg.M0012}");

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if(EVF.V("ID_CHECK")!="Y"){
                return alert("${SMY1_051_007}");
            }

            /*
            if(EVF.V("BLOCK_FLAG")=="Y"){
                if(EVF.V("BLOCK_REASON")==""){
                    EVF.C("BLOCK_REASON").setFocus();
                    return alert("${SMY1_051_001}");
                }
            }
            */

            if(!confirm(btnMsg)) { return; }

                store.load(baseUrl + 'smy1051_doSave', function () {
                    alert(this.getResponseMessage());
                        opener.doSearch();

                        var param = {
                            'USER_ID': EVF.V("USER_ID"),
                            'detailView': false,
                            'popupFlag': true
                        };
                        window.close();
                        //window.location.href = '/evermp/SMY1/SMY101/SMY1_051/view.so?' + $.param(param);

                });

        }

        //id중복체크크
       function doIdcheck() {
    	   EVF.V("ID_CHECK","");
        	if(EVF.C("USER_ID").getValue()==""){
               EVF.C('USER_ID').setFocus();
               alert(everString.getMessage("${msg.M0109}", "${form_USER_ID_N}"));
           }else{
               var store = new EVF.Store();
               store.load('/evermp/BS03/BS0302/bs01002_doCheckUserId', function() {
                   if(this.getParameter("POSSIBLE_FLAG") == "N") {
                       EVF.V("ID_CHECK","");
                       return alert("${SMY1_051_006}");
                   }else{
                       EVF.V("ID_CHECK","Y");
                       alert("${SMY1_051_001}");

                       //EVF.C('Idcheck').setDisabled(true);
                       //EVF.C('USER_ID').setReadOnly(true);
                   }
               }, false);
           }
        }
        
       function onChangeID() {
        	  EVF.V("ID_CHECK","");
        	  IdcheckId();
        }

       function IdcheckId(){

       	//var regExp = /^[A-Za-z0-9_]{4,16}$/;
       	var regExp = /^[A-Za-z0-9_-]{3,16}$/;
           if (!EVF.V("USER_ID").match(regExp)){
               alert("${msg.ID_INVALID}");

               EVF.V("USER_ID","");
           }
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
                EVF.C("ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('ADDR_2').setFocus();
            }
        }


        function ModCheckPW(){
            var checkType = this.getData();
            if(checkType == "1") {
                EVF.V("PASSWORD","");
                EVF.V("CHANGE_PW","Y");
            }
            if(checkType == "2") {
                EVF.V("PASSWORD_CHECK","");
                EVF.V("CHANGE_PW","Y");
            }
        }

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
            }else{
                if(EVF.V("PASSWORD")!=""&&EVF.V("PASSWORD_CHECK")!=""){
                    if(EVF.V("PASSWORD")!=EVF.V("PASSWORD_CHECK")){
                        EVF.C("PASSWORD_CHECK").setValue("");
                        EVF.C("PASSWORD_CHECK").setFocus();
                        return alert("${SMY1_051_008}");
                    }
                }
            }
        }
        function chkPwd(str){
            var SamePass_0 = 0;
            var SamePass_1 = 0;
            var SamePass_2 = 0;

            var reg_pwd = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[a-zA-Z]).*$/;                     //영문숫자
            var reg_pwd2 = /^.*(?=.{6,12})(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;              //영문특수
            var reg_pwd3 = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[!@#$%^&+=]).*$/;                 //숫자특수
            var reg_pwd4 = /^.*(?=^.{6,12}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;    //영문숫자특수문자
            if(reg_pwd.test(str) || reg_pwd2.test(str)|| reg_pwd3.test(str)|| reg_pwd4.test(str)){

            }else{
                alert("${SMY1_051_021}");
                return false;
            }
            if(str.length >20){
                alert("${SMY1_051_021}");
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

                if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == 1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == 1) {
                    SamePass_1 = SamePass_1 + 1
                }

                if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == -1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == -1) {
                    SamePass_2 = SamePass_2 + 1
                }
            }
            if(SamePass_0 > 0) {
                alert("${SMY1_051_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${SMY1_051_023}");
                return false;
            }

            return true;
        }

        function checkTelNo() {

            var checkType = this.getData();
            if(checkType == "FAX_NUM") {
                if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("FAX_NUM").setValue("");
                    EVF.C('FAX_NUM').setFocus();
                }
            }
            if(checkType == "TEL_NUM") {
                if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("TEL_NUM").setValue("");
                    EVF.C('TEL_NUM').setFocus();
                }
            }
        }

        function checkCellNo() {
            var CellNum = EVF.V("CELL_NUM");
            var rgEx = /(01[016789])[-](\d{4}|\d{3})[-]\d{4}$/g;
            var chkFlg = rgEx.test(CellNum);
            if(!chkFlg){
                EVF.C("CELL_NUM").setValue("");
                EVF.C('CELL_NUM').setFocus();
                return alert("${msg.M0128}");
            }
        }

        function checkEmail(){

            if(!everString.isValidEmail(EVF.V("EMAIL"))) {
                alert("${msg.EMAIL_INVALID}");

                EVF.V("EMAIL","");
            }
        }

        //첨부파일갯수제어-------------------------
        function onFileAdd() {
            if(EVF.C('AGREE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${BS03_002_001}");
            }
        }

        function doTempletDown() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BS03_002A');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);
            }, false);
        }

    </script>
    <e:window id="SMY1_051" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

            <e:buttonBar id="buttonTopBottom" align="right" width="100%">
                <c:if test="${param.USER_ID == '' }">
                    <e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${param.havePermission ? false : true}" onClick="doSave" data="I" />
                </c:if>
                <c:if test="${param.USER_ID != null && param.USER_ID != '' }">
                    <e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }"  visible="${param.havePermission ? false : true}"  onClick="doSave" data="U" />
                </c:if>
            </e:buttonBar>
        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:inputHidden id="USER_TYPE" name="USER_TYPE" value="${ses.userType}" />

            <e:row>
                <e:label for="COMPANY_CD" title="${form_COMPANY_CD_N}"></e:label>
                <e:field>
                    <e:inputText id="COMPANY_CD" style='ime-mode:inactive' name="COMPANY_CD" value="${ses.companyCd}" width="100%" maxLength="${form_COMPANY_CD_M}" disabled="${form_COMPANY_CD_D}" readOnly="true" required="${form_COMPANY_CD_R}" />
                </e:field>
                <e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}"></e:label>
                <e:field>
                    <e:inputText id="COMPANY_NM" style='ime-mode:inactive' name="COMPANY_NM" value="${ses.companyNm}" width="100%" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="true" required="${form_COMPANY_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="USER_ID" title="${form_USER_ID_N}"/>
                <e:field>
                    <e:inputText id="USER_ID" name="USER_ID" value="${formData.USER_ID }" width="70%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" onChange="onChangeID" />
                    &nbsp;<e:button id="Idcheck" name="Idcheck" label="${Idcheck_N}" onClick="doIdcheck" disabled="${Idcheck_D}" visible="${Idcheck_V}" />
                    <e:inputHidden id="ID_CHECK" name="ID_CHECK" value="${formData.ID_CHECK }" />
                    <e:inputHidden id="ORI_USER_ID" name="ORI_USER_ID" value="${formData.USER_ID }" />

                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="USER_NM" name="USER_NM" value="${formData.USER_NM }" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PASSWORD" title="${form_PASSWORD_N}"></e:label>
                <e:field>
                    <e:inputPassword id="PASSWORD" style='ime-mode:inactive' name="PASSWORD" value="${formData.PASSWORD}"  width="100%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}" onChange="CheckCall" data="1" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                    <e:inputHidden id="CHANGE_PW" name="CHANGE_PW" value="" />
                </e:field>
                <e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N}"></e:label>
                <e:field>
                    <e:inputPassword id="PASSWORD_CHECK" style='ime-mode:inactive' name="PASSWORD_CHECK" value="${formData.PASSWORD_CHECK}"  width="100%" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" onChange="CheckCall" data="2" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="EMPLOYEE_NO" title="${form_EMPLOYEE_NO_N}"/>
                <e:field>
                    <e:inputText id="EMPLOYEE_NO" name="EMPLOYEE_NO" value="${formData.EMPLOYEE_NO}" width="${form_EMPLOYEE_NO_W}" maxLength="${form_EMPLOYEE_NO_M}" disabled="${form_EMPLOYEE_NO_D}" readOnly="${form_EMPLOYEE_NO_RO}" required="${form_EMPLOYEE_NO_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="MNG_YN" title="${form_MNG_YN_N}"/>
                <e:field>
                    <e:select id="MNG_YN" name="MNG_YN" value="${formData.MNG_YN}" options="${mngYnOptions}" width="${form_MNG_YN_W}" disabled="${form_MNG_YN_D}" readOnly="${form_MNG_YN_RO}" required="${form_MNG_YN_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="POSITION_NM" title="${form_POSITION_NM_N}"/>
                <e:field>
                    <e:inputText id="POSITION_NM" name="POSITION_NM" value="${formData.POSITION_NM }" width="${form_POSITION_NM_W}" maxLength="${form_POSITION_NM_M}" disabled="${form_POSITION_NM_D}" readOnly="${form_POSITION_NM_RO}" required="${form_POSITION_NM_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="DUTY_NM" title="${form_DUTY_NM_N}" />
                <e:field>
                    <e:inputText id="DUTY_NM" name="DUTY_NM" value="${formData.DUTY_NM }" width="${form_DUTY_NM_W}" maxLength="${form_DUTY_NM_M}" disabled="${form_DUTY_NM_D}" readOnly="${form_DUTY_NM_RO}" required="${form_DUTY_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="TEL_NUM" name="TEL_NUM"  placeHolder="${SMY1_051_INPUT_T2 }" value="${formData.TEL_NUM}" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" onChange="checkTelNo" data="TEL_NUM" />
                </e:field>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="FAX_NUM" name="FAX_NUM" placeHolder="${SMY1_051_INPUT_T2 }" value="${formData.FAX_NUM}" width="100%" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" onChange="checkTelNo" data="FAX_NUM" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="CELL_NUM" name="CELL_NUM"  placeHolder="${SMY1_051_INPUT_T2 }" value="${formData.CELL_NUM}" width="100%" maxLength="${form_CELL_NUM_M}" disabled="${form_CELL_NUM_D}" readOnly="${form_CELL_NUM_RO}" required="${form_CELL_NUM_R}" onChange="checkCellNo" data="CELL_NUM" />
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"></e:label>
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" style='ime-mode:inactive' value="${formData.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" onChange="checkEmail"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SMS_FLAG" title="${form_SMS_FLAG_N}" />
                <e:field>
                    <e:select id="SMS_FLAG" name="SMS_FLAG" value="${formData.SMS_FLAG }" options="${smsFlagOptions }" width="${form_SMS_FLAG_W}" disabled="${form_SMS_FLAG_D}" readOnly="${form_SMS_FLAG_RO}" required="${form_SMS_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="MAIL_FLAG" title="${form_MAIL_FLAG_N}" />
                <e:field>
                    <e:select id="MAIL_FLAG" name="MAIL_FLAG" value="${formData.MAIL_FLAG }" options="${smsFlagOptions }" width="${form_MAIL_FLAG_W}" disabled="${form_MAIL_FLAG_D}" readOnly="${form_MAIL_FLAG_RO}" required="${form_MAIL_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>            
            <e:row>
                <e:label for="VNGL_ROLE" title="${form_VNGL_ROLE_N}"/>
                <e:field colSpan="3">
                    <e:checkGroup id="VNGL_ROLE" name="VNGL_ROLE" value="${formData.VNGL_ROLE}" width="100%" disabled="${form_VNGL_ROLE_D}" readOnly="${form_VNGL_ROLE_RO}" required="${form_VNGL_ROLE_R}">
                        <c:forEach var="role" items="${RoleList}" varStatus="vs">
                            <e:check id="VNGL_ROLE_${role.value}" name="VNGL_ROLE_${role.value}" value="${role.value}" label="${role.text}" disabled="${form_VNGL_ROLE_D}" readOnly="${form_VNGL_ROLE_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
            </e:row>
            <%--
            <e:row>
                <e:label for="BLOCK_FLAG" title="${form_BLOCK_FLAG_N}"/>
                <e:field>
                    <e:select id="BLOCK_FLAG" name="BLOCK_FLAG" value="${formData.BLOCK_FLAG}" options="${blockFlagOptions}" width="${form_BLOCK_FLAG_W}" disabled="${form_BLOCK_FLAG_D}" readOnly="${form_BLOCK_FLAG_RO}" required="${form_BLOCK_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="BLOCK_REASON" title="${form_BLOCK_REASON_N}" />
                <e:field>
                    <e:inputText id="BLOCK_REASON" name="BLOCK_REASON" value="${formData.BLOCK_REASON}" width="${form_BLOCK_REASON_W}" maxLength="${form_BLOCK_REASON_M}" disabled="${form_BLOCK_REASON_D}" readOnly="${form_BLOCK_REASON_RO}" required="${form_BLOCK_REASON_R}" />
                </e:field>
            </e:row>
            --%>
<%--             <e:row>
                <e:label for="AGREE_ATT_FILE_NUM" title="${form_AGREE_ATT_FILE_NUM_N}" />
                <e:field colSpan="2">
                    <div style="width: 100%; height: 50px;">
                        <e:fileManager id="AGREE_ATT_FILE_NUM" name="AGREE_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.AGREE_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="0px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_AGREE_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                <e:field>
                    <e:button id="TempletDown" name="TempletDown" label="${TempletDown_N}" onClick="doTempletDown" disabled="${TempletDown_D}" visible="${TempletDown_V}" />
                </e:field>
            </e:row> --%>

        </e:searchPanel>

    </e:window>
</e:ui>