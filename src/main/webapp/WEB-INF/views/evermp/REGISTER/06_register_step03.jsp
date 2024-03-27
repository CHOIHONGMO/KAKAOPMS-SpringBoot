<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<!DOCTYPE>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>SONO Welcome</title>
    <link rel="stylesheet" href="/css/ymro/ui/style.css" type="text/css">
    <link rel="stylesheet" href="/css/jquery/jquery-ui.css">
    <script type="text/javascript" src="/js/everuxf/everuxf.min.js"></script>
    <script src="/js/jquery/jquery-ui.js"></script>
    <script type="text/javascript" src="/css/ymro/js/lib/jquery.bxslider.js"></script>
    <script type="text/javascript" src="/css/ymro/js/ui/common.js"></script>
    <script type="text/javascript" src="/js/ever-string.js"></script>
    <script type="text/javascript" src="/js/ever-popup.js"></script>
    <script type="text/javascript" src="/js/ever-formutils.js"></script>
<c:if test="${sslFlag == false}">
    <script src="http://dmaps.daum.net/map_js_init/postcode.v2.js"></script>
</c:if>
<c:if test="${sslFlag == true}">
    <script src="https://spi.maps.daum.net/imap/map_js_init/postcode.v2.js"></script>
</c:if>
    <style type="text/css">
        .loader {
   			position: absolute;
    		left: 50%;
    		top: 50%;
    		z-index: 1;
    		width: 95px;
    		height: 95px;
    		margin: -50px 0 0 -50px;
    		border: 15px solid #f3f3f3;
    		border-radius: 50%;
    		border-top: 11px solid #3498db;
    		width: 85px;
    		height: 85px;
    		-webkit-animation: spin 3s linear infinite;
    		animation: spin 3s linear infinite;
		}

		@-webkit-keyframes spin {
    		0% { -webkit-transform: rotate(0deg); }
    		100% { -webkit-transform: rotate(360deg); }
		}

		@keyframes spin {
    		0% { transform: rotate(0deg); }
    		100% { transform: rotate(360deg); }
		}
		.center {
            text-align: center;
        }
    </style>
    <script>
        var changeIdFlag = true;
        var regExpEMAIL = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i;
        var regExpTEL_NUM = /^\d{2,3}-\d{3,4}-\d{4}$/;
        var regExpCELL_NUM = /^\d{3}-\d{3,4}-\d{4}$/;
        var pop = null;

        $(document).ready(function() {
            // $('#mainIframe', parent.document).css('height', '3000px');

            $( "#FOUNDATION_DATE, #IPO_DATE, #DEAL_APRV_DATE" ).datepicker({
                dateFormat: 'yy-mm-dd',
                prevText: '이전 달',
                nextText: '다음 달',
                monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
                monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
                dayNames: ['일','월','화','수','목','금','토'],
                dayNamesShort: ['일','월','화','수','목','금','토'],
                dayNamesMin: ['일','월','화','수','목','금','토'],
                showMonthAfterYear: true,
                changeMonth: true,
                changeYear: true,
                yearSuffix: '년',
                yearRange: '-30:+0'
            });

            $('.input_search').on('click', function(e) {
                var url = '/common/code/BADV_020/view';

                var param = {
                    callBackFunction : "setZipCode",
                    modalYn : false
                };
                // everPopup.openWindowPopup(url, 700, 600, param, 'searchZip');
                // window.showModalDialog(url+"?"+$.param(param), window, "dialogWidth:800px;dialogHeight:600px;help:0;scroll:0;status:0;center:1;");
                // var url = location.href + "?" + $.param(param);
                //document.domain = window.location.hostname;
                //window.name = "jusoPop";
                //var pop = window.open(url + "?" + $.param(param),"pop","width=570,height=420, scrollbars=yes, resizable=yes");
                //everPopup.openWindowPopup(url, 570, 420, param, 'searchZip');
                //everPopup.openPopupByScreenId("BADV_020", 570, 420, param);

                //everPopup.openWindowPopup(url, 700, 600, param);
                everPopup.jusoPop(url, param);

            });

            // 금액관련 콤마 이벤트
            $('input[name*=_AMT]').change(function(e) {
                $(this).number(true);
            });

        });

        function setZipCode(zipcd) {
            if (zipcd.ZIP_CD != "") {
                $('#HQ_ZIP_CD').val(zipcd.ZIP_CD_5 == '' ? zipcd.ZIP_CD : zipcd.ZIP_CD_5);
                $('#HQ_ADDR_1').val(zipcd.ADDR1);
                $('#HQ_ADDR_2').val(zipcd.ADDR2);
                $('#HQ_ADDR_2').focus();
            }
        }

        function userIdCheck() {
            if($('#USER_ID').val() == '') {
                $('#USER_ID').focus();
                return alert("사용자ID를 입력하여 주시기 바랍니다.");
            }

            var url = "/evermp/register/userIdCheck";
            var param = {
                USER_ID: $('#USER_ID').val()
            };
            $.post(url, param, function(data) {
                if(data.responseCode == 'fail') {
                    alert("이미 등록된 사용자 ID 입니다.");
                    $('#USER_ID').val('');
                    $('#USER_ID').focus();
                    changeIdFlag = true;
                } else {
                    alert("사용하실 수 있는 ID 입니다.");
                    changeIdFlag = false;
                }
                return;
            }, "json" );
        }

        function doSGSelect(){

            var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
            var param = {
                callBackFunction: '_setSg',
                'multiYN' : true,
                'ModalPopup' : false,
                'searchYN' : true
            };
            everPopup.openWindowPopup(popupUrl, 500, 600, param, 'sgSelectPopup');
        }

        function doSGDelete() {
            var itemCb = $('input[name=ITEM_CB]');

            if(itemCb.length == '0') {
                return alert("선택된 데이터가 없습니다.");
            }

            $('input[name=ITEM_CB]').each(function(k, v) {
                if(v.checked) {
                    $(v).closest('tr').remove();
                }
            });

            doSGNumber();
        }

        function doSGNumber() {
            $('td[name=NO]').each(function(k, v) {
                $(v).text(k + 1);
            });
        }

        function _setSg(data) {
            var html = "";
            if($('input[id*=SG_NUM]').length > 0) {
                $('input[id*=SG_NUM]').each(function(k, v) {
                    for(var i in data) {
                        if(v.value == data[i].SG_NUM) {
                            data.splice(i, 1);
                        }
                    }
                });
            }

            for(var idx in data) {
                html += "<tr>\n";
                html +=     "<td class='center' name='NO' style='background: #eeeeee;'>"+ (Number(idx) + 1) +"</td>\n";
                html +=     "<td class='center'><input type='checkbox' class='reg_check' name='ITEM_CB' checked></td>\n";
                html +=     "<td style='padding:0 0 0 10px;'><input style='font-size: 14px;' type='text' id='ITEM_CLS_NM_"+ idx +"' name='ITEM_CLS_NM' value='"+ data[idx].ITEM_CLS_NM +"' readonly></td>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_1_"+ idx +"' name='ITEM_CLS1' value='"+ data[idx].ITEM_CLS1 +"'>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_2_"+ idx +"' name='ITEM_CLS2' value='"+ data[idx].ITEM_CLS2 +"'>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_3_"+ idx +"' name='ITEM_CLS3' value='"+ data[idx].ITEM_CLS3 +"'>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_4_"+ idx +"' name='ITEM_CLS4' value='"+ data[idx].ITEM_CLS4 +"'>\n";
                html +=     "<input type='hidden' id='SG_NUM_"+ idx +"' name='SG_NUM' value='"+ data[idx].SG_NUM +"'>\n";
                html += "</tr>\n";
            };

            $('#sgTable tr:eq(0)').after(html);
            doSGNumber();
        }

        function userIdChange() {
            changeIdFlag = true;
        }

        function doSave() {
        	
        	if($('#beingSave').val() == '1') {
        		return alert("회원가입 진행중입니다.");
        	}
			
        	// validation 체크
            var returnFlag = false;
            $('input').closest('dl').find('em').each(function(k, v) {
                if($(v).closest('dl').find('input').val() == '') {
                    var name = $(v).closest('dl').find('input').prop('name');
                    formUtil.animate(name, 'form');
                    returnFlag = true;
                }
            });

            $('select').closest('dl').find('em').each(function(k, v) {
                if($(v).closest('dl').find('select').val() == '') {
                    var name = $(v).closest('dl').find('select').prop('name');
                    formUtil.animate(name, 'form');
                    returnFlag = true;
                }
            });

            // 파일 체크
            $('#filePop').contents().find('.e-required-badge').each(function(k, v) {
            	if($(v).prop('style').length > 0) {
            		var len1 = $(v).prop('style').length;
                    var len2 = $(v).parent().next().find('.qq-upload-file').length;
                    if($(v).parent().next().find('.qq-upload-file').length == 0 && v.style.visibility === 'visible') {
                    //if($(v).parent().next().find('li.plupload_file').length == 0) {
                        $(v).parent().next().find('.plupload_dropbox, .qq-uploader').css('color', '#fff').css('background-color', '#ff988c');
                        setTimeout(function() {
                            $(v).parent().next().find('.plupload_dropbox, .qq-uploader').animate({backgroundColor: "#fff", color: "#333"}, 1000);
                        }, 4000);
                        returnFlag = true;
                    }
                }
            });

            if(returnFlag) {
                return alert("필수 값을 입력하여 주시기 바랍니다.");
            }

            if(changeIdFlag) {
                return alert("사용자 ID 중복체크를 하여 주시기 바랍니다.");
            }

            // 파일 UUID 받아오기
            document.getElementById('filePop').contentWindow.doSave();

            // 데이터 저장
            if(confirm('입력한 정보로 회원가입 하시겠습니까?')) {
            	$('#beingSave').val('1');
                $.post('/evermp/register/doSaveB', $('#form').serialize(), function(data) {
                	$('#beingSave').val('');
                    if(data.responseCode == 'success') {
                        alert("회원가입 요청이 완료되었습니다.\n\n내부검토 승인 후 등록하신 '사용자ID/비밀번호'로 로그인이 가능합니다.");
                        window.close();
                        //location.href = "/welcome";
                    }
                }, "json" );
            }
        }

        function setFileUUID(data) {
            for(var k in data) {
                $('#'+k).val(data[k]);
            }
        }

        function checkAll(e) {
            $('input[name=ITEM_CB]').each(function(k, v) {
                e.checked ? v.checked = true : v.checked = false;
            });
        }

        function fileSearchPop() {
            var popupUrl = "/evermp/register/fileSearchPopB/view";
            var param = {

            };
            everPopup.openWindowPopup(popupUrl, 1000, 370, param, 'fileSearchPop');
        }

        function doTempletDown() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BS01_002A');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                var param = {
                    bizType : 'tmplMng',
                    attFileNum : this.getParameter('attFileNum'),
                    detailView: true,
                    havePermission : false
                };
                var url = '/common/popup/commonFileAttach/view';
                everPopup.openWindowPopup(url, 600,320, param);

            }, false);
        }

        function ppddCheck() {
            if($('#PASSWORD').val() != $('#PASSWORD_CHECK').val()) {
                $('#PASSWORD').val('');
                $('#PASSWORD_CHECK').val('');
                $('#PASSWORD').focus();

                alert("비밀번호가 일치하지 않습니다.");
                return;
            }
        }

        function validTelCellEmail(e, type) {
            var id = e.id;
            var value = $('#'+id).val();

            if(type == 'C' || type == 'T') {
                if(!everString.isTel(value)) {
                    alert("형식이 일치하지 않습니다.");
                    $('#'+id).focus();
                    return;
                }
            } else if(type == 'E') {
                if(!value.match(regExpEMAIL)) {
                    alert("이메일 형식이 일치하지 않습니다.");
                    $('#'+id).focus();
                    return;
                }
            }
        }

        function checkCall(){
            var str = $('#PASSWORD').val();

            if(!chkPwd(str)){
                $('#PASSWORD').val('');
                $('#PASSWORD_CHECK').val('');
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
                alert("비밀번호는 영문, 숫자, 특수문자의 조합으로 8~20자리\n또는 두가지 조합으로 10~20자리 입력해주세요.");
                return false;
            }
            if(str.length > 20){
                alert("비밀번호는 영문, 숫자, 특수문자의 조합으로 8~20자리\n또는 두가지 조합으로 10~20자리 입력해주세요.");
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
                alert("동일문자를 3번 이상 사용할 수 없습니다.");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("연속된 문자열(123 또는 321, abc, cba 등)을 3자 이상 사용 할 수 없습니다.");
                return false;
            }

            return true;
        }

        function IPO_FLAG_Validation() {
            if ($('#IPO_FLAG').val() == 1) {
                $('#IPO_DATE').closest('dl').find('dt').html('<dt>상장일자<em class="check sprite sprite_common">필수입력사항</em></dt>');
            } else {
                $('#IPO_DATE').closest('dl').find('dt').html('<dt>상장일자</dt>');
            }
        }
    </script>
