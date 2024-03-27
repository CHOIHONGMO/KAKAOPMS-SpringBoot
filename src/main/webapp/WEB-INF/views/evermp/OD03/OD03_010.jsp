<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD03/";
		var ROW_ID;

        function init() {
            grid = EVF.C("grid");
            //grid.setProperty('sortable', true);

            if('${form.autoSearchFlag}' == 'Y') {
				EVF.V('START_DATE', '${param.fromDate}');
				EVF.V('END_DATE', '${param.toDate}');

                var store = new EVF.Store();

                store.setGrid([grid]);
                store.load(baseUrl + "od03010_doSearch", function () {
                    if(grid.getRowCount() == 0) {
                        return alert('${msg.M0002}');
                    }
                });
            }
            EVF.C("PR_TYPE").removeOption("R");


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
	        	} else if(colId === 'CPO_NO'){
					if(value !== ""){
						param = {
							callbackFunction: "",
							CPO_NO: grid.getCellValue(rowId, "CPO_NO")
						};
						everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
					}
				} else if(colId === "CPO_SEQ") {
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
                            title: "${OD03_010_001}",
                            callbackFunction: "callbackGridREQ_TEXT",
                            message: grid.getCellValue(rowId, "REQ_TEXT"),
                            detailView: false,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";

                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                } else if(colId === "ATTACH_FILE_NO_IMG") {
                    var attFileNum = grid.getCellValue(rowId, "ATTACH_FILE_NO");

                    if(value > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: attFileNum,
                            rowId: rowId,
                            callBackFunction: "callbackGridATTACH_FILE_NO",
                            bizType: "DGM",
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                } else if(colId === "GR_AGENT_ATTFILE_NUM_CNT") {
                    var attFileNum = grid.getCellValue(rowId, "GR_AGENT_ATTFILE_NUM");

					var param = {
						havePermission: true,
						attFileNum: attFileNum,
						rowId: rowId,
						callBackFunction: "callbackGridGR_AGENT_ATTFILE_NUM",
						bizType: "DGM",
						fileExtension: '*'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                } else if(colId == "AM_USER_NM") { // 진행관리담당자
					if( grid.getCellValue(rowId, "AM_USER_ID") == "" ) return;
					param = {
						callbackFunction: "",
						USER_ID: grid.getCellValue(rowId, "AM_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
				if(colId === "GR_QTY" && value !== oldValue) {
				    if(value == 0) {
                        alert("${OD03_010_009}");
                        grid.setCellValue(rowId, "GR_QTY", oldValue);
                        grid.checkRow(rowId, false);
                        return;
					}

				    var AV_GR_QTY =  Number(grid.getCellValue(rowId, "AV_GR_QTY"));

                    if(AV_GR_QTY > 0) {
                        if(AV_GR_QTY < value) {
                            alert("${OD03_010_002}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                        if(value <= 0) {
                            alert("${OD03_010_009}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                    } else {
                        if(AV_GR_QTY > value) {
                            alert("${OD03_010_008}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                        if(value >= 0) {
                            alert("${OD03_010_009}");
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

            /*
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
			*/

/*            grid.setColMerge(["CUST_NM", "DEPT_NM", "CPO_USER_NM", "REF_MNG_NO", "CPO_NO", "CPO_SEQ", "PO_NO", "PO_SEQ", "CUST_ITEM_CD", "ITEM_CD", "ITEM_DESC", "ITEM_SPEC",
							  "MAKER_NM", "MAKER_PART_NO", "BRAND_NM", "ORIGIN_NM", "UNIT_CD", "CPO_QTY", "CUR", "VENDOR_NM",
							  "BD_DEPT_CD", "BD_DEPT_NM", "ACCOUNT_CD", "ACCOUNT_NM", "CPO_DATE", "HOPE_DUE_DATE", "RECIPIENT_NM",
							  "RECIPIENT_DEPT_NM", "RECIPIENT_TEL_NUM", "RECIPIENT_CELL_NUM", "DELY_ZIP_CD", "DELY_ADDR_1", "DELY_ADDR_2",
							  "PRIOR_GR_FLAG_NM", "REQ_TEXT_YN", "ATTACH_FILE_NO_IMG"]);

            grid.freezeCol("CPO_NO_SEQ");*/
            doSearch();
        }

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
            grid.checkRow(data.rowId, true);
		}

        function callbackGridATTACH_FILE_NO(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, "ATTACH_FILE_NO", uuid);
			grid.setCellValue(rowId, "ATTACH_FILE_NO_IMG", fileCount);
        }

        function callbackGridGR_AGENT_ATTFILE_NUM(rowId, uuid, fileCount) {
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM", uuid);
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM_CNT", fileCount);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "od03010_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doGrSave() {
            var store = new EVF.Store();

            if(!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
           	for( var i in rowIds ) {
           		/*
            	if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                	return alert("${msg.M0008}");
                }
                */

                if(grid.getCellValue(rowIds[i], 'IF_CPO_NO') != "") {
                	return alert("${OD03_010_0012}");
                }
           	}

            if(!confirm("${OD03_010_004}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "od03010_doGrSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
		}

        function searchDEPT_CD() {
            var custCd = EVF.V("CUST_CD");
			var custNm = EVF.V("CUST_NM");

            if(custCd == "") {
                alert("${OD03_010_006}");
                return;
			}

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
            EVF.V("DEPT_CD", data.ITEM_CLS3);
            EVF.V("DEPT_NM", data.ITEM_CLS_NM);
        }

        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${OD03_010_006}");
                return;
            }

        	var param = {
        			callBackFunction: "callbackCPO_USER_ID",
        			custCd: custCd
                };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function callbackCPO_USER_ID(data) {
            EVF.V("CPO_USER_ID", data.USER_ID);
            EVF.V("CPO_USER_NM", data.USER_NM);
        }

        function searchVENDOR_CD() {
            var param = {
                callBackFunction: "callbackVENDOR_CD"
            };
            everPopup.openCommonPopup(param, "SP0063");
        }

        function callbackVENDOR_CD(data) {
            EVF.V("VENDOR_CD", data.VENDOR_CD);
            EVF.V("VENDOR_NM", data.VENDOR_NM);
        }

        function searchMAKER_CD(){
            var param = {
                callBackFunction: "callbackMAKER_CD"
            };
            everPopup.openCommonPopup(param, "SP0068");
        }

        function callbackMAKER_CD(data) {
            EVF.V("MAKER_CD", data.MKBR_CD);
            EVF.V("MAKER_NM", data.MKBR_NM);
        }

        function searchCUST_CD() {
            var param = {
                callBackFunction: "callbackCUST_CD"
            };
            everPopup.openCommonPopup(param, "SP0902");
        }

        function callbackCUST_CD(data) {
            EVF.V("CUST_CD", data.CUST_CD);
            EVF.V("CUST_NM", data.CUST_NM);
            //chgCustCd();
        }

		function onSearchPlant() {
			if( EVF.V("CUST_CD") == "" ) return alert("${OD03_010_0013}");
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


            <%--
            if( delyDate > '${END_DATE}' ) {
                return alert("${BGA1_010_015 }");
            }
            --%>




            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], 'GR_DATE', delyDate);
            }
        }

    </script>

    <e:window id="OD03_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCUST_CD" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
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
				<e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD03_010_0009}" value="CPO_DATE"/>
						<e:option text="${OD03_010_0014}" value="PO_DATE"/>
                        <e:option text="${OD03_010_0010}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE }" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE }" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>

				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				<e:text>&nbsp;</e:text>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>


				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVENDOR_CD" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
				<e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${ses.userId}" options="${sgCtrlUserIdOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="G" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field colSpan="3">
				<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
            </e:row>


        </e:searchPanel>

		<e:panel height="fit" width="50%">
			<e:text style="font-weight: bold;">●&nbsp;${form_GR_DATE_N} &nbsp;:&nbsp; </e:text>
			<e:inputDate id="GR_DATE" name="GR_DATE" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_GR_DATE_R}" disabled="${form_GR_DATE_D}" readOnly="${form_GR_DATE_RO}" />
			<e:text>&nbsp;&nbsp;</e:text>
			<e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>
		</e:panel>

		<e:panel height="fit" width="50%">
			<e:buttonBar align="right" width="100%">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<e:button id="doGrSave" name="doGrSave" label="${doGrSave_N}" onClick="doGrSave" disabled="${doGrSave_D}" visible="${doGrSave_V}"/>
			</e:buttonBar>
		</e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>