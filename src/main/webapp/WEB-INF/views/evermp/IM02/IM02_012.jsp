<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};
        var selRow;

        function init() {

            grid = EVF.C('grid');
            grid.setProperty('multiSelect', (${param.multiFlag} ? true : false));

            grid.cellClickEvent(function(rowId, colId, value) {
                // Single Popup : 품목코드 선택시 자동 선택 후 팝업창 닫힘 (MultiPopup 제외)
            	if(colId == "ITEM_CD" && !${param.multiFlag}) {
                    var selectedData = [{
						 "TIER_CD"   : grid.getCellValue(rowId, 'TIER_CD')
                        ,"ITEM_CD"   : grid.getCellValue(rowId, 'ITEM_CD')
                        ,"ITEM_DESC" : grid.getCellValue(rowId, 'ITEM_DESC')
                        ,"ITEM_SPEC" : grid.getCellValue(rowId, 'ITEM_SPEC')
                        ,"MAKER_CD"  : grid.getCellValue(rowId, 'MAKER_CD')
                        ,"MAKER_NM"  : grid.getCellValue(rowId, 'MAKER_NM')
                        ,"MAKER_PART_NO" : grid.getCellValue(rowId, 'MAKER_PART_NO')
                        ,"ITEM_CLS1" : grid.getCellValue(rowId, 'ITEM_CLS1')
                        ,"ITEM_CLS2" : grid.getCellValue(rowId, 'ITEM_CLS2')
                        ,"ITEM_CLS3" : grid.getCellValue(rowId, 'ITEM_CLS3')
                        ,"ITEM_CLS4" : grid.getCellValue(rowId, 'ITEM_CLS4')
                        ,"ORIGIN_CD" : grid.getCellValue(rowId, 'ORIGIN_CD')
                        ,"ORIGIN_NM" : grid.getCellValue(rowId, 'ORIGIN_NM')
                        ,"UNIT_CD"   : grid.getCellValue(rowId, 'UNIT_CD')
                        ,"UNIT_NM"   : grid.getCellValue(rowId, 'UNIT_NM')
                        ,"BRAND_CD"  : grid.getCellValue(rowId, 'BRAND_CD')
                        ,"BRAND_NM"  : grid.getCellValue(rowId, 'BRAND_NM')
                        ,"CUST_ITEM_CD"  : grid.getCellValue(rowId, 'CUST_ITEM_CD')
                        ,"DELY_TYPE"  : grid.getCellValue(rowId, 'DELY_TYPE')
                        ,"VAT_CD"  : grid.getCellValue(rowId, 'VAT_CD')
                        ,"ITEM_STATUS"  : grid.getCellValue(rowId, 'ITEM_STATUS')

                        ,"CONT_NO"  : grid.getCellValue(rowId, 'CONT_NO')
                        ,"CONT_SEQ"  : grid.getCellValue(rowId, 'CONT_SEQ')
                        ,"VENDOR_CD"  : grid.getCellValue(rowId, 'VENDOR_CD')

                    }];
                    if(grid.isEmpty(selectedData)) { return ; }
                    opener['${param.callBackFunction}'](selectedData, '${param.rowId}');
                    doClose();
                }
            });

            EVF.C('Choice').setVisible((${param.multiFlag} ? true : false));

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            if( EVF.isEmpty(EVF.C("ITEM_CD").getValue()) && EVF.isEmpty(EVF.C("ITEM_DESC").getValue()) &&
                EVF.isEmpty(EVF.C("ITEM_SPEC").getValue()) && EVF.isEmpty(EVF.C("MAKER_CD").getValue()) && EVF.isEmpty(EVF.C("MAKER_NM").getValue()) &&
                EVF.isEmpty(EVF.C("MAKER_PART_NO").getValue()) && EVF.isEmpty(EVF.C("ITEM_CLS1").getValue()) &&
                EVF.isEmpty(EVF.C("ITEM_CLS2").getValue()) && EVF.isEmpty(EVF.C("ITEM_CLS3").getValue()) &&
                EVF.isEmpty(EVF.C("ITEM_CLS4").getValue())) {
                return alert("${IM02_012_001}");
            }

            store.setGrid([grid]);
            store.setParameter("STD_FLAG", "${param.STD_FLAG}");
            store.setParameter("PR_BUYER_CD", "${formData.PR_BUYER_CD}");
            store.setParameter("PR_PLANT_CD", "${formData.PR_PLANT_CD}");
            store.load(baseUrl + 'im02012_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doChoice() {
            var selectedData = grid.getSelRowValue();
            if(grid.isEmpty(selectedData)) { return ; }
            opener['${param.callBackFunction}'](selectedData, '${param.rowId}');
            doClose();
        }

        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNm",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '${ses.companyCd}',	// 고객사코드 or 회사코드
                'custNm' : '${ses.companyNm}'  	// 고객사코드 or 회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        function doClose() {
            window.close();
        }

    </script>

    <e:window id="IM02_012" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <!-- 유효한 계약 존재여부 : 기본은 존재하는 것으로 조회, 견적요청서작성 화면에서는 유효계약이 없어도 조회하도록 함 -->
            <e:inputHidden id="CONTRACT_YN" name="CONTRACT_YN" value="${param.contractYn}"/>

            <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${param.BUYER_CD }"/>
            <e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${param.BUYER_CD }"/>
            <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1"/>
            <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2"/>
            <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3"/>
            <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4"/>

            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field>
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:search id="MAKER_CD" style="ime-mode:inactive" name="MAKER_CD"  value="" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="${form_MAKER_CD_RO ? 'everCommon.blank' : 'searchMakerCd'}" disabled="${form_MAKER_CD_D}" readOnly="${form_MAKER_CD_RO}" required="${form_MAKER_CD_R}" />
                    <e:inputText id="MAKER_NM" style="${imeMode}" name="MAKER_NM" value="" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}"/>
                </e:field>
                <e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
                <e:field>
                    <e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
                </e:field>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field>
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" onIconClick="_getItemClsNm" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Choice" name="Choice" label="${Choice_N}" disabled="${Choice_D}" visible="${Choice_V}" onClick="doChoice" />
            <%-- <e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" /> --%>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>