<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
    <script>

    var supplierGrid, picGrid, itemClassGrid; //gridSIRA

    var baseUrl = "/eversrm/srm/master/sourcing/";
    var fileUrl = "/common/file/fileAttach/upload.so?";

    var isSave = true;
    var newNode = "";
    var currentNode = "";
    var currentDepth = 1;
    var currentLeaf = 0;
    var insertMode = false;
    var treeNode = null;

    var supplierSelRow, picSelRow, itemSelRow; //siraSelRow

    function init() {
        supplierGrid = EVF.getComponent('supplierGrid');
        supplierGrid.setProperty("shrinkToFit", true);
        supplierGrid.setProperty('multiselect', true);

        picGrid = EVF.getComponent('picGrid');
        picGrid.setProperty("shrinkToFit", true);
        picGrid.setProperty('multiselect', true);

        itemClassGrid = EVF.getComponent('itemClassGrid');
        itemClassGrid.setProperty("shrinkToFit", true);
        itemClassGrid.setProperty('multiselect', true);
        /*
        gridSIRA = EVF.getComponent('gridSIRA');
        gridSIRA.setProperty("shrinkToFit", false);
        gridSIRA.setProperty('multiselect', false);
        */

        EVF.getComponent('doSaveDefinition').setDisabled(false);
        EVF.getComponent('doDeleteDefinition').setDisabled(false);
        EVF.getComponent('addCurrentNode').setDisabled(false);
        EVF.getComponent('addChildNode').setDisabled(false);

        supplierGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            supplierSelRow = rowid;
        });

        picGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            picSelRow = rowid;
        });

        itemClassGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            itemSelRow = rowid;
        });
        /*
        gridSIRA.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            siraSelRow = rowid;
        });
        */
        supplierGrid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        picGrid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        itemClassGrid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });
        /*
        gridSIRA.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            excelOptions : {
                imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        gridSIRA.setGroupCol(
                [
                    {'colName' : 'SI_X_SCORE',  'colIndex': 3, 'titleText' : '전략중요도'},
                    {'colName' : 'RA_X_SCORE',  'colIndex': 3, 'titleText' : '관계매력도'},
                    {'colName' : 'SRS_X_SCORE', 'colIndex': 3, 'titleText' : 'SRS'}
                ]
        );
        */
        doSearchTree();
    }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                    activate: function(event, ui) {
                        <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                        $(window).trigger('resize');
                    }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        //getContentTab('1');

        setTimeout(function() {
            <%-- 컨텐츠 영역 리사이즈 --%>
            $('#e-tabs > iframe').height($('.ui-layout-center').outerHeight()-30);
            <%-- 왼쪽 메뉴 높이 리사이즈 (헬프데스크 때문에) --%>
            $('.menu-container').height($('.ui-layout-west').outerHeight(true)-100);
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
        if (uu == '3') {
            window.scrollbars = true;
        }
        if (uu == '4') {
            window.scrollbars = true;
        }
        if (uu == '5') {
            window.scrollbars = true;
        }
    }

    function onSelectNode() {

        if(EVF.getComponent("DEPTH").getValue() == "4") {
            var store = new EVF.Store();
            if (!store.validate()) return;
            isSave = true;

            store.setGrid([supplierGrid, picGrid, itemClassGrid]);
            //disableButtons(isSave);

            store.load(baseUrl + "SRM_010/doGetSgInfoById", function() {
                //itemClassGrid.setCellMerge.call(['ITEM_CLS_NM1','ITEM_CLS_NM2','ITEM_CLS_NM3'], true);
                itemClassGrid.setCellMerge(['ITEM_CLS_NM1','ITEM_CLS_NM2','ITEM_CLS_NM3']);
            });
        }
    }

    function doSearchTree() {
    	if(parseInt(currentDepth) === 4)
            EVF.getComponent('addChildNode').setDisabled(true);

        if(EVF.getComponent("DEPTH").getValue() == "4")
            EVF.getComponent("SG_NUM").setValue("");

        var store = new EVF.Store();
        store.load(baseUrl + "SRM_010/doSearchTree", function() {
            setTreeNode(JSON.parse(this.getParameter('treeData')));
        });

    }

    function setTreeNode(treeData) {

        for(var i= 0, dataOfL1 = treeData.length; i < dataOfL1; i++) {

            if(treeData[i].childs != undefined) {
                var childrenL1 = JSON.parse(treeData[i].childs);
                treeData[i].children = childrenL1;
                for(var j= 0, dataOfL2 = childrenL1.length; j < dataOfL2; j++) {

                    if(childrenL1[j].childs != undefined) {
                        var childrenL2 = JSON.parse(childrenL1[j].childs);
                        childrenL1[j].children = childrenL2;

                        for(var k= 0, dataOfL3 = childrenL2.length; k < dataOfL3; k++) {

                            if(childrenL2[k].childs != undefined) {
                                var childrenL3 = JSON.parse(childrenL2[k].childs);
                                childrenL2[k].children = childrenL3;

                                for(var l= 0, dataOfL4 = childrenL3.length; l < dataOfL4; l++) {

                                    if(childrenL3[l].childs != undefined) {
                                        var childrenL4 = JSON.parse(childrenL3[l].childs);
                                        childrenL3[l].children = childrenL4;
                                    }
                                    childrenL3[l].isFolder = (childrenL3[l].isFolder === 'false' ? false : true);
                                    //childrenL2[k].title = (childrenL2[k].useFlag === '1' ? childrenL2[k].title : "<strike><font color='#BDBDBD'>" + childrenL2[k].title + "</font></strike>");
                                }
                            }
                            childrenL2[k].isFolder = (childrenL2[k].isFolder === 'false' ? false : true);
                            //childrenL2[k].title = (childrenL2[k].useFlag === '1' ? childrenL2[k].title : "<strike><font color='#BDBDBD'>" + childrenL2[k].title + "</font></strike>");
                        }
                    }
                    childrenL1[j].isFolder = (childrenL1[j].isFolder === 'false' ? false : true);
                    //childrenL1[j].title = (childrenL1[j].useFlag === '1' ? childrenL1[j].title : "<strike><font color='#BDBDBD'>" + childrenL1[j].title + "</font></strike>");
                }
            }
            treeData[i].isFolder = (treeData[i].isFolder === 'false' ? false : true);
            //treeData[i].title = (treeData[i].useFlag === '1' ? treeData[i].title : "<strike><font color='#BDBDBD'>" + treeData[i].title + "</font></strike>");
        }
        $(function(){
            <%-- Attach the dynatree widget to an existing <div id="tree"> element --%>
            <%-- and pass the tree options as an argument to the dynatree() function: --%>
            $("#tree").dynatree({

                persist: false,
                keyboard: true,
                children: treeData,
                minExpandLevel: 4,

                onActivate: function(node) {

                    treeNode = node;
                    <%-- A DynaTreeNode object is passed to the activation handler --%>
                    <%-- Note: we also get this event, if persistence is on, and the page is reloaded. --%>
                    <%-- alert("You activated " + node.data.title + ", " + node.data.key + ", " + node.data.isLazy + ", " + node.data.isFolder); --%>
                    <%--  EVF.getComponent('MENU_NM').setValue((node.data.menuNm == null || node.data.menuNm == '') ? node.data.title : node.data.menuNm); --%>
                    EVF.getComponent('SG_NM').setValue(node.data.title);
                    EVF.getComponent('SG_NUM').setValue(node.data.key);
                    EVF.getComponent('CONTENT').setValue(node.data.content);
                    EVF.getComponent('SCRE_EV_TPL_SUBJECT').setValue(node.data.scre_ev_tpl_subject);
                    EVF.getComponent('SCRE_EV_TPL_NUM').setValue(node.data.scre_ev_tpl_num);
                    EVF.getComponent('SITE_EV_TPL_SUBJECT').setValue(node.data.site_ev_tpl_subject);
                    EVF.getComponent('SITE_EV_TPL_NUM').setValue(node.data.site_ev_tpl_num);
                    EVF.getComponent('CTRL_USER_ID').setValue(node.data.ctrl_user_id);
                    EVF.getComponent('CTRL_USER_NM').setValue(node.data.ctrl_user_nm);
                    EVF.getComponent('ATT_FILE_NUM').setValue(node.data.att_file_num);
                    EVF.getComponent('PARENT_SG_NUM').setValue(node.data.parent_sg_num);
                    EVF.getComponent('DEPTH').setValue(node.data.depth);

                    if(node.data.depth == 4) {
                        onSelectNode();
                    } else {
                        supplierGrid.delAllRow();
                        picGrid.delAllRow();
                        itemClassGrid.delAllRow();
                    }
                }
            });
            $("#tree").dynatree("getTree").reload();
        });
    }

    function doReset(){
    	EVF.getComponent('SG_NUM').reset();
    	EVF.getComponent('CONTENT').reset();
    }

    function addCurrentNode(){

        //EVF.getComponent('form').setDisabled(false);

        if(treeNode == null)
        {
         	EVF.getComponent('DEPTH').setValue('1');
            EVF.getComponent('LEAF').setValue('0');
            EVF.getComponent('PARENT_SG_NUM').setValue('');
            EVF.getComponent('SORT_SQ').setValue(treeNode.data.sort_sq_cnt);
        }
        else if(treeNode != null && treeNode.bExpanded == false){
        	EVF.getComponent('DEPTH').setValue('1');
            EVF.getComponent('LEAF').setValue('0');
            EVF.getComponent('PARENT_SG_NUM').setValue('');
            EVF.getComponent('SORT_SQ').setValue(treeNode.data.sort_sq_cnt);
        }
        else if(treeNode.bExpanded == true){
          	EVF.getComponent('DEPTH').setValue(treeNode.data.depth);
            EVF.getComponent('LEAF').setValue(treeNode.data.leaf_flag);
            EVF.getComponent('PARENT_SG_NUM').setValue(treeNode.data.parent_sg_num);
            EVF.getComponent('SORT_SQ').setValue(treeNode.data.sort_sq_cnt);
        }

        insertMode = true;
        doSaveDefinition();
    }

    function addChildNode(){
        if(treeNode != null){

            EVF.getComponent('DEPTH').setValue(treeNode.data.depth);
            EVF.getComponent('LEAF').setValue('1');
            EVF.getComponent('PARENT_SG_NUM').setValue(treeNode.data.key);
            EVF.getComponent('SORT_SQ').setValue(parseInt(treeNode.data.sortSq) + 1);

            if(treeNode.data.depth === 4)
                 EVF.getComponent('addChildNode').setDisabled(true);
          }
          else {
          	alert('${SRM_010_001}');
          	return;
          }

          insertMode = true;
          doSaveDefinition();
    }

    function resetAll(){

        var formValue = formUtil.getFormData();
        var formKey = Object.keys(formValue);

        for(var i = 0; i < formKey.length; i++) {
            if(formKey[i] != "ATT_FILE_NUM") {
                EVF.getComponent(formKey[i]).setValue("");
            } else {
                EVF.getComponent(formKey[i]).setFileId("");
            }
        }

        itemClassGrid.delAllRow();
        supplierGrid.delAllRow();
        picGrid.delAllRow();

        isSave = false;

        //disableButtons(isSave);
    }


    function disableButtons(flag){
        if(!flag){
            //eUX.getComponent('addCurrentNode').setDisabled(true);
            //eUX.getComponent('addChildNode').setDisabled(true);

            EVF.getComponent('doAppendSuplier').setDisabled(true);
            EVF.getComponent('doSaveSuplier').setDisabled(true);
            EVF.getComponent('doDeleteSuplier').setDisabled(true);

            EVF.getComponent('doAppendPic').setDisabled(true);
            EVF.getComponent('doSavePic').setDisabled(true);
            EVF.getComponent('doDeletePic').setDisabled(true);

            EVF.getComponent('doAppendItemClass').setDisabled(true);
            EVF.getComponent('doSaveItemClass').setDisabled(true);
            EVF.getComponent('doDeleteItemClass').setDisabled(true);

            EVF.getComponent('doSaveDefinition').setDisabled(true);
         	EVF.getComponent('doDeleteDefinition').setDisabled(true);
        }
        else{
        	EVF.getComponent('doSaveDefinition').setDisabled(false);
         	EVF.getComponent('doDeleteDefinition').setDisabled(false);

            EVF.getComponent('addCurrentNode').setDisabled(false);
            EVF.getComponent('addChildNode').setDisabled(false);

             EVF.getComponent('doAppendSuplier').setDisabled(false);
            EVF.getComponent('doSaveSuplier').setDisabled(false);
            EVF.getComponent('doDeleteSuplier').setDisabled(false);

            EVF.getComponent('doAppendPic').setDisabled(false);
            EVF.getComponent('doSavePic').setDisabled(false);
            EVF.getComponent('doDeletePic').setDisabled(false);

            EVF.getComponent('doAppendItemClass').setDisabled(false);
            EVF.getComponent('doSaveItemClass').setDisabled(false);
            EVF.getComponent('doDeleteItemClass').setDisabled(false);
        }
    }

    //Save button process
    function doSaveDefinition(){

        var store = new EVF.Store();

        if (!store.validate()) return;

        if (insertMode && EVF.getComponent('SG_NUM').getValue() != "") {
            if (!confirm("${SRM_010_CONFIRM_ATT_REMOVED }\n" + "${msg.M0021}")) {
                insertMode = false;
                return;
            }
            //EVF.getComponent('ATT_FILE_NUM').setFileId("");
        } else {
            if (!confirm("${msg.M0021}")) {
                insertMode = false;
                return;
            }
        }

<!--         var confirmMsg = (insertMode ? "${SRM_010_CONFIRM_ATT_REMOVED }\n" : "") + "${msg.M0021}"; -->

<!--         if (confirm(confirmMsg)) { -->
        if (insertMode) EVF.getComponent('SG_NUM').setValue("");
        store.doFileUpload(function() {
            store.load(baseUrl + "SRM_010/saveSGDefinition", function() {
                insertMode = false;
                currentNode = this.getParameter("SG_NUM");
                newNode = "";
                isSave = true;
                //disableButtons(isSave);
                if (parseInt(currentDepth) === 4)
                    EVF.getComponent('addChildNode').setDisabled(true);
                alert(this.getResponseMessage());
                resetAll();
                doSearchTree();
            });
        });
<!--         } else { -->
<!--             insertMode = false; -->
<!--         } -->
    }

    function doDeleteDefinition(){

        var store = new EVF.Store();
        if(!store.validate()) return;

        if (!confirm("${msg.M0013}")) return;

        if(treeNode != null){

            var store = new EVF.Store();
            store.load(baseUrl + "SRM_010/deleteSGDefinition", function() {

                if(this.getResponseMessage() == "fail"){
                    var nodeId =  EVF.getComponent('tree').getSelectedNode().getId();
                    EVF.getComponent('tree').remove(nodeId);
                }
                alert(this.getResponseMessage());
                newNode = currentNode = "";
                EVF.getComponent('SG_NUM').setValue('');
                currentDepth = 1;
                currentLeaf = 0;
                isSave = false;
                //disableButtons(isSave);
                resetAll();
                doSearchTree();
            });
        }
        else alert('${SRM_010_001}');

    }

    function getMultiSgName(){

    // if(EVF.getComponent('SG_NUM').getValue() == '') return;


     var params = {
                 multi_code: 'SG',
                 screen_id: '-',
                 other_code: EVF.getComponent('SG_NUM').getValue(),
                 nRow: 0,
                 callBackFunction:'reGetMultiEgName'
             };
             everPopup.openMultiLanguagePopup(params);
    }

    function reGetMultiEgName(redata){
         EVF.getComponent('SG_NUM').setValue(redata.multiNm);
    }

    function doAppendSuplier(){
        if(EVF.getComponent('DEPTH').getValue() != "4") {
            alert("${SRM_010_0001}"); // 세분류에서만 추가하실 수 있습니다.
            return;
        }

        var param =
            {
                callBackFunction: "selectVendor",
                clearButton : "OFF"
            };
        everPopup.openCommonPopup(param, 'SP0013');
    }

    function selectVendor(data) {
     	if(data.VENDOR_CD == '') return;

        var arrData = [];
        arrData.push({
            'VENDOR_CD': data.VENDOR_CD,
            'VENDOR_NM': data.VENDOR_NM
        });

        supplierGrid.addRow(arrData);
    }

    function doSaveSuplier(){

        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((supplierGrid.jsonToArray(supplierGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0021}")) return;

        store.setGrid([supplierGrid]);
        store.getGridData(supplierGrid, 'sel');
        store.load(baseUrl + "SRM_010/doSaveSupplierInfo", function() {
        	alert(this.getResponseMessage());
        	currentNode = EVF.getComponent('SG_NUM').getValue();

            onSelectNode();
            //doSearchTree();
        });

    }

    function doDeleteSuplier(){
        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((supplierGrid.jsonToArray(supplierGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0013}")) return;

        store.setGrid([supplierGrid]);
        store.getGridData(supplierGrid, 'sel');
        store.load(baseUrl + "SRM_010/doDeleteSuplier", function() {
            alert(this.getResponseMessage());

            onSelectNode();
        });

    }

    function doAppendPic() {
        if(EVF.getComponent('DEPTH').getValue() != "4") {
            alert("${SRM_010_0001}"); // 세분류에서만 추가하실 수 있습니다.
            return;
        }

        var param = {
            callBackFunction: "selectUser",
            clearButton: "OFF"
        };

        everPopup.openCommonPopup(param, 'SP0001');
    }
    function selectUser(data) {
    	if(data.USER_ID == '') return;

        var arrData = [];
        arrData.push({
            'USER_ID': data.USER_ID,
            'USER_NM': data.USER_NM,
            'DEPT_NM': data.DEPT_NM,
            'REP_FLAG': data.REP_FLAG,
            'EVAL_FLAG': data.EVAL_FLAG
        });

        picGrid.addRow(arrData);

    }
    function doSelectPic() {
        everPopup.openCommonPopup(
            {
                callBackFunction: "selectUser2"
            }
          , 'SP0001');
    }
    function selectUser2(data) {
    	if(data.USER_ID == '') return;
        EVF.getComponent("CTRL_USER_ID").setValue(data.USER_ID);
    	EVF.getComponent("CTRL_USER_NM").setValue(data.USER_NM);

    }
    function doSelectScreenTemplate(){
    	everPopup.openCommonPopup({
    		EV_TYPE : "SCRE",
            callBackFunction: "selectScreenTemplate"
        }, 'SP0034');
    }

    function selectScreenTemplate(data){
    	EVF.getComponent("SCRE_EV_TPL_NUM").setValue(data.EV_TPL_NUM);
    	EVF.getComponent("SCRE_EV_TPL_SUBJECT").setValue(data.EV_TPL_SUBJECT);
    }


    function doSelectSiteTemplate(){
    	everPopup.openCommonPopup({
    		EV_TYPE : "SITE",
            callBackFunction: "selectSiteTemplate"
        }, 'SP0034');
    }

    function selectSiteTemplate(data){
    	EVF.getComponent("SITE_EV_TPL_NUM").setValue(data.EV_TPL_NUM);
    	EVF.getComponent("SITE_EV_TPL_SUBJECT").setValue(data.EV_TPL_SUBJECT);
    }

    function doSavePic(){
        var store = new EVF.Store();

        if (!store.validate()) return;

        if ((picGrid.jsonToArray(picGrid.getSelRowId()).value).length == 0) {
         alert("${msg.M0004}");
         return;
        }

        if (!confirm("${msg.M0021}")) return;

        store.setGrid([picGrid]);
        store.getGridData(picGrid, 'sel');
        store.load(baseUrl + "SRM_010/doSavePic", function() {
            alert(this.getResponseMessage());
            currentNode = EVF.getComponent('SG_NUM').getValue();
            onSelectNode();
        });
    }

    function doDeletePic(){
        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((picGrid.jsonToArray(picGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0013}")) return;

        store.setGrid([picGrid]);
        store.getGridData(picGrid, 'sel');
        store.load(baseUrl + "SRM_010/doDeletePic", function() {
        	alert(this.getResponseMessage());
            onSelectNode();
        });

    }

    function doAppendItemClass(){
        if(EVF.getComponent('DEPTH').getValue() != "4") {
            alert("${SRM_010_0001}"); // 세분류에서만 추가하실 수 있습니다.
            return;
        }

        var param = {
            'detailView' : false,
            'popupFlag'  : true,
            'from'		 : 'SRM_010',
            callBackFunction: "selectItemClass"
        };

        everPopup.openCommonPopup(param, 'SP0015');
    }

    function selectItemClass(data){

        var arrData = [];
            arrData.push({
                'ITEM_CLS_NM1': data.ITEM_CLS_NM1,
                'ITEM_CLS_NM2': data.ITEM_CLS_NM2,
                'ITEM_CLS_NM3': data.ITEM_CLS_NM3,
                'ITEM_CLS_NM4': data.ITEM_CLS_NM4,
                'ITEM_CLS1': data.ITEM_CLS1,
                'ITEM_CLS2': data.ITEM_CLS2,
                'ITEM_CLS3': data.ITEM_CLS3,
                'ITEM_CLS4': data.ITEM_CLS4
            });
        itemClassGrid.addRow(arrData);

    }

    function doSaveItemClass(){
        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((itemClassGrid.jsonToArray(itemClassGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0021}")) return;

        store.setGrid([itemClassGrid]);
        store.getGridData(itemClassGrid, 'sel');
        store.load(baseUrl + "SRM_010/doSaveItemClass", function() {
        	alert(this.getResponseMessage());
            currentNode = EVF.getComponent('SG_NUM').getValue();
            onSelectNode();
        });

    }

    function doDeleteItemClass(){
        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((itemClassGrid.jsonToArray(itemClassGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0013}")) return;

        store.setGrid([itemClassGrid]);
        store.getGridData(itemClassGrid, 'sel');
        store.load(baseUrl + "SRM_010/doDeleteItemClass", function() {
        	alert(this.getResponseMessage());
            onSelectNode();
        });

    }

    </script>

    <e:window id="SRM_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="leftPanel" width="40%">
            <e:buttonBar align="right">
                <e:button id="addCurrentNode" name="addCurrentNode" label="${addCurrentNode_N}" onClick="addCurrentNode" disabled="${addCurrentNode_D}" visible="${addCurrentNode_V}"/>
                <e:button id="addChildNode" name="addChildNode" label="${addChildNode_N}" onClick="addChildNode" disabled="${addChildNode_D}" visible="${addChildNode_V}"/>
            </e:buttonBar>
            <div id="tree" style="height:600px;"> </div>

        </e:panel>

        <e:panel width="1%">&nbsp;</e:panel>

        <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
            <e:panel id="rightPanel" width="58%">
                <tr><td><div>
                    <ul>
                        <li><a href="#ui-tabs-1" onclick="getContentTab('1');">정의서</a></li>
                        <%--<li><a href="#ui-tabs-2" onclick="getContentTab('2');">SI/RA/SRS</a></li>--%>
                        <li><a href="#ui-tabs-3" onclick="getContentTab('3');">협력회사</a></li>
                        <li><a href="#ui-tabs-4" onclick="getContentTab('4');">담당자</a></li>
                        <li><a href="#ui-tabs-5" onclick="getContentTab('5');">품목분류</a></li>
                    </ul>
                    <div id="ui-tabs-1">
                        <%--Definition--%>
                        <e:buttonBar width="100%" align="right">
                            <e:button id="doSaveDefinition" name="doSaveDefinition" label="${doSaveDefinition_N}" onClick="doSaveDefinition" disabled="${doSaveDefinition_D}" visible="${doSaveDefinition_V}"/>
                            <e:button id="doDeleteDefinition" name="doDeleteDefinition" label="${doDeleteDefinition_N}" onClick="doDeleteDefinition" disabled="${doDeleteDefinition_D}" visible="${doDeleteDefinition_V}"/>
                        </e:buttonBar>
                        <e:searchPanel useTitleBar="false" id="form" title="${form_CAPTION_N}" labelWidth="130px" labelAlign="${labelAlign}" columnCount="1">
                            <%--소싱그룹명--%>
                            <e:row>
                                <e:label for="SG_NM" title="${form_SG_NM_N}"/>
                                <e:field>
                                    <e:search id="SG_NM" style="ime-mode:inactive" name="SG_NM" value="${form.SG_NM}" width="100%" maxLength="${form_SG_NM_M}" onIconClick="getMultiSgName" disabled="${form_SG_NM_D}" readOnly="${form_SG_NM_RO}" required="${form_SG_NM_R}" />
                                    <e:inputHidden id="SG_NUM" name="SG_NUM" />
                                </e:field>
                            </e:row>
                            <%--정의서--%>
                            <e:row>
                                <e:label for="CONTENT" title="${form_CONTENT_N}"/>
                                <e:field>
                                    <e:richTextEditor height="100%" id="CONTENT" name="CONTENT" width="100%" required="${form_CONTENT_R }" readOnly="${form_CONTENT_RO }" disabled="${form_CONTENT_D }" value="${form.CONTENT }" useToolbar="${!param.detailView}" />
                                </e:field>
                            </e:row>
                            <%--스크리닝 템플릿--%>
                            <e:row>
                                <e:label for="SCRE_EV_TPL_SUBJECT" title="${form_SCRE_EV_TPL_SUBJECT_N}"/>
                                <e:field>
                                    <e:search id="SCRE_EV_TPL_SUBJECT" style="ime-mode:auto" name="SCRE_EV_TPL_SUBJECT" value="${form.SCRE_EV_TPL_SUBJECT}" width="${inputTextWidth}" maxLength="${form_SCRE_EV_TPL_SUBJECT_M}" onIconClick="doSelectScreenTemplate" disabled="${form_SCRE_EV_TPL_SUBJECT_D}" readOnly="${form_SCRE_EV_TPL_SUBJECT_RO}" required="${form_SCRE_EV_TPL_SUBJECT_R}" />
                                    <e:inputHidden id="SCRE_EV_TPL_NUM" name="SCRE_EV_TPL_NUM" value="${form.SCRE_EV_TPL_NUM}"/>
                                </e:field>
                            </e:row>
                            <%--현장실사 템플릿--%>
                            <e:row>
                                <e:label for="SITE_EV_TPL_SUBJECT" title="${form_SITE_EV_TPL_SUBJECT_N}"/>
                                <e:field>
                                    <e:search id="SITE_EV_TPL_SUBJECT" style="ime-mode:auto" name="SITE_EV_TPL_SUBJECT" value="${form.SITE_EV_TPL_SUBJECT}" width="${inputTextWidth}" maxLength="${form_SITE_EV_TPL_SUBJECT_M}" onIconClick="doSelectSiteTemplate" disabled="${form_SITE_EV_TPL_SUBJECT_D}" readOnly="${form_SITE_EV_TPL_SUBJECT_RO}" required="${form_SITE_EV_TPL_SUBJECT_R}" />
                                    <e:inputHidden id="SITE_EV_TPL_NUM" name="SITE_EV_TPL_NUM" value="${form.SITE_EV_TPL_NUM}"/>
                                </e:field>
                            </e:row>
                            <%--담당자--%>
                            <e:row>
                                <e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}"/>
                                <e:field>
                                    <e:search id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${form.CTRL_USER_NM}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="doSelectPic" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
                                    <e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.CTRL_USER_ID}"/>
                                </e:field>
                            </e:row>
                            <%--첨부파일--%>
                            <e:row>
                                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                                <e:field>
                                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="SRM" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
                                </e:field>
                            </e:row>

                            <%--HIDDEN FIELD--%>
                            <e:inputHidden id="PARENT_SG_NUM" name="PARENT_SG_NUM" />
                            <e:inputHidden id="SORT_SQ" name="SORT_SQ" />
                            <e:inputHidden id="LEAF" name="LEAF" />
                            <e:inputHidden id="DEPTH" name="DEPTH" />
                        </e:searchPanel>
                    </div>
                    <%--
                    <div id="ui-tabs-2">
                        &lt;%&ndash;SIRA&ndash;%&gt;
                        <e:gridPanel gridType="${_gridType}" id="gridSIRA" name="gridSIRA" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridSIRA.gridColData}"/>
                    </div>
                    --%>
                    <div id="ui-tabs-3">
                        <%--협력회사--%>
                        <e:buttonBar width="100%" align="right">
                            <e:button id="doAppendSuplier" name="doAppendSuplier" label="${doAppendSuplier_N}" onClick="doAppendSuplier" disabled="${doAppendSuplier_D}" visible="${doAppendSuplier_V}"/>
                            <e:button id="doSaveSuplier" name="doSaveSuplier" label="${doSaveSuplier_N}" onClick="doSaveSuplier" disabled="${doSaveSuplier_D}" visible="${doSaveSuplier_V}"/>
                            <e:button id="doDeleteSuplier" name="doDeleteSuplier" label="${doDeleteSuplier_N}" onClick="doDeleteSuplier" disabled="${doDeleteSuplier_D}" visible="${doDeleteSuplier_V}"/>
                        </e:buttonBar>
                        <e:gridPanel gridType="${_gridType}" id="supplierGrid" name="supplierGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.supplierGrid.gridColData}"/>
                    </div>
                    <div id="ui-tabs-4">
                        <%--담당자--%>
                        <e:buttonBar width="100%" align="right">
                            <e:button id="doAppendPic" name="doAppendPic" label="${doAppendPic_N}" onClick="doAppendPic" disabled="${doAppendPic_D}" visible="${doAppendPic_V}"/>
                            <e:button id="doSavePic" name="doSavePic" label="${doSavePic_N}" onClick="doSavePic" disabled="${doSavePic_D}" visible="${doSavePic_V}"/>
                            <e:button id="doDeletePic" name="doDeletePic" label="${doDeletePic_N}" onClick="doDeletePic" disabled="${doDeletePic_D}" visible="${doDeletePic_V}"/>
                        </e:buttonBar>
                        <e:gridPanel gridType="${_gridType}" id="picGrid" name="picGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.picGrid.gridColData}"/>
                    </div>
                    <div id="ui-tabs-5">
                        <%--품목분류--%>
                        <e:buttonBar width="100%" align="right">
                            <e:button id="doAppendItemClass" name="doAppendItemClass" label="${doAppendItemClass_N}" onClick="doAppendItemClass" disabled="${doAppendItemClass_D}" visible="${doAppendItemClass_V}"/>
                            <e:button id="doSaveItemClass" name="doSaveItemClass" label="${doSaveItemClass_N}" onClick="doSaveItemClass" disabled="${doSaveItemClass_D}" visible="${doSaveItemClass_V}"/>
                            <e:button id="doDeleteItemClass" name="doDeleteItemClass" label="${doDeleteItemClass_N}" onClick="doDeleteItemClass" disabled="${doDeleteItemClass_D}" visible="${doDeleteItemClass_V}"/>
                        </e:buttonBar>
                        <e:gridPanel gridType="${_gridType}" id="itemClassGrid" name="itemClassGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.itemClassGrid.gridColData}"/>
                    </div>
                </div></td></tr>
            </e:panel>
        </div>
	</e:window>
</e:ui>
