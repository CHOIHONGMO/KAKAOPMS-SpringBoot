<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BOD1/BOD101/";
        var ROW_ID;

        function init() {
            grid = EVF.C("grid");
            //grid.setProperty('sortable', false);

            grid.cellClickEvent(function(rowId, colId, value) {
                var param;

                ROW_ID = rowId;

                if(colId === "multiSelect") {

                } else if(colId === "CUST_NM") {
                    param = {
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
                } else if(colId === "CPO_USER_NM") {
                    param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId === "GR_USER_NM") {
                    var GR_AGENT_FLAG = grid.getCellValue(rowId, "GR_AGENT_FLAG");

                    param = {
                        callbackFunction: "",
                        USER_ID: GR_AGENT_FLAG === "1" ? grid.getCellValue(rowId, "GR_USER_ID") : grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId === "CPO_NO") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if(colId === "ITEM_CD") {
                    if (value !== "") {
                        param = {
                            ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                            popupFlag: true,
                            detailView: true
                        };
                        everPopup.im03_014open(param);
                    }
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


			if('${ses.userType}' != 'C') {
				EVF.C("CUST_NM").setValue('${ses.companyNm}');
				EVF.C("CUST_CD").setValue('${ses.companyCd}');
				EVF.C("CUST_NM").setDisabled(true);
				EVF.C("CUST_CD").setDisabled(true);
//				getPlantCd();
			}

            //doSearch();
        }

        function callbackGridCUBL_NM(data) {
            grid.setCellValue(ROW_ID, "CUBL_SQ", data.CUBL_SQ);
            grid.setCellValue(ROW_ID, "CUBL_NM", data.CUBL_NM);
            grid.setCellValue(ROW_ID, "CUBL_COMPANY_NM", data.CUBL_COMPANY_NM);
            grid.setCellValue(ROW_ID, "CUBL_IRS_NUM", data.CUBL_IRS_NUM);
            grid.setCellValue(ROW_ID, "CUBL_ADDR", data.CUBL_ADDR);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "bod1110Dosearch", function () {

            });
        }


        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${PY01_020_007}");
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

		function onSearchPlant() {
			if( EVF.V("CUST_CD") == "" ) return alert("${BOD1_110_004}");
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

        function searchCUST_CD() {
            var param = {
                callBackFunction: "callbackCUST_CD"
            };
            everPopup.openCommonPopup(param, "SP0067");
        }

        function callbackCUST_CD(data) {
			EVF.V("CUST_CD", data.CUST_CD);
			EVF.V("CUST_NM", data.CUST_NM);

			/*
			if ("1" == data.PLANT_FLAG) {
				var store = new EVF.Store();
				store.load("/evermp/BOD1/BOD102/bod1020_doSearchPLANT", function () {
					var PLANT_CD_Options = JSON.parse(this.getParameter("PLANT_CD_Options"));

					EVF.C("PLANT_CD").setOptions(PLANT_CD_Options);
				});
			}
			*/
		}

        function getPlantCd() {
            var store = new EVF.Store();
            store.load("/evermp/BOD1/BOD102/bod1020_doSearchPLANT", function() {
                var PLANT_CD_Options =  JSON.parse(this.getParameter("PLANT_CD_Options"));
                EVF.C("PLANT_CD").setOptions(PLANT_CD_Options);
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


		function doBack() {
            var store = new EVF.Store();

            if(!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var temp_cust_cd = rows[0].CUST_CD;
            var temp_plant_cd = rows[0].PLANT_CD;
            for( var i = 0; i < rows.length; i++ ) {
            	/*
            	if(rows[i].AM_USER_ID != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                	return alert("${msg.M0008}");
                }
                */
                if(rows[i].CUST_CD != temp_cust_cd) {
                    alert("${BOD1_110_002}");
                    return;
                }
                if(rows[i].PLANT_CD != temp_plant_cd) {
                    alert("${BOD1_110_002}");
                    return;
                }
            }

            if(!confirm("${BOD1_110_001}")) { return; }
			var param = {
					bkList 		 	: JSON.stringify(grid.getSelRowValue()),
					detailView 		: false
			};
			everPopup.openPopupByScreenId("BOD1_111", 800, 600, param);
		}
    </script>

    <e:window id="BOD1_110" onReady="init" initData="${initData}" title="${fullScreenName}">
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
				<e:label for="ADD_DATE_FROM" title="${form_ADD_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="ADD_DATE_FROM" name="ADD_DATE_FROM" value="${START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_FROM_R}" disabled="${form_ADD_DATE_FROM_D}" readOnly="${form_ADD_DATE_FROM_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="ADD_DATE_TO" name="ADD_DATE_TO" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_TO_R}" disabled="${form_ADD_DATE_TO_D}" readOnly="${form_ADD_DATE_TO_RO}" />
				</e:field>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputText id="CPO_NO" name="CPO_NO" value="" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				</e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar width="100%" align="right">
	        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doBack" name="doBack" label="${doBack_N}" onClick="doBack" disabled="${doBack_D}" visible="${doBack_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>