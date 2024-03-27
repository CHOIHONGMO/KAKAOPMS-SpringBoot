<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/master/catalog/BPR_070/";
    var popupFlag;
    var gridL;
    var gridR;
    var currentRow;

    function init() {

        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");
        popupFlag = '${param.popupFlag}';
		gridL.setColFontColor('TPL_NM', '0|0|255');
		gridL.setProperty('shrinkToFit', true);

        gridL.addRowEvent(function() {
            gridL.addRow();
        });

        gridL.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            onCellClickL(celName, rowId);
        });

        gridR.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            onCellClickR(celName, rowId);
        });

        var excelProp = {
            allCol: "${excelExport.allCol}",
            selRow: "${excelExport.selRow}",
            fileType: "${excelExport.fileType}",
            fileName: "${fullScreenName}",
            excelOptions: {
                imgWidth: 0.12,        <%-- // 이미지의 너비. --%>
                imgHeight: 0.26 ,      <%-- // 이미지의 높이. --%>
                colWidth: 20,          <%-- // 컬럼의 넓이. --%>
                rowSize: 500,          <%-- // 엑셀 행에 높이 사이즈. --%>
                attachImgFlag: false   <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        };
        gridL.excelExportEvent(excelProp);
        gridR.excelExportEvent(excelProp);

        if (popupFlag) {
            EVF.C('doSelect').setVisible(true);
            EVF.C('doClose').setVisible(true);
        } else {
            EVF.C('doSelect').setVisible(false);
            EVF.C('doClose').setVisible(false);
        }

        doSearch();
    }


    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridL]);
        store.load(baseUrl + "doSearchCatalogTemplateManagement", function() {
            if (gridL.getRowCount() == 0) {
                alert("${msg.M0002 }");
            } else {
            	if(eval(currentRow) >= 0) {
                	onCellClickL("TPL_NM", currentRow);
            	} else {
            		onCellClickL("TPL_NM", 0);
            	}
            }
        });
    }
    function doSearchItem() {
        var store = new EVF.Store();
        store.setGrid([gridR]);
        store.load(baseUrl + "doSearchItemCatalogTemplateManagement", function() {
            if (gridR.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }
    function onCellClickL(strColumnKey, nRow) {
        if (strColumnKey == "TPL_NM" && gridL.getCellValue(nRow, "TPL_NUM") != "") {
            EVF.C("TPL_NUM").setValue(gridL.getCellValue(nRow, "TPL_NUM"));
            EVF.C("TPLR_NM").setValue(gridL.getCellValue(nRow, "TPL_NM"));
            doSearchItem();
            currentRow = nRow;
        }
    }

    function onCellClickR(strColumnKey, nRow) {
        if (strColumnKey == "ITEM_CD") {
            var param = {
                'ITEM_CD': gridR.getCellValue(nRow, "ITEM_CD")
            };
            everPopup.openItemDetailInformation(param);
        }
    }

    function doCatalog() {
        var param = {
            popupFlag: true,
            callBackFunction: 'selectItem'
        };
        everPopup.openItemCatalogPopup(param);
    }

    function doMyCatalog() {
        var callBackFunction = 'selectItem';

        everPopup.openPopupByScreenId('BPR_080', 1000, 600, {
            callBackFunction: callBackFunction,
            popupFlag: true,
            detailView: false,
            openerScreen: 'BPR_070'
        });
    }

    function doSelect() {

        if(gridR.jsonToArray(gridR.getSelRowId())['key'].length === 0) {
            return alert("${msg.M0004}");
        }

        if('${param.openerScreen}' === 'BPRM_010') {
            var resultData = [];
            var selectedData = gridR.getSelRowValue();
            for(var x in selectedData) {
                var data = {};
                data['ITEM_CD'] = selectedData[x]['ITEM_CD'];
                data['ITEM_DESC'] = selectedData[x]['ITEM_DESC'];
                data['ITEM_SPEC'] = selectedData[x]['ITEM_SPEC'];
                data['UNIT_CD'] = selectedData[x]['UNIT_CD'];
                data['UNIT_PRC'] = selectedData[x]['UNIT_PRC'];
                data['ITEM_AMT'] = selectedData[x]['AMOUNT'];
                data['PR_QT'] = selectedData[x]['ITEM_QT'];
                resultData.push(data);
            }
            opener.window['${param.callBackFunction}'](JSON.stringify(resultData));
            window.close();
        } else {
            opener.window['${param.callBackFunction}'](JSON.stringify(grid.getSelRowValue()));
            window.close();
        }

        doClose();
    }

    function selectItem(datas) {
    	datas = JSON.parse(datas);
        var resultData = [];

        for(var x in datas) {
            var data = {};
            data['ITEM_CD'] = datas[x]['ITEM_CD'];
            data['ITEM_DESC'] = datas[x]['ITEM_DESC'];
            data['ITEM_SPEC'] = datas[x]['ITEM_SPEC'];
            data['UNIT_CD'] = datas[x]['UNIT_CD'];
            data['ITEM_QT'] = datas[x]['ITEM_QT'];
            data['TPL_NUM'] = EVF.C("TPL_NUM").getValue();
            resultData.push(data);
        }

        gridR.addRow(resultData);
    }

    function doSaveL() {

    	if (gridL.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
    	if (!gridL.validate().flag) { return alert(gridL.validate().msg); }

        if (!confirm("${msg.M0021}")) {
            return;
        }

        var store = new EVF.Store();
        store.setGrid([gridL]);
        store.getGridData(gridL, 'sel');
        store.load(baseUrl + "doSaveCatalogTemplateManagement", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function doSaveR() {

    	if (gridR.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
    	if (!gridR.validate().flag) { return alert(gridR.validate().msg); }

        if (!confirm("${msg.M0021}")) {
            return;
        }

        var store = new EVF.Store();
        store.setGrid([gridR]);
        store.getGridData(gridR, 'sel');
        store.load(baseUrl + "doSaveItemCatalogTemplateManagement", function() {
            alert(this.getResponseMessage());
            doSearchItem();
            doSearch();
        });
    }

    function doDeleteL() {

        if(gridL.jsonToArray(gridL.getSelRowId())['key'].length === 0) {
            return alert("${msg.M0004}");
        }

        if (confirm("${msg.M0009}")) {

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.getGridData(gridL, 'sel');
            store.load(baseUrl + "doDeleteCatalogTemplateManagement", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }
    }

    function doDeleteR() {

        if(gridR.jsonToArray(gridR.getSelRowId())['key'].length === 0) {
            return alert("${msg.M0004}");
        }

        if (confirm("${msg.M0009}")) {

            var store = new EVF.Store();
            store.setGrid([gridR]);
            store.getGridData(gridR, 'sel');
            store.load(baseUrl + "doDeleteItemCatalogTemplateManagement", function() {
                alert(this.getResponseMessage());
                doSearch();
                if (EVF.C("TPL_NUM").getValue() != "") {
                    for (var i = 0; i < gridL.getRowCount(); i++) {
                        if (gridL.getCellValue("TPL_NUM", i) == EVF.C("TPL_NUM").getValue()) {
//                            gridL.setActiveRowIndex(i);
                            onCellClickL("TPL_NM", i);
                            break;
                        }
                    }
                }
                doSearchItem();
            });
        }
    }

    function doClose() {
        formUtil.close();
    }

    function doAddLineL() {
        gridL.addRow();
    }

</script>

<e:window id="BPR_070" onReady="init" initData="${initData}" title="${fullScreenName}">
    <e:panel width="30%" height="100%">
        <e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch">
            <e:row>
                <e:label for="TPL_NM" title="${formL_TPL_NM_N}" />
                <e:field>
                    <e:inputText id="TPL_NM" name="TPL_NM" value="${form.TPL_NM}" width="100%" maxLength="${formL_TPL_NM_M}" disabled="${formL_TPL_NM_D}" readOnly="${formL_TPL_NM_RO}" required="${formL_TPL_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A}' />
            <e:button label='${doSaveL_N }' id='doSaveL' onClick='doSaveL' disabled='${doSaveL_D }' visible='${doSaveL_V }' data='${doSaveL_A }'/>
            <e:button label='${doDeleteL_N }' id='doDeleteL' onClick='doDeleteL' disabled='${doDeleteL_D }' visible='${doDeleteL_V }' data='${doDeleteL_A }'/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
    </e:panel>

    <e:panel width="1%">&nbsp;</e:panel>

    <e:panel width="69%" height="100%">
        <e:searchPanel id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch">
            <e:row>
                <e:label for="TPLR_NM" title="${formR_TPLR_NM_N}"/>
                <e:field>
                    <e:inputText id="TPLR_NM" name="TPLR_NM" value="${form.TPLR_NM}" width="100%" maxLength="${formR_TPLR_NM_M}" disabled="${formR_TPLR_NM_D}" readOnly="${formR_TPLR_NM_RO}" required="${formR_TPLR_NM_R}" />
                    <e:inputHidden id='TPL_NUM' name="TPL_NUM" visible='false' />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doSelect_N }' id='doSelect' align="left" onClick='doSelect' disabled='${doSelect_D }' visible='${doSelect_V }' data='${doSelect_A }'/>
            <e:button label='${doCatalog_N }' id='doCatalog' onClick='doCatalog' disabled='${doCatalog_D }' visible='${doCatalog_V }' data='${doCatalog_A }'/>
            <e:button id="doMyCatalog" name="doMyCatalog" label="${doMyCatalog_N}" onClick="doMyCatalog" disabled="${doMyCatalog_D}" visible="${doMyCatalog_V}"/>
            <e:button label='${doSaveR_N }' id='doSaveR' onClick='doSaveR' disabled='${doSaveR_D }' visible='${doSaveR_V }' data='${doSaveR_A }'/>
            <e:button label='${doDeleteR_N }' id='doDeleteR' onClick='doDeleteR' disabled='${doDeleteR_D }' visible='${doDeleteR_V }' data='${doDeleteR_A }'/>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A}' />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
    </e:panel>
</e:window>
</e:ui>