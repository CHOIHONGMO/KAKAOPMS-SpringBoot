<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD01/OD0101/";
        function init() {
            grid = EVF.C("grid");
            grid.setProperty('multiSelect', false);
            grid.setProperty('sortable', false);




            grid.setColGroup([
               	{"groupName": '협력업체',"columns": [ "VENDOR_NM", "PREV_VENDOR_NM"]}
               	,{"groupName": '주문수량',"columns": [ "CPO_QTY", "PREV_CPO_QTY"]}
               	,{"groupName": '팬매가',"columns": [ "CPO_UNIT_PRICE", "PREV_CPO_UNIT_PRICE"]}
               	,{"groupName": '매입가',"columns": [ "PO_UNIT_PRICE", "PREV_PO_UNIT_PRICE"]}
               	,{"groupName": '거래유형',"columns": [ "DEAL_CD", "PREV_DEAL_CD"]}
               	,{"groupName": '배송지명',"columns": [ "DELY_NM", "PREV_DELY_NM"]}
               	,{"groupName": '우편번호',"columns": [ "DELY_ZIP_CD", "PREV_DELY_ZIP_CD"]}
               	,{"groupName": '기본주소',"columns": [ "DELY_ADDR_1", "PREV_DELY_ADDR_1"]}
               	,{"groupName": '상세주소',"columns": [ "DELY_ADDR_2", "PREV_DELY_ADDR_2"]}
               	],50);


            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "PO0211/doSearch", function () {
            });
        }

    </script>

    <e:window id="PO0211" onReady="init" initData="${initData}" title="${fullScreenName}">
    	<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.APP_DOC_NUM}"/>
    	<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${param.APP_DOC_CNT}"/>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>