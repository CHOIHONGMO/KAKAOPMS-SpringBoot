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
                if(colId === "ITEM_CD") {
					var param = {
						ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
						popupFlag: true,
						detailView: true
					};
					everPopup.im03_014open(param);
                } else if(colId === "CPO_USER_NM") {
					var param = {
						callbackFunction: "",
						USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId === "GR_USER_NM") {
                    var GR_AGENT_FLAG = grid.getCellValue(rowId, "GR_AGENT_FLAG");

                    var param = {
                        callbackFunction: "",
                        USER_ID: GR_AGENT_FLAG === "1" ? grid.getCellValue(rowId, "GR_USER_ID") : grid.getCellValue(rowId, "CPO_USER_ID"),
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
            grid.setRowFooter("PO_GR_UNIT_PRICE", footerTxt);
            grid.setRowFooter("PO_GR_ITEM_AMT", footerSum);

            grid.showCheckBar(false);

            if("Y" === "${param.MOVE_LINK_YN}") {
                EVF.V("CLOSING_YEAR_MONTH", "${param.CLOSING_YEAR_MONTH}");
                EVF.V("CUST_CD", "${param.CUST_CD}");
                EVF.V("CUST_NM", "${param.CUST_NM}");
                <%--EVF.V("CUST_CONFIRM_YN", "${param.CUST_CONFIRM_YN}");--%>

                doSearch();
            }

			//grid.freezeCol("CUST_CONFIRM_NM");
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "sap1010_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
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

    <e:window id="SAP1_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCUST_CD'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
				<e:label for="INV_NO" title="${form_INV_NO_N}" />
				<e:field>
					<e:inputText id="INV_NO" name="INV_NO" value="" width="${form_INV_NO_W}" maxLength="${form_INV_NO_M}" disabled="${form_INV_NO_D}" readOnly="${form_INV_NO_RO}" required="${form_INV_NO_R}" />
				</e:field>
				<e:label for="DEAL_TYPE" title="${form_DEAL_TYPE_N}"/>
				<e:field>
					<e:select id="DEAL_TYPE" name="DEAL_TYPE" value="" options="${dealTypeOptions}" width="${form_DEAL_TYPE_W}" disabled="${form_DEAL_TYPE_D}" readOnly="${form_DEAL_TYPE_RO}" required="${form_DEAL_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="CLOSING_YEAR_MONTH" title="${form_CLOSING_YEAR_MONTH_N}"/>
				<e:field>
					<e:inputDate id="CLOSING_YEAR_MONTH" name="CLOSING_YEAR_MONTH" value="${CLOSING_YEAR_MONTH}" format="yyyy-mm" width="${inputDateWidth}" datePicker="true" required="${form_CLOSING_YEAR_MONTH_R}" disabled="${form_CLOSING_YEAR_MONTH_D}" readOnly="${form_CLOSING_YEAR_MONTH_RO}" />
				</e:field>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				<e:text>&nbsp;</e:text>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>

				<e:label for="GR_NO" title="${form_GR_NO_N}" />
				<e:field>
					<e:inputText id="GR_NO" name="GR_NO" value="" width="${form_GR_NO_W}" maxLength="${form_GR_NO_M}" disabled="${form_GR_NO_D}" readOnly="${form_GR_NO_RO}" required="${form_GR_NO_R}" />
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
				<e:field colSpan="2"/>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>