<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var baseUrl = "/common/sample/";

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
				,imgHeight     : 0.26       <%-- // 이미지의 높이. --%>
				,colWidth      : 20         <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500        <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

    }

    function doConnect() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'TEST010/doConnect', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    </script>

	<e:window id="WM2020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" onEnter="doSearch">
			<e:row>
				<e:label for="DOMAIN" title="Domain" />
				<e:field>
					<e:inputText id="DOMAIN" style="${imeMode}" name="DOMAIN" value="donghee.co.kr" width="100%" maxLength="9999" disabled="false" readOnly="false" required="true" />
				</e:field>
				<e:label for="USER_ID" title="User ID" />
				<e:field>
					<e:inputText id="USER_ID" style="${imeMode}" name="USER_ID" value="dhsrmadmin" width="100%" maxLength="9999" disabled="false" readOnly="false" required="true" />
				</e:field>
				<e:label for="PASSWORD" title="Password" />
				<e:field>
					<e:inputText id="PASSWORD" style="${imeMode}" name="PASSWORD" value="dGu@st001" width="100%" maxLength="9999" disabled="false" readOnly="false" required="true" />
				</e:field>

			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doConnect" name="doConnect" label="Connection" onClick="doConnect" disabled="false" visible="true" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>
