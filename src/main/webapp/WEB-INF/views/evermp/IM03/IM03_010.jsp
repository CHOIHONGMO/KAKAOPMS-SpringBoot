<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var grid;
	var baseUrl = "/evermp/IM03/IM0301/";
	var mngYn = "${ses.mngYn}";

	function init(){

        grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value) {
            var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
            var ITEM_CD = grid.getCellValue(rowId, "ITEM_CD");
            if (colId === "CUST_NM") {
                var param = {
                    CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                    detailView: true,
                    popupFlag: true
                };
                everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
            } else if(colId === "REQ_USER_NM") {
                if( EVF.isEmpty(grid.getCellValue(rowId, "REQ_USER_ID")) ) return;
            	var param = {
                    callbackFunction: "",
                    USER_ID: grid.getCellValue(rowId, "REQ_USER_ID"),
                    detailView: true
                };
                everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
            } else if(colId === "ITEM_REQ_NO") {
                var param = {
                    CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                    ITEM_REQ_NO: grid.getCellValue(rowId, "ITEM_REQ_NO"),
                    ITEM_REQ_SEQ: grid.getCellValue(rowId, "ITEM_REQ_SEQ"),
                    detailView: true,
                    popupFlag: true
                };
                everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
            } else if(colId === "ATTACH_FILE_CNT") {
                if( !EVF.isEmpty(value) && value > 0 ) {
                    var uuid = grid.getCellValue(rowId, "ATTACH_FILE_NO");
                    var param = {
                        havePermission: false,
                        attFileNum: uuid,
                        rowId: rowId,
                        callBackFunction: "",
                        bizType: "RE"
                    };
                    everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
                }
            /**
             * 상품의 분류체계 Mapping하는 팝업
            } else if(colId === "ITEM_CLS_NM") {
                var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                var param = {
                    callBackFunction: "callbackGridITEM_CLS_NM",
                    detailView: false,
                    multiYN: false,
                    ModalPopup: false,
                    searchYN: false,
                    rowId: rowId,
                    custCd: "${ses.companyCd}",
                    custNm: "${ses.companyNm}"
                };
               	everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup"); */
            } else if(colId === "ITEM_CD") {
                if (value != "") {
                    var param = {
                        ITEM_CD: grid.getCellValue(rowId, 'ITEM_CD'),
                        popupFlag : true,
                        detailView: true
                    };
                    everPopup.im03_009open(param);
                }
                /**
                 * 상품 표준화(기존 상품 Mapping)시 사용하는 상품선택 팝업
            	if(value !== "") {
	                var param = {
	                    STD_FLAG: "1",
	                    callBackFunction: "callbackGridITEM_CD",
	                    rowId: rowId,
	                    multiFlag: false,
	                    detailView: true,
	                    popupFlag: true
	                };
	              	everPopup.openPopupByScreenId("IM02_012", 1200, 600, param);
            	}*/
            }// 상품 상세내용
            else if(colId === "ITEM_RMK") {
            	if(value !== "") {
	                var param = {
	                    title : "${IM03_010_034}",
	                    message : grid.getCellValue(rowId, "ITEM_RMK"),
	                    callbackFunction : "",
	                    detailView : true,
	                    rowId : rowId
	                };
	                var url = "/common/popup/common_text_input/view";
	                everPopup.openModalPopup(url, 500, 320, param);
            	}
            }// 상품 요청내용
            else if(colId === "RFQ_REQ_TXT") {
                if(value !== "") {
                    var param = {
                        title : "${IM03_010_033}",
                        message : grid.getCellValue(rowId, "RFQ_REQ_TXT"),
                        callbackFunction : "",
                        detailView : true,
                        rowId : rowId
                    };
                    var url = "/common/popup/common_text_input/view";
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            }
            /**
             * 미표준화 사유
            else if(colId === "NOT_STD_REMARK_YN") {
                var detailView = false;
                if(PROGRESS_CD !== "100") {
                    detailView = true;
                }
                if(value !== "" || PROGRESS_CD === "100") {
                    var param = {
                        title : "${IM03_010_032}",
                        message : grid.getCellValue(rowId, "NOT_STD_REMARK"),
                        callbackFunction : "callbackGridNOT_STD_REMARK",
                        detailView : detailView,
                        rowId : rowId
                    };
                    var url = "/common/popup/common_text_input/view";
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            }*/
            // 반려사유
            else if(colId === "RE_REQ_REASON") {
                var detailView = false;
                if(PROGRESS_CD !== "100") {
                    detailView = true;
                }
                if(value !== "" || PROGRESS_CD === "100") {
                    var param = {
                        title : "${IM03_010_031}",
                        message : grid.getCellValue(rowId, "RE_REQ_REASON"),
                        callbackFunction : "callbackGridRE_REQ_REASON",
                        detailView : detailView,
                        rowId : rowId
                    };
                    var url = "/common/popup/common_text_input/view";
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            }
            /**
             * 재요청 반려사유
            else if(colId === "RE_REQ_REJECT_RMK_YN") {
                if(value !== "") {
                    var param = {
                        title : "${IM03_010_030}",
                        message : grid.getCellValue(rowId, "RE_REQ_REJECT_RMK"),
                        callbackFunction : "",
                        detailView : true,
                        rowId : rowId
                    };
                    var url = "/common/popup/common_text_input/view";
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            }*/
            // 상품담당자 이관사유
            else if(colId === "MOVE_REASON") {
            	var detailView = false;
                if(PROGRESS_CD !== "300") {
                    detailView = true;
                }
            	var param = {
                    title : "${IM03_010_029}",
                    message : grid.getCellValue(rowId, "MOVE_REASON"),
                    callbackFunction : "callbackGridMOVE_REASON",
                    detailView : detailView,
                    rowId : rowId
                };
                var url = "/common/popup/common_text_input/view";
                everPopup.openModalPopup(url, 500, 320, param);
            }
            else if(colId === "REFER_URL") {
            	if(value == "") return;

	          	  var width = 800
	              var height = 500
	              var dim = new Array(2);
	              var left = 300
	              var top = 400;
	              var toolbar = 'yes'
	              var menubar = 'yes'
	              var status = 'yes'
	              var scrollbars = 'yes'
	              var resizable = 'yes'
	              var url = value
//	              window.open(url,'_blank','left='+left+',top='+top+',width='+width+',height='+height+',toolbar='+toolbar+',menubar='+menubar+',status='+status+',scrollbars='+scrollbars+',resizable='+resizable)
                  window.open(url, "_blank", "width=800,height=500");

            	//everPopup.openWindowPopup(value, 500, 470, '', 'destUrl', true);
            }
            /**
             * 회신사유
            else if(colId === "RETURN_REASON_YN") {
                var detailView = false;
                if(PROGRESS_CD !== "100") {
                    detailView = true;
                }
                var param = {
                    title : "${IM03_010_025}",
                    message : grid.getCellValue(rowId, "RETURN_REASON"),
                    callbackFunction : "callbackGridRETURN_REASON",
                    detailView : detailView,
                    rowId : rowId
                };
                var url = "/common/popup/common_text_input/view";
                everPopup.openModalPopup(url, 500, 320, param);
            }*/
            /**
             * 삭제사유
            else if(colId === "DELETE_REASON_YN") {
                var detailView = false;
                if(PROGRESS_CD !== "100") {
                    detailView = true;
                }

                if(value !== "" || PROGRESS_CD === "100") {
                    var param = {
                        title : "${IM03_010_036}",
                        message : grid.getCellValue(rowId, "DELETE_REASON"),
                        callbackFunction : "callbackGridDELETE_REASON",
                        detailView : detailView,
                        rowId : rowId
                    };
                    var url = "/common/popup/common_text_input/view";
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            }*/
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            if(colId == 'ORIGIN_NM') {
                grid.setCellValue(rowId, "CMS_ORIGIN_CD", newValue);
            }
        });

        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        var CMS_CTRL_USER_ID_Options = ${CMS_CTRL_USER_ID_Options};
        var SG_CTRL_USER_ID_Options  = ${SG_CTRL_USER_ID_Options};

        var lookupKeys1 = [];
        var lookupValues1 = [];
        var lookupKeys2 = [];
        var lookupValues2 = [];

        for(var i in CMS_CTRL_USER_ID_Options) {
            lookupKeys1.push(CMS_CTRL_USER_ID_Options[i].value);
            lookupValues1.push(CMS_CTRL_USER_ID_Options[i].text);
        }

        for(var i in SG_CTRL_USER_ID_Options) {
            lookupKeys2.push(SG_CTRL_USER_ID_Options[i].value);
            lookupValues2.push(SG_CTRL_USER_ID_Options[i].text);
        }

        grid._gvo.setLookups([{
            "id": "lookup1",
            "levels": 1,
            "keys": lookupKeys1,
            "values": lookupValues1
        }, {
            "id": "lookup2",
            "levels": 1,
            "keys": lookupKeys2,
            "values": lookupValues2
        }]);

        var Col1 = grid._gvo.columnByField("CMS_CTRL_USER_ID");
        Col1.lookupDisplay = true;
        Col1.lookupSourceId = "lookup1";
        Col1.lookupKeyFields = ["CMS_CTRL_USER_ID"];
        grid._gvo.setColumn(Col1);

        var Col2 = grid._gvo.columnByField("SG_CTRL_USER_ID");
        Col2.lookupDisplay = true;
        Col2.lookupSourceId = "lookup2";
        Col2.lookupKeyFields = ["SG_CTRL_USER_ID"];
        grid._gvo.setColumn(Col2);

        grid.setColIconify("NOT_STD_REMARK_YN", "NOT_STD_REMARK", "comment", false);
        grid.setColIconify("RE_REQ_REASON_YN", "RE_REQ_REASON", "comment", false);
        grid.setColIconify("RETURN_REASON_YN", "RETURN_REASON", "comment", false);
        grid.setColIconify("RE_REQ_REJECT_RMK_YN", "RE_REQ_REJECT_RMK", "comment", false);
        grid.setColIconify("DELETE_REASON_YN", "DELETE_REASON", "comment", false);

        // 고객사 진행상태인 작성(T), 반려(R)는 제외
        EVF.C('PROGRESS_CD').removeOption('T');
        EVF.C('PROGRESS_CD').removeOption('R');

    	// 진행상태 자동 체크 (T:등록요청, R:요청반려, 100:견적요청)
        var chkName = "";
        $('.ui-multiselect-checkboxes li input').each(function (k, v) {
            if (v.value == '100') {
                chkName += v.title + ", ";
                v.checked = true;
            }
        });
        $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));

		doSearch();
	}

	// 미표준화사유
	function callbackGridNOT_STD_REMARK(data) {
        grid.setCellValue(data.rowId, "NOT_STD_REMARK", data.message);
        grid.checkRow(data.rowId, true);
    }

	// 재요청사유
	function callbackGridRE_REQ_REASON(data) {
        grid.setCellValue(data.rowId, "RE_REQ_REASON", data.message);
        grid.checkRow(data.rowId, true);
    }

	// 삭제사유
	function callbackGridDELETE_REASON(data) {
        grid.setCellValue(data.rowId, "DELETE_REASON", data.message);
        grid.checkRow(data.rowId, true);
    }

	// 반려사유
    function callbackGridRETURN_REASON(data) {
        grid.setCellValue(data.rowId, "RETURN_REASON", data.message);
        grid.checkRow(data.rowId, true);
    }

    // 표준화담당자 이관사유
    // 접수 후 표준화담당자를 변경하는 경우 작성
    function callbackGridMOVE_REASON(data) {
        grid.setCellValue(data.rowId, "MOVE_REASON", data.message);
        grid.checkRow(data.rowId, true);
    }

    // 상품 표준화시 사용하는 상품 선택 팝업
	function callbackGridITEM_CD(data, rowId) {
        grid.setCellValue(rowId, "ITEM_CD", data[0].ITEM_CD);
    }

    function callbackGridMAKER_NM(data) {
        grid.setCellValue(data.rowId, "CMS_MAKER_CD", data.MKBR_CD);
        grid.setCellValue(data.rowId, "CMS_MAKER_NM", data.MKBR_NM);
        grid.setCellValue(data.rowId, "MAKER_NM", data.MKBR_NM);
    }

	/*function callbackGridCMS_BRAND_NM(data) {
        grid.setCellValue(data.rowId, "CMS_BRAND_CD", data.MKBR_CD);
        grid.setCellValue(data.rowId, "CMS_BRAND_NM", data.MKBR_NM);
    }*/

    function callbackGridITEM_CLS_NM(data) {
        if(data != null) {
            data = JSON.parse(data);
            grid.setCellValue(data.rowId, "ITEM_CLS1", data.ITEM_CLS1);
            grid.setCellValue(data.rowId, "ITEM_CLS2", data.ITEM_CLS2);
            grid.setCellValue(data.rowId, "ITEM_CLS3", data.ITEM_CLS3);
            grid.setCellValue(data.rowId, "ITEM_CLS4", data.ITEM_CLS4);
            grid.setCellValue(data.rowId, "ITEM_CLS_NM", data.ITEM_CLS_PATH_NM);
            grid.setCellValue(data.rowId, "SG_CTRL_USER_ID", data.SG_CTRL_USER_ID);
            grid.setCellValue(data.rowId, "SG_CTRL_USER_NM", data.SG_CTRL_USER_NM);
        } else {
            grid.setCellValue(data.rowId, "ITEM_CLS1", "");
            grid.setCellValue(data.rowId, "ITEM_CLS2", "");
            grid.setCellValue(data.rowId, "ITEM_CLS3", "");
            grid.setCellValue(data.rowId, "ITEM_CLS4", "");
            grid.setCellValue(data.rowId, "ITEM_CLS_NM", "");
            grid.setCellValue(data.rowId, "SG_CTRL_USER_ID", "");
            grid.setCellValue(data.rowId, "SG_CTRL_USER_NM", "");
        }
    }

	function doSearch() {

		var store = new EVF.Store();
		if (!store.validate()) { return; }

        store.setGrid([grid]);
		store.load(baseUrl + "im03010_doSearch", function() {
			if(grid.getRowCount() === 0) {
				return EVF.alert('${msg.M0002}');
			}
		});
	}

	// [미사용] 표준화담당자 할당 후 데이터 저장
	function doSave() {

        if(!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return EVF.alert(grid.validate().msg); }

        var rows = grid.getSelRowValue();
        for( var i = 0; i < rows.length; i++ ) {
            if(rows[i].PROGRESS_CD !== "100") {
                return EVF.alert("${IM03_010_005}");
            }
            if(rows[i].ORG_SG_CTRL_USER_ID !== "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                return EVF.alert("${IM03_010_004}");
            }
        }

        if (!confirm("${msg.M0021 }")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, "sel");
        store.load(baseUrl + "im03010_doSave", function() {
            EVF.alert(this.getResponseMessage());
            doSearch();
        });
    }

    // 담당자 할당, 표준화담당자 저장
    function doAssigmnent() {

        if(!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return EVF.alert(grid.validate().msg); }

        var rows = grid.getSelRowValue();
        var rowIds = grid.getSelRowId();
        for( var i = 0; i < rows.length; i++ ) {

            var rowId = rowIds[i];
            if(rows[i].PROGRESS_CD !== "100" && rows[i].PROGRESS_CD !== "300") { // 신규요청, 접수
                return EVF.alert("${IM03_010_001}");
            }

            if(rows[i].PROGRESS_CD === "300" && rows[i].MOVE_REASON === "") { // 접수인 건은 사유 입력 후 담당자 이관 가능
            	EVF.alert("${IM03_010_039}");
                var index = {
                    column: "MOVE_REASON",
                    itemIndex: rowId
                };
                grid._gvo.setCurrent(index);
                return;
            }

            if(rows[i].SG_CTRL_USER_ID === "" || rows[i].SG_CTRL_USER_ID === null) {
                EVF.alert("${IM03_010_003}");
                var index = {
                    column: "SG_CTRL_USER_ID",
                    itemIndex: rowId
                };
                grid._gvo.setCurrent(index);
                return;
            }
        }

        if (!confirm("${IM03_010_002}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, "sel");
        store.load(baseUrl + "im03010_doAssigmnent", function() {
            EVF.alert(this.getResponseMessage());
            doSearch();
        });
    }

    // 신규요청등록
    function doNewRequestReg() {
        var param = {
            callbackFunction: "callback_doNewRequestReg",
            detailView: false,
            popupFlag: true
        };
        everPopup.openPopupByScreenId("IM03_016", 1100, 500, param);
    }

    function callback_doNewRequestReg() {
        doSearch();
    }

    // 재접수 (접수 취소 후 다시 접수할 때 사용)
	function doItemMapping() {
		if (!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
		if (!grid.validate().flag)  { return EVF.alert(grid.validate().msg); }

		var rows   = grid.getSelRowValue();
       	var rowIds = grid.getSelRowId();
       	for( var i = 0; i < rows.length; i++ ) {
        	var rowId = rowIds[i];
			if (rows[i].ORG_SG_CTRL_USER_ID !== "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
            	EVF.alert("${IM03_010_004}");
               	return;
           	}

			// 접수반려
           	if(rows[i].PROGRESS_CD !== "100" && rows[i].ITEM_CD != '') {
            	EVF.alert("${IM03_010_041}");
               	return;
           	}

			// 품목코드 Mapping 여부
           	if(rows[i].ITEM_CD === "" || rows[i].ITEM_CD === null) {
            	EVF.alert("${IM03_010_007}");
               	var index = {
                   	column: "ITEM_CD",
                   	itemIndex: rowId
               	};
               	grid._gvo.setCurrent(index);
				return;
           	}
       	}

       	if (!confirm("${IM03_010_008}")) return;

       	var store = new EVF.Store();
       	store.setGrid([grid]);
       	store.getGridData(grid, "sel");
       	store.load(baseUrl + "im03010_doItemMapping", function() {
        	EVF.alert(this.getResponseMessage());
           	doSearch();
       	});
    }

    // 반려
    function doReject() {
        if(!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return EVF.alert(grid.validate().msg); }

        var rows = grid.getSelRowValue();
        var rowIds = grid.getSelRowId();
        for( var i = 0; i < rows.length; i++ ) {
            var rowId = rowIds[i];

            /* if(rows[i].ORG_SG_CTRL_USER_ID !== "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                EVF.alert("${IM03_010_004}");
                return;
            } */

            if(rows[i].PROGRESS_CD !== "100") {
                EVF.alert("${IM03_010_024}");
                return;
            }

            if(rows[i].RE_REQ_CODE === "" || rows[i].RE_REQ_CODE === null) {
                EVF.alert("${IM03_010_009}");
                var index = {
                    column: "RE_REQ_CODE",
                    itemIndex: rowId
                };
                grid._gvo.setCurrent(index);
                return;
            }

            if(rows[i].RE_REQ_REASON === "" || rows[i].RE_REQ_REASON === null) {
                EVF.alert("${IM03_010_010}");
                var param = {
                        title : "${IM03_010_031}",
                        message : grid.getCellValue(rowId, "RE_REQ_REASON"),
                        callbackFunction : "callbackGridRE_REQ_REASON",
                        detailView : detailView,
                        rowId : rowId
                    };
                var url = "/common/popup/common_text_input/view";
                everPopup.openModalPopup(url, 500, 320, param);
            }
        }

        if (!confirm("${IM03_010_011}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, "sel");
        store.load(baseUrl + "im03010_doReRequest", function() {
            EVF.alert(this.getResponseMessage());
            doSearch();
        });
    }

    // 접수(표준화)
    function doStandardization() {

        if(!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return EVF.alert(grid.validate().msg); }

        var rows = grid.getSelRowValue();

        if(rows.length > 1) {
            EVF.alert("${IM03_010_013}");
            return;
        }

        var ITEM_REQ_NO = "";
        var ITEM_REQ_SEQ = "";
        var CUST_CD = "";

        for( var i = 0; i < rows.length; i++ ) {

            /* if(rows[i].ORG_SG_CTRL_USER_ID !== "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                EVF.alert("${IM03_010_004}");
                return;
            } */

            if(rows[i].PROGRESS_CD !== "100") {
                EVF.alert("${IM03_010_024}");
                return;
            }

			if(rows[i].PROGRESS_CD !== "100") {
				EVF.alert("${IM03_010_024}");
				return;
			}

			if(rows[i].ITEM_CD != "") {
				EVF.alert("${IM03_010_040}");
				return;
			}

            ITEM_REQ_NO = rows[i].ITEM_REQ_NO;
            ITEM_REQ_SEQ = rows[i].ITEM_REQ_SEQ;
            CUST_CD = rows[i].CUST_CD;
        }
        var param = {
            ITEM_REQ_NO: ITEM_REQ_NO,
            ITEM_REQ_SEQ: ITEM_REQ_SEQ,
            CUST_CD: CUST_CD,
            callbackFunction: "doSearch",
            detailView: false,
            popupFlag: true
        };
        everPopup.openPopupByScreenId("IM03_015", 1000, 700, param);
    }

    function searchCUST_CD() {
        var param = {
            callBackFunction : "callbackCUST_CD"
        };
        everPopup.openCommonPopup(param, 'SP0902');
    }

    function callbackCUST_CD(data) {
        EVF.C("CUST_CD").setValue(data.CUST_CD);
        EVF.C("CUST_NM").setValue(data.CUST_NM);

        EVF.C("ADD_PLANT_CD").setValue("");
    	EVF.C("ADD_PLANT_NM").setValue("");
    }


    function onSearchPlant() {
		if( EVF.V("CUST_CD") == "" ) return EVF.alert("${IM03_010_035}");
		var param = {
	           callBackFunction : "_setPlant",
	           custCd: EVF.V("CUST_CD")
		};
		everPopup.openCommonPopup(param, 'SP0005');
    }

    function _setPlant(data) {
        jsondata = JSON.parse(JSON.stringify(data));
        EVF.C("ADD_PLANT_CD").setValue(jsondata.PLANT_CD);
        EVF.C("ADD_PLANT_NM").setValue(jsondata.PLANT_NM);
    }

	function searchADD_USER_ID() {
		if( EVF.V("CUST_CD") == "" ) return EVF.alert("${IM03_010_035}");
		var param = {
			callBackFunction : "callbackADD_USER_ID",
			custCd: EVF.V("CUST_CD"),
			plantCd: EVF.V("ADD_PLANT_CD")
		};
		everPopup.openCommonPopup(param, 'SP0083');
	}

	function callbackADD_USER_ID(data) {
		jsondata = JSON.parse(JSON.stringify(data));
		EVF.C("ADD_USER_ID").setValue(jsondata.USER_ID);
		EVF.C("ADD_USER_NM").setValue(jsondata.USER_NM);
	}
 </script>

	<e:window id="IM03_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="ADD_FROM_DATE" name="ADD_FROM_DATE" value="${ADD_FROM_DATE}" toDate="ADD_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
				<e:text> ~ </e:text>
					<e:inputDate id="ADD_TO_DATE" name="ADD_TO_DATE" value="${ADD_TO_DATE}" fromDate="ADD_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
				</e:field>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCUST_CD'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
                <e:label for="ADD_PLANT_CD" title="${form_ADD_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="ADD_PLANT_CD" name="ADD_PLANT_CD" value="" width="40%" maxLength="${form_ADD_PLANT_CD_M}" disabled="${form_ADD_PLANT_CD_D}" readOnly="${form_ADD_PLANT_CD_RO}" required="${form_ADD_PLANT_CD_R}" onIconClick="onSearchPlant" />
                    <e:inputText id="ADD_PLANT_NM" name="ADD_PLANT_NM" value="" width="60%" maxLength="${form_ADD_PLANT_NM_M}" disabled="${form_ADD_PLANT_NM_D}" readOnly="${form_ADD_PLANT_NM_RO}" required="${form_ADD_DEPT_NM_R}" />
                </e:field>
			</e:row>
            <e:row>
				<e:label for="ADD_USER_ID" title="${form_ADD_USER_ID_N}"/>
				<e:field>
					<e:search id="ADD_USER_ID" name="ADD_USER_ID" value="" width="40%" maxLength="${form_ADD_USER_ID_M}" onIconClick="searchADD_USER_ID" disabled="${form_ADD_USER_ID_D}" readOnly="${form_ADD_USER_ID_RO}" required="${form_ADD_USER_ID_R}" />
					<e:inputText id="ADD_USER_NM" name="ADD_USER_NM" value="" width="60%" maxLength="${form_ADD_USER_NM_M}" disabled="${form_ADD_USER_NM_D}" readOnly="${form_ADD_USER_NM_RO}" required="${form_ADD_USER_NM_R}" />
				</e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false" />
                </e:field>

				<e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${ses.userId}" options="${SG_CTRL_USER_ID_Options}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="ITEM_REQ_NO" title="${form_ITEM_REQ_NO_N}" />
                <e:field>
                    <e:inputText id="ITEM_REQ_NO" name="ITEM_REQ_NO" value="" width="${form_ITEM_REQ_NO_W}" maxLength="${form_ITEM_REQ_NO_M}" disabled="${form_ITEM_REQ_NO_D}" readOnly="${form_ITEM_REQ_NO_RO}" required="${form_ITEM_REQ_NO_R}" />
                </e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
                <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
                <e:field>
                    <e:inputText id="MAKER_NM" name="MAKER_NM" value="" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
                </e:field>
            </e:row>
			<%--
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="STD_FLAG" title="${form_STD_FLAG_N}"/>
                <e:field>
                    <e:select id="STD_FLAG" name="STD_FLAG" value="" options="${stdFlagOptions}" width="${form_STD_FLAG_W}" disabled="${form_STD_FLAG_D}" readOnly="${form_STD_FLAG_RO}" required="${form_STD_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field>
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
                <e:label for="MODEL_NM" title="${form_MODEL_NM_N}" />
                <e:field>
                    <e:inputText id="MODEL_NM" name="MODEL_NM" value="" width="${form_MODEL_NM_W}" maxLength="${form_MODEL_NM_M}" disabled="${form_MODEL_NM_D}" readOnly="${form_MODEL_NM_RO}" required="${form_MODEL_NM_R}" />
                </e:field>
            </e:row>
 			--%>
		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
            <e:panel>
	            <e:button id="Assigmnent" name="Assigmnent" label="${Assigmnent_N}" onClick="doAssigmnent" disabled="${Assigmnent_D}" visible="${Assigmnent_V}"/>
			</e:panel>

			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Standardization" name="Standardization" label="${Standardization_N}" onClick="doStandardization" disabled="${Standardization_D}" visible="${Standardization_V}"/>
			<e:button id="Reject" name="Reject" label="${Reject_N}" onClick="doReject" disabled="${Reject_D}" visible="${Reject_V}"/>
			<e:button id="ItemMapping" name="ItemMapping" label="${ItemMapping_N}" onClick="doItemMapping" disabled="${ItemMapping_D}" visible="${ItemMapping_V}"/>
            <e:button id="NewRequestReg" name="NewRequestReg" label="${NewRequestReg_N}" onClick="doNewRequestReg" disabled="${NewRequestReg_D}" visible="${NewRequestReg_V}"/>

			<%--
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            <e:button id="Reply" name="Reply" label="${Reply_N}" onClick="doReply" disabled="${Reply_D}" visible="${Reply_V}"/>
            <e:button id="ReRequest" name="ReRequest" label="${ReRequest_N}" onClick="doReRequest" disabled="${ReRequest_D}" visible="${ReRequest_V}"/>
            <e:button id="NotStandardization" name="NotStandardization" label="${NotStandardization_N}" onClick="doNotStandardization" disabled="${NotStandardization_D}" visible="${NotStandardization_V}"/>
            <e:button id="Delete" name="Delete" label="${Delete_N}" onClick="doDelete" disabled="${Delete_D}" visible="${Delete_V}"/>
 			--%>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>