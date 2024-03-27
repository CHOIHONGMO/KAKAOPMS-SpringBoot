<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/PY02/";
		var ROW_ID;

        function init() {
            grid = EVF.C("grid");
			
            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
                ROW_ID = rowId;

                if(colId === "multiSelect") {

				} else if(colId === "CUST_NM") {
                    var param = {
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                } else if(colId == "VENDOR_NM") {
                    param = {
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if(colId == "PO_GR_ITEM_AMT") {
                    param = {
                        MOVE_LINK_YN: "Y",
                        CLOSE_YEAR: grid.getCellValue(rowId, "CLOSING_YEAR"),
                        CLOSE_MONTH: grid.getCellValue(rowId, "CLOSING_MONTH"),
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        CUST_NM: grid.getCellValue(rowId, "CUST_NM"),
                        CUST_CONFIRM_YN: "1"
					};
                    // var el = parent.parent.document.getElementById('mainIframe');
                    top.pageRedirectByScreenId("PY02_010", param);
                    // top.pageRedirectByScreenId("PY02_010", param);
				}
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {

			};

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('shrinkToFit', true);
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
            store.load(baseUrl + "py02020_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    EVF.V("TOT_PO_AMT", "0 원");

                    return alert('${msg.M0002}');
                } else {
                    var TOT_PO_AMT = 0;
                    var rows = grid.getAllRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        TOT_PO_AMT += Number(rows[i].TOT_PO_AMT);
                    }

                    EVF.V("TOT_PO_AMT", comma(String(TOT_PO_AMT)) + " 원");
                }
            });
        }

		function comma(obj) {
			var regx = new RegExp(/(-?\d+)(\d{3})/);
			var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
			var strArr = obj.split('.');
			while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
				//정수 부분에만 콤마 달기
				strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
			}
			if (bExists > -1) {
				//. 소수점 문자열이 발견되지 않을 경우 -1 반환
				obj = strArr[0] + "." + strArr[1];
			} else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
				obj = strArr[0];
			}
			return obj;//문자열 반환
		}

        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${PY02_010_004}");
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
            everPopup.openCommonPopup(param, "SP0067");
        }

        function callbackCUST_CD(data) {
            EVF.V("CUST_CD", data.CUST_CD);
            EVF.V("CUST_NM", data.CUST_NM);
        }
    </script>

    <e:window id="PY02_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="CLOSE_YEAR" title="${form_CLOSE_YEAR_N}"/>
				<e:field>
					<e:select id="CLOSE_YEAR" name="CLOSE_YEAR" value="${CLOSE_YEAR}" options="${closeYearOptions}" width="80" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false" />
					<e:text>년 </e:text>
					<e:select id="CLOSE_MONTH" name="CLOSE_MONTH" value="${CLOSE_MONTH}" width="50" disabled="${form_CLOSE_MONTH_D}" readOnly="${form_CLOSE_MONTH_RO}" required="${form_CLOSE_MONTH_R}" placeHolder="" usePlaceHolder="false">
						<e:option text="01" value="01"></e:option>
						<e:option text="02" value="02"></e:option>
						<e:option text="03" value="03"></e:option>
						<e:option text="04" value="04"></e:option>
						<e:option text="05" value="05"></e:option>
						<e:option text="06" value="06"></e:option>
						<e:option text="07" value="07"></e:option>
						<e:option text="08" value="08"></e:option>
						<e:option text="09" value="09"></e:option>
						<e:option text="10" value="10"></e:option>
						<e:option text="11" value="11"></e:option>
						<e:option text="12" value="12"></e:option>
					</e:select>
					<e:text>월 </e:text>
				</e:field>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVENDOR_CD'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCUST_CD'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

		<e:panel width="50%">
			<e:text style="color:blue;font-weight:bold;">[ 총마감금액: </e:text>
			<e:text id="TOT_PO_AMT" name="TOT_PO_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
			<e:text style="color:blue;font-weight:bold;">]</e:text>
		</e:panel>
		<e:panel width="50%">
		<e:buttonBar align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>
		</e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>