<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
        var gridTree;
    	var addParam = [];
    	var baseUrl = "/evermp/IM04/IM0402/";

		function init() {

            gridTree = EVF.C("gridTree");

            var treeViewObj = gridTree.getGridViewObj();
            treeViewObj.setHeader({visible: true});

            // 멀티인경우에만
            if(${param.multiYN}){
                treeViewObj.setTreeOptions({showCheckBox: true}); //체크박스
                EVF.C('doChoose').setVisible(true);
                EVF.C('doClean').setVisible(false);

            }else{
                EVF.C('doChoose').setVisible(false);
                EVF.C('doClean').setVisible(true);
            }
            if(${param.searchYN}){
                EVF.C('doClean').setVisible(true);
            }else{
                EVF.C('doClean').setVisible(false);
            }

            treeViewObj.setCheckBar({visible: false});
            treeViewObj.setIndicator({visible: false});

            // 멀티인경우
            if(${param.multiYN}){
                gridTree.cellClickEvent(function(rowId, colId, value) {
                    //전체선택 또는 상위 카테고리 선택시 하위항목 체크활성/비활성

                    if (gridTree.isChecked(rowId)) {
                        gridTree._gvo.checkChildren(gridTree.getIndex(rowId), true, true, true, true, false);
                    }else{
                        gridTree._gvo.checkChildren(gridTree.getIndex(rowId), false, true, true, true, false)}
//
//                    var data = gridTree.getGridViewObj().getDescendants(gridTree.getIndex(rowId));
//                    var lastV;
//                    if (gridTree.isChecked(rowId)) {
//                        for (var i in data) {
//                            console.log(data[i]);
//                            gridTree.getGridViewObj().checkRow(data[i], true);
//                            lastV = data[i];
//                        }
//                        gridTree.getGridViewObj().checkRow(lastV + 1, true);
//                    } else {
//                        for (var i in data) {
//                            gridTree.getGridViewObj().checkRow(data[i], false);
//                            lastV = data[i];
//                        }
//                        gridTree.getGridViewObj().checkRow(lastV + 1, false);
//                    }
                });
            // 싱글일경우 : 바로 선택값 넘기기
            } else {
                gridTree.cellClickEvent(function(rowId, colId, value) {

                    var data = gridTree.getRowValue(rowId);
                        if(data['UPYN']!=""){
                            //최하위 분류만 선택가능
                            return alert("${IM04_005_001 }");
                        }


                    data.rowId = '${param.rowId}';
                    var selectedData = JSON.stringify(data);

                    if(${param.ModalPopup == true}){
                        parent['${param.callBackFunction}'](selectedData);
                    }else{
                        opener['${param.callBackFunction}'](selectedData);
                    }
                    doClose();
                });
            }

            gridTree.setProperty('shrinkToFit', true);
            gridTree.setColCursor('ITEM_CLS_NM', 'pointer');
            gridTree.getDataProvider().setRows(${treeData}, 'tree', true, '', 'icon');

            var treeViewObj = gridTree.getGridViewObj();
            // treeViewObj.expandAll();
            for(var i = 0; i < treeViewObj.getItemCount(); i++) {
                if(treeViewObj.getValue(i, "ITEM_CLS1") == "${param.ITEM_CLS1}") {
                    treeViewObj.expand(i, true, true);
                    return;
                }
            }
        }

        function doSearch() {

            var store = new EVF.Store();
            <%--store.setGrid([grid]);--%>
            store.setParameter('businessType', '${param.businessType}');
            store.setParameter('ptYn', '${param.ptYn}');  <%-- 사업구분값이 있을 경우 해당 값에 대한 조회만 수행한다. --%>

            store.load(baseUrl + 'IM04_005/doSearch', function() {

                var treeData = this.getParameter("treeData");
                var jsonTree = JSON.parse(treeData);

                gridTree.getDataProvider().setRows(jsonTree, 'tree', true, '', 'icon');
                var treeViewObj = gridTree.getGridViewObj();
                treeViewObj.expandAll();
            });
        }

        function doClean(){
            var selectedData = null;

            if(${param.ModalPopup == true}){
                parent['${param.callBackFunction}'](selectedData);
            } else {
                opener['${param.callBackFunction}'](selectedData);
            }
            doClose();
        }

        function doChoose() {

            if(!gridTree.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selectedData = gridTree.getSelRowValue();
            if( gridTree.isEmpty( selectedData) ) { return ; }

            if(${param.ModalPopup == true}){
                parent['${param.callBackFunction}'](selectedData);
            }else{
                opener['${param.callBackFunction}'](selectedData);
            }
            gridTree.checkAll(false);
        }

        function doClose() {
            if(${param.ModalPopup == true}){
                new EVF.ModalWindow().close(null);
            } else {
                window.close();
            }
        }

    </script>
    <e:window id="IM04_005" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="1" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}"/>
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="${param.custNm}" width="100%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                    <e:inputHidden id="CUST_CD" name="CUST_CD" value="${param.custCd}"></e:inputHidden>
                </e:field>
            </e:row>
            <e:row>
				<e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}"/>
				<e:field>
                    <!--
                    <e:select id="ITEM_CLS" name="ITEM_CLS" value="${form.ITEM_CLS}" options="${refItemType }" width="40%" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" usePlaceHolder="false" placeHolder="" />
                    -->
				<e:inputText id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="100%" maxLength="${form_ITEM_CLS_NM_M}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
				<%-- <e:inputText id="ITEM_CLS_RMK" name="ITEM_CLS_RMK" value="" width="100%" maxLength="${form_ITEM_CLS_RMK_M}" disabled="${form_ITEM_CLS_RMK_D}" readOnly="${form_ITEM_CLS_RMK_RO}" required="${form_ITEM_CLS_RMK_R}" /> --%>
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doChoose" name="doChoose" label="${doChoose_N }" disabled="${doChoose_D }" visible="${doChoose_V}" onClick="doChoose" />
            <e:button id="doClean" name="doClean" label="${doClean_N}" onClick="doClean" disabled="${doClean_D}" visible="${doClean_V}"/>
            <%-- <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/> --%>
        </e:buttonBar>

        <%--<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />--%>
        <e:gridPanel gridType="RGT" id="gridTree" name="gridTree" height="fit" />

    </e:window>
</e:ui>