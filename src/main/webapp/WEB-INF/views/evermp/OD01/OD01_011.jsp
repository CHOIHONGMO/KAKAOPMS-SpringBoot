<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var grid2;
        var baseUrl = "/evermp/OD01/OD0101/";
        var PROGRESS_CD;

        function init() {

            grid = EVF.C("grid");
            grid2 = EVF.C("grid2");

            grid.setProperty('shrinkToFit', true);
            grid2.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            });

            grid.showCheckBar(false);
            grid2.showCheckBar(false);

            PROGRESS_CD = "${DATA.PROGRESS_CD}";
            if(PROGRESS_CD === "10" || PROGRESS_CD === "20") {
                $("#order_f").hide();
                $("#order_n").show();
                $("#delivery_generation_f").hide();
                $("#delivery_generation_n").show();
                $("#delivery_completion_f").hide();
                $("#delivery_completion_n").show();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "30" || PROGRESS_CD === "36" || PROGRESS_CD === "38") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").hide();
                $("#delivery_generation_n").show();
                $("#delivery_completion_f").hide();
                $("#delivery_completion_n").show();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "40") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").show();
                $("#delivery_generation_n").hide();
                $("#delivery_completion_f").hide();
                $("#delivery_completion_n").show();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "50" || PROGRESS_CD === "65") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").show();
                $("#delivery_generation_n").hide();
                $("#delivery_completion_f").show();
                $("#delivery_completion_n").hide();
                $("#inbound_f").hide();
                $("#inbound_n").show();
            } else if(PROGRESS_CD === "60" || PROGRESS_CD === "70") {
                $("#order_f").show();
                $("#order_n").hide();
                $("#delivery_generation_f").show();
                $("#delivery_generation_n").hide();
                $("#delivery_completion_f").show();
                $("#delivery_completion_n").hide();
                $("#inbound_f").show();
                $("#inbound_n").hide();
            }
            $("#process_arrow_01").show();
            $("#process_arrow_02").show();
            $("#process_arrow_03").show();

            // 결재중 또는 예산체크하는 고객사는 주문변경 안됨
            <%-- if( EVF.V("SIGN_STATUS") == "P" || EVF.V("BUDGET_FLAG") == "Y" ){ --%>
            if( EVF.V("SIGN_STATUS") == "P"){
            	EVF.C("doConfirm").setDisabled(true);
            	EVF.C("doSearchVendor").setDisabled(true);
            	EVF.C("CPO_QTY").setReadOnly(true);
            	EVF.C("CPO_UNIT_PRICE").setReadOnly(true);
            	EVF.C("PO_UNIT_PRICE").setReadOnly(true);
            	EVF.C("CHANGE_REMARK").setReadOnly(true);
            }

            if(PROGRESS_CD === "30" || PROGRESS_CD === "40") {
                $('#doSaveRecipient').find('.e-button-center-wrapper').css('background', '#d1fdff');
                $('#doSaveRecipient').find('.e-button-text').css('color', '#000000');
                $('label[for*=RECIPIENT]').parent().css('background', '#d1fdff');
                $('label[for*=RECIPIENT]').css('background', '#d1fdff');
                $('label[for*=DELY]').parent().css('background', '#d1fdff');
                $('label[for*=DELY]').css('background', '#d1fdff');
                $('label[for*=REQ_TEXT]').parent().css('background', '#d1fdff');
                $('label[for*=REQ_TEXT]').css('background', '#d1fdff');
            } else {
                EVF.C("doSaveRecipient").setDisabled(true);
                EVF.C("RECIPIENT_NM").setReadOnly(true);
                EVF.C("RECIPIENT_DEPT_NM").setReadOnly(true);
                EVF.C("RECIPIENT_TEL_NUM").setReadOnly(true);
                EVF.C("RECIPIENT_CELL_NUM").setReadOnly(true);
                EVF.C("DELY_ZIP_CD").setReadOnly(true);
                EVF.C("DELY_ADDR_2").setReadOnly(true);
                EVF.C("REQ_TEXT").setReadOnly(true);
            }

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid, grid2]);
            store.load(baseUrl + "od01011_doSearch", function () {
                if(grid.getRowCount() == 0) {
                }
            });
        }

        // 주문변경
        // 1. 주문변경수량 = 주문수량 - 납품수량 까지 변경 가능
        // 2. 매입 및 판매단가 = 납품완료여부 또는 입고완료여부가 1개라도 YES이면 단가 변경안됨
        //  -. 납품완료되지 않은 납품건은 납품단가도 함께 변경
        // 3. 공급사 = 납품완료여부 또는 입고완료여부가 1개라도 YES이면 단가 변경안됨
        //  -. 납품완료되지 않은 납품건은 납품서 삭제 후 신규 주문 생성
        function doConfirm() {

    		var store = new EVF.Store();
    		if (!store.validate()) {
				return;
			}

    		// 0. 예산체크 고객사는 주문변경 안됨
    		<%--if( EVF.V("BUDGET_FLAG") == "Y" ){--%>
				<%--return alert("${OD01_011_006}");--%>
            <%--}--%>

    		// 1. 입고 완료시 주문변경 안됨
            if( EVF.V("GR_COMPLETE_FLAG") == "1" ){
				return alert("${OD01_011_004}");
            }

            var cpoQty = Number(EVF.V("CPO_QTY"));
            var invQty = Number(EVF.V("INV_QTY"));
            var CPO_QTY_ORI = Number(EVF.V("CPO_QTY_ORI"));

            if(CPO_QTY_ORI > 0) {
                // 수량은 감소만 가능
                if( cpoQty > CPO_QTY_ORI ){
                    return alert("${OD01_011_005}");
                }

                if(cpoQty < invQty){
                    alert("${OD01_011_007}");
                    EVF.C("CPO_QTY").setValue(Number(EVF.V("CPO_QTY_ORI")));
                    return;
                }

                // 최소주문량, 주문배수 체크.
                var MOQ_QTY = Number(EVF.C("MOQ_QTY").getValue());
                var RV_QTY = Number(EVF.C("RV_QTY").getValue());
                <%--
                if(!(Number(EVF.V("CPO_QTY")) >= MOQ_QTY && (Number(EVF.V("CPO_QTY")) === MOQ_QTY || (Number(EVF.V("CPO_QTY")) - MOQ_QTY) % RV_QTY === 0))) {
                    alert("${OD01_011_007}");
                    EVF.C("CPO_QTY").setValue(Number(EVF.V("CPO_QTY_ORI")));
                }
                --%>
            } else {
                if(cpoQty >= 0) {
                    alert("${OD01_011_018}");
                    return;
                } else {
                    if(invQty < 0) {
                        if(cpoQty > invQty){
                            alert("${OD01_011_007}");
                            return;
                        }
                    }
                }
            }

            // 변경전후 비교
            var approvalFlag = "0";
        	if( Number(EVF.V("CPO_UNIT_PRICE")) != Number(EVF.V("CPO_UNIT_PRICE_ORI")) ||
       			Number(EVF.V("PO_UNIT_PRICE"))  != Number(EVF.V("PO_UNIT_PRICE_ORI"))  ||
       			Number(EVF.V("CPO_QTY"))  != Number(EVF.V("CPO_QTY_ORI"))  ||
       			EVF.V("VENDOR_CD") != EVF.V("VENDOR_CD_ORI") )
        	{
                // 납품완료여부가 1개라도 있으면 단가, 공급사 변경안됨
                var rowIds = grid.getAllRowId();
                for( var i in rowIds ) {
                	if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == '1' ) {
        				return alert("${OD01_011_003}");
        			}
        		}
        		approvalFlag = "1";
        		EVF.C("CUST_SIGN_FLAG").setValue(approvalFlag);
        	} else {
        		// 변경사항이 없는 경우
        		if( Number(EVF.V("CPO_QTY")) == Number(EVF.V("CPO_QTY_ORI")) ){
        			return alert("${OD01_011_002}");
        		}
        	}

        	if(!confirm('${OD01_011_001}')) { return; }

        	// 결재사용여부 = 1
            if( approvalFlag == "1" ) {
            	var itemCd  = EVF.V("ITEM_CD");
	            var subject = EVF.V("ITEM_DESC");
	            var cpoAmt  = EVF.V("CPO_ITEM_AMT");
	            var bizCls1 = "05"; // 발주(운영사→공급사)

				// 매출가/수량 > 단가/수량변경
				if((Number(EVF.V("CPO_QTY")) != Number(EVF.V("CPO_QTY_ORI"))) || (Number(EVF.V("CPO_UNIT_PRICE")) != Number(EVF.V("CPO_UNIT_PRICE_ORI")))) {
					bizCls1 = "04"; // 주문(고객사→운영사)
					bizCls2 = "05";
					bizCls3 = "05";
				}
				// 공급사변경 > 공급사변경
				if(EVF.V("VENDOR_CD") != EVF.V("VENDOR_CD_ORI")) {
					bizCls2 = "11";
					bizCls3 = "12";
				}
				// 매입가/수량 > 단가/수량변경
				if(Number(EVF.V("PO_UNIT_PRICE")) != Number(EVF.V("PO_UNIT_PRICE_ORI"))) {
					bizCls2 = "06"; // 매입가/수량
					bizCls3 = "05"; // 단가/수량 변경
				}

	        	var param = {
					subject: "[" + itemCd + " : "+ subject + "] 주문 변경 결재요청",
					docType: "PO",
					signStatus: "P",
					screenId: "BOD1_030",
					approvalType: 'APPROVAL',
					oldApprovalFlag: "",
					attFileNum: "",
					docNum: "",
					appDocNum: "",
					callBackFunction: "goApproval",
					bizCls1: bizCls1,
					bizCls2: bizCls2,
					bizCls3: bizCls3,
					bizAmt: cpoAmt
				};
	            everPopup.openApprovalRequestIIPopup(param);
            } else {
            	goApproval();
            }
        }

        // 결재창 오픈
        function goApproval(formData, gridData, attachData) {

        	EVF.C('approvalFormData').setValue(formData);
			EVF.C('approvalGridData').setValue(gridData);
			EVF.C('attachFileDatas').setValue(attachData);

        	var store = new EVF.Store();
        	store.doFileUpload(function() {
            	store.setGrid([grid]);
                store.getGridData(grid, 'sel');
            	store.load(baseUrl + 'od01011_doOrder', function () {
            		alert(this.getResponseMessage());
                    if( this.getResponseCode() == "OK" ){
                        opener["${param.callbackFunction}"]();
                        window.close();
                    }
                });
            });
	    }

        function orderChange() {
        	var cpoQty = Number(EVF.V("CPO_QTY"));
            var invQty = Number(EVF.V("INV_QTY"));
        	var cpoUnitPrice = Number(EVF.V("CPO_UNIT_PRICE"));
        	var poUnitPrice  = Number(EVF.V("PO_UNIT_PRICE"));
            var CPO_QTY_ORI = Number(EVF.V("CPO_QTY_ORI"));

            if(CPO_QTY_ORI > 0) {
                if( cpoQty > CPO_QTY_ORI){
                    alert("${OD01_011_005}");
                    EVF.C("CPO_QTY").setValue(Number(EVF.V("CPO_QTY_ORI")));
                    return;
                }

                if(cpoQty < invQty){
                    alert("${OD01_011_007}");
                    EVF.C("CPO_QTY").setValue(Number(EVF.V("CPO_QTY_ORI")));
                    return;
                }

                var MOQ_QTY = Number(EVF.C("MOQ_QTY").getValue());
                var RV_QTY = Number(EVF.C("RV_QTY").getValue());
                EVF.C("CPO_ITEM_AMT").setValue(everMath.round_float(cpoQty * cpoUnitPrice, 0));
                EVF.C("PO_ITEM_AMT").setValue(everMath.round_float(cpoQty * poUnitPrice, 0));

                <%--if(Number(EVF.V("CPO_QTY")) >= MOQ_QTY && (Number(EVF.V("CPO_QTY")) === MOQ_QTY || (Number(EVF.V("CPO_QTY")) - MOQ_QTY) % RV_QTY === 0)) {
                    EVF.C("CPO_ITEM_AMT").setValue(everMath.round_float(cpoQty * cpoUnitPrice, 0));
                    EVF.C("PO_ITEM_AMT").setValue(everMath.round_float(cpoQty * poUnitPrice, 0));
                } else {
                    alert("${OD01_011_007}");
                    EVF.C("CPO_QTY").setValue(Number(EVF.V("CPO_QTY_ORI")));
                }--%>
			} else {
				if(cpoQty >= 0) {
                    alert("${OD01_011_018}");
                    EVF.C("CPO_QTY").setValue(CPO_QTY_ORI);

                } else {
				    if(invQty < 0) {
                        if(cpoQty > invQty){
                            alert("${OD01_011_007}");
                            EVF.C("CPO_QTY").setValue(Number(EVF.V("CPO_QTY_ORI")));
                            return;
                        }
                    }
                    EVF.C("CPO_ITEM_AMT").setValue(everMath.round_float(cpoQty * cpoUnitPrice, 0));
                    EVF.C("PO_ITEM_AMT").setValue(everMath.round_float(cpoQty * poUnitPrice, 0));
                }
			}

        }

        function doSearchVendor() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM_ORI").setValue(dataJsonArray.VENDOR_NM);
            EVF.C("VENDOR_CHANGE_FLAG").setValue("Y");
        }

        function onClickUserInfo(USER_TYPE, USER_ID) {
            var param = {
                callbackFunction: "",
                USER_ID: USER_ID,
                detailView : true
            };
            everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
		}

		function onClickVendorInfo(VENDOR_CD) {
            var param = {
                VENDOR_CD: VENDOR_CD,
                detailView: true,
                popupFlag: true
            };
            everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
		}

		function doSaveRecipient() {
            var store = new EVF.Store();

            if(!(PROGRESS_CD === "30" || PROGRESS_CD === "40")) {
                return alert("${OD01_011_008}");
            }

            if(EVF.V("RECIPIENT_NM") === "") {
                EVF.C("RECIPIENT_NM").setFocus();
                return alert("${OD01_011_009}");
            } else if(EVF.V("RECIPIENT_DEPT_NM") === "") {
                EVF.C("RECIPIENT_DEPT_NM").setFocus();
                return alert("${OD01_011_010}");
            } else if(EVF.V("RECIPIENT_TEL_NUM") === "") {
                EVF.C("RECIPIENT_TEL_NUM").setFocus();
                return alert("${OD01_011_011}");
            } else if(EVF.V("RECIPIENT_CELL_NUM") === "") {
                EVF.C("RECIPIENT_CELL_NUM").setFocus();
                return alert("${OD01_011_012}");
            } else if(EVF.V("DELY_ZIP_CD") === "") {
                EVF.C("DELY_ZIP_CD").setFocus();
                return alert("${OD01_011_013}");
            } else if(EVF.V("DELY_ADDR_1") === "") {
                EVF.C("DELY_ADDR_1").setFocus();
                return alert("${OD01_011_014}");
            } else if(EVF.V("DELY_ADDR_2") === "") {
                EVF.C("DELY_ADDR_2").setFocus();
                return alert("${OD01_011_015}");
            }

            if(!confirm('${OD01_011_016}')) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'od01011_doSaveRecipient', function () {
                alert(this.getResponseMessage());
            });
		}

		function searchRECIPIENT_NM() {
            if(PROGRESS_CD === "30" || PROGRESS_CD === "40") {
                var param = {
                    callBackFunction : "callBackRECIPIENT_NM",
                    CUST_CD : EVF.V("CUST_CD"),
                    USER_ID : EVF.V("CPO_USER_ID"),
                    detailView : false
                };
                everPopup.openPopupByScreenId("MY01_006", 800, 600, param);
            }
		}

        function callBackRECIPIENT_NM(data) {
            EVF.V("RECIPIENT_NM", data.HIDDEN_RECIPIENT_NM);
            EVF.V("RECIPIENT_DEPT_NM", data.RECIPIENT_DEPT_NM);
            EVF.V("RECIPIENT_TEL_NUM", data.HIDDEN_RECIPIENT_TEL_NUM);
            EVF.V("RECIPIENT_CELL_NUM", data.HIDDEN_RECIPIENT_CELL_NUM);
            EVF.V("DELY_ZIP_CD", data.DELY_ZIP_CD);
            EVF.V("DELY_ADDR_1", data.DELY_ADDR_1);
            EVF.V("DELY_ADDR_2", data.DELY_ADDR_2);
            EVF.V("REQ_TEXT", data.DELY_RMK);
        }

        function searchDELY_ZIP_CD() {
            if(PROGRESS_CD === "30" || PROGRESS_CD === "40") {
                var url = "/common/code/BADV_020/view";
                var param = {
                    callBackFunction : "callBackDELY_ZIP_CD",
                    modalYn : false
                };
                //everPopup.openWindowPopup(url, 700, 600, param);
                everPopup.jusoPop(url, param);
            }
		}

        function callBackDELY_ZIP_CD(data) {
            if (data.ZIP_CD != "") {
                EVF.V("DELY_ZIP_CD", data.ZIP_CD_5);
                EVF.V("DELY_ADDR_1", data.ADDR1);
                EVF.V("DELY_ADDR_2", data.ADDR2);
                //EVF.V("DELY_ADDR_2", "");
            }
        }
    </script>

    <e:window id="OD01_011" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:panel height="fit"  width="100%">
			<table style="margin-left: auto;margin-right: auto;margin-top: auto;margin-bottom: auto;">
				<tr>
					<td width="226px">
						<img id="order_f" name="delivery_generation_f" src="/images/kakao/sub/order_f.png" alt="주문생성_f" style="display: none;">
						<img id="order_n" name="delivery_generation_f" src="/images/kakao/sub/order_n.png" alt="주문생성_n" style="display: none;">
					</td>
					<td width="44px">
						<img id="process_arrow_01" name="process_arrow_01" src="/images/kakao/sub/process_arrow.png" style="display: none;">
					</td>
					<td width="226px">
						<img id="delivery_generation_f" name="delivery_generation_f" src="/images/kakao/sub/delivery_generation_f.png" alt="납품생성_f" style="display: none;">
						<img id="delivery_generation_n" name="delivery_generation_f" src="/images/kakao/sub/delivery_generation_n.png" alt="납품생성_n" style="display: none;">
					</td>
					<td width="44px">
						<img id="process_arrow_02" name="process_arrow_02" src="/images/kakao/sub/process_arrow.png" style="display: none;">
					</td>
					<td width="226px">
						<img id="delivery_completion_f" name="delivery_generation_f" src="/images/kakao/sub/delivery_completion_f.png" alt="납품완료_f" style="display: none;">
						<img id="delivery_completion_n" name="delivery_generation_f" src="/images/kakao/sub/delivery_completion_n.png" alt="납품완료_n" style="display: none;">
					</td>
					<td width="44px">
						<img id="process_arrow_03" name="process_arrow_03" src="/images/kakao/sub/process_arrow.png" style="display: none;">
					</td>
					<td>
						<img id="inbound_f" name="inbound_f" src="/images/kakao/sub/inbound_f.png" alt="입고_f" style="display: none;">
						<img id="inbound_n" name="inbound_n" src="/images/kakao/sub/inbound_n.png" alt="입고_n" style="display: none;">
					</td>
				</tr>
			</table>
		</e:panel>

		<e:panel id="panelLeft" height="fit" width="40%">
			<e:title title="${OD01_011_CAPTION01 }" depth="1"/>
		</e:panel>
		<e:panel id="PanelRight" height="fit" width="60%">
            <e:buttonBar id="buttonBar" align="right" width="100%">
                <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
            </e:buttonBar>
        </e:panel>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false">
        	<e:inputHidden id="PO_NO"            name="PO_NO"  value="${DATA.PO_NO}" />
        	<e:inputHidden id="PO_SEQ"           name="PO_SEQ" value="${DATA.PO_SEQ}" />
        	<e:inputHidden id="SIGN_STATUS"      name="SIGN_STATUS" value="${DATA.CHANGE_SIGN_STATUS}" />
        	<e:inputHidden id="MOQ_QTY" 		 name="MOQ_QTY" value="${DATA.MOQ_QTY}" />
        	<e:inputHidden id="RV_QTY"			 name="RV_QTY" value="${DATA.RV_QTY}" />
        	<e:inputHidden id="GR_COMPLETE_FLAG" name="GR_COMPLETE_FLAG" value="${DATA.GR_COMPLETE_FLAG}" /> <!-- 입고 완료시 주문변경 안됨 -->
        	<e:inputHidden id="CUST_SIGN_FLAG"   name="CUST_SIGN_FLAG" /> <!-- 결재여부 : 공급사, 단가(매입, 판가) 변경시 결재 진행 -->
            <e:inputHidden id="approvalFormData" name="approvalFormData" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" />
            <e:inputHidden id="attachFileDatas"  name="attachFileDatas" />
			<e:inputHidden id="INV_QTY" name="INV_QTY" value="${DATA.INV_QTY}"/>
			<e:inputHidden id="CUST_CD" name="CUST_CD" value="${DATA.CUST_CD}" />
			<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${DATA.PROGRESS_CD}" />

            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${DATA.ITEM_CD}" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="CUST_ITEM_CD" name="CUST_ITEM_CD" value="${DATA.CUST_ITEM_CD}" width="${form_CUST_ITEM_CD_W}" maxLength="${form_CUST_ITEM_CD_M}" disabled="${form_CUST_ITEM_CD_D}" readOnly="${form_CUST_ITEM_CD_RO}" required="${form_CUST_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}" />
				<e:field>
					<e:inputText id="ITEM_STATUS" name="ITEM_STATUS" value="${DATA.ITEM_STATUS}" width="${form_ITEM_STATUS_W}" maxLength="${form_ITEM_STATUS_M}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" />
				</e:field>
            </e:row>

            <e:row>
				<e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
				<e:field>
					<e:inputText id="MAKER_NM" name="MAKER_NM" value="${DATA.MAKER_NM}" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field colSpan="3">
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${DATA.ITEM_DESC}" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
			</e:row>

            <e:row>
				<e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
				<e:field>
					<e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="${DATA.MAKER_PART_NO}" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
				</e:field>
				<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
				<e:field colSpan="3">
					<e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="${DATA.ITEM_SPEC}" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
				</e:field>
            </e:row>

			<e:row>
				<e:label for="BRAND_NM" title="${form_BRAND_NM_N}" />
				<e:field>
					<e:inputText id="BRAND_NM" name="BRAND_NM" value="${DATA.BRAND_NM}" width="${form_BRAND_NM_W}" maxLength="${form_BRAND_NM_M}" disabled="${form_BRAND_NM_D}" readOnly="${form_BRAND_NM_RO}" required="${form_BRAND_NM_R}" />
				</e:field>
				<e:label for="ORIGIN_NM" title="${form_ORIGIN_NM_N}" />
				<e:field>
					<e:inputText id="ORIGIN_NM" name="ORIGIN_NM" value="${DATA.ORIGIN_NM}" width="${form_ORIGIN_NM_W}" maxLength="${form_ORIGIN_NM_M}" disabled="${form_ORIGIN_NM_D}" readOnly="${form_ORIGIN_NM_RO}" required="${form_ORIGIN_NM_R}" />
				</e:field>
				<e:label for="SG_CTRL_USER_NM" title="${form_SG_CTRL_USER_NM_N}" />
				<e:field>
					<e:inputHidden id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${DATA.SG_CTRL_USER_ID}"/>
					<e:text><a href="javascript:onClickUserInfo('C', '${DATA.SG_CTRL_USER_ID}');">${DATA.SG_CTRL_USER_NM}</a></e:text>
				</e:field>
			</e:row>
        </e:searchPanel>

		<e:panel id="panel2" height="fit" width="100%">
			<e:title title="${OD01_011_CAPTION02 }" depth="1"/>
		</e:panel>

		<e:searchPanel id="form2" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false">
			<e:row>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputHidden id="CPO_NO" name="CPO_NO" value="${DATA.CPO_NO}"/>
					<e:inputHidden id="CPO_SEQ" name="CPO_SEQ" value="${DATA.CPO_SEQ}"/>
					<e:inputText id="CPO_NO_L" name="CPO_NO_L" value="${DATA.CPO_NO}  / ${DATA.PROGRESS_NM}" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				</e:field>
				<e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="DEPT_NM" name="DEPT_NM" value="${DATA.DEPT_NM}" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				</e:field>
				<e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}" />
				<e:field>
					<e:inputHidden id="CPO_USER_ID" name="CPO_USER_ID" value="${DATA.CPO_USER_ID}"/>
					<e:text><a href="javascript:onClickUserInfo('B', '${DATA.CPO_USER_ID}');">${DATA.CPO_USER_NM}</a></e:text>
				</e:field>
			</e:row>

			<e:row>
				<e:label for="BUDGET_FLAG" title="${form_BUDGET_FLAG_N}" />
				<e:field>
					<e:inputText id="BUDGET_FLAG" name="BUDGET_FLAG" value="${DATA.BUDGET_FLAG}" width="${form_BUDGET_FLAG_W}" maxLength="${form_BUDGET_FLAG_M}" disabled="${form_BUDGET_FLAG_D}" readOnly="${form_BUDGET_FLAG_RO}" required="${form_BUDGET_FLAG_R}" />
				</e:field>
				<e:label for="BD_DEPT_NM" title="${form_BD_DEPT_NM_N}" />
				<e:field>
					<e:inputHidden id="BD_DEPT_CD" name="BD_DEPT_CD" value="${DATA.BD_DEPT_CD}"/>
					<e:inputText id="BD_DEPT_NM" name="BD_DEPT_NM" value="${DATA.BD_DEPT_NM}" width="${form_BD_DEPT_NM_W}" maxLength="${form_BD_DEPT_NM_M}" disabled="${form_BD_DEPT_NM_D}" readOnly="${form_BD_DEPT_NM_RO}" required="${form_BD_DEPT_NM_R}" />
				</e:field>
				<e:label for="APPROVE_FLAG" title="${form_APPROVE_FLAG_N}" />
				<e:field>
					<e:inputText id="APPROVE_FLAG" name="APPROVE_FLAG" value="${DATA.APPROVE_FLAG}" width="${form_APPROVE_FLAG_W}" maxLength="${form_APPROVE_FLAG_M}" disabled="${form_APPROVE_FLAG_D}" readOnly="${form_APPROVE_FLAG_RO}" required="${form_APPROVE_FLAG_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}" />
				<e:field>
					<e:inputText id="ACCOUNT_CD" name="ACCOUNT_CD" value="${DATA.ACCOUNT_CD}" width="${form_ACCOUNT_CD_W}" maxLength="${form_ACCOUNT_CD_M}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
				</e:field>
				<e:label for="ACCOUNT_NM" title="${form_ACCOUNT_NM_N}" />
				<e:field>
					<e:inputText id="ACCOUNT_NM" name="ACCOUNT_NM" value="${DATA.ACCOUNT_NM}" width="${form_ACCOUNT_NM_W}" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
				</e:field>
				<e:label for="PRIOR_GR_FLAG" title="${form_PRIOR_GR_FLAG_N}" />
				<e:field>
					<e:inputText id="PRIOR_GR_FLAG" name="PRIOR_GR_FLAG" value="${DATA.PRIOR_GR_FLAG}" width="${form_PRIOR_GR_FLAG_W}" maxLength="${form_PRIOR_GR_FLAG_M}" disabled="${form_PRIOR_GR_FLAG_D}" readOnly="${form_PRIOR_GR_FLAG_RO}" required="${form_PRIOR_GR_FLAG_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="CPO_DATE" title="${form_CPO_DATE_N}" />
				<e:field>
					<e:inputText id="CPO_DATE" name="CPO_DATE" value="${DATA.CPO_DATE}" width="${form_CPO_DATE_W}" maxLength="${form_CPO_DATE_M}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" required="${form_CPO_DATE_R}" />
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:inputHidden id="VENDOR_CD_ORI" name="VENDOR_CD_ORI" value="${DATA.VENDOR_CD}"/> <!-- 변경전 공급사코드 -->
					<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${DATA.VENDOR_CD}"/> <!-- 변경후 공급사코드 -->
					<e:inputText id="VENDOR_NM_ORI" name="VENDOR_NM_ORI" value="${DATA.VENDOR_NM}" width="61%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
					<e:inputHidden id="VENDOR_CHANGE_FLAG" name="VENDOR_CHANGE_FLAG" value=""/> <!-- 변경여부 -->
					<e:text>&nbsp;</e:text>
					<e:button id="doSearchVendor" name="doSearchVendor" label="${doSearchVendor_N}" onClick="doSearchVendor" disabled="${doSearchVendor_D}" visible="${doSearchVendor_V}" align="right"/>
				</e:field>
				<e:label for="REF_MNG_NO" title="${form_REF_MNG_NO_N}" />
				<e:field>
					<e:inputText id="REF_MNG_NO" name="REF_MNG_NO" value="${DATA.REF_MNG_NO}" width="${form_REF_MNG_NO_W}" maxLength="${form_REF_MNG_NO_M}" disabled="${form_REF_MNG_NO_D}" readOnly="${form_REF_MNG_NO_RO}" required="${form_REF_MNG_NO_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="CPO_QTY" title="${form_CPO_QTY_N}"/>
				<e:field>
					<e:inputHidden id="CPO_QTY_ORI" name="CPO_QTY_ORI" value="${DATA.CPO_QTY}"/>
					<e:inputNumber id="CPO_QTY" name="CPO_QTY" value="${DATA.CPO_QTY}" width="${form_CPO_QTY_W}" maxValue="${form_CPO_QTY_M}" decimalPlace="${form_CPO_QTY_NF}" disabled="${form_CPO_QTY_D}" readOnly="${form_CPO_QTY_RO}" required="${form_CPO_QTY_R}" onChange="orderChange" />
				</e:field>
				<e:label for="CPO_UNIT_PRICE" title="${form_CPO_UNIT_PRICE_N}"/>
				<e:field>
					<e:inputHidden id="CPO_UNIT_PRICE_ORI" name="CPO_UNIT_PRICE_ORI" value="${DATA.CPO_UNIT_PRICE}"/>
					<e:inputNumber id="CPO_UNIT_PRICE" name="CPO_UNIT_PRICE" value="${DATA.CPO_UNIT_PRICE}" width="${form_CPO_UNIT_PRICE_W}" maxValue="${form_CPO_UNIT_PRICE_M}" decimalPlace="${form_CPO_UNIT_PRICE_NF}" disabled="${form_CPO_UNIT_PRICE_D}" readOnly="${form_CPO_UNIT_PRICE_RO}" required="${form_CPO_UNIT_PRICE_R}" onChange="orderChange" />
				</e:field>
				<e:label for="CPO_ITEM_AMT" title="${form_CPO_ITEM_AMT_N}"/>
				<e:field>
					<e:inputHidden id="CPO_ITEM_AMT_ORI" name="CPO_ITEM_AMT_ORI" value="${DATA.CPO_ITEM_AMT}"/>
					<e:inputNumber id="CPO_ITEM_AMT" name="CPO_ITEM_AMT" value="${DATA.CPO_ITEM_AMT}" width="${form_CPO_ITEM_AMT_W}" maxValue="${form_CPO_ITEM_AMT_M}" decimalPlace="${form_CPO_ITEM_AMT_NF}" disabled="${form_CPO_ITEM_AMT_D}" readOnly="${form_CPO_ITEM_AMT_RO}" required="${form_CPO_ITEM_AMT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
				<e:field>
					<e:inputText id="UNIT_CD" name="UNIT_CD" value="${DATA.UNIT_CD}" width="${form_UNIT_CD_W}" maxLength="${form_UNIT_CD_M}" disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}" required="${form_UNIT_CD_R}" />
				</e:field>
				<e:label for="PO_UNIT_PRICE" title="${form_PO_UNIT_PRICE_N}"/>
				<e:field>
					<e:inputHidden id="PO_UNIT_PRICE_ORI" name="PO_UNIT_PRICE_ORI" value="${DATA.PO_UNIT_PRICE}"/>
					<e:inputNumber id="PO_UNIT_PRICE" name="PO_UNIT_PRICE" value="${DATA.PO_UNIT_PRICE}" width="${form_PO_UNIT_PRICE_W}" maxValue="${form_PO_UNIT_PRICE_M}" decimalPlace="${form_PO_UNIT_PRICE_NF}" disabled="${form_PO_UNIT_PRICE_D}" readOnly="${form_PO_UNIT_PRICE_RO}" required="${form_PO_UNIT_PRICE_R}" onChange="orderChange" />
				</e:field>
				<e:label for="PO_ITEM_AMT" title="${form_PO_ITEM_AMT_N}"/>
				<e:field>
					<e:inputNumber id="PO_ITEM_AMT" name="PO_ITEM_AMT" value="${DATA.PO_ITEM_AMT}" width="${form_PO_ITEM_AMT_W}" maxValue="${form_PO_ITEM_AMT_M}" decimalPlace="${form_PO_ITEM_AMT_NF}" disabled="${form_PO_ITEM_AMT_D}" readOnly="${form_PO_ITEM_AMT_RO}" required="${form_PO_ITEM_AMT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="CHANGE_REMARK" title="${form_CHANGE_REMARK_N}"/>
				<e:field colSpan="5">
					<e:textArea id="CHANGE_REMARK" name="CHANGE_REMARK" value="${(DATA.CHANGE_SIGN_STATUS=='P')?DATA.CHANGE_REMARK:''}" height="50px" width="${form_CHANGE_REMARK_W}" maxLength="${form_CHANGE_REMARK_M}" disabled="${form_CHANGE_REMARK_D}" readOnly="${form_CHANGE_REMARK_RO}" required="${form_CHANGE_REMARK_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="LEAD_TIME_DATE" title="${form_LEAD_TIME_DATE_N}" />
				<e:field>
					<e:inputText id="LEAD_TIME_DATE" name="LEAD_TIME_DATE" value="${DATA.LEAD_TIME_DATE}" width="${form_LEAD_TIME_DATE_W}" maxLength="${form_LEAD_TIME_DATE_M}" disabled="${form_LEAD_TIME_DATE_D}" readOnly="${form_LEAD_TIME_DATE_RO}" required="${form_LEAD_TIME_DATE_R}" />
				</e:field>
				<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}"/>
				<e:field>
					<e:search id="RECIPIENT_NM" name="RECIPIENT_NM" value="${DATA.RECIPIENT_NM}" width="60%" maxLength="${form_RECIPIENT_NM_M}" onIconClick="${form_RECIPIENT_NM_RO ? 'everCommon.blank' : 'searchRECIPIENT_NM'}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO}" required="${form_RECIPIENT_NM_R}" />
					<e:button id="doSaveRecipient" name="doSaveRecipient" label="${doSaveRecipient_N}" onClick="doSaveRecipient" disabled="${doSaveRecipient_D}" visible="${doSaveRecipient_V}" align="right"/>
				</e:field>

				<e:label for="RECIPIENT_DEPT_NM" title="${form_RECIPIENT_DEPT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" value="${DATA.RECIPIENT_DEPT_NM}" width="${form_RECIPIENT_DEPT_NM_W}" maxLength="${form_RECIPIENT_DEPT_NM_M}" disabled="${form_RECIPIENT_DEPT_NM_D}" readOnly="${form_RECIPIENT_DEPT_NM_RO}" required="${form_RECIPIENT_DEPT_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}" />
				<e:field>
					<e:inputText id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="${DATA.HOPE_DUE_DATE}" width="${form_HOPE_DUE_DATE_W}" maxLength="${form_HOPE_DUE_DATE_M}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" required="${form_HOPE_DUE_DATE_R}" />
				</e:field>
				<e:label for="RECIPIENT_TEL_NUM" title="${form_RECIPIENT_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM" value="${DATA.RECIPIENT_TEL_NUM}" width="${form_RECIPIENT_TEL_NUM_W}" maxLength="${form_RECIPIENT_TEL_NUM_M}" disabled="${form_RECIPIENT_TEL_NUM_D}" readOnly="${form_RECIPIENT_TEL_NUM_RO}" required="${form_RECIPIENT_TEL_NUM_R}" />
				</e:field>
				<e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${DATA.RECIPIENT_CELL_NUM}" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="DELY_ZIP_CD" title="${form_DELY_ZIP_CD_N}"/>
				<e:field>
					<e:search id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${DATA.DELY_ZIP_CD}" width="${form_DELY_ZIP_CD_W}" maxLength="${form_DELY_ZIP_CD_M}" onIconClick="${form_DELY_ZIP_CD_RO ? 'everCommon.blank' : 'searchDELY_ZIP_CD'}" disabled="${form_DELY_ZIP_CD_D}" readOnly="${form_DELY_ZIP_CD_RO}" required="${form_DELY_ZIP_CD_R}" />
				</e:field>

				<e:label for="DELY_ADDR_1" title="${form_DELY_ADDR_1_N}" />
				<e:field colSpan="3">
					<e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="${DATA.DELY_ADDR_1}" width="60%" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
					<e:inputText id="DELY_ADDR_2" name="DELY_ADDR_2" value="${DATA.DELY_ADDR_2}" width="40%" maxLength="${form_DELY_ADDR_2_M}" disabled="${form_DELY_ADDR_2_D}" readOnly="${form_DELY_ADDR_2_RO}" required="${form_DELY_ADDR_2_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REQ_TEXT" title="${form_REQ_TEXT_N}"/>
				<e:field colSpan="5">
					<e:textArea id="REQ_TEXT" name="REQ_TEXT" value="${DATA.REQ_TEXT}" height="50px" width="${form_REQ_TEXT_W}" maxLength="${form_REQ_TEXT_M}" disabled="${form_REQ_TEXT_D}" readOnly="${form_REQ_TEXT_RO}" required="${form_REQ_TEXT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}" />
				<e:field colSpan="5">
					<e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" readOnly="${form_ATTACH_FILE_NO_RO}"  fileId="${DATA.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="MP" height="90px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:panel id="panel3" height="fit" width="100%">
			<e:title title="${OD01_011_CAPTION03 }" depth="1"/>
		</e:panel>

		<e:searchPanel id="form3" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
			<e:row>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
				<e:field>
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${DATA.VENDOR_NM} / ${DATA.VENDOR_CD}" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:label for="TEL_NO" title="${form_TEL_NO_N}" />
				<e:field>
					<e:inputText id="TEL_NO" name="TEL_NO" value="${DATA.TEL_NO}" width="${form_TEL_NO_W}" maxLength="${form_TEL_NO_M}" disabled="${form_TEL_NO_D}" readOnly="${form_TEL_NO_RO}" required="${form_TEL_NO_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="IV_REG_USER_NM" title="${form_IV_REG_USER_NM_N}" />
				<e:field>
					<e:inputHidden id="IV_REG_USER_ID" name="IV_REG_USER_ID" value="${DATA.IV_REG_USER_ID}"/>
					<e:text><a href="javascript:onClickUserInfo('${DATA.USER_TYPE}', '${DATA.IV_REG_USER_ID}');">${DATA.IV_REG_USER_NM}</a></e:text>
				</e:field>
				<e:label for="IV_TEL_NUM" title="${form_IV_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="IV_TEL_NUM" name="IV_TEL_NUM" value="${DATA.IV_TEL_NUM}" width="${form_IV_TEL_NUM_W}" maxLength="${form_IV_TEL_NUM_M}" disabled="${form_IV_TEL_NUM_D}" readOnly="${form_IV_TEL_NUM_RO}" required="${form_IV_TEL_NUM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="IV_CELL_NUM" title="${form_IV_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="IV_CELL_NUM" name="IV_CELL_NUM" value="${DATA.IV_CELL_NUM}" width="${form_IV_CELL_NUM_W}" maxLength="${form_IV_CELL_NUM_M}" disabled="${form_IV_CELL_NUM_D}" readOnly="${form_IV_CELL_NUM_RO}" required="${form_IV_CELL_NUM_R}" />
				</e:field>
				<e:label for="IV_EMAIL" title="${form_IV_EMAIL_N}" />
				<e:field>
					<e:inputText id="IV_EMAIL" name="IV_EMAIL" value="${DATA.IV_EMAIL}" width="${form_IV_EMAIL_W}" maxLength="${form_IV_EMAIL_M}" disabled="${form_IV_EMAIL_D}" readOnly="${form_IV_EMAIL_RO}" required="${form_IV_EMAIL_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="100px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<e:panel id="panel4" height="fit" width="30%">
			<e:title title="${OD01_011_CAPTION04 }" depth="1"/>
		</e:panel>

		<e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="100px" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}" />

		<jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true">
			<jsp:param value="${formData.APP_DOC_NO}" name="APP_DOC_NUM" />
			<jsp:param value="${formData.APP_DOC_CNT}" name="APP_DOC_CNT" />
		</jsp:include>

    </e:window>
</e:ui>