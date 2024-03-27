/**
 * @author YEON-MOO
 */
/**
 * Object Popup() 팝업 화면들을 호출 하는 class 입니다.
 *
 * @constructor
 * @extends Object
 */
var everPopup = function() {};

everPopup.openModalPopup = function(url, width, height, param){
    if(param == null) {
        param = {};
    }
    
    param.popupFlag = true;
    
    if(param.detailView === undefined) {
        param.detailView = false;
    }

    var oriId = url.replace(/[^(a-zA-Z0-9)]/gi, "");
    if ( $('#'+ oriId).length == 0 ) {
        var id = new EVF.ModalWindow(url, param, width, height).open();
        return id;
    }
};

everPopup.openWindowPopup = function(url, width, height, param, name, resizable){

    var _param = param;
    if(_param != null) {
        _param.detailView = param.detailView || false;
    }

    if(resizable === undefined) {
    	resizable = true;
    }
    if(resizable == null) {
    	resizable = true;
    }
    everPopup.createWindowPopup(url, width, height, _param, name, resizable);
};

everPopup.openWindowPopupParamIsStr = function(url, width, height, paramStr, name, resizable){

	var param = JSON.parse(everString.replaceAll(paramStr, "@@@", "\\n"));

	var _param = param;
	if(_param != null) {
		_param.detailView = param.detailView || false;
	}

	if(resizable === undefined) {
		resizable = true;
	}
	if(resizable == null) {
		resizable = true;
	}
	everPopup.createWindowPopup(url, width, height, _param, name, resizable);
};

everPopup.createWindowPopup = function(url, width, height, param, name, resizable) {

    if (name === undefined || $.trim(name) === '') {
        name = "newPopup" + String(Math.random()).substring(2,7);
    }
    var maxHeight = window.screen.availHeight - 70;
    if(maxHeight < height){
        height = maxHeight;
    }
    name = everString.replaceAll(name, ' ', '');

    /*
    var top = (maxHeight - height)/2;
    var left = (window.screen.availWidth - width)/2;

    var top = (screen.availHeight-430)/2;
    var left = (screen.availWidth-660)/2;
    */
    var top  = (screen.availHeight - height) / 2;
    var left = (screen.availWidth  - width)  / 2;

    if(param != null) {
        param.popupFlag = true;
    } else {
        param = { popupFlag:true };
    }

    var property = { "url" : url,
        "fullscreen" : false,
        "directories": false,
        "location": false,
        "menubar" : false,
        "status"  : false,
        "toolbar" : false,
        "scrollbars": true,
        "method": 'post',
        "param" : param,
        "width" : width,
        "height": height,
        "top"   : top,
        "left"  : left,
        "name"  : name,
        "resizable": resizable};
    
    var form = everPopup.makePostForm(property, param);
    var popWindow = window.open('', name, everPopup.argsToString(property));
    form.submit();
};

everPopup.makePostForm = function (property, param) {

    var postFormEl;

    postFormEl = document.createElement("form");
    postFormEl.setAttribute("method", "post");
    postFormEl.setAttribute("accept-charset", 'UTF-8');
    postFormEl.setAttribute('action', property.url);
    postFormEl.setAttribute('target', property.name);

    for (var p in param) {
    	var input = document.createElement('input');
        input.setAttribute('type', 'hidden');
        input.setAttribute('name', p);
        input.setAttribute('value', (param[p] !== null ? param[p] : ''));
        postFormEl.appendChild(input);
    }

    document.body.appendChild(postFormEl);
    return postFormEl;
};

everPopup.argsToString = function (property) {

    var rtn = [];
    rtn.push('top=' + property.top);
    rtn.push('left=' + property.left);

    rtn.push('fullscreen=' + property.fullscreen || 'false');
    rtn.push('height=' + property.height || '200');
    rtn.push('width=' + property.width || '200');

    rtn.push('directories=' + (property.directories == true ? 'yes' : 'no'));
    rtn.push('location=' + (property.location == true ? '1' : '0'));
    rtn.push('menubar=' + (property.menubar == true ? 'yes' : 'no'));
    rtn.push('resizable=' + (property.resizable == true ? 'yes' : 'no'));

    rtn.push('status=' + (property.status == true ? '1' : '0'));
    rtn.push('toolbar=' + (property.toolbar == true ? '1' : '0'));
    rtn.push('scrollbars=' + (property.scrollbars == true ? '1' : '0'));
    return rtn.join(',');
};

