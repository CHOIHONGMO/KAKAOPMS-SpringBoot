<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cn/CN0130/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {
                if (colId == 'EXEC_NUM') {
                    var param = {
                         GATE_CD    : "${ses.gateCd}",
                         EXEC_NUM   : grid.getCellValue(rowId,'EXEC_NUM'),
                         EXEC_CNT   : grid.getCellValue(rowId,'EXEC_CNT'),
                 		 detailView : true
                     };
// 	                    var shipperType = grid.getCellValue(rowId,'SHIPPER_TYPE');
	                    everPopup.openPopupByScreenId('CN0120', 1300, 900, param);
//             			if (shipperType == 'D') {
//             		        everPopup.openPopupByScreenId('CN0120', 1300, 900, param);
//             			} else {
//             		        everPopup.openPopupByScreenId('CN0121', 1300, 900, param);
//             			}

                }
            });

            grid.setProperty('panelVisible', ${panelVisible});
            grid.setProperty('shrinkToFit', false);

            grid.excelExportEvent({
                allCol	 : "${excelExport.allCol}",
                selRow	 : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }"
            });

//             var values = $.map($('#PR_BUYER_CD option'), function(e) { return e.value; });
// 		    EVF.V('PR_BUYER_CD',values.join(','));


            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }

        function doModify(){

        	var rowIds = grid.getSelRowId();
			for(var i in rowIds){
				if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0){
					return alert("${CN0130_0003}");
				}
			}

            if(!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
            if(grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }
            if( (grid.getSelRowValue()[0].SIGN_STATUS == 'E' || grid.getSelRowValue()[0].SIGN_STATUS == 'P')&& (grid.getSelRowValue()[0].SIGN_STATUS2 == 'E' || grid.getSelRowValue()[0].SIGN_STATUS2 == 'P' ) ){ return EVF.alert("${CN0130_0001}"); }

            var param = {
                GATE_CD    : "${ses.gateCd}",
                EXEC_NUM   : grid.getSelRowValue()[0].EXEC_NUM,
                EXEC_CNT   : grid.getSelRowValue()[0].EXEC_CNT,
        		detailView : false
            };

            var shipperType = grid.getSelRowValue()[0].SHIPPER_TYPE;
            everPopup.openPopupByScreenId('CN0120', 1300, 900, param);
// 			if (shipperType == 'D') {
// 		        everPopup.openPopupByScreenId('CN0120', 1300, 900, param);
// 			} else {
// 		        everPopup.openPopupByScreenId('CN0121', 1300, 900, param);
// 			}


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
				return EVF.alert('${CN0130_0002}');
			}
			var param = {
				  custCd		   : EVF.V("PR_BUYER_CD")
				, callBackFunction : 'callback_setPlant'
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
				return EVF.alert('${CN0130_0002}');
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





        function doPrint() {
            var checkType = this.getData();
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rfqList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                rfqList.push({
                    'EXEC_NUM': grid.getCellValue(rowIds[i], 'EXEC_NUM'),
                    'EXEC_CNT': grid.getCellValue(rowIds[i], 'EXEC_CNT')
                });
            }

            var param = {
                RFQ_LIST : JSON.stringify(rfqList)
            };

            everPopup.openPopupByScreenId("PRT_070", 976, 800, param);
        }



    </script>

    <e:window id="CN0130" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">


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
				<%--협력업체--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'selectVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<%--요청자--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserIdOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
				<%--품의번호--%>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />
				<e:field>
					<e:inputText id="EXEC_NUM" name="EXEC_NUM" value="" width="40%" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}" />
					<e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="" width="60%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
				</e:field>
            </e:row>
            <e:row>
                <%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false"/>
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
				<e:label for="dummy" />
				<e:field colSpan="1" />
            </e:row>


        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
			<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}" data="P"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
