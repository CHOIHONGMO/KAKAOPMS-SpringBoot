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


		var val = {"visible": true, "count": 2, "height": 50};
		grid.setProperty("footerVisible", val);
		grid.setProperty('multiSelect', false);
    }

    function doSearch() {
        var store = new EVF.Store();
		if(!store.validate()) return;

        store.setGrid([grid]);
        store.load(baseUrl + "/srm290_doSearch", function() {
            if(grid.getRowCount() == 0) {
            	EVF.alert("${msg.M0002 }");
            } else {
            	var allRowId = grid.getAllRowId();
				var allRowValue = grid.getAllRowValue();

				var vendorCnt = [];
				for(var j in allRowId) {
					var rowIdJ = allRowId[j];
					var rowValueJ = allRowValue[j];

					var ii = 0;
					for(var kk in rowValueJ) {
						if(kk != "VENDOR_NM" && kk != "VENDOR_EV_SCORE_AVG" && kk != "VENDOR_RMK" && kk != "AMEND_SCORE" && kk != "CONT_DESC") {
							if(vendorCnt[ii] == undefined) vendorCnt[ii] = 0;

							if (grid.getCellValue(rowIdJ, kk) != "") {
								vendorCnt[ii]++;
							}

							ii++;
						}
					}
				}

            	for(var i in allRowId) {
            		var rowId = allRowId[i];
					var rowValue = allRowValue[i];
					var sum = 0;
					var cnt = 0;
					ii = 0;

					for(var k in rowValue) {
						if(k != "VENDOR_NM" && k != "VENDOR_EV_SCORE_AVG" && k != "VENDOR_RMK" && k != "AMEND_SCORE" && k != "CONT_DESC") {
							if(grid.getCellValue(rowId, k) != "") {
								sum += Number(grid.getCellValue(rowId, k));
								cnt++;
							}

							var exp_avg = "sum['" + k + "'] / " + vendorCnt[ii];
							var exp_count = vendorCnt[ii] + "";
							var AVG = {
								styles: [{
									textAlignment: "center",
									numberFormat: "#,###.0",
									fontFmaily: "Nanum Gothic",
									paddingRight: 5,
									suffix: "",
									fontBold: true
								}, {
									textAlignment: "center",
									numberFormat: "#,###.#",
									fontFmaily: "Nanum Gothic",
									paddingRight: 5,
									suffix: "개",
									fontBold: true
								}],
								expression: [exp_avg, exp_count]
							};

							grid.setRowFooter(k, AVG);

							ii++;
						}
					}

					grid.setCellValue(rowId, "VENDOR_EV_SCORE_AVG",  everMath.round_float(sum/cnt, 1));
				}

				for(var l in allRowId) {
					var AVG_AVG = {
						styles: [{
							textAlignment: "center",
							numberFormat: "#,###.0",
							fontFmaily: "Nanum Gothic",
							paddingRight: 5,
							suffix: "",
							fontBold: true
						}, {
							textAlignment: "center",
							numberFormat: "#,###.#",
							fontFmaily: "Nanum Gothic",
							paddingRight: 5,
							suffix: "개",
							fontBold: true
						}],
						expression: ["sum['VENDOR_EV_SCORE_AVG'] / count", "count"]
					};

					grid.setRowFooter("VENDOR_EV_SCORE_AVG", AVG_AVG);
				}

				var footer = {
					"styles": {
						"textAlignment": "center",
						"fontFmaily": "Nanum Gothic",
						"fontBold": true},
					"text": ["평   균", "파트너사 수"]
				};

				grid.setRowFooter("VENDOR_NM", footer);
				grid._gvo.setColumnProperty("VENDOR_EV_SCORE_AVG", "styles", {numberFormat: "#,###.0"});
			}
        });
    }

    function onIconClickEV_NUM(){
    	for(var j in grid.columns) {
    		grid.removeColumn(grid.columns[j].name);

		}
    	var param = {
			callBackFunction: "callbackEV_NUM"
    	};
    	everPopup.openCommonPopup(param, "SP0067");
    }

    function callbackEV_NUM(data){
    	EVF.C("EV_NUM").setValue(data.EV_NUM);
		EVF.C("EV_NM").setValue(data.EV_NM);

		if(EVF.V("EV_NUM") != "") {
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + "/srm290_doSearchUSER", function() {
				var col;
				var cnt = 0;
				var columns = [];
				var colList = JSON.parse(this.data.colList);

				for(var i in colList) {
					if(colList[i].COLUMN_ID == "VENDOR_NM" || colList[i].COLUMN_ID == "VENDOR_RMK" || colList[i].COLUMN_ID == "CONT_DESC") {
						// grid.createColumn(colList[i].COLUMN_ID, colList[i].COLUMN_NM, 150, "left", "text", 50, false, false, "", 0);
						grid.addColumn(colList[i].COLUMN_ID, colList[i].COLUMN_NM, 150, "left", "text", 50, false, false, "", 0);
						// col = {
						// 	name: colList[i].COLUMN_ID,
						// 	fieldName: colList[i].COLUMN_ID,
						// 	header: {text: colList[i].COLUMN_NM},
						// 	width: 150,
						// 	colType: "text",
						// 	editable: false
						// };
					} else {
						// grid.createColumn(colList[i].COLUMN_ID, colList[i].COLUMN_NM, 110, "right", "number", 50, false, false, "", 0);
						if(colList[i].COLUMN_ID == "AMEND_SCORE") {
							grid.addColumn(colList[i].COLUMN_ID, colList[i].COLUMN_NM, 0, "center", "number", 50, false, false, "", 0);
						} else {
							grid.addColumn(colList[i].COLUMN_ID, colList[i].COLUMN_NM, 80, "center", "number", 50, false, false, "", 0);
						}
						// col = {
						// 	name: colList[i].COLUMN_ID,
						// 	fieldName: colList[i].COLUMN_ID,
						// 	header: {text: colList[i].COLUMN_NM},
						// 	width: 110,
						// 	colType: "number",
						// 	editable: false
						// };
					}

					// columns[cnt] = col;

					// cnt++;
				}


				// grid._gvo.setColumns(columns);
			});

			var footer = {
				"styles": {
					"textAlignment": "center",
					"fontFmaily": "Nanum Gothic",
					"fontBold": true},
				"text": "평   균"
			};

			grid.setRowFooter("VENDOR_NM", footer);
		}
    }

	</script>

<e:window id="EV0290" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
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
