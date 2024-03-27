<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var grid;
        var baseUrl = "/evermp/SIV1/SIV101/";

        function init() {
         grid = EVF.C("grid");
         grid.setProperty("shrinkToFit", true);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
               if(colId == "DELY_DELAY_NM") {
               var param = {
                        title : '납품지연사유',
                        CODE  : grid.getCellValue(rowId, 'DELY_DELAY_CD'),
                          TEXT  : grid.getCellValue(rowId, 'DELY_DELAY_REASON'),
                          rowId : rowId,
                        callBackFunction : 'setGridDelyText',
                          detailView : 'false'
                    };
               var url = '/evermp/SIV1/SIV101/SIV1_022/view';
                 everPopup.openModalPopup(url, 600, 360, param);
            }
            });

         grid.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
            if(colId == "INV_QTY") {
               var sum = 0;
               var INV_QTY = Number(EVF.V("INV_QTY"));
               var rows = grid.getAllRowId();
               for( var i = 0; i < rows.length; i++ ) {
                  sum += Number(grid.getCellValue(rows[i], "INV_QTY"));
               }
               INV_RE_QTY = INV_QTY - sum;
               EVF.V("INV_RE_QTY", comma(String(INV_RE_QTY)));
            }
            });

            grid.addRowEvent(function() {
                grid.addRow([{
                   INSERT_FLAG : 'I',
                   PO_NO  : EVF.V("PO_NO"),
                   PO_SEQ : EVF.V("PO_SEQ"),
                   CPO_NO  : EVF.V("CPO_NO"),
                   CPO_SEQ  : EVF.V("CPO_SEQ"),
                   CUST_CD  : EVF.V("CUST_CD"),
                   IF_CPO_NO_SEQ : EVF.V("IF_CPO_NO_SEQ")
                }]);
            });

         grid.delRowEvent(function() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            grid.delRow();
         });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doAddLineFill();
        }

        function doAddLineFill(){
          for( var i = 0; i < 1; i++) {
             grid.addRow([{
                   INSERT_FLAG : 'I',
                   PO_NO  : '${param.PO_NO}',
                   PO_SEQ : '${param.PO_SEQ}',
                   CPO_NO : '${param.CPO_NO}',
                   CPO_SEQ : '${param.CPO_SEQ}',
                   CUST_CD  : EVF.V("CUST_CD"),
                   IF_CPO_NO_SEQ : EVF.V("IF_CPO_NO_SEQ"),
                   DELY_APP_DATE : '${param.DELY_APP_DATE}'
                }]);
          }
       }

        function doCreateInvoice() {
           var lUrl="";
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var sum = 0;
            var INV_QTY = Number(EVF.V("INV_QTY"));

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
               for( var j in rowIds ) {
                  if( i == j ) continue;
                  if( grid.getCellValue(rowIds[i], 'DELY_APP_DATE') == grid.getCellValue(rowIds[j], 'DELY_APP_DATE') ) {
                     return alert("${SIV1_021_005}");
                  }
               }

               if(INV_QTY > 0) {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) <= 0 ) {
                        return alert("${SIV1_021_001}");
                    }
                } else {
                    if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) >= 0 ) {
                        return alert("${SIV1_021_006}");
                    }
                }

              if( everString.replaceAll(EVF.V("HOPE_DUE_DATE"), "-", "") < grid.getCellValue(rowIds[i], "DELY_APP_DATE") ) {
                 if( everString.lrTrim(grid.getCellValue(rowIds[i], "DELY_DELAY_CD")) == "" ) {
                    //return alert("${SIV1_021_002 }");
                 }
              }
              sum = Number(sum) + Number(grid.getCellValue(rowIds[i], "INV_QTY"));
          }

            if(INV_QTY > 0) {
                if(sum > INV_QTY) {
                    return alert("${SIV1_021_004 }");
                }
            } else {
                if(sum < INV_QTY) {
                    return alert("${SIV1_021_004 }");
                }
            }

            if(!confirm('${SIV1_021_003}')) { return; }

            <c:if test="${param.ODFLAG == 'ODFLAG'}"> // 출하지시일 경우 출하로 매핑
               lUrl="/SIV1_020/doOdCreateInvoice"
            </c:if>
         	<c:if test="${param.ODFLAG != 'ODFLAG'}">
            lUrl="/SIV1_020/doCreateInvoice";
            </c:if>
            console.log(lUrl)

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+lUrl, function() {
               alert(this.getResponseMessage());
               if (opener != null) {
                    opener['${param.callBackFunction}']();
                } else {
                    parent['${param.callBackFunction}']();
                }
               doClose();
            });
        }

        function setGridDelyText(data){
              grid.setCellValue(data.rowId, "DELY_DELAY_CD", data.code);
              grid.setCellValue(data.rowId, "DELY_DELAY_NM", data.code_nm);
              grid.setCellValue(data.rowId, "DELY_DELAY_REASON", data.text);
          }

        function doClose() {
           if (opener != null) {
                window.close();
            } else {
                new EVF.ModalWindow().close(null);
            }
        }

      function comma(obj) {
         var regx = new RegExp(/(-?\d+)(\d{3})/);
         var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
         var strArr = obj.split('.');
         while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
            //정수 부분에만 콤마 달기
            strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
         }
         if (bExists > -1) {
            //. 소수점 문자열이 발견되지 않을 경우 -1 반환
            obj = strArr[0] + "." + strArr[1];
         } else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
            obj = strArr[0];
         }
         return obj;//문자열 반환
      }

    </script>

    <e:window id="SIV1_021" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${param.CUST_CD }" />
            <e:inputHidden id="CPO_NO" name="CPO_NO" value="${param.CPO_NO }" />
            <e:inputHidden id="CPO_SEQ" name="CPO_SEQ" value="${param.CPO_SEQ }" />
            <e:inputHidden id="PO_NO" name="PO_NO" value="${param.PO_NO }" />
            <e:inputHidden id="PO_SEQ" name="PO_SEQ" value="${param.PO_SEQ }" />
            <e:inputHidden id="PO_UNIT_PRICE" name="PO_UNIT_PRICE" value="${param.PO_UNIT_PRICE }" />
            <e:inputHidden id="INV_QTY" name="INV_QTY" value="${param.INV_QTY }" />
            <e:inputHidden id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="${param.HOPE_DUE_DATE }" />
            <e:inputHidden id="RECIPIENT_NM" name="RECIPIENT_NM" value="${param.RECIPIENT_NM }" />
            <e:inputHidden id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" value="${param.RECIPIENT_DEPT_NM }" />
            <e:inputHidden id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" value="${param.RECIPIENT_TEL_NUM }" />
            <e:inputHidden id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${param.RECIPIENT_CELL_NUM }" />
            <e:inputHidden id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${param.DELY_ZIP_CD }" />
            <e:inputHidden id="DELY_ADDR_1" name="DELY_ADDR_1" value="${param.DELY_ADDR_1 }" />
            <e:inputHidden id="DELY_ADDR_2" name="DELY_ADDR_2" value="${param.DELY_ADDR_2 }" />
            <e:inputHidden id="DEAL_CD" name="DEAL_CD" value="${param.DEAL_CD }" />
            <e:inputHidden id="IF_CPO_NO_SEQ" name="IF_CPO_NO_SEQ" value="${param.IF_CPO_NO_SEQ }" />


            <e:row>
            <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
            <e:field>
               <e:text>${param.CUST_NM }</e:text>
            </e:field>
            <e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}" />
            <e:field>
               <e:text>${param.CPO_USER_DEPT_NM } / ${param.CPO_USER_NM }</e:text>
            </e:field>
            </e:row>
            <e:row>
            <e:label for="CPO_NO" title="${form_CPO_NO_N}" />
            <e:field>
               <e:text>${param.CPO_NO }</e:text>
            </e:field>
            <e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
            <e:field>
               <e:text>${param.HOPE_DUE_DATE }</e:text>
            </e:field>
         </e:row>
            <e:row>
            <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
            <e:field>
               <e:text>${param.ITEM_CD }</e:text>
            </e:field>
            <e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}" />
            <e:field>
               <e:text>${param.CUST_ITEM_CD }</e:text>
            </e:field>
            </e:row>
            <e:row>
            <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
            <e:field colSpan="3">
               <e:text>${param.ITEM_DESC }</e:text>
            </e:field>
            </e:row>
            <e:row>
            <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
            <e:field colSpan="3">
               <e:text>${param.ITEM_SPEC }</e:text>
            </e:field>
            </e:row>
            <e:row>
            <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
            <e:field>
               <e:text>${param.MAKER_NM }</e:text>
            </e:field>
            <e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
            <e:field>
               <e:text>${param.MAKER_PART_NO }</e:text>
            </e:field>
            </e:row>
            <e:row>
            <e:label for="BRAND_NM" title="${form_BRAND_NM_N}" />
            <e:field>
               <e:text>${param.BRAND_NM }</e:text>
            </e:field>
            <e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
            <e:field>
               <e:text>${param.UNIT_CD }</e:text>
            </e:field>
            </e:row>
            <e:row>
            <e:label for="CPO_QTY" title="${form_CPO_QTY_N}"/>
            <e:field>
               <e:text>${param.CPO_QTY }</e:text>
            </e:field>
            <e:label for="INV_QTY" title="${form_INV_QTY_N}"/>
            <e:field>
               <e:text>${param.INV_QTY }</e:text>
            </e:field>
            </e:row>
        </e:searchPanel>
      <e:panel id="Panel5" height="fit" width="30%">
         <e:text style="color:red;font-weight:bold;font-size:14px;">잔량 : </e:text>
         <e:text id="INV_RE_QTY" name="INV_RE_QTY" style="color:red;font-weight:bold;font-size:14px;"></e:text>
      </e:panel>
      <e:panel id="Panel6" height="fit" width="70%">
         <e:buttonBar align="right" width="100%">
            <e:button id="doCreateInvoice" name="doCreateInvoice" label="${doCreateInvoice_N}" onClick="doCreateInvoice" disabled="${doCreateInvoice_D}" visible="${doCreateInvoice_V}"/>
         </e:buttonBar>
      </e:panel>

      <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>