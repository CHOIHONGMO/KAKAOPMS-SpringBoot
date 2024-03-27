<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
    <link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
    <script type="text/javascript" src="/js/dtree/dtree.js"></script>
    <script>

    var supplierGrid, itemClassGrid; //gridSIRA, picGrid
//    var ptItemGrid;

    var baseUrl = "/evermp/IM04/IM0402/";
    var fileUrl = "/common/file/fileAttach/upload.so?";

    var isSave = true;
    var newNode = "";
    var currentNode = "";
    var currentDepth = 1;
    var currentLeaf = 0;
    var insertMode = false;
    var treeNode = null;
    var SelectGrid;

    var supplierSelRow, itemSelRow; //siraSelRow, picSelRow

    function init() {

    	supplierGrid = EVF.C('supplierGrid');
        supplierGrid.setProperty("shrinkToFit", true);
        supplierGrid.setProperty('multiselect', true);

      /*  itemClassGrid.setProperty("shrinkToFit", true);
        itemClassGrid.setProperty('multiselect', true); */

//        ptItemGrid = EVF.C('ptItemGrid');
//        ptItemGrid.setProperty("shrinkToFit", true);
//        ptItemGrid.setProperty('multiselect', true);

        supplierGrid.setProperty('panelVisible', ${panelVisible});
        /* itemClassGrid.setProperty('panelVisible', ${panelVisible}); */
        <%--ptItemGrid.setProperty('panelVisible', ${panelVisible});--%>

        EVF.C('doSaveDefinition').setDisabled(false);
        EVF.C('doDeleteDefinition').setDisabled(false);
        EVF.C('addCurrentNode').setDisabled(false);
        EVF.C('addChildNode').setDisabled(false);

        supplierGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            supplierSelRow = rowid;
        });

        /* itemClassGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
            itemSelRow = rowid;
        }); */
