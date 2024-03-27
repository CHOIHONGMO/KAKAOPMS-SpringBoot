<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0320P01";
	    var grid;


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

			grid.cellClickEvent(function(rowId, colId, value, iRow, iCol){

				if(colId === 'QTA_NUM' && value !== ''){
					var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');
					if(progressCd < '2800' && progressCd !== '1400'){
						return alert('${BD0320P01_0001}');
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
						return alert('${BD0320P01_0001}');
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

			if(EVF.V('PRC_SLT_TYPE')!=='NGO'){
				grid.hideCol('QTA_RFX_FROM_TO_DATE', true);
			}

			doSearch();
	    }


	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {

		        setColorSelectedVendor();
	        });
        }

        function setColorSelectedVendor(){

	    	var sel = grid.getAllRowValue();
	    	for(var i in sel){

	    		var slt = sel[i].SETTLE_YN;
	    		if(slt === 'Y'){
				    grid.setRowFontColor(i,'#0000fe');
				}

			}

		}




        function doClose() {
     		if(opener != null) {
     			window.close();
     		} else {
     			new EVF.ModalWindow().close(null);
     		}
        }

	</script>

	<e:window id="BD0320P01" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}" >
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch" useTitleBar="false">
        	<e:inputHidden id="CHG_TYPE" name="CHG_TYPE" value="END"/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
            <e:row>
				<%--입찰요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text> / </e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--입찰요청명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
				<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--입찰기간--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:text> ${form.RFX_FROM_DATE2} </e:text>
					<e:text> ~ </e:text>
					<e:text> ${form.RFX_TO_DATE2} </e:text>
				</e:field>
            </e:row>
            <e:row>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
				<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
				<%--업체선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form_VENDOR_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="PRC_SLT_TYPE" name="PRC_SLT_TYPE" value="${form.PRC_SLT_TYPE}" options="${prcSltTypeOptions}" width="${form_PRC_SLT_TYPE_W}" disabled="${form_PRC_SLT_TYPE_D}" readOnly="${form_PRC_SLT_TYPE_RO}" required="${form_PRC_SLT_TYPE_R}" placeHolder="" />
					<e:text>/</e:text>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${form.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>