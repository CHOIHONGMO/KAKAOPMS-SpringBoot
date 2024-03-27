<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var gridL;
		var gridDEL;
		var gridR;
		var baseUrl      = "/evermp/buyer/bd";
		var rowData      = [];
		var prBuyerVal   = "";
		var prBuyerNmVal = "";
		var prPlantVal   = "";
		var prPlantNmVal = "";
		var flagCount    = 0;
		function init(){

			// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
			if('${param.detailView}' == 'true') {
				if('${ses.userType}' == 'C') {
					$('#upload-button-ATT_FILE_NUM_IN').css('display','none');
				}
				$('#upload-button-ATT_FILE_NUM').css('display','none');
			}

			if('${formData.GW_FLAG}'=='Y'){
				$("#doSend").children('div').find(".e-button-text").text('입찰신청 미리보기')
			}else if('${param.detailView}' == 'true' && '${formData.GW_FLAG}'=='N'){
				$("#doSend").hide();
			}

			$('#form').css('margin-top','-25px');
			$('.e-buttonbar').css('z-Index',1);
			EVF.C('PRC_SLT_TYPE').removeOption('NON');
			EVF.C('CTRL_USER_NM').setReadOnly(true);
			EVF.C('VENDOR_OPEN_TYPE').removeOption('QN');

			gridDEL = EVF.C("gridDEL");
			$("#panel_hide").hide();

			gridL = EVF.getComponent("gridL");
			gridL.setProperty("shrinkToFit"    , ${shrinkToFit});     // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			gridL.setProperty("rowNumbers"     , ${rowNumbers});      // 로우의 번호 표시 여부를 지정한다. [true/false]
			gridL.setProperty("sortable"       , ${sortable});        // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			gridL.setProperty("panelVisible"   , ${panelVisible});    // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			gridL.setProperty("enterToNextRow" , ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			gridL.setProperty("acceptZero"     , ${acceptZero});      // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			gridL.setProperty("multiSelect"    , ${multiSelect});     // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			//gridL.hideCol('PR_NUM'  , true);
			//gridL.hideCol('PR_SQ'   , true);
			gridL.hideCol('DEPT_NM' , true);

			/* gridL.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			}); */

			gridL.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){

				if( colIdx == "CUST_ITEM_CD"
	           	     || colIdx == "ITEM_DESC"
	           	     || colIdx == "ITEM_SPEC"
	           	     || colIdx == "MAKER_CD"
					 || colIdx == "MAKER_PART_NO"
	           		 || colIdx == "BRAND_NM"
	           	     || colIdx == "ORIGIN_CD"
	           	     || colIdx == "UNIT_CD"
				) {
					if (gridL.getCellValue(rowIdx, "ITEM_CD")!='') {
						gridL.setCellValue(rowIdx, colIdx, oldValue);
						return alert("${BD0310_0027}");
					}
				}
				if(colIdx === 'RFX_QT' || colIdx === 'UNIT_PRC'){
					itemAmtSum(rowIdx);
				}
				if(colIdx === 'PR_BUYER_CD'){
					gridL.setCellValue(rowIdx, 'CTRL_NM', '');
					gridL.setCellValue(rowIdx, 'CTRL_CD', '');
				}
				if(colIdx === 'VALID_FROM_DATE' ){
					allChangeGrid('VALID_FROM_DATE',newValue);
				}
				if(colIdx === 'DEAL_CD') {
					allChangeGrid('DEAL_CD',newValue);
				}
				if(colIdx === 'VALID_TO_DATE') {
					allChangeGrid('VALID_TO_DATE',newValue);
				}
				if(colIdx === 'DELY_DATE') {
					allChangeGrid('DELY_DATE',newValue);
				}
				showTotalSum();
			});


			gridL.cellClickEvent(function(rowIdx, colIdx, value, iRow, iCol){
				if(colIdx === 'VENDOR_CNT' && value !== '' && value !== '0') {
					doSearchVendorByItem(rowIdx);
				}else if(colIdx === 'VENDOR_SEL'){

					selectVendor_grid(rowIdx,'doSelectVendor');

				}else if(colIdx === 'ATT_FILE_CNT'){
					var param = {
						detailView       : true,
						havePermission   : true,
						attFileNum       : gridL.getCellValue(rowIdx, "ATT_FILE_NUM"),
						rowId            : rowIdx,
						callBackFunction : "callback_setAttFile",
						bizType          : "RQ",
						fileExtension    : "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'RMK'){
					var param = {
						  rowId			   : rowIdx
						, havePermission   : false
						, screenName	   : '비고'
						, callBackFunction : "callback_set_gridL_RMK"
						, TEXT_CONTENTS    : gridL.getCellValue(rowIdx, "RMK")
						, detailView       : "${param.detailView}"
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}else if(colIdx === 'PR_NUM' && value !== ''){
					if(value !== ""){
						param = {
							CPO_NO: gridL.getCellValue(rowIdx, "PR_NUM")
						};
						everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
					}
				}else if(colIdx === 'CTRL_NM'){
					if(gridL.getCellValue(rowIdx, 'PR_BUYER_CD') === '') {
						return EVF.alert('${BD0310_0024}');
					}
					param = {
						callBackFunction: "callback_setCTRL",
						BUYER_CD : gridL.getCellValue(rowIdx, "PR_BUYER_CD"),
						rowId    : rowIdx
					};
					everPopup.openCommonPopup(param, "SP0031");
				}else if(colIdx === 'PLANT_NM'){
					param = {
						  rowId            : rowIdx
						, PR_BUYER_CD      : gridL.getCellValue(rowIdx, "PR_BUYER_CD")
						, callBackFunction : 'callback_setPlant'
					}
					everPopup.openCommonPopup(param, 'SP0500');
				}else if(colIdx === 'WH_NM'){
					if(gridL.getCellValue(rowIdx, 'PLANT_NM') === '') {
						return EVF.alert('${RQ0310_0020}');
					}
					param = {
						rowId 			 : rowIdx,
						PLANT_CD         : gridL.getCellValue(rowIdx,"PLANT_CD"),
						PLANT_NM         : gridL.getCellValue(rowIdx,"PLANT_NM"),
						BUYER_CD         : gridL.getCellValue(rowIdx,"LOC_BUYER_CD"),
						callBackFunction : "callback_setWH"
					};
					everPopup.openCommonPopup(param, "SP0501");
				}else if(colIdx === 'MAKER_NM') {
					if('${param.detailView}' == 'true') return;
					var param = {
	                        rowId: rowIdx,
	                        callBackFunction: 'setMakerG'
	                    };
	                everPopup.openCommonPopup(param, 'SP0068');
				}
			});

			//매뉴얼 최초작성일때만.
			if(opener==null){

				gridL.addRowEvent(function() {
					<%-- 고객사를 먼저 선택해주세요 --%>
					if(EVF.V('PR_BUYER_CD') === '') {
						return EVF.alert('${BD0310_0024}');
					}
					<%-- 사업장을 먼저 선택해주세요 --%>
					if(EVF.V('PR_PLANT_CD') === '') {
						return EVF.alert('${BD0310_0029}');
					}
					var vendorList = null;
					var vendorCnt  = 0;

					if(gridR!=undefined){
						if(gridR.getRowCount()>0){
							 vendorList = JSON.stringify(gridR.getSelRowValue());
							 vendorCnt  = gridR.getRowCount();
						}
					}

					let addParam={
						 "PR_BUYER_CD" : EVF.V("PR_BUYER_CD")
					   , "PR_BUYER_NM" : EVF.V("PR_BUYER_NM")
					   , "PR_PLANT_CD" : EVF.V("PR_PLANT_CD")
					   , "PR_PLANT_NM" : EVF.V("PR_PLANT_NM")
					   , "VENDOR_JSON" : vendorList
					   , "VENDOR_CNT"  : vendorCnt
		  			}
					gridL.addRow(addParam);
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "ITEM_DESC", false);
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "ITEM_SPEC", false);
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "MAKER_PART_NO", false);
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "MAKER_NM", false);
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "BRAND_NM", false);
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "ORIGIN_CD", false);
					gridL.setCellValue(gridL.getAllRowId().length-1, "ORIGIN_CD", 'KR');
					gridL.setCellReadOnly(gridL.getAllRowId().length-1, "UNIT_CD", false);
					gridL.setCellValue(gridL.getAllRowId().length-1, "UNIT_CD", 'EA');
				});
			}

			if('${param.baseDataType}' !== 'RERFX' && '${param.baseDataType}' !== 'PR'){
				gridL.excelImportEvent({
					'append': false
				}, function (msg, code) {
					console.log('check');
					if (code) {
						gridL.checkAll(true);

						var store = new EVF.Store();
						store.setGrid([gridL]);
						$.each(gridL.getAllRowValue(),function(index, item){
 							gridL.setCellValue(index, 'PR_BUYER_CD', EVF.V('PR_BUYER_CD'), true)
 							gridL.setCellValue(index, 'PR_PLANT_CD', EVF.V('PR_PLANT_CD'), true)
 						});
						store.getGridData(gridL, 'all');
						store.load('/evermp/buyer/rq/RQ0310/doSetExcelImportItemRfx', function () {

						});
					}
				});
			}

			gridR = EVF.getComponent("gridR");
			gridR.setProperty("shrinkToFit"    , ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			gridR.setProperty("rowNumbers"     , ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			gridR.setProperty("sortable"       , ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			gridR.setProperty("panelVisible"   , ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			gridR.setProperty("enterToNextRow" , ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			gridR.setProperty("acceptZero"     , ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			gridR.setProperty("multiSelect"    , true);        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			gridR.delRowEvent(function () {
				if(gridR.getSelRowCount() === 0) { return EVF.alert("${msg.M0004}"); }

				if(!confirm('${BD0310_0025}')) return;

				var vendorList = null;
				var vendorCnt  = 0;

				for(var i = gridR.getRowCount() - 1; i >= 0; i--) {
					if(gridR.isChecked(i)) {
						gridR.delRow(i);
					}
				}

				if(gridR!=undefined){
					if(gridR.getRowCount()>0){
						 vendorList = JSON.stringify(gridR.getAllRowValue());
						 vendorCnt  = gridR.getRowCount();
					}
				}
				for(var i=0; i<gridL.getRowCount(); i++){
					gridL.setCellValue(i,"VENDOR_JSON" , vendorList);
					gridL.setCellValue(i,"VENDOR_CNT"  , vendorCnt);
				}

			});

			gridR.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${screenName }"
			});

			if("${ses.userType}" === 'S'){
				//gridL.hideCol('VENDOR_S',true);
				gridL.hideCol('UNIT_PRC'   , true);
				gridL.hideCol('RFX_AMT'    , true);
				gridL.hideCol('VENDOR_SEL' , true);
			}

			if('${param.detailView}' === 'true'){
				gridL.hideCol('VENDOR_SEL' , true);
			}


			/*재견적인 경우 readOnly 설정*/
			if('${param.baseDataType}' === 'RERFX'){
				formUtil.setVisible(['doDownloadExcel']	, false);
				formUtil.setVisible(['doSelectItem']	, false);
				formUtil.setVisible(['doDeleteItem']	, false);
				//formUtil.setVisible(['doSave']		, false);
				//formUtil.setVisible(['doDelete']		, false);
				formUtil.setVisible(['doSelectVendor']	, false);		// 협력업체선택
				formUtil.setVisible(['doSelectFavorVendor']	, false);	// 관심업체선택
				formUtil.setVisible('doApply'			, false);

				gridL.setColReadOnly('UNIT_CD'  , true);
				gridL.setColReadOnly('RFX_QT'   , true);
				gridL.setColReadOnly('UNIT_PRC' , true);

				EVF.C('VENDOR_OPEN_TYPE').setReadOnly(true);
				EVF.C('VENDOR_SLT_TYPE').setReadOnly(true);
				EVF.C('PRC_SLT_TYPE').setReadOnly(true);

				if(EVF.V('VENDOR_SLT_TYPE') === 'DOC'){
					gridL.hideCol('VENDOR_SEL',true);
				}
			}

			if(EVF.V('RFX_CNT') > '1'){
				<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C'}">
					formUtil.setVisible(['doDownloadExcel'] , false);
					formUtil.setVisible(['doSelectItem']    , false);
					formUtil.setVisible(['doDeleteItem']	, false);
				</c:if>
			}

			/*gridL.setColGroup([{
				"groupName": '협력업체',
				"columns": [ "VENDOR_CNT", "VENDOR_SEL" ]
			}],50);*/

			if(EVF.V('VENDOR_SLT_TYPE') === 'DOC'){
				gridL.hideCol('VENDOR_SEL',true);
			}

			$('#VENDOR_SLT_TYPE').change(function(){
				if(EVF.V('VENDOR_SLT_TYPE') === 'DOC'){
					gridL.hideCol('VENDOR_SEL',true);
				}else{
					gridL.hideCol('VENDOR_SEL',false);
				}
			});


			if('${param.baseDataType}' !== 'PR'){
				doSearch();
			}else {

				//PR에서 넘어올 때
				EVF.C('CTRL_USER_NM').setReadOnly(true);
				EVF.C('CTRL_USER_NM').setDisabled(true);
				EVF.C('PR_BUYER_NM').setDisabled(true);
				EVF.C('PR_PLANT_NM').setDisabled(true);
				EVF.C('doDeleteItem').setVisible(false);
				EVF.C('doSelectItem').setVisible(false);
// 				EVF.C('CTRL_USER_DEPT').setReadOnly(true);
// 				EVF.C('CTRL_USER_DEPT').setDisabled(true);

				gridL.hideCol('PR_NUM'  , false);
				gridL.hideCol('PR_SQ'   , false);
				gridL.hideCol('DEPT_NM' , false);

				gridL.setColReadOnly('UNIT_CD'    , true);
				gridL.setColReadOnly('RFX_QT'     , true);
				gridL.setColReadOnly('PR_BUYER_CD', true);
				gridL.setColReadOnly('PLANT_NM'   , true);

				<c:forEach items="${prList}" var="C" varStatus="status">

					var addParam = {
						  ITEM_CD 		: "${C.ITEM_CD}"
						, ITEM_DESC 	: "${C.ITEM_DESC}"
						, ITEM_SPEC 	: "${C.ITEM_SPEC}"
						, CS_COLOR 		: "${C.CS_COLOR}"
						, UNIT_CD 		: "${C.UNIT_CD}"
						, RFX_QT 		: "${C.CPO_QTY}"
						, UNIT_PRC 		: "${C.CPO_UNIT_PRICE}"
						, RFX_AMT 		: "${C.CPO_QTY}"*"${C.CPO_UNIT_PRICE}"
						, DELY_PLACE_NM : "${C.DELY_PLACE_NM}"
						, DELY_DATE 	: "${C.DELY_DATE}"
						, PR_NUM 		: "${C.CPO_NO}"
						, PR_SQ 		: "${C.CPO_SEQ}"
						, DEPT_NM 		: "${C.DEPT_NM}"
						, PR_BUYER_CD 	: "${C.CUST_CD}"
						, PR_PLANT_CD 	:"${C.PLANT_CD}"
						, BUYER_CD 		: "${ses.companyCd}"
					    , CTRL_CD 		: "${C.CTRL_CD}"
						, CTRL_NM 		: "${C.CTRL_NM}"
						, MAKER_NM 		: "${C.MAKER_NM}"
						, MAKER_CD 		: "${C.MAKER_CD}"
						, MAKER_PART_NO : "${C.MAKER_PART_NO}"
						, DEAL_CD 	 	: "${C.DEAL_CD}"
						, DELY_DATE 	: "${C.HOPE_DUE_DATE}"
						, ORIGIN_CD     : "${C.ORIGIN_CD}"
// 						, PLANT_CD 		: "${C.PLANT_CD}"
// 						, PLANT_NM 		: "${C.PLANT_NM}"
// 						, LOC_BUYER_CD  : "${C.LOC_BUYER_CD}"
// 						, WH_CD 		: "${C.WH_CD}"
// 						, WH_NM 		: "${C.WH_NM}"
					}
					gridL.addRow(addParam);
					gridL.setCellReadOnly('${status.index}','DEAL_CD' 	  , true);

				</c:forEach>
				showTotalSum();
			}

			$('#PRC_SLT_TYPE').change(function(){
				if($(this).val()==='PRI'){
					$('#PRC_PERCENT').val('100');
					$('#PRC_PERCENT').attr('readOnly', true);
					$('#NPRC_PERCENT').val('0');
					$('#NPRC_PERCENT').attr('readOnly', true);

					EVF.V('VENDOR_SLT_TYPE','');
					EVF.C('VENDOR_SLT_TYPE').setReadOnly(false);
				}else{
					$('#PRC_PERCENT').val('');
					$('#PRC_PERCENT').removeAttr('readOnly');
					$('#NPRC_PERCENT').val('');
					$('#NPRC_PERCENT').removeAttr('readOnly');

					EVF.V('VENDOR_SLT_TYPE','DOC');
					EVF.C('VENDOR_SLT_TYPE').setReadOnly(true);
				}
			});

			$('#PRC_PERCENT').change(function(){
				let restPercent = Number($('#PRC_PERCENT').val());
				let deci = decimalFits(restPercent);
				$('#NPRC_PERCENT').val((100-$('#PRC_PERCENT').val()).toFixed(deci));
			});

			if("${param.detailView}"==='false' && $('#ANN_FLAG').val()==='1'){
				ANN_YorN(1);
			}

			$('#ANN_FLAG').change(function(){
				if($(this).val()==='1'){
					ANN_YorN(1);
				}else{
					ANN_YorN(0);
				}
			});
		}
		
		//일괄적용 그리드 적용
		function allChangeGrid(colName,newValue){
			EVF.confirm('일괄적용하시겠습니까?',function(){
    			for(k=0;k<gridL.getRowCount();k++) {
    	            gridL.setCellValue(k,colName,newValue);
    			}
    		});
		}
		
		function setMakerG(data) {
            gridL.setCellValue(data.rowId, 'MAKER_CD', data.MKBR_CD);
            gridL.setCellValue(data.rowId, 'MAKER_NM', data.MKBR_NM);
        }

		function callback_setPlant(data){
			gridL.setCellValue(data.rowId , "PLANT_NM"     , data.PLANT_NM);
			gridL.setCellValue(data.rowId , "PLANT_CD"     , data.PLANT_CD);
			gridL.setCellValue(data.rowId , "LOC_BUYER_CD" , data.BUYER_CD);
			gridL.setCellValue(data.rowId , 'WH_NM'        ,'');
			gridL.setCellValue(data.rowId , 'WH_CD'        ,'');
			setSubject();
		}

		function callback_setCTRL(data) {
			gridL.setCellValue(data.rowId , "CTRL_CD" , data.CODE);
			gridL.setCellValue(data.rowId , "CTRL_NM" , data.CODE_DESC);
			setSubject();
		}

		function callback_setWH(data){
			gridL.setCellValue(data.rowId , "WH_CD" , data.WH_CD);
			gridL.setCellValue(data.rowId , "WH_NM" , data.WH_NM);
		}

		function ANN_YorN(data){
			var disable = true;
			var req = false;
			if(data===1){
				disable = false;
				req = true;
			}

			$(':input').each(function(k, v){
				var vid = v.id;
				if(vid.indexOf('ANN_') !== -1 && vid !== 'ANN_FLAG' && vid.indexOf('ui-multiselect') === -1){
					EVF.C(vid).setDisabled(disable);
					EVF.C(vid).setReadOnly(disable);
					if(vid !== 'ANN_RMK'){
						EVF.C(vid).setRequired(req);
					}
				}
			});
		}

		function doSearch(){
			var store = new EVF.Store();
			store.setGrid([gridL]);
			store.setAsync(false);
			store.load(baseUrl + "/BD0310/doSearch", function(){
				gridL.checkAll(true);

				//구매요청접수에서 넘어와서 PR번호가 있을 때
				if(gridL.getRowCount() > 0){
					var prNum = gridL.getAllRowValue()[0].PR_NUM;
					if(prNum !== null && prNum !== ''){
						<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C'}">
							formUtil.setVisible(['doSelectItem'], false);
							formUtil.setVisible(['doDeleteItem'], false);
						</c:if>

						EVF.C('CTRL_USER_NM').setReadOnly(true);
						EVF.C('CTRL_USER_NM').setDisabled(true);

						gridL.setColReadOnly('PR_BUYER_CD' , true);
						gridL.setColReadOnly('RFX_QT'      , true);
						gridL.hideCol('PR_NUM'  , false);
						gridL.hideCol('PR_SQ'   , false);
						gridL.hideCol('DEPT_NM' , false);
					}
				}
				
				//배송유형 저장된것 수정 페이지 띄울때 그리드 STOPRDT 배송유형 선택
				<c:if test="${formData.updatePg == 'true'}">
					EVF.V("DELY_TYPE",gridL.getAllRowValue()[0].DELY_TYPE)
					EVF.V("PR_PLANT_NM",gridL.getAllRowValue()[0].PR_PLANT_NM)
					EVF.V("PR_PLANT_CD",gridL.getAllRowValue()[0].PR_PLANT_CD)
					EVF.V("PR_BUYER_NM",gridL.getAllRowValue()[0].PR_BUYER_NM)
					EVF.V("PR_BUYER_CD",gridL.getAllRowValue()[0].PR_BUYER_CD)
					EVF.V("RFX_AMT",gridL.getAllRowValue()[0].RFX_AMT)
					EVF.C('PR_BUYER_NM').setDisabled(true);
					EVF.C('PR_PLANT_NM').setDisabled(true);
				</c:if>
				
				if(gridL.getRowCount() > 0 && gridL.getAllRowValue()[0].VENDOR_CNT > 0){
					doSearchVendorByItem(0);
				}
			})
			showTotalSum();
		}

		function itemAmtSum(rowId){

			var amt = 0;
			var qt  = Number(gridL.getCellValue(rowId, "RFX_QT"));
			var unitPrc = Number(gridL.getCellValue(rowId, "UNIT_PRC"));

			var primNum = decimalFits(qt) + decimalFits(unitPrc);
			if(primNum > 0) {
				amt = parseFloat(qt * unitPrc).toFixed(primNum);
			} else {
				amt = qt * unitPrc;
			}

			gridL.setCellValue(rowId, 'RFX_AMT', amt);
		}

		Number.isInteger = Number.isInteger || function(value) {
			return typeof value === "number" &&
				isFinite(value) &&
				Math.floor(value) === value;
		};

		function decimalFits(n){
			var decimalN = 0;
			if(!Number.isInteger(n)){ //소수
				var d = String(n).split('.')[1].length;
				if(decimalN < d)decimalN = d;
			}
			return decimalN;
		}

		function showTotalSum(){
			var totalSum = 0;
			var gridSelected = gridL.getAllRowValue();
			for(var i in gridSelected){
				var eachSum = gridSelected[i].RFX_AMT;
				totalSum += eachSum;
			}
			EVF.V('RFX_AMT', totalSum);
		}

		function selectCtrlUser(){
			var param = {
					custCd           : "${formData.BUYER_CD}",
					callBackFunction : "callBack_selectCtrlUser",
				};
			everPopup.openCommonPopup(param, "SP0040");
		}

		function callBack_selectCtrlUser(data){
			console.log(data)
			EVF.V('CTRL_USER_NM', data.USER_NM);
			EVF.V('CTRL_USER_ID', data.USER_ID);
		}

		function callback_setAttFile(rowId, fileId, fileCount) {
			gridL.setCellValue(rowId , "ATT_FILE_CNT" , fileCount);
			gridL.setCellValue(rowId , "ATT_FILE_NUM" , fileId);
		}

		function callback_set_gridL_RMK(context, rowId){
			gridL.setCellValue(rowId , 'RMK' , context);
		}

		function doSearchVendorByItem(rowIdx){
			gridR.delAllRow();
			var vendorList = JSON.parse(gridL.getCellValue(rowIdx, 'VENDOR_JSON'));
			for(var i in vendorList){
				var param = {
					 ITEM_CD 		: gridL.getCellValue(rowIdx, 'ITEM_CD')
					,ITEM_DESC 		: gridL.getCellValue(rowIdx, 'ITEM_DESC')
					,VENDOR_CD 		: vendorList[i].VENDOR_CD
					,VENDOR_NM 		: vendorList[i].VENDOR_NM
					,CEO_NM 		: vendorList[i].CEO_USER_NM
					,IRS_NUM 		: vendorList[i].IRS_NO
					,USER_NM 		: vendorList[i].USER_NM
					,CELL_NUM 		: vendorList[i].CELL_NUM
					,EMAIL 			: vendorList[i].EMAIL
					,MAKER_NM 		: vendorList[i].MAKER_NM
					,BUSINESS_TYPE 	: vendorList[i].BUSINESS_TYPE
					,INDUSTRY_TYPE 	: vendorList[i].INDUSTRY_TYPE
					,MAJOR_ITEM_NM  : vendorList[i].MAJOR_ITEM_NM
					,SG_TXT     	: vendorList[i].SG_TXT
					,SG_NUM      	: vendorList[i].SG_NUM
					,USER_ID      	: vendorList[i].USER_ID
				}
				gridR.addRow(param);
			}
		}

		//저장
		function doSave(){

			var store = new EVF.Store();
			if(!store.validate()) {	return;	}
			var signStatus = this.data;

			EVF.V('SIGN_STATUS', signStatus);
			if(!validationCheck()){
				return;
			}

			var message = signStatus === 'T' ? '${msg.M0021}' : '${msg.M0060}' ;
			EVF.confirm(message, function(){
				goSaveRQ();
			})
		}

		function validationCheck(){
			let prcPercent  = EVF.V('PRC_PERCENT');
			let nprcPercent = EVF.V('NPRC_PERCENT');

			if(prcPercent + nprcPercent !== 100){
				return EVF.alert('${BD0310_0019}');
			}

			// 입찰 시작 및 종료일자 체크
			if(!checkTimeToServer(EVF.V("RFX_TO_DATE"), EVF.V("RFX_TO_HOUR"), EVF.V("RFX_TO_MIN"))) return;

			// 현장설명회 일시 체크
			if(EVF.V('baseDataType') !== 'RERFX'){
				if(EVF.V('ANN_FLAG')==='1' && !checkAnnTime()) return;
			}

			if (gridL.getRowCount()===0) {return alert("${BD0310_0006}");}
			if (!gridL.validate().flag) { return EVF.alert(gridL.validate().msg); }

			var vendorCdList = [];
			var vendorJson;
			if(gridL.getCellValue(0,'VENDOR_JSON') != null && gridL.getCellValue(0,'VENDOR_JSON') !== ''){
				vendorJson = JSON.parse(gridL.getCellValue(0,'VENDOR_JSON'));
				for(var i in vendorJson){
					vendorCdList.push(vendorJson[i].VENDOR_CD);
				}
			}

			var allgrid = gridL.getAllRowValue();
			for(var i in  allgrid){
				//if(allgrid[i].VENDOR_JSON === "[]" || allgrid[i].VENDOR_JSON === "" || allgrid[i].VENDOR_CNT === "0"){return alert('${BD0310_0007}');}	//협력업체를 선택해주세요.

				//총액별인 경우 선택된 협력업체가 모두 같아야 함.
				if(EVF.V('VENDOR_SLT_TYPE') === 'DOC' &&  allgrid[i].VENDOR_JSON !== null && allgrid[i].VENDOR_JSON !== ''){
					var eachVendorCdList = [];
					vendorJson = JSON.parse(allgrid[i].VENDOR_JSON);
					for(var j in vendorJson){
						eachVendorCdList.push(vendorJson[j].VENDOR_CD);
					}

					if(JSON.stringify(vendorCdList) !== JSON.stringify(eachVendorCdList)){
						return EVF.alert('${BD0310_0009}');
					}
				}

				//지명방식이 수의계약인 경우 선택된 협력업체가 한 업체여야 함.
				if(EVF.V('VENDOR_OPEN_TYPE') === 'QN' && allgrid[i].VENDOR_CNT > '1'){
					return EVF.alert('${BD0310_0010}');
				} else if(EVF.V('VENDOR_OPEN_TYPE') === 'QN' && (allgrid[i].VENDOR_CNT === '' || allgrid[i].VENDOR_CNT === '0')){
					return EVF.alert('${BD0310_0007}');
				}

				if(EVF.V('baseDataType') !== 'RERFX'){

					//지명방식이 지명경쟁인 경우 협력업체지정이 필수이며, 2개 이상의 협력업체를 지정해야 함.
					if(EVF.V('VENDOR_OPEN_TYPE') === 'AB' && (allgrid[i].VENDOR_CNT === '' || allgrid[i].VENDOR_CNT < '2')){
						return EVF.alert('${BD0310_0020}');
					}

					//지명방식이 공개경쟁인 경우 협력업체가 지정되어 있으면 안됨.
					if(EVF.V('VENDOR_OPEN_TYPE') === 'OB' && allgrid[i].VENDOR_CNT !=='' && allgrid[i].VENDOR_CNT !=='0'){
						return EVF.alert('${BD0310_0023}');
					}
				}
			}
			return true ;
		}

		//결재상신
		function doSign(){

			if(!checkTimeToServer(EVF.V("RFX_TO_DATE"), EVF.V("RFX_TO_HOUR"), EVF.V("RFX_TO_MIN"))) return;

			var store = new EVF.Store();
			if(!store.validate()) return;
			if(!gridL.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
			if(!gridL.validate().flag) { return EVF.alert(gridL.validate().msg); }

			if (!confirm("${msg.M0100}")) return;

			EVF.V("SIGN_STATUS", "P");

			param = {
				subject          : EVF.V("RFX_SUBJECT"),
				docType          : "RFP",
				signStatus       : "P",
				screenId         : "BD0310",
				approvalType     : 'APPROVAL',
				oldApprovalFlag  : EVF.V("SIGN_STATUS"),
				attFileNum       : "",
				docNum           : EVF.V("RFX_NUM"),
				appDocNum        : EVF.V("APP_DOC_NUM"),
				callBackFunction : "goSaveRQ"
			};
			everPopup.openApprovalRequestIIPopup(param);
		}

		function goSaveRQ(formData, gridData, attachData){

			EVF.V("approvalFormData" , formData);
			EVF.V("approvalGridData" , gridData);
			//EVF.V("attachFileDatas", attachData);

			gridL.checkAll(true);
			var store = new EVF.Store();
			store.doFileUpload(function() {
				store.setGrid([gridL, gridDEL]);
				store.getGridData(gridL   , 'all');
				store.getGridData(gridDEL , 'all');
				store.load(baseUrl + "/BD0310/doSave", function(){
					//디폴트저장
					alert(this.getResponseMessage());
					var rfxNum = this.getParameter('rfxNum');
	                var rfxCnt = this.getParameter('rfxCnt');

					if('${param.popupFlag}' === 'true'){
						if('${param.baseDataType}' =='RERFX'){
							doClose2();
						}else{
							opener.doSearch();
							location.href = baseUrl + "/BD0310/view.so?RFX_NUM=" + rfxNum+'&RFX_CNT='+rfxCnt+'&popupFlag=true';
							localStorage.removeItem('flag');
						}
					}else{
						location.href=baseUrl+'/BD0310/view';
					}
				});
			});
		}

		function checkTimeToServer(date, time, min) {

			//시작날짜가 오늘 날짜와 지금 시각보다 커야 함.
			if (!EVF.isEmpty(EVF.V("RFX_FROM_DATE")) && !EVF.isEmpty(EVF.V("RFX_FROM_HOUR"))){
				var now = new Date();
				var month = (now.getMonth()+1) < 10 ? '0' + (now.getMonth()+1).toString() : (now.getMonth()+1).toString();
				var date  = now.getDate()    < 10 ? '0' + now.getDate().toString()   : now.getDate().toString();
				var hour  = now.getHours()   < 10 ? '0' + now.getHours().toString()  : now.getHours().toString();
				var min   = now.getMinutes() < 10 ? '0' + now.getMinutes().toString(): now.getMinutes().toString();
				var validStartDate = now.getFullYear().toString() + month + date + hour + min;
				var curStartDate   = EVF.V('RFX_FROM_DATE') + EVF.V('RFX_FROM_HOUR') + EVF.V('RFX_FROM_MIN');
				if ( curStartDate < validStartDate) {
					alert("${BD0310_0001}");
					return false;
				}
			}

			//견적이 끝나는 날짜가 시작날짜보다 커야 함
			if (!EVF.isEmpty(date) && !EVF.isEmpty(time) && !EVF.isEmpty(min)) {
				let settledfromtime = EVF.V("RFX_FROM_DATE") + EVF.V("RFX_FROM_HOUR") + EVF.V("RFX_FROM_MIN");
				let settledtotime   = EVF.V("RFX_TO_DATE") + EVF.V("RFX_TO_HOUR") + EVF.V("RFX_TO_MIN");
				if (settledfromtime > settledtotime) {
					EVF.alert("${BD0310_0002}");
					return false;
				}
			}

			return true;
		}

		function doSelectItem() {
			prBuyerVal   = "";
			prPlantVal   = "";
			prBuyerNmVal = "";
			prPlantNmVal = "";
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PR_BUYER_CD') === '') {
				return EVF.alert('${BD0310_0024}');
			}
			<%-- 사업장을 먼저 선택해주세요 --%>
			if(EVF.V('PR_PLANT_CD') === '') {
				return EVF.alert('${BD0310_0029}');
			}
			prBuyerVal   = EVF.V("PR_BUYER_CD");
			prPlantVal   = EVF.V("PR_PLANT_CD");
			prBuyerNmVal = EVF.V("PR_BUYER_NM");
			prPlantNmVal = EVF.V("PR_PLANT_NM");
			var param = {
				contractYn		 : 'N',	//유효한 단가계약 존재여부
				PR_BUYER_CD      : EVF.V("PR_BUYER_CD"),
				PR_PLANT_CD      : EVF.V("PR_PLANT_CD"),
				callBackFunction : "callback_doSelectItem",
				multiFlag        : true,
				detailView       : false,
				returnType       :"M",
				popupFlag        : true
			};
			everPopup.openPopupByScreenId("IM02_012", 1200, 800, param);
		}

		function callback_doSelectItem(list){
			var arrData = [];
			var vendorList = null;
			var vendorCnt  = 0;

			if(gridR!=undefined){
				if(gridR.getRowCount()>0){
					 vendorList = JSON.stringify(gridR.getAllRowValue());
					 vendorCnt  = gridR.getRowCount();
				}
			}
			for(idx in list) {
				arrData.push({
					 CUST_ITEM_CD 	 : list[idx].CUST_ITEM_CD
					,ITEM_CD  	 	 : list[idx].ITEM_CD
					,ITEM_DESC	 	 : list[idx].ITEM_DESC
					,ITEM_SPEC	 	 : list[idx].ITEM_SPEC
					,MAKER_CD 	 	 : list[idx].MAKER_CD
					,MAKER_NM 	 	 : list[idx].MAKER_NM
					,MAKER_PART_NO   : list[idx].MAKER_PART_NO
					,ORIGIN_CD       : list[idx].ORIGIN_CD
					,BRAND_NM        : list[idx].BRAND_NM
					,CUR             : "KRW"
					,UNIT_CD  	 	 : list[idx].UNIT_CD
					,UNIT_PRC		 : list[idx].CONT_UNIT_PRICE
					,BUYER_CD 	 	 : '${ses.companyCd}'
					,PR_BUYER_CD     : prBuyerVal
					,PR_BUYER_NM     : prBuyerNmVal
					,PR_PLANT_CD     : prPlantVal
					,PR_PLANT_NM	 : prPlantNmVal
					//,VALID_FROM_DATE : list[idx].VALID_FROM_DATE
					//,VALID_TO_DATE 	 : list[idx].VALID_TO_DATE
				});
            }
			gridL.addRow(arrData);

			for(var i=0; i<gridL.getRowCount(); i++){
				gridL.setCellValue(i,"VENDOR_JSON" , vendorList);
				gridL.setCellValue(i,"VENDOR_CNT"  , vendorCnt);
			}
			setSubject();
		}

		function setSubject(){
			let subject = '[' + gridL.getCellValue('0','PR_BUYER_NM') + ' ' + gridL.getCellValue('0','PR_PLANT_NM') + ' ' + gridL.getCellValue('0','CTRL_NM') + ']' + gridL.getCellValue('0','ITEM_DESC') + ' 外 ' + String(gridL.getRowCount()-1).padStart(4,'0') + '건';
			EVF.V('RFX_SUBJECT', subject);
		}

		// 품목삭제
		function doDeleteItem() {
			if(gridL.getSelRowCount() === 0) { return EVF.alert("${msg.M0004}"); }

			if(!confirm('${BD0310_0005}')) return;

			var param;
			for(var i = gridL.getRowCount() - 1; i >= 0; i--) {
				if(gridL.isChecked(i)) {
					param = [{
						 BUYER_CD : gridL.getCellValue(i, "BUYER_CD")
						,RFX_NUM  : gridL.getCellValue(i, "RFX_NUM")
						,RFX_CNT  : gridL.getCellValue(i, "RFX_CNT")
						,RFX_SQ   : gridL.getCellValue(i, "RFX_SQ")
						,PR_NUM   : gridL.getCellValue(i, "PR_NUM")
						,PR_SQ    : gridL.getCellValue(i, "PR_SQ")
					}];
					gridDEL.addRow(param);
					gridL.delRow(i);
				}
			}
		}

		//일괄적용
		function doApply(){
			if(gridL.getSelRowCount() === 0) { return EVF.alert("${msg.M0004}"); }

			var param = {
				callBackFunction : "selectApply"
				,selected : JSON.stringify(gridL.getSelRowValue()[0], replacer)
			};
			everPopup.openPopupByScreenId('BD0310P01', 800, 600, param);
		}

		function selectApply(data){
			let prBuyerCdFromApply;
			let plantCdFromApply;
			for(var i in data){
				if(data[i][0] === 'PR_BUYER_CD'){
					prBuyerCdFromApply =  data[i][1];
				}
				if(data[i][0] === 'PR_PLANT_CD'){
					plantCdFromApply =  data[i][1];
				}
			}

			var rowIds = gridL.getSelRowId();
			for(var i in rowIds){
				for(var j in data){
					//if(data[j][0] === 'UNIT_PRC' && gridL.getCellValue(rowIds[i], data[j][0]) !== '') continue;
					//if(gridL.getCellValue(rowIds[i], data[j][0]) !== '') continue;
// 					if(data[j][0] === 'PR_BUYER_CD'){
// 						continue;
// 					}
					if(data[j][0] === 'CTRL_NM' || data[j][0] === 'CTRL_CD'){
// 						if(gridL.getCellValue(rowIds[i], 'PR_BUYER_CD') !== prBuyerCdFromApply){
// 							continue;
// 						}
					}
					if(data[j][0] === 'WH_CD' || data[j][0] === 'WH_NM'){
						if(gridL.getCellValue(rowIds[i], 'PLANT_CD') !== plantCdFromApply){
							continue;
						}
					}

					gridL.setCellValue(rowIds[i], data[j][0], data[j][1]);
				}
				itemAmtSum(rowIds[i]);
			}
		}
		function replacer(key, value) {

			if(key === 'VENDOR_JSON') {
				return undefined;
			}else{
				var s = value + "";
				if(s.indexOf("\"") === -1 && s.indexOf("\'") === -1 && s.indexOf("\\") === -1){
					return value;
				}else{
					return s.replaceAll("\\","\\\\").replaceAll("\"" ,"\\\"").replaceAll("\'","");
				}
			}
		}

		//협력사 선택
		function doSelectVendor(){

			selectVendor_grid(null,$(this).attr('id'));
		}

		function selectVendor_grid(rowIdx,id){

			var vendorSltType = EVF.V('VENDOR_SLT_TYPE');
			var vendorOpenType = EVF.V('VENDOR_OPEN_TYPE');
			var scrId= "";

			<%--지명방식을 먼저 선택해 주십시오.--%>
			if(vendorOpenType === ''){
				return alert("${BD0310_0003}");
			}

			<%--업체 선정방식을 먼저 선택해 주십시오.--%>
			if(vendorSltType === ''){
				return alert("${BD0310_0004}");
			}

			<%-- 선택된 행들의 업체코드를 읽어서 JSON 문자열로 만든다. --%>
			rowData = [];
			if(rowIdx !== null){
				rowData.push(rowIdx);
			}else{
				rowData = gridL.getAllRowId();
			}
			if(id == 'doSelectVendor'){
				scrId='RQ01_012'
			}else{
				scrId='RQ01_013'
			}
			var vendorArray   = [];
			var vendorCdArray = [];
			var prBuyerCdSet  = new Set();

			for(var row in rowData){
				<%-- 구매요청회사를 먼저 선택해주세요 --%>
				if(gridL.getCellValue(rowData[row], 'PR_BUYER_CD') === '') {
					return EVF.alert('${BD0310_0024}');
				}

				prBuyerCdSet.add(gridL.getCellValue(rowData[row], 'PR_BUYER_CD'));

				var vendorJson = gridL.getCellValue(rowData[row], 'VENDOR_JSON');
				if(vendorJson === '') continue;

				var vendorJsonParse = JSON.parse(vendorJson);
				var vendorCd;


				for(var k=0; k<vendorJsonParse.length; k++) {
					vendorCd = vendorJsonParse[k].VENDOR_CD;

					if (!arrayContains(vendorCdArray, vendorCd)) {
						var addParam = {
								 "VENDOR_CD"   : vendorCd
								,"VENDOR_NM"   : vendorJsonParse[k].VENDOR_NM
								,"CEO_USER_NM" : vendorJsonParse[k].CEO_USER_NM
								,"IRS_NO"      : vendorJsonParse[k].IRS_NO
								,"USER_NM"     : vendorJsonParse[k].USER_NM
								,"TEL_NUM"     : vendorJsonParse[k].TEL_NUM
								,"CELL_NUM"    : vendorJsonParse[k].CELL_NUM
								,"EMAIL"       : vendorJsonParse[k].EMAIL
								,"USER_ID"     : vendorJsonParse[k].USER_ID
								,"MAKER_NM"    : vendorJsonParse[k].MAKER_NM
						}
						var vendorParam = JSON.stringify(addParam);
						vendorArray.push(vendorParam);
						vendorCdArray.push(vendorCd);
					}
				}
			}
			var prBuyerCd = Array.from(prBuyerCdSet);
			param = {
				  callBackFunction : 'callback_selectVendor'
				, VENDOR_OPEN_TYPE : EVF.V('VENDOR_OPEN_TYPE')
				, vendorArray 	   : '['+vendorArray+']'
				, CUST_CD		   : '${ses.companyCd}'
				, ROW_DATA 		   : JSON.stringify(rowData)
				, MODIFIABILITY    : true
				, VENDOR_TYPE 	   : 'RQ'
				, PR_BUYER_CD 	   : prBuyerCd
			}
			everPopup.openPopupByScreenId(scrId, 1500, 800, param);
		}

		function arrayContains(array, obj){
			var i = array.length;
			while(i-- > 0){
				if(array[i] == obj){
					return true;
				}
			}
			return false;
		}

		function callback_selectVendor(vendors){

			var list  	   = JSON.parse(vendors)
			var addRowList = JSON.parse(vendors)
			var arrData    = [];
			let localRow   = gridR.getAllRowValue();

			if(localRow != undefined){
				for(var ii in localRow){
					for(var xx in list){
						if(localRow[ii].VENDOR_CD == list[xx].VENDOR_CD){
							return alert('${BD0310_0026}');
						}
					}
				}
			}
			if(gridL.getCellValue(0,"VENDOR_JSON")!=null && gridL.getCellValue(0,"VENDOR_JSON") !=""){
				list = [
			 			   ...JSON.parse(gridL.getCellValue(0,"VENDOR_JSON"))
					     , ...list
					   ];
				vendors=JSON.stringify(list);
			}
			for(var i in rowData){
				gridL.setCellValue(rowData[i], 'VENDOR_CNT'  , list.length);
				gridL.setCellValue(rowData[i], 'VENDOR_JSON' , vendors);
			}
			for(idx in addRowList) {
				arrData.push({
					 VENDOR_CD  	: addRowList[idx].VENDOR_CD
					,VENDOR_NM	 	: addRowList[idx].VENDOR_NM
					,MAKER_NM	 	: addRowList[idx].MAKER_NM
					,BUSINESS_TYPE 	: addRowList[idx].BUSINESS_TYPE
					,INDUSTRY_TYPE 	: addRowList[idx].INDUSTRY_TYPE
					,MAJOR_ITEM_NM  : addRowList[idx].MAJOR_ITEM_NM
					,SG_TXT     	: addRowList[idx].SG_TXT
					,SG_NUM      	: addRowList[idx].SG_NUM
 					,USER_NM 		: addRowList[idx].USER_NM
  					,CELL_NUM 		: addRowList[idx].CELL_NUM
 					,EMAIL 			: addRowList[idx].EMAIL
 					,USER_ID 		: addRowList[idx].USER_ID
				});
            }
			gridR.addRow(arrData);
		}

		function doClose2() {
			if(opener != null) {

				<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
					if(opener.doSearch != undefined) {
						opener.doSearch();
					}
				</c:if>

				if('${param.baseDataType}' === 'RERFX'){
					opener.doClose();
				}

				window.close();
			} else {

				<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
					if(parent.doSearch != undefined) {
						parent.doSearch();
					}
				</c:if>

				if('${param.baseDataType}' === 'RERFX'){
					parent.doClose();
				}

				new EVF.ModalWindow().close(null);
			}
		}

		function doClose() {

			if(opener != null) {
				window.close();
			} else {
				new EVF.ModalWindow().close(null);
			}

		}

		function doDelete(){
			var msg = "${msg.M0013}";
			if(EVF.V("PROGRESS_CD") === "2650" && EVF.V("SIGN_STATUS") === "E") {
				msg = "선택하신 입찰건은 '입찰대기'인 상태입니다.\n삭제 후 '주문관리 > 고객사주문접수'에서 다시 진행할 수 있습니다.\n\n선택하신 입찰을 삭제하시겠습니까?";
			}
			
			if (!confirm(msg)) return;

			var store = new EVF.Store();
			store.setGrid([gridL]);
			store.getGridData(gridL,'all');
			store.load(baseUrl + "/BD0310/doDelete", function(){
				alert(this.getResponseMessage());
				doClose2();
			});
		}

		function doDownloadExcel() {
			var attFileNum = '${TEMP_ATT_FILE_NUM}';
            if (attFileNum != '') {
                var param = {
                    havePermission: false,
                    attFileNum: attFileNum,
                    bizType: "BI",
                    fileExtension: '*'
                };
                everPopup.openPopupByScreenId('commonFileAttach', 650, 340, param);
            }
		}

		//입찰설명회 시간 유효성 체크
		function checkAnnTime(){
			var now = new Date();
			var month = (now.getMonth()+1) < 10 ? '0' + (now.getMonth()+1).toString() : (now.getMonth()+1).toString();
			var date  = now.getDate()    < 10 ? '0' + now.getDate().toString()   : now.getDate().toString();
			var hour  = now.getHours()   < 10 ? '0' + now.getHours().toString()  : now.getHours().toString();
			var min   = now.getMinutes() < 10 ? '0' + now.getMinutes().toString(): now.getMinutes().toString();
			var validStartDate = now.getFullYear().toString() + month + date + hour + min;
			var curStartDate   = EVF.V('ANN_DATE') + EVF.V('ANN_FROM_HOUR') + EVF.V('ANN_FROM_MIN');
			if (curStartDate <= validStartDate) {
				EVF.alert('${BD0310_0021}');
				return false;
			}

			var starttime = EVF.V("ANN_FROM_HOUR") + EVF.V("ANN_FROM_MIN");
			var endtime   = EVF.V("ANN_TO_HOUR") + EVF.V("ANN_TO_MIN");
			if (endtime <= starttime){
				EVF.alert('${BD0310_0022}');
				return false;
			}

			return true;
		}

		//고객사 팝업
		function selectBuyer(){
			if(gridL.getRowCount()>0){
				return EVF.alert('${BD0310_0028}');
			}
			var param = {
					 PR_BUYER_CD : EVF.V("PR_BUYER_CD")
					,callBackFunction : 'callback_setBuyer'
				}
				everPopup.openCommonPopup(param, 'SP0902');
		}

		function callback_setBuyer(data){
			EVF.V("PR_BUYER_CD" , data.CUST_CD);
			EVF.V("PR_BUYER_NM" , data.CUST_NM);
		}

		//사업장 팝업
		function selectPlant(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PR_BUYER_CD') === '') {
				return EVF.alert('${BD0310_0024}');
			}
			if(gridL.getRowCount()>0){
				return EVF.alert('${BD0310_0028}');
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

		function openerFn(){
			opener.doSearch();
			doClose();
		}

		function openPopupLogic(){

			if( flagCount== 0 && '${formData.GW_FLAG}'=='N'){
				if(!validationCheck()){
					localStorage.setItem('flag', 'true');
					flagCount++;
					return;
				}
			}
			if(localStorage.getItem('flag') == 'true' && flagCount>0){
				return alert("저장 후 진행 바랍니댜.");
			}

			var store = new EVF.Store();
			if('${param.detailView}' === 'false'){
				if(!store.validate()) return;
				if(!gridL.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
				if(!gridL.validate().flag) { return EVF.alert(gridL.validate().msg); }

			}

			//입찰품의결재신청로직
			let param = {
					'EXEC_NUM' 	   : EVF.V('RFX_NUM'),
					'EXEC_CNT' 	   : EVF.V('RFX_CNT'),
					'SUBJECT' 	   : EVF.V('RFX_SUBJECT'),
					'PROGRESS_CD'  : EVF.V('PROGRESS_CD'),
					'APP_DOC_NUM'  : EVF.V('APP_DOC_NUM'),
					'APP_DOC_CNT'  : EVF.V('APP_DOC_CNT'),
					'SIGN_STATUS'  : EVF.V('SIGN_STATUS'),
					'screenName'   : '입찰시행품의 (CN0130P01)',
					'pageName'     : 'BD',
					'EXEC_GB'      : 'BD'
			}
			everPopup.openPopupByScreenId("CN0130P01", 1150, 900, param);
		}

	</script>

	<e:window id="BD0310" onReady="init" initData="${initData}" title="${fullScreenName}">

		<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${formData.BUYER_CD}" />
		<e:inputHidden id="PR_REQ_TYPE" name="PR_REQ_TYPE" value="01" />
		<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS}" />
		<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD}" />
		<e:inputHidden id="RFX_TYPE" name="RFX_TYPE" value="BID"  />
		<e:inputHidden id="baseDataType" name="baseDataType" value="${param.baseDataType}" />
		<e:inputHidden id="ReBid_OB" name="ReBid_OB" value="${param.ReBid_OB}" />

		<e:inputHidden id='APP_DOC_NUM' name="APP_DOC_NUM" value="${empty param.appDocNum ? formData.APP_DOC_NUM : param.appDocNum}" />
		<e:inputHidden id='APP_DOC_CNT' name="APP_DOC_CNT" value="${formData.APP_DOC_CNT}" />
		<e:inputHidden id="approvalFormData" name="approvalFormData"/>
		<e:inputHidden id="approvalGridData" name="approvalGridData"/>
		<e:inputHidden id="RFX_BF_DAY1" name="RFX_BF_DAY1" value="${formData.RFX_BF_DAY1}" />
		<e:inputHidden id="RFX_BF_HOUR1" name="RFX_BF_HOUR1" value="${formData.RFX_BF_HOUR1}" />
		<e:inputHidden id="RFX_BF_MIN1" name="RFX_BF_MIN1" value="${formData.RFX_BF_MIN1}" />
		<e:inputHidden id="RFX_BF_DAY2" name="RFX_BF_DAY2" value="${formData.RFX_BF_DAY2}" />
		<e:inputHidden id="RFX_BF_HOUR2" name="RFX_BF_HOUR2" value="${formData.RFX_BF_HOUR2}" />
		<e:inputHidden id="RFX_BF_MIN2" name="RFX_BF_MIN2" value="${formData.RFX_BF_MIN2}" />

		<e:inputHidden id="PR_TYPE" name="PR_TYPE" value="${empty formData.PR_TYPE ? 'G' : formData.PR_TYPE}" />

		<e:buttonBar id="buttonBar" align="right">
			<%--
			<c:if test="${(formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C') && (formData.GW_FLAG == 'N' || formData.GW_FLAG == null)}">
			--%>
			<c:if test="${(formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C')}">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data="T"/>
			</c:if>
			<!-- 작성중(T)이거나, 입찰대기(2650)인 경우 삭제 가능 -->
			<%--
			<c:if test="${not empty formData.RFX_NUM && (formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C' || (formData.SIGN_STATUS == 'E' && formData.PROGRESS_CD == '2650')) && (formData.GW_FLAG == 'N' || formData.GW_FLAG == null)}">
			--%>
			<c:if test="${not empty formData.RFX_NUM && (formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C' || (formData.SIGN_STATUS == 'E' && formData.PROGRESS_CD == '2650'))}">
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			</c:if>
			<c:if test="${not empty formData.RFX_NUM && param.baseDataType != 'RERFX' }">
            	<e:button id="doSend" name="doSend" label="${doSend_N}" onClick="openPopupLogic" disabled="${doSend_D}" visible="${doSend_V}" data="sign"/>
			</c:if>
			<c:if test="${param.baseDataType == 'RERFX' }">
				<e:button id="doVendorSend" name="doVendorSend" label="${doVendorSend_N}" onClick="doSave" disabled="${doVendorSend_D}" visible="${doVendorSend_V}" data="E"/>
			</c:if>
			<%--
			<c:if test="${param.popupFlag == true}">
				<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
			</c:if>
			--%>
		</e:buttonBar>

		<e:searchPanel id="form" columnCount="2" labelWidth="180" title="입찰정보" useTitleBar="true">
			<e:row>
				<%--입찰요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${formData.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text>&nbsp;/&nbsp;</e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${formData.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<!-- 고객사/ 사업자명 -->
				<e:label for="PR_BUYER_NM" title="${form_PR_BUYER_NM_N}"/>
				<e:field>
					<e:search id="PR_BUYER_NM" name="PR_BUYER_NM" value="${ formData.PR_BUYER_NM}" width="${form_PR_BUYER_NM_W}" maxLength="${form_PR_BUYER_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
					<e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${ formData.PR_BUYER_CD }" />
					<e:text>&nbsp;/&nbsp;</e:text>
					<e:search id="PR_PLANT_NM" name="PR_PLANT_NM" value="${formData.PR_PLANT_NM}" width="${form_PR_PLANT_NM_W}" maxLength="${form_PR_PLANT_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'selectPlant'}" disabled="${form_PR_PLANT_NM_D}" readOnly="${form_PR_PLANT_NM_RO}" required="${form_PR_PLANT_NM_R}" />
					<e:inputHidden id="PR_PLANT_CD" name="PR_PLANT_CD" value="${formData.PR_PLANT_CD}" />
				</e:field>
			</e:row>
			<e:row>
				<%--입찰요청명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${formData.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${formData.VENDOR_OPEN_TYPE}" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
				<%--가격선정방식--%>
				<e:label for="PRC_SLT_TYPE" title="${form_PRC_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="PRC_SLT_TYPE" name="PRC_SLT_TYPE" value="${formData.PRC_SLT_TYPE}" options="${prcSltTypeOptions}" width="${form_PRC_SLT_TYPE_W}" disabled="${form_PRC_SLT_TYPE_D}" readOnly="${form_PRC_SLT_TYPE_RO}" required="${form_PRC_SLT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--업체선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form_VENDOR_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${formData.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
					<e:text>&nbsp;&nbsp;</e:text>
				</e:field>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}"/>
				<e:field>
					<e:search id="CTRL_USER_NM" name="CTRL_USER_NM" value="${formData.CTRL_USER_NM}" width="${form_CTRL_USER_NM_W}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'selectCtrlUser'}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
					<e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${formData.CTRL_USER_ID}" />
				</e:field>
			</e:row>
			<e:row>
				<%--입찰일시--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field colSpan="3">
					<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" value="${formData.RFX_FROM_DATE}" toDate="RFX_TO_DATE"  width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
					<e:text>&nbsp;&nbsp;</e:text>
					<%--시--%>
					<e:select id="RFX_FROM_HOUR" name="RFX_FROM_HOUR" value="${formData.RFX_FROM_HOUR}" options="${rfxFromHourOptions}" width="${form_RFX_FROM_HOUR_W}" disabled="${form_RFX_FROM_HOUR_D}" readOnly="${form_RFX_FROM_HOUR_RO}" required="${form_RFX_FROM_HOUR_R}" placeHolder="" />
					<e:text>${form_RFX_FROM_HOUR_N}&nbsp;&nbsp;</e:text>
					<%--분--%>
					<e:select id="RFX_FROM_MIN" name="RFX_FROM_MIN" value="${formData.RFX_FROM_MIN}" options="${rfxFromMinOptions}" width="${form_RFX_FROM_MIN_W}" disabled="${form_RFX_FROM_MIN_D}" readOnly="${form_RFX_FROM_MIN_RO}" required="${form_RFX_FROM_MIN_R}" placeHolder="" />
					<e:text>${form_RFX_FROM_MIN_N}&nbsp;</e:text>
					<e:text>&nbsp;~&nbsp;&nbsp;</e:text>
					<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" value="${formData.RFX_TO_DATE}" fromDate="RFX_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
					<e:text>&nbsp;&nbsp;</e:text>
					<e:select id="RFX_TO_HOUR" name="RFX_TO_HOUR" value="${formData.RFX_TO_HOUR}" options="${rfxToHourOptions}" width="${form_RFX_TO_HOUR_W}" disabled="${form_RFX_TO_HOUR_D}" readOnly="${form_RFX_TO_HOUR_RO}" required="${form_RFX_TO_HOUR_R}" placeHolder="" />
					<e:text>${form_RFX_TO_HOUR_N}&nbsp;&nbsp;</e:text>
					<e:select id="RFX_TO_MIN" name="RFX_TO_MIN" value="${formData.RFX_TO_MIN}" options="${rfxToMinOptions}" width="${form_RFX_TO_MIN_W}" disabled="${form_RFX_TO_MIN_D}" readOnly="${form_RFX_TO_MIN_RO}" required="${form_RFX_TO_MIN_R}" placeHolder="" />
					<e:text>${form_RFX_TO_MIN_N}&nbsp;&nbsp;</e:text>
				</e:field>
			</e:row>
			<%--<e:row>
				&lt;%&ndash;견적마감 알림1&ndash;%&gt;
				<e:label for="RFX_BF_DAY1" title="${form_RFX_BF_DAY1_N}"/>
				<e:field>
					<e:inputDate id="RFX_BF_DAY1" name="RFX_BF_DAY1" value="${formData.RFX_BF_DAY1}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_BF_DAY1_R}" disabled="${form_RFX_BF_DAY1_D}" readOnly="${form_RFX_BF_DAY1_RO}" />
					<e:text>&nbsp;&nbsp;</e:text>
					<e:select id="RFX_BF_HOUR1" name="RFX_BF_HOUR1" value="${formData.RFX_BF_HOUR1}" options="${rfxBfHour1Options}" width="${form_RFX_BF_HOUR1_W}" disabled="${form_RFX_BF_HOUR1_D}" readOnly="${form_RFX_BF_HOUR1_RO}" required="${form_RFX_BF_HOUR1_R}" placeHolder="" />
					<e:text>${form_RFX_BF_HOUR1_N}&nbsp;&nbsp;</e:text>
					<e:select id="RFX_BF_MIN1" name="RFX_BF_MIN1" value="${formData.RFX_BF_MIN1}" options="${rfxBfMin1Options}" width="${form_RFX_BF_MIN1_W}" disabled="${form_RFX_BF_MIN1_D}" readOnly="${form_RFX_BF_MIN1_RO}" required="${form_RFX_BF_MIN1_R}" placeHolder="" />
					<e:text>${form_RFX_BF_MIN1_N}&nbsp;&nbsp;</e:text>
				</e:field>
				&lt;%&ndash;견적마감 알림1&ndash;%&gt;
				<e:label for="RFX_BF_DAY2" title="${form_RFX_BF_DAY2_N}"/>
				<e:field>
					<e:inputDate id="RFX_BF_DAY2" name="RFX_BF_DAY2" value="${formData.RFX_BF_DAY2}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_BF_DAY2_R}" disabled="${form_RFX_BF_DAY2_D}" readOnly="${form_RFX_BF_DAY1_RO}" />
					<e:text>&nbsp;&nbsp;</e:text>
					<e:select id="RFX_BF_HOUR2" name="RFX_BF_HOUR2" value="${formData.RFX_BF_HOUR2}" options="${rfxBfHour1Options}" width="${form_RFX_BF_HOUR2_W}" disabled="${form_RFX_BF_HOUR2_D}" readOnly="${form_RFX_BF_HOUR2_RO}" required="${form_RFX_BF_HOUR2_R}" placeHolder="" />
					<e:text>${form_RFX_BF_HOUR2_N}&nbsp;&nbsp;</e:text>
					<e:select id="RFX_BF_MIN2" name="RFX_BF_MIN2" value="${formData.RFX_BF_MIN2}" options="${rfxBfMin1Options}" width="${form_RFX_BF_MIN2_W}" disabled="${form_RFX_BF_MIN2_D}" readOnly="${form_RFX_BF_MIN2_RO}" required="${form_RFX_BF_MIN2_R}" placeHolder="" />
					<e:text>${form_RFX_BF_MIN2_N}&nbsp;&nbsp;</e:text>
				</e:field>
			</e:row>--%>
			<e:row>
				<%--가격/기술 평가비율--%>
				<e:label for="PRC_PERCENT" title="${form_PRC_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="PRC_PERCENT" name="PRC_PERCENT" value="${formData.PRC_PERCENT}" width="${form_PRC_PERCENT_W}" maxValue="${form_PRC_PERCENT_M}" decimalPlace="${form_PRC_PERCENT_NF}" disabled="${form_PRC_PERCENT_D}" readOnly="${form_PRC_PERCENT_RO}" required="${form_PRC_PERCENT_R}" />
					<e:text>%&nbsp;</e:text>
					<e:inputNumber id="NPRC_PERCENT" name="NPRC_PERCENT" value="${formData.NPRC_PERCENT}" width="${form_NPRC_PERCENT_W}" maxValue="${form_NPRC_PERCENT_M}" decimalPlace="${form_NPRC_PERCENT_NF}" disabled="${form_NPRC_PERCENT_D}" readOnly="${form_NPRC_PERCENT_RO}" required="${form_NPRC_PERCENT_R}" />
					<e:text>%&nbsp;</e:text>
				</e:field>
				<e:label for="OPEN_BID_USER_ID" title="${form_OPEN_BID_USER_ID_N}"/>
				<e:field>
					<e:select id="OPEN_BID_USER_ID" name="OPEN_BID_USER_ID" value="${formData.OPEN_BID_USER_ID == null ? '731545' : formData.OPEN_BID_USER_ID }" options="${ctrlUserNmOptions}" width="${form_OPEN_BID_USER_ID_W}" disabled="${form_OPEN_BID_USER_ID_D}" readOnly="${form_OPEN_BID_USER_ID_RO}" required="${form_OPEN_BID_USER_ID_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--입찰예상금액--%>
				<e:label for="CUR" title="${form_CUR_N}"/>
				<e:field>
					<e:select id="CUR" name="CUR" value="KRW" options="${curOptions}" width="${form_CUR_W}" disabled="${form_CUR_D}" readOnly="true" required="${form_CUR_R}" placeHolder="" />
					<e:text>&nbsp;&nbsp;</e:text>
					<e:inputNumber id="RFX_AMT" name="RFX_AMT" value="${formData.RFX_AMT}" width="${form_RFX_AMT_W}" maxValue="${form_RFX_AMT_M}" decimalPlace="${form_RFX_AMT_NF}" disabled="${form_RFX_AMT_D}" readOnly="${form_RFX_AMT_RO}" required="${form_RFX_AMT_R}" />
				</e:field>
				<%--배송유형--%>
				<e:label for="DELY_TYPE" title="${form_DELY_TYPE_N}"/>
				<e:field>
					<e:select id="DELY_TYPE" name="DELY_TYPE" value="" options="${delyTypeOptions}" width="${form_DELY_TYPE_W}" disabled="${form_DELY_TYPE_D}" readOnly="${form_DELY_TYPE_RO}" required="${form_DELY_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--입찰참가자격--%>
				<e:label for="BID_PREQ_RMK" title="${form_BID_PREQ_RMK_N}" />
				<e:field colSpan="3">
					<e:textArea id="BID_PREQ_RMK" name="BID_PREQ_RMK" value="${formData.BID_PREQ_RMK}" height="100px" width="${form_BID_PREQ_RMK_W}" maxLength="${form_BID_PREQ_RMK_M}" disabled="${form_BID_PREQ_RMK_D}" readOnly="${form_BID_PREQ_RMK_RO}" required="${form_BID_PREQ_RMK_R}" />
				</e:field>
			</e:row>
			<c:if test="${ses.userType eq 'C'}">
				<e:row>
					<%--특기사항(내부공유)--%>
					<e:label for="RMK_IN" title="${form_RMK_IN_N}"/>
					<e:field>
						<e:textArea id="RMK_IN" name="RMK_IN" value="${formData.RMK_IN}" height="100px" width="${form_RMK_IN_W}" maxLength="${form_RMK_IN_M}" disabled="${form_RMK_IN_D}" readOnly="${form_RMK_IN_RO}" required="${form_RMK_IN_R}" />
					</e:field>
					<%--특기사항(업체공유)--%>
					<e:label for="RMK" title="${form_RMK_N}"/>
					<e:field>
						<e:textArea id="RMK" name="RMK" value="${formData.RMK}" height="100px" width="${form_RMK_W}" maxLength="${form_RMK_M}" disabled="${form_RMK_D}" readOnly="${form_RMK_RO}" required="${form_RMK_R}" />
					</e:field>
				</e:row>
				<e:row>
					<%--내부 첨부파일--%>
					<e:label for="ATT_FILE_NUM_IN" title="${form_ATT_FILE_NUM_IN_N}" />
					<e:field>
						<e:fileManager id="ATT_FILE_NUM_IN" name="ATT_FILE_NUM_IN" fileId="${formData.ATT_FILE_NUM_IN}" bizType="RQ"  width="${form_ATT_FILE_NUM_IN_W}" height="100px" readOnly="${empty param.detailView ? false :  param.detailView}" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
					</e:field>
					<%--첨부파일--%>
					<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
					<e:field>
						<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" width="${form_ATT_FILE_NUM_W}"  readOnly="${empty param.detailView ? false :  param.detailView}" bizType="RQ" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
					</e:field>
				</e:row>
			</c:if>
			<c:if test="${ses.userType eq 'S'}">
				<e:row>
					<%--특기사항(업체공유)--%>
					<e:label for="RMK" title="${form_RMK_N}" />
					<e:field>
						<e:richTextEditor id="RMK_TEXT" name="RMK_TEXT" value="${formData.RMK_TEXT}" width="${form_RMK_TEXT_W}" maxLength="${form_RMK_TEXT_M}" disabled="${form_RMK_TEXT_D}" readOnly="${form_RMK_TEXT_RO}" required="${form_RMK_TEXT_R}" />
						<e:inputHidden id="RMK" name="RMK" value="${formData.RMK}" />
					</e:field>
					<%--첨부파일--%>
					<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
					<e:field>
						<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" width="${form_ATT_FILE_NUM_W}"  readOnly="${empty param.detailView ? false :  param.detailView}" bizType="RQ" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
					</e:field>
				</e:row>
			</c:if>
		</e:searchPanel>

		<e:searchPanel id="form2" columnCount="2" labelWidth="180" useTitleBar="true" title="입찰설명회 정보" >
			<e:row>
				<%--입찰설명회 개최여부--%>
				<e:label for="ANN_FLAG" title="${form_ANN_FLAG_N}"/>
				<e:field>
					<e:select id="ANN_FLAG" name="ANN_FLAG" value="${formData.ANN_FLAG}" options="${annFlagOptions}" width="${form_ANN_FLAG_W}" disabled="${form_ANN_FLAG_D}" readOnly="${form_ANN_FLAG_RO}" required="${form_ANN_FLAG_R}" placeHolder="" />
				</e:field>
				<%--참석필수여부--%>
				<e:label for="ANN_ATTEND_FLAG" title="${form_ANN_ATTEND_FLAG_N}"/>
				<e:field>
					<e:select id="ANN_ATTEND_FLAG" name="ANN_ATTEND_FLAG" value="${formData.ANN_ATTEND_FLAG}" options="${annAttendFlagOptions}" width="${form_ANN_ATTEND_FLAG_W}" disabled="${form_ANN_ATTEND_FLAG_D}" readOnly="${form_ANN_ATTEND_FLAG_RO}" required="${form_ANN_ATTEND_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--개최일--%>
				<e:label for="ANN_DATE" title="${form_ANN_DATE_N}"/>
				<e:field>
					<e:inputDate id="ANN_DATE" name="ANN_DATE" value="${formData.ANN_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_ANN_DATE_R}" disabled="${form_ANN_DATE_D}" readOnly="${form_ANN_DATE_RO}" />
				</e:field>
				<%--시간--%>
				<e:label for="ANN_FROM_HOUR" title="${form_ANN_FROM_HOUR_N}"/>
				<e:field>
					<e:select id="ANN_FROM_HOUR" name="ANN_FROM_HOUR" value="${formData.ANN_FROM_HOUR}" options="${annFromHourOptions}" width="${form_ANN_FROM_HOUR_W}" disabled="${form_ANN_FROM_HOUR_D}" readOnly="${form_ANN_FROM_HOUR_RO}" required="${form_ANN_FROM_HOUR_R}" placeHolder="" />
					<e:text>시&nbsp;</e:text>
					<e:select id="ANN_FROM_MIN" name="ANN_FROM_MIN" value="${formData.ANN_FROM_MIN}" options="${annFromMinOptions}" width="${form_ANN_FROM_MIN_W}" disabled="${form_ANN_FROM_MIN_D}" readOnly="${form_ANN_FROM_MIN_RO}" required="${form_ANN_FROM_MIN_R}" placeHolder="" />
					<e:text>분&nbsp;~&nbsp;</e:text>
					<e:select id="ANN_TO_HOUR" name="ANN_TO_HOUR" value="${formData.ANN_TO_HOUR}" options="${annToHourOptions}" width="${form_ANN_TO_HOUR_W}" disabled="${form_ANN_TO_HOUR_D}" readOnly="${form_ANN_TO_HOUR_RO}" required="${form_ANN_TO_HOUR_R}" placeHolder="" />
					<e:text>시&nbsp;</e:text>
					<e:select id="ANN_TO_MIN" name="ANN_TO_MIN" value="${formData.ANN_TO_MIN}" options="${annToMinOptions}" width="${form_ANN_TO_MIN_W}" disabled="${form_ANN_TO_MIN_D}" readOnly="${form_ANN_TO_MIN_RO}" required="${form_ANN_TO_MIN_R}" placeHolder="" />
					<e:text>분&nbsp;</e:text>
				</e:field>
			</e:row>
			<e:row>
				<%--장소--%>
				<e:label for="ANN_PLACE_NM" title="${form_ANN_PLACE_NM_N}" />
				<e:field colSpan="3">
					<e:inputText id="ANN_PLACE_NM" name="ANN_PLACE_NM" value="${formData.ANN_PLACE_NM}" width="${form_ANN_PLACE_NM_W}" maxLength="${form_ANN_PLACE_NM_M}" disabled="${form_ANN_PLACE_NM_D}" readOnly="${form_ANN_PLACE_NM_RO}" required="${form_ANN_PLACE_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--담당자--%>
				<e:label for="ANN_USER_NM" title="${form_ANN_USER_NM_N}" />
				<e:field>
					<e:inputText id="ANN_USER_NM" name="ANN_USER_NM" value="${formData.ANN_USER_NM}" width="${form_ANN_USER_NM_W}" maxLength="${form_ANN_USER_NM_M}" disabled="${form_ANN_USER_NM_D}" readOnly="${form_ANN_USER_NM_RO}" required="${form_ANN_USER_NM_R}" />
				</e:field>
				<%--문의처--%>
				<e:label for="ANN_USER_TEL_NM" title="${form_ANN_USER_TEL_NM_N}" />
				<e:field>
					<e:inputText id="ANN_USER_TEL_NM" name="ANN_USER_TEL_NM" value="${formData.ANN_USER_TEL_NM}" width="${form_ANN_USER_TEL_NM_W}" maxLength="${form_ANN_USER_TEL_NM_M}" disabled="${form_ANN_USER_TEL_NM_D}" readOnly="${form_ANN_USER_TEL_NM_RO}" required="${form_ANN_USER_TEL_NM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--특기사항--%>
				<e:label for="ANN_RMK" title="${form_ANN_RMK_N}"/>
				<e:field colSpan="3">
					<e:textArea id="ANN_RMK" name="ANN_RMK" value="${formData.ANN_RMK}" height="100px" width="${form_ANN_RMK_W}" maxLength="${form_ANN_RMK_M}" disabled="${form_ANN_RMK_D}" readOnly="${form_ANN_RMK_RO}" required="${form_ANN_RMK_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:panel id="panelLeft" width="75%" height="fit">
			<e:buttonBar id="buttonL" >
				<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C'}">
					<div style="float: left; display: inline-block; margin-bottom: 2px;">
						<e:button id="doDownloadExcel" name="doDownloadExcel" label="${doDownloadExcel_N}" onClick="doDownloadExcel" disabled="${doDownloadExcel_D}" visible="${doDownloadExcel_V}"/>
					</div>
					<div style="float: right; display: inline-block; margin-bottom: 2px;">
						<e:button id="doSelectItem" name="doSelectItem" label="${doSelectItem_N}" onClick="doSelectItem" disabled="${doSelectItem_D}" visible="${doSelectItem_V}"/>
						<e:button id="doDeleteItem" name="doDeleteItem" label="${doDeleteItem_N}" onClick="doDeleteItem" disabled="${doDeleteItem_D}" visible="${doDeleteItem_V}"/>
						<e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
					</div>
				</c:if>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="400" readOnly="${empty param.detailView ? false :  param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
		</e:panel>

		<e:panel id="blank_pn" height="100%" width="1%">&nbsp;</e:panel>

		<e:panel id="panelRight" width="24%" height="fit">
			<e:buttonBar id="buttonR" align="right">
				<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R' || formData.SIGN_STATUS == 'C'}">
					<e:button id="doSelectFavorVendor" name="doSelectFavorVendor" label="${doSelectFavorVendor_N}" onClick="doSelectVendor" disabled="${doSelectFavorVendor_D}" visible="${doSelectFavorVendor_V}"/>
					<e:button id="doSelectVendor" name="doSelectVendor" label="${doSelectVendor_N}" onClick="doSelectVendor" disabled="${doSelectVendor_D}" visible="${doSelectVendor_V}"/>
				</c:if>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="400" readOnly="${empty param.detailView ? false :  param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
		</e:panel>

		<e:panel id="panel_hide">
			<e:gridPanel id="gridDEL" name="gridDEL" width="0" height="0" gridType="${_gridType}" readOnly="${empty param.detailView ? false :  param.detailView}" columnDef="${gridInfos.gridDEL.gridColData}" />
		</e:panel>

	</e:window>
</e:ui>