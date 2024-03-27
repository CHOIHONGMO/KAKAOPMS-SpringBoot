<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/board/email/";

		function init() {
			grid = EVF.C('grid');
			grid.setProperty('shrinkToFit', true);
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

	        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if(celname == 'SUBJECT') {
			        var param = {
			        			MSG_NUM : grid.getCellValue(rowid,'MSG_NUM')
			        		   ,GATE_CD  : grid.getCellValue(rowid,'GATE_CD')
			                   ,detailView    : "true"
			                   ,havePermission : false
				    };

			        everPopup.openPopupByScreenId('BSN_130', 950, 580, param);
	            }

			});

	        search();
        }

        function search() {
            var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + '/BSN_110/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }


        function delete2() {
  			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
        	if (!confirm("${msg.M0013 }")) return;
	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + '/BSN_110/doDelete', function(){
        		alert(this.getResponseMessage());
        		search();
        	});
        }



    </script>
    <e:window id="BSN_110" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="180" width="100%" columnCount="2" onEnter="search">
           <e:row>
               <e:label for="REG_DATE" title="${form_addDateFrom_N }" />
                <e:field>
				<e:inputDate id="addDateFrom" name="addDateFrom" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_addDateFrom_R}" disabled="${form_addDateFrom_D}" readOnly="${form_addDateFrom_RO}" />
				<e:text>~&nbsp;</e:text>
				<e:inputDate id="addDateTo" name="addDateTo" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_addDateTo_R}" disabled="${form_addDateTo_D}" readOnly="${form_addDateTo_RO}" />
                </e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N}"/>
				<e:field>
				<e:inputText id="USER_NM" name="USER_NM" value="${form.USER_NM}" width="100%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				 </e:field>
 			</e:row>
          <e:row>
				 <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
				<e:field>
				<e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				 </e:field>
				 <e:label for="RECIPIENT_COMPANY_NM" title="${form_RECIPIENT_COMPANY_NM_N}"/>
				<e:field>
				<e:inputText id="RECIPIENT_COMPANY_NM" name="RECIPIENT_COMPANY_NM" value="${form.RECIPIENT_COMPANY_NM}" width="100%" maxLength="${form_RECIPIENT_COMPANY_NM_M}" disabled="${form_RECIPIENT_COMPANY_NM_D}" readOnly="${form_RECIPIENT_COMPANY_NM_RO}" required="${form_RECIPIENT_COMPANY_NM_R}" />
				 </e:field>
			</e:row>

		</e:searchPanel>
         <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="delete2" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>
    	<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>