/**
 * @param param
 * {YOUR PARAMETER JSON TYPE}
 * @param commonId
 * POPUP ID
 */
everPopup.openCommonPopup = function(param, commonId, width, height){

    if(param == null) {
        param = {};
    }

    param.popupFlag = true;

    var baseUrl = '/common/commonPopup';
    var store = new EVF.Store();
    store.setParameter("COMMON_ID", commonId);
    store.load(baseUrl + '/getDimension.so', function() {

        param.COMMON_ID = commonId;
        width  = this.getParameter('width');
        height = this.getParameter('height');

        if(width === undefined || width === '' || width == null) {
        	width = 700;
        }

        if(height === undefined || height === '' || height == null) {
        	height = 600;
        }

        everPopup.openModalPopup(baseUrl+'/view.so', width, height, param);
    }, false);
};

everPopup.openCommonPopupWindow = function(param, commonId, width, height){

    if(param == null) {
        param = {};
    }

    param.popupFlag = true;

    var baseUrl = '/common/commonPopup';
    var store = new EVF.Store();
    store.setParameter("COMMON_ID", commonId);
    store.load(baseUrl + '/getDimension.so', function() {

        param.COMMON_ID = commonId;
        width = this.getParameter('width');
        height = this.getParameter('height');

        if(width === undefined || width === '' || width == null) {
            width = 700;
        }

        if(height === undefined || height === '' || height == null) {
            height = 600;
        }

        everPopup.openWindowPopup(baseUrl+'/view.so', width, height, param);
    }, false);
};

everPopup.openMultiLanguagePopup = function(param){
    var url = '/everadmin/system/multiLang/ATTR01_030/view.so';
    if(param.callBackFunction === undefined || $.trim(param.callBackFunction) === ''){
        param.callBackFunction = 'multiLanguagePopupCallBack';
    }
    everPopup.openModalPopup(url, 600, 400, param);
};

/**
 * @param param
 * @Author : St-Ones
 * @param commonId
 * POPUP ID
 */
everPopup.openZipCodePopup = function(params) {
    var url = '/everc/common/code/zipCode/view.so';
    everPopup.openWindowPopup(url, 800, 600, params,'zipCodeSearch');
};

/**
 * Per-user -defined column view and editable popup
 * @param param
 */
everPopup.openUserColumnList = function(param) {
    var url = "/everadmin/system/multiLang/ATTR01_020/view.so";
    if(param === undefined){
        param = {};
    }
    everPopup.openWindowPopup(url, 1000, 500, param, "ATTR01_020", true);
};

/**
 * 결재내역 팝업
 * @param appDocNum
 * @param appDocCnt
 */
everPopup.approvalProcessPopup = function(appDocNum, appDocCnt) {
    var param = {
        "APP_DOC_NUM" : appDocNum,
        "APP_DOC_CNT" : appDocCnt
    };
    var url = '/eversrm/eApproval/approvalSignUserList/view.so';
    everPopup.openWindowPopup(url, 800, 550, param, "");
};

// 첨부파일
everPopup.fileAttachPopup = function (bizType, uuid, callBackFunction, rowId, isDetailView, fileExtension) {
    var param = {
        bizType : bizType,
        attFileNum : uuid,
        callBackFunction : callBackFunction,
        rowId: rowId,
        detailView : isDetailView,
        havePermission : true,
        fileExtension : fileExtension == undefined ? '*' : fileExtension
    };
    var url = '/common/commonFileAttach/view.so';
    everPopup.openModalPopup(url, 600, 320, param);
};

// 첨부파일
everPopup.fileAttachWindowPopup = function (param) {

    if (EVF.isEmpty(param.bizType)) {
        return EVF.alert("bizType 이 존재하지 않습니다.\n확인하여 주시기 바랍니다.");
    }

    if (EVF.isEmpty(param.fileExtension)) {
        param.fileExtension = "*";
    }

    var url = '/common/commonFileAttach/view.so';
    everPopup.openWindowPopup(url, 600, (param.detailView == true ? 310 : 340), param);
};

/**
 * File Attach
 *@param params
 */
