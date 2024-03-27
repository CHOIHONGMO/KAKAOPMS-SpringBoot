<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var gridImg;
        var baseUrl = "/evermp/BOD1/BOD104/";
        var eventRowId = 0;
        var gridType;
        var userType;

        function init() {

            grid = EVF.C("grid");
            gridImg = EVF.C("gridImg");
            gridImg.setRowHeightAll(60);
            gridImg._gvo.setHeader({height:40});

            gridType = "G";
            userType = "${ses.userType}";

            $('#List_Div').css('display', 'block');
            $('#ImgArea_Div').css('display', 'none');
            gridImg.resize();

            gridImg._gvo.setColumnProperty('CUST_ITEM_CDS', 'header', {'text': "상품코드\n고객사상품코드"});
            gridImg._gvo.setColumnProperty('PRIOR_GR_NAP_FLAG', 'header', {'text': "선입고여부\n국책여부"});
            gridImg._gvo.setColumnProperty('PROGRESS_CD_REF_MNG_NO', 'header', {'text': "진행상태\n관리번호"});
            gridImg._gvo.setColumnProperty('ITEM_DESC_SPEC', 'header', {'text': "상품명\n규격"});
            gridImg._gvo.setColumnProperty('MAKER_NM_MAKER_PART_NO', 'header', {'text': "제조사\n모델번호"});
            gridImg._gvo.setColumnProperty('BRAND_NM_ORIGIN_CD', 'header', {'text': "브랜드\n원산지"});
            gridImg._gvo.setColumnProperty('BD_DEPT_NM_ACCOUNT_CD', 'header', {'text': "예산부서\n예산계정"});
            gridImg._gvo.setColumnProperty('COST_CENTER', 'header', {'text': "코스트센터코드\n코스트센터명"});
            gridImg._gvo.setColumnProperty('PLANT', 'header', {'text': "플랜트코드\n플랜트명"});
            gridImg._gvo.setColumnProperty('UNIT_CD_CUR', 'header', {'text': "단위\n통화"});
            gridImg._gvo.setColumnProperty('CPO_QTY_UNIT_PRC', 'header', {'text': "수량\n단가"});
            gridImg._gvo.setColumnProperty('LEAD_TIME_HOPE_DUE_DATE', 'header', {'text': "주문일자\n희망납기일"});
            gridImg._gvo.setColumnProperty('CSDM_SEQ_DELY_NM', 'header', {'text': "배송지코드\n배송지명"});
            gridImg._gvo.setColumnProperty('RECIPIENT_NM_DEPT_NM', 'header', {'text': "인수자명\n인수자부서"});
            gridImg._gvo.setColumnProperty('RECIPIENT_TEL_FAX_NUM', 'header', {'text': "인수자연락처\n인수자팩스번호"});
            gridImg._gvo.setColumnProperty('RECIPIENT_CELL_EMAIL', 'header', {'text': "인수자휴대전화\n인수자이메일"});
            gridImg._gvo.setColumnProperty('DELY_ADDR', 'header', {'text': "기본주소\n상세주소"});

            if(userType == "C") {
                gridImg._gvo.setColumnProperty('CPO_QTY_CONT_UNIT_PRC', 'header', {'text': "수량\n매입단가"});
            } else {
                gridImg.hideCol("CPO_QTY_CONT_UNIT_PRC", true);
                gridImg.hideCol("CONT_UNIT_AMT", true);
                gridImg.hideCol("PROFIT_RATE", true);
                grid.hideCol("CONT_UNIT_PRC", true);
                grid.hideCol("CONT_UNIT_AMT", true);
                grid.hideCol("PROFIT_RATE", true);
                grid.hideCol("VENDOR_CD",true);
                grid.hideCol("VENDOR_NM",true);
            }

            grid.cellClickEvent(function(rowId, colId, value) {
                var param;

                eventRowId = rowId;

                if (colId == "ITEM_CD") {
                    param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupYn': "Y",
                        'detailView': false
                    };
                    everPopup.im03_014open(param);
                }
                if (colId == "DELY_RMK") {
                    if( grid.getCellValue(rowId, 'DELY_RMK') == "" ) return;
                    param = {
                        title: '요청사항',
                        message: grid.getCellValue(rowId, 'DELY_RMK'),
                        detailView: true
                    };
                    var url = '/common/popup/common_text_view/view';
                    everPopup.openModalPopup(url, 500, 300, param);
                }
                if (colId == "ATTACH_FILE_NO_IMG") {
                    if( grid.getCellValue(rowId, 'ATTACH_FILE_NO_IMG') == '0' ) return;
                    param = {
                        attFileNum: grid.getCellValue(rowId, 'ATTACH_FILE_NO'),
                        rowId: rowId,
                        detailView: true,
                        bizType: 'CPO',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if (colId == "VENDOR_NM") {
                    if(userType == "C"){
                        var param = {
                            VENDOR_CD: grid.getCellValue(rowId, 'VENDOR_CD'),
                            detailView: true,
                            popupFlag: true
                        };
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                    }
                }
            });

            gridImg.cellClickEvent(function(rowId, colId, value) {
                var param;

                eventRowId = rowId;

                if (colId == "DELY_RMK") {
                    if( gridImg.getCellValue(rowId, 'DELY_RMK') == "" ) return;
                    param = {
                        title: '요청사항',
                        message: gridImg.getCellValue(rowId, 'DELY_RMK'),
                        detailView: true
                    };
                    var url = '/common/popup/common_text_view/view';
                    everPopup.openModalPopup(url, 500, 300, param);
                }
                if (colId == "ATTACH_FILE_NO_IMG") {
                    if( gridImg.getCellValue(rowId, 'ATTACH_FILE_NO_IMG') == '0' ) return;
                    param = {
                        attFileNum: gridImg.getCellValue(rowId, 'ATTACH_FILE_NO'),
                        rowId: rowId,
                        detailView: true,
                        bizType: 'CPO',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
            });

            gridImg._gvo.onShowTooltip = function (grid, index, value) {
                var column = index.column;
                var itemIndex = index.itemIndex;

                var tooltip = "";
                if (column == 'MAIN_IMG') {
                    tooltip = gridImg.getCellValue(itemIndex, 'MAIN_IMG_TOOLTIP');
                }
                return tooltip;
            };

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridImg.excelExportEvent({
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
                text: "0",
                expression: ["sum"],
                groupExpression: "sum"
            };

            grid.setProperty("footerVisible", val);
            grid.setProperty('multiSelect', ("${formData.SIGN_STATUS}" == "R" ? true : false));
            gridImg.setProperty('multiSelect', ("${formData.SIGN_STATUS}" == "R" ? true : false));

            grid.setRowFooter("UNIT_PRC", footerTxt);
            grid.setRowFooter("ITEM_AMT", footerSum);
            if(userType == "C") { grid.setRowFooter("CONT_UNIT_AMT", footerSum); }

            grid.setColIconify("DELY_RMK", "DELY_RMK", "comment", false);
            gridImg.setColIconify("DELY_RMK", "DELY_RMK", "comment", false);

            doSearch();
        }

        function doSearch() {

            var itemTotal = 0; var contTotal = 0;
            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setParameter("gridType", gridType);
            if(gridType == "I") {
                store.setGrid([gridImg]);
                store.load(baseUrl + "bod1042_doSearch", function () {
                    if(gridImg.getRowCount() == 0) {
                        EVF.V("ITEM_TOT_AMT", "0");
                        EVF.V("ITEM_TOT_CNT", "0");
                        if(userType == "C") {
                            EVF.C("CONT_TOT_AMT").setValue("0");
                            EVF.C("PROFIT_RATE").setValue("0");
                        }
                    } else {
                        var rowIds = gridImg.getAllRowId();
                        for (var i in rowIds) {
                            itemTotal += Number(gridImg.getCellValue(rowIds[i], 'ORI_ITEM_AMT'));
                            if(userType == "C") { contTotal += Number(gridImg.getCellValue(rowIds[i], 'CONT_UNIT_AMT')); }

                            if(gridImg.getCellValue(rowIds[i], 'PROGRESS_CD') == "36") {
                                gridImg.setCellFontColor(rowIds[i], 'PROGRESS_CD_REF_MNG_NO', "#ff4c29");
                                gridImg.setCellFontWeight(rowIds[i], 'PROGRESS_CD_REF_MNG_NO', true);
                            }

                        }
                        EVF.C("ITEM_TOT_AMT").setValue(comma(String(itemTotal)));
                        EVF.C("ITEM_TOT_CNT").setValue(comma(String(gridImg.getRowCount())));
                        if(userType == "C") {
                            var profitRate = 0;
                            if(!EVF.isEmpty(itemTotal) && itemTotal > 0 && !EVF.isEmpty(contTotal) && contTotal > 0) {
                                profitRate = everMath.round_float(((itemTotal - contTotal) / itemTotal) * 100, 1);
                            }
                            EVF.C("PROFIT_RATE").setValue(profitRate + "%");
                            EVF.C("CONT_TOT_AMT").setValue(comma(String(contTotal)));
                        }
                    }
                });
            } else {
                store.setGrid([grid]);
                store.load(baseUrl + 'bod1042_doSearch', function () {
                    if (grid.getRowCount() == 0) {
                        EVF.V("ITEM_TOT_AMT", "0");
                        EVF.V("ITEM_TOT_CNT", "0");
                        if(userType == "C") {
                            EVF.C("CONT_TOT_AMT").setValue("0");
                            EVF.C("PROFIT_RATE").setValue("0");
                        }
                    } else {
                        var rowIds = grid.getAllRowId();
                        for (var i in rowIds) {
                            itemTotal += Number(grid.getCellValue(rowIds[i], 'ITEM_AMT'));
                            if(userType == "C") { contTotal += Number(grid.getCellValue(rowIds[i], 'CONT_UNIT_AMT')); }
                        }
                        EVF.C("ITEM_TOT_AMT").setValue(comma(String(itemTotal)));
                        EVF.C("ITEM_TOT_CNT").setValue(comma(String(grid.getRowCount())));
                        if(userType == "C") {
                            var profitRate = 0;
                            if(!EVF.isEmpty(itemTotal) && itemTotal > 0 && !EVF.isEmpty(contTotal) && contTotal > 0) {
                                profitRate = everMath.round_float(((itemTotal - contTotal) / itemTotal) * 100, 1);
                            }
                            EVF.C("PROFIT_RATE").setValue(profitRate + "%");
                            EVF.C("CONT_TOT_AMT").setValue(comma(String(contTotal)));

                            var footerRate = {
                                styles: {
                                    textAlignment: "far",
                                    suffix: " ",
                                    background:"#ffffff",
                                    foreground:"#FF0000",
                                    numberFormat: "###.#",
                                    fontBold: true
                                },
                                text: [profitRate + "%"]
                            };
                            grid.setRowFooter('PROFIT_RATE', footerRate);
                        }
                    }
                });
            }
        }

        function doCart(){

            var store = new EVF.Store();

            if(gridType == "I") {
                if(!gridImg.isExistsSelRow()) { return alert("${msg.M0004}"); }
                store.setGrid([gridImg]);
                store.getGridData(gridImg, "sel");
            }
            else {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                store.setGrid([grid]);
                store.getGridData(grid, "sel");
            }

            if(!confirm("${BOD1_042_013}")) { return; }

            store.setParameter("gridType", gridType);
            store.load(baseUrl + "bod1042_doCart", function () {
                alert(this.getResponseMessage());
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

        function doChangeGrid(){
return;
            // Img일경우 > List로 전환
            if(gridType == "I"){
                gridType = "L";
                EVF.C('ChangeGrid').setLabel('${BOD1_042_btn2}');
                $('#List_Div').css('display', 'block');
                $('#ImgArea_Div').css('display', 'none');
                grid.resize();
                gridImg.delAllRow();
            } else {
                gridType = "I";
                EVF.C('ChangeGrid').setLabel('${BOD1_042_btn1}');
                $('#List_Div').css('display', 'none');
                $('#ImgArea_Div').css('display', 'block');
                gridImg.resize();
                grid.delAllRow();
            }
            doSearch();
        }

    </script>

    <e:window id="BOD1_042" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false">
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${formData.CUST_CD }" />
            <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS }" />
            <e:row>
                <e:label for="CPO_NO" title="${form_CPO_NO_N}" />
                <e:field>
                    <e:inputText id="CPO_NO" name="CPO_NO" value="${formData.CPO_NO}" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
                </e:field>
                <e:label for="CPO_DATE" title="${form_CPO_DATE_N}" />
                <e:field>
                    <e:inputText id="CPO_DATE" name="CPO_DATE" value="${formData.CPO_DATE}" width="${form_CPO_DATE_W}" maxLength="${form_CPO_DATE_M}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" required="${form_CPO_DATE_R}" />
                </e:field>
            </e:row>
            <e:row>
				<e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}" />
				<e:field colSpan="3">
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="${formData.PR_SUBJECT}" width="${form_PR_SUBJECT_W}" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="${formData.CUST_NM }" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
				<e:label for="PLANT_NM" title="${form_PLANT_NM_N}" />
				<e:field>
				<e:inputText id="PLANT_NM" name="PLANT_NM" value="${formData.PLANT_NM }" width="${form_PLANT_NM_W}" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="CUST_DEPT_NM" title="${form_CUST_DEPT_NM_N}" />
				<e:field>
				<e:inputText id="CUST_DEPT_NM" name="CUST_DEPT_NM" value="${formData.CUST_DEPT_NM }" width="${form_CUST_DEPT_NM_W}" maxLength="${form_CUST_DEPT_NM_M}" disabled="${form_CUST_DEPT_NM_D}" readOnly="${form_CUST_DEPT_NM_RO}" required="${form_CUST_DEPT_NM_R}" />
				</e:field>

				<e:label for="CUST_USER_NM" title="${form_CUST_USER_NM_N}" />
				<e:field>
				<e:inputText id="CUST_USER_NM" name="CUST_USER_NM" value="${formData.CUST_USER_NM }" width="${form_CUST_USER_NM_W}" maxLength="${form_CUST_USER_NM_M}" disabled="${form_CUST_USER_NM_D}" readOnly="${form_CUST_USER_NM_RO}" required="${form_CUST_USER_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:panel id="Panel4" height="fit" width="10%">
            <e:title title="${BOD1_042_CAPTION3 }" depth="1"/>
        </e:panel>
        <e:panel id="Panel5" height="fit" width="70%">
            <e:text style="color:red;font-weight:bold;font-size:14px;">주문금액 합 계 : </e:text>
            <e:text id="ITEM_TOT_AMT" name="ITEM_TOT_AMT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:gray;">(부가세별도)</e:text>
        <c:if test="${ses.userType == 'C' }">
            <e:text style="color:red;font-weight:bold;font-size:14px;">, 매입금액 합 계 : </e:text>
            <e:text id="CONT_TOT_AMT" name="CONT_TOT_AMT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:gray;">(부가세별도)</e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;">, 이익율 : </e:text>
            <e:text id="PROFIT_RATE" name="PROFIT_RATE" style="color:red;font-weight:bold;font-size:14px;"></e:text>
        </c:if>
            <e:text style="color:red;font-weight:bold;font-size:14px;">, 상품건수 : </e:text>
            <e:text id="ITEM_TOT_CNT" name="ITEM_TOT_CNT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;"> 건</e:text>
        </e:panel>
        <e:panel id="Panel6" height="fit" width="20%">
            <e:buttonBar id="buttonBar2" align="right" width="100%">
                <!-- e:button id="ChangeGrid" name="ChangeGrid" label="${ChangeGrid_N}" disabled="${ChangeGrid_D}" visible="${ChangeGrid_V}" onClick="doChangeGrid" /-->
                <!-- e:button id="Cart" name="Cart" label="${Cart_N}" disabled="${formData.SIGN_STATUS == 'R' ? false : true}" visible="${formData.SIGN_STATUS == 'R' ? true : false}" onClick="doCart" /-->
            </e:buttonBar>
        </e:panel>

        <%--
        <e:buttonBar align="right" width="100%">
            <e:button id="Cart" name="Cart" label="${Cart_N}" disabled="${formData.SIGN_STATUS == 'R' ? false : true}" visible="${formData.SIGN_STATUS == 'R' ? true : false}" onClick="doCart" />
        </e:buttonBar>
        --%>
        <div id="List_Div" style="width: 100%;">
            <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        </div>
        <div id="ImgArea_Div" style="width: 100%;">
            <e:gridPanel id="gridImg" name="gridImg" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridImg.gridColData}" />
        </div>

        <jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true">
            <jsp:param value="${formData.APP_DOC_NO}" name="APP_DOC_NUM" />
            <jsp:param value="${formData.APP_DOC_CNT}" name="APP_DOC_CNT" />
        </jsp:include>

    </e:window>
</e:ui>