<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BOD1/BOD101/";
        var ROW_ID;

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('sortable', false);

            grid.cellClickEvent(function(rowId, colId, value) {

            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
               if(colId == "CPO_QTY") {
                   var CPO_ITEM_AMT = grid.getCellValue(rowId, "CPO_QTY") * grid.getCellValue(rowId, "CPO_UNIT_PRICE");
                   var PO_ITEM_AMT = grid.getCellValue(rowId, "CPO_QTY") * grid.getCellValue(rowId, "PO_UNIT_PRICE");
                   grid.setCellValue(rowId, "CPO_ITEM_AMT", CPO_ITEM_AMT);
                   grid.setCellValue(rowId, "PO_ITEM_AMT", PO_ITEM_AMT);

	   				var cpoAmt = 0;
		            var rows = grid.getSelRowValue();
		            for( var i = 0; i < rows.length; i++ ) {
		            	cpoAmt+=rows[i].CPO_ITEM_AMT;
		            }
					EVF.C("CPO_AMT").setValue(cpoAmt);

               }
           	});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            doSearch();
        }
        function doClose() {
            window.close();
        }

        function doSearch() {
			if ('${param.bkList}' !='') {
				var obj = JSON.parse('${param.bkList}');
				grid.addRow(obj);
				var cpoAmt = 0;
	            var rows = grid.getSelRowValue();
	            for( var i = 0; i < rows.length; i++ ) {
	            	cpoAmt+=rows[i].CPO_ITEM_AMT;
	            }
				EVF.C("CPO_AMT").setValue(cpoAmt);

			} else {
	            var store = new EVF.Store();
	            if (!store.validate()) { return; }
	            store.setGrid([grid]);
	            store.load(baseUrl + "bod1111Dosearch", function () {
					var cpoAmt = 0;
		            var rows = grid.getAllRowValue();
		            for( var i = 0; i < rows.length; i++ ) {
		            	cpoAmt+=rows[i].CPO_ITEM_AMT;
		            }
					EVF.C("CPO_AMT").setValue(cpoAmt);
	            });
			}
        }

        function doBack() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            if(!confirm('${BOD1_111_001}')) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.load(baseUrl + 'doBack', function() {
                alert(this.getResponseMessage());
                doClose();
            });
        }



        function onIconClickCPO_USER_NM() {

            var rows = grid.getSelRowValue();
            var temp_cust_cd = rows[0].CUST_CD;
            var temp_plant_cd = rows[0].PLANT_CD;
            var param = {
                callBackFunction : "callbackCPO_USER_NM",
                custCd: temp_cust_cd,
				plantCd : temp_plant_cd
            };
            everPopup.openCommonPopup(param, 'SP0083');
        }

        function callbackCPO_USER_NM(data) {
            EVF.C("CPO_USER_ID").setValue(data.USER_ID);
            EVF.C("CPO_USER_NM").setValue(data.USER_NM);

        }


    </script>

    <e:window id="BOD1_111" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar width="100%" align="right">

			<c:if test="${param.CPO_NO=='' || param.CPO_NO==null}">
				<e:button id="doBack" name="doBack" label="${doBack_N}" onClick="doBack" disabled="${doBack_D}" visible="${doBack_V}"/>
			</c:if>

			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
        	<e:inputHidden id="PR_TYPE" name="PR_TYPE" value="R"/>
        	<e:inputHidden id="PO_NO" name="PO_NO" value="${param.PO_NO}"/>

			<e:row>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="${form.CPO_NO}" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				</e:field>
				<e:label for="CPO_DATE" title="${form_CPO_DATE_N}"/>
				<e:field>
				<e:inputDate id="CPO_DATE" name="CPO_DATE" value="${TO_DAY}" width="${inputDateWidth}" datePicker="true" required="${form_CPO_DATE_R}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}" />
				<e:field>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="${form.PR_SUBJECT}" width="${form_PR_SUBJECT_W}" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
				<e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}"/>
				<e:field>
				<e:search id="CPO_USER_NM" name="CPO_USER_NM" value="${form.CPO_USER_NM}" width="${form_CPO_USER_NM_W}" maxLength="${form_CPO_USER_NM_M}" onIconClick="${form_CPO_USER_NM_RD ? 'everCommon.blank' : 'onIconClickCPO_USER_NM'}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				<e:inputHidden id="CPO_USER_ID" name="CPO_USER_ID" value="${form.CPO_USER_ID}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CPO_AMT" title="${form_CPO_AMT_N}"/>
				<e:field>
				<e:inputNumber id="CPO_AMT" name="CPO_AMT" value="${form.CPO_AMT}" width="${form_CPO_AMT_W}" maxValue="${form_CPO_AMT_M}" decimalPlace="${form_CPO_AMT_NF}" disabled="${form_CPO_AMT_D}" readOnly="${form_CPO_AMT_RO}" required="${form_CPO_AMT_R}" />
				</e:field>
				<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
				<e:field>
				<e:inputDate id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="${form.HOPE_DUE_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="RMKS" title="${form_RMKS_N}"/>
				<e:field colSpan="3">
				<e:textArea id="RMKS" name="RMKS" value="${form.RMKS}" height="100px" width="100%" maxLength="${form_RMKS_M}" disabled="${form_RMKS_D}" readOnly="${form_RMKS_RO}" required="${form_RMKS_R}" />
				</e:field>
			</e:row>
        </e:searchPanel>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>