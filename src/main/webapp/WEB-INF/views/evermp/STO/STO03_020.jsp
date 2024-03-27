<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/";
        var selRow;

        function init() {
            grid = EVF.C("grid");
            popupFlag = '${param.popupFlag}';

            if (popupFlag) {
                EVF.C('Choice').setVisible(true);
            } else {
                EVF.C('Choice').setVisible(false);
            }

            grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

            	<%--셀 여러개 선택 방지--%>
            	if(selRow == undefined){
    				selRow = rowId;
    			}

    			if (colId == "multiSelect") {
    				if(selRow != rowId) {
    					grid.checkRow(selRow, false);
    					selRow = rowId;
    				}
    			}
                if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_009open(param);
                } else if (colId == "VENDOR_NM") {
                	var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: true,
                            popupFlag: true
                        };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
            });


            EVF.C('DEAL_CD').setValue("400");
            EVF.C('DEAL_CD').setDisabled(true);
            EVF.C('VENDOR_CD').setValue("${ses.companyCd}");
            EVF.C('VENDOR_NM').setValue("${ses.companyNm}");
            EVF.C('VENDOR_CD').setDisabled(true);
            EVF.C('VENDOR_NM').setDisabled(true);

            doSearch();
        }


        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0301_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
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

        function doChoice() {
            var selected = grid.getSelRowValue()[0];
            opener.window['${param.callBackFunction}'](JSON.stringify(selected));

            doClose();
        }

        function doClose() {
            window.close();
        }




    </script>

    <e:window id="STO03_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
            <e:field>
               <e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
            </e:field>
              <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
            <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
            <e:field>
               <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
            </e:field>
         </e:row>
         <e:row>
         <e:label for="STR_CTRL_CODE" title="${form_STR_CTRL_CODE_N}"/>
            <e:field>
               <e:select id="STR_CTRL_CODE" name="STR_CTRL_CODE" value="" options="${strCtrlCodeOptions}" width="${form_STR_CTRL_CODE_W}" disabled="${form_STR_CTRL_CODE_D}" readOnly="${form_STR_CTRL_CODE_RO}" required="${form_STR_CTRL_CODE_R}" placeHolder="" />
            </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right" width="100%">
         <div style="float: right;">
            <e:button id="Choice" name="Choice" label="${Choice_N}" disabled="${Choice_D}" visible="${Choice_V}" onClick="doChoice" />
               <e:check id="EXCLUDE" name="EXCLUDE" value="0"/><e:text style="font-weight: bold;">재고 "0" 제외 </e:text>
               <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            </div>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>