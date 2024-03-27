<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/STO/PO0560/";
        var grid = {};
        var selRow;
        var newMode = false;


        function init() {

        	grid = EVF.C('grid');

            grid.cellClickEvent(function(rowId, colId, value) {

            	if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': false
                    };
                    everPopup.im03_009open(param);
				}

            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
	            if(colId == "NEW_SALES_UNIT_PRICE" || colId == "CONT_UNIT_PRICE"  ){
					var contUnitPrc = Number(EVF.isEmpty(grid.getCellValue(rowId, 'CONT_UNIT_PRICE')) ? 0 : grid.getCellValue(rowId, 'CONT_UNIT_PRICE'));
	                var changeSalesUnitPrc = Number(EVF.isEmpty(grid.getCellValue(rowId, 'NEW_SALES_UNIT_PRICE')) ? 0 : grid.getCellValue(rowId, 'NEW_SALES_UNIT_PRICE'));
	                var calSalesRate = ((changeSalesUnitPrc - contUnitPrc) / changeSalesUnitPrc) * 100;
	                var salesRate = everMath.round_float(calSalesRate, 1);
	                grid.setCellValue(rowId, 'SALES_RATE', salesRate);
	            }
            });

            grid.setColIconify("CHANGE_REASON_YN", "CHANGE_REASON", "comment", false);
            grid.setColIconify("CUST_HISTORY_YN", "CUST_HISTORY_YN", "detail", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            if('${form.autoSearchFlag}' == 'Y') {
                EVF.V('DATE_CONDITION', "M");
                EVF.V('SG_CTRL_USER', '${ses.userId}');

            }
            EVF.C('ITEM_CD').setDisabled(true);
            EVF.C('DEAL_CD').setDisabled(true);
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store()

            store.setGrid([grid]);
            store.load(baseUrl + 'PO0560_doSearch', function() {
            	if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

	    function doChoice() {
            var selected = grid.getSelRowValue()[0];
            opener.window['${form.callBackFunction}'](JSON.stringify(selected));
            window.close();
        }

        function getBuyerInfo() {
            var param = {
                callBackFunction : "setBuyerInfo"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function setBuyerInfo(data) {
            EVF.V("BUYER_CD",data.CUST_CD);
            EVF.V("BUYER_NM",data.CUST_NM);

            EVF.V("CUST_CD",data.CUST_CD);
            //chgCustCd();
        }
        function doClose() {
            window.close();
        }



	</script>

    <e:window id="PO0560" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD} " width="${form_ITEM_CD_W }" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
					<e:select id="DEAL_CD" name="DEAL_CD" value="${form.DEAL_CD}" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
					<e:search id="BUYER_CD" style="ime-mode:inactive" name="BUYER_CD" value="" width="40%" maxLength="${form_BUYER_CD_M}" onIconClick="${form_BUYER_CD_RO ? 'everCommon.blank' : 'getBuyerInfo'}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
					<e:inputText id="BUYER_NM" style="${imeMode}" name="BUYER_NM" value="" width="60%" maxLength="${form_BUYER_NM_M}" disabled="${form_BUYER_NM_D}" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}"  onChange="cleanValue"  data="B" />
					<e:inputHidden id="CUST_CD" name="CUST_CD"/>
					<e:inputHidden id="DEPT_CD" name="DEPT_CD"/>
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
           <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
           <e:button id="doChoice" name="doChoice" label="${doChoice_N}" onClick="doChoice" disabled="${doChoice_D}" visible="${doChoice_V}"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>