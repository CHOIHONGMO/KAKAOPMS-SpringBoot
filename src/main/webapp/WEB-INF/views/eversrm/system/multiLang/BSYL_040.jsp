<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/multiLang/";

		function init() {

			grid = EVF.C('grid');

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
			    excelOptions : {
					imgWidth      : 0.12,       <%-- // 이미지의 너비. --%>
					imgHeight     : 0.26,      <%-- // 이미지의 높이. --%>
					colWidth      : 20,        <%-- // 컬럼의 넓이. --%>
					rowSize       : 500,       <%-- // 엑셀 행에 높이 사이즈. --%>
			        attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if(celname == "DOMAIN_NM") {
                    var rowValue = grid.getRowValue(rowid);
                    if(opener) {
                        opener['setDomain'](rowValue);
                    } else if(parent) {
                        parent['setDomain'](rowValue);
                    }
            		doClose();
	            }
			});

			doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'doSearchWord', function() {
                if(grid.getRowCount() == 0){
                	//EVF.C('SEARCH_WORD').setValue('');
                }
            });
        }

	    function doClose() {
            new EVF.ModalWindow().close(null);
	    }

    </script>
    <e:window id="BSYL_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="1" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
        	<e:row>
                <e:label for="SEARCH_WORD" title="${form_SEARCH_WORD_N }" />
                <e:field>
                	<e:inputText id="SEARCH_WORD" name="SEARCH_WORD" value="${param.searchWord }" width="${inputTextWidth }" readOnly="${form_SEARCH_WORD_RO }" maxLength="${form_SEARCH_WORD_M }" required="${form_SEARCH_WORD_R }" disabled="${form_SEARCH_WORD_D }" style="ime-mode: inactive;" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>