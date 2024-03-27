<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = "/evermp/buyer/eval";
    var grid;
    var selRow;

    function init() {
        grid = EVF.C("grid");

        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
			var params;

        	if(selRow == undefined) selRow = rowId;

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


		var val = {"visible": true, "count": 1, "height": 15};
		grid.setProperty("footerVisible", val);
		grid.setProperty('multiSelect', false);

		var footer = {
			"styles": {
				"textAlignment": "center",
				"fontFmaily": "Nanum Gothic",
				"fontBold": true},
			"text": "평   균"
		};

		var EV_SCORE_TOT_NM = {
			"styles": {
				"textAlignment": "far",
				"numberFormat" : "#,###.0",
				"fontFmaily": "Nanum Gothic",
				"paddingRight": 5,
				"fontBold": true
			},
			"expression": ["avg"],
			"groupExpression": "avg"
		};

		grid.setRowFooter("VENDOR_NM", footer);
		grid.setRowFooter("EV_SCORE_TOT_NM", EV_SCORE_TOT_NM);
    }

    function doSearch() {
        var store = new EVF.Store();
		if(!store.validate()) return;

        store.setGrid([grid]);
        store.load(baseUrl + "/srm280_doSearch", function() {
            if(grid.getRowCount() == 0) {
            	EVF.alert("${msg.M0002 }");
            }
        });
    }

    function onIconClickEV_NUM(){
    	var param = {
			callBackFunction: "callbackEV_NUM"
    	};
    	everPopup.openCommonPopup(param, "SP0069");
    }

    function callbackEV_NUM(data){
    	EVF.C("EV_NUM").setValue(data.EV_NUM);
		EVF.C("EV_NM").setValue(data.EV_NM);
		grid.delAllRow();
    }

	</script>

<e:window id="EV0280" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
		<e:row>
			<e:label for="EV_NUM" title="${form_EV_NUM_N}" />
			<e:field colSpan="5">
				<e:search id="EV_NUM" name="EV_NUM" value="" width="15%" maxLength="${form_EV_NUM_M}" onIconClick="onIconClickEV_NUM" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}" />
				<e:inputText id="EV_NM" name="EV_NM" value="" width="85%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}" />
			</e:field>
		</e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>

    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>
</e:ui>
