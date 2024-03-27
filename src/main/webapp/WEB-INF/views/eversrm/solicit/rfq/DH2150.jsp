
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {

        grid = EVF.getComponent("grid");
		grid.setProperty('shrinkToFit', true);

        //버튼 제어 - 견적서 제출후 저장못하게 처리
        var buttonStatus = '${param.buttonStatus}';
        if (buttonStatus == 'Y') {
            EVF.C('doSave').setVisible(true);
        }else{
            EVF.C('doSave').setVisible(false);
        }

        grid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        if ('${param.COST_NUM}' !== '') {
            doSearch();
        } else {

            <c:if test="${param.COST_TEXT != null && param.COST_TEXT != ''}">

            var kkk = ${param.COST_TEXT};
//        	var data = JSON.parse(kkk);
            var arrData = [];
        	for (var k = 0; k < kkk.length; k++) {
                arrData.push({
                	COST_TYPE_CD          : kkk[k].COST_TYPE_CD,
                	COST_TEXT    : kkk[k].COST_TEXT
                });

        	}
        	grid.addRow(arrData);



            </c:if>




        }

        grid.cellChangeEvent(function(rowId, celName, iRow, iCol, value, oldValue) {
            if (celName === 'UNIT_PRC') {
                if (Number(value) < 0) {
                    //alert('${DH2150_0002}');
                    //grid.setCellValue(rowId, celName, oldValue);
                    //return;
                }
                calculateSum();
            }
        });

    	<c:if test="${param.MOLD_YN != '1'}">
	        grid.addRowEvent(function() {
	        	grid.addRow();
			});

			grid.delRowEvent(function() {
				if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
		            alert("선택된 데이터가 없습니다.");
		            return;
		        }
				grid.delRow();
				calculateSum();
			});
		</c:if>
    	<c:if test="${param.MOLD_YN == '1'}">
    		for(var k=0;k<grid.getRowCount();k++)	{
	    		grid.setCellReadOnly(k, 'COST_TYPE_CD', true);
    		}
		</c:if>

    }


    function fileAttachCallback(result) {
        EVF.getComponent('ATT_FILE_NUM').setValue(result.UUID);
    }

    function fileAttachPopupCallback(fileInfo) {
        //grid.setCellValue('ATTACH_FILE_COUNT', fileInfo.nRow, fileInfo.FILE_COUNT);
        grid.setCellValue('ATT_FILE_NUM', fileInfo.nRow, fileInfo.UUID);
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "DH2150/doSearch", function() {
        });
    }

  	//Grid 금액 계산
    function calculateSum() {
        var tAmt = 0;
        var rowData = grid.getAllRowId();

		for ( var nRow in rowData) {
            var amt = grid.getCellValue(nRow, 'UNIT_PRC');
            tAmt = Number(tAmt) + Number(amt);
		}

        EVF.getComponent('RAW_COST_AMT').setValue(tAmt);
        sumFinalAmt();
    }

	//Form 금액들 계산
    function sumFinalAmt() {
    	var finalAmt = 0;
    	var rawCostAmt = EVF.getComponent('RAW_COST_AMT').getValue();
    	var mngtCostAmt = EVF.getComponent('MNGT_COST_AMT').getValue();
    	var profitAmt = EVF.getComponent('PROFIT_AMT').getValue();

    	finalAmt = Number(finalAmt) + Number(rawCostAmt) + Number(mngtCostAmt) + Number(profitAmt);
    	EVF.getComponent('FINAL_AMT').setValue(finalAmt);
    }


	function doSave() {

    	var store = new EVF.Store();
        if(!store.validate()) return;

        grid.checkAll(true);
        var valid = grid.validate()
		, selRows = grid.getSelRowValue();

    	if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
		if (!grid.validate().flag) {
			alert("${msg.M0014}");
		    return;
		}

		for( var i = 0, len = selRows.length; i < len; i++ ) {
			if( Number(selRows[i].UNIT_PRC) == 0 ){
				alert(everString.getMessage("${msg.M0108}", "금액")); return;
			}
		}

		var mngCostAmt = EVF.getComponent('MNGT_COST_AMT').getValue();
		var profitAmt = EVF.getComponent('PROFIT_AMT').getValue();

		if(mngCostAmt == "") mngCostAmt == "0";
		if(profitAmt == "") profitAmt == "0";

		if (Number(mngCostAmt) == 0) {
			//alert(everString.getMessage("${msg.M0109}", "판매/일반 관리비")); return;
        }
		if (Number(profitAmt) == 0) {
			//alert(everString.getMessage("${msg.M0109}", "기업이윤")); return;
        }


    	if (!confirm("${msg.M0021}")) return;
    	var oRowid = '${param.rowid}';


        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.doFileUpload(function() {
	        store.load(baseUrl + "DH2150/doSave", function() {
	        	var COSTNUM = this.getParameter("COST_NUM");

	            alert(this.getResponseMessage());
	            if (opener !== undefined && opener.setCostItemNeed !== undefined){
	            	var finalAmt = EVF.getComponent('FINAL_AMT').getValue();
	            	opener.setCostItemNeed(COSTNUM, oRowid, finalAmt);
	            }
	            window.close();
	        });
        });
    }


    function doClose() {
        formUtil.close();
    }

	</script>

    <e:window id="DH2150" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">

    <e:inputHidden id="COST_NUM" name="COST_NUM" value="${param.COST_NUM}" />
    <e:inputHidden id="COST_CD" name="COST_CD" value="${param.COST_CD}" />

        <e:buttonBar>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' align="right" />
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled="${doSave_D }" visible="${doSave_V }" align="right"/>
        </e:buttonBar>

        <e:searchPanel id="form2" useTitleBar="true" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field colSpan="3">
				<e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${param.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
				<e:field colSpan="3">
				<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${param.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
				<e:field>
				<e:inputText id="ITEM_SPEC" style="${imeMode}" name="ITEM_SPEC" value="${param.ITEM_SPEC}" width="100%" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}"/>
				</e:field>
				<e:label for="RFX_QT" title="${form_RFX_QT_N}"/>
				<e:field>
				<e:inputNumber id="RFX_QT" name="RFX_QT" value="${param.RFX_QT}" maxValue="${form_RFX_QT_M}" decimalPlace="${form_RFX_QT_NF}" disabled="${form_RFX_QT_D}" readOnly="${form_RFX_QT_RO}" required="${form_RFX_QT_R}" />
				</e:field>
			</e:row>
            <e:row>


			</e:row>
		</e:searchPanel>

        <e:searchPanel id="form" useTitleBar="true" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
                <e:label for="RAW_COST_AMT" title="${form_RAW_COST_AMT_N}"/>
				<e:field>
				<e:inputNumber id="RAW_COST_AMT" name="RAW_COST_AMT" width="${inputNumberWidth }" value="${form.RAW_COST_AMT}" maxValue="${form_RAW_COST_AMT_M}" decimalPlace="${form_RAW_COST_AMT_NF}" disabled="${form_RAW_COST_AMT_D}" readOnly="${form_RAW_COST_AMT_RO}" required="${form_RAW_COST_AMT_R}" />
				</e:field>
				<e:label for="MNGT_COST_AMT" title="${form_MNGT_COST_AMT_N}"/>
				<e:field>
				<e:inputNumber id="MNGT_COST_AMT" name="MNGT_COST_AMT" width="${inputNumberWidth }" value="${form.MNGT_COST_AMT}" onChange="sumFinalAmt" maxValue="${form_MNGT_COST_AMT_M}" decimalPlace="${form_MNGT_COST_AMT_NF}" disabled="${form_MNGT_COST_AMT_D}" readOnly="${form_MNGT_COST_AMT_RO}" required="${form_MNGT_COST_AMT_R}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="PROFIT_AMT" title="${form_PROFIT_AMT_N}"/>
				<e:field>
				<e:inputNumber id="PROFIT_AMT" name="PROFIT_AMT" width="${inputNumberWidth }" value="${form.PROFIT_AMT}" onChange="sumFinalAmt" maxValue="${form_PROFIT_AMT_M}" decimalPlace="${form_PROFIT_AMT_NF}" disabled="${form_PROFIT_AMT_D}" readOnly="${form_PROFIT_AMT_RO}" required="${form_PROFIT_AMT_R}" />
				</e:field>
				<e:label for="FINAL_AMT" title="${form_FINAL_AMT_N}"/>
				<e:field>
				<e:inputNumber id="FINAL_AMT" name="FINAL_AMT" width="${inputNumberWidth }" value="${form.FINAL_AMT}" maxValue="${form_FINAL_AMT_M}" decimalPlace="${form_FINAL_AMT_NF}" disabled="${form_FINAL_AMT_D}" readOnly="${form_FINAL_AMT_RO}" required="${form_FINAL_AMT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="COST_RMK" title="${form_COST_RMK_N}"/>
				<e:field colSpan="3">
				<e:textArea id="COST_RMK" name="COST_RMK" height="100px" value="${form.COST_RMK}" width="100%" maxLength="${form_COST_RMK_M}" disabled="${form_COST_RMK_D}" readOnly="${form_COST_RMK_RO}" required="${form_COST_RMK_R}" />
				 </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" height="120px" bizType="QTA" fileId="${form.ATT_FILE_NUM}" width="100%"  readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}" />

                </e:field>
            </e:row>
        </e:searchPanel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>