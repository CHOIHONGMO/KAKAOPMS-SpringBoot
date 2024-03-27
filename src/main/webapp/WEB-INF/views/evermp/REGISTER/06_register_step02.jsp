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
	<style>
		.center {
            text-align: center;
        }
    </style>
    <script>
        var changeIdFlag = true;
        
        // 반려된 공급사 수정 화면
        <c:if test="${form.USER_INSERT_FLAG != 'Y'}">
        	changeIdFlag = false;
        </c:if>
        
        var regExpEMAIL = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i;
        var regExpTEL_NUM = /^\d{2,3}-\d{3,4}-\d{4}$/;
        var regExpCELL_NUM = /^\d{3}-\d{3,4}-\d{4}$/;
        var pop = null;

        $(document).ready(function() {
            // $('#mainIframe', parent.document).css('height', '3000px');

            $( "#FOUNDATION_DATE, #IPO_DATE" ).datepicker({
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

            $("#E_BILL_ASP_TYPE option[value='0']").remove();
            $("#E_BILL_ASP_TYPE option[value='3']").remove();

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
                html +=     "<td style='padding:0 0 0 10px;'><input style='font-size: 14px;' type='text' id='SG_NUM_"+ idx +"' name='SG_NUM' value='"+ data[idx].SG_NUM +"' readonly></td>\n";
                html +=     "<td style='padding:0 0 0 10px;'><input style='font-size: 14px;' type='text' id='ITEM_CLS_NM_"+ idx +"' name='ITEM_CLS_NM' value='"+ data[idx].ITEM_CLS_NM +"' readonly></td>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_1_"+ idx +"' name='ITEM_CLS1' value='"+ data[idx].ITEM_CLS1 +"'>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_2_"+ idx +"' name='ITEM_CLS2' value='"+ data[idx].ITEM_CLS2 +"'>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_3_"+ idx +"' name='ITEM_CLS3' value='"+ data[idx].ITEM_CLS3 +"'>\n";
                html +=     "<input type='hidden' id='ITEM_CLS_4_"+ idx +"' name='ITEM_CLS4' value='"+ data[idx].ITEM_CLS4 +"'>\n";
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

            if($('input[id*=SG_NUM]').length == 0) {
                $('#SGSelect').focus();
                alert("취급분야를 1개 이상 선택하여 주시기 바랍니다.");
                return;
            } else {
                $('input[name=ITEM_CB]').each(function(k, v) {
                    v.checked = true;
                });
            }

            if(changeIdFlag) {
                return alert("사용자 ID 중복체크를 하여 주시기 바랍니다.");
            }

            // 파일 UUID 받아오기
            document.getElementById('filePop').contentWindow.doSave();

            // 데이터 저장
            if(confirm('입력한 정보로 회원가입 하시겠습니까?')) {
            	$('#beingSave').val('1');
                $.post('/evermp/register/doSave', $('#form').serialize(), function(data) {
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
            var popupUrl = "/evermp/register/fileSearchPop/view";
            var param = {

            };
            everPopup.openWindowPopup(popupUrl, 1000, 370, param, 'fileSearchPop');
        }

        function doTempletDown() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BS03_002');
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
            if($('#PPDD').val() != $('#PPDD_CHECK').val()) {
                $('#PPDD').val('');
                $('#PPDD_CHECK').val('');
                $('#PPDD').focus();

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
            var str = $('#PPDD').val();

            if(!chkPwd(str)){
                $('#PPDD').val('');
                $('#PPDD_CHECK').val('');
                $('#PPDD').focus();
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
    	<!-- 반려시 수정을 취한 값 -->
       	<input type="hidden" id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}">	<!-- 협력사코드 -->
		<input type="hidden" id="USER_INSERT_FLAG" name="USER_INSERT_FLAG" value="${form.USER_INSERT_FLAG}">	<!-- 사용자 추가여부 -->

        <!-- 파일 정보 -->
        <input type="hidden" id="BASIC_ATT_FILE_NUM" name="BASIC_ATT_FILE_NUM">
        <input type="hidden" id="BIZ_ATT_FILE_NUM" name="BIZ_ATT_FILE_NUM">
        <input type="hidden" id="ID_ATT_FILE_NUM" name="ID_ATT_FILE_NUM">
        <input type="hidden" id="PRICE_ATT_FILE_NUM" name="PRICE_ATT_FILE_NUM">
        <input type="hidden" id="CERTIFI_ATT_FILE_NUM" name="CERTIFI_ATT_FILE_NUM">
        <input type="hidden" id="BANKBOOK_ATT_FILE_NUM" name="BANKBOOK_ATT_FILE_NUM">
        <input type="hidden" id="SIGN_ATT_FILE_NUM" name="SIGN_ATT_FILE_NUM">
        <input type="hidden" id="CONTRACT_ATT_FILE_NUM" name="CONTRACT_ATT_FILE_NUM">
        <input type="hidden" id="SECRET_ATT_FILE_NUM" name="SECRET_ATT_FILE_NUM">
        <input type="hidden" id="IMGAGREE_ATT_FILE_NUM" name="IMGAGREE_ATT_FILE_NUM">
        <input type="hidden" id="ATTACH_FILE_NO" name="ATTACH_FILE_NO">

        <!--content-->
        <div class="contents contents_user contents_registery">
            <div class="registery_step02">
                <section class="step">
                    <h3 class="title title_h_28">공급사 회원가입</h3>
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
                                <input type="text" id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>회사명(영문)</dt>
                            <dd>
                                <input type="text" id="VENDOR_ENG_NM" name="VENDOR_ENG_NM" value="${form.VENDOR_ENG_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>사업자번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="number" id="IRS_NO" name="IRS_NO" maxlength="10" value="${param.IRS_NUM}" readonly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>사업자구분<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="REG_TYPE" id="REG_TYPE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="reg" items="${regType}">
                                        <option value="${reg.value}" ${reg.value eq form.REG_TYPE ? "selected" : ""}>${reg.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl class="table_w1020 table_three_box">
                            <dt>본사주소<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd style="height: 79px;">
                                <div class="input_search_box">
                                    <input type="text" class="input_half" id="HQ_ZIP_CD" name="HQ_ZIP_CD" value="${form.HQ_ZIP_CD}" readonly>
                                    <input type="search" class="input_search">
                                </div>
                                <div class="input_half_box">
                                    <input type="text" class="input_half" id="HQ_ADDR_1" name="HQ_ADDR_1" value="${form.HQ_ADDR_1}">
                                    <input type="text" class="input_half" id="HQ_ADDR_2" name="HQ_ADDR_2" value="${form.HQ_ADDR_2}">
                                </div>
                            </dd>
                        </dl>
                        <dl>
                            <dt>업태<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="${form.BUSINESS_TYPE}"></dd>
                        </dl>
                        <dl>
                            <dt>종목<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="INDUSTRY_TYPE" name="INDUSTRY_TYPE" value="${form.INDUSTRY_TYPE}"></dd>
                        </dl>
                        <dl>
                            <dt>대표자명<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="CEO_USER_NM" name="CEO_USER_NM" value="${form.CEO_USER_NM}"></dd>
                        </dl>
                        <dl>
                            <dt>설립일자<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="FOUNDATION_DATE" name="FOUNDATION_DATE" value="${form.FOUNDATION_DATE_HOMEPAGE}"></dd>
                        </dl>
                        <dl>
                            <dt>대표전화번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="TEL_NO" name="TEL_NO" value="${form.TEL_NO}"></dd>
                        </dl>
                        <dl>
                            <dt>대표팩스번호</dt>
                            <dd><input type="text" id="FAX_NO" name="FAX_NO" value="${form.FAX_NO}" onchange="javascript:validTelCellEmail(this, 'T');" maxlength="12"></dd>
                        </dl>
                        <dl>
                            <dt>대표이메일<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd><input type="text" id="EMAIL" name="EMAIL" value="${form.EMAIL}" onchange="javascript:validTelCellEmail(this, 'E');"></dd>
                        </dl>
                        <dl>
                            <dt>기업규모<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="BUSINESS_SIZE" id="BUSINESS_SIZE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="size" items="${businessSize}">
                                        <option value="${size.value}" ${size.value eq form.BUSINESS_SIZE ? "selected" : ""}>${size.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>홈페이지주소</dt>
                            <dd>
                                <input type="text" id="HOMEPAGE_URL" name="HOMEPAGE_URL" value="${form.HOMEPAGE_URL}">
                            </dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>기업구분<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <c:forEach var="blist" items="${businessList}" varStatus="vs">
                                    <input type="checkbox" class="reg_check" id="BUSINESS_DIVISION_${blist.value}" name="BUSINESS_DIVISION" value="${blist.value}" ${blist.value eq form.BUSINESS_DIVISION ? "checked" : ""}>
                                    <label for="BUSINESS_DIVISION_${blist.value}">${blist.text}</label>
                                    <c:if test="${(vs.index+1) % 9 == 0}">
                                        <br>
                                    </c:if>
                                </c:forEach>
                            </dd>
                        </dl>
                        <dl>
                            <dt>상장여부<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="IPO_FLAG" id="IPO_FLAG" onchange="IPO_FLAG_Validation();">
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ${yn.value eq form.BUSINESS_SIZE ? "selected" : ""}>${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>유통레벨<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="DELIVERY_LEVEL" id="DELIVERY_LEVEL">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="level" items="${deliveryLevel}">
                                        <option value="${level.value}" ${level.value eq form.DELIVERY_LEVEL ? "selected" : ""}>${level.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>상장일자</dt>
                            <dd><input type="text" id="IPO_DATE" name="IPO_DATE" value="${form.IPO_DATE_HOMEPAGE}"></dd>
                        </dl>
                        <dl>
                            <dt>신용평가사</dt>
                            <dd>
                                <input type="text" name="CREDIT_EVAL_COMPANY" id="CREDIT_EVAL_COMPANY" value="${form.CREDIT_EVAL_COMPANY}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>신용등급</dt>
                            <dd>
                                <input type="text" name="CREDIT_CD" id="CREDIT_CD" value="${form.CREDIT_CD}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>주요배송수단</dt>
                            <dd>
                                <c:forEach var="deli" items="${deliberyType}" varStatus="vs">
                                    <input type="checkbox" class="reg_check" id="DELIVERY_TYPE_${deli.value}" name="DELIVERY_TYPE" value="${deli.value}" ${deli.value eq form.DELIVERY_TYPE ? "checked" : ""}>
                                    <label for="DELIVERY_TYPE_${deli.value}">${deli.text}</label>
                                    <c:if test="${(vs.index+1) % 9 == 0}">
                                        <br>
                                    </c:if>
                                </c:forEach>
                            </dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>납품가능지역</dt>
                            <dd>
                                <c:forEach var="item" items="${regionCd}" varStatus="vs">
                                    <input type="checkbox" class="reg_check" id="REGION_CD_${item.value}" name="REGION_CD" value="${item.value}" ${item.value eq form.REGION_CD ? "checked" : ""}>
                                    <label for="REGION_CD_${item.value}">${item.text}</label>
                                    <c:if test="${(vs.index+1) % 9 == 0}">
                                        <br>
                                    </c:if>
                                </c:forEach>
                            </dd>
                        </dl>
                        <dl>
                            <dt>과세구분<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="TAX_TYPE" id="TAX_TYPE">
                                    <c:forEach var="tax" items="${taxType}">
                                        <option value="${tax.value}" ${tax.value eq form.TAX_TYPE ? "selected" : ""}>${tax.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>ISO여부</dt>
                            <dd>
                                <select name="IOS_TYPE" id="IOS_TYPE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="ios" items="${iosType}">
                                        <option value="${ios.value}" ${ios.value eq form.IOS_TYPE ? "selected" : ""}>${ios.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>주요고객사/거래처</dt>
                            <dd>
                                <input type="text" name="MAJOR_CUSTOMERS" id="MAJOR_CUSTOMERS" value="${form.MAJOR_CUSTOMERS}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>주요취급상품<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" name="MAJOR_ITEM_NM" id="MAJOR_ITEM_NM" value="${form.MAJOR_ITEM_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>취급브랜드<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" name="MAKER_NM" id="MAKER_NM" value="${form.MAKER_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>계산서발행구분</dt>
                            <dd>
                                <select name="E_BILL_ASP_TYPE" id="E_BILL_ASP_TYPE">
                                    <c:forEach var="e" items="${eBillAspType}">
                                        <option value="${e.value}" ${e.value eq form.E_BILL_ASP_TYPE ? "selected" : ""}>${e.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>특허여부</dt>
                            <dd>
                                <select name="LICENSE_YN" id="LICENSE_YN">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ${yn.value eq form.LICENSE_YN ? "selected" : ""}>${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>계산서발행사이트</dt>
                            <dd>
                            	<input type="text" name="TAX_ASP_NM" id="TAX_ASP_NM" value="${form.TAX_ASP_NM}">
                            </dd>
                        </dl>
                        <dl class="table_w1020 table_three_box">
                            <dt>회사소개</dt>
                            <dd style="height: 79px;">
                                <div>
                                	<textarea style="width: 811px; height: 78px;" id="BUSINESS_REMARK" name="BUSINESS_REMARK">${form.BUSINESS_REMARK}</textarea>
                                </div>
                            </dd>
                        </dl>
	                    <dl class="table_w1020">
	                        <dt>실적1</dt>
	                        <dd>
	                            <input type="text" name="MAJOR_PERFORM" id="MAJOR_PERFORM" value="${form.MAJOR_PERFORM}">
	                        </dd>
	                    </dl>
	                    <dl class="table_w1020">
	                        <dt>실적2</dt>
	                        <dd>
	                            <input type="text" name="MAJOR_PERFORM1" id="MAJOR_PERFORM1" value="${form.MAJOR_PERFORM1}">
	                        </dd>
	                    </dl>
	                    <dl class="table_w1020">
	                        <dt>실적3</dt>
	                        <dd>
	                            <input type="text" name="MAJOR_PERFORM2" id="MAJOR_PERFORM2" value="${form.MAJOR_PERFORM2}">
	                        </dd>
	                    </dl>
	                    <dl class="table_w1020">
	                        <dt>실적4</dt>
	                        <dd>
	                            <input type="text" name="MAJOR_PERFORM3" id="MAJOR_PERFORM3" value="${form.MAJOR_PERFORM3}">
	                        </dd>
	                    </dl>
	                    <dl class="table_w1020">
	                        <dt>실적5</dt>
	                        <dd>
	                            <input type="text" name="MAJOR_PERFORM4" id="MAJOR_PERFORM4" value="${form.MAJOR_PERFORM4}">
	                        </dd>
	                    </dl>
	                    <dl class="table_w1020 table_three_box">
	                        <dt>특이사항</dt>
	                        <dd style="height: 79px;">
	                            <div>
	                                <textarea style="width: 811px; height: 78px;" id="REMARK_TEXT" name="REMARK_TEXT">${form.REMARK_TEXT}</textarea>
	                            </div>
	                        </dd>
	                    </dl>
                    </div>
					
					<br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>취급분야
                        <a href="javascript:doSGSelect();" id="SGSelect" class="btn2" style="right: 100px;"><em class="sprite sprite_common"></em>S/G선택</a>
                        <a href="javascript:doSGDelete();" class="btn2"><em class="sprite sprite_common"></em>S/G삭제</a>
                    </p>
                    <div class="info_box margin_bottom clearfix">
                        <table id="sgTable" style="width: 100%; line-height: 30px; font-size: 14px; color: #606060;">
                            <colgroup>
                                <col class="center" width="30">
                                <col class="center" width="30">
                                <col width="*">
                            </colgroup>
                            <tr>
                                <th></th>
                                <th><input type="checkbox" class="reg_check" onclick="checkAll(this);"></th>
                                <th>취급분야코드</th>
                                <th>취급분야명</th>
                            </tr>
                            <tr></tr>
					<c:if test="${sgList != null || sgList.size() > 0}">
						<c:forEach items="${sgList}" var="sgData">
							<tr>
								<td class="center" name="NO" style="background: #eeeeee;">${sgData.SEQ}</td>
								<td class="center">
									<input type="checkbox" class="reg_check" name="ITEM_CB" checked>
								</td>
								<td style="padding:0 0 0 10px;">
									<input style="font-size: 14px;" type="text" id="SG_NUM_${sgData.SEQ}" name="SG_NUM" value="${sgData.SG_NUM}" readonly>
								</td>
								<td style="padding:0 0 0 10px;">
									<input style="font-size: 14px;" type="text" id="ITEM_CLS_NM_${sgData.SEQ}" name="ITEM_CLS_NM" value="${sgData.CLS_PATH_NM}" readonly>
								</td>
								<input type="hidden" id="ITEM_CLS_1_${sgData.SEQ}" name="ITEM_CLS1" value="${sgData.CLS1}">
								<input type="hidden" id="ITEM_CLS_2_${sgData.SEQ}" name="ITEM_CLS2" value="${sgData.CLS2}">
								<input type="hidden" id="ITEM_CLS_3_${sgData.SEQ}" name="ITEM_CLS3" value="${sgData.CLS3}">
								<input type="hidden" id="ITEM_CLS_4_${sgData.SEQ}" name="ITEM_CLS4" value="${sgData.CLS4}">
							</tr>
				        </c:forEach>
					</c:if>
                        </table>
                    </div>
					
                    <%--
                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>재무사항 <span style="font-size: 13px; padding-left: 920px;">[단위 : 백만원]</span></p>
                    <div class="info_box margin_bottom clearfix">
                        <dl>
                            <!-- <dt>기준년도</dt> -->
                            <dt>기준년도<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select id="FI_YEAR" name="FI_YEAR">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="fi" items="${fiYear}">
                                        <option value="${fi.value}" ${fi.value eq form.FI_YEAR ? "selected" : ""}>${fi.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>자료근거</dt>
                            <dd>
                                <select id="EVIDENCE_TYPE" name="EVIDENCE_TYPE">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="ev" items="${evidenceType}">
                                        <option value="${ev.value}" ${ev.value eq form.EVIDENCE_TYPE ? "selected" : ""}>${ev.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총자산</dt>
                            <dd>
                                <input type="text" id="TOT_CAP_AMT" name="TOT_CAP_AMT" value="${form.TOT_CAP_AMT}" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총부채</dt>
                            <dd>
                                <input type="text" id="TOT_LIAB_AMT" name="TOT_LIAB_AMT" value="${form.TOT_LIAB_AMT}" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>총자본</dt>
                            <dd>
                                <input type="text" id="TOT_FUND_AMT" name="TOT_FUND_AMT" value="${form.TOT_FUND_AMT}" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>매출액</dt>
                            <dd>
                                <input type="text" id="SALES_AMT" name="SALES_AMT" value="${form.SALES_AMT}" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>영업이익</dt>
                            <dd>
                                <input type="text" id="SALES_PROF_AMT" name="SALES_PROF_AMT" value="${form.SALES_PROF_AMT}" numberOnly>
                            </dd>
                        </dl>
                        <dl>
                            <dt>당기순이익</dt>
                            <dd>
                                <input type="text" id="ORI_SALES_AMT" name="ORI_SALES_AMT" value="${form.ORI_SALES_AMT}" numberOnly>
                            </dd>
                        </dl>
                    </div>
                    --%>
                    
					<br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>제출서류 (첨부가능파일 각 1개)
                        <a href="javascript:doTempletDown();" class="btn2"><em class="sprite sprite_common"></em>결제계좌신청서 양식다운로드</a>
                    </p>
                    <div class="info_box margin_bottom clearfix">
                        <iframe id="filePop" src="/evermp/register/fileSearchPop/view.so?VENDOR_CD=${form.VENDOR_CD}" style="width: 1025px; height: 290px;"></iframe>
                        <span style="font-size: 13px;padding-left: 5px;">※ 상기 제출서류의 경우 다운로드 받은 후 작성 및 날인하여 직접 공급사 담당자에게 원본 제출해주시기 바랍니다.</span>
                        <span style="font-size: 11px;">(온라인 회원 가입 시에는 "사업자등록증"에 한해서만 제출)</span>
                    </div>
                    
                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>결제정보</p>
                    <div class="info_box margin_bottom clearfix">
                       <%--
                        <dl>
                            <dt>정산담당자<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="PAY_MANAGE_USER_NM" name="PAY_MANAGE_USER_NM">
                            </dd>
                        </dl>
                        <dl>
                            <dt>연락처<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="PAY_MANAGE_TEL_NO" name="PAY_MANAGE_TEL_NO">
                            </dd>
                        </dl>
                        --%>
                        <dl>
                            <dt>은행 및 지점명<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="PAY_BANK_CD" id="PAY_BANK_CD">
                                    <option value="">----------------------------------------</option>
                                    <c:forEach var="bc" items="${bcFlag}">
                                        <option value="${bc.value}" ${bc.value eq form.PAY_BANK_CD ? "selected" : ""}>${bc.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <%--
                        <dl>
                            <dt>E-MAIL<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="PAY_MANAGE_EMAIL" name="PAY_MANAGE_EMAIL" onchange="javascript:validTelCellEmail(this, 'E');">
                            </dd>
                        </dl>
                        --%>
                        <dl>
                            <dt>예금주<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="PAY_ACCOUNT_USER_NM" name="PAY_ACCOUNT_USER_NM" value="${form.PAY_ACCOUNT_USER_NM}">
                            </dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>계좌번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="PAY_ACCOUNT_NO" name="PAY_ACCOUNT_NO" value="${form.PAY_ACCOUNT_NO}">
                            </dd>
                        </dl>
                    </div>

                    <br>
                    <p class="title_arrow"><span class="sprite sprite_common sprite_arrow_blue"></span>사용자(관리자)</p>
                    <div class="info_box margin_bottom clearfix">
                        <dl class="table_have_btn">
                            <dt>사용자 ID<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd class="clearfix">
                                <div>
                                	<input type="text" id="USER_ID" name="USER_ID" value="${form.USER_ID}" ${(form.USER_INSERT_FLAG != null && form.USER_INSERT_FLAG != 'Y') ? "readonly" : ""} onchange="javascript:userIdChange();">
                                </div>
                                <c:if test="${form.USER_INSERT_FLAG == null || form.USER_INSERT_FLAG == 'Y'}">
                                	<div class="have_btn"><a href="#" onclick="javascript:userIdCheck(); return false;" class="btn btn_no_radius"><em class="icon icon_search sprite sprite_common"></em>중복체크</a></div>
                                </c:if>
                            </dd>
                        </dl>
                        <dl>
                            <dt>사용자명<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="USER_NM" name="USER_NM" value="${form.USER_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>비밀번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="password" id="PPDD" name="PPDD" value="${form.PASSWORD}" onchange="javascript:checkCall();">
                            </dd>
                        </dl>
                        <dl>
                            <dt>비밀번호확인<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="password" id="PPDD_CHECK" name="PPDD_CHECK" value="${form.PASSWORD_CHECK}" onchange="javascript:ppddCheck();">
                            </dd>
                        </dl>
                        <dl>
                            <dt>부서</dt>
                            <dd>
                                <input type="text" id="DEPT_NM" name="DEPT_NM" value="${form.DEPT_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>직위(직급)</dt>
                            <dd>
                                <input type="text" id="POSITION_NM" name="POSITION_NM" value="${form.POSITION_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>휴대전화<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="CELL_NUM" name="CELL_NUM" value="${form.CELL_NUM}" onchange="javascript:validTelCellEmail(this, 'C');" maxlength="13">
                            </dd>
                        </dl>
                        <dl>
                            <dt>직책</dt>
                            <dd>
                                <input type="text" id="DUTY_NM" name="DUTY_NM" value="${form.DUTY_NM}">
                            </dd>
                        </dl>
                        <dl>
                            <dt>이메일<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="USER_EMAIL" name="USER_EMAIL" value="${form.USER_EMAIL}" onchange="javascript:validTelCellEmail(this, 'E');">
                            </dd>
                        </dl>
                        <dl>
                            <dt>전화번호<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <input type="text" id="TEL_NUM" name="TEL_NUM" value="${form.TEL_NUM}" onchange="javascript:validTelCellEmail(this, 'T');" maxlength="12">
                            </dd>
                        </dl>
                        <dl>
                            <dt>SMS수신여부<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="SMS_FLAG" id="SMS_FLAG">
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ${yn.value eq form.SMS_FLAG ? "selected" : ""}>${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl>
                            <dt>메일수신여부<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <select name="MAIL_FLAG" id="MAIL_FLAG">
                                    <c:forEach var="yn" items="${ynFlag}">
                                        <option value="${yn.value}" ("${yn.value eq form.MAIL_FLAG ? "selected" : ""}>${yn.text}</option>
                                    </c:forEach>
                                </select>
                            </dd>
                        </dl>
                        <dl class="table_w1020">
                            <dt>관리자 주업무<em class="check sprite sprite_common">필수입력사항</em></dt>
                            <dd>
                                <c:forEach var="rold" items="${RoleList}" varStatus="vs">
                                    <input type="checkbox" class="reg_check" id="VNGL_ROLE_${rold.value}" name="VNGL_ROLE" value="${rold.value}" ${rold.value eq form.VNGL_ROLE ? "checked" : ""}>
                                    <label for="VNGL_ROLE_${rold.value}">${rold.text}</label>
                                    <c:if test="${(vs.index+1) % 9 == 0}">
                                        <br>
                                    </c:if>
                                </c:forEach>
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
    </div>
</form>
</body>
</html>