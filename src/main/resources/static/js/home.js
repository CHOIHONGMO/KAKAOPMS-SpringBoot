/**
 * @User: Azure
 * @CreateDate: 13. 10. 18 오후 3:34
 */
var homeJs = {};

/**
 * 로그인한 사용자에게 웹사이트 사용 주의사항 알림창을 띄웁니다.
 */
homeJs.warningUser = function (ip, datetime) {

    var message;
    var browser = this.getBrowser();
    var browserVersion = this.getBrowserVersion();

    var Browser = {
        ie: navigator.userAgent.toLowerCase().indexOf("msie") != -1,
        ie7: navigator.userAgent.toLowerCase().indexOf("msie 7") != -1,
        ie8: navigator.userAgent.toLowerCase().indexOf("msie 8") != -1,
        ie9: navigator.userAgent.toLowerCase().indexOf("msie 9") != -1,
        ie10: navigator.userAgent.toLowerCase().indexOf("msie 10") != -1,
        ie11: (browser === "Trident" && browserVersion === "7.0"),
        opera: !!window.opera,
        safari: navigator.userAgent.toLowerCase().indexOf("safari") != -1,
        safari3: navigator.userAgent.toLowerCase().indexOf("applewebkir/5") != -1,
        mac: navigator.userAgent.toLowerCase().indexOf("mac") != -1,
        chrome: navigator.userAgent.toLowerCase().indexOf("chrome") != -1,
        firefox: navigator.userAgent.toLowerCase().indexOf("firefox") != -1
    };

    message = " * 접속 IP      : " + ip + "\n\n";
    message += " * 접속 Browser : ";
    if ((Browser.ie || Browser.ie11)) {
        message += "Microsoft Internet Explorer";
    } else if (Browser.chrome) {
        message += "Google Chrome";
    } else if (Browser.firefox) {
        message += "Firefox";
    } else if (Browser.opera) {
        message += "Opera";
    } else if (Browser.safari) {
        message += "Safari";
    } else if (Browser.safari3) {
        message += "Safari3";
    } else if (Browser.mac) {
        message += "MAC";
    } else {
        message += "Other";
    }

    message += "\n\n";
    message += " * 접속시간     : " + datetime + "\n\n";
    message += "임직원을 위한 시스템으로 인가된 분만\n\n사용할 수 있습니다.\n\n";
    message += "불법 사용시 법적 제재를 받을 수 있습니다.";

    //alert(message);
};

homeJs.getBrowser = function () {
    var N = navigator.appName, ua = navigator.userAgent, tem;
    var M = ua.match(/(opera|chrome|safari|firefox|msie|trident)\/?\s*(\.?\d+(\.\d+)*)/i);

    if (M && (tem = ua.match(/version\/([\.\d]+)/i)) != null) M[2] = tem[1];
    M = M ? [M[1], M[2]] : [N, navigator.appVersion, "-?"];

    return M[0];
};

//Optional to get browser version, not needed in this case
homeJs.getBrowserVersion = function () {
    var N = navigator.appName, ua = navigator.userAgent, tem;
    var M = ua.match(/(opera|chrome|safari|firefox|msie|trident)\/?\s*(\.?\d+(\.\d+)*)/i);

    if (M && (tem = ua.match(/version\/([\.\d]+)/i)) != null) M[2] = tem[1];
    M = M ? [M[1], M[2]] : [N, navigator.appVersion, "-?"];

    return M[1];
};

var pageRedirectByScreenId = function (screenId, param) {
    if (param === undefined) param = {};
    param.screenId = screenId;
    pageRedirect(param);
};

