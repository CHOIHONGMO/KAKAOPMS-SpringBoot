<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BGA1/";
		var ROW_ID;

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
				ROW_ID = rowId;

                if (colId === "CLOSING_YEAR_MONTHXXXXXXXX") {
                    var param = {
                        callbackFunction: "",
                        LINK_POPUP_YN: "Y",
                        LINK_CLOSING_YEAR_MONTH: grid.getCellValue(rowId, "O_CLOSING_YEAR_MONTH"),
                        LINK_DEPT_CD: grid.getCellValue(rowId, "DEPT_CD"),
						LINK_BD_DEPT_CD: grid.getCellValue(rowId, "BD_DEPT_CD"),
						LINK_ACCOUNT_CD: grid.getCellValue(rowId, "ACCOUNT_CD"),
                        LINK_DOC_TYPE: grid.getCellValue(rowId, "DOC_TYPE"),
                        LINK_GR_USER_ID: EVF.V("LINK_GR_USER_ID"),
                        LINK_GR_USER_NM: EVF.V("LINK_GR_USER_NM")
                    };
                    everPopup.openPopupByScreenId("BGA1_040", 1100, 700, param);
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
            grid.setRowFooter("DOC_TYPE_NM", footerTxt);
            grid.setRowFooter("GR_ITEM_AMT", footerSum);

            //grid.setProperty('shrinkToFit', true);
            grid.showCheckBar(false);

            //chgCustCd();

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
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "bga1050_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }

                //EVF.V("LINK_GR_USER_ID", EVF.V("GR_USER_ID"));
                //EVF.V("LINK_GR_USER_NM", EVF.V("GR_USER_NM"));
            });
        }

        function searchGR_USER_ID() {
        	var custCd = "${ses.companyCd}";

        	var param = {
        			callBackFunction: "callbackGR_USER_ID",
        			custCd: custCd
                };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function callbackGR_USER_ID(data) {
            EVF.C("GR_USER_ID").setValue(data.USER_ID);
            EVF.C("GR_USER_NM").setValue(data.USER_NM);
        }

        function searchDEPT_CD() {
            var custCd = "${ses.companyCd}";
			var custNm = "${ses.companyNm}";

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
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function searchBD_DEPT_CD() {
            var custCd = "${ses.companyCd}";
			var custNm = "${ses.companyNm}";

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "callbackBD_DEPT_CD",
                AllSelectYN: true,
                detailView: false,
                multiYN: false,
                ModalPopup: true,
                custCd : custCd,
                custNm : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function callbackBD_DEPT_CD(dataJsonArray) {
            data = JSON.parse(dataJsonArray);
            EVF.C("BD_DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("BD_DEPT_NM").setValue(data.DEPT_NM);
        }

        function searchACCOUNT_CD() {
            var param = {
                callBackFunction: "callbackACCOUNT_CD",
                custCd: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0085');
		}

        function callbackACCOUNT_CD(data) {
            EVF.C("ACCOUNT_CD").setValue(data.ACCOUNT_CD);
            EVF.C("ACCOUNT_NM").setValue(data.ACCOUNT_NM);
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

    <e:window id="BGA1_050" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
	    <e:row>
                <e:label for="CLOSE_YEAR" title="${form_CLOSE_YEAR_N}"/>
                <e:field>
		            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd }" />
                    <e:select id="CLOSE_YEAR" name="CLOSE_YEAR" value="${CLOSE_YEAR}" options="${closeYearOptions}" width="80" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false" />
                    <e:text>년 </e:text>
                    <e:select id="CLOSE_MONTH" name="CLOSE_MONTH" value="${CLOSE_MONTH}" width="50" disabled="${form_CLOSE_MONTH_D}" readOnly="${form_CLOSE_MONTH_RO}" required="${form_CLOSE_MONTH_R}" placeHolder="" usePlaceHolder="false">
                        <e:option text="01" value="01"/>
                        <e:option text="02" value="02"/>
                        <e:option text="03" value="03"/>
                        <e:option text="04" value="04"/>
                        <e:option text="05" value="05"/>
                        <e:option text="06" value="06"/>
                        <e:option text="07" value="07"/>
                        <e:option text="08" value="08"/>
                        <e:option text="09" value="09"/>
                        <e:option text="10" value="10"/>
                        <e:option text="11" value="11"/>
                        <e:option text="12" value="12"/>
                    </e:select>
                    <e:text>월 </e:text>
                </e:field>

                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="${ses.plantCd}" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="${ses.plantNm}" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
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
				<e:text>&nbsp;</e:text>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>

				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVENDOR_CD" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>

                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="${ses.userId}" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="${ses.userNm}" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
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
				<e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
				<e:field>
					<e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>