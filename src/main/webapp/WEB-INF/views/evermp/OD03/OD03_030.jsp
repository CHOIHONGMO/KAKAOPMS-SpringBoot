<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD03/";
		var ROW_ID;

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('sortable', true);
            EVF.C("DEAL_CD").removeOption("200");
            EVF.C("PR_TYPE").removeOption("R");


            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
				ROW_ID = rowId;

	        	if(colId === "CPO_USER_NM") {
	        		if(grid.getCellValue(rowId, "CPO_USER_ID") == "") {

					} else {
                        var param = {
                            callbackFunction: "",
                            USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
					}
	        	} else if (colId === "WH_CD"){ //창고선택
                    param = {
                            callBackFunction: "callbackWH_CD",
                            DEAL_CD : grid.getCellValue(rowId, "DEAL_CD"),
                            rowId: rowId,
                            detailView: false,
                        };
                        everPopup.openPopupByScreenId("STO02P01", 600, 600, param);
                }else if(colId === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                            CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                        };
                        everPopup.openPopupByScreenId("BOD1_041", 1100, 800, param);
                    }
                }  else if(colId === "ITEM_CD") {
	                if(value !== ""){
	                    var param = {
	                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
	                        popupFlag: true,
	                        detailView: true
	                    };
	                    everPopup.im03_014open(param);
	                }
	            } else if(colId == "RECIPIENT_NM") { // 인수자
                    if( grid.getCellValue(rowId, "RECIPIENT_NM") == "" ) return;
                    var param = {
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ"),
                        detailView: "true"
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colId == "AM_USER_NM") { // 진행관리담당자
					if( grid.getCellValue(rowId, "AM_USER_ID") == "" ) return;
					param = {
						callbackFunction: "",
						USER_ID: grid.getCellValue(rowId, "AM_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
				}else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }else if (colId == "VENDOR_NM") {
                	var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: true,
                            popupFlag: true
                        };
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
				if(colId === "GR_QTY" && value !== oldValue) {
				    if(value == 0) {
                        alert("${OD03_030_009}");
                        grid.setCellValue(rowId, "GR_QTY", oldValue);
                        grid.checkRow(rowId, false);
                        return;
					}

				    var AV_GR_QTY =  Number(grid.getCellValue(rowId, "AV_GR_QTY"));

                    if(AV_GR_QTY > 0) {
                        if(AV_GR_QTY < value) {
                            alert("${OD03_030_002}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                        if(value <= 0) {
                            alert("${OD03_030_009}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                    } else {
                        if(AV_GR_QTY > value) {
                            alert("${OD03_030_008}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }

                        if(value >= 0) {
                            alert("${OD03_030_009}");
                            grid.setCellValue(rowId, "GR_QTY", oldValue);
                            grid.checkRow(rowId, false);
                            return;
                        }
					}

					var CPO_UNIT_PRICE = Number(grid.getCellValue(rowId, "CPO_UNIT_PRICE"));
					var GR_AMT = CPO_UNIT_PRICE * value;

					grid.setCellValue(rowId, "GR_AMT", GR_AMT);

					var PO_UNIT_PRICE = Number(grid.getCellValue(rowId, "PO_UNIT_PRICE"));
					var PO_ITEM_AMT = PO_UNIT_PRICE * value;

					grid.setCellValue(rowId, "PO_ITEM_AMT", PO_ITEM_AMT);
				}
            });

            grid.setColIconify("REQ_TEXT_YN", "REQ_TEXT", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            var val = {visible: true, count: 1, height: 40};
            var footerTxt = {
                styles: {
                    textAlignment: "center",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: ["합 계"],
            };
            var footerSum = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    numberFormat: "###,###",
                    fontBold: true
                },
                text: "",
                expression: ["sum"],
                groupExpression: "sum"
            };
            grid.setProperty("footerVisible", val);
            grid.setRowFooter("CPO_UNIT_PRICE", footerTxt);
            grid.setRowFooter("GR_AMT", footerSum);


            doSearch();
        }
        //창고 물류센터 선택
        function callbackWH_CD(data) {
            var whdata = JSON.parse(data);
            grid.setCellValue(ROW_ID, 'WH_CD', whdata.WAREHOUSE_CODE);
            grid.setCellValue(ROW_ID, 'LOG_CD', whdata.STR_CTRL_CODE);
        }


        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
            grid.checkRow(data.rowId, true);
		}

        function callbackGridATTACH_FILE_NO(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, "ATTACH_FILE_NO", uuid);
			grid.setCellValue(rowId, "ATTACH_FILE_NO_IMG", fileCount);
        }

        function callbackGridGR_AGENT_ATTFILE_NUM(rowId, uuid, fileCount) {
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM", uuid);
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM_CNT", fileCount);
        }
		//조회
        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "od03030_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }
			//입고처리
        function doGrSave() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            if( grid.getCellValue(rowIds[i], 'GR_DATE') == "" ) {
                return alert("${OD03_030_003 }");
             }
            }

            if(!confirm("${OD03_030_004}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.setParameter("MMRS", "1");
            store.load(baseUrl + "od03010_doGrSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
		}

        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${OD03_030_006}");
                return;
            }

        	var param = {
        			callBackFunction: "callbackCPO_USER_ID",
        			custCd: custCd
                };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function callbackCPO_USER_ID(data) {
            EVF.V("CPO_USER_ID", data.USER_ID);
            EVF.V("CPO_USER_NM", data.USER_NM);
        }

        function searchVENDOR_CD() {
            var param = {
                callBackFunction: "callbackVENDOR_CD"
            };
            everPopup.openCommonPopup(param, "SP0063");
        }

        function callbackVENDOR_CD(data) {
            EVF.V("VENDOR_CD", data.VENDOR_CD);
            EVF.V("VENDOR_NM", data.VENDOR_NM);
        }

        function chgDivisionCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "200");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DEPT_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }
        function chgDeptCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "300");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('PART_CD').setOptions(this.getParameter("divisionDeptPartCd"));
            	}
            });
        }

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            var delyDate = EVF.V("GR_DATE");


            if( delyDate > '${END_DATE}' ) {
                return alert("${OD03_030_015 }");
            }
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], 'GR_DATE', delyDate);
            }
        }

		//납품서 수정
       function doSave() {
          if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
          if(!grid.validate().flag) { return alert(grid.validate().msg); }

          var cpoNo    = ""; // 주문번호
          var cpoQty   = 0; // 주문수량
          var bfInvQty = 0; // 기납품수량
          var invQty   = 0; // 납품수량
          var rowIds = grid.getSelRowId();
          for( var i in rowIds ) {
              <%--동일한 주문에 대해 납품서 변경 가능 --%>
              if( cpoNo != "" && cpoNo != grid.getCellValue(rowIds[i], 'CPO_NO') ) {
                  return alert("${OD02_020_008 }");
               }
               cpoNo = grid.getCellValue(rowIds[i], 'CPO_NO');
              <%--납품완료시 오류 --%>
              if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" || grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                  return alert("${OD02_020_004 }");
               }


              cpoQty   = Number(grid.getCellValue(rowIds[i], 'CPO_QTY'));
              bfInvQty = Number(grid.getCellValue(rowIds[i], 'BF_INV_QTY'));
              invQty   = Number(grid.getCellValue(rowIds[i], 'INV_QTY'));

              if(cpoQty > 0) {
                 <%--납품수량 > 0 --%>
                  if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) <= 0 ) {
                      return alert("${OD02_020_005}");
                   }

                  <%--납품수량 + 기납품수량 < 주문수량 --%>
                  if((bfInvQty + invQty) > cpoQty ) {
                      return alert("${OD02_020_007 }");
                   }
                }else {
                   if( Number(grid.getCellValue(rowIds[i], 'INV_QTY')) >= 0 ) {
                       return alert("${OD02_020_005}");
                   }

                   if( (bfInvQty + invQty) < cpoQty ) {
                       return alert("${OD02_020_007 }");
                   }
               }
	}
           if(!confirm("${OD03_030_012}")) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'od03030_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }
		//납품취소
       function doDelete() {
           if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

           var rowIds = grid.getSelRowId();
           for( var i in rowIds ) {
        	   if( grid.getCellValue(rowIds[i], 'FORCE_CLOSE_DATE') != '') {
                   return alert("${OD03_030_024 }");
               }
           }

           if (!confirm("${OD03_030_013 }")) return;

           var store = new EVF.Store();
           store.setGrid([grid]);
           store.getGridData(grid, 'sel');
           store.load(baseUrl + 'od03030_doDelete', function() {
               alert(this.getResponseMessage());
               doSearch();
           });
       }

    </script>

    <e:window id="OD03_030" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD03_030_0009}" value="CPO_DATE"/>
						<e:option text="${OD03_030_0012}" value="PO_DATE"/>
                        <e:option text="${OD03_030_0010}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE }" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE }" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>

				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				<e:text>&nbsp;</e:text>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>


				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVENDOR_CD" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
				<e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
				<e:field>
					<e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}"/>
				<e:field>
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="${form_CPO_USER_NM_W}" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field colSpan="3">
				<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
            </e:row>


        </e:searchPanel>

		<e:panel height="fit" width="20%">
			<e:text style="font-weight: bold;">●&nbsp;${form_GR_DATE_N} &nbsp;:&nbsp; </e:text>
			<e:inputDate id="GR_DATE" name="GR_DATE" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_GR_DATE_R}" disabled="${form_GR_DATE_D}" readOnly="${form_GR_DATE_RO}" />
			<e:text>&nbsp;&nbsp;</e:text>
			<e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>

		</e:panel>

		<e:panel height="fit" width="80%">
			<e:buttonBar align="right" width="100%">
				<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<e:button id="doGrSave" name="doGrSave" label="${doGrSave_N}" onClick="doGrSave" disabled="${doGrSave_D}" visible="${doGrSave_V}"/>
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			</e:buttonBar>
		</e:panel>



        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>