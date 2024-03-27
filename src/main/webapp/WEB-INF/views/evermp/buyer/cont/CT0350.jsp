<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cont/CT0350/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'CONT_NUM') {
					var param = {
							 CONT_NUM     : grid.getCellValue(rowId,'CONT_NUM')
							,CONT_CNT     : grid.getCellValue(rowId,'CONT_CNT')
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
				callBackFunction: "setContUser"
			};
			everPopup.openCommonPopup(param, 'SP0508');
		}

		function setContUser(data) {
			EVF.V("USER_ID", data.CTRL_USER_ID);
			EVF.V("USER_NM", data.CTRL_USER_NM);
		}









	     function doModCont() {

	            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

	            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

	            var selRowId = grid.getSelRowId();
	            var paramContNum; var paramContCnt;
	            var paramBundleNum;
	            for(var i in selRowId) {
	                if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
	                    //return EVF.alert("${CT0330_0027}");
	                }
	                if (grid.getCellValue(selRowId[i], "NEXT_CONT_CNT_FLAG") == "Y") {
	                    //return EVF.alert("${CT0330_0031}");
	                }
	                paramContNum = grid.getCellValue(selRowId[i], "CONT_NUM");
	                paramContCnt = grid.getCellValue(selRowId[i], "CONT_CNT");
					paramBundleNum = grid.getCellValue(selRowId[i], "BUNDLE_NUM");
	            }

				if(EVF.isEmpty(paramBundleNum) || paramBundleNum == "") {
	                everPopup.openContractChangeInformation({
	                    callBackFunction: 'doSearch',
	                    contNum: paramContNum,
	                    contCnt: paramContCnt,
	                    resumeFlag: "true"
	                });
	            } else {
	                var url = '/eversrm/econtract/ECOB0040/view';
	                var params = {
	                    callBackFunction: 'doSearch',
	                    bundleNum: paramBundleNum,
	                    contNum: paramContNum,
	                    contCnt: paramContCnt,
						resumeFlag: "true"
	                }
	                everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
	            }
	        }
    </script>

    <e:window id="CT0350" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

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
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate}" width="${inputTextDate }" required="${form_REG_DATE_FROM_R}" readOnly="${form_REG_DATE_FROM_RO }" disabled="${form_REG_DATE_FROM_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate}" width="${inputTextDate }" required="${form_REG_DATE_TO_R }" readOnly="${form_REG_DATE_TO_RO }" disabled="${form_REG_DATE_TO_D }" datePicker="true" />
				</e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N }" />
				<e:field colSpan="3">
					<e:search id="USER_NM" style="ime-mode:active;" name="USER_NM" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M }" required="${form_USER_NM_R }" disabled="${form_USER_NM_D }" readOnly="${form_USER_NM_RO }" value="${authFlag ? ses.userNm : null}" onIconClick="getContUser" onKeyDown="cleanUserInfo" />
					<e:inputHidden id="USER_ID" name="USER_ID" value="" />
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
			<e:button id="doModCont" name="doModCont" label="${doModCont_N}" onClick="doModCont" disabled="${doModCont_D}" visible="${doModCont_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
