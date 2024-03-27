<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    var grid1 = {};
    var baseUrl = "/eversrm/solicit/rfq/";
	function init() {
        grid1 = new EVF.C('grid1');
        grid1.createColumn('FINAL_AWARD', '${BSOX_270_FINAL_AWARD}', 0, 'center', 'text', 20, false,'');
        grid1.createColumn('ITEM_CD', '${BSOX_270_ITEM_CD}', 100, 'center', 'text', 30, false,'');
        grid1.createColumn('ITEM_DESC', '${BSOX_270_ITEM_DESC}', 150, 'left', 'text', 500, false,'');
        grid1.createColumn('UNIT_CD', '${BSOX_270_UNIT_CD}', 50, 'center', 'text', 50, false,'');
        grid1.createColumn('RFX_QT', '${BSOX_270_RFX_QT}', 100, 'right', 'number', 22, false,false, '', 0);
        grid1.createColumn('ITEM_AMT', '${BSOX_270_ITEM_AMT}', 0, 'right', 'number', 22, false,false, '', 0);

		var cols = [];
		var col = [];
		var cnt = 0;
		<c:forEach varStatus="status" var="columnx" items="${columnInfos}">

        	<c:if test="${status.count%4==1 || status.count%4==2}">
        		grid1.createColumn('${columnx.COLUMN_ID}', '${columnx.COLUMN_NM}', 100, 'right', 'number', 50, false,false, '', 0);
				col.push('${columnx.COLUMN_ID}');
			</c:if>
        	<c:if test="${status.count%4==3}">
        		grid1.createColumn('${columnx.COLUMN_ID}', '${columnx.COLUMN_NM}', 0, 'center', 'text', 50, false,false, '', 0);
			</c:if>
        	<c:if test="${status.count%4==0}">
        		grid1.createColumn('${columnx.COLUMN_ID}', '${columnx.COLUMN_NM}', 100, 'center', 'imagetext', 50, false,false, '', 0);
				col.push('${columnx.COLUMN_ID}');

				cols[cnt] = col;
				col = [];
				cnt++;
			</c:if>
		</c:forEach>

		// grid1.boundColumns();
		if(${_gridType eq "RG"}) {
			grid1.setColGroup([
				<c:forEach varStatus="status" var="columnx" items="${columnInfos}">
					<c:if test="${status.count%4==1}">
						{
							"groupName": '${columnx.VENDOR_NM}',
							"columns": cols[Math.floor(${status.count/4})]
						}
						<c:if test="${status.count!=0  && status.count+1 != columnsize}">
							,
						</c:if>
					</c:if>
				</c:forEach>
			]);
		} else {
			grid1.setGroupCol(
					[
						<c:forEach varStatus="status" var="columnx" items="${columnInfos}">
						<c:if test="${status.count%4==1}">
						{'colName' : '${columnx.COLUMN_ID}', 'colIndex' : 4, 'titleText' : '${columnx.VENDOR_NM}'}
						<c:if test="${status.count!=0  && status.count+1 !=columnsize}">
						,
						</c:if>
						</c:if>
						</c:forEach>
					]
			);
		}


	    grid1.cellClickEvent(function(rowId, celName, value, iRow, iCol) {

	        <c:forEach varStatus="status" var="columnx" items="${columnInfos}">
        	<c:if test="${status.count%4==0}">

	    	if (celName=='${columnx.COLUMN_ID}') {
//        		var costNeed = grid1.getCellValue(rowId, "COST_ITEM_NEED");
        		var costNeed = grid1.getCellValue(rowId, "${columnx.COLUMN_ID}");
        		if(costNeed == 'Yes'){
        			var itemC='';

                	if(  1==1)
                	{
                		var turl = '';
                    	turl = '/eversrm/solicit/rfq/DH2150/view';
                		var param = {
                			flag: itemC,
                			rowid: rowId,
                			COST_NUM: grid1.getCellValue(rowId, '${columnx.COLUMN_ID}'.substring(0,'${columnx.COLUMN_ID}'.indexOf('_')   )+'_COST_NUM'),
                			COST_CD: '',

                    		ITEM_CD : grid1.getCellValue(rowId, 'ITEM_CD'),
                    		ITEM_DESC : grid1.getCellValue(rowId, 'ITEM_DESC'),
//                    		ITEM_SPEC : grid1.getCellValue(rowId, 'ITEM_SPEC'),
                    		RFX_QT : grid1.getCellValue(rowId, 'RFX_QT'),


                			detailView: 'true',
                            callBackFunction: 'setCostItemNeed',
                            url: turl,
                            "buttonStatus": 'N'
                        };
                        everPopup.openCostItemNeed(param);
                	}else{
                		//alert("품목구분이 수입품,제작품,ISP 가 아닐 경우 원가계산서 대상이 아닙니다.");
                		alert('${BSOX_290_001}');
                	}
        		}
            }
	    	</c:if>
	    	</c:forEach>

	    });

		grid1.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
			excelOptions : {
				imgWidth : 0.12, // 이미지의 너비.
				imgHeight : 0.26, // 이미지의 높이.
				colWidth : 20, // 컬럼의 넓이.
				rowSize : 500, // 엑셀 행에 높이 사이즈.
				attachImgFlag : false
			// 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부
			}
		});

	    doSearch();
	}
	function doClose() {
		if (opener) {
			window.open("", "_self");
			window.close();
		} else if (parent) {
			new EVF.ModalWindow().close(null);
		}
	}
	function doSearch() {
    	var store = new EVF.Store();
    	store.setGrid([grid1]);
        store.load(baseUrl + "BSOX_270/doSearch", function() {
           	//grid1.setProperty('footerrow', true);
           	//grid1.setRowFooter('ITEM_AMT', 'sum', '합 계', 'FINAL_AWARD');

			grid1.setProperty('footerVisible', true);
			var footer = {
				"expression": "sum",
				"styles": {
					"textAlignment": "far",
					"numberFormat": "0,000",
					"fontBold": true
				}
			};

	        <c:forEach varStatus="status" var="columnx" items="${columnInfos}">
				grid1._gvo.setColumnProperty('${columnx.COLUMN_ID}', "footer", footer);
		    </c:forEach>
		    grid1.setProperty('multiselect', false);
        });
	}
    </script>
	<e:window id="BSOX_270" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch" useTitleBar="false">
            <e:row>
            <e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
                <e:field>
                    <e:inputText id="RFX_NUM" name="RFX_NUM" align="center" value="${form.RFX_NUM}" width="100" maxLength="${form_RFX_NUM_M}" disabled="true" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
                    <e:text>/</e:text>
                    <e:inputNumber id="RFX_CNT" name="RFX_CNT" align="center" value="${form.RFX_CNT}" maxValue="${form_RFX_CNT_M}" width="30" decimalPlace="${form_RFX_CNT_NF}" disabled="true" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="true" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>

            </e:row>
            <e:row>
					<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}"/>
					<e:field>
					<e:inputText id="RFX_SUBJECT" style="ime-mode:auto" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="100%" maxLength="${form_RFX_SUBJECT_M}" disabled="true" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}"/>
					</e:field>
	                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
	                <e:field>
	                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='true' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
	                    </e:select>
	                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenType }" width="45%" disabled="true" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
					<e:text> / </e:text>
                    <e:select id="SUBMIT_TYPE" onChange="clearTplNum" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="45%" disabled="true" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>


                <e:label for="PRC_STL_TYPE" title="${form_PRC_STL_TYPE_N}"/>
                <e:field>
                    <e:select id="PRC_STL_TYPE" name="PRC_STL_TYPE" value="${form.PRC_STL_TYPE}" options="${prcStlType }" width="45%" disabled="true" readOnly="${form_PRC_STL_TYPE_RO}" required="${form_PRC_STL_TYPE_R}" placeHolder="" />
                    <e:text> / </e:text>
                    <e:select id="SETTLE_TYPE"  name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" options="${settleType}" width='45%' required='${form_SETTLE_TYPE_R }' readOnly='${form_SETTLE_TYPE_RO }' disabled='true' visible='${form_SETTLE_TYPE_V }' placeHolder='${placeHolder }' />
                </e:field>

            </e:row>
            <e:row>
				<e:label for="RFQ_START_END_DATE" title="${form_RFQ_START_END_DATE_N}"/>
				<e:field colSpan="3">
				<e:text> ${form.RFQ_START_END_DATE } </e:text>
				</e:field>
			</e:row>


        </e:searchPanel>
		<e:buttonBar align="right">
		<%--
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		 --%>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
	</e:window>
</e:ui>