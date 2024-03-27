<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid1 = {};
        var grid2 = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/popup/";

		function init() {

			grid1 = EVF.C('grid1');
			grid1.setProperty('panelVisible', ${panelVisible});
			grid1.excelExportEvent({
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

			grid1.showCheckBar(false);

	        grid1.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

	        	//var rowData = grid1.getColType(grid1.getColidx(celname));

	        	if(celname === "COMMON_ID") {

			        var param = {
	                    COMMON_ID : grid1.getCellValue (rowid,'COMMON_ID')
	                   ,DATABASE_CD : grid1.getCellValue(rowid,'DATABASE_CD')
                        ,POPUPFLAG : "Y"
                        ,detailView : false

				    };
			       	everPopup.openPopupByScreenId('BSYP_020', 900, 700, param);
	            }
			});

			grid1.setProperty('shrinkToFit', false);
        }

        function search() {
            var store = new EVF.Store();
        	store.setGrid([grid1]);
            store.load(baseUrl + 'BSYP_030/doSearch', function() {
                if(grid1.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }
    </script>
    <e:window id="BSYP_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false" onEnter="search">
           <e:row>
               <e:label for="TYPE" title="${form_TYPE_N }" />
                <e:field>
               	 	<e:select id="TYPE" name="TYPE"  value=""  readOnly="${form_TYPE_RO }"   options="${typeOfData}" width="${form_TYPE_W }" required="${form_TYPE_R }" disabled="${form_TYPE_D }" onFocus="onFocus" />
                </e:field>
               <e:label for="COMMON_ID" title="${form_COMMON_ID_N }" />
                <e:field>
                <e:inputText id="COMMON_ID" name="COMMON_ID" style='ime-mode:inactive'  readOnly="${form_COMMON_ID_RO }"   maxLength="${form_COMMON_ID_M}"  value=""  width="${form_COMMON_ID_W }" required="${form_COMMON_ID_R }" disabled="${form_COMMON_ID_D }"  />
                </e:field>
                <e:label for="COMMON_DESC" title="${form_COMMON_DESC_N }" />
                <e:field>
                    <e:inputText id="COMMON_DESC" name="COMMON_DESC" style="${imeMode}"  readOnly="${form_COMMON_DESC_RO }"  maxLength="${form_COMMON_DESC_M}"  value="" width="${form_COMMON_DESC_W }" required="${form_COMMON_DESC_R }" disabled="${form_COMMON_DESC_D }" />
                </e:field>
 			</e:row>


           <e:row>
               <e:label for="DATABASE" title="${form_DATABASE_N }" />
                <e:field>
               	 	<e:select id="DATABASE" name="DATABASE"  value="${empty form_DATABASE ? 'OR' : form_DATABASE}" readOnly="${form_DATABASE_RO }"  options="${databaseCodes}" width="${form_DATABASE_W }" required="${form_DATABASE_R }" disabled="${form_DATABASE_D }" onFocus="onFocus" />
                </e:field>
               <e:label for="SQL_TEXT" title="${form_SQL_TEXT_N }" />
                <e:field>
                <e:inputText id="SQL_TEXT" name="SQL_TEXT" value=""  readOnly="${form_SQL_TEXT_RO }"   maxLength="${form_SQL_TEXT_M}"  width="${form_SQL_TEXT_W }" required="${form_SQL_TEXT_R }" disabled="${form_SQL_TEXT_D }"  />
                </e:field>
                <e:label for="USE_FLAG" title="${form_USE_FLAG_N }" />
                <e:field>
               	 	<e:select id="USE_FLAG" name="USE_FLAG"  value="${empty form_USE_FLAG ? '1' : form_USE_FLAG}"  readOnly="${form_USE_FLAG_RO }"  options="${useFlagOptions}" width="${form_USE_FLAG_W }" required="${form_USE_FLAG_R }" disabled="${form_USE_FLAG_D }" onFocus="onFocus" />
                </e:field>
 			</e:row>

		</e:searchPanel>



         <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />
        </e:buttonBar>

    	<e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}"/>

    </e:window>
</e:ui>