everPopup.readOnlyFileAttachPopup = function(bizType, uuid, callBackFunction, rowId){
    var param = {
        bizType : bizType,
        attFileNum : uuid,
        callBackFunction : callBackFunction,
        rowId : rowId,
        detailView: true,
        havePermission : false
    };
    var url = '/common/commonFileAttach/view.so';
    everPopup.openModalPopup(url, 600,320, param);
};

everPopup.commonTextInput = function(param) {
    var url = '/common/commonPopup/common_text_input/view.so';
    everPopup.openModalPopup(url, 500, param.detailView ? 320 : 350, param);
};

/**
 * Approval Request Popup : type I
 *@param params
 */
everPopup.openApprovalRequestPopup = function(param){
    var url = '/eversrm/eApproval/eApprovalModule/approvalRequestPopup/view.so';
    everPopup.openWindowPopup(url, 1070, 700, param, 'openApprovalRequestPopup');
};

/**
 * Approval Request Popup : type II
 *@param params
 */
everPopup.openApprovalRequestIIPopup = function(param){
	
    var url = '/eversrm/buyer/approval/BAPP01_070/view.so';
    everPopup.openWindowPopup(url, 1100, 850, param, 'openApprovalRequestIIPopup');
};

/**
 * Approval or Reject Popup
 * @memberOf Popup
 * @param {Object}
 *            params<br>
 *            gateCd :gridRow.gate_cd, appDocNo:gridRow.APP_DOC_NUM, appDocCnt:gridRow.APP_DOC_CNT, docType:gridRow.DOC_TYPE, signStatus:
 *            gridRow.SIGN_STATUS, from:'sendBox'
 */
everPopup.openApprovalOrRejectPopup = function(params) {
    var url = '/eversrm/buyer/approval/BAPP01_050/view.so';
    everPopup.openWindowPopup(url, 1400, 1000, params, 'approvalOrRejectPopup');
};

/**
 * User Search Popup
 *@param params
 */
everPopup.userSearchPopup = function(callBackFunction, nRow, userNm, mode, buyerCd){

    if(userNm === undefined){
    	userNm = '';
    }
    if(nRow === undefined){
        nRow = -1;
    }
    if(mode === undefined){
        mode = '';
    }
    if(buyerCd === undefined){
        buyerCd = '';
    }

    var popupUrl = "/eversrm/buyer/user/BADU_050/view.so?" ;
    var param = {
        callBackFunction: callBackFunction,
        nRow: nRow,
        userNm: userNm,
        buyerCd: buyerCd,
        mode: mode,
        detailView: false,
        popupFlag: true
    };
    everPopup.openModalPopup(popupUrl, 800, 700, param);
};

/**
 * Approval Sample Popup
 *@param params
 */
everPopup.openeApprovalRequestSample = function(param){
    var url = '/eversrm/eApproval/approvalRequestPopup/view.so';
    everPopup.openWindowPopup(url, 800, 700, param, 'approvalRequestPopup');
};

/**
 * approval / reject comment popup
 *
 * @memberOf Popup
 * @param approvalType
 *            E approval R reject
 */
everPopup.openApprovalRemarkPopup = function(approvalType) {
    var param = { approvalType : approvalType };
    var url = '/eversrm/buyer/approval/BAPP01_052/view.so';
    everPopup.openModalPopup(url, 600, 420, param);

};

/**
 * get My Approval Path
 */
everPopup.openMyApprovalPathPopup = function() {
    var url = '/eversrm/buyer/approval/BAPM_040/view.so';
	everPopup.openModalPopup(url, 800, 600, {}, 'myApprovalPathPopup');
};

/**
 * Approval Path Search
 *@param params
 *
 *St-Ones
 */
everPopup.approvalPathSearchPopup = function(param){
    var url = '/eversrm/buyer/approval/BAPP01_060/view.so';
    everPopup.openWindowPopup(url, 950, 600, param);
};

/**
 * Menu Template Detail Popup
 * @param param
 * @Author : St-Ones
 */
everPopup.openMenuTemplateDetailPopup = function(params) {
    var url = '/eversrm/system/menu/BSYM_020/view.so';
    everPopup.openWindowPopup(url, 1000, 550, params, params.TMPL_MENU_GROUP_CD + 'menuTemplateDetail');
};

