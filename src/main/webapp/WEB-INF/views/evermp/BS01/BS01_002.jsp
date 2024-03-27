<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var baseUrl = "/evermp/BS01/BS0101/";
        var gridtx; //계산서담당자
        function init() {
			
        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-ATTACH_FILE_NUM').css('display','none');
        		$('#upload-button-ATTACH_FILE1_NUM').css('display','none');
        		$('#upload-button-CI_FILE_NUM').css('display','none');
        		$('#upload-button-ATTACH_FILE4_NUM').css('display','none');
        	}
        	
            gridtx = EVF.C("gridtx");
            gridtx.setProperty('shrinkToFit', true);


            gridtx.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "TX_ASP_ID") {
                    gridtx.setCellValue(rowid, 'TX_ASP_ID_$TP', gridtx.getCellValue(rowid, 'TX_ASP_ID'));
                }
                if (colId == "TX_USER_NM") {
                    gridtx.setCellValue(rowid, 'TX_USER_NM_$TP', gridtx.getCellValue(rowid, 'TX_USER_NM'));
                }
                if (colId == "TX_USER_TEL_NO") {
                    gridtx.setCellValue(rowid, 'TX_USER_TEL_NO_$TP', gridtx.getCellValue(rowid, 'TX_USER_TEL_NO'));
                }
                if (colId == "TX_USER_CELL_NO") {
                    gridtx.setCellValue(rowid, 'TX_USER_CELL_NO_$TP', gridtx.getCellValue(rowid, 'TX_USER_CELL_NO'));
                }
                if (colId == "TX_USER_FAX_NO") {
                    gridtx.setCellValue(rowid, 'TX_USER_FAX_NO_$TP', gridtx.getCellValue(rowid, 'TX_USER_FAX_NO'));
                }
                if (colId == "TX_USER_EMAIL") {
                    gridtx.setCellValue(rowid, 'TX_USER_EMAIL_$TP', gridtx.getCellValue(rowid, 'TX_USER_EMAIL'));
                }
            });

            gridtx.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


            if(!${detailView}) {
                gridtx.addRowEvent(function() {
                    var addParam = [{}];
                    gridtx.addRow(addParam);
                });

                gridtx.delRowEvent(function() {
                    if(!gridtx.isExistsSelRow()) { return alert("${msg.M0004}"); }
                    var selRowId = gridtx.jsonToArray(gridtx.getSelRowId()).value;
                    for (var i = 0; i < selRowId.length; i++) {
                        if(gridtx.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                            return alert("${msg.M0145}");
                        }
                    }
                    gridtx.delRow();
                });
			}


            // SUPER유저 OR B100 : 고객사담당자
        	if( ${!havePermission} ) {
				EVF.C('Save').setVisible(false);
                EVF.C('Insert').setVisible(false);
                EVF.C('Update').setVisible(false);
            }

			if(EVF.V("PROGRESS_CD") == "E" || EVF.V("SIGN_STATUS") == "P"){
				EVF.C('Save').setVisible(false);
				EVF.C('Save').setDisabled(true);
			}

            // 수정
            if( !EVF.isEmpty(EVF.V("CUST_CD")) && EVF.V("PROGRESS_CD") == "E" ) {

                dodSearchTx();

            	EVF.C('Insert').setDisabled(true);
				EVF.C('Insert').setVisible(false);

            	EVF.C('CUST_CD').setDisabled(true);
                EVF.C('IRS_NUM').setDisabled(true);
                // if (회계관리번호 != "") 고객사명, 사업자등록번호, 종사업장번호, 법인등록번호, 설립일자, 우편번호, 주소, 상세주소, 대표자명, 업태, 종목 = disabled
                /*if( !EVF.isEmpty(EVF.V("ACC_NUM")) ) {
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
                	// 회계관리번호는 superuser만 수정 가능함
                	if( ${!superUserFlag} ) {
                    	EVF.C('ACC_NUM').setDisabled(true);
                	}
                }*/
            } else {
                EVF.C('Update').setDisabled(true);
				EVF.C('Update').setVisible(false);
            }

            // 사용자 id가 있는 경우 id는 수정 불가
            if( !EVF.isEmpty(EVF.V("USER_ID_OLD")) ) {
                EVF.C('USER_ID').setDisabled(true);
            }

            if(EVF.V("USER_ID")!=""){
                EVF.C("USER_ID").setReadOnly(true);
                EVF.V("ID_CHECK","Y");
                EVF.C('Idcheck').setDisabled(true);


                EVF.C("IRS_NUM").setReadOnly(true);
                EVF.V("IRS_NUM_CHECK","Y");
                EVF.C('Irscheck').setDisabled(true);


            }else{
                EVF.V("ID_CHECK","");
            }

			if(EVF.V("SIGN_STATUS") === 'P'){
				EVF.C('Insert').setDisabled(true);
				EVF.C('Update').setDisabled(true);
			}

			if(EVF.V("SIGN_STATUS") === 'R' || EVF.V("SIGN_STATUS") === 'C'){
				EVF.C('Insert').setDisabled(false);
				EVF.C('Update').setDisabled(true);
			}

        }

        function doSave() {
            var btnData = this.getData();
            var btnMsg = (btnData == "I" ? "${msg.M0011}" : btnData == "S" ? "${msg.M0021}" : "${msg.M0012}");

            var store = new EVF.Store();

            if( EVF.C("USER_ID_OLD").getValue() == "" ) {
            	EVF.C('PASSWORD').setRequired(true);
            	EVF.C('PASSWORD_CHECK').setRequired(true);
            }
            if( EVF.C("STOP_FLAG").getValue() == "1" ) {
            	EVF.C('STOP_REMARK').setRequired(true);
            	EVF.C('STOP_REMARK').setFocus();
            } else {
            	EVF.C('STOP_REMARK').setRequired(false);
            	EVF.C('STOP_REMARK').setValue("");
            }

            if(EVF.V("IRS_NUM_CHECK")!="Y"){
                return alert("${BS01_002_213}");
            }
            if(EVF.V("ID_CHECK")!="Y"){
                return alert("${BS01_002_007}");
            }

/*             if(EVF.V("E_BILL_ASP_TYPE")=="0"){
                if(!gridtx.isExistsSelRow()) { return alert("${BS01_002_013}"); }
                if(!gridtx.validate().flag) { return alert(gridtx.validate().msg); }
            } */


            if(!store.validate()) { return; }

            /*var irsSubNum = everString.lrTrim(EVF.C('IRS_SUB_NUM').getValue());
            if(irsSubNum.length != 0){
	            if( !everString.isNumber(irsSubNum) || irsSubNum.length != 4) {
	            	alert("${BS01_002_003}");
	            	EVF.C('IRS_SUB_NUM').setFocus();
	            	return;
	            }
            }*/

            // 신규 저장시 아이디 중복체크 중복체크 버튼으로 처리
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

            if(!confirm(btnMsg)) { return; }

         	// 수정시 대표자명, 우편번호, 주소, 상세주소, 고객사판가정율이 변경되는 경우 변경사유 입력
            if( EVF.V("CUST_CD") != "" ) {
            	if( everString.lrTrim(EVF.V("CEO_USER_NM_ORI"))!=everString.lrTrim(EVF.V("CEO_USER_NM")) || everString.lrTrim(EVF.V("HQ_ZIP_CD_ORI"))!=everString.lrTrim(EVF.V("HQ_ZIP_CD"))
            	 || everString.lrTrim(EVF.V("HQ_ADDR_1_ORI"))!=everString.lrTrim(EVF.V("HQ_ADDR_1"))     || everString.lrTrim(EVF.V("HQ_ADDR_2_ORI"))!=everString.lrTrim(EVF.V("HQ_ADDR_2"))
            	 || Number(EVF.V("PROFIT_RATIO_ORI"))!=Number(EVF.V("PROFIT_RATIO"))
            	) {
            		var param = {
              				title : '대표자명/우편번호/주소/판가정율 변경사유',
              				callbackFunction : 'setApproval',
              				detailView : false
              			};
            	    everPopup.commonTextInput(param);
            	} else {
					if(btnData === "I"){
						EVF.V("PROGRESS_CD","P");
						EVF.V("SIGN_STATUS","P");
						approvalInfoInsert();
					}else{
						goApproval();
					}
            	}
            } else {
				//setApproval(null);
				if(btnData == "S"){
					EVF.V("PROGRESS_CD","T");
					goApproval();
				}else if(btnData == "I"){
					EVF.V("PROGRESS_CD","P");
					EVF.V("SIGN_STATUS","P");
					approvalInfoInsert();
				}

            }
        }

		function approvalInfoInsert(){
			var param = {
				subject: EVF.C("CUST_NM").getValue() + " 등록 승인 요청 건",
				docType: "CUST",
				signStatus: "P",
				screenId: "BS01_002",
				approvalType: 'APPROVAL',
				oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
				attFileNum: "",
				docNum: EVF.C('CUST_CD').getValue(),
				appDocNum: EVF.C('APP_DOC_NUM').getValue(),
				callBackFunction: "goApproval",
				bizCls1: "02",
				bizCls2: "03",
				bizCls3: "03",
				reqUserId: "${ses.userId}"
			};
			everPopup.openApprovalRequestIIPopup(param);
		}

		function goApproval(formData, gridData, attachData){
			EVF.C('approvalFormData').setValue(formData);
			EVF.C('approvalGridData').setValue(gridData);
			EVF.C('attachFileDatas').setValue(attachData);

			var store = new EVF.Store();
			store.setGrid([gridtx]);
			store.getGridData(gridtx, 'sel');

			store.doFileUpload(function() {
				store.load(baseUrl + 'bs01002_doSave', function () {
					alert(this.getResponseMessage());
					if (this.getParameter("CUST_CD") == "" || this.getParameter("CUST_CD") == null) {
					} else {
						opener.doSearch();
						var param = {
							'CUST_CD': this.getParameter("CUST_CD"),
							'detailView': false,
							'popupFlag': true
						};
						window.location.href = '/evermp/BS01/BS0101/BS01_002/view.so?' + $.param(param);
					}
				});
			});
		}

        function setApproval(data) {
        	var store = new EVF.Store();

        	if( data != undefined && data != null ) {
        		EVF.C("CHANGE_REMARK").setValue(data.message);
        	}

            store.setGrid([gridtx]);
            store.getGridData(gridtx, 'sel');

        	store.doFileUpload(function() {
                store.load(baseUrl + 'bs01002_doSave', function () {
                    alert(this.getResponseMessage());
                    if (this.getParameter("CUST_CD") == "" || this.getParameter("CUST_CD") == null) {
                    } else {
                        opener.doSearch();
                        var param = {
                            'CUST_CD': this.getParameter("CUST_CD"),
                            'detailView': false,
                            'popupFlag': true
                        };
                        window.location.href = '/evermp/BS01/BS0101/BS01_002/view.so?' + $.param(param);
                    }
                });
            });
        }

        function dodeleteTx(){
            if (!gridtx.isExistsSelRow()) { return alert('${msg.M0004}'); }

            var rowIds = gridtx.getSelRowId();
            for(var i in rowIds) {
                if(gridtx.getCellValue(rowIds[i], "INSERT_FLAG")==""){
                    return alert("${msg.M0146}");
                }
            }
            var gridAllDatas = gridtx.getAllRowValue();
            if(gridAllDatas.length-rowIds.length<1){
                return alert("${BS01_002_016}");
            }
            if(!confirm('${msg.M0013}')) { return; }
            var store = new EVF.Store();

            store.setGrid([gridtx]);
            store.setParameter("CUST_CD", EVF.V("CUST_CD"));
            store.getGridData(gridtx, 'sel');
            store.load(baseUrl + 'bs01002_dodeleteTX', function() {
                alert(this.getResponseMessage());
                for( var i = 0; i < rowIds.length; i++ ) {
                    gridtx.delRow();
                }
            });
        }



        function dodSearchTx(){
        }

        function checkIrsNum() {
            if( !isIrsNum(EVF.C("IRS_NUM").getValue()) ) {
                alert("${msg.M0126}");
                EVF.C("IRS_NUM").setValue("");
                EVF.C('IRS_NUM').setFocus();
            } else {
                var irs_no = EVF.V("IRS_NUM").replace(/-/gi, '');
                EVF.V('IRS_NUM', irs_no);

				var store = new EVF.Store();
		        store.load(baseUrl + 'bs01002_checkIrsNum', function() {
		        	if(this.getParameter("POSSIBLE_FLAG") == "N") {
						EVF.C("IRS_NUM").setValue("");
						EVF.C('IRS_NUM').setFocus();
		        		return alert("${msg.M0127}");
		        	}
		        }, false);
			}
        }

        function isIrsNum(str) {
            var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
            var chkSum = 0;
            var c2 = "";
            var remander;
            str = str.replace(/-/gi,'');

            for (var i = 0; i <= 7; i++) {
                chkSum += checkID[i] * str.charAt(i);
            }
            c2 = "0" + (checkID[8] * str.charAt(8));
            c2 = c2.substring(c2.length - 2, c2.length);
            chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
            remander = (10 - (chkSum % 10)) % 10 ;
            if (Math.floor(str.charAt(9)) == remander) {
                return true ; // OK!
            }
            return false;
        }

        function checkCompanyRegNum(){
            if( !isCompanyRegNum(EVF.C("COMPANY_REG_NUM").getValue()) ) {
                alert("${msg.M0174}");
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
			/*
			if( checkType == "TEL_NUM" ) {
				if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
					alert("${msg.M0128}");
					EVF.C("TEL_NUM").setValue("");
					EVF.C('TEL_NUM').setFocus();
				}
			}
			*/
			if( checkType == "FAX_NUM" ) {
				if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
					alert("${msg.M0128}");
					EVF.C("FAX_NUM").setValue("");
					EVF.C('FAX_NUM').setFocus();
				}
			}
            if( checkType == "RECIPIENT_FAX_NUM" ) {
                if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("RECIPIENT_FAX_NUM").setValue("");
                    EVF.C('RECIPIENT_FAX_NUM').setFocus();
                }
            }
