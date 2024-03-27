<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BOD1/BOD105/";
        var mngYn = "${ses.mngYn}";
        var sesCompanyCd = "${ses.companyCd}";
        var isDev = "${isDev}" == "true";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty("sortable", false);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            	var param;

				// 주문자
				if(colId == "CPO_USER_NM") {
					if( grid.getCellValue(rowId, "CPO_USER_ID") == "" ) return;
					param = {
						callbackFunction: "",
						USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
				}
            	// 주문번호
	        	if(colId === "CPO_NO") {
	                if(value !== ""){
	                	param = {
							callbackFunction: "",
							CPO_NO: grid.getCellValue(rowId, "CPO_NO")
	                    };
	                    everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
	                }
	            }
	        	// 주문항번
	        	if(colId === "CPO_SEQ") {
	                if(value !== ""){
						param = {
							callbackFunction: "",
							CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
							CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
	                    };
	                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
	                }
	            }
            	// 품목코드
	        	if(colId === "ITEM_CD") {
	                if(value !== ""){
	                    param = {
	                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
	                        popupFlag: true,
	                        detailView: true
	                    };
	                    everPopup.im03_014open(param);
	                }
	            }
            	// 요청사항
	        	if(colId === "DELY_RMK") {
					if(value == "Y") {
						param = {
							title: "${BOD1_050_0006}",
							message: grid.getCellValue(rowId, "REQ_TEXT"),
							detailView: true
						};
						everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
					}
	            }
				// 납품지연상세사유
				if(colId == "DELY_DELAY_NM") {
					if( grid.getCellValue(rowId, "DELY_DELAY_CD") == "" ) return;
					param = {
						title: "납품지연사유",
						CODE: grid.getCellValue(rowId, "DELY_DELAY_CD"),
						TEXT: grid.getCellValue(rowId, "DELY_DELAY_REASON"),
						rowId: rowId,
						detailView: "true"
					};
					var url = "/evermp/SIV1/SIV101/SIV1_022/view";
					everPopup.openModalPopup(url, 600, 360, param);
				}
				// 납품거부상세사유
				if(colId == "DELY_REJECT_NM") {
					if( grid.getCellValue(rowId, "DELY_REJECT_CD") == "" ) return;
					param = {
						title: "납품거부사유",
						CODE: grid.getCellValue(rowId, "DELY_REJECT_CD"),
						TEXT: grid.getCellValue(rowId, "DELY_REJECT_REASON"),
						detailView: "true"
					};
					var url = "/evermp/SIV1/SIV101/SIV1_023/view";
					everPopup.openModalPopup(url, 600, 360, param);
				}
	        	// 표준화담당자
	        	if(colId == "MANAGE_NM") {
	        		if( grid.getCellValue(rowId, "MANAGE_ID") == "" ) return;
					param = {
						callbackFunction: "",
						USER_ID: grid.getCellValue(rowId, "MANAGE_ID"),
						detailView: true
					};
		            everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
	        	}
	        	// 첨부파일 업로드
	        	if(colId == "ATTACH_FILE_NO_IMG") {
	        		if( grid.getCellValue(rowId, "ATTACH_FILE_NO_IMG") == "0" ) return;
	        		everPopup.readOnlyFileAttachPopup("CPO", grid.getCellValue(rowId, "ATTACH_FILE_NO"),"",rowId);
	        	}

              if(colId == "WAYBILL_NO") { // 운송장번호
            	if(value=='') return;
                var param = {
                   		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                   		'value': value	// 송장번호
                    };
                    everPopup.CourierPop(param);
              }

            });

            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });

            var val = {"visible": true, "count": 1, "height": 40};
            var footerTxt = {
                "styles": {
                    "textAlignment": "far",
                    "font": "굴림,12",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": ["합 계 "]
            };
            var footerSum = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum"],
                "groupExpression": "sum"
            };
            grid.setProperty('footerVisible', val);
            grid.setRowFooter('CPO_UNIT_PRICE', footerTxt);
            grid.setRowFooter("CPO_ITEM_AMT", footerSum);

            if( sesCompanyCd == 'C000zz' && !isDev )
    		{
	            if( mngYn == '1' ) {
	            	grid.setRowFooter("PO_ITEM_AMT", footerSum);
	            }
    		}

            if("${param.autoSearchFlag}" == "Y") {
//                EVF.C("PROGRESS_CD").setValue("10");
//                doSearch();
            }

    		if( mngYn != '1' ) {
//            	EVF.C("DEPT_CD").setReadOnly(true);
//            	EVF.C("DEPT_NM").setReadOnly(true);
            }

    		//관리자가 아니면 매입단가, 매입금액

    		if( sesCompanyCd == 'C000zz' && !isDev )
    		{
        		if( mngYn == '1' ) {
//        			grid.hideCol("PO_UNIT_PRICE",false);
//        			grid.hideCol("PO_ITEM_AMT",false);
                }
    		}else {
//    			grid.hideCol("PO_UNIT_PRICE",true);
//    			grid.hideCol("PO_ITEM_AMT",true);
    		}

            if("Y" === "${param.MOVE_LINK_YN}") {
                EVF.V("CUST_CD", "${param.CUST_CD}");
                EVF.V("DEPT_CD", "${param.CPO_DEPT_CD}");
                EVF.V("DEPT_NM", "${param.CPO_DEPT_NM}");
                EVF.V("CPO_USER_ID", "${param.CPO_USER_ID}");
                EVF.V("CPO_USER_NM", "${param.CPO_USER_NM}");
                EVF.V("START_DATE_COMBO", "${param.START_DATE_COMBO}");
                EVF.V("START_DATE", "${param.START_DATE}");
                EVF.V("END_DATE", "${param.END_DATE}");
                EVF.V("DOC_NUM_COMBO", "${param.DOC_NUM_COMBO}");
                EVF.V("DOC_NUM", "${param.DOC_NUM}");
                EVF.V("ITEM_CD", "${param.ITEM_CD}");

                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '30' || v.value == '36' || v.value == '38' || v.value == '40' || v.value == '50' || v.value == '60' || v.value == '65' || v.value == '70') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            }


			grid.freezeCol("PR_SUBJECT");
			chgCustCd();




			if('${param.PROGRESS_CD}' != '') {

                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '10' || v.value == '15' || v.value == '20' || v.value == '25' || v.value == '26' || v.value == '30' || v.value == '40' || v.value == '45' || v.value == '50') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));


			}

			if('${superUserFlag}' != 'true' ) {
				EVF.C('PLANT_CD').setDisabled(true);
				EVF.C('PLANT_NM').setDisabled(true);
				if( '${havePermission}' == 'true' ) {
					EVF.C('DDP_CD').setDisabled(false);// 사업부

					EVF.C("CPO_USER_ID").setDisabled(false);// 주문자ID
					EVF.C("CPO_USER_NM").setDisabled(false);// 주문자명
				} else {
					EVF.C('DDP_CD').setDisabled(true);	// 사업부

					EVF.C("CPO_USER_ID").setDisabled(true);
					EVF.C("CPO_USER_NM").setDisabled(true);
				}
			}

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "BOD1_050/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                grid.setColIconify("DELY_RMK", "REQ_TEXT", "comment", false);
				grid.setColIconify("DELY_DELAY_NM", "DELY_DELAY_CD", "comment", false);
				grid.setColIconify("DELY_REJECT_NM", "DELY_REJECT_CD", "comment", false);

				grid.setColMerge(['CPO_NO_SEQ', 'CUST_NM', 'DEPT_NM', 'CPO_USER_NM', 'BD_DEPT_NM', "ACCOUNT_CD", 'ACCOUNT_NM', 'COST_CENTER_CD', 'COST_CENTER_NM', 'PLANT_CD', 'IF_CPO_NO_SEQ', 'CPO_NO','CPO_SEQ',
					'REF_MNG_NO', 'CUST_ITEM_CD','ITEM_CD','NAP_FLAG','ITEM_DESC','ITEM_SPEC', 'MAKER_NM', 'MAKER_PART_NO', 'BRAND_NM', 'ORIGIN_CD', 'UNIT_CD', 'MOQ_QTY', 'CPO_QTY', 'CUR', 'CPO_UNIT_PRICE', 'CPO_ITEM_AMT',
					//'PO_UNIT_PRICE','PO_ITEM_AMT','LEAD_TIME','YPO_REG_DATE','DELY_PLACE','DELY_TYPE','REQ_USER_NM','RECIPIENT_TEL_NUM', 'RECIPIENT_FAX_NUM', 'RECIPIENT_CELL_NUM', 'RECIPIENT_EMAIL'
					//'REQ_USER_TEL_NUM','SUP_INV_QTY','SUP_NOT_INV_QTY','SUP_NOT_GR_QTY',
					'CPO_DATE',  'HOPE_DUE_DATE', 'LEAD_TIME_DATE',   'RECIPIENT_NM',
					'CSDM_SEQ', 'DELY_NM', 'RECIPIENT_DEPT_NM', ,'DELY_ZIP_CD', 'DELY_ADDR_1', 'DELY_ADDR_2',
					 'PO_NO', 'PO_SEQ', 'VENDOR_NM', 'REQ_TEXT', 'ATTACH_FILE_NO_IMG']);

				//grid.setColMerge(['VENDOR_NM','IV_NO', 'IV_SEQ', 'IF_INVC_CD', 'INV_QTY', 'DELY_APP_DATE', 'DELY_COMPLETE_DATE', 'DELY_COMPLETE_USER_NM', 'MANAGE_NM', 'DELY_COMPANY_NM', 'WAYBILL_NO', 'DELY_REJECT_NM', 'DELY_REJECT_REASON', 'DELY_REJECT_DATE','DELY_DELAY_NM', 'DELY_DELAY_REASON']);
            });
        }

        function searchCustDeptCd() {

        	if( mngYn != '1' ) { return; }

            var custCd = EVF.V("CUST_CD");
        	if( custCd == "" ) {
            	alert("${BOD1_050_001}");
                return;
    		}

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "selectCustDeptCd",
                AllSelectYN: true,
                detailView: false,
                multiYN: false,
                ModalPopup: true,
                custCd: custCd,
                custNm: "${ses.companyNm }"
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function selectCustDeptCd(dataJsonArray) {
        	var data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function searchCustUserId() {
        	var custCd = EVF.V("CUST_CD");
        	if( custCd == "" ) {
            	alert("${BOD1_050_001}");
                return;
    		}

        	var param = {
        			callBackFunction: "selectCustUserId",
        			custCd: custCd
                };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function selectCustUserId(dataJsonArray) {
            EVF.C("CPO_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CPO_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        function doCpoPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                cpoList.push( grid.getCellValue(rowIds[i], 'CPO_NO') );
            }

            // 중복 값 제거
            var cpouniq = cpoList.reduce(function(a,b){
                if (a.indexOf(b) < 0 ) a.push(b);
                return a;
            },[]);

            var param = {
                CPO_LIST : JSON.stringify(cpouniq)
			};
            everPopup.openPopupByScreenId("PRT_030", 976, 800, param);
		}

        function searchBRAND_CD(){
            var param = {
                callBackFunction : "callBackBRAND_CD"
            };
            everPopup.openCommonPopup(param, 'SP0088');
        }

        function callBackBRAND_CD(data) {
            EVF.V("BRAND_CD", data.MKBR_CD);
            EVF.V("BRAND_NM", data.MKBR_NM);
        }
    	//사업장 팝업
		function selectPlant(){

			var param = {
					 custCd			  : "${ses.companyCd }"
					,callBackFunction : 'callback_setPlant'
				}
			everPopup.openCommonPopup(param, 'SP0005');
		}
		function callback_setPlant(data){
			EVF.V("PLANT_NM", data.PLANT_NM);
			EVF.V("PLANT_CD", data.PLANT_CD);

		}
		//사업부 팝업
		function selectDiv(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PLANT_CD') === '') {
				return EVF.alert('${BOD1_040_025}');
			}
			var param = {
					 custCd			  : "${ses.companyCd }"
					,plantCd          : EVF.V('PLANT_CD')
					,callBackFunction : 'callback_setDiv'
				}
			everPopup.openCommonPopup(param, 'SP0020');
		}
		function callback_setDiv(data){
			EVF.V("DIVISION_CD", data.DIVISION_CD);
			EVF.V("DIVISION_NM", data.DIVISION_NM);

		}




        function chgCustCd() {
            var store = new EVF.Store;
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
                    EVF.C('DIVISION_CD').setOptions([]);
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);

            	}
            });
        }

        function chgPlantCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "100");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DIVISION_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);
            	}
            });
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

		function onSearchPlant() {
			var param = {
				callBackFunction : "callBackPlant",
				custCd: EVF.V("CUST_CD")
			};
			everPopup.openCommonPopup(param, 'SP0005');
		}

		function callBackPlant(data) {
			jsondata = JSON.parse(JSON.stringify(data));
			EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
			EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
		}


    </script>

    <e:window id="BOD1_050" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd }" />
            <e:inputHidden id="FIRST_GR_FLAG" name="FIRST_GR_FLAG" value="" />
            <e:inputHidden id="MAKER_CD" name="MAKER_CD" value="" />
            <e:inputHidden id="MAKER_NM" name="MAKER_NM" value="" />
            <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="" />



            <e:row>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
				<e:label for="DDP_CD" title="${form_DDP_CD_N}" />
				<e:field>
					<e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
				</e:field>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="${CPO_USER_ID}" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="${CPO_USER_NM}" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
            </e:row>

            <e:row>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				<e:inputHidden id="PR_SUBJECT" name="PR_SUBJECT"/>
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${BOD1_050_020}" value="CPO_DATE"/>
                        <e:option text="${BOD1_050_021}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE }" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE }" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field colSpan="5">
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false"/>
				</e:field>
			</e:row>


        </e:searchPanel>

		<e:buttonBar align="right" width="100%">
						<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>



        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>