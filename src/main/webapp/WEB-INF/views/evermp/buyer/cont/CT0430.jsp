<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cont/CT0430/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'CONT_NUM') {
                	if(grid.getCellValue(rowId,'CONT_NUM')=='') return;
					var param = {
							 CONT_NUM     : grid.getCellValue(rowId,'CONT_NUM')
							,detailView : true
						};
					everPopup.openPopupByScreenId('CT0320', 1200, 1000, param);
                }
                if (colId == 'PO_NUM') {
					var param = {
							PO_NUM     : grid.getCellValue(rowId,'PO_NUM')
							,detailView : true
						};
					everPopup.openPopupByScreenId('PO0130', 1200, 1000, param);
                }
                if (colId == 'PR_NUM') {
					var param = {
							 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
							,PR_NUM     : grid.getCellValue(rowId,'PR_NUM')
							,detailView : true
						};
					everPopup.openPopupByScreenId('PR0140', 1200, 1000, param);
                }
                if (colId == 'RFX_NUM') {
					var param = {
							 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
							,RFX_NUM     : grid.getCellValue(rowId,'RFX_NUM')
							,RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
							,detailView : true
						};
					everPopup.openPopupByScreenId('RQ0310', 1200, 1000, param);
                }
                if (colId == 'QTA_NUM') {
					var param = {
							 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
							,QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')
							,detailView : true
						};
					everPopup.openPopupByScreenId('QT0320', 1200, 1000, param);
                }
                if (colId == "VENDOR_NM") {
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true
                    };
                    everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
                }


            });

            grid.setProperty('panelVisible', ${panelVisible});
            grid.setProperty('singleSelect', true);
            grid.setProperty('shrinkToFit', false);

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });
            var values = $.map($('#PUR_ORG_CD option'), function(e) { return e.value; });
		    EVF.V('PUR_ORG_CD',values.join(','));

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function () {
            });
        }

        function getVendorCd() {
            everPopup.openCommonPopup({
                callBackFunction: "setVendorCd"
            }, 'SP0063');
        }

        function setVendorCd(vendor) {
            EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
        }


		function getContUser() {
			var param = {
				callBackFunction: "setContUser",
				GATE_CD: '${ses.gateCd}',
				BUYER_CD: "${ses.companyCd}"
			};
			everPopup.openCommonPopup(param, 'SP0040');
		}

		function setContUser(data) {
			EVF.V("CTRL_USER_ID", data.CTRL_USER_ID);
			EVF.V("CTRL_USER_NM", data.CTRL_USER_NM);
		}

    </script>

    <e:window id="CT0430" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="125" onEnter="doSearch" useTitleBar="false">
            <e:row>
				<%--구매운영조직코드--%>
				<e:label for="PUR_ORG_CD" title="${form_PUR_ORG_CD_N}"/>
				<e:field>
				<e:select id="PUR_ORG_CD" name="PUR_ORG_CD" value="" options="${purOrgCdOptions}" width="${form_PUR_ORG_CD_W}" disabled="${form_PUR_ORG_CD_D}" readOnly="${form_PUR_ORG_CD_RO}" required="${form_PUR_ORG_CD_R}" usePlaceHolder="false" useMultipleSelect="true"/>
				</e:field>
				<%--계약/발주일자--%>
				<e:label for="DATE_FROM" title="${form_DATE_FROM_N}"/>
				<e:field>
				<e:inputDate id="DATE_FROM" name="DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" />
				<e:text> ~ </e:text>
				<e:inputDate id="DATE_TO" name="DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" />
				</e:field>
				<%--협력업체--%>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="48%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RD ? 'everCommon.blank' : 'getVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" placeHolder="${CT0430_0001}"/>
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="48%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" placeHolder="${CT0430_0002}"/>
				</e:field>
            </e:row>
            <e:row>
				<%--계약번호--%>
				<e:label for="CONT_NUM" title="${form_CONT_NUM_N}" />
				<e:field>
				<e:inputText id="CONT_NUM" name="CONT_NUM" value="" width="${form_CONT_NUM_W}" maxLength="${form_CONT_NUM_M}" disabled="${form_CONT_NUM_D}" readOnly="${form_CONT_NUM_RO}" required="${form_CONT_NUM_R}" />
				</e:field>
				<%--발주번호--%>
				<e:label for="PO_NUM" title="${form_PO_NUM_N}" />
				<e:field>
				<e:inputText id="PO_NUM" name="PO_NUM" value="" width="${form_PO_NUM_W}" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}" />
				</e:field>
				<%--계약/발주명--%>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field>
				<e:inputText id="SUBJECT" name="SUBJECT" value="" width="${form_SUBJECT_W}" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--결재상태--%>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
				<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${PROGRESS_CD_Options}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<%--협력업체접수상태--%>
				<e:label for="RECEIPT_YN" title="${form_RECEIPT_YN_N}"/>
				<e:field>
				<e:select id="RECEIPT_YN" name="RECEIPT_YN" value="" options="${receiptYnOptions}" width="${form_RECEIPT_YN_W}" disabled="${form_RECEIPT_YN_D}" readOnly="${form_RECEIPT_YN_RO}" required="${form_RECEIPT_YN_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}"/>
				<e:field colSpan="5">
				<e:search id="CTRL_USER_NM" name="CTRL_USER_NM" value="" width="${form_CTRL_USER_NM_W}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="${form_CTRL_USER_NM_RD ? 'everCommon.blank' : 'getContUser'}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
				<e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID"/>
				</e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
