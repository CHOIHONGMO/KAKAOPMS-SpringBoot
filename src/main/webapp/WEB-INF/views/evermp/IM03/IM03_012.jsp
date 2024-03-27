<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/IM03/IM0304/";

        function init() {

        }

        function doSelect() {
            var store = new EVF.Store();
            if(!store.validate()) { return; }

            var param = {
                "REGION_CD": EVF.V("REGION_CD"),
                "REGION_NM": EVF.C("REGION_CD").getText(),
                "rowId": '${param.rowId}'
            };
            parent['${param.callBackFunction}'](param);

            new EVF.ModalWindow().close(null);
        }



    </script>

    <e:window id="IM03_012" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar align="right" width="100%">
            <e:button id="Select" name="Select" label="${Select_N}" onClick="doSelect" disabled="${Select_D}" visible="${Select_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="false">
            <e:row>
                <e:field colSpan="2" >
                    <e:checkGroup id="REGION_CD" name="REGION_CD" value="${param.REGION_CD}" width="100%" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" required="${form_REGION_CD_R}">
                        <c:forEach var="item" items="${regionCd}" varStatus="vs">
                            <e:check id="REGION_CD_${item.value}" name="REGION_CD_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" onClick="doClick" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
            </e:row>
        </e:searchPanel>

    </e:window>
</e:ui>