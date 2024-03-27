<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/rq/RQ0120";
	    var grid;
		var selRow;

	    function init() {
	        grid = EVF.C("grid");
			grid.setProperty("shrinkToFit", false);        			// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});


		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
		    	if(selRow == undefined) selRow = rowId;
		    	if(colId == "multiSelect") {
					if(selRow != rowId) {
						grid.checkRow(selRow, false);
						selRow = rowId;
					}
				} else if(colId === 'RFX_NUM'){
					var prType = grid.getCellValue(rowId,'PR_TYPE');

			        var param = {
			        		 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
			        		,RFX_NUM   : grid.getCellValue(rowId,'RFX_NUM')
		                    ,RFX_CNT     : grid.getCellValue(rowId,'RFX_CNT')
			        		,detailView : true
				    };
				    everPopup.openPopupByScreenId('RQ0110', 1200, 1000, param);
				} else if(colId === 'FROM_MOD_RMK'){
		            var param = {
		                      rowId: rowId
		                    , havePermission: false
		                    , screenName: '사유'
		                    , callBackFunction: ''
		                    , TEXT_CONTENTS: grid.getCellValue(rowId, "FROM_MOD_RMK")
		                    , detailView: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				} else if(colId === 'TO_EXTEND_RMK'){
		            var param = {
		                      rowId: rowId
		                    , havePermission: false
		                    , screenName: '사유'
		                    , callBackFunction: ''
		                    , TEXT_CONTENTS: grid.getCellValue(rowId, "TO_EXTEND_RMK")
		                    , detailView: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				} else if(colId === 'FORCE_CLOSE_RMK'){
		            var param = {
		                      rowId: rowId
		                    , havePermission: false
		                    , screenName: '사유'
		                    , callBackFunction: ''
		                    , TEXT_CONTENTS: grid.getCellValue(rowId, "FORCE_CLOSE_RMK")
		                    , detailView: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				} else if(colId === 'VENDOR_CNT'){
			        var param = {
			        		 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
			        		,RFX_NUM    : grid.getCellValue(rowId,'RFX_NUM')
		                    ,RFX_CNT    : grid.getCellValue(rowId,'RFX_CNT')
			        		,detailView : true
				    };
				    everPopup.openPopupByScreenId('RQ0120P03', 1200, 500, param);
				}

			});




	        doSearch();
	    }

	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {
	            if (grid.getRowCount() == 0) {
	                alert("${msg.M0002 }");
	            }
	        });
        }

		//조회 조건 구매 담당자 검색
		function openCtrlUser(){
			var param = {
				callBackFunction: "setCtrlUser",
			};
			everPopup.openCommonPopup(param, "SP0040");
		}

		function setCtrlUser(data){
			EVF.V('CTRL_USER_NM', data.CTRL_USER_NM);
			EVF.V('CTRL_USER_ID', data.CTRL_USER_ID);
		}

		//선택한 데이터의 구매담당자 본인 인지 체크
		function checkUserValidate(){
			var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
            for(var i = 0; i < rowIds.length; i++) {
				if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != '' && grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}"){
					return 'M0008'; //처리할 권한이 없습니다.
				}
            }
		}


		function doTransferCtrlUser(){

			if(checkUserValidate() == 'M0008'){
				return alert("${msg.M0008}")
			}

			var param = {
				callBackFunction: "transferCtrlUser",
			};
			everPopup.openCommonPopup(param, "SP0040");
		}

		function transferCtrlUser(data){
			EVF.V('CTRL_USER_TRANSFER_NM', data.CTRL_USER_NM);
			EVF.V('CTRL_USER_TRANSFER_ID', data.CTRL_USER_ID);
		}



		//구매담당자 이관 버튼
		function doCtrlIdChg(){

			if(grid.getRowCount() == 0){
				return alert("${msg.M0002}");
			}
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0){
				return alert("${msg.M0004}");
			}
			if(EVF.V('CTRL_USER_TRANSFER_ID') == null || EVF.V('CTRL_USER_TRANSFER_ID') == ''){
				return alert("${RQ0120_0002}");
			}

			if(checkUserValidate() == 'M0008'){
				return alert("${msg.M0008}")
			}else if(checkUserValidate() == 'M0044'){
				return alert("${msg.M0044}")
			}


	        var selRowId = grid.getSelRowId();
            for(var i = 0; i < selRowId.length; i++) {
            	var progressCd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
    			if (progressCd != '1300' && progressCd != '2300'
    			) {
    				return alert("${msg.M0044}");
    			}
            }

			if(!confirm('${RQ0120_0003}')) return; //이관 하시겠습니까?

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, "sel");
			store.load(baseUrl + "/doCtrlIdChg", function(){
				alert(this.getResponseMessage());
				doSearch();
			});

		}

		function doChgStartDate() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

			if(checkUserValidate() == 'M0008'){
				return alert("${msg.M0008}")
			}else if(checkUserValidate() == 'M0044'){
				return alert("${msg.M0044}")
			}


			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');

			if (progressCd == '1300' || progressCd == '2300' || progressCd == '2500'
				|| progressCd >= '2500'
			) {
				return alert("${msg.M0044}");
			}




	        var param = {
	        		 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
	        		,RFX_NUM   : grid.getCellValue(rowId,'RFX_NUM')
                    ,RFX_CNT     : grid.getCellValue(rowId,'RFX_CNT')
	        		,detailView : false
		    };
		    everPopup.openPopupByScreenId('RQ0120P01', 600, 440, param);
		}




		function doChgEndDate() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

			if(checkUserValidate() == 'M0008'){
				return alert("${msg.M0008}")
			}else if(checkUserValidate() == 'M0044'){
				return alert("${msg.M0044}")
			}


			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');

			if (progressCd == '1300' || progressCd == '2300' || progressCd == '2500'
				|| progressCd >= '2500'
			) {
				return alert("${msg.M0044}");
			}




	        var param = {
	        		 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
	        		,RFX_NUM   : grid.getCellValue(rowId,'RFX_NUM')
                    ,RFX_CNT     : grid.getCellValue(rowId,'RFX_CNT')
	        		,detailView : false
		    };
		    everPopup.openPopupByScreenId('RQ0120P02', 600, 440, param);


		}



		function doModify() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

			if(checkUserValidate() == 'M0008'){
				return alert("${msg.M0008}")
			}else if(checkUserValidate() == 'M0044'){
				return alert("${msg.M0044}")
			}

			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');

			var signStatus = grid.getCellValue(rowId,'SIGN_STATUS');

			if (progressCd != '2300' || signStatus == 'P' || signStatus == 'E'
			) {
				return alert("${msg.M0044}");
			}
	        var param = {
	        		 BUYER_CD   : grid.getCellValue(rowId,'BUYER_CD')
	        		,RFX_NUM   : grid.getCellValue(rowId,'RFX_NUM')
                    ,RFX_CNT     : grid.getCellValue(rowId,'RFX_CNT')
	        		,detailView : false
		    };
		    everPopup.openPopupByScreenId('RQ0110', 1200, 1000, param);
		}



		function doCloseRfq() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];

			if(checkUserValidate() == 'M0008'){
				return alert("${msg.M0008}")
			}else if(checkUserValidate() == 'M0044'){
				return alert("${msg.M0044}")
			}
			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');

			if (progressCd == '1300' || progressCd == '2300' || progressCd == '2500' || progressCd == '2355'
				|| progressCd >= '2500'
			) {
				return alert("${msg.M0044}");
			}

            var param = {
                      rowId: rowId
                    , havePermission: true
                    , screenName: '강제마감사유'
                    , callBackFunction: 'doCloseRfqSave'
                    , TEXT_CONTENTS: ''
                    , detailView: false
                };
                everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
		}


	    function doCloseRfqSave(text, rowId) {
			grid.setCellValue(rowId, 'FORCE_CLOSE_RMK', text);


			var store = new EVF.Store();
    		store.setGrid([grid]);
    		store.getGridData(grid, 'sel');
			if (!confirm("${RQ0120_0001}")) return;


    		store.load(baseUrl + '/doCloseRfq', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

	</script>

	<e:window id="RQ0120" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
            <e:row>
				<%--FROM--%>
				<e:label for="DATE_FROM">
					<e:select id="TYPE" name="TYPE" value="" options="${typeOptions}" width="${form_TYPE_W}" disabled="${form_TYPE_D}" readOnly="${form_TYPE_RO}" required="${form_TYPE_R}" placeHolder="" usePlaceHolder="flase">
                        <e:option text="${RQ0120_REG_DATE}" value="REG_DATE">${RQ0120_REG_DATE}</e:option>
                        <e:option text="${RQ0120_RFX_TO_DATE}" value="RFX_TO_DATE">${RQ0120_RFX_TO_DATE}</e:option>
                        <e:option text="${RQ0120_RFX_FROM_DATE}" value="RFX_FROM_DATE">${RQ0120_RFX_FROM_DATE}</e:option>
					</e:select>
				</e:label>
				<e:field>
				<e:inputDate id="DATE_FROM" name="DATE_FROM" toDate="DATE_TO" value="${addFromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" />
				<e:text> ~ </e:text>
				<e:inputDate id="DATE_TO" name="DATE_TO" fromDate="DATE_FROM" value="${addToDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" />
				</e:field>
				<%--구매유형--%>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<%--회사명--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" usePlaceHolder="false"/>
				</e:field>
            </e:row>
            <e:row>
				<%--요청번호/명--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
				<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				<e:text> / </e:text>
				<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--사용자ID--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
				<e:search id="CTRL_USER_ID" name="CTRL_USER_ID" value="" width="${form_CTRL_USER_ID_W}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_D ? 'everCommon.blank' : 'openCtrlUser'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
				<e:text> / </e:text>
				<e:inputText id="CTRL_USER_NM" name="CTRL_USER_NM" value="" width="${form_CTRL_USER_NM_W}" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
				</e:field>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<%--견적/입찰--%>
				<e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}"/>
				<e:field>
				<e:select id="RFX_TYPE" name="RFX_TYPE" value="" options="${rfxTypeOptions}" width="${form_RFX_TYPE_W}" disabled="${form_RFX_TYPE_D}" readOnly="${form_RFX_TYPE_RO}" required="${form_RFX_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
				</e:field>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field colSpan="3">
				<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">

			<e:panel>
				<%--구매담당자 이관--%>
				<e:text style="font-weight: bold;">●&nbsp;${form_CTRL_USER_TRANSFER_NM_N } &nbsp;:&nbsp; </e:text>
				<e:search id="CTRL_USER_TRANSFER_NM" name="CTRL_USER_TRANSFER_NM" value="" width="${form_CTRL_USER_TRANSFER_NM_W}" maxLength="${form_CTRL_USER_TRANSFER_NM_M}" onIconClick="${form_CTRL_USER_TRANSFER_NM_RO ? 'everCommon.blank' : 'doTransferCtrlUser'}" disabled="${form_CTRL_USER_TRANSFER_NM_D}" readOnly="true" required="${form_CTRL_USER_TRANSFER_NM_R}" />
				<e:inputHidden id="CTRL_USER_TRANSFER_ID" name="CTRL_USER_TRANSFER_ID" />
				<e:inputHidden id="TRANS_RMK" name="TRANS_RMK" />
				<e:text>&nbsp;</e:text>
				<e:button id="doCtrlIdChg" name="doCtrlIdChg" label="${doCtrlIdChg_N}" onClick="doCtrlIdChg" disabled="${doCtrlIdChg_D}" visible="${doCtrlIdChg_V}"/>
			</e:panel>






				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
				<e:button id="doChgStartDate" name="doChgStartDate" label="${doChgStartDate_N}" onClick="doChgStartDate" disabled="${doChgStartDate_D}" visible="${doChgStartDate_V}"/>
				<e:button id="doChgEndDate" name="doChgEndDate" label="${doChgEndDate_N}" onClick="doChgEndDate" disabled="${doChgEndDate_D}" visible="${doChgEndDate_V}"/>
				<e:button id="doCloseRfq" name="doCloseRfq" label="${doCloseRfq_N}" onClick="doCloseRfq" disabled="${doCloseRfq_D}" visible="${doCloseRfq_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>