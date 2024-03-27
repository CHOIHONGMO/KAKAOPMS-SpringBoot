<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var gridAttr = {};
        var addParam = [];
        var baseUrl = "/eversrm/master/item/";

        function init() {
            gridAttr = EVF.C('gridAttr');
            gridAttr.setProperty('shrinkToFit', true);
            gridAttr.setProperty('panelVisible', ${panelVisible});


            gridAttr.setProperty('panelVisible', ${panelVisible});


            if ('${form.ITEM_CD}' != '') {
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
                store.setParameter("bizType", "ITEM");
                store.setParameter("uuid", EVF.C("UUID").getValue());
                store.load(baseUrl + 'BBM_010/getFileInfo', function () {

                    var imageDefault = '/images/noimage.jpg';
                    document.getElementById('MAIN_IMAGE').src = imageDefault;
                    for (k = 0; k < 4; k++) {
                        document.getElementById('IMAGE' + k).src = imageDefault;
                    }

                    var imgfileDatas = JSON.parse(this.getParameter("fileList"));
                    for (k = 0; k < imgfileDatas.length; k++) {
                        if (k < 4) {
                            document.getElementById('IMAGE' + k).src = imgfileDatas[k].WWWIMGPATH;
                            EVF.C("C_UI_IMAGE" + k).setValue(imgfileDatas[k].WWWIMGPATH);
                            if (EVF.C("UUID_SQ").getValue() == imgfileDatas[k].UUID_SQ) {
                                document.getElementById('MAIN_IMAGE').src = imgfileDatas[k].WWWIMGPATH;
                            }
                        }
                    }

                    // 품목구분이 부품일 경우만 추가정보 show
                    if (EVF.C("ITEM_KIND_CD").getValue() == "ROH2") {
                        $('#ui-tabs-1').show();
                        $('#title1').show();
                    } else {
                        $('#ui-tabs-1').hide();
                        $('#title1').hide();

                        $('#title2').focus();
                        // 이동된 위치에서 엔터
                        var e = jQuery.Event('keydown', {keyCode: 13});
                        $("#title2").trigger(e);
                    }
                });
                getAttr();
            }
        }

        function chgImg(imgcou) {
            var imageVal = EVF.C("C_UI_IMAGE" + imgcou).getValue();
            if (imageVal != "") {
                document.getElementById('MAIN_IMAGE').src = imageVal;
            }
        }

        function getAttr() {
            EVF.C('ITEM_ATTR_STATUS').setValue("U");
            var store = new EVF.Store();
            store.setGrid([gridAttr]);
            store.load(baseUrl + "BBM_010/getAttr", function () {
                gridAttr.checkAll(true);
            });
        }
        function checkMainImage() {
        }
        function doClose() {
            window.close();
        }

        $(document.body).ready(function () {
            $('#e-tabs').height(($('.ui-layout-center').height() - 30)).tabs(
                    {
                        activate: function (event, ui) {
                            <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                            $(window).trigger('resize');
                        }
                    }
            );
            $('#e-tabs').tabs('option', 'active', 0);
            //getContentTab('1');

            setTimeout(function () {
                <%-- 컨텐츠 영역 리사이즈 --%>
                $('#e-tabs > iframe').height($('.ui-layout-center').outerHeight() - 30);
                <%-- 왼쪽 메뉴 높이 리사이즈 (헬프데스크 때문에) --%>
                $('.menu-container').height($('.ui-layout-west').outerHeight(true) - 100);
            }, 500);
        });

        function getContentTab(uu) {
            onSelectNode();

            if (uu == '1') {
                window.scrollbars = true;
            }
            if (uu == '2') {
                window.scrollbars = true;
            }
        }

    </script>
    <e:window id="BBM_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}"
                      visible="${doClose_V}"/>
        </e:buttonBar>

        <e:panel id="M1" width="30%" height="250">
            <img src="" width="250" height="250" id="MAIN_IMAGE" style="float: left"/>
        </e:panel>

        <e:panel id="M1M" width="1%">
            <e:text>&nbsp;</e:text>
        </e:panel>

        <e:panel id="M2" width="69%">
            <e:searchPanel id="form" useTitleBar="true" title="${form_CAPTION_N }" labelWidth="${labelWidth}"
                           width="100%" columnCount="2">
                <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${form.ITEM_CLS1}"/>
                <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${form.ITEM_CLS2}"/>
                <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${form.ITEM_CLS3}"/>
                <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${form.ITEM_CLS4}"/>
                <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}"/>
                <e:inputHidden id="INSERT_FLAG" name="INSERT_FLAG" value="${form.INSERT_FLAG}"/>
                <e:inputHidden id="ITEM_ATTR_STATUS" name="ITEM_ATTR_STATUS" value="${form.ITEM_ATTR_STATUS}"/>
                <e:inputHidden id="GATE_CD" name="GATE_CD" value="${form.GATE_CD}"/>
                <e:inputHidden id="DATA_CREATION_TYPE" name="DATA_CREATION_TYPE" value="${form.DATA_CREATION_TYPE}"/>
                <e:inputHidden id="REQ_DATE" name="REQ_DATE" value="${form.REQ_DATE}"/>
                <e:inputHidden id="UUID_SQ" name="UUID_SQ" value="${form.UUID_SQ}"/>
                <e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}"/>
                <e:inputHidden id="C_UI_IMAGE0" name="C_UI_IMAGE0"/>
                <e:inputHidden id="C_UI_IMAGE1" name="C_UI_IMAGE1"/>
                <e:inputHidden id="C_UI_IMAGE2" name="C_UI_IMAGE2"/>
                <e:inputHidden id="C_UI_IMAGE3" name="C_UI_IMAGE3"/>
                <e:inputHidden id="UUID" name="UUID" value="${form.UUID}"/>

                <div style="display: none;">
                    <e:select id="ORDER_UNIT_CD" name="ORDER_UNIT_CD" value="${form.ORDER_UNIT_CD}" options="${refM037}"
                              width="${inputTextWidth}" disabled="${form_ORDER_UNIT_CD_D}"
                              readOnly="${form_ORDER_UNIT_CD_RO}" required="${form_ORDER_UNIT_CD_R}" placeHolder=""
                              visible="${form_ORDER_UNIT_CD_V}"/>
                    <e:inputNumber id="MIN_ORDER_QT" name="MIN_ORDER_QT" value="${form.MIN_ORDER_QT}"
                                   width="${inputNumberWidth }" maxValue="${form_MIN_ORDER_QT_M}"
                                   decimalPlace="${form_MIN_ORDER_QT_NF}" disabled="${form_MIN_ORDER_QT_D}"
                                   readOnly="${form_MIN_ORDER_QT_RO}" required="${form_MIN_ORDER_QT_R}"
                                   visible="${form_MIN_ORDER_QT_V}"/>
                    <e:inputNumber id="CONV_QT" name="CONV_QT" value="${form.CONV_QT}" width="${inputNumberWidth }"
                                   maxValue="${form_CONV_QT_M}" decimalPlace="${form_CONV_QT_NF}"
                                   disabled="${form_CONV_QT_D}" readOnly="${form_CONV_QT_RO}"
                                   required="${form_CONV_QT_R}" visible="${form_CONV_QT_V}"/>
                    <e:inputNumber id="LEADTIME" name="LEADTIME" value="${form.LEADTIME}" width="${inputNumberWidth }"
                                   maxValue="${form_LEADTIME_M}" decimalPlace="${form_LEADTIME_NF}"
                                   disabled="${form_LEADTIME_D}" readOnly="${form_LEADTIME_RO}"
                                   required="${form_LEADTIME_R}" visible="${form_LEADTIME_V}"/>
                    <e:select id="VAT_CD" name="VAT_CD" value="${form.VAT_CD}" options="${refM036}"
                              width="${inputTextWidth}" disabled="${form_VAT_CD_D}" readOnly="${form_VAT_CD_RO}"
                              required="${form_VAT_CD_R}" placeHolder="" visible="${form_VAT_CD_V}"/>
                </div>
                <e:row>
                    <%--품목분류--%>
                    <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                    <e:field colSpan="3">
                        <e:text>${form.ITEM_CLS_NM1} > ${form.ITEM_CLS_NM2} > ${form.ITEM_CLS_NM3} > ${form.ITEM_CLS_NM4}   </e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <%--품번--%>
                    <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                    <e:field>
                        <e:text>${form.ITEM_CD}</e:text>
                    </e:field>
                    <%--품목구분--%>
                    <e:label for="ITEM_KIND_CD" title="${form_ITEM_KIND_CD_N}"/>
                    <e:field>
                        <e:select id="ITEM_KIND_CD" name="ITEM_KIND_CD" value="${form.ITEM_KIND_CD}"
                                  options="${refM035}" width="${inputTextWidth}" disabled="${form_ITEM_KIND_CD_D}"
                                  readOnly="${form_ITEM_KIND_CD_RO}" required="${form_ITEM_KIND_CD_R}" placeHolder=""/>
                    </e:field>
                </e:row>
                <e:row>
                    <%--품명--%>
                    <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
                    <e:field colSpan="3">
                        <e:text>${form.ITEM_DESC}</e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <%--규격--%>
                    <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
                    <e:field colSpan="3">
                        <e:text>${form.ITEM_SPEC}</e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <%--단위--%>
                    <e:label for="UNIT_CD" title="${form_UNIT_CD_N}"/>
                    <e:field>
                        <e:select id="UNIT_CD" name="UNIT_CD" value="${form.UNIT_CD}" options="${refM037}" width="100%"
                                  disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}"
                                  required="${form_UNIT_CD_R}" placeHolder=""/>
                    </e:field>
                    <%--제조사--%>
                    <e:label for="MAKER" title="${form_MAKER_N}"/>
                    <e:field>
                        <e:text>${form.MAKER}</e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <%--자재그룹--%>
                    <e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
                    <e:field>
                        <e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${refM179}"
                                  width="${inputTextWidth}" disabled="${form_MAT_GROUP_D}"
                                  readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder=""/>
                    </e:field>
                    <%--자재유형--%>
                    <e:label for="MAT_TYPE" title="${form_MAT_TYPE_N}"/>
                    <e:field>
                        <e:select id="MAT_TYPE" name="MAT_TYPE" value="${form.MAT_TYPE}" options="${refM180}"
                                  width="${inputTextWidth}" disabled="${form_MAT_TYPE_D}" readOnly="${form_MAT_TYPE_RO}"
                                  required="${form_MAT_TYPE_R}" placeHolder=""/>
                    </e:field>
                </e:row>
                <e:row>
                    <%--제품군(M217)--%>
                    <e:label for="GOODS_GROUP" title="${form_GOODS_GROUP_N}"/>
                    <e:field>
                        <e:select id="GOODS_GROUP" name="GOODS_GROUP" value="${form.GOODS_GROUP}"
                                  options="${goodsGroupOptions}" width="${inputTextWidth}"
                                  disabled="${form_GOODS_GROUP_D}" readOnly="${form_GOODS_GROUP_RO}"
                                  required="${form_GOODS_GROUP_R}" placeHolder=""/>
                    </e:field>
                    <%--제품계층구조(M218)--%>
                    <e:label for="GOODS_HIERARCHY" title="${form_GOODS_HIERARCHY_N}"/>
                    <e:field>
                        <e:select id="GOODS_HIERARCHY" name="GOODS_HIERARCHY" value="${form.GOODS_HIERARCHY}"
                                  options="${goodsHierarchyOptions}" width="${inputTextWidth}"
                                  disabled="${form_GOODS_HIERARCHY_D}" readOnly="${form_GOODS_HIERARCHY_RO}"
                                  required="${form_GOODS_HIERARCHY_R}" placeHolder=""/>
                    </e:field>
                </e:row>
                <e:row>
                    <%--품목군--%>
                    <e:label for="PROD_GROUP" title="${form_PROD_GROUP_N}"/>
                    <e:field>
                        <e:select id="PROD_GROUP" name="PROD_GROUP" value="${form.PROD_GROUP}" options="${refM181}"
                                  width="${inputTextWidth}" disabled="${form_PROD_GROUP_D}"
                                  readOnly="${form_PROD_GROUP_RO}" required="${form_PROD_GROUP_R}" placeHolder=""/>
                    </e:field>
                    <%--구매정지--%>
                    <e:label for="CHECK_ORDER_HALT_FLAG" title="${form_CHECK_ORDER_HALT_FLAG_N}"/>
                    <e:field>
                        <e:text>&nbsp;</e:text>
                        <e:check id="ORDER_HALT_FLAG" name="ORDER_HALT_FLAG" value="1" disabled="${form_CHECK_ORDER_HALT_FLAG_D}" readOnly="${form_CHECK_ORDER_HALT_FLAG_RO}" required="${form_CHECK_ORDER_HALT_FLAG_R}"/>
                    </e:field>
                </e:row>
            </e:searchPanel>
        </e:panel>

        <e:panel id="xxx1" width="100%">
            <e:panel id="x1" width="120">
                <img src="" width="100" height="100" id="IMAGE0" style="float: left" onclick="chgImg('0')"/>
            </e:panel>
            <e:panel id="x2" width="120">
                <img src="" width="100" height="100" id="IMAGE1" style="float: left" onclick="chgImg('1')"/>
            </e:panel>
            <e:panel id="x3" width="120">
                <img src="" width="100" height="100" id="IMAGE2" style="float: left" onclick="chgImg('2')"/>
            </e:panel>
            <e:panel id="x4" width="120">
                <img src="" width="100" height="100" id="IMAGE3" style="float: left" onclick="chgImg('3')  "/>
            </e:panel>

            <e:panel id="x5" width="0">
                <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                <e:check id="C_IMAGE0" name="C_IMAGE0" value="0" onClick="checkMainImage" data="0" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}"/>
            </e:panel>
            <e:panel id="x6" width="0">
                <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                <e:check id="C_IMAGE1" name="C_IMAGE1" value="1" onClick="checkMainImage" data="1" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}"/>
            </e:panel>
            <e:panel id="x7" width="0">
                <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                <e:check id="C_IMAGE2" name="C_IMAGE2" value="2" onClick="checkMainImage" data="2" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}"/>
            </e:panel>
            <e:panel id="x8" width="0">
                <e:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</e:text>
                <e:check id="C_IMAGE3" name="C_IMAGE3" value="3" onClick="checkMainImage" data="3" disabled="${form_C_IMAGE0_D}" readOnly="${form_C_IMAGE0_RO}" required="${form_C_IMAGE0_R}"/>
            </e:panel>
        </e:panel>
        <e:br/>

        <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
            <e:panel id="panel" width="100%">
                <tr>
                    <td>
                        <div>
                            <ul>
                                <li id="title1"><a href="#ui-tabs-1" onclick="getContentTab('1');">추가정보</a></li>
                                <li id="title2"><a href="#ui-tabs-2" onclick="getContentTab('2');">속성정보</a></li>
                            </ul>
                            <div id="ui-tabs-1">
                                <e:searchPanel useTitleBar="false" id="form2" title="${form_CAPTION_N}"
                                               labelWidth="130px" labelAlign="${labelAlign}" columnCount="1">
                                    <e:row>
                                        <%--재질코드--%>
                                        <e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
                                        <e:field>
                                            <e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}"
                                                      options="${refMatCd}" width="${inputTextWidth}"
                                                      disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}"
                                                      required="${form_MAT_CD_R}" placeHolder=""/>
                                        </e:field>
                                        <%--NET중량--%>
                                        <e:label for="NET_WGT" title="${form_NET_WGT_N}"/>
                                        <e:field>
                                            <e:inputNumber id="NET_WGT" name="NET_WGT" value="${form.NET_WGT}"
                                                           maxValue="${form_NET_WGT_M}"
                                                           decimalPlace="${form_NET_WGT_NF}"
                                                           disabled="${form_NET_WGT_D}" readOnly="${form_NET_WGT_RO}"
                                                           required="${form_NET_WGT_R}"/>
                                        </e:field>
                                    </e:row>
                                    <e:row>
                                        <%--이전재질단가--%>
                                        <e:label for="PREV_MAT_PRC" title="${form_PREV_MAT_PRC_N}"/>
                                        <e:field>
                                            <e:inputNumber id="PREV_MAT_PRC" name="PREV_MAT_PRC"
                                                           value="${form.PREV_MAT_PRC}"
                                                           maxValue="${form_PREV_MAT_PRC_M}"
                                                           decimalPlace="${form_PREV_MAT_PRC_NF}"
                                                           disabled="${form_PREV_MAT_PRC_D}"
                                                           readOnly="${form_PREV_MAT_PRC_RO}"
                                                           required="${form_PREV_MAT_PRC_R}"/>
                                        </e:field>
                                        <%--이전SCRAP단가--%>
                                        <e:label for="PREV_SCRAP_PRC" title="${form_PREV_SCRAP_PRC_N}"/>
                                        <e:field>
                                            <e:inputNumber id="PREV_SCRAP_PRC" name="PREV_SCRAP_PRC"
                                                           value="${form.PREV_SCRAP_PRC}"
                                                           maxValue="${form_PREV_SCRAP_PRC_M}"
                                                           decimalPlace="${form_PREV_SCRAP_PRC_NF}"
                                                           disabled="${form_PREV_SCRAP_PRC_D}"
                                                           readOnly="${form_PREV_SCRAP_PRC_RO}"
                                                           required="${form_PREV_SCRAP_PRC_R}"/>
                                        </e:field>
                                    </e:row>
                                    <e:row>
                                        <%--규격--%>
                                        <e:label for="SPEC" title="${form_SPEC_N}"/>
                                        <e:field>
                                            <e:inputText id="SPEC" style="ime-mode:auto" name="SPEC"
                                                         value="${form.SPEC}" width="100%" maxLength="${form_SPEC_M}"
                                                         disabled="${form_SPEC_D}" readOnly="${form_SPEC_RO}"
                                                         required="${form_SPEC_R}"/>
                                        </e:field>
                                        <%--비중--%>
                                        <e:label for="WEIGHT" title="${form_WEIGHT_N}"/>
                                        <e:field>
                                            <e:inputNumber id="WEIGHT" name="WEIGHT" value="${form.WEIGHT}"
                                                           maxValue="${form_WEIGHT_M}" decimalPlace="${form_WEIGHT_NF}"
                                                           disabled="${form_WEIGHT_D}" readOnly="${form_WEIGHT_RO}"
                                                           required="${form_WEIGHT_R}"/>
                                        </e:field>
                                    </e:row>
                                    <e:row>
                                        <%--두께--%>
                                        <e:label for="THICK" title="${form_THICK_N}"/>
                                        <e:field>
                                            <e:inputNumber id="THICK" name="THICK" value="${form.THICK}"
                                                           maxValue="${form_THICK_M}" decimalPlace="${form_THICK_NF}"
                                                           disabled="${form_THICK_D}" readOnly="${form_THICK_RO}"
                                                           required="${form_THICK_R}"/>
                                        </e:field>
                                        <%--COLL LOSS율--%>
                                        <e:label for="COLL_LOSS_RTO" title="${form_COLL_LOSS_RTO_N}"/>
                                        <e:field>
                                            <e:inputNumber id="COLL_LOSS_RTO" name="COLL_LOSS_RTO"
                                                           value="${form.COLL_LOSS_RTO}"
                                                           maxValue="${form_COLL_LOSS_RTO_M}"
                                                           decimalPlace="${form_COLL_LOSS_RTO_NF}"
                                                           disabled="${form_COLL_LOSS_RTO_D}"
                                                           readOnly="${form_COLL_LOSS_RTO_RO}"
                                                           required="${form_COLL_LOSS_RTO_R}"/>
                                        </e:field>
                                    </e:row>
                                    <e:row>
                                        <%--가로--%>
                                        <e:label for="WIDTH" title="${form_WIDTH_N}"/>
                                        <e:field>
                                            <e:inputNumber id="WIDTH" name="WIDTH" value="${form.WIDTH}"
                                                           maxValue="${form_WIDTH_M}" decimalPlace="${form_WIDTH_NF}"
                                                           disabled="${form_WIDTH_D}" readOnly="${form_WIDTH_RO}"
                                                           required="${form_WIDTH_R}"/>
                                        </e:field>
                                        <%--세로--%>
                                        <e:label for="HEIGHT" title="${form_HEIGHT_N}"/>
                                        <e:field>
                                            <e:inputNumber id="HEIGHT" name="HEIGHT" value="${form.HEIGHT}"
                                                           maxValue="${form_HEIGHT_M}" decimalPlace="${form_HEIGHT_NF}"
                                                           disabled="${form_HEIGHT_D}" readOnly="${form_HEIGHT_RO}"
                                                           required="${form_HEIGHT_R}"/>
                                        </e:field>
                                    </e:row>
                                    <e:row>
                                        <%--BL SIZE(가로)--%>
                                        <e:label for="BL_WIDTH" title="${form_BL_WIDTH_N}"/>
                                        <e:field>
                                            <e:inputNumber id="BL_WIDTH" name="BL_WIDTH" value="${form.BL_WIDTH}"
                                                           maxValue="${form_BL_WIDTH_M}"
                                                           decimalPlace="${form_BL_WIDTH_NF}"
                                                           disabled="${form_BL_WIDTH_D}" readOnly="${form_BL_WIDTH_RO}"
                                                           required="${form_BL_WIDTH_R}"/>
                                            <e:text>(mm)</e:text>
                                        </e:field>
                                        <%--BL SIZE(세로)--%>
                                        <e:label for="BL_HEIGHT" title="${form_BL_HEIGHT_N}"/>
                                        <e:field>
                                            <e:inputNumber id="BL_HEIGHT" name="BL_HEIGHT" value="${form.BL_HEIGHT}"
                                                           maxValue="${form_BL_HEIGHT_M}"
                                                           decimalPlace="${form_BL_HEIGHT_NF}"
                                                           disabled="${form_BL_HEIGHT_D}"
                                                           readOnly="${form_BL_HEIGHT_RO}"
                                                           required="${form_BL_HEIGHT_R}"/>
                                            <e:text>(mm)</e:text>
                                        </e:field>
                                    </e:row>
                                </e:searchPanel>
                            </div>
                            <div id="ui-tabs-2">
                                <e:gridPanel gridType="${_gridType}" id="gridAttr" name="gridAttr" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridAttr.gridColData}"/>
                            </div>
                        </div>
                    </td>
                </tr>
            </e:panel>
        </div>
    </e:window>
</e:ui>