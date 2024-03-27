<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="editableStatus" value="${empty form.PROGRESS_CD or form.PROGRESS_CD eq '4110' or form.PROGRESS_CD eq '4220'
                                    or (form.PROGRESS_CD eq '4110' and (form.SIGN_STATUS eq 'R' or form.SIGN_STATUS eq 'C')   )}" />
<e:ui dateFmt="">

    <style type="text/css">
        .clearfix {*zoom:1;}
        .clearfix:before, .clearfix:after {display:block; content: ''; line-height: 0;}
        .clearfix:after {clear: both;}

        #ui-tabs-2 > .e-buttonbar { margin: auto; }
        .e-buttonbar { margin: auto; }
        .contract_contents_div {
            box-shadow: 5px 5px 20px #777;
            width: 700px;
            min-height: 990px;
            overflow-y: auto;
            background-color: white;
            border: 1px solid #ccc;
            padding: 15px;
            margin: 3px auto 20px;
            word-wrap: break-word;
            word-break: keep-all;
            text-align: justify;
        }
    </style>

    <!-- 전자인증 모듈 기본으로 설정 //-->
    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/econt_plugins_n.js"></script>
    <script type="text/javascript">

        var gridM;  // 계약서
        var gridA;  // 부서식
        var gridV;  // 협력사
        var gridItem;


        var baseUrl = "/evermp/buyer/cont/CT0210/";
        var userType = '${ses.userType}';
        var clickRowId;
    	var resumeFlag = "${empty resumeFlag ? false : resumeFlag}";
        var formNumUpdateState = resumeFlag;     // 이 값이 true면 서식을 확인해야 저장 등을 할 수 있다.
        var shouldConfirmSubFormNum = {};     // 이 값에 담긴 부서식 객체가 true면 부서식을 확인해야 저장 등을 할 수 있다.

        function init() {

            gridM = EVF.C("gridM");
            gridA = EVF.C("gridA");
            gridV = EVF.C("gridV");
            gridItem = EVF.C("gridItem");


            gridM.setProperty('singleSelect', true);
            gridM.setProperty('shrinkToFit', true);
            gridA.setProperty('shrinkToFit', true);
            gridV.setProperty('shrinkToFit', true);



			if('${form.CONT_NUM}'== '') {
	            gridV.addRowEvent(function() {
	    			param = {
	    					callBackFunction : 'setVendorCd'
	    				}
	    			everPopup.openPopupByScreenId('RQ0110P02', 1500, 800, param);
	            	return;
	                everPopup.openCommonPopup({
	                    callBackFunction: "setVendorCd"
	                }, 'MP0008');
	            });
	            gridV.delRowEvent(function() {
	                if(EVF.isEmpty('${form.CONT_NUM}')) {
	                    gridV.delRow();
	                } else {
	                    return EVF.alert("${CT0210_0003}");
	                }
	            });
			}




            gridM.cellClickEvent(function (rowId, colId, value) {
                gridM.checkRow(rowId, true, true, false);
                formNumUpdateState = true;

                setForm(rowId);
                setButtons();
                resetSubFormTab();
                doSearchSubForms();
            });

            gridA.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

                if (colId === "multiSelect") {

                    var subFormNum = gridA.getCellValue(rowId, 'REL_FORM_NUM');
                    var subFormName = "부서식: " + gridA.getCellValue(rowId, 'REL_FORM_NM');

                    if(value === "1") {

                        if($('#ui-tabs-'+subFormNum+'-head').length > 0) {
                            return;
                        }

                        var $tabLabel = $('<li id="ui-tabs-label-' + subFormNum + '" name=' + subFormNum + ' title="' + subFormName + '"><a href="#ui-tabs-' + subFormNum + '" style="">' + subFormName + '</a></li>');
                        $('#T1 > ul').append($tabLabel);

                        var $tab = $("<div id='ui-tabs-" + subFormNum + "' class='e-component e-tab-container' title=''></div>");
                        var $div = $("<div style='width: 100%; padding: 0; margin: 0;'>" +
                                     "<div class='contract_contents_div' id='"+subFormNum+"'></div></div>");
                        var $button = $("<div class=\"e-buttonbar\" style=\"text-align: right;width: 700px;\">\n" +
                                        "<div class=\"e-button-wrapper\"><a name=\"doConfirm\" data-formnum=\""+subFormNum+"\" class=\"e-button\" href=\"javascript://확인\"><div class=\"e-button-left-wrapper \"></div><div class=\"e-button-center-wrapper \"><div class=\"e-button-text\">확인</div></div><div class=\"e-button-right-wrapper \"></div></a></div>\n" +
                                        "</div>");

                        $tab.append($button);
                        $tab.append($div);

                        $('#T1').append($tab);
                        $('#T1').tabs('refresh');

                        attachClickEventOnConfirm();

                        shouldConfirmSubFormNum[subFormNum] = true;

                    } else {

                        var panelId = $('#ui-tabs-label-'+subFormNum).remove().attr("aria-controls");
                        $('#'+panelId).attr('src', null);
                        $('#'+panelId).remove();
                        $('#T1').tabs('refresh');
                        if(typeof CollectGarbage == 'function') {
                            CollectGarbage();
                        }

                        delete shouldConfirmSubFormNum[subFormNum];
                    }
                }
            });

            gridV.cellClickEvent(function (rowId, colId, value) {

                clickRowId = rowId;

                if(colId == "VENDOR_CD") {
                    if(EVF.isNotEmpty(EVF.V("PROGRESS_CD"))) {
                        return EVF.alert("${CT0210_0004}");
                    }
                    everPopup.openCommonPopup({
                        callBackFunction: "setVendorCdSingle"
                    }, 'SP0065');
                }
                if(colId == "VENDOR_ATT_FILE_CNT") {
                    everPopup.fileAttachPopup('ECAT', gridV.getCellValue(rowId, 'VENDOR_ATT_FILE_NUM'), (userType == "S" ? 'setFileAttach' : ''), rowId, (userType == "S" ? false : true));
                }
                if(colId == 'CONT_NUM' && value != '') {
                    var progressCd = gridV.getCellValue(rowId, "PROGRESS_CD");
                    var url = '/eversrm/econtract/CT0210/view';
                    var params = {
                        callBackFunction: 'doSearch',
                        bundleNum: '${empty param.appDocNum ? param.bundleNum : (empty form.BUNDLE_NUM ? param.bundleNum : form.BUNDLE_NUM)}',
                        contNum: '${empty param.appDocNum ? param.contNum : (empty form.CONT_NUM ? param.contNum : form.CONT_NUM)}',
                        contCnt: '${empty param.appDocNum ? param.contCnt : (empty form.CONT_CNT ? param.contCnt : form.CONT_CNT)}',
                        vendorCd: '${param.vendorCd}'
                    }
                    everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
                }
            });

            <c:if test="${editableStatus}">

                var editableBlocks = $('#cont_content').find('[contenteditable="true"]');
                for (var i = 0; i < editableBlocks.length; i++) {
                    var editor = CKEDITOR.inline(editableBlocks[i], {
                        customConfig: '/js/everuxf/lib/ckeditor/ep_config.js?var=3',
                        allowedContent: true,
                        width: '100%',
                        height: 380
                    });
                }

            </c:if>

            /*
            gridV.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


            gridV.excelImportEvent({
                'append': false
            }, function (msg, code) {

                var store = new EVF.Store();
                store.setGrid([gridV]);
                store.getGridData(gridV, 'all');
                store.load(baseUrl+'getVendorListForBundleContract', function() {

                }, false);
            });
			*/



            <c:forEach items="${subFormList}" var="subForm">
                shouldConfirmSubFormNum['${subForm.REL_FORM_NUM}'] = false;
            </c:forEach>

            EVF.C('CONT_REQ_CD').removeOption('03');
            EVF.C('CONT_REQ_CD').removeOption('04');

            setFormRequiredStatus();
            doSearchForm();
            attachClickEventOnConfirm();
            attachChangeEventsOnContractInputs();
            doSearchVendor();
        }

        <%-- 부서식 탭 클릭 시 확인 버튼에 click 이벤트 부여 --%>
        function attachClickEventOnConfirm() {

            $('a[name=doConfirm]').click(function() {

                var formNum = $(this).data('formnum');
                var existsEmptyForm = false;
                var $inputEls = $('#'+formNum).find("input, textarea");
                for(var i in $inputEls) {
                    var ipe = $inputEls[i]
                    if (ipe.value == '') {
                        existsEmptyForm = true;
                        break;
                    } else {
                        existsEmptyForm = false;
                    }
                }

                if(existsEmptyForm) {
                    if(confirm('부서식에 입력이 안된 부분을 발견했습니다. 무시하고 확인하시겠습니까?')) {
                        EVF.C('T1').setActive(1);
                    }
                } else {
                    EVF.alert('부서식을 확인하셨습니다.');
                }

                var selRowId = gridA.getSelRowId();
                for(var i in selRowId) {
                    var rowId = selRowId[i];
                    if(gridA.getCellValue(rowId, 'REL_FORM_NUM') == formNum) {
                        gridA.setCellValue(rowId, 'FORM_CONTENTS', $('#'+formNum).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                        shouldConfirmSubFormNum[formNum] = false;
                        break;
                    }
                }

                EVF.C('T1').setActive(1);
            });
        }

        function attachChangeEventsOnContractInputs() {
            $('.contract_contents_div').on('change', 'input, textarea', function() {
                var type = $(this).prop("type");
                if(type != "radio") {
                    $(this).attr("value", $(this).val());
                } else {
                    var name = $(this).prop("name");
                    $("input[name="+name+"]").removeAttr("checked");
                    $(this).attr("checked", "checked");
                    $(this).prop("checked", true);
                }
            });
        }

        /**
         *  <%-- 계약서 진행상태에 따라 버튼의 노출 처리 --%>
         *  <%-- 버튼은 기본적으로 hidden 처리되어 있으며, 계약서 진행상태에 따라 노출시킨다. --%>
         */
        function setButtons() {

            var selFormInfo = gridM.getRowValue(gridM.getSelRowId()[0]);
            var progressCd = EVF.V('PROGRESS_CD');

            var approvalFlag = selFormInfo['APPROVAL_FLAG'] === '1';      <%-- 기안유무 --%>
            var econtFlag = selFormInfo['ECONT_FLAG'] === '1';            <%-- 전자서명유무 --%>
            var signStatus = '${form.SIGN_STATUS}';                     <%-- 체결기안 결재상태 --%>

            if(${not param.detailView eq 'true'}) {

                EVF.C('doSave').setVisible(false);
                EVF.C('doDelete').setVisible(false);
                EVF.C('doReqSign').setVisible(false);
                EVF.C('doSend').setVisible(false);
                EVF.C('doSign').setVisible(false);

                <%--
                4200 : 임시저장
                4210 : 파트너사 서명대기, 4220 : 파트너사 서명반려, 4230 : 파트너사 서명완료
                4240 : 계약체결기안
                4300 : 계약체결완료
                --%>
                /*
		                진행상태 [P005]
		        4110 : 임시저장
		        4200 : 협력업체 서명대기
		        4210 : 협력업체 서명반려
		        4220 : 협력업체 서명완료
		        4300 : 계약체결완료
				*/

		        if (progressCd == '' || progressCd == '4110' || progressCd == '4210' || progressCd == '4220'
		            || (signStatus == 'R' || signStatus == 'C' || signStatus == 'T')
		        ) {
					if (progressCd == '4220' || (   (progressCd == '' || progressCd == '4110') && (signStatus == '' ||signStatus == 'R' || signStatus == 'C' || signStatus == 'T') )  ) {
		            	EVF.C('doSave').setVisible(true);
		                <c:if test="${not empty form.CONT_NUM}">
				            if(signStatus == '' || signStatus == 'R' || signStatus == 'C' || signStatus == 'T') {
				                 EVF.C('doReqSign').setVisible(true);
				            }
			                EVF.C('doDelete').setVisible(true);
		                </c:if>
					}
		        }


		                if (progressCd == '4220') { <%-- 파트너사 서명완료 시 --%>
//	                    if (approvalFlag) {
//	                        EVF.C('doReqSign').setVisible(true);
//	                    } else {
	                        EVF.C('doSign').setVisible(true);
	 //                   }
	                }


				return;






                if (progressCd == '' || progressCd == '4200' || progressCd == '4220' || progressCd == '4230'
                    || (progressCd == '4240' && (signStatus2 == 'R' || signStatus2 == 'C'))
                ) {
                    EVF.C('doSave').setVisible(true);
	                <c:if test="${not empty form.CONT_NUM}">
	                    EVF.C('doDelete').setVisible(true);
	                </c:if>
                    if(progressCd == '4240' && (signStatus2 == '' || signStatus2 == 'R' || signStatus2 == 'C')) {
                        if (approvalFlag) {
                            EVF.C('doReqSign').setVisible(true);
                        }
                    }
                }
                if(progressCd == '4200') {
                    EVF.C('doSend').setVisible(true);
                }

                if (progressCd == '4220') { <%-- 파트너사 서명완료 시 --%>
//                    if (approvalFlag) {
//                        EVF.C('doReqSign').setVisible(true);
//                    } else {
                        EVF.C('doSign').setVisible(true);
 //                   }
                }








            }
        }

        function loadMainForm() {

          <c:if test="${editableStatus}">
            if(gridM.isExistsSelRow()) {

                var store = new EVF.Store();
                store.setGrid([gridA,gridItem]);

                store.getGridData(gridItem, 'all');

                store.setParameter('contNum', '${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}');
                store.setParameter('contCnt', '${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}');
                store.setParameter('selectedFormNum', gridM.getSelRowValue()[0].FORM_NUM);
                store.setParameter('isUpdatedFormNum', formNumUpdateState);
                store.setParameter('formContents', $('#cont_content').html());
                store.load('/evermp/buyer/cont/CT0110P01/getContractForm', function() {

                    $('#cont_content').html(this.getParameter("contractForm"));

                    var editableBlocks = $('#cont_content').find('[contenteditable="true"]');
                    for (var i = 0; i < editableBlocks.length; i++) {
                        editor = CKEDITOR.inline(editableBlocks[i], {
                            customConfig: '/js/everuxf/lib/ckeditor/ep_config.js?var=3',
                            allowedContent: true,
                            width: '100%',
                            height: 380
                        });
                    }

                    formNumUpdateState = false;

                    $('input[name=changeVal_99]', '#cont_content').autoNumeric("init", {
                        "mDec" : "99",
                        "aPad" : false,
                        "wEmpty" : "empty",
                        "aForm": false
                    });
                });
            }
            </c:if>
        }

        function doSearchForm() {

            var store = new EVF.Store();
            store.setGrid([ gridM,gridItem ]);
            store.setParameter("bundleFlag", "1");

//            store.setParameter("resumeFlag", resumeFlag);

            store.load('/evermp/buyer/cont/CT0110P01/doSearchMainForm', function() {
                gridM.checkRow(0, true, true, false);
                doSearchSubForms();
                setButtons();
            });
        }

        // 부서식 탭을 모두 초기화한다.
        function resetSubFormTab() {

            $('#T1 > ul > li').each(function(index, b) {
                var targetTabId = $('a', $(b)).attr('href');
                if( !(targetTabId == '#ui-tabs-1' || targetTabId == '#ui-tabs-2') ) {
                    var tid = targetTabId.replace('#', '');
                    $('#T1 > ul > li[aria-controls='+tid+']').remove();
                    $('#T1 div[id='+tid+']').attr('src', null).remove();
                }
            });

            $('#T1').tabs('refresh');
        }

        function doSearchSubForms() {

            if(gridM.isExistsSelRow()) {

                var store = new EVF.Store();
                store.setParameter('selectedFormNum', gridM.getSelRowValue()[0].FORM_NUM);
                store.setGrid([ gridA ]);
                store.load('/evermp/buyer/cont/CT0110P01/doSearchAdditionalForm', function() {
                    if(EVF.isNotEmpty('${form.CONT_NUM}')) {
                        var rowIds = gridA.getAllRowId();
                        for(var i = 0; i < rowIds.length; i++) {
                            if(EVF.isNotEmpty(gridA.getCellValue(rowIds[i], 'FORM_SQ'))) {
                                gridA.checkRow(rowIds[i], true);
                                gridA.setCellValue(rowIds[i], 'FORM_CONTENTS', $('#' + gridA.getCellValue(rowIds[i], 'REL_FORM_NUM')).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                            }
                        }
                    }
                }, false);
            }
        }

        function doSearchVendor() {

            var progressCd = EVF.V('PROGRESS_CD');
            var store = new EVF.Store();
            store.setGrid([gridV]);
            store.setParameter("bundleNum", '${empty param.appDocNum ? param.bundleNum : (empty form.BUNDLE_NUM ? param.bundleNum : form.BUNDLE_NUM)}');
            store.setParameter("contNum", '${empty param.appDocNum ? param.contNum : (empty form.CONT_NUM ? param.contNum : form.CONT_NUM)}');
            store.setParameter("contCnt", '${empty param.appDocNum ? param.contCnt : (empty form.CONT_CNT ? param.contCnt : form.CONT_CNT)}');
            store.load(baseUrl + 'getSavedVendorListForBundleContract', function() {

            }, false);
        }

        // 폼과 그리드의 값을 체크한다.
        function checkFormValidation() {

            var store = new EVF.Store();
            if(!store.validate()) {
                EVF.C('T1').setActive(0);
                return false;
            }

            if(!gridM.isExistsSelRow()) {
                EVF.alert('계약서 서식을 선택하셔야 합니다.');
                return false;
            }

            if(!gridV.isExistsRow()) {
                EVF.alert('파트너사를 업로드하셔야 합니다.');
                return false;
            }

            var subFormGridRowId = gridA.getAllRowId();
            for(var i in subFormGridRowId) {
                var rowId = subFormGridRowId[i];
                if(gridA.getCellValue(rowId, 'REQUIRE_FLAG') === '1' && !gridA.isChecked(rowId)) {
                    EVF.alert('['+gridA.getCellValue(rowId, 'REL_FORM_NM')+'] 부서식은 반드시 선택하셔야 합니다.');
                    return false;
                }
            }

            for(var id in shouldConfirmSubFormNum) {
                if(shouldConfirmSubFormNum[id] === true) {
                    EVF.alert('확인되지 않은 부서식이 있습니다. 부서식을 모두 확인해주시고 확인버튼을 눌러주세요.');
                    return false;
                }
            }
/*
            var validResult = true;
            var $inputEls = $('.contract_contents_div').find("input, textarea");
            for(var i in $inputEls) {
                var ipe = $inputEls[i]
                if(ipe.value == '') {
                    $('html, body').animate({scrollTop: $(ipe).offset().top-100}, 1000, function() {
                        ipe.focus();
                    });
                    return EVF.alert('서식에 입력이 안된 부분이 있습니다. 입력할 내용이 없다면 공백을 입력해주세요.');
                }
            }
*/
			var validResult = true;
			var $inputEls = $('.contract_contents_div').find("input, textarea");
			for(var i in $inputEls) {
			    var ipe = $inputEls[i];

			    if ((ipe.name != undefined && ipe.name.indexOf("changeVal") > -1) && ipe.value == '') {
			        $('html, body').animate({scrollTop: $(ipe).offset().top-100}, 1000, function() {
			            ipe.focus();
			        });
			        return EVF.alert('서식에 입력이 안된 부분이 있습니다. 입력할 내용이 없다면 공백을 입력해주세요.');
			    }
			}



            return validResult;
        }

        <%-- 임시저장 --%>
        function doSave() {

            if(!checkFormValidation()) { return; }

            EVF.confirm("${msg.M0021 }", function () {
                var store = new EVF.Store();
                store.setParameter('mainContractContents', $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                store.setGrid([gridM, gridA, gridV]);
                store.getGridData(gridM, 'sel');
                store.getGridData(gridA, 'sel');
                store.getGridData(gridV, 'all');
                store.doFileUpload(function() {
                    store.load(baseUrl + 'doSave', function() {
                        EVF.alert('${msg.M0031}', function() {

                            if (opener) {
                                opener.doSearch();
                                doClose();
                            } else {
                                location.href = baseUrl + 'view';
                            }

//                            if (opener) { opener.doSearch(); }
//                            location.href = baseUrl + "view.so?bundleNum=" + '${empty param.appDocNum ? param.bundleNum : (empty form.BUNDLE_NUM ? param.bundleNum : form.BUNDLE_NUM)}' + "&contNum=" + '${empty param.appDocNum ? param.contNum : (empty form.CONT_NUM ? param.contNum : form.CONT_NUM)}' + "&contCnt=" + '${empty param.appDocNum ? param.contCnt : (empty form.CONT_CNT ? param.contCnt : form.CONT_CNT)}';
                        });
                    });
                });
            });
        }

        <%-- 계약서 전송 --%>
        function doSend() {

            if(!checkFormValidation()) { return; }

            EVF.confirm("${CT0210_0001 }", function () {
                var store = new EVF.Store();
                store.setParameter('mainContractContents', $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                store.setGrid([gridM, gridA, gridV]);
                store.getGridData(gridM, 'sel');
                store.getGridData(gridA, 'sel');
                store.getGridData(gridV, 'all');
                store.load(baseUrl + 'doSendContract', function() {
                    EVF.alert(this.getResponseMessage(), function() {
                        if (opener) {
                            opener.doSearch();
                            doClose();
                        }
                    });
                });
            });
        }

        <%-- 계약 체결기안 --%>
        function doReqSign() {

            if (!checkFormValidation()) { return; }

            EVF.confirm("${CT0210_0005 }", function () {
                var param = {
                    subject: EVF.C('CONT_DESC').getValue(),
                    docType: "CONT2",
                    signStatus: "P",
                    screenId: "CT0210",
                    approvalType: 'APPROVAL',
                    oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
                    attFileNum: "",
                    docNum: EVF.C('CONT_NUM').getValue(),
                    appDocNum: EVF.C('APP_DOC_NUM').getValue(),
                    callBackFunction: "goApprovalCont"
                };
                everPopup.openApprovalRequestIIPopup(param);
            });
        }

        function goApprovalCont(formData, gridData, attachData) {

            EVF.V('approvalFormData', formData);
            EVF.V('approvalGridData', gridData);
            EVF.V('attachFileDatas', attachData);
            EVF.V('SIGN_STATUS', "P");

            var store = new EVF.Store();
            store.setParameter('mainContractContents', $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
            store.setGrid([gridM, gridA, gridV]);
            store.getGridData(gridM, 'sel');
            store.getGridData(gridA, 'sel');
            store.getGridData(gridV, 'all');
            store.doFileUpload(function() {
                store.load(baseUrl + 'doReqSign', function() {
                    EVF.alert(this.getResponseMessage(), function() {

                        if (opener) {
                            opener.doSearch();
                            doClose();
                        } else {
                            location.href = baseUrl + 'view';
                        }


//                    	if (opener) { opener.doSearch(); }
//                        location.href = baseUrl + "view.so?bundleNum=" + '${empty param.appDocNum ? param.bundleNum : (empty  form.BUNDLE_NUM ? param.bundleNum : form.BUNDLE_NUM)}' + "&contNum=" + '${empty param.appDocNum ? param.contNum : (empty form.CONT_NUM ? param.contNum : form.CONT_NUM)}' + "&contCnt=" + '${empty param.appDocNum ? param.contCnt : (empty form.CONT_CNT ? param.contCnt : form.CONT_CNT)}';
                    });
                });
            });
        }

        <%-- 삭제 --%>
        function doDelete() {

            var progressCd = EVF.V("PROGRESS_CD");

            EVF.confirm("${msg.M0013 }", function () {
                var store = new EVF.Store();
                store.setParameter("bundleNum", '${empty param.appDocNum ? param.bundleNum : (empty form.BUNDLE_NUM ? param.bundleNum : form.BUNDLE_NUM)}');
                store.setParameter("contNum", '${empty param.appDocNum ? param.contNum : (empty form.CONT_NUM ? param.contNum : form.CONT_NUM)}');
                store.setParameter("contCnt", '${empty param.appDocNum ? param.contCnt : (empty form.CONT_CNT ? param.contCnt : form.CONT_CNT)}');
                store.load(baseUrl + "doDeleteBundleContract", function () {
                    EVF.alert(this.getResponseMessage(), function() {
                        if (opener) {
                            opener.doSearch();
                            doClose();
                        } else {
                            location.href = baseUrl + 'view';
                        }
                    });
                });
            });
        }

        <%-- 서명 --%>
        function doSign() {

            EVF.confirm("${CT0210_0006 }", function () {
                var store = new EVF.Store();
                store.load(baseUrl + 'signContract', function() {

                	//alert(this.getResponseMessage());
                    if (opener) {
                        opener.doSearch();
                        doClose();
                    }


                }, true);
            });
        }

        function onActiveTab(newTabId, oldTabId, event) {
            if(newTabId === '1') {

            } else if(newTabId === '2') {
                loadMainForm();
            } else {    <%-- 부서식탭 활성화 --%>

            <c:if test="${empty form.PROGRESS_CD or form.PROGRESS_CD eq '4200'}">
                var store = new EVF.Store();
                store.setParameter('contNum', '${empty param.appDocNum ? param.contNum : (form.CONT_NUM ? param.contNum : form.CONT_NUM)}');
                store.setParameter('contCnt', '${empty param.appDocNum ? param.contCnt : (form.CONT_CNT ? param.contCnt : form.CONT_CNT)}');
                store.setParameter('selectedFormNum', newTabId);
                store.setParameter('isUpdatedFormNum', shouldConfirmSubFormNum[newTabId]);
                store.setParameter('formContents', $('#'+newTabId).html());
                store.load('/evermp/buyer/cont/CT0110P01/getSubContractForm', function() {
                    $('#'+newTabId).html(this.getParameter("contractForm"));
                    attachChangeEventsOnContractInputs();

                    var editableBlocks = $('#'+newTabId).find('[contenteditable="true"]');
                    for (var i = 0; i < editableBlocks.length; i++) {
                        console.log(i);
                        editor = CKEDITOR.inline(editableBlocks[i], {
                            customConfig: '/js/everuxf/lib/ckeditor/ep_config.js?var=3',
                            allowedContent: true,
                            width: '100%',
                            height: 380
                        });
                    }

                    $('input[name=changeVal_99]', '#'+newTabId).autoNumeric("init", {
                        "mDec" : "99",
                        "aPad" : false,
                        "wEmpty" : "empty",
                        "aForm": false
                    });
                });
            </c:if>
            }
        }

        function onBeforeActiveTab() {

        }

        function setFormRequiredStatus() {
            EVF.C('ATT_FILE_NUM').setRequired(EVF.V('CONT_REQ_CD') === '1');
        }

        function setForm(rowId) {
            var econtFlag = gridM.getCellValue(rowId, 'ECONT_FLAG');    // 전자서명 여부
            EVF.V('MANUAL_CONT_FLAG', (econtFlag === '1' ? "0" : "1"));
        }

        function getDrafter() {
            if (userType != 'S') {
                everPopup.openCommonPopup({
                    callBackFunction: "setDrafter"
                }, 'SP0001');
            }
        }

        function setDrafter(drafter) {
            EVF.C("CONT_USER_ID").setValue(drafter.USER_ID);
            EVF.C("CONT_USER_NM").setValue(drafter.USER_NM);
        }

        function setVendorCd(vendor) {

        	var vendor = JSON.parse(vendor);

            if (vendor.length != undefined) {
                var dataArr = [];
                //alert(vendor.length)
                for (idx in vendor) {
                	//alert(idx)
                    var arr = {
                        'VENDOR_CD': vendor[idx].VENDOR_CD,
                        'VENDOR_NM': vendor[idx].VENDOR_NM,
                        'VENDOR_PIC_USER_NM': vendor[idx].USER_NM,
                        'VENDOR_PIC_USER_EMAIL': vendor[idx].EMAIL,
                        'VENDOR_PIC_USER_EMAIL': vendor[idx].EMAIL,
                        'VENDOR_PIC_CELL_NUM': vendor[idx].CELL_NUM,
                        'IRS_NUM': vendor[idx].IRS_NO

                	};
                    dataArr.push(arr);
                }
                var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridV, "VENDOR_CD");
                gridV.addRow(validData);
            }
        }

        function setVendorCdSingle(vendor) {
            gridV.setCellValue(clickRowId, 'VENDOR_CD', vendor.VENDOR_CD);
            gridV.setCellValue(clickRowId, 'VENDOR_NM', vendor.VENDOR_NM);
            gridV.setCellValue(clickRowId, 'VENDOR_PIC_USER_NM', vendor.VENDOR_PIC_USER_NM);
            gridV.setCellValue(clickRowId, 'VENDOR_PIC_USER_EMAIL', vendor.VENDOR_PIC_USER_EMAIL);
            gridV.setCellValue(clickRowId, 'IRS_NUM', vendor.IRS_NUM);
        }

        function setFileAttach(rowId, fileId, fileCnt) {
            gridV.setCellValue(rowId, 'VENDOR_ATT_FILE_CNT', fileCnt);
            gridV.setCellValue(rowId, 'VENDOR_ATT_FILE_NUM', fileId);
        }

        function doClose() {
            if(opener) {
                window.open("", "_self");
                window.close();
            } else if(parent) {
                new EVF.ModalWindow().close(null);
            }
        }

		function doPrint() {
			fileFrame.location.href = '/common/file/fileAttach/downloadContPdf.so?contNum=${form.CONT_NUM}&contCnt=${form.CONT_CNT}';
		}


    </script>

    <e:window id="CT0210" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">
        <e:tabPanel id="T1" onActive="onActiveTab" onBeforeActive="onBeforeActiveTab">
            <e:tab id="1" title="기본정보">

            <e:inputHidden id='BUNDLE_NUM' name='BUNDLE_NUM' value='${empty form.BUNDLE_NUM ? param.bundleNum : form.BUNDLE_NUM}'/>
            <e:inputHidden id='CONT_NUM' name='CONT_NUM' value='${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}'/>
            <e:inputHidden id='CONT_CNT' name='CONT_CNT' value='${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}'/>

            <e:inputHidden id='NEW_CONT_CNT' name='NEW_CONT_CNT' value='${empty form.NEW_CONT_CNT ? null : form.NEW_CONT_CNT}'/>


            <e:inputHidden id='PROGRESS_CD' name='PROGRESS_CD' value='${form.PROGRESS_CD}'/>
            <e:inputHidden id='SEARCH_TYPE' name='SEARCH_TYPE' value='${form.SEARCH_TYPE}'/>
            <e:inputHidden id='CONTRACT_TYPE' name='CONTRACT_TYPE' value='${form.CONTRACT_TYPE}'/>
            <e:inputHidden id='CONTRACT_TEXT_NUM' name='CONTRACT_TEXT_NUM' value='${form.CONTRACT_TEXT_NUM}'/>
            <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${empty form.BUYER_CD ? param.BUYER_CD : form.BUYER_CD}"/>
            <e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${empty form.BUYER_NM ? param.BUYER_NM : form.BUYER_NM}"/>
            <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${empty form.APP_DOC_NUM ? param.appDocNum2 : form.APP_DOC_NUM}"/>
            <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${empty form.APP_DOC_CNT ? param.appDocCnt2 : form.APP_DOC_CNT}"/>
            <e:inputHidden id='SIGN_STATUS' name="SIGN_STATUS" value="${form.SIGN_STATUS}" />
            <e:inputHidden id="approvalFormData" name="approvalFormData" value="" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" value="" />
            <e:inputHidden id="attachFileDatas" name="attachFileDatas" visible="false" />
            <e:inputHidden id="openFormType" name="openFormType" value="B" />
            <e:inputHidden id='FORM_NUM' name='FORM_NUM' value='${form.MAIN_FORM_NUM}' alt="주계약서 서식번호" />



            <div class="clearfix">
                <e:panel width="100%">
                    <e:title title="기본정보" />
                    <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="135" useTitleBar="false">
                        <e:row>
							<%--구매운영조직코드--%>
							<e:label for="PUR_ORG_CD" title="${form_PUR_ORG_CD_N}"/>
							<e:field>
							<e:select id="PUR_ORG_CD" name="PUR_ORG_CD" value="" options="${purOrgCdOptions}" width="${form_PUR_ORG_CD_W}" disabled="${form_PUR_ORG_CD_D}" readOnly="${form_PUR_ORG_CD_RO}" required="${form_PUR_ORG_CD_R}" placeHolder="" usePlaceHolder="false"/>
							</e:field>
                            <e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"/>
                            <e:field>
                                <e:select id="CONT_REQ_CD" name="CONT_REQ_CD" value="${empty form.CONT_REQ_CD ? param.CONT_REQ_CD : form.CONT_REQ_CD}" options="${contReqCdOptions}" width="${form_CONT_REQ_CD_W}" disabled="${form_CONT_REQ_CD_D}" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder="" usePlaceHolder="false" onChange="setFormRequiredStatus" />
                            </e:field>
                            <e:label for="MANUAL_CONT_FLAG" title="${form_MANUAL_CONT_FLAG_N}"/>
                            <e:field>
                                <e:select id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="${empty form.MANUAL_CONT_FLAG ? param.MANUAL_CONT_FLAG : form.MANUAL_CONT_FLAG}" options="${manualContFlagOptions}" width="${form_MANUAL_CONT_FLAG_W}" disabled="${form_MANUAL_CONT_FLAG_D}" readOnly="${form_MANUAL_CONT_FLAG_RO}" required="${form_MANUAL_CONT_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                            </e:field>
                        </e:row>
                        <e:row>
	                        <e:label for="CONT_NUM" title="${form_CONT_NUM_N}"/>
	                        <e:field>
	                            <e:text>${not empty form.CONT_NUM ? form.CONT_NUM_AND_CNT : ""}</e:text>
	                        </e:field>
                            <e:label for="CONT_DESC" title="${form_CONT_DESC_N }"/>
                            <e:field colSpan="3">
                                <e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="${empty form.CONT_DESC ? param.CONT_DESC : form.CONT_DESC}" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}"/>
                            </e:field>
                        </e:row>
                        <e:row>
                            <e:label for="CONT_DATE" title="${form_CONT_DATE_N }"/>
                            <e:field>
                                <e:inputDate id="CONT_DATE" name="CONT_DATE" value="${empty form.CONT_DATE ? toDate : form.CONT_DATE}}" width="${inputTextDate }" required="${form_CONT_DATE_R }" readOnly="${form_CONT_DATE_RO }" disabled="${form_CONT_DATE_D }" datePicker="true"/>
                            </e:field>
                            <e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N }"/>
                            <e:field>
                                <e:inputDate id="CONT_START_DATE" name="CONT_START_DATE" value="${empty form.CONT_START_DATE ? param.CONT_START_DATE : form.CONT_START_DATE}" width="${inputTextDate }" required="${form_CONT_START_DATE_R }" readOnly="${form_CONT_START_DATE_RO }" disabled="${form_CONT_START_DATE_D }" datePicker="true"/>
                                <e:text>~</e:text>
                                <e:inputDate id="CONT_END_DATE" name="CONT_END_DATE" value="${empty form.CONT_END_DATE ? param.CONT_END_DATE : form.CONT_END_DATE}" width="${inputTextDate }" required="${form_CONT_END_DATE_R }" readOnly="${form_CONT_END_DATE_RO }" disabled="${form_CONT_END_DATE_D }" datePicker="true"/>
                            </e:field>
                            <e:label for="CONT_USER_NM" title="${form_CONT_USER_ID_N }"/>
                            <e:field>
                                <e:search id="CONT_USER_NM" name="CONT_USER_NM" width="140px" value="${empty form.CONT_USER_NM ? ses.userNm : form.CONT_USER_NM}" maxLength="${form_CONT_USER_NM_M }" required="${form_CONT_USER_NM_R }" disabled="${form_CONT_USER_NM_D }" readOnly="${form_CONT_USER_NM_RO }" onIconClick="getDrafter"/>
                                <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${empty form.CONT_USER_ID ? ses.userId : form.CONT_USER_ID}"/>
                            </e:field>
                        </e:row>

                        <e:row>
							<e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
							<e:field colSpan="5">
							<e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="${empty form.SHIPPER_TYPE ? 'C' : form.SHIPPER_TYPE}" options="${shipperTypeOptions}" width="${form_SHIPPER_TYPE_W}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
							</e:field>
                        </e:row>

                        <e:row>
                            <e:label for="CONT_REQ_RMK" title="${form_CONT_REQ_RMK_N}"/>
                            <e:field colSpan="5">
                                <e:textArea id="CONT_REQ_RMK" style="${imeMode}" name="CONT_REQ_RMK" height="130" value="${empty form.CONT_REQ_RMK ? param.CONT_REQ_RMK : form.CONT_REQ_RMK}" width="100%" maxLength="${form_CONT_REQ_RMK_M}" disabled="${form_CONT_REQ_RMK_D}" readOnly="${form_CONT_REQ_RMK_RO}" required="${form_CONT_REQ_RMK_R}"/>
                            </e:field>
                        </e:row>
                    </e:searchPanel>

                    <e:panel width="100%">
                        <e:title title="계약서 서식"/>
                        <e:panel width="60%" style="z-index: 10">
                            <e:gridPanel id="gridM" name="gridM" width="100%" height="200" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridM.gridColData}" />
                        </e:panel>
                        <e:panel width="1%" />
                        <e:panel width="39%">
                            <e:gridPanel id="gridA" name="gridA" width="100%" height="200" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridA.gridColData}" />
                        </e:panel>
                    </e:panel>




                <e:title title="첨부파일"/>

                <e:searchPanel id="form2" title="${form_CAPTION_N }" columnCount="2" labelWidth="155" useTitleBar="false">
                    <e:row>
                        <c:set var="attFileEditable" value="${empty form.PROGRESS_CD or form.ATT_FILE_EDITABLE eq 'true'}"/>
                        <e:label for="M_ATT_FILE_NUM" title="${form_M_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="M_ATT_FILE_NUM" height="130" width="100%" fileId="${form.M_ATT_FILE_NUM}" readOnly="${not attFileEditable}" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
                        <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="ATT_FILE_NUM" height="130" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${not attFileEditable}" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
                    </e:row>
                </e:searchPanel>






                    <e:panel width="100%">
                        <e:title title="협력업체" />
                        <e:gridPanel id="gridV" name="gridV" width="100%" height="500" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridV.gridColData}" />
