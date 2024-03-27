<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var deptGrid;
        var grid;
        //var gridDP;
        var baseUrl = "/evermp/SY01/SY0101/";

        function init() {

            deptGrid = EVF.C("deptGrid");
            grid = EVF.C("grid");

            //gridDP = EVF.C("gridDP");
            //gridDP.setProperty('shrinkToFit', true);

            var treeViewObj = deptGrid.getGridViewObj();
            treeViewObj.setHeader({visible: true});
            treeViewObj.setCheckBar({visible: false});
            treeViewObj.setIndicator({visible: false});
            treeViewObj.setTreeOptions({showCheckBox: false});
            deptGrid.setProperty('shrinkToFit', true);

            deptGrid.setColCursor('DEPT_NM', 'pointer');
            deptGrid.setColReadOnly('CTRL_MAPPING_YN', true);
            deptGrid.setColReadOnly('USER_MAPPING_YN', true);
            //deptGrid.setProperty('multiselect', false);

            deptGrid.cellClickEvent(function(rowId, colId, value) {
                if(colId=="DEPT_NM"){
                    EVF.V("DEPT_CD",deptGrid.getCellValue(rowId, 'DEPT_CD'));
                    doSearch_DP();
                }else if(colId=="TEAM_LEADER_USER_NM"){
                    var	param =	{
                        rowId: rowId,
                        custCd: EVF.V("CUST_CD"),
                        callBackFunction: "callBackCTRL_USER_ID"
                    };
                    everPopup.openCommonPopup(param, 'SP0083');
                }
            });

            deptGrid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
                if(colId=="INDEPT"||colId=="ACC_CODE"){
                    //deptGrid.setCellValue(rowId, 'checkYN', 'Y');

                    var addParam = [{
                        "DEPT_CD" : deptGrid.getCellValue(rowId, 'DEPT_CD')
                        ,"ACC_CODE" : deptGrid.getCellValue(rowId, 'ACC_CODE')
                        ,"INDEPT" : deptGrid.getCellValue(rowId, 'INDEPT')
                        ,"TEAM_LEADER_USER_ID" : deptGrid.getCellValue(rowId, 'TEAM_LEADER_USER_ID')
                    }];
                    grid.addRow(addParam);

                }
            });


            doSearch();
        }



        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.load(baseUrl + 'sy01001_doSelect_deptTree', function() {

                var treeData = this.getParameter("treeData");
                var jsonTree = JSON.parse(treeData);

                deptGrid.getDataProvider().setRows(jsonTree, 'tree', '', '', 'icon');
                treeViewObj = deptGrid.getGridViewObj();
                treeViewObj.expandAll();
            });
        }

//        function doSearch_DP() {
//
//            var store = new EVF.Store();
//            if(!store.validate()) { return;}
//            store.setGrid([gridDP]);
//            store.load(baseUrl + 'sy01001_doSelect_DP', function() {
//
//            });
//        }

        function doSave() {

            grid.checkAll(true);
            if(!grid.isExistsSelRow()) { return alert("${SY01_002_002}"); }
            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.load(baseUrl + 'sy01001_doSave_tree', function() {
                alert(this.getResponseMessage());
                doSearch();
                grid.delAllRow();
            });

        }


        <%--function doDPSave(){--%>
            <%--if(EVF.C("DEPT_CD").getValue()==""){--%>
                <%--return alert("${SY01_002_001}");--%>
            <%--}--%>

            <%--if(!gridDP.isExistsSelRow()) { return alert("${msg.M0004}"); }--%>
            <%--if(!gridDP.validate().flag) { return alert(gridDP.validate().msg); }--%>

            <%--if (!confirm("${msg.M0021}")) return;--%>
            <%--var store = new EVF.Store();--%>
            <%--store.setGrid([gridDP]);--%>
            <%--store.getGridData(gridDP, 'sel');--%>
            <%--store.load(baseUrl + 'sy01001_doSave_DP', function() {--%>
                <%--alert(this.getResponseMessage());--%>
                <%--doSearch_DP();--%>
            <%--});--%>

        <%--}--%>

        <%--function doDPDelete(){--%>

            <%--if(!gridDP.isExistsSelRow()) {  return alert("${msg.M0004}"); }--%>
            <%--if(!gridDP.validate().flag) { return alert(gridDP.validate().msg); }--%>
            <%--if (!confirm("${msg.M0013 }")) return;--%>

            <%--var store = new EVF.Store();--%>
            <%--store.setGrid([gridDP]);--%>
            <%--store.getGridData(gridDP, 'sel');--%>
            <%--store.load(baseUrl + 'sy01001_doDelete_DP', function() {--%>
                <%--alert(this.getResponseMessage());--%>
                <%--doSearch_DP();--%>
            <%--});--%>
        <%--}--%>

        function callBackCTRL_USER_ID(jsonData)	{
            deptGrid.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_NM', jsonData.USER_NM);
            deptGrid.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID', jsonData.USER_ID);
            deptGrid.setCellValue(jsonData.rowId, 'checkYN', 'Y');

            var addParam = [{
                "DEPT_CD" : deptGrid.getCellValue(jsonData.rowId, 'DEPT_CD')
                ,"ACC_CODE" : deptGrid.getCellValue(jsonData.rowId, 'ACC_CODE')
                ,"INDEPT" : deptGrid.getCellValue(jsonData.rowId, 'INDEPT')
                ,"TEAM_LEADER_USER_ID" : deptGrid.getCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID')
            }];
            grid.addRow(addParam);
        }

        function setBuyer(data) {
            EVF.V('CUST_CD', data.CUST_CD);
            EVF.V('CUST_NM', data.CUST_NM);
        }

    </script>
    <e:window id="SY01_002" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="DEPT_CD" name="DEPT_CD"/>

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="1" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
        <e:row>
            <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
            <e:field>
                <e:inputText id="CUST_CD" name="CUST_CD" value="${ses.companyCd}" width="0" maxLength="${form_CUST_CD_M}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                <e:search id="CUST_NM" name="CUST_NM" value="${ses.companyNm}" width="100%" maxLength="${form_CUST_NM_M}" onIconClick="${form_CUST_NM_RO ? 'everCommon.blank' : 'getBuyer'}" popupCode="SP0067.setBuyer" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
            </e:field>
        </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
        </e:buttonBar>


        <e:panel id="H1" width="100%"  height="fit">
            <e:gridPanel gridType="RGT" id="deptGrid" name="deptGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.deptGrid.gridColData}" />
        </e:panel>
        <%--<e:panel id="H2" width="1%"  height="fit" >&nbsp;</e:panel>--%>
        <%--<e:panel id="H3" width="45%"  height="fit">--%>
            <%--<e:buttonBar id="tab1_btn3" align="right" width="100%" title="${SY01_002_TITLE2 }">--%>
                <%--<e:button id="DPSave" name="DPSave" label="${DPSave_N }" disabled="${DPSave_D }" visible="${DPSave_V}" onClick="doDPSave" />--%>
                <%--<e:button id="DPDelete" name="DPDelete" label="${DPDelete_N }" disabled="${DPDelete_D }" visible="${DPDelete_V}" onClick="doDPDelete" />--%>
            <%--</e:buttonBar>--%>
            <%--<e:gridPanel gridType="${_gridType}" id="gridDP" name="gridDP" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridDP.gridColData}" />--%>
        <%--</e:panel>--%>
        <e:panel width="0px" height="0px">
            <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="0%" height="0px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>