<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var docGrid;
        var baseUrl = "/eversrm/gr/DH1031";
        var selRow;

        function init() {

            if(${not empty form.SL_NUM} && ${not param.detailView eq 'true'}) {
                alert('${DH1031_002}');
                formUtil.close();
            }

            grid = EVF.C('grid');
            docGrid = EVF.C('docGrid');
            docGrid.setProperty("shrinkToFit", true);
            grid.setProperty("shrinkToFit", true);

            //grid Column Head Merge
            grid.setProperty('multiselect', true);

            grid.addRow();
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

            docGrid.addRowEvent(function () {
                docGrid.addRow();
            });

            docGrid.delRowEvent(function () {
                docGrid.delRow();
            });

            docGrid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
                var userwidth  = 810; // 고정(수정하지 말것)
    			var userheight = (screen.height - 2);
    			if (userheight < 780) userheight = 780; // 최소 780
    			var LeftPosition = (screen.width-userwidth)/2;
    			var TopPosition  = (screen.height-userheight)/2;
    			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

    			switch (celName) {
                    case 'APRV_URL':
    	            	if ('${param.detailView}' == 'true' && docGrid.getCellValue(rowId, celName) != '' && docGrid.getCellValue(rowId, celName).length > 200) {
        	            	window.open(docGrid.getCellValue(rowId, celName), "signwindow", gwParam);
            	        }
                	    break;
    				default:
    			}
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
                doSearchGroupwareDocs();
                //setAmount();
            });
        }

        function doSearchGroupwareDocs() {

            var store = new EVF.Store();
            store.setGrid([docGrid]);
            store.load(baseUrl + '/doSearchGroupwareDocs', function () {

            }, false);
        }

        // Save
        function doSave() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            grid.checkAll(true);

            if(EVF.C('DATA_CREATE_TYPE').getValue() != 'S') /* 매뉴얼생성일 경우만 아래의 조건을 체크한다. */ {
                if(Number(EVF.C("VAT_AMT").getValue()) > 0) {
                    EVF.C('VAT_GL_ACCOUNT_CD').setRequired(true);
                } else {
                    EVF.C('VAT_GL_ACCOUNT_CD').setRequired(false);
                }
            }

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if (!confirm("${msg.M0021}")) {
                return;
            }

            store.setGrid([grid, docGrid]);
            store.getGridData(grid, 'all');
            store.getGridData(docGrid, 'all');
            store.doFileUpload(function () {
                store.load(baseUrl + '/doSave', function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());
                    var params = {
                        "dealNum": this.getParameter('dealNum')
                    };
                    location.href = baseUrl + '/view.so?' + $.param(params);
                });
            })
        }

        function doDelete() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

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
            	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                alert(this.getResponseMessage());
                formUtil.close();
            });
        }

        function _getVendorNm() {
            var param = {
                callBackFunction: '_setVendorNm'
            };
            everPopup.openCommonPopup(param, "SP0025");
        }

        function _setVendorNm(data) {
            EVF.C('VENDOR_CD').setValue(data['VENDOR_CD']);
            EVF.C('VENDOR_NM').setValue(data['VENDOR_NM']);
        }

        function getPayTerms() {
            var param = {
                "callBackFunction": 'setPayTerms'
            };
            everPopup.openCommonPopup(param, "SP0055");
        }

        function setPayTerms(data) {
            EVF.C('PAY_TERMS').setValue(data['CODE']);
            EVF.C('PAY_TERMS_NM').setValue(data['CODE_DESC']);
        }

        function _getGlAccount() {

        	if (EVF.C('SL_TYPE').getValue() == 'CA') return;
            var param = {
                "callBackFunction": '_setGlAccount'
            };
            everPopup.openCommonPopup(param, "SP0024");
        }

        function _setGlAccount(data) {
            EVF.C('GL_ACCOUNT_CD').setValue(data['ACCOUNT_CD']);
            EVF.C('GL_ACCOUNT_NM').setValue(data['ACCOUNT_NM']);
        }

        function _getCostCd() {

            if (EVF.isEmpty(EVF.C('PLANT_CD').getValue())) {
                return alert('${DH1031_001}');
            }

            var param = {
                "callBackFunction": '_setCostCd',
                "PLANT_CD": EVF.C('PLANT_CD').getValue()
            };
            everPopup.openCommonPopup(param, "SP0036");
        }

        function _clearCostCdOnChange() {
        	return;
            EVF.C('COST_CD').setValue('');
            EVF.C('COST_NM').setValue('');
        }

        function _setCostCd(data) {

        	grid.setCellValue(selRow,'COST_CD',data['COST_CD']);

        	return;
        	EVF.C('COST_CD').setValue(data['COST_CD']);
            EVF.C('COST_NM').setValue(data['COST_NM']);
        }

        function doClose() {
            formUtil.close();
        }

        function doDeleteItem() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var selRowId = grid.getSelRowId();
            for(var ri in selRowId) {

                var rowId = selRowId[ri];
                if(EVF.isEmpty(grid.getCellValue(rowId, 'GR_NUM')) && EVF.isEmpty(grid.getCellValue(rowId, 'DEAL_NUM'))) {
                    grid.delRow(rowId);
                }
            }

            setAmount();

            if(!grid.isExistsSelRow()) {
                return;
            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doDeleteItem', function () {
                doSearch();
                alert(this.getResponseMessage());
            });

        }

        function setAmount() {

            var cur = EVF.C('CUR').getValue();
            var taxCd = EVF.C('TAX_CD').getValue();
            var taxText = EVF.C('TAX_CD').getText();

            var supAmt = EVF.C('SUP_AMT').getValue();



                var pct = (taxText.indexOf('10%') > -1) ? 10 : taxCd.indexOf('0%') > -1 ? 0 : 0;
                if(pct === 10) {

                    var vatAmt = parseInt(supAmt * 0.1);
                    EVF.C('VAT_AMT').setValue(vatAmt);
                    EVF.C('TOTAL_AMT').setValue(supAmt + vatAmt);
                    if (vatAmt > 0) {
                        EVF.C('VAT_GL_ACCOUNT_CD').setValue("11131101");
                    }
                    EVF.C('VAT_GL_ACCOUNT_CD').setDisabled(false);

                } else if(pct === 0) {

                    EVF.C('VAT_GL_ACCOUNT_CD').setValue('');
                    EVF.C('VAT_GL_ACCOUNT_CD').setDisabled(true);
                    EVF.C('VAT_AMT').setValue(0);
                    EVF.C('TOTAL_AMT').setValue(EVF.C('SUP_AMT').getValue());

                }

        }

        function setAmount2() {
        	var supAmt = EVF.C('SUP_AMT').getValue();
        	var vatAmt = EVF.C('VAT_AMT').getValue();
            EVF.C('TOTAL_AMT').setValue(supAmt + vatAmt);

        }


        function _onChangePurchaseType() {

            var purchaseType = EVF.C('PURCHASE_TYPE').getValue();
            if(purchaseType == 'ISP') /* 투자품의의 경우 SAP오더번호를 필수입력받는다. */ {
                EVF.C('SAP_ORDER_NUM').setRequired(true);
            } else {
                EVF.C('SAP_ORDER_NUM').setRequired(false);
            }
        }

        function chSlType() {
        	if (EVF.C('SL_TYPE').getValue() == 'CA') {
                EVF.C('GL_ACCOUNT_CD').setValue('21113103');
                EVF.C('GL_ACCOUNT_NM').setValue('미지급금-법인카드');
                EVF.C('GL_ACCOUNT_CD').setReadOnly(true);
        	} else {
                EVF.C('GL_ACCOUNT_CD').setValue('');
                EVF.C('GL_ACCOUNT_NM').setValue('');
                EVF.C('GL_ACCOUNT_CD').setReadOnly(false);
        	}
        }


        function getProvisionItem() {

            var param = {
                    "callBackFunction": 'setProvisionItem',
                };
                everPopup.openCommonPopup(param, "SP0060");
        }

        function getDistrbution() {

            var param = {
                    "callBackFunction": 'setDistrbution',
                };
                everPopup.openCommonPopup(param, "SP0061");
        }

        function setProvisionItem(data) {
        	EVF.C('PROVISION_ITEM_CD').setValue(data['CODE']);
            EVF.C('PROVISION_ITEM_NM').setValue(data['CODE_DESC']);
        }
        function setDistrbution(data) {
        	EVF.C('DISTRIBUTION_CD').setValue(data['CODE']);
            EVF.C('DISTRIBUTION_NM').setValue(data['CODE_DESC']);
        }



    </script>

    <e:window id="DH1031" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="DATA_CREATE_TYPE" name="DATA_CREATE_TYPE" value="${form.DATA_CREATE_TYPE}" />

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
				<e:select id="SL_TYPE" onChange="chSlType" name="SL_TYPE" value="ET" options="${slTypeOptions}" width="${inputTextWidth}" disabled="true" readOnly="${form_SL_TYPE_RO}" required="${form_SL_TYPE_R}" placeHolder="" />
				</e:field>

                <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${inputTextWidth}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
                </e:field>

			</e:row>
			<e:row>
                <e:label for="PROOF_DATE" title="${form_PROOF_DATE_N}"/>
                <e:field>
                    <e:inputDate id="PROOF_DATE" name="PROOF_DATE" value="${form.PROOF_DATE}" width="${inputTextDate}" datePicker="true" required="${form_PROOF_DATE_R}" disabled="${form_PROOF_DATE_D}" readOnly="${form_PROOF_DATE_RO}"/>
                </e:field>
                <e:label for="DEAL_DATE" title="${form_DEAL_DATE_N}"/>
                <e:field>
                    <e:inputDate id="DEAL_DATE" name="DEAL_DATE" value="${form.DEAL_DATE}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_DATE_R}" disabled="${form_DEAL_DATE_D}" readOnly="${form_DEAL_DATE_RO}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${empty form.PLANT_CD ? ses.plantCd : form.PLANT_CD}" options="${plantCdOptions}" width="100%" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" onChange="_clearCostCdOnChange"/>
                </e:field>
            </e:row>

			<e:row>
                <e:label for="REMARK" title="${form_REMARK_N}"/>
                <e:field colSpan="5">
                    <e:inputText id="REMARK" style="ime-mode:auto" name="REMARK" value="${form.REMARK}" width="100%" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}"/>
                </e:field>
			</e:row>

			<e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : '_getVendorNm'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="VENDOR_NM" style="ime-mode:auto" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="GL_ACCOUNT_CD" title="${form_GL_ACCOUNT_CD_N}"/>
                <e:field>
                    <e:search id="GL_ACCOUNT_CD" style="ime-mode:inactive" name="GL_ACCOUNT_CD" value="${form.GL_ACCOUNT_CD}" width="${inputTextWidth}" maxLength="${form_GL_ACCOUNT_CD_M}" onIconClick="${form_GL_ACCOUNT_CD_RO ? 'everCommon.blank' : '_getGlAccount'}" disabled="${form_GL_ACCOUNT_CD_D}" readOnly="${form_GL_ACCOUNT_CD_RO}" required="${form_GL_ACCOUNT_CD_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="GL_ACCOUNT_NM" style="ime-mode:inactive" name="GL_ACCOUNT_NM" value="${form.GL_ACCOUNT_NM}" width="${inputTextWidth}" maxLength="${form_GL_ACCOUNT_NM_M}" disabled="${form_GL_ACCOUNT_NM_D}" readOnly="${form_GL_ACCOUNT_NM_RO}" required="${form_GL_ACCOUNT_NM_R}"/>
                </e:field>
                <e:label for="TAX_CD" title="${form_TAX_CD_N}"/>
                <e:field>
                    <e:select id="TAX_CD" name="TAX_CD" value="${form.TAX_CD}" options="${taxCdOptions}" width="100%" disabled="${form_TAX_CD_D}" readOnly="${form_TAX_CD_RO}" required="${form_TAX_CD_R}" placeHolder="" onChange="setAmount" />
                    <e:inputHidden id="TAX_NM" name="TAX_NM" value="${form.TAX_NM}" />
                </e:field>
			</e:row>

            <e:row>
                <e:label for="SUP_AMT" title="${form_SUP_AMT_N}"/>
                <e:field>
                    <e:select id="CUR" name="CUR" value="${empty form.CUR ? 'KRW' : form.CUR}" options="${curOptions}" width="${inputTextWidth}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" onChange="setAmount" />
                    <e:text>&nbsp;</e:text>
                    <e:inputNumber id="SUP_AMT" name="SUP_AMT" value="${form.SUP_AMT}" width="${inputTextWidth}"  maxValue="${form_SUP_AMT_M}" decimalPlace="${form_SUP_AMT_NF}" disabled="${form_SUP_AMT_D}" readOnly="${form_SUP_AMT_RO}" required="${form_SUP_AMT_R}" onChange="setAmount" />
                </e:field>
                <e:label for="VAT_AMT" title="${form_VAT_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="VAT_AMT" name="VAT_AMT" value="${form.VAT_AMT}" width="${inputTextWidth}"  maxValue="${form_VAT_AMT_M}" decimalPlace="${form_VAT_AMT_NF}" disabled="${form_VAT_AMT_D}" readOnly="${form_VAT_AMT_RO}" required="${form_VAT_AMT_R}" onChange="setAmount2"/>
                    <e:text>&nbsp;</e:text>
                    <e:select id="VAT_GL_ACCOUNT_CD" name="VAT_GL_ACCOUNT_CD" value="${form.VAT_GL_ACCOUNT_CD}" options="${vatGlAccountCdOptions}" width="${inputTextWidth}" disabled="${form_VAT_GL_ACCOUNT_CD_D}" readOnly="${form_VAT_GL_ACCOUNT_CD_RO}" required="${form_VAT_GL_ACCOUNT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="TOTAL_AMT" title="${form_TOTAL_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="TOTAL_AMT" name="TOTAL_AMT" value="${form.TOTAL_AMT}" width="${inputTextWidth}"  maxValue="${form_TOTAL_AMT_M}" decimalPlace="${form_TOTAL_AMT_NF}" disabled="${form_TOTAL_AMT_D}" readOnly="${form_TOTAL_AMT_RO}" required="${form_TOTAL_AMT_R}"/>
                </e:field>
            </e:row>
			<e:row>
                <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
                <e:field colSpan="5">
                    <e:search id="PAY_TERMS" style="ime-mode:inactive" name="PAY_TERMS" value="${form.PAY_TERMS}" width="${inputTextWidth}" maxLength="${form_PAY_TERMS_M}" onIconClick="${form_PAY_TERMS_RO ? 'everCommon.blank' : 'getPayTerms'}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="PAY_TERMS_NM" style="ime-mode:inactive" name="PAY_TERMS_NM" value="${form.PAY_TERMS_NM}" width="${inputTextWidth}" maxLength="${form_PAY_TERMS_NM_M}" disabled="${form_PAY_TERMS_NM_D}" readOnly="${form_PAY_TERMS_NM_RO}" required="${form_PAY_TERMS_NM_R}"/>
                </e:field>
				<e:inputHidden id="BIZ_AREA_CD" name="BIZ_AREA_CD"/>
				<e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE"/>
				<e:inputHidden id="SAP_ORDER_NUM" name="SAP_ORDER_NUM"/>
				<e:inputHidden id="COST_CD" name="COST_CD"/>

			</e:row>

			<e:row>
				<e:label for="PROVISION_ITEM_CD" title="${form_PROVISION_ITEM_CD_N}"/>
				<e:field>
				<e:search id="PROVISION_ITEM_CD" style="ime-mode:inactive" name="PROVISION_ITEM_CD" value="${form.PROVISION_ITEM_CD}" width="30%" maxLength="${form_PROVISION_ITEM_CD_M}" onIconClick="${form_PROVISION_ITEM_CD_RO ? 'everCommon.blank' : 'getProvisionItem'}" disabled="${form_PROVISION_ITEM_CD_D}" readOnly="${form_PROVISION_ITEM_CD_RO}" required="${form_PROVISION_ITEM_CD_R}" />
				<e:inputText id="PROVISION_ITEM_NM" style="${imeMode}" name="PROVISION_ITEM_NM" value="${form.PROVISION_ITEM_NM}" width="70%" maxLength="${form_PROVISION_ITEM_NM_M}" disabled="${form_PROVISION_ITEM_NM_D}" readOnly="${form_PROVISION_ITEM_NM_RO}" required="${form_PROVISION_ITEM_NM_R}"/>

				</e:field>
				<e:label for="DISTRIBUTION_CD" title="${form_DISTRIBUTION_CD_N}"/>
				<e:field>
				<e:search id="DISTRIBUTION_CD" style="ime-mode:inactive" name="DISTRIBUTION_CD" value="${form.DISTRIBUTION_CD}" width="30%" maxLength="${form_DISTRIBUTION_CD_M}" onIconClick="${form_DISTRIBUTION_CD_RO ? 'everCommon.blank' : 'getDistrbution'}" disabled="${form_DISTRIBUTION_CD_D}" readOnly="${form_DISTRIBUTION_CD_RO}" required="${form_DISTRIBUTION_CD_R}" />
				<e:inputText id="DISTRIBUTION_NM" style="${imeMode}" name="DISTRIBUTION_NM" value="${form.DISTRIBUTION_NM}" width="70%" maxLength="${form_DISTRIBUTION_NM_M}" disabled="${form_DISTRIBUTION_NM_D}" readOnly="${form_DISTRIBUTION_NM_RO}" required="${form_DISTRIBUTION_NM_R}"/>
				</e:field>

				<e:label for="DR_REMARK" title="${form_DR_REMARK_N}"/>
				<e:field>
				<e:inputText id="DR_REMARK" style="${imeMode}" name="DR_REMARK" value="${form.DR_REMARK}" width="${inputTextWidth}" maxLength="${form_DR_REMARK_M}" disabled="${form_DR_REMARK_D}" readOnly="${form_DR_REMARK_RO}" required="${form_DR_REMARK_R}"/>
				</e:field>
			</e:row>


            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                <e:field colSpan="5">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="DL" fileId="${form.ATT_FILE_NUM}" width="100%" readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="" title="${form_APRV_URL_N}"/>
                <e:field colSpan="5">
                    <e:gridPanel gridType="${_gridType}" id="docGrid" name="docGrid" height="150" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.docGrid.gridColData}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <div style="visibility: hidden;">
            <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="100%" readOnly="${param.detailView}" useTitleBar="false" columnDef="${gridInfos.grid.gridColData}" />
        </div>
    </e:window>
</e:ui>