/**
 * Screen ID Popup
 * @param param
 * @Author : St-Ones
 */
everPopup.openScreenIdPopup = function(params) {
    var url = '/everadmin/system/screen/SCREEN01_021/view.so';
    everPopup.openWindowPopup(url, 1000, 500, params, 'SCREEN01_021',false);
};

/**
 * Menu Group Codde Popup
 * @param param
 * @Author : St-Ones
 */
everPopup.openMenuGroupCodePopup = function(params) {
    var url = '/eversrm/system/menu/BSYM_040/view.so';
    everPopup.openWindowPopup(url, 1000, 700, params, 'menuGroupCd');
};

/**
 * Menu Template Group Code Popup
 * @param param
 * @Author : St-Ones
 */
everPopup.openMenuTemplateGroupCodePopup = function(params) {
    var url = '/everadmin/system/menu/BSYM_050/view.so';
    everPopup.openWindowPopup(url, 950, 450, params, 'menuTemplateGroupCd');
};

/**
 * multi-language view and editable popup
 * @param param
 */
everPopup.openMultiLanguageList = function(param) {
    var url = "/everadmin/system/multiLang/ATTR01_010/view.so";
    if(param === undefined){
        param = {};
    }
    everPopup.openWindowPopup(url, 1000, 700, param, "multiLangListPopup", true);
};

everPopup.openPopupByScreenId = function(screenId, width, height, param){

	if(param === undefined) {param = {};}
    if(width === undefined) {width = 800;}
    if(height === undefined){height = 600;}

    param.screenId = screenId;
    if(param.detailView === undefined) {
        param.detailView = false;
    }
    if(param.popupFlag === undefined) {
        param.popupFlag = true;
    }
    var store = new EVF.Store();
    store.setParameter('SCREEN_ID', screenId);
    store.load('/common/menu/getScreenInfo.so', function() {
        var url = this.getParameter('SCREEN_URL');
        if (url == 'NOTFOUNDSCRRENID') {
            return EVF.alert(url);
        }
        if(url.indexOf('?') === -1){
            url = url + '?';
        }
        if(screenId == 'CHARTVIEW') screenId='';

        if(screenId === 'commonFileAttach' || screenId === 'commonTextContents' || screenId === 'commonImgFileAttach') {
            everPopup.openModalPopup(url, width, height, param);
        } else {
        	everPopup.openWindowPopup(url, width, height, param, screenId, true);
        }
    }, false);
};

/**
 * @Task screenActionManagement editable popup
 * @Author: su
 */
everPopup.openScreenActionManagement = function(param) {
    var url = "/everadmin/system/screen/SCREEN01_020/view.so";
    if(param === undefined){
        param = {};
    }
    everPopup.openWindowPopup(url, 1000, 700, param, "", true);
};

/**
 * 고객사 조회 팝업
 * @param param
 */
everPopup.getBuyer = function(param) {
    if(param === null || param === undefined) {
        param = {
            callBackFunction: "setBuyer"
        };
    }
    everPopup.openCommonPopup(param, "SP0001");
};

/**
 * 주소 팝업호출
 * @param param
 */
everPopup.jusoPop= function(url, param) {
    var height = 420;
    var width  = 570;
    var top  = (screen.availHeight - height) / 2;
    var left = (screen.availWidth  - width)  / 2;
    var options = "width="+width+",height="+height+",left="+left+",top="+top+",scrollbars=yes, resizable=yes";

    var pop = window.open(url + "?" + $.param(param),"pop",options);
};

