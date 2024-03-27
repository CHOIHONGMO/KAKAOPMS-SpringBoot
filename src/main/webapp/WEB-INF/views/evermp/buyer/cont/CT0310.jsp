<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/buyer/cont/";

        function init() {

            grid = EVF.C("grid");

            grid.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function(rowIdx, colIdx, value) {

                if(colIdx == "IRS_NUM") {
                    var params = {
                        VENDOR_CD: grid.getCellValue(rowIdx, "VENDOR_CD"),
                        popupFlag: true,
                        detailView : true
                    };
                    everPopup.openSupManagementPopup(params);
                }else if(colIdx === 'RFX_NUM'){
	                var prReqType = grid.getCellValue(rowIdx, 'PR_REQ_TYPE');
	                var screenName = prReqType == '02' ? '단가계약 견적요청작성' : '견적요청작성';
	                var param = {
		                BUYER_CD   : grid.getCellValue(rowIdx,'BUYER_CD')
		                ,RFX_NUM   : grid.getCellValue(rowIdx,'RFX_NUM')
		                ,RFX_CNT     : grid.getCellValue(rowIdx,'RFX_CNT')
		                ,screen_name : screenName
		                ,detailView : true
	                };
	                everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);
                }else if(colIdx === 'QTA_NUM') {
	                var param = {
		                QTA_NUM     : grid.getCellValue(rowIdx,'QTA_NUM')
		                ,popupFlag : true
		                ,detailView : true
	                };
	                everPopup.openPopupByScreenId('QT0320', 1600, 1000, param);
                }
            });

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

           // EVF.C('PUR_ORG_CD').removeOption('');
            var values = $.map($('#PUR_ORG_CD option'), function(e) { return e.value; });
		    EVF.V('PUR_ORG_CD',values.join(','));

//            EVF.C('CONT_TYPE').removeOption('03');
//           EVF.C('CONT_TYPE').removeOption('04');
//            EVF.V('EXCEPT_TYPE','0');

	        // DashBoard 통해서 들어왔을 경우 파라미터 셋팅
	        if ('${param.dashBoardFlag}' == 'Y') {
		        EVF.V('RFX_FROM_DATE', '${param.FROM_DATE}');
		        EVF.V('RFX_TO_DATE', '${param.TO_DATE}');
	        }

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + '/CT0310/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }


        function doRegCont() {
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

                    ,openFormType : 'A' // 단가계약
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
                    return EVF.alert("${CT0310_007}"); <%-- 파트너사 정보가 없어 처리할 수 없습니다. --%>
                }




                selVendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
                selVendorNm = grid.getCellValue(rowIds[i], 'VENDOR_NM');
                selPurcContNum = grid.getCellValue(rowIds[i], 'PURC_CONT_NUM');

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
                openFormType : 'A' ,// 단가계약
                popupFlag: 'true'
            }
            everPopup.openWindowPopup(url, 1100, 700, params, 'openContSearchPop');
        }


        function doExcept() {
            if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
                EVF.alert("${msg.M0004}");
                return;
            }

            var selec = grid.getSelRowValue();
            for(var i in selec){
	            var ecdtcnt = selec[i].ECDTCNT;
	            if(ecdtcnt>'0') return EVF.alert('${CT0310_010}');
            }

            EVF.confirm("${CT0310_009}", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl + '/CT0310/doExcept', function(){
					EVF.alert(this.getResponseMessage());
					doSearch();
				});
			});
		}


        function getVendorCd() {
            everPopup.openCommonPopup({
                callBackFunction: "setVendorCd"
            }, 'SP0063');
        }

        function setVendorCd(data) {
            EVF.V("VENDOR_CD", data.VENDOR_CD);
            EVF.V("VENDOR_NM", data.VENDOR_NM);
        }

        function cleanVendorCd() {
            EVF.V("VENDOR_CD", '');
        }

    </script>

    <e:window id="CT0310" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
            <e:row>
				<%--구매운영조직코드--%>
				<e:label for="PUR_ORG_CD" title="${form_PUR_ORG_CD_N}"/>
				<e:field>
				<e:select id="PUR_ORG_CD" name="PUR_ORG_CD" value="" options="${purOrgCdOptions}" width="${form_PUR_ORG_CD_W}" disabled="${form_PUR_ORG_CD_D}" readOnly="${form_PUR_ORG_CD_RO}" required="${form_PUR_ORG_CD_R}" usePlaceHolder="false" useMultipleSelect="true"/>
				</e:field>
				<%--견적요청번호--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
				<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				</e:field>
				<%--협력사--%>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RD ? 'everCommon.blank' : 'getVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD"/>
				</e:field>
            </e:row>
            <e:row>
				<%--마감일자--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field colSpan="5">
				<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" value="${not empty param.FROM_DATE ? param.FROM_DATE : fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
				<e:text> ~ </e:text>
				<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" value="${not empty param.TO_DATE ? param.TO_DATE : toDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="RegCont" name="RegCont" label="${RegCont_N}" disabled="${RegCont_D}" visible="${RegCont_V}" onClick="doRegCont" />
            <e:button id="ModCont" name="ModCont" label="${ModCont_N}" disabled="${ModCont_D}" visible="${ModCont_V}" onClick="doModCont" />
            <e:button id="doExcept" name="doExcept" label="${doExcept_N}" disabled="${doExcept_D}" visible="${doExcept_V}" onClick="doExcept" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>

</e:ui>


