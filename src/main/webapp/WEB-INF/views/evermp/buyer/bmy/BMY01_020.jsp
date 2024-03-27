<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/eversrm/buyer/bmy";
        var userType = '${ses.userType}';
        var clickRowId;
        var grid;

        function init() {

            grid = EVF.C("grid");

            grid.setProperty('shrinkToFit', true);        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
            grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
            grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
            grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
            grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
            grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
            grid.setProperty('multiSelect', false);        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

            doSearchTask();
        }

        function doSearchTask() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load('/eversrm/buyer/basic/BBS02_011_doSearchTask', function() {
            });
        }

        function doSave() {
            var presentPass = EVF.C("P_PASSWORD").getValue();
            var newPassCheck1 = EVF.C("PASSWORD_CHECK1").getValue();
            var newPassCheck2 = EVF.C("PASSWORD_CHECK2").getValue();

            if(EVF.isNotEmpty(presentPass)) {
                if (newPassCheck1.trim() == '' || newPassCheck2.trim() == '') {
                    pwValid();
                    return EVF.alert("${BMY01_020_003}");
                }

                if(newPassCheck1 != newPassCheck2) {
                    pwValid();
                    return EVF.alert('${BMY01_020_004}');
                }
            }

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            if (!confirm("${msg.M0021}")) return;
            store.load(baseUrl+'/BMY01_020_saveUser', function () {
                alert(this.getResponseMessage());
                location.reload();
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
                EVF.alert("${BMY01_020_021}");
                return false;
            }
            if(str.length >20){
                EVF.alert("${BMY01_020_021}");
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
                EVF.alert("${BMY01_020_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                EVF.alert("${BMY01_020_023}");
                return false;
            }

            <%-- 기존비밀번호와 동일하면안됨. --%>
            if(str==EVF.V("P_PASSWORD")){
                EVF.alert("${msg.M0153 }");
                return false;
            }
            return true;
        }

        <%-- 전화번호체크 --%>
        function checkTelNo() {
            var checkType = this.getData();
            if(checkType == "FAX_NUM") {
                if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
                    EVF.alert("${msg.M0128}");
                    EVF.C("FAX_NUM").setValue("");
                    EVF.C('FAX_NUM').setFocus();
                }
            }
/*             if(checkType == "TEL_NUM") {
                if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("TEL_NUM").setValue("");
                    EVF.C('TEL_NUM').setFocus();
                }
            } */
        }

        function checkCellNo() {
            var CellNum = EVF.V("CELL_NUM");
            var rgEx = /(01[016789])[-](\d{4}|\d{3})[-]\d{4}$/g;
            var chkFlg = rgEx.test(CellNum);
            if(!chkFlg){
                EVF.C("CELL_NUM").setValue("");
                EVF.C('CELL_NUM').setFocus();
                return EVF.alert("${msg.M0128}");
            }
        }

      //회사별 부서찾기 팝업
        function deptCdSearch_IC() {
            var param = {
                callBackFunction : "selectDept_IC"
            };
            everPopup.openCommonPopup(param, 'SP0002');
        }
        function selectDept_IC(data) {
            EVF.V("DEPT_CD", data.DEPT_CD);
            EVF.V("DEPT_NM", data.DEPT_NM);
        }




    </script>
    <e:window id="BMY01_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <%--<e:title title="${BMY01_020_TITLE1}" depth="1" />--%>
        <e:buttonBar title="${BMY01_020_TITLE1}" width="100%" align="right">
            <%--<e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D}' visible='${doSave_V}'/>--%>
            <%-- <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }'/> --%>
        </e:buttonBar>

        <e:searchPanel id="sp" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2">

            <e:row>
                <e:label for="COMPANY_CD" title="${form_COMPANY_CD_N}"/>
                <e:field>
                    <e:inputText id='COMPANY_CD' name="COMPANY_CD" label='${form_COMPANY_CD_N }' value="${formData.COMPANY_CD}" width='100%' maxLength='${form_COMPANY_CD_M }' required='${form_COMPANY_CD_R }' readOnly='${form_COMPANY_CD_RO }' disabled='${form_COMPANY_CD_D }' visible='${form_COMPANY_CD_V }'/>
                </e:field>
                <e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}"/>
                <e:field>
                    <e:inputText id='COMPANY_NM' name="COMPANY_NM" label='${form_COMPANY_NM_N }' value="${formData.COMPANY_NM}" width='100%' maxLength='${form_COMPANY_NM_M }' required='${form_COMPANY_NM_R }' readOnly='${form_COMPANY_NM_RO }' disabled='${form_COMPANY_NM_D }' visible='${form_COMPANY_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DEPT_CD" title="${form_DEPT_CD_N}"/>
                <e:field>
                    <e:search id="DEPT_CD" name="DEPT_CD" value="${formData.DEPT_CD }" width="100%" maxLength="${form_DEPT_CD_M}" onIconClick="${form_DEPT_CD_RD ? 'everCommon.blank' : ''}" disabled="${form_DEPT_CD_D}" readOnly="${form_DEPT_CD_RO}" required="${form_DEPT_CD_R}" />
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
                <e:field>
                    <e:inputText id='DEPT_NM' name="DEPT_NM" label='${form_DEPT_NM_N }' value="${formData.DEPT_NM}" width='100%' maxLength='${form_DEPT_NM_M }' required='${form_DEPT_NM_R }' readOnly='${form_DEPT_NM_RO }' disabled='${form_DEPT_NM_D }' visible='${form_DEPT_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="USER_ID" title="${form_USER_ID_N}"/>
                <e:field>
                    <e:inputText id='USER_ID' name="USER_ID" label='${form_USER_ID_N }' value="${formData.USER_ID}" width='100%' maxLength='${form_USER_ID_M }' required='${form_USER_ID_R }' readOnly='${form_USER_ID_RO }' disabled='${form_USER_ID_D }' visible='${form_USER_ID_V }'/>
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:inputText id='USER_NM' name="USER_NM" label='${form_USER_NM_N }' value="${formData.USER_NM}" width='100%' maxLength='${form_USER_NM_M }' required='${form_USER_NM_R }' readOnly='${form_USER_NM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_USER_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id='TEL_NUM' name="TEL_NUM" label='${form_TEL_NUM_N }' value="${formData.TEL_NUM}" width='100%' maxLength='${form_TEL_NUM_M }' required='${form_TEL_NUM_R }' readOnly='${form_TEL_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' onChange="checkTelNo" visible='${form_TEL_NUM_V }' data="TEL_NUM" />
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id='EMAIL' name="EMAIL" label='${form_EMAIL_N }' value="${formData.EMAIL}" width='100%' maxLength='${form_EMAIL_M }' required='${form_EMAIL_R }' readOnly='${form_EMAIL_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_EMAIL_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"/>
                <e:field>
                    <e:inputText id='FAX_NUM' name="FAX_NUM" label='${form_FAX_NUM_N }' value="${formData.FAX_NUM}" width='100%' maxLength='${form_FAX_NUM_M }' required='${form_FAX_NUM_R }' readOnly='${form_FAX_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' onChange="checkTelNo" visible='${form_FAX_NUM_V }'  data="FAX_NUM" />
                </e:field>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"/>
                <e:field>
                    <e:inputText id='CELL_NUM' name="CELL_NUM" label='${form_CELL_NUM_N }' value="${formData.CELL_NUM}" width='100%' maxLength='${form_CELL_NUM_M }' required='${form_CELL_NUM_R }' readOnly='${form_CELL_NUM_RO }' disabled='${ses.userType eq "X" ? true : false}' onChange="checkCellNo" visible='${form_CELL_NUM_V }'/>
                </e:field>

                <e:inputHidden id='LANG_CD' name="LANG_CD" value="${ses.langCd}"/>
                <e:inputHidden id='COUNTRY_CD' name="COUNTRY_CD" value="${ses.countryCd}"/>
                <%--<e:inputHidden id='GMT_CD' name="GMT_CD" value="${ses.gmtCd}"/>--%>
                <e:inputHidden id='USER_TYPE' name="GMT_CD" value="${ses.userType}"/>
            </e:row>
            <e:row>
                <e:label for="POSITION_NM" title="${form_POSITION_NM_N}"/>
                <e:field>
                    <e:inputText id='POSITION_NM' name="POSITION_NM" label='${form_POSITION_NM_N }' value="${formData.POSITION_NM}" width='100%' maxLength='${form_POSITION_NM_M }' required='${form_POSITION_NM_R }' readOnly='${form_POSITION_NM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_POSITION_NM_V }'/>
                </e:field>
                <e:label for="DUTY_NM" title="${form_DUTY_NM_N}"/>
                <e:field>
                    <e:inputText id='DUTY_NM' name="DUTY_NM" label='${form_DUTY_NM_N }' value="${formData.DUTY_NM}" width='100%' maxLength='${form_DUTY_NM_M }' required='${form_DUTY_NM_R }' readOnly='${form_DUTY_NM_RO }' disabled='${ses.userType eq "X" ? true : false}' visible='${form_DUTY_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="EMPLOYEE_NO" title="${form_EMPLOYEE_NO_N}"/>
                <e:field>
                    <e:inputText id="EMPLOYEE_NO" name="EMPLOYEE_NO" value="${formData.EMPLOYEE_NO}" width="${form_EMPLOYEE_NO_W}" maxLength="${form_EMPLOYEE_NO_M}" disabled="${form_EMPLOYEE_NO_D}" readOnly="${form_EMPLOYEE_NO_RO}" required="${form_EMPLOYEE_NO_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="AGREE_YN" title="${form_AGREE_YN_N}"/>
                <e:field>
                    <e:inputText id="AGREE_YN" name="AGREE_YN" value="${formData.AGREE_YN}" width="${form_AGREE_YN_W}" maxLength="${form_AGREE_YN_M}" disabled="${form_AGREE_YN_D}" readOnly="${form_AGREE_YN_RO}" required="${form_AGREE_YN_R}"/>
                </e:field>
            </e:row>
            <e:inputHidden id="SMS_FLAG" name="SMS_FLAG" value="${formData.SMS_FLAG}"/> <%--options="${smsFlagOptions}" width="${form_SMS_FLAG_W}" disabled="${form_SMS_FLAG_D}" readOnly="${form_SMS_FLAG_RO}" required="${form_SMS_FLAG_R}" placeHolder="" usePlaceHolder="false"/>--%>
            <e:inputHidden id="MAIL_FLAG" name="MAIL_FLAG" value="${formData.MAIL_FLAG}"/> <%--options="${mailFlagOptions}" width="${form_MAIL_FLAG_W}" disabled="${form_MAIL_FLAG_D}" readOnly="${form_MAIL_FLAG_RO}" required="${form_MAIL_FLAG_R}" placeHolder="" usePlaceHolder="false"/>--%>
            <%--<e:row>
                <e:label for="SMS_FLAG" title="${form_SMS_FLAG_N}"/>
                <e:field>

                </e:field>
                <e:label for="MAIL_FLAG" title="${form_MAIL_FLAG_N}"/>
                <e:field>

                </e:field>
            </e:row>--%>
            <e:row>
                <e:label for="MOD_USER_NM" title="${form_MOD_USER_NM_N}" />
                <e:field>
                    <e:inputText id="MOD_USER_NM" name="MOD_USER_NM" value="${formData.MOD_USER_NM}" width="${form_MOD_USER_NM_W}" maxLength="${form_MOD_USER_NM_M}" disabled="${form_MOD_USER_NM_D}" readOnly="${form_MOD_USER_NM_RO}" required="${form_MOD_USER_NM_R}" />
                </e:field>
                <e:label for="MOD_DATE" title="${form_MOD_DATE_N}" />
                <e:field>
                    <e:inputText id="MOD_DATE" name="MOD_DATE" value="${formData.MOD_DATE}" width="${form_MOD_DATE_W}" maxLength="${form_MOD_DATE_M}" disabled="${form_MOD_DATE_D}" readOnly="${form_MOD_DATE_RO}" required="${form_MOD_DATE_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
            <%--<e:row>--%>
            <%--<e:label for="USER_DATE_FORMAT_CD" title="${form_USER_DATE_FORMAT_CD_N}"/>--%>
            <%--<e:field>--%>
            <e:select id='USER_DATE_FORMAT_CD' name="USER_DATE_FORMAT_CD" value="${formData.USER_DATE_FORMAT_CD}"  options="${userDateFormat}" label='${form_USER_DATE_FORMAT_CD_N }' width='0' required='${form_USER_DATE_FORMAT_CD_R }' readOnly='${form_USER_DATE_FORMAT_CD_RO }' disabled='${form_USER_DATE_FORMAT_CD_D }' visible='${form_USER_DATE_FORMAT_CD_V }' placeHolder='${placeHolder }'>
            </e:select>
            <%--<e:label for="USER_NUMBER_FORMAT_CD" title="${form_USER_NUMBER_FORMAT_CD_N}"/>--%>
            <%--<e:field>--%>
            <e:select id='USER_NUMBER_FORMAT_CD' name="USER_NUMBER_FORMAT_CD" value="${formData.USER_NUMBER_FORMAT_CD}" options="${numCd}" label='${form_USER_NUMBER_FORMAT_CD_N }' width='0' required='${form_USER_NUMBER_FORMAT_CD_R }' readOnly='${form_USER_NUMBER_FORMAT_CD_RO }' disabled='${form_USER_NUMBER_FORMAT_CD_D }' visible='${form_USER_NUMBER_FORMAT_CD_V }' placeHolder='${placeHolder }'>
            </e:select>
            <%--</e:field>--%>

        <%--<e:title title="${BMY01_020_TITLE2}" width="100%"/>
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
                    <e:inputPassword id='PASSWORD_CHECK1' name="PASSWORD_CHECK1" label='${form_PASSWORD_CHECK1_N }' width='100%' required='${form_PASSWORD_CHECK1_R }' readOnly='${form_PASSWORD_CHECK1_RO }' disabled='${form_PASSWORD_CHECK1_D }' visible='${form_PASSWORD_CHECK1_V }' maxLength="${form_PASSWORD_CHECK1_M}" onChange="CheckCall" data="1"/>
                </e:field>
                <e:label for="PASSWORD_CHECK2" title="${form_PASSWORD_CHECK2_N}"/>
                <e:field>
                    <e:inputPassword id='PASSWORD_CHECK2' name="PASSWORD_CHECK2" label='${form_PASSWORD_CHECK2_N }' width='100%' required='${form_PASSWORD_CHECK2_R }' readOnly='${form_PASSWORD_CHECK2_RO }' disabled='${form_PASSWORD_CHECK2_D }' visible='${form_PASSWORD_CHECK2_V }' maxLength="${form_PASSWORD_CHECK2_M}" onChange="CheckCall" data="2"/>
                </e:field>
            </e:row>
        </e:searchPanel>--%>

        <e:searchPanel id="custform7" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:panel id="custanel7" height="fit" width="100%">
                <e:title title="${BMY01_020_CAPTION8}" depth="1"/>
            </e:panel>
            <e:gridPanel id="grid" name="grid" gridType="${_gridType}" width="100%" height="300px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        </e:searchPanel>

    </e:window>
</e:ui>