//
//        ptItemGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
//            itemSelRow = rowid;
//        });



        supplierGrid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });
        /* itemClassGrid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        }); */
        <%--ptItemGrid.excelExportEvent({--%>
            <%--allItems : "${excelExport.allCol}",--%>
            <%--fileName : "${screenName }"--%>
        <%--});--%>

        supplierGrid.delRowEvent(function() {
            if(!supplierGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = supplierGrid.jsonToArray(supplierGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(supplierGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${IM04_002_0004}');
                }
            }

            supplierGrid.delRow();
        });

        /* itemClassGrid.delRowEvent(function() {
            if(!itemClassGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = itemClassGrid.jsonToArray(itemClassGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(itemClassGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${IM04_002_0004}');
                }
            }
            itemClassGrid.delRow();
        }); */

        <%--ptItemGrid.delRowEvent(function() {--%>
            <%--if(!ptItemGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }--%>

            <%--var selRowId = ptItemGrid.jsonToArray(ptItemGrid.getSelRowId()).value;--%>
            <%--for (var i = 0; i < selRowId.length; i++) {--%>
                <%--if(ptItemGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){--%>
                    <%--return alert('${IM04_002_0004}');--%>
                <%--}--%>
            <%--ptItemGrid.delRow();--%>
        <%--});--%>

        doSearchTree();
    }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
            {
                activate: function(event, ui) {
                    $(window).trigger('resize');
                }
            }
        );
        $('#e-tabs').tabs('option', 'active', 0);

        setTimeout(function() {
            $('#e-tabs > iframe').height($('.ui-layout-center').outerHeight()-30);
            $('.menu-container').height($('.ui-layout-west').outerHeight(true)-100);
        }, 500);
    });

    function getContentTab(uu) {

    	if (uu != '1')
            //onSelectNode();

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
    	if(treeNode.IS_FOLDER == "false") {

            var store = new EVF.Store();
            updateCurrentNode();
            //isSave = true;



//            store.setGrid([supplierGrid, itemClassGrid, ptItemGrid]);
            store.setGrid([supplierGrid]);
            //store.setGrid([supplierGrid, itemClassGrid]);
            //disableButtons(isSave);

            store.load(baseUrl + "IM04_002/doGetSgInfoById", function() {
                //itemClassGrid.setCellMerge.call(['ITEM_CLS_NM1','ITEM_CLS_NM2','ITEM_CLS_NM3'], true);
                //itemClassGrid.setColMerge(['ITEM_CLS_NM1','ITEM_CLS_NM2','ITEM_CLS_NM3']);
            });


        }
    }

    function doSearchTree() {

    	var store = new EVF.Store();
        store.load(baseUrl + 'IM04_002/doSearchDtree', function() {
            var treeData = this.getParameter("treeData");
            var jsontree = JSON.parse(treeData);
            d = new dTree('d');

            d.add(0, -1, '${IM04_002_002}', '', '');

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
        initRightPanel();
    }

    function goTarget() {

        var nodeData = JSON.parse(d.aNodes[d.selectedNode].data);
        if (nodeData == null)
            return;

        formUtil.setFormData(d.aNodes[d.selectedNode].data);

        treeNode = nodeData;

        var store = new EVF.Store();
        store.setParameter("SG_DEF_TEXT_NUM", nodeData.SG_DEF_TEXT_NUM);
        store.load(baseUrl + 'IM04_002/doSearchContent', function() {
            var content = this.getParameter("content");
            EVF.V('CONTENT',content);
        });

        EVF.C('ITEM_CLS_PATH_NM').getValue();
        EVF.V('SG_NM_T3',EVF.C('ITEM_CLS_PATH_NM').getValue());

        //EVF.V('SG_NM_T3',EVF.C('ITEM_CLS_PATH_NM').getValue());
        //EVF.V('SG_NM_T4',EVF.C('ITEM_CLS_PATH_NM').getValue());

        if(treeNode.IS_FOLDER == "false") {
            EVF.C('addChildNode').setDisabled(false);
            onSelectNode();

        } else {
            EVF.C('addChildNode').setDisabled(false);
            supplierGrid.delAllRow();
//            picGrid.delAllRow();
           // itemClassGrid.delAllRow();
        }
    }

    function doReset(){
    	EVF.C('SG_NUM').reset();
    	EVF.C('CONTENT').reset();
    }

    function addCurrentNode(){
		//console.log("addCurrentNode execute");
       // EVF.C("ATT_FILE_NUM").reset();
		treeNode = null;
        if(treeNode == null)
        {
         	EVF.C('DEPTH').setValue('1');
            EVF.C('LEAF').setValue('0');
            EVF.C('PARENT_SG_NUM').setValue('');
            EVF.C('SORT_SQ').setValue(0);
        } /* else{
        	alert("DEPTH : " + treeNode.DEPTH + ", LEAF : " + treeNode.LEAF_FLAG);
          	EVF.C('DEPTH').setValue(treeNode.DEPTH);
            EVF.C('LEAF').setValue(treeNode.LEAF_FLAG);
            EVF.C('PARENT_SG_NUM').setValue(treeNode.PARENT_SG_NUM);
            EVF.C('SORT_SQ').setValue(treeNode.SORT_SQ_CNT);
        } */

       // console.log("addCurrentNode DEPTH : " + EVF.C('DEPTH').getValue() + ", LEAF : " + EVF.C('LEAF').getValue());

        insertMode = true;
      //  doSaveDefinition();
    }

    function updateCurrentNode(){
    	//console.log("updateCurrentNode execute");
    	if(treeNode != null){
	    	EVF.C('DEPTH').setValue(treeNode.DEPTH);
	        EVF.C('LEAF').setValue(treeNode.LEAF_FLAG);
	        EVF.C('PARENT_SG_NUM').setValue(treeNode.PARENT_SG_NUM);
	        EVF.C('SORT_SQ').setValue(treeNode.SORT_SQ_CNT);
    	}

    	//console.log("updateCurrentNode DEPTH : " + EVF.C('DEPTH').getValue(treeNode.DEPTH) + ", LEAF : " + EVF.C('LEAF').getValue(treeNode.LEAF_FLAG));
    	//console.log("update treeNode == " + treeNode);
    	insertMode = false;
       // doSaveDefinition();
    }

    function initRightPanel(){

        var formValue = formUtil.getFormData();
        var formKey = Object.keys(formValue);

        for(var i = 0; i < formKey.length; i++) {
            if(formKey[i] != "ATT_FILE_NUM") {
                EVF.C(formKey[i]).setValue("");
            } else {
                EVF.C(formKey[i]).setFileId("");
            }
        }

        addCurrentNode();
        //console.log("treeNode == " + treeNode);

    }

    function addChildNode(){

    	EVF.C("ATT_FILE_NUM").reset();

        if(treeNode != null){
            EVF.C('DEPTH').setValue(parseInt(treeNode.DEPTH) + 1);
            EVF.C('LEAF').setValue('1');
            EVF.C('PARENT_SG_NUM').setValue(treeNode.SG_NUM);
        } else {
          	alert('${IM04_002_0002}');
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
                EVF.C(formKey[i]).setValue("");
            } else {
                EVF.C(formKey[i]).setFileId("");
            }
        }

//        itemClassGrid.delAllRow();
        supplierGrid.delAllRow();
//      picGrid.delAllRow();
        isSave = false;
//		disableButtons(isSave);
    }

    function disableButtons(flag){
        if(!flag){
            EVF.C('doAppendSuplier').setDisabled(true);
            EVF.C('doSaveSuplier').setDisabled(true);
            EVF.C('doDeleteSuplier').setDisabled(true);

            EVF.C('doAppendPic').setDisabled(true);
            EVF.C('doSavePic').setDisabled(true);
            EVF.C('doDeletePic').setDisabled(true);

            EVF.C('doAppendItemClass').setDisabled(true);
            EVF.C('doSaveItemClass').setDisabled(true);
            EVF.C('doDeleteItemClass').setDisabled(true);
            EVF.C('doAppendPTItemClass').setDisabled(true);
            EVF.C('doSavePTItemClass').setDisabled(true);
            EVF.C('doDeletePTItemClass').setDisabled(true);

            EVF.C('doSaveDefinition').setDisabled(true);
         	EVF.C('doDeleteDefinition').setDisabled(true);
        }
        else {
        	EVF.C('doSaveDefinition').setDisabled(false);
         	EVF.C('doDeleteDefinition').setDisabled(false);

            EVF.C('addCurrentNode').setDisabled(false);
            EVF.C('addChildNode').setDisabled(false);

            EVF.C('doAppendSuplier').setDisabled(false);
            EVF.C('doSaveSuplier').setDisabled(false);
            EVF.C('doDeleteSuplier').setDisabled(false);

            EVF.C('doAppendPic').setDisabled(false);
            EVF.C('doSavePic').setDisabled(false);
            EVF.C('doDeletePic').setDisabled(false);

            EVF.C('doAppendItemClass').setDisabled(false);
            EVF.C('doSaveItemClass').setDisabled(false);
            EVF.C('doDeleteItemClass').setDisabled(false);
            EVF.C('doAppendPTItemClass').setDisabled(false);
            EVF.C('doSavePTItemClass').setDisabled(false);
            EVF.C('doDeletePTItemClass').setDisabled(false);
        }
    }

    // Save button process
    function doSaveDefinition(){

        var store = new EVF.Store();

        if (!store.validate()) return;

        if (insertMode && EVF.C('SG_NUM').getValue() != "") {
            if (!confirm("${IM04_002_CONFIRM_ATT_REMOVED }\n" + "${msg.M0021}")) {
                insertMode = false;
                return;
            }
        } else {
            if (!confirm("${msg.M0021}")) {
                insertMode = false;
                return;
            }
        }
        <%--var confirmMsg = (insertMode ? "${IM04_002_CONFIRM_ATT_REMOVED }\n" : "") + "${msg.M0021}"; --%>

        <!--if (confirm(confirmMsg)) { -->
        if (insertMode) EVF.C('SG_NUM').setValue("");
        store.doFileUpload(function() {
            store.load(baseUrl + "IM04_002/saveSGDefinition", function() {
                insertMode = false;
                currentNode = this.getParameter("SG_NUM");
                newNode = "";
                isSave = true;
                //disableButtons(isSave);
               // console.log("save__ insertMode t/f : " + insertMode);
               // console.log("save__ DEPTH : " + EVF.C('DEPTH').getValue() + ", LEAF : " + EVF.C('LEAF').getValue());
               // console.log("save__ json : " + JSON.stringify(treeNode));
                if (parseInt(currentDepth) === 4)
                    EVF.C('addChildNode').setDisabled(true);
                alert(this.getResponseMessage());
                resetAll();
                doSearchTree();
            });
        });
    }

    function doDeleteDefinition(){

        if(treeNode == null){
            return alert('${IM04_002_0002}');
        }

        var store = new EVF.Store();
        if(!store.validate()) return;

        if (!confirm("${msg.M0013}")) return;

        if(treeNode != null){

            var store = new EVF.Store();
            store.load(baseUrl + "IM04_002/deleteSGDefinition", function() {

                if(this.getResponseMessage() == "fail"){
                    var nodeId =  EVF.C('tree').getSelectedNode().getId();
                    EVF.C('tree').remove(nodeId);
                }
                alert(this.getResponseMessage());
                newNode = currentNode = "";
                EVF.C('SG_NUM').setValue('');
                currentDepth = 1;
                currentLeaf = 0;
                isSave = false;
                //disableButtons(isSave);
                resetAll();
                doSearchTree();
            });
        }
        else alert('${IM04_002_0002}');
    }

    function getMultiSgName(){

    	var params = {
            multi_code: 'SG',
            screen_id: '-',
            other_code: EVF.C('SG_NUM').getValue(),
            nRow: 0,
            callBackFunction:'reGetMultiEgName'
        };
        everPopup.openMultiLanguagePopup(params);
    }

    function reGetMultiEgName(redata){
		EVF.C('SG_NUM').setValue(redata.multiNm);
    }

    function doAppendSuplier(){

        if(treeNode == null){
            return alert('${IM04_002_0002}');
        }

        if(treeNode.IS_FOLDER == "true") {
            return alert("${IM04_002_0003}");
        }

        var param = {
            callBackFunction: "selectVendor",
            clearButton : "OFF"
        };
        everPopup.openCommonPopup(param, 'MP0001');
    }

    function selectVendor(data) {

        var dataArr = [];

        for(idx in data) {
            var arr = {
                'VENDOR_CD': data[idx].VENDOR_CD,
                'VENDOR_NM': data[idx].VENDOR_NM,
                'MAJOR_ITEM_TEXT': data[idx].MAJOR_ITEM_TEXT
            };
            dataArr.push(arr);
        }

        var validData = valid.equalPopupValid(JSON.stringify(dataArr), supplierGrid, "VENDOR_CD");
        supplierGrid.addRow(validData);
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
        store.load(baseUrl + "IM04_002/doSaveSupplierInfo", function() {
        	alert(this.getResponseMessage());
        	currentNode = EVF.C('SG_NUM').getValue();
            onSelectNode();
            //doSearchTree();
        });
    }

    function doDeleteSuplier(){

    	var store = new EVF.Store();
        if (!store.validate()) return;

        if ((supplierGrid.jsonToArray(supplierGrid.getSelRowId()).value).length == 0) {
            return alert("${msg.M0004}");
        }

        var selRowId = supplierGrid.jsonToArray(supplierGrid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            if(supplierGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                return alert('${IM04_002_0005}');
            }
        }

        if (!confirm("${msg.M0013}")) return;

        store.setGrid([supplierGrid]);
        store.getGridData(supplierGrid, 'sel');
        store.load(baseUrl + "IM04_002/doDeleteSuplier", function() {
            alert(this.getResponseMessage());

            onSelectNode();
        });
    }

    function doAppendPic() {

    	if(treeNode.IS_FOLDER == "true") {
            return alert("${IM04_002_0001}");
        }

        var param = {
            callBackFunction: "selectUser",
            clearButton: "OFF"
        };
        everPopup.openCommonPopup(param, 'SP0011');
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
//      picGrid.addRow(arrData);
    }

    function doSelectPic() {
        everPopup.openCommonPopup({
            callBackFunction: "selectUser2"
        }, 'SP0011');
    }

    function selectUser2(data) {
    	if(data.USER_ID == '') return;
        EVF.C("CTRL_USER_ID").setValue(data.USER_ID);
    	EVF.C("CTRL_USER_NM").setValue(data.USER_NM);
    }

    function doSelectScreenTemplate(){
    	everPopup.openCommonPopup({
    		EV_TYPE : "SCRE",
            callBackFunction: "selectScreenTemplate"
        }, 'SP0034');
    }

    function selectScreenTemplate(data){
    	EVF.C("SCRE_EV_TPL_NUM").setValue(data.EV_TPL_NUM);
    	EVF.C("SCRE_EV_TPL_SUBJECT").setValue(data.EV_TPL_SUBJECT);
    }

    function doSelectSiteTemplate(){
    	everPopup.openCommonPopup({
    		EV_TYPE : "SITE",
            callBackFunction: "selectSiteTemplate"
        }, 'SP0034');
    }

    function selectSiteTemplate(data){
    	EVF.C("SITE_EV_TPL_NUM").setValue(data.EV_TPL_NUM);
    	EVF.C("SITE_EV_TPL_SUBJECT").setValue(data.EV_TPL_SUBJECT);
    }

    function doAppendItemClass(){
        var data = this.getData();
    	if(treeNode == null){
            return alert('${IM04_002_0002}');
        }

        if(treeNode.IS_FOLDER == "true") {
            return alert("${IM04_002_0003}");
        }

        if(data=="M"){
            SelectGrid = "m";
            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "selectItemClass",
                'detailView': false,
                'multiYN' : true,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '${ses.companyCd}',
                'custNm' : '${ses.companyNm}'
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }else{
            SelectGrid = "pt";
            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "selectItemClass",
                'detailView': false,
                'multiYN' : true,
                'ModalPopup' : true,
                'searchYN' : true,
                'ptYn' : true,
                'screenName': '분류체계(판촉)',
                'custCd' : '${ses.manageCd}',
                'custNm' : '${ses.companyNm}'
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }


    }

    function selectItemClass(data){

        var dataArr = [];
        for(idx in data) {
            if(data[idx].UPYN!='100'){

                if(data[idx].SG_YN!=''){
                    alert(data[idx].ITEM_CLS_PATH_NM+'${IM04_002_0006}');
                    return;
                }else{

                    if (SelectGrid == "m") {
                        var arr = {
                            'ITEM_CLS1': data[idx].ITEM_CLS1,
                            'ITEM_CLS2': data[idx].ITEM_CLS2,
                            'ITEM_CLS3': data[idx].ITEM_CLS3,
                            'ITEM_CLS4': data[idx].ITEM_CLS4,
                            'ITEM_CLS_PATH_NM': data[idx].ITEM_CLS_PATH_NM,
                            'SG_NUM' : data[idx].tree,
                            'M_CATE_YN' :'1',   //MRO
                            'P_CATE_YN' :'0'    //판촉
                        };
                        dataArr.push(arr);
                    }else{
                        var arr = {
                            'ITEM_CLS1': data[idx].ITEM_CLS1,
                            'ITEM_CLS2': data[idx].ITEM_CLS2,
                            'ITEM_CLS3': data[idx].ITEM_CLS3,
                            'ITEM_CLS4': data[idx].ITEM_CLS4,
                            'ITEM_CLS_PATH_NM': data[idx].ITEM_CLS_PATH_NM,
                            'SG_NUM' : data[idx].tree,
                            'M_CATE_YN' :'0',   //MRO
                            'P_CATE_YN' :'1'    //판촉
                        };
                        dataArr.push(arr);
                    }

                }

            }
        }

        if (SelectGrid == "m") {
//            var validData = valid.equalPopupValid(JSON.stringify(dataArr), itemClassGrid, "ITEM_CLS_PATH_NM");
//           itemClassGrid.addRow(validData);
        }else{
//            var validData = valid.equalPopupValid(JSON.stringify(dataArr), ptItemGrid, "ITEM_CLS_PATH_NM");
//            ptItemGrid.addRow(validData);
        }

    }





    /* function doSaveItemClass(){

    	var store = new EVF.Store();
        if (!store.validate()) return;

        if ((itemClassGrid.jsonToArray(itemClassGrid.getSelRowId()).value).length == 0) {
            return alert("${msg.M0004}");
        }

        if (!confirm("${msg.M0021}")) return;

        store.setGrid([itemClassGrid]);
        store.getGridData(itemClassGrid, 'sel');
        store.load(baseUrl + "IM04_002/doSaveItemClass", function() {
        	alert(this.getResponseMessage());
            currentNode = EVF.C('SG_NUM').getValue();
            onSelectNode();
        });
    } */

    /* function doDeleteItemClass(){
        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((itemClassGrid.jsonToArray(itemClassGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        var selRowId = itemClassGrid.jsonToArray(itemClassGrid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            if(itemClassGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                return alert('${IM04_002_0005}');
            }
        }

        if (!confirm("${msg.M0013}")) return;

        store.setGrid([itemClassGrid]);
        store.getGridData(itemClassGrid, 'sel');
        store.load(baseUrl + "IM04_002/doDeleteItemClass", function() {
        	alert(this.getResponseMessage());
            onSelectNode();
        });
    } */



    function doSavePTItemClass(){

        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((ptItemGrid.jsonToArray(ptItemGrid.getSelRowId()).value).length == 0) {
            return alert("${msg.M0004}");
        }

        if (!confirm("${msg.M0021}")) return;

        store.setGrid([ptItemGrid]);
        store.getGridData(ptItemGrid, 'sel');
        store.load(baseUrl + "IM04_002/doSavePTItemClass", function() {
            alert(this.getResponseMessage());
            currentNode = EVF.C('SG_NUM').getValue();
            onSelectNode();
        });
    }

    function doDeletePTItemClass(){
        var store = new EVF.Store();
        if (!store.validate()) return;

        if ((ptItemGrid.jsonToArray(ptItemGrid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        var selRowId = ptItemGrid.jsonToArray(ptItemGrid.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
            if(ptItemGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                return alert('${IM04_002_0005}');
            }
        }

        if (!confirm("${msg.M0013}")) return;

        store.setGrid([ptItemGrid]);
        store.getGridData(ptItemGrid, 'sel');
        store.load(baseUrl + "IM04_002/doDeletePTItemClass", function() {
            alert(this.getResponseMessage());
            onSelectNode();
        });
    }

    </script>

    <e:window id="IM04_002" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="leftPanel" width="30%">
            <e:buttonBar align="right">
                <e:button id="addCurrentNode" name="addCurrentNode" label="${addCurrentNode_N}" onClick="initRightPanel" disabled="${addCurrentNode_D}" visible="${addCurrentNode_V}"/>
                <e:button id="addChildNode" name="addChildNode" label="${addChildNode_N}" onClick="addChildNode" disabled="${addChildNode_D}" visible="${addChildNode_V}"/>
            </e:buttonBar>
            <div id="tree" style="height: 550px; overflow: auto;"> </div>
        </e:panel>

        <e:panel width="1%">&nbsp;</e:panel>

        <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
            <e:panel id="rightPanel" width="68%">
                <tr><td><div>
                    <ul>
                        <li><a href="#ui-tabs-1" onclick="getContentTab('1');">${IM04_002_003}</a></li>
                        <li><a href="#ui-tabs-3" onclick="getContentTab('3');">${IM04_002_004}</a></li>
                        <%-- <li><a href="#ui-tabs-5" onclick="getContentTab('5');">${IM04_002_005}</a></li> --%>
                    </ul>
                    <div id="ui-tabs-1">
                        <%--Definition--%>
                        <e:buttonBar width="100%" align="right">
                            <e:button id="doSaveDefinition" name="doSaveDefinition" label="${doSaveDefinition_N}" onClick="doSaveDefinition" disabled="${doSaveDefinition_D}" visible="${doSaveDefinition_V}"/>
                            <e:button id="doDeleteDefinition" name="doDeleteDefinition" label="${doDeleteDefinition_N}" onClick="doDeleteDefinition" disabled="${doDeleteDefinition_D}" visible="${doDeleteDefinition_V}"/>
                        </e:buttonBar>
                        <e:searchPanel useTitleBar="false" id="form" title="${form_CAPTION_N}" labelWidth="130px" labelAlign="${labelAlign}" columnCount="1">
                            <e:row>
                                <e:label for="SG_NM" title="${form_SG_NM_N}"/>
                                <e:field>
                                    <e:inputText id="SG_NM" name="SG_NM" value="${form.SG_NM}" width="${form_SG_NM_W}" maxLength="${form_SG_NM_M}" disabled="${form_SG_NM_D}" readOnly="${form_SG_NM_RO}" required="${form_SG_NM_R}" />
                                    <e:inputHidden id="SG_NUM" name="SG_NUM" />
                                    <e:inputHidden id="ITEM_CLS_PATH_NM" name="ITEM_CLS_PATH_NM" />
                                </e:field>
                            </e:row>
                            <e:row>
                                <e:label for="CONTENT" title="${form_CONTENT_N}"/>
                                <e:field>
                                    <e:richTextEditor height="100%" id="CONTENT" name="CONTENT" width="100%" required="${form_CONTENT_R }" readOnly="${form_CONTENT_RO }" disabled="${form_CONTENT_D }" value="${form.CONTENT }" useToolbar="${!param.detailView}" />
                                </e:field>
                            </e:row>
                            <e:row>
								<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
								<e:field>
									<e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.CTRL_USER_ID}" options="${ctrlUserIdOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
								</e:field>
                            </e:row>
                            <e:row>
                                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                                <e:field>
                                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="SRM" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
                                </e:field>
                            </e:row>

                            <e:inputHidden id="PARENT_SG_NUM" name="PARENT_SG_NUM" />
                            <e:inputHidden id="SORT_SQ" name="SORT_SQ" />
                            <e:inputHidden id="LEAF" name="LEAF" />
                            <e:inputHidden id="DEPTH" name="DEPTH" />
                            <e:inputHidden id="IS_FOLDER" name="IS_FOLDER" />
                        </e:searchPanel>
                    </div>
                    <div id="ui-tabs-3">
                        <e:buttonBar width="100%" align="right">
                            <e:button id="doAppendSuplier" name="doAppendSuplier" label="${doAppendSuplier_N}" onClick="doAppendSuplier" disabled="${doAppendSuplier_D}" visible="${doAppendSuplier_V}"/>
                            <e:button id="doSaveSuplier" name="doSaveSuplier" label="${doSaveSuplier_N}" onClick="doSaveSuplier" disabled="${doSaveSuplier_D}" visible="${doSaveSuplier_V}"/>
                            <e:button id="doDeleteSuplier" name="doDeleteSuplier" label="${doDeleteSuplier_N}" onClick="doDeleteSuplier" disabled="${doDeleteSuplier_D}" visible="${doDeleteSuplier_V}"/>
                        </e:buttonBar>
                        <e:searchPanel useTitleBar="false" id="form3" title="${form_CAPTION_N}" labelWidth="130px" labelAlign="${labelAlign}" columnCount="1">

                            <e:row>
                                <e:label for="SG_NM_T3" title="${form_SG_NM_T4_N}"></e:label>
                                <e:field>
                                    <e:inputText id="SG_NM_T3" name="SG_NM_T3" value="${form.SG_NM}" width="${form_SG_NM_T4_W}" maxLength="${form_SG_NM_T4_M}" disabled="${form_SG_NM_T4_D}" readOnly="${form_SG_NM_T4_RO}" required="${form_SG_NM_T4_R}" style="${imeMode}" />
                                </e:field>
                            </e:row>
                        </e:searchPanel>
                        <e:gridPanel gridType="${_gridType}" id="supplierGrid" name="supplierGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.supplierGrid.gridColData}"/>
                    </div>
                    <%-- <div id="ui-tabs-5">

                        <e:searchPanel useTitleBar="false" id="form4" title="${form_CAPTION_N}" labelWidth="130px" labelAlign="${labelAlign}" columnCount="1">
                            <e:row>
                                <e:label for="SG_NM_T4" title="${form_SG_NM_T4_N}"></e:label>
                                <e:field>
                                    <e:inputText id="SG_NM_T4" name="SG_NM_T4" value="${form.SG_NM}" width="${form_SG_NM_T4_W}" maxLength="${form_SG_NM_T4_M}" disabled="${form_SG_NM_T4_D}" readOnly="${form_SG_NM_T4_RO}" required="${form_SG_NM_T4_R}" style="${imeMode}" />
                                </e:field>
                            </e:row>
                        </e:searchPanel>

                        <e:buttonBar title="${IM04_002_0007}" width="100%" align="right">
                            <e:button id="doAppendItemClass" name="doAppendItemClass" label="${doAppendItemClass_N}" data="M" onClick="doAppendItemClass" disabled="${doAppendItemClass_D}" visible="${doAppendItemClass_V}"/>
                            <e:button id="doSaveItemClass" name="doSaveItemClass" label="${doSaveItemClass_N}" onClick="doSaveItemClass" disabled="${doSaveItemClass_D}" visible="${doSaveItemClass_V}"/>
                            <e:button id="doDeleteItemClass" name="doDeleteItemClass" label="${doDeleteItemClass_N}" onClick="doDeleteItemClass" disabled="${doDeleteItemClass_D}" visible="${doDeleteItemClass_V}"/>
                        </e:buttonBar>
                        <e:gridPanel gridType="${_gridType}" id="itemClassGrid" name="itemClassGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.itemClassGrid.gridColData}"/>

                    </div>--%>
                </div></td></tr>
            </e:panel>
        </div>
	</e:window>
</e:ui>