<div style="display:none">
                        <e:gridPanel id="gridItem" name="gridItem" width="0" height="0" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridItem.gridColData}" />
</div>
                    </e:panel>

                </e:panel>
            </div><br>
            </e:tab>

            <e:tab id="2" title="일괄계약서 서식">
                <c:if test="${not param.detailView eq 'true'}">
                    <e:buttonBar width="700" align="right">
                        <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                        <e:button id="doSend" name="doSend" label="${doSend_N}" onClick="doSend" disabled="${doSend_D}" visible="${doSend_V}"/>
                        <e:button id="doReqSign" name="doReqSign" label="${doReqSign_N}" onClick="doReqSign" disabled="${doReqSign_D}" visible="${doReqSign_V}"/>
                        <e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
                        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>

                        <c:if test="${form.PROGRESS_CD ne null}">
							<e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
						</c:if>


                    </e:buttonBar>
                </c:if>
                <div style="width: 100%; padding: 0; margin: 0;">
                    <div class="contract_contents_div" id="cont_content" class="contract_contents">${fn:replace(fn:replace(fn:replace(form.formContents, "&lt;", "<"), "&gt;", ">"), "&quot;", "\"")}</div>
                </div>
            </e:tab>

            <c:forEach items="${subFormList}" var="subForm">
                <e:tab id="${subForm.REL_FORM_NUM}" title="부서식: ${subForm.REL_FORM_NM}">
                    <c:if test="${editableStatus}">
                    <div class="e-buttonbar" style="text-align: right;width: 700px;">
                        <div class="e-button-wrapper"><a name="doConfirm" data-formnum="${subForm.REL_FORM_NUM}" class="e-button" href="javascript://확인">
                            <div class="e-button-left-wrapper "></div>
                            <div class="e-button-center-wrapper ">
                                <div class="e-button-text">확인</div>
                            </div>
                            <div class="e-button-right-wrapper "></div>
                        </a></div>
                    </div>
                    </c:if>
                    <div style="width: 100%; padding: 0; margin: 0;">
                        <div class="contract_contents_div" id="${subForm.REL_FORM_NUM}" class="contract_contents">${fn:replace(fn:replace(fn:replace(subForm.CONTRACT_TEXT, "&lt;", "<"), "&gt;", ">"), "&quot;", "\"")}</div>
                    </div>
                </e:tab>
            </c:forEach>

        </e:tabPanel>

        <iframe id="fileFrame" name="fileFrame" style="display: block;" height="0"></iframe>


    </e:window>

</e:ui>