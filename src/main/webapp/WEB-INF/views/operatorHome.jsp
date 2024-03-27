<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:useBean id="everDate" class="com.st_ones.common.util.clazz.EverDate" />
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript" src="../../js/home.js"></script>
    <script type="text/javascript" src="/js/everuxf/lib/jquery.pnotify.min.js"></script>
    <script type="text/javascript" src="/js/ever-alarm.js"></script>
    <script type="text/javascript" src="/js/ever-dwr.js"></script>
    <script type="text/javascript" src="/js/ever-cookie.js"></script>
    <script type="text/javascript" src="/js/ever-popup.js"></script>
    <link rel="stylesheet" href="/css/home.css">
    <link rel="shortcut icon" href="/images/favicon.ico"/>
    <title>(주)카카오페이증권 구매시스템</title>

    <e:window id="e-body" width="100%" height="100%" onReady="init" initData="${initData}" padding="0 0 0 0">
		<div id="contentsBody" class="ui-layout-center" style="width: 100%;">
            <div id="e-main-tab" class="e-main-tab" style="height: 100%; width: 100%;">
                <ul>
                    <li><a href="#ui-tabs-main" title="HOME"></a></li>
                </ul>
                <iframe id="ui-tabs-main" src="/eversrm/mypageBuyer/view" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" style="padding: 0; margin: 0; height: 100%; width: 100%;"></iframe>
            </div>
        </div>
        <div class="ui-layout-west">
        	<div class="ui-layout-center">
        		<div id="logo" style="width: 100%; height: 80px; padding: 23px; cursor: pointer; background-size: 100%;" title="로고" onclick="goHome();">
        			<img src="/images/eversrm/logo/kakao-logo.png" alt="(주)카카오페이증권 로고" style="width:100%; height:100%;">
        		</div>
        		<%--2020.08.31 HMCHOI : 로고 DB에서 가져오는 기능 제외
				<div id="logo" style="height: 63px; width: 99.9%; cursor: pointer; background: url('data:image/${FILE_EXTENSION};base64,${BYTE_ARRAY}') 50% 50% no-repeat; background-size: 60%;" title="로고" onclick="goHome();"></div>
				--%>
        		<div id="line" style="height: 1px; width: 100%; background-color: #d6d6d6;"></div>
                <div style="height: 54px; width: 100%; background-color: #ededed;">
                    <div style="width: 184px; float: left; vertical-align: middle; line-height: 17px; padding: 9px; text-overflow: ellipsis; white-space: nowrap;">
                        <span style="color: #134E80; font-size: 10pt;">&nbsp;&nbsp;${ses.deptNm}</span><br/>
                        <span style="color: #027bc2; font-size: 10pt;">&nbsp;&nbsp;${ses.userNm}&nbsp;${ses.dutyNm}</span>
                    </div>
                    <div style="width: 74px; float: right; position: relative; top: 3px; right: 4px;">
                        <div id="e-btn-myinfo" class="e-session-btn-wrapper" onclick="openUserInfo();">
                            <div class="e-info-icon"></div>
                            <span class="e-session-btn-text-wrapper" title="사용자 정보를 확인하려면 클릭하세요.">My Info</span>
                        </div>
                        <div id="e-btn-logout" class="e-session-btn-wrapper" onclick="logout();">
                            <div class="e-logout-icon"></div>
                            <span class="e-session-btn-text-wrapper" title="로그아웃하시려면 클릭하세요.">Logout</span>
                        </div>
                    </div>
                </div>
                <div id="line" style="height: 1px; width: 100%; background-color: #d6d6d6;"></div>
                <div style="height:100%; margin: 0; padding: 0; overflow:hidden; float: left; width: 100%; position: relative;" >
                    <div style="height:100%; width:74px; float: left; background-color: #58645B;">
	                    <div style="width: 100%; text-align: center; user-select: none;">
	                        <c:forEach items="${topMenu}" var="topMenuList">
                                <div id="${topMenuList.CODE}" class="e-topmenu-wrapper" onclick="fetchLeftMenu('${topMenuList.CODE}')">
                                    <div class="e-topmenu-icon-wrapper" style="background: url(/images/eversrm/leftmenu/${topMenuList.CODE}.png) 0 0"></div>
                                    <div class="e-topmenu-text-wrapper">
                                        <span class="e-topmenu-text" title='${topMenuList.CODE_DESC}'>${topMenuList.CODE_DESC}</span>
                                    </div>
                                </div>
	                        </c:forEach>
	                    </div>
	                </div>
                    <div style="overflow: auto; width: 208px;">
                        <e:treePanel id="leftMenuTree" width="100%" height="100%" onClickNode="openScreenToNewTab" />
                    </div>
                </div>
            </div>
        </div>

	    <script>
	        var oldinnerText = "screenDefault";
	        $(document).ready(function () {
	            $('#e-main-tab').on('dblclick', function (e) {
	            	return;
	                var id = e.target.offsetParent.id.replace('label-', '');

	                if(id != 'e-main-tab' && id != '') {
	                    $('#' + e.target.offsetParent.id).remove();
	                    $('#' + id).remove();
	                    tabs.tabs('refresh');

	                }
	            });

	            $('#e-main-tab').on('click', function (e) {
	                if(oldinnerText == e.target.innerText) {
	                    var id = e.target.offsetParent.id.replace('label-', '');

	                    if(id != 'e-main-tab' && id != '') {
	                        // document.getElementById(id).contentDocument.location.reload(true);
	                    } else {
	                        document.getElementById('ui-tabs-main').contentDocument.location.reload(true);
	                    }
	                }

	                $(e.target).find('a').trigger('click');

	                oldinnerText = e.target.innerText;
	            });
	        });

	        var tabs;
	        var tabLimit = Number('${tabLimit}');

	        $(document).ready(function() {
	            $('#mainIframe', parent.parent.document).css('height', '100vh').css('width', '100%');

	            var layout = EVF.Properties.layout;
	            layout.west.minSize = 282;
	            layout.west.maxSize = 282;
	            $('#e-window-container-body').layout(layout);

	            tabs = $('#e-main-tab').height( ($('.ui-layout-center').height()) ).tabs();

	            $('.e-topmenu-wrapper').click(function(e) {
	                $('.e-topmenu-wrapper').removeClass('e-topmenu-selected');
	                $(this).toggleClass('e-topmenu-selected');
	            });

	            $('.e-topmenu-wrapper').hover(
	                function(e) { $(this).addClass('e-topmenu-hover'); },
	                function(e) { $(this).removeClass('e-topmenu-hover'); }
	            );

	            <%-- 탭버튼에 X 닫기 버튼 --%>
	            tabs.delegate("span.ui-icon-close", "click", function() {
	                var panelId = $(this).closest('li').remove().attr("aria-controls");
	                $('#'+panelId).attr('src', null);
	                $('#'+panelId).remove();
	                tabs.tabs('refresh');
	                if(typeof CollectGarbage == 'function') {
	                    CollectGarbage();
	                }
	            }).css({"cursor":"pointer"});

	            $.contextMenu({
	                selector: '.ui-tabs-nav li',
	                callback: function(key, options) {
	                    switch(key) {
	                        case 'closeOtherTabs':
	                            var thisId = $('a', $(this)).attr('href');
	                            $('#e-main-tab ul li').each(function(index, b) {
	                                var targetTabId = $('a', $(b)).attr('href');
	                                if( !(targetTabId == '#ui-tabs-main' || thisId == targetTabId) ) {
	                                    var tid = targetTabId.replace('#', '');
	                                    $('#e-main-tab ul li[aria-controls='+tid+']').remove();
	                                    $('#e-main-tab iframe[id='+tid+']').attr('src', null).remove();
	                                }
	                            });

	                            $('#e-main-tab').tabs('refresh');
	                            $('#e-main-tab').tabs('option', 'active', 1);

	                            if(typeof CollectGarbage == 'function') {
	                                CollectGarbage();
	                            }

	                            break;
	                        case 'closeAllTabs':
	                            $('#e-main-tab ul li').each(function(index, b) {
	                                var targetTabId = $('a', $(b)).attr('href');
	                                if( targetTabId != '#ui-tabs-main' ) {
	                                    var tid = targetTabId.replace('#', '');
	                                    $('#e-main-tab ul li[aria-controls='+tid+']').remove();
	                                    $('#e-main-tab iframe[id='+tid+']').attr('src', null).remove();
	                                }
	                            });

	                            $('#e-main-tab').tabs('refresh');
	                            $('#e-main-tab').tabs('option', 'active', 0);

	                            if(typeof CollectGarbage == 'function') {
	                                CollectGarbage();
	                            }

	                            break;
	                        case 'popupThisTab':
	                            var $iframe = $($('a', $(this)).attr('href'));
	                            var param = 'height='+(Number($iframe.outerHeight(true))-150)
	                                +',width='+(Number($iframe.outerWidth(true))-150)
	                                +',menubar=no,toolbar=no,status=no,location=no,resizable=yes,scrollbars=yes';
	                            window.open($iframe.attr('src')+"&popupFlag=true", '', param);

	                            break;
	                    }
	                },
	                items: {
	                    'closeOtherTabs': {name: '다른 탭 닫기', icon: 'ui-tab--arrow'},
	                    'closeAllTabs':   {name: '전체 탭 닫기', icon: 'ui-tab--minus'},
	                    'popupThisTab':   {name: '이 탭 팝업하기', icon: 'ui-tab--plus'}
	                }
	            });

	            // superUser 권한 체크
	            if('${ses.superUserFlag}' != '1') {
	                $('#MA').remove();	// 시스템관리 메뉴
	            }

	            if(!EVF.isEmpty('${initDatas}')) {
	                var initDataStr = JSON.parse('${initDatas}');
	                var params = {
	                    gateCd    : "100",
	                    appDocNum : initDataStr[0].appDocNum,
	                    appDocCnt : initDataStr[0].appDocCnt,
	                    docType   : initDataStr[0].docType,
	                    signStatus: initDataStr[0].signStatus,
	                    sendBox	  : false
	                };
	                everPopup.openApprovalOrRejectPopup(params);
	            }

	            resizeComponent();

	            // 채팅 관련 - nodejs 설치 필요(nodejs 폴더의 파일 설치)
	          	// chatStart();

	            //if('${ses.grantedAuthCd}'=='PF0123'){
	            //	alert("연채채권 회수계획을 등록하세요.\n정상로그인은 최종승인 이후에 진행 할 수 있습니다.");
	            //	openScreenToNewTab("TM901295","연채채권 회수계획 등록","/siis/A02/A02_010/view","");
	            //}
	        });

	        function init() {
	            //전화번호, 휴대전화번호, E-Mail
	            <%--var telNum = '${ses.telNum}';--%>
	            <%--var cellNum = '${ses.cellNum}';--%>
	            <%--var email = '${ses.email}';--%>

	            <%--var message = '';--%>

	            <%--message += '${ses.userNm} 님!\n';--%>

	            <%--if (telNum == '') {--%>
	                <%--message += '전화번호\n';--%>
	            <%--}--%>
	            <%--if (cellNum == '') {--%>
	                <%--message += '휴대전화번호\n';--%>
	            <%--}--%>
	            <%--if (email == '') {--%>
	                <%--message += 'E-Mail\n';--%>
	            <%--}--%>
	            <%--message += '정보가 존재하지 않습니다. 사용자 정보를 변경해 주십시오.';--%>

	            <%--if (telNum == '' || cellNum == '' || email == '') {--%>
	                <%--alert(message);--%>
	                <%--openUserInfo();--%>
	            <%--}--%>

	            <c:forEach var="noticePopup" items="${noticeListPopup}">
	                noticeCookieCheck('${noticePopup.NOTICE_NUM }', 'loginPopupNotice');
	            </c:forEach>

	            initHome('${topMenu[0].MAIN_MODULE_TYPE}');
	        }

	        function noticeCookieCheck(noticeNum, loginPopupNotice) {
	            var blnCookie = cookie.getCookie('div_laypopup' + noticeNum);
	            if (!blnCookie) {
	                openNotice(noticeNum, loginPopupNotice);
	            }
	        }


	        <%-- 창닫기 --%>
	        function closeWinAt00(winName, expiredays) {
	            cookie.setCookie(winName, "done", expiredays);
	        }

	        function openNotice(noticeNum, loginPopupNotice) {
	            var url = "/eversrm/board/notice/BBON_010/view";
	            var param = {
	                NOTICE_NUM: noticeNum,
	                popupFlag: true,
	                detailView: true,
	                loginPopupNotice: loginPopupNotice
	            };

	            everPopup.openWindowPopup(url, 1100, 670, param, 'NOTICE' + noticeNum);
	        }

	        function logout() {
	            if (confirm('${msg.M0039}')) {
	                var store = new EVF.Store();
	                store.setParameter("userId", "${ses.userId }");
	                store.setParameter("userName", "${ses.userNm }");
	                store.load('/logout', function() {

	                    alert(this.getResponseMessage());
	                    location.href = this.getParameter('locationAfterLoggedOut');
	                });
	            }
	        }

	        function goHome() {

	            if ('${everSslUseFlag}'=='true') {
	                location.href="/home";
	            } else {
	                location.href="/home";
	            }
	        }

	        function openUserInfo() {
	            var param = {};
	            if ('${everSslUseFlag}'=='true') {
	                window.open('${realDomainUrl}'+'/eversrm/main/userInfoChange/view.so?popupFlag=true',"사용자정보", "width=700,height=400,scrollbars=yes,resizeable=no,left=150,top=150");
	            } else {
	                var url = '/eversrm/main/userInfoChange/view.so?popupFlag=true';
	                everPopup.openWindowPopup(url, 700, 360, null,'openUserInfo');
	            }
	        }

	        function openScreenToNewTab(id, text, value, e, data) {

	        	//alert(id + ',' + text + ',' + value + ',' + e + ',' + data);
	            if ($('#ui-tabs-' + id).length > 0) {
	                if( data ) {
	                    $('#ui-tabs-label-' + id).remove();
	                    $('#ui-tabs-' + id).remove();
	                    $('#e-main-tab').tabs('refresh');
	                } else {
	                    return $('#e-main-tab').tabs('option', 'active', $('li#ui-tabs-label-'+id).index());
	                }
	            }

	            if ($('#e-main-tab li').length > tabLimit) {
	                var title = $('#e-main-tab ul li').eq(1).prop('title');
	                if(confirm('탭의 제한수['+tabLimit+'개]가 초과되었습니다.\n\n['+title+'] 탭을 닫고 선택하신 화면을 여시겠습니까?')) {
	                    $('#e-main-tab ul li').eq(1).remove();
	                    $('#e-main-tab iframe').eq(1).attr('src', null).remove();
	                } else {
	                    return;
	                }
	            }

	            // Parameter 처리
	            var param = '';
	            if( data ) {
	                for(var i in data) {
	                    param += "&" + i + "=" + encodeURIComponent(data[i]);
	                }
	            }

	            var store = new EVF.Store();
	            store.setParameter('tmpl_menu_cd', id);
	            store.setParameter('moduleName', value);
	            store.setParameter('jobDesc', text);
	            store.setParameter('methodName', "menuClick");
	            store.setParameter('actionCode', "menuClick");
	            store.load('/common/util/' + 'menuClickSave', function () {

	                if(this.getResponseCode() == '1') {

	                    var screenName = encodeURIComponent(text);
	                    var $tabLabel = $('<li id="ui-tabs-label-' + id + '" name='+text+' title="' + text + '"><a href="#ui-tabs-' + id + '" style="width: 80px; padding-right: 0px;">' + text + '</a> <span class="ui-icon ui-icon-close" role="presentation">X</span></li>').hide();
	                    $('#e-main-tab ul').append($tabLabel);
	                    $tabLabel.slideDown('fast');

	                    var $iframes = $('#e-main-tab iframe');

	                    if (value.indexOf('?') > -1 ) {
	                        $('#e-main-tab').append($('<iframe id="ui-tabs-' + id + '" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" src="' + value + '&tmpl_menu_cd=' + id + '&detailView=false&screen_name=' + screenName + param +'" style="padding: 0; margin: 0; height: 100%;"></iframe>'));
	                    } else {
	                        $('#e-main-tab').append($('<iframe id="ui-tabs-' + id + '" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0" width="100%" height="100%" src="' + value + '?tmpl_menu_cd=' + id + '&detailView=false&screen_name=' + screenName + param +'" style="padding: 0; margin: 0; height: 100%;"></iframe>'));
	                    }


	                    $('#e-main-tab').tabs('refresh');
	                    var $tabs = $('#e-main-tab').tabs('option', 'active', ($('#e-main-tab > ul > li').length - 1));
	                    $tabs.find(".ui-tabs-nav").sortable({
	                        axis: "x",
	                        stop: function() {
	                            $tabs.tabs( "refresh" );
	                        }
	                    });

	                    resizeComponent();
	                }
	            }, false);
	        }

	        function openAPI() {
	            window.open('/docs/frontend', 'everuxf_api', '', '_blank')
	        }

	    </script>
    </e:window>
</e:ui>