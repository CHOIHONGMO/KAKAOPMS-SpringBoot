<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/rfqProgress/";

    function init() {

        grid = EVF.getComponent("grid");

        if ('${param.qtaNum}' !== '') {
            EVF.getComponent('QTA_NUM').setValue('${param.qtaNum}');
            doSearch();
        } else if ('${param.rfxNum}' !== '') {
            var rfxNum = '${param.rfxNum}';
            var rfxCnt = '${param.rfxCnt}';

            EVF.getComponent('RFX_NUM').setValue(rfxNum);
            EVF.getComponent('RFX_CNT').setValue(rfxCnt);

            if ('${ses.userType}' == 'S') {
                EVF.getComponent('VENDOR_CD').setValue('${ses.companyCd}');
                EVF.getComponent('VENDOR_CD').setDisabled('true');
            }
            doSearch();
        }

        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            if (celName === 'SUB_ITEM') {
                if ("${param.detailView }" == 'false') {
                    var param = {
                        rowid: rowId,
                        rfxNo: grid.getCellValue(rowId, 'RFX_NUM'),
                        rfxCnt: grid.getCellValue(rowId, 'RFX_CNT'),
                        rfxSq: grid.getCellValue(rowId, 'RFX_SQ'),
                        qtaNum: grid.getCellValue(rowId, 'QTA_NUM'),
                        itemAmt : grid.getCellValue(rowId, 'ITEM_AMT'),
                        qtaSq: grid.getCellValue(rowId, 'QTA_SQ'),
//                        cur: EVF.getComponent(rowId, 'CUR').getValue(),
                        detailView: 'false',
                        callBackFunction: 'setSubItem'
                    };
                    everPopup.openQuotationSubItem(param);
                }
            } else if (celName === 'RC_ATT_FILE_NUM') {
                var uuid = grid.getCellValue(rowId, 'R_ATT_FILE_NUM');
                if ('${param.detailView}' === 'true') {
                    everPopup.readOnlyFileAttachPopup('RFQ', uuid, 'fileAttachPopupCallback_R', 'true');
                } else {
                    everPopup.fileAttachPopup('RFQ', uuid, 'fileAttachPopupCallback_R', 'true');
                }

            } else if (celName === 'QC_ATT_FILE_NUM') {
                var uuid = grid.getCellValue(rowId, 'Q_ATT_FILE_NUM');
                if ('${param.detailView}' === 'true') {
                    everPopup.readOnlyFileAttachPopup('RFQ', uuid, 'fileAttachPopupCallback', '${param.detailView}');
                } else {
                    everPopup.fileAttachPopup('RFQ', uuid, 'fileAttachPopupCallback', '${param.detailView}');
                }

            }
        });

        grid.cellChangeEvent(function(rowId, celName, iRow, iCol, value, oldValue) {
            if (celName === 'UNIT_PRC') {
                if (EVF.getComponent('CUR').getValue() === '') {
                    grid.setCellValue(rowId, celName, oldValue);
                    return;
                }

                if (Number(value) < 0) {
                    alert('${SPX_020_0002}');
                    grid.setCellValue(rowId, celName, oldValue);
                    return;
                }
                calculateSum();
            }

            if (celName === 'VALID_FROM_DATE' || celName == 'QTA_DUE_DATE') {

                everDate.diffWithServerDate(value, function(status, message) {
                    if (status === '-1') {
                        alert('${SPX_020_0003}');
                        grid.setCellValue(rowId, celName, oldValue);
                    } else {
                        if (grid.getCellValue(rowId, 'VALID_TO_DATE') < grid.getCellValue(rowId, 'VALID_FROM_DATE') && grid.getCellValue(rowId, 'VALID_TO_DATE') != '') {
                            alert('${SPX_020_0004}');
                            grid.setCellValue(rowId, celName, oldValue);
                        }
                    }
                }, "true");
            }

            if (celName === 'VALID_TO_DATE') {
                if (grid.getCellValue(rowId, 'VALID_TO_DATE') < grid.getCellValue(rowId, 'VALID_FROM_DATE')) {
                    alert('${SPX_020_0004}');
                    grid.setCellValue(rowId, celName, oldValue);
                }
            }

            if (celName === 'ITEM_CD') {
                var store = new EVF.Store();
                store.setParameter("itemCd", value);
                store.load("/common/util/getItemSearchByCode", function() {
                    if (this.getParameter('result') === 'null') {
                        grid.setCellValue(rowId, 'ITEM_CD', oldValue);
                    } else {
//                    gridUtil.setRowData(grid, nRow, JSON.parse(this.getParameter('result')), [{
//                        source: 'ITEM_DESC_ENG',
//                        target: 'ITEM_DESC'
//                    }]);
                    }
                });
            }

            if (celName === 'GIVEUP_FLAG') {
                if (value === "1") {
                    grid.setCellValue(rowId, "UNIT_PRC", 0);
                }
                calculateSum();
            }
        });
    }

    function changeVendor(obj, selectedVendor, oldVendor) {
        var param = {
            "rfxNum" : '${param.rfxNum}',
            "rfxCnt" : '${param.rfxCnt}',
            "vendorCd" : selectedVendor,
            "detailView": false
        };
        location.href=baseUrl+'SPX_020/view.so?'+ $.param(param);
    }

    function fileAttachCallback(result) {
        EVF.getComponent('ATT_FILE_NUM').setValue(result.UUID);
    }

    function fileAttachPopupCallback(fileInfo) {
        //grid.setCellValue('ATTACH_FILE_COUNT', fileInfo.nRow, fileInfo.FILE_COUNT);
        grid.setCellValue('ATT_FILE_NUM', fileInfo.nRow, fileInfo.UUID);
    }

    function doSearch() {

        if ('${param.rfxNum}' !== '') {
            var rfxNum = '${param.rfxNum}';
            var rfxCnt = '${param.rfxCnt}';
            var isPreferredBidder = ${empty param.isPrefferedBidder ? false : param.isPrefferedBidder};

//            EVF.getComponent('RFX_NUM').setValue(rfxNum);
//            EVF.getComponent('RFX_CNT').setValue(rfxCnt);
        }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "SPX_020/doSearch", function() {

            <%--if (EVF.getComponent('VALID_TO_DATE').getValue() === '') {--%>
                    <%--EVF.getComponent('VALID_TO_DATE').setValue('${toDate}');--%>
            <%--}--%>
//            EVF.getComponent('VENDOR_CD').setDisplayText(EVF.getComponent('VENDOR_NM').getValue());
//            EVF.getComponent('isPrefferedBidder').setValue(isPrefferedBidder);

            <%-- 우선협상 대상자 --%>
            if(isPreferredBidder) {
                for(var i=0; i < grid.getRowCount(); i++) {
                    var awardFlag = grid.getCellValue(i, 'AWARD_FLAG');
                    if(awardFlag === '0') {
//                        gridUtil.setCellActivation(grid, 'UNIT_PRC', i, 'activatenoedit');
//                        gridUtil.setCellActivation(grid, 'QTA_DUE_DATE', i, 'activatenoedit');
//                        gridUtil.setCellActivation(grid, 'VALID_FROM_DATE', i, 'activatenoedit');
//                        gridUtil.setCellActivation(grid, 'VALID_TO_DATE', i, 'activatenoedit');
                    }
                }
            }

            grid.checkAll(true);

        });
    }

    function doSubmit() {
        saveSubmit('1');
    }

    function doSave() {
        saveSubmit('0');
    }

    function saveSubmit(saveType) {

        if (EVF.getComponent('SAVE_FLAG').getValue() == "N") {
            alert("${msg.M0008 }");
            return;
        }

        var store = new EVF.Store();
        if(!store.validate()) { return; }

        if (EVF.getComponent('SETTLE_TYPE').getValue() == 'DOC') {
            for (var s = 0; s < grid.getRowCount(); s++) {
                if (grid.getCellValue('GIVEUP_FLAG', s) == '1') {
                    alert('${SPX_020_0007}');
                    return;
                }
            }
        }

        var a = EVF.getComponent('VALID_TO_DATE').getValue();
        everDate.diffWithServerDate(a, function(status, message) {

            var isPreferedBidder = '${param.isPrefferedBidder}';
            if (isPreferedBidder === true) {
                status = '1';
            }
            if (status === '-1') {
                alert('${SPX_020_0003}');
                EVF.getComponent('VALID_TO_DATE').setValue('${toDate}');
            } else {
                
                var intArray = {};
                var k = 0;

                for (var i = 0; i < grid.getRowCount(); i++) {
                    if (grid.getCellValue('SELECTED', i) == '1') {
                        if (grid.getCellValue('GIVEUP_FLAG', i) == '1') {
                            intArray[k++] = i;
                            grid.setCellValue('SELECTED', i, '0');
                        } else {
                            if (parseInt(grid.getCellValue("UNIT_PRC", i)) == 0) return alert("${msg.M0014}");
                        }
                    }
                }

                if (!grid.validate().flag) { return alert(grid.validate().msg); }

				var cur = EVF.getComponent('CUR').getValue();

                var allRowId = grid.getAllRowId();
                for(var x in allRowId) {
                    var rowId = allRowId[x];

					if (grid.getCellValue(rowId, 'GIVEUP_FLAG') != '1') {
					    if ( grid.getCellValue(rowId, 'SUB_ITEM_JSON') == '' && grid.getCellValue(rowId, 'SUB_ITEM') != 0){
                            return alert('${SPX_020_0009}');
						}
						
<!-- 						var subItemTotalAmt = gridUtil.getCellValue(grid, 'SUB_ITEM_JSON', i); -->
<!-- 						if(gridUtil.getCellValue(grid, 'SUB_ITEM', i) != 0 && parseFloat(gridUtil.getCellValue(grid, 'ITEM_AMT', i)) != parseFloat(subItemTotalAmt)) { -->
<!--                             alert('${SPX_020_0010}'); -->
<!--                             return ; -->
<!--                         }            -->
						var jsonData = grid.getCellValue(rowId, 'SUB_ITEM_JSON');
						if(jsonData != ''){
							var subItemJsonData = JSON.parse(jsonData);
							var subItemTotalAmt = 0;			
							for(var j = 0; j < subItemJsonData.length; j++){
								subItemTotalAmt += everCurrency.getAmount(cur, subItemJsonData[j].UNIT_PRC);
							}
							
							if(parseFloat(grid.getCellValue(rowId, 'ITEM_AMT')) != parseFloat(subItemTotalAmt)) {
								alert('${SPX_020_0010}');
								return ;
							}			
						}
					}
				}	
								
                var msg = saveType == '0' ? "${msg.M0021}" : "${msg.M0060}";
                if (!confirm(msg)) return;

                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'all');
                store.setParameter('saveType', saveType);
                store.doFileUpload(function() {
                    store.load(baseUrl + "SPX_020/doSave", function() {
                        alert(this.getResponseMessage());
                        opener['doSearch']();
                        var param = {
                            "rfxNum" : '${param.rfxNum}',
                            "rfxCnt" : '${param.rfxCnt}',
                            "vendorCd" : EVF.C('VENDOR_CD').getValue(),
                            "detailView": false
                        };
                        location.href=baseUrl+'SPX_020/view.so?'+ $.param(param);
                    });
                });
            }
        });
    }
		
    function doDelete() {

        if (EVF.getComponent("QTA_NUM").getValue() == "") return alert("${msg.M0004 }");

        if (!confirm("${msg.M0013 }")) return;

        var store = new EVF.Store();
        store.load(baseUrl + "SPX_020/doDelete", function() {
            alert(this.getResponseMessage());
            if (opener !== undefined && opener.doSearch !== undefined) opener.doSearch();
            window.close();
        });
    }

    function setSubItem(subItemJson, rowId) {
        grid.setCellValue(rowId, 'SUB_ITEM_JSON', subItemJson);
    }

    function fileAttachPopupCallback(fileInfo) {
        grid.setCellValue('QC_ATT_FILE_NUM', fileInfo.nRow, fileInfo.FILE_CNT);
        grid.setCellValue('Q_ATT_FILE_NUM', fileInfo.nRow, fileInfo.UUID);
    }

    function calculateSum() {
        var qtaATM = 0;
        var currency = EVF.getComponent('CUR').getValue();
        for (var i = 0; i < grid.getRowCount(); i++) {
            var price = everCurrency.getPrice(currency, grid.getCellValue(i, 'UNIT_PRC'));
            var qty = everCurrency.getQty(currency, grid.getCellValue(i, 'RFX_QT'));

            grid.setCellValue(i, 'ITEM_AMT', (price * qty));
            qtaATM = qtaATM + (price * qty);
        }

        EVF.getComponent('QTA_AMT').setValue(qtaATM);
    }

    function doClose() {
        formUtil.close();
    }

    function doRequest() {
        var param = {
            gateCd: EVF.getComponent('GATE_CD').getValue(),
            rfxNum: EVF.getComponent('RFX_NUM').getValue(),
            rfxCnt: EVF.getComponent('RFX_CNT').getValue(),
            rfxType: 'RFQ',
            detailView: true
        };
        everPopup.openRfxDetailInformation(param);
    }
	</script>
    
    <e:window id="SPX_020" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">
        <e:buttonBar>
            <e:text style="font-weight: bold;">▣ ${form_VENDOR_CD_N} : </e:text>
            <e:select id="VENDOR_CD" name="VENDOR_CD" value="${param.vendorCd}" options="${refVendorValue}" width="300" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" placeHolder="" onChange="changeVendor" usePlaceHolder="false" />
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' align="right" />
            <e:button label='${doSubmit_N }' id='doSubmit' onClick='doSubmit' disabled="${doSubmit_D }" visible="${doSubmit_V }" align="right"/>
            <e:button label='${doDelete_N }' id='doDelete' onClick='doDelete' disabled='${doDelete_D }' visible='${doDelete_V }' data='${doDelete_A }' align="right"/>
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled="${doSave_D }" visible="${doSave_V }" align="right"/>
        </e:buttonBar>
        <e:searchPanel id="form" title="${form_CAPTION1_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
                <e:field>
                    <e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="150" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                    <e:text>/</e:text>
                    <e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" maxValue="${form_RFX_CNT_M}" width="50" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
                </e:field>
                <e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
                <e:field>
                    <e:inputText id="BUYER_NM" name="BUYER_NM" value="${form.BUYER_NM}" width="100%" maxLength="${form_BUYER_CD_M}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
                    <e:inputHidden id='GATE_CD' name="GATE_CD" value="${form.GATE_CD}" />
                    <e:inputHidden id='BUYER_CD' name="BUYER_CD" value="${form.BUYER_CD}" />
                    <e:inputHidden id='VENDOR_NM' name="VENDOR_NM" value="${form.VENDOR_NM}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="100%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
                    <e:inputHidden id='SAVE_FLAG' name='SAVE_FLAG' />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doRequest_N }' id='doRequest' onClick='doRequest' visible='${doRequest_V }' data='${doRequest_A }'/>
        </e:buttonBar>
        <e:searchPanel id="form2" title="${form_CAPTION2_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
                <e:label for="QTA_NUM" title="${form_QTA_NUM_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="QTA_NUM" name="QTA_NUM" value="${form.QTA_NUM}" width="100%" maxLength="${form_QTA_NUM_M}" disabled="${form_QTA_NUM_D}" readOnly="${form_QTA_NUM_RO}" required="${form_QTA_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PIC_USER_NM" title="${form_PIC_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="PIC_USER_NM" name="PIC_USER_NM" value="${form.PIC_USER_NM}" width="100%" maxLength="${form_PIC_USER_NM_M}" disabled="${form_PIC_USER_NM_D}" readOnly="${form_PIC_USER_NM_RO}" required="${form_PIC_USER_NM_R}" />
                </e:field>
                <e:label for="PIC_TEL_NUM" title="${form_PIC_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id="PIC_TEL_NUM" name="PIC_TEL_NUM" value="${form.PIC_TEL_NUM}" width="100%" maxLength="${form_PIC_TEL_NUM_M}" disabled="${form_PIC_TEL_NUM_D}" readOnly="${form_PIC_TEL_NUM_RO}" required="${form_PIC_TEL_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="QTA_AMT" title="${form_QTA_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="QTA_AMT" name="QTA_AMT" value="${form.QTA_AMT}" maxValue="${form_QTA_AMT_M}" width="${inputNumberWidth}" decimalPlace="${form_QTA_AMT_NF}" disabled="${form_QTA_AMT_D}" readOnly="${form_QTA_AMT_RO}" required="${form_QTA_AMT_R}" />
                    <e:inputText id='CUR' name="CUR" value="${form.CUR}" width='100' disabled="false" maxLength="100" required="false" readOnly="true"/>
                </e:field>
                <e:label for="VALID_TO_DATE" title="${form_VALID_TO_DATE_N}"/>
                <e:field>
                    <e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE" value="${form.VALID_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_VALID_TO_DATE_R}" disabled="${form_VALID_TO_DATE_D}" readOnly="${form_VALID_TO_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="QTA_RMK_TEXT_NUM" title="${form_QTA_RMK_TEXT_NUM_N}"/>
                <e:field colSpan="3">
                    <e:richTextEditor id="QTA_REMARK_TEXT" name="QTA_REMARK_TEXT" value="${form.QTA_RMK_TEXT}" width="100%" maxLength="${form_QTA_RMK_TEXT_NUM_M}" disabled="${form_QTA_RMK_TEXT_NUM_D}" readOnly="${form_QTA_RMK_TEXT_NUM_RO}" required="${form_QTA_RMK_TEXT_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="RFQ" fileId="${form.ATT_FILE_NUM}" width="100%"  readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}" />
                    <e:inputHidden id='VENDOR_OPEN_TYPE' name="VENDOR_OPEN_TYPE" />
                    <e:inputHidden id='SETTLE_TYPE' name="SETTLE_TYPE" />
                    <e:inputHidden id='isPrefferedBidder' name="isPrefferedBidder" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>