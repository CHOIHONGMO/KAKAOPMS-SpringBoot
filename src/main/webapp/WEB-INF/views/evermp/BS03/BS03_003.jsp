<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('multiSelect', false);

            grid.setProperty('shrinkToFit', true);
            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId === 'REG_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "REG_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearchHistory();

        }

        function doSearchHistory(){

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.setParameter("VENDOR_CD", EVF.V("VENDOR_CD"));
            store.load(baseUrl + 'bs03003_doSearchHistory', function() {

            });
        }

        function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if("${formData.SIGN_STATUS}"=="P"){
                return alert("${BS03_003_002}");
            }
            //block/해제 history 없을 때 실행안함
            if("${formData.SIGN_STATUS}" != ''){
                if(EVF.C("BLOCK_FLAG").getValue() == grid.getCellValue(0,'BLOCK_CD')){
                	return alert ("${BS03_003_003}");
                	}
            }
            if(!confirm("${msg.M0011}")) { return; }


            var param = {
                subject: "공급사 [" + EVF.C("VENDOR_NM").getValue() + " Block 해제]",
                docType: "VENBLOCK",
                signStatus: "P",
                screenId: "BS03_002",
                approvalType: 'APPROVAL',
                oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
                attFileNum: "",
                docNum: EVF.getComponent('VENDOR_CD').getValue(),
                appDocNum: EVF.C('APP_DOC_NUM').getValue(),
                callBackFunction: "goApproval",
                bizCls1: "01",
                bizCls2: "01",
                bizCls3: "03",
                bizAmt: 0
            };
            EVF.V("SIGN_STATUS","P");
            everPopup.openApprovalRequestIIPopup(param);


        }

        function goApproval(formData, gridData, attachData) {

            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            var store = new EVF.Store();
            store.load(baseUrl + 'bs03003_doSave', function () {
                alert(this.getResponseMessage());
                if (this.getParameter("VENDOR_CD") == "" || this.getParameter("VENDOR_CD") == null) {

                } else {
                    opener.doSearch();
                    var param = {
                        'VENDOR_CD': this.getParameter("VENDOR_CD"),
                        'detailView': false,
                        'popupFlag': true
                    };
                    window.location.href = '/evermp/BS03/BS0301/BS03_003/view.so?' + $.param(param);
                }
            });
        }

    </script>
    <e:window id="BS03_003" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="SIGN_DATE" name="SIGN_DATE" value="${formData.SIGN_DATE }" />
        <e:inputHidden id="approvalFormData" name="approvalFormData" />
        <e:inputHidden id="approvalGridData" name="approvalGridData" />
        <e:inputHidden id="attachFileDatas" name="attachFileDatas" />
        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${formData.APP_DOC_NUM }" />
        <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${formData.APP_DOC_CNT }" />
        <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="" />


        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="4" useTitleBar="false">
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:text> ${formData.VENDOR_CD } </e:text>
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${formData.VENDOR_NM }" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>
                    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${formData.VENDOR_CD }" />
                    <e:inputHidden id="BLOCK_FLAG_V" name="BLOCK_FLAG_V" value="${formData.BLOCK_FLAG }" />
                </e:field>
                <e:label for="REG_TYPE" title="${form_REG_TYPE_N}" />
                <e:field>
                    <e:select id="REG_TYPE" name="REG_TYPE" value="${formData.REG_TYPE }" options="${regTypeOptions }" width="${form_REG_TYPE_W}" disabled="${form_REG_TYPE_D}" readOnly="${form_REG_TYPE_RO}" required="${form_REG_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="IRS_NO" title="${form_IRS_NO_N}"/>
                <e:field>
                    <e:inputText id="IRS_NO" name="IRS_NO" placeHolder="${BS03_002_INPUT_T1 }" value="${formData.IRS_NO }" width="${form_IRS_NO_W}" maxLength="${form_IRS_NO_M}" disabled="${form_IRS_NO_D}" readOnly="${form_IRS_NO_RO}" required="${form_IRS_NO_R}" onChange="checkIrsNum" />
                </e:field>
            </e:row>
            <e:row>
				<e:label for="HQ_ADDR_1" title="${form_HQ_ADDR_1_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="HQ_ADDR_1" name="HQ_ADDR_1" value="${formData.HQ_ADDR_1 }" width="${form_HQ_ADDR_1_W}" maxLength="${form_HQ_ADDR_1_M}" disabled="${form_HQ_ADDR_1_D}" readOnly="${form_HQ_ADDR_1_RO}" required="${form_HQ_ADDR_1_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}"/>
                <e:field>
                    <e:inputText id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="${formData.BUSINESS_TYPE }" width="${form_BUSINESS_TYPE_W}" maxLength="${form_BUSINESS_TYPE_M}" disabled="${form_BUSINESS_TYPE_D}" readOnly="${form_BUSINESS_TYPE_RO}" required="${form_BUSINESS_TYPE_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="INDUSTRY_TYPE" title="${form_INDUSTRY_TYPE_N}"/>
                <e:field>
                    <e:inputText id="INDUSTRY_TYPE" name="INDUSTRY_TYPE" value="${formData.INDUSTRY_TYPE }" width="${form_INDUSTRY_TYPE_W}" maxLength="${form_INDUSTRY_TYPE_M}" disabled="${form_INDUSTRY_TYPE_D}" readOnly="${form_INDUSTRY_TYPE_RO}" required="${form_INDUSTRY_TYPE_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="MAJOR_ITEM_NM" title="${form_MAJOR_ITEM_NM_N}" />
				<e:field colSpan="3">
					<e:inputText id="MAJOR_ITEM_NM" name="MAJOR_ITEM_NM" value="${formData.MAJOR_ITEM_NM }" width="${form_MAJOR_ITEM_NM_W}" maxLength="${form_MAJOR_ITEM_NM_M}" disabled="${form_MAJOR_ITEM_NM_D}" readOnly="${form_MAJOR_ITEM_NM_RO}" required="${form_MAJOR_ITEM_NM_R}" />
				</e:field>
				<e:label for="BUSINESS_SIZE" title="${form_BUSINESS_SIZE_N}"/>
                <e:field>
                    <e:select id="BUSINESS_SIZE" name="BUSINESS_SIZE" value="${formData.BUSINESS_SIZE}" options="${businessSizeOptions}" width="${form_BUSINESS_SIZE_W}" disabled="${form_BUSINESS_SIZE_D}" readOnly="${form_BUSINESS_SIZE_RO}" required="${form_BUSINESS_SIZE_R}" placeHolder="" />
                </e:field>
                <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
				<e:field>
				<e:inputText id="MAKER_NM" name="MAKER_NM" value="${formData.MAKER_NM }" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
				</e:field>

            </e:row>
            <e:row>
				<e:label for="BLOCK_CD" title="${form_BLOCK_CD_N}" />
                <e:field colSpan="3">
                <e:inputHidden id="BLOCK_CD" name="BLOCK_CD" value="" />

                    <e:radioGroup id="BLOCK_FLAG" name="BLOCK_FLAG" value="${formData.BLOCK_FLAG}" width="${form_BLOCK_FLAG_W}" disabled="${form_BLOCK_FLAG_D}" readOnly="${form_BLOCK_FLAG_RO}" required="${form_BLOCK_FLAG_R}">
                        <c:forEach var="item" items="${blockFlag}">
                            <e:radio id="BLOCK_FLAG_${item.value}" name="BLOCK_FLAG_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_SEAL_TYPE_D}" readOnly="${param.detailView}" />
                        </c:forEach>
                    </e:radioGroup>
                </e:field>
                <e:label for="BLOCK_REASON" title="${form_BLOCK_REASON_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="BLOCK_REASON" name="BLOCK_REASON" value="${formData.BLOCK_REASON }" width="${form_BLOCK_REASON_W}" maxLength="${form_BLOCK_REASON_M}" disabled="${form_BLOCK_REASON_D}" readOnly="${form_BLOCK_REASON_RO}" required="${form_BLOCK_REASON_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
            	<e:label for="MAJOR_PERFORM" title="${form_MAJOR_PERFORM_N}" />
				<e:field colSpan="7">
					<e:inputText id="MAJOR_PERFORM" name="MAJOR_PERFORM" value="${formData.MAJOR_PERFORM}" width="${form_MAJOR_PERFORM_W}" maxLength="${form_MAJOR_PERFORM_M}" disabled="${form_MAJOR_PERFORM_D}" readOnly="${form_MAJOR_PERFORM_RO}" required="${form_MAJOR_PERFORM_R}" />
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="MAJOR_PERFORM1" title="${form_MAJOR_PERFORM1_N}" />
				<e:field colSpan="7">
					<e:inputText id="MAJOR_PERFORM1" name="MAJOR_PERFORM1" value="${formData.MAJOR_PERFORM1}" width="${form_MAJOR_PERFORM1_W}" maxLength="${form_MAJOR_PERFORM1_M}" disabled="${form_MAJOR_PERFORM1_D}" readOnly="${form_MAJOR_PERFORM1_RO}" required="${form_MAJOR_PERFORM1_R}" />
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="MAJOR_PERFORM2" title="${form_MAJOR_PERFORM2_N}" />
				<e:field colSpan="7">
					<e:inputText id="MAJOR_PERFORM2" name="MAJOR_PERFORM2" value="${formData.MAJOR_PERFORM2}" width="${form_MAJOR_PERFORM2_W}" maxLength="${form_MAJOR_PERFORM2_M}" disabled="${form_MAJOR_PERFORM2_D}" readOnly="${form_MAJOR_PERFORM2_RO}" required="${form_MAJOR_PERFORM2_R}" />
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="MAJOR_PERFORM3" title="${form_MAJOR_PERFORM3_N}" />
				<e:field colSpan="7">
					<e:inputText id="MAJOR_PERFORM3" name="MAJOR_PERFORM3" value="${formData.MAJOR_PERFORM3}" width="${form_MAJOR_PERFORM3_W}" maxLength="${form_MAJOR_PERFORM3_M}" disabled="${form_MAJOR_PERFORM3_D}" readOnly="${form_MAJOR_PERFORM3_RO}" required="${form_MAJOR_PERFORM3_R}" />
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="MAJOR_PERFORM4" title="${form_MAJOR_PERFORM4_N}" />
				<e:field colSpan="7">
					<e:inputText id="MAJOR_PERFORM4" name="MAJOR_PERFORM4" value="${formData.MAJOR_PERFORM4}" width="${form_MAJOR_PERFORM4_W}" maxLength="${form_MAJOR_PERFORM4_M}" disabled="${form_MAJOR_PERFORM4_D}" readOnly="${form_MAJOR_PERFORM4_RO}" required="${form_MAJOR_PERFORM4_R}" />
				</e:field>
            </e:row>

        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
     		<e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        </e:buttonBar>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>