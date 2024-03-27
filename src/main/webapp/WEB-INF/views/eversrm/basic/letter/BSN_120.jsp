<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/basic/user/";

		function init() {
			grid1 = EVF.C('grid1');
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

        }

        function search() {
            var store = new EVF.Store();
        	store.setGrid([grid1]);
            store.load(baseUrl + 'doSearchUserWorkHistory', function() {
                if(grid1.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }


    </script>
    <e:window id="BSN_120" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="search">
           <e:row>
               <e:label for="REG_DATE" title="${form_REG_DATE_N }" />
                <e:field>
                    <e:inputDate id="ADD_DATE_FROM" name="ADD_DATE_FROM"  readOnly="${form_ADD_DATE_FROM_RO }" value="${fromDate }" width="${inputTextDate }" required="${form_ADD_DATE_N }" disabled="${form_ADD_DATE_N }" datePicker="true" />
                    <e:inputDate id="ADD_DATE_TO" name="ADD_DATE_TO"  readOnly="${form_ADD_DATE_TO_RO }" value="${toDate }" width="${inputTextDate }" required="${form_ADD_DATE_N }" disabled="${form_ADD_DATE_N }" datePicker="true" />
                </e:field>
               <e:label for="JOB_TYPE" title="${form_JOB_TYPE_N }" />
                <e:field>
	                <e:select id="JOB_TYPE" name="JOB_TYPE"  value=""  readOnly="${form_JOB_TYPE_RO }"  options="${refJobType}" width="${inputTextWidth }" required="${form_JOB_TYPE_R }" disabled="${form_JOB_TYPE_D }" onFocus="onFocus"  placeHolder=""/>
                </e:field>
               <e:label for="USER_ID" title="${form_USER_ID_N }" />
                <e:field>
                    <e:inputText id="USER_ID" name="USER_ID"  maxLength="${form_USER_ID_M}" readOnly="${form_USER_ID_RO }" value="" width="${inputTextWidth }" required="${form_USER_ID_N }" disabled="${form_USER_ID_D }" />
                </e:field>
 			</e:row>

		</e:searchPanel>
         <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />
        </e:buttonBar>
    	<e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}"/>
    </e:window>
</e:ui>