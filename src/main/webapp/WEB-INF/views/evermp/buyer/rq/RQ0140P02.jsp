<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/rq/RQ0140P02";
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


		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
		    	if(colId == "BATT_FILE_CNT") {
					param = {
							detailView: true,
							attFileNum: grid.getCellValue(rowId, "BATT_FILE_NUM"),
							rowId: rowId,
							callBackFunction: "setAttFile",
							bizType: "RQ",
							fileExtension: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		    	} else if(colId == "SATT_FILE_CNT") {
					param = {
							detailView: true,
							attFileNum: grid.getCellValue(rowId, "SATT_FILE_NUM"),
							rowId: rowId,
							callBackFunction: "setAttFile",
							bizType: "RQ",
							fileExtension: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		    	} else if(colId === 'BRMK'){
		            var param = {
		                      rowId: rowId
		                    , havePermission: false
		                    , screenName: '비고'
		                    , callBackFunction: ''
		                    , TEXT_CONTENTS: grid.getCellValue(rowId, "BRMK")
		                    , detailView: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				} else if(colId === 'SRMK'){
		            var param = {
		                      rowId: rowId
		                    , havePermission: false
		                    , screenName: '비고'
		                    , callBackFunction: ''
		                    , TEXT_CONTENTS: grid.getCellValue(rowId, "SRMK")
		                    , detailView: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}
		    });



	        grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
	        	if(colId == "SLT_FLAG") {
        			for (var i = 0; i < grid.getRowCount(); i++) {
        	        	var iBUYER_CD = grid.getCellValue(i, 'BUYER_CD');
        	        	var iRFX_NUM  = grid.getCellValue(i, 'RFX_NUM');
        	        	var iRFX_CNT  = grid.getCellValue(i, 'RFX_CNT');
        	        	var iRFX_SQ   = grid.getCellValue(i, 'RFX_SQ');

    	        		if(grid.getCellValue(rowId, 'RFX_NUM') == iRFX_NUM && grid.getCellValue(rowId, 'RFX_CNT') == iRFX_CNT && grid.getCellValue(rowId, 'RFX_SQ') == iRFX_SQ){
            				grid.setCellValue(i, 'SLT_FLAG','N');
    	        		}

                    }
        			grid.setCellValue(rowId, 'SLT_FLAG',value);
	        	}
		    });


































			doSearch();
	    }


	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {
	        });
        }





        function doClose() {
     		if(opener != null) {
     			opener.doSearch();
     			window.close();
     		} else {
     			parent.doSearch();
     			new EVF.ModalWindow().close(null);
     		}
        }

		function doReRfq() {
	        var param = {
	        		 BUYER_CD   : '${form.BUYER_CD}'
	        		,RFX_NUM    : '${form.RFX_NUM}'
                    ,RFX_CNT    : '${form.RFX_CNT}'
	        		,detailView : false
		    };
		    everPopup.openPopupByScreenId('RQ0140P03', 900, 330, param);
		}



		function doCancelRfq() {
			if (!confirm("${RQ0140P02_0003}")) return;
    		var store = new EVF.Store();
    		store.load(baseUrl + '/doCancelRfq', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
		}



		function doSettle() {
	        var countAward = 0;
	        for (var i = 0; i < grid.getRowCount(); i++) {
	        	var iBUYER_CD = grid.getCellValue(i, 'BUYER_CD');
	        	var iRFX_NUM  = grid.getCellValue(i, 'RFX_NUM');
	        	var iRFX_CNT  = grid.getCellValue(i, 'RFX_CNT');
	        	var iRFX_SQ   = grid.getCellValue(i, 'RFX_SQ');

	        	//var cnt = 0;

	        	//품목별 업체선정여부 체크
	        	var countAward = 0;
	        	for (var j = 0; j < grid.getRowCount(); j++) {
	        		if(grid.getCellValue(j, 'SLT_FLAG') == "Y" && grid.getCellValue(j, 'RFX_NUM') == iRFX_NUM && grid.getCellValue(j, 'RFX_CNT') == iRFX_CNT && grid.getCellValue(j, 'RFX_SQ') == iRFX_SQ){
	        			countAward++;
	        		}
	        	}

	        	if (countAward > 1) {
	        		alert('${RQ0140P02_0004}'); //업체선정여부는 한건만 입력하시기 바랍니다.
	                return;
	            }
	        	if (countAward == 0) {
	        		alert('${RQ0140P02_0005}'); //품목별로 한 업체를 꼭 선정하셔야 합니다.
	                return;
	            }
	        }

//	        for (var i = 0; i < grid.getRowCount(); i++) {
//	        	if(grid.getCellValue(i, 'AWARD') == "1" && grid.getCellValue(i, 'SETTLE_RMK').text == ''
//	        		&& grid.getCellValue(i, 'PRICE_RANK') != '1'
//	        	){
//	        		alert(everString.getMessage("${msg.M0109}", "선정사유")); return;//선정사유는 필수입력사항입니다.
//	        	}
//	        }


			if (!confirm("${RQ0140P02_0002}")) return;
    		var store = new EVF.Store();

			store.setGrid([grid]);
			store.getGridData(grid,'all');
    		store.load(baseUrl + '/doItemSettle', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
		}

	</script>

	<e:window id="RQ0140P02" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
            <e:row>
				<%--견적요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
				<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				<e:text> / </e:text>
				<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<%--구매유형--%>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<%--견적/입찰명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
				<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--견적기간--%>
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
				<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${form.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right">

		<c:if test="${form.PROGRESS_CD == '2400'}">
			<e:button id="doReRfq" name="doReRfq" label="${doReRfq_N}" onClick="doReRfq" disabled="${doReRfq_D}" visible="${doReRfq_V}"/>
			<e:button id="doSettle" name="doSettle" label="${doSettle_N}" onClick="doSettle" disabled="${doSettle_D}" visible="${doSettle_V}"/>
			<e:button id="doCancelRfq" name="doCancelRfq" label="${doCancelRfq_N}" onClick="doCancelRfq" disabled="${doCancelRfq_D}" visible="${doCancelRfq_V}"/>
		</c:if>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>