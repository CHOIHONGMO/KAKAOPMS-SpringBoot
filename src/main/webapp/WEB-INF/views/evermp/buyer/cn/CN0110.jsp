<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cn/CN0110/";

        function init() {

            grid  = EVF.C("grid");
            gridB = EVF.C("gridB");
            gridQ = EVF.C("gridQ");

            $("#panelB").hide();
            var gubnNm;
            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'RFX_NUM') {
                	var gubun = grid.getCellValue(rowId,'GUBUN');
					if(gubun == 'RQ') {
	                	var param = {
			        		  BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
			        		, RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
		                    , RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
			        		, detailView : true
					    };
					    everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);
					} else {
				        var param = {
			        		  BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
			        		, RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
		                    , RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
			        		, detailView : true
					    };
					    everPopup.openPopupByScreenId('BD0310', 1200, 900, param);
					}
                }

                if (colId == 'QTA_NUM') {
                	var gubun = grid.getCellValue(rowId,'GUBUN');
					if(gubun == 'RQ') {
						var param = {
								QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')
								,popupFlag : true
								,detailView : true
							};
							everPopup.openPopupByScreenId('QT0320', 1600, 1000, param);
					} else {
						var param = {
							  QTA_NUM 	 : grid.getCellValue(rowId,'QTA_NUM')
							, QTA_CNT 	 : grid.getCellValue(rowId,'QTA_CNT')
							, VENDOR_CD  : grid.getCellValue(rowId,'VENDOR_CD')
							, popupFlag  : true
							, detailView : true
						};
						everPopup.openPopupByScreenId('BQ0320', 1200, 900, param);
					}
                }
				if (colId == 'RFX_SUBJECT'){
					var gubun = grid.getCellValue(rowId,'GUBUN');

					if(gubun == 'RQ') {
						gubnNm=EVF.C("gridQ");
						$("#panelQ").show();
						$("#panelB").hide();
					} else {
						gubnNm=EVF.C("gridB");
						$("#panelB").show();
						$("#panelQ").hide();
					}
					var store = new EVF.Store();
	                   store.setParameter("QTA_NUM"	, grid.getCellValue(rowId, 'QTA_NUM'));
	                   store.setParameter("QTA_CNT"	, grid.getCellValue(rowId, 'QTA_CNT'));
	                   store.setParameter("GUBUN"	, grid.getCellValue(rowId, 'GUBUN'));
	                   store.setGrid([gubnNm]);
	                   store.load(baseUrl + "/doSearchT", function () {

	                   }, false);
				}
            });

            grid.setProperty('panelVisible', ${panelVisible});
            grid.setProperty('shrinkToFit', false);

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'doSearchTargetExec', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }


		function selectCtrlUserId(){
			var param = {
				callBackFunction : "setCtrlUserId"
			};
			everPopup.openCommonPopup(param, 'SP0040');
		}

		function setCtrlUserId(data){
			EVF.V("CTRL_USER_ID", data.CTRL_USER_ID);
			EVF.V("CTRL_USER_NM", data.CTRL_USER_NM);
		}

		function doChangeWrite(){
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
			var checkFlag = true;

			var rowIds = grid.getSelRowId();

			var checkData = grid.getCellValue(rowIds[0],'PR_TYPE')+grid.getCellValue(rowIds[0],'PR_BUYER_CD')+grid.getCellValue(rowIds[0],'PR_PLANT_CD');

// 			var curr = grid.getCellValue(rowIds[0],'CUR');
// 			var shipperType = grid.getCellValue(rowIds[0],'SHIPPER_TYPE');

		    for(var i in rowIds){

		    	if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0){
		    		return alert("${CN0110_014}");
				}

		    	var right_v_yn = grid.getCellValue(rowIds[i],'RIGHT_V_YN');

		    	if(right_v_yn!='Y') {
					alert('${CN0110_013}')
					return;
		    	}


				var data = grid.getCellValue(rowIds[i],'PR_TYPE')+grid.getCellValue(rowIds[i],'PR_BUYER_CD')+grid.getCellValue(rowIds[i],'PR_PLANT_CD');
				if (
						data != checkData
				) {
					checkFlag = false;
					break;
				}
		    }
			if(!checkFlag) {
				alert('${CN0110_0001}')
				return;
			}
			var param = {
	        		QTA_NUM_LIST : JSON.stringify(grid.getSelRowValue()),
	        		detailView   : false
		    };
	        everPopup.openPopupByScreenId('CN0120P02', 1300, 900, param); // 내자 통일.
		}

		function doExecWrite() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
			var checkFlag = true;

			var rowIds = grid.getSelRowId();

			var checkData = grid.getCellValue(rowIds[0],'PR_TYPE')+grid.getCellValue(rowIds[0],'PR_BUYER_CD')+grid.getCellValue(rowIds[0],'PR_PLANT_CD');

