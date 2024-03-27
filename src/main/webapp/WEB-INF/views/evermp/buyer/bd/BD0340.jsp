<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0340";
	    var grid;
		var selRow;

	    function init() {

		    EVF.C('PR_TYPE').removeOption('R');
		    EVF.C('PROGRESS_CD').removeOption('2600');
		    EVF.C('PROGRESS_CD').removeOption('2650');
		    EVF.C('PROGRESS_CD').removeOption('2700');

		    grid = EVF.C("grid");
		    gridT = EVF.C("gridT");
		    grid.setProperty("shrinkToFit"	  , false);            	 // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers"	  , ${rowNumbers});      // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable"		  , ${sortable});        // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible"	  , ${panelVisible});    // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow" , ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero"	  , ${acceptZero});      // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect"	  , ${multiSelect});     // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allCol   : "${excelOption.allCol}",
				selRow   : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});

		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
		    	if(selRow == undefined) selRow = rowId;
		    	if(colId == "multiSelect" && value =='1') {
					if(selRow != rowId) {
						grid.checkRow(selRow, false);
						selRow = rowId;
					}
					grid.checkRow(selRow, true);
					var store = new EVF.Store();
					store.setParameter("RFX_NUM", grid.getCellValue(rowId, 'RFX_NUM'));
					store.setParameter("QTA_CNT", grid.getCellValue(rowId, 'QTA_CNT'));
					store.setGrid([gridT]);
					store.load(baseUrl + "/doSearchT", function () {

					}, false);
				} else if(colId === 'RFX_NUM'){
				    var param = {
					      BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
					    , RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
					    , RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
					    , detailView : true
				    };
				    everPopup.openPopupByScreenId('BD0310', 1400, 900, param);
				} else if(colId === 'VENDOR_CNT'){
				    var param = {
					      BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
					    , RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
					    , RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
					    , detailView : true
				    };
				    everPopup.openPopupByScreenId('BD0320P01', 1200, 500, param);
				}else if(colId === 'EV_STATUS' && value !== ''){
				    var param = {
					      BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
					    , RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
					    , RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
					    , detailView : true
				    };
				    everPopup.openPopupByScreenId('BD0340P04', 1400, 900, param);
				}else if(colId === 'RFX_SUBJECT'){
		    	   grid.checkRow(rowId, true);
				   var store = new EVF.Store();
                   store.setParameter("RFX_NUM", grid.getCellValue(rowId, 'RFX_NUM'));
                   store.setParameter("RFX_CNT", grid.getCellValue(rowId, 'RFX_CNT'));
                   store.setGrid([gridT]);
                   store.load(baseUrl + "/doSearchT", function () {

                   }, false);
				}
			});

		    //상세그리드
			gridT.cellClickEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){
				var qtopenYn = gridT.getCellValue(rowIdx,'QTOPEN_YN');
				if(colIdx === 'BATT_FILE_CNT') {
					if(qtopenYn =='N'){
						return alert('${RQ0340_012}');
					}
					param = {
						  detailView	   : true
						, attFileNum	   : gridT.getCellValue(rowIdx, "BATT_FILE_NUM")
						, rowId			   : rowIdx
						, callBackFunction : ""
						, bizType		   : "RQ"
						, fileExtension    : "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'SATT_FILE_CNT'){
					if(qtopenYn =='N'){
						return alert('${RQ0340_012}');
					}
					param = {
						  detailView	   : ${param.detailView}
						, attFileNum	   : gridT.getCellValue(rowIdx, "SATT_FILE_NUM")
						, havePermission   : true
						, rowId			   : rowIdx
						, callBackFunction : "callback_setAttFile"
						, bizType		   : "QT"
						, fileExtension	   : "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'BRMK'){
					if(qtopenYn =='N'){
						return alert('${RQ0340_012}');
					}
					var param = {
						  rowId			   : rowIdx
						, havePermission   : false
						, screenName	   : '구매사 비고'
						, callBackFunction : ''
						, TEXT_CONTENTS	   : gridT.getCellValue(rowIdx, "BRMK")
						, detailView	   : true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}else if(colIdx === 'SRMK'){
					if(qtopenYn =='N'){
						return alert('${RQ0340_012}');
					}
					var param = {
						  rowId			   : rowIdx
						, havePermission   : true
						, screenName	   : '협력사 비고'
						, callBackFunction : "callback_set_grid_SRMK"
						, TEXT_CONTENTS	   : gridT.getCellValue(rowIdx, "SRMK")
						, detailView	   : "${param.detailView}"
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}

			});
		    fn_multiCombo();
	        doSearch();

	    }

	    function fn_multiCombo(){
	    	if('${form.autoSearchFlag}' == 'Y') {
            	var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if(v.value == '2750' || v.value == '2800' || v.value == '2850') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                doSearch();
            } else {
            	var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                	if(v.value == '2750' || v.value == '2800' || v.value == '2850') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            }
	    }

	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {
	            if (grid.getRowCount() == 0) {
		            EVF.alert("${msg.M0002 }");
	            }
	        });
        }

		//조회 조건 구매 담당자 검색
		function openCtrlUser(){
			var param = {
				callBackFunction: "setCtrlUser",
			};
			everPopup.openCommonPopup(param, "SP0508");
		}

		function setCtrlUser(data){
			EVF.V('CTRL_USER_NM', data.CTRL_USER_NM);
			EVF.V('CTRL_USER_ID', data.CTRL_USER_ID);
		}

		//선택한 데이터의 구매담당자 본인 인지 체크
		function checkUserValidate(){
			var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
            for(var i = 0; i < rowIds.length; i++) {
				if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') !== "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0){
					return 'M0008'; //처리할 권한이 없습니다.
				}
            }
		}

		function doTransferCtrlUser(){

			if(checkUserValidate() === 'M0008'){
				return EVF.alert("${msg.M0008}")
			}

			var param = {
				callBackFunction: "transferCtrlUser",
			};
			everPopup.openCommonPopup(param, "SP0508");
		}

		function transferCtrlUser(data){
			EVF.V('CTRL_USER_TRANSFER_NM', data.CTRL_USER_NM);
			EVF.V('CTRL_USER_TRANSFER_ID', data.CTRL_USER_ID);
		}

		//평가 요청
		function doReqEval(){

			if(grid.getSelRowCount() === 0) {
				return  EVF.alert("${msg.M0004}");
			}

			if(grid.getSelRowCount() > 1) {
				return  EVF.alert("${msg.M0006}");
			}

			if(checkUserValidate() === 'M0008'){
				return EVF.alert("${msg.M0008}")
			}

			if(grid.getSelRowValue()[0].PROGRESS_CD < '2800'){
				return EVF.alert("${BD0340_006}");
			}

			if(grid.getSelRowValue()[0].PRC_SLT_TYPE !== 'NGO'){
				return EVF.alert("${BD0340_007}");
			}

			if(grid.getSelRowValue()[0].EV_STATUS !== '050'){
				return EVF.alert("${BD0340_008}");
			}

			var param = {
				  BUYER_CD    : grid.getSelRowValue()[0].BUYER_CD
				, RFX_NUM     : grid.getSelRowValue()[0].RFX_NUM
				, RFX_CNT     : grid.getSelRowValue()[0].RFX_CNT
				, RFX_SUBJECT : '[협력업체 선정 평가] ' + grid.getSelRowValue()[0].RFX_SUBJECT
				, detailView  : false
			};
			everPopup.openPopupByScreenId('BD0340P04', 1600, 900, param);
		}

		//개찰
		function doQtOpen() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return EVF.alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return EVF.alert("${msg.M0006}");
	        }

	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];


			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');

			if ( progressCd !== '2750' && progressCd !== '2850') {
				return EVF.alert("${BD0340_005}");
			}

			if ( grid.getCellValue(rowId,'OPEN_BID_USER_ID') != '${ses.userId}') {
				return EVF.alert("${BD0340_013}");
			}
			if(!confirm('${BD0340_001}')) return;

			var novendor = '${BD0340_002}';
			if ( grid.getCellValue(rowId,'SUBMIT_VENDOR_CNT') === '0') {
				if(!confirm(novendor)) return;	//참여한 업체가 0개
			}

			var submitVendorCnt = grid.getCellValue(rowId,'SUBMIT_VENDOR_CNT');
			var totalVendorCnt = grid.getCellValue(rowId,'TOTAL_VENDOR_CNT');
			if(submitVendorCnt !== totalVendorCnt){
				if(!confirm('${BD0340_004}')) return;	//미참여업체가 존재합니다. 계속 진행 하시겠습니까?
			}

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + '/doQtOpen', function(){
				EVF.alert(this.getResponseMessage(),function(){
					doSearch();
				});
			});
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
				return EVF.alert('${BD0340_011}');
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

		//입찰비교
		function doCompareBq() {
			if(grid.getSelRowCount() === 0) {
	            return  EVF.alert("${msg.M0004}");
	        }
	        if(grid.getSelRowCount() > 1) {
	            return  EVF.alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

			if(checkUserValidate() == 'M0008'){
				return  EVF.alert("${msg.M0008}")
			}

			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');
			var vendorSltType = grid.getCellValue(rowId,'VENDOR_SLT_TYPE');
			var prcSltType = grid.getCellValue(rowId,'PRC_SLT_TYPE');
			var evStatus = grid.getCellValue(rowId,'EV_STATUS');

			if ( progressCd < '2800' && progressCd !== '1400') {
				return  EVF.alert("${BD0340_003}");	//진행상태가 입찰마감인 건은 개찰 진행 후 입찰비교를 하시기 바랍니다.
			}

			if(prcSltType === 'NGO' && evStatus !== '300'){
				return EVF.alert("${BD0340_009}");	//평가완료 후 입찰비교가 가능합니다.
			}

			var screenId = '';
			if(prcSltType === 'NGO'){
				screenId = 'BD0340P05';
			} else if (vendorSltType === 'DOC') {
				screenId = 'BD0340P01';
			} else {
				screenId = 'BD0340P02';
			}

			var width = screenId === 'BD0340P05' ? '1650' : '1300';

	        var param = {
        		  BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
        		, RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
                , RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
			    , appDocNum  : grid.getCellValue(rowId,'APP_DOC_NUM2')
			    , appDocCnt  : grid.getCellValue(rowId,'APP_DOC_CNT2')
        		, detailView : false
		    };
		    everPopup.openPopupByScreenId(screenId, width, 800, param);
		}

		//조회조건 협력업체 검색
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

	</script>

	<e:window id="BD0340" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<%--FROM--%>
				<e:label for="DATE_FROM">
					<e:select id="TYPE" name="TYPE" value="RFX_TO_DATE" options="${typeOptions}" width="${form_TYPE_W}" disabled="${form_TYPE_D}" readOnly="${form_TYPE_RO}" required="${form_TYPE_R}" placeHolder="" usePlaceHolder="flase">
						<e:option text="${BD0340_REG_DATE}" value="REG_DATE">${BD0340_REG_DATE}</e:option>
						<e:option text="${BD0340_RFX_TO_DATE}" value="RFX_TO_DATE">${BD0340_RFX_TO_DATE}</e:option>
						<e:option text="${BD0340_RFX_FROM_DATE}" value="RFX_FROM_DATE">${BD0340_RFX_FROM_DATE}</e:option>
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="DATE_FROM" name="DATE_FROM" toDate="DATE_TO" value="${addFromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="DATE_TO" name="DATE_TO" fromDate="DATE_FROM" value="${addToDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" />
				</e:field>
				<%--구매요청회사--%>
				<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}"/>
				<e:field>
					<e:search id="PR_BUYER_CD" name="PR_BUYER_CD" width="40%" value=""  maxLength="${form_PR_BUYER_CD_M}" onIconClick="${form_PR_BUYER_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" />
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" width="60%" value=""  maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--사업장 코드/명--%>
				<e:label for="PR_PLANT_CD" title="${form_PR_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PR_PLANT_CD" name="PR_PLANT_CD" width="40%" value=""  maxLength="${form_PR_PLANT_CD_M}" onIconClick="${form_PR_PLANT_CD_RO ? 'everCommon.blank' : 'selectPlant'}" disabled="${form_PR_PLANT_CD_D}" readOnly="${form_PR_PLANT_CD_RO}" required="${form_PR_PLANT_CD_R}" />

					<e:inputText id="PR_PLANT_NM" name="PR_PLANT_NM" width="60%" value=""  maxLength="${form_PR_PLANT_NM_M}" disabled="${form_PR_PLANT_NM_D}" readOnly="${form_PR_PLANT_NM_RO}" required="${form_PR_PLANT_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--요청번호/명--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="40%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />

					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--협력업체--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" width="40%" value=""  maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'selectVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" width="60%" value="" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserNmOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false" />
				</e:field>
				<%--구매유형--%>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />

			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doQtOpen" name="doQtOpen" label="${doQtOpen_N}" onClick="doQtOpen" disabled="${doQtOpen_D}" visible="${doQtOpen_V}"/>
			<e:button id="doReqEval" name="doReqEval" label="${doReqEval_N}" onClick="doReqEval" disabled="${doReqEval_D}" visible="${doReqEval_V}"/>
			<e:button id="doCompareBq" name="doCompareBq" label="${doCompareBq_N}" onClick="doCompareBq" disabled="${doCompareBq_D}" visible="${doCompareBq_V}"/>
		</e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

        <e:title title="품목정보" />
		<e:gridPanel id="gridT" name="gridT" width="100%" height="250px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}" />

	</e:window>
</e:ui>