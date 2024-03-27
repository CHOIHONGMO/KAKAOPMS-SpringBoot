<!--
* IM04_006 : S/G 선택
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
    <link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
    <script type="text/javascript" src="/js/dtree/dtree.js"></script>
    <script>

    var baseUrl = "/evermp/IM04/IM0402/";
    var gridTree;

    function init() {

    	gridTree = EVF.C("gridTree");
        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.setHeader({visible: true});

        if(${param.multiYN}){
            treeViewObj.setTreeOptions({showCheckBox: true}); //체크박스
            EVF.C('doChoose').setVisible(true);
            /*EVF.C('doClean').setVisible(false);
            if(${param.searchYN}){
                EVF.C('doClean').setVisible(true);
            } else {
                EVF.C('doClean').setVisible(false);
            }*/
        }

        treeViewObj.setCheckBar({visible: false});
        treeViewObj.setIndicator({visible: false});

        if(${param.multiYN}){
            gridTree.cellClickEvent(function(rowId, colId, value) {
                //전체선택 또는 상위 카테고리 선택시 하위항목 체크활성/비활성

                if (gridTree.isChecked(rowId)) {
                    gridTree._gvo.checkChildren(gridTree.getIndex(rowId), true, true, true, true, false);
                }else{
                    gridTree._gvo.checkChildren(gridTree.getIndex(rowId), false, true, true, true, false)}

            });
        } else {

            gridTree.cellClickEvent(function(rowId, colId, value) {

                var data = gridTree.getRowValue(rowId);
                if(${param.searchYN}){

                }else{
                    if(data['ITEM_CLS3']=="*"){
                        return alert("${IM04_006_001 }");
                    }
                }
                data.rowId = '${param.rowId}';
                var selectedData = JSON.stringify(data);
                if(${param.ModalPopup == true}){
                    parent['${param.callBackFunction}'](selectedData);
                } else {
                    opener['${param.callBackFunction}'](selectedData);
                }
                doClose();
            });
        }
        gridTree.setProperty('shrinkToFit', true);
        gridTree.setColCursor('ITEM_CLS_NM', 'pointer');
        gridTree.getDataProvider().setRows(${treeData}, 'tree', false, '', 'icon');

        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.expandAll();
    }

    function doClean(){

    	var selectedData = {};
    	selectedData.rowId = '${param.rowId}';
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

    <e:window id="IM04_006" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <c:if test="${param.multiYN eq true}">
            <e:buttonBar id="buttonBar" align="right" width="100%">
                <e:button id="doChoose" name="doChoose" label="${doChoose_N }" disabled="${doChoose_D }" visible="${doChoose_V}" onClick="doChoose" />
                <%--<e:button id="doClean" name="doClean" label="${doClean_N}" onClick="doClean" disabled="${doClean_D}" visible="${doClean_V}"/>--%>
                <%-- <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/> --%>
            </e:buttonBar>
        </c:if>
        <e:gridPanel gridType="RGT" id="gridTree" name="gridTree" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}" />

	</e:window>
</e:ui>