// 			var curr = grid.getCellValue(rowIds[0],'CUR');
// 			var shipperType = grid.getCellValue(rowIds[0],'SHIPPER_TYPE');

		    for(var i in rowIds){

		    	if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0){
		    		return alert("${CN0110_014}");
				}

		    	var right_v_yn = grid.getCellValue(rowIds[i],'RIGHT_V_YN');

		    	if(right_v_yn!='Y') {
					alert('${CN0110_013}')
					return;
		    	}


				var data = grid.getCellValue(rowIds[i],'PR_TYPE')+grid.getCellValue(rowIds[i],'PR_BUYER_CD')+grid.getCellValue(rowIds[i],'PR_PLANT_CD');
				if (
						data != checkData
				) {
					checkFlag = false;
					break;
				}
		    }
			if(!checkFlag) {
				alert('${CN0110_0001}')
				return;
			}
	        var param = {
	        		QTA_NUM_LIST : JSON.stringify(grid.getSelRowValue()),
	        		detailView : false
		    };
	        everPopup.openPopupByScreenId('CN0120', 1300, 900, param); // 내자 통일.


// 			if (shipperType == 'D') {
// 		        everPopup.openPopupByScreenId('CN0120', 1300, 900, param);
// 			} else {
// 		        everPopup.openPopupByScreenId('CN0121', 1300, 900, param);
// 			}


		}




		function doSettleCancel() {

            if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
                EVF.alert("${msg.M0004}");
                return;
            }

            var message = '';
            var prevRfxNum = '';
            var selectedGrid = grid.getSelRowValue();

			for(var i in selectedGrid){
				if(selectedGrid[i].CN_NUM > '0'){
					return EVF.alert(selectedGrid[i].RFX_NUM + ' ${CN0110_009}');
				}
				if(grid.getCellValue(i, 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0){
					return alert("${CN0110_014}");
				}
			}

            for(var i in selectedGrid){
            	if(prevRfxNum !== selectedGrid[i].RFX_NUM && i!=='0') message += ', ';
            	if(prevRfxNum !== selectedGrid[i].RFX_NUM) message += selectedGrid[i].RFX_NUM;
	            prevRfxNum = selectedGrid[i].RFX_NUM;
            }

            EVF.confirm(message + ' ${CN0110_011}', function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl + 'doSettleCancel', function(){
					EVF.alert(this.getResponseMessage());
					doSearch();
				});
            });

		}
		 //고객사 팝업
	    function selectBuyer(){

			var param = {
					callBackFunction : 'callback_setBuyer'
				}
			everPopup.openCommonPopup(param, 'SP0067');
		}
		function callback_setBuyer(data){
			EVF.V("PR_BUYER_CD", data.CUST_CD);
			EVF.V("PR_BUYER_NM", data.CUST_NM);
		}
		//사업장 팝업
		function selectPlant(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PR_BUYER_CD') === '') {
				return EVF.alert('${CN0110_014}');
			}
			var param = {
					 custCd			  : EVF.V("PR_BUYER_CD")
					,callBackFunction : 'callback_setPlant'
				}
				everPopup.openCommonPopup(param, 'SP0005');
		}
		function callback_setPlant(data){
			EVF.V("PR_PLANT_NM", data.PLANT_NM);
			EVF.V("PR_PLANT_CD", data.PLANT_CD);

		}
		//공급사
		function selectVendor(){

			var param = {
				callBackFunction : "callBack_selectVendor"
			}
			everPopup.openCommonPopup(param, "SP0063", 1100, 800);
		}

		function callBack_selectVendor(data){
			EVF.V('VENDOR_NM', data.VENDOR_NM);
			EVF.V('VENDOR_CD', data.VENDOR_CD);
		}
		//요청자
		function selectCpoUser(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PR_BUYER_CD') === '') {
				return EVF.alert('${CN0110_014}');
			}
			var param = {
				cust_cd          : EVF.V("PR_BUYER_CD"),
				callBackFunction : "callBack_selectCpoUser"
			}
			everPopup.openCommonPopup(param, "SP0039", 1100, 800);
		}

		function callBack_selectCpoUser(data){
			EVF.V('CPO_USER_ID', data.USER_ID);
			EVF.V('CPO_USER_NM', data.USER_NM);
		}
    </script>

    <e:window id="CN0110" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">


        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="125" onEnter="doSearch" useTitleBar="false">

            <e:row>
				<%--종료일자--%>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<%--구매요청회사--%>
				<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}"/>
				<e:field>
					<e:search id="PR_BUYER_CD" name="PR_BUYER_CD" width="40%" value="${formData.PR_BUYER_CD}"  maxLength="${form_PR_BUYER_CD_M}" onIconClick="${form_PR_BUYER_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" />
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" width="60%" value="${formData.PR_BUYER_NM}"  maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--사업장 코드/명--%>
				<e:label for="PR_PLANT_CD" title="${form_PR_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PR_PLANT_CD" name="PR_PLANT_CD" width="40%" value=""  maxLength="${form_PR_PLANT_CD_M}" onIconClick="${form_PR_PLANT_CD_RO ? 'everCommon.blank' : 'selectPlant'}" disabled="${form_PR_PLANT_CD_D}" readOnly="${form_PR_PLANT_CD_RO}" required="${form_PR_PLANT_CD_R}" />
					<e:inputText id="PR_PLANT_NM" name="PR_PLANT_NM" width="60%" value=""  maxLength="${form_PR_PLANT_NM_M}" disabled="${form_PR_PLANT_NM_D}" readOnly="${form_PR_PLANT_NM_RO}" required="${form_PR_PLANT_NM_R}" />
				</e:field>

            </e:row>
            <e:row>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserNmOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
				<%--협력업체--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'selectVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
			    </e:field>
				<%--요청자--%>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="${form_CPO_USER_ID_RO ? 'everCommon.blank' : 'selectCpoUser'}" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>

            </e:row>
			 <e:row>
			 	<%--요청번호--%>
				<e:label for="RFQ_BD_NUM" title="${form_RFQ_BD_NUM_N}" />
				<e:field>
					<e:inputText id="RFQ_BD_NUM" name="RFQ_BD_NUM" value="" width="40%" maxLength="${form_RFQ_BD_NUM_M}" disabled="${form_RFQ_BD_NUM_D}" readOnly="${form_RFQ_BD_NUM_RO}" required="${form_RFQ_BD_NUM_R}" />
					<e:inputText id="RFQ_BD_NM" name="RFQ_BD_NM" value="" width="60%" maxLength="${form_RFQ_BD_NM_M}" disabled="${form_RFQ_BD_NM_D}" readOnly="${form_RFQ_BD_NM_RO}" required="${form_RFQ_BD_NM_R}" />
				</e:field>
				<%--소싱유형--%>
				<e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}"/>
				<e:field>
				<e:select id="RFX_TYPE" name="RFX_TYPE" value="" options="${rfxTypeOptions}" width="${form_RFX_TYPE_W}" disabled="${form_RFX_TYPE_D}" readOnly="${form_RFX_TYPE_RO}" required="${form_RFX_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
			 </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doExecWrite" name="doExecWrite" label="${doExecWrite_N}" onClick="doExecWrite" disabled="${doExecWrite_D}" visible="${doExecWrite_V}"/>
			<e:button id="doChangeWrite" name="doChangeWrite" label="${doChangeWrite_N}" onClick="doChangeWrite" disabled="${doChangeWrite_D}" visible="${doChangeWrite_V}"/>
			<e:button id="doSettleCancel" name="doSettleCancel" label="${doSettleCancel_N}" onClick="doSettleCancel" disabled="${doSettleCancel_D}" visible="${doSettleCancel_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="400px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    	<e:panel id="panelB" width="100%">
			<e:gridPanel id="gridB" name="gridB" width="100%" height="300px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridB.gridColData}" />
		</e:panel>
		<e:panel id="panelQ" width="100%">
			<e:gridPanel id="gridQ" name="gridQ" width="100%" height="300px" gridType="${_gridType}" readOnly="${empty param.detailView ? false :  param.detailView}" columnDef="${gridInfos.gridQ.gridColData}" />
		</e:panel>
    </e:window>
</e:ui>
