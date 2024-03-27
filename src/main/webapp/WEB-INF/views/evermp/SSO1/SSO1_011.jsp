<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/SSO1/";

        function init() {

            var list = [];
            <c:forEach var="region" items="${regionList}" varStatus="vs">
                list.push("${region.value}");
            </c:forEach>
            var vList = "${param.VENDOR_REGION_CD}".split(",");
            for(var idx = 0; idx < list.length; idx++) {
                for(var vIdx = 0; vIdx < vList.length; vIdx++) {
                    if(list[idx] == vList[vIdx].replace(" ", "")) {
                        EVF.C("VENDOR_REGION_CD_"+list[idx]).setChecked(true);
                    }
                }
            }
        }

        function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            var list = [];
            <c:forEach var="region" items="${regionList}" varStatus="vs">
                list.push("${region.value}");
            </c:forEach>
            var vListStr = "";
            for(var idx = 0; idx < list.length; idx++) {
                if (EVF.C("VENDOR_REGION_CD_"+list[idx]).isChecked()) {
                    vListStr = vListStr + list[idx] + ",";
                }
            }
            if(vListStr.length > 0) { vListStr = vListStr.substring(0, vListStr.length - 1); }

            if(Number(EVF.C("MOQ_QT").getValue()) < 0 || Number(EVF.C("MOQ_QT").getValue()) == 0) {
                return alert("${SSO1_011_006}");
            }
            if(Number(EVF.C("RV_QT").getValue()) < 0 || Number(EVF.C("RV_QT").getValue()) == 0) {
                return alert("${SSO1_011_007}");
            }

            var param = {
                "VENDOR_REGION_CD": vListStr,
                "QTA_UNIT_PRC": EVF.C("QTA_UNIT_PRC").getValue(),
                "LEADTIME": EVF.C("LEADTIME").getValue(),
                "LEADTIME_CD": EVF.C("LEADTIME_CD").getValue(),
                "MOQ_QT": EVF.C("MOQ_QT").getValue(),
                "RV_QT": EVF.C("RV_QT").getValue(),
                "TAX_CD": EVF.C("TAX_CD").getValue(),
                "QTA_REMARK": EVF.C("QTA_REMARK").getValue(),
                "LEADTIME_RMK": EVF.C("LEADTIME_RMK").getValue(),
                "rowId": "${param.rowId}"
            };
            opener['${param.callbackFunction}'](param);
            doClose();
        }

        function setRequestRmk() {
            if(EVF.C("LEADTIME_CD").getValue() == "50") {
                EVF.C('LEADTIME_RMK').setRequired(true);
            } else {
                EVF.C('LEADTIME_RMK').setRequired(false);
            }
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="SSO1_011" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false">
            <e:row>
                <e:label for="VENDOR_REGION_CD" title="${form_VENDOR_REGION_CD_N}"/>
                <e:field colSpan="5">
                    <e:checkGroup id="VENDOR_REGION_CD" name="VENDOR_REGION_CD" value="${formData.DELY_TYPE}" width="100%" disabled="${form_VENDOR_REGION_CD_D}" readOnly="${form_VENDOR_REGION_CD_RO}" required="${form_VENDOR_REGION_CD_R}">
                        <c:forEach var="region" items="${regionList}" varStatus="vs">
                            <e:check id="VENDOR_REGION_CD_${region.value}" name="VENDOR_REGION_CD_${region.value}" value="${region.value}" label="${region.text}" disabled="${form_VENDOR_REGION_CD_D}" readOnly="${form_VENDOR_REGION_CD_RO}" />
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="QTA_UNIT_PRC" title="${form_QTA_UNIT_PRC_N}"/>
                <e:field>
                    <e:inputNumber id="QTA_UNIT_PRC" name="QTA_UNIT_PRC" width="${form_QTA_UNIT_PRC_W}" required="${form_QTA_UNIT_PRC_R }" disabled="${form_QTA_UNIT_PRC_D }" value="${empty param.QTA_UNIT_PRC ? 0 : param.QTA_UNIT_PRC }" readOnly="${form_QTA_UNIT_PRC_RO }" />
                </e:field>
                <e:label for="LEADTIME" title="${form_LEADTIME_N}"/>
                <e:field>
                    <e:inputNumber id="LEADTIME" name="LEADTIME" width="${form_LEADTIME_W}" required="${form_LEADTIME_R }" disabled="${form_LEADTIME_D }" value="${empty param.LEADTIME ? 0 : param.LEADTIME }" readOnly="${form_LEADTIME_RO }" />
                </e:field>
                <e:label for="LEADTIME_CD" title="${form_LEADTIME_CD_N}"/>
                <e:field>
                    <e:select id="LEADTIME_CD" name="LEADTIME_CD" value="${param.LEADTIME_CD }" options="${leadtimeCdOptions}" width="${form_LEADTIME_CD_W}" disabled="${form_LEADTIME_CD_D}" readOnly="${form_LEADTIME_CD_RO}" required="${form_LEADTIME_CD_R}" placeHolder="" onChange="setRequestRmk" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MOQ_QT" title="${form_MOQ_QT_N}"/>
                <e:field>
                    <e:inputNumber id="MOQ_QT" name="MOQ_QT" width="${form_MOQ_QT_W}" required="${form_MOQ_QT_R }" disabled="${form_MOQ_QT_D }" value="${empty param.MOQ_QT ? 0 : param.MOQ_QT }" readOnly="${form_MOQ_QT_RO }" />
                </e:field>
                <e:label for="RV_QT" title="${form_RV_QT_N}"/>
                <e:field>
                    <e:inputNumber id="RV_QT" name="RV_QT" width="${form_RV_QT_W}" required="${form_RV_QT_R }" disabled="${form_RV_QT_D }" value="${empty param.RV_QT ? 0 : param.RV_QT }" readOnly="${form_RV_QT_RO }" />
                </e:field>
                <e:label for="TAX_CD" title="${form_TAX_CD_N}"/>
                <e:field>
                    <e:select id="TAX_CD" name="TAX_CD" value="${empty param.TAX_CD ? 'T1' : param.TAX_CD }" options="${taxCdOptions}" width="${form_TAX_CD_W}" disabled="${form_TAX_CD_D}" readOnly="${form_TAX_CD_RO}" required="${form_TAX_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="QTA_REMARK" title="${form_QTA_REMARK_N}"/>
                <e:field  colSpan="3">
                    <e:textArea id="QTA_REMARK" name="QTA_REMARK" value="${param.QTA_REMARK }" height="130px" width="100%" maxLength="${form_QTA_REMARK_M}" disabled="${form_QTA_REMARK_D}" readOnly="${form_QTA_REMARK_RO}" required="${form_QTA_REMARK_R}" />
                </e:field>
                <e:label for="LEADTIME_RMK" title="${form_LEADTIME_RMK_N}"/>
                <e:field>
                    <e:textArea id="LEADTIME_RMK" name="LEADTIME_RMK" value="${param.LEADTIME_RMK }" height="130px" width="100%" maxLength="${form_LEADTIME_RMK_M}" disabled="${form_LEADTIME_RMK_D}" readOnly="${form_LEADTIME_RMK_RO}" required="${form_LEADTIME_RMK_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
        </e:buttonBar>

    </e:window>
</e:ui>