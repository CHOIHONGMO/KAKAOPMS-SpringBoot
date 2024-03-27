<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0350P01";
	    var grid;


	    function init() {
	    	
	    	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
	    	if('${param.detailView}' == 'true') {
	    		$('#upload-button-RSLT_ATT_FILE_NUM').css('display','none');
	    	}
	    	
	        grid = EVF.C("grid");
			grid.setProperty("shrinkToFit", false);        			// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]


			<c:if test="${VIEW_FLAG}">
				$("#doModify").hide();
			</c:if>
			grid.cellClickEvent(function(rowId, colId, value, iRow, iCol){

				if(colId === 'QTA_NUM' && value !== ''){
					var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');
					if(progressCd < '2800' && progressCd !== '1400'){
						return alert('${BD0350P01_0001}');
					}

					var negoResultType = grid.getCellValue(rowId, 'NEGO_RESULT_TYPE');
					var maxCnt_qtaNum = '1';
					var allgrid = grid.getAllRowValue();
					for(var i in allgrid){
						if(allgrid[i].QTA_NUM === grid.getCellValue(rowId,'QTA_NUM') && maxCnt_qtaNum < grid.getCellValue(rowId,'QTA_CNT')){
							maxCnt_qtaNum = grid.getCellValue(rowId,'QTA_CNT');
						}
					}

					if(negoResultType === '06' && grid.getCellValue(rowId,'QTA_CNT') === maxCnt_qtaNum){
						return alert('${BD0350P01_0001}');
					}

					var param = {
						 QTA_NUM : grid.getCellValue(rowId,'QTA_NUM')
						,QTA_CNT : grid.getCellValue(rowId,'QTA_CNT')
						,VENDOR_CD : grid.getCellValue(rowId,'VENDOR_CD')
						,popupFlag : true
						,detailView : true
					};
					everPopup.openPopupByScreenId('BQ0320', 1200, 900, param);
				}
			});

			doSearch();
	    }


	    function doSearch() {
	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {
				
	        });
        }
	    
	    function doModify() {
	    	
	    	if (!grid.validate().flag) { return EVF.alert(grid.validate().msg); }
	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.getGridData(grid, 'sel');
	        store.doFileUpload(function() {
		        store.load(baseUrl + "/doSave", function() {
		        	alert(this.getResponseMessage());
		        	doSearch();
		        	
		        	if(opener != null) {
						opener.doSearch();
					} else {
						parent.doSearch();
					}
		        });
	        });
        }
		
        function doClose() {
     		if(opener != null) {
     			window.close();
     		} else {
     			new EVF.ModalWindow().close(null);
     		}
        }

	</script>

	<e:window id="BD0350P01" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}" >
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch" useTitleBar="false">
        	<e:inputHidden id="CHG_TYPE" name="CHG_TYPE" value="END"/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
            <e:row>
            	<%--입찰요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
				<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				<e:text> / </e:text>
				<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<e:label for="dummy"/>
				<e:field colSpan="1" />
            </e:row>
			<e:row>
				<%--특기사항(업체공유)--%>
				<e:label for="RSLT_RMK" title="${form_RSLT_RMK_N}"/>
				<e:field>
					<e:textArea id="RSLT_RMK" name="RSLT_RMK" value="${form.RSLT_RMK}" height="140px" width="100%" maxLength="${form_RSLT_RMK_M}" disabled="${form_RSLT_RMK_D}" readOnly="${form_RSLT_RMK_RO}" required="${form_RSLT_RMK_R}" />
				</e:field>
				<%--첨부파일--%>
				<e:label for="RSLT_ATT_FILE_NUM" title="${form_RSLT_ATT_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="RSLT_ATT_FILE_NUM" name="RSLT_ATT_FILE_NUM" fileId="${form.RSLT_ATT_FILE_NUM}" width="100%"  readOnly="${empty param.detailView ? false :  param.detailView}" bizType="BD" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        	<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>