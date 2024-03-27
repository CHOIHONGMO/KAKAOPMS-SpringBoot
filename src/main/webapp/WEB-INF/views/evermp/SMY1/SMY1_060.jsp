<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">


        var grid1;  //취급분야(SG)
        //var grid; //담당자정보
        var gridtx; //계산서담당자
        var gridVncp; //담당자정보
        var signStatus;
        var baseUrl = "/evermp/SMY1/SMY101/";
        var btnMsg;

        function init() {

            grid1 = EVF.C("grid1");
            gridtx = EVF.C("gridtx");
            gridVncp = EVF.C("gridVncp");
            grid1.setProperty('shrinkToFit', true);
            gridtx.setProperty('shrinkToFit', true);
            gridVncp.setProperty('shrinkToFit', true);

            gridVncp.addRowEvent(function () {
                gridVncp.addRow();
            });

            gridVncp.delRowEvent(function() {
                gridVncp.delRow();
            });

            gridtx.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "TX_ASP_ID") {
                    gridtx.setCellValue(rowid, 'TX_ASP_ID_$TP', gridtx.getCellValue(rowid, 'TX_ASP_ID'));
                }
                if (colId == "TX_USER_NM") {
                    gridtx.setCellValue(rowid, 'TX_USER_NM_$TP', gridtx.getCellValue(rowid, 'TX_USER_NM'));
                }
                if (colId == "TX_USER_TEL_NO") {
                    gridtx.setCellValue(rowid, 'TX_USER_TEL_NO_$TP', gridtx.getCellValue(rowid, 'TX_USER_TEL_NO'));
                }
                if (colId == "TX_USER_CELL_NO") {
                    gridtx.setCellValue(rowid, 'TX_USER_CELL_NO_$TP', gridtx.getCellValue(rowid, 'TX_USER_CELL_NO'));
                }
                if (colId == "TX_USER_FAX_NO") {
                    gridtx.setCellValue(rowid, 'TX_USER_FAX_NO_$TP', gridtx.getCellValue(rowid, 'TX_USER_FAX_NO'));
                }
                if (colId == "TX_USER_EMAIL") {
                    gridtx.setCellValue(rowid, 'TX_USER_EMAIL_$TP', gridtx.getCellValue(rowid, 'TX_USER_EMAIL'));
                }
            });
            grid1.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridtx.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            EVF.C("ACCOUNT_M_NUM").setReadOnly(true);

            if(!${detailView}) {
                grid1.delRowEvent(function() {
                    if(!grid1.isExistsSelRow()) { return alert("${msg.M0004}"); }

                    var grid1Data = grid1.getSelRowValue();
                    for( var i = 0; i < grid1Data.length; i++ ) {
                        if(grid1.getCellValue(i, 'INSERT_FLAG') =="Y"){
                            return alert("${SMY1_060_002}");
                        }
                    }
                    grid1.delRow();
                });

                gridtx.addRowEvent(function() {
                    var addParam = [{}];
                    gridtx.addRow(addParam);
                });

                gridtx.delRowEvent(function() {

                    if(!gridtx.isExistsSelRow()) { return alert("${msg.M0004}"); }
                    var selRowId = gridtx.jsonToArray(gridtx.getSelRowId()).value;
                    for (var i = 0; i < selRowId.length; i++) {
                        if(gridtx.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                            return alert("${msg.M0145}");
                        }
                    }
                    gridtx.delRow();
                });
            }

            if("${formData.SIGN_STATUS }" == "P"){
                EVF.C('doUpdate').setDisabled(true);
                EVF.C('SGSelect').setDisabled(true);
                EVF.C('SGDelete').setDisabled(true);
                EVF.C('deleteTx').setDisabled(true);

            }
            if("${formData.PROGRESS_CD }" == "E"){
                EVF.C('doUpdate').setDisabled(false);
                EVF.C('SGSelect').setDisabled(false);
                EVF.C('SGDelete').setDisabled(false);
                EVF.C('deleteTx').setDisabled(false);
            }else{

                EVF.C('doUpdate').setDisabled(true);
                EVF.C('SGSelect').setDisabled(true);
                EVF.C('SGDelete').setDisabled(true);
                EVF.C('deleteTx').setDisabled(true);
            }

            if(EVF.V("ACCOUNT_M_NUM")!="") {
                EVF.C("VENDOR_NM").setReadOnly(true);
                EVF.C("REG_TYPE").setReadOnly(true);
                EVF.C("HQ_ADDR_1").setReadOnly(true);
                EVF.C("HQ_ADDR_2").setReadOnly(true);
                EVF.C("HQ_ZIP_CD").setReadOnly(true);
                EVF.C("CEO_USER_NM").setReadOnly(true);
                EVF.C("BUSINESS_TYPE").setReadOnly(true);
                EVF.C("INDUSTRY_TYPE").setReadOnly(true);
                EVF.C("FOUNDATION_DATE").setReadOnly(true);
            }

            doSearchGrid();
            dodSearchTx();
            doSearchVncp();

            if(EVF.V("USER_ID")!=""){
                EVF.C("USER_ID").setReadOnly(true);
                EVF.V("ID_CHECK","Y");
                EVF.C('Idcheck').setDisabled(true);
            }else{
                EVF.V("ID_CHECK","");
            }
        }


        function doSearchVncp() {
            var store = new EVF.Store();
            store.setGrid([gridVncp]);
            store.setParameter("VENDOR_CD", EVF.V("VENDOR_CD"));
            store.load('/evermp/BS03/BS0301/bs03002_doSearchUser', function() {
                if(gridVncp.getRowCount() > 0){
                    gridVncp.checkAll(true);
                }
            });
        }

        function doSearchGrid() {

            var store = new EVF.Store();
            store.setGrid([grid1]);
            store.setParameter("VENDOR_CD", EVF.V("VENDOR_CD"));
            store.load('/evermp/BS03/BS0301/bs03002_doSearchSG', function() {
                if(grid1.getRowCount() > 0){
                    grid1.checkAll(true);
                }
            });
        }

        function dodSearchTx(){
            var store = new EVF.Store();
            store.setGrid([gridtx]);
            store.setParameter("VENDOR_CD", EVF.V("VENDOR_CD"));
            store.load('/evermp/BS03/BS0301/bs03002_doSearchTX', function() {
                if(gridtx.getRowCount() > 0){
                    gridtx.checkAll(true);
                }
            });
        }

        function doSave() {


            var store = new EVF.Store();
            if(!store.validate()) { return; }

            /*
            if(EVF.V("IPO_FLAG")=="1"){
                if(EVF.V("IPO_DATE")==""){
                    EVF.C("IPO_DATE").setFocus();
                    return alert("${SMY1_060_004}");
                }
            }
            */

            if(!grid1.isExistsSelRow()) { return alert("${SMY1_060_003}"); }
            if(!grid1.validate().flag) { return alert(grid1.validate().msg); }

            if(EVF.V("E_BILL_ASP_TYPE")=="0"){
                if(!gridtx.isExistsSelRow()) { return alert("${SMY1_060_013}"); }
                if(!gridtx.validate().flag) { return alert(gridtx.validate().msg); }
            }

            if(EVF.V("ID_CHECK")!="Y"){
                return alert("${SMY1_060_007}");
            }

            var checkChange ="";
            if(EVF.V("VENDOR_CD")!=""){

                if(EVF.V("ORI_CEO_USER_NM")!=EVF.V("CEO_USER_NM")){ checkChange = "Y"; }
                if(EVF.V("ORI_HQ_ZIP_CD")!=EVF.V("HQ_ZIP_CD")){ checkChange = "Y"; }
                if(EVF.V("ORI_HQ_ADDR_1")!=EVF.V("HQ_ADDR_1")){ checkChange = "Y"; }
                if(EVF.V("ORI_HQ_ADDR_2")!=EVF.V("HQ_ADDR_2")){ checkChange = "Y"; }

                if(checkChange=="Y"){
                    if(!alert("${SMY1_060_009}")) {
                        var param = {
                            title: "회사주소, 대표자명 변경사유",
                            message: "",
                            callbackFunction: 'setChReason'
                        };
                        everPopup.commonTextInput(param);
                    }
                }
            }else{
                EVF.V("CH_REASON","신규등록");
            }
            if(checkChange==""){
                doSaveAction();
            }
        }

        function doSaveAction(){

            if (!confirm("${msg.M0012}")) return;

            goApproval();
        }

        function goApproval() {

            var store = new EVF.Store();
            store.doFileUpload(function() {
                store.setParameter("signStatus", signStatus);

                store.setGrid([grid1,gridtx,gridVncp]);
                store.getGridData(grid1, 'sel');
                store.getGridData(gridtx, 'sel');
                store.getGridData(gridVncp, 'all');
                store.load(baseUrl + 'smy1060_doSave', function () {
                    alert(this.getResponseMessage());
                    var param = {
                        'detailView': false
                    };
                    window.location.href = '/evermp/SMY1/SMY101/SMY1_060/view.so?' + $.param(param);
                });

            });
        }

        function dodeleteTx(){
            if (!gridtx.isExistsSelRow()) { return alert('${msg.M0004}'); }

            var rowIds = gridtx.getSelRowId();
            for(var i in rowIds) {
                if(gridtx.getCellValue(rowIds[i], "INSERT_FLAG")==""){
                    return alert("${msg.M0146}");
                }
            }
            var gridAllDatas = gridtx.getAllRowValue();
            if(gridAllDatas.length-rowIds.length<1){
                return alert("${SMY1_060_016}");
            }
            if(!confirm('${msg.M0013}')) { return; }
            var store = new EVF.Store();

            store.setGrid([gridtx]);
            store.setParameter("VENDOR_CD", EVF.V("VENDOR_CD"));
            store.getGridData(gridtx, 'sel');
            store.load('/evermp/BS03/BS0301/bs03002_dodeleteTX', function() {
                alert(this.getResponseMessage());
                for( var i = 0; i < rowIds.length; i++ ) {
                    gridtx.delRow();
                }
            });
        }

        function setChReason(data) {
            EVF.V("CH_REASON",data.message);
            if(EVF.V("CH_REASON")==""){
                return alert("${SMY1_060_010}");
            }

            doSaveAction();
        }

        function doTempletDown() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BS03_002');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);
            }, false);
        }


        function checkIrsNum() {
            if(!isIrsNum(EVF.C("IRS_NO").getValue())) {
                alert("${msg.M0126}");
                EVF.C("IRS_NO").setValue("");
                EVF.C('IRS_NO').setFocus();
            }
        }

        function isIrsNum(str) {

            var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
            var chkSum = 0;
            var c2 = "";
            var remander;
            str = str.replace(/-/gi,'');

            for (var i = 0; i <= 7; i++) {
                chkSum += checkID[i] * str.charAt(i);
            }
            c2 = "0" + (checkID[8] * str.charAt(8));
            c2 = c2.substring(c2.length - 2, c2.length);
            chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
            remander = (10 - (chkSum % 10)) % 10 ;
            if (Math.floor(str.charAt(9)) == remander) {
                return true ; // OK!
            }
            return false;
        }

        function searchZipCd() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode",
                modalYn : false
            };
            //everPopup.openWindowPopup(url, 700, 600, param);
            everPopup.jusoPop(url, param);
        }

        function setZipCode(zipcd) {
            if (zipcd.ZIP_CD != "") {
                EVF.C("HQ_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('HQ_ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('HQ_ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('HQ_ADDR_2').setFocus();
            }
        }

        function searchZipCd2() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode2",
                modalYn : false
            };
            //everPopup.openWindowPopup(url, 700, 600, param);
            everPopup.jusoPop(url, param);
        }

        function setZipCode2(zipcd) {
            if (zipcd.ZIP_CD != "") {
                EVF.C("PLANT_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('PLANT_ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('PLANT_ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('PLANT_ADDR_2').setFocus();
            }
        }




        function doSGSelect(){

            var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
            var param = {
                callBackFunction: '_setSg',
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
        }
        function _setSg(resultData) {

            resultData = JSON.parse(resultData);
            var addParam = [
                {
                    "CLS_PATH_NM" : resultData.ITEM_CLS_PATH_NM
                    ,"CLS1" : resultData.ITEM_CLS1
                    ,"CLS2" : resultData.ITEM_CLS2
                    ,"CLS3" : resultData.ITEM_CLS3
                    ,"CLS4" : resultData.ITEM_CLS4
                    ,"SG_NUM" : resultData.SG_NUM
                    ,"INSERT_FLAG" : ""
                }
            ];
            grid1.addRow(addParam);
//            Set_SgTPL(-1);
        }

        function doSGDelete(){

            if (!grid1.isExistsSelRow()) { return alert('${msg.M0004}'); }
            var grid1Data = grid1.getSelRowValue();
            for( var i = 0; i < grid1Data.length; i++ ) {
                if(grid1.getCellValue(i, 'INSERT_FLAG') ==""){
                    return alert("${msg.M0146}");
                }
            }
            var gridAllDatas = grid1.getAllRowValue();

            if(gridAllDatas.length-grid1Data.length<1){
                return alert("${SMY1_060_015}");
            }

            if(!confirm('${msg.M0013}')) { return; }
            var store = new EVF.Store();

            store.setParameter("VENDOR_CD", "${param.VENDOR_CD }");
            store.setGrid([grid1]);
            store.getGridData(grid1, 'sel');
            store.load('/evermp/BS03/BS0301/bs03002_dodeleteSGVN', function() {
                alert(this.getResponseMessage());
                for( var i = 0; i < grid1Data.length; i++ ) {
                    grid1.delRow();
                }
            });

        }

        //첨부파일갯수제어-------------------------
        function onFileAdd() {
            if(EVF.C('BASIC_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            if(EVF.C('BIZ_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            /*if(EVF.C('ID_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }*/
            if(EVF.C('PRICE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            /*if(EVF.C('CERTIFI_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }*/
            if(EVF.C('BANKBOOK_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            /*if(EVF.C('SIGN_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            if(EVF.C('CONTRACT_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }*/
            if(EVF.C('SECRET_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            if(EVF.C('IMGAGREE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            /*if(EVF.C('PRIVATE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }
            if(EVF.C('AGREE_ATT_FILE_NUM').getFileCount()>1){
                return alert("${SMY1_060_001}");
            }*/
        }


        //id중복체크
        function doIdcheck() {
        	EVF.V("ID_CHECK","");
        	if(EVF.C("USER_ID").getValue()==""){
                EVF.C('USER_ID').setFocus();
                alert(everString.getMessage("${msg.M0109}", "${form_USER_ID_N}"));
            }else{
                var store = new EVF.Store();
                store.load('/evermp/BS03/BS0302/bs01002_doCheckUserId', function() {
                    if(this.getParameter("POSSIBLE_FLAG") == "N") {
                        EVF.V("ID_CHECK","");
                        return alert("${SMY1_060_006}");
                    }else{
                        EVF.V("ID_CHECK","Y");
                        alert("${SMY1_060_005}");

                        //EVF.C('Idcheck').setDisabled(true);
                        //EVF.C('USER_ID').setReadOnly(true);
                    }
                }, false);
            }
        }

        function onChangeID() {
      	  EVF.V("ID_CHECK","");
      	  IdcheckId();
      }

     function IdcheckId(){

     	//var regExp = /^[A-Za-z0-9_]{4,16}$/;
     	var regExp = /^[A-Za-z0-9_-]{3,16}$/;
         if (!EVF.V("USER_ID").match(regExp)){
             alert("${msg.ID_INVALID}");

             EVF.V("USER_ID","");
         }
     }

        function ModCheckPW(){
            var checkType = this.getData();
            if(checkType == "1") {
                EVF.V("PASSWORD","");
                EVF.V("CHANGE_PW","Y");
            }
            if(checkType == "2") {
                EVF.V("PASSWORD_CHECK","");
                EVF.V("CHANGE_PW","Y");
            }
        }

        function CheckCall(){
            var str;
            if(this.data=="1"){
                str = EVF.V("PASSWORD");
            }else{
                str = EVF.V("PASSWORD_CHECK");
            }
            if(!chkPwd(str)){
                EVF.C("PASSWORD").setValue("");
                EVF.C("PASSWORD_CHECK").setValue("");
                $('#PASSWORD').focus();
            }else{
                if(EVF.V("PASSWORD")!=""&&EVF.V("PASSWORD_CHECK")!=""){
                    if(EVF.V("PASSWORD")!=EVF.V("PASSWORD_CHECK")){
                        EVF.C("PASSWORD_CHECK").setValue("");
                        EVF.C("PASSWORD_CHECK").setFocus();
                        return alert("${SMY1_060_008}");
                    }
                }
            }
        }
        function chkPwd(str){
            var SamePass_0 = 0;
            var SamePass_1 = 0;
            var SamePass_2 = 0;

            var reg_pwd = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[a-zA-Z]).*$/;                     //영문숫자
            var reg_pwd2 = /^.*(?=.{6,12})(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;              //영문특수
            var reg_pwd3 = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[!@#$%^&+=]).*$/;                 //숫자특수
            var reg_pwd4 = /^.*(?=^.{6,12}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;    //영문숫자특수문자
            if(reg_pwd.test(str) || reg_pwd2.test(str)|| reg_pwd3.test(str)|| reg_pwd4.test(str)){

            }else{
                alert("${SMY1_060_021}");
                return false;
            }
            if(str.length >20){
                alert("${SMY1_060_021}");
                return false;
            }


            //동일문자 카운트
            for(var i=0; i < str.length; i++) {
                var chr_pass_0 = str.charAt(i);
                var chr_pass_1 = str.charAt(i+1);
                var chr_pass_2 = str.charAt(i+2);
                if(chr_pass_0 == chr_pass_1 && chr_pass_1 == chr_pass_2) {
                    SamePass_0 = SamePass_0 + 1
                }

                var chr_pass_2 = str.charAt(i+2);

                if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == 1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == 1) {
                    SamePass_1 = SamePass_1 + 1
                }

                if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == -1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == -1) {
                    SamePass_2 = SamePass_2 + 1
                }
            }
            if(SamePass_0 > 0) {
                alert("${SMY1_060_022}");
                return false;
            }
            if(SamePass_1 > 1 || SamePass_2 > 1 ) {
                alert("${SMY1_060_023}");
                return false;
            }

            return true;
        }

        function checkTelNo() {
            var checkType = this.getData();

            if(checkType == "FAX_NO") {
                if(!everString.isTel(EVF.C("FAX_NO").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("FAX_NO").setValue("");
                    EVF.C('FAX_NO').setFocus();
                }
            }
            /*
            if(checkType == "TEL_NO") {
                if(!everString.isTel(EVF.C("TEL_NO").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("TEL_NO").setValue("");
                    EVF.C('TEL_NO').setFocus();
                }
            }

            if(checkType == "PAY_MANAGE_TEL_NO") {
                if(!everString.isTel(EVF.C("PAY_MANAGE_TEL_NO").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("PAY_MANAGE_TEL_NO").setValue("");
                    EVF.C('PAY_MANAGE_TEL_NO').setFocus();
                }
            }
*/
            if(checkType == "FAX_NUM") {
                if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("FAX_NUM").setValue("");
                    EVF.C('FAX_NUM').setFocus();
                }
            }
            if(checkType == "TEL_NUM") {
                if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
                    alert("${msg.M0128}");
                    EVF.C("TEL_NUM").setValue("");
                    EVF.C('TEL_NUM').setFocus();
                }
            }
        }

        function checkCellNo() {
            var CellNum = EVF.V("CELL_NUM");
            var rgEx = /(01[016789])[-](\d{4}|\d{3})[-]\d{4}$/g;
            var chkFlg = rgEx.test(CellNum);
            if(!chkFlg){
                EVF.C("CELL_NUM").setValue("");
                EVF.C('CELL_NUM').setFocus();
                return alert("${msg.M0128}");
            }
        }

    </script>
    <e:window id="SMY1_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonTopBottom" align="right" width="100%" title="${SMY1_060_CAPTION1 }">
            <e:button id="doUpdate" name="doUpdate" label="${doUpdate_N }" disabled="${doUpdate_D }" visible="${doUpdate_V}" onClick="doSave" data="P" />
        </e:buttonBar>
        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:text> ${formData.VENDOR_CD } </e:text>
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${formData.VENDOR_NM }" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>
                    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${formData.VENDOR_CD }" />
                    <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${formData.APP_DOC_NUM }" />
                    <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${formData.APP_DOC_CNT }" />
                    <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD }" />
                    <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS }" />
                    <e:inputHidden id="OLD_SIGN_STATUS" name="OLD_SIGN_STATUS" value="${formData.SIGN_STATUS }" />
                    <e:inputHidden id="EVA_NAME" name="EVA_NAME" value="${formData.EVA_NAME }" />
                    <e:inputHidden id="YEAR" name="YEAR" value="${formData.YEAR }" />
                    <e:inputHidden id="FOUNDATION_DATE2" name="FOUNDATION_DATE2" value="${formData.FOUNDATION_DATE2 }" />
                    <e:inputHidden id="EVA1" name="EVA1" value="${formData.EVA1 }" />
                    <e:inputHidden id="EVA2" name="EVA2" value="${formData.EVA2 }" />
                    <e:inputHidden id="INS_AMT" name="INS_AMT" value="${formData.INS_AMT }" />
                    <e:inputHidden id="OPERATION" name="OPERATION" value="${formData.OPERATION }" />
                    <e:inputHidden id="PROFIT" name="PROFIT" value="${formData.PROFIT }" />
                    <e:inputHidden id="CAPITAL" name="CAPITAL" value="${formData.CAPITAL }" />
                    <e:inputHidden id="DEBT_TOT" name="DEBT_TOT" value="${formData.DEBT_TOT }" />
                    <e:inputHidden id="SALES_PROFIT" name="SALES_PROFIT" value="${formData.SALES_PROFIT }" />
                    <e:inputHidden id="NET_PROFIT" name="NET_PROFIT" value="${formData.NET_PROFIT }" />
                    <e:inputHidden id="DEBT_RATIO" name="DEBT_RATIO" value="${formData.DEBT_RATIO }" />
                    <e:inputHidden id="VENDOR_USER_UPDATE_YN" name="VENDOR_USER_UPDATE_YN" value="Y" />
                </e:field>
                <e:label for="VENDOR_ENG_NM" title="${form_VENDOR_ENG_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_ENG_NM" name="VENDOR_ENG_NM" value="${formData.VENDOR_ENG_NM }" width="100%" maxLength="${form_VENDOR_ENG_NM_M}" disabled="${form_VENDOR_ENG_NM_D}" readOnly="${form_VENDOR_ENG_NM_RO}" required="${form_VENDOR_ENG_NM_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REG_TYPE" title="${form_REG_TYPE_N}" />
                <e:field>
                    <e:select id="REG_TYPE" name="REG_TYPE" value="${formData.REG_TYPE }" options="${regTypeOptions }" width="${form_REG_TYPE_W}" disabled="${form_REG_TYPE_D}" readOnly="${form_REG_TYPE_RO}" required="${form_REG_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="IRS_NO" title="${form_IRS_NO_N}"/>
                <e:field>
                    <e:inputText id="IRS_NO" name="IRS_NO" placeHolder="${SMY1_060_INPUT_T1 }" value="${formData.IRS_NO }" width="${form_IRS_NO_W}" maxLength="${form_IRS_NO_M}" disabled="${form_IRS_NO_D}" readOnly="${form_IRS_NO_RO}" required="${form_IRS_NO_R}" onChange="checkIrsNum" />
                </e:field>
                <e:label for="COMPANY_REG_NO" title="${form_COMPANY_REG_NO_N}"/>
                <e:field>
                    <e:inputText id="COMPANY_REG_NO" name="COMPANY_REG_NO" placeHolder="${SMY1_060_INPUT_T1 }" value="${formData.COMPANY_REG_NO }" width="100%" maxLength="${form_COMPANY_REG_NO_M}" disabled="${form_COMPANY_REG_NO_D}" readOnly="${form_COMPANY_REG_NO_RO}" required="${form_COMPANY_REG_NO_R}" style="${imeMode}" onChange="checkCompanyRegNum"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="HQ_ZIP_CD" title="${form_HQ_ZIP_CD_N}"/>
                <e:field>
                    <e:search id="HQ_ZIP_CD" name="HQ_ZIP_CD" value="${formData.HQ_ZIP_CD }" width="100%" maxLength="7" onIconClick="${form_HQ_ZIP_CD_RO ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_HQ_ZIP_CD_D}" readOnly="true" required="${form_HQ_ZIP_CD_R}" />
                </e:field>
                <e:label for="HQ_ADDR_1" title="${form_HQ_ADDR_1_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="HQ_ADDR_1" name="HQ_ADDR_1" value="${formData.HQ_ADDR_1 }" width="${form_HQ_ADDR_1_W}" maxLength="${form_HQ_ADDR_1_M}" disabled="${form_HQ_ADDR_1_D}" readOnly="${form_HQ_ADDR_1_RO}" required="${form_HQ_ADDR_1_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="${formData.CEO_USER_NM }" width="${form_CEO_USER_NM_W}" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" style="${imeMode}"/>
                    <e:inputHidden id="ORI_CEO_USER_NM" name="ORI_CEO_USER_NM" value="${formData.CEO_USER_NM }" />
                    <e:inputHidden id="ORI_HQ_ZIP_CD" name="ORI_HQ_ZIP_CD" value="${formData.HQ_ZIP_CD }" />
                    <e:inputHidden id="ORI_HQ_ADDR_1" name="ORI_HQ_ADDR_1" value="${formData.HQ_ADDR_1 }" />
                    <e:inputHidden id="ORI_HQ_ADDR_2" name="ORI_HQ_ADDR_2" value="${formData.HQ_ADDR_2 }" />
                    <e:inputHidden id="CH_REASON" name="CH_REASON" value=""/>

                </e:field>
                <e:label for="HQ_ADDR_2" title="${form_HQ_ADDR_2_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="HQ_ADDR_2" name="HQ_ADDR_2" value="${formData.HQ_ADDR_2 }" width="${form_HQ_ADDR_2_W}" maxLength="${form_HQ_ADDR_2_M}" disabled="${form_HQ_ADDR_2_D}" readOnly="${form_HQ_ADDR_2_RO}" required="${form_HQ_ADDR_2_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}"/>
                <e:field>
                    <e:inputText id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="${formData.BUSINESS_TYPE }" width="${form_BUSINESS_TYPE_W}" maxLength="${form_BUSINESS_TYPE_M}" disabled="${form_BUSINESS_TYPE_D}" readOnly="${form_BUSINESS_TYPE_RO}" required="${form_BUSINESS_TYPE_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="INDUSTRY_TYPE" title="${form_INDUSTRY_TYPE_N}"/>
                <e:field>
                    <e:inputText id="INDUSTRY_TYPE" name="INDUSTRY_TYPE" value="${formData.INDUSTRY_TYPE }" width="${form_INDUSTRY_TYPE_W}" maxLength="${form_INDUSTRY_TYPE_M}" disabled="${form_INDUSTRY_TYPE_D}" readOnly="${form_INDUSTRY_TYPE_RO}" required="${form_INDUSTRY_TYPE_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="FOUNDATION_DATE" title="${form_FOUNDATION_DATE_N}"/>
                <e:field>
                    <e:inputDate id="FOUNDATION_DATE" name="FOUNDATION_DATE" value="${formData.FOUNDATION_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_FOUNDATION_DATE_R}" disabled="${form_FOUNDATION_DATE_D}" readOnly="${form_FOUNDATION_DATE_RO}" />
                </e:field>

            </e:row>
            <e:row>
                <e:label for="TEL_NO" title="${form_TEL_NO_N}"/>
                <e:field>
                    <e:inputText id="TEL_NO" name="TEL_NO" placeHolder="${SMY1_060_INPUT_T2 }" value="${formData.TEL_NO }" width="${form_TEL_NO_W}" maxLength="${form_TEL_NO_M}" disabled="${form_TEL_NO_D}" readOnly="${form_TEL_NO_RO}" required="${form_TEL_NO_R}" data="TEL_NO" />
                </e:field>
                <e:label for="FAX_NO" title="${form_FAX_NO_N}"/>
                <e:field>
                    <e:inputText id="FAX_NO" name="FAX_NO" placeHolder="${SMY1_060_INPUT_T2 }" value="${formData.FAX_NO }" width="${form_FAX_NO_W}" maxLength="${form_FAX_NO_M}" disabled="${form_FAX_NO_D}" readOnly="${form_FAX_NO_RO}" required="${form_FAX_NO_R}" data="FAX_NO" />
                </e:field>
                <e:label for="EMAIL" title="${form_EMAIL_N}"/>
                <e:field>
                    <e:inputText id="EMAIL" name="EMAIL" value="${formData.EMAIL }" width="${form_EMAIL_W}" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="EMPLOYEE_CNT" title="${form_EMPLOYEE_CNT_N}"/>
                <e:field>
                    <e:inputNumber id="EMPLOYEE_CNT" name="EMPLOYEE_CNT" value="${formData.EMPLOYEE_CNT}" width="100%" maxValue="${form_EMPLOYEE_CNT_M}" decimalPlace="${form_EMPLOYEE_CNT_NF}" placeHolder="(명)" disabled="${form_EMPLOYEE_CNT_D}" readOnly="${form_EMPLOYEE_CNT_RO}" required="${form_EMPLOYEE_CNT_R}" />
                </e:field>
                <e:label for="IPO_FLAG" title="${form_IPO_FLAG_N}" />
                <e:field>
                    <e:select id="IPO_FLAG" name="IPO_FLAG" value="${formData.IPO_FLAG }" options="${ipoFlagOptions }" width="${form_IPO_FLAG_W}" disabled="${form_IPO_FLAG_D}" readOnly="${form_IPO_FLAG_RO}" required="${form_IPO_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="IPO_DATE" title="${form_IPO_DATE_N}"/>
                <e:field>
                    <e:inputDate id="IPO_DATE" name="IPO_DATE" value="${formData.IPO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_IPO_DATE_R}" disabled="${form_IPO_DATE_D}" readOnly="${form_IPO_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="BUSINESS_SIZE" title="${form_BUSINESS_SIZE_N}"/>
                <e:field>
                    <e:select id="BUSINESS_SIZE" name="BUSINESS_SIZE" value="${formData.BUSINESS_SIZE}" options="${businessSizeOptions}" width="${form_BUSINESS_SIZE_W}" disabled="${form_BUSINESS_SIZE_D}" readOnly="${form_BUSINESS_SIZE_RO}" required="${form_BUSINESS_SIZE_R}" placeHolder="" />
                </e:field>
                <e:label for="BUSINESS_DIVISION" title="${form_BUSINESS_DIVISION_N}"/>
                <e:field colSpan="3" >
                    <e:checkGroup id="BUSINESS_DIVISION" name="BUSINESS_DIVISION" value="${formData.BUSINESS_DIVISION}" width="100%" disabled="${form_BUSINESS_DIVISION_D}" readOnly="${form_BUSINESS_DIVISION_RO}" required="${form_BUSINESS_DIVISION_R}">
                        <c:forEach var="busi" items="${businessList}" varStatus="vs">
                            <e:check id="BUSINESS_DIVISION_${busi.value}" name="BUSINESS_DIVISION_${busi.value}" value="${busi.value}" label="${busi.text}" disabled="${form_BUSINESS_DIVISION_D}" readOnly="${form_BUSINESS_DIVISION_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="HOMEPAGE_URL" title="${form_HOMEPAGE_URL_N}" />
                <e:field>
                    <e:inputText id="HOMEPAGE_URL" name="HOMEPAGE_URL" value="${formData.HOMEPAGE_URL}" width="${form_HOMEPAGE_URL_W}" maxLength="${form_HOMEPAGE_URL_M}" disabled="${form_HOMEPAGE_URL_D}" readOnly="${form_HOMEPAGE_URL_RO}" required="${form_HOMEPAGE_URL_R}" />
                </e:field>
                <e:label for="DELIVERY_TYPE" title="${form_DELIVERY_TYPE_N}"/>
                <e:field>
                    <e:checkGroup id="DELIVERY_TYPE" name="DELIVERY_TYPE" value="${formData.DELIVERY_TYPE}" width="100%" disabled="${form_DELIVERY_TYPE_D}" readOnly="${form_DELIVERY_TYPE_RO}" required="${form_DELIVERY_TYPE_R}">
                        <c:forEach var="deli" items="${deliberyType}" varStatus="vs">
                            <e:check id="DELIVERY_TYPE_${deli.value}" name="DELIVERY_TYPE_${deli.value}" value="${deli.value}" label="${deli.text}" disabled="${form_DELIVERY_TYPE_D}" readOnly="${form_DELIVERY_TYPE_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
                <e:label for="LICENSE_YN" title="${form_LICENSE_YN_N}"/>
                <e:field>
                    <e:select id="LICENSE_YN" name="LICENSE_YN" value="${formData.LICENSE_YN}" options="${licenseYnOptions}" width="${form_LICENSE_YN_W}" disabled="${form_LICENSE_YN_D}" readOnly="${form_LICENSE_YN_RO}" required="${form_LICENSE_YN_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DELIVERY_LEVEL" title="${form_DELIVERY_LEVEL_N}"/>
                <e:field>
                    <e:select id="DELIVERY_LEVEL" name="DELIVERY_LEVEL" value="${formData.DELIVERY_LEVEL}" options="${deliveryLevelOptions}" width="${form_DELIVERY_LEVEL_W}" disabled="${form_DELIVERY_LEVEL_D}" readOnly="${form_DELIVERY_LEVEL_RO}" required="${form_DELIVERY_LEVEL_R}" placeHolder="" />
                </e:field>
                <e:label for="REG_REQ_INFO" title="${form_REG_REQ_INFO_N}" />
                <e:field>
                    <e:inputText id="REG_REQ_INFO" name="REG_REQ_INFO" value="${formData.REG_REQ_INFO}" width="${form_REG_REQ_INFO_W}" maxLength="${form_REG_REQ_INFO_M}" disabled="${form_REG_REQ_INFO_D}" readOnly="${form_REG_REQ_INFO_RO}" required="${form_REG_REQ_INFO_R}" />
                </e:field>
                <e:label for="IOS_TYPE" title="${form_IOS_TYPE_N}"/>
                <e:field>
                    <e:select id="IOS_TYPE" name="IOS_TYPE" value="${formData.IOS_TYPE}" options="${iosTypeOptions}" width="${form_IOS_TYPE_W}" disabled="${form_IOS_TYPE_D}" readOnly="${form_IOS_TYPE_RO}" required="${form_IOS_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REGION_CD" title="${form_REGION_CD_N}"/>
                <e:field colSpan="3" >
                    <e:checkGroup id="REGION_CD" name="REGION_CD" value="${formData.REGION_CD}" width="100%" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" required="${form_REGION_CD_R}">
                        <c:forEach var="item" items="${regionCd}" varStatus="vs">
                            <e:check id="REGION_CD_${item.value}" name="REGION_CD_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
                <e:label for="TAX_TYPE" title="${form_TAX_TYPE_N}"/>
                <e:field>
                    <e:select id="TAX_TYPE" name="TAX_TYPE" value="${formData.TAX_TYPE}" options="${taxTypeOptions}" width="${form_TAX_TYPE_W}" disabled="${form_TAX_TYPE_D}" readOnly="${form_TAX_TYPE_RO}" required="${form_TAX_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAJOR_CUSTOMERS" title="${form_MAJOR_CUSTOMERS_N}" />
                <e:field>
                    <e:inputText id="MAJOR_CUSTOMERS" name="MAJOR_CUSTOMERS" value="${formData.MAJOR_CUSTOMERS}" width="${form_MAJOR_CUSTOMERS_W}" maxLength="${form_MAJOR_CUSTOMERS_M}" disabled="${form_MAJOR_CUSTOMERS_D}" readOnly="${form_MAJOR_CUSTOMERS_RO}" required="${form_MAJOR_CUSTOMERS_R}" />
                </e:field>
                <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
                <e:field>
                    <e:inputText id="MAKER_NM" name="MAKER_NM" value="${formData.MAKER_NM}" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
                </e:field>
                <e:label for="MAJOR_ITEM_NM" title="${form_MAJOR_ITEM_NM_N}" />
                <e:field>
                    <e:inputText id="MAJOR_ITEM_NM" name="MAJOR_ITEM_NM" value="${formData.MAJOR_ITEM_NM}" width="${form_MAJOR_ITEM_NM_W}" maxLength="${form_MAJOR_ITEM_NM_M}" disabled="${form_MAJOR_ITEM_NM_D}" readOnly="${form_MAJOR_ITEM_NM_RO}" required="${form_MAJOR_ITEM_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="C_MANAGER_USER_ID" title="${form_C_MANAGER_USER_ID_N}"/>
                <e:field>
                    <e:select id="C_MANAGER_USER_ID" name="C_MANAGER_USER_ID" value="${formData.C_MANAGER_USER_ID}" options="${bacpUserOptions}" width="${form_C_MANAGER_USER_ID_W}" disabled="${form_C_MANAGER_USER_ID_D}" readOnly="${form_C_MANAGER_USER_ID_RO}" required="${form_C_MANAGER_USER_ID_R}" placeHolder="" />
                </e:field>
                <e:label for="ACCOUNT_USER_ID" title="${form_ACCOUNT_USER_ID_N}"/>
                <e:field>
                    <e:select id="ACCOUNT_USER_ID" name="ACCOUNT_USER_ID" value="${formData.ACCOUNT_USER_ID}" options="${bacpUserOptions}" width="${form_ACCOUNT_USER_ID_W}" disabled="${form_ACCOUNT_USER_ID_D}" readOnly="${form_ACCOUNT_USER_ID_RO}" required="${form_ACCOUNT_USER_ID_R}" placeHolder="" />
                </e:field>
                <%--<e:label for="DEAL_TYPE" title="${form_DEAL_TYPE_N}"/>--%>
                <%--<e:field>--%>
                    <%--<e:checkGroup id="DEAL_TYPE" name="DEAL_TYPE" value="${formData.DEAL_TYPE}" width="100%" disabled="${form_DEAL_TYPE_D}" readOnly="${form_DEAL_TYPE_RO}" required="${form_DEAL_TYPE_R}">--%>
                        <%--<c:forEach var="deal" items="${dealType}" varStatus="vs">--%>
                            <%--<e:check id="DEAL_TYPE_${deal.value}" name="DEAL_TYPE_${deal.value}" value="${deal.value}" label="${deal.text}" disabled="${form_DEAL_TYPE_D}" readOnly="${form_DEAL_TYPE_RO}" />--%>
                            <%--<c:if test="${(vs.index+1) % 9 == 0}">--%>
                                <%--<e:br/>--%>
                            <%--</c:if>--%>
                        <%--</c:forEach>--%>
                    <%--</e:checkGroup>--%>
                <%--</e:field>--%>
                <e:label for="GROUP_YN" title="${form_GROUP_YN_N}"/>
                <e:field>
                    <e:select id="GROUP_YN" name="GROUP_YN" value="${formData.GROUP_YN}" options="${groupYnOptions}" width="${form_GROUP_YN_W}" disabled="${form_GROUP_YN_D}" readOnly="${form_GROUP_YN_RO}" required="${form_GROUP_YN_R}" placeHolder="" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="E_BILL_ASP_TYPE" title="${form_E_BILL_ASP_TYPE_N}"/>
                <e:field>
                    <e:select id="E_BILL_ASP_TYPE" name="E_BILL_ASP_TYPE" value="${formData.E_BILL_ASP_TYPE}" options="${eBillAspTypeOptions}" width="${form_E_BILL_ASP_TYPE_W}" disabled="${form_E_BILL_ASP_TYPE_D}" readOnly="${form_E_BILL_ASP_TYPE_RO}" required="${form_E_BILL_ASP_TYPE_R}" placeHolder=""  />
                </e:field>
                <e:label for="TAX_ASP_NM" title="${form_TAX_ASP_NM_N}" />
                <e:field>
                    <e:inputText id="TAX_ASP_NM" name="TAX_ASP_NM" value="${formData.TAX_ASP_NM}" width="${form_TAX_ASP_NM_W}" maxLength="${form_TAX_ASP_NM_M}" disabled="${form_TAX_ASP_NM_D}" readOnly="${form_TAX_ASP_NM_RO}" required="${form_TAX_ASP_NM_R}" />
                </e:field>
                <e:label for="TAX_SEND_TYPE" title="${form_TAX_SEND_TYPE_N}"/>
                <e:field>
                    <e:select id="TAX_SEND_TYPE" name="TAX_SEND_TYPE" value="${formData.TAX_SEND_TYPE}" options="${taxSendTypeOptions}" width="${form_TAX_SEND_TYPE_W}" disabled="${form_TAX_SEND_TYPE_D}" readOnly="${form_TAX_SEND_TYPE_RO}" required="${form_TAX_SEND_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="BUSINESS_REMARK" title="${form_BUSINESS_REMARK_N}" />
                <e:field colSpan="5">
                    <e:textArea id="BUSINESS_REMARK" name="BUSINESS_REMARK" height="60" value="${formData.BUSINESS_REMARK }" width="${form_BUSINESS_REMARK_W}" maxLength="${form_BUSINESS_REMARK_M}" disabled="${form_BUSINESS_REMARK_D}" readOnly="${form_BUSINESS_REMARK_RO}" required="${form_BUSINESS_REMARK_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAJOR_PERFORM" title="${form_MAJOR_PERFORM_N}" />
                <e:field colSpan="5">
                    <e:inputText id="MAJOR_PERFORM" name="MAJOR_PERFORM" value="${formData.MAJOR_PERFORM}" width="${form_MAJOR_PERFORM_W}" maxLength="${form_MAJOR_PERFORM_M}" disabled="${form_MAJOR_PERFORM_D}" readOnly="${form_MAJOR_PERFORM_RO}" required="${form_MAJOR_PERFORM_R}" />
                </e:field>
            </e:row>
            <e:label for="MAJOR_PERFORM1" title="${form_MAJOR_PERFORM1_N}" />
            <e:field colSpan="5">
                <e:inputText id="MAJOR_PERFORM1" name="MAJOR_PERFORM1" value="${formData.MAJOR_PERFORM1}" width="${form_MAJOR_PERFORM1_W}" maxLength="${form_MAJOR_PERFORM1_M}" disabled="${form_MAJOR_PERFORM1_D}" readOnly="${form_MAJOR_PERFORM1_RO}" required="${form_MAJOR_PERFORM1_R}" />
            </e:field>
            <e:row>
                <e:label for="MAJOR_PERFORM2" title="${form_MAJOR_PERFORM2_N}" />
                <e:field colSpan="5">
                    <e:inputText id="MAJOR_PERFORM2" name="MAJOR_PERFORM2" value="${formData.MAJOR_PERFORM2}" width="${form_MAJOR_PERFORM2_W}" maxLength="${form_MAJOR_PERFORM2_M}" disabled="${form_MAJOR_PERFORM2_D}" readOnly="${form_MAJOR_PERFORM2_RO}" required="${form_MAJOR_PERFORM2_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAJOR_PERFORM3" title="${form_MAJOR_PERFORM3_N}" />
                <e:field colSpan="5">
                    <e:inputText id="MAJOR_PERFORM3" name="MAJOR_PERFORM3" value="${formData.MAJOR_PERFORM3}" width="${form_MAJOR_PERFORM3_W}" maxLength="${form_MAJOR_PERFORM3_M}" disabled="${form_MAJOR_PERFORM3_D}" readOnly="${form_MAJOR_PERFORM3_RO}" required="${form_MAJOR_PERFORM3_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAJOR_PERFORM4" title="${form_MAJOR_PERFORM4_N}" />
                <e:field colSpan="5">
                    <e:inputText id="MAJOR_PERFORM4" name="MAJOR_PERFORM4" value="${formData.MAJOR_PERFORM4}" width="${form_MAJOR_PERFORM4_W}" maxLength="${form_MAJOR_PERFORM4_M}" disabled="${form_MAJOR_PERFORM4_D}" readOnly="${form_MAJOR_PERFORM4_RO}" required="${form_MAJOR_PERFORM4_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REMARK_TEXT" title="${form_REMARK_TEXT_N}" />
                <e:field colSpan="5">
                    <e:textArea id="REMARK_TEXT" name="REMARK_TEXT" height="60" value="${formData.REMARK_TEXT }" width="${form_REMARK_TEXT_W}" maxLength="${form_REMARK_TEXT_M}" disabled="${form_REMARK_TEXT_D}" readOnly="${form_REMARK_TEXT_RO}" required="${form_REMARK_TEXT_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ACCOUNT_M_NUM" title="${form_ACCOUNT_M_NUM_N}" />
                <e:field>
                    <e:inputText id="ACCOUNT_M_NUM" name="ACCOUNT_M_NUM" value="${formData.ACCOUNT_M_NUM}" width="${form_ACCOUNT_M_NUM_W}" maxLength="${form_ACCOUNT_M_NUM_M}" disabled="${form_ACCOUNT_M_NUM_D}" readOnly="${form_ACCOUNT_M_NUM_RO}" required="${form_ACCOUNT_M_NUM_R}" />
                </e:field>
                <e:label for="PROGRESS_NM" title="${form_PROGRESS_NM_N}" />
                <e:field>
                    <e:inputText id="PROGRESS_NM" name="PROGRESS_NM" value="${formData.PROGRESS_NM}" width="${form_PROGRESS_NM_W}" maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}" />
                </e:field>
                <%--<e:label for="BLOCK_FLAG" title="${form_BLOCK_FLAG_N}"/>--%>
                <%--<e:field>--%>
                    <%--<e:select id="BLOCK_FLAG" name="BLOCK_FLAG" value="${formData.BLOCK_FLAG}" options="${blockFlagOptions}" width="${form_BLOCK_FLAG_W}" disabled="${form_BLOCK_FLAG_D}" readOnly="${form_BLOCK_FLAG_RO}" required="${form_BLOCK_FLAG_R}" placeHolder="" />--%>
                <%--</e:field>--%>



                <e:inputHidden id="BLOCK_FLAG" name="BLOCK_FLAG" value="${formData.BLOCK_FLAG }" />
                <e:inputHidden id="BLOCK_REASON" name="BLOCK_REASON" value="${formData.BLOCK_REASON }" />
                <e:label for="MOD_INFO" title="${form_MOD_INFO_N}" />
                <e:field>
                    <e:inputText id="MOD_INFO" name="MOD_INFO" value="${formData.MOD_INFO}" width="${form_MOD_INFO_W}" maxLength="${form_MOD_INFO_M}" disabled="${form_MOD_INFO_D}" readOnly="${form_MOD_INFO_RO}" required="${form_MOD_INFO_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
            <e:buttonBar id="SGbuttonBar" align="right" width="100%" title="${SMY1_060_CAPTION3}">
                <e:button id="SGSelect" name="SGSelect" label="${SGSelect_N }" disabled="${SGSelect_D }" visible="${SGSelect_V}" onClick="doSGSelect"/>
                <e:button id="SGDelete" name="SGDelete" label="${SGDelete_N }" disabled="${SGDelete_D }" visible="${SGDelete_V}" onClick="doSGDelete"/>
            </e:buttonBar>
            <e:gridPanel id="grid1" name="grid1" width="100%" height="95px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}"/>

        <%--
        <e:panel id="SGPanelC" height="150px" width="1%">&nbsp;</e:panel>
        <e:panel id="SGPanelR" height="150px" width="54%">
            <e:panel id="vf1" height="25px" width="40%">
                <e:title title="${SMY1_060_CAPTION4}" depth="1" />
            </e:panel>
            <e:panel id="vf2" height="25px" width="60%">
                <e:text style="float:right">
                    ${SMY1_060_TEXT2}
                </e:text>
            </e:panel>
            <e:searchPanel id="form2" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
                <e:row>
                    <e:label for="FI_YEAR" title="${form_FI_YEAR_N}" />
                    <e:field>
                        <e:select id="FI_YEAR" name="FI_YEAR" value="${formData.FI_YEAR}" options="${fiYearOptions}" width="${form_FI_YEAR_W}" disabled="${form_FI_YEAR_D}" readOnly="${form_FI_YEAR_RO}" required="${form_FI_YEAR_R}" placeHolder="" />
                    </e:field>
                    <e:label for="EVIDENCE_TYPE" title="${form_EVIDENCE_TYPE_N}"/>
                    <e:field>
                        <e:select id="EVIDENCE_TYPE" name="EVIDENCE_TYPE" value="${formData.EVIDENCE_TYPE}" options="${evidenceTypeOptions}" width="${form_EVIDENCE_TYPE_W}" disabled="${form_EVIDENCE_TYPE_D}" readOnly="${form_EVIDENCE_TYPE_RO}" required="${form_EVIDENCE_TYPE_R}" placeHolder="" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="TOT_CAP_AMT" title="${form_TOT_CAP_AMT_N}"/>
                    <e:field>
                        <e:inputNumber id="TOT_CAP_AMT" name="TOT_CAP_AMT" value="${formData.TOT_CAP_AMT}" width="${form_TOT_CAP_AMT_W}" maxValue="${form_TOT_CAP_AMT_M}" decimalPlace="${form_TOT_CAP_AMT_NF}" disabled="${form_TOT_CAP_AMT_D}" readOnly="${form_TOT_CAP_AMT_RO}" required="${form_TOT_CAP_AMT_R}" />
                    </e:field>
                    <e:label for="TOT_LIAB_AMT" title="${form_TOT_LIAB_AMT_N}"/>
                    <e:field>
                        <e:inputNumber id="TOT_LIAB_AMT" name="TOT_LIAB_AMT" value="${formData.TOT_LIAB_AMT}" width="${form_TOT_LIAB_AMT_W}" maxValue="${form_TOT_LIAB_AMT_M}" decimalPlace="${form_TOT_LIAB_AMT_NF}" disabled="${form_TOT_LIAB_AMT_D}" readOnly="${form_TOT_LIAB_AMT_RO}" required="${form_TOT_LIAB_AMT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="TOT_FUND_AMT" title="${form_TOT_FUND_AMT_N}"/>
                    <e:field>
                        <e:inputNumber id="TOT_FUND_AMT" name="TOT_FUND_AMT" value="${formData.TOT_FUND_AMT}" width="${form_TOT_FUND_AMT_W}" maxValue="${form_TOT_FUND_AMT_M}" decimalPlace="${form_TOT_FUND_AMT_NF}" disabled="${form_TOT_FUND_AMT_D}" readOnly="${form_TOT_FUND_AMT_RO}" required="${form_TOT_FUND_AMT_R}" />
                    </e:field>
                    <e:label for="SALES_AMT" title="${form_SALES_AMT_N}"/>
                    <e:field>
                        <e:inputNumber id="SALES_AMT" name="SALES_AMT" value="${formData.SALES_AMT}" width="${form_SALES_AMT_W}" maxValue="${form_SALES_AMT_M}" decimalPlace="${form_SALES_AMT_NF}" disabled="${form_SALES_AMT_D}" readOnly="${form_SALES_AMT_RO}" required="${form_SALES_AMT_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="SALES_PROF_AMT" title="${form_SALES_PROF_AMT_N}"/>
                    <e:field>
                        <e:inputNumber id="SALES_PROF_AMT" name="SALES_PROF_AMT" value="${formData.SALES_PROF_AMT}" width="${form_SALES_PROF_AMT_W}" maxValue="${form_SALES_PROF_AMT_M}" decimalPlace="${form_SALES_PROF_AMT_NF}" disabled="${form_SALES_PROF_AMT_D}" readOnly="${form_SALES_PROF_AMT_RO}" required="${form_SALES_PROF_AMT_R}" />
                    </e:field>
                    <e:label for="ORI_SALES_AMT" title="${form_ORI_SALES_AMT_N}"/>
                    <e:field>
                        <e:inputNumber id="ORI_SALES_AMT" name="ORI_SALES_AMT" value="${formData.ORI_SALES_AMT}" width="${form_ORI_SALES_AMT_W}" maxValue="${form_ORI_SALES_AMT_M}" decimalPlace="${form_ORI_SALES_AMT_NF}" disabled="${form_ORI_SALES_AMT_D}" readOnly="${form_ORI_SALES_AMT_RO}" required="${form_ORI_SALES_AMT_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>
        </e:panel>
        --%>
        <%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
        <e:panel id="fileP1" height="30px" width="40%">
            <e:title title="${SMY1_060_CAPTION5}" depth="1" />
        </e:panel>
            <e:buttonBar id="FIbuttonBar" align="right" width="100%">
                <e:button id="TempletDown" name="TempletDown" label="${TempletDown_N }" disabled="${TempletDown_D }" visible="${TempletDown_V}" onClick="doTempletDown"/>
            </e:buttonBar>
        <e:searchPanel id="form3" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="BIZ_ATT_FILE_NUM" title="${form_BIZ_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="BIZ_ATT_FILE_NUM" name="BIZ_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.BIZ_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_BIZ_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                <e:label for="ID_ATT_FILE_NUM" title="${form_ID_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="ID_ATT_FILE_NUM" name="ID_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.ID_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_ID_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PRICE_ATT_FILE_NUM" title="${form_PRICE_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="PRICE_ATT_FILE_NUM" name="PRICE_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.PRICE_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_PRICE_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                <e:label for="BANKBOOK_ATT_FILE_NUM" title="${form_BANKBOOK_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="BANKBOOK_ATT_FILE_NUM" name="BANKBOOK_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.BANKBOOK_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_BANKBOOK_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CERTIFI_ATT_FILE_NUM" title="${form_CERTIFI_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="CERTIFI_ATT_FILE_NUM" name="CERTIFI_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.BANKBOOK_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_CERTIFI_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
                <e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATTACH_FILE_NO_R}" />
                    </div>
                </e:field>
            </e:row>
            <%--<e:row>
                <e:label for="PRIVATE_ATT_FILE_NUM" title="${form_PRIVATE_ATT_FILE_NUM_N}" />
                <e:field>
                    <div style="width: 100%; height: 80px;">
                        <e:fileManager id="PRIVATE_ATT_FILE_NUM" name="PRIVATE_ATT_FILE_NUM" readOnly="${param.detailView == 'true' ? true : false}" fileId="${formData.PRIVATE_ATT_FILE_NUM}" downloadable="true" width="100%" bizType="VENDOR" height="40px" onBeforeRemove="onBeforeRemove" onError="onError" onFileAdd="onFileAdd" onFileClick="onFileClick" maxFileCount="1" onSuccess="onSuccess" required="${form_PRIVATE_ATT_FILE_NUM_R}" />
                    </div>
                </e:field>
            </e:row>--%>
        </e:searchPanel>
        <%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>
        <e:panel id="payP1" height="25px" width="100%">
            <e:title title="${SMY1_060_CAPTION6}" depth="1" />
        </e:panel>
        <e:searchPanel id="form4" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>
                <e:label for="PAY_BANK_CD" title="${form_PAY_BANK_CD_N}"/>
                <e:field>
                    <e:select id="PAY_BANK_CD" name="PAY_BANK_CD" value="${formData.PAY_BANK_CD}" options="${payBankCdOptions}" width="${form_PAY_BANK_CD_W}" disabled="${form_PAY_BANK_CD_D}" readOnly="${form_PAY_BANK_CD_RO}" required="${form_PAY_BANK_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="PAY_ACCOUNT_NO" title="${form_PAY_ACCOUNT_NO_N}" />
                <e:field>
                    <e:inputText id="PAY_ACCOUNT_NO" name="PAY_ACCOUNT_NO" value="${formData.PAY_ACCOUNT_NO}" width="${form_PAY_ACCOUNT_NO_W}" maxLength="${form_PAY_ACCOUNT_NO_M}" disabled="${form_PAY_ACCOUNT_NO_D}" readOnly="${form_PAY_ACCOUNT_NO_RO}" required="${form_PAY_ACCOUNT_NO_R}" />
                </e:field>
                <e:label for="PAY_ACCOUNT_USER_NM" title="${form_PAY_ACCOUNT_USER_NM_N}" />
                <e:field>
                    <e:inputText id="PAY_ACCOUNT_USER_NM" name="PAY_ACCOUNT_USER_NM" value="${formData.PAY_ACCOUNT_USER_NM}" width="${form_PAY_ACCOUNT_USER_NM_W}" maxLength="${form_PAY_ACCOUNT_USER_NM_M}" disabled="${form_PAY_ACCOUNT_USER_NM_D}" readOnly="${form_PAY_ACCOUNT_USER_NM_RO}" required="${form_PAY_ACCOUNT_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PAY_CONDITION" title="${form_PAY_CONDITION_N}"/>
                <e:field>
                    <e:select id="PAY_CONDITION" name="PAY_CONDITION" value="${formData.PAY_CONDITION}" options="${payConditionOptions}" width="${form_PAY_CONDITION_W}" disabled="${form_PAY_CONDITION_D}" readOnly="${form_PAY_CONDITION_RO}" required="${form_PAY_CONDITION_R}" placeHolder="" />
                </e:field>
                <e:label for="PAY_DAY" title="${form_PAY_DAY_N}"/>
                <e:field colSpan="3">
                    <e:inputNumber id="PAY_DAY" name="PAY_DAY" value="${formData.PAY_DAY}" width="50" maxValue="${form_PAY_DAY_M}" decimalPlace="${form_PAY_DAY_NF}" disabled="${form_PAY_DAY_D}" readOnly="${form_PAY_DAY_RO}" required="${form_PAY_DAY_R}" />
                    <e:text>${SMY1_060_TEXT3 }</e:text>
                </e:field>
            </e:row>
        </e:searchPanel>
        <%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%>

        <e:panel id="userP1" height="25px" width="40%">
            <e:title title="${SMY1_060_CAPTION2}" depth="1" />
        </e:panel>
        <e:searchPanel id="form5" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
            <e:row>
                <e:label for="USER_ID" title="${form_USER_ID_N}"/>
                <e:field>
                    <e:inputText id="USER_ID" name="USER_ID" value="${formData.USER_ID }" width="70%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" onChange="onChangeID" />
                    &nbsp;<e:button id="Idcheck" name="Idcheck" label="${Idcheck_N}" onClick="doIdcheck" disabled="${Idcheck_D}" visible="${Idcheck_V}" />
                    <e:inputHidden id="ID_CHECK" name="ID_CHECK" value="${formData.ID_CHECK }" />
                    <e:inputHidden id="ORI_USER_ID" name="ORI_USER_ID" value="${formData.USER_ID }" />
                    <e:inputHidden id="MNG_YN" name="MNG_YN" value="${formData.MNG_YN }" />
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="USER_NM" name="USER_NM" value="${formData.USER_NM }" width="${form_USER_NM_W}" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" style="${imeMode}"/>
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
                <e:field>
                    <e:inputText id="DEPT_NM" name="DEPT_NM" value="${formData.DEPT_NM}" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PASSWORD" title="${form_PASSWORD_N}"></e:label>
                <e:field>
                    <e:inputPassword id="PASSWORD" style='ime-mode:inactive' name="PASSWORD" value="${formData.PASSWORD}"  width="100%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}" onChange="CheckCall" data="1" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                    <e:inputHidden id="CHANGE_PW" name="CHANGE_PW" value="" />
                </e:field>
                <e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N}"></e:label>
                <e:field>
                    <e:inputPassword id="PASSWORD_CHECK" style='ime-mode:inactive' name="PASSWORD_CHECK" value="${formData.PASSWORD_CHECK}"  width="100%" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" onChange="CheckCall" data="2" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                </e:field>
                <e:label for="POSITION_NM" title="${form_POSITION_NM_N}"/>
                <e:field>
                    <e:inputText id="POSITION_NM" name="POSITION_NM" value="${formData.POSITION_NM }" width="${form_POSITION_NM_W}" maxLength="${form_POSITION_NM_M}" disabled="${form_POSITION_NM_D}" readOnly="${form_POSITION_NM_RO}" required="${form_POSITION_NM_R}" style="${imeMode}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="CELL_NUM" name="CELL_NUM"  placeHolder="${SMY1_060_INPUT_T2 }" value="${formData.CELL_NUM}" width="100%" maxLength="${form_CELL_NUM_M}" disabled="${form_CELL_NUM_D}" readOnly="${form_CELL_NUM_RO}" required="${form_CELL_NUM_R}" onChange="checkCellNo" data="CELL_NUM" />
                </e:field>
                <e:label for="USER_EMAIL" title="${form_USER_EMAIL_N}"></e:label>
                <e:field>
                    <e:inputText id="USER_EMAIL" name="USER_EMAIL" style='ime-mode:inactive' value="${formData.USER_EMAIL}" width="100%" maxLength="${form_USER_EMAIL_M}" disabled="${form_USER_EMAIL_D}" readOnly="${form_USER_EMAIL_RO}" required="${form_USER_EMAIL_R}" onChange="checkEmail2"/>
                </e:field>
                <e:label for="DUTY_NM" title="${form_DUTY_NM_N}"/>
				<e:field>
					<e:inputText id="DUTY_NM" name="DUTY_NM" value="${formData.DUTY_NM}" width="${form_DUTY_NM_W}" maxLength="${form_DUTY_NM_M}" disabled="${form_DUTY_NM_D}" readOnly="${form_DUTY_NM_RO}" required="${form_DUTY_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="SMS_FLAG" title="${form_SMS_FLAG_N}" />
                <e:field>
                    <e:select id="SMS_FLAG" name="SMS_FLAG" value="${formData.SMS_FLAG }" options="${smsFlagOptions }" width="${form_SMS_FLAG_W}" disabled="${form_SMS_FLAG_D}" readOnly="${form_SMS_FLAG_RO}" required="${form_SMS_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="MAIL_FLAG" title="${form_MAIL_FLAG_N}" />
                <e:field>
                    <e:select id="MAIL_FLAG" name="MAIL_FLAG" value="${formData.MAIL_FLAG }" options="${smsFlagOptions }" width="${form_MAIL_FLAG_W}" disabled="${form_MAIL_FLAG_D}" readOnly="${form_MAIL_FLAG_RO}" required="${form_MAIL_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="TEL_NUM" name="TEL_NUM"  placeHolder="${SMY1_060_INPUT_T2 }" value="${formData.TEL_NUM}" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" onChange="checkTelNo" data="TEL_NUM" />
                </e:field>
            </e:row>
            <e:row>

                <e:label for="VNGL_ROLE" title="${form_VNGL_ROLE_N}"/>
                <e:field>
                    <e:checkGroup id="VNGL_ROLE" name="VNGL_ROLE" value="${formData.VNGL_ROLE}" width="100%" disabled="${form_VNGL_ROLE_D}" readOnly="${form_VNGL_ROLE_RO}" required="${form_VNGL_ROLE_R}">
                        <c:forEach var="role" items="${RoleList}" varStatus="vs">
                            <e:check id="VNGL_ROLE_${role.value}" name="VNGL_ROLE_${role.value}" value="${role.value}" label="${role.text}" disabled="${form_VNGL_ROLE_D}" readOnly="${form_VNGL_ROLE_RO}" />
                            <c:if test="${(vs.index+1) % 9 == 0}">
                                <e:br/>
                            </c:if>
                        </c:forEach>
                    </e:checkGroup>
                </e:field>
                <e:label for="AGREE_YN" title="${form_AGREE_YN_N}"/>
				<e:field>
					<e:inputText id="AGREE_YN" name="AGREE_YN" value="${formData.AGREE_YN}" width="${form_AGREE_YN_W}" maxLength="${form_AGREE_YN_M}" disabled="${form_AGREE_YN_D}" readOnly="${form_AGREE_YN_RO}" required="${form_AGREE_YN_R}" />
				</e:field>
				<e:label for="FAX_NUM" title="${form_FAX_NUM_N}"></e:label>
                <e:field>
                    <e:inputText id="FAX_NUM" name="FAX_NUM" placeHolder="${SMY1_060_INPUT_T2 }" value="${formData.FAX_NUM}" width="100%" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" onChange="checkTelNo" data="FAX_NUM" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:panel id="leftP7" height="25px" width="40%">
            <e:title title="${SMY1_060_CAPTION9}" depth="1" />
        </e:panel>
            <e:buttonBar id="buttonBar7" align="right" width="100%">
                <e:button id="deleteTx" name="deleteTx" label="${deleteTx_N}" onClick="dodeleteTx" disabled="${deleteTx_D}" visible="${deleteTx_V}"/>
            </e:buttonBar>
        <e:gridPanel id="gridVncp" name="gridVncp" width="100%" height="160px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridVncp.gridColData}"/>
        <div style="display: none">
            <e:gridPanel gridType="${_gridType}" id="gridtx" name="gridtx" width="100%" height="160px" readOnly="${param.detailView}" columnDef="${gridInfos.gridtx.gridColData}"/>
        </div>

    </e:window>
</e:ui>