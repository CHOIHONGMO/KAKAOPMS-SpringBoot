<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">


        var gridTree;
        var baseUrl = "/evermp/SY01/SY0101/";

        function init() {

            gridTree = EVF.C("gridTree");

            var treeViewObj = gridTree.getGridViewObj();
            treeViewObj.setHeader({visible: true});

            // 멀티인경우에만
            if(${param.multiYN}){
                treeViewObj.setTreeOptions({showCheckBox: true}); //체크박스
            }
            treeViewObj.setCheckBar({visible: false});
            treeViewObj.setIndicator({visible: false});

            // 멀티인경우
            if(${param.multiYN}){
                gridTree.cellClickEvent(function(rowId, colId, value) {

                    //전체선택 또는 상위 카테고리 선택시 하위항목 체크활성/비활성
                    /* if(gridTree.getCellValue(rowId, 'COUNTS')>0){

                        if (gridTree.isChecked(rowId)) {
                            gridTree._gvo.checkChildren(gridTree.getIndex(rowId), true, true, true, true, false);
                        }else{
                            gridTree._gvo.checkChildren(gridTree.getIndex(rowId), false, true, true, true, false);
                        }
                    } */
                });
            	// 싱글일경우 : 바로 선택값 넘기기
            }
            else {
                gridTree.cellClickEvent(function(rowId, colId, value) {

                    var data = gridTree.getRowValue(rowId);
                    data.rowId = '${param.rowId}';

                    var selectedData = JSON.stringify(data);

                    if("${param.AllSelectYN}" != "true"){

/*                        if(data['PARENTS_YN']!=''){
                            //최하위 분류만 선택가능
                            return alert("${SY01_003_001 }");
                        }*/

                    }
                    if("${param.parentsSelectYN}" != "true"){
                        if(data['PARENTS_YN'] != ''){
                            //최하위 분류만 선택가능
                            return alert("${SY01_003_001 }");
                        }
                    }

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
            gridTree.getDataProvider().setRows(${treeData}, 'tree', '', '', 'icon');

            var treeViewObj = gridTree.getGridViewObj();
            treeViewObj.expandAll();

            doSearch();

        }

        function doSearch() {

            var store = new EVF.Store();
            store.load(baseUrl + 'SY01_003_doSearch', function() {

                var treeData = this.getParameter("treeData");
                var jsonTree = JSON.parse(treeData);

                gridTree.getDataProvider().setRows(jsonTree, 'tree', '', '', 'icon');
                var treeViewObj = gridTree.getGridViewObj();
                treeViewObj.expandAll();
            });
        }
        
        // 선택시 parents 에 넘기기.
        function doChoose() {

            if(!gridTree.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selectedData = gridTree.getSelRowValue();
            if( gridTree.isEmpty( selectedData) ) { return ; }


            if(${param.ModalPopup == true}){
                parent['${param.callBackFunction}'](selectedData);
            }else{
                opener['${param.callBackFunction}'](selectedData);
            }
        }

        function doClose() {
            if(${param.ModalPopup == true}){
                new EVF.ModalWindow().close(null);
            }else{
                window.close();
            }
        }

    </script>
    <e:window id="SY01_003" initData="${initData}" onReady="init" title="${param.tiTle != null ? param.tiTle : screenName  }" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="1" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="CUST_CD"  name="CUST_CD"  value="${param.custCd}"></e:inputHidden>
            <e:inputHidden id="PLANT_CD" name="PLANT_CD" value="${param.plantCd}"></e:inputHidden>
            <e:row>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}"/>
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="${param.custNm}" width="100%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
                <e:field>
                    <e:inputText id="DEPT_NM" style="${imeMode}" name="DEPT_NM" value="" width="100%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">

            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <c:if test="${param.multiYN == true}">
                <e:button id="Choose" name="Choose" label="${Choose_N }" disabled="${Choose_D }" visible="${Choose_V}" onClick="doChoose" />
            </c:if>
            <%--<e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" visible="${Close_V}" onClick="doClose" />--%>
        </e:buttonBar>

        <e:gridPanel gridType="RGT" id="gridTree" name="gridTree" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}" />

    </e:window>
</e:ui>