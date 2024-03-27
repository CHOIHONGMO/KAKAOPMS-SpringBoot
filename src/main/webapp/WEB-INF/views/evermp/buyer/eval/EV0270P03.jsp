<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/EV0270P03';
    var grid;
    var selRow;

    function init() {

        grid = EVF.C('grid');
        grid.showCheckBar(false);
        grid.setProperty('shrinkToFit', true);

        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case '':

            default:
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

    <%-- 조회 --%>
    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) { return;}
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0){
                alert("${msg.M0002 }");
            }
        });
    }




    </script>
<e:window id="EV0270P03" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
    <e:row>
        <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
        <e:field>
            <e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${form_VENDOR_CD_W}" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
        </e:field>
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
        <e:field>
            <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
        </e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>
</e:ui>
