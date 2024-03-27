<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BGA1/";
		var ROW_ID;
		var mngYn = "${ses.mngYn}";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
				ROW_ID = rowId;

	        	if(colId === "CPO_USER_NM") {
	        		if(grid.getCellValue(rowId, "CPO_USER_ID") == "") {

					} else {
                        var param = {
                            callbackFunction: "",
                            USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
					}
	        	} else if(colId === "CPO_NO") {
                    var param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if(colId === "ITEM_CD") {
	                if(value !== ""){
	                    var param = {
	                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
	                        popupFlag: true,
	                        detailView: true
	                    };
	                    everPopup.im03_014open(param);
	                }
	            } else if(colId === "REQ_TEXT_YN") {
                    if(value !== "") {
                        var param = {
                            title: "${BGA1_010_001}",
                            callbackFunction: "callbackGridREQ_TEXT",
                            message: grid.getCellValue(rowId, "REQ_TEXT"),
                            detailView: true,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";

                        everPopup.openModalPopup(url, 500, 330, param);
                    }
                } else if(colId === "ATTACH_FILE_NO_IMG") {
                    var attFileNum = grid.getCellValue(rowId, "ATTACH_FILE_NO");

                    if(value > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: attFileNum,
                            rowId: rowId,
                            callBackFunction: "callbackGridATTACH_FILE_NO",
                            bizType: "OM",
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                } else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                } else if(colId == "IF_INVC_CD") {
                    var invList = [];
                    invList.push( grid.getCellValue(rowId, "IF_INVC_CD") );

                    var ifInvcCd = grid.getCellValue(rowId, "IF_INVC_CD");
                    param = {
                    		IF_INVC_CD: ifInvcCd
                    };

					if(ifInvcCd.substring(0,1) == 'V') {
	                    everPopup.openWindowPopup("/evermp/print/PRT_041/view.so?#toolbar=1&navpanes=1", 976, 800, param, "", true, true);
					} else {
	                    everPopup.openWindowPopup("/evermp/print/PRT_042/view.so?#toolbar=1&navpanes=1", 976, 800, param, "", true, true);
					}

                }
            });



            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
            	if(colId === "GR_DATE") {
                    if( grid.getCellValue(rowId, 'GR_DATE') > '${END_DATE}' ) {
                        grid.setCellValue(rowId, 'GR_DATE', oldValue);
                        return alert("${BGA1_010_015 }");
                    }
            	}

            	if(colId === "GR_QTY" && value !== oldValue) {
                    if(value == 0) {
                        alert("${BGA1_010_008}");
                        grid.setCellValue(rowId, "GR_QTY", oldValue);
                        grid.checkRow(rowId, false);
                        return;
                    }

				    var AV_GR_QTY =  Number(grid.getCellValue(rowId, "AV_GR_QTY"));

				    if(AV_GR_QTY > 0) {
                        if(AV_GR_QTY < value) {
                            alert("${BGA1_010_002}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                        if(value <= 0) {
                            alert("${BGA1_010_008}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }
					} else {
                        if(AV_GR_QTY > value) {
                            alert("${BGA1_010_007}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                        if(value >= 0) {
                            alert("${BGA1_010_008}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }
					}

					var CPO_UNIT_PRICE = Number(grid.getCellValue(rowId, "CPO_UNIT_PRICE"));
					var GR_AMT = CPO_UNIT_PRICE * value;

					grid.setCellValue(rowId, "GR_AMT", GR_AMT);

					var PO_UNIT_PRICE = Number(grid.getCellValue(rowId, "PO_UNIT_PRICE"));
					var PO_ITEM_AMT = PO_UNIT_PRICE * value;

					grid.setCellValue(rowId, "PO_ITEM_AMT", PO_ITEM_AMT);
				}
            });

            grid.setColIconify("REQ_TEXT_YN", "REQ_TEXT", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            var val = {visible: true, count: 1, height: 40};
            var footerTxt = {
                styles: {
                    textAlignment: "center",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: ["합 계"],
            };
            var footerSum = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    numberFormat: "###,###",
                    fontBold: true
                },
                text: "",
                expression: ["sum"],
                groupExpression: "sum"
            };
            grid.setProperty("footerVisible", val);
            grid.setRowFooter("CPO_UNIT_PRICE", footerTxt);
            grid.setRowFooter("GR_AMT", footerSum);

            grid.setColMerge(["PLANT_NM","DEPT_NM", "CPO_USER_NM", "REF_MNG_NO", "CPO_NO", "CPO_SEQ", "PO_NO", "PO_SEQ", "CUST_ITEM_CD", "ITEM_CD", "ITEM_DESC", "ITEM_SPEC",
							  "MAKER_NM", "MAKER_PART_NO", "BRAND_NM", "ORIGIN_NM", "UNIT_CD", "CPO_QTY", "CUR", "VENDOR_CD", "VENDOR_NM",
							  "BD_DEPT_CD", "BD_DEPT_NM", "ACCOUNT_CD", "CPO_DATE", "HOPE_DUE_DATE", "RECIPIENT_NM",
							  "RECIPIENT_DEPT_NM", "RECIPIENT_TEL_NUM", "RECIPIENT_CELL_NUM", "CSDM_SEQ", "DELY_NM", "DELY_ZIP_CD", "DELY_ADDR_1", "DELY_ADDR_2",
							  "REQ_TEXT_YN", "ATTACH_FILE_NO_IMG"
			]);
            if("${param.autoSearchFlag}" == "Y") { doSearch(); }

			//1. 시스템관리자 : 전체 권한
			//2. 직무의 관리자, 구매담당자 : 자신이 속한 사업장 업무만 처리할 수 있음
			//3. 나머지 : 자신이 요청한 건만 처리 가능
			if( '${superUserFlag}' != 'true' ) {
				EVF.C('PLANT_CD').setDisabled(true);
				EVF.C('PLANT_NM').setDisabled(true);
				if( '${havePermission}' == 'true' ) {
					EVF.C('DDP_CD').setDisabled(false);// 사업부

					EVF.C("CPO_USER_ID").setDisabled(false);// 주문자ID
					EVF.C("CPO_USER_NM").setDisabled(false);// 주문자명
				} else {
					EVF.C('DDP_CD').setDisabled(true);	// 사업부

					EVF.C("CPO_USER_ID").setDisabled(true);
					EVF.C("CPO_USER_NM").setDisabled(true);
				}
			}

            grid.freezeCol("CPO_USER_NM");

			var store = new EVF.Store();
			store.load("/evermp/BOD1/BOD102/bod1020_doSearchPLANT", function() {
				var PLANT_CD_Options =  JSON.parse(this.getParameter("PLANT_CD_Options"));

				EVF.C("PLANT_CD").setOptions(PLANT_CD_Options);
			});

			//chgCustCd();
			doSearch();
        }

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
            grid.checkRow(data.rowId, true);
		}

        function callbackGridATTACH_FILE_NO(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, 'ATTACH_FILE_NO', uuid);
			grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', fileCount);
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "bga1010_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doGrSave() {

            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
               if(rows[i].IF_CPO_NO != "") {
                   alert("${BGA1_010_016}");
                   return;
               }
               if(rows[i].CPO_USER_ID != '${ses.userId}' && '${ses.mngYn}' != '1') {
                   alert("${BGA1_010_017}");
                   return;
               }
           }

            if(!confirm("${BGA1_010_004}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "bga1010_doGrSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
		}

        function searchDEPT_CD() {
        	if( mngYn != '1' ) { return; }
            var custCd = EVF.V("CUST_CD");
			var custNm = "${ses.companyNm }";

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "callbackDEPT_CD",
                AllSelectYN: true,
                detailView: false,
                multiYN: false,
                ModalPopup: true,
                custCd : custCd,
                custNm : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function callbackDEPT_CD(dataJsonArray) {
        	data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS3);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCPO_USER_ID() {
        	var custCd = EVF.V("CUST_CD");

        	var param = {
        			callBackFunction: "callbackCPO_USER_ID",
        			custCd: custCd
                };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function callbackCPO_USER_ID(data) {
            EVF.C("CPO_USER_ID").setValue(data.USER_ID);
            EVF.C("CPO_USER_NM").setValue(data.USER_NM);
        }

        function searchVENDOR_CD() {
            var param = {
                callBackFunction : "callbackVENDOR_CD"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function callbackVENDOR_CD(data) {
            EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
        }

        function searchMAKER_CD(){
            var param = {
                callBackFunction : "callbackMAKER_CD"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function callbackMAKER_CD(data) {
            EVF.V("MAKER_CD",data.MKBR_CD);
            EVF.V("MAKER_NM",data.MKBR_NM);
        }

        function searchBRAND_CD(){
            var param = {
                callBackFunction : "callBackBRAND_CD"
            };
            everPopup.openCommonPopup(param, 'SP0088');
        }

        function callBackBRAND_CD(data) {
            EVF.V("BRAND_CD", data.MKBR_CD);
            EVF.V("BRAND_NM", data.MKBR_NM);
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

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            var delyDate = EVF.V("GR_DATE");

            if( delyDate > '${END_DATE}' ) {
                return alert("${BGA1_010_015 }");
            }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], 'GR_DATE', delyDate);
            }
        }

		function onSearchPlant() {
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

    </script>

    <e:window id="BGA1_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd }" />
            <e:row>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="${ses.plantCd}" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" name="PLANT_NM" value="${ses.plantNm}" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
				<e:label for="DDP_CD" title="${form_DDP_CD_N}" />
				<e:field>
					<e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
				</e:field>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="${CPO_USER_ID}" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="${CPO_USER_NM}" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${BGA1_010_013}" value="CPO_DATE"/>
                        <e:option text="${BGA1_010_014}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${empty param.fromDate ? START_DATE : param.fromDate}" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${empty param.toDate ? END_DATE : param.toDate}" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputText id="CPO_NO" name="CPO_NO" value="" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				</e:field>
				<e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
				<e:field>
					<e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
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
        </e:searchPanel>

		<e:buttonBar align="left" width="100%">
			<e:text style="font-weight:bold;">${form_GR_DATE_N} : </e:text>
			<e:inputDate id="GR_DATE" name="GR_DATE" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_GR_DATE_R}" disabled="${form_GR_DATE_D}" readOnly="${form_GR_DATE_RO}" />
			<e:text>&nbsp;&nbsp;</e:text>
			<e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>

			<e:button id="doGrSave" name="doGrSave" label="${doGrSave_N}" onClick="doGrSave" disabled="${GR_FLAG_D}" visible="${doGrSave_V}" align="right"/>
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" align="right"/>
		</e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>