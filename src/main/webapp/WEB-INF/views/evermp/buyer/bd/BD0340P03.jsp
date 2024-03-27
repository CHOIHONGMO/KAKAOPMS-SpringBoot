<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0340P03";
	    var grid;


	    function init() {
			$(".e-title-text").after('<div style="color:red; font-size: 11pt;">&nbsp;&nbsp;&nbsp;입찰비교표는 업체 선정 후에 확인이 가능합니다.</div>');
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
				fileName : "${fullScreenName}"
			});

			var cols = [];
			var col = [];
			var cnt = 0;
			<c:forEach varStatus="status" var="columnx" items="${additionalColumn}" >

				grid.createColumn('${columnx.COLUMN_ID}','${columnx.COLUMN_NM}',110,'right','text',100, false, false,'',0);
				col.push('${columnx.COLUMN_ID}');

				<c:if test="${status.index%3==2}">
					cols[cnt] = col;
					col = [];
					cnt++;
				</c:if>
			</c:forEach>

			grid.setColGroup([
				{
	                "groupName" : '구매요구',
	                "columns"   : [ "UNIT_CD","RFX_QT" ]
	            },{
	                "groupName" : '예산',
	                "columns"   : [ "UNIT_PRC","RFX_AMT" ]
	            },{
	                "groupName" : '구매진행',
	                "columns"   : [ "UNIT_CD1","RFX_QT1" ]
	            },
				<c:forEach varStatus="status" var="columnx" items="${additionalColumn}" >

					<c:if test="${status.index%3==0}">
						{
							"groupName" : "${columnx.VENDOR_NM}",
							"columns" :	cols[Math.floor('${status.index/3}')]
						}
					</c:if>
					<c:if test="${status.index%3==2 && status.index+1 != columnsize}">
						,
					</c:if>

				</c:forEach>
			],50);
			
		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

		    });

	        grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

		    });

			doSearch();
	    }

	    function callback_setSltRmk(text, rowId) {
		    grid.setCellValue(rowId, 'SLT_RMK', text);
	    }


	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {
		       // setColDecimalByPrc();
	        });
        }


        //소수점 0인 경우 안나오도록 처리
		function setColDecimalByPrc(){
			<c:forEach varStatus="status" var="columnx" items="${additionalColumn}" >
				var decimalvalue = 0;
				var checkdecimal = grid.getAllRowId();
				for(var idx in checkdecimal){
					let eachvalue = grid.getCellValue(idx,'${columnx.COLUMN_ID}');
					if(eachvalue > decimalvalue){decimalvalue = eachvalue;}
				}
				var valueStr = decimalvalue.toString().split('.');
				var decimalnum = valueStr[1].length;
				grid.setColDecimal('${columnx.COLUMN_ID}',decimalnum);
			</c:forEach>
		}



        function doClose() {
     		if(opener != null) {
     			//opener.doSearch();
     			window.close();
     		} else {
     			//parent.doSearch();
     			new EVF.ModalWindow().close(null);
     		}
        }


        //재견적
		function doReRfq() {
	        var param = {
	        		 BUYER_CD   : '${form.BUYER_CD}'
	        		,RFX_NUM    : '${form.RFX_NUM}'
                    ,RFX_CNT    : '${form.RFX_CNT}'
	        		,detailView : false
		    };
		    everPopup.openPopupByScreenId('RQ0340P03', 900, 330, param);
		}


		//유찰
		function doCancelRfq() {
			if (!confirm("${RQ0140P02_0003}")) return;
    		var store = new EVF.Store();
    		store.load(baseUrl + '/doCancelRfq', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
		}



		//협력업체 선정
		function doSettle() {
	        var countAward = 0;
	        for (var i = 0; i < grid.getRowCount(); i++) {
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

	        		if(grid.getCellValue(j, 'SLT_FLAG') == "Y" && grid.getCellValue(j, 'RANK') != "1" && grid.getCellValue(j, 'SLT_RMK') == ""){
						return alert('${RQ0340P02_0006}'); //선택된 협력업체 품목의 순위가 1위가 아닌 경우 선정사유를 필수로 등록해야 합니다.
					}
	        	}

	        	if (countAward > 1) {
	        		alert('${RQ0340P02_0004}'); //업체선정여부는 한건만 입력하시기 바랍니다.
	                return;
	            }
	        	if (countAward == 0) {
	        		alert('${RQ0340P02_0005}'); //품목별로 한 업체를 꼭 선정하셔야 합니다.
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


			if (!confirm("${RQ0340P02_0002}")) return;
    		var store = new EVF.Store();

			store.setGrid([grid]);
			store.getGridData(grid,'all');
    		store.load(baseUrl + '/doItemSettle', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});
		}

	</script>

	<e:window id="BD0340P03" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="입찰비교" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
            <e:row>
				<%--견적요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text> / </e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--견적명--%>
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
				<%--선정방식--%>
				<e:label for="PRC_SLT_TYPE" title="${form_PRC_SLT_TYPE_N}"/>
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