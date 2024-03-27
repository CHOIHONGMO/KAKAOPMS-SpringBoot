<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BNM1/BNM101/";
        var mngYn = "${ses.mngYn}";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_REQ_NO') {

                	var param = {
        	    		CUST_CD : grid.getCellValue(rowId, 'CUST_CD'),
        	    		ITEM_REQ_NO : grid.getCellValue(rowId, 'ITEM_REQ_NO'),
        	    		ITEM_REQ_SEQ : grid.getCellValue(rowId, 'ITEM_REQ_SEQ'),
        	    		'detailView': grid.getCellValue(rowId, 'PROGRESS_NM')=="요청작성"?false:true,
        	    		'popupFlag': true
        			};
                    everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
                }
                if(colId === "ITEM_CD") {
                    if(value !== "" && grid.getCellValue(rowId, 'PROGRESS_CD') >= '500'){
                        param = {
                                ITEM_CD: grid.getCellValue(rowId, 'ITEM_CD'),
                                popupFlag: true,
                                detailView: false
                            };
                            everPopup.im03_014open(param);
						return;



                    	var param = {
                            ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                            CUST_CD : grid.getCellValue(rowId, "CUST_CD"),
                            APPLY_COM : grid.getCellValue(rowId, "APPLY_COM"),
                            CONT_NO : grid.getCellValue(rowId, "CONT_NO"),
                            CONT_SEQ : grid.getCellValue(rowId, "CONT_SEQ"),
                            CART_YN : true,
                            popupFlag: true,
                            detailView: false
                        };
                        everPopup.im03_014open(param);
                    }
                }
             	// 의뢰자
                if(colId == 'REQUEST_USER_NM') {
                    if( grid.getCellValue(rowId, 'REQUEST_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'REQUEST_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
             	// 품목담당
                if(colId == 'SG_CTRL_USER_NM') {
                    if( grid.getCellValue(rowId, 'SG_CTRL_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            EVF.C("PROGRESS_CD").removeOption("T");
            EVF.C("PROGRESS_CD").removeOption("R");
            EVF.C("PROGRESS_CD").removeOption("100");
            EVF.C("PROGRESS_CD").removeOption("300");
            EVF.C("PROGRESS_CD").removeOption("400");
            EVF.C("PROGRESS_CD").removeOption("440");
            EVF.C("PROGRESS_CD").removeOption("450");
            EVF.C("PROGRESS_CD").removeOption("500");

            var chkName = "";
            $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                if (v.value == '550' || v.value == '560') {
                    chkName += v.title + ", ";
                    v.checked = true;
                }
            });
            $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));


            /*
            grid.setColGroup([{
                "groupName": "계약정보",
                "columns": [ "SALES_UNIT_PRICE", "CUR", "VALID_FROM_DATE", "VALID_TO_DATE", "VENDOR_CD", "VENDOR_NM" ]
            }],55);
             */

            if( '${superUserFlag}' != 'true' ) {
                EVF.C('ADD_PLANT_CD').setDisabled(true);
                EVF.C('ADD_PLANT_NM').setDisabled(true);
                if( '${havePermission}' == 'true' ) {
                    EVF.C('DDP_CD').setDisabled(false);// 사업부

                    EVF.C("ADD_USER_ID").setDisabled(false);// 주문자ID
                    EVF.C("ADD_USER_NM").setDisabled(false);// 주문자명
                } else {
                    EVF.C('DDP_CD').setDisabled(true);	// 사업부

                    EVF.C("ADD_USER_ID").setDisabled(true);
                    EVF.C("ADD_USER_NM").setDisabled(true);
                }
            }

        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.setParameter("CUST_CD", "${ses.companyCd}");
            store.load(baseUrl + "BNM1_032/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                //grid.setColIconify("SOURCING_REJECT_RMK", "SOURCING_REJECT_RMK", "comment", false);
            });
        }

       function doAddCart() {

            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cartCnt = 0;
            var rows = grid.getSelRowValue();
            for (var i = 0; i < rows.length; i++) {
                if(rows[i].PROGRESS_CD !== "560") {
                    alert("${BNM1_032_008}"); // 진행상태가 [상품등록완료] 건만 처리할 수 있습니다.
                    return;
                }

                if(EVF.isEmpty(rows[i].ITEM_CD)) {
                    alert("${BNM1_032_009}"); // 상품코드가 없거나 단가가 존재하지 않습니다.
                    return;
                }

                if(EVF.isEmpty(rows[i].CART_QT) || rows[i].CART_QT == 0) {
                	alert("${BNM1_032_010}"); // 주문수량을 입력하세요.
                    return;
                }
            }

            if(!confirm("${BNM1_032_006}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "bnm1032_doAddCart", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 관심상품등록
        function doInterestItem() {

			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

        	var itemInfo = "";
        	var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	if( grid.getCellValue(rowIds[i], 'PROGRESS_CD') !== "560" ) {
                    alert("${BNM1_032_008}"); // 진행상태가 [상품등록완료] 건만 처리할 수 있습니다.
                    return;
                }

                if( EVF.isEmpty(grid.getCellValue(rowIds[i], 'ITEM_CD')) || EVF.isEmpty(grid.getCellValue(rowIds[i], 'CONT_NO')) ) {
                    alert("${BNM1_032_009}"); // 상품코드가 없거나 단가가 존재하지 않습니다.
                    return;
                }

            	var itemCd     = grid.getCellValue(rowIds[i], 'ITEM_CD');
            	var applyCom   = grid.getCellValue(rowIds[i], 'APPLY_COM');
            	var contNum    = grid.getCellValue(rowIds[i], 'CONT_NO');
            	var contSeq    = grid.getCellValue(rowIds[i], 'CONT_SEQ');
            	var applyPlant = grid.getCellValue(rowIds[i], 'APPLY_PLANT');

            	itemInfo = itemInfo + itemCd + ":" + applyCom + ":" + contNum + ":" + contSeq + ":"+applyPlant+",";
    		}

        	var param = {
                itemInfo : itemInfo,
                detailView : false
            };
        	everPopup.openPopupByScreenId('BOD1_032', 600, 400, param);
        }

        function onSearchUser() {
            var param = {
            	custCd: "${ses.companyCd}",
                callBackFunction: "setUser"
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function setUser(data) {
            EVF.C("ADD_USER_ID").setValue(data.USER_ID);
            EVF.C("ADD_USER_NM").setValue(data.USER_NM);
        }

        function onSearchDept() {
        	if( mngYn != '1' ) { return; }
            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setDept",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : "${ses.companyCd}",
                'custNm' : "${ses.companyNm}"
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
        }

        function setDept(data) {
            data = JSON.parse(data);
            EVF.C("ADD_DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("ADD_DEPT_NM").setValue(data.DEPT_NM);
        }

        function onSearchPlant() {
            var param = {
                    callBackFunction: "_setPlant",
                    custCd: "${ses.companyCd}"
                };
                everPopup.openCommonPopup(param, 'SP0005');
        }

        function _setPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("ADD_PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("ADD_PLANT_NM").setValue(jsondata.PLANT_NM);
        }

    </script>

    <e:window id="BNM1_032" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
            	<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="ADD_FROM_DATE" name="ADD_FROM_DATE" value="${oneMonthAgo}" toDate="ADD_TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="ADD_TO_DATE" name="ADD_TO_DATE" value="${today}" fromDate="ADD_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
                </e:field>
                <e:label for="ADD_PLANT_CD" title="${form_ADD_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="ADD_PLANT_CD" name="ADD_PLANT_CD" value="${ses.mngYn eq '1' ? '' : ses.plantCd }" width="40%" maxLength="${form_ADD_PLANT_CD_M}" disabled="${form_ADD_PLANT_CD_D}" readOnly="${form_ADD_PLANT_CD_RO}" required="${form_ADD_PLANT_CD_R}" onIconClick="onSearchPlant" />
                    <e:inputText id="ADD_PLANT_NM" name="ADD_PLANT_NM" value="${ses.mngYn eq '1' ? '' : ses.plantNm }" width="60%" maxLength="${form_ADD_PLANT_NM_M}" disabled="${form_ADD_PLANT_NM_D}" readOnly="${form_ADD_PLANT_NM_RO}" required="${form_ADD_DEPT_NM_R}" />
                </e:field>
                <e:label for="DDP_CD" title="${form_DDP_CD_N}" />
                <e:field>
                    <e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ADD_USER_ID" title="${form_ADD_USER_ID_N}"/>
                <e:field>
                    <e:search id="ADD_USER_ID" name="ADD_USER_ID" value="${ses.mngYn eq '1' ? '' : ses.userId }" width="40%" maxLength="${form_ADD_USER_ID_M}" disabled="${form_ADD_USER_ID_D}" readOnly="${form_ADD_USER_ID_RO}" required="${form_ADD_USER_ID_R}" onIconClick="onSearchUser" />
                    <e:inputText id="ADD_USER_NM" name="ADD_USER_NM" value="${ses.mngYn eq '1' ? '' : ses.userNm }" width="60%" maxLength="${form_ADD_USER_NM_M}" disabled="${form_ADD_USER_NM_D}" readOnly="${form_ADD_USER_NM_RO}" required="${form_ADD_USER_NM_R}" />
                </e:field>
                <e:label for="ITEM_NM" title="${form_ITEM_NM_N}" />
				<e:field>
					<e:inputText id="ITEM_NM" name="ITEM_NM" value="" width="${form_ITEM_NM_W}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}" />
				</e:field>
            	<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" useMultipleSelect="true" usePlaceHolder="false" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<e:button id="AddCart" name="AddCart" label="${AddCart_N}" onClick="doAddCart" disabled="${AddCart_D}" visible="${AddCart_V}"/>
			<e:button id="InterestItem" name="InterestItem" label="${InterestItem_N}" onClick="doInterestItem" disabled="${InterestItem_D}" visible="${InterestItem_V}"/>
		</e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>