<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO04_020/";
        var rowid;
        var selRow;


        function init() {
          grid = EVF.C("grid");
          grid.setProperty('shrinkToFit', true);

          var rowIds = grid.getSelRowId();

          grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
              <%--셀 여러개 선택 방지--%>
                if(selRow == undefined){
                   selRow = rowId;
                }

                if (colId == "multiSelect") {
                   if(selRow != rowId) {
                      grid.checkRow(selRow, false);
                      selRow = rowId;
                   }
                }
                if(colId == 'REG_USER_NM') {
                    if( grid.getCellValue(rowId, 'REG_USER_NM') == '' ) return;
                    var param = {
                        		USER_ID    : grid.getCellValue(rowId, 'REG_USER_ID'),
                        		detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'DOC_NO') {
                    if( grid.getCellValue(rowId, 'DOC_NO') == '' ) return;
                    var param = {
                                YEAR_MONTH : grid.getCellValue(rowId, 'YEAR_MONTH'),
                        		detailView : false
                    };
                    everPopup.openPopupByScreenId("STO04_030", 1100, 800, param);
                }
            });
          doSearch();

         grid.addRowEvent(function() {
           if(!grid.isExistsSelRow()) {
        	    var param={
        	    			 YEAR_MONTH : EVF.V('YEAR')+EVF.V('MONTH')
        	    		    ,C_FLAG    : "마감전"
        	    		};
          	  	grid.addRow(param);
           }else{
           		let rowVal= grid.getCellValue(grid.getAllRowId().length-1,'YEAR_MONTH');
           		let date = new Date(rowVal.substr(0,4),(parseInt(rowVal.substr(4))-1),1);
           		date.setMonth(date.getMonth()+1)
		        var month = (date.getMonth()+1) < 10 ? '0' + (date.getMonth()+1).toString() : (date.getMonth()+1).toString();
           		var param={
           				     YEAR_MONTH : date.getFullYear()+''+month
           					,C_FLAG    : "마감전"
           				};
           		grid.addRow(param);
           	}
         });

         grid.delRowEvent(function() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var delCnt = 0;
                var rowIds = grid.getSelRowId();
                for(var i = rowIds.length -1; i >= 0; i--) {
                    if(!EVF.isEmpty(grid.getCellValue(rowIds[i], "DOC_NO"))) {
                       delCnt++;
                    }else{
                       grid.delRow(rowIds[i]);
                    }
                }
                if(delCnt > 0){
                   return alert("${STO04_020_005}");
                }
            });
        }
        function doSearch() {
            var rowIds = grid.getSelRowId();
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0402_doSearch", function () {

               if(grid.getRowCount() == 0) {
                    return alert('${STO04_020_001}');
                }
            });
        }
        function doConfirm() {
             var store = new EVF.Store();

             if (!store.validate()) { return; }

             var rowIds = grid.getSelRowId();
             let rowVal= grid.getCellValue(grid.getAllRowId().length-1,'YEAR_MONTH');
             let date = new Date(rowVal.substr(0,4),(parseInt(rowVal.substr(4))-1),1);
             date.setMonth(date.getMonth()+1)
             var month = (date.getMonth()+1) < 10 ? '0' + (date.getMonth()+1).toString() : (date.getMonth()+1).toString();

             store.setParameter("NEXT_MONTH" ,  (date.getFullYear()+''+month) );

             if(!grid.isExistsSelRow()) { return alert("${msg.M0004}");}

             if(grid.getCellValue(rowIds, "YEAR_MONTH") > "${NOWMM}") {
                return alert("${STO04_020_0001 }"); //선택한 년월이 현재 년월보다 클때 return
            	 }
             if(grid.getCellValue(rowIds, "REG_DATE") != null && grid.getCellValue(rowIds, "REG_DATE") != '' ){
             	return alert("${STO04_020_014}");
              }  //마감완료(마감일 존재)일 경우 실행 안되게끔

             if(!confirm("${STO04_020_002}")) { return; }

             store.setGrid([grid]);
             store.getGridData(grid, "sel");
             store.load(baseUrl + "sto0402_doConfirm", function() {
             alert(this.getResponseMessage());
             doSearch();
             });
        }
        function doDelete() {
            var store = new EVF.Store();
            if(!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            store.setParameter("YEAR_MONTH",grid.getCellValue(rowIds,"YEAR_MONTH"));

             if(grid.getCellValue(rowIds, "DOC_NO") == null || grid.getCellValue(rowIds, "DOC_NO") == '' ){
        	   		return alert("${STO04_020_012}");
 	    	   }
             if(grid.getCellValue(rowIds, "DOC_NO") != null && grid.getCellValue(rowIds, "REG_DATE") == '' ){
        	   		return alert("${STO04_020_013}");
 	    	   }

            if(!confirm("${STO04_020_009}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "sto0402_doDelete", function() {
                alert(this.getResponseMessage());
                doSearch();
           });
        }
    </script>

    <e:window id="STO04_020" onReady="init" initData="${initData}" title="${fullScreenName}">
      <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
      	 <e:label for="S_YEAR" title="${form_S_YEAR_N}"/>
	  	 <e:field>
		  	<e:select id="S_YEAR" name="S_YEAR" value="${YYYY}" options="${sYearOptions}" width="${form_S_YEAR_W}" disabled="${form_S_YEAR_D}" readOnly="${form_S_YEAR_RO}" required="${form_S_YEAR_R}" placeHolder="" />
      		<e:text>년&nbsp;</e:text>
      	</e:field>
          <e:label for="" title="" />
          <e:field> </e:field>
          <e:label for="" title="" />
          <e:field> </e:field>
      </e:searchPanel>
      <e:panel id="leftP1" height="fit" width="7%">
             <e:text style="font-weight: bold;">●&nbsp;&nbsp;&nbsp;${STO04_020_CAPTION} </e:text>
      </e:panel>
      <e:panel id="leftP2" height="fit" width="43%">
		     <e:select id="YEAR" name="YEAR" value="${YYYY}" options="${yearOptions}" width="98" disabled="${form_YEAR_D}" readOnly="${form_YEAR_RO}" required="${form_YEAR_R}" placeHolder="" />
		     <e:text>년&nbsp;</e:text>
		     <e:select id="MONTH" name="MONTH" value="${MM}" options="${monthOptions}" width="80" disabled="${form_MONTH_D}" readOnly="${form_MONTH_RO}" required="${form_MONTH_R}" placeHolder="" />
		     <e:text><small style= "color : red ;">(마감년월을 선택한 뒤 행추가를 해주세요.)</small></e:text>
         	 </e:panel>
      <e:panel id="rightP1" height="fit" width="50%">
         <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
          </e:buttonBar>
      </e:panel>
      <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>