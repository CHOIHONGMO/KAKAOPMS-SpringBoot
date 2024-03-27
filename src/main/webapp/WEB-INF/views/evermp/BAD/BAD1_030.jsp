<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BAD/BAD1/";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {
            	if (colId == "ITEM_CD") {
            		var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupYn': "Y",
                            'detailView': false
                        };
                    everPopup.im03_014open(param);
                }
                if(colId == "ACCOUNT_CD") {
                    var param = {
                        callBackFunction: "setgridAccountCd",
                        custCd: '${ses.companyCd}',
                        rowId : rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0085');
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bad1030_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }


        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bad1030_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }


        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bad1030_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }
        function doAllSetting(){
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                grid.setCellValue(rowIds[i], 'ACCOUNT_CD', EVF.V("SET_ACCOUNT_CD"));
                grid.setCellValue(rowIds[i], 'ACCOUNT_NM', EVF.V("SET_ACCOUNT_NM"));
            }

        }

        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param;
            if ("${ses.buyerMySiteFlag }"=="1"){
                param = {
                    callBackFunction : "_setItemClassNm",
                    'detailView': false,
                    'multiYN' : false,
                    'ModalPopup' : true,
                    'searchYN' : true,
                    'custCd' : '${ses.companyCd}',  // 고객사코드
                    'custNm' : '${ses.companyNm}'
                };
            }else{
                param = {
                    callBackFunction : "_setItemClassNm",
                    'detailView': false,
                    'multiYN' : false,
                    'ModalPopup' : true,
                    'searchYN' : true,
                    'custCd' : '${ses.manageCd}',
                    'custNm' : '${BOD1_010_manaceNm}'
                };
            }

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


        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }


        function searchAccountCd() {
            var param = {
                callBackFunction : "selectAccountCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectAccountCd(dataJsonArray) {
            EVF.V("ACCOUNT_CD",dataJsonArray.VENDOR_CD);
            EVF.V("ACCOUNT_NM",dataJsonArray.VENDOR_NM);
        }

        function searchAccount(){
            var param = {
           		custCd : '${ses.companyCd}',
               	callBackFunction : "selectAccount"
           	};
            everPopup.openCommonPopup(param, 'SP0085');
        }

        function selectAccount(data){
            EVF.V("ACCOUNT_CD",data.ACCOUNT_CD);
            EVF.V("ACCOUNT_NM",data.ACCOUNT_NM);
        }

        function searchAccount2(){
            var param = {
           		custCd : '${ses.companyCd}',
               	callBackFunction : "selectAccount2"
           	};
            everPopup.openCommonPopup(param, 'SP0085');
        }

        function selectAccount2(data){
            EVF.V("SET_ACCOUNT_CD",data.ACCOUNT_CD);
            EVF.V("SET_ACCOUNT_NM",data.ACCOUNT_NM);
        }

        function setgridAccountCd(data) {
            grid.setCellValue(data.rowId, 'ACCOUNT_CD', data.ACCOUNT_CD);
            grid.setCellValue(data.rowId, 'ACCOUNT_NM', data.ACCOUNT_NM);
        }

    </script>
    <e:window id="BAD1_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field colSpan="3">
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : '_getItemClsNm'}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
                </e:field>
                <e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
                <e:field>
                    <e:select id="ITEM_STATUS" name="ITEM_STATUS" value="" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
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
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field>
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}"/>
                <e:field>
                    <e:search id="ACCOUNT_CD" style="ime-mode:inactive" name="ACCOUNT_CD" value="" width="35%" maxLength="${form_ACCOUNT_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchAccount'}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
                    <e:select id="st_ACCOUNT_NM" name="st_ACCOUNT_NM" value="${st_default}" width="${everMultiWidth}" options="${searchTerms}" visible="${everMultiVisible}" required="" readOnly="" disabled="" />
                    <e:inputText id="ACCOUNT_NM" style="${imeMode}" name="ACCOUNT_NM" value="" width="65%" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
                </e:field>

                <e:label for="MAPPING_YN" title="${form_MAPPING_YN_N}"/>
                <e:field>
                    <e:select id="MAPPING_YN" name="MAPPING_YN" value="" options="${mappingYnOptions}" width="${form_MAPPING_YN_W}" disabled="${form_MAPPING_YN_D}" readOnly="${form_MAPPING_YN_RO}" required="${form_MAPPING_YN_R}" placeHolder="" />
                </e:field>
                
                <e:label for="" title=""/>
                <e:field> </e:field>
            </e:row>
        </e:searchPanel>
        
        <e:panel width="40%">
	        <e:searchPanel id="form2" title="${msg.M9999 }" columnCount="1" labelWidth="${labelWidth }" useTitleBar="false" onEnter="">
	            <e:row>
	            	<e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}"/>
	            	<e:field width="320px">
	                    <e:search id="SET_ACCOUNT_CD" style="ime-mode:inactive" name="SET_ACCOUNT_CD" value="" width="35%" maxLength="${form_SET_ACCOUNT_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchAccount2'}" disabled="${form_SET_ACCOUNT_CD_D}" readOnly="true" required="${form_SET_ACCOUNT_CD_R}" />
	                    <e:inputText id="SET_ACCOUNT_NM" style="${imeMode}" name="SET_ACCOUNT_NM" value="" width="65%" maxLength="${form_SET_ACCOUNT_NM_M}" disabled="${form_SET_ACCOUNT_NM_D}" readOnly="true" required="${form_SET_ACCOUNT_NM_R}" />
                    </e:field>
                    <e:field>
		                <e:button id="doAllSetting" name="doAllSetting" label="${doAllSetting_N }" disabled="${doAllSetting_D }" visible="${doAllSetting_V}" onClick="doAllSetting" />
                    </e:field>
	            </e:row>
	        </e:searchPanel>
        </e:panel>

        <div style="float: right;margin-top: 4px;">
            <e:buttonBar id="buttonBar"  width="100%">
                <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" align="right"/>
                <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" align="right"/>
                <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" align="right"/>
            </e:buttonBar>
        </div>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>


    </e:window>
</e:ui>