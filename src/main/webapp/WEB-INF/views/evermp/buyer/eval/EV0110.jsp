<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui>

	<script>
		var baseUrl = "/evermp/buyer/eval/";
		var gridMain;
		var gridQly;
		var gridQty;
		let evimType = "";

		function init() {

			gridMain = EVF.C("gridMain");
			gridQly = EVF.C("gridQly");
			gridQty = EVF.C("gridQty");

			gridMain.setProperty('panelVisible', ${panelVisible});
			gridQly.setProperty('panelVisible', ${panelVisible});
			gridQty.setProperty('panelVisible', ${panelVisible});

			if('${_gridType}' != "RG") {
				gridQly.acceptZero(true);
				gridQty.acceptZero(true);
			}
			gridMain.setProperty('multiselect', true);
			gridMain.setProperty('shrinkToFit', false);
			gridQly.setProperty('shrinkToFit', true);
			gridQty.setProperty('shrinkToFit', true);

			// Grid Excel Export
			gridMain.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth      : 0.12, 		// 이미지 너비
					imgHeight     : 0.26,		    // 이미지 높이
					colWidth      : 20,        	// 컬럼의 넓이
					rowSize       : 500,       	// 엑셀 행에 높이 사이즈
					attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
				}
			});

			// Grid Excel Export
			gridQly.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth      : 0.12, 		// 이미지 너비
					imgHeight     : 0.26,		    // 이미지 높이
					colWidth      : 20,        	// 컬럼의 넓이
					rowSize       : 500,       	// 엑셀 행에 높이 사이즈
					attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
				}
			});

			// Grid Excel Export
			gridQty.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth      : 0.12, 		// 이미지 너비
					imgHeight     : 0.26,		    // 이미지 높이
					colWidth      : 20,        	// 컬럼의 넓이
					rowSize       : 500,       	// 엑셀 행에 높이 사이즈
					attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
				}
			});

			gridQly.addRowEvent(function () {
				addParam = [
					{
						"EV_ID_ORDER" : gridQly.getRowCount()+1,
						"INSERT_FLAG" : 'I'
					}
				];

				if(EVF.V("SCALE_TYPE_CD_R") == "M") {
					if(gridQly.getRowCount() > 0) {
						EVF.alert("${EV0110_MSG_002}");
					} else {
						gridQly.addRow(addParam);
					}
				} else {
					gridQly.addRow(addParam);
				}
			});

			gridQly.delRowEvent(function() {
				if(gridQly.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

				var rowData = gridQly.getSelRowId();
				for ( var nRow in rowData) {
					gridQly.setCellValue(rowData[nRow],'INSERT_FLAG','D');
					gridQly.setRowBgColor(rowData[nRow], '#8C8C8C');
				}

				//gridQly.delRow();
			});

			gridQty.addRowEvent(function () {
				addParam = [
					{
						"EV_ID_ORDER" : gridQty.getRowCount()+1,
						"INSERT_FLAG" : 'I'
					}
				];
				gridQty.addRow(addParam);
			});

			gridQty.delRowEvent(function() {

				if(gridQty.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

				var rowData = gridQty.getSelRowId();
				for ( var nRow in rowData) {
					gridQty.setCellValue(rowData[nRow],'INSERT_FLAG','D');
					gridQty.setRowBgColor(rowData[nRow], '#8C8C8C');
				}

				//gridQty.delRow();
			});

			gridMain.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
				if (celname =='EV_ITEM_SUBJECT') {
					EVF.C('EV_ITEM_KIND_CD_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_KIND_CD')  ,false  );
					EVF.C('EV_ITEM_METHOD_CD_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_METHOD_CD')    );
					EVF.C('SCALE_TYPE_CD_R').setValue( gridMain.getCellValue(rowid,'SCALE_TYPE_CD')    );
					EVF.C('EV_ITEM_CONTENTS_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_CONTENTS')    );
					EVF.C('EV_ITEM_SUBJECT_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_SUBJECT')    );
					EVF.C('EV_ITEM_NUM').setValue( gridMain.getCellValue(rowid,'EV_ITEM_NUM'));
					EVF.C('QTY_ITEM_CD').setValue( gridMain.getCellValue(rowid,'QTY_ITEM_CD'));

					evimType = gridMain.getCellValue(rowid,'EVIM_TYPE');
					getEvImType(evimType);



