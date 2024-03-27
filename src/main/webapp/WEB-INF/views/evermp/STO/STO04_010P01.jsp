<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO04_010P01/";
        var RowId = 0;

        function init() {
            grid = EVF.C("grid");

            EVF.C('DEAL_CD').setValue('400');
 		    EVF.C('VENDOR_CD').setValue('${ses.companyCd}');
 		    EVF.C('VENDOR_NM').setValue('${ses.companyNm}');
            EVF.C('DEAL_CD').setDisabled(true);
            EVF.C('VENDOR_CD').setDisabled(true);
            EVF.C('VENDOR_NM').setDisabled(true);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId === "ITEM_CD") {
	                if(value !== ""){
	                    var param = {
	                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
	                        popupFlag: true,
	                        detailView: true
	                    };
	                    everPopup.im03_014open(param);
	                }
             }else if (colId == "VENDOR_NM") {
             	var param = {
                        VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                        detailView: true,
                        popupFlag: true
                    };
                everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
            }


            });
            grid.setColGroup([
            	 {
    				 "groupName" : "기초재고",
    				 "columns"	  : [ "BASE_QTY", "BASE_AMT" ]
    			 },{
            		 "groupName" : "입고",
            		 "columns"   : [{
		            	             "groupName" : "구매입고",
		            	             "columns"   : [ "S_GR_QTY", "S_GR_AMT" ]
	            	           	   },{
		            	              "groupName" : "이동입고",
		            	              "columns"	  : [ "M_GR_QTY", "M_GR_AMT" ]
	            	          	   },{
		            	              "groupName" : "샘플입고",
		            	              "columns"	  : [ "SP_GR_QTY", "SP_GR_AMT"]
	            	           	   },{
		            	              "groupName" : "재고조정입고",
		            	              "columns"	  : [ "J_GR_QTY", "J_GR_AMT"]
	            	               },{
		            	              "groupName" : "기타입고",
		            	              "columns"	  : [ "O_GR_QTY", "O_GR_AMT"]
	            	               }]
            	},{
           		    "groupName" : "출고",
        		    "columns"   : [{
	           		                "groupName" : "판매출고",
	           		                "columns"	: [ "S_GI_QTY", "S_GI_AMT" ]
           		             	  },{
	           		                "groupName" : "불량/폐기출고",
	           		                "columns"	: [ "F_GI_QTY", "F_GI_AMT" ]
           		             	  },{
	           		                "groupName" : "재고조정출고",
	           		                "columns"	: [ "J_GI_QTY", "J_GI_AMT" ]
           		             	  },{
	           		                "groupName" : "기타출고",
	           		                "columns"	: [ "O_GI_QTY", "O_GI_AMT" ]
           		             	  },{
	           		                "groupName" : "이동출고",
	           		                "columns"	: [ "M_GI_QTY", "M_GI_AMT" ]
           		             	  }]
        	    },{
				    "groupName" : "기말재고",
				    "columns"	: [ "CUR_QTY", "CUR_AMT" ]
			    }],80);
            doSearch();
        }

         function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0401p01_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }
         function searchVendorCd() {
             var param = {
                 callBackFunction : "selectVendorCd"
             };
             everPopup.openCommonPopup(param, 'SP0063');
         }

         function selectVendorCd(dataJsonArray) {
             EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
             EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
         }

    </script>

    <e:window id="STO04_010P01" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="RD_DATE" title="${form_RD_DATE_N}"/>
				<e:field>
					<e:inputDate id="RD_DATE" name="RD_DATE" value="${addFromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RD_DATE_R}" disabled="${form_RD_DATE_D}" readOnly="${form_RD_DATE_RO}" />
					<e:text><small style ="color :red"> 1일 부터 선택하신 날짜 까지 조회합니다.</small></e:text>
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
					<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
            	<e:field>
               		<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
          	    </e:field>
			</e:row>
        </e:searchPanel>
        <e:buttonBar align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>