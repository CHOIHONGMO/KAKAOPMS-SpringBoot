<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/STO/PO0550/";
        var ROWIDX;

        function init() {
            grid = EVF.C("grid");
            EVF.C('CUST_NM').setDisabled(true);
            EVF.C('PLANT_CD').setDisabled(true);
            EVF.C('PR_TYPE').setDisabled(true);
            EVF.C('CPO_USER_NM').setDisabled(true);
            EVF.C('DEAL_CD').setDisabled(true);

            EVF.C("PR_TYPE").removeOption("R");


          <c:if test = "${form.newOrder == '0'}">
	      var paramArray = ${paramArray}
           for(var i in paramArray) {
             var param={
                     CUST_CD       	 : EVF.V("CUST_CD")
                   , CUST_NM       	 : EVF.V("CUST_NM")
                   , CPO_USER_ID   	 : EVF.V("CPO_USER_ID")
                   , CPO_USER_NM   	 : EVF.V("CPO_USER_NM")
                   , CPO_USER_DEPT_CD: EVF.V("CPO_USER_DEPT_CD")
                   , PR_SUBJECT 	 : EVF.V("PR_SUBJECT")
                   , PR_TYPE 		 : EVF.V("PR_TYPE")
                   , CPO_DATE 		 : EVF.V("CPO_DATE")
                   , HOPE_DUE_DATE 	 : EVF.V("HOPE_DUE_DATE")
                   , PLANT_CD        : "${ses.plantCd}"
                   , PLANT_NM        : "${ses.plantNm}"
                   , PRIOR_GR_FLAG 	 : "0"
                   , RESULT_CD		 : "New"
                   , CUR			 : "KRW"
                   , ITEM_CD 		 : paramArray[i].ITEM_CD
                   , ITEM_DESC		 : paramArray[i].ITEM_DESC
                   , ITEM_SPEC 		 : paramArray[i].ITEM_SPEC
                   , MAKER_NM 		 : paramArray[i].MAKER_NM
                   , MAKER_CD 		 : paramArray[i].MAKER_CD
                   , BRAND_NM 		 : paramArray[i].BRAND_NM
                   , ORIGIN_CD 		 : paramArray[i].ORIGIN_CD
                   , DEAL_CD 		 : paramArray[i].DEAL_CD
                   , CPO_QTY 		 : paramArray[i].PO_QTY
                   , WH_CD 			 : paramArray[i].WH_CD
                   , LOG_CD 	     : paramArray[i].LOG_CD
                   , UNIT_CD		 : paramArray[i].UNIT_CD
                   , CUST_ITEM_CD	 : paramArray[i].CUST_ITEM_CD }
             grid.addRow(param)
           }
          </c:if>

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
                }else if(colId == "ITEM_CD") {
                    param = {
                    	  callBackFunction : "callbackGridITEM_CD"
                        , 'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD')
                        , 'detailView': false
                        , 'searchFlag': 'Y'
                        , DEAL_CD 	: grid.getCellValue(rowId, "DEAL_CD")
                    };
                    everPopup.openPopupByScreenId("STO01_020", 900, 600, param);
    		    }else if(colId == "VENDOR_CD") {
					if(grid.getCellValue(rowId, "ITEM_CD") ==''){
					   return alert("상품을 먼저 선택해주세요")}
                    param = {
                        callBackFunction : "callbackGridVENDOR_CD",
                        ITEM_CD : grid.getCellValue(rowId, "ITEM_CD"),
                        DEAL_CD : grid.getCellValue(rowId, "DEAL_CD"),
                        popupFlag : true,
                        rowId : rowId
                    };
                    everPopup.openPopupByScreenId("PO0560", 900, 600, param);
                } else if(colId == "DELY_NM") {
                    param = {
                        callBackFunction: "callbackGridRECIPIENT_NM",
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: false
                    };
                    everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                }else if(colId == "REQ_TEXT") {
                    param = {
                        title: "요청사항",
                        message: grid.getCellValue(rowId, "REQ_TEXT"),
                        callbackFunction: "callbackGridREQ_TEXT",
                        detailView: false,
                        rowId: rowId
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
                }
            })

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {


              if( colId == "MAKER_PART_NO"
                   || colId == "BRAND_CD"
                    || colId == "PR_TYPE"
                    || colId == "ITEM_DESC"
                    || colId == "ITEM_SPEC"
                    || colId == "MAKER_CD"
                    || colId == "ORIGIN_CD"
                    || colId == "UNIT_CD"
                    || colId == "CUR"
                    || colId == "CPO_UNIT_PRICE"
                    || colId == "CPO_ITEM_AMT"
            ) {
               if (grid.getCellValue(rowId, "ITEM_CD")!='') {
                  grid.setCellValue(rowId,colId, oldValue);
                  return alert("${PO0550_017}");
               }
              }

                if(colId == "CPO_QTY" || colId == 'CPO_UNIT_PRICE') {
                    var CPO_ITEM_AMT = grid.getCellValue(rowId, "CPO_QTY") * grid.getCellValue(rowId, "CPO_UNIT_PRICE");
                    var PO_ITEM_AMT = value * grid.getCellValue(rowId, "PO_UNIT_PRICE");

                    grid.setCellValue(rowId, "CPO_ITEM_AMT", CPO_ITEM_AMT);
                    grid.setCellValue(rowId, "PO_ITEM_AMT", PO_ITEM_AMT);
                } else if(colId == "IF_UNIT_PRICE") {
                    grid.setCellValue(rowId, "IF_ITEM_AMT",  grid.getCellValue(rowId, "IF_UNIT_PRICE") * grid.getCellValue(rowId, "CPO_QTY") );
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
            grid.addRowEvent(function() {
            	var param = {
            		  CUST_CD         : EVF.V("CUST_CD")
                    , CUST_NM         : EVF.V("CUST_NM")
                    , CPO_USER_ID     : EVF.V("CPO_USER_ID")
                    , CPO_USER_NM     : EVF.V("CPO_USER_NM")
                    , PLANT_CD        : "${ses.plantCd}"
                    , PLANT_NM        : "${ses.plantNm}"
                    , CPO_USER_DEPT_CD: EVF.V("CPO_USER_DEPT_CD")
                    , PR_SUBJECT 	  : EVF.V("PR_SUBJECT")
                    , PR_TYPE 		  : EVF.V("PR_TYPE")
                    , CPO_DATE 		  : EVF.V("CPO_DATE")
                    , HOPE_DUE_DATE   : EVF.V("HOPE_DUE_DATE")
                    , PRIOR_GR_FLAG   : "0"
                    , RESULT_CD		  : "New"
                    , CUR			  : "KRW"
                    , DEAL_CD 		  : EVF.V("DEAL_CD")}
		    	grid.addRow(param);
		    });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });
             chgCustCd();
        }       //INIT

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var PR_SUBJECT = EVF.V("PR_SUBJECT");

            if(PR_SUBJECT == "") {
                return alert("${PO0550_022}");
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
        function callbackGridVENDOR_CD(data) {
        	 var ndata = JSON.parse(data);
             grid.setCellValue(ROWIDX, "VENDOR_CD", ndata.VENDOR_CD);
             grid.setCellValue(ROWIDX, "VENDOR_NM", ndata.VENDOR_NM);
             grid.setCellValue(ROWIDX, "LEAD_TIME", ndata.LEAD_TIME);
             grid.setCellValue(ROWIDX, "PO_UNIT_PRICE", ndata.CONT_UNIT_PRICE);
             grid.setCellValue(ROWIDX, "MOQ_QTY", ndata.MOQ_QTY);
             grid.setCellValue(ROWIDX, "RV_QTY", ndata.RV_QTY);
             grid.setCellValue(ROWIDX, "DELY_TYPE", ndata.DELY_TYPE);
             grid.setCellValue(ROWIDX, "SG_CTRL_USER_ID", ndata.SG_CTRL_USER_ID);
             grid.setCellValue(ROWIDX, "TAX_CD", ndata.TAX_CD);
             grid.setCellValue(ROWIDX, "CUST_ITEM_CD", ndata.CUST_ITEM_CD)
             var PO_ITEM_AMT = (grid.getCellValue(ROWIDX, "PO_UNIT_PRICE") * grid.getCellValue(ROWIDX, "CPO_QTY"));
             grid.setCellValue(ROWIDX, "PO_ITEM_AMT", PO_ITEM_AMT);
             grid.setCellValue(ROWIDX, "CONT_NO", ndata.CONT_NO);
             grid.setCellValue(ROWIDX, "CONT_SEQ",ndata.CONT_SEQ);


        }
        function callbackGridITEM_CD(data) {

        	 var ndata = JSON.parse(data);

        	 grid.setCellValue(ROWIDX, "MAKER_NM", ndata.MAKER_NM);
        	 grid.setCellValue(ROWIDX, "MAKER_CD", ndata.MAKER_CD);
        	 grid.setCellValue(ROWIDX, "ITEM_CD", ndata.ITEM_CD);
        	 grid.setCellValue(ROWIDX, "ITEM_DESC", ndata.ITEM_DESC);
        	 grid.setCellValue(ROWIDX, "ITEM_SPEC", ndata.ITEM_SPEC);
        	 grid.setCellValue(ROWIDX, "MAKER_NM", ndata.MAKER_NM);
        	 grid.setCellValue(ROWIDX, "BRAND_NM", ndata.BRAND_NM);
        	 grid.setCellValue(ROWIDX, "ORIGIN_CD", ndata.ORIGIN_CD);
        	 grid.setCellValue(ROWIDX, "VENDOR_CD", ndata.VENDOR_CD);
             grid.setCellValue(ROWIDX, "VENDOR_NM", ndata.VENDOR_NM);
             grid.setCellValue(ROWIDX, "LEAD_TIME", ndata.LEAD_TIME);
             grid.setCellValue(ROWIDX, "PO_UNIT_PRICE", ndata.CONT_UNIT_PRICE);
             grid.setCellValue(ROWIDX, "MOQ_QTY", ndata.MOQ_QTY);
             grid.setCellValue(ROWIDX, "RV_QTY", ndata.RV_QTY);
             grid.setCellValue(ROWIDX, "DELY_TYPE", ndata.DELY_TYPE);
             grid.setCellValue(ROWIDX, "SG_CTRL_USER_ID", ndata.SG_CTRL_USER_ID);
             grid.setCellValue(ROWIDX, "TAX_CD", ndata.TAX_CD);
             grid.setCellValue(ROWIDX, "CUST_ITEM_CD", ndata.CUST_ITEM_CD)
             var PO_ITEM_AMT = (grid.getCellValue(ROWIDX, "PO_UNIT_PRICE") * grid.getCellValue(ROWIDX, "CPO_QTY"));
             grid.setCellValue(ROWIDX, "PO_ITEM_AMT", PO_ITEM_AMT);
             grid.setCellValue(ROWIDX, "CONT_NO", ndata.CONT_NO);
             grid.setCellValue(ROWIDX, "CONT_SEQ",ndata.CONT_SEQ);
        	 grid.setCellValue(ROWIDX, "UNIT_CD", ndata.UNIT_CD);

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

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
        }


        function doOrder() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            // 결재 및 예산검토여부가 y인 고객은 일괄주문할 수 없음
            if( EVF.V("BUDGET_FLAG") == "Y" ){
                return alert("${PO0550_016}");
            }

            var curDate = new Date().toString('yyyyMMdd');
            var rowIds  = grid.getSelRowId();

            var tempPrType = grid.getCellValue( 0 , 'PR_TYPE');

            for( var i in rowIds ) {

               if(tempPrType != grid.getCellValue(rowIds[i], 'PR_TYPE')) {
                    return alert("${PO0550_021}");
               }
                if( grid.getCellValue(rowIds[0], 'CUST_CD') != grid.getCellValue(rowIds[i], 'CUST_CD') ) {
                    return alert("${PO0550_003}"); // 동일 고객사
                }
                if( grid.getCellValue(rowIds[0], 'CPO_DATE') != grid.getCellValue(rowIds[i], 'CPO_DATE') ) {
                    return alert("${PO0550_004}"); // 동일 주문일자
                }
                if( grid.getCellValue(rowIds[0], 'CPO_USER_ID') != grid.getCellValue(rowIds[i], 'CPO_USER_ID') ) {
                    return alert("${PO0550_003}"); // 동일 주문자
                }
                if( Number(grid.getCellValue(rowIds[i], 'CPO_QTY')) <= 0 ) {
                    return alert("${PO0550_006}");
                }
                if( (grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE')).length != 8 ){
                    return alert("${PO0550_009}");
                }
                if( Number(grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE')) <= Number(grid.getCellValue(rowIds[i], 'CPO_DATE')) ){
                    return alert("${PO0550_009}");
                }
                if( Number(grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE')) < Number(curDate) ){
                    return alert("${PO0550_011}");
                }
                var mouQty = Number(grid.getCellValue(rowIds[i], "MOQ_QTY")); // 최소주문량
                var rvQty  = Number(grid.getCellValue(rowIds[i], "RV_QTY")); // 주문배수
                var cartQt = Number(grid.getCellValue(rowIds[i], "CPO_QTY")); // 주문수량
                // 주문수량 >= 최소주문량 and 주문수량 = 최소주문량 * 발주배수
                if(!(cartQt >= mouQty && (cartQt === mouQty || (cartQt - mouQty) % rvQty === 0))) {
                   if(grid.getCellValue(rowIds[i], 'ITEM_CD') != ''){
                        return alert("${PO0550_006}");
                   }
                }
            }

            if(!confirm('${PO0550_013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'PO0550_doOrder', function() {
                 alert(this.getResponseMessage());
                 window.close();

            });
        }


        function comma(obj) {
            var regx = new RegExp(/(-?\d+)(\d{3})/);
            var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
            var strArr = obj.split('.');
            while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
                //정수 부분에만 콤마 달기
                strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
            }
            if (bExists > -1) {
                //. 소수점 문자열이 발견되지 않을 경우 -1 반환
                obj = strArr[0] + "." + strArr[1];
            } else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
                obj = strArr[0];
            }
            return obj;//문자열 반환
        }

        // 첨부파일 양식 다운로드
        function dotempletDownload() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'PO0550');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);

            }, false);
        }


        function chgCustCd() {
            var store = new EVF.Store;
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getPlantCd', function() {
               if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
               }
                <c:if test="${ses.userType == 'B'}">
               EVF.C('PLANT_CD').setValue('${ses.plantCd}');
               </c:if>
            });
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

    <e:window id="PO0550" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form1" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false">
            <e:inputHidden id="approvalFormData" name="approvalFormData" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" />
            <e:inputHidden id="attachFileDatas"  name="attachFileDatas" />
            <e:inputHidden id="CPO_USER_DEPT_CD"  name="CPO_USER_DEPT_CD" value="${ses.deptCd}"/>
            <e:row>
               <e:label for="CUST_NM" title="${form_CUST_NM_N}"/>
               <e:field>
                    <e:inputHidden id="CUST_CD"  name="CUST_CD" value="${ses.manageCd}"/>
                    <e:inputHidden id="PR_BUYER_CD"  name="PR_BUYER_CD" />
                    <e:inputHidden id="BUDGET_FLAG"  name="BUDGET_FLAG" value=""/>
                    <e:inputHidden id="CUST_CD_ORI"  name="CUST_CD_ORI" />
                    <e:search id="CUST_NM" name="CUST_NM" value="${ses.manageComNm}" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" onIconClick="onIconClickCUST_NM" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
               </e:field>
               <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
               <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${ses.plantCd}" options="${plantCdOptions}" width="${form_PLANT_CD_W}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" usePlaceHolder="false"/>
               </e:field>
               <e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}"/>
               <e:field>
                   <e:search id="CPO_USER_NM" name="CPO_USER_NM" value="${ses.userNm}" width="${form_CPO_USER_NM_W}" maxLength="${form_CPO_USER_NM_M}" onIconClick="onIconClickCPO_USER_NM" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                   <e:inputHidden id="CPO_USER_ID" name="CPO_USER_ID" value="${ses.userId}" />
                   <e:inputHidden id="CPO_USER_TEL_NUM" name="CPO_USER_TEL_NUM" />
                   <e:inputHidden id="CPO_USER_CELL_NUM" name="CPO_USER_CELL_NUM" value="${ses.cellNum}"/>
                   <e:inputHidden id="CPO_USER_EMAIL" name="CPO_USER_EMAIL" />
               </e:field>
            </e:row>
            <e:row>
               <e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
               <e:field>
                   <e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" usePlaceHolder="false"/>

               </e:field>
               <e:label for="CPO_DATE" title="${form_CPO_DATE_N}"/>
               <e:field>
                    <e:inputDate id="CPO_DATE" name="CPO_DATE" value="${toDate}" width="${inputDateWidth}"  toDate="HOPE_DUE_DATE" datePicker="true" required="${form_CPO_DATE_R}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" />
               </e:field>
               <e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
               <e:field>
                    <e:inputDate id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" fromDate="CPO_DATE" value="${hopeDueDate}" width="${inputDateWidth}" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
               </e:field>
               </e:row>
            <e:row>
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
		       <e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
			   <e:field>
					<e:select id="DEAL_CD" name="DEAL_CD" value="${form.DEAL_CD2}" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
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