var pageRedirect = function (param) {

//    var hasTabComponent = WUX.hasComponent('tab');
//    if(hasTabComponent){
//        var tabComponent = WUX.getComponent('tab');
//        if (param.closeTab === true) tabComponent.removeTab(tabComponent.getActiveIndex());
//    }
    var store = new EVF.Store();
    store.setParameter('SCREEN_ID', param.screenId);
    store.load('/common/menu/getScreenInfo.so', function () {

        var screenInfo = JSON.parse(this.getParameter('screenInfo'))[0];
        var url = screenInfo.SCREEN_URL;
        if (url.indexOf('?') === -1) url = url + '?';

        openScreenToNewTab(screenInfo.TMPL_MENU_CD, screenInfo.SCREEN_NM, screenInfo.SCREEN_URL, '', param);

//        if(screenInfo.hasNotice === 'true'){
//            var remainingTime = getRemainingTime(screenInfo);
//            if(remainingTime > 0){
//                console.log('NoticeBlocked By User. remainingTime: ' + remainingTime);
//                return;
//            }
//            wisePopup.openScreenNotice(screenInfo.NOTICE_NO);
//        }
    });
};

var getRemainingTime = function (screenInfo) {
    var cookieKey = "screenNoticeDelayUntil" + screenInfo[0].NOTICE_NUM;
    var currentDate = new Date().getTime();
    var screenNoticeDelayUntil = $.cookie(cookieKey) === null ? currentDate - 1 : $.cookie(cookieKey);
    console.log("currentDate: " + currentDate);
    console.log("screenNoticeDelayUntil: " + screenNoticeDelayUntil);
    return screenNoticeDelayUntil - currentDate;
};

function resizeComponent() {
    setTimeout(function () {
        $("#e-main-tab > iframe").height($(".ui-layout-center").outerHeight() - 36);
        $('.e-treepanel-contents').height($('.ui-layout-west').outerHeight(true) - 210);
    }, 500);
}

$(window).resize(function() {
    resizeComponent();
});

function goHome() {
    location.href="/welcome";
}

function openUserInfo() {
    var param = {};
    new EVF.ModalWindow("/eversrm/main/userInfoChange/view.so", param, "700", "420").open();
}

function initHome(lMenu) {
	if (lMenu != "") {
	    fetchLeftMenu(lMenu);
	}
}

function fetchLeftMenu(moduleType,ctrlCd, superUserFlag) {
    /*if (superUserFlag != '1') {
        if (ctrlCd != undefined) {
            //발주관리
            if (moduleType == 'DGM' && ctrlCd.indexOf('B200') < 0) {
                alert("권한이 없습니다.");
                return;
            }
            //자재관리
            if (moduleType == 'IT' && ctrlCd.indexOf('B200') < 0) {
                alert("권한이 없습니다.");
                return;
            }
            //기준정보
            if (moduleType == 'BI' && ctrlCd.indexOf('B700') < 0) {
                alert("권한이 없습니다.");
                return;
            }
        }
    }*/

    return new Promise(function(resolve, reject) {
        $(".e-topmenu-wrapper").removeClass("e-topmenu-selected");
        $("#"+moduleType).addClass("e-topmenu-selected");
        EVF.C("leftMenuTree").setProperty("expandAllNode", true);
        EVF.C("leftMenuTree").loadTreeForModuleType(moduleType).then(function() {
            $('.e-treepanel-item-depth1-wrapper').next().find('.e-treepanel-item-container').prevObject.each(function(k, v) {
                if( $(v).find('.e-treepanel-item-depth2-wrapper').length == 0) {
                    $(v).prev().remove();
                }
            });

            return resolve();
        }, function() {
            return reject();
        });
    });
}
/*
function processWhenLoggedOut(id, type) {
    //var mask = new EVF.Mask();
    //mask.mask({noIcon:true});

    var top = (document.body.clientHeight / 2) - 250;
    var left = (document.body.clientWidth / 2) - 200;

    var $window = $(document.body);

    if($('iframe#loginLayer').length == 0) {

        var $tempForm = $('<form id="login_layer_form" action="/loginLayer.so?id='+id+'&type='+type+'" method="post" target="loginLayer"></form>');
        $window.append($tempForm);
        var $modalWindow = $("<iframe frameborder='0'></iframe>");
        $modalWindow.attr("id", "loginLayer").attr("name", "loginLayer").width("400").height("500").css({
            position: "absolute",
            backgroundColor: "transparent",
            zIndex: 10000,
            top: top,
            left: left
        });

        $window.append($modalWindow);
        $tempForm.submit().remove();
    }
}
*/
