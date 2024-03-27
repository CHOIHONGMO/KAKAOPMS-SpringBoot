<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/BS03/BS0302/";
        var noChange="";

        function init() {

            if(${!havePermission}) {

                EVF.C('Insert').setDisabled(true);
                EVF.C('Update').setDisabled(true);
            }else{

                EVF.C('Insert').setDisabled(false);
                EVF.C('Update').setDisabled(false);

                if(EVF.V("USER_ID") != "") {
                    noChange = "Y";
                    EVF.C('Insert').setDisabled(true);
                    EVF.C('Idcheck').setDisabled(true);
                    EVF.C("USER_ID").setReadOnly(true);
                    EVF.C("USER_TYPE").setReadOnly(true);
                    EVF.C("COMPANY_CD").setDisabled(true);
                    EVF.C("COMPANY_NM").setReadOnly(true);
                    EVF.C("PASSWORD").setRequired(false);
                    EVF.C("PASSWORD_CHECK").setRequired(false);
                    // DGNS I/F 고객사인 경우 조직정보는 수정할 수 없도록 함
                    if( EVF.V("IF_USER_FLAG") == '1' ) {
                    	EVF.C("PLANT_CD").setDisabled(true);
                    	EVF.C("S_DEPT_NM").setDisabled(true);
                    	EVF.C("USER_NM").setReadOnly(true);
                    }
                } else {
                    EVF.C('Update').setDisabled(true);
                    EVF.V("MNG_YN","0");
                    EVF.V("BUDGET_FLAG","0");
                    EVF.V("USER_AUTO_PO_FLAG","0");
                    EVF.V("APCH_FLAG","0");
                    EVF.V("APROVAL_USER_FLAG","0");
                }
            }
            UserTypeSearchChange();
            chgCustCd();
        }

        function doSave() {

            var btnData = this.getData();
            var btnMsg = (btnData == "I" ? "${msg.M0011}" : "${msg.M0012}");

            var store = new EVF.Store();
        
            if(!store.validate()) { return; }
            if(EVF.V("ID_CHECK")==""){
                return alert("${BS03_006_002}");
            }

            if(!confirm(btnMsg)) { return; }

                store.load(baseUrl + 'bs03006_doSave', function () {
                    alert(this.getResponseMessage());
                        opener.doSearch();

                        var param = {
                            'USER_ID': EVF.V("USER_ID"),
                            'detailView': false,
                            'popupFlag': true
                        };
                        window.close();
                });
        }

        //id중복체크
       function doIdcheck() {
          EVF.V("ID_CHECK","");
           if(EVF.C("USER_ID").getValue()==""){
               EVF.C('USER_ID').setFocus();
               alert(everString.getMessage("${msg.M0109}", "${form_USER_ID_N}"));
           }else{
               var store = new EVF.Store();
               store.load(baseUrl + 'bs01002_doCheckUserId', function() {
                   if(this.getParameter("POSSIBLE_FLAG") == "N") {
                       EVF.V("ID_CHECK","");
                       return alert("${BS03_006_006}");
                   }else{
                       EVF.V("ID_CHECK","Y");
                       alert("${BS03_006_001}");
                   }
               }, false);
           }
        }

        function onChangeID()
        {
           EVF.V("ID_CHECK","");
           IdcheckId();
        }

        function searchZipCd() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode",
                modalYn : false
            };
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
        function searchZipCd2() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode2",
                modalYn : false
            };
            everPopup.jusoPop(url, param);
        }

        function setZipCode2(zipcd) {
            if (zipcd.ZIP_CD != "") {
                EVF.C("DELY_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('DELY_ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('DELY_ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('DELY_ADDR_2').setFocus();
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
                alert("${BS03_006_021}");
                return false;
            }
            if(str.length >20){
                alert("${BS03_006_021}");
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
                alert("${BS03_006_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${BS03_006_023}");
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

        function IdcheckId(){

           //var regExp = /^[A-Za-z0-9_]{4,16}$/;
           var regExp = /^[A-Za-z0-9_-]{3,16}$/;
            if (!EVF.V("USER_ID").match(regExp)){
                alert("${msg.ID_INVALID}");

                EVF.V("USER_ID","");
            }
        }

        //회사찾기팝업
        function companySearch_I() {
            if (EVF.V('USER_TYPE') == '') {
                alert("${form_USER_TYPE_N } - ${msg.M0004}.");
                return;
            }
            if (EVF.V('USER_TYPE') == 'S') {

                    var param = {
                        callBackFunction: "selectVendor_I"
                    };
                    everPopup.openCommonPopup(param, 'SP0063');

            }else if (EVF.V('USER_TYPE') == 'B') {
                var param = {
                    callBackFunction : "selectCust_I"
                };
                everPopup.openCommonPopup(param, 'SP0067');

            }
        }
        
        function selectVendor_I(dataJsonArray) {
            EVF.C('COMPANY_CD').setValue(dataJsonArray.VENDOR_CD);
            EVF.C('COMPANY_NM').setValue(dataJsonArray.VENDOR_NM);
            EVF.V("DEPT_CD","");
            EVF.V("DEPT_NM","");
            EVF.V("BUDGET_DEPT_CD","");
            EVF.V("BUDGET_DEPT_NM","");
        }
        
        function selectCust_I(dataJsonArray) {
            EVF.C('COMPANY_CD').setValue(dataJsonArray.CUST_CD);
            EVF.C('COMPANY_NM').setValue(dataJsonArray.CUST_NM);
            EVF.V("DEPT_CD","");
            EVF.V("DEPT_NM","");
            EVF.V("BUDGET_DEPT_CD","");
            EVF.V("BUDGET_DEPT_NM","");
            chgCustCd();
        }

        //회사별 부서찾기 팝업
        function deptCdSearch_I() {

            if (EVF.V("USER_TYPE") == "") {
                alert("${BS03_006_0002}");
                return;
            }

            if (EVF.V("COMPANY_CD") == "") {
                alert("${BS03_006_0005}");
                return;
            }

            if (EVF.V("PLANT_CD") == "") {
                alert("${BS03_006_024}");
                return;
            }

            if (EVF.V('USER_TYPE') == 'S') {
                alert("${BSB_060_0004}");
            } else {
                var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
                var param = {
                    callBackFunction: "selectDept_I",
                    'AllSelectYN': false,
                    'detailView': false,
                    'multiYN': false,
                    'ModalPopup': true,
                    'parentsSelectYN': true,
                    'custCd' : EVF.V("COMPANY_CD"),
                    'custNm' : EVF.V("COMPANY_NM"),
                    'plantCd': EVF.V("PLANT_CD")
                };
                everPopup.openModalPopup(popupUrl, 800, 600, param, "SearchTeamPopup");
            }
        }

        function selectDept_I(dataJsonArray) {
            data = JSON.parse(dataJsonArray);

            EVF.C("PLANT_CD").setValue(data.ITEM_CLS1);
            EVF.C("DIVISION_CD").setValue(data.ITEM_CLS2);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS3);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
            EVF.C("PART_CD").setValue(data.ITEM_CLS4);

            // 화면에 보여지는 부서 경로
            EVF.C("S_DEPT_NM").setValue(data.DEPT_NM);
        }

        function deptCdSearch_2() {

            if (EVF.V("USER_TYPE") == "") {
                alert("${BS03_006_0002}");
                return;
            }

            if (EVF.V("COMPANY_CD") == "") {
                alert("${BS03_006_0005}");
                return;
            }

            if ("${ses.userType}" != 'S' && EVF.V('USER_TYPE') != 'S') {
               var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
                var param = {
                    callBackFunction: "selectDept_2",
                    'AllSelectYN': false,
                    'detailView': false,
                    'multiYN': false,
                    'ModalPopup': true,
                    'parentsSelectYN': false,
                    'custCd' : EVF.V("COMPANY_CD"),
                    'custNm' :  EVF.V("COMPANY_NM"),
                    'PLANT_CD' : EVF.V("PLANT_CD")
                };
                everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup1");
            } else {
                alert("${BS03_006_0004}");

            }
        }
        function selectDept_2(dataJsonArray) {
           data = JSON.parse(dataJsonArray);
            EVF.C('BUDGET_DEPT_CD').setValue(data.DEPT_CD);
            EVF.C('BUDGET_DEPT_NM').setValue(data.DEPT_NM);
        }

        function csdmCdSearch() {

            if (EVF.V("USER_TYPE") == "") {
                alert("${BS03_006_0002}");
                return;
            }

            if (EVF.V("COMPANY_CD") == "") {
                alert("${BS03_006_0005}");
                return;
            }

            if ("${ses.userType}" != 'S' && EVF.V('USER_TYPE') != 'S') {
                var param = {
                    callBackFunction: "setCsdmCdSearch",
                    CUST_CD: EVF.V("COMPANY_CD"),
                    detailView : false
                };
                //everPopup.openCommonPopup(param, 'SP0023');
                everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
            } else {
                alert("${BS03_006_0004}");

            }
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

            if (EVF.V("USER_TYPE") == "") {
                alert("${BS03_006_0002}");
                return;
            }

            if (EVF.V("COMPANY_CD") == "") {
                alert("${BS03_006_0005}");
                return;
            }

            if ("${ses.userType}" != 'S' && EVF.V('USER_TYPE') != 'S') {
                var param = {
                    callBackFunction: "setCublCdSearch",
                    CUST_CD: EVF.V("COMPANY_CD"),
                    detailView : false
                };
                //everPopup.openCommonPopup(param, 'SP0023');
                everPopup.openPopupByScreenId("MY01_008", 900, 600, param);
            } else {
                alert("${BS03_006_0004}");

            }
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


        function recipientSame_Check() {
            if(EVF.V("RECIPIENT_FLAG")=="Y"){
                EVF.V("RECIPIENT_NM",EVF.V("USER_NM"));
                EVF.V("RECIPIENT_DEPT_NM",EVF.V("DEPT_NM"));
                EVF.V("RECIPIENT_CELL_NUM",EVF.V("CELL_NUM"));
                EVF.V("RECIPIENT_TEL_NUM",EVF.V("TEL_NUM"));
                EVF.V("RECIPIENT_EMAIL",EVF.V("EMAIL"));
                EVF.V("DELY_ZIP_CD",EVF.V("ZIP_CD"));
                EVF.V("DELY_ADDR_1",EVF.V("ADDR_1"));
                EVF.V("DELY_ADDR_2",EVF.V("ADDR_2"));
            }
        }

        function UserTypeSearchChange(){

            if(EVF.V("USER_TYPE")=="S"){
                $('#CustDiv').css('display', 'none');
                $('#CustCsdm').css('display', 'none');
                $('#CustCubl').css('display', 'none');
                $('#VendorDiv').css('display', 'block');
                EVF.C('DEPT_CD').setDisabled(true);
                EVF.C('DEPT_CD').setReadOnly(true);
                EVF.C('DEPT_NM').setReadOnly(false);
                EVF.C('DEPT_NM').setRequired(false);
                EVF.C('VNGL_ROLE').setRequired(true);

                $('#form3').css('display', 'none');
            }else{
                $('#CustDiv').css('display', 'block');
                $('#CustCsdm').css('display', 'block');
                $('#CustCubl').css('display', 'block');
                $('#VendorDiv').css('display', 'none');
                EVF.C('DEPT_CD').setDisabled(false);
                EVF.C('DEPT_CD').setReadOnly(true);
                EVF.C('DEPT_NM').setReadOnly(true);
                EVF.C('DEPT_NM').setRequired(false);
                EVF.C('VNGL_ROLE').setRequired(false);
                EVF.C('BUDGET_FLAG').setRequired(true);
                EVF.C('GR_FLAG').setRequired(true);
                EVF.C('FINANCIAL_FLAG').setRequired(true);
                EVF.C('BUDGET_DEPT_CD').setDisabled(false);
                EVF.C('BUDGET_DEPT_NM').setDisabled(false);
                EVF.C('BUDGET_FLAG').setDisabled(false);
                EVF.C('GR_FLAG').setDisabled(false);
                EVF.C('FINANCIAL_FLAG').setDisabled(false);
                EVF.C('CHIEF_USER_NM').setDisabled(false);

                $('#form3').css('display', 'block');
            }
        }

        function doUserSearch() {

            var custCd = EVF.V("COMPANY_CD");
            if( custCd == "" ) {
                alert("${BS03_006_011}");
                return;
            }
            var param = {
                callBackFunction: "selectCustUserId",
                custCd: custCd
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function selectCustUserId(data) {
            EVF.C("CHIEF_USER_ID").setValue(data.USER_ID);
            EVF.C("CHIEF_USER_NM").setValue(data.USER_NM);
        }

        function doInitPass() {
            var valueNew = EVF.V('USER_ID');
            var valueOld = EVF.V('ORI_USER_ID');

            if (valueNew != valueOld || valueOld == "") {
                return alert("${msg.M0007}");
            }

            if (confirm("${msg.M0029}")) {
                var store = new EVF.Store();
                store.load("/eversrm/master/user/userInformation/doResetLast", function() {
                    alert(this.getResponseMessage());
                });
            }
        }

        function chgCustCd() {
            var store = new EVF.Store;
            store.load('/evermp/SY01/SY0101/getPlantCd', function() {
               if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
                 if('${formData.PLANT_CD}' !='') {

                    if(EVF.C("USER_ID").getValue() != '') {
                        EVF.C("PLANT_CD").setValue('${formData.PLANT_CD}');
                    }
                 }
               }
            });
        }

    </script>

    <e:window id="BS03_006" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonTopBottom" align="right" width="100%" title="${BS03_006_CAPTION1 }">
            <e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${Insert_V}" onClick="doSave" data="I" />
            <e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }" visible="${Update_V}" onClick="doSave" data="U" />
        </e:buttonBar>

        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:inputHidden id="ORI_USER_ID" name="ORI_USER_ID" value="${formData.USER_ID }" />
            <e:inputHidden id="IF_USER_FLAG" name="IF_USER_FLAG" value="${formData.IF_USER_FLAG }" />
            <e:inputHidden id="USER_TYPE" name="USER_TYPE" value="B" />   <!-- 고객사 사용자 -->
	        <e:inputHidden id="DIVISION_CD" name="DIVISION_CD" value="${formData.DIVISION_CD}" />   <!-- 사업부코드 -->
	        <e:inputHidden id="DEPT_CD" name="DEPT_CD" value="${formData.DEPT_CD}" />   <!-- 부서코드 -->
	        <e:inputHidden id="DEPT_NM" name="DEPT_NM" value="${formData.DEPT_NM}" />   <!-- 부서명 -->
	        <e:inputHidden id="PART_CD" name="PART_CD" value="${formData.PART_CD}" />   <!-- 파트코드 -->

            <e:row>
                <e:label for="COMPANY_CD" title="${form_COMPANY_CD_N}"></e:label>
                <e:field>
                    <e:search id="COMPANY_CD" name="COMPANY_CD" value="${formData.COMPANY_CD }" width="40%" maxLength="${form_COMPANY_CD_M}" onIconClick="companySearch_I" disabled="${form_COMPANY_CD_D}" readOnly="${form_COMPANY_CD_RO}" required="${form_COMPANY_CD_R}" />
                    <e:inputText id="COMPANY_NM" style='ime-mode:inactive' name="COMPANY_NM" value="${formData.COMPANY_NM}" width="60%" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="true" required="${form_COMPANY_NM_R}" />
                </e:field>
	            <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
	            <e:field>
	               <e:select id="PLANT_CD" name="PLANT_CD" value="${formData.PLANT_CD}" options="${plantCdOptions}" width="${form_PLANT_CD_W}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
	            </e:field>
            </e:row>
            <e:row>
                <e:label for="DEPT_CD" title="${form_DEPT_CD_N}"></e:label>
                <e:field colSpan="3">
                    <e:search id="S_DEPT_NM" name="S_DEPT_NM" value="${formData.DEPT_NM}" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" onIconClick="deptCdSearch_I" disabled="${form_DEPT_NM_D}" readOnly="true" required="${form_DEPT_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="form2" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:panel id="Panel2" height="fit" width="30%">
                <e:title title="${BS03_006_CAPTION2 }" depth="1"/>
            </e:panel>
            <e:row>
                <e:label for="USER_ID" title="${form_USER_ID_N}"/>
                <e:field>
                    <e:inputText id="USER_ID" name="USER_ID" value="${formData.USER_ID }" width="60%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" onChange="onChangeID" />
                    &nbsp;<e:button id="Idcheck" name="Idcheck" label="${Idcheck_N}" onClick="doIdcheck" disabled="${Idcheck_D}" visible="${Idcheck_V}" />
                    <e:inputHidden id="ID_CHECK" name="ID_CHECK" value="${formData.ID_CHECK }" />
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="USER_NM" name="USER_NM" value="${formData.USER_NM }" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PASSWORD" title="${form_PASSWORD_N}"></e:label>
                <e:field>
                    <e:inputPassword id="PASSWORD" style='ime-mode:inactive' name="PASSWORD" value="${formData.PASSWORD}"  width="100%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}"  data="1" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                    <e:inputHidden id="CHANGE_PW" name="CHANGE_PW" value="" />
                </e:field>
                <e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N}"></e:label>
                <e:field>
                    <e:inputPassword id="PASSWORD_CHECK" style='ime-mode:inactive' name="PASSWORD_CHECK" value="${formData.PASSWORD_CHECK}"  width="100%" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" data="2" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="TEL_NUM" name="TEL_NUM"  placeHolder="${BS03_006_INPUT_T2 }" value="${formData.TEL_NUM}" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" onChange="checkTelNo" data="TEL_NUM" />
                </e:field>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="FAX_NUM" name="FAX_NUM" placeHolder="${BS03_006_INPUT_T2 }" value="${formData.FAX_NUM}" width="100%" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" onChange="checkTelNo" data="FAX_NUM" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="CELL_NUM" name="CELL_NUM"  placeHolder="${BS03_006_INPUT_T2 }" value="${formData.CELL_NUM}" width="100%" maxLength="${form_CELL_NUM_M}" disabled="${form_CELL_NUM_D}" readOnly="${form_CELL_NUM_RO}" required="${form_CELL_NUM_R}" onChange="checkCellNo" data="CELL_NUM" />
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"></e:label>
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" style='ime-mode:inactive' value="${formData.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" onChange="checkEmail"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SMS_FLAG" title="${form_SMS_FLAG_N}" />
                <e:field>
                    <e:select id="SMS_FLAG" name="SMS_FLAG" value="${formData.SMS_FLAG }" options="${smsFlagOptions }" width="${form_SMS_FLAG_W}" disabled="${form_SMS_FLAG_D}" readOnly="${form_SMS_FLAG_RO}" required="${form_SMS_FLAG_R}" usePlaceHolder="false" />
                </e:field>
                <e:label for="MAIL_FLAG" title="${form_MAIL_FLAG_N}" />
                <e:field>
                    <e:select id="MAIL_FLAG" name="MAIL_FLAG" value="${formData.MAIL_FLAG }" options="${smsFlagOptions }" width="${form_MAIL_FLAG_W}" disabled="${form_MAIL_FLAG_D}" readOnly="${form_MAIL_FLAG_RO}" required="${form_MAIL_FLAG_R}" usePlaceHolder="false" />
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
                <e:label for="EMPLOYEE_NO" title="${form_EMPLOYEE_NO_N}"/>
                <e:field>
                    <e:inputText id="EMPLOYEE_NO" name="EMPLOYEE_NO" value="${formData.EMPLOYEE_NO}" width="${form_EMPLOYEE_NO_W}" maxLength="${form_EMPLOYEE_NO_M}" disabled="${form_EMPLOYEE_NO_D}" readOnly="${form_EMPLOYEE_NO_RO}" required="${form_EMPLOYEE_NO_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="MNG_YN" title="${form_MNG_YN_N}"/>
                <e:field>
                    <e:select id="MNG_YN" name="MNG_YN" value="${formData.MNG_YN}" options="${mngYnOptions}" width="${form_MNG_YN_W}" disabled="${form_MNG_YN_D}" readOnly="${form_MNG_YN_RO}" required="${form_MNG_YN_R}" usePlaceHolder="false" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="AGREE_YN" title="${form_AGREE_YN_N}"/>
                <e:field>
                    <e:inputText id="AGREE_YN" name="AGREE_YN" value="${formData.AGREE_YN}" width="${form_AGREE_YN_W}" maxLength="${form_AGREE_YN_M}" disabled="${form_AGREE_YN_D}" readOnly="${form_AGREE_YN_RO}" required="${form_AGREE_YN_R}"/>
                </e:field>
                <e:label for="AGREE_YN_DATE" title="${form_AGREE_YN_DATE_N}"/>
                <e:field>
                    <e:inputText id="AGREE_YN_DATE" name="AGREE_YN_DATE" value="${formData.AGREE_YN_DATE}" width="${form_AGREE_YN_DATE_W}" maxLength="${form_AGREE_YN_DATE_M}" disabled="${form_AGREE_YN_DATE_D}" readOnly="${form_AGREE_YN_DATE_RO}" required="${form_AGREE_YN_DATE_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <c:if test="${formData.USER_TYPE ne 'S'}">
           <div id="CustCsdm" style="display: block;">
               <e:searchPanel id="custform5" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                   <e:panel id="custanel5" height="fit" width="30%">
                       <e:title title="${BS03_006_CAPTION6 }" depth="1"/>
                   </e:panel>

                   <e:row>
                       <e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}"></e:label>
                       <e:field>
                           <e:search id="CSDM_SEQ" name="CSDM_SEQ" value="${formData.CSDM_SEQ }" width="40%" maxLength="${form_CSDM_SEQ_M}" onIconClick="csdmCdSearch" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
                           <e:inputText id="DELY_NM" style='ime-mode:inactive' name="DELY_NM" value="${formData.DELY_NM}" width="60%" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="true" required="${form_DELY_NM_R}" />
                       </e:field>
                       <e:label for="DELY_RECIPIENT_NM" title="${form_DELY_RECIPIENT_NM_N}" />
                       <e:field>
                          <e:inputText id="DELY_RECIPIENT_NM" name="DELY_RECIPIENT_NM" value="${formData.DELY_RECIPIENT_NM}" width="${form_DELY_RECIPIENT_NMO_W}" maxLength="${form_DELY_RECIPIENT_NM_M}" disabled="${form_DELY_RECIPIENT_NM_D}" readOnly="${form_DELY_RECIPIENT_NM_RO}" required="${form_DELY_RECIPIENT_NM_R}" />
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="DELY_ADDR" title="${form_DELY_ADDR_N}" />
                       <e:field colSpan="3">
                          <e:inputText id="DELY_ADDR" name="DELY_ADDR" value="${formData.DELY_ADDR}" width="${form_DELY_ADDR_W}" maxLength="${form_DELY_ADDR_M}" disabled="${form_DELY_ADDR_D}" readOnly="${form_DELY_ADDR_RO}" required="${form_DELY_ADDR_R}" />
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="DELY_RECIPIENT_TEL_NUM" title="${form_DELY_RECIPIENT_TEL_NUM_N}" />
                       <e:field>
                           <e:inputText id="DELY_RECIPIENT_TEL_NUM" name="DELY_RECIPIENT_TEL_NUM" value="${formData.DELY_RECIPIENT_TEL_NUM}" width="${form_DELY_RECIPIENT_TEL_NUM_W}" maxLength="${form_DELY_RECIPIENT_TEL_NUM_M}" disabled="${form_DELY_RECIPIENT_TEL_NUM_D}" readOnly="${form_DELY_RECIPIENT_TEL_NUM_RO}" required="${form_DELY_RECIPIENT_TEL_NUM_R}" />
                     <e:inputHidden id="DELY_RECIPIENT_FAX_NUM" name="DELY_RECIPIENT_FAX_NUM"/>
                       </e:field>
                       <e:label for="DELY_RECIPIENT_CELL_NUM" title="${form_DELY_RECIPIENT_CELL_NUM_N}" />
                       <e:field>
                           <e:inputText id="DELY_RECIPIENT_CELL_NUM" name="DELY_RECIPIENT_CELL_NUM" value="${formData.DELY_RECIPIENT_CELL_NUM}" width="${form_DELY_RECIPIENT_CELL_NUM_W}" maxLength="${form_DELY_RECIPIENT_CELL_NUM_M}" disabled="${form_DELY_RECIPIENT_CELL_NUM_D}" readOnly="${form_DELY_RECIPIENT_CELL_NUM_RO}" required="${form_DELY_RECIPIENT_CELL_NUM_R}" />

                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="DELY_RECIPIENT_EMAIL" title="${form_DELY_RECIPIENT_EMAIL_N}" />
                       <e:field colSpan="3">
                           <e:inputText id="DELY_RECIPIENT_EMAIL" name="DELY_RECIPIENT_EMAIL" value="${formData.DELY_RECIPIENT_EMAIL}" width="${form_DELY_RECIPIENT_EMAIL_W}" maxLength="${form_DELY_RECIPIENT_EMAIL_M}" disabled="${form_DELY_RECIPIENT_EMAIL_D}" readOnly="${form_DELY_RECIPIENT_EMAIL_RO}" required="${form_DELY_RECIPIENT_EMAIL_R}" />
                       </e:field>
                   </e:row>
               </e:searchPanel>
           </div>
           <div id="CustCubl" style="display: block;">
               <e:searchPanel id="custform6" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                   <e:panel id="custanel6" height="fit" width="30%">
                       <e:title title="${BS03_006_CAPTION7 }" depth="1"/>
                   </e:panel>

                   <e:row>
                       <e:label for="CUBL_SQ" title="${form_CUBL_SQ_N}"></e:label>
                       <e:field>
                           <e:search id="CUBL_SQ" name="CUBL_SQ" value="${formData.CUBL_SQ }" width="40%" maxLength="${form_CUBL_SQ_M}" onIconClick="cublCdSearch" disabled="${form_CUBL_SQ_D}" readOnly="${form_CUBL_SQ_RO}" required="${form_CUBL_SQ_R}" />
                           <e:inputText id="CUBL_NM" style='ime-mode:inactive' name="CUBL_NM" value="${formData.CUBL_NM}" width="60%" maxLength="${form_CUBL_NM_M}" disabled="${form_CUBL_NM_D}" readOnly="true" required="${form_CUBL_NM_R}" />
                       </e:field>
                       <e:label for="CUBL_COMPANY_NM" title="${form_CUBL_COMPANY_NM_N}" />
                       <e:field>
                          <e:inputText id="CUBL_COMPANY_NM" name="CUBL_COMPANY_NM" value="${formData.CUBL_COMPANY_NM}" width="${form_CUBL_COMPANY_NM_W}" maxLength="${form_CUBL_COMPANY_NM_M}" disabled="${form_CUBL_COMPANY_NM_D}" readOnly="${form_CUBL_COMPANY_NM_RO}" required="${form_CUBL_COMPANY_NM_R}" />
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="CUBL_ADDR" title="${form_CUBL_ADDR_N}" />
                       <e:field colSpan="3">
                          <e:inputText id="CUBL_ADDR" name="CUBL_ADDR" value="${formData.CUBL_ADDR}" width="${form_CUBL_ADDR_W}" maxLength="${form_CUBL_ADDR_M}" disabled="${form_CUBL_ADDR_D}" readOnly="${form_CUBL_ADDR_RO}" required="${form_CUBL_ADDR_R}" />
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="CUBL_CEO_USER_NM" title="${form_CUBL_CEO_USER_NM_N}" />
                       <e:field>
                           <e:inputText id="CUBL_CEO_USER_NM" name="CUBL_CEO_USER_NM" value="${formData.CUBL_CEO_USER_NM}" width="${form_CUBL_CEO_USER_NM_W}" maxLength="${form_CUBL_CEO_USER_NM_M}" disabled="${form_CUBL_CEO_USER_NM_D}" readOnly="${form_CUBL_CEO_USER_NM_RO}" required="${form_CUBL_CEO_USER_NM_R}" />
                       </e:field>
                       <e:label for="CUBL_IRS_NUM" title="${form_CUBL_IRS_NUM_N}" />
                       <e:field>
                           <e:inputText id="CUBL_IRS_NUM" name="CUBL_IRS_NUM" value="${formData.CUBL_IRS_NUM}" width="${form_CUBL_IRS_NUM_W}" maxLength="${form_CUBL_IRS_NUM_M}" disabled="${form_CUBL_IRS_NUM_D}" readOnly="${form_CUBL_IRS_NUM_RO}" required="${form_CUBL_IRS_NUM_R}" />
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="CUBL_BUSINESS_TYPE" title="${form_CUBL_BUSINESS_TYPE_N}" />
                       <e:field>
                           <e:inputText id="CUBL_BUSINESS_TYPE" name="CUBL_BUSINESS_TYPE" value="${formData.CUBL_BUSINESS_TYPE}" width="${form_CUBL_BUSINESS_TYPE_W}" maxLength="${form_CUBL_BUSINESS_TYPE_M}" disabled="${form_CUBL_BUSINESS_TYPE_D}" readOnly="${form_CUBL_BUSINESS_TYPE_RO}" required="${form_CUBL_BUSINESS_TYPE_R}" />
                       </e:field>
                       <e:label for="CUBL_INDUSTRY_TYPE" title="${form_CUBL_INDUSTRY_TYPE_N}" />
                       <e:field>
                           <e:inputText id="CUBL_INDUSTRY_TYPE" name="CUBL_INDUSTRY_TYPE" value="${formData.CUBL_INDUSTRY_TYPE}" width="${form_CUBL_INDUSTRY_TYPE_W}" maxLength="${form_CUBL_INDUSTRY_TYPE_M}" disabled="${form_CUBL_INDUSTRY_TYPE_D}" readOnly="${form_CUBL_INDUSTRY_TYPE_RO}" required="${form_CUBL_INDUSTRY_TYPE_R}" />
                       </e:field>

                       <e:inputHidden id="CUBL_BANK_NM" name="CUBL_BANK_NM" value="${formData.CUBL_BANK_NM}"/>
                       <e:inputHidden id="CUBL_ACCOUNT_NUM" name="CUBL_ACCOUNT_NUM" value="${formData.CUBL_ACCOUNT_NUM}"/>
                       <e:inputHidden id="CUBL_ACCOUNT_NM" name="CUBL_ACCOUNT_NM" value="${formData.CUBL_ACCOUNT_NM}"/>
                       <e:inputHidden id="CUBL_USER_TEL_NUM" name="CUBL_USER_TEL_NUM" value="${formData.CUBL_USER_TEL_NUM}"/>
                       <e:inputHidden id="CUBL_USER_FAX_NUM" name="CUBL_USER_FAX_NUM" value="${formData.CUBL_ACCOUNT_NM}"/>
                   </e:row>
                   <e:row>
                       <e:label for="CUBL_USER_NM" title="${form_CUBL_USER_NM_N}" />
                       <e:field colSpan="3">
                           <e:inputText id="CUBL_USER_NM" name="CUBL_USER_NM" value="${formData.CUBL_USER_NM}" width="${form_CUBL_USER_NM_W}" maxLength="${form_CUBL_USER_NM_M}" disabled="${form_CUBL_USER_NM_D}" readOnly="${form_CUBL_USER_NM_RO}" required="${form_CUBL_USER_NM_R}" />
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="CUBL_USER_CELL_NUM" title="${form_CUBL_USER_CELL_NUM_N}" />
                       <e:field>
                           <e:inputText id="CUBL_USER_CELL_NUM" name="CUBL_USER_CELL_NUM" value="${formData.CUBL_USER_CELL_NUM}" width="${form_CUBL_USER_CELL_NUM_W}" maxLength="${form_CUBL_USER_CELL_NUM_M}" disabled="${form_CUBL_USER_CELL_NUM_D}" readOnly="${form_CUBL_USER_CELL_NUM_RO}" required="${form_CUBL_USER_CELL_NUM_R}" />
                       </e:field>
                       <e:label for="CUBL_USER_EMAIL" title="${form_CUBL_USER_EMAIL_N}" />
                       <e:field>
                           <e:inputText id="CUBL_USER_EMAIL" name="CUBL_USER_EMAIL" value="${formData.CUBL_USER_EMAIL}" width="${form_CUBL_USER_EMAIL_W}" maxLength="${form_CUBL_USER_EMAIL_M}" disabled="${form_CUBL_USER_EMAIL_D}" readOnly="${form_CUBL_USER_EMAIL_RO}" required="${form_CUBL_USER_EMAIL_R}" />
                       </e:field>
                   </e:row>
               </e:searchPanel>
           </div>
           <div id="CustDiv" style="display: block;">
               <e:searchPanel id="custform2" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                   <e:panel id="custanel2" height="fit" width="30%">
                       <e:title title="${BS03_006_CAPTION5 }" depth="1"/>
                   </e:panel>
                   <e:row>
                       <e:label for="BUDGET_DEPT_CD" title="${form_BUDGET_DEPT_CD_N}"></e:label>
                       <e:field>
                           <e:search id="BUDGET_DEPT_CD" name="BUDGET_DEPT_CD" value="${formData.BUDGET_DEPT_CD }" width="40%" maxLength="${form_BUDGET_DEPT_CD_M}" onIconClick="deptCdSearch_2" disabled="${form_BUDGET_DEPT_CD_D}" readOnly="${form_BUDGET_DEPT_CD_RO}" required="${form_BUDGET_DEPT_CD_R}" />
                           <e:inputText id="BUDGET_DEPT_NM" style='ime-mode:inactive' name="BUDGET_DEPT_NM" value="${formData.BUDGET_DEPT_NM}" width="60%" maxLength="${form_BUDGET_DEPT_NM_M}" disabled="${form_BUDGET_DEPT_NM_D}" readOnly="true" required="${form_BUDGET_DEPT_NM_R}" />
                       </e:field>
                       <e:label for="BUDGET_FLAG" title="${form_BUDGET_FLAG_N}" />
                       <e:field>
                           <e:select id="BUDGET_FLAG" name="BUDGET_FLAG" value="${formData.BUDGET_FLAG }" options="${budgetFlagOptions }" width="${form_BUDGET_FLAG_W}" disabled="${form_BUDGET_FLAG_D}" readOnly="${form_BUDGET_FLAG_RO}" required="${form_BUDGET_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                       </e:field>
                   </e:row>
                   <e:row>
                       <e:label for="FINANCIAL_FLAG" title="${form_FINANCIAL_FLAG_N}" />
                       <e:field>
                           <e:select id="FINANCIAL_FLAG" name="FINANCIAL_FLAG" value="${formData.FINANCIAL_FLAG }" options="${financialFlagOptions }" width="${form_FINANCIAL_FLAG_W}" disabled="${form_FINANCIAL_FLAG_D}" readOnly="${form_FINANCIAL_FLAG_RO}" required="${form_FINANCIAL_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                       </e:field>
                       <e:label for="GR_FLAG" title="${form_GR_FLAG_N}" />
                       <e:field>
                           <e:select id="GR_FLAG" name="GR_FLAG" value="${formData.GR_FLAG }" options="${grFlagOptions }" width="${form_GR_FLAG_W}" disabled="${form_GR_FLAG_D}" readOnly="${form_GR_FLAG_RO}" required="${form_GR_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                       </e:field>
                       <e:inputHidden id="CHIEF_USER_ID" name="CHIEF_USER_ID" value="${formData.CHIEF_USER_ID}" />
                       <e:inputHidden id="CHIEF_USER_NM" name="CHIEF_USER_NM" value="${formData.CHIEF_USER_NM}"/>
                       <e:inputHidden id="USER_AUTO_PO_FLAG" name="USER_AUTO_PO_FLAG" value="${formData.USER_AUTO_PO_FLAG}"/>
                       <e:inputHidden id="APROVAL_USER_FLAG" name="APROVAL_USER_FLAG" value="${formData.APROVAL_USER_FLAG}"/>
                       <e:inputHidden id="APCH_FLAG" name="APCH_FLAG" value="${formData.APCH_FLAG}"/>
                   </e:row>
               </e:searchPanel>
           </div>
        </c:if>

        <div id="VendorDiv" style="display: none;">
            <e:searchPanel id="vendorform2" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                <e:panel id="vendoranel2" height="fit" width="30%">
                    <e:title title="${BS03_006_CAPTION5 }" depth="1"/>
                </e:panel>
                <e:row>
                    <e:label for="VNGL_ROLE" title="${form_VNGL_ROLE_N}"/>
                    <e:field>
                        <e:checkGroup id="VNGL_ROLE" name="VNGL_ROLE" value="${formData.VNGL_ROLE}" width="100%" disabled="${form_VNGL_ROLE_D}" readOnly="${form_VNGL_ROLE_RO}" required="${form_VNGL_ROLE_R}">
                            <c:forEach var="role" items="${RoleList}" varStatus="vs">
                                <e:check id="VNGL_ROLE_${role.value}" name="VNGL_ROLE_${role.value}" value="${role.value}" label="${role.text}" disabled="${form_VNGL_ROLE_D}" readOnly="${form_VNGL_ROLE_RO}" />
                                <c:if test="${(vs.index+1) % 9 == 0}">
                                    <e:br/>
                                </c:if>
                            </c:forEach>
                        </e:checkGroup>
                    </e:field>
                    <e:label for="MOD_INFO2" title="${form_MOD_INFO_N}" />
                    <e:field>
                        <e:inputText id="MOD_INFO2" name="MOD_INFO" value="${formData.MOD_INFO}" width="${form_MOD_INFO_W}" maxLength="${form_MOD_INFO_M}" disabled="${form_MOD_INFO_D}" readOnly="${form_MOD_INFO_RO}" required="${form_MOD_INFO_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>
        </div>
        <br>
    </e:window>
</e:ui>