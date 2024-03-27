<!--
* SRM_010_TREEP : S/G 선택
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
    <link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
    <script type="text/javascript" src="/js/dtree/dtree.js"></script>
    <script>

    var baseUrl = "/eversrm/srm/master/sourcing/";
    var gridTree;

    function init() {
        gridTree = EVF.C("gridTree");
        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.setHeader({visible: true});

        if(${param.multiYN}){
            treeViewObj.setTreeOptions({showCheckBox: true}); //체크박스
            EVF.C('doChoose').setVisible(true);
            EVF.C('doClean').setVisible(false);
            if(${param.searchYN}){
                EVF.C('doClean').setVisible(true);
            }else{
                EVF.C('doClean').setVisible(false);
            }
        }else{
//            EVF.C('doChoose').setVisible(false);
//            EVF.C('doClean').setVisible(true);
        }


        treeViewObj.setCheckBar({visible: false});
        treeViewObj.setIndicator({visible: false});


        if(${param.multiYN}){

        }else{
            gridTree.cellClickEvent(function(rowId, colId, value) {

                var data = gridTree.getRowValue(rowId);
                if(${param.searchYN}){

                }else{
                    if(data['ITEM_CLS3']=="*"){
                        return alert("${SRM_010_TREEP_001 }");
                    }
                }

                var selectedData = JSON.stringify(data);
                parent['${param.callBackFunction}'](selectedData);
                doClose();
            });
        }

        gridTree.setProperty('shrinkToFit', true);
        gridTree.setColCursor('ITEM_CLS_NM', 'pointer');
        gridTree.getDataProvider().setRows(${treeData}, 'tree', false, '', 'icon');

        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.expandAll();

    }
<%--
    function doSearchTree() {
        var store = new EVF.Store();
        store.load(baseUrl + 'SRM_010/doSearchDtree', function() {
            var treeData = this.getParameter("treeData");
            var jsontree = JSON.parse(treeData);
            d = new dTree('d');

            d.add(0, -1, '소싱그룹', '', '');

            for (var k = 0; k < jsontree.length; k++) {

                d.add(jsontree[k].SG_NUM,
                        jsontree[k].PARENT_SG_NUM || '',
                        jsontree[k].SG_NM,
                        jsontree[k].SG_NUM,
                        JSON.stringify(jsontree[k]));
            }

            document.getElementById("tree").innerHTML = d;
            d.openAll();
        });

    }--%>


    function doClean(){
        var selectedData = null;

        if(${param.ModalPopup == true}){
            parent['${param.callBackFunction}'](selectedData);
        }else{
            opener['${param.callBackFunction}'](selectedData);
        }

        doClose();
    }

    function doClose() {
        if(${param.ModalPopup == true}){
            new EVF.ModalWindow().close(null);
        }else{
            window.close();
        }
    }


    </script>

    <e:window id="SRM_010_TREEP" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <c:if test="${param.multiYN eq true}">
            <e:buttonBar id="buttonBar" align="right" width="100%">
                <e:button id="doChoose" name="doChoose" label="${doChoose_N }" disabled="${doChoose_D }" visible="${doChoose_V}" onClick="doChoose" />
                <e:button id="doClean" name="doClean" label="${doClean_N}" onClick="doClean" disabled="${doClean_D}" visible="${doClean_V}"/>
                <%-- <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/> --%>
            </e:buttonBar>
        </c:if>
        <e:gridPanel gridType="RGT" id="gridTree" name="gridTree" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}" />

	</e:window>
</e:ui>
