<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cn/CN0120P02/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {

                if (colId == 'EXEC_NUM') {
                    var param = {
                            GATE_CD : "${ses.gateCd}",
                            EXEC_NUM : grid.getCellValue(rowId,'EXEC_NUM'),
                            EXEC_CNT : grid.getCellValue(rowId,'EXEC_CNT'),
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
            grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

            grid.setProperty('shrinkToFit', true);

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

//             var values = $.map($('#PR_BUYER_CD option'), function(e) { return e.value; });
// 		    EVF.V('PR_BUYER_CD',values.join(','));


            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.setParameter("PROGRESS_CD", "3300");
            store.setParameter("EXEC_TYPE_D", "EXEC_CHAGE");
            store.load(baseUrl + 'doSearch', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }

        function doModify(){
        	if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
        	if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
 	            return EVF.alert("${msg.M0006}");
 	        }
        	var qtaNumList=${QTA_NUM_LIST};

        	var rowIds = grid.getSelRowId();

        	var checkData = grid.getCellValue(rowIds[0],'PR_TYPE')+grid.getCellValue(rowIds[0],'PR_BUYER_CD')+grid.getCellValue(rowIds[0],'PR_PLANT_CD')

        	var checkLocalData =qtaNumList[0].PR_TYPE+qtaNumList[0].PR_BUYER_CD+qtaNumList[0].PR_PLANT_CD

        	if(checkData!=checkLocalData){
        		return EVF.alert('${CN0120P02_0003}');
			}

        	qtaNumList.push({QTA_NUM : grid.getCellValue(grid.getSelRowId()[0],'EXEC_NUM')})
        	var checkFlag = true;

            var param = {
            	EXEC_NUM    	: grid.getCellValue(grid.getSelRowId()[0],'EXEC_NUM'),
            	EXEC_CNT     	: grid.getCellValue(grid.getSelRowId()[0],'EXEC_CNT'),
            	EXEC_TYPE_D  	: "EXEC_CHAGE",
            	CH_CTRL_USER_ID : EVF.V("CH_CTRL_USER_ID"),
            	CH_CTRL_USER_NM : EVF.V("CH_CTRL_USER_NM"),
            	QTA_NUM_LIST 	: JSON.stringify(qtaNumList),
        		detailView 		:  false
            };

//             var shipperType = grid.getSelRowValue()[0].SHIPPER_TYPE;
            everPopup.openPopupByScreenId('CN0120', 1300, 900, param);



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
				return EVF.alert('${CN0120P02_0002}');
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
				return EVF.alert('${CN0120P02_0002}');
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
		function doOpnerSearch(){
			opener.doSearch();
		}
    </script>

    <e:window id="CN0120P02" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">


        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="125" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id="CH_CTRL_USER_ID" name="CH_CTRL_USER_ID" value="${form.CH_CTRL_USER_ID}"/>
			<e:inputHidden id="CH_CTRL_USER_NM" name="CH_CTRL_USER_NM" value="${form.CH_CTRL_USER_NM}"/>

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
					<e:search id="PR_BUYER_CD" name="PR_BUYER_CD" width="40%" value="${form.PR_BUYER_CD}"   maxLength="${form_PR_BUYER_CD_M}" onIconClick="${form_PR_BUYER_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" />
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" width="60%" value="${form.PR_BUYER_NM}"   maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--사업장 코드/명--%>
				<e:label for="PR_PLANT_CD" title="${form_PR_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PR_PLANT_CD" name="PR_PLANT_CD" width="40%" value="${form.PR_PLANT_CD =='null'? '' : form.PR_PLANT_CD}"  maxLength="${form_PR_PLANT_CD_M}" onIconClick="${form_PR_PLANT_CD_RO ? 'everCommon.blank' : 'selectPlant'}" disabled="${form_PR_PLANT_CD_D}" readOnly="${form_PR_PLANT_CD_RO}" required="${form_PR_PLANT_CD_R}" />
					<e:inputText id="PR_PLANT_NM" name="PR_PLANT_NM" width="60%" value="${ form.PR_PLANT_NM=='null' ? '' : form.PR_PLANT_NM}"   maxLength="${form_PR_PLANT_NM_M}" disabled="${form_PR_PLANT_NM_D}" readOnly="${form_PR_PLANT_NM_RO}" required="${form_PR_PLANT_NM_R}" />
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
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="${form.CPO_USER_ID =='null' ? '' : form.CPO_USER_ID}"  width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="${form_CPO_USER_ID_RO ? 'everCommon.blank' : 'selectCpoUser'}" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="${form.CPO_USER_ID =='null' ? '' : form.CPO_USER_NM}" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
				<%--품의번호--%>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />
				<e:field>
					<e:inputText id="EXEC_NUM" name="EXEC_NUM" value="" width="40%" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}" />
					<e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="" width="60%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
				</e:field>
            </e:row>
			 <e:row>

				<%--소싱유형--%>
				<e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}"/>
				<e:field>
				<e:select id="RFX_TYPE" name="RFX_TYPE" value="${form.RFX_TYPE}" options="${rfxTypeOptions}" width="${form_RFX_TYPE_W}" disabled="${form_RFX_TYPE_D}" readOnly="${form_RFX_TYPE_RO}" required="${form_RFX_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
				<e:label for="dummy" />
				<e:field colSpan="1" />
			 </e:row>


        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        	<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