everPopup.doCBSearch = function(param) {

    var store = new EVF.Store();
    var keys = Object.keys(param);
    for (var i in keys) {
        var key = keys[i];
        if (param.ACTION_ID != undefined && param.ACTION_ID.indexOf(key) > -1) {
            var delColumn = key.indexOf('CD') > -1 ? key.replace('CD', 'NM') : key.replace('NM', 'CD');
            store.setParameter(delColumn, '');
        }
        store.setParameter(key, param[key]);
    }
    
    store.setAsync(false);
    store.load('/everadmin/system/code/getCBSearch.so', function() {
        // 1건만 조회된 경우
    	if (this.getResponseObject()[1] == undefined) {
            var reqParam = this.getResponseObject()[0];
            if (reqParam == undefined) {
            	if( param.gridId != undefined && param.gridId != '' ) {
        			eval(param.gridId).setCellValue(param.rowid, param.V_CD, '');
        			eval(param.gridId).setCellValue(param.rowid, param.V_NM, '');
            	} else {
            		if(param.V_CD != param.ACTION_ID) {
	                    EVF.V(param.V_CD, '');
	                } else if(param.V_NM != param.ACTION_ID) {
	                    EVF.V(param.V_NM, '');
	                }
            	}
            } else {
            	if( param.gridId != undefined && param.gridId != '' ) {
        			eval(param.gridId).setCellValue(param.rowid, param.V_CD, reqParam.value);
        			eval(param.gridId).setCellValue(param.rowid, param.V_NM, reqParam.text);
            	} else {
                    EVF.V(param.V_CD, reqParam.value);
                    EVF.V(param.V_NM, reqParam.text);
            	}
            }
        } // 2건 이상 조회된 경우
    	else {
        	if (param.POPUP_CD != undefined && param.POPUP_CD != '') {
        		var popParam = {
        				args : (param.args == undefined)  ? '' : param.args,
                	    rowid: (param.rowid == undefined) ? '' : param.rowid,
        				callBackFunction: param.callBackFunction
        	        };
    	        everPopup.openCommonPopup(popParam, param.POPUP_CD);
        	}
        }
    });
};

/*
let arr = ['NEW_CMC_CD','ITEM_NM','SIZEUNIT','ITEM_CLS_NAME','ITEM_MEDICATION_CLS_NAME','CALC_STOCK_QTY','PRICE_3_DT']

var param = {
                CB_CD			 : 'CB0053', -- 단건 일시 조회 쿼리
	            gridId			 : gridDetailList, -- 그리드 오브젝트로 선언 넘겨야함
	            rowId			 : rowId,  -- 해당로우넘버
	            args             : gridDetailList.getCellValue(rowId, 'ITEM_CD_S'), -- 다건인경우 args 컬럼매핑
	            V_PARAM          : arr, -- 단건인경우 그리드 초기화 칼럼명 배열로 던지면 자동으로 공백처리.
	            POPUP_CD		 : 'SP0019',  -- 다건 팝업 아이디
	            callBackFunction : 'setItemCd' -- 콜백 함수 문자열로 넘겨야함.
	            필수조건
------------------------------------------------------------------------------------------------------	            
	            단건 CB0053 필요 값
	            ITEM_CD 		 : gridDetailList.getCellValue(rowId, 'ITEM_CD_S'), -- 단건인경우 CB0053쿼리실행 KEY ID
	            ORDER_DT 	     : EVF.V("START_DT"), -- -- 단건인경우 CB0053쿼리실행 KEY ID
	       		HOSPITAL_CLS  	 : EVF.V("CUST_CD"),  -- -- 단건인경우 CB0053쿼리실행 KEY ID
        }; */
everPopup.doCBSearchItem = function(param) {
    var store = new EVF.Store();
    var keys = Object.keys(param);
    for (var i in keys) {
        var key = keys[i];
        if (param.ACTION_ID != undefined && param.ACTION_ID.indexOf(key) > -1) {
            var delColumn = key.indexOf('CD') > -1 ? key.replace('CD', 'NM') : key.replace('NM', 'CD');
            store.setParameter(delColumn, '');
        }

        if(typeof  param[key] != 'object' && typeof  param[key] != 'function'){
	        store.setParameter(key, param[key]);
		}
    }
    console.log(param.CB_CD+":::?")
    if( param.CB_CD == undefined || param.CB_CD == '' ) {
    	if( param.POPUP_CD != undefined && param.POPUP_CD != '' ) {
            let popParam = {}
            for(let v in param){
                popParam[v] = param[v];
            }
            popParam.args = (popParam.args == undefined)  ? '' : popParam.args;
            popParam.rowId = (popParam.rowId == undefined)  ? '' : popParam.rowId;

            everPopup.openCommonPopup(popParam, param.POPUP_CD);
    	}
	} else {
		store.setAsync(false);
	    store.load('/everadmin/system/code/getCBSearch.so', function() {
	        // 1건만 조회된 경우
	    	if (this.getResponseObject()[1] == undefined) {
	            var reqParam = this.getResponseObject()[0];
	            if (reqParam == undefined) {
	            	if( param.gridId != undefined && param.gridId != '' ) {
					    for(let a in param.V_PARAM){
							param.gridId.setCellValue(param.rowId, param.V_PARAM[a], '');
					    }
	            	} else {
	            		for(let a in param.V_PARAM){
							 EVF.V(param.V_PARAM[a], '');
					    }
	            	}
	            } else {
					reqParam.rowId = param.rowId
					window[param.callBackFunction](reqParam)
	            }
	        } // 2건 이상 조회된 경우
	    	else {
	        	if (param.POPUP_CD != undefined && param.POPUP_CD != '') {
                    let popParam = {}
                    for(let v in param){
                        popParam[v] = param[v];
                    }
                    popParam.args  =  (popParam.args == undefined)  ? '' : popParam.args;
                    popParam.rowId = (popParam.rowId == undefined)  ? '' : popParam.rowId;

	    	        everPopup.openCommonPopup(popParam, param.POPUP_CD);
	        	}
	        }
	    });
	}
};

