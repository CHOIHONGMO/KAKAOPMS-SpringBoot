<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SAP1/";
		var ROW_ID;

        function init() {
            grid = EVF.C("grid");
			
            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
				ROW_ID = rowId;
				/*
                if(colId === "CUST_NM") {
                    var param = {
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                } else
                */
                if(colId == "PO_GR_ITEM_AMT") {
                    param = {
                        MOVE_LINK_YN: "Y",
                        CLOSING_YEAR_MONTH: grid.getCellValue(rowId, "O_CLOSING_YEAR_MONTH"),
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        CUST_NM: grid.getCellValue(rowId, "CUST_NM"),
                        CUST_CONFIRM_YN: "1"
                    };
                    // var el = parent.parent.document.getElementById('mainIframe');
                    top.pageRedirectByScreenId("SAP1_010", param);
                    // top.pageRedirectByScreenId("SAP1_010", param);
                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

            });

            grid.setColIconify("REQ_TEXT_YN", "REQ_TEXT", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('shrinkToFit', true);
            grid.showCheckBar(false);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "sap1020_doSearch", function () {
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

    <e:window id="SAP1_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="CLOSING_YEAR_MONTH" title="${form_CLOSING_YEAR_MONTH_N}"/>
				<e:field>
					<e:inputDate id="CLOSING_YEAR_MONTH" name="CLOSING_YEAR_MONTH" value="${CLOSING_YEAR_MONTH}" format="yyyy-mm" width="${inputDateWidth}" datePicker="true" required="${form_CLOSING_YEAR_MONTH_R}" disabled="${form_CLOSING_YEAR_MONTH_D}" readOnly="${form_CLOSING_YEAR_MONTH_RO}" />
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