/*
            if( checkType == "RECIPIENT_TEL_NUM" ) {
                if(!everString.isTel(EVF.C("RECIPIENT_TEL_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("RECIPIENT_TEL_NUM").setValue("");
                    EVF.C('RECIPIENT_TEL_NUM').setFocus();
                }
            }
*/
		}

        // 담당자id 중복체크
        function docheckDup() {
        	var store = new EVF.Store();
	        store.load(baseUrl + 'bs01002_checkDupCustUser', function() {
	        	if(this.getParameter("USER_POSSIBLE_FLAG") == "N") {
	        		return alert("${BS01_002_001}");
	        	}
	        }, false);
        }


        //id중복체크
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
                        return alert("${BS01_002_006}");
                    }else{
                        EVF.V("ID_CHECK","Y");
                        alert("${BS01_002_005}");

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
                return alert("${BS01_002_001}");
            }
            if( EVF.C('ATTACH_FILE1_NUM').getFileCount() > 1 ){
                return alert("${BS01_002_001}");
            }
            if( EVF.C('ATTACH_FILE2_NUM').getFileCount() > 1 ){
                return alert("${BS01_002_001}");
            }
            if( EVF.C('ATTACH_FILE3_NUM').getFileCount() > 1 ){
                return alert("${BS01_002_001}");
            }
        }

        function searchZipCd() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode",
                modalYn : false
            };
            everPopup.openWindowPopup(url, 700, 600, param);
            //everPopup.jusoPop(url, param);
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
                EVF.C('UR_ADDR1').setValue(zipcd.ADDR);
                EVF.C('UR_ADDR1').setFocus();
            }
        }

        function getDept() {

            if(EVF.V("CUST_CD")==""){
            	alert("${BS01_002_024}");
                return;
    		}

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setDeptCd_s",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : EVF.C("CUST_CD").getValue(),
                'custNm' : EVF.C("CUST_NM").getValue()
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");


        }
        function setDeptCd_s(data) {
            data = JSON.parse(data);
            EVF.V('DEPT_CD', data.ITEM_CLS3);
            EVF.V('DEPT_NM', data.ITEM_CLS_NM);
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


        // 비밀번호 체크
        function CheckCall(){
            var str;
            if( this.data == "1" ) {
                str = EVF.V("PASSWORD");
            } else {
                str = EVF.V("PASSWORD_CHECK");
            }

            if( !chkPwd(str) ){
                //EVF.C("PASSWORD").setValue("");
                //EVF.C("PASSWORD_CHECK").setValue("");
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
                alert("${BS01_002_021}");
                return false;
            }
            if(str.length >20){
                alert("${BS01_002_021}");
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
                alert("${BS01_002_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${BS01_002_023}");
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

        function companyInfoSame_Check() {
            if(EVF.V("COMPANY_FLAG")=="Y"){
                EVF.V("RECIPIENT_TEL_NUM",EVF.V("TEL_NUM"));
                EVF.V("RECIPIENT_FAX_NUM",EVF.V("FAX_NUM"));
                EVF.V("RECIPIENT_EMAIL",EVF.V("EMAIL"));
                //EVF.V("UR_ZIP_CD",EVF.V("HQ_ZIP_CD"));
                //EVF.V("UR_ADDR1",EVF.V("HQ_ADDR_1"));
                //EVF.V("UR_ADDR2",EVF.V("HQ_ADDR_2"));
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

        function IdcheckId(){

        	var regExp = /^[A-Za-z0-9_-]{3,16}$/;
            if (!EVF.V("USER_ID").match(regExp)){
                alert("${msg.ID_INVALID}");

                EVF.V("USER_ID","");
            }
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






        //irs_no 중복체크
        function doIrscheck() {
        	EVF.V("IRS_NUM_CHECK","");
        	if(EVF.C("IRS_NUM").getValue()==""){
                EVF.C('IRS_NUM').setFocus();
                alert(everString.getMessage("${msg.M0109}", "${form_IRS_NUM_N}"));
            }else{
                var store = new EVF.Store();
                store.load(baseUrl + 'bs01003_doCheckIrsNo', function() {
                    if(this.getParameter("POSSIBLE_FLAG") == "N") {
                        EVF.V("IRS_NUM_CHECK","");
                        return alert("${BS01_002_215}");
                    }else{
                        EVF.V("IRS_NUM_CHECK","Y");
                        alert("${BS01_002_214}");
                    }
                }, false);
            }
        }

















    </script>

    <e:window id="BS01_002" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <!-- 1. 고객 일반정보 -->
        <%--<e:panel id="leftP1" height="fit" width="30%">
            <e:title title="${BS01_002_CAPTION1 }" depth="1"/>
        </e:panel>
        --%>
        <%--<e:panel id="rightP1" height="fit" width="70%">--%>
		<e:buttonBar id="buttonBar1" align="right" width="100%" title="${BS01_002_CAPTION1}">
			<e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}" data="S"/>
			<e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${Insert_V}" onClick="doSave" data="I" />
			<e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }" visible="${Update_V}" onClick="doSave" data="U" />
		</e:buttonBar>
        <%--</e:panel>--%>

        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
        	<e:inputHidden id="CEO_USER_NM_ORI" name="CEO_USER_NM_ORI" value="${formData.CEO_USER_NM }" /> <!-- 대표자명2------------------- -->
        	<e:inputHidden id="HQ_ZIP_CD_ORI" name="HQ_ZIP_CD_ORI" value="${formData.HQ_ZIP_CD }" /> <!-- 우편번호 -->
        	<e:inputHidden id="HQ_ADDR_1_ORI" name="HQ_ADDR_1_ORI" value="${formData.HQ_ADDR_1 }" /> <!-- 주소 -->
        	<e:inputHidden id="HQ_ADDR_2_ORI" name="HQ_ADDR_2_ORI" value="${formData.HQ_ADDR_2 }" /> <!-- 상세주소 -->
        	<e:inputHidden id="PROFIT_RATIO_ORI" name="PROFIT_RATIO_ORI" value="${formData.PROFIT_RATIO }" /> <!-- 고객사판가정율 -->
        	<e:inputHidden id="CREDIT_LIMIT_AMT" name="CREDIT_LIMIT_AMT" value="${formData.CREDIT_LIMIT_AMT }" />
			<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${formData.APP_DOC_NUM}" />
			<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${formData.APP_DOC_CNT}" />
			<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS}" />
			<e:inputHidden id="IRS_SUB_NUM" name="IRS_SUB_NUM" value="${formData.IRS_SUB_NUM}" />
			<e:inputHidden id="IRS_SUB_NM" name="IRS_SUB_NM" value="${formData.IRS_SUB_NM}" />
			<e:inputHidden id="approvalFormData" name="approvalFormData" />
			<e:inputHidden id="approvalGridData" name="approvalGridData" />
			<e:inputHidden id="attachFileDatas" name="attachFileDatas" />


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
				<e:label for="IRS_NUM" title="${form_IRS_NUM_N}" />
				<e:field>
					<e:inputText id="IRS_NUM" name="IRS_NUM" placeHolder="${BS01_002_INPUT_T1 }" value="${formData.IRS_NUM }" width="${form_IRS_NUM_W}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" onChange="checkIrsNum" />

                    &nbsp;<e:button id="Irscheck" name="Irscheck" label="${Irscheck_N}" onClick="doIrscheck" disabled="${Irscheck_D}" visible="${Irscheck_V}"/>
                    <e:inputHidden id="IRS_NUM_CHECK" name="IRS_NUM_CHECK"/>

				</e:field>
				<e:label for="SCALE_TYPE" title="${form_SCALE_TYPE_N}"/>
				<e:field>
					<e:select id="SCALE_TYPE" name="SCALE_TYPE" value="${formData.SCALE_TYPE }" options="${scaleTypeOptions}" width="${form_SCALE_TYPE_W}" disabled="${form_SCALE_TYPE_D}" readOnly="${form_SCALE_TYPE_RO}" required="${form_SCALE_TYPE_R}" placeHolder="" />
				</e:field>
 			</e:row>
            <e:row>
				<e:label for="CORP_TYPE" title="${form_CORP_TYPE_N}"/>
				<e:field>
					<e:select id="CORP_TYPE" name="CORP_TYPE" value="${formData.CORP_TYPE }" options="${corpTypeOptions}" width="${form_CORP_TYPE_W}" disabled="${form_CORP_TYPE_D}" readOnly="${form_CORP_TYPE_RO}" required="${form_CORP_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="COMPANY_REG_NUM" title="${form_COMPANY_REG_NUM_N}" />
				<e:field>
					<e:inputText id="COMPANY_REG_NUM" name="COMPANY_REG_NUM" placeHolder="${BS01_002_INPUT_T1 }" value="${formData.COMPANY_REG_NUM }" width="${form_COMPANY_REG_NUM_W}" maxLength="${form_COMPANY_REG_NUM_M}" disabled="${form_COMPANY_REG_NUM_D}" readOnly="${form_COMPANY_REG_NUM_RO}" required="${form_COMPANY_REG_NUM_R}" style="${imeMode}" onChange="checkCompanyRegNum" />
				</e:field>
				<e:label for="DEAL_APRV_DATE" title="${form_DEAL_APRV_DATE_N}"/>
				<e:field>
					<e:inputDate id="DEAL_APRV_DATE" name="DEAL_APRV_DATE" value="${formData.DEAL_APRV_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_DEAL_APRV_DATE_R}" disabled="${form_DEAL_APRV_DATE_D}" readOnly="${form_DEAL_APRV_DATE_RO}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="HQ_ZIP_CD" title="${form_HQ_ZIP_CD_N}"/>
                <e:field>
                    <e:search id="HQ_ZIP_CD" name="HQ_ZIP_CD" value="${formData.HQ_ZIP_CD }" width="${form_HQ_ZIP_CD_W}" maxLength="7" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_HQ_ZIP_CD_D}" readOnly="true" required="${form_HQ_ZIP_CD_R}" />
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
					<e:text>${BS01_002_TEXT1 }</e:text>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="TEL_NUM" title="${form_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${formData.TEL_NUM }" width="${form_TEL_NUM_W}" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" data="TEL_NUM" />
				</e:field>
				<e:label for="FAX_NUM" title="${form_FAX_NUM_N}" />
				<e:field>
					<e:inputText id="FAX_NUM" name="FAX_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${formData.FAX_NUM }" width="${form_FAX_NUM_W}" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" data="FAX_NUM"  onChange="checkTelNo"/>
				</e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" placeHolder="${BS01_002_INPUT_T3 }" value="${formData.EMAIL }" width="${form_EMAIL_W}" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
			<e:row>

				<e:label for="IPO_FLAG" title="${form_IPO_FLAG_N}"/>
				<e:field>
					<e:select id="IPO_FLAG" name="IPO_FLAG" value="${formData.IPO_FLAG }" options="${ipoFlagOptions}" width="${form_IPO_FLAG_W}" disabled="${form_IPO_FLAG_D}" readOnly="${form_IPO_FLAG_RO}" required="${form_IPO_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<e:label for="IPO_DATE" title="${form_IPO_DATE_N}"/>
				<e:field>
					<e:inputDate id="IPO_DATE" name="IPO_DATE" value="${formData.IPO_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_IPO_DATE_R}" disabled="${form_IPO_DATE_D}" readOnly="${form_IPO_DATE_RO}" />
				</e:field>
				<e:label for="FOUNDATION_DATE" title="${form_FOUNDATION_DATE_N}"/>
				<e:field>
					<e:inputDate id="FOUNDATION_DATE" name="FOUNDATION_DATE" value="${formData.FOUNDATION_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_FOUNDATION_DATE_R}" disabled="${form_FOUNDATION_DATE_D}" readOnly="${form_FOUNDATION_DATE_RO}" />
				</e:field>

			</e:row>
			<e:row>
				<e:label for="HOMEPAGE_URL" title="${form_HOMEPAGE_URL_N}" />
				<e:field colSpan="3">
					<e:inputText id="HOMEPAGE_URL" name="HOMEPAGE_URL" value="${formData.HOMEPAGE_URL}" width="${form_HOMEPAGE_URL_W}" maxLength="${form_HOMEPAGE_URL_M}" disabled="${form_HOMEPAGE_URL_D}" readOnly="${form_HOMEPAGE_URL_RO}" required="${form_HOMEPAGE_URL_R}" />
				</e:field>
				<e:label for="" />
				<e:field colSpan="1" />
			</e:row>

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

        <!-- 2. 관리정보 -->

        <e:panel id="leftP2" height="25px" width="40%">
            <e:title title="${BS01_002_CAPTION2}" depth="1" />
        </e:panel>

		<e:searchPanel id="form2" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>
				<e:label for="CREDIT_AGENCY_NM" title="${form_CREDIT_AGENCY_NM_N}" />
				<e:field>
					<e:inputText id="CREDIT_AGENCY_NM" name="CREDIT_AGENCY_NM" value="${formData.CREDIT_AGENCY_NM }" width="${form_CREDIT_AGENCY_NM_W}" maxLength="${form_CREDIT_AGENCY_NM_M}" disabled="${form_CREDIT_AGENCY_NM_D}" readOnly="${form_CREDIT_AGENCY_NM_RO}" required="${form_CREDIT_AGENCY_NM_R}" />
				</e:field>
				<e:label for="CREDIT_CD" title="${form_CREDIT_CD_N}" />
				<e:field>
					<e:inputText id="CREDIT_CD" name="CREDIT_CD" value="${formData.CREDIT_CD }" width="${form_CREDIT_CD_W}" maxLength="${form_CREDIT_CD_M}" disabled="${form_CREDIT_CD_D}" readOnly="${form_CREDIT_CD_RO}" required="${form_CREDIT_CD_R}" />
				</e:field>
				<e:label for="CASH_CD" title="${form_CASH_CD_N}" />
				<e:field>
					<e:inputText id="CASH_CD" name="CASH_CD" value="${formData.CASH_CD}" width="${form_CASH_CD_W}" maxLength="${form_CASH_CD_M}" disabled="${form_CASH_CD_D}" readOnly="${form_CASH_CD_RO}" required="${form_CASH_CD_R}" />
				</e:field>

            </e:row>
            <e:row>
				<e:label for="MANAGE_ID" title="${form_MANAGE_ID_N}"/>
				<e:field>
					<e:select id="MANAGE_ID" name="MANAGE_ID" value="${formData.MANAGE_ID }" options="${custMngId}" width="${form_MANAGE_ID_W}" disabled="${form_MANAGE_ID_D}" readOnly="${form_MANAGE_ID_RO}" required="${form_MANAGE_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="TAX_USER_ID" title="${form_TAX_USER_ID_N}"/>
				<e:field>
					<e:select id="TAX_USER_ID" name="TAX_USER_ID" value="${formData.TAX_USER_ID }" options="${taxMngId}" width="${form_TAX_USER_ID_W}" disabled="${form_TAX_USER_ID_D}" readOnly="${form_TAX_USER_ID_RO}" required="${form_TAX_USER_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="PROFIT_RATIO" title="${form_PROFIT_RATIO_N}"/>
				<e:field>
					<e:inputNumber id="PROFIT_RATIO" name="PROFIT_RATIO" value="${formData.PROFIT_RATIO }" width="50%" maxValue="${form_PROFIT_RATIO_M}" decimalPlace="${form_PROFIT_RATIO_NF}" disabled="${form_PROFIT_RATIO_D}" readOnly="${form_PROFIT_RATIO_RO}" required="${form_PROFIT_RATIO_R}" />
					<e:text>${BS01_002_TEXT3 }</e:text>
				</e:field>
            </e:row>
			<e:row>
				<e:label for="RELAT_YN" title="${form_RELAT_YN_N}"/>
				<e:field>
					<e:select id="RELAT_YN" name="RELAT_YN" value="${formData.RELAT_YN}" options="${relatYnOptions}" width="${form_RELAT_YN_W}" disabled="${form_RELAT_YN_D}" readOnly="${form_RELAT_YN_RO}" required="${form_RELAT_YN_R}" placeHolder="" />
				</e:field>
				<e:label for="TAX_TYPE" title="${form_TAX_TYPE_N}"/>
				<e:field>
					<e:select id="TAX_TYPE" name="TAX_TYPE" value="${formData.TAX_TYPE}" options="${taxTypeOptions}" width="${form_TAX_TYPE_W}" disabled="${form_TAX_TYPE_D}" readOnly="${form_TAX_TYPE_RO}" required="${form_TAX_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="TRUNC_TYPE" title="${form_TRUNC_TYPE_N}"/>
				<e:field>
					<e:select id="TRUNC_TYPE" name="TRUNC_TYPE" value="${formData.TRUNC_TYPE}" options="${truncTypeOptions}" width="${form_TRUNC_TYPE_W}" disabled="${form_TRUNC_TYPE_D}" readOnly="${form_TRUNC_TYPE_RO}" required="${form_TRUNC_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="STOP_FLAG" title="${form_STOP_FLAG_N}"/>
				<e:field>
					<e:select id="STOP_FLAG" name="STOP_FLAG" value="${formData.STOP_FLAG}" options="${stopFlagOptions}" width="${form_STOP_FLAG_W}" disabled="${form_STOP_FLAG_D}" readOnly="${form_STOP_FLAG_RO}" required="${form_STOP_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="STOP_REMARK" title="${form_STOP_REMARK_N}"/>
				<e:field colSpan="3">
					<e:inputText id="STOP_REMARK" name="STOP_REMARK" value="${formData.STOP_REMARK }" width="${form_STOP_REMARK_W}" maxLength="${form_STOP_REMARK_M}" disabled="${form_STOP_REMARK_D}" readOnly="${form_STOP_REMARK_RO}" required="${form_STOP_REMARK_R}" style="${imeMode}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="APPROVE_USE_FLAG" title="${form_APPROVE_USE_FLAG_N}"/>
				<e:field>
					<e:select id="APPROVE_USE_FLAG" name="APPROVE_USE_FLAG" value="${formData.APPROVE_USE_FLAG }" options="${approveUseFlagOptions}" width="${form_APPROVE_USE_FLAG_W}" disabled="${form_APPROVE_USE_FLAG_D}" readOnly="${form_APPROVE_USE_FLAG_RO}" required="${form_APPROVE_USE_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="BUDGET_USE_FLAG" title="${form_BUDGET_USE_FLAG_N}"/>
				<e:field>
					<e:select id="BUDGET_USE_FLAG" name="BUDGET_USE_FLAG" value="${formData.BUDGET_USE_FLAG }" options="${budgetUseFlagOptions}" width="${form_BUDGET_USE_FLAG_W}" disabled="${form_BUDGET_USE_FLAG_D}" readOnly="${form_BUDGET_USE_FLAG_RO}" required="${form_BUDGET_USE_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="COST_CENTER_FLAG" title="${form_COST_CENTER_FLAG_N}"/>
				<e:field>
					<e:select id="COST_CENTER_FLAG" name="COST_CENTER_FLAG" value="${formData.COST_CENTER_FLAG }" options="${costCenterFlagOptions}" width="${form_COST_CENTER_FLAG_W}" disabled="${form_COST_CENTER_FLAG_D}" readOnly="${form_COST_CENTER_FLAG_RO}" required="${form_COST_CENTER_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ERP_IF_FLAG" title="${form_ERP_IF_FLAG_N}"/>
				<e:field>
					<e:select id="ERP_IF_FLAG" name="ERP_IF_FLAG" value="${(formData.ERP_IF_FLAG == NULL)?'0':formData.ERP_IF_FLAG}" options="${erpIfFlagOptions}" width="${form_ERP_IF_FLAG_W}" disabled="${form_ERP_IF_FLAG_D}" readOnly="${form_ERP_IF_FLAG_RO}" required="${form_ERP_IF_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="MOD_USER_ID" title="${form_MOD_USER_ID_N}" />
				<e:field>
					<e:inputText id="MOD_USER_ID" name="MOD_USER_ID" value="${formData.MOD_USER_ID}" width="${form_MOD_USER_ID_W}" maxLength="${form_MOD_USER_ID_M}" disabled="${form_MOD_USER_ID_D}" readOnly="${form_MOD_USER_ID_RO}" required="${form_MOD_USER_ID_R}" />
				</e:field>
				<e:label for="MOD_DATE" title="${form_MOD_DATE_N}"/>
				<e:field>
					<e:inputDate id="MOD_DATE" name="MOD_DATE" value="${formData.MOD_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_MOD_DATE_R}" disabled="${form_MOD_DATE_D}" readOnly="${form_MOD_DATE_RO}" />
				</e:field>
			</e:row>
			<%--<e:row>
				<e:label for="TAX_ASP_NM" title="${form_TAX_ASP_NM_N}"/>
				<e:field>
					<e:inputText id="TAX_ASP_NM" name="TAX_ASP_NM" value="${formData.TAX_ASP_NM }" width="${form_TAX_ASP_NM_W}" maxLength="${form_TAX_ASP_NM_M}" disabled="${form_TAX_ASP_NM_D}" readOnly="${form_TAX_ASP_NM_RO}" required="${form_TAX_ASP_NM_R}"/>
				</e:field>
				<e:label for="TAX_SEND_TYPE" title="${form_TAX_SEND_TYPE_N}"/>
                <e:field>
                	<e:select id="TAX_SEND_TYPE" name="TAX_SEND_TYPE" value="${formData.TAX_SEND_TYPE }" options="${taxSendTypeOptions}" width="${form_TAX_SEND_TYPE_W}" disabled="${form_TAX_SEND_TYPE_D}" readOnly="${form_TAX_SEND_TYPE_RO}" required="${form_TAX_SEND_TYPE_R}" placeHolder="" />
                </e:field>
			</e:row>
			<e:row>
				<e:label for="PAY_CONDITION" title="${form_PAY_CONDITION_N}"/>
                <e:field>
                    <e:select id="PAY_CONDITION" name="PAY_CONDITION" value="${formData.PAY_CONDITION}" options="${payConditionOptions}" width="${form_PAY_CONDITION_W}" disabled="${form_PAY_CONDITION_D}" readOnly="${form_PAY_CONDITION_RO}" required="${form_PAY_CONDITION_R}" placeHolder="" />
                </e:field>
                <e:label for="ACC_NUM" title="${form_ACC_NUM_N}" />
				<e:field>
					<e:inputText id="ACC_NUM" name="ACC_NUM" value="${formData.ACC_NUM }" width="${form_ACC_NUM_W}" maxLength="${form_ACC_NUM_M}" disabled="${form_ACC_NUM_D}" readOnly="${form_ACC_NUM_RO}" required="${form_ACC_NUM_R}" />
				</e:field>
				<e:label for="AUTO_PO_FLAG" title="${form_AUTO_PO_FLAG_N}"/>
				<e:field>
					<e:select id="AUTO_PO_FLAG" name="AUTO_PO_FLAG" value="${formData.AUTO_PO_FLAG }" options="${autoPoFlagOptions}" width="${form_AUTO_PO_FLAG_W}" disabled="${form_AUTO_PO_FLAG_D}" readOnly="${form_AUTO_PO_FLAG_RO}" required="${form_AUTO_PO_FLAG_R}" placeHolder="" />
				</e:field>

			</e:row>
            <e:row>
            	<e:label for="PAY_DAY" title="${form_PAY_DAY_N}"/>
            	<e:field>
                    <e:inputNumber id="PAY_DAY" name="PAY_DAY" value="${formData.PAY_DAY}" width="75%" maxValue="${form_PAY_DAY_M}" decimalPlace="${form_PAY_DAY_NF}" disabled="${form_PAY_DAY_D}" readOnly="${form_PAY_DAY_RO}" required="${form_PAY_DAY_R}" />
					<e:text>${BS01_002_TEXT5 }</e:text>
                </e:field>
                <e:label for="MY_SITE_FLAG" title="${form_MY_SITE_FLAG_N}"/>
				<e:field>
					<e:select id="MY_SITE_FLAG" name="MY_SITE_FLAG" value="${formData.MY_SITE_FLAG }" options="${mySiteFlagOptions}" width="${form_MY_SITE_FLAG_W}" disabled="${form_MY_SITE_FLAG_D}" readOnly="${form_MY_SITE_FLAG_RO}" required="${form_MY_SITE_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="NEW_COMPANY_FLAG" title="${form_NEW_COMPANY_FLAG_N}"/>
				<e:field>
					<e:select id="NEW_COMPANY_FLAG" name="NEW_COMPANY_FLAG" value="${formData.NEW_COMPANY_FLAG }" options="${newCompanyFlagOptions}" width="${form_NEW_COMPANY_FLAG_W}" disabled="${form_NEW_COMPANY_FLAG_D}" readOnly="${form_NEW_COMPANY_FLAG_RO}" required="${form_NEW_COMPANY_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>--%>
            <e:row>

				<%--<e:label for="DEPT_PRICE_FLAG" title="${form_DEPT_PRICE_FLAG_N}"/>
				<e:field>
					<e:select id="DEPT_PRICE_FLAG" name="DEPT_PRICE_FLAG" value="${formData.DEPT_PRICE_FLAG }" options="${deptPriceFlagOptions}" width="${form_DEPT_PRICE_FLAG_W}" disabled="${form_DEPT_PRICE_FLAG_D}" readOnly="${form_DEPT_PRICE_FLAG_RO}" required="${form_DEPT_PRICE_FLAG_R}" placeHolder="" />
				</e:field>--%>
            </e:row>
		</e:searchPanel>

		<!-- 3.결제정보 -->
		<e:panel id="CAPTION8" height="25px">
			<e:title title="${BS01_002_CAPTION8}" depth="1" />
		</e:panel>
		<e:searchPanel id="PAY_INFO" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
			<e:inputHidden id="CUBL_SQ" name="CUBL_SQ" value="${formData.CUBL_SQ}" />
			<e:row>
				<e:label for="CUBL_BANK_NM" title="${form_CUBL_BANK_NM_N}" />
				<e:field>
					<e:inputText id="CUBL_BANK_NM" name="CUBL_BANK_NM" value="${formData.CUBL_BANK_NM}" width="${form_CUBL_BANK_NM_W}" maxLength="${form_CUBL_BANK_NM_M}" disabled="${form_CUBL_BANK_NM_D}" readOnly="${form_CUBL_BANK_NM_RO}" required="${form_CUBL_BANK_NM_R}" />
				</e:field>
				<e:label for="CUBL_ACCOUNT_NUM" title="${form_CUBL_ACCOUNT_NUM_N}" />
				<e:field>
					<e:inputText id="CUBL_ACCOUNT_NUM" name="CUBL_ACCOUNT_NUM" value="${formData.CUBL_ACCOUNT_NUM}" width="${form_CUBL_ACCOUNT_NUM_W}" maxLength="${form_CUBL_ACCOUNT_NUM_M}" disabled="${form_CUBL_ACCOUNT_NUM_D}" readOnly="${form_CUBL_ACCOUNT_NUM_RO}" required="${form_CUBL_ACCOUNT_NUM_R}" />
				</e:field>
				<e:label for="CUBL_ACCOUNT_NM" title="${form_CUBL_ACCOUNT_NM_N}" />
				<e:field>
					<e:inputText id="CUBL_ACCOUNT_NM" name="CUBL_ACCOUNT_NM" value="${formData.CUBL_ACCOUNT_NM}" width="${form_CUBL_ACCOUNT_NM_W}" maxLength="${form_CUBL_ACCOUNT_NM_M}" disabled="${form_CUBL_ACCOUNT_NM_D}" readOnly="${form_CUBL_ACCOUNT_NM_RO}" required="${form_CUBL_ACCOUNT_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PAY_CONDITION" title="${form_PAY_CONDITION_N}" />
				<e:field>
					<e:inputText id="PAY_CONDITION" name="PAY_CONDITION" value="${formData.PAY_CONDITION}" width="${form_PAY_CONDITION_W}" maxLength="${form_PAY_CONDITION_M}" disabled="${form_PAY_CONDITION_D}" readOnly="${form_PAY_CONDITION_RO}" required="${form_PAY_CONDITION_R}" />
				</e:field>
				<e:label for="PAY_DAY" title="${form_PAY_DAY_N}"/>
				<e:field>
					<e:inputNumber id="PAY_DAY" name="PAY_DAY" value="${formData.PAY_DAY}" width="100%" maxValue="${form_PAY_DAY_M}" decimalPlace="${form_PAY_DAY_NF}" disabled="${form_PAY_DAY_D}" readOnly="${form_PAY_DAY_RO}" required="${form_PAY_DAY_R}" />
					<%--<e:text>${BS01_002_TEXT5 }</e:text>--%>
				</e:field>
				<e:label for="" />
				<e:field colSpan="1" />
			</e:row>
		</e:searchPanel>

		<!-- 4. 관리자 정보 -->

		<e:searchPanel id="form5" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
			<e:panel id="leftP5" height="25px" width="40%">
				<e:title title="${BS01_002_CAPTION5}" depth="1" />
			</e:panel>

			<%--<e:panel id="rightP5" height="30px" width="60%">
				<div style="float:right">
					<e:checkGroup id="COMPANY_SAME_FLAG" name="COMPANY_SAME_FLAG" disabled="false" readOnly="false" required="false" onChange="companyInfoSame_Check">
						<e:check id="COMPANY_FLAG" name="COMPANY_FLAG" value="Y" label="${BS01_002_CAPTION6}" checked="false" />
					</e:checkGroup>
				</div>
			</e:panel>--%>
			<e:inputHidden id="USER_ID_OLD" name="USER_ID_OLD" value="${mngUser.USER_ID }" />
			<e:row>
				<e:label for="USER_ID" title="${form_USER_ID_N}" />
				<e:field>

					<e:inputText id="USER_ID" name="USER_ID" value="${mngUser.USER_ID }" width="60%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" onChange="onChangeID" />
					&nbsp;<e:button id="Idcheck" name="Idcheck" label="${Idcheck_N}" onClick="doIdcheck" disabled="${Idcheck_D}" visible="${Idcheck_V}" />
					<e:inputHidden id="ID_CHECK" name="ID_CHECK" value="" />
					<e:inputHidden id="ORI_USER_ID" name="ORI_USER_ID" value="${mngUser.USER_ID }" />

				</e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N}" />
				<e:field>
					<e:inputText id="USER_NM" name="USER_NM" value="${mngUser.USER_NM }" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				</e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
				<e:field>
					<e:inputHidden id="DEPT_CD" name="DEPT_CD" value="${mngUser.DEPT_CD }" />
					<e:search id="DEPT_NM" name="DEPT_NM" value="${mngUser.DEPT_NM }" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'getDept'}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
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
					<e:search id="BUDGET_DEPT_NM" name="BUDGET_DEPT_NM" value="${mngUser.BUDGET_DEPT_NM }" width="${form_BUDGET_DEPT_NM_W}" maxLength="${form_BUDGET_DEPT_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'getBudgetDept'}" disabled="${form_BUDGET_DEPT_NM_D}" readOnly="${form_BUDGET_DEPT_NM_RO}" required="${form_BUDGET_DEPT_NM_R}" />
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
					<e:inputText id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${mngUser.RECIPIENT_TEL_NUM }" width="${form_RECIPIENT_TEL_NUM_W}" maxLength="${form_RECIPIENT_TEL_NUM_M}" disabled="${form_RECIPIENT_TEL_NUM_D}" readOnly="${form_RECIPIENT_TEL_NUM_RO}" required="${form_RECIPIENT_TEL_NUM_R}" />
				</e:field>
				<e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${mngUser.RECIPIENT_CELL_NUM }" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" onChange="checkCellNo" />
				</e:field>
				<e:label for="RECIPIENT_EMAIL" title="${form_RECIPIENT_EMAIL_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" placeHolder="${BS01_002_INPUT_T3 }" value="${mngUser.RECIPIENT_EMAIL }" width="${form_RECIPIENT_EMAIL_W}" maxLength="${form_RECIPIENT_EMAIL_M}" disabled="${form_RECIPIENT_EMAIL_D}" readOnly="${form_RECIPIENT_EMAIL_RO}" required="${form_RECIPIENT_EMAIL_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="RECIPIENT_FAX_NUM" title="${form_RECIPIENT_FAX_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_FAX_NUM" name="RECIPIENT_FAX_NUM" placeHolder="${BS01_002_INPUT_T2 }" value="${mngUser.RECIPIENT_FAX_NUM }" width="${form_RECIPIENT_FAX_NUM_W}" maxLength="${form_RECIPIENT_FAX_NUM_M}" disabled="${form_RECIPIENT_FAX_NUM_D}" readOnly="${form_RECIPIENT_FAX_NUM_RO}" required="${form_RECIPIENT_FAX_NUM_R}"  onChange="checkTelNo"/>
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
					<e:select id="USER_AUTO_PO_FLAG" name="USER_AUTO_PO_FLAG" value="${mngUser.USER_AUTO_PO_FLAG}" options="${userAutoPoFlagOptions}" width="${form_USER_AUTO_PO_FLAG_W}" disabled="${form_USER_AUTO_PO_FLAG_D}" readOnly="${form_USER_AUTO_PO_FLAG_RO}" required="${form_USER_AUTO_PO_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="GR_FLAG" title="${form_GR_FLAG_N}"/>
				<e:field>
					<e:select id="GR_FLAG" name="GR_FLAG" value="${mngUser.GR_FLAG }" options="${grFlagOptions}" width="${form_GR_FLAG_W}" disabled="${form_GR_FLAG_D}" readOnly="${form_GR_FLAG_RO}" required="${form_GR_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<e:label for="FINANCIAL_FLAG" title="${form_FINANCIAL_FLAG_N}"/>
				<e:field>
					<e:select id="FINANCIAL_FLAG" name="FINANCIAL_FLAG" value="${mngUser.FINANCIAL_FLAG }" options="${financialFlagOptions}" width="${form_FINANCIAL_FLAG_W}" disabled="${form_FINANCIAL_FLAG_D}" readOnly="${form_FINANCIAL_FLAG_RO}" required="${form_FINANCIAL_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<%--<e:label for="BUDGET_FLAG" title="${form_BUDGET_FLAG_N}"/>
				<e:field>
					<e:select id="BUDGET_FLAG" name="BUDGET_FLAG" value="${mngUser.BUDGET_FLAG }" options="${budgetFlagOptions}" width="${form_BUDGET_FLAG_W}" disabled="${form_BUDGET_FLAG_D}" readOnly="${form_BUDGET_FLAG_RO}" required="${form_BUDGET_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>--%>
			</e:row>
		</e:searchPanel>

		<!-- 5. 재무정보 -->

		<e:buttonBar title="${BS01_002_CAPTION4 }">
			<e:text style="float: right;">${BS01_002_SUB_T }</e:text>
		</e:buttonBar>

		<e:searchPanel id="form4" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="4" useTitleBar="false">
			<e:row>
				<e:label for="STD_YYYY" title="${form_STD_YYYY_N}"/>
				<e:field>
					<e:select id="STD_YYYY" name="STD_YYYY" value="${formData.STD_YYYY }" options="${stdYyyyOptions}" width="${form_STD_YYYY_W}" disabled="${form_STD_YYYY_D}" readOnly="${form_STD_YYYY_RO}" required="${form_STD_YYYY_R}" placeHolder="" />
				</e:field>
				<e:label for="DATA_REF_CD" title="${form_DATA_REF_CD_N}"/>
				<e:field>
					<e:select id="DATA_REF_CD" name="DATA_REF_CD" value="${formData.DATA_REF_CD }" options="${dataRefCdOptions}" width="${form_DATA_REF_CD_W}" disabled="${form_DATA_REF_CD_D}" readOnly="${form_DATA_REF_CD_RO}" required="${form_DATA_REF_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="TOT_ASSET" title="${form_TOT_ASSET_N}" />
				<e:field>
					<e:inputNumber id="TOT_ASSET" name="TOT_ASSET" value="${formData.TOT_ASSET}" width="${form_TOT_ASSET_W}" maxValue="${form_TOT_ASSET_M}" decimalPlace="${form_TOT_ASSET_NF}" disabled="${form_TOT_ASSET_D}" readOnly="${form_TOT_ASSET_RO}" required="${form_TOT_ASSET_R}" />
				</e:field>
				<e:label for="TOT_SDEPT" title="${form_TOT_SDEPT_N}" />
				<e:field>
					<e:inputNumber id="TOT_SDEPT" name="TOT_SDEPT" value="${formData.TOT_SDEPT}" width="${form_TOT_SDEPT_W}" maxValue="${form_TOT_SDEPT_M}" decimalPlace="${form_TOT_SDEPT_NF}" disabled="${form_TOT_SDEPT_D}" readOnly="${form_TOT_SDEPT_RO}" required="${form_TOT_SDEPT_R}" onChange="setTotAsset" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="TOT_FUND" title="${form_TOT_FUND_N}" />
				<e:field>
					<e:inputNumber id="TOT_FUND" name="TOT_FUND" value="${formData.TOT_FUND}" width="${form_TOT_FUND_W}" maxValue="${form_TOT_FUND_M}" decimalPlace="${form_TOT_FUND_NF}" disabled="${form_TOT_FUND_D}" readOnly="${form_TOT_FUND_RO}" required="${form_TOT_FUND_R}" onChange="setTotAsset" />
				</e:field>
				<e:label for="TOT_SALES" title="${form_TOT_SALES_N}" />
				<e:field>
					<e:inputNumber id="TOT_SALES" name="TOT_SALES" value="${formData.TOT_SALES}" width="${form_TOT_SALES_W}" maxValue="${form_TOT_SALES_M}" decimalPlace="${form_TOT_SALES_NF}" disabled="${form_TOT_SALES_D}" readOnly="${form_TOT_SALES_RO}" required="${form_TOT_SALES_R}" onChange="setTotAsset" />
				</e:field>
				<e:label for="BUSINESS_PROFIT" title="${form_BUSINESS_PROFIT_N}" />
				<e:field>
					<e:inputNumber id="BUSINESS_PROFIT" name="BUSINESS_PROFIT" value="${formData.BUSINESS_PROFIT}" width="${form_BUSINESS_PROFIT_W}" maxValue="${form_BUSINESS_PROFIT_M}" decimalPlace="${form_BUSINESS_PROFIT_NF}" disabled="${form_BUSINESS_PROFIT_D}" readOnly="${form_BUSINESS_PROFIT_RO}" required="${form_BUSINESS_PROFIT_R}" />
				</e:field>
				<e:label for="NET_INCOM" title="${form_NET_INCOM_N}" />
				<e:field>
					<e:inputNumber id="NET_INCOM" name="NET_INCOM" value="${formData.NET_INCOM}" width="${form_NET_INCOM_W}" maxValue="${form_NET_INCOM_M}" decimalPlace="${form_NET_INCOM_NF}" disabled="${form_NET_INCOM_D}" readOnly="${form_NET_INCOM_RO}" required="${form_NET_INCOM_R}" onChange="setTotAsset" />
				</e:field>
			</e:row>
		</e:searchPanel>

        <!-- 3. 첨부파일 -->
		<e:buttonBar id="FilebuttonBar" align="right" width="100%" title="첨부파일 (첨부가능파일 각 1개)">
			<%--
			<e:button id="doFileTempletDown" name="doFileTempletDown" label="${doFileTempletDown_N}" onClick="doFileTempletDown" disabled="${doFileTempletDown_D}" visible="${doFileTempletDown_V}"/>
			--%>
        </e:buttonBar>
		<e:searchPanel id="form3" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
			<e:row>
                <e:label for="ATTACH_FILE_NUM" title="${form_ATTACH_FILE_NUM_N}"/>
                <e:field>
               		<e:fileManager id="ATTACH_FILE_NUM" name="ATTACH_FILE_NUM" fileId="${formData.ATTACH_FILE_NUM}" downloadable="true" width="100%" bizType="CUST" height="" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE_NUM_R}" fileExtension="${fileExtension}" />
                </e:field>
                <e:label for="ATTACH_FILE1_NUM" title="${form_ATTACH_FILE1_NUM_N}"/>
                <e:field>
               		<e:fileManager id="ATTACH_FILE1_NUM" name="ATTACH_FILE1_NUM" fileId="${formData.ATTACH_FILE1_NUM}" downloadable="true" width="100%" bizType="CUST" height="50px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE1_NUM_R}" fileExtension="${fileExtension}" />
                </e:field>
			</e:row>
			<e:row>
                <%--<e:label for="ATTACH_FILE2_NUM" title="${form_ATTACH_FILE2_NUM_N}"/>
                <e:field>
					<div style="width: 100%; height: 50px;">
                   	<e:fileManager id="ATTACH_FILE2_NUM" name="ATTACH_FILE2_NUM" fileId="${formData.ATTACH_FILE2_NUM}" downloadable="true" width="100%" bizType="CUST" height="100px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ATTACH_FILE2_NUM_R}" fileExtension="${fileExtension}" />
					</div>
                </e:field>--%>
				<e:label for="CI_FILE_NUM" title="${form_CI_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="CI_FILE_NUM" name="CI_FILE_NUM" fileId="${formData.CI_FILE_NUM}" downloadable="true" width="100%" bizType="IMG" height="50px" readOnly="${form_CI_FILE_NUM_RO}" required="${form_CI_FILE_NUM_R}" maxFileCount="1" fileExtension="${fileExtension}"/>
				</e:field>
				<e:label for="ATTACH_FILE4_NUM" title="${form_ATTACH_FILE4_NUM_N}" />
				<e:field>
					<e:fileManager id="ATTACH_FILE4_NUM" name="ATTACH_FILE4_NUM" fileId="${formData.ATTACH_FILE4_NUM}" downloadable="true" width="100%" bizType="CUST" height="50px" readOnly="${form_ATTACH_FILE4_NUM_RO}" required="${form_ATTACH_FILE4_NUM_R}" maxFileCount="1" fileExtension="${fileExtension}"/>
				</e:field>
			</e:row>
			<%--<e:row>
				<e:label for="ATTACH_FILE3_NUM" title="${form_ATTACH_FILE3_NUM_N}"/>
				<e:field colSpan="3">
					<e:fileManager id="ATTACH_FILE3_NUM" name="ATTACH_FILE3_NUM" fileId="${formData.ATTACH_FILE3_NUM}" downloadable="true" width="100%" bizType="CUST" height="100px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATTACH_FILE3_NUM_R}" fileExtension="${fileExtension}" />
				</e:field>
			</e:row>--%>
		</e:searchPanel>

		<br>
		<div style="display: none;">
		<!-- 7. 계산서 담당자 -->
		<e:panel id="leftP7" height="25px" width="40%">
			<e:title title="${BS01_002_CAPTION7}" depth="1" />
		</e:panel>

		<e:panel id="rightP7" height="30px" width="60%">
			<e:buttonBar id="buttonBar7" align="right" width="100%">
				<e:button id="deleteTx" name="deleteTx" label="${deleteTx_N}" onClick="dodeleteTx" disabled="${deleteTx_D}" visible="${deleteTx_V}"/>
			</e:buttonBar>
		</e:panel>
		<e:gridPanel gridType="${_gridType}" id="gridtx" name="gridtx" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridtx.gridColData}" />
		</div>
    </e:window>
</e:ui>