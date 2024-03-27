<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cont/CT0410/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'FORM_NM') {

                }else if(colId === 'RFX_NUM'){
	                var param = {
		                BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
		                ,RFX_NUM   : grid.getCellValue(rowId,'RFX_NUM')
		                ,RFX_CNT     : grid.getCellValue(rowId,'RFX_CNT')
		                ,detailView : true
	                };
	                everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);
                }else if(colId === 'QTA_NUM') {
	                var param = {
		                QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')
		                ,popupFlag : true
		                ,detailView : true
	                };
	                everPopup.openPopupByScreenId('QT0320', 1600, 1000, param);
                } else if (colId == "VENDOR_NM") {
                    var param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': true
                        };
                        everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
                    }
            });

            grid.setProperty('panelVisible', ${panelVisible});
            grid.setProperty('singleSelect', true);
            grid.setProperty('shrinkToFit', true);

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });
            var values = $.map($('#PUR_ORG_CD option'), function(e) { return e.value; });
		    EVF.V('PUR_ORG_CD',values.join(','));

	        // DashBoard 통해서 들어왔을 경우 파라미터 셋팅
	        /*if ('${param.dashBoardFlag}' == 'Y') {
		        EVF.V('RFX_DATE_FROM', '${param.FROM_DATE2}');
		        EVF.V('RFX_DATE_TO', '${param.TO_DATE}');
		        doSearch();
	        }*/
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

		function doCreatePo(){
			if(!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
			if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }
			var value = grid.getSelRowValue()[0];
			if(value.CS_PR_DIV == 'C' || value.CS_PR_DIV == 'D') { return EVF.alert("${CT0410_010}");} //제품은 계약전 발주생성 불가.

			var param = {
				BUYER_CD : value.BUYER_Cd,
				RFX_NUM : value.RFX_NUM,
				RFX_CNT : value.RFX_CNT,
				QTA_NUM : value.QTA_NUM,
				PUR_ORG_CD : value.PUR_ORG_CD,
				CUR : value.CUR,
				SHIPPER_TYPE : value.SHIPPER_TYPE,
				VENDOR_CD : value.VENDOR_CD,
				VENDOR_NM : value.VENDOR_NM,
				BUYER_CD : value.BUYER_CD,
				RFX_SUBJECT : value.RFX_SUBJECT,
				PO_TYPE : "02",
				DO_TYPE : "insert"
			};
			everPopup.openPopupByScreenId('PO0130',  1200, 1000, param);
		}


		function doSettleCancel() {

            if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
                EVF.alert("${msg.M0004}");
                return;
            }

			var selec = grid.getSelRowValue();
			for(var i in selec){
				var ecdtcnt = selec[i].ECDTCNT;
				if(ecdtcnt>'0') return EVF.alert('${CT0410_009}');
			}

            EVF.confirm("${CT0410_008}", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl + 'doExcept', function(){
					EVF.alert(this.getResponseMessage());
					doSearch();
				});
            });
		}

        function doCreateCont() {
            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

	        var param = {
	        		 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
                    ,RFX_NUM     : grid.getCellValue(rowId,'RFX_NUM')
	        		,RFX_CNT   : grid.getCellValue(rowId,'RFX_CNT')
                    ,QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')

                    ,VENDOR_CD     : grid.getCellValue(rowId,'VENDOR_CD')
                    ,VENDOR_NM     : grid.getCellValue(rowId,'VENDOR_NM')

                    ,PUR_ORG_CD     : grid.getCellValue(rowId,'PUR_ORG_CD')
                    ,SHIPPER_TYPE     : grid.getCellValue(rowId,'SHIPPER_TYPE')

                    ,openFormType : 'C'// 일반계약
	        		,detailView : false
		    };
		    everPopup.openPopupByScreenId('CT0320', 1200, 1000, param);
        }

		function openModCont(param) {
		    everPopup.openPopupByScreenId('CT0320', 1200, 1000, param);
		}



        function doModCont() {
            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

            var selVendorCd = "";
            var selVendorNm = "";
            var selPurcContNum = "";

            var selBuyerCd = "";
            var selRfxNum = "";
            var selRfxCnt = "";
            var selQtaNum = "";

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {

				//alert(grid.getCellValue(rowIds[i], 'VENDOR_CD'));

                if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'VENDOR_CD'))) {
                    return EVF.alert("${CT0410_007}"); <%-- 파트너사 정보가 없어 처리할 수 없습니다. --%>
                }

                selVendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
                selVendorNm = grid.getCellValue(rowIds[i], 'VENDOR_NM');
                //selPurcContNum = grid.getCellValue(rowIds[i], 'PURC_CONT_NUM');

                selBuyerCd = grid.getCellValue(rowIds[i], 'BUYER_CD');
                selRfxNum = grid.getCellValue(rowIds[i], 'RFX_NUM');
                selRfxCnt = grid.getCellValue(rowIds[i], 'RFX_CNT');
                selQtaNum = grid.getCellValue(rowIds[i], 'QTA_NUM');


            }

            var url = '/evermp/buyer/cont/CT0310P01/view';
            var params = {
                selVendorCd: selVendorCd,
                selVendorNm: selVendorNm,
                selPurcContNum: selPurcContNum,

                selBuyerCd: selBuyerCd,
                selRfxNum: selRfxNum,
                selRfxCnt: selRfxCnt,
                selQtaNum: selQtaNum,



                openType: 'regModCont',
                openFormType : 'C' ,// 단가계약
                popupFlag: 'true'
            }
            everPopup.openWindowPopup(url, 1100, 700, params, 'openContSearchPop');
        }

    </script>

    <e:window id="CT0410" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="125" onEnter="doSearch" useTitleBar="false">
			<e:row>
				<%--구매운영조직코드--%>
				<e:label for="PUR_ORG_CD" title="${form_PUR_ORG_CD_N}"/>
				<e:field>
				<e:select id="PUR_ORG_CD" name="PUR_ORG_CD" options="${purOrgCdOptions}" width="${form_PUR_ORG_CD_W}" disabled="${form_PUR_ORG_CD_D}" readOnly="${form_PUR_ORG_CD_RO}" required="${form_PUR_ORG_CD_R}" usePlaceHolder="false"  useMultipleSelect="true"/>
				</e:field>
				<%--견적요청 번호--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
				<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				</e:field>
				<%--협력업체명--%>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RD ? 'everCommon.blank' : 'getVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD"/>
				</e:field>
			</e:row>
			<e:row>
				<%--견적요청일자--%>
				<e:label for="RFX_DATE_FROM" title="${form_RFX_DATE_FROM_N}"/>
				<e:field>
				<e:inputDate id="RFX_DATE_FROM" name="RFX_DATE_FROM" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_RFX_DATE_FROM_R}" disabled="${form_RFX_DATE_FROM_D}" readOnly="${form_RFX_DATE_FROM_RO}" />
				<e:text> ~ </e:text>
				<e:inputDate id="RFX_DATE_TO" name="RFX_DATE_TO" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_RFX_DATE_TO_R}" disabled="${form_RFX_DATE_TO_D}" readOnly="${form_RFX_DATE_TO_RO}" />
				</e:field>
				<%--견적요청명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
				<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}"/>
				<e:field>
				<e:search id="CTRL_USER_NM" name="CTRL_USER_NM" value="" width="${form_CTRL_USER_NM_W}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="${form_CTRL_USER_NM_RD ? 'everCommon.blank' : 'getContUser'}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
				<e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID"/>
				</e:field>
			</e:row>
			<e:row>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
				<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
				<%--업체선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form_VENDOR_SLT_TYPE_N}"/>
				<e:field colSpan="3">
				<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>

        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
			<e:button id="doCreateCont" name="doCreateCont" label="${doCreateCont_N}" onClick="doCreateCont" disabled="${doCreateCont_D}" visible="${doCreateCont_V}"/>
			<e:button id="doModCont" name="doModCont" label="${doModCont_N}" onClick="doModCont" disabled="${doModCont_D}" visible="${doModCont_V}"/>
			<e:button id="doCreatePo" name="doCreatePo" label="${doCreatePo_N}" onClick="doCreatePo" disabled="${doCreatePo_D}" visible="${doCreatePo_V}"/>
			<e:button id="doSettleCancel" name="doSettleCancel" label="${doSettleCancel_N}" onClick="doSettleCancel" disabled="${doSettleCancel_D}" visible="${doSettleCancel_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
