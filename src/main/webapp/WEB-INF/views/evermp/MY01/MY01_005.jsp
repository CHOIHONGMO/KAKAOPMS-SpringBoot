<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/MY01/";
        var userType = '${ses.userType}';
        var clickRowId;

        function init() {
        	
         	// DGNS I/F 고객사인 경우 조직정보는 수정할 수 없도록 함
            if( EVF.V("IF_USER_FLAG") == '0' ) {
            	EVF.C("DIVISION_NM").setDisabled(true);
            	EVF.C("DEPT_NM").setDisabled(true);
            	EVF.C("PART_NM").setDisabled(true);
            	EVF.C("USER_NM").setReadOnly(true);
            }
            chgCustCd();
        }

        function doSave() {

            var presentPass = EVF.C("P_PASSWORD").getValue();
            var newPassCheck1 = EVF.C("PASSWORD_CHECK1").getValue();
            var newPassCheck2 = EVF.C("PASSWORD_CHECK2").getValue();

            if(EVF.isNotEmpty(presentPass)) {
                if (newPassCheck1.trim() == '' || newPassCheck2.trim() == '') {
                    pwValid();
                    return alert("${MY01_005_003}");
                }

                if(newPassCheck1 != newPassCheck2) {
                    pwValid();
                    return alert('${MY01_005_004}');
                }
            }

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            if (!confirm("${msg.M0021}")) return;
            store.load(baseUrl+'my01005_saveUser', function () {
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
        	//return;
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
                alert("${MY01_005_021}");
                return false;
            }
            if(str.length >20){
                alert("${MY01_005_021}");
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
                alert("${MY01_005_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${MY01_005_023}");
                return false;
            }

            <%-- 기존비밀번호와 동일하면안됨. --%>
            if(str==EVF.V("P_PASSWORD")){
                alert("${msg.M0153 }");
                return false;
            }
            return true;
        }


        function doUserSearch() {

            var param = {
                callBackFunction: "selectCustUserId",
                custCd: '${ses.companyCd}'
            };
            if('${ses.userType}' == 'B'){
                everPopup.openCommonPopup(param, "SP0083");
            }else{
                everPopup.openCommonPopup(param, "SP0011");
            }
        }

        function selectCustUserId(data) {
            EVF.C("CHIEF_USER_ID").setValue(data.USER_ID);
            EVF.C("CHIEF_USER_NM").setValue(data.USER_NM);
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

        function doSearchDivision() {
        	var param = {
                    callBackFunction: "setDivision",
                    custCd: '${ses.companyCd}',
                   	plantCd: EVF.V("PLANT_CD")
                };
            everPopup.openCommonPopup(param, "SP0020");
	    }

	    function setDivision(data) {
	        EVF.C("DIVISION_CD").setValue(data.DIVISION_CD);
	        EVF.C("DIVISION_NM").setValue(data.DIVISION_NM);
	    }

	    function doSearchDept() {
        	var param = {
                    callBackFunction: "setDept",
                    custCd: '${ses.companyCd}',
                   	plantCd: EVF.V("PLANT_CD"),
                   	divisionCd: EVF.V("DIVISION_CD")
                };
            everPopup.openCommonPopup(param, "SP0071");
	    }

	    function setDept(data) {
	        EVF.C("DEPT_CD").setValue(data.DEPT_CD);
	        EVF.C("DEPT_NM").setValue(data.DEPT_NM);
	    }

	    function doSearchPart() {
        	var param = {
                    callBackFunction: "setPart",
                    custCd: '${ses.companyCd}',
                    plantCd: EVF.V("PLANT_CD"),
                   	divisionCd: EVF.V("DIVISION_CD"),
                   	deptCd: EVF.V("DEPT_CD")
                };
            everPopup.openCommonPopup(param, "SP0084");
	    }

	    function setPart(data) {
	        EVF.C("PART_CD").setValue(data.PART_CD);
	        EVF.C("PART_NM").setValue(data.PART_NM);
	    }

      	//회사별 부서찾기 팝업
        function deptCdSearch_IC() {

                var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
                var param = {
                    callBackFunction: "selectDept_IC",
                    'AllSelectYN': false,
                    'detailView': false,
                    'multiYN': false,
                    'ModalPopup': true,
                    'custCd' : EVF.V("COMPANY_CD"),
                    'custNm' : EVF.V("COMPANY_NM"),
                    'PLANT_CD' : EVF.V("PLANT_CD")
                };
                everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
        }

        function selectDept_IC(dataJsonArray) {
            data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function csdmCdSearch() {

                var param = {
                    callBackFunction: "setCsdmCdSearch",
                    CUST_CD: EVF.V("COMPANY_CD"),
                    detailView : false
                };
                everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
        }

        function setCsdmCdSearch(data) {
        	EVF.C("CSDM_SEQ").setValue(data.CSDM_SEQ);
        	EVF.C("DELY_NM").setValue(data.DELY_NM);
        	EVF.C("DELY_RECIPIENT_NM").setValue(data.HIDDEN_DELY_RECIPIENT_NM);
        	EVF.C("DELY_ADDR").setValue(data.DELY_ADDR);
        	EVF.C("DELY_RECIPIENT_TEL_NUM").setValue(data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
        	EVF.C("DELY_RECIPIENT_FAX_NUM").setValue(data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
        	EVF.C("DELY_RECIPIENT_CELL_NUM").setValue(data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
        	EVF.C("DELY_RECIPIENT_EMAIL").setValue(data.HIDDEN_DELY_RECIPIENT_EMAIL);
        }

        function cublCdSearch() {

                var param = {
                    callBackFunction: "setCublCdSearch",
                    CUST_CD: EVF.V("COMPANY_CD"),
                    detailView : false
                };
                everPopup.openPopupByScreenId("MY01_008", 900, 600, param);
        }

        function setCublCdSearch(data) {
        	EVF.C("CUBL_SQ").setValue(data.CUBL_SQ);
        	EVF.C("CUBL_NM").setValue(data.CUBL_NM);
        	EVF.C("CUBL_COMPANY_NM").setValue(data.CUBL_COMPANY_NM);
        	EVF.C("CUBL_ADDR").setValue(data.CUBL_ADDR);
        	EVF.C("CUBL_CEO_USER_NM").setValue(data.HIDDEN_CUBL_CEO_USER_NM);
        	EVF.C("CUBL_IRS_NUM").setValue(data.CUBL_IRS_NUM);
        	EVF.C("CUBL_BUSINESS_TYPE").setValue(data.CUBL_BUSINESS_TYPE);
        	EVF.C("CUBL_INDUSTRY_TYPE").setValue(data.CUBL_INDUSTRY_TYPE);
        	EVF.C("CUBL_BANK_NM").setValue(data.CUBL_BANK_NM);
        	EVF.C("CUBL_ACCOUNT_NUM").setValue(data.CUBL_ACCOUNT_NUM);
        	EVF.C("CUBL_ACCOUNT_NM").setValue(data.HIDDEN_CUBL_ACCOUNT_NM);
        	EVF.C("CUBL_USER_NM").setValue(data.HIDDEN_CUBL_USER_NM);
        	EVF.C("CUBL_USER_TEL_NUM").setValue(data.HIDDEN_CUBL_USER_TEL_NUM);
        	EVF.C("CUBL_USER_FAX_NUM").setValue(data.HIDDEN_CUBL_USER_FAX_NUM);
        	EVF.C("CUBL_USER_CELL_NUM").setValue(data.HIDDEN_CUBL_USER_CELL_NUM);
        	EVF.C("CUBL_USER_EMAIL").setValue(data.HIDDEN_CUBL_USER_EMAIL);
        }

        function chgCustCd() {
            var store = new EVF.Store;
            store.load('/evermp/SY01/SY0101/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));


        			if('${form.PLANT_CD}' !='') {
            				EVF.C("PLANT_CD").setValue('${form.PLANT_CD}');
        			}

            	}
            });
        }

    </script>
    <e:window id="MY01_005" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:buttonBar width="100%" align="right" title="${MY01_005_TITLE1}">
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }'/>
        </e:buttonBar>

        <e:searchPanel id="sp" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2">
			<e:inputHidden id='IF_USER_FLAG' name="IF_USER_FLAG" value="${form.IF_USER_FLAG}"/>
            <e:row>
                <e:label for="COMPANY_CD" title="${form_COMPANY_CD_N}"/>
                <e:field>
                    <e:inputText id='COMPANY_CD' name="COMPANY_CD" label='${form_COMPANY_CD_N }' value="${form.COMPANY_CD}" width='20%' maxLength='${form_COMPANY_CD_M }' required='${form_COMPANY_CD_R }' readOnly='${form_COMPANY_CD_RO }' disabled='${form_COMPANY_CD_D }' visible='${form_COMPANY_CD_V }'/>
                    <e:inputText id='COMPANY_NM' name="COMPANY_NM" label='${form_COMPANY_NM_N }' value="${form.COMPANY_NM}" width='80%' maxLength='${form_COMPANY_NM_M }' required='${form_COMPANY_NMM_R }' readOnly='${form_COMPANY_NM_RO }' disabled='${form_COMPANY_NM_D }' visible='${form_COMPANY_NM_V }'/>
                </e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
				<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${form_PLANT_CD_W}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="DEPT_CD" title="${form_DEPT_CD_N}"/>
                <e:field colSpan="3">
                	<e:text>사업부 : </e:text>
                	<e:inputHidden id="DIVISION_CD" name="DIVISION_CD" value="${form.DIVISION_CD }"/>
					<e:search id="DIVISION_NM" name="DIVISION_NM" value="${form.DIVISION_NM }" width="200px" maxLength="${form_DIVISION_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'doSearchDivision'}" disabled="${form_DIVISION_CD_D}" readOnly="${form_DIVISION_CD_RO}" required="${form_DIVISION_CD_R}" />
                	<e:text>&nbsp;&nbsp;&nbsp;&nbsp;부서 : </e:text>
                	<e:inputHidden id="DEPT_CD" name="DEPT_CD" value="${form.DEPT_CD }"/>
                    <e:search id="DEPT_NM" name="DEPT_NM" value="${form.DEPT_NM }" width="200px" maxLength="${form_DEPT_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'doSearchDept'}" disabled="${form_DEPT_CD_D}" readOnly="${form_DEPT_CD_RO}" required="${form_DEPT_CD_R}" />
                	<e:text>&nbsp;&nbsp;&nbsp;&nbsp;파트(영업장) : </e:text>
                	<e:inputHidden id="PART_CD" name="PART_CD" value="${form.PART_CD }"/>
					<e:search id="PART_NM" name="PART_NM" value="${form.PART_NM }" width="200px" maxLength="${form_PART_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'doSearchPart'}" disabled="${form_PART_CD_D}" readOnly="${form_PART_CD_RO}" required="${form_PART_CD_R}" />
                </e:field>
            </e:row>
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
                    <e:inputText id='TEL_NUM' name="TEL_NUM" label='${form_TEL_NUM_N }' value="${form.TEL_NUM}" width='100%' maxLength='${form_TEL_NUM_M }' required='${form_TEL_NUM_R }' readOnly='${form_TEL_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' onChange="checkTelNo" visible='${form_TEL_NUM_V }' data="TEL_NUM" />
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id='EMAIL' name="EMAIL" label='${form_EMAIL_N }' value="${form.EMAIL}" width='100%' maxLength='${form_EMAIL_M }' required='${form_EMAIL_R }' readOnly='${form_EMAIL_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_EMAIL_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"/>
                <e:field>
                    <e:inputText id='FAX_NUM' name="FAX_NUM" label='${form_FAX_NUM_N }' value="${form.FAX_NUM}" width='100%' maxLength='${form_FAX_NUM_M }' required='${form_FAX_NUM_R }' readOnly='${form_FAX_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' onChange="checkTelNo" visible='${form_FAX_NUM_V }'  data="FAX_NUM" />
                </e:field>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"/>
                <e:field>
                    <e:inputText id='CELL_NUM' name="CELL_NUM" label='${form_CELL_NUM_N }' value="${form.CELL_NUM}" width='100%' maxLength='${form_CELL_NUM_M }' required='${form_CELL_NUM_R }' readOnly='${form_CELL_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' onChange="checkCellNo" visible='${form_CELL_NUM_V }'/>
                </e:field>

                <e:inputHidden id='LANG_CD' name="LANG_CD" value="${form.LANG_CD}"/>
                <e:inputHidden id='COUNTRY_CD' name="COUNTRY_CD" value="${form.COUNTRY_CD}"/>
                <e:inputHidden id='GMT_CD' name="GMT_CD" value="${form.GMT_CD}"/>
                <e:inputHidden id='USER_TYPE' name="GMT_CD" value="${ses.userType}"/>
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
                <e:label for="EMPLOYEE_NO" title="${form_EMPLOYEE_NO_N}"/>
                <e:field>
                    <e:inputText id="EMPLOYEE_NO" name="EMPLOYEE_NO" value="${form.EMPLOYEE_NO}" width="${form_EMPLOYEE_NO_W}" maxLength="${form_EMPLOYEE_NO_M}" disabled="${form_EMPLOYEE_NO_D}" readOnly="${form_EMPLOYEE_NO_RO}" required="${form_EMPLOYEE_NO_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="AGREE_YN" title="${form_AGREE_YN_N}"/>
                <e:field>
                    <e:inputText id="AGREE_YN" name="AGREE_YN" value="${form.AGREE_YN}" width="${form_AGREE_YN_W}" maxLength="${form_AGREE_YN_M}" disabled="${form_AGREE_YN_D}" readOnly="${form_AGREE_YN_RO}" required="${form_AGREE_YN_R}"/>
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
                <e:inputHidden id='CHIEF_USER_NM' name="CHIEF_USER_NM" value="${form.CHIEF_USER_NM}"/>
                <e:inputHidden id='CHIEF_USER_ID' name="CHIEF_USER_ID" value="${form.CHIEF_USER_ID}"/>
                <e:inputHidden id='USER_DATE_FORMAT_CD' name="USER_DATE_FORMAT_CD" value="${form.USER_DATE_FORMAT_CD}"/>
                <e:inputHidden id='USER_NUMBER_FORMAT_CD' name="USER_NUMBER_FORMAT_CD" value="${form.USER_NUMBER_FORMAT_CD}"/>
            </e:row>
            <e:row>
                <e:label for="MOD_INFO" title="${form_MOD_INFO_N}" />
                <e:field colSpan="3">
                    <e:inputText id="MOD_INFO" name="MOD_INFO" value="${form.MOD_INFO}" width="${form_MOD_INFO_W}" maxLength="${form_MOD_INFO_M}" disabled="${form_MOD_INFO_D}" readOnly="${form_MOD_INFO_RO}" required="${form_MOD_INFO_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:title title="${MY01_005_TITLE2}" depth="1" />
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

    <%-- 고객사인 경우 기본배송지, 청구지 보이게 처리 --%>
	<c:if test="${ses.userType == 'B'}">
	    <div id="CustCsdm" style="display: block;">
            <e:searchPanel id="custform5" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                <e:panel id="custanel5" height="fit" width="30%">
                    <e:title title="${MY01_005_CAPTION6 }" depth="1"/>
                </e:panel>
                <e:row>
                    <e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}"></e:label>
                    <e:field>
                        <e:search id="CSDM_SEQ" name="CSDM_SEQ" value="${form.CSDM_SEQ }" width="20%" maxLength="${form_CSDM_SEQ_M}" onIconClick="csdmCdSearch" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
                        <e:inputText id="DELY_NM" style='ime-mode:inactive' name="DELY_NM" value="${form.DELY_NM}" width="80%" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="true" required="${form_DELY_NM_R}" />
                    </e:field>
                    <e:label for="DELY_RECIPIENT_NM" title="${form_DELY_RECIPIENT_NM_N}" />
                    <e:field>
                    	<e:inputText id="DELY_RECIPIENT_NM" name="DELY_RECIPIENT_NM" value="${form.DELY_RECIPIENT_NM}" width="${form_DELY_RECIPIENT_NMO_W}" maxLength="${form_DELY_RECIPIENT_NM_M}" disabled="${form_DELY_RECIPIENT_NM_D}" readOnly="${form_DELY_RECIPIENT_NM_RO}" required="${form_DELY_RECIPIENT_NM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="DELY_ADDR" title="${form_DELY_ADDR_N}" />
                    <e:field colSpan="3">
                    	<e:inputText id="DELY_ADDR" name="DELY_ADDR" value="${form.DELY_ADDR}" width="${form_DELY_ADDR_W}" maxLength="${form_DELY_ADDR_M}" disabled="${form_DELY_ADDR_D}" readOnly="${form_DELY_ADDR_RO}" required="${form_DELY_ADDR_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="DELY_RECIPIENT_TEL_NUM" title="${form_DELY_RECIPIENT_TEL_NUM_N}" />
                    <e:field>
                        <e:inputText id="DELY_RECIPIENT_TEL_NUM" name="DELY_RECIPIENT_TEL_NUM" value="${form.DELY_RECIPIENT_TEL_NUM}" width="${form_DELY_RECIPIENT_TEL_NUM_W}" maxLength="${form_DELY_RECIPIENT_TEL_NUM_M}" disabled="${form_DELY_RECIPIENT_TEL_NUM_D}" readOnly="${form_DELY_RECIPIENT_TEL_NUM_RO}" required="${form_DELY_RECIPIENT_TEL_NUM_R}" />
                    </e:field>
                    <e:label for="DELY_RECIPIENT_FAX_NUM" title="${form_DELY_RECIPIENT_FAX_NUM_N}" />
                    <e:field>
                        <e:inputText id="DELY_RECIPIENT_FAX_NUM" name="DELY_RECIPIENT_FAX_NUM" value="${form.DELY_RECIPIENT_FAX_NUM}" width="${form_DELY_RECIPIENT_FAX_NUM_W}" maxLength="${form_DELY_RECIPIENT_FAX_NUM_M}" disabled="${form_DELY_RECIPIENT_FAX_NUM_D}" readOnly="${form_DELY_RECIPIENT_FAX_NUM_RO}" required="${form_DELY_RECIPIENT_FAX_NUM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="DELY_RECIPIENT_CELL_NUM" title="${form_DELY_RECIPIENT_CELL_NUM_N}" />
                    <e:field>
                        <e:inputText id="DELY_RECIPIENT_CELL_NUM" name="DELY_RECIPIENT_CELL_NUM" value="${form.DELY_RECIPIENT_CELL_NUM}" width="${form_DELY_RECIPIENT_CELL_NUM_W}" maxLength="${form_DELY_RECIPIENT_CELL_NUM_M}" disabled="${form_DELY_RECIPIENT_CELL_NUM_D}" readOnly="${form_DELY_RECIPIENT_CELL_NUM_RO}" required="${form_DELY_RECIPIENT_CELL_NUM_R}" />

                    </e:field>
                    <e:label for="DELY_RECIPIENT_EMAIL" title="${form_DELY_RECIPIENT_EMAIL_N}" />
                    <e:field>
                        <e:inputText id="DELY_RECIPIENT_EMAIL" name="DELY_RECIPIENT_EMAIL" value="${form.DELY_RECIPIENT_EMAIL}" width="${form_DELY_RECIPIENT_EMAIL_W}" maxLength="${form_DELY_RECIPIENT_EMAIL_M}" disabled="${form_DELY_RECIPIENT_EMAIL_D}" readOnly="${form_DELY_RECIPIENT_EMAIL_RO}" required="${form_DELY_RECIPIENT_EMAIL_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>
        </div>

        <div id="CustCubl" style="display: block;">
            <e:searchPanel id="custform6" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                <e:panel id="custanel6" height="fit" width="30%">
                    <e:title title="${MY01_005_CAPTION7 }" depth="1"/>
                </e:panel>
                <e:row>
                    <e:label for="CUBL_SQ" title="${form_CUBL_SQ_N}"></e:label>
                    <e:field>
                        <%-- <e:search id="CUBL_SQ" name="CUBL_SQ" value="${form.CUBL_SQ }" width="20%" maxLength="${form_CUBL_SQ_M}" onIconClick="${form_CUBL_SQ_RO ? 'everCommon.blank' : 'cublCdSearch'}" disabled="${form_CUBL_SQ_D}" readOnly="${form_CUBL_SQ_RO}" required="${form_CUBL_SQ_R}" /> --%>
 						<%--   <e:inputText id="CUBL_SQ" style='ime-mode:inactive' name="CUBL_SQ" value="${form.CUBL_SQ}" width="20%" maxLength="${form_CUBL_SQ_M}" disabled="${form_CUBL_SQ_D}" readOnly="${form_CUBL_SQ_RO}" required="${form_CUBL_SQ_R}" /> --%>
 						<e:search id="CUBL_SQ" name="CUBL_SQ" value="${form.CUBL_SQ }" width="20%" maxLength="${form_CUBL_SQ_M}" onIconClick="cublCdSearch" disabled="${form_CUBL_SQ_D}" readOnly="${form_CUBL_SQ_RO}" required="${form_CUBL_SQ_R}" />
                        <e:inputText id="CUBL_NM" style='ime-mode:inactive' name="CUBL_NM" value="${form.CUBL_NM}" width="80%" maxLength="${form_CUBL_NM_M}" disabled="${form_CUBL_NM_D}" readOnly="${form_CUBL_NM_RO}" required="${form_CUBL_NM_R}" />
                    </e:field>
                    <e:label for="CUBL_COMPANY_NM" title="${form_CUBL_COMPANY_NM_N}" />
                    <e:field>
                    	<e:inputText id="CUBL_COMPANY_NM" name="CUBL_COMPANY_NM" value="${form.CUBL_COMPANY_NM}" width="${form_CUBL_COMPANY_NM_W}" maxLength="${form_CUBL_COMPANY_NM_M}" disabled="${form_CUBL_COMPANY_NM_D}" readOnly="${form_CUBL_COMPANY_NM_RO}" required="${form_CUBL_COMPANY_NM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="CUBL_ADDR" title="${form_CUBL_ADDR_N}" />
                    <e:field colSpan="3">
                    	<e:inputText id="CUBL_ADDR" name="CUBL_ADDR" value="${form.CUBL_ADDR}" width="${form_CUBL_ADDR_W}" maxLength="${form_CUBL_ADDR_M}" disabled="${form_CUBL_ADDR_D}" readOnly="${form_CUBL_ADDR_RO}" required="${form_CUBL_ADDR_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="CUBL_CEO_USER_NM" title="${form_CUBL_CEO_USER_NM_N}" />
                    <e:field>
                        <e:inputText id="CUBL_CEO_USER_NM" name="CUBL_CEO_USER_NM" value="${form.CUBL_CEO_USER_NM}" width="${form_CUBL_CEO_USER_NM_W}" maxLength="${form_CUBL_CEO_USER_NM_M}" disabled="${form_CUBL_CEO_USER_NM_D}" readOnly="${form_CUBL_CEO_USER_NM_RO}" required="${form_CUBL_CEO_USER_NM_R}" />
                    </e:field>
                    <e:label for="CUBL_IRS_NUM" title="${form_CUBL_IRS_NUM_N}" />
                    <e:field>
                        <e:inputText id="CUBL_IRS_NUM" name="CUBL_IRS_NUM" value="${form.CUBL_IRS_NUM}" width="${form_CUBL_IRS_NUM_W}" maxLength="${form_CUBL_IRS_NUM_M}" disabled="${form_CUBL_IRS_NUM_D}" readOnly="${form_CUBL_IRS_NUM_RO}" required="${form_CUBL_IRS_NUM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="CUBL_BUSINESS_TYPE" title="${form_CUBL_BUSINESS_TYPE_N}" />
                    <e:field>
                        <e:inputText id="CUBL_BUSINESS_TYPE" name="CUBL_BUSINESS_TYPE" value="${form.CUBL_BUSINESS_TYPE}" width="${form_CUBL_BUSINESS_TYPE_W}" maxLength="${form_CUBL_BUSINESS_TYPE_M}" disabled="${form_CUBL_BUSINESS_TYPE_D}" readOnly="${form_CUBL_BUSINESS_TYPE_RO}" required="${form_CUBL_BUSINESS_TYPE_R}" />

                    </e:field>
                    <e:label for="CUBL_INDUSTRY_TYPE" title="${form_CUBL_INDUSTRY_TYPE_N}" />
                    <e:field>
                        <e:inputText id="CUBL_INDUSTRY_TYPE" name="CUBL_INDUSTRY_TYPE" value="${form.CUBL_INDUSTRY_TYPE}" width="${form_CUBL_INDUSTRY_TYPE_W}" maxLength="${form_CUBL_INDUSTRY_TYPE_M}" disabled="${form_CUBL_INDUSTRY_TYPE_D}" readOnly="${form_CUBL_INDUSTRY_TYPE_RO}" required="${form_CUBL_INDUSTRY_TYPE_R}" />
                    </e:field>
	                <e:inputHidden id='CUBL_BANK_NM' name="CUBL_BANK_NM" value="${form.CUBL_BANK_NM}"/>
	                <e:inputHidden id='CUBL_ACCOUNT_NUM' name="CUBL_ACCOUNT_NUM" value="${form.CUBL_ACCOUNT_NUM}"/>
	                <e:inputHidden id='CUBL_ACCOUNT_NM' name="CUBL_ACCOUNT_NM" value="${form.CUBL_ACCOUNT_NM}"/>
	                <e:inputHidden id='CUBL_USER_TEL_NUM' name="CUBL_USER_TEL_NUM" value="${form.CUBL_USER_TEL_NUM}"/>
	                <e:inputHidden id='CUBL_USER_FAX_NUM' name="CUBL_USER_FAX_NUM" value="${form.CUBL_USER_FAX_NUM}"/>
                </e:row>
                <e:row>
                     <e:label for="CUBL_USER_NM" title="${form_CUBL_USER_NM_N}" />
                    <e:field colSpan="3">
                        <e:inputText id="CUBL_USER_NM" name="CUBL_USER_NM" value="${form.CUBL_USER_NM}" width="${form_CUBL_USER_NM_W}" maxLength="${form_CUBL_USER_NM_M}" disabled="${form_CUBL_USER_NM_D}" readOnly="${form_CUBL_USER_NM_RO}" required="${form_CUBL_USER_NM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="CUBL_USER_CELL_NUM" title="${form_CUBL_USER_CELL_NUM_N}" />
                    <e:field>
                        <e:inputText id="CUBL_USER_CELL_NUM" name="CUBL_USER_CELL_NUM" value="${form.CUBL_USER_CELL_NUM}" width="${form_CUBL_USER_CELL_NUM_W}" maxLength="${form_CUBL_USER_CELL_NUM_M}" disabled="${form_CUBL_USER_CELL_NUM_D}" readOnly="${form_CUBL_USER_CELL_NUM_RO}" required="${form_CUBL_USER_CELL_NUM_R}" />
                    </e:field>
                    <e:label for="CUBL_USER_EMAIL" title="${form_CUBL_USER_EMAIL_N}" />
                    <e:field>
                        <e:inputText id="CUBL_USER_EMAIL" name="CUBL_USER_EMAIL" value="${form.CUBL_USER_EMAIL}" width="${form_CUBL_USER_EMAIL_W}" maxLength="${form_CUBL_USER_EMAIL_M}" disabled="${form_CUBL_USER_EMAIL_D}" readOnly="${form_CUBL_USER_EMAIL_RO}" required="${form_CUBL_USER_EMAIL_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>
        </div>
	</c:if>

    </e:window>
</e:ui>