/**
 * Jasper를 통한 PDF 출력
 * 서버에 PDF를 생성한 후 생성한 PDF를 보여주도록 함
 * @param param
 */
everPopup.jasperReport = function(callType, queryParam, param) {
	let store = new EVF.Store();
    store.setParameter("paramObj"    , JSON.stringify(param));
    store.setParameter("queryParam"  , JSON.stringify(queryParam, null, 2));
    store.load('/common/REPORT/reportJsonQury.so', function() {
        this.data.jsonData = JSON.stringify(this.responseBody.rtn)
        param.callType = callType;
        param.callType2 = 'J';
        this.data.param = JSON.stringify(param);
        everPopup.openWindowPopup('/eversrm/buyer/bmy/REPORT/view.so', 1200, 800, this.data)


    });
    
    
    
    
    
   /*
	$.ajax({
    	 type   : 'GET',
    	 url    : '/common/REPORT/jasperPrint.do',
    	 data   : JSON.stringify(param),
    	 async  : false,
    	 success: function(data,textStatus,jqXHR){
                      var sUrl        = "/js/PDFJS/web/viewer.html?file=" + JSON.parse(jqXHR.responseText).fileName;
                      var strWinStyle = "width=990 height=500 toolbar=no menubar=no location=no scrollbars=no resizable=no fullscreen=no ";
                      var popup = window.open(sUrl, 'popup', strWinStyle);
                  },
         error  : function(jqXHR, textStatus, errorThrown) {
                      alert(JSON.parse(jqXHR.responseText).message);
                  }
    })*/
};

/*
*  callType   : 'D' Download, 'V' View, 'P' View & Print
*  filenm     : 배열 fileName
*  param      : parameters
* */
everPopup.clipReport = function(callType, filenm, param){
	
    this.data          = {};
    this.data.filenm   = filenm;
    param.callType     = callType;
    param.callType2    = 'R';
    this.data.param    = JSON.stringify(param);
    everPopup.openWindowPopup('/common/REPORT/view.so', 1200, 800, this.data)
}

/*
*  callType   : 'D' Download, 'V' View, 'P' View & Print
*  queryParam : 배열 fileName & queryId & multiReportFlag
*  multiReportFlag -> clipReport 멀티리포트 사용시  구분값 마다 특정 동작 필요시   clipReport 매개변수 multiReportFlag 선언후 사용하면 됩니다.
*  param      : parameters
* */
everPopup.clipJsonReport = function(callType, queryParam, param){
	
    this.data = {};
    
    let print = param.PRINT;
    
    var store = new EVF.Store();
    store.setParameter("paramObj"    , JSON.stringify(param));
    store.setParameter("queryParam"  , JSON.stringify(queryParam, null, 2));
    
    store.load('/common/REPORT/clipJsonQuery.so', function() {
        this.data.jsonData = JSON.stringify(this.responseBody.rtn)
        param.callType  = callType;
        param.callType2 = 'J';
        param.PRINT     = print;
        this.data.param = JSON.stringify(param);
        everPopup.openWindowPopup('/common/REPORT/view.so',1200, 800 ,this.data)
    });
}

