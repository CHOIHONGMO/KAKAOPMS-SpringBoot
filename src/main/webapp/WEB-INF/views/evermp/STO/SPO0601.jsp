<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/STO/SPO0601/";
        var ROWIDX;

        function init() {
            grid = EVF.C("grid");
            userType = "${ses.userType}";
            EVF.C('CUST_CD').setDisabled(true);
            EVF.C('VENDOR_CD').setDisabled(true);
            EVF.C('VENDOR_NM').setDisabled(true);


            var paramArray =${paramArray};
         for(var i in paramArray) {
            var param={

                    CUST_CD       	 : EVF.V("CUST_CD"),
                    CUST_NM       	 : EVF.V("CUST_NM"),
                    CPO_USER_ID   	 : "${ses.userId}",
                    CPO_USER_NM   	 : "${ses.userNm}",
                    PLANT_CD		 : "-",
                    PR_SUBJECT 	  	 : EVF.V("PR_SUBJECT"),
                    ITEM_CD 		 : paramArray[i].ITEM_CD,
                    ITEM_DESC		 : paramArray[i].ITEM_DESC,
                    ITEM_SPEC 		 : paramArray[i].ITEM_SPEC,
                    ORIGIN_CD 		 : paramArray[i].ORIGIN_CD,
                    DEAL_CD 		 : paramArray[i].DEAL_CD,
                    CPO_QTY 		 : paramArray[i].PO_QTY,
                    MAKER_NM 		 : paramArray[i].MAKER_NM,
                    MAKER_CD 		 : paramArray[i].MAKER_CD,
                    BRAND_NM 		 : paramArray[i].BRAND_NM,
                    WH_CD 			 : paramArray[i].WH_CD,
                    LOG_CD 			 : paramArray[i].LOG_CD,
                    PO_UNIT_PRICE	 : paramArray[i].CONT_UNIT_PRICE,
                    MOQ_QTY			 : paramArray[i].MOQ_QTY,
                    RV_QTY 			 : paramArray[i].RV_QTY,
                    PO_ITEM_AMT 	 : paramArray[i].PO_ITEM_AMT,
                    TAX_CD 		 	 : paramArray[i].TAX_CD,
                    LEAD_TIME 		 : paramArray[i].LEAD_TIME,
                    DELY_TYPE 		 : paramArray[i].DELY_TYPE,
                    SIGN_STATUS 	 : paramArray[i].SIGN_STATUS,
                    CUST_ITEM_CD 	 : paramArray[i].CUST_ITEM_CD,
                    SG_CTRL_USER_ID	 : paramArray[i].SG_CTRL_USER_ID,
                    CONT_NO			 : paramArray[i].CONT_NO,
                    CONT_SEQ		 : paramArray[i].CONT_SEQ,
                    VENDOR_CD 		 : "${ses.companyCd}",
                    CPO_DATE 		 : EVF.V("CPO_DATE"),
                    PRIOR_GR_FLAG    : "0", //선입고여부
					PR_TYPE 		 : "G", //일반구매
                    RESULT_CD		 : "New",
                    UNIT_CD		  	 : paramArray[i].UNIT_CD,
                    ITEM_STATUS		 : paramArray[i].ITEM_STATUS,
                    CUR				 : "KRW"
            }
            grid.addRow(param);
         }


            grid.cellClickEvent(function(rowId, colId, value) {
                var param;

                ROWIDX = rowId;

                if(colId === "multiSelect") {
                    var ITEM_TOT_AMT = 0;
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        ITEM_TOT_AMT += Number(rows[i].CPO_ITEM_AMT);
                    }
                    EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                    EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));
                } if(colId == "ITEM_CD") {
                    var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupFlag': true,
                            'detailView': true
                        };
                        everPopup.im03_009open(param);
                    }else if(colId == "DELY_NM") {
                    param = {
                            callBackFunction: "callbackGridRECIPIENT_NM",
                            CUST_CD: "${ses.manageCd}",
	                        DELY_NM: grid.getCellValue(rowId, "DELY_NM"),
                            detailView: false
                     };
                   everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                }else if(colId === "MAKER_NM") {
                   if (grid.getCellValue(rowId, "ITEM_CD")!='') {
                  return;
                   }

                    var param = {
                            rowId: rowId
                        };
                        everPopup.openCommonPopup(param, "SP0068");
                }
            });


            grid._gvo.onItemAllChecked = function(gridView, checked) {
                if(checked) {
                    var ITEM_TOT_AMT = 0;
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        ITEM_TOT_AMT += Number(rows[i].CPO_ITEM_AMT);
                    }
                    EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                    EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));
                } else {
                    EVF.V("ITEM_TOT_AMT", "0");
                    EVF.V("ITEM_TOT_CNT", "0");
                }
            };


            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });

        }
        function callbackGridRECIPIENT_NM(data) {
			 grid.setCellValue(ROWIDX, "CSDM_SEQ", data.CSDM_SEQ);
	         grid.setCellValue(ROWIDX, "DELY_NM", data.DELY_NM);
	         grid.setCellValue(ROWIDX, "RECIPIENT_NM", data.HIDDEN_DELY_RECIPIENT_NM);
	         grid.setCellValue(ROWIDX, "RECIPIENT_TEL_NUM", data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
	         grid.setCellValue(ROWIDX, "RECIPIENT_CELL_NUM", data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
	         grid.setCellValue(ROWIDX, "RECIPIENT_EMAIL", data.HIDDEN_DELY_RECIPIENT_EMAIL);
	         grid.setCellValue(ROWIDX, "RECIPIENT_FAX_NUM", data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
	         grid.setCellValue(ROWIDX, "RECIPIENT_DEPT_NM", data.DELY_RECIPIENT_DEPT_NM);
	         grid.setCellValue(ROWIDX, "DELY_ZIP_CD", data.DELY_ZIP_CD);
	         grid.setCellValue(ROWIDX, "DELY_ADDR_1", data.DELY_ADDR_1);
	         grid.setCellValue(ROWIDX, "DELY_ADDR_2", data.DELY_ADDR_2);

		}


        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var PR_SUBJECT = EVF.V("PR_SUBJECT");

            if(PR_SUBJECT == "") {
                return alert("${SPO0601_022}");
            }

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                grid.setCellValue(selRowId[i], "PR_SUBJECT", PR_SUBJECT);
                grid.setCellValue(selRowId[i], "CSDM_SEQ",  EVF.V("CSDM_SEQ"));
                grid.setCellValue(selRowId[i], "DELY_NM",  EVF.V("DELY_NM"));
                grid.setCellValue(selRowId[i], "RECIPIENT_NM",  EVF.V("RECIPIENT_NM"));
                grid.setCellValue(selRowId[i], "RECIPIENT_TEL_NUM",  EVF.V("RECIPIENT_TEL_NUM"));
                grid.setCellValue(selRowId[i], "RECIPIENT_CELL_NUM",  EVF.V("RECIPIENT_CELL_NUM"));
                grid.setCellValue(selRowId[i], "RECIPIENT_EMAIL",  EVF.V("RECIPIENT_EMAIL"));
                grid.setCellValue(selRowId[i], "RECIPIENT_FAX_NUM",  EVF.V("RECIPIENT_FAX_NUM"));
                grid.setCellValue(selRowId[i], "RECIPIENT_DEPT_NM",  EVF.V("RECIPIENT_DEPT_NM"));
                grid.setCellValue(selRowId[i], "DELY_ZIP_CD",  EVF.V("DELY_ZIP_CD"));
                grid.setCellValue(selRowId[i], "DELY_ADDR_1",  EVF.V("DELY_ADDR_1"));
                grid.setCellValue(selRowId[i], "DELY_ADDR_2",  EVF.V("DELY_ADDR_2"));
            }
        }


        function doOrder() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var curDate = new Date().toString('yyyyMMdd');
            var rowIds  = grid.getSelRowId();

            var tempPrType = grid.getCellValue( 0 , 'PR_TYPE');

            for( var i in rowIds ) {
                if(tempPrType != grid.getCellValue(rowIds[i], 'PR_TYPE')) {
                    return alert("${SPO0601_021}");
                }
                if( grid.getCellValue(rowIds[0], 'CUST_CD') != grid.getCellValue(rowIds[i], 'CUST_CD') ) {
                    return alert("${SPO0601_003}"); // 동일 고객사
                }
                if( grid.getCellValue(rowIds[0], 'CPO_DATE') != grid.getCellValue(rowIds[i], 'CPO_DATE') ) {
                    return alert("${SPO0601_004}"); // 동일 주문일자
                }
                if( grid.getCellValue(rowIds[0], 'CPO_USER_ID') != grid.getCellValue(rowIds[i], 'CPO_USER_ID') ) {
                    return alert("${SPO0601_003}"); // 동일 주문자
                }
                if( Number(grid.getCellValue(rowIds[i], 'CPO_QTY')) <= 0 ) {
                    return alert("${SPO0601_006}");
                }
                if( grid.getCellValue(rowIds[i], 'PRIOR_GR_FLAG') == '1' && Number(grid.getCellValue(rowIds[i], 'CPO_DATE')) >= Number(curDate) ){
                    return alert("${SPO0601_010}");
                }
                if( grid.getCellValue(rowIds[i], 'RECIPIENT_NM') == '' || grid.getCellValue(rowIds[i], 'RECIPIENT_NM') == null) {
                    return alert("${SPO0601_024}");
               }





                var mouQty = Number(grid.getCellValue(rowIds[i], "MOQ_QTY")); // 최소주문량
                var rvQty  = Number(grid.getCellValue(rowIds[i], "RV_QTY")); // 주문배수
                var cartQt = Number(grid.getCellValue(rowIds[i], "CPO_QTY")); // 주문수량
                // 주문수량 >= 최소주문량 and 주문수량 = 최소주문량 * 발주배수
                if(!(cartQt >= mouQty && (cartQt === mouQty || (cartQt - mouQty) % rvQty === 0))) {
                   if(grid.getCellValue(rowIds[i], 'ITEM_CD') != ''){
                        return alert("${SPO0601_006}");
                   }
                }
            }

            if(!confirm('${SPO0601_013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SPO0601_doOrder', function() {
                alert(this.getResponseMessage());
            });
           doClose();


        }
        function doClose() {
        	window.close();
        }
        function getDelyAddr() {
    		param = {
                    callBackFunction: "setDelyAddr",
                    CUST_CD: EVF.V("CUST_CD"),
                    USER_ID: EVF.V("CPO_USER_ID"),
                    detailView: false
                };
            everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
        }

        function setDelyAddr(data) {
            EVF.C("CSDM_SEQ").setValue(data.CSDM_SEQ);
            EVF.C("DELY_NM").setValue(data.DELY_NM);
            EVF.C("RECIPIENT_NM").setValue(data.RECIPIENT_NM);
            EVF.C("DELY_ZIP_CD").setValue(data.DELY_ZIP_CD);
            EVF.C("DELY_ADDR_1").setValue(data.DELY_ADDR_1);
            EVF.C("DELY_ADDR_2").setValue(data.DELY_ADDR_2);
            EVF.C("RECIPIENT_TEL_NUM").setValue(data.RECIPIENT_TEL_NUM);
            EVF.C("RECIPIENT_CELL_NUM").setValue(data.RECIPIENT_CELL_NUM);
            EVF.C("RECIPIENT_EMAIL").setValue(data.RECIPIENT_EMAIL);
            EVF.C("RECIPIENT_FAX_NUM").setValue(data.RECIPIENT_FAX_NUM);
            EVF.C("RECIPIENT_DEPT_NM").setValue(data.RECIPIENT_DEPT_NM);
        }


    </script>

    <e:window id="SPO0601" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form1" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false">
           <e:row>
              <e:label for="CUST_NM" title="${form_CUST_NM_N}"/>
                 <e:field>
         			<e:inputHidden id="CUST_CD"  name="CUST_CD" value="${ses.manageCd}"/>
                    <e:inputHidden id="PR_BUYER_CD"  name="PR_BUYER_CD" />
                    <e:inputHidden id="BUDGET_FLAG"  name="BUDGET_FLAG" value=""/>
                    <e:inputHidden id="CUST_CD_ORI"  name="CUST_CD_ORI" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="${ses.manageComNm}" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                 </e:field>
              <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
               	 <e:field>
                 	 <e:inputHidden id="VENDOR_CD"  name="CUST_CD" value="${ses.companyCd}"/>
                  	 <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${ses.companyNm}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                 </e:field>
              <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}" />
                 <e:field>
                     <e:inputText id="REG_USER_NM" name="REG_USER_NM" value="${ses.userNm }" width="${form_REG_USER_NM_W}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" />
                     <e:inputHidden id="REG_USER_ID"  name="REG_USER_ID" value="${ses.userId }"/>
                 </e:field>
				 <e:inputHidden id="CPO_USER_ID"  name="CPO_USER_ID" value=""/>
				 <e:inputHidden id="CPO_USER_NM"  name="CPO_USER_NM" value=""/>
           </e:row>
           <e:row>
        	  <e:label for="CPO_DATE" title="${form_CPO_DATE_N}"/>
				 <e:field>
					 <e:inputDate id="CPO_DATE" name="CPO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_CPO_DATE_R}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" />
				</e:field>
			  <e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}" />
                 <e:field>
                     <e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="${form_PR_SUBJECT_W}" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
                 </e:field>
			   	<e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}"/>
						<e:field>
							<e:search id="CSDM_SEQ" name="CSDM_SEQ" value="${ses.csdmSeq}" width="40%" maxLength="${form_CSDM_SEQ_M}" onIconClick="${form_CSDM_SEQ_RD ? 'everCommon.blank' : 'getDelyAddr'}" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
							<e:inputText id="DELY_NM" name="DELY_NM" value="${ses.delyNm}" width="60%" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="${form_DELY_NM_RO}" required="${form_DELY_NM_R}" />
	                        <e:inputHidden id="DELY_ZIP_CD" name="DELY_ZIP_CD" />
	                        <e:inputHidden id="DELY_ADDR_1" name="DELY_ADDR_1" />
	                        <e:inputHidden id="DELY_ADDR_2" name="DELY_ADDR_2" />
	                        <e:inputHidden id="RECIPIENT_NM" name="RECIPIENT_NM" />
	                        <e:inputHidden id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" />
	                        <e:inputHidden id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" />
	                        <e:inputHidden id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" />
	                        <e:inputHidden id="RECIPIENT_FAX_NUM" name="RECIPIENT_FAX_NUM" />
	                        <e:inputHidden id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" />
						</e:field>

           </e:row>
        </e:searchPanel>
        <e:panel id="leftPanel" height="fit" width="30%">
            <e:text style="color:red;font-weight:bold;font-size:14px;">합 계 : </e:text>
            <e:text id="ITEM_TOT_AMT" name="ITEM_TOT_AMT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:gray;">(부가세별도)</e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;">, 선택건수 : </e:text>
            <e:text id="ITEM_TOT_CNT" name="ITEM_TOT_CNT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;"> 건</e:text>
            <e:text>&nbsp;&nbsp;</e:text>
            <e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>
        </e:panel>

        <e:panel id="rightPanel" height="fit" width="70%">
            <e:buttonBar id="buttonBar" align="right" width="100%">
                 <e:button id="doOrder" name="doOrder" label="${doOrder_N}" onClick="doOrder" disabled="${doOrder_D}" visible="${doOrder_V}"/>
            </e:buttonBar>
        </e:panel>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>