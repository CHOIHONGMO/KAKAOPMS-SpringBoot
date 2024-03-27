<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var gridAttr = {};
        var addParam = [];
        var baseUrl = "/eversrm/master/item/";

        function init() {
            gridAttr = EVF.C('gridAttr');
            gridAttr.setProperty('shrinkToFit', true);

            <%-- Addrow 필요없음.
            gridAttr.addRowEvent(function() {
                gridAttr.addRow();
            });
            --%>

            gridAttr.addRowEvent(function() {
               gridAttr.addRow();
            });

            gridAttr.delRowEvent(function() {
                if ((gridAttr.jsonToArray(gridAttr.getSelRowId()).value).length == 0) {
                    alert("${msg.M0004}");
                    return;
                }
                gridAttr.delRow();
            });

            gridAttr.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            	if (celname == "ATTR_NM") {
                	var param = {
                 		callBackFunction: "setAttrId"
                 	};
                 	currRow = rowid;
                 	everPopup.openCommonPopup(param, 'SP0017');
                }
            });

            gridAttr.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue){
                if (celname == "ATTR_VALUE") {
                    var attrvalue = gridAttr.getCellValue(rowid  , "ATTR_VALUE");
                    var rstcheck = isNaN(attrvalue);
                    var characterCode =  gridAttr.getCellValue(rowid, "CHARACTER_CD") ;

                    if (characterCode == "NUM" && rstcheck == true) {
                        alert("${BBM_010_0007}" + gridAttr.getCellValue(rowid, "CHARACTER_CD"));
                        gridAttr.setCellValue(rowid, "ATTR_VALUE", oldValue);
                    }
                }
            });

            gridAttr.excelExportEvent({
                allCol : "${excelExport.allCol}",
                selRow : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }",
                excelOptions : {
                    imgWidth     : 0.12      <%-- // 이미지의 너비. --%>
                    ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                    ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                    ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                    ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            if ('${form.ITEM_CD}' !='') {
                getAttr();
                if ('${form.ORDER_HALT_FLAG}' == '1') {
                    EVF.C("ORDER_HALT_FLAG").setChecked("true");
                }

                if ('${form.ECHO_GREEN_ITEM_FLAG}' == '1') {
                    EVF.C("ECHO_GREEN_ITEM_FLAG").setChecked("true");
                }

                if ('${form.PRICE_CHANGE_FLAG}' == '1') {
                    EVF.C("PRICE_CHANGE_FLAG").setChecked("true");
                }

                var store = new EVF.Store();
                store.setParameter("bizType",  "ITEM"  );
                store.setParameter("uuid",  EVF.C("UUID").getFileId()  );
                store.load(baseUrl + 'BBM_010/getFileInfo', function() {
                    var imgfileDatas = JSON.parse( this.getParameter("fileList")   );
                    for (k=0;k<imgfileDatas.length;k++ ) {
                        if (k<4) {
                            document.getElementById('IMAGE'+k).src= imgfileDatas[k].WWWIMGPATH;
                            EVF.C("C_UI_IMAGE"+k).setValue( imgfileDatas[k].UUID_SQ  );


                            if (EVF.C("UUID_SQ").getValue() == imgfileDatas[k].UUID_SQ) {
                                EVF.C("C_IMAGE"+k).setChecked("true");
                            }
                        }
                    }
                });
            }

            <%-- 품목현황에서 넘어 왔으면 --%>
            if('${param.changeFrom}' == 'itemList') {
                EVF.C('doDelete').setVisible(false);
                //EVF.C('doRequest').setVisible(false);
                //EVF.C('doReset').setVisible(false);
            }

            <%-- 연단가조회에서 넘어 왔으면 --%>
            if('${param.changeFrom}' == 'priceList') {
                //EVF.C('BBM_010').setTitle("품목이미지");

                EVF.C('doSearch').setVisible(false);
                EVF.C('doReset').setVisible(false);

                EVF.C('form').setVisible(false);
                EVF.C('form3').setVisible(false);
            }

            onChangeItemKindCd();
        }

        var currRow;
        function setAttrId(data) {
            var rowCount = gridAttr.getRowCount();
            var notchoose = true;
            for (var i = 0; i < rowCount; i++) {
                if (gridAttr.getCellValue(i,"ATTR_ID") == data.ATTR_ID) notchoose = false;
            }

            if (notchoose == true) {
                gridAttr.setCellValue(currRow, "ATTR_NM", data.ATTR_NM);
                gridAttr.setCellValue(currRow, "ATTR_DESC" , data.ATTR_DESC);
                gridAttr.setCellValue(currRow, "ATTR_ID"      , data.ATTR_ID);

                gridAttr.setCellValue(currRow, "CHARACTER_CD"      , data.CHARACTER_CD);
                //gridAttr.setComboSelectedHiddenValue("CHARACTER_CODE", gridAttr.getActiveRowIndex(), data.CHARACTER_CODE);
            } else {
                alert(data.ATTR_NM + "${BBM_010_0002 }");
            }
        }

        function doSearch() {
            if ( EVF.C('ITEM_CD').getValue() == '' ) {
                return;
            }

            location.href =baseUrl + 'BBM_010/view'
            + "?changeFrom=" + encodeURIComponent('${param.changeFrom}')
            + "&popupFlag=" + encodeURIComponent('${param.popupFlag}')
            + "&ITEM_CD=" + EVF.C('ITEM_CD').getValue();

        }

        function doSearchItemCode() {
            if (opener == null) {
                var param = {
                    callBackFunction: 'selectItemCode'
                };
                everPopup.openCommonPopup(param, 'SP0018');
            }
        }

        function selectItemCode(dataJsonArray) {
            EVF.C("ITEM_CD").setValue(dataJsonArray.ITEM_CD);
            doSearch();
        }

        function itemClassChange() {
            var popupUrl = baseUrl + "BBM_011/view";
            var param = {
                callBackFunction: 'selectClass'
            };
            everPopup.openModalPopup(popupUrl, 800, 600, param, "itemClassPopup");
        }

        function selectClass(dataJsonArray) {
            EVF.C("ITEM_CLS1").setValue(dataJsonArray.ITEM_CLS1);
            EVF.C("ITEM_CLS_NM1").setValue(dataJsonArray.ITEM_CLS_NM1);

            EVF.C("ITEM_CLS2").setValue(dataJsonArray.ITEM_CLS2);
            EVF.C("ITEM_CLS_NM2").setValue(dataJsonArray.ITEM_CLS_NM2);

            EVF.C("ITEM_CLS3").setValue(dataJsonArray.ITEM_CLS3);
            EVF.C("ITEM_CLS_NM3").setValue(dataJsonArray.ITEM_CLS_NM3);

            EVF.C("ITEM_CLS4").setValue(dataJsonArray.ITEM_CLS4);
            EVF.C("ITEM_CLS_NM4").setValue(dataJsonArray.ITEM_CLS_NM4);

            if (EVF.C('ITEM_CLS1').getValue() != "" && EVF.C('ITEM_CLS2').getValue() != "" && EVF.C('ITEM_CLS3').getValue() != "" && EVF.C('ITEM_CLS4').getValue() != "") {
                getAttrLink();
            }
        }
        function getAttrLink() {

            EVF.C('ITEM_ATTR_STATUS').setValue("U");
            if (gridAttr.getRowCount() != 0 && EVF.C('ITEM_CD').getValue() != "") {
                if (!confirm("${BBM_010_0001 }")) {
                    EVF.C('ITEM_ATTR_STATUS').setValue("D");
                }
            }

            var store = new EVF.Store();
            store.setGrid([gridAttr]);
            store.load(baseUrl + "BBM_010/getAttrLink",function() {
                gridAttr.checkAll(true);
                var rowCount = gridAttr.getRowCount();
                for (var i = 0; i < rowCount; i++) {
                    if (gridAttr.getCellValue(i,  "INSERT_FLAG") == "D") {
                        gridAttr.setCellValue(i,  "ATTR_DESC", "${BBM_010_0003}");
                    }

                    if (gridAttr.getCellValue(i,'REQUIRE_FLAG') == '1' &&   gridAttr.getCellValue(i,'ATTR_VALUE') == '') {
                        //gridAttr.setCellStyle(i, "ATTR_VALUE", 'background-color', '#fdd');
                        gridAttr.setCellBgColor(i, "ATTR_VALUE", '#fdd');
                    } else {
                        //gridAttr.setCellStyle(i, "ATTR_VALUE", 'background-color', '#fff');
                        gridAttr.setCellBgColor(i, "ATTR_VALUE", '#fff');
                    }
                }
            });
        }
        function getAttr() {
            EVF.C('ITEM_ATTR_STATUS').setValue("U");
            var store = new EVF.Store();
            store.setGrid([gridAttr]);
            store.load(baseUrl + "BBM_010/getAttr",function() {

                gridAttr.checkAll(true);

            });
        }

        // 품목 저장
        function doSave() {
            <%-- 품목현황에서 넘어온 것이 아니면 --%>
            if (!('${param.changeFrom}' == 'itemList' || '${param.changeFrom}' == 'priceList')) {
                if (everString.lrTrim(EVF.C('PROGRESS_CD').getValue()) == "E") {
                    alert("${BBM_010_1230 }");
                    return;
                }
            }

            var selRowId = gridAttr.jsonToArray(gridAttr.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if (gridAttr.getCellValue(selRowId[i],'REQUIRE_FLAG') == '1' &&   gridAttr.getCellValue(selRowId[i],'ATTR_VALUE') == ''     ) {
                    alert("${BBM_010_0008}");
                    return;
                }
            }

            var store = new EVF.Store();
            if(!store.validate()) return;

            if (!gridAttr.validate().flag) { return alert(gridAttr.validate().msg); }

            if (!confirm("${msg.M0021 }")) return;

            store.setGrid([gridAttr]);
            store.getGridData(gridAttr, 'sel');

            // 이미지 파일 업로드
            //ImagefileUp();

            store.doFileUpload(function() {
                store.load(baseUrl + 'BBM_010/doSave', function(){
                    alert(this.getResponseMessage());

                    if('${param.popupFlag}' == 'true') {
                        <c:if test="${param.callBackFunction != null && param.callBackFunction !=''}">
                        opener.${param.callBackFunction}();
                        </c:if>
                    }
                    //doSearch();

                    /*location.href = baseUrl + 'BBM_010/view.so?ITEM_CD='
                     + encodeURIComponent(this.getParameter('ITEM_CD'))
                     + "&changeFrom=" + encodeURIComponent('${param.changeFrom}')
                     + "&callBackFunction=" + '${param.callBackFunction}'
                     + "&popupFlag=" + encodeURIComponent('${param.popupFlag}');*/
                });
            });
        }

        // 요청자 승인요청
        function doRequest() {
            if (EVF.C('ITEM_CD').getValue() == "") {
                alert("${msg.M0007}");
                return
            }

            if (everString.lrTrim(EVF.C('PROGRESS_CD').getValue()) == "E") {
                alert("${BBM_010_1230 }");
                return;
            }

            if (!confirm("${msg.M0053}")) return;

            var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([ gridAttr ]);
            store.getGridData(gridAttr,"sel");

            // 이미지 파일 업로드
            //ImagefileUp();

            store.doFileUpload(function() {
                store.load(baseUrl + 'BBM_010/doRequest', function(){
                    alert(this.getResponseMessage());

                    if('${param.popupFlag}' == 'true') {
                        <c:if test="${param.callBackFunction != null && param.callBackFunction !=''}">
                        opener.${param.callBackFunction}();
                        </c:if>

                        window.close();
                    } else {
                        doReset();
                    }
                });
            });
        }
        // 품목관리자 등록완료
        function doApproval() {
            var store = new EVF.Store();
            if(!store.validate()) return;

            if(!confirm("${BBM_010_0011}")) return;

            store.setGrid([ gridAttr ]);
            store.getGridData(gridAttr,"sel");

            // 이미지 파일 업로드
            //ImagefileUp();

            store.doFileUpload(function() {
                store.load(baseUrl + 'BBM_010/doApproval', function() {
                    alert(this.getResponseMessage());

                    if('${param.popupFlag}' == 'true') {
                        <c:if test="${param.callBackFunction != null && param.callBackFunction !=''}">
                        opener.${param.callBackFunction}();
                        </c:if>

                        window.close();
                    } else {
                        doReset();
                    }
                    //doSearch();
                });
            });
        }

        // 품목 삭제
        function doDelete() {
            <%-- 품목현황에서 넘어온 것이 아니면 --%>
            if('${param.changeFrom}' != 'itemList') {
                if (everString.lrTrim(EVF.C('PROGRESS_CD').getValue()) == "E") {
                    alert("${BBM_010_1230 }");
                    return;
                }
            }
            if (EVF.C('ITEM_CD').getValue() == "") {
                alert("${msg.M0007}");
                return
            }
            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([gridAttr]);
            store.getGridData(gridAttr, 'sel');
            store.load(baseUrl + 'BBM_010/doDelete', function(){
                alert(this.getResponseMessage());

                if('${param.popupFlag}' === 'true') {
                    <c:if test="${param.callBackFunction != null && param.callBackFunction !=''}">
                    opener.${param.callBackFunction}();
                    </c:if>

                    window.close();
                } else {
                    doReset();
                }
            });
        }
        // 화면 초기화
        function doReset() {
            location.href =baseUrl + 'BBM_010/view';
        }

        function checkMainImage() {
            var name = "";

            for (var i = 0; i < 4; i++) {
                name = 'C_IMAGE' + i.toString();
                EVF.C(name).setChecked(false);
            }
            var picNo = this.getData();
            var name = 'C_IMAGE' + picNo.toString();
            EVF.C(name).setChecked(true);
            var ui_name = 'C_UI_IMAGE' + picNo.toString();
            EVF.C("UUID_SQ").setValue(    EVF.C(ui_name).getValue()             );
        }
        function ImagefileUp() {
            var store = new EVF.Store();
            store.doFileUpload(function() {
                store.setParameter("bizType",  "ITEM"  );
                store.setParameter("uuid",  EVF.C("UUID").getFileId()  );
                store.load(baseUrl + 'BBM_010/getFileInfo', function() {
                    var imgfileDatas = JSON.parse( this.getParameter("fileList")   );
                    for (k=0;k<imgfileDatas.length;k++ ) {
                        if (k < 4) {
                            document.getElementById('IMAGE'+k).src= imgfileDatas[k].WWWIMGPATH;
                            EVF.C("C_UI_IMAGE"+k).setValue( imgfileDatas[k].UUID_SQ  );
                            if (k==0) {
                                var temp_c = false;
                                for (var i = 0; i < 4; i++) {
                                    var kd = EVF.C("C_IMAGE"+i).isChecked();
                                    if (kd == true) {
                                        temp_c = true;
                                    }
                                }
                                if (temp_c == false)
                                    EVF.C("C_IMAGE"+k).setChecked("true");
                            }

                        }

                    }

                    if (imgfileDatas.length!=0) {

                        for (var i = 0; i < 4; i++) {
                            name = 'C_IMAGE' + i.toString();
                            EVF.C(name).setChecked(false);
                        }

                        var picNo =0;
                        var name = 'C_IMAGE' + picNo.toString();
                        EVF.C(name).setChecked(true);
                        var ui_name = 'C_UI_IMAGE' + picNo.toString();
                        EVF.C("UUID_SQ").setValue(    EVF.C(ui_name).getValue()             );
                    }
                });
            });
        }

        function fileimgref() {
            var store = new EVF.Store();
            store.setParameter("bizType",  "ITEM"  );
            store.setParameter("uuid",  EVF.C("UUID").getFileId()  );
            store.load(baseUrl + 'BBM_010/getFileInfo', function() {


                for (k=0;k<4;k++ ) {
                    document.getElementById('IMAGE'+k).src= null;
                }

                var imgfileDatas = JSON.parse( this.getParameter("fileList")   );
                for (k=0;k<imgfileDatas.length;k++ ) {
                    if (k < 4 ) {
                        document.getElementById('IMAGE'+k).src= imgfileDatas[k].WWWIMGPATH;
                        EVF.C("C_UI_IMAGE"+k).setValue( imgfileDatas[k].UUID_SQ  );
                        if (k==0) {
                            var temp_c = false;
                            for (var i = 0; i < 4; i++) {
                                var kd = EVF.C("C_IMAGE"+i).isChecked();
                                if (kd == true) {
                                    temp_c = true;
                                }
                            }
                            if (temp_c == false)
                                EVF.C("C_IMAGE"+k).setChecked("true");
                        }
                    }
                }
            });
        }

        function doClose() {
            window.close();
        }

        // 품목구분 CHANGE
        function onChangeItemKindCd() {
            var kind_cd = EVF.C("ITEM_KIND_CD").getValue();
            var flag;
            if(kind_cd != "") {
                // 팝업창으로 호출시 또는 진행상태가 "저장" 이후인 건은 품번 수정하지 못함
                if ("${param.popupFlag}" == "true" || EVF.C('PROGRESS_CD').getValue() != '') {
                    setItemDisable();
                } else {
                    // 설비(EPA0) : 품번 자동채번, 이외는 품번 수동입력
                    if (kind_cd == "EPA0") {
                        EVF.C("ITEM_CD").setDisabled(true);
                        EVF.C("ITEM_CD").setRequired(false);

                        EVF.C("HIDDEN_ITEM_CD").setValue(EVF.C("ITEM_CD").getValue());
                        EVF.C("ITEM_CD").setValue("");
                    } else {
                        EVF.C("ITEM_CD").setDisabled(false);
                        EVF.C("ITEM_CD").setRequired(true);

                        EVF.C("ITEM_CD").setValue(EVF.C("HIDDEN_ITEM_CD").getValue());
                    }
                }

                // 부품(ROH2) : 추가정보 활성화
                if (kind_cd == "ROH2") {
                    flag = "C"; // IN 절 안에 들어가는 쿼리문(CB0038)
                    $("#form4Div").css('display', 'block');
                    if(EVF.C("HIDDEN_ITEM_CD").getValue() != "") {
                        // 부품 : 자재그룹 => 차종 검색
                        getAttrLink();
                    }
                } else {
                    flag = "M','S"; // IN 절 안에 들어가는 쿼리문(CB0038)
                    // 추가정보 폼 값 초기화
                    if ($("#form4Div").css('display') == "block") {
                        if (!confirm("${BBM_010_0010}")) {
                            return;
                        }
                    }
                    $("#form4Div").css('display', 'none');

                    addInfoClear();
                    // 부품 이외 : 자재그룹 => 차종 이외 검색
                    onChangeItemCd();
                }

                // 부품일 때와 아닐 경우 코드 셋팅
                var store = new EVF.Store();
                store.setParameter("FLAG", flag);
                store.load(baseUrl + 'BBM_010/getMatGroup', function () {
                    EVF.C("MAT_GROUP").setOptions(this.getParameter("matGroupList"));
                    EVF.C("MAT_GROUP").setValue("${form.MAT_GROUP}");
                });
            } else {
                EVF.C("ITEM_CD").setValue("");
                setItemDisable();
            }

            // 품목구분이 부품(ROH2)인 경우 품번, 품명, 단위만 필수체크
            if (kind_cd == "ROH2") {
                EVF.C("ITEM_SPEC").setRequired(false);
                EVF.C("MAT_GROUP").setRequired(false);
                EVF.C("MAT_TYPE").setRequired(false);
                EVF.C("GOODS_GROUP").setRequired(false);
                EVF.C("GOODS_HIERARCHY").setRequired(false);
            // 품목구분이 부자재(ROM1), MRO(MRO)인 경우 자재그룹, 자재유형, 제품군, 제품계층구조 필수체크
            } else if (kind_cd != "EPA0") {
                EVF.C("MAT_GROUP").setRequired(true);
                EVF.C("MAT_TYPE").setRequired(true);
                EVF.C("GOODS_GROUP").setRequired(true);
                EVF.C("GOODS_HIERARCHY").setRequired(true);
            } else {
                EVF.C("MAT_GROUP").setRequired(false);
                EVF.C("MAT_TYPE").setRequired(false);
                EVF.C("GOODS_GROUP").setRequired(false);
                EVF.C("GOODS_HIERARCHY").setRequired(false);
            }
        }

        // 품번 CHANGE
        function onChangeItemCd() {
            var store = new EVF.Store();
            store.load(baseUrl + 'BBM_010/getItemCd', function() {
                if(this.getResponseCode() == "false") {
                    alert("${BBM_010_0009}"); // 동일한 품번이 존재합니다.
                    EVF.C("ITEM_CD").setValue('');

                }
            });
        }

        function addInfoClear() {
            EVF.C("form4").iterator(function() {
                EVF.C(this.getID()).setValue('');
            });
        }

        // 품번 Disabled Function
        function setItemDisable() {
            EVF.C("ITEM_CD").setDisabled(true);
            EVF.C("ITEM_CD").setRequired(false);
        }
    </script>

    <e:window id="BBM_010" onReady="init" initData="${initData}" title="${(param.changeFrom == 'priceList')? '품목이미지' : screenName }" breadCrumbs="${breadCrumb }">

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <%--<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />--%>

            <%--<c:if test="${ses.userType == 'B' && (ses.ctrlCd != null || form.REG_USER_ID == ses.userId || empty form.ITEM_CD) }"></c:if>--%>
            <c:if test="${ses.ctrlCd == null || ses.ctrlCd == ''}">
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
                <e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}" />
            </c:if>

            <c:if test="${ses.ctrlCd != null && ses.ctrlCd != ''}">
                <e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doApproval" disabled="${doApproval_D}" visible="${doApproval_V}"/>
            </c:if>

            <c:if test="${ses.userType == 'S' && param.changeFrom == 'priceList'}">
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
            </c:if>

            <c:if test="${param.popupFlag == 'true'}">
                <c:if test="${param.changeFrom != 'BBM_100_Approval'}">
                    <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
                </c:if>
            </c:if>

            <c:if test="${param.popupFlag != 'true'}">
                <e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />
            </c:if>

            <c:if test="${param.popupFlag == 'true'}">
                <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" />
            </c:if>
        </e:buttonBar>

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:inputHidden id="GATE_CD" name="GATE_CD" value="${form.GATE_CD}" />
            <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
            <e:inputHidden id="INSERT_FLAG" name="INSERT_FLAG" value="${form.INSERT_FLAG}" />
            <e:inputHidden id="ITEM_ATTR_STATUS" name="ITEM_ATTR_STATUS" value="${form.ITEM_ATTR_STATUS}" />
            <e:inputHidden id="DATA_CREATION_TYPE" name="DATA_CREATION_TYPE" value="${form.DATA_CREATION_TYPE}" />
            <e:inputHidden id="REQ_DATE" name="REQ_DATE" value="${form.REQ_DATE}" />
            <e:inputHidden id="UUID_SQ" name="UUID_SQ" value="${form.UUID_SQ}" />
            <div style="display: none;">
                    <%--화면 보였다 사라지는 부분 수정--%>
                <e:select id="ORDER_UNIT_CD" name="ORDER_UNIT_CD" value="${form.ORDER_UNIT_CD}" options="${refM037}" width="${inputTextWidth}" disabled="${form_ORDER_UNIT_CD_D}" readOnly="${form_ORDER_UNIT_CD_RO}" required="${form_ORDER_UNIT_CD_R}" placeHolder="" visible="${form_ORDER_UNIT_CD_V}" />
                <e:inputNumber id="CONV_QT" name="CONV_QT" value="${form.CONV_QT}" width="${inputNumberWidth}" maxValue="${form_CONV_QT_M}" decimalPlace="${form_CONV_QT_NF}" disabled="${form_CONV_QT_D}" readOnly="${form_CONV_QT_RO}" required="${form_CONV_QT_R}" visible="${form_CONV_QT_V}" />
                <e:inputNumber id="MIN_ORDER_QT" name="MIN_ORDER_QT" width="${inputNumberWidth}" value="${form.MIN_ORDER_QT}" maxValue="${form_MIN_ORDER_QT_M}" decimalPlace="${form_MIN_ORDER_QT_NF}" disabled="${form_MIN_ORDER_QT_D}" readOnly="${form_MIN_ORDER_QT_RO}" required="${form_MIN_ORDER_QT_R}" visible="${form_MIN_ORDER_QT_V}" />
                <e:inputNumber id="LEADTIME" name="LEADTIME" value="${form.LEADTIME}" width="${inputNumberWidth}" maxValue="${form_LEADTIME_M}" decimalPlace="${form_LEADTIME_NF}" disabled="${form_LEADTIME_D}" readOnly="${form_LEADTIME_RO}" required="${form_LEADTIME_R}" visible="${form_LEADTIME_V}" />
                <e:select id="VAT_CD" name="VAT_CD" value="${form.VAT_CD}" options="${refM036}" width="${inputTextWidth}" disabled="${form_VAT_CD_D}" readOnly="${form_VAT_CD_RO}" required="${form_VAT_CD_R}" placeHolder="" visible="${form_VAT_CD_V}" />
            </div>
            <e:row>
                <%--품번--%>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <%--<e:search id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'doSearchItemCode'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onChange="onChangeItemCd"/>--%>
                    <e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onChange="onChangeItemCd"/>
                    <e:inputHidden id="HIDDEN_ITEM_CD" name="HIDDEN_ITEM_CD" />
                </e:field>
                <%--품목구분--%>
                <e:label for="ITEM_KIND_CD" title="${form_ITEM_KIND_CD_N}"/>
                <e:field>
                    <e:select id="ITEM_KIND_CD" name="ITEM_KIND_CD" value="${form.ITEM_KIND_CD}" options="${refM035}" width="${inputTextWidth}" disabled="${form_ITEM_KIND_CD_D}" readOnly="${form_ITEM_KIND_CD_RO}" required="${form_ITEM_KIND_CD_R}" placeHolder="" onChange="onChangeItemKindCd"/>
                </e:field>
            </e:row>
            <e:row>
                <%--품명--%>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" style="${imeMode}"/>
                </e:field>
                <%--품명(영문)--%>
                <e:label for="ITEM_DESC_ENG" title="${form_ITEM_DESC_ENG_N}"/>
                <e:field>
                    <e:inputText id="ITEM_DESC_ENG" name="ITEM_DESC_ENG" value="${form.ITEM_DESC_ENG}" width="100%" maxLength="${form_ITEM_DESC_ENG_M}" disabled="${form_ITEM_DESC_ENG_D}" readOnly="${form_ITEM_DESC_ENG_RO}" required="${form_ITEM_DESC_ENG_R}" />
                </e:field>
            </e:row>
            <e:row>
                <%--규격--%>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field colSpan="3">
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="${form.ITEM_SPEC}" width="100%" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <%--품목분류--%>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}" />
                <e:field colSpan="3">
                    <e:inputText id="ITEM_CLS_NM1" name="ITEM_CLS_NM1" value="${form.ITEM_CLS_NM1}" width="18%" maxLength="${form_ITEM_CLS_NM_M}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="ITEM_CLS_NM2" name="ITEM_CLS_NM2" value="${form.ITEM_CLS_NM2}" width="18%" maxLength="${form_ITEM_CLS_NM_M}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="ITEM_CLS_NM3" name="ITEM_CLS_NM3" value="${form.ITEM_CLS_NM3}" width="18%" maxLength="${form_ITEM_CLS_NM_M}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:search id="ITEM_CLS_NM4" name="ITEM_CLS_NM4" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'itemClassChange'}" value="${form.ITEM_CLS_NM4}" width="18%" maxLength="${form_ITEM_CLS_NM_M}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${form.ITEM_CLS1}" />
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${form.ITEM_CLS2}" />
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${form.ITEM_CLS3}" />
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${form.ITEM_CLS4}" />
                </e:field>
            </e:row>
            <e:row>
                <%--단위--%>
                <e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
                <e:field>
                    <e:select id="UNIT_CD" name="UNIT_CD" value="${form.UNIT_CD}" options="${refM037}" width="${inputTextWidth}" disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}" required="${form_UNIT_CD_R}" placeHolder="" />
                </e:field>
                <%--제조사--%>
                <e:label for="MAKER" title="${form_MAKER_N}" />
                <e:field>
                    <e:inputText id="MAKER" name="MAKER" value="${form.MAKER}" width="100%" maxLength="${form_MAKER_M}" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <%--자재그룹--%>
                <e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
                <e:field>
                    <e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${refM179}" width="${inputTextWidth}" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder="" />
                </e:field>
                <%--자재유형--%>
                <e:label for="MAT_TYPE" title="${form_MAT_TYPE_N}"/>
                <e:field>
                    <e:select id="MAT_TYPE" name="MAT_TYPE" value="${form.MAT_TYPE}" options="${refM180}" width="${inputTextWidth}" disabled="${form_MAT_TYPE_D}" readOnly="${form_MAT_TYPE_RO}" required="${form_MAT_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <%--제품군(M217)--%>
                <e:label for="GOODS_GROUP" title="${form_GOODS_GROUP_N}"/>
                <e:field>
                    <e:select id="GOODS_GROUP" name="GOODS_GROUP" value="${form.GOODS_GROUP}" options="${goodsGroupOptions}" width="${inputTextWidth}" disabled="${form_GOODS_GROUP_D}" readOnly="${form_GOODS_GROUP_RO}" required="${form_GOODS_GROUP_R}" placeHolder="" />
                </e:field>
                <%--제품계층구조(M218)--%>
                <e:label for="GOODS_HIERARCHY" title="${form_GOODS_HIERARCHY_N}"/>
                <e:field>
                    <e:select id="GOODS_HIERARCHY" name="GOODS_HIERARCHY" value="${form.GOODS_HIERARCHY}" options="${goodsHierarchyOptions}" width="${inputTextWidth}" disabled="${form_GOODS_HIERARCHY_D}" readOnly="${form_GOODS_HIERARCHY_RO}" required="${form_GOODS_HIERARCHY_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <%--품목군--%>
                <e:label for="PROD_GROUP" title="${form_PROD_GROUP_N}"/>
                <e:field>
                    <e:select id="PROD_GROUP" name="PROD_GROUP" value="${form.PROD_GROUP}" options="${refM181}" width="${inputTextWidth}" disabled="${form_PROD_GROUP_D}" readOnly="${form_PROD_GROUP_RO}" required="${form_PROD_GROUP_R}" placeHolder="" />
                </e:field>
                <%--구매정지--%>
                <e:label for="CHECK_ORDER_HALT_FLAG" title="${form_CHECK_ORDER_HALT_FLAG_N}" />
                <e:field>
                    <e:text>&nbsp;</e:text><e:check id="ORDER_HALT_FLAG" name="ORDER_HALT_FLAG" value="1" disabled="${form_CHECK_ORDER_HALT_FLAG_D}" readOnly="${form_CHECK_ORDER_HALT_FLAG_RO}" required="${form_CHECK_ORDER_HALT_FLAG_R}" />
                </e:field>
            </e:row>
            <e:row>
                <%--품목상세정보--%>
                <e:label for="ITEM_RMK" title="${form_ITEM_RMK_N}" />
                <e:field>
                    <e:textArea id="ITEM_RMK" name="ITEM_RMK" height="100" value="${form.ITEM_RMK}" width="100%" maxLength="${form_ITEM_RMK_M}" disabled="${form_ITEM_RMK_D}" readOnly="${form_ITEM_RMK_RO}" required="${form_ITEM_RMK_R}" style="${imeMode}"/>
                </e:field>
                <%--첨부파일--%>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
                <e:field>
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="ITEM" height="100px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <div id="form4Div" style="display: none;">
            <e:searchPanel id="form4" useTitleBar="true" title="${form_ADD_INFO_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
                <e:row>
                    <%--재질코드--%>
                    <e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
                    <e:field>
                        <e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${refMatCd}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
                    </e:field>
                    <%--NET중량--%>
                    <e:label for="NET_WGT" title="${form_NET_WGT_N}"/>
                    <e:field>
                        <e:inputNumber id="NET_WGT" name="NET_WGT" value="${form.NET_WGT}" maxValue="${form_NET_WGT_M}" decimalPlace="${form_NET_WGT_NF}" disabled="${form_NET_WGT_D}" readOnly="${form_NET_WGT_RO}" required="${form_NET_WGT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--이전재질단가--%>
                    <e:label for="PREV_MAT_PRC" title="${form_PREV_MAT_PRC_N}"/>
                    <e:field>
                        <e:inputNumber id="PREV_MAT_PRC" name="PREV_MAT_PRC" value="${form.PREV_MAT_PRC}" maxValue="${form_PREV_MAT_PRC_M}" decimalPlace="${form_PREV_MAT_PRC_NF}" disabled="${form_PREV_MAT_PRC_D}" readOnly="${form_PREV_MAT_PRC_RO}" required="${form_PREV_MAT_PRC_R}" />
                    </e:field>
                    <%--이전SCRAP단가--%>
                    <e:label for="PREV_SCRAP_PRC" title="${form_PREV_SCRAP_PRC_N}"/>
                    <e:field>
                        <e:inputNumber id="PREV_SCRAP_PRC" name="PREV_SCRAP_PRC" value="${form.PREV_SCRAP_PRC}" maxValue="${form_PREV_SCRAP_PRC_M}" decimalPlace="${form_PREV_SCRAP_PRC_NF}" disabled="${form_PREV_SCRAP_PRC_D}" readOnly="${form_PREV_SCRAP_PRC_RO}" required="${form_PREV_SCRAP_PRC_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--규격--%>
                    <e:label for="SPEC" title="${form_SPEC_N}"/>
                    <e:field>
                        <e:inputText id="SPEC" style="ime-mode:auto" name="SPEC" value="${form.SPEC}" width="100%" maxLength="${form_SPEC_M}" disabled="${form_SPEC_D}" readOnly="${form_SPEC_RO}" required="${form_SPEC_R}"/>
                    </e:field>
                    <%--비중--%>
                    <e:label for="WEIGHT" title="${form_WEIGHT_N}"/>
                    <e:field>
                        <e:inputNumber id="WEIGHT" name="WEIGHT" value="${form.WEIGHT}" maxValue="${form_WEIGHT_M}" decimalPlace="${form_WEIGHT_NF}" disabled="${form_WEIGHT_D}" readOnly="${form_WEIGHT_RO}" required="${form_WEIGHT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--두께--%>
                    <e:label for="THICK" title="${form_THICK_N}"/>
                    <e:field>
                        <e:inputNumber id="THICK" name="THICK" value="${form.THICK}" maxValue="${form_THICK_M}" decimalPlace="${form_THICK_NF}" disabled="${form_THICK_D}" readOnly="${form_THICK_RO}" required="${form_THICK_R}" />
                    </e:field>
                    <%--COLL LOSS율--%>
                    <e:label for="COLL_LOSS_RTO" title="${form_COLL_LOSS_RTO_N}"/>
                    <e:field>
                        <e:inputNumber id="COLL_LOSS_RTO" name="COLL_LOSS_RTO" value="${form.COLL_LOSS_RTO}" maxValue="${form_COLL_LOSS_RTO_M}" decimalPlace="${form_COLL_LOSS_RTO_NF}" disabled="${form_COLL_LOSS_RTO_D}" readOnly="${form_COLL_LOSS_RTO_RO}" required="${form_COLL_LOSS_RTO_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--가로--%>
                    <e:label for="WIDTH" title="${form_WIDTH_N}"/>
                    <e:field>
                        <e:inputNumber id="WIDTH" name="WIDTH" value="${form.WIDTH}" maxValue="${form_WIDTH_M}" decimalPlace="${form_WIDTH_NF}" disabled="${form_WIDTH_D}" readOnly="${form_WIDTH_RO}" required="${form_WIDTH_R}" />
                    </e:field>
                    <%--세로--%>
                    <e:label for="HEIGHT" title="${form_HEIGHT_N}"/>
                    <e:field>
                        <e:inputNumber id="HEIGHT" name="HEIGHT" value="${form.HEIGHT}" maxValue="${form_HEIGHT_M}" decimalPlace="${form_HEIGHT_NF}" disabled="${form_HEIGHT_D}" readOnly="${form_HEIGHT_RO}" required="${form_HEIGHT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <%--BL SIZE(가로)--%>
                    <e:label for="BL_WIDTH" title="${form_BL_WIDTH_N}"/>
                    <e:field>
                        <e:inputNumber id="BL_WIDTH" name="BL_WIDTH" value="${form.BL_WIDTH}" maxValue="${form_BL_WIDTH_M}" decimalPlace="${form_BL_WIDTH_NF}" disabled="${form_BL_WIDTH_D}" readOnly="${form_BL_WIDTH_RO}" required="${form_BL_WIDTH_R}" />
                        <e:text>(mm)</e:text>
                    </e:field>
                    <%--BL SIZE(세로)--%>
                    <e:label for="BL_HEIGHT" title="${form_BL_HEIGHT_N}"/>
                    <e:field>
                        <e:inputNumber id="BL_HEIGHT" name="BL_HEIGHT" value="${form.BL_HEIGHT}" maxValue="${form_BL_HEIGHT_M}" decimalPlace="${form_BL_HEIGHT_NF}" disabled="${form_BL_HEIGHT_D}" readOnly="${form_BL_HEIGHT_RO}" required="${form_BL_HEIGHT_R}" />
                        <e:text>(mm)</e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <%--CVT--%>
                    <e:label for="CVT" title="${form_CVT_N}"/>
                    <e:field colSpan="3">
                        <e:inputNumber id="CVT" name="CVT" value="${form.CVT}" maxValue="${form_CVT_M}" decimalPlace="${form_CVT_NF}" disabled="${form_CVT_D}" readOnly="${form_CVT_RO}" required="${form_CVT_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>
        </div>
        <e:searchPanel id="form2" useTitleBar="true" title="${form_gridPict_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:row>
                <e:label for="CAPTION_ATTACH2" title="${form_gridPict_N}" />
                <e:field colSpan="3">
                    <e:fileManager id="UUID" name="UUID" onAfterRemove="fileimgref" readOnly="${param.detailView == 'true' ? true : false}" fileId="${form.UUID}" downloadable="true" width="100%" bizType="ITEM" height="100px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
                    <e:inputHidden id="C_UI_IMAGE0" name="C_UI_IMAGE0" />
                    <e:inputHidden id="C_UI_IMAGE1" name="C_UI_IMAGE1" />
                    <e:inputHidden id="C_UI_IMAGE2" name="C_UI_IMAGE2" />
                    <e:inputHidden id="C_UI_IMAGE3" name="C_UI_IMAGE3" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CAPTION_ATTACH2x" title="Main Image" />
                <e:field colSpan="3">
                    <e:panel id="x1" width="210">
                        <img src="" width="200" height="200" id="IMAGE0" style="float: left" />
                    </e:panel>
                    <e:panel id="x2" width="210">
                        <img src="" width="200" height="200" id="IMAGE1" style="float: left" />
                    </e:panel>
                    <e:panel id="x3" width="210">
                        <img src="" width="200" height="200" id="IMAGE2" style="float: left" />
                    </e:panel>
                    <e:panel id="x4" width="210">
                        <img src="" width="200" height="200" id="IMAGE3" style="float: left" />
                    </e:panel>
                    <e:br />
                    <e:panel id="x5" width="210">
                        <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                        <e:check id="C_IMAGE0" name="C_IMAGE0" value="0" onClick="checkMainImage" data="0" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}" />
                    </e:panel>
                    <e:panel id="x6" width="210">
                        <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                        <e:check id="C_IMAGE1" name="C_IMAGE1" value="1" onClick="checkMainImage" data="1" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}" />
                    </e:panel>
                    <e:panel id="x7" width="210">
                        <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                        <e:check id="C_IMAGE2" name="C_IMAGE2" value="2" onClick="checkMainImage" data="2" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}" />
                    </e:panel>
                    <e:panel id="x8" width="210">
                        <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                        <e:check id="C_IMAGE3" name="C_IMAGE3" value="3" onClick="checkMainImage" data="3" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}" />
                    </e:panel>
                    <e:br />

                    <e:button id="doImageFileUpload" name="doImageFileUpload" label="${doImageFileUpload_N}" onClick="ImagefileUp" disabled="${doImageFileUpload_D}" visible="${doImageFileUpload_V}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="form3" useTitleBar="true" title="${form_gridAttr_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:gridPanel gridType="${_gridType}" id="gridAttr" name="gridAttr" width="100%" height="200px" readOnly="${param.detailView}" columnDef="${gridInfos.gridAttr.gridColData}" />
        </e:searchPanel>

    </e:window>
</e:ui>