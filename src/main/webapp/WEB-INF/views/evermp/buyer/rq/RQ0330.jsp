<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid;
		var baseUrl = "/evermp/buyer/rq";

		function init() {

 		    EVF.C('PR_REQ_TYPE').removeOption('R');
 		    EVF.C('PROGRESS_CD').removeOption('2300');
			EVF.C('PROGRESS_CD').removeOption('2350');
//  		    EVF.C('PROGRESS_CD').removeOption('2500');
//  		    EVF.C('PROGRESS_CD').removeOption('2550');

			grid = EVF.C("grid");

			grid.setProperty('shrinkToFit'	  , false);                 // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty('rowNumbers'	  , ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty('sortable'		  , ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty('panelVisible'	  , ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty('enterToNextRow' , ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty('acceptZero'	  , ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty('multiSelect'	  , ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${screenName }"
			});

			//Cell Click Event
			grid.cellClickEvent(function(rowId, colId, value) {

				if(colId === 'RFX_NUM' && value !== '') {
					var param = {
						  BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
						, RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
						, RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
						, detailView : true
					};
					everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);

				}else if(colId === 'QTA_NUM' && value !== '') {
					var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');
					if(progressCd < '2400' && progressCd !== '1300'){
						return alert('${RQ0330_004}');
					}
					var param = {
						QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')
						,popupFlag  : true
						,detailView : true
					};
					everPopup.openPopupByScreenId('QT0320', 1200, 900, param);
				}else if(colId === 'VENDOR_NM' && value !== '') {
					 param = {
		                        VENDOR_CD  : grid.getCellValue(rowId, "VENDOR_CD"),
		                        detailView : true,
		                        popupFlag  : true
		                    };
		        	everPopup.openPopupByScreenId("BS03_002", 1200, 900, param);
				}
			});

			// 1300 - 유찰, 2350 - 견적 진행중, 2355 - 견적 마감, 2400 - 업체선정대기, 2550 - 재견적
			if('${form.autoSearchFlag}' == 'Y') {
            	var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                	if(v.value == '2355' || v.value == '2400' || v.value == '2500') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                doSearch();
            } else {
            	var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                	if(v.value == '2355' || v.value == '2400' || v.value == '2500') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            }

			doSearch();
		}

	    //고객사 팝업
	    function selectBuyer(){

			var param = {
					callBackFunction : 'callback_setBuyer'
				}
			everPopup.openCommonPopup(param, 'SP0902');
		}

		function callback_setBuyer(data){
			EVF.V("PR_BUYER_CD", data.CUST_CD);
			EVF.V("PR_BUYER_NM", data.CUST_NM);
		}

		//사업장 팝업
		function selectPlant(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PR_BUYER_CD') === '') {
				return EVF.alert('${RQ0330_005}');
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

		function doSearch() {
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([grid]);
			store.load(baseUrl + '/RQ0330/doSearch', function() {
				if(grid.getRowCount() == 0){
					EVF.alert("${msg.M0002 }");
				}
			});
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

		//조회 조건 구매 담당자 검색
		function selectCtrlUser(){
			var param = {
				callBackFunction: "callback_selectCtrlUser",
			};
			everPopup.openCommonPopup(param, "SP0508");
		}

		function callback_selectCtrlUser(data){
			EVF.V('CTRL_USER_NM', data.CTRL_USER_NM);
			EVF.V('CTRL_USER_ID', data.CTRL_USER_ID);
		}

	</script>

	<e:window id="RQ0330" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--일자--%>
				<e:label for="FROM_DATE" title="">
					<e:select id="TYPE" name="TYPE" value="" options="${typeOptions}" width="${form_TYPE_W}" disabled="${form_TYPE_D}" readOnly="${form_TYPE_RO}" required="${form_TYPE_R}" placeHolder="" usePlaceHolder="false">
						<e:option text="${RQ0330_001}" value="REQ">${RQ0330_001}</e:option>
						<e:option text="${RQ0330_002}" value="END">${RQ0330_002}</e:option>
						<e:option text="${RQ0330_003}" value="STR">${RQ0330_003}</e:option>
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="FROM_DATE" name="FROM_DATE" toDate="TO_DATE" value="${FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="TO_DATE" name="TO_DATE" fromDate="FROM_DATE" value="${TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
				</e:field>
				<%--고객사--%>
				<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}"/>
				<e:field>
					<e:search id="PR_BUYER_CD" name="PR_BUYER_CD" value="" width="40%" maxLength="${form_PR_BUYER_CD_M}" onIconClick="${form_PR_BUYER_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" />
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" value="" width="60%" maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--사업장--%>
				<e:label for="PR_PLANT_CD" title="${form_PR_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PR_PLANT_CD" name="PR_PLANT_CD" value="" width="40%" maxLength="${form_PR_PLANT_CD_M}" onIconClick="${form_PR_PLANT_CD_RO ? 'everCommon.blank' : 'selectPlant'}" disabled="${form_PR_PLANT_CD_D}" readOnly="${form_PR_PLANT_CD_RO}" required="${form_PR_PLANT_CD_R}" />
					<e:inputText id="PR_PLANT_NM" name="PR_PLANT_NM" value="" width="60%" maxLength="${form_PR_PLANT_NM_M}" disabled="${form_PR_PLANT_NM_D}" readOnly="${form_PR_PLANT_NM_RO}" required="${form_PR_PLANT_NM_R}" />
				</e:field>


			</e:row>


			<e:row>
				<%--공급사--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'selectVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<%--견적요청번호/명--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="40%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserNmOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false" />
				</e:field>
				<%--구매요청유형--%>
				<e:label for="PR_REQ_TYPE" title="${form_PR_REQ_TYPE_N}"/>
				<e:field>
					<e:select id="PR_REQ_TYPE" name="PR_REQ_TYPE" value="" options="${prReqTypeOptions}" width="${form_PR_REQ_TYPE_W}" disabled="${form_PR_REQ_TYPE_D}" readOnly="${form_PR_REQ_TYPE_RO}" required="${form_PR_REQ_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
			</e:row>
		</e:searchPanel>

		<e:buttonBar width="100%" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>
