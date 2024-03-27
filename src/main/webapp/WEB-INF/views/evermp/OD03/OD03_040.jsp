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
            //grid.setProperty('sortable', false);
            EVF.C("PR_TYPE").removeOption("R");
            EVF.C("DEAL_CD").removeOption("200");

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
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                            CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                        };
                        everPopup.openPopupByScreenId("BOD1_041", 1100, 800, param);
                    }
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
                            title: "${OD03_030_001}",
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
                            bizType: "OM",
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                } else if(colId === "GR_AGENT_ATTFILE_NUM_CNT") {
                    var attFileNum = grid.getCellValue(rowId, "GR_AGENT_ATTFILE_NUM");

                    var param = {
                        havePermission: false,
                        attFileNum: attFileNum,
                        rowId: rowId,
                        callBackFunction: "callbackGridGR_AGENT_ATTFILE_NUM",
                        bizType: "DGM",
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }else if(colId == "RECIPIENT_NM") { // 인수자
                    if( grid.getCellValue(rowId, "RECIPIENT_NM") == "" ) return;
                    var param = {
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ"),
                        detailView: "true"
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                }else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }else if (colId == "VENDOR_NM") {
                	var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: true,
                            popupFlag: true
                        };
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }else if(colId == "AM_USER_NM") { // 진행관리담당자
					if( grid.getCellValue(rowId, "AM_USER_ID") == "" ) return;
					param = {
						callbackFunction: "",
						USER_ID: grid.getCellValue(rowId, "AM_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
				}
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

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
                text: ["합 계"]
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






            grid.setColMerge(["DELY_NM","CSDM_SEQ","VENDOR_CD","PO_DATE","DEAL_CD","PR_TYPE","CUST_CD","CUST_NM","CUST_NM","PLANT_CD","PLANT_NM","DEPT_NM","PR_SUBJECT", "CPO_USER_NM", "REF_MNG_NO", "CPO_NO", "CPO_SEQ", "PO_NO", "PO_SEQ", "CUST_ITEM_CD", "ITEM_CD", "ITEM_DESC", "ITEM_SPEC",
                "MAKER_NM", "MAKER_PART_NO", "BRAND_NM", "ORIGIN_NM", "UNIT_CD", "CPO_QTY", "CUR", "VENDOR_NM",
                "BD_DEPT_CD", "BD_DEPT_NM", "ACCOUNT_CD", "ACCOUNT_NM", "CPO_DATE", "HOPE_DUE_DATE", "RECIPIENT_NM",
                "RECIPIENT_DEPT_NM", "RECIPIENT_TEL_NUM", "RECIPIENT_CELL_NUM", "DELY_ZIP_CD", "DELY_ADDR_1", "DELY_ADDR_2",
                "PRIOR_GR_FLAG_NM", "REQ_TEXT_YN", "ATTACH_FILE_NO_IMG"
			]);
            doSearch();
			//grid.freezeCol("GR_NO_SEQ");
        }

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
            grid.checkRow(data.rowId, true);
		}

        function callbackGridATTACH_FILE_NO(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, 'ATTACH_FILE_NO', uuid);
			grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', fileCount);
        }

        function callbackGridGR_AGENT_ATTFILE_NUM(rowId, uuid, fileCount) {
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM", uuid);
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM_CNT", fileCount);
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.setParameter("autoSearchFlag", "");
            store.load(baseUrl + "od03040_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doGrCancel() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].CLOSING_YN == "Y" || rows[i].GR_CLOSE_YN=='1' ) {
                    alert("${OD03_040_002}");
                    return;
                }
            }

            if(!confirm("${OD03_040_003}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.setParameter("MMRS","1");
            store.load(baseUrl + "od03020_doGrCancel", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function searchDEPT_CD() {
            var custCd = EVF.V("CUST_CD");
			var custNm = EVF.V("CUST_NM");

            if(custCd == "") {
                alert("${OD03_040_006}");
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
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS2);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${OD03_040_006}");
                return;
            }

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

        function searchCUST_CD() {
            var param = {
                callBackFunction: "callbackCUST_CD"
            };
            everPopup.openCommonPopup(param, "SP0902");
        }

        function callbackCUST_CD(data) {
            EVF.V("CUST_CD", data.CUST_CD);
            EVF.V("CUST_NM", data.CUST_NM);
            chgCustCd();
        }

        function doPrint() {
	        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

	        var recipient_nm_list = [];
	        var rowIds = grid.getSelRowId();
	        for( var i in rowIds ) {
		        recipient_nm_list.push( grid.getCellValue(rowIds[i], "CUST_CD") + grid.getCellValue(rowIds[i], "RECIPIENT_NM") + grid.getCellValue(rowIds[i], "CUBL_SQ"));
	        }

	        // 중복 값 제거(CUST_CD, RECIPIENT_NM)
	        var pouniq = recipient_nm_list.reduce(function(a,b){
		        if (a.indexOf(b) < 0 ) a.push(b);
		        return a;
	        },[]);

	        var pouniqArr = [];

	        // 데이터 추출
	        for (var j in pouniq) {
		        var pouniqStr = "";
				var custCd_recipientNm = pouniq[j];

		        for( var k in rowIds ) {
		        	if(custCd_recipientNm == grid.getCellValue(rowIds[k], "CUST_CD") + grid.getCellValue(rowIds[k], "RECIPIENT_NM") + grid.getCellValue(rowIds[i], "CUBL_SQ")) {
				        // pouniqArr.push({GR_NUM_SEQ: grid.getCellValue(rowIds[k], "GR_NO") + grid.getCellValue(rowIds[k], "GR_SEQ"), CUSTCD_RECIPIENTNM: custCd_recipientNm});
				        pouniqStr += grid.getCellValue(rowIds[k], "GR_NO") + grid.getCellValue(rowIds[k], "GR_SEQ") + ","
			        }
		        }

		        pouniqArr.push(pouniqStr.substr(0, pouniqStr.length - 1));
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
	        	USER_NMS: JSON.stringify(pouniq),
		        GR_NO_SEQ: JSON.stringify(pouniqArr),
		        HOST_INFO: oz80_url,
		        MANAGE_CD: "${ses.manageCd}",
		        OZ80_URL: oz80_url
	        };

	        url = oz80_url + "/ozhviewer/OD03_040.jsp";
	        everPopup.openWindowPopup(url, 1000, 700, param, "", true);
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



    </script>

    <e:window id="OD03_040" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD03_040_0009}" value="CPO_DATE"/>
						<e:option text="${OD03_040_019}" value="PO_DATE"/>
						<e:option text="${OD03_040_018}" value="GR_DATE"/>
                        <e:option text="${OD03_040_0010}" value="HOPE_DUE_DATE"/>
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
				<e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
				<e:field>
					<e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}"/>
				<e:field>
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="${form_CPO_USER_NM_W}" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field colSpan="3">
				<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
            </e:row>



        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doGrCancel" name="doGrCancel" label="${doGrCancel_N}" onClick="doGrCancel" disabled="${doGrCancel_D}" visible="${doGrCancel_V}"/>
		</e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>