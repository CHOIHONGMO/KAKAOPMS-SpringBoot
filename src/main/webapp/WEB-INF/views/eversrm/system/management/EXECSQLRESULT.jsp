<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var cnt = 0;
        var baseUrl = '/eversrm/system/management/EXECSQL';
        var grid1 = {};
        function init() {
        	
        	if(${_gridType eq "RG"}) {
            	grid1 = new EVF.C('grid1');
        	} else {
        		grid1 = new EVF.GridPanel('grid1');
        	}
            <c:forEach varStatus="status" var="columnx" items="${COLUNM}">
        		grid1.createColumn('${columnx}', '${columnx}', 130, 'center', 'text', 50, false,false, '', 0);
			</c:forEach>

        	if(${_gridType eq "RG"}) {
        	} else {
    			grid1.boundColumns();

    			grid1.setProperty('footerrow', true);
    			grid1.setProperty('multiselect', false);
        	}
			
			
			grid1.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth : 0.12, // 이미지의 너비.
					imgHeight : 0.26, // 이미지의 높이.
					colWidth : 20, // 컬럼의 넓이.
					rowSize : 500, // 엑셀 행에 높이 사이즈.
					attachImgFlag : false
				// 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부
				}
			});

	    	<c:if test="${param.TYPE=='S'}">
				doSearch();
	    	</c:if>
	    	<c:if test="${param.TYPE=='T'}">
				alert('${message}');
	    	</c:if>
        }
        
        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid1]);
            store.load(baseUrl+'/doSearch', function() {
				$('.e-panel-titlebar').css('width', '');
			});
        }

    </script>

    <e:window id="EXECSQLRESULT" onReady="init" initData="${initData}">
        <e:searchPanel id="form" title="SQL" columnCount="1" useTitleBar="true">
            <e:row>
                <e:label for="MESSAGE1" title="SQL"/>
                <e:field>
                    <e:textArea id="SQL" name="SQL" value="${param.SQL }" required="" disabled="" readOnly="" maxLength="" width="100%" height="200"/>
                </e:field>
            </e:row>
        </e:searchPanel>

		<e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>