</head>
<body>
<form id="form" name="form">
    <!--wrap-->
    <div class="wrap">
        <!-- 파일 정보 -->
        <input type="hidden" id="ATTACH_FILE_NUM" name="ATTACH_FILE_NUM">
        <input type="hidden" id="ATTACH_FILE1_NUM" name="ATTACH_FILE1_NUM">
        <input type="hidden" id="CI_FILE_NUM" name="CI_FILE_NUM">
        <input type="hidden" id="ATTACH_FILE4_NUM" name="ATTACH_FILE4_NUM">

        <!--content-->
        <div class="contents contents_user contents_registery">
            <div class="registery_step02">
                <section class="step">
                    <h3 class="title title_h_28">고객사 회원가입</h3>
                    <div class="step_bar clearfix">
                        <div><em>STEP 1</em><br>약관동의</div>
                        <span class="sprite sprite_common sprite_next text_out">다음</span>
                        <div class="active"><em>STEP 2</em><br>정보입력</div>
                        <span class="sprite sprite_common sprite_next text_out">다음</span>
                        <div><em>STEP 3</em><br>가입완료</div>
                    </div>
                </section>
                <section>
                    <h3 class="title title_deco_blue_sq"><span class="title_point">타이틀</span>회원정보</h3>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>일반정보</p>
                    <div class="info_box margin_bottom clearfix">
                        <dl>
                            <dt>회사명(국문)<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="CUST_NM" name="CUST_NM" value="">
                            </dd>
                        </dl>
                        <dl>
                            <dt>회사명(영문)</dt>
                            <dd>
                                <input type="text" id="CUST_ENG_NM" name="CUST_ENG_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>사업자번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="number" id="IRS_NUM" name="IRS_NUM" maxlength="10" value="${param.IRS_NUM}" readonly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>사업자구분<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="COMPANY_TYPE" id="COMPANY_TYPE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="reg" items="${regType}">
                                        <option value="${reg.value}">${reg.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>기업구분<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="SCALE_TYPE" id="SCALE_TYPE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="size" items="${businessSize}">
                                        <option value="${size.value}">${size.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>법인구분<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="CORP_TYPE" id="CORP_TYPE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="size" items="${CorpSize}">
                                        <option value="${size.value}">${size.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>법인등록번호</dt>
                            <dd>
                                <input type="text" id="COMPANY_REG_NUM" name="COMPANY_REG_NUM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>거래체결일자</dt>
                            <dd><input type="text" id="DEAL_APRV_DATE" name="DEAL_APRV_DATE"></dd>
                        </dl>
                        <dl class="table_w1020 table_three_box">
                            <dt>본사주소<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd style="height: 79px;">
                                <div class="input_search_box">
                                    <input type="text" class=""  id="HQ_ZIP_CD" name="HQ_ZIP_CD" readonly>
                                    <input type="search" class="input_search">
                                </div>
                                <div class="input_half_box">
                                    <input type="text" class="input_half" id="HQ_ADDR_1" name="HQ_ADDR_1">
                                    <input type="text" class="input_half" id="HQ_ADDR_2" name="HQ_ADDR_2">
                                </div>
                            </dd>
                        </dl>
                        <dl>
                            <dt>업태<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="BUSINESS_TYPE" name="BUSINESS_TYPE"></dd>
                        </dl>
                        <dl>
                            <dt>종목<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="INDUSTRY_TYPE" name="INDUSTRY_TYPE"></dd>
                        </dl>
                        <dl>
                            <dt>대표자명<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="CEO_USER_NM" name="CEO_USER_NM"></dd>
                        </dl>
                        <dl>
                            <dt>종업원수</dt>
                            <dd><input type="text" id="EMPLOYEE_CNT" name="EMPLOYEE_CNT"></dd>
                        </dl>
                        <dl>
                            <dt>설립일자<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="FOUNDATION_DATE" name="FOUNDATION_DATE"></dd>
                        </dl>
                        <dl>
                            <dt>대표전화번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="TEL_NUM" name="TEL_NUM"></dd>
                        </dl>
                        <dl>
                            <dt>대표팩스번호</dt>
                            <dd><input type="text" id="FAX_NUM" name="FAX_NUM" onchange="javascript:validTelCellEmail(this, 'T');" maxlength="12"></dd>
                        </dl>
                        <dl>
                            <dt>대표이메일<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="EMAIL" name="EMAIL" onchange="javascript:validTelCellEmail(this, 'E');"></dd>
                        </dl>
                        <dl>
                            <dt>상장여부</dt>
                            <dd>
                                <select name="IPO_FLAG" id="IPO_FLAG" onchange="IPO_FLAG_Validation();">
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ${yn.value == '0' ? 'selected' : ''}>${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>상장일자</dt>
                            <dd><input type="text" id="IPO_DATE" name="IPO_DATE"></dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>홈페이지주소</dt>
                            <dd>
                                <input type="text" id="HOMEPAGE_URL" name="HOMEPAGE_URL">
                            </dd>
                        </dl>
                    </div>
                    
                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>재무사항</p>
                    <div class="info_box margin_bottom clearfix">
                        <dl>
                            <!-- <dt>기준년도</dt> -->
                            <dt>기준년도</dt>
                            <dd>
                                <select id="STD_YYYY" name="STD_YYYY">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="fi" items="${fiYear}">
                                        <option value="${fi.value}">${fi.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>자료근거</dt>
                            <dd>
                                <select id="DATA_REF_CD" name="DATA_REF_CD">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="ev" items="${evidenceType}">
                                        <option value="${ev.value}">${ev.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총자산</dt>
                            <dd>
                                <input type="text" id="TOT_ASSET" name="TOT_ASSET" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총부채</dt>
                            <dd>
                                <input type="text" id="TOT_SDEPT" name="TOT_SDEPT" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총자본</dt>
                            <dd>
                                <input type="text" id="TOT_FUND" name="TOT_FUND" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총매출액</dt>
                            <dd>
                                <input type="text" id="TOT_SALES" name="TOT_SALES" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>영업이익</dt>
                            <dd>
                                <input type="text" id="BUSINESS_PROFIT" name="BUSINESS_PROFIT" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>당기순이익</dt>
                            <dd>
                                <input type="text" id="NET_INCOM" name="NET_INCOM" numberOnly>
                            </dd>
                        </dl>
                    </div>
                    
                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>제출서류 (첨부가능파일 각 1개)
                        <!--
                        <a href="javascript:fileSearchPop();" class="btn2" style="right: 130px;"><em class="sprite sprite_common"></em>파일팝업</a>
                        <a href="javascript:doTempletDown();" class="btn2"><em class="sprite sprite_common"></em>양식다운로드</a>
                        -->
                    </p>
                    <div class="info_box margin_bottom clearfix">
                        <iframe id="filePop" src="/evermp/register/fileSearchPopB/view" style="width: 1025px; height: 240px;"></iframe>
                        <span style="font-size: 13px;padding-left: 5px;">※ 상기 제출서류의 경우 다운로드 받은 후 작성 및 날인하여 직접 고객사 담당자에게 원본 제출해주시기 바랍니다.</span>
                        <span style="font-size: 11px;">(온라인 회원 가입 시에는 "사업자등록증"에 한해서만 제출)</span>
                    </div>
                    
                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>결제정보</p>
                    <div class="info_box margin_bottom clearfix">
                        <dl>
                            <dt>은행 및 지점명</dt>
                            <dd>
                                <input type="text" id="CUBL_BANK_NM" name="CUBL_BANK_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>예금주</dt>
                            <dd>
                                <input type="text" id="CUBL_ACCOUNT_NM" name="CUBL_ACCOUNT_NM">
                            </dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>계좌번호</dt>
                            <dd>
                                <input type="text" id="CUBL_ACCOUNT_NUM" name="CUBL_ACCOUNT_NUM">
                            </dd>
                        </dl>
                    </div>
                    
                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>사용자(관리자)</p>
                    <div class="info_box margin_bottom clearfix">
                        <dl class="table_have_btn">
                            <dt>사용자 ID<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd class="clearfix">
                                <div><input type="text" id="USER_ID" name="USER_ID" onchange="javascript:userIdChange();"></div>
                                <div class="have_btn"><a href="javascript:userIdCheck();" class="btn btn_no_radius"><em class="icon icon_search sprite sprite_common"></em>중복체크</a></div>
                            </dd>
                        </dl>
                        <dl>
                            <dt>사용자명<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="USER_NM" name="USER_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>비밀번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="password" id="PASSWORD" name="PASSWORD" onchange="javascript:checkCall();">
                            </dd>
                        </dl>
                        <dl>
                            <dt>비밀번호확인<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="password" id="PASSWORD_CHECK" name="PASSWORD_CHECK" onchange="javascript:ppddCheck();">
                            </dd>
                        </dl>
                        <dl>
                            <dt>부서</dt>
                            <dd>
                                <input type="text" id="DEPT_NM" name="DEPT_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>직위(직급)</dt>
                            <dd>
                                <input type="text" id="POSITION_NM" name="POSITION_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>휴대폰번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>직책</dt>
                            <dd>
                                <input type="text" id="DUTY_NM" name="DUTY_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>이메일</dt>
                            <dd>
                                <input type="text" id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" onchange="javascript:validTelCellEmail(this, 'E');">
                            </dd>
                        </dl>
                        <dl>
                            <dt>전화번호</dt>
                            <dd>
                                <input type="text" id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" onchange="javascript:validTelCellEmail(this, 'T');" maxlength="12">
                            </dd>
                        </dl>
                        <dl>
                            <dt>SMS수신여부</dt>
                            <dd>
                                <select name="SMS_FLAG" id="SMS_FLAG">
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ${yn.value eq "1"} ? selected : "">${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>메일수신여부</dt>
                            <dd>
                                <select name="MAIL_FLAG" id="MAIL_FLAG">
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ${yn.value eq "1"} ? selected : "">${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                    </div>
                </section>

                <div class="btn_wrap">
                	<input type="hidden" id="beingSave" name="beingSave">	<!-- 회원가입을 연속으로 2회 이상 클릭할 경우 체크 -->
                    <a href="javascript:doSave();" class="btn btn_no_icon btn_middle">회원가입</a>
                    <a href="javascript:window.close();" class="btn btn_no_icon btn_cancel btn_middle">취소</a>
                    <br><br><br><br>
                </div>
            </div>
        </div>
        <!--// content-->
    </div>
</form>
</body>
</html>