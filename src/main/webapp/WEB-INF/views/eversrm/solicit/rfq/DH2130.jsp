<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var grid;
		var baseUrl = "/eversrm/solicit/rfq/";

		function init() {
			grid = EVF.C("grid");
			grid.setColEllipsis (['QTA_GIVEUP_RMK'], true);
			grid.setProperty('panelVisible', ${panelVisible});


		      if(${_gridType eq "RG"}) {
		          grid.setColGroup([{
		            "groupName": '입찰설명회',
		            "columns": [ "ANN_FLAG", "ANN_PASS_YN" ]
		          }]);
		        } else {
				    grid.setGroupCol(
					    	[
								{'colName' : 'ANN_FLAG', 'colIndex' : 2, 'titleText' : '입찰설명회'}
					    	]
					    );
		        }



			grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
				if (celName == "RFX_NUM") {
					var param = {
						gateCd: grid.getCellValue(rowId, "GATE_CD"),
						rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
						rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
						rfxType: grid.getCellValue(rowId, "RFX_TYPE"),
						popupFlag: true,
						detailView: true
					};
					everPopup.openRfxDetailInformation(param);
				}

                if (celName == "QTA_GIVEUP_RMK") {
                	setRowId = rowId;
            	    var param = {
            				  havePermission : true
            				, callBackFunction : 'setTextContents'
            				, detailView : false
            				, TEXT_CONTENTS : grid.getCellValue(rowId, "QTA_GIVEUP_RMK")
            			};
          	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
                }
                if (celName == "QTA_NUM") {
                	if (grid.getCellValue(rowId,'QTA_NUM') == '') return;
        	        var param = {
        		            gateCd: grid.getCellValue(rowId,'GATE_CD'),
        		            rfxNum: grid.getCellValue(rowId,'RFX_NUM'),
        		            qtaNum : grid.getCellValue(rowId,'QTA_NUM'),
        		            rfxCnt: grid.getCellValue(rowId,'RFX_CNT'),
        		            //rfxType: selectedRow['RFX_TYPE'],
        		            popupFlag: true,
        		            //callBackFunction: "doSearch"
        		            detailView: false,
        		            "isPrefferedBidder": false,
        		            "buttonStatus" : 'Y',
        		            vendorCd: "${ses.companyCd}"
        		    };
        		    everPopup.openPopupByScreenId('DH2140', 1000, 800, param);
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

			//SUMMARY화면에서 넘어올 경우 자동조회
			//if ('${param.summary}' == 'Y') {
				doSearch();
			//}
			//get_timer();

		}
		var setRowId;
		function setTextContents(tests) {
			grid.setCellValue(setRowId, "QTA_GIVEUP_RMK",tests);
		}
		//조회
		function doSearch() {

			if (!everDate.fromTodateValid('ADD_DATE_FROM', 'ADD_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');
			var store = new EVF.Store();
			if(!store.validate()) return;
			store.setGrid([grid]);
			store.load(baseUrl + "DH2130/doSearch", function() {
				if (grid.getRowCount() == 0) {
					alert("${msg.M0002 }");
				}
			});
		}
		//접수
		function doReceipt() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}

			var selRows = grid.getSelRowValue();
			for( var i = 0, len = selRows.length; i < len; i++ ) {
				if (selRows[i].ANN_FLAG == 'Y' && selRows[i].ANN_PASS_YN != '1') {
					alert('${DH2130_0002}');
					return;
				}
				if (selRows[i].RFQ_PROGRESS_CD != '100') {
					alert('${DH2130_1000}');
					return;
				}
			}

			if (!confirm("${msg.M0066}")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'DH2130/doReceipt', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}
		//참여포기
		function doWaive() {
			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}

			var selRows = grid.getSelRowValue();
			for( var i = 0, len = selRows.length; i < len; i++ ) {

				if (selRows[i].RFQ_PROGRESS_CD == '150'
				||selRows[i].RFQ_PROGRESS_CD == '300'
				||selRows[i].RFQ_PROGRESS_CD == '400'
				) {
					alert('${DH2130_1001}');
					return;
				}

				if (selRows[i].ANN_FLAG == 'Y' && selRows[i].ANN_PASS_YN != '1') {
					alert('${DH2130_0002}');
					return;
				}
				if (selRows[i].QTA_GIVEUP_RMK == '') {
					alert('${DH2130_0001}');
					return;
				}
			}


			if (!confirm("${msg.M0030}")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'DH2130/doWaive', function(){
				alert(this.getResponseMessage());
				doSearch();
			});

		}

		function doQuote() {
			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
			var selectedRow = grid.getSelRowValue()[0];

			if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
				alert("${msg.M0006}");
				return;
			}

			if (!selectedRow) return alert("${msg.M0004}");
			//if ('${ses.userId}' != selectedRow.CTRL_USER_ID) return alert('${msg.M0008}');
			if (parseInt(selectedRow.RFQ_PROGRESS_CD) != 200 && parseInt(selectedRow.RFQ_PROGRESS_CD) != 250) return alert("${msg.M0044}");
			var isPrefferedBidder = selectedRow.RFQ_PROGRESS_CD === '275' ? true : false;
			var pcd = selectedRow.RFQ_PROGRESS_CD;
			var buttonStatus = "Y";
			if( pcd >= 300 ){
				buttonStatus = "N";
			}else{
				buttonStatus = "Y";
			}


			if (selectedRow.ANN_FLAG == 'Y' && selectedRow.ANN_PASS_YN != '1') {
				alert('${DH2130_0002}');
				return;
			}


			var param = {
				gateCd: selectedRow['GATE_CD'],
				rfxNum: selectedRow['RFX_NUM'],
				rfxCnt: selectedRow['RFX_CNT'],
				//rfxType: selectedRow['RFX_TYPE'],
				popupFlag: true,
				//callBackFunction: "doSearch"
				detailView: false,
				"isPrefferedBidder": isPrefferedBidder,
				"buttonStatus" : buttonStatus,
				vendorCd: "${ses.companyCd}"
			};

			everPopup.openPopupByScreenId('DH2140', 1000, 800, param);

		}


		function doQuote_OLD() {
			var selectedRow = gridUtil.getJSONDataOneOnly(grid, 'SELECTED');

			if (!selectedRow) return alert("${msg.M0078}");
			if (parseInt(selectedRow.RFQ_PROGRESS_CODE) < 200 || parseInt(selectedRow.RFQ_PROGRESS_CODE) > 275) return alert("${msg.M0044}");

			var isPrefferedBidder = selectedRow.RFQ_PROGRESS_CODE === '275' ? true : false;
			var param = {
				houseCode: selectedRow.HOUSE_CODE,
				rfxNo: selectedRow.RFX_NO,
				rfxCnt: selectedRow.RFX_CNT,
				detailView: false,
				"isPrefferedBidder": isPrefferedBidder
			};
			wisePopup.openPopupByScreenId("SPX_020", 1000, 700, param);
		}

		/*
		function timer(){
			var currdate;

			var store = new EVF.Store();
			store.load(baseUrl + "DH2130/getTime", function() {
				currdate = this.getParameter("currDatetime");
				var yy = currdate.substr(0,4);
				var mm = currdate.substr(4,2);
				var dd = currdate.substr(6,2);
				var hh = currdate.substr(8,2);
				var mi = currdate.substr(10,2);
				var ss = currdate.substr(12,2);
				var date = new Date(yy,mm,dd,hh,mi,ss);
				// 그 지역의 날짜 (locale date).
				 var dateString = date .toLocaleDateString();
				 // 그 지역의 시간 (locale time).
				 var timeString = date .toLocaleTimeString();
				 var text = dateString + " " + timeString;
				 // 'text'만 저장하고, 이 함수 끝내기.

				 EVF.getComponent('CURR_TIME').setValue(text);

//				 return text;
			},false);
		}
		*/
		/*
		function get_timer(){

			 // 함수값 불러와서, 태그 안에 집어넣기.
			// document.getElementById( "CURR_TIME" ).innerHTML = timer();

			 timer();
			 // 1000 밀리초(=1초) 후에, 이 함수를 실행하기 (반복 실행 효과).
			 setTimeout( "get_timer()", 1000 );
		}
		*/
	</script>


	<e:window id="DH2130" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
			<e:inputHidden id="summary" name="summary" value="${summary}" />

			<e:row>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
				<e:field>
					<e:inputDate id="ADD_DATE_FROM" toDate="ADD_DATE_TO" name="ADD_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_R}" disabled="${form_ADD_DATE_D}" readOnly="${form_ADD_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="ADD_DATE_TO" fromDate="ADD_DATE_FROM" name="ADD_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_DATE_R}" disabled="${form_ADD_DATE_D}" readOnly="${form_ADD_DATE_RO}" />
				</e:field>

                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>

				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" style='ime-mode:inactive' value="${form.RFX_NUM}" width="${inputTextWidth}"  maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				</e:field>



			</e:row>
			<e:row>
				<e:label for="SUBMIT_TYPE" title="${form_SUBMIT_TYPE_N}"/>
				<e:field>
				<e:select id="SUBMIT_TYPE" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitTypeOptions}" width="${inputTextWidth}" disabled="${form_SUBMIT_TYPE_D}" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
				</e:field>


				<e:inputHidden id="DEPT_NM" name="DEPT_NM" />
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
					<e:inputText id="RFX_SUBJECT" style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="100%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>


				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${refPROGRESS_CD}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<!--
			<e:row>
				<e:label for="CURR_TIME" title="${form_CURR_TIME_N}"/>
				<e:field colSpan="5">
					<e:text id="CURR_TIME"></e:text>
				</e:field>
			</e:row>
			-->
		</e:searchPanel>


		<e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doReceipt" name="doReceipt" label="${doReceipt_N}" onClick="doReceipt" disabled="${doReceipt_D}" visible="${doReceipt_V}"/>
			<e:button id="doQuote" name="doQuote" label="${doQuote_N}" onClick="doQuote" disabled="${doQuote_D}" visible="${doQuote_V}"/>
			<e:button id="doWaive" name="doWaive" label="${doWaive_N}" onClick="doWaive" disabled="${doWaive_D}" visible="${doWaive_V}"/>
		</e:buttonBar>


		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>