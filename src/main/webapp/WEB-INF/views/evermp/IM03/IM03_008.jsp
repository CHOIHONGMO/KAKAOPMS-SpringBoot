<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0301/";

        function init() {

            grid = EVF.C("grid");
            grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

                if (colId == 'IMG_FILE_CNT') {

                    var param = {
                        attFileNum: grid.getCellValue(rowId, 'IMG_FILE_NUM'),
                        mainImgSq: grid.getCellValue(rowId, 'MAIN_IMG_SQ'),
                        rowId: rowId,
                        callBackFunction: 'setImgFile',
                        havePermission: true,
                        bizType: 'IMG',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonImgFileAttach', 900, 410, param);

                } else if (colId == 'ATT_FILE_CNT') {

                    var param = {
                        attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: 'setAttFile',
                        havePermission: true,
                        bizType: 'IT',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

                } else if (colId == 'MAKER_NM') {

                    var param = {
                        rowId: rowId,
                        callBackFunction: 'setMakerG'
                    };
                    everPopup.openCommonPopup(param, 'SP0068');

                } else if (colId == 'BRAND_NM') {

                    var param = {
                        rowId: rowId,
                        callBackFunction: 'setBrandG'
                    };
                    everPopup.openCommonPopup(param, 'SP0088');

                } else if (colId == 'SG_NM') {


                } else if (colId == 'ITEM_CLS_NM') {

                    var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                    var param = {
                        callBackFunction: "_setItemClassNm_Grid",
                        detailView: false,
                        multiYN: false,
                        ModalPopup: true,
                        searchYN: true,
                        rowId: rowId,
                        'custCd': '${ses.companyCd}',
                        'custNm': '${ses.companyNm}'
                    };
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");

                } else if (colId == 'PT_ITEM_CLS_NM') {

                    var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                    var param = {
                        callBackFunction: "_setPTItemClassNm_Grid",
                        detailView: false,
                        multiYN: false,
                        ModalPopup: true,
                        searchYN: true,
                        rowId: rowId,
                        ptYn: true,
                        screenName: '분류체계(판촉)',
                        'custCd': '${ses.manageCd}',
                        'custNm': '${ses.companyNm}'
                    };
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");


                } else if (colId == 'ITEM_DETAIL_TEXT_FLAG') {

                    var param = {
                        rowId: rowId
                        , havePermission: true
                        , screenName: '상세설명'
                        , callBackFunction: 'setItemDetailText'
                        , largeTextNum: grid.getCellValue(rowId, "ITEM_DETAIL_TEXT_NUM")
                        , detailView: false
                    };
                    everPopup.openPopupByScreenId('commonRichTextContents', 900, 600, param);

                } else if (colId == 'ITEM_CHG_REASON') {

                    var param = {
                        rowId: rowId
                        , havePermission: true
                        , screenName: '품목상태 변경사유'
                        , callBackFunction: 'setItemChgReason'
                        , TEXT_CONTENTS: grid.getCellValue(rowId, "ITEM_CHG_REASON")
                        , detailView: false
                    };
                    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);

                } else if (colId == 'VENDOR_ITEM_CD') {

                    if (EVF.isEmpty(grid.getCellValue(rowId, 'ITEM_CD'))) {
                        return alert('${IM03_008_001}');
                    }

                    var popupUrl = "/evermp/IM03/IM0301/IM03_008P/view";
                    var param = {
                        rowId: rowId
                        , itemCd: grid.getCellValue(rowId, 'ITEM_CD')
                        , callBackFunction: 'setVendorItemCdCount'
                        , detailView: false
                    };
                    everPopup.openModalPopup(popupUrl, 600, 800, param);

                } else if (colId == 'ITEM_CD') {
                    if (value != "") {
                        var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupFlag': true,
                            'detailView': false
                        };
                        everPopup.im03_009open(param);
                    }

                } else if (colId == 'ITEM_DESC') {
                	return;
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_014open(param);

                } else if (colId == 'ITEM_DETAIL_FILE_FLAG') {

                    var popupUrl = "/evermp/IM03/IM0301/IM03_017/view";
                    var param = {
                        rowId: rowId,
                        'ITEM_DETAIL_FILE_NUM': grid.getCellValue(rowId, 'ITEM_DETAIL_FILE_NUM'),
                        callBackFunction: 'setDetailFile',
                        popupFlag: true,
                        detailView: false,
                        ModalPopup: true,
                        bizType: 'IT',
                        fileExtension: '*'
                    };
                    everPopup.openModalPopup(popupUrl, 550, 620, param, "itemNotcPopup");



                } else if (colId == 'ITEM_NOTC_FLAG') {

                    var popupUrl = "/evermp/IM03/IM0301/IM03_018/view";
                    var param = {
                        rowId: rowId,
                        'ITEM_NOTC_DESC': grid.getCellValue(rowId, 'ITEM_NOTC_DESC'),
                        'ITEM_NOTC_CERT': grid.getCellValue(rowId, 'ITEM_NOTC_CERT'),
                        'ITEM_NOTC_ORIGIN': grid.getCellValue(rowId, 'ITEM_NOTC_ORIGIN'),
                        'ITEM_NOTC_MAKER': grid.getCellValue(rowId, 'ITEM_NOTC_MAKER'),
                        'ITEM_NOTC_AS': grid.getCellValue(rowId, 'ITEM_NOTC_AS'),
                        'popupFlag': true,
                        'detailView': false,
                        ModalPopup: true,
                        callBackFunction: 'setItemNotc'
                    };
                    everPopup.openModalPopup(popupUrl, 900, 500, param, "itemNotcPopup");
                } else if (colId == 'MOD_USER_NM') {
                    if( grid.getCellValue(rowId, 'MOD_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'MOD_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, ir, or, value, oldValue) {
            	if (colId == 'ITEM_STATUS') {

					if(grid.getCellValue(rowId,'ITEM_STATUS') =='10')
            		grid.setCellValue(rowId,'ITEM_CHG_REASON','');

            	}




            });


            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });

            if("${param.autoSearchFlag}" == "Y") {
                EVF.V("REG_FROM_DATE", "${param.IMG_FROM_DATE}");
                EVF.V("REG_TO_DATE", "${param.IMG_TO_DATE}");
                EVF.C("IMAGE_FLAG_YN").setChecked(true);

                doSearch();
            }
        }

        function doSearch() {
            var flag = true;
            $('input').each(function (k, v) {
                if (!(v.type == 'hidden' || v.type == 'radio' || v.type == 'checkbox' || v.id == 'grid_line' || v.id == 'grid-search')) {
                    if (v.value != '') {
                        flag = false;
                    }
                }
            });

            if(flag) {
                alert("${IM03_008_003}"); // 검색조건을 한개 이상 입력하여 주시기 바랍니다.
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "IM03_008/im03008_doSearch", function () {
                if (grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }
            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!grid.validate().flag) {
                return alert(grid.validate().msg);
            }

            var allRowId = grid.getSelRowId();
            for(var i in allRowId) {
                var rowId = allRowId[i];

                if(grid.getCellValue(rowId, "ITEM_STATUS") != '10' && grid.getCellValue(rowId, "ITEM_CHG_REASON") == '') {
                	EVF.alert('변경사유를 입력해주세요.');
                	return;
                }
            }







            if (!confirm("${msg.M0021}")) return;
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "IM03_008/im03008_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doEstimate(){
            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }
            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!confirm("${IM03_008_002}")) return;

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "IM03_008/im03008_doEstimate", function () {
                alert(this.getResponseMessage());
            });
        }

        function setImgFile(rowId, fileId, fileCnt, mainImgSq) {

            console.log(rowId + "_____" + fileId + "_____" + fileCnt + "_____" + mainImgSq);
            grid.setCellValue(rowId, 'IMG_FILE_NUM', fileId);       //IMG_ATT_FILE_NUM
            grid.setCellValue(rowId, 'IMG_FILE_CNT', fileCnt);
            grid.setCellValue(rowId, 'MAIN_IMG_SQ', mainImgSq);

        }

        function setAttFile(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, 'ATT_FILE_NUM', fileId);
            grid.setCellValue(rowId, 'ATT_FILE_CNT', fileCnt);
        }

        function searchMakerCd() {
            var param = {
                callBackFunction: "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD", dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM", dataJsonArray.MKBR_NM);
        }

        function searchBrandCd() {
            var param = {
                callBackFunction: "selectBrandCd"
            };
            everPopup.openCommonPopup(param, 'SP0088');
        }

        function selectBrandCd(dataJsonArray) {
            EVF.V("BRAND_CD", dataJsonArray.MKBR_CD);
            EVF.V("BRAND_NM", dataJsonArray.MKBR_NM);
        }

        function _getItemClsNm() {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction: "_setItemClassNm",
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'searchYN': true,
                'custCd': '${ses.companyCd}',  // 고객사코드or회사코드
                'custNm': '${ses.companyNm}'  // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNm(data) {
            if (data != null) {
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                if (data.ITEM_CLS2 == "*") {
                    EVF.C("ITEM_CLS2").setValue("");
                } else {
                    EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);
                }
                if (data.ITEM_CLS3 == "*") {
                    EVF.C("ITEM_CLS3").setValue("");
                } else {
                    EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);
                }
                if (data.ITEM_CLS4 == "*") {
                    EVF.C("ITEM_CLS4").setValue("");
                } else {
                    EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);
                }
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }


        function _getSGClsNm() {

            var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
            var param = {
                callBackFunction: '_setSg',
                'multiYN': false,
                'ModalPopup': true,
                'searchYN': true
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
        }

        function _setSg(data) {
            if (data != null) {
                data = JSON.parse(data);
                EVF.C("SG_NUM1").setValue(data.ITEM_CLS1);
                if (data.ITEM_CLS2 == "*") {
                    EVF.C("SG_NUM2").setValue("");
                } else {
                    EVF.C("SG_NUM2").setValue(data.ITEM_CLS2);
                }
                if (data.ITEM_CLS3 == "*") {
                    EVF.C("SG_NUM3").setValue("");
                } else {
                    EVF.C("SG_NUM3").setValue(data.ITEM_CLS3);
                }
                if (data.ITEM_CLS4 == "*") {
                    EVF.C("SG_NUM4").setValue("");
                } else {
                    EVF.C("SG_NUM4").setValue(data.ITEM_CLS4);
                }
                EVF.C("SG_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("SG_NUM1").setValue("");
                EVF.C("SG_NUM2").setValue("");
                EVF.C("SG_NUM3").setValue("");
                EVF.C("SG_NUM4").setValue("");
                EVF.C("SG_NM").setValue("");
            }
        }

        function setItemDetailText(datum) {
            datum = JSON.parse(datum);
            if (EVF.isEmpty(datum)) {
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_FLAG', '');
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_NUM', datum.largeTextNum);
            } else {
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_FLAG', 'Y');
                grid.setCellValue(datum.rowId, 'ITEM_DETAIL_TEXT_NUM', datum.largeTextNum);
            }
        }

        function setItemNotc(datum){
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_FLAG', 'Y');
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_DESC', datum.ITEM_NOTC_DESC);
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_CERT', datum.ITEM_NOTC_CERT);
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_ORIGIN', datum.ITEM_NOTC_ORIGIN);
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_MAKER', datum.ITEM_NOTC_MAKER);
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_AS', datum.ITEM_NOTC_AS);
            grid.setCellValue(datum.rowId, 'ITEM_NOTC_AS', datum.ITEM_NOTC_AS);
        }

        function setDetailFile(datum){
            grid.setCellValue(datum.rowId, 'ITEM_DETAIL_FILE_FLAG', 'Y');
            grid.setCellValue(datum.rowId, 'ITEM_DETAIL_FILE_NUM', datum.ITEM_DETAIL_FILE_NUM);


        }

        function setItemChgReason(datum, rowId) {
            grid.setCellValue(rowId, 'ITEM_CHG_REASON', datum);
        }

        function _setItemClassNm_Grid(data) {
            if (data != null) {
                data = JSON.parse(data);
                grid.setCellValue(data.rowId, 'ITEM_CLS1', data.ITEM_CLS1);
                grid.setCellValue(data.rowId, 'ITEM_CLS2', data.ITEM_CLS2);
                grid.setCellValue(data.rowId, 'ITEM_CLS3', data.ITEM_CLS3);
                grid.setCellValue(data.rowId, 'ITEM_CLS4', data.ITEM_CLS4);
                grid.setCellValue(data.rowId, 'ITEM_CLS_NM', data.ITEM_CLS_PATH_NM);
                doSearchSG(data);

            } else {
                grid.setCellValue(data.rowId, 'ITEM_CLS1', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS2', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS3', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS4', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS_NM', '');
            }
        }

        function _setPTItemClassNm_Grid(data) {
            if (data != null) {
                data = JSON.parse(data);
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS1', data.ITEM_CLS1);
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS2', data.ITEM_CLS2);
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS3', data.ITEM_CLS3);
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS_NM', data.ITEM_CLS_PATH_NM);
                doSearchDPSG(data);

            } else {
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS1', '');
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS2', '');
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS3', '');
                grid.setCellValue(data.rowId, 'PT_ITEM_CLS_NM', '');
            }
        }

        //        function _setSg_G(data) {
        //            data = JSON.parse(data);
        //            grid.setCellValue(data.rowId, 'SG_CD', data.SG_NUM);
        //            grid.setCellValue(data.rowId, 'SG_NM', data.ITEM_CLS_NM);
        //            grid.setCellValue(data.rowId, 'SG_CTRL_USER_ID', data.CTRL_USER_ID);
        //        }


        function setMakerG(data) {
            grid.setCellValue(data.rowId, 'MAKER_CD', data.MKBR_CD);
            grid.setCellValue(data.rowId, 'MAKER_NM', data.MKBR_NM);
        }
        function setBrandG(data) {
            grid.setCellValue(data.rowId, 'BRAND_CD', data.MKBR_CD);
            grid.setCellValue(data.rowId, 'BRAND_NM', data.MKBR_NM);
        }
        function setVendorItemCdCount(data) {
            grid.setCellValue(data.rowId, 'VENDOR_ITEM_CD', data.count);
        }

        function doSearchSG(data) {
            var store = new EVF.Store();
            store.setParameter("ITEM_CLS1", data.ITEM_CLS1);
            store.setParameter("ITEM_CLS2", data.ITEM_CLS2);
            store.setParameter("ITEM_CLS3", data.ITEM_CLS3);
            store.setParameter("ITEM_CLS4", data.ITEM_CLS4);
            store.load(baseUrl + '/setSgData', function () {

                var sgValues = JSON.parse(this.getParameter('sgDatas'));
                if (sgValues != null) {
                    grid.setCellValue(data.rowId, 'SG_CD', sgValues.SG_NUM);
                    grid.setCellValue(data.rowId, 'SG_NM', sgValues.ITEM_CLS_PATH_NM);
                    grid.setCellValue(data.rowId, 'SG_CTRL_USER_ID', sgValues.CTRL_USER_ID);
                }
            });
        }

        function doSearchDPSG(data) {
            var store = new EVF.Store();
            store.setParameter("PT_ITEM_CLS1", data.ITEM_CLS1);
            store.setParameter("PT_ITEM_CLS2", data.ITEM_CLS2);
            store.setParameter("PT_ITEM_CLS3", data.ITEM_CLS3);

            store.load(baseUrl + '/setDPSgData', function () {

                var sgValues = JSON.parse(this.getParameter('dpsgDatas'));
                if (sgValues != null) {
                    grid.setCellValue(data.rowId, 'PT_SG_CD', sgValues.SG_NUM);
                    grid.setCellValue(data.rowId, 'PT_SG_NM', sgValues.ITEM_CLS_PATH_NM);
                }
            });
        }

    </script>

    <e:window id="IM03_008" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:inputHidden id="PT_ITEM_CLS1" name="PT_ITEM_CLS1"/>
        <e:inputHidden id="PT_ITEM_CLS2" name="PT_ITEM_CLS2"/>
        <e:inputHidden id="PT_ITEM_CLS3" name="PT_ITEM_CLS3"/>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field colSpan="3">
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1"/>
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2"/>
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3"/>
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4"/>
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}"/>
                </e:field>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REG_FROM_DATE" name="REG_FROM_DATE" value="" toDate="REG_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}"/>
                    <e:text>~</e:text>
                    <e:inputDate id="REG_TO_DATE" name="REG_TO_DATE" value="" fromDate="REG_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                </e:field>
				<e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
				<e:field>
				<e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="" options="${sgCtrlUserIdOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
                <e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
                <e:field>
                    <e:select id="ITEM_STATUS" name="ITEM_STATUS" value="10" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder=""/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="40%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
					<e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="60%" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
				</e:field>
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:search id="MAKER_CD" style="ime-mode:inactive" name="MAKER_CD" value="" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="${form_MAKER_CD_RO ? 'everCommon.blank' : 'searchMakerCd'}" disabled="${form_MAKER_CD_D}" readOnly="${form_MAKER_CD_RO}" required="${form_MAKER_CD_R}"/>
                    <e:inputText id="MAKER_NM" style="${imeMode}" name="MAKER_NM" value="" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}"/>
                </e:field>
                <e:label for="SEARCH_COUNT_CD" title="${form_SEARCH_COUNT_CD_N}"/>
				<e:field>
					<e:select id="SEARCH_PAGE_NO" name="SEARCH_PAGE_NO" value="1" options="${searchPageNoOptions}" width="40%" disabled="${form_SEARCH_PAGE_NO_D}" readOnly="${form_SEARCH_PAGE_NO_RO}" required="${form_SEARCH_PAGE_NO_R}" placeHolder="" usePlaceHolder="false"/>
					<e:select id="SEARCH_COUNT_CD" name="SEARCH_COUNT_CD" value="500" options="${searchCountCdOptions}" width="60%" disabled="${form_SEARCH_COUNT_CD_D}" readOnly="${form_SEARCH_COUNT_CD_RO}" required="${form_SEARCH_COUNT_CD_R}" placeHolder="" />
				</e:field>
				<%--
				<e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
				<e:field>
					<e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
				</e:field>
				--%>
				<e:inputHidden id="STD_FLAG" name="STD_FLAG"/>
                <e:inputHidden id="SG_NM" name="SG_NM"/>
                <e:inputHidden id="SG_NUM1" name="SG_NUM1"/>
                <e:inputHidden id="SG_NUM2" name="SG_NUM2"/>
                <e:inputHidden id="SG_NUM3" name="SG_NUM3"/>
                <e:inputHidden id="SG_NUM4" name="SG_NUM4"/>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <div>
                <e:text style="color:black;font-weight:bold;">${IM03_008_TITLE1}</e:text>
            </div>
            <div style="float: right;">
                <e:check id="IMAGE_FLAG_YN" name="IMAGE_FLAG_YN" value="1"/><e:text style="font-weight: bold;">이미지없음 </e:text>
                <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
                <%--<e:button id="openBulk" name="openBulk" label="${openBulk_N}" onClick="doopenBulk" disabled="${openBulk_D}" visible="${openBulk_V}"/>--%>
                <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
                <%--<e:button id="Estimate" name="Estimate" label="${Estimate_N}" onClick="doEstimate" disabled="${Estimate_D}" visible="${Estimate_V}"/>--%>
            </div>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>