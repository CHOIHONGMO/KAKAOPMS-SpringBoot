<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');

        EVF.C('EV_TYPE').removeOption('REGISTRATION');
        EVF.C('EV_TYPE').removeOption('CLASS');

        grid.setProperty('panelVisible', ${panelVisible});

    	EVF.C('EV_CTRL_USER_ID').setValue('${ses.userId}');
        EVF.C('EV_CTRL_USER_NM').setValue('${ses.userNm}');
    	EVF.C('RESULT_ENTER_CD').setValue('PERUSER');

        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

        });

        grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${fullScreenName}",    <%--${screenName }--%>
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

        grid.excelImportEvent({
            'append': false
        }, function (msg, code) {
           	if (code) {
           		var allRowId = grid.getAllRowId();
           		for(var i = grid.getRowCount() - 1; i >= 0 ; i--) {
           			var rowId = allRowId[i];
           			if(grid.getCellValue(rowId, "PROJECT_CD") == "" && grid.getCellValue(rowId, "SALES_CONT_NUM") == "" &&
						grid.getCellValue(rowId, "PERIODIC_EV_TYPE") == "" && grid.getCellValue(rowId, "EXEC_EV_TPL_NM") == "" &&
						grid.getCellValue(rowId, "CONT_NUM") == "" && grid.getCellValue(rowId, "CONT_DESC") == "" &&
						grid.getCellValue(rowId, "VENDOR_CD") == "" && grid.getCellValue(rowId, "VENDOR_NM") == "") {

           				grid.delRow(rowId);
					}
				}

           		grid.checkAll(true);
           	}
        });
    }

    <%-- 협력업체담당자 선택 팝업 --%>
    function doSelectUser() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }

    <%-- 평가담당자 세팅 --%>
    function selectUser(dataJsonArray) {
        EVF.C("EV_CTRL_USER_NM").setValue(dataJsonArray.USER_NM);
        EVF.C("EV_CTRL_USER_ID").setValue(dataJsonArray.USER_ID);
    }

    function doImportSrm() {
    	<%-- 날짜 체크--%>
        if(!everDate.checkTermDate('START_DATE','CLOSE_DATE','${msg.M0073}')) {
            return;
        }

        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/EV0215/doImportSrm', function() {
            if(grid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }
        });
    }

    <%-- 엑셀 DownLoad--%>
    function doExcelDownload() {
		$('.btn-download').trigger('click');
    }


	<%-- 엑셀 UPload --%>
	function doExcelUpload() {
		$('.btn-upload').trigger('click');
	}

	function excelUploadCallBack( msg, code ) {
		grid.checkAll(true);
	 	alert('${msg.M0001}');
 	}

 	function doEvalAll() {
		var store = new EVF.Store();

		if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
		if(!grid.validate().flag) { return alert("${msg.M0014}"); }
		if(!store.validate()) return;

		var selRowValue = grid.getSelRowValue();
		var selRowId = grid.getSelRowId();
		var SI_NUM = "";
		var SM_NUM = "";
		var CO_NUM = "";

		for(var i in selRowId) {
			var rowI = selRowId[i];
			var rowValue = selRowValue[i];

			if(grid.getCellValue(rowI, "PERIODIC_EV_TYPE") == "SI" && SI_NUM == "") {
				SI_NUM = grid.getCellValue(rowI, "EXEC_EV_TPL_NM");
			}

			if(grid.getCellValue(rowI, "PERIODIC_EV_TYPE") == "SM" && SM_NUM == "") {
				SM_NUM = grid.getCellValue(rowI, "EXEC_EV_TPL_NM");
			}

			if(grid.getCellValue(rowI, "PERIODIC_EV_TYPE") == "CO" && CO_NUM == "") {
				CO_NUM = grid.getCellValue(rowI, "EXEC_EV_TPL_NM");
			}

			var cnt = 0;
			for(var j in selRowId) {
				var rowJ = selRowId[j];

				if(grid.getCellValue(rowI, "PERIODIC_EV_TYPE") == grid.getCellValue(rowJ, "PERIODIC_EV_TYPE")) {
					if(grid.getCellValue(rowI, "EXEC_EV_TPL_NM") != grid.getCellValue(rowJ, "EXEC_EV_TPL_NM")) {
						return EVF.alert("${EV0215_001}");
					}
				}

				if("" != grid.getCellValue(rowI, "CONT_NUM") && "" != grid.getCellValue(rowJ, "CONT_NUM") ) {
					if(grid.getCellValue(rowI, "CONT_NUM") == grid.getCellValue(rowJ, "CONT_NUM")) {
						cnt++;
					}
				}
			}

			if(cnt > 1) {
				return EVF.alert("${EV0215_009}");
			}

			var REP_EV_USER_ID = grid.getCellValue(rowI, "REP_EV_USER_ID");
			var check = true;

			if(EVF.V("RESULT_ENTER_CD") == "REPUSER") {
				if(REP_EV_USER_ID == "") {
					return EVF.alert("${EV0215_003}");
				}
			} else {
				check = false;
			}

			var userId = "";

			for(var k in rowValue) {
				if(k.indexOf("USER") >= 0 && k != "REP_EV_USER_ID") {
					if(grid.getCellValue(rowI, k) != "") {
						userId = grid.getCellValue(rowI, k);

						if(REP_EV_USER_ID == userId) {
							check = false;
						}

						for(var kk in rowValue) {
							if(kk.indexOf("USER") >= 0 && kk != "REP_EV_USER_ID") {
								if(grid.getCellValue(rowI, kk) != "" && k != kk) {
									if(userId == grid.getCellValue(rowI, kk)) {
										return EVF.alert("${EV0215_002}");
									}
								}
							}
						}
					}
				}
			}

			if(check) return EVF.alert("${EV0215_005}");

			if(userId == "") {
				return EVF.alert("${EV0215_004}");
			}
		}

		if(!(SI_NUM != SM_NUM && SI_NUM != CO_NUM && SM_NUM != CO_NUM)) {
			return EVF.alert("${EV0215_001}");
		}

		EVF.confirm("${EV0215_008}", function () {
			store.setGrid([grid]);
			store.getGridData(grid, "sel");
			store.load(baseUrl + "/srm215_doEvalAll", function() {
				grid.delAllRow();
				EVF.alert(this.getResponseMessage(), function() {

				});
			});
		});
	}

    </script>
	<e:window id="EV0215" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" useTitleBar="false">
		<e:inputHidden id="BUSI_FLAG" name="BUSI_FLAG" value="NPUR"/>
		<e:row>
			<%-- 평가구분--%>
			<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
			<e:field>
			<e:select id="EV_TYPE" name="EV_TYPE" value="${empty form.EV_TYPE ? 'ROUTINE' : form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
			</e:field>
			<%-- 평가기간 --%>
			<e:label for="START_DATE" title="${form_START_DATE_N}"/>
			<e:field>
			<e:inputDate id="START_DATE" toDate="CLOSE_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
			<e:text>~</e:text>
			<e:inputDate id="CLOSE_DATE" fromDate="START_DATE" name="CLOSE_DATE" value="${form.CLOSE_DATE}" width="${inputTextDate}" datePicker="true" required="${form_CLOSE_DATE_R}" disabled="${form_CLOSE_DATE_D}" readOnly="${form_CLOSE_DATE_RO}" />
			</e:field>
		</e:row>

		<e:row>
			<%-- 협력업체담당자 --%>
			<e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
			<e:field>
			<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="${form.EV_CTRL_USER_NM }" width="${form_EV_CTRL_USER_NM_W}" maxLength="${form_EV_CTRL_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
			<%-- <e:select id="EV_CTRL_USER_NM" name="EV_CTRL_USER_NM" value="${st_default}" width="${everMultiWidth}" options="${searchTerms}" visible="${everMultiVisible}" required="" readOnly="" disabled="" />
			<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="${form_EV_CTRL_USER_NM_W}" maxLength="${form_EV_CTRL_USER_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'EV_CTRL_USER'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" /> --%>
			<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>
			</e:field>
			<%-- 결과입력 --%>
			<e:label for="RESULT_ENTER_CD" title="${form_RESULT_ENTER_CD_N}"/>
			<e:field>
			<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${form.RESULT_ENTER_CD}" options="${resultEnterCdOptions}" width="${form_RESULT_ENTER_CD_W}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" />
			</e:field>
		</e:row>
		</e:searchPanel>

		<e:buttonBar align="right">
			<e:button id="doImportSrm" name="doImportSrm" label="${doImportSrm_N}" onClick="doImportSrm" disabled="${doImportSrm_D}" visible="${doImportSrm_V}"/>
			<e:button id="doExcelDownload" name="doExcelDownload" label="${doExcelDownload_N}" onClick="doExcelDownload" disabled="${doExcelDownload_D}" visible="${doExcelDownload_V}"/>
			<e:button id="doExcelUpload" name="doExcelUpload" label="${doExcelUpload_N}" onClick="doExcelUpload" disabled="${doExcelUpload_D}" visible="${doExcelUpload_V}"/>
			<e:button id="doEvalAll" name="doEvalAll" label="${doEvalAll_N}" onClick="doEvalAll" disabled="${doEvalAll_D}" visible="${doEvalAll_V}"/>
		</e:buttonBar>

		<%-- 그리드 창 켜줌 --%>
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>