//					EVF.C('EVIM_SORT').setValue( gridMain.getCellValue(rowid,'EVIM_SORT'));



					getEvItemTypeRValue2(gridMain.getCellValue(rowid,'EV_ITEM_KIND_CD'),  gridMain.getCellValue(rowid,'EV_ITEM_TYPE_CD') );
					doSearchDetail(gridMain.getCellValue(rowid,'EV_ITEM_NUM'));

//    			alert(gridMain.getCellValue(rowid,'EV_ITEM_METHOD_CD'))
					if (gridMain.getCellValue(rowid,'EV_ITEM_METHOD_CD') == 'QUA') {
						gridQty.delAllRow();

						$('#tab1').focus();
						var e = jQuery.Event( 'keydown', { keyCode: 13 } );
						$("#tab1").trigger(e);
						window.scrollbars = true;
					} else {
						gridQly.delAllRow();

						$('#tab2').focus();
						var e = jQuery.Event( 'keydown', { keyCode: 13 } );
						$("#tab2").trigger(e);
						window.scrollbars = true;
					}
				}
			});

			chgMethod();
		}

		function doNew() {
			EVF.C('EV_ITEM_KIND_CD_R').setValue( ''  ,false  );
			EVF.C('EV_ITEM_METHOD_CD_R').setValue( 'QUA'    );
			EVF.C('SCALE_TYPE_CD_R').setValue( 'A'    );
			EVF.C('EV_ITEM_CONTENTS_R').setValue( ''    );
			EVF.C('EV_ITEM_SUBJECT_R').setValue( ''    );
			EVF.C('EV_ITEM_NUM').setValue( ''   );
			EVF.C('EV_ITEM_TYPE_CD_R').setValue( ''  );
			EVF.C('QTY_ITEM_CD').setValue( ''   );

			gridQly.delAllRow();
			gridQty.delAllRow();
		}

		function chgMethod() {
			var method = EVF.C('EV_ITEM_METHOD_CD_R').getValue();

			if (method == 'QUA') {
				$("#tab1").show();
				$("#tab2").hide();
				EVF.C("EV_ITEM_SUBJECT_R").setReadOnly(false);

				$('#tab1').focus();
				var e = jQuery.Event( 'keydown', { keyCode: 13 } );
				$("#tab1").trigger(e);
				window.scrollbars = true;
			} else {
				$("#tab1").hide();
				$("#tab2").show();
				EVF.V("SCALE_TYPE_CD_R", "A");
				EVF.C("EV_ITEM_SUBJECT_R").setReadOnly(true);

				$('#tab2').focus();
				var e = jQuery.Event( 'keydown', { keyCode: 13 } );
				$("#tab2").trigger(e);
				window.scrollbars = true;
			}
		}

		function onChangeSCALE_TYPE_CD_R(c, a, b) {
			var EV_ITEM_METHOD_CD_R = EVF.V("EV_ITEM_METHOD_CD_R");

			if(EV_ITEM_METHOD_CD_R == "QTY" && a == "M") {
				EVF.alert("${EV0110_MSG_003}");
				EVF.V("SCALE_TYPE_CD_R", b);
			}
		}

		function getEvItemTypeRValue2(type,value) {
			var store = new EVF.Store;
			store.setParameter('EV_ITEM_KIND_CD',type);
			store.load(baseUrl + '/EV0110/changeComboItemKindValue', function() {
				if (this.getParameter("itemTypeCode") != null) {
					EVF.C('EV_ITEM_TYPE_CD_R').setOptions(this.getParameter("itemTypeCode"));
				}
				EVF.C('EV_ITEM_TYPE_CD_R').setValue(value);
			});
		}

		function doSearchDetail(value) {
			var store = new EVF.Store();
			store.setParameter('EV_ITEM_NUM',value);
			store.setGrid([gridQly,gridQty]);
			store.load(baseUrl + "EV0110/doSearchDetail", function() {
				setTimeout(() => EVF.C('EVIM_TYPE').setValue(evimType), 500);
			});

		}

		function doSearch() {
			var store = new EVF.Store();
			store.setGrid([gridMain]);
			store.load(baseUrl + "EV0110/doSearch", function() {
				if (gridMain.getRowCount() == 0) {
					EVF.alert("${msg.M0002 }");
				}
				doNew();
			});
		}

		function getEvItemType() {
			var store = new EVF.Store;
			store.load(baseUrl + '/EV0110/changeComboItemKindL', function() {
				if(EVF.isNotEmpty(this.getParameter("itemTypeCode"))) {
					EVF.C('EV_ITEM_TYPE_CD').setOptions(this.getParameter("itemTypeCode"));
				}
			});
		}


		function getEvImType() {
			return;
			var store = new EVF.Store;
			store.setParameter('EV_ITEM_KIND_CD',EVF.V('EV_ITEM_KIND_CD_R'));
			store.setParameter('EV_ITEM_TYPE_CD',EVF.V('EV_ITEM_TYPE_CD_R'));
			store.load(baseUrl + '/EV0110/getEvimType', function() {
				if(EVF.isNotEmpty(this.getParameter("evimType"))) {
					EVF.C('EVIM_TYPE').setOptions(this.getParameter("evimType"));
				}
			});
		}


		function getEvImTypeLeft() {
			var store = new EVF.Store;
			store.setParameter('EV_ITEM_KIND_CD',EVF.V('EV_ITEM_KIND_CD'));
			store.setParameter('EV_ITEM_TYPE_CD',EVF.V('EV_ITEM_TYPE_CD'));
			store.load(baseUrl + '/EV0110/getEvimType', function() {
				if(EVF.isNotEmpty(this.getParameter("evimType"))) {
// 					EVF.C('EVIM_TYPE_LEFT').setOptions(this.getParameter("evimType"));
				}
			});
		}









		function getEvImType2(data2) {
			var store = new EVF.Store;
			store.setParameter('EV_ITEM_KIND_CD',EVF.V('EV_ITEM_KIND_CD_R'));
			store.setParameter('EV_ITEM_TYPE_CD',EVF.V('EV_ITEM_TYPE_CD_R'));
			store.load(baseUrl + '/EV0110/getEvimType', function() {
				if(EVF.isNotEmpty(this.getParameter("evimType"))) {
					EVF.C('EVIM_TYPE').setOptions(this.getParameter("evimType"));

					/*setTimeout(() => console.log("after"), 2000);
					alert('======'+data2+'======')
					EVF.C('EVIM_TYPE').setValue(data2);*/

				}
			});

		}









		function getEvItemTypeR() {
			var store = new EVF.Store;
			store.load(baseUrl + '/EV0110/changeComboItemKindR', function() {
				if (this.getParameter("itemTypeCode") != null) {
					EVF.C('EV_ITEM_TYPE_CD_R').setOptions(this.getParameter("itemTypeCode"));
				}
			});
		}

		function getContentTab(uu) {
			return;
			if (uu == '1') {
			}
			if (uu == '2') {
			}
		}

		$(document.body).ready(function() {
			$('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
				{
					activate: function(event, ui) {
						<%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
						$(window).trigger('resize');
					}
				}
			);
			$('#e-tabs').tabs('option', 'active', 0);
			//getContentTab('1');
		});


		function doDelete() {
			if (!gridMain.isExistsSelRow()) { return alert('${msg.M0004}'); }

			EVF.confirm("${msg.M8888 }", function () {
				var store = new EVF.Store();
				store.setGrid([gridMain]);
				store.getGridData(gridMain, 'sel');
				store.load(baseUrl + '/EV0110/doDelete', function () {
					EVF.alert(this.getResponseMessage(), function() {
						doSearch();
					});
				});
			});
		}

		function doSave() {
			var store = new EVF.Store();
			if (!store.validate())
				return;

			gridQly.checkAll(true);
			gridQty.checkAll(true);

			var method = EVF.C('EV_ITEM_METHOD_CD_R').getValue();
			var scaleType = EVF.C('SCALE_TYPE_CD_R').getValue();
			if (method == 'QUA') {
				if (!gridQly.validate().flag) {
					EVF.alert("${msg.M0014}");
					return;
				}
			} else {
				if (!gridQty.validate().flag) {
					EVF.alert("${msg.M0014}");
					return;
				}
			}

			var selRowId = gridQly.getSelRowId();

			for(var i in selRowId) {
				if(gridQly.getCellValue(selRowId[i],'EV_ID_SCORE') > '10'){
					EVF.alert('${EV0110_004}');
					return;
				}
			}

			store.setGrid([ gridQly,gridQty ]);
			store.getGridData(gridQly, 'sel');
			store.getGridData(gridQty, 'sel');

			EVF.confirm("${msg.M8888 }", function () {
				store.load(baseUrl + '/EV0110/doSave', function () {
					EVF.alert(this.getResponseMessage(), function() {
						doSearch();
					});
				});
			});
		}

		function doSearchQtyItem() {
			var method = EVF.C('EV_ITEM_METHOD_CD_R').getValue();

			if (method == 'QUA') {
				EVF.alert('${EV0110_MSG_001}'); <%-- 정량평가인 경우에만 처리 가능합니다. --%>
				return;
			}

			var param = {
				callBackFunction : 'doSetQtyItem'
				, codeType : 'M207'
			};

			everPopup.openCommonPopup(param, 'SP0029');
		}

		function doSetQtyItem(data) {
			EVF.C("EV_ITEM_SUBJECT_R").setValue(data.CODE_DESC);
			EVF.C("QTY_ITEM_CD").setValue(data.CODE);
		}
	</script>

	<e:window id="EV0110" onReady="init" initData="${initData}" title="${fullScreenName}">

		<e:panel width="54%" height="100%">



			<e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
				<e:row>
					<e:label for="EV_ITEM_KIND_CD" title="${form_EV_ITEM_KIND_CD_N}"/>
					<e:field>
						<e:select id="EV_ITEM_KIND_CD" name="EV_ITEM_KIND_CD" value="${form.EV_ITEM_KIND_CD}" onChange="getEvItemType"  options="${itemKindCode }" width="${form_EV_ITEM_KIND_CD_W}" disabled="${form_EV_ITEM_KIND_CD_D}" readOnly="${form_EV_ITEM_KIND_CD_RO}" required="${form_EV_ITEM_KIND_CD_R}" placeHolder="" />
					</e:field>
					<e:label for="EV_ITEM_TYPE_CD" title="${form_EV_ITEM_TYPE_CD_N}"/>
					<e:field>
						<e:select id="EV_ITEM_TYPE_CD" name="EV_ITEM_TYPE_CD" value="${form.EV_ITEM_TYPE_CD}" onChange="getEvImTypeLeft" options="" width="${form_EV_ITEM_TYPE_CD_W}" disabled="${form_EV_ITEM_TYPE_CD_D}" readOnly="${form_EV_ITEM_TYPE_CD_RO}" required="${form_EV_ITEM_TYPE_CD_R}" placeHolder="" />
					</e:field>
				</e:row>
				<e:row>
					<e:label for="EV_ITEM_SUBJECT" title="${form_EV_ITEM_SUBJECT_N}" />
					<e:field>
						<e:inputText id="EV_ITEM_SUBJECT" style="${imeMode}" name="EV_ITEM_SUBJECT" value="${form.EV_ITEM_SUBJECT}" width="100%" maxLength="${form_EV_ITEM_SUBJECT_M}" disabled="${form_EV_ITEM_SUBJECT_D}" readOnly="${form_EV_ITEM_SUBJECT_RO}" required="${form_EV_ITEM_SUBJECT_R}"/>
					</e:field>
					<e:label for="EV_ITEM_CONTENTS" title="${form_EV_ITEM_CONTENTS_N}" />
					<e:field>
						<e:inputText id="EV_ITEM_CONTENTS" style="${imeMode}" name="EV_ITEM_CONTENTS" value="${form.EV_ITEM_CONTENTS}" width="100%" maxLength="${form_EV_ITEM_CONTENTS_M}" disabled="${form_EV_ITEM_CONTENTS_D}" readOnly="${form_EV_ITEM_CONTENTS_RO}" required="${form_EV_ITEM_CONTENTS_R}"/>
					</e:field>

					<e:inputHidden id="EV_ITEM_METHOD_CD" name="EV_ITEM_METHOD_CD" value="QUA"/>
					<e:inputHidden id="EVIM_TYPE_LEFT" name="EVIM_TYPE_LEFT" value=""/>

				</e:row>





				<e:row>
					<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
					<%--회사명--%>
					<%--<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
					<e:field>
						<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
					</e:field>
					<e:label for="dummy" />
					<e:field colSpan="1" />--%>
				</e:row>
			</e:searchPanel>
			<e:buttonBar align="right">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<e:button id="doNew" name="doNew" label="${doNew_N}" onClick="doNew" disabled="${doNew_D}" visible="${doNew_V}"/>
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			</e:buttonBar>

			<e:gridPanel gridType="${_gridType}" id="gridMain" name="gridMain" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridMain.gridColData}"/>


		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>
		<e:panel width="45%" height="100%">
			<e:searchPanel useTitleBar="false" id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
				<e:row>
					<e:label for="EV_ITEM_KIND_CD_R" title="${form_EV_ITEM_KIND_CD_R_N}"/>
					<e:field colSpan="3">
						<e:select id="EV_ITEM_KIND_CD_R" name="EV_ITEM_KIND_CD_R"  onChange="getEvItemTypeR" value="${form.EV_ITEM_KIND_CD_R}" options="${itemKindCode }" width="${form_EV_ITEM_KIND_CD_R_W}" disabled="${form_EV_ITEM_KIND_CD_R_D}" readOnly="${form_EV_ITEM_KIND_CD_R_RO}" required="${form_EV_ITEM_KIND_CD_R_R}" placeHolder="" />
					</e:field>

					<e:inputHidden id="EV_ITEM_NUM" name="EV_ITEM_NUM"/>
					<e:inputHidden id="QTY_ITEM_CD" name="QTY_ITEM_CD"/>
<%-- 					<e:inputHidden id="EV_ITEM_TYPE_CD_R" name="EV_ITEM_TYPE_CD_R"/> --%>
				</e:row>
				<e:row>
					<e:label for="EV_ITEM_SUBJECT_R" title="${form_EV_ITEM_SUBJECT_R_N}"/>
					<e:field colSpan="3">
						<e:inputText id="EV_ITEM_SUBJECT_R" name="EV_ITEM_SUBJECT_R" value="" width="${form_EV_ITEM_SUBJECT_R_W}" maxLength="${form_EV_ITEM_SUBJECT_R_M}" disabled="${form_EV_ITEM_SUBJECT_R_D}" readOnly="${form_EV_ITEM_SUBJECT_R_RO}" required="${form_EV_ITEM_SUBJECT_R_R}" />
					</e:field>

					<e:inputHidden id="EVIM_TYPE" name="EVIM_TYPE" value=""/>
					<e:inputHidden id="EV_ITEM_METHOD_CD_R" name="EV_ITEM_METHOD_CD_R" value="QUA"/>
					<e:inputHidden id="SCALE_TYPE_CD_R" name="SCALE_TYPE_CD_R" value="A"/>

				</e:row>
				<e:row>
					<e:label for="EV_ITEM_TYPE_CD_R" title="${form_EV_ITEM_TYPE_CD_R_N}"/>
					<e:field colSpan="3">
						<e:select id="EV_ITEM_TYPE_CD_R" name="EV_ITEM_TYPE_CD_R" value="" options="${evItemTypeCdROptions}" width="${form_EV_ITEM_TYPE_CD_R_W}" disabled="${form_EV_ITEM_TYPE_CD_R_D}" readOnly="${form_EV_ITEM_TYPE_CD_R_RO}" required="${form_EV_ITEM_TYPE_CD_R_R}" placeHolder="" />
					</e:field>
				</e:row>

				<e:row>
					<%--평가내용--%>
					<e:label for="EV_ITEM_CONTENTS_R" title="${form_EV_ITEM_CONTENTS_R_N}"/>
					<e:field colSpan="3">
					<e:textArea id="EV_ITEM_CONTENTS_R" name="EV_ITEM_CONTENTS_R" value="" height="180px" width="${form_EV_ITEM_CONTENTS_R_W}" maxLength="${form_EV_ITEM_CONTENTS_R_M}" disabled="${form_EV_ITEM_CONTENTS_R_D}" readOnly="${form_EV_ITEM_CONTENTS_R_RO}" required="${form_EV_ITEM_CONTENTS_R_R}" />
					</e:field>
				</e:row>

			</e:searchPanel>

			<e:buttonBar align="right">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			</e:buttonBar>
		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>

		<div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
			<e:panel id="righttPanel1" height="fit" width="45%">
				<tr><td><div>
					<ul>
						<li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${EV0110_QLY}</a></li>
						<li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${EV0110_QTY}</a></li>
					</ul>

					<div id="ui-tabs-1">
						<div style="height: auto;">
							<e:gridPanel gridType="${_gridType}" id="gridQly" name="gridQly" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridQly.gridColData}"/>
						</div>
					</div>

					<div id="ui-tabs-2">
						<div style="height: auto;">
							<e:gridPanel gridType="${_gridType}" id="gridQty" name="gridQty" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridQty.gridColData}"/>
						</div>
					</div>
				</div></td></tr>
			</e:panel>
		</div>

	</e:window>
</e:ui>