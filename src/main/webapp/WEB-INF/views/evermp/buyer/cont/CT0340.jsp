<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cont/CT0340/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'CONT_NUM') {
					var param = {
                             contNum: grid.getCellValue(rowId, "CONT_NUM")
                            ,contCnt: grid.getCellValue(rowId, "CONT_CNT")
							,detailView : true
						};
					everPopup.openPopupByScreenId('CT0320', 1200, 1000, param);
                }
                if (colId == "VENDOR_CD") {
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true
                    };
                    everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
                }

            });

            grid.setProperty('panelVisible', ${panelVisible});
//            grid.setProperty('singleSelect', true);
            grid.setProperty('shrinkToFit', false);

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });
            var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
		    EVF.V('BUYER_CD',values.join(','));

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

    <e:window id="CT0340" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="125" onEnter="doSearch" useTitleBar="false">
			<e:row>


				<%--구매요청회사--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true"/>
				</e:field>







				<e:label for="CONT_NUM" title="${form_CONT_NUM_N}"/>
				<e:field>
					<e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="getVendorCd" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onKeyDown="cleanVendorCd" />
					<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="" />
				</e:field>
			</e:row>
			<e:row>
				<%--계약일자--%>
				<e:label for="DATE_TYPE" title="${form_DATE_TYPE_N}"/>
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>
				<%--유효여부--%>
				<e:label for="EXPIRE_YN" title="${form_EXPIRE_YN_N}"/>
				<e:field>
				<e:select id="EXPIRE_YN" name="EXPIRE_YN" value="" options="${expireYnOptions}" width="${form_EXPIRE_YN_W}" disabled="${form_EXPIRE_YN_D}" readOnly="${form_EXPIRE_YN_RO}" required="${form_EXPIRE_YN_R}" placeHolder="" />
				</e:field>
				<%--자재코드--%>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
				<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--자재명--%>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
				<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<%--규격--%>
				<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
				<e:field colSpan="3">
				<e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
				</e:field>

			</e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
