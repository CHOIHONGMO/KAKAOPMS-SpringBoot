<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {

        	grid = EVF.C("grid");
            grid.setProperty('singleSelect', true);
//            grid._gvo.setFixedOptions({colCount: 2});

            grid.cellClickEvent(function(rowId, colId, value) {
                if (colId == "VENDOR_CD") {

                    var param ;
                    if(grid.getCellValue(rowId, 'SIGN_STATUS')=='P'){
                        param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': true,
                            'popupFlag': true
                        };
                    } else {
                        param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': false,
                            'popupFlag': true
                        };
                    }
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if (colId == "CREDIT_HIST") {
                    var param ;
                    param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002C", 900, 400, param);
                }

                else if (colId == "BLOCK_FLAG") {
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_003", 1100, 700, param);
                }
                else if (colId == "HISTORY_YN") {
                    if(value!=""){
                        var param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'VENDOR_NM' :grid.getCellValue(rowId, 'VENDOR_NM'),
                            'detailView': true
                        };
                        everPopup.bs03_007open(param);
                    }
                }
                else if (colId =="EV_RESULT_SCORE"){
                    if(value!=""){
                        var progressCd = grid.getCellValue(rowId, "PROGRESS_CD");
                        var resultScore = grid.getCellValue(rowId, "EV_RESULT_SCORE");
                        var detailView;

                        if(resultScore == '') {
                            return;
                        }

                        if(progressCd == "100" || progressCd == "200") {
                            detailView = false;
                        } else {
                            detailView = true;
                        }
                        param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: detailView
                        };
                        everPopup.bs03_010open(param);
                    }
                }
                else if (colId =="EV_CNT"){
                    if(value!="0"){
                        var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                            EV_RESULT_SCORE: grid.getCellValue(rowId, "EV_RESULT_SCORE"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BS03_009P", 600, 300, param);
                    }
                }
                else if (colId == "BASIC_ATT_FILE_YN"||colId =="BIZ_ATT_FILE_YN"||colId=="ID_ATT_FILE_YN"||colId=="PRICE_ATT_FILE_YN"
                        ||colId=="CERTIFI_ATT_FILE_YN"||colId=="BANKBOOK_ATT_FILE_YN"||colId=="SIGN_ATT_FILE_YN"||colId=="CONTRACT_ATT_FILE_YN"
                        ||colId=="SECRET_ATT_FILE_YN"||colId=="IMGAGREE_ATT_FILE_YN"||colId=="PRIVATE_ATT_FILE_YN"||colId=="ATTACH_FILE_YN") {
                    if(value!=""){
                        var uuid = "";
                        if(colId =="BASIC_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'BASIC_ATT_FILE_NUM');
                        }else if(colId =="BIZ_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'BIZ_ATT_FILE_NUM');
                        }else if(colId =="ID_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'ID_ATT_FILE_NUM');
                        }else if(colId =="PRICE_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'PRICE_ATT_FILE_NUM');
                        }else if(colId =="CERTIFI_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'CERTIFI_ATT_FILE_NUM');
                        }else if(colId =="BANKBOOK_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'BANKBOOK_ATT_FILE_NUM');
                        }else if(colId =="SIGN_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'SIGN_ATT_FILE_NUM');
                        }else if(colId =="CONTRACT_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'CONTRACT_ATT_FILE_NUM');
                        }else if(colId =="SECRET_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'SECRET_ATT_FILE_NUM');
                        }else if(colId =="IMGAGREE_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'IMGAGREE_ATT_FILE_NUM');
                        }else if(colId =="PRIVATE_ATT_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'PRIVATE_ATT_FILE_NUM');
                        }else if(colId =="ATTACH_FILE_YN"){
                            uuid = grid.getCellValue(rowId, 'ATTACH_FILE_NO');
                        }
                        var param = {
                            havePermission : false,
                            attFileNum     : uuid,
                            rowId          : rowId,
                            bizType: 'VENDOR'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                else if (colId =="SG_CNT"){
                    if(value!="0"){
                        var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BS03_002P", 600, 300, param);
                    }
                }
                else if (colId == 'RQ_HIST'){
                    var param = {
                        searchFlag: 'Y',
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                        detailView: true
                    };
                    top.pageRedirectByScreenId('RQ0350', param);
                }
                else if (colId == 'BD_HIST'){
                    var param = {
                        searchFlag: 'Y',
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                        detailView: true
                    };
                    top.pageRedirectByScreenId('BD0360', param);
                }
                else if (colId =="EV_HIST"){
                    if(value!="0"){
                        var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("EV0270P03", 600, 300, param);
                    }
                }
            });

            EVF.C('PROGRESS_CD').removeOption('C');

            grid.setColIconify("HISTORY_YN", "HISTORY_YN", "detail", false);
            grid.setColIconify("BASIC_ATT_FILE_YN", "BASIC_ATT_FILE_YN", "file", false);
            grid.setColIconify("BIZ_ATT_FILE_YN", "BIZ_ATT_FILE_YN", "file", false);
            grid.setColIconify("ID_ATT_FILE_YN", "ID_ATT_FILE_YN", "file", false);
            grid.setColIconify("PRICE_ATT_FILE_YN", "PRICE_ATT_FILE_YN", "file", false);
            grid.setColIconify("CERTIFI_ATT_FILE_YN", "CERTIFI_ATT_FILE_YN", "file", false);
            grid.setColIconify("BANKBOOK_ATT_FILE_YN", "BANKBOOK_ATT_FILE_YN", "file", false);
            grid.setColIconify("SIGN_ATT_FILE_YN", "SIGN_ATT_FILE_YN", "file", false);
            grid.setColIconify("CONTRACT_ATT_FILE_YN", "CONTRACT_ATT_FILE_YN", "file", false);
            grid.setColIconify("SECRET_ATT_FILE_YN", "SECRET_ATT_FILE_YN", "file", false);
            grid.setColIconify("IMGAGREE_ATT_FILE_YN", "IMGAGREE_ATT_FILE_YN", "file", false);
            grid.setColIconify("PRIVATE_ATT_FILE_YN", "PRIVATE_ATT_FILE_YN", "file", false);
            grid.setColIconify("ATTACH_FILE_YN", "ATTACH_FILE_YN", "file", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs03001_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doInsert() {

            var param = {
                'VENDOR_CD': '',
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
        }

        function doConfirmReject() {

        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'SIGN_STATUS') == "E") {
                	return alert("${BS03_001_001 }");
                }
                if(grid.getCellValue(rowIds[i], 'SIGN_STATUS') == "R") {
                	return alert("${BS03_001_002 }");
                }
                if(grid.getCellValue(rowIds[i], 'SIGN_STATUS') != "P") {
                	return alert("${BS03_001_003 }");
                }
            }

            var signStatus = this.getData();
            var confirmMsg = (signStatus == "E" ? "${BS03_001_004}" : "${BS03_001_005}");

            if(!confirm(confirmMsg)) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
    		store.getGridData(grid, 'sel');
    		store.setParameter("signStatus", signStatus);
            store.load(baseUrl + 'bs03001_doConfirmReject', function(){
           		alert(this.getResponseMessage());
           		doSearch();
           	});
        }

        function doBlockYN() {

        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var vendorCd = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
            }
            var param = {
                'VENDOR_CD': vendorCd,
                'SIGN_STATUS': grid.getCellValue(rowIds[i], 'SIGN_STATUS'),
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS03_003", 1100, 600, param);
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

        function doSpEval() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var value = grid.getSelRowValue()[0];

            if(value.SPEV_CNT > 0) {
                return alert("${BS03_001_006}");
            }

            var param = {
                VENDOR_CD: value.VENDOR_CD,
                detailView: false,
                PROGRESS_CD: "100",
                SPEV_YN: "Y"
            };
            everPopup.bs03_010open(param);
        }


		function doModify() {
        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var vendorCd = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
            }
            var param = {
                'VENDOR_CD': vendorCd,
                'SIGN_STATUS': grid.getCellValue(rowIds[i], 'SIGN_STATUS'),
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
		}

    </script>

    <e:window id="BS03_001" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD"/>
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
                <e:label for="IRS_NO" title="${form_IRS_NO_N}" />
                <e:field>
                    <e:inputText id="IRS_NO" name="IRS_NO" value="" width="${form_IRS_NO_W}" maxLength="${form_IRS_NO_M}" disabled="${form_IRS_NO_D}" readOnly="${form_IRS_NO_RO}" required="${form_IRS_NO_R}" />
                </e:field>
				<e:label for="CEO_NM" title="${form_CEO_NM_N}" />
				<e:field>
				<e:inputText id="CEO_NM" name="CEO_NM" value="" width="${form_CEO_NM_W}" maxLength="${form_CEO_NM_M}" disabled="${form_CEO_NM_D}" readOnly="${form_CEO_NM_RO}" required="${form_CEO_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
               <%--
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
                --%>
                <e:label for="MAJOR_ITEM_CD" title="${form_MAJOR_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="MAJOR_ITEM_CD" name="MAJOR_ITEM_CD" value="" width="${form_MAJOR_ITEM_CD_W}" maxLength="${form_MAJOR_ITEM_CD_M}" disabled="${form_MAJOR_ITEM_CD_D}" readOnly="${form_MAJOR_ITEM_CD_RO}" required="${form_MAJOR_ITEM_CD_R}" />
                </e:field>
				<e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
				<e:field>
				<e:inputText id="MAKER_NM" name="MAKER_NM" value="" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
				</e:field>
                <e:label for="BLOCK_YN" title="${form_BLOCK_YN_N}"/>
                <e:field>
                    <e:select id="BLOCK_YN" name="BLOCK_YN" value="" options="${blockYnOptions }" width="${form_BLOCK_YN_W}" disabled="${form_BLOCK_YN_D}" readOnly="${form_BLOCK_YN_RO}" required="${form_BLOCK_YN_R}" placeHolder="" />
                </e:field>
            </e:row>
           <e:row>
               	<e:label for="SG_NUM" title="${form_SG_NUM_N}" />
               	<e:field>
                   <e:inputText id="SG_NUM" name="SG_NUM" value="" width="${form_SG_NUM_W}" maxLength="${form_SG_NUM_M}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" />
               	</e:field>
               	<e:label for="" title="" />
               	<e:field> </e:field>
                <e:label for="" title="" />
                <e:field> </e:field>
               	<e:inputHidden id="CLS01" name="CLS01" value=""/>
               	<e:inputHidden id="CLS02" name="CLS02" />
               	<e:inputHidden id="CLS03" name="CLS03" />
               	<e:inputHidden id="CLS04" name="CLS04" />
           </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <%--
			<e:button id="Insert" name="Insert" label="${Insert_N}" onClick="doInsert" disabled="${Insert_D}" visible="${Insert_V}"/>
			<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
			--%>
            <e:button id="BlockYN" name="BlockYN" label="${BlockYN_N }" disabled="${BlockYN_D }" visible="${BlockYN_V}" onClick="doBlockYN" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>