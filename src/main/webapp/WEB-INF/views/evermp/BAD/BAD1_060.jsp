<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/BAD/BAD1/";
        
        function init() {
            // if (회계관리번호 != "") 고객사명, 사업자등록번호, 종사업장번호, 법인등록번호, 설립일자, 우편번호, 주소, 상세주소, 대표자명, 업태, 종목 = disabled 
            if( !EVF.isEmpty(EVF.V("ACC_NUM")) ) {
            	EVF.C('CUST_NM').setDisabled(true);
            	EVF.C('IRS_SUB_NUM').setDisabled(true);
            	EVF.C('COMPANY_REG_NUM').setDisabled(true);
            	EVF.C('FOUNDATION_DATE').setDisabled(true);
            	EVF.C('CEO_USER_NM').setDisabled(true);
            	EVF.C('HQ_ZIP_CD').setDisabled(true);
            	EVF.C('HQ_ADDR_1').setDisabled(true);
            	EVF.C('HQ_ADDR_2').setDisabled(true);
            	EVF.C('BUSINESS_TYPE').setDisabled(true);
            	EVF.C('INDUSTRY_TYPE').setDisabled(true);
            	EVF.C('DEAL_APRV_DATE').setDisabled(true);
            }
            // 사용자 id가 있는 경우 id는 수정 불가
            if( !EVF.isEmpty(EVF.V("USER_ID_OLD")) ) {
                EVF.C('USER_ID').setDisabled(true);
            }
        }

        function doSave() {
            var store = new EVF.Store();
			
            if( EVF.C("USER_ID_OLD").getValue() == "" ) {
            	EVF.C('PASSWORD').setRequired(true);
            	EVF.C('PASSWORD_CHECK').setRequired(true);
            }
            
            if(!store.validate()) { return; }
            
            var irsSubNum = everString.lrTrim(EVF.C('IRS_SUB_NUM').getValue());
            /*  종사업장 번호 주석처리
            if( !everString.isNumber(irsSubNum) || irsSubNum.length != 4) {
            	alert("${BAD1_060_003}");
            	EVF.C('IRS_SUB_NUM').setFocus();
            	return;
            }
             */

            // 신규 저장시 아이디 중복체크
            if( EVF.C("USER_ID_OLD").getValue() == "" ) {
            	docheckDup();
            }
            
            var pass  = everString.lrTrim(EVF.C('PASSWORD').getValue());
            var passc = everString.lrTrim(EVF.C('PASSWORD_CHECK').getValue());
            if( pass != "" || passc != "" ) {
            	if( pass != passc ) {
                	alert("${msg.M0028}");
                	return;
            	}
            }
            
            if(!confirm("${msg.M0012}")) { return; }
			
         	// 수정시 대표자명, 우편번호, 주소, 상세주소, 고객사판가정율이 변경되는 경우 변경사유 입력
            if( EVF.V("CUST_CD") != "" ) {
            	if( everString.lrTrim(EVF.V("CEO_USER_NM_ORI"))!=everString.lrTrim(EVF.V("CEO_USER_NM")) || everString.lrTrim(EVF.V("HQ_ZIP_CD_ORI"))!=everString.lrTrim(EVF.V("HQ_ZIP_CD"))
            	 || everString.lrTrim(EVF.V("HQ_ADDR_1_ORI"))!=everString.lrTrim(EVF.V("HQ_ADDR_1"))     || everString.lrTrim(EVF.V("HQ_ADDR_2_ORI"))!=everString.lrTrim(EVF.V("HQ_ADDR_2"))
            	) {
            		var param = {
              				title : '대표자명/우편번호/주소/판가정율 변경사유',
              				callbackFunction : 'setApproval',
              				detailView : false
              			};
            	    everPopup.commonTextInput(param);
            	} else {
            		setApproval(null);
            	}
            } else {
            	setApproval(null);
            }
        }
		
        function setApproval(data) {
        	var store = new EVF.Store();
        	
        	if( data != undefined && data != null ) {
        		EVF.C("CHANGE_REMARK").setValue(data.message);
        	}
        	
        	store.doFileUpload(function() {
                store.load(baseUrl + 'bad1060_doSave', function () {
                    alert(this.getResponseMessage());
                    window.location.href = '/evermp/BAD/BAD1/BAD1_060/view.so?';
                });
            });
        }
        
        function checkCompanyRegNum(){
            if( !isCompanyRegNum(EVF.C("COMPANY_REG_NUM").getValue()) ) {
                alert("${msg.M0126}");
                EVF.C("COMPANY_REG_NUM").setValue("");
                EVF.C('COMPANY_REG_NUM').setFocus();
            }
        }

        function isCompanyRegNum(bubinNum) {
            var as_Biz_no= String(bubinNum);
            var isNum = true;
            var I_TEMP_SUM = 0 ;
            var I_TEMP = 0;
            var S_TEMP;
            var I_CHK_DIGIT = 0;

            if(bubinNum.length != 13) {
                return false;
            }

            for(index01 = 1; index01 < 13; index01++) {
                var i = index01 % 2;
                var j = 0;

                if(i == 1) j = 1;
                else if( i == 0) j = 2;

                I_TEMP_SUM = I_TEMP_SUM + parseInt(as_Biz_no.substring(index01-1, index01),10) * j;
            }

            I_CHK_DIGIT= I_TEMP_SUM%10 ;
            if(I_CHK_DIGIT != 0 ) I_CHK_DIGIT = 10 - I_CHK_DIGIT;

            if (as_Biz_no.substring(12,13) != String(I_CHK_DIGIT)) return false;
            return true ;
        }
        
        function checkTelNo() {
			var checkType = this.getData();
			if( checkType == "TEL_NUM" ) {
				if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
					alert("${msg.M0128}");
					EVF.C("TEL_NUM").setValue("");
					EVF.C('TEL_NUM').setFocus();
				}
			}
			if( checkType == "FAX_NUM" ) {
				if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
					alert("${msg.M0128}");
					EVF.C("FAX_NUM").setValue("");
					EVF.C('FAX_NUM').setFocus();
				}
			}
            if( checkType == "RECIPIENT_TEL_NUM" ) {
                if(!everString.isTel(EVF.C("RECIPIENT_TEL_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("RECIPIENT_TEL_NUM").setValue("");
                    EVF.C('RECIPIENT_TEL_NUM').setFocus();
                }
            }
            if( checkType == "RECIPIENT_FAX_NUM" ) {
                if(!everString.isTel(EVF.C("RECIPIENT_FAX_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("RECIPIENT_FAX_NUM").setValue("");
                    EVF.C('RECIPIENT_FAX_NUM').setFocus();
                }
            }
		}


        function checkCellNo() {
            var CellNum = EVF.V("RECIPIENT_CELL_NUM");
            var rgEx = /(01[016789])[-](\d{4}|\d{3})[-]\d{4}$/g;
            var chkFlg = rgEx.test(CellNum);
            if(!chkFlg){
                EVF.C("RECIPIENT_CELL_NUM").setValue("");
                EVF.C('RECIPIENT_CELL_NUM').setFocus();
                return alert("${msg.M0128}");
            }
        }
        
        // 담당자id 중복체크
        function docheckDup() {
        	var store = new EVF.Store();
	        store.load(baseUrl + 'bad1060_checkDupCustUser', function() {
	        	if(this.getParameter("USER_POSSIBLE_FLAG") == "N") {
	        		return alert("${BAD1_060_001}");
	        	}
	        }, false);
        }
        
        // 총자산 자동계산 (총자산 = 총부채 + 총자본)
        function setTotAsset() {
			var totSdept = eval(EVF.C("TOT_SDEPT").getValue()); // 총부채
			var totFund  = eval(EVF.C("TOT_FUND").getValue());  // 총자본

			var totAsset = 0;
			if(totSdept != null && totSdept != "") { totAsset = totAsset + totSdept; }
			if(totFund  != null && totFund != "")  { totAsset = totAsset + totFund; }

			EVF.C("TOT_ASSET").setValue(totAsset);
		}
        
      	//첨부파일갯수제어-------------------------
        function onFileAdd() {
            if( EVF.C('ATTACH_FILE_NUM').getFileCount() > 1 ){
                return alert("${BAD1_060_001}");
            }
            if( EVF.C('ATTACH_FILE1_NUM').getFileCount() > 1 ){
                return alert("${BAD1_060_001}");
            }
            if( EVF.C('ATTACH_FILE2_NUM').getFileCount() > 1 ){
                return alert("${BAD1_060_001}");
            }
            if( EVF.C('ATTACH_FILE3_NUM').getFileCount() > 1 ){
                return alert("${BAD1_060_001}");
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
                EVF.C("HQ_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('HQ_ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('HQ_ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('HQ_ADDR_2').setFocus();
            }
        }
        
        function searchZipCd3() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode3",
                modalYn : false
            };
            //everPopup.openWindowPopup(url, 700, 600, param);
            everPopup.jusoPop(url, param);
        }

        function setZipCode3(zipcd) {
            if (zipcd.ZIP_CD != "") {
                EVF.C("UR_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('UR_ADDR1').setValue(zipcd.ADDR1);
				EVF.C('UR_ADDR2').setValue(zipcd.ADDR2);
                EVF.C('UR_ADDR2').setFocus();
            }
        }
        
        function getDept() {
        	var param = {
        			CUST_CD : EVF.C("CUST_CD").getValue(),
                    callBackFunction : "setDept"
                };
                everPopup.openCommonPopup(param, 'SP0084');
        }

        function setDept(data) {
			EVF.C("DEPT_CD").setValue(data.DEPT_CD);
			EVF.C('DEPT_NM').setValue(data.DEPT_NM);
        }
		
        function getBudgetDept() {
        	var param = {
        			CUST_CD : EVF.C("CUST_CD").getValue(),
                    callBackFunction : "setBudgetDept"
                };
                everPopup.openCommonPopup(param, 'SP0087');
        }

        function setBudgetDept(data) {
			EVF.C("BUDGET_DEPT_CD").setValue(data.DEPT_CD);
			EVF.C('BUDGET_DEPT_NM').setValue(data.DEPT_NM);
        }
        
        // 비밀번호 체크
        function CheckCall(){
            var str;
            if( this.data == "1" ) {
                str = EVF.V("PASSWORD");
            } else {
                str = EVF.V("PASSWORD_CHECK");
            }
            
            if( !chkPwd(str) ){
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

            if( reg_pwd.test(str) || reg_pwd2.test(str)|| reg_pwd3.test(str)|| reg_pwd4.test(str) ){
            } else {
                alert("${BAD1_060_021}");
                return false;
            }
            if(str.length >20){
                alert("${BAD1_060_021}");
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
                alert("${BAD1_060_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${BAD1_060_023}");
                return false;
            }

            return true;
        }
        
        // 템플릿 다운로드
        function doTempletDown() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BS01_002');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);
            }, false);
        }
        
        // 첨부파일 양식 다운로드
        function doFileTempletDown() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BS01_002A');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);
            }, false);
        }


        function getBudgetDept() {

            if(EVF.V("CUST_CD")==""){
                alert("${BS01_002_024}");
                return;
            }

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setBudgetDept",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : EVF.C("CUST_CD").getValue(),
                'custNm' : EVF.C("CUST_NM").getValue()
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");


        }
        function setBudgetDept(data) {
            data = JSON.parse(data);
            EVF.V('BUDGET_DEPT_CD', data.ITEM_CLS3);
            EVF.V('BUDGET_DEPT_NM', data.ITEM_CLS_NM);
        }


	</script>
    
    <e:window id="BAD1_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <!-- 1. 고객 일반정보 -->
        <%--<e:panel id="leftP1" height="fit" width="30%">
            <e:title title="${BAD1_060_CAPTION1 }" depth="1"/>
        </e:panel>--%>
        
        <%--<e:panel id="rightP1" height="fit" width="70%">--%>
		<e:buttonBar id="buttonBar1" align="right" width="100%" title="${BAD1_060_CAPTION1 }">
			<e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }" visible="${Update_V}" onClick="doSave" data="U" />
		</e:buttonBar>
        <%--</e:panel>--%>
        
        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
        	<e:inputHidden id="CEO_USER_NM_ORI" name="CEO_USER_NM_ORI" value="${formData.CEO_USER_NM }" /> <!-- 대표자명2------------------- -->
        	<e:inputHidden id="HQ_ZIP_CD_ORI" name="HQ_ZIP_CD_ORI" value="${formData.HQ_ZIP_CD }" /> <!-- 우편번호 -->
        	<e:inputHidden id="HQ_ADDR_1_ORI" name="HQ_ADDR_1_ORI" value="${formData.HQ_ADDR_1 }" /> <!-- 주소 -->
        	<e:inputHidden id="HQ_ADDR_2_ORI" name="HQ_ADDR_2_ORI" value="${formData.HQ_ADDR_2 }" /> <!-- 상세주소 -->
			<e:inputHidden id="TRUNC_TYPE" name="TRUNC_TYPE" value="${formData.TRUNC_TYPE}"/>
			<e:inputHidden id="ERP_IF_FLAG" name="ERP_IF_FLAG" value="${formData.ERP_IF_FLAG}" />
			<e:inputHidden id="CASH_CD" name="CASH_CD" value="${formData.CASH_CD}" />
			<e:inputHidden id="PAY_CONDITION" name="PAY_CONDITION" value="${formData.PAY_CONDITION}" />
			<e:inputHidden id="PAY_DAY" name="PAY_DAY" value="${formData.PAY_DAY}" />
			
            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}" />
				<e:field>
					<e:inputText id="CUST_CD" name="CUST_CD" value="${formData.CUST_CD }" width="${form_CUST_CD_W}" maxLength="${form_CUST_CD_M}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
				</e:field>
				<e:label for="CUST_NM" title="${form_CUST_NM_N}" />
				<e:field>
					<e:inputText id="CUST_NM" name="CUST_NM" value="${formData.CUST_NM }" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" style="${imeMode}" />
				</e:field>
				<e:label for="CUST_ENG_NM" title="${form_CUST_ENG_NM_N}" />
				<e:field>
					<e:inputText id="CUST_ENG_NM" name="CUST_ENG_NM" value="${formData.CUST_ENG_NM }" width="${form_CUST_ENG_NM_W}" maxLength="${form_CUST_ENG_NM_M}" disabled="${form_CUST_ENG_NM_D}" readOnly="${form_CUST_ENG_NM_RO}" required="${form_CUST_ENG_NM_R}" style="${imeMode}" />
				</e:field>
            </e:row>
 			<e:row>
				<e:label for="COMPANY_TYPE" title="${form_COMPANY_TYPE_N}"/>
				<e:field>
					<e:select id="COMPANY_TYPE" name="COMPANY_TYPE" value="${formData.COMPANY_TYPE }" options="${companyTypeOptions}" width="${form_COMPANY_TYPE_W}" disabled="${form_COMPANY_TYPE_D}" readOnly="${form_COMPANY_TYPE_RO}" required="${form_COMPANY_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="CORP_TYPE" title="${form_CORP_TYPE_N}"/>
				<e:field>
					<e:select id="CORP_TYPE" name="CORP_TYPE" value="${formData.CORP_TYPE }" options="${corpTypeOptions}" width="${form_CORP_TYPE_W}" disabled="${form_CORP_TYPE_D}" readOnly="${form_CORP_TYPE_RO}" required="${form_CORP_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="SCALE_TYPE" title="${form_SCALE_TYPE_N}"/>
				<e:field>
					<e:select id="SCALE_TYPE" name="SCALE_TYPE" value="${formData.SCALE_TYPE }" options="${scaleTypeOptions}" width="${form_SCALE_TYPE_W}" disabled="${form_SCALE_TYPE_D}" readOnly="${form_SCALE_TYPE_RO}" required="${form_SCALE_TYPE_R}" placeHolder="" />
				</e:field>
 			</e:row>
            <e:row>
				<e:label for="IRS_NUM" title="${form_IRS_NUM_N}" />
				<e:field>
					<e:inputText id="IRS_NUM" name="IRS_NUM" placeHolder="${BAD1_060_INPUT_T1 }" value="${formData.IRS_NUM }" width="${form_IRS_NUM_W}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
				</e:field>
				<e:label for="IRS_SUB_NUM" title="${form_IRS_SUB_NUM_N}" />
				<e:field>
					<e:inputText id="IRS_SUB_NUM" name="IRS_SUB_NUM" value="${formData.IRS_SUB_NUM }" width="95px" maxLength="${form_IRS_SUB_NUM_M}" disabled="${form_IRS_SUB_NUM_D}" readOnly="${form_IRS_SUB_NUM_RO}" required="${form_IRS_SUB_NUM_R}" />
					<e:text>${BAD1_060_TEXT4 }</e:text>
				</e:field>
				<e:label for="IRS_SUB_NM" title="${form_IRS_SUB_NM_N}" />
				<e:field>
					<e:inputText id="IRS_SUB_NM" name="IRS_SUB_NM" value="${formData.IRS_SUB_NM }" width="${form_IRS_SUB_NM_W}" maxLength="${form_IRS_SUB_NM_M}" disabled="${form_IRS_SUB_NM_D}" readOnly="${form_IRS_SUB_NM_RO}" required="${form_IRS_SUB_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="COMPANY_REG_NUM" title="${form_COMPANY_REG_NUM_N}" />
				<e:field>
					<e:inputText id="COMPANY_REG_NUM" name="COMPANY_REG_NUM" placeHolder="${BAD1_060_INPUT_T1 }" value="${formData.COMPANY_REG_NUM }" width="${form_COMPANY_REG_NUM_W}" maxLength="${form_COMPANY_REG_NUM_M}" disabled="${form_COMPANY_REG_NUM_D}" readOnly="${form_COMPANY_REG_NUM_RO}" required="${form_COMPANY_REG_NUM_R}" style="${imeMode}" onChange="checkCompanyRegNum" />
				</e:field>
				<e:label for="FOUNDATION_DATE" title="${form_FOUNDATION_DATE_N}"/>
				<e:field>
					<e:inputDate id="FOUNDATION_DATE" name="FOUNDATION_DATE" value="${formData.FOUNDATION_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_FOUNDATION_DATE_R}" disabled="${form_FOUNDATION_DATE_D}" readOnly="${form_FOUNDATION_DATE_RO}" />
				</e:field>
				<e:label for="DEAL_APRV_DATE" title="${form_DEAL_APRV_DATE_N}"/>
				<e:field>
					<e:inputDate id="DEAL_APRV_DATE" name="DEAL_APRV_DATE" value="${formData.DEAL_APRV_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_DEAL_APRV_DATE_R}" disabled="${form_DEAL_APRV_DATE_D}" readOnly="${form_DEAL_APRV_DATE_RO}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="HQ_ZIP_CD" title="${form_HQ_ZIP_CD_N}"/>
                <e:field>
                    <e:search id="HQ_ZIP_CD" name="HQ_ZIP_CD" value="${formData.HQ_ZIP_CD }" width="${form_HQ_ZIP_CD_W}" maxLength="7" onIconClick="searchZipCd" disabled="${form_HQ_ZIP_CD_D}" readOnly="true" required="${form_HQ_ZIP_CD_R}" />
                </e:field>
                <e:label for="HQ_ADDR_1" title="${form_HQ_ADDR_1_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="HQ_ADDR_1" name="HQ_ADDR_1" value="${formData.HQ_ADDR_1 }" width="${form_HQ_ADDR_1_W}" maxLength="${form_HQ_ADDR_1_M}" disabled="${form_HQ_ADDR_1_D}" readOnly="${form_HQ_ADDR_1_RO}" required="${form_HQ_ADDR_1_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
				<e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}" />
				<e:field>
					<e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="${formData.CEO_USER_NM }" width="${form_CEO_USER_NM_W}" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" />
				</e:field>
				<e:label for="HQ_ADDR_2" title="${form_HQ_ADDR_2_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="HQ_ADDR_2" name="HQ_ADDR_2" value="${formData.HQ_ADDR_2 }" width="${form_HQ_ADDR_2_W}" maxLength="${form_HQ_ADDR_2_M}" disabled="${form_HQ_ADDR_2_D}" readOnly="${form_HQ_ADDR_2_RO}" required="${form_HQ_ADDR_2_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
				<e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}" />
				<e:field>
					<e:inputText id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="${formData.BUSINESS_TYPE }" width="${form_BUSINESS_TYPE_W}" maxLength="${form_BUSINESS_TYPE_M}" disabled="${form_BUSINESS_TYPE_D}" readOnly="${form_BUSINESS_TYPE_RO}" required="${form_BUSINESS_TYPE_R}" />
				</e:field>
				<e:label for="INDUSTRY_TYPE" title="${form_INDUSTRY_TYPE_N}" />
				<e:field>
					<e:inputText id="INDUSTRY_TYPE" name="INDUSTRY_TYPE" value="${formData.INDUSTRY_TYPE }" width="${form_INDUSTRY_TYPE_W}" maxLength="${form_INDUSTRY_TYPE_M}" disabled="${form_INDUSTRY_TYPE_D}" readOnly="${form_INDUSTRY_TYPE_RO}" required="${form_INDUSTRY_TYPE_R}" />
				</e:field>
				<e:label for="EMPLOYEE_CNT" title="${form_EMPLOYEE_CNT_N}"/>
				<e:field>
					<e:inputNumber id="EMPLOYEE_CNT" name="EMPLOYEE_CNT" value="${formData.EMPLOYEE_CNT }" width="60%" maxValue="${form_EMPLOYEE_CNT_M}" decimalPlace="${form_EMPLOYEE_CNT_NF}" disabled="${form_EMPLOYEE_CNT_D}" readOnly="${form_EMPLOYEE_CNT_RO}" required="${form_EMPLOYEE_CNT_R}" />
					<e:text>${BAD1_060_TEXT1 }</e:text>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="TEL_NUM" title="${form_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" placeHolder="${BAD1_060_INPUT_T2 }" value="${formData.TEL_NUM }" width="${form_TEL_NUM_W}" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" onChange="checkTelNo" data="TEL_NUM" />
				</e:field>
				<e:label for="FAX_NUM" title="${form_FAX_NUM_N}" />
				<e:field>
					<e:inputText id="FAX_NUM" name="FAX_NUM" placeHolder="${BAD1_060_INPUT_T2 }" value="${formData.FAX_NUM }" width="${form_FAX_NUM_W}" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" onChange="checkTelNo" data="FAX_NUM" />
				</e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" placeHolder="${BAD1_060_INPUT_T3 }" value="${formData.EMAIL }" width="${form_EMAIL_W}" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
			<e:row>
				<e:label for="HOMEPAGE_URL" title="${form_HOMEPAGE_URL_N}" />
				<e:field>
					<e:inputText id="HOMEPAGE_URL" name="HOMEPAGE_URL" value="${formData.HOMEPAGE_URL}" width="${form_HOMEPAGE_URL_W}" maxLength="${form_HOMEPAGE_URL_M}" disabled="${form_HOMEPAGE_URL_D}" readOnly="${form_HOMEPAGE_URL_RO}" required="${form_HOMEPAGE_URL_R}" />
				</e:field>
				<%--
				<e:label for="DELY_TYPE" title="${form_DELY_TYPE_N}"/>
				<e:field>
					<e:checkGroup id="DELY_TYPE" name="DELY_TYPE" value="${formData.DELY_TYPE}" width="100%" disabled="${form_DELY_TYPE_D}" readOnly="${form_DELY_TYPE_RO}" required="${form_DELY_TYPE_R}">
                        <c:forEach var="deal" items="${deliberyType}" varStatus="vs">
                            <e:check id="DELY_TYPE_${deal.value}" name="DELY_TYPE_${deal.value}" value="${deal.value}" label="${deal.text}" disabled="${form_DELY_TYPE_D}" readOnly="${form_DELY_TYPE_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
				</e:field>
				--%>
				<e:label for="IPO_FLAG" title="${form_IPO_FLAG_N}"/>
				<e:field>
					<e:select id="IPO_FLAG" name="IPO_FLAG" value="${formData.IPO_FLAG }" options="${ipoFlagOptions}" width="${form_IPO_FLAG_W}" disabled="${form_IPO_FLAG_D}" readOnly="${form_IPO_FLAG_RO}" required="${form_IPO_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<e:label for="IPO_DATE" title="${form_IPO_DATE_N}"/>
				<e:field>
					<e:inputDate id="IPO_DATE" name="IPO_DATE" value="${formData.IPO_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_IPO_DATE_R}" disabled="${form_IPO_DATE_D}" readOnly="${form_IPO_DATE_RO}" />
				</e:field>
			</e:row>
			<%--
            <e:row>
                <e:label for="REGION_CD" title="${form_REGION_CD_N}"/>
                <e:field colSpan="5">
                    <e:checkGroup id="REGION_CD" name="REGION_CD" value="${formData.REGION_CD}" width="100%" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" required="${form_REGION_CD_R}">
                        <c:forEach var="item" items="${regionCd}" varStatus="vs">
                            <e:check id="REGION_CD_${item.value}" name="REGION_CD_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
            </e:row>
            --%>
            <e:row>
				<e:label for="CHANGE_REMARK" title="${form_CHANGE_REMARK_N}" />
				<e:field>
					<e:inputText id="CHANGE_REMARK" name="CHANGE_REMARK" value="${formData.CHANGE_REMARK }" width="${form_CHANGE_REMARK_W}" maxLength="${form_CHANGE_REMARK_M}" disabled="${form_CHANGE_REMARK_D}" readOnly="${form_CHANGE_REMARK_RO}" required="${form_CHANGE_REMARK_R}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD }" />
					<e:text>${formData.PROGRESS_NM }&nbsp;</e:text>
				</e:field>
				<e:label for="MOD_DATE" title="${form_MOD_DATE_N}"/>
				<e:field>
					<e:text>${formData.MOD_DATE }&nbsp;</e:text>
				</e:field>
            </e:row>
        </e:searchPanel>
        
        <!-- 2. 관리정보 : hidden -->
		<e:inputHidden id="RELAT_YN" name="RELAT_YN" value="${formData.RELAT_YN }" />
		<e:inputHidden id="CREDIT_AGENCY_NM" name="CREDIT_AGENCY_NM" value="${formData.CREDIT_AGENCY_NM }" />
		<e:inputHidden id="CREDIT_CD" name="CREDIT_CD" value="${formData.CREDIT_CD }" />
		<e:inputHidden id="CREDIT_LIMIT_AMT" name="CREDIT_LIMIT_AMT" value="${formData.CREDIT_LIMIT_AMT }" />
		<e:inputHidden id="MANAGE_ID" name="MANAGE_ID" value="${formData.MANAGE_ID }" />
		<e:inputHidden id="TAX_USER_ID" name="TAX_USER_ID" value="${formData.TAX_USER_ID }" />
		<e:inputHidden id="DEAL_TRADE_CD" name="DEAL_TRADE_CD" value="${formData.DEAL_TRADE_CD }" />
        <e:inputHidden id="PROFIT_RATIO" name="PROFIT_RATIO" value="${formData.PROFIT_RATIO }" />
        <e:inputHidden id="APPROVE_USE_FLAG" name="APPROVE_USE_FLAG" value="${formData.APPROVE_USE_FLAG }" />
        <e:inputHidden id="MY_SITE_FLAG" name="MY_SITE_FLAG" value="${formData.MY_SITE_FLAG }" />
        <e:inputHidden id="BUDGET_USE_FLAG" name="BUDGET_USE_FLAG" value="${formData.BUDGET_USE_FLAG }" />
        <e:inputHidden id="AUTO_PO_FLAG" name="AUTO_PO_FLAG" value="${formData.AUTO_PO_FLAG }" />
        <e:inputHidden id="ACC_NUM" name="ACC_NUM" value="${formData.ACC_NUM }" />
        <e:inputHidden id="MNG_COM_TAX_YN" name="MNG_COM_TAX_YN" value="${formData.MNG_COM_TAX_YN }" />
        <e:inputHidden id="TAX_ASP_NM" name="TAX_ASP_NM" value="${formData.TAX_ASP_NM }" />
        <e:inputHidden id="TAX_SEND_TYPE" name="TAX_SEND_TYPE" value="${formData.TAX_SEND_TYPE }" />
        <e:inputHidden id="STOP_FLAG" name="STOP_FLAG" value="${formData.STOP_FLAG }" />
        <e:inputHidden id="STOP_REMARK" name="STOP_REMARK" value="${formData.STOP_REMARK }" />
        
        <!-- 3. 첨부파일 -->
        <e:panel id="leftP3" height="25px" width="40%">
            <e:title title="${BAD1_060_CAPTION2}" depth="1" />
        </e:panel>
        	
            <e:buttonBar id="buttonBar3" align="right" width="100%">
            	<e:button id="doFileTempletDown" name="doFileTempletDown" label="${doFileTempletDown_N}" onClick="doFileTempletDown" disabled="${doFileTempletDown_D}" visible="${doFileTempletDown_V}"/>
            </e:buttonBar>

		<e:searchPanel id="form3" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
			<e:row>
                <e:label for="ATTACH_FILE_NUM" title="${form_ATTACH_FILE_NUM_N}"/>
                <e:field>
               		<e:fileManager id="ATTACH_FILE_NUM" name="ATTACH_FILE_NUM" fileId="${formData.ATTACH_FILE_NUM}" downloadable="true" width="100%" bizType="CUST" height="50px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE_NUM_R}" fileExtension="${fileExtension}" />
                </e:field>
                <e:label for="ATTACH_FILE1_NUM" title="${form_ATTACH_FILE1_NUM_N}"/>
                <e:field>
               		<e:fileManager id="ATTACH_FILE1_NUM" name="ATTACH_FILE1_NUM" fileId="${formData.ATTACH_FILE1_NUM}" downloadable="true" width="100%" bizType="CUST" height="50px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE1_NUM_R}" fileExtension="${fileExtension}" />
                </e:field>
			</e:row>
			<e:row>
				<e:label for="CI_FILE_NUM" title="${form_CI_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="CI_FILE_NUM" name="CI_FILE_NUM" fileId="${formData.CI_FILE_NUM}" downloadable="true" width="100%" bizType="CUST" height="50px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_CI_FILE_NUM_R}" fileExtension="${fileExtension}" />
				</e:field>
				<e:label for="ATTACH_FILE4_NUM" title="${form_ATTACH_FILE4_NUM_N}"/>
                <e:field>
                   	<e:fileManager id="ATTACH_FILE4_NUM" name="ATTACH_FILE4_NUM" fileId="${formData.ATTACH_FILE4_NUM}" downloadable="true" width="100%" bizType="CUST" height="50px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATTACH_FILE4_NUM_R}" fileExtension="${fileExtension}" />
                </e:field>
			</e:row>
		</e:searchPanel>
		
		<!-- 4. 재무정보 : hidden -->
		<e:inputHidden id="STD_YYYY" name="STD_YYYY" value="${formData.STD_YYYY }" />
		<e:inputHidden id="DATA_REF_CD" name="DATA_REF_CD" value="${formData.DATA_REF_CD }" />
		<e:inputHidden id="TOT_ASSET" name="TOT_ASSET" value="${formData.TOT_ASSET }" />
		<e:inputHidden id="TOT_SDEPT" name="TOT_SDEPT" value="${formData.TOT_SDEPT }" />
		<e:inputHidden id="TOT_FUND" name="TOT_FUND" value="${formData.TOT_FUND }" />
		<e:inputHidden id="TOT_SALES" name="TOT_SALES" value="${formData.TOT_SALES }" />
		<e:inputHidden id="BUSINESS_PROFIT" name="BUSINESS_PROFIT" value="${formData.BUSINESS_PROFIT }" />
		<e:inputHidden id="NET_INCOM" name="NET_INCOM" value="${formData.NET_INCOM }" />
		
		<!-- 5. 담당자 정보 -->
		<e:panel id="leftP5" height="25px" width="40%">
            <e:title title="${BAD1_060_CAPTION4}" depth="1" />
        </e:panel>		

		<e:searchPanel id="form5" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
			<e:inputHidden id="USER_ID_OLD" name="USER_ID_OLD" value="${mngUser.USER_ID }" />
			<e:row>
				<e:label for="USER_ID" title="${form_USER_ID_N}" />
				<e:field>
					<e:inputText id="USER_ID" name="USER_ID" value="${mngUser.USER_ID }" width="${form_USER_ID_W}" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
				</e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N}" />
				<e:field>
					<e:inputText id="USER_NM" name="USER_NM" value="${mngUser.USER_NM }" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				</e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
				<e:field>
					<e:inputHidden id="DEPT_CD" name="DEPT_CD" value="${mngUser.DEPT_CD }" />
					<e:search id="DEPT_NM" name="DEPT_NM" value="${mngUser.DEPT_NM }" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" onIconClick="getDept" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PASSWORD" title="${form_PASSWORD_N}" />
				<e:field>
					<e:inputPassword id="PASSWORD" name="PASSWORD" value="" width="${form_PASSWORD_W}" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}" style='ime-mode:inactive' onChange="CheckCall" data="1" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리" />
				</e:field>
				<e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N}" />
				<e:field>
					<e:inputPassword id="PASSWORD_CHECK" name="PASSWORD_CHECK" value="" width="${form_PASSWORD_CHECK_W}" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" style='ime-mode:inactive' onChange="CheckCall" data="2" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리" />
				</e:field>
				<e:label for="BUDGET_DEPT_NM" title="${form_BUDGET_DEPT_NM_N}"/>
				<e:field>
					<e:inputHidden id="BUDGET_DEPT_CD" name="BUDGET_DEPT_CD" value="${mngUser.BUDGET_DEPT_CD }" />
					<e:search id="BUDGET_DEPT_NM" name="BUDGET_DEPT_NM" value="${mngUser.BUDGET_DEPT_NM }" width="${form_BUDGET_DEPT_NM_W}" maxLength="${form_BUDGET_DEPT_NM_M}" onIconClick="getBudgetDept" disabled="${form_BUDGET_DEPT_NM_D}" readOnly="${form_BUDGET_DEPT_NM_RO}" required="${form_BUDGET_DEPT_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="POSITION_NM" title="${form_POSITION_NM_N}" />
				<e:field>
					<e:inputText id="POSITION_NM" name="POSITION_NM" value="${mngUser.POSITION_NM }" width="${form_POSITION_NM_W}" maxLength="${form_POSITION_NM_M}" disabled="${form_POSITION_NM_D}" readOnly="${form_POSITION_NM_RO}" required="${form_POSITION_NM_R}" />
				</e:field>
				<e:label for="DUTY_NM" title="${form_DUTY_NM_N}" />
				<e:field>
					<e:inputText id="DUTY_NM" name="DUTY_NM" value="${mngUser.DUTY_NM }" width="${form_DUTY_NM_W}" maxLength="${form_DUTY_NM_M}" disabled="${form_DUTY_NM_D}" readOnly="${form_DUTY_NM_RO}" required="${form_DUTY_NM_R}" />
				</e:field>
				<e:label for="EMPLOYEE_NO" title="${form_EMPLOYEE_NO_N}" />
				<e:field>
					<e:inputText id="EMPLOYEE_NO" name="EMPLOYEE_NO" value="${mngUser.EMPLOYEE_NO }" width="${form_EMPLOYEE_NO_W}" maxLength="${form_EMPLOYEE_NO_M}" disabled="${form_EMPLOYEE_NO_D}" readOnly="${form_EMPLOYEE_NO_RO}" required="${form_EMPLOYEE_NO_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="RECIPIENT_TEL_NUM" title="${form_RECIPIENT_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${mngUser.RECIPIENT_TEL_NUM }" width="${form_RECIPIENT_TEL_NUM_W}" maxLength="${form_RECIPIENT_TEL_NUM_M}" disabled="${form_RECIPIENT_TEL_NUM_D}" readOnly="${form_RECIPIENT_TEL_NUM_RO}" required="${form_RECIPIENT_TEL_NUM_R}" onChange="checkTelNo" data="RECIPIENT_TEL_NUM" />
				</e:field>
				<e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${mngUser.RECIPIENT_CELL_NUM }" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" onChange="checkCellNo" data="RECIPIENT_CELL_NUM" />
				</e:field>
				<e:label for="RECIPIENT_EMAIL" title="${form_RECIPIENT_EMAIL_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" placeHolder="${BS01_002_INPUT_T3 }" value="${mngUser.RECIPIENT_EMAIL }" width="${form_RECIPIENT_EMAIL_W}" maxLength="${form_RECIPIENT_EMAIL_M}" disabled="${form_RECIPIENT_EMAIL_D}" readOnly="${form_RECIPIENT_EMAIL_RO}" required="${form_RECIPIENT_EMAIL_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="RECIPIENT_FAX_NUM" title="${form_RECIPIENT_FAX_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_FAX_NUM" name="RECIPIENT_FAX_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${mngUser.RECIPIENT_FAX_NUM }" width="${form_RECIPIENT_FAX_NUM_W}" maxLength="${form_RECIPIENT_FAX_NUM_M}" disabled="${form_RECIPIENT_FAX_NUM_D}" readOnly="${form_RECIPIENT_FAX_NUM_RO}" required="${form_RECIPIENT_FAX_NUM_R}" onChange="checkTelNo" data="RECIPIENT_FAX_NUM" />
				</e:field>
				<e:label for="SMS_FLAG" title="${form_SMS_FLAG_N}"/>
				<e:field>
					<e:select id="SMS_FLAG" name="SMS_FLAG" value="${mngUser.SMS_FLAG }" options="${smsFlagOptions}" width="${form_SMS_FLAG_W}" disabled="${form_SMS_FLAG_D}" readOnly="${form_SMS_FLAG_RO}" required="${form_SMS_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<e:label for="MAIL_FLAG" title="${form_MAIL_FLAG_N}"/>
				<e:field>
					<e:select id="MAIL_FLAG" name="MAIL_FLAG" value="${mngUser.MAIL_FLAG }" options="${mailFlagOptions}" width="${form_MAIL_FLAG_W}" disabled="${form_MAIL_FLAG_D}" readOnly="${form_MAIL_FLAG_RO}" required="${form_MAIL_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="USER_AUTO_PO_FLAG" title="${form_USER_AUTO_PO_FLAG_N}"/>
				<e:field>
					<e:select id="USER_AUTO_PO_FLAG" name="USER_AUTO_PO_FLAG" value="${mngUser.USER_AUTO_PO_FLAG }" options="${userAutoPoFlagOptions}" width="${form_USER_AUTO_PO_FLAG_W}" disabled="${form_USER_AUTO_PO_FLAG_D}" readOnly="${form_USER_AUTO_PO_FLAG_RO}" required="${form_USER_AUTO_PO_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="GR_FLAG" title="${form_GR_FLAG_N}"/>
				<e:field>
					<e:select id="GR_FLAG" name="GR_FLAG" value="${mngUser.GR_FLAG }" options="${grFlagOptions}" width="${form_GR_FLAG_W}" disabled="${form_GR_FLAG_D}" readOnly="${form_GR_FLAG_RO}" required="${form_GR_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<e:label for="FINANCIAL_FLAG" title="${form_FINANCIAL_FLAG_N}"/>
				<e:field>
					<e:select id="FINANCIAL_FLAG" name="FINANCIAL_FLAG" value="${mngUser.FINANCIAL_FLAG }" options="${financialFlagOptions}" width="${form_FINANCIAL_FLAG_W}" disabled="${form_FINANCIAL_FLAG_D}" readOnly="${form_FINANCIAL_FLAG_RO}" required="${form_FINANCIAL_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
			</e:row>
		</e:searchPanel>
		
		<br>
    </e:window>
</e:ui>