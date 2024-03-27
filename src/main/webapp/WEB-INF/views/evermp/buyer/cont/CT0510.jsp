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
                        VENDOR_CD	: grid.getCellValue(rowIdx, "VENDOR_CD"),
                        popupFlag	: true,
                        detailView 	: true
                    };
                    everPopup.openSupManagementPopup(params);
                }else if(colIdx === 'RFX_NUM'){
	                var prReqType = grid.getCellValue(rowIdx, 'PR_REQ_TYPE');
	                var screenName = prReqType == '02' ? '단가계약 견적요청작성' : '견적요청작성';
	                var param = {
		                 BUYER_CD    : grid.getCellValue(rowIdx,'BUYER_CD')
		                ,RFX_NUM     : grid.getCellValue(rowIdx,'RFX_NUM')
		                ,RFX_CNT     : grid.getCellValue(rowIdx,'RFX_CNT')
		                ,screen_name : screenName
		                ,detailView : true
	                };
	                everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);
                }else if(colIdx === 'QTA_NUM') {
	                var param = {
		                QTA_NUM     : grid.getCellValue(rowIdx,'QTA_NUM')
		                ,popupFlag  : true
		                ,detailView : true
	                };
	                everPopup.openPopupByScreenId('QT0320', 1600, 1000, param);
                }else if(colIdx === 'EXEC_NUM') {
                    var param = {
                            GATE_CD  	: "${ses.gateCd}",
                            EXEC_NUM 	: grid.getCellValue(rowIdx,'EXEC_NUM'),
                            EXEC_CNT 	: grid.getCellValue(rowIdx,'EXEC_CNT'),
                    		detailView  : true
                        };
	                    var shipperType = grid.getCellValue(rowIdx,'SHIPPER_TYPE');
            			if (shipperType != 'O') {
            		        everPopup.openPopupByScreenId('CN0120', 1300, 900, param);
            			} else {
            		        everPopup.openPopupByScreenId('CN0121', 1300, 900, param);
            			}



                }
            });

            grid.excelExportEvent({
                allCol	: "${excelExport.allCol}",
                selRow	: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

//             var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
// 		    EVF.V('BUYER_CD',values.join(','));

//            EVF.C('CONT_TYPE').removeOption('03');
//           EVF.C('CONT_TYPE').removeOption('04');
//            EVF.V('EXCEPT_TYPE','0');

	        // DashBoard 통해서 들어왔을 경우 파라미터 셋팅

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + '/CT0510/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }


        function doRegCont() {
            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }
            if (grid.getCellValue(0,'CTRL_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
            	return EVF.alert("${CT0510_001}");
            }

	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

	        var param = {
        		  RFX_NUM            : grid.getCellValue(rowId,'RFX_NUM')
        		, RFX_CNT            : grid.getCellValue(rowId,'RFX_CNT')
                , QTA_NUM            : grid.getCellValue(rowId,'QTA_NUM')
                , VENDOR_CD          : grid.getCellValue(rowId,'VENDOR_CD')
                , VENDOR_NM          : grid.getCellValue(rowId,'VENDOR_NM')
                , BUYER_CD           : grid.getCellValue(rowId,'PR_BUYER_CD')
                , BUYER_NM           : grid.getCellValue(rowId,'PR_BUYER_NM')
                , PUR_ORG_CD         : grid.getCellValue(rowId,'PUR_ORG_CD')
                , SHIPPER_TYPE       : grid.getCellValue(rowId,'SHIPPER_TYPE')
                , CUR                : grid.getCellValue(rowId,'CUR')
                , CONT_DESC          : grid.getCellValue(rowId,'EXEC_SUBJECT')
                , PR_BUYER_CD        : grid.getCellValue(rowId,'PR_BUYER_CD')
                , PR_BUYER_NM        : grid.getCellValue(rowId,'PR_BUYER_NM')
                , EXEC_NUM           : grid.getCellValue(rowId,'EXEC_NUM')
                , EXEC_CNT           : grid.getCellValue(rowId,'EXEC_CNT')
                , APAR_TYPE          : grid.getCellValue(rowId,'APAR_TYPE')
                , CTRL_USER_ID 		 : grid.getCellValue(rowId,'CTRL_USER_ID')
                , BELONG_DIVISION_CD : grid.getCellValue(rowId,'BELONG_DIVISION_CD')
                , BELONG_DEPT_CD     : grid.getCellValue(rowId,'BELONG_DEPT_CD')
                , CTRL_USER_ID       : grid.getCellValue(rowId,'CTRL_USER_ID')
                , openFormType       : 'C'
        		, detailView         : false
		    };
		    everPopup.openPopupByScreenId('CT0320', 1400, 1000, param);
		    /*
		    A  ('03') -- 단가계약
		    B  ('01') -- 기본계약
		    C  ('02') -- 일반계약
		    D  ('02') -- 기타계약
		    */
        }

		function openModCont(param) {
		    everPopup.openPopupByScreenId('CT0320', 1400, 1000, param);
		}

        function doModCont() {

            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

            if (grid.getCellValue(0,'CTRL_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
            	return EVF.alert("${CT0510_001}");
            }

            var selVendorCd 	= "";
            var selVendorNm 	= "";
            var selPurcContNum 	= "";

            var selBuyerCd 		= "";
            var selRfxNum 		= "";
            var selRfxCnt 		= "";
            var selQtaNum 		= "";

            var shipperType  	= "";
            var locBuyerCd   	= "";
            var execNum  	 	= "";
            var execCnt  	 	= "";

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {

				//alert(grid.getCellValue(rowIds[i], 'VENDOR_CD'));

	            if(EVF.isEmpty(grid.getCellValue(rowIds[i], 'VENDOR_CD'))) {
	                return EVF.alert("${CT0510_007}"); <%-- 파트너사 정보가 없어 처리할 수 없습니다. --%>
	            }
	            selVendorCd 	= grid.getCellValue(rowIds[i], 'VENDOR_CD');
	            selVendorNm 	= grid.getCellValue(rowIds[i], 'VENDOR_NM');
	            selPurcContNum 	= grid.getCellValue(rowIds[i], 'PURC_CONT_NUM');
	            selBuyerCd 		= grid.getCellValue(rowIds[i], 'BUYER_CD');
	            selRfxNum 		= grid.getCellValue(rowIds[i], 'RFX_NUM');
	            selRfxCnt 		= grid.getCellValue(rowIds[i], 'RFX_CNT');
	            selQtaNum 		= grid.getCellValue(rowIds[i], 'QTA_NUM');
                shipperType   	= grid.getCellValue(rowIds[i],'SHIPPER_TYPE');
                execNum     	=  grid.getCellValue(rowIds[i],'EXEC_NUM');
                execCnt     	=  grid.getCellValue(rowIds[i],'EXEC_CNT');
            }
            var url = '/evermp/buyer/cont/CT0310P01/view';
            var params = {
                selVendorCd		: selVendorCd,
                selVendorNm		: selVendorNm,
                selPurcContNum	: selPurcContNum,
                selBuyerCd		: selBuyerCd,
                selRfxNum		: selRfxNum,
                selRfxCnt		: selRfxCnt,
                selQtaNum		: selQtaNum,
                openType		: 'regModCont',
                openFormType 	: 'C' ,
                popupFlag		: 'true',
                shipperType     : shipperType,
                execNum     	: execNum,
                execCnt     	: execCnt
            }



/*
A  ('03') -- 단가계약
B  ('01') -- 기본계약
C  ('02') -- 일반계약
D  ('02') -- 기타계약
*/
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
	            if(ecdtcnt>'0') return EVF.alert('${CT0510_010}');
	            if (grid.getCellValue(i,'CTRL_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
	            	return EVF.alert("${CT0510_001}");
	            }
            }

            EVF.confirm("${CT0510_009}", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl + '/CT0510/doExcept', function(){
					EVF.alert(this.getResponseMessage());
					doSearch();
				});
			});
		}

		//계약자(을)
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
		//계약자(갑)
		function selectBuyer(){

			var param = {
					 PR_BUYER_CD 	  : EVF.V("PR_BUYER_CD")
					,callBackFunction : 'callback_setBuyer'
				}
				everPopup.openCommonPopup(param, 'SP0067');
		}
		function callback_setBuyer(data){
			EVF.V("PR_BUYER_CD", data.CUST_CD);
			EVF.V("PR_BUYER_NM", data.CUST_NM);
		}

    </script>
    <e:window id="CT0510" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
            <e:row>
				<%--구매요청회사--%>
				<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}"/>
				<e:field>
					<e:search id="PR_BUYER_CD" name="PR_BUYER_CD" width="40%" value=""  maxLength="${form_PR_BUYER_CD_M}" onIconClick="${form_PR_BUYER_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" />
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" width="60%" value=""  maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--협력사--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'getVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<%--품의번호/명--%>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />
				<e:field>
					<e:inputText id="EXEC_NUM" name="EXEC_NUM" value="" width="50%" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}" />
					<e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="" width="50%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EXEC_START_DATE" title="${form_EXEC_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="EXEC_START_DATE" name="EXEC_START_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_EXEC_START_DATE_R}" disabled="${form_EXEC_START_DATE_D}" readOnly="${form_EXEC_START_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="EXEC_END_DATE" name="EXEC_END_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_EXEC_END_DATE_R}" disabled="${form_EXEC_END_DATE_D}" readOnly="${form_EXEC_END_DATE_RO}" />
				</e:field>

				<%--품의명--%>
				<e:label for="APAR_TYPE" title="${form_APAR_TYPE_N}"/>
				<e:field>
					<e:select id="APAR_TYPE" name="APAR_TYPE" value="" options="${aparTypeOptions}" width="${form_APAR_TYPE_W}" disabled="${form_APAR_TYPE_D}" readOnly="${form_APAR_TYPE_RO}" required="${form_APAR_TYPE_R}" placeHolder="" />
				</e:field>
				<!-- 계약담당자 -->
				<e:label for="CONT_USER_ID" title="${form_CONT_USER_ID_N}"/>
				<e:field>
					<e:select id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId}" options="${contUserIdOptions}" width="${form_CONT_USER_ID_W}" disabled="${form_CONT_USER_ID_D}" readOnly="${form_CONT_USER_ID_RO}" required="${form_CONT_USER_ID_R}" placeHolder="" />
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


