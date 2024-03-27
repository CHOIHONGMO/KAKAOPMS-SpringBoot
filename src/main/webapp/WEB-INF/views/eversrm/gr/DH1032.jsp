<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/eversrm/gr/DH1032";
        var selRow;

        function init() {
            if(${not empty form.SL_NUM} && ${not param.detailView eq 'true'}) {
                alert('${DH1032_002}');
                formUtil.close();
            }

            grid = EVF.C('grid');
            //grid Column Head Merge
            grid.setProperty('multiselect', true);
            grid.setProperty('panelVisible', ${panelVisible});
            grid.delRowEvent(function () {
            	grid.delRow();
            });

            // Grid Excel Event
            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,
                    imgHeight: 0.26,
                    colWidth: 20,
                    rowSize: 500,
                    attachImgFlag: false
                }
            });
            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {

                if (code) {
                    grid.checkAll(true);

                    var allRowId = grid.getAllRowId();
                    for(var i in allRowId) {

                        var rowId = allRowId[i];

//                        grid.setCellValue(rowId, 'PURCHASE_TYPE', 'DMRO');
//                        grid.setCellValue(rowId, 'REG_USER_ID', '${ses.userId}');
//                        grid.setCellValue(rowId, 'REG_USER_NM', '${ses.userNm}');
                    }
                }
            });
            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {

            });

            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {

            });


            if (EVF.isNotEmpty('${param.dealNum}')) {
                doSearch();
            }
        }

        function setAccount(data) {
            grid.setCellValue(selRow, "ACCOUNT_CD", data['ACCOUNT_CD']);
        }

        // Search
        function doSearch() {
            var store = new EVF.Store();

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
               // doSearchGroupwareDocs();
                //setAmount();
            });
        }

        function doSave() {
            grid.checkAll(true);
            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }
            var selRowsI = grid.getSelRowValue();

            if (!confirm("${msg.M0021}")) {
                return;
            }

            var sum = 0;
            for (var i = 0; i < grid.getRowCount(); i++) {
            	var currency = grid.getCellValue(i, "CUR");
                var grAmt = grid.getCellValue(i, "GR_AMT");

                if (currency != '' && grAmt != '') {
                    sum += everCurrency.getAmount(currency, grAmt);
                }
            }
            EVF.getComponent('SUP_AMT').setValue(sum);

            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.doFileUpload(function () {
                store.load(baseUrl + '/doSave', function () {
                    alert(this.getResponseMessage());
                    var params = {
                        "dealNum": ''
                    };
                    location.href = baseUrl + '/view.so?' + $.param(params);
                });
            })
        }

        function doDelete() {

            if(${empty form.DEAL_NUM}) {
                return alert("${msg.M0118}");
            }

            if (!confirm('${msg.M0013}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doDelete', function () {
                alert(this.getResponseMessage());
                formUtil.close();
            });
        }


        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="DH1032" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="DATA_CREATE_TYPE" name="DATA_CREATE_TYPE" value="${form.DATA_CREATE_TYPE}" />
        <e:inputHidden id="SUP_AMT" name="SUP_AMT" value="${form.SUP_AMT}" />

        <e:buttonBar width="100%" align="right">
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <c:if test="${not empty param.popupFlag}">
                <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
            </c:if>
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="110" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
            <e:row>
                <e:label for="DEAL_NUM" title="${form_DEAL_NUM_N}"/>
                <e:field>
                    <e:inputText id="DEAL_NUM" style="ime-mode:inactive" name="DEAL_NUM" value="${form.DEAL_NUM}" width="${inputTextWidth}" maxLength="${form_DEAL_NUM_M}" disabled="${form_DEAL_NUM_D}" readOnly="${form_DEAL_NUM_RO}" required="${form_DEAL_NUM_R}"/>
                </e:field>

				<e:label for="SL_TYPE" title="${form_SL_TYPE_N}"/>
				<e:field>
				<e:select id="SL_TYPE" onChange="chSlType" name="SL_TYPE" value="BU" options="${slTypeOptions}" width="${inputTextWidth}" disabled="true" readOnly="${form_SL_TYPE_RO}" required="${form_SL_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:select id="BUYER_CD" onChange="chBuyerCd" name="BUYER_CD" value="${ses.companyCd}" options="${buyerCdOptions}" width="${inputTextWidth}" disabled="" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>
