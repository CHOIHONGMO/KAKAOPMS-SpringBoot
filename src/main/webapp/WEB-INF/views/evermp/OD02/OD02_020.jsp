<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD02/OD0201/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;

                if(colId === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO")
                        };
                        everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
                    }
                } else if (colId == "CPO_SEQ") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if(colId == "CPO_USER_NM") {
                    if( grid.getCellValue(rowId, "CPO_USER_ID") == "" ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == "DELY_DELAY_NM") { // 납품지연상세사유
                    var delyCd = grid.getCellValue(rowId, "DELY_DELAY_CD");
                    if( delyCd == "" ) return;
                    param = {
                        title: "납품지연사유",
                        CODE: grid.getCellValue(rowId, "DELY_DELAY_CD"),
                        TEXT: grid.getCellValue(rowId, "DELY_DELAY_REASON"),
                        rowId: rowId,
                        detailView: "true"
                    };
                    var url = "/evermp/SIV1/SIV101/SIV1_022/view";
                    everPopup.openModalPopup(url, 600, 360, param);
                } else if(colId == "MANAGE_NM") { // 진행관리담당자
                    if( grid.getCellValue(rowId, "MANAGE_ID") == "" ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, "MANAGE_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == "RECIPIENT_NM") { // 인수자
                    if( grid.getCellValue(rowId, "RECIPIENT_NM") == "" ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ"),
                        detailView: "true"
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colId == "REQ_TEXT") { // 주문요청사항
                    if( grid.getCellValue(rowId, "REQ_TEXT") == "" ) return;
                    param = {
                        title: "주문요청사항",
                        message: grid.getCellValue(rowId, "REQ_TEXT"),
                        detailView: true,
                        rowId: rowId
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                } else if(colId == "ATTACH_FILE_CNT") { // 주문 첨부파일 업로드
                    if( grid.getCellValue(rowId, "ATTACH_FILE_CNT") == "0" ) return;
                    everPopup.readOnlyFileAttachPopup("CPO", grid.getCellValue(rowId, "ATTACH_FILE_NO"), "", rowId);
                } else if(colId == "AGENT_ATTACH_FILE_CNT") {
                    if( grid.getCellValue(rowId, "AGENT_ATTACH_FILE_CNT") == "0" ) return;
                    everPopup.readOnlyFileAttachPopup("CPO", grid.getCellValue(rowId, "AGENT_ATTACH_FILE_NO"), "", rowId);
                } else if (colId == "VENDOR_NM") {
                    param = {
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        detailView: true,
                        popupFlag: true
                    };

                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if(colId == "ITEM_CD") {
                    param = {
                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                        popupFlag: true,
                        detailView: true
                    };
                    everPopup.im03_014open(param);
                } else if(colId == "IF_INVC_CD") {
                    var invList = [];
                    invList.push( grid.getCellValue(rowId, "IF_INVC_CD") );

                    // 운영사용 거래명세서
                    param = {
                    		IF_INVC_CD: grid.getCellValue(rowId, "IF_INVC_CD")
                    };
                    everPopup.openWindowPopup("/evermp/print/PRT_041/view.so?#toolbar=1&navpanes=1", 976, 800, param, "", true, true);
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                } else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                if (colId == "INV_QTY") {
                    var unitPrice = Number(grid.getCellValue(rowId, "PO_UNIT_PRICE"));
                    var invQty = Number(grid.getCellValue(rowId, "INV_QTY"));
                    grid.setCellValue(rowId, "IV_ITEM_AMT", unitPrice * invQty);
                }
            });

            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });
            if("${param.autoSearchFlag}" == "Y") {

                //EVF.C("START_DATE").setValue("");
                //EVF.C("END_DATE").setValue("");

                var store = new EVF.Store();
                store.setGrid([grid]);
                store.setParameter("autoSearchFlag", "${param.autoSearchFlag}");
                store.load(baseUrl + "OD02_020/doSearch", function () {
                    if(grid.getRowCount() == 0) {
                        return alert("${msg.M0002}");
                    }
                });
            }

            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);
            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);

            grid.freezeCol("GR_COMPLETE_FLAG");

            grid.setColMerge(["PO_NO","PO_SEQ","PR_SUBJECT","CUST_ITEM_CD","ITEM_CD","ITEM_DESC","ITEM_SPEC","MAKER_NM","UNIT_CD","CUR","CPO_NO","CPO_SEQ","CPO_QTY"
            	,'CPO_UNIT_PRICE'
            	,'TEMP_PO_UNIT_PRICE'
            	,"BF_INV_QTY"
            ]);

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "OD02_020/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                var rowIds = grid.getAllRowId();
                for (var i =0 ; i< rowIds.length; i++){
                	if(grid.getCellValue(rowIds[i], "DELY_COMPLETE_FLAG") == '1')
                		{grid.setCellFontColor(rowIds[i], 'DELY_COMPLETE_FLAG', "#ff4c29");}
                	if(grid.getCellValue(rowIds[i], "GR_COMPLETE_FLAG") == '1')
                		{grid.setCellFontColor(rowIds[i], 'GR_COMPLETE_FLAG', "#ff4c29");}
                }
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var cpoNo    = ""; // 주문번호
            var cpoQty   = 0; // 주문수량
            var bfInvQty = 0; // 기납품수량
            var invQty   = 0; // 납품수량
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	/*if(grid.getCellValue(rowIds[i], 'MANAGE_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0240_0008}");
                }*/

            	<%--동일한 주문에 대해 납품서 변경 가능 --%>
                if( cpoNo != "" && cpoNo != grid.getCellValue(rowIds[i], 'CPO_NO') ) {
                    return alert("${OD02_020_008 }");
                }

                cpoNo = grid.getCellValue(rowIds[i], 'CPO_NO');
                <%--납품완료시 오류 --%>
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${OD02_020_004 }");
                }

                cpoQty   = Number(grid.getCellValue(rowIds[i], 'CPO_QTY'));
                bfInvQty = Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY'));
                invQty   = Number(grid.getCellValue(rowIds[i], 'INV_QTY'));

                if( grid.getCellValue(rowIds[i], 'FORCE_CLOSE_YN') == "1" ) {
                    return alert("${OD02_020_028 }");
                }




                if(cpoQty > 0) {
                    <%--납품수량 > 0 --%>
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) <= 0 ) {
                        return alert("${OD02_020_005}");
                    }

                    <%--납품수량 + 기납품수량 < 주문수량 --%>
                    if( (bfInvQty + invQty) > cpoQty ) {
                        //return alert("${OD02_020_007 }");
                    }
                } else {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) >= 0 ) {
                        return alert("${OD02_020_005}");
                    }

                    if( (bfInvQty + invQty) < cpoQty ) {
                        return alert("${OD02_020_007 }");
                    }
                }
			}

            if (!confirm("${OD02_020_002 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_020/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	/*if(grid.getCellValue(rowIds[i], 'MANAGE_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0240_0008}");
                }*/
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${OD02_020_004 }");
                }
                if( grid.getCellValue(rowIds[i], 'GR_NO') != '') {
                    return alert("${OD02_020_024 }");
                }
            }

            if (!confirm("${OD02_020_003 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_020/doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        <%--프린트 --%>
        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var invList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                invList.push( grid.getCellValue(rowIds[i], 'IV_NO') );
            }

            var params = {
                printList: JSON.stringify(invList)
            };

            var url = "/evermp/print/PRT_041/view.so?#toolbar=1&navpanes=1";
            everPopup.openWindowPopup(url, 976, 800, params, '', true, true);
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
            //chgCustCd();
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${OD02_020_001}");
            var param = {
                callBackFunction : "callBackPlant",
                custCd: EVF.V("CUST_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
        }


        function searchCustDeptCd() {
            var custCd = EVF.V("CUST_CD");
            var custNm = EVF.V("CUST_NM");

            if( custCd == "" ) {
                alert("${OD02_020_001}");
                return;
            }

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "selectCustDeptCd",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : custCd,
                'custNm' : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function selectCustDeptCd(dataJsonArray) {
            data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS3);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCustUserId() {
            var custCd = EVF.V("CUST_CD");
            if( custCd == "" ) {
                alert("${OD02_020_001}");
                return;
            }

            var param = {
                callBackFunction: "selectCustUserId",
                custCd: custCd
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function selectCustUserId(dataJsonArray) {
            EVF.C("CPO_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CPO_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowValue = grid.getSelRowValue();
            var IV_NO = "";

            for( var i in selRowValue) {
                if(IV_NO.indexOf(selRowValue[i].IV_NO) < 0) {
                    if(i == 0) {
                        IV_NO = selRowValue[i].IV_NO;
                    } else {
                        IV_NO += "," + selRowValue[i].IV_NO;
                    }
                }
            }

            var localFlag = ${localFlag};
            var host_info;
            var oz80_url;

            if(localFlag) {
                host_info = location.protocol + "//" + location.hostname + ":" + location.port;
                oz80_url = location.protocol + "//" + location.hostname + ":" + "7070/oz80";
            } else {
                host_info = location.protocol + "//" + location.hostname;
                oz80_url = location.protocol + "//" + location.hostname + ":" + "7071/oz80";
            }


            var param = {
                IV_NO: IV_NO,
                HOST_INFO: oz80_url,
                OZ80_URL: oz80_url
            };

            var url = oz80_url + "/ozhviewer/IV_SourcingEstimate.jsp";
            everPopup.openWindowPopup(url, 1000, 700, param, "", true);
        }

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var delyDate = EVF.V("DELY_COMPLETE_DATE");
            if( delyDate == "" || delyDate.length != 8 ) {
                EVF.C("DELY_COMPLETE_DATE").setFocus();
                return alert("${OD02_020_007 }");
            }
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], 'DELY_COMPLETE_DATE', delyDate);
            }
        }

        // 납품완료
        function doComplete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	/*if(grid.getCellValue(rowIds[i], 'MANAGE_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0240_0008}");
                }*/
                if( grid.getCellValue(rowIds[i], 'FORCE_CLOSE_YN') == "1" ) {
                    return alert("${OD02_020_028 }");
                }
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${OD02_020_004 }");
                }
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_DATE') == '' ) {
                    return alert("${OD02_020_026 }");
                }
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_DATE') > '${addToDate }' ) {
                    return alert("${OD02_020_021 }");
                }
            }

            if (!confirm("${OD02_020_022 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_030/doCompleteDely', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 납품완료 취소
        function doCancel() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var dgnsCnt = 0;
            var rowIds  = grid.getSelRowId();
            for( var i in rowIds ) {
            	/*if(grid.getCellValue(rowIds[i], 'MANAGE_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0240_0008}");
                }*/
                if( grid.getCellValue(rowIds[i], 'FORCE_CLOSE_YN') == "1" ) {
                    return alert("${OD02_020_028 }");
                }
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') != "1" ) {
                    return alert("${OD02_020_023 }");
                /**
                 * DGNS 납품건 : IF_FLAG='2'인 경우 납품완료 취소 가능*/
                } else {
                	if( grid.getCellValue(rowIds[i], 'IF_CPO_NO') != "" ) {
                		//return alert("${OD02_020_027 }");
                		dgnsCnt = 1;
                	}
                }
                if( grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${OD02_020_024 }");
                }
                if( grid.getCellValue(rowIds[i], 'GR_NO') != "" ) {
                    return alert("${OD02_020_024 }");
                }
            }

            //2023.01.27: DGNS 주문건이 포함되어 있을 경우 납품완료 취소 추가
            if (!confirm(((dgnsCnt>0)?"DGNS 주문건이 포함되어 있습니다.\n\n":"") + "${OD02_020_025 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_030/doCancelDely', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function chgCustCd() {
            var store = new EVF.Store;
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
                    EVF.C('DIVISION_CD').setOptions([]);
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }

        function chgPlantCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "100");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DIVISION_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }

        function chgDivisionCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "200");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DEPT_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }

        function chgDeptCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "300");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('PART_CD').setOptions(this.getParameter("divisionDeptPartCd"));
            	}
            });
        }

		function doPoCancel() {

			if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                /*if(grid.getCellValue(rowIds[i], 'MANAGE_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0240_0008}");
                }*/
                if( grid.getCellValue(rowIds[i], 'FORCE_CLOSE_YN') == "1" ) {
                    return alert("${OD02_020_028 }");
                }

            	if(grid.getCellValue(rowIds[i], "PROGRESS_CD") != "6100") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0240_0029}");
                }

                if(grid.getCellValue(rowIds[i], 'FORCE_CLOSE_DATE') != "") {
                    return alert("${PO0240_0034}");
                }


            }

            if(!confirm('${PO0240_0031}')) { return; }
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", '5100'); // 확정대기
            store.load(baseUrl + 'PO0240_doPoCancel', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
		}

    </script>

    <e:window id="OD02_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                </e:field>
                <e:label for="DDP_CD" title="${form_DDP_CD_N}" />
                <e:field>
                    <e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
                </e:field>
            </e:row>
            <e:row>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
					<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="60%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="G" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${ses.userId}" options="${sgCtrlUserIdOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
				<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="6120"/>

                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD02_020_0001}" value="CPO_DATE"/>
                        <e:option text="${OD02_020_0002}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${empty param.yesterday ? addFromDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${empty param.yesterday ? addToDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
					<e:inputHidden id="ITEM_CD" name="ITEM_CD"/>
					<e:inputHidden id="MAKER_CD" name="MAKER_CD"/>
					<e:inputHidden id="DELY_REJECT_CD" name="DELY_REJECT_CD"/>
					<e:inputHidden id="DOC_NUM_COMBO" name="DOC_NUM_COMBO"/>
					<e:inputHidden id="DOC_NUM" name="DOC_NUM"/>
					<e:inputHidden id="DEAL_CD" name="DEAL_CD"/>
                </e:field>
				<e:label for="DELY_COMPLETE_FLAG" title="${form_DELY_COMPLETE_FLAG_N}"/>
				<e:field>
					<e:select id="DELY_COMPLETE_FLAG" name="DELY_COMPLETE_FLAG" value="" options="${delyCompleteFlagOptions}" width="${form_DELY_COMPLETE_FLAG_W}" disabled="${form_DELY_COMPLETE_FLAG_D}" readOnly="${form_DELY_COMPLETE_FLAG_RO}" required="${form_DELY_COMPLETE_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="GR_COMPLETE_FLAG" title="${form_GR_COMPLETE_FLAG_N}"/>
				<e:field>
					<e:select id="GR_COMPLETE_FLAG" name="GR_COMPLETE_FLAG" value="" options="${grCompleteFlagOptions}" width="${form_GR_COMPLETE_FLAG_W}" disabled="${form_GR_COMPLETE_FLAG_D}" readOnly="${form_GR_COMPLETE_FLAG_RO}" required="${form_GR_COMPLETE_FLAG_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
			<e:text style="color:red;font-weight:bold;font-size:10pt;">※ 납품완료일 : </e:text>
            <e:inputDate id="DELY_COMPLETE_DATE" name="DELY_COMPLETE_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_DELY_COMPLETE_DATE_R}" disabled="${form_DELY_COMPLETE_DATE_D}" readOnly="${form_DELY_COMPLETE_DATE_RO}" />
            <e:text>&nbsp;</e:text>
            <e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}" align="left"/>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>

			<e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
			<%-- 2022.12.13 : 납품완료시 dgns i/f, 납품 완료 후 "취소" 불가능--%>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>