<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/menu/menuTemplateGroupCode/";

		function init() {

			grid = EVF.C('grid');
            grid.setProperty('multiselect', false);
            grid.setProperty('shrinkToFit', true);

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

				if(celname == 'TMPL_MENU_GROUP_CD') {

					var selectedData = grid.getRowValue(rowid);

					if('${param.rowid}' !== ''){
						selectedData.rowid = Number('${param.rowid}');
					}
			        opener.${param.callBackFunction}(selectedData);
			        doClose();
			    }
			});

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

			doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'doSelect', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function doClose() {
	        window.close();
	    }

    </script>
    <e:window id="BSYM_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="" columnCount="3" useTitleBar="false" labelWidth="${longLabelWidth }" onEnter="doSearch">
        	<e:row>
                <e:label for="MODULE_TYPE" title="${form_MODULE_TYPE_N }" />
                <e:field>
                    <e:select id="MODULE_TYPE" name="MODULE_TYPE" value="" options="${refModuleType}" readOnly="${form_MODULE_TYPE_RO }" width="100%" required="${form_MODULE_TYPE_R }" disabled="${form_MODULE_TYPE_D }" />
                </e:field>
                <e:label for="TMPL_MENU_GROUP_CD" title="${form_TMPL_MENU_GROUP_CD_N }" />
                <e:field>
                	<e:inputText id="TMPL_MENU_GROUP_CD" name="TMPL_MENU_GROUP_CD" width="100%" required="${form_TMPL_MENU_GROUP_CD_R }" disabled="${form_TMPL_MENU_GROUP_CD_D }" readOnly="${form_TMPL_MENU_GROUP_CD_RO }" maxLength="${form_TMPL_MENU_GROUP_CD_M}" />
                </e:field>
				<e:label for="TMPL_MENU_GROUP_NM" title="${form_TMPL_MENU_GROUP_NM_N }" />
                <e:field>
                	<e:inputText id="TMPL_MENU_GROUP_NM" name="TMPL_MENU_GROUP_NM" width="100%" required="${form_TMPL_MENU_GROUP_NM_R }" disabled="${form_TMPL_MENU_GROUP_NM_D }" readOnly="${form_TMPL_MENU_GROUP_NMD_RO }" maxLength="${form_TMPL_MENU_GROUP_NM_M}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <%-- <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" /> --%>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>