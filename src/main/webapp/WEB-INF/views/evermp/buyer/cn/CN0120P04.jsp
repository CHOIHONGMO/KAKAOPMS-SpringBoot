<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/cn/CN0120P04/";
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
				fileName : "${fullScreenName}"
			});
			var cols = [];
			var col = [];
			var cnt = 0;
			//첫번째 탭 실행
			onActiveTab($(".ui-tabs-nav").children().children()[0].text)
// 			doSearch();
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
        function onActiveTab(newTabId, oldTabId, event){


        	var store = new EVF.Store();
        	store.setParameter("RFX_SEQ"   , newTabId);
        	store.load(baseUrl + "/doSearch", function() {
        		var info=store.getFormObject();
 		    	EVF.V("RFX_NUM"				,info.RFX_NUM);
 		   		EVF.V("RFX_CNT"				,info.RFX_CNT);
 		    	EVF.V("RFX_SUBJECT"			,info.RFX_SUBJECT);
 		    	EVF.V("RFX_FROM_DATE2"		,info.RFX_FROM_DATE2);
 		    	EVF.V("RFX_TO_DATE2"		,info.RFX_TO_DATE2);
 		    	EVF.V("VENDOR_OPEN_TYPE"	,info.VENDOR_OPEN_TYPE);
 		    	EVF.V("PRC_SLT_TYPE"		,info.PRC_SLT_TYPE);
 		    	EVF.V("VENDOR_SLT_TYPE"		,info.VENDOR_SLT_TYPE);
 		    	var cols = [];
 				var col = [];
 				var cnt = 0;
                // 그리드 컬럼 초기화
 				grid.columns=grid.columns.filter(v=>v.fieldName.includes('_FINAL_')!=true )
 				grid.fields=grid.fields.filter(v=>v.fieldName.includes('_FINAL_')!=true )
				//그리드 colgrup뽑
 		    	$.each (store.responseBody.additionalColumn, function (index, el) {

 		    		grid.createColumn(el.COLUMN_ID,el.COLUMN_NM,110,'right','text',100, false, false,'',0);
 					col.push(el.COLUMN_ID);

					if(index%3==2){
						cols[cnt] = col;
						col = [];
						cnt++;

					}
 		    	});
                //그리드 그룹 셋팅/추가
 		    	grid.setColGroup(groupFn(store.responseBody,cols),50);
                grid.delAllRow();
 		    	grid.addRow(store.responseBody.grid)
 	        });
        }
		function groupFn(responseBody,cols){
			var groupList=[];
			groupList.push(
 					{
 		                "groupName" : '구매요구',
 		                "columns"   : [ "UNIT_CD","RFX_QT" ]
 		            })
			groupList.push(
 					{
 		                "groupName" : '예산',
 		                "columns"   : [ "UNIT_PRC","RFX_AMT" ]
 		            })
			groupList.push(
 					{
 		                "groupName" : '구매진행',
 		                "columns"   : [ "UNIT_CD1","RFX_QT1" ]
 		            })
			$.each (responseBody.additionalColumn, function (index, el) {
        		if(index%3==0){
        			groupList.push({
						"groupName" : el.VENDOR_NM,
						"columns" :	cols[Math.floor(index/3)]
					})
        	    }

            })
            return groupList;
		}






	</script>

	<e:window id="CN0120P04"  onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">
        <e:tabPanel id="T1" onActive="onActiveTab" onBeforeActive="onBeforeActiveTab">
	        <c:forEach items="${QTA_NUM_LIST}" var="subForm" varStatus="status">
		        <e:tab id="${subForm}" title="${subForm}">

				</e:tab>
	        </c:forEach>
 			<e:searchPanel id="form" title="입찰/견적비교" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
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
							<e:text id="RFX_FROM_DATE2"> ${form.RFX_FROM_DATE2} </e:text>
							<e:text> ~ </e:text>
							<e:text id="RFX_TO_DATE2"> ${form.RFX_TO_DATE2} </e:text>
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

	        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>        </e:tabPanel>

	</e:window>
</e:ui>