<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/PO0510/";
        var rowId;
        function init() {
            grid = EVF.C("grid");


            grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
                if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_009open(param);
                }/* else if(colId == "VENDOR_CD") {
                	  param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': true,
                            'popupFlag': true
                       };
                	everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } */
            });
            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


	        EVF.C('DEAL_CD').setValue("100");
	        <c:if test = "${form.TYPE == 'A'}">
	        EVF.C('DEAL_CD').setValue("400");
	        </c:if>

	        EVF.C('DEAL_CD').setDisabled(true);
	        EVF.C('STR_CTRL_CODE').removeOption("2000");
	        EVF.C('STR_CTRL_CODE').removeOption("1100");
	        doSearch();
        }

        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "po0510_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }else{
                   var REAL_QTY = '';
                   var SAFE_QTY = '';
                   var rowIds = grid.getAllRowId();
                   for(var i = 0; i < rowIds.length; i++) {
                       REAL_QTY = grid.getCellValue(rowIds[i], "REAL_QTY");
                       SAFE_QTY = grid.getCellValue(rowIds[i], "SAFE_QTY");
                       PO_QTY   = grid.getCellValue(rowIds[i], "PO_QTY");
               		   if(REAL_QTY < SAFE_QTY  ){
               			 grid.setCellFontColor(rowIds[i], 'REAL_QTY', "#ff4c29");
               		    }else{
               		     grid.setCellValue(rowIds[i],"PO_QTY","0");
               		    }
                 	   if(PO_QTY < 0){
                 		  grid.setCellValue(rowIds[i],"PO_QTY","0");
                 	    }
                      }
                   }
                grid.checkAll(false);
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

        function doConfirm(){

         var selRowId = grid.getSelRowId();
         var paramArray = []
         if(selRowId == '' || selRowId == null ){
        	 var param ={'DEAL_CD2' : EVF.V("DEAL_CD") }
         }else{
           for(var i in selRowId) {

        	   var itemStatus = grid.getCellValue(selRowId[i], 'ITEM_STATUS');
			   if (itemStatus == '20' || itemStatus == '30') {  //ITEM_STATUS가 [삭제] [단종] 시 주문안됨
				   return alert("${PO0510_0005}")
				   }

			   var PO_QTY = grid.getCellValue(selRowId[i], 'PO_QTY')
        	   if( PO_QTY == '0' ){ //발주수량 입력
        		   return alert('${PO0510_0004}');
        		   }

        	   var addParam={
                	   'ITEM_CD'  	  : grid.getCellValue(selRowId[i], 'ITEM_CD')
                   	  ,'ITEM_DESC'	  : grid.getCellValue(selRowId[i], 'ITEM_DESC')
                   	  ,'ITEM_SPEC'	  : grid.getCellValue(selRowId[i], 'ITEM_SPEC')
                   	  ,'PO_QTY'   	  : grid.getCellValue(selRowId[i], 'PO_QTY')
                   	  ,'ORIGIN_CD'	  : grid.getCellValue(selRowId[i], 'ORIGIN_CD')
                   	  ,'DEAL_CD'  	  : grid.getCellValue(selRowId[i], 'DEAL_CD')
                   	  ,'MAKER_CD' 	  : grid.getCellValue(selRowId[i], 'MAKER_CD')
                   	  ,'MAKER_NM' 	  : grid.getCellValue(selRowId[i], 'MAKER_NM')
                   	  ,'BRAND_NM' 	  : grid.getCellValue(selRowId[i], 'BRAND_NM')
                   	  ,'LOG_CD'   	  : grid.getCellValue(selRowId[i], 'STR_CTRL_CODE')
                   	  ,'WH_CD'    	  : grid.getCellValue(selRowId[i], 'WAREHOUSE_CODE')
                   	  ,'CUST_ITEM_CD' : grid.getCellValue(selRowId[i], 'CUST_ITEM_CD')
                   	  ,'UNIT_CD' 	  : grid.getCellValue(selRowId[i], 'UNIT_CD')
                      , rowId     	  : rowId
                 	 }
                  paramArray.push(addParam);
           }

         var param ={
                paramArray : JSON.stringify(paramArray)
               ,'CUST_CD' : "${ses.manageCd}"
               ,'CUST_NM' : "${ses.manageComNm}"
               ,'DEAL_CD2': EVF.V("DEAL_CD")
               ,newOrder  : "0"
            }
          }
         everPopup.openPopupByScreenId("PO0550", 1100, 700, param);

        }

    </script>

    <e:window id="PO0510" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
            	<e:field>
               		<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
            	</e:field>
              	<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
            	<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
            	<e:field>
               		<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
          	    </e:field>
			</e:row>
	        <e:row>
	        <e:label for="STR_CTRL_CODE" title="${form_STR_CTRL_CODE_N}"/>
	            <e:field>
	               <e:select id="STR_CTRL_CODE" name="STR_CTRL_CODE" value="" options="${strCtrlCodeOptions}" width="${form_STR_CTRL_CODE_W}" disabled="${form_STR_CTRL_CODE_D}" readOnly="${form_STR_CTRL_CODE_RO}" required="${form_STR_CTRL_CODE_R}" placeHolder="" />
	            </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
                <e:label for="" title="" />
            	<e:field> </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
         <div style="float: right;">
              <e:check id="QTY_FLAG" name="QTY_FLAG" value="1"/><e:text style="font-weight: bold;">재고 부족만 보기</e:text>
              <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
              <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
        </div>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>