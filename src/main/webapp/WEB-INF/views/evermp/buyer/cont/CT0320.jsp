<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- 계약서를 수정할 수 있는 상태변수(저장 전, 임시저장(4110), 협력사서명반려(4220), 법무팀 검토/체결기안(4203)이면서 결재반려 상태) --%>
<c:set var="editableStatus" value="${empty form.PROGRESS_CD or form.PROGRESS_CD eq '4110' or form.PROGRESS_CD eq '4210'
                                    or (form.PROGRESS_CD eq '4203' and (form.SIGN_STATUS eq 'R' or form.SIGN_STATUS eq 'C'))
                                    or (form.PROGRESS_CD eq '4240' and (form.SIGN_STATUS2 eq 'R' or form.SIGN_STATUS2 eq 'C'))}" />

<%-- 수정가능상태에 따라 그리드 높이를 조절하기 위한 변수 --%>
<c:set var="formSelGridHeight" value="${editableStatus ? '160' : '140'}" />
<c:set var="formSelPanelHeight" value="${editableStatus ? '190' : '160'}" />

<e:ui>

    <style type="text/css">
        .e-buttonbar { margin: auto; }
        .contract_contents_div {
            box-shadow		 : 5px 5px 20px #777;
            width			 : 700px;
            min-height		 : 990px;
            overflow-y		 : auto;
            background-color : white;
            border			 : 1px solid #ccc;
            padding			 : 15px;
            margin			 : 3px auto 20px;
            word-wrap		 : break-word;
            word-break		 : keep-all;
            text-align		 : justify;
        }

    </style>

    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/js/everuxf/lib/ckeditor/econt_plugins_n.js"></script>
    <script type="text/javascript">

        var gridM;
        var gridA;
        var gridP;
        var gridItem;
        var editor;
        var prBuyerVal	= "";
        var baseUrl  	= "/evermp/buyer/cont/CT0320/";
        var userType 	= '${ses.userType}';   <%--  --%>
        var openType 	= '${openType}';       <%-- 'createCont' : 계약대기현황에서 신규계약, null : 계약서 작성--%>
    	var resumeFlag 	= "${empty resumeFlag ? false : resumeFlag}";
        var formNumUpdateState = false;
        var shouldConfirmSubFormNum = {};   <%-- 이 값에 담긴 부서식 객체가 true면 부서식을 확인해야 저장 등을 할 수 있다. --%>

        CKEDITOR.disableAutoInline = true;  // 인라인에디터를 자동으로 초기화하는 것을 방지(원하는 영역만 수동으로 에디터를 로드하기 위해)

		var gwUseFlag = '0';   <%-- GW 결재여부--%>
        var first_view = true;
        var pResetFlag = true;
        var erpData = false;

        function init() {


        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-M_ATT_FILE_NUM').css('display','none');
        		$('#upload-button-ATT_FILE_NUM').css('display','none');
        		$('#upload-button-CONT_ATT_FILE_NUM').css('display','none');
        		$('#upload-button-ADV_ATT_FILE_NUM').css('display','none');
        		$('#upload-button-WARR_ATT_FILE_NUM').css('display','none');
        	}
            gridM = EVF.C("gridM");
            gridA = EVF.C("gridA");
            gridP = EVF.C("gridP");
            gridItem = EVF.C("gridItem");
            gridM.setProperty('singleSelect'  , true);
            gridM.setProperty('shrinkToFit'	  , true);
            gridA.setProperty('shrinkToFit'	  , true);
            gridP.setProperty('shrinkToFit'	  , true);
            gridItem.setProperty('shrinkToFit', true);
			EVF.C('PR_BUYER_NM').setReadOnly(true);
			//console.log("${form.CONT_AMT}");


        	gridItem.excelExportEvent({
				allCol	 : "${excelExport.allCol}",
				selRow	 : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }"
			});


			//체크박스 헤더 삭제
			gridA._gvo.setCheckBar({
				  showAll: false
				});

            gridItem.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){

				if (colIdx == 'ITEM_QT' || colIdx == 'UNIT_PRC'  || colIdx == 'VAT_CD') {

					var qtaNum = gridItem.getCellValue(rowIdx,'QTA_NUM');
					if(qtaNum != '') {

						if('${form.CONT_CNT}' == '1') {
	                        EVF.alert("${CT0320_G0001}");
							gridItem.setCellValue(rowIdx,colIdx,oldValue);
						}
					}
					setContAmt();
				}
			});
            //매뉴얼 최초작성일때만.
		    if(opener==null){
		    	gridItem.addRowEvent(function() {
		    		gridItem.addRow();
		    		gridItem.setCellReadOnly(gridItem.getAllRowId().length-1, "ITEM_DESC", false);
					gridItem.setCellReadOnly(gridItem.getAllRowId().length-1, "ITEM_SPEC", false);
					gridItem.setCellReadOnly(gridItem.getAllRowId().length-1, "UNIT_CD", false);
					gridItem.setCellValue(gridItem.getAllRowId().length-1, "UNIT_CD", 'EA');
		    	});
	            gridItem.delRowEvent(function() {
					if(!gridItem.isExistsSelRow()) { return alert("${msg.M0004}"); }
					gridItem.delRow();
				});

			}



            gridItem.cellClickEvent(function (rowId, colId, value) {
                if (colId == 'VAT_DTL_NM') {
                    param = {
                         rowId : rowId
                        ,callBackFunction : 'seTaxMethod'
                    }
                    everPopup.openCommonPopup(param, 'SP0502');
                 } else if (colId == 'PLANT_NM') {
					    param = {
							    rowId : rowId,
							    BUYER_CD : EVF.V("PR_BUYER_CD") ,
							    callBackFunction : "callbackGrid_PLANT_NM"
						    };
						    everPopup.openCommonPopup(param, "SP0503");
                 } else if (colId == 'WH_NM') {
					    param = {
						    rowId    		 : rowId,
						    PLANT_CD 		 : gridItem.getCellValue(rowId,"PLANT_CD"),
						    PLANT_NM 		 : gridItem.getCellValue(rowId,"PLANT_NM"),
							BUYER_CD 		 : gridItem.getCellValue(rowId,"LOC_BUYER_CD"),
						    callBackFunction : "callbackGrid_WH_NM"
					    };
						everPopup.openCommonPopup(param, "SP0501");
                 }
			});


            gridM.cellClickEvent(function (rowId, colId, value) {
                gridM.checkRow(rowId, true, true, false);
                formNumUpdateState = true;
                first_view 		   = true;
                pResetFlag 		   = false;
				if(gridM.getCellValue(rowId,"CONTRACT_FORM_TYPE") == 'ISU'){
				    EVF.V("CONT_AMT", '0');
				}else{
					contAmtPaySum();
				}
                setForm(rowId);
                setButtons();

                if(EVF.isEmpty("${form.PROGRESS_CD}") || (resumeFlag == "true")){
                    resetSubFormTab();
                    doSearchSubForms();
                }
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

            gridP.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {
                if (colIdx == "PAY_PERCENT" || colIdx == "VAT_TYPE") {

					if(EVF.isEmpty(EVF.V("SUPPLY_AMT")) || Number(EVF.V("SUPPLY_AMT"))==0){

						return alert("${CT0320_0011}");
					}
//                    var contAmt = Number(EVF.V("CONT_AMT"));
                    var contAmt = Number(EVF.V("SUPPLY_AMT"));
                    var payPer  = Number(gridP.getCellValue(rowIdx, 'PAY_PERCENT'));
                    var payAmt  = 0;
                    if(payPer > 0 && contAmt > 0) {
                        payAmt = Math.round(contAmt * (payPer / 100));
                    } else {
                        payAmt = 0;
                    }

                    gridP.setCellValue(rowIdx, 'SUPPLY_AMT', payAmt);

                    if(gridP.getCellValue(rowIdx, 'VAT_TYPE') == "0") {
                        gridP.setCellValue(rowIdx, 'VAT_AMT', (payAmt * 0.1));
                    } else if(gridP.getCellValue(rowIdx, 'VAT_TYPE') == "1") { // 부가세포함
                        gridP.setCellValue(rowIdx, 'VAT_AMT', (payAmt * 0.1));
                        payAmt = payAmt + (payAmt * 0.1);
                    } else {
                        gridP.setCellValue(rowIdx, 'VAT_AMT', 0);
                    }
                    gridP.setCellValue(rowIdx, 'PAY_AMT', payAmt);
// 					EVF.V("CONT_AMT",payAmt);

                    if(gridP.getCellValue(rowIdx, 'PAY_CNT_TYPE') == "DP" && !EVF.isEmpty(EVF.V("ADV_GUAR_PERCENT"))) {

                        var dpAmt = 0;
                        var rowIds = gridP.getAllRowId();
                        for(var i in rowIds) {
                            if(gridP.getCellValue(rowIds[i], 'PAY_CNT_TYPE') == "DP") {
                                dpAmt = dpAmt + Number(gridP.getCellValue(rowIds[i], 'PAY_AMT'));
                            }
                        }
                        var advGuarPer = Number(EVF.V("ADV_GUAR_PERCENT"));
                        var advGuarAmt = 0;
                        if(advGuarPer > 0 && dpAmt > 0) {
                            advGuarAmt = Math.round(dpAmt * (advGuarPer / 100));
                        } else {
                            advGuarAmt = 0;
                        }
                        if(EVF.V("ADV_VAT_TYPE") == "1") { // 부가세포함
                            advGuarAmt = advGuarAmt + (advGuarAmt * 0.1);
                        }
                        EVF.V("ADV_GUAR_AMT", advGuarAmt);


                    }
                    contAmtPaySum();
                }else if(colIdx == "SUPPLY_AMT" || colIdx == "VAT_AMT"){
                	var amt = Number(gridP.getCellValue(rowIdx, 'SUPPLY_AMT'))+Number(gridP.getCellValue(rowIdx, 'VAT_AMT'))
                	gridP.setCellValue(rowIdx, 'PAY_AMT', amt);
                	contAmtPaySum();
                }
            });

            // CKEDITOR Setting
            <c:if test="${editableStatus}">
                var editableBlocks = $('#cont_content').find('[contenteditable="true"]');
                for (var i = 0; i < editableBlocks.length; i++) {
                    editor = CKEDITOR.inline(editableBlocks[i], {
                        customConfig: '/js/everuxf/lib/ckeditor/ep_config.js?var=3',
                        allowedContent: true,
                        width: '100%',
                        height: 380
                    });
                }
            </c:if>

            <c:forEach items="${subFormList}" var="subForm">
                shouldConfirmSubFormNum['${subForm.REL_FORM_NUM}'] = true;
            </c:forEach>

            doSearchForm();
            attachClickEventOnConfirm();
            attachChangeEventsOnContractInputs();
            doSearchContItem();
            first_view = false;

            //품의에서 넘어온 계약건은 수정불가
			<c:if test="${(form.VENDOR_EDIT_FLAG == '1' && openType != 'modCont' )}">
                EVF.C('VENDOR_NM').setDisabled(true);			// 업체명
				EVF.C('PUR_ORG_CD').setReadOnly(true);			// 구매그룹코드
				EVF.C('CONT_REQ_CD').setReadOnly(true);			// 신규/변경구분
				EVF.C('PAY_TYPE').setReadOnly(true);			// 대금지급방식
				EVF.C('PAY_CNT').setReadOnly(true);				// 대금지급차수
				EVF.C('PAY_METHOD_NM').setReadOnly(true);		// 인도조건
				EVF.C('PAY_RMK').setReadOnly(true);				// 대금지급조건
				EVF.C('CONT_AMT').setReadOnly(true);			// 계약금액
				EVF.C('BELONG_DIVISION_NM').setDisabled(true);	// 납품장소-고객사
				EVF.C('BELONG_DEPT_NM').setDisabled(true);		// 납품장소-사업장

				EVF.C('CONT_GUAR_PERCENT').setReadOnly(true);	// 계약보증율
				EVF.C('CONT_GUAR_AMT').setReadOnly(true);		// 계약보증금액
				EVF.C('ADV_GUAR_PERCENT').setReadOnly(true);	// 선급보증율
				EVF.C('ADV_GUAR_AMT').setReadOnly(true);		// 선급보증금액
				EVF.C('WARR_GUAR_PERCENT').setReadOnly(true);	// 하자보증율
				EVF.C('WARR_GUAR_AMT').setReadOnly(true);		// 하자보증금액
				EVF.C('WARR_GUAR_QT').setReadOnly(true);		// 하자이행보증기간(월)

				// 매출인 경우에만...
				if(EVF.V("APAR_TYPE") == 'S') {
					EVF.C('CONT_INSU_BILL_FLAG').setReadOnly(true);	// 계약보증여부
					EVF.C('CONT_GUAR_TYPE').setReadOnly(true);		// 계약보증구분
					EVF.C('ADV_INSU_BILL_FLAG').setReadOnly(true);	// 선급보증여부
					EVF.C('ADV_GUAR_TYPE').setReadOnly(true);		// 선급보증구분
					EVF.C('WARR_INSU_BILL_FLAG').setReadOnly(true);	// 하자보증여부
					EVF.C('WARR_GUAR_TYPE').setReadOnly(true);		// 하자보증구분
				}

				gridP.setColReadOnly('SUPPLY_AMT'		, true);	// 공급가액
				gridP.setColReadOnly('VAT_AMT'			, true);	// 부가세액
				gridP.setColReadOnly('PAY_PERCENT'		, true);	// 지급율
				gridP.setColReadOnly('PAY_CNT_NM'		, true);	// 지급차수명
				gridP.setColReadOnly('PAY_CNT_TYPE'		, true);	// 지급차수구분
				gridP.setColReadOnly('VAT_TYPE'			, true);	// 과세구분
				gridP.setColReadOnly('PAY_METHOD_NM'	, true);	// 청구시기

				gridItem.setColReadOnly('ITEM_QT'		, true);	// 수량
				gridItem.setColReadOnly('UNIT_PRC'		, true);	// 단가
				gridItem.setColReadOnly('TAX_CD'		, true);	// 과세구분
				$("#doApply").hide();
	        </c:if>

            <c:if test="${(openType == 'modCont')}">
				EVF.V("CONT_REQ_CD","04");
            </c:if>

			<c:if test="${param.resumeFlag == 'true' || (form.CONT_CNT != '1' && not empty form.CONT_CNT)  }">
				EVF.C('VENDOR_NM').setDisabled(true);
			</c:if>

			<c:if test="${not empty form.CONT_NUM}">
				EVF.C('PR_BUYER_NM').setDisabled(true);
			</c:if>

            <c:if test="${not empty form.QTA_NUM}"> //일반계약 (구매요청접수 현황)
				EVF.C('PR_BUYER_NM').setDisabled(true);
				EVF.C('CURS').setReadOnly(true);
            </c:if>

            <%-- 매출 --%>
			if(EVF.V("APAR_TYPE") == 'S') {
				//$("#contBil").css("display","none");
				EVF.C("BELONG_DIVISION_NM").setVisible(false);
				EVF.C("CONT_INSU_BILL_FLAG").setRequired(false);
				EVF.C("ADV_INSU_BILL_FLAG").setRequired(false);
				EVF.C("WARR_INSU_BILL_FLAG").setRequired(false);
			}
			//changePayType();
        }

        function setContAmt(){
            var rowIds 	= gridItem.getAllRowId();
            var poAmt 	= 0;
            var vatAmt 	= 0;
            var sum 	= 0;
            for (var i in rowIds) {
                sum = Number(gridItem.getCellValue(rowIds[i],"ITEM_QT")) * Number(gridItem.getCellValue(rowIds[i],"UNIT_PRC"));
                gridItem.setCellValue(rowIds[i], "ITEM_AMT", sum);
                poAmt  += sum;
                vatAmt += Number(sum * 0.1);
            }
            EVF.V("SUPPLY_AMT", Math.round(poAmt));
//             EVF.V("VAT_AMT"	  , everMath.floor_float(vatAmt,0));
//             EVF.V("CONT_AMT", Number(poAmt + vatAmt));
//             if(EVF.V("VAT_TYPE") == "1"){
//                 EVF.V("CONT_AMT", Number(poAmt + vatAmt));
//             } else {
//             	EVF.V("CONT_AMT", Number(poAmt));
//             }
//             calContAmt();
        }

        function doSearchContItem() {
            var store = new EVF.Store();
            store.setGrid([gridItem]);
            store.load(baseUrl + 'doSearchContItem', function () {
            	setContAmt();

                <c:if test="${param.openFormType != 'D' && param.openFormType != null }">
					//dt 단기계약 날짜 디폴트 첫번째 날짜 넣음.
              		EVF.V("CONT_START_DATE" , EVF.isEmpty("${form.CONT_START_DATE}") ? gridItem.getCellValue(0,'VALID_FROM_DATE') : "${form.CONT_START_DATE}")
					EVF.V("CONT_END_DATE"   , EVF.isEmpty("${form.CONT_END_DATE}")   ? gridItem.getCellValue(0,'VALID_TO_DATE')   : "${form.CONT_END_DATE}")

	  	        </c:if>
            });
        }

        <%-- 계약서 서식 로드 시 입력폼에 change 이벤트 부여한다 --%>
        function attachChangeEventsOnContractInputs() {

            <%-- 계약서 서식 내 입력폼 수정 시(onchange) value 속성에 attr()로 값을 넣어줘야 html()로 가져올 때 사용자가 입력한 값을 가져올 수 있음 --%>
            $('.contract_contents_div').on('change', 'input, textarea', function() {
                var type = $(this).prop("type");
                if(type != "radio") {
                    $(this).attr("value", $(this).val());
                    if(type == "textarea") {
                    	var newVal = $(this).val();
                    	if (newVal.length > 0) {
                    		if(newVal.indexOf('\n') == 0) {
                    			newVal = " " + newVal;
                    		}
                    	}
                        $(this).html(newVal);
                    }
                } else {
                    var name = $(this).prop("name");
                    $("input[name="+name+"]").removeAttr("checked");
                    $(this).attr("checked", "checked");
                    $(this).prop("checked", true);
                }
            });
        }

        <%-- 계약서 주서식 변경 시 계약서 기본정보의 폼을 자동셋팅하는 함수 --%>
        function setForm(rowId) {

            if(rowId === undefined) {
                rowId = 0;
            }

            return;
            if(gridM.getRowCount() > 0) {
                <%-- 서식의 주소속부서가 Y(1)일 경우 주소속부서 폼의 필수여부 변경 --%>
                var deptFlag = gridM.getCellValue(rowId, 'DEPT_FLAG');
                if (deptFlag === '1') {
//                     EVF.C('BELONG_DEPT_CD').setRequired(true);
//                     EVF.C('BELONG_DEPT_NM').setRequired(true);
                } else {
                    EVF.C('BELONG_DEPT_CD').setRequired(false);
                    EVF.C('BELONG_DEPT_NM').setRequired(false);
                    EVF.V('BELONG_DEPT_CD', '');
                    EVF.V('BELONG_DEPT_NM', '');
                }

                var econtFlag = gridM.getCellValue(rowId, 'ECONT_FLAG');
                <%-- 전자서명 여부 --%>
                EVF.V('MANUAL_CONT_FLAG', (econtFlag === '1' ? "0" : "1"));
            }
        }

        /**
         * <%-- 부서식 탭 클릭 시 확인 버튼에 click 이벤트 부여 --%>
         * <%-- 확인버튼을 클릭하면 기본정보의 부서식 그리드에 부서식 HTML을 숨겨진 컬럼(FORM_CONTENTS)에 임시저장하고, 서버로 전송해서 저장한다. --%>
         */
        function attachClickEventOnConfirm() {

            $('a[name=doConfirm]').click(function() {

                var formNum = $(this).data('formnum');
                var existsEmptyForm = false;
                var $inputEls = $('#'+formNum).find("input, textarea");
                for(var i in $inputEls) {
                    var ipe = $inputEls[i];
                    if ((ipe.name != undefined && ipe.name.indexOf("changeVal") > -1) && ipe.value == '') {
                        existsEmptyForm = true;
                        break;
                    }
                }

                if(existsEmptyForm) {
                    return EVF.alert('부서식에 입력이 안된 부분이 있습니다. 입력할 내용이 없다면 공백을 입력해주세요.');
                } else {
                    EVF.alert('부서식을 확인하셨습니다.');
                }

                var selRowId = gridA.getSelRowId();
                for(var i in selRowId) {
                    var rowId = selRowId[i];
                    if(gridA.getCellValue(rowId, 'REL_FORM_NUM') == formNum) {
                        shouldConfirmSubFormNum[formNum] = false;
                        break;
                    }
                }

                EVF.C('T1').setActive(1);
            });
        }

        /**
         *  <%-- 계약서 진행상태에 따라 버튼의 노출 처리 --%>
         *  <%-- 버튼은 기본적으로 hidden 처리되어 있으며, 계약서 진행상태에 따라 노출시킨다. --%>
         */
        function setButtons() {

            var selFormInfo = gridM.getRowValue(gridM.getSelRowId()[0]);
            var progressCd = EVF.V('PROGRESS_CD');

            var examFlag     = selFormInfo['EXAM_FLAG'] === '1';              <%-- 검토유무 --%>
            var approvalFlag = selFormInfo['APPROVAL_FLAG'] === '1';      <%-- 기안유무 --%>
            var bundleFlag 	 = selFormInfo['BUNDLE_FLAG'] === '1';          <%-- 일괄계약유무 --%>
            var deptFlag 	 = selFormInfo['DEPT_FLAG'] === '1';              <%-- 주소속부서지정유무 --%>
            var econtFlag 	 = selFormInfo['ECONT_FLAG'] === '1';            <%-- 전자서명유무 --%>
            var signStatus 	 = '${form.SIGN_STATUS}';                       <%-- 법무팀 결재상태 --%>
            var signStatus2  = '${form.SIGN_STATUS2}';                     <%-- 체결기안 결재상태 --%>

            if(${not param.detailView eq 'true'}) {

                EVF.C('doSave').setVisible(false);
                EVF.C('doDelete').setVisible(false);
                EVF.C('doReqLegalTeam').setVisible(false);
/*
			                진행상태 [P005]
                 4110 : 임시저장
                 4200 : 협력업체 서명대기
                 4210 : 협력업체 서명반려
                 4220 : 협력업체 서명완료
                 4300 : 계약체결완료
  */

                if (progressCd == '' || progressCd == '4110' || progressCd == '4210' || progressCd == '4220' || (signStatus == 'R' || signStatus == 'C' || signStatus == 'T')

                	) {
					if (progressCd == '4210' || (   (progressCd == '' || progressCd == '4110') && (signStatus == '' ||signStatus == 'R' || signStatus == 'C' || signStatus == 'T') )  ) {
	                	EVF.C('doSave').setVisible(true);
                        EVF.C('doReqLegalTeam').setVisible(true);
	                    <c:if test="${not empty form.CONT_NUM}">
	                        EVF.C('doDelete').setVisible(true);
	                    </c:if>
					}
                    if(signStatus == '' || signStatus == 'R' || signStatus == 'C' || signStatus == 'T') {
                         EVF.C('doReqLegalTeam').setVisible(true);
                    }
                }
            }
            if(EVF.isEmpty(EVF.V("CONT_NUM"))) {
            	//changePayType();
                if(!pResetFlag) {
//                    EVF.confirm("${CT0320_0025 }", function () {
//                        changePayType();
//                        pResetFlag = true;
//                    });
                } else {
//                    EVF.V("PAY_TYPE", "LS");
                }
            }

            if(${!authFlag}) {
                EVF.C('doSave').setVisible(false);
                EVF.C('doDelete').setVisible(false);
                EVF.C('doReqLegalTeam').setVisible(false);
                //EVF.C('doSign').setVisible(false);
                <%-- EVF.C('doFinishContract').setVisible(false); --%>
            }
        }

        /** <%--
           계약서 주서식을 로드하는 함수
           계약서 서식 번호(selectedFormNum)와 화면에 보여진 주계약서 HTML(formContents) 값을 서버에 넘긴다.
           서식이 변경되었거나(isUpdateFormNum) 주계약서 HTML에 값이 없을 경우 계약서 서식번호를 통해
           DB에서 서식을 조회하고, 기본정보에 선택된 값에 따라 입력폼들이 치환되어 화면에 보여준다.

           서식이 변경되지 않고, 주계약서 HTML의 값이 있을 경우 사용자에 의해 수정된 계약서이므로, 그 값을 그대로
           서버로 보내서 기본정보에 선택된 값만 입력폼을 치환하여 새로고침하여 화면에 보여준다.

           이렇게 서버에서 조회된 주계약서 HTML에 contenteditable=true 속성을 가진 HTML 태그를 찾아
           CKEDITOR 인라인 에디터를 로드시켜서 사용자가 자유롭게 그 영역은 수정가능하도록 했다.

           changeVal_99라는 이름(name)을 가진 input 태그는 숫자만 입력가능하도록 플러그인을 로드시켰다.
           --%>
         */
        function loadMainForm() {

            first_view = true;
            <c:if test="${editableStatus}">
            if(gridM.isExistsSelRow()) {
                var store = new EVF.Store();
                store.setGrid([gridA, gridP,gridItem]);
                store.getGridData(gridA, 'all');
                store.getGridData(gridP, 'all');
                store.getGridData(gridItem, 'all');
                store.setParameter('contNum', '${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}');
                store.setParameter('contCnt', '${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}');
                store.setParameter('selectedFormNum', gridM.getSelRowValue()[0].FORM_NUM);
                store.setParameter('isUpdatedFormNum', formNumUpdateState);
                store.setParameter('formContents', $('#cont_content').html());
                store.setParameter('first_view', first_view);
                store.load('/evermp/buyer/cont/CT0110P01/getContractForm', function () {

                    $('#cont_content').html(this.getParameter("contractForm"));
                    EVF.V("oriFormContents", this.getParameter("contractForm"));
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
                        "mDec" 	 : "99",
                        "aPad" 	 : false,
                        "wEmpty" : "empty",
                        "aForm"	 : false
                    });

                    first_view = false;
                });
            }
            </c:if>
        }

        <%-- 주계약서 서식을 조회하여 그리드에 조회한다 --%>
        function doSearchForm() {
            var store = new EVF.Store();
            store.setGrid([ gridM ]);
            store.setParameter("resumeFlag", resumeFlag);
            store.load('/evermp/buyer/cont/CT0110P01/doSearchMainForm', function() {

                var rowIds = gridM.getAllRowId();
                if( rowIds.length > 0 ) {
                    for(var i = 0; i < rowIds.length; i++) {
                        if(gridM.getCellValue(rowIds[i], 'FORM_CHECKED') == '1') {
                        	gridM.checkRow(rowIds[i], true, true, false);
                        	formNumUpdateState = true;
                            first_view 		   = true;
                            if(gridM.getCellValue(rowIds[i],"CONTRACT_FORM_TYPE") == 'ISU'){
            				    EVF.V("CONT_AMT", '0');
            				}else{
            					contAmtPaySum();
            				}
                        	setForm(rowIds[i]);
                        	break;
                        }
                    }
                } else {
                    setForm(0);
                }

                doSearchSubForms();
                setButtons();
                $("#CONT_GUAR_TYPE").change();
    			$("#ADV_GUAR_TYPE").change();
    			$("#WARR_GUAR_TYPE").change();

                if(openType == "createCont" || openType == "regModCont" || openType == "modCont") {
                    EVF.confirm("${CT0320_0025 }", function () {
                        EVF.V("PAY_TYPE", "LS");
						//EVF.V("PAY_METHOD", "AA01");
                        EVF.V("PAY_CNT", "1");
                        EVF.V("PAY_RMK", "");
                    }, function() {
                        doPayInfo();
                    });
                } else {
                    doPayInfo();
                }
            }, false);
        }

        <%-- 주서식이 바뀌면 부서식 탭을 리셋시킨다 --%>
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
            shouldConfirmSubFormNum = {};
        }

        <%-- 부서식을 조회하여 그리드에 보여준다 --%>
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
                            }
                        }
                    }
                }, false);
            }
        }

        <%-- 대금지급정보의 내용을 그리드에 보여준다. --%>
        function doPayInfo() {

             var store = new EVF.Store();
             store.setParameter('contNum', '${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}');
             store.setParameter('contCnt', '${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}');
             store.setParameter('vendorCd', '${form.VENDOR_CD}');
             store.setGrid([ gridP ]);

             store.load(baseUrl + 'doSearchEcpy', function () {
				changeGuarAmt();
				contAmtPaySum();
				if(gridP.getRowCount()==0) {
					changePayType();
				}
             	 gridP._gvo.setPasteOptions({enableAppend:false});
                 gridP.checkAll(true);
             }, false);

        }
        <%-- 저장을 하기 전에 입력되지 않은 폼이 있는지 확인해주는 체크함수 --%>
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

            var subFormGridRowId = gridA.getAllRowId();
            for(var i in subFormGridRowId) {
                var rowId = subFormGridRowId[i];
                if(gridA.getCellValue(rowId, 'REQUIRE_FLAG') === '1' && !gridA.isChecked(rowId)) {
                    EVF.alert('['+gridA.getCellValue(rowId, 'REL_FORM_NM')+'] 부서식은 반드시 선택하셔야 합니다.');
                    return false;
                }
            }

            if (!gridP.validate().flag) { return EVF.alert("대금지급정보의 " + gridP.validate().msg); }
            var payGridRowId = gridP.getAllRowId();
            var sumPayAmt = 0;
            var sumPayPercent = 0;
            for(var i in payGridRowId) {
                sumPayAmt = sumPayAmt + Number(gridP.getCellValue(payGridRowId[i], 'SUPPLY_AMT'));
                sumPayPercent = +(Number(sumPayPercent) + Number(gridP.getCellValue(payGridRowId[i], 'PAY_PERCENT'))).toFixed(2);
            }
			if(Number(EVF.V("SUPPLY_AMT")) != sumPayAmt) {
				alert('FORM(cont_amt)='+EVF.V("CONT_AMT")+'    FORM(SUPPLY_AMT)='+EVF.V("SUPPLY_AMT")+'    GRID(sumPayAmt)='+sumPayAmt);
				EVF.alert("${CT0320_0017}");
				return false;
			}

            if(sumPayPercent != 100) {
                EVF.alert("${CT0320_0023}");
                return false;
            }
            <c:if test="${editableStatus}">
            for(var id in shouldConfirmSubFormNum) {
                <%--if(shouldConfirmSubFormNum[id] === true) {
                    저장, 법무팀 검토, 전송 등 체크로직 수행시 부서식 확인 Skip 2020.12.18
                    EVF.alert('확인되지 않은 부서식이 있습니다.\n부서식을 모두 확인해주시고 확인버튼을 눌러주세요.');
                    return false;
                }--%>
            }
            </c:if>

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

        function limitLines(obj, e) {
            let numberOfLines = (obj.value.match(/\n/g) || []).length + 1;
            let maxRows = obj.rows;
            if(e.which === 13 && numberOfLines === maxRows) {
                return false;
            }
        }

		/* 잔금,중도금,선금 계산 및 지체상금율 계산 날짜*/
		function changeGuarAmt(){

			var rowValues 	     = gridP.getAllRowValue();
			var totalAmt 		 = 0;
        	var totalExecAmt 	 = 0;
        	var totalVatAmt 	 = 0;
        	var totalPer 		 = 0;
			var totalContGuarAmt = 0; //선금
        	var totalAdvGuarAmt  = 0; //중도금
        	var totalWarrGuarAmt = 0; //잔금
        	var delyRate 		 = Number(EVF.V("DELAY_RATE"));
        	var contEndDate 	 = EVF.V("CONT_END_DATE");
        	var date			 = new Date(contEndDate.substr(0,4),Number(contEndDate.substr(4,2))-1,contEndDate.substr(6,2))
        	//console.log(contEndDate.substr(0,4)+"년"+contEndDate.substr(4,2)+"월"+contEndDate.substr(6,2))
        	for(var k =0; k < rowValues.length;k++){
        		totalAmt+=rowValues[k].SUPPLY_AMT
        		totalVatAmt+=rowValues[k].VAT_AMT
        		totalPer+=rowValues[k].PAY_PERCENT
        		totalExecAmt+=rowValues[k].PAY_AMT
        	 	if(rowValues[k].PAY_CNT_TYPE =='DP'){
        			totalContGuarAmt+=rowValues[k].PAY_AMT;
        		}else if(rowValues[k].PAY_CNT_TYPE =='PP'){
        			totalAdvGuarAmt+=rowValues[k].PAY_AMT;
        		}else if(rowValues[k].PAY_CNT_TYPE =='BP'){
        			totalWarrGuarAmt+=rowValues[k].PAY_AMT;
        		}
        	}
            var cc =0;
        	//다음날부터적용 +1일
        	date.setDate(date.getDate()+1);
        	EVF.V("WARR_FROM_DATE"	,getToday(date));
        	if(!EVF.isEmpty(EVF.V('WARR_GUAR_QT')) && EVF.V('WARR_GUAR_QT') !=0){
        		var yy =date.getFullYear()
        		var mm =date.getMonth()
        		for(var i=0; i<Number(EVF.V('WARR_GUAR_QT')); i++){
        		mm +=1;
        		var last = new Date(yy, mm, 0);
        			cc += last.getDate();
        		}
			}

        	date.setDate(date.getDate()+(cc-1));
        	EVF.V("WARR_END_DATE"	,getToday(date));
        	EVF.V("DELAY_NUME_RATE"	,delyRate*10);
        	EVF.V("CONT_PAY_AMT"	,Math.floor(totalContGuarAmt))
        	EVF.V("ADV_PAY_AMT"		,Math.floor(totalAdvGuarAmt))
        	EVF.V("WARR_PAY_AMT"	,Math.floor(totalWarrGuarAmt))
        	EVF.V("CONT_GUAR_AMT"	,Math.floor(totalExecAmt*(Number(EVF.V("CONT_GUAR_PERCENT"))/100)))
        	EVF.V("ADV_GUAR_AMT"	,Math.floor(totalExecAmt*(Number(EVF.V("ADV_GUAR_PERCENT"))/100)))
        	EVF.V("WARR_GUAR_AMT"	,Math.floor(totalExecAmt*(Number(EVF.V("WARR_GUAR_PERCENT"))/100)))
        	if(EVF.V("APAR_TYPE")=='S'){
				EVF.V("BUYER_PLANT_INFO",EVF.V("BELONG_DEPT_NM"))
			}else{
				EVF.V("BUYER_PLANT_INFO",EVF.V("BELONG_DIVISION_NM")+"/"+EVF.V("BELONG_DEPT_NM"))
			}
		}

		//날짜계산
		function getToday(date,val){
			var reDate="";
		    var year  = date.getFullYear();
		    var month = ('0' + (date.getMonth()+1)).slice(-2);
		    var day = ('0' + date.getDate()).slice(-2);
			if(!EVF.isEmpty(EVF.V('WARR_GUAR_QT')) && EVF.V('WARR_GUAR_QT') !=0){
				reDate=year +"년"+month +"월"+ day+"일";
			}


		    return reDate;
		}

        <%-- 계약서를 임시저장 상태로 저장한다 --%>
        function doSave() {
            if(gridItem.getRowCount()==0) { return EVF.alert("계약할 품목이 없습니다."); }
            if(!gridItem.validate().flag) { return EVF.alert(gridItem.validate().msg); }
            if(!checkFormValidation()) { return; }

            var store = new EVF.Store();
            var oriFormContents = EVF.V("oriFormContents");
            <c:if test="${editableStatus}">
            var progressCd = EVF.V("PROGRESS_CD");
            for (var id in shouldConfirmSubFormNum) {
                // 부서식 확인 로직을 제거하는 대신, 각 부서식탭의 내용을 그리드에 담는다.
                var selRowId = gridA.getSelRowId();
                for (var i in selRowId) {
                    var rowId = selRowId[i];
                    if (gridA.getCellValue(rowId, 'REL_FORM_NUM') == id) {
                        //console.log($('#' + id).html());
                        gridA.setCellValue(rowId, 'FORM_CONTENTS',     (EVF.isEmpty($('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')) ? gridA.getCellValue(rowId, 'FORM_CONTENTS') : $('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')));
                        gridA.setCellValue(rowId, 'ORI_CONTRACT_TEXT', (EVF.isEmpty($('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')) ? gridA.getCellValue(rowId, 'ORI_CONTRACT_TEXT') : $('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')));
                    }
                }
            }
            oriFormContents = $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;');
            </c:if>

            EVF.confirm("${msg.M0021 }", function () {
                store = new EVF.Store();
                store.setParameter('mainContractContents', $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                store.setParameter('oriMainContractContents', oriFormContents);
                store.setParameter('openType', openType);
                store.setParameter('purcContNum', '${selPurcContNum}');
                store.setGrid([gridM, gridA, gridP, gridItem]);
                store.getGridData(gridM    , 'sel');
                store.getGridData(gridA    , 'sel');
                store.getGridData(gridP    , 'all');
                store.getGridData(gridItem , 'all');

                store.doFileUpload(function() {
                    store.load(baseUrl + 'doSave', function() {
                        var contNum = this.getParameter('contNum');
                        var contCnt = this.getParameter('contCnt');
                        EVF.alert('${msg.M0031}', function() {
                            location.href = baseUrl + "view.so?contNum=" + contNum + '&contCnt=' + contCnt+'&popupFlag=true';
                            if (opener) {
                                opener['doSearch']();
                            }
                        });
                    });
                });
            });
        }

        <%-- 내부 결재요청 --%>
        function doReqLegalTeam() {
            if(gridItem.getRowCount()==0) { return EVF.alert('${CT0320_0030}'); }
            if(!gridItem.validate().flag) { return EVF.alert(gridItem.validate().msg); }
            if(!checkFormValidation()) { return; }
			var param = {
                 subject			: EVF.C('CONT_DESC').getValue(),
                 docType			: "EC",
                 signStatus			: "P",
                 screenId			: "CT0320",
                 approvalType		: 'APPROVAL',
                 oldApprovalFlag	: EVF.C('SIGN_STATUS').getValue(),
                 attFileNum			: "",
                 docNum				: EVF.C('CONT_NUM').getValue(),
                 appDocNum			: EVF.C('APP_DOC_NUM').getValue(),
                 callBackFunction	: "goApprovalExam"
			};
			everPopup.openApprovalRequestIIPopup(param);
        }

        function goApprovalExam(formData, gridData, attachData) {

            EVF.V('approvalFormData', formData);
            EVF.V('approvalGridData', gridData);
            EVF.V('attachFileDatas', attachData);
            EVF.V('SIGN_STATUS', 'P');

            var oriFormContents = EVF.V("oriFormContents");
            <c:if test="${editableStatus}">
            oriFormContents = $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;');
            </c:if>

            var store = new EVF.Store();
            store.setParameter('mainContractContents', $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
            store.setParameter('oriMainContractContents', oriFormContents);
            store.setGrid([gridM, gridA, gridP, gridItem]);
            store.getGridData(gridM, 'sel');
            store.getGridData(gridA, 'sel');
            store.getGridData(gridP, 'all');
            store.getGridData(gridItem, 'all');

            store.doFileUpload(function() {

            	store.load(baseUrl + 'doReqLegalTeam', function() {
                    var contNum  = this.getParameter('contNum');
                    var contCnt  = this.getParameter('contCnt');
                    var aparType = this.getParameter('aparType');
                    alert(this.getResponseMessage());
                    location.href = baseUrl + "view.so?contNum=" + contNum + '&contCnt=' + contCnt + '&APAR_TYPE=' + aparType;
                    opener['doSearch']();
//                     EVF.alert(this.getResponseMessage(), function() {
//                         location.href = baseUrl + "view.so?contNum=" + contNum + '&contCnt=' + contCnt;
//                         if (opener) {
//                             opener['doSearch']();
//                         }
//                     });
                });
            });
        }

        <%-- 계약서를 협력사에 전송한다 --%>
        function doSend() {

            if (!checkFormValidation()) { return; }

            for (var id in shouldConfirmSubFormNum) {
                // 부서식 확인 로직을 제거하는 대신, 각 부서식탭의 내용을 그리드에 담는다.
                var selRowId = gridA.getSelRowId();
                for (var i in selRowId) {
                    var rowId = selRowId[i];
                    if (gridA.getCellValue(rowId, 'REL_FORM_NUM') == id) {
                        gridA.setCellValue(rowId, 'FORM_CONTENTS',     (EVF.isEmpty($('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')) ? gridA.getCellValue(rowId, 'FORM_CONTENTS') : $('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')));
                        gridA.setCellValue(rowId, 'ORI_CONTRACT_TEXT', (EVF.isEmpty($('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')) ? gridA.getCellValue(rowId, 'ORI_CONTRACT_TEXT') : $('#' + id).html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;')));
                    }
                }
            }

            EVF.confirm("${CT0320_0007 }", function () {

                <c:if test="${editableStatus}">
                if(gridM.isExistsSelRow()) {
                    var store = new EVF.Store();
                    store.setGrid([gridA, gridP]);
                    store.getGridData(gridA, 'all');
                    store.getGridData(gridP, 'all');
                    store.setParameter('contNum', '${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}');
                    store.setParameter('contCnt', '${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}');
                    store.setParameter('selectedFormNum', gridM.getSelRowValue()[0].FORM_NUM);
                    store.setParameter('isUpdatedFormNum', formNumUpdateState);
                    store.setParameter('formContents', $('#cont_content').html());
                    store.setParameter('first_view', false);
                    store.load('/evermp/buyer/cont/CT0110P01/getContractForm', function () {

                        $('#cont_content').html(this.getParameter("contractForm"));
                        EVF.V("oriFormContents", this.getParameter("contractForm"));

                        store = new EVF.Store();
                        store.setParameter('mainContractContents', $('#cont_content').html().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
                        store.setParameter('oriMainContractContents', EVF.V("oriFormContents"));
                        store.setParameter('APAR_TYPE', EVF.V("APAR_TYPE"));
                        store.setParameter('CTRL_USER_ID', EVF.V("CTRL_USER_ID"));
                        store.setGrid([gridM, gridA, gridP]);
                        store.getGridData(gridM, 'sel');
                        store.getGridData(gridA, 'sel');
                        store.getGridData(gridP, 'all');
                        store.doFileUpload(function() {
                            store.load(baseUrl + 'doSendContract', function () {
                                var contNum = this.getParameter('contNum');
                                var contCnt = this.getParameter('contCnt');
                                EVF.alert(this.getResponseMessage(), function() {
                                    location.href = baseUrl + "view.so?contNum=" + contNum + '&contCnt=' + contCnt;
                                    if (opener) {
                                        opener['doSearch']();
                                    }
                                });
                            });
                        });
                    });
                }
                </c:if>
            });
        }

        <%-- 계약서를 삭제처리한다 --%>
        function doDelete() {

            EVF.confirm("${CT0320_0022 }", function () {
                var store = new EVF.Store();
                store.load(baseUrl + "doDeleteContract", function () {
                    EVF.alert(this.getResponseMessage(), function() {
                        if (opener !=null) {
                            opener.doSearch();
                            doClose();
                        } else {
                            location.href = baseUrl + 'view';
                        }
                    });
                });
            });
        }

        <%-- 계약서에 서명한다 --%>
        function doSign() {

            EVF.confirm("${CT0320_0016 }", function () {
                var store = new EVF.Store();

                store.setGrid([gridItem]);
                store.getGridData(gridItem, 'all');
                store.setParameter("GUBN","CT0320");
                store.doFileUpload(function() {
                    store.load(baseUrl + 'doSign', function () {
                        EVF.alert(this.getResponseMessage(), function() {
                            location.href = baseUrl + "view.so?contNum=" + EVF.V('CONT_NUM') + '&contCnt=' + EVF.V('CONT_CNT')+'&popupFlag=true';
                            if (opener) {
                                opener['doSearch']();
                            }
                        });
                    }, true);
                });
            });
        }

        function doClose() {
            if ('${param.appDocNum}' === '') {
                window.close();
            } else {
                doClose2();
            }
        }

        function getDrafter() {
        	var param = {
    				custCd           : "${ses.companyCd}",
    				callBackFunction : "callBack_selectCtrlUser",
    			};
    			everPopup.openCommonPopup(param, "SP0040");
        }

        function setDrafter(drafter) {
            EVF.C("CONT_USER_ID").setValue(drafter.USER_ID);
            EVF.C("CONT_USER_NM").setValue(drafter.USER_NM);
        }

        function getVendorCd() {

        	<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PR_BUYER_CD') === '') {
				return EVF.alert('${CT0320_0029}');
			}

        	if(EVF.V("APAR_TYPE")=='P') {
                everPopup.openCommonPopup({
                    callBackFunction: "setVendorCd"
                }, 'SP0907');
        	}
        }

        function setVendorCd(vendor) {

            EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
            EVF.C("VENDOR_PIC_USER_NM").setValue(vendor.SALES_USER_NM);
            EVF.C("VENDOR_PIC_USER_EMAIL").setValue(vendor.EMAIL);
            EVF.C("VENDOR_PIC_CELL_NUM").setValue(vendor.TEL_NO);
        }

        function calContGuarAmt() {

            if(EVF.V("CONT_GUAR_TYPE") == "EX") {
                EVF.alert("${CT0320_0026}");
                EVF.V("CONT_GUAR_PERCENT", 0);
                EVF.V("CONT_GUAR_AMT", 0);
                return;
            }

<%--             대상금액 설정...                                --%>
<%--                  부가세포함, 면제인 경우 => 대상금액 = 계약금       --%>
<%--                  부가세별도인 경우 => 대상금액 = 계약금액 + 부가세금액 --%>
            var targetAmt = 0;
            var vatType = EVF.V("VAT_TYPE");

            // 부가세 포함, 부가세 면제
            if(vatType == "1" || vatType == "0") {
                targetAmt = Number(EVF.V("CONT_AMT"));
            }
            // 부가세 별도
            else if(vatType == "2") {
                targetAmt = Number(EVF.V("CONT_AMT")) + Number(EVF.V("VAT_AMT"));
            }

            if(EVF.isEmpty(targetAmt) || targetAmt == 0) {
                return EVF.alert("${CT0320_0011}");
            }

<%--             보증금액 계산  --%>
<%--                  보증금에 대해 부가세포함, 면제인 경우 => 보증금액 = 대상금액 * 보증율 --%>
<%--                  보증금에 대해 부가세별도인 경우 => 보증금액 = (대상금액 * 보증율) / 1.1 --%>
            var contGuarAmt = 0;
            var contVatType = EVF.V("CONT_VAT_TYPE");
            var contGuarPer = Number(EVF.V("CONT_GUAR_PERCENT"));

            // 부가세 포함, 부가세 면제
            if(contVatType == "1" || contVatType == "0") {
                if(contGuarPer > 0) {
                    contGuarAmt = Math.round(targetAmt * (contGuarPer / 100));
                } else {
                    contGuarAmt = 0;
                }
            }
            // 부가세 별도
            else if(contVatType == "2") {
                if(contGuarPer > 0) {

                    //contGuarAmt = Math.floor(Math.round(targetAmt * (contGuarPer / 100)) / 1.1);
                    var sup_amt = +(targetAmt / 1.1).toFixed(5);
                    var vat_amt = targetAmt - Math.floor(sup_amt);
                    contGuarAmt = targetAmt - vat_amt;

                } else {
                    contGuarAmt = 0;
                }
            }
            EVF.V("CONT_GUAR_AMT", Math.round(contGuarAmt));
        }

        function cleanGuarVal(val) {
        	var labelVal = val.data;
            if(EVF.V(labelVal+"_GUAR_TYPE") == "EX") {
                EVF.V(labelVal+"_GUAR_PERCENT", 0);
                EVF.V(labelVal+"_GUAR_AMT", 0);
            }

        }

        function calAdvGuarAmt() {
		<c:if test="${(form.VENDOR_EDIT_FLAG != '1' && openType != 'modCont' )}"> //품의에서 넘어온건은 적용불가.
            var dpAmt = 0;
            var rowIds = gridP.getAllRowId();
            for(var i in rowIds) {
                if(gridP.getCellValue(rowIds[i], 'PAY_CNT_TYPE') == "DP") {
                    dpAmt += Number(gridP.getCellValue(rowIds[i], 'PAY_AMT'));
                }
            }

            if(EVF.V("ADV_GUAR_TYPE") == "EX") {
                EVF.alert("${CT0320_0026}");
                EVF.V("ADV_GUAR_PERCENT", 0);
                EVF.V("ADV_GUAR_AMT", 0);
                return;
            }

            if(dpAmt == 0) {
                EVF.alert("${CT0320_0024}");
                EVF.V("ADV_GUAR_PERCENT", '');
                return;
            }

            var advGuarPer = Number(EVF.V("ADV_GUAR_PERCENT"));
            var advGuarAmt = 0;
            if(advGuarPer > 0 && dpAmt > 0) {
                advGuarAmt = Math.round(dpAmt * (advGuarPer / 100));
            } else {
                advGuarAmt = 0;
            }
            if(EVF.V("ADV_VAT_TYPE") == "1") { // 부가세포함
                advGuarAmt = advGuarAmt + (advGuarAmt * 0.1);
            }
            EVF.V("ADV_GUAR_AMT", Math.round(advGuarAmt));
		</c:if>
        }

        function calWarrGuarAmt() {

            if(EVF.V("WARR_GUAR_TYPE") == "EX") {
                EVF.alert("${CT0320_0026}");
                EVF.V("WARR_GUAR_PERCENT", 0);
                EVF.V("WARR_GUAR_AMT", 0);
                return;
            }

            <%-- 대상금액 설정...
                 부가세포함, 면제인 경우 => 대상금액 = 계약금액
                 부가세별도인 경우 => 대상금액 = 계약금액 + 부가세금액 --%>
            var targetAmt = 0;
            var vatType = EVF.V("VAT_TYPE");

            // 부가세 포함, 부가세 면제
            if(vatType == "1" || vatType == "0") {
                targetAmt = Number(EVF.V("CONT_AMT"));
            }
            // 부가세 별도
            else if(vatType == "2") {
                targetAmt = Number(EVF.V("CONT_AMT")) + Number(EVF.V("VAT_AMT"));
            }

            if(EVF.isEmpty(targetAmt) || targetAmt == 0) {
                return EVF.alert("${CT0320_0011}");
            }

            <%-- 보증금액 계산
                 보증금에 대해 부가세포함, 면제인 경우 => 보증금액 = 대상금액 * 보증율
                 보증금에 대해 부가세별도인 경우 => 보증금액 = (대상금액 * 보증율) / 1.1 --%>
            var warrGuarAmt = 0;
            var warrVatType = EVF.V("WARR_VAT_TYPE");
            var warrGuarPer = Number(EVF.V("WARR_GUAR_PERCENT"));

            // 부가세 포함, 부가세 면제
            if(warrVatType == "1" || warrVatType == "0") {
                if(warrGuarPer > 0) {
                    warrGuarAmt = Math.round(targetAmt * (warrGuarPer / 100));
                } else {
                    warrGuarAmt = 0;
                }
            }
            // 부가세 별도
            else if(warrVatType == "2") {
                if(warrGuarPer > 0) {
                    warrGuarAmt = Math.floor(Math.round(targetAmt * (warrGuarPer / 100)) / 1.1);
                } else {
                    warrGuarAmt = 0;
                }
            }
            EVF.V("WARR_GUAR_AMT", Math.round(warrGuarAmt));
        }

        function changePayType() {

        	if (erpData) {
        		erpData = false;
        		return;
        	}

            gridP.delAllRow();
            if(EVF.V("PAY_TYPE") == "LS") {
            	EVF.V('PAY_CNT', 1);
                gridP.addRow([{"PAY_CNT": 1, "PAY_CNT_TYPE": "BP", "PAY_CNT_NM": "잔금", "VAT_TYPE": "1", "PAY_PERCENT" : 100}]);
                initPay(0);
            } else {
                if(EVF.isEmpty("${form.PAY_CNT}")) { EVF.V('PAY_CNT', ''); }
            }
        }

		function initPay(rowIdx) {

            if(EVF.isEmpty(EVF.V("CONT_AMT")) || EVF.V("CONT_AMT") == '0') {
                gridP.setCellValue(rowIdx, 'PAY_PERCENT', '');
                return;
            }

            var contAmt = Number(EVF.V("SUPPLY_AMT"));
            var payPer = Number(gridP.getCellValue(rowIdx, 'PAY_PERCENT'));
            var payAmt = 0;
            if(payPer > 0 && contAmt > 0) {
                payAmt = Math.round(contAmt * (payPer / 100));
            } else {
                payAmt = 0;
            }

            gridP.setCellValue(rowIdx, 'SUPPLY_AMT', payAmt);

            if(gridP.getCellValue(rowIdx, 'VAT_TYPE') == "0") {
                gridP.setCellValue(rowIdx, 'VAT_AMT', (payAmt * 0.1));
            } else if(gridP.getCellValue(rowIdx, 'VAT_TYPE') == "1") { // 부가세포함
                gridP.setCellValue(rowIdx, 'VAT_AMT', (payAmt * 0.1));
                payAmt = payAmt + (payAmt * 0.1);
            } else {
                gridP.setCellValue(rowIdx, 'VAT_AMT', 0);
            }
            gridP.setCellValue(rowIdx, 'PAY_AMT', payAmt);


            if(gridP.getCellValue(rowIdx, 'PAY_CNT_TYPE') == "DP" && !EVF.isEmpty(EVF.V("ADV_GUAR_PERCENT"))) {

                var dpAmt = 0;
                var rowIds = gridP.getAllRowId();
                for(var i in rowIds) {
                    if(gridP.getCellValue(rowIds[i], 'PAY_CNT_TYPE') == "DP") {
                        dpAmt = dpAmt + Number(gridP.getCellValue(rowIds[i], 'PAY_AMT'));
                    }
                }
                var advGuarPer = Number(EVF.V("ADV_GUAR_PERCENT"));
                var advGuarAmt = 0;
                if(advGuarPer > 0 && dpAmt > 0) {
                    advGuarAmt = Math.round(dpAmt * (advGuarPer / 100));
                } else {
                    advGuarAmt = 0;
                }
                if(EVF.V("ADV_VAT_TYPE") == "1") { // 부가세포함
                    advGuarAmt = advGuarAmt + (advGuarAmt * 0.1);
                }
                EVF.V("ADV_GUAR_AMT", advGuarAmt);
            }
		}
		//2023 -01-12 대금지급조건금액으로 계약금액변경
		function contAmtPaySum(){
			 var payAmt  = 0;
			 var vatAmtR = 0;
			 for(var i=0; i<gridP.getRowCount(); i++){
               	payAmt = payAmt + Number(gridP.getCellValue(i, 'PAY_AMT'));
               	vatAmtR = vatAmtR + Number(gridP.getCellValue(i, 'VAT_AMT'));
             }

			  if("${contractFormType}" == 'ISU'){
				 EVF.V("CONT_AMT"  , '0');
			 }else{
				 EVF.V("CONT_AMT"  , Math.floor(payAmt))
		         EVF.V("VAT_AMT"   , Math.floor(vatAmtR))
			 }
		}
        function doApply() {

            // 일시불이고, 적용차수가 1보다 큰경우 알림창
            if (EVF.V('PAY_TYPE') == "LS" || Number(EVF.V('PAY_CNT')) < 1) {
                return EVF.alert("${CT0320_0010}");
            }
            if(EVF.V("PAY_TYPE") == "IS" && Number(EVF.V('PAY_CNT')) == 1) {
                EVF.alert("${CT0320_0015}");
                EVF.V('PAY_CNT', '');
                return;
            }

            gridP.delAllRow();
            var payCnt = Number(EVF.V('PAY_CNT'));
            for(var i = 0; i < payCnt; i++) {
                var payCntType = "PP";
                var payCntNm = "중도금";
                if(i == 0) {
                    payCntType = "DP";
                    payCntNm = "선급금";
                }
                if((i+1) == payCnt) {
                    payCntType = "BP";
                    payCntNm = "잔금";
                }
                gridP.addRow([{"PAY_CNT": (i + 1), "PAY_CNT_TYPE": payCntType, "PAY_CNT_NM": payCntNm, "VAT_TYPE": "1"}]);
            }
            gridP._gvo.setPasteOptions({enableAppend:false});
        }

        /**
         * 기본정보: 1
         * 주서식: 2
         * 그 외
         * @param newTabId 새탭ID
         * @param oldTabId 이전탭ID
         * @param event
         */
        function onActiveTab(newTabId, oldTabId, event) {
            if(newTabId === '1') {

            } else if(newTabId === '2') {
            	 changeGuarAmt(); //잔금,보증금,선금 계산 및 지체상금율 계산

                <%-- 계약서가 수정가능한 상태일 때 기본정보 등이 바뀌었을 수 있으므로, 주계약서 내용을 다시 로드한다. --%>
                <c:if test="${editableStatus}">
                	loadMainForm();

                </c:if>
            } else {    <%-- 부서식탭 활성화 --%>

            <c:if test="${editableStatus}">

            	//if ("${form.PROGRESS_CD}" == "4220") return;

                //if($('#'+newTabId).html().trim() == '') {
                    var store = new EVF.Store();
                    store.setGrid([ gridP,gridItem]);
                    store.getGridData(gridP, 'all');
                    store.getGridData(gridItem, 'all');
                    store.setParameter('contNum', '${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}');
                    store.setParameter('contCnt', '${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}');
                    store.setParameter('selectedFormNum', newTabId);
                    store.setParameter('isUpdatedFormNum', shouldConfirmSubFormNum[newTabId]);
                    store.setParameter('formContents', $('#'+newTabId).html());
                    store.setParameter('first_view', first_view);
                    store.load('/evermp/buyer/cont/CT0110P01/getSubContractForm', function() {

                       $('#'+newTabId).html(this.getParameter("contractForm"));

                       // 서식이 바뀔 때마다 이벤트를 다시 지정해줘야한다.
                        attachChangeEventsOnContractInputs();

                        // 사용자 자유수정가능 영역에 에디터를 로드하는 것도 다시 해야한다.
                        var editableBlocks = $('#'+newTabId).find('[contenteditable="true"]');
                        for (var i = 0; i < editableBlocks.length; i++) {
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
                //}
            </c:if>
            }
        }

        function getDept() {

            if(gridM.getSelRowValue()[0].DEPT_FLAG === '1') {
                <%--
                var param = {
                    multiYN: "false",
                    callbackFunction: "setDept",
                    detailView: false
                };
                everPopup.openPopupByScreenId('BSYO_080', 400, 600, param);
                --%>
                var popupUrl = "/eversrm/manager/org/MOGA0032/view";
                var param = {
                  callBackFunction : "setDept",
                  rowId			 : '',
                  tiTle			 : '',
                  'AllSelectYN'	 : true,
                  'detailView'	 : false,
                  'multiYN'		 : false,
                  'ModalPopup'	 : true,
                  'buyerCd'		 : EVF.V("BUYER_CD"),
                  'custCd'		 : EVF.V("BUYER_CD"),
                  'custNm'		 : EVF.V("BUYER_NM")
                };
                everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
            }
        }

        function setDept(data) {
            var d = JSON.parse(data);
            EVF.V('BELONG_DEPT_CD', d.DEPT_CD);
            EVF.V('BELONG_DEPT_NM', d.DEPT_NM);
        }

        function doFinishContract() {

            if(!checkFormValidation()) { return; }

            EVF.confirm("${CT0320_0020 }", function () {
                var store = new EVF.Store();
                store.setGrid([gridM, gridA]);
                store.getGridData(gridM, 'sel');
                store.getGridData(gridA, 'sel');
                store.doFileUpload(function() {
                    store.load(baseUrl + 'doFinishContract', function() {
                        var contNum = this.getParameter('contNum');
                        var contCnt = this.getParameter('contCnt');
                        EVF.alert('${msg.M0031}', function() {
                            location.href = baseUrl + "view.so?contNum=" + contNum + '&contCnt=' + contCnt;
                            if (opener) {
                                opener['doSearch']();
                            }
                        });
                    });
                });
            });
        }

        function approvalCallBack(appData) {
            var approvalData = JSON.parse(appData);
            EVF.C('approvalFormData').setValue(approvalData.formData);
            EVF.C('approvalGridData').setValue(approvalData.gridData);
        }

        function getApproval() {
            doReqSign() ;
        }

        function calContAmt() {

            var vatType = EVF.V("VAT_TYPE");
            var contAmt = Number(EVF.V("CONT_AMT"));
            var supplyAmt = Number(EVF.V("SUPPLY_AMT"));
            var vatAmt = Number(EVF.V("VAT_AMT"));


            if(EVF.isEmpty(contAmt)) {
                //return EVF.alert("${CT0320_0011}");
            }

            <%-- 부가세 포함 --%>
            if(vatType == "1") {
//                EVF.V("SUPPLY_AMT", Math.floor(contAmt / 1.1));
//                EVF.V("VAT_AMT", contAmt - Math.floor(contAmt / 1.1));
// 				EVF.V("GUBN_AMT",Math.round(supplyAmt+vatAmt))
            	EVF.V("CONT_AMT", Math.round(supplyAmt+vatAmt));

            }
            <%-- 부가세 별도 --%>
            else if(vatType == "0") {
//                EVF.V("SUPPLY_AMT", contAmt);
//                EVF.V("VAT_AMT", Math.floor(contAmt * 0.1));
            	EVF.V("CONT_AMT", Math.round(supplyAmt));
            }
            <%-- 부가세 면제 --%>
            else if(vatType == "2") {
//                EVF.V("SUPPLY_AMT", contAmt);
//                EVF.V("VAT_AMT", 0);
            	EVF.V("CONT_AMT", Math.round(supplyAmt));
            }
//            calContGuarAmt();
//            calWarrGuarAmt();
        }

        function doTest() {
            var param = {
                CONT_NUM: EVF.V("CONT_NUM"),
                callBackFunction: "doOpenPreCont"
            };
            everPopup.openCommonPopup(param, "SP0051");
        }


        function doOpenPreCont(data) {
            location.href = baseUrl + "view.so?contNum=" + data.CONT_NUM + '&contCnt=' + data.CONT_CNT;
        }

		function callback_doSelectItem(list) {
			var arrData = [];
			for(idx in list) {
				arrData.push({
					 ITEM_CD  	 	: list[idx].ITEM_CD
					,ITEM_DESC	 	: list[idx].ITEM_DESC
					,ITEM_SPEC	 	: list[idx].ITEM_SPEC
					,MAKER_CD 	 	: list[idx].MAKER_CD
					,MAKER_NM 	 	: list[idx].MAKER_NM
					,MAKER_PART_NO  : list[idx].MAKER_PART_NO
					,ORIGIN_CD      : list[idx].ORIGIN_CD
					,ORIGIN_NM      : list[idx].ORIGIN_NM
					,BRAND_NM       : list[idx].BRAND_CD
					,CUR            : "KRW"
					,UNIT_CD  	 	: list[idx].UNIT_CD
					,BUYER_CD 	 	: '${ses.companyCd}'
					,PR_BUYER_CD    : prBuyerVal
					,CUST_ITEM_CD 	: list[idx].CUST_ITEM_CD
					,VALID_FROM_DATE: list[idx].VALID_FROM_DATE
					,VALID_TO_DATE 	: list[idx].VALID_TO_DATE
				});
            }

			gridItem.addRow(arrData);
		}


		function doPrint() {
			fileFrame.location.href = '/common/file/fileAttach/downloadContPdf.so?contNum=${form.CONT_NUM}&contCnt=${form.CONT_CNT}';
		}



		function chgContStartDate() {

			var startDate = EVF.V("CONT_START_DATE");
			var yy = startDate.substr(0,4);
			var mm = new Number(startDate.substr(4,2))-1;
			var dd = startDate.substr(6,2);

			let date = new Date(yy, mm, dd);
			date.setFullYear(date.getFullYear() + 1)
			date.setDate(date.getDate() - 1)
			var year = date.getFullYear();
			var month = date.getMonth() + 1;
			var day = date.getDate();

			day = day >= 10 ? day : '0'+day;
			month = month >= 10 ? month : '0'+month;

			EVF.V("CONT_END_DATE",year+''+month+''+day);
		}

        function seTaxMethod(data){
            gridItem.setCellValue(data.rowId,'VAT_DTL_NM',data.VAT_DTL_NM);
            gridItem.setCellValue(data.rowId,'VAT_DTL_CD',data.VAT_DTL_CD);
            setContAmt();
        }

		function getPayMethod() {
            param = {
                    BUYER_CD : EVF.V("LOC_BUYER_CD")
                   ,callBackFunction : 'setPayMethod'
               }
               everPopup.openCommonPopup(param, 'SP0055');
		}

        function setPayMethod(data){
        	EVF.V("PAY_METHOD_NM",data.CODE_DESC);
        }

		function chgPrBuyerCd() {
            var rowIds = gridItem.getAllRowId();
			for (var i in rowIds) {
				gridItem.setCellValue(rowIds[i],"LOC_BUYER_CD" , EVF.V("PR_BUYER_CD") );
				gridItem.setCellValue(rowIds[i],"PLANT_CD" , '' );
				gridItem.setCellValue(rowIds[i],"WH_CD" , '' );
				gridItem.setCellValue(rowIds[i],"PLANT_NM" , '' );
				gridItem.setCellValue(rowIds[i],"WH_NM" , '' );
			}
			EVF.V("LOC_BUYER_CD",   EVF.V("PR_BUYER_CD") );
		}

	    function callbackGrid_PLANT_NM(data){
	    	gridItem.setCellValue(data.rowId, "PLANT_CD", data.PLANT_CD);
	    	gridItem.setCellValue(data.rowId, "PLANT_NM", data.PLANT_NM);
	    }

	    function callbackGrid_WH_NM(data){
	    	gridItem.setCellValue(data.rowId, "WH_CD", data.WH_CD);
	    	gridItem.setCellValue(data.rowId, "WH_NM", data.WH_NM);
	    }

	  	//고객사 팝업
		function selectBuyer(){

			var param = {
					 PR_BUYER_CD 	  : EVF.V("PR_BUYER_CD")
					,callBackFunction : 'callback_setBuyer'
				}
				everPopup.openCommonPopup(param, 'SP0067');
		}

		function callback_setBuyer(data){

			(data.COMPANY_CD == 'C') ? EVF.V("APAR_TYPE","P") : EVF.V("APAR_TYPE","S");
			// 매출(S)
			if(data.COMPANY_CD != 'C'){
				//$("#contBil").css("display","none");
				EVF.C("CONT_INSU_BILL_FLAG").setRequired(false);	// 계약보증여부
				EVF.C("ADV_INSU_BILL_FLAG").setRequired(false);		// 선급보증여부
				EVF.C("WARR_INSU_BILL_FLAG").setRequired(false);	// 하자보증여부
				EVF.C("BELONG_DIVISION_NM").setVisible(false);

				EVF.V("BELONG_DIVISION_CD" , data.CUST_CD);
				EVF.V("BELONG_DIVISION_NM" , data.CUST_NM);
				$("#BELONG_DEPT_NM").parent().css("width",'100%')
				EVF.C("BELONG_DEPT_NM").setRequired(true);

				var store = new EVF.Store();
			    //매출이면 협력업체 운영사 박기.
				store.setParameter("CTRL_USER_ID", EVF.V("CONT_USER_ID"));
				store.load(baseUrl + 'getVendorCustInformation', function() {
                    EVF.C("VENDOR_CD").setValue(this.getParameter('VENDOR_CD'));
                    EVF.C("VENDOR_NM").setValue(this.getParameter('VENDOR_NM'));
                    EVF.C("VENDOR_PIC_USER_NM").setValue(this.getParameter('VENDOR_PIC_USER_NM'));
                    EVF.C("VENDOR_PIC_USER_EMAIL").setValue(this.getParameter('VENDOR_PIC_EMAIL'));
                    EVF.C("VENDOR_PIC_CELL_NUM").setValue(this.getParameter('VENDOR_PIC_CELL_NUM'));
                });
			}// 매입(P)
			else{
				EVF.C("BELONG_DIVISION_NM").setVisible(true);
				$("#BELONG_DEPT_NM").parent().css("width",'50%')

				EVF.C("VENDOR_CD").setValue('');
	            EVF.C("VENDOR_NM").setValue('');
	            EVF.C("VENDOR_PIC_USER_NM").setValue('');
	            EVF.C("VENDOR_PIC_USER_EMAIL").setValue('');
	            EVF.C("VENDOR_PIC_CELL_NUM").setValue('');
			}
			EVF.V("PR_BUYER_CD"		   , data.CUST_CD);
			EVF.V("PR_BUYER_NM"		   , data.CUST_NM);
		}

		//고객사 팝업
		function selectBuyer2(){

			var param = {
				 PR_BUYER_CD : EVF.V("PR_BUYER_CD")
				,callBackFunction : 'callback_setBuyer2'
			}
			everPopup.openCommonPopup(param, 'SP0902');
		}

		function callback_setBuyer2(data){
			EVF.V("BELONG_DIVISION_CD" , data.CUST_CD);
			EVF.V("BELONG_DIVISION_NM" , data.CUST_NM);
			EVF.V("BELONG_DEPT_NM" , "");
			EVF.V("BELONG_DEPT_CD" , "");
		}

		//사업장 팝업
		function selectPlant(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('BELONG_DIVISION_CD') === '') {
				return EVF.alert('${CT0320_0034}');
			}

			var param = {
				 custCd : EVF.V("BELONG_DIVISION_CD")
				,callBackFunction : 'callback_setPlant'
			}
			everPopup.openCommonPopup(param, 'SP0005');
		}
		function callback_setPlant(data){
			EVF.V("BELONG_DEPT_NM", data.PLANT_NM);
			EVF.V("BELONG_DEPT_CD", data.PLANT_CD);
		}

		//계약회수 --> 협력업체 계약서명 날인 완료 전 가능
		function doSendCancle(){
			EVF.confirm("${CT0320_0031}", function () {
                var store = new EVF.Store();
                store.load(baseUrl + "doSendCancle", function () {
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

    </script>

    <e:window id="CT0320" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">

        <e:tabPanel id="T1" onActive="onActiveTab" onBeforeActive="onBeforeActiveTab">
            <e:tab id="1" title="기본정보">

                <e:inputHidden id="CONT_NUM" name="CONT_NUM" value="${empty form.CONT_NUM ? param.contNum : form.CONT_NUM}"/>
                <e:inputHidden id='CONT_CNT' name='CONT_CNT' value='${empty form.CONT_CNT ? param.contCnt : form.CONT_CNT}'/>
                <e:inputHidden id='NEW_CONT_CNT' name='NEW_CONT_CNT' value='${empty form.NEW_CONT_CNT ? null : form.NEW_CONT_CNT}'/>

                <e:inputHidden id='PROGRESS_CD' name='PROGRESS_CD' value='${form.PROGRESS_CD}'/>
                <e:inputHidden id='CONTRACT_TEXT_NUM' name='CONTRACT_TEXT_NUM' value='${form.CONTRACT_TEXT_NUM}'/>
                <e:inputHidden id='FORM_NUM' name='FORM_NUM' value='${form.MAIN_FORM_NUM}' alt="주계약서 서식번호" />
                <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${empty form.APP_DOC_NUM ? param.appDocNum : form.APP_DOC_NUM}"/>
                <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${empty form.APP_DOC_CNT ? param.appDocCnt : form.APP_DOC_CNT}"/>
                <e:inputHidden id='SIGN_STATUS' name="SIGN_STATUS" value="${form.SIGN_STATUS}" />
                <e:inputHidden id="APP_DOC_NUM2" name="APP_DOC_NUM2" value="${empty form.APP_DOC_NUM2 ? param.appDocNum2 : form.APP_DOC_NUM2}"/>
                <e:inputHidden id="APP_DOC_CNT2" name="APP_DOC_CNT2" value="${empty form.APP_DOC_CNT2 ? param.appDocCnt2 : form.APP_DOC_CNT2}"/>
                <e:inputHidden id='SIGN_STATUS2' name="SIGN_STATUS2" value="${form.SIGN_STATUS2}" />
				<e:inputHidden id="approvalFormData" name="approvalFormData" value="" />
				<e:inputHidden id="approvalGridData" name="approvalGridData" value="" />
                <e:inputHidden id="attachFileDatas" name="attachFileDatas" visible="false" />
                <e:inputHidden id="oriFormContents" name="oriFormContents" value="${form.oriFormContents}" />
                <e:inputHidden id='SUPPLY_AMT' name="SUPPLY_AMT" value="${form.SUPPLY_AMT}" />
                <e:inputHidden id='GUBN_AMT' name="GUBN_AMT" value="${form.GUBN_AMT}" />
                <e:inputHidden id='VAT_AMT' name="VAT_AMT" value="${form.VAT_AMT}" />

                <e:inputHidden id='AUTO_PO_YN' name="AUTO_PO_YN" value="${form.AUTO_PO_YN}" />

				<e:inputHidden id="RFX_NUM" name="RFX_NUM" value="" />
				<e:inputHidden id="RFX_CNT" name="RFX_CNT" value="" />
				<e:inputHidden id="QTA_NUM" name="QTA_NUM" value="" />
				<e:inputHidden id="PR_NUM_SQ" name="PR_NUM_SQ" value="" />
				<e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD" value="" />

				<e:inputHidden id="LOC_BUYER_CD" name="LOC_BUYER_CD" value="${form.LOC_BUYER_CD}" />
				<e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${form.EXEC_NUM}" />
				<e:inputHidden id="EXEC_CNT" name="EXEC_CNT" value="${form.EXEC_CNT}" />

				<e:inputHidden id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" />
				<e:inputHidden id="GR_IV_DIV" name="GR_IV_DIV" value="${form.GR_IV_DIV}" />
				<e:inputHidden id="APAR_TYPE" name="APAR_TYPE" value="${form.APAR_TYPE}" />
				<e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.CTRL_USER_ID}" />
				<e:inputHidden id="WARR_FROM_DATE" name="WARR_FROM_DATE" value="${form.WARR_FROM_DATE}" />
				<e:inputHidden id="WARR_END_DATE" name="WARR_END_DATE" value="${form.WARR_END_DATE}" />

				<e:inputHidden id="CONTRACT_FORM_TYPE" name="CONTRACT_FORM_TYPE" value="${form.CONTRACT_FORM_TYPE}" />
				<e:inputHidden id="VENDOR_TEST_REQ_YN" name="VENDOR_TEST_REQ_YN" value="${form.VENDOR_TEST_REQ_YN}" />
				<e:inputHidden id="VENDOR_EDIT_FLAG" name="VENDOR_EDIT_FLAG" value="${empty form.VENDOR_EDIT_FLAG ? '0' : form.VENDOR_EDIT_FLAG}" />
				<e:inputHidden id="CUR" name="CUR" value="KRW" />
				<e:inputHidden id="CONT_PAY_AMT" name="CONT_PAY_AMT" value="${form.CONT_PAY_AMT}" />
				<e:inputHidden id="ADV_PAY_AMT" name="ADV_PAY_AMT" value="${form.ADV_PAY_AMT}" />
				<e:inputHidden id="WARR_PAY_AMT" name="WARR_PAY_AMT" value="${form.WARR_PAY_AMT}" />
				<e:inputHidden id="BUYER_PLANT_INFO" name="BUYER_PLANT_INFO" value="" />

                <e:title title="기본정보" />
                <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="160px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false">
                    <e:row>
						<%--구매요청회사--%>
						<e:label for="PR_BUYER_NM" title="${form_PR_BUYER_NM_N}<br>납품장소(고객사/사업장)"/>
						<e:field>
							<e:search id="PR_BUYER_NM" name="PR_BUYER_NM" value="${form.PR_BUYER_NM}" width="${form_PR_BUYER_NM_W}" maxLength="${form_PR_BUYER_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
							<e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${form.PR_BUYER_CD}" />
							<e:inputHidden id="BELONG_DIVISION_CD" name="BELONG_DIVISION_CD" value="${form.BELONG_DIVISION_CD}" />
							<e:inputHidden id="BELONG_DEPT_CD" name="BELONG_DEPT_CD" value="${form.BELONG_DEPT_CD}" />
							<e:br/>
							<e:br/>
							<e:br/>
							<e:br/>
							<e:br/>
							<e:br/>
							<e:search id="BELONG_DIVISION_NM" name="BELONG_DIVISION_NM" value="${form.BELONG_DIVISION_NM}" width="50%" maxLength="${form_BELONG_DIVISION_NM_M}" onIconClick="selectBuyer2" disabled="${form_BELONG_DIVISION_NM_D}" readOnly="${form_BELONG_DIVISION_NM_RO}" required="${form_BELONG_DIVISION_NM_R}" />
							<e:search id="BELONG_DEPT_NM" name="BELONG_DEPT_NM" value="${form.BELONG_DEPT_NM}"  width="${form.APAR_TYPE == 'S' ? '100%' :'50%'}" maxLength="${form_BELONG_DEPT_NM_M}" onIconClick="selectPlant" disabled="${form_BELONG_DEPT_NM_D}" readOnly="${form_BELONG_DEPT_NM_RO}" required="${form_BELONG_DEPT_NM_R}" />
						</e:field>
						<%--품질보증기간--%>
						<e:label for="QUALITY_WARRANTY_PERIOD" title="${form_QUALITY_WARRANTY_PERIOD_N}" />
						<e:field>
							<e:inputText id="QUALITY_WARRANTY_PERIOD" name="QUALITY_WARRANTY_PERIOD" value="${empty form.QUALITY_WARRANTY_PERIOD ? '납품완료일에서 30일 가산' :form.QUALITY_WARRANTY_PERIOD }" width="${form_QUALITY_WARRANTY_PERIOD_W}" maxLength="${form_QUALITY_WARRANTY_PERIOD_M}" disabled="${form_QUALITY_WARRANTY_PERIOD_D}" readOnly="${form_QUALITY_WARRANTY_PERIOD_RO}" required="${form_QUALITY_WARRANTY_PERIOD_R}" />
						</e:field>
						<%--지체상금율--%>
						<e:label for="DELAY_RATE" title="${form_DELAY_RATE_N}"/>
						<e:field>
							<e:inputNumber id="DELAY_RATE" name="DELAY_RATE" value="${empty form.DELAY_RATE ? '0.15' : form.DELAY_RATE}" width="${form_DELAY_RATE_W}" maxValue="${form_DELAY_RATE_M}" decimalPlace="${form_DELAY_RATE_NF}" disabled="${form_DELAY_RATE_D}" readOnly="${form_DELAY_RATE_RO}" required="${form_DELAY_RATE_R}" />
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
                            <e:inputDate id="CONT_START_DATE"  onChange="chgContStartDate"    name="CONT_START_DATE" toDate="CONT_END_DATE" value="${empty form.CONT_START_DATE ? param.CONT_START_DATE : form.CONT_START_DATE}" width="${inputTextDate }" required="${form_CONT_START_DATE_R }" readOnly="${form_CONT_START_DATE_RO }" disabled="${form_CONT_START_DATE_D }" datePicker="true"/>
                            <e:text>~</e:text>
                            <e:inputDate id="CONT_END_DATE" name="CONT_END_DATE" fromDate="CONT_START_DATE" value="${empty form.CONT_END_DATE ? param.CONT_END_DATE : form.CONT_END_DATE}" width="${inputTextDate }" required="${form_CONT_END_DATE_R }" readOnly="${form_CONT_END_DATE_RO }" disabled="${form_CONT_END_DATE_D }" datePicker="true"/>
                        </e:field>
                        <e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"/>
                        <e:field>
                            <e:select id="CONT_REQ_CD" name="CONT_REQ_CD" value="${form.CONT_REQ_CD}" options="${contReqCdOptions}" width="${form_CONT_REQ_CD_W}" disabled="${form_CONT_REQ_CD_D}" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder="" usePlaceHolder="false" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="CONT_AMT" title="${form_CONT_AMT_N }"/>
                        <e:field colSpan="3">
                            <e:inputNumber id="CONT_AMT" name="CONT_AMT" value="${form.CONT_AMT}" width="200px" required="${form_CONT_AMT_R }" disabled="${form_CONT_AMT_D }" readOnly="${form_CONT_AMT_RO }" onChange="calContAmt" />
							<e:inputText id="CURS" name="CURS" value="KRW" width="${form_CURS_W}" maxLength="${form_CURS_M}" disabled="${form_CURS_D}" readOnly="${form_CURS_RO}" required="${form_CURS_R}" />
                            <e:select id="VAT_TYPE" name="VAT_TYPE" value="1" options="${vatTypeOptions}" width="110px" disabled="true" readOnly="${form_VAT_TYPE_RO}" required="${form_VAT_TYPE_R}" placeHolder="" usePlaceHolder="false" onChange="calContAmt" />
                            <e:br/>
                            <e:text>아래 품목정보상의 금액을 입력하시면 자동으로 합산되어 입력됩니다.</e:text>
                        </e:field>
                        <e:label for="CONT_USER_NM" title="${form_CONT_USER_ID_N }"/>
                        <e:field>
                            <e:search id="CONT_USER_NM" name="CONT_USER_NM" width="100%" value="${empty form.CONT_USER_NM ? ses.userNm : form.CONT_USER_NM}" maxLength="${form_CONT_USER_NM_M }" required="${form_CONT_USER_NM_R }" disabled="${form_CONT_USER_NM_D }" readOnly="${form_CONT_USER_NM_RO }" onIconClick="${param.detailView ? '' : 'getDrafter'}"/>
                            <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${empty form.CONT_USER_ID ? ses.userId : form.CONT_USER_ID}"/>
                            <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${empty form.BUYER_CD ? ses.companyCd : form.BUYER_CD}"/>
                            <e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${empty form.BUYER_NM ? ses.companyNm : form.BUYER_NM}"/>
                            <e:inputHidden id="openFormType" name="openFormType" value="${param.openFormType}"/>
                            <e:inputHidden id="DELAY_RMK" name="DELAY_RMK" value=""/>
                            <e:inputHidden id="DELAY_DENO_RATE" name="DELAY_DENO_RATE" value="1000"/>
                            <e:inputHidden id="DELAY_NUME_RATE" name="DELAY_NUME_RATE" value=""/>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="VENDOR_NM" title="${form_VENDOR_CD_N }"/>
                        <e:field>
                            <e:search id="VENDOR_NM" name="VENDOR_NM" width="100%" value="${empty form.VENDOR_NM ? param.VENDOR_NM : form.VENDOR_NM}" maxLength="${form_VENDOR_NM_M }" required="${form_VENDOR_NM_R }" disabled="${form_VENDOR_NM_D }" readOnly="${form_VENDOR_NM_RO }" onIconClick="${param.detailView ? '' : 'getVendorCd'}"/>
                            <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${empty form.VENDOR_CD ? param.VENDOR_CD : form.VENDOR_CD}"/>
                        </e:field>
                        <e:label for="MANUAL_CONT_FLAG" title="${form_MANUAL_CONT_FLAG_N}"/>
                        <e:field>
                            <e:select id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="${empty form.MANUAL_CONT_FLAG ? param.MANUAL_CONT_FLAG : form.MANUAL_CONT_FLAG}" options="${manualContFlagOptions}" width="${form_MANUAL_CONT_FLAG_W}" disabled="${form_MANUAL_CONT_FLAG_D}" readOnly="${form_MANUAL_CONT_FLAG_RO}" required="${form_MANUAL_CONT_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
                        </e:field>
						<%--내/외자--%>
						<e:label for="WARR_GUAR_QT" title="${form_WARR_GUAR_QT_N}"/>
						<e:field>
							<e:inputNumber id="WARR_GUAR_QT" name="WARR_GUAR_QT" value="${form.WARR_GUAR_QT}" width="${form_WARR_GUAR_QT_W}" maxValue="${form_WARR_GUAR_QT_M}" decimalPlace="${form_WARR_GUAR_QT_NF}" disabled="${form_WARR_GUAR_QT_D}" readOnly="${form_WARR_GUAR_QT_RO}" required="${form_WARR_GUAR_QT_R}" />
						</e:field>
                    </e:row>
                    <e:row>
                        <e:label for="VENDOR_PIC_USER_NM" title="${form_VENDOR_PIC_USER_NM_N}"/>
                        <e:field>
                            <e:inputText id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" value="${form.VENDOR_PIC_USER_NM}" width="${form_VENDOR_PIC_USER_NM_W}" maxLength="${form_VENDOR_PIC_USER_NM_M}" disabled="${form_VENDOR_PIC_USER_NM_D}" readOnly="${form_VENDOR_PIC_USER_NM_RO}" required="${form_VENDOR_PIC_USER_NM_R}"/>
                        </e:field>
                        <e:label for="VENDOR_PIC_USER_EMAIL" title="${form_VENDOR_PIC_USER_EMAIL_N}"/>
                        <e:field>
                            <e:inputText id="VENDOR_PIC_USER_EMAIL" name="VENDOR_PIC_USER_EMAIL" value="${form.VENDOR_PIC_USER_EMAIL}" width="${form_VENDOR_PIC_USER_EMAIL_W}" maxLength="${form_VENDOR_PIC_USER_EMAIL_M}" disabled="${form_VENDOR_PIC_USER_EMAIL_D}" readOnly="${form_VENDOR_PIC_USER_EMAIL_RO}" required="${form_VENDOR_PIC_USER_EMAIL_R}"/>
                        </e:field>
                        <e:label for="VENDOR_PIC_CELL_NUM" title="${form_VENDOR_PIC_CELL_NUM_N}"/>
                        <e:field>
                            <e:inputText id="VENDOR_PIC_CELL_NUM" name="VENDOR_PIC_CELL_NUM" value="${form.VENDOR_PIC_CELL_NUM}" width="${form_VENDOR_PIC_CELL_NUM_W}" maxLength="${form_VENDOR_PIC_CELL_NUM_M}" disabled="${form_VENDOR_PIC_CELL_NUM_D}" readOnly="${form_VENDOR_PIC_CELL_NUM_RO}" required="${form_VENDOR_PIC_CELL_NUM_R}"/>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="CONT_REQ_RMK" title="${form_CONT_REQ_RMK_N}"/>
                        <e:field colSpan="5">
                            <e:textArea id="CONT_REQ_RMK" style="${imeMode}" name="CONT_REQ_RMK" height="70" value="${empty form.CONT_REQ_RMK ? param.CONT_REQ_RMK : form.CONT_REQ_RMK}" width="100%" maxLength="${form_CONT_REQ_RMK_M}" disabled="${form_CONT_REQ_RMK_D}" readOnly="${form_CONT_REQ_RMK_RO}" required="${form_CONT_REQ_RMK_R}"/>
                        </e:field>
                    </e:row>
                    <c:if test="${form.PROGRESS_CD eq '4220'}">
                        <e:row>
                            <e:label for="VENDOR_REJECT_RMK" title="${form_VENDOR_REJECT_RMK_N}"/>
                            <e:field colSpan="5">
                                <e:textArea id="VENDOR_REJECT_RMK" name="VENDOR_REJECT_RMK" value="${form.VENDOR_REJECT_RMK}" height="100px" width="100%" maxLength="${form_VENDOR_REJECT_RMK_M}" disabled="${form_VENDOR_REJECT_RMK_D}" readOnly="${form_VENDOR_REJECT_RMK_RO}" required="${form_VENDOR_REJECT_RMK_R}" />
                            </e:field>
                        </e:row>
                    </c:if>
                </e:searchPanel>

                <div id="Panel-307-487-661" class="e-panel" style="height: ${formSelPanelHeight}px;width: 100%; float:none;">
                    <div class="e-panel-body">
                        <div id="Panel-820-128-37" class="e-panel" style="width: 59%;">
                        	<e:title title="주계약서식"/>
                            <div class="e-panel-body">
                                <e:gridPanel gridType="${_gridType}" id="gridM" name="gridM" width="100%" height="${formSelGridHeight}" readOnly="${param.detailView}" columnDef="${gridInfos.gridM.gridColData}"/>
                            </div>
                        </div>
                        <div id="Panel-767-343-650" class="e-panel" style="width: 1%;">
                            <div class="e-panel-body">&nbsp;</div>
                        </div>
                        <div id="Panel-733-617-336" class="e-panel" style="width: 40%;">
                        	<e:title title="부계약서식"/>
                            <div class="e-panel-body">
                                <e:gridPanel gridType="${_gridType}" id="gridA" name="gridA" width="100%" height="${formSelGridHeight}" readOnly="${param.detailView}" columnDef="${gridInfos.gridA.gridColData}"/>
                            </div>
                        </div>
                    </div>
                </div>

                <e:title title="첨부파일"/>
                <e:searchPanel id="form2" title="${form_CAPTION_N}" labelWidth="160px" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
                    <e:row>
                        <c:set var="attFileEditable" value="${empty form.PROGRESS_CD or form.PROGRESS_CD eq '4210' or form.PROGRESS_CD eq '4110'}"/>

                        <e:label for="M_ATT_FILE_NUM" title="${form_M_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="M_ATT_FILE_NUM" height="110" width="100%" fileId="${form.M_ATT_FILE_NUM}" readOnly="${not attFileEditable}" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
                        <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="ATT_FILE_NUM" height="110" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${not attFileEditable}" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
                    </e:row>
                </e:searchPanel>

				<div id="contBil" style="display : inline">

                <e:title title="보증정보" />
                <e:searchPanel id="form3" title="${form_CAPTION_N}" labelWidth="160px" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
                    <e:row >
						<e:label for="CONT_INSU_BILL_FLAG" title="${form_CONT_INSU_BILL_FLAG_N}"/>
                        <e:field>
                        	<e:select id="CONT_INSU_BILL_FLAG" name="CONT_INSU_BILL_FLAG" value="${form.CONT_INSU_BILL_FLAG}" options="${contInsuBillFlagOptions}" width="${form_CONT_INSU_BILL_FLAG_W}" disabled="${form_CONT_INSU_BILL_FLAG_D}" readOnly="${form_CONT_INSU_BILL_FLAG_RO}" required="${form_CONT_INSU_BILL_FLAG_R}" placeHolder="" onChange="cleanGuarVal" data="CONT"/>
							<e:text>&nbsp;&nbsp;보증구분</e:text>
                            <e:select id="CONT_GUAR_TYPE" name="CONT_GUAR_TYPE" value="${form.CONT_GUAR_TYPE}" options="${contGuarTypeOptions}" width="120px" disabled="${form_CONT_GUAR_TYPE_D}" readOnly="${form_CONT_GUAR_TYPE_RO}" required="${form_CONT_GUAR_TYPE_R}" placeHolder="" usePlaceHolder="false" onChange="cleanGuarVal" data="CONT"/>
                            <e:text>&nbsp;&nbsp;보증율</e:text>
                            <e:inputNumber id="CONT_GUAR_PERCENT" name="CONT_GUAR_PERCENT" value="${form.CONT_GUAR_PERCENT}" width="60px" required="${form_CONT_GUAR_PERCENT_R }" disabled="${form_CONT_GUAR_PERCENT_D }" readOnly="${form_CONT_GUAR_PERCENT_RO }" onChange="calContGuarAmt" />
                            <e:text>%&nbsp;&nbsp;&nbsp;보증금액</e:text>
                            <e:inputNumber id="CONT_GUAR_AMT" name="CONT_GUAR_AMT" value="${form.CONT_GUAR_AMT}" width="100px" required="${form_CONT_GUAR_AMT_R }" disabled="${form_CONT_GUAR_AMT_D }" readOnly="${form_CONT_GUAR_AMT_RO }"/>
                            <e:text>&nbsp;</e:text>
                            <e:inputHidden id="CONT_VAT_TYPE" name="CONT_VAT_TYPE" value="${empty form.CONT_VAT_TYPE ? '1' : form.CONT_VAT_TYPE}" />
						</e:field>
                    	<e:label for="CONT_ATT_FILE_NUM" title="${form_CONT_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="CONT_ATT_FILE_NUM" height="50" width="100%" fileId="${form.CONT_ATT_FILE_NUM}" readOnly="false" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="ADV_INSU_BILL_FLAG" title="${form_ADV_INSU_BILL_FLAG_N}"/>
                        <e:field>
                        	<e:select id="ADV_INSU_BILL_FLAG" name="ADV_INSU_BILL_FLAG" value="${form.ADV_INSU_BILL_FLAG}" options="${advInsuBillFlagOptions}" width="${form_ADV_INSU_BILL_FLAG_W}" disabled="${form_ADV_INSU_BILL_FLAG_D}" readOnly="${form_ADV_INSU_BILL_FLAG_RO}" required="${form_ADV_INSU_BILL_FLAG_R}" placeHolder="" onChange="cleanGuarVal" data="ADV"/>
                            <e:text>&nbsp;&nbsp;보증구분</e:text>
                            <e:select id="ADV_GUAR_TYPE" name="ADV_GUAR_TYPE" value="${form.ADV_GUAR_TYPE}" options="${advGuarTypeOptions}" width="120px" disabled="${form_ADV_GUAR_TYPE_D}" readOnly="${form_ADV_GUAR_TYPE_RO}" required="${form_ADV_GUAR_TYPE_R}" placeHolder="" usePlaceHolder="false" onChange="cleanGuarVal" data="ADV" />
                            <e:text>&nbsp;&nbsp;보증율</e:text>
                            <e:inputNumber id="ADV_GUAR_PERCENT" name="ADV_GUAR_PERCENT" value="${form.ADV_GUAR_PERCENT}" width="60px" required="${form_ADV_GUAR_PERCENT_R }" disabled="${form_ADV_GUAR_PERCENT_D }" readOnly="${form_ADV_GUAR_PERCENT_RO }" onChange="calAdvGuarAmt" />
                            <e:text>%&nbsp;&nbsp;&nbsp;보증금액</e:text>
                            <e:inputNumber id="ADV_GUAR_AMT" name="ADV_GUAR_AMT" value="${form.ADV_GUAR_AMT}" width="100px" required="${form_ADV_GUAR_AMT_R }" disabled="${form_ADV_GUAR_AMT_D }" readOnly="${form_ADV_GUAR_AMT_RO }"/>
                            <e:text>&nbsp;</e:text>
                            <e:inputHidden id="ADV_VAT_TYPE" name="ADV_VAT_TYPE" value="${empty form.ADV_VAT_TYPE ? '1' : form.ADV_VAT_TYPE}" />
                        </e:field>
                    	<e:label for="ADV_ATT_FILE_NUM" title="${form_ADV_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="ADV_ATT_FILE_NUM" height="50" width="100%" fileId="${form.ADV_ATT_FILE_NUM}" readOnly="false" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="WARR_INSU_BILL_FLAG" title="${form_WARR_INSU_BILL_FLAG_N}"/>
                        <e:field>
                        	<e:select id="WARR_INSU_BILL_FLAG" name="WARR_INSU_BILL_FLAG" value="${form.WARR_INSU_BILL_FLAG}" options="${warrInsuBillFlagOptions}" width="${form_WARR_INSU_BILL_FLAG_W}" disabled="${form_WARR_INSU_BILL_FLAG_D}" readOnly="${form_WARR_INSU_BILL_FLAG_RO}" required="${form_WARR_INSU_BILL_FLAG_R}" placeHolder="" onChange="cleanGuarVal" data="WARR"/>
                            <e:text>&nbsp;&nbsp;보증구분</e:text>
                            <e:select id="WARR_GUAR_TYPE" name="WARR_GUAR_TYPE" value="${form.WARR_GUAR_TYPE}" options="${warrGuarTypeOptions}" width="120px" disabled="${form_WARR_GUAR_TYPE_D}" readOnly="${form_WARR_GUAR_TYPE_RO}" required="${form_WARR_GUAR_TYPE_R}" placeHolder="" usePlaceHolder="false" onChange="cleanGuarVal" data="WARR"/>
                            <e:text>&nbsp;&nbsp;보증율</e:text>
                            <e:inputNumber id="WARR_GUAR_PERCENT" name="WARR_GUAR_PERCENT" value="${form.WARR_GUAR_PERCENT}" width="60px" required="${form_WARR_GUAR_PERCENT_R }" disabled="${form_WARR_GUAR_PERCENT_D }" readOnly="${form_WARR_GUAR_PERCENT_RO }" onChange="calWarrGuarAmt" />
                            <e:text>%&nbsp;&nbsp;&nbsp;보증금액</e:text>
                            <e:inputNumber id="WARR_GUAR_AMT" name="WARR_GUAR_AMT" value="${form.WARR_GUAR_AMT}" width="100px" required="${form_WARR_GUAR_AMT_R }" disabled="${form_WARR_GUAR_AMT_D }" readOnly="${form_WARR_GUAR_AMT_RO }"/>
                            <e:text>&nbsp;</e:text>
							<e:inputHidden id="WARR_VAT_TYPE" name="WARR_VAT_TYPE" value="${empty form.WARR_VAT_TYPE ? '1' : form.WARR_VAT_TYPE}" />
                        </e:field>
                    	<e:label for="WARR_ATT_FILE_NUM" title="${form_WARR_ATT_FILE_NUM_N}"/>
                        <e:field>
                            <e:fileManager id="WARR_ATT_FILE_NUM" height="50" width="100%" fileId="${form.WARR_ATT_FILE_NUM}" readOnly="false" bizType="EC" required="false" uploadable="${attFileEditable}" autoUpload="true" />
                        </e:field>
					</e:row>
                </e:searchPanel>
			</div>

			<div style="display : true">
                <e:title title="대금지급정보" />
                <e:searchPanel id="form4" title="${form_CAPTION_N}" labelWidth="160px" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
                    <e:row>
                        <e:label for="PAY_TYPE" title="${form_PAY_TYPE_N}"/>
                        <e:field>
                            <e:select id="PAY_TYPE" name="PAY_TYPE" value="${form.PAY_TYPE}" options="${payTypeOptions}" width="120px" disabled="${form_PAY_TYPE_D}" readOnly="${form_PAY_TYPE_RO}" required="${form_PAY_TYPE_R}" placeHolder="" usePlaceHolder="false" onChange="changePayType" />
                        </e:field>
                        <e:label for="PAY_CNT" title="${form_PAY_CNT_N}"/>
                        <e:field>
                            <e:inputNumber id="PAY_CNT" name="PAY_CNT" value="${form.PAY_CNT}" width="60px" required="${form_PAY_CNT_R }" disabled="${form_PAY_CNT_D }" readOnly="${form_PAY_CNT_RO }"/>
                            <e:text>&nbsp;</e:text>
                            <e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
                        </e:field>
                    </e:row>
                    <e:row>
	                    <%--대금지급조건--%>
						<e:label for="PAY_METHOD_NM" title="${form_PAY_METHOD_NM_N}" />
						<e:field colSpan="3">
							<e:inputText id="PAY_METHOD_NM" name="PAY_METHOD_NM" value="${form.PAY_METHOD_NM}" width="100%" maxLength="${form_PAY_METHOD_NM_M}" disabled="${form_PAY_METHOD_NM_D}" readOnly="${form_PAY_METHOD_NM_RO}" required="${form_PAY_METHOD_NM_R}" />
						</e:field>

                    </e:row>
                    <e:row>
                        <e:label for="PAY_RMK" title="${form_PAY_RMK_N}"/>
                        <e:field colSpan="3">
                            <e:inputText id="PAY_RMK" style="${imeMode}" name="PAY_RMK" value="${form.PAY_RMK}" width="100%" maxLength="${form_PAY_RMK_M}" disabled="${form_PAY_RMK_D}" readOnly="${form_PAY_RMK_RO}" required="${form_PAY_RMK_R}"/>
                        </e:field>
                    </e:row>
                </e:searchPanel>
                <e:gridPanel id="gridP" name="gridP" width="100%" height="150px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridP.gridColData}" />
			</div>

                <e:buttonBar id="contXButtons" title="품목정보" width="100%" align="right">
				</e:buttonBar>
                <e:gridPanel id="gridItem" name="gridItem" width="100%" height="240px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridItem.gridColData}" />
            </e:tab>

            <e:tab id="2" title="주계약정보">
                <c:if test="${not param.detailView eq 'true'}">
                    <e:buttonBar id="contButtons" width="700" align="right">
                        <e:text><span style="color: #dc2d34; font-size: 13px; font-weight: bold;">※ 계약서 첨부파일은 기본정보 탭에 있습니다.</span></e:text>
                        <%-- 저장 --%>
                        <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${authFlag ? doSave_V : false}"/>
                        <%-- 결재요청 --%>
                        <e:button id="doReqLegalTeam" name="doReqLegalTeam" label="${doReqLegalTeam_N}" onClick="doReqLegalTeam" disabled="${doReqLegalTeam_D}" visible="${authFlag ? doReqLegalTeam_V : false}"/>
                        <%-- 4220: 협력업체 서명완료 --%>
                        <c:if test="${form.PROGRESS_CD eq '4220'}">
                            <e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
                        </c:if>
                        <%-- 4200: 협력업체 서명대기 이면서 접수전일때 -> 협력업체 서명완료전 계약회수 버튼. --%>
                    	<c:if test="${form.PROGRESS_CD eq '4200' and form.RECEIPT_YN eq '0'}">
                    		<e:button id="doSendCancle" name="doSendCancle" label="${doSendCancle_N}" onClick="doSendCancle" disabled="${doSendCancle_D}" visible="${doSendCancle_V}"/>
                        </c:if>
                        <c:if test="${form.PROGRESS_CD ne null}">
							<e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
						</c:if>
                        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${authFlag ? doDelete_V : false}"/>

                    </e:buttonBar>
                </c:if>
                <div style="width: 100%; padding: 0; margin: 0;">
                    <div class="contract_contents_div" id="cont_content">${fn:replace(fn:replace(fn:replace(form.formContents, "&lt;", "<"), "&gt;", ">"), "&quot;", "\"")}</div>
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
                        <div class="contract_contents_div" id="${subForm.REL_FORM_NUM}">${fn:replace(fn:replace(fn:replace(subForm.ADDITIONAL_CONTENTS, "&lt;", "<"), "&gt;", ">"), "&quot;", "\"")}</div>
                    </div>
                </e:tab>
            </c:forEach>
        </e:tabPanel>

        <iframe id="fileFrame" name="fileFrame" style="display: block;" height="0"></iframe>
    </e:window>

</e:ui>