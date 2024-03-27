<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var baseUrl = "/evermp/IM03/IM0301/";
    var gridat;

	function init(){
        gridat = EVF.C("gridat");

        var editor = EVF.C('MTGL_TEXT_CONTENTS').getInstance();
        editor.config.contentsCss  = "/css/richText.css";
        editor.config.allowedContent = true;

        _setImages();
        _setImages2();
        doSearchAT();
        if("${DATA.CMS_ORIGIN_CD}"==""){
            EVF.C("MTGL_ORIGIN_CD").setValue("KR");
        }



        if("${DATA.ITEM_CD}"==""){
            EVF.C("MTGL_ITEM_RMK").setValue(EVF.C("RFQ_REQ_TXT").getValue());
        }


	}

	function doSave() {
        var store = new EVF.Store();
        if(!store.validate()) { return; }
        if(!confirm("${msg.M0021}")) { return; }

        store.setGrid([gridat]);
        store.getGridData(gridat, "all");
        if(store.doFileUpload(function() {
                store.setParameter("mainImgSq", $("#mainImgContainer").find("input[type=radio]:checked").prop("id"));

                store.load(baseUrl + "im03015_doSave", function() {
                    alert(this.getResponseMessage());
                    opener.doSearch();
                    window.close();
                });
            }));
    }

	function doCopy() {
        EVF.V("MTGL_ITEM_NM", EVF.V("ITEM_NM"));
        EVF.V("MTGL_UNIT_CD", EVF.V("UNIT_CD"));
		EVF.V("MTGL_ORIGIN_CD",EVF.V("ORIGIN_NM"));
        if(EVF.V("CMS_MAKER_CD") !== "") {
            EVF.V("MTGL_MAKER_CD", EVF.V("CMS_MAKER_CD"));
            EVF.V("MTGL_MAKER_NM", EVF.V("CMS_MAKER_NM"));
        } else {
            EVF.V("MTGL_MAKER_CD", "");
            EVF.V("MTGL_MAKER_NM", EVF.V("MAKER_NM"));
        }
    }

	function doClear() {
        EVF.V("MTGL_ITEM_CLS_NM", "");
        EVF.V("MTGL_ITEM_CLS1", "");
        EVF.V("MTGL_ITEM_CLS2", "");
        EVF.V("MTGL_ITEM_CLS3", "");
        EVF.V("MTGL_ITEM_CLS4", "");
        EVF.V("MTGL_SG_CTRL_USER_ID", "");
        EVF.V("MTGL_ITEM_NM", "");
        EVF.V("MTGL_CMS_CTRL_USER_ID", "");
        EVF.V("MTGL_ITEM_SPEC", "");
        EVF.V("MTGL_ITEM_KIND_CD", "");
        EVF.V("MTGL_MAKER_NM", "");
        EVF.V("MTGL_MAKER_CD", "");
        EVF.V("MTGL_MAKER_PART_NO", "");
        EVF.V("MTGL_BRAND_CD", "");
        EVF.V("MTGL_ORIGIN_CD", "");
        EVF.V("MTGL_UNIT_CD", "");
        EVF.V("MTGL_VAT_CD", "T1");
        EVF.V("MTGL_CMS_REMARK", "");
    }

    function doSearchAT() {
        if(${not empty DATA.ITEM_CD}) {
            var store = new EVF.Store();
            store.setGrid([gridat]);
            store.load(baseUrl + 'im03009_doSearch_AT', function () {

            });
        }
    }

	function searchMTGL_ITEM_CLS_NM() {
        var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
        var param = {
            callBackFunction : "callbackITEM_CLS_NM",
            'detailView': false,
            'multiYN' : false,
            'ModalPopup' : true,
            'searchYN' : true,
            'custCd' : '${ses.companyCd}',  // 고객사코드or회사코드
            'custNm' : '${ses.companyNm}'  // 고객사코드or회사코드
        };
        everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
    }

    function callbackITEM_CLS_NM(data) {
        if(data != null) {
            data = JSON.parse(data);
            EVF.C("MTGL_ITEM_CLS1").setValue(data.ITEM_CLS1);
            if(data.ITEM_CLS2 == "*") {EVF.C("MTGL_ITEM_CLS2").setValue("*");} else {EVF.C("MTGL_ITEM_CLS2").setValue(data.ITEM_CLS2);}
            if(data.ITEM_CLS3 == "*") {EVF.C("MTGL_ITEM_CLS3").setValue("*");} else {EVF.C("MTGL_ITEM_CLS3").setValue(data.ITEM_CLS3);}
            if(data.ITEM_CLS4 == "*") {EVF.C("MTGL_ITEM_CLS4").setValue("*");} else {EVF.C("MTGL_ITEM_CLS4").setValue(data.ITEM_CLS4);}
            EVF.C("MTGL_ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
//             EVF.C("MTGL_SG_CTRL_USER_ID").setValue(data.SG_CTRL_USER_ID);
        } else {
            EVF.C("MTGL_ITEM_CLS1").setValue("");
            EVF.C("MTGL_ITEM_CLS2").setValue("");
            EVF.C("MTGL_ITEM_CLS3").setValue("");
            EVF.C("MTGL_ITEM_CLS4").setValue("");
            EVF.C("MTGL_ITEM_CLS_NM").setValue("");
//             EVF.C("MTGL_SG_CTRL_USER_ID").setValue("");
        }
    }

    function searchMTGL_ITEM_SPEC() {
        if(EVF.V("MTGL_ITEM_CLS_NM") == "") {
            EVF.C("MTGL_ITEM_CLS_NM").setFocus();
            alert("${IM03_015_001}");
            return;
        }

        var selectedATData;
        var rowIds = gridat.getAllRowId();
        for (var i in rowIds) {
            if(i>0){
                selectedATData = selectedATData + "@" + gridat.getCellValue(rowIds[i], "ATTR_CD") + "|" + gridat.getCellValue(rowIds[i], "ATTR_VALUE");
            }else{
                selectedATData = gridat.getCellValue(rowIds[i], "ATTR_CD") + "|" + gridat.getCellValue(rowIds[i], "ATTR_VALUE");
            }

        }

        var param = {
            callBackFunction: "callbackMTGL_ITEM_SPEC",
            ITEM_CLS1: EVF.V("MTGL_ITEM_CLS1"),
            ITEM_CLS2: EVF.V("MTGL_ITEM_CLS2"),
            ITEM_CLS3: EVF.V("MTGL_ITEM_CLS3"),
            ITEM_CLS4: EVF.V("MTGL_ITEM_CLS4"),
            AT_DATA: selectedATData,
            detailView: false
        };
        everPopup.im03_011open(param);
    }

    function callbackMTGL_ITEM_SPEC(data){
        var itemSpecNm = "";

        gridat.delAllRow();

        for(var idx in data) {

            gridat.addRow();
            gridat.setCellValue(idx, "ATTR_CD", data[idx].ATTR_CD);
            gridat.setCellValue(idx, "ATTR_VALUE", data[idx].ATTR_VALUE);
            gridat.setCellValue(idx, "ATTR_TYPE", "ITEM");

//            if(idx >0){
//                itemSpecNm = itemSpecNm + ", " + data[idx].CODE_NM + ":" + data[idx].ATTR_VALUE;
//            }else{
//                itemSpecNm = data[idx].CODE_NM + ":" + data[idx].ATTR_VALUE;
//            }

            if(idx >0){
                itemSpecNm = itemSpecNm + "; " + data[idx].ATTR_VALUE;
            }else{
                itemSpecNm = data[idx].ATTR_VALUE;
            }
        }
        EVF.V("MTGL_ITEM_SPEC", itemSpecNm);
    }

    function searchMTGL_MAKER_NM() {
        var param = {
            callBackFunction: "callbackMTGL_MAKER_NM",
            MKBR_NM: EVF.V("MTGL_MAKER_NM")
        };
        everPopup.openCommonPopup(param, 'SP0068');
    }

    function callbackMTGL_MAKER_NM(data) {
        EVF.V("MTGL_MAKER_CD", data.MKBR_CD);
        EVF.V("MTGL_MAKER_NM", data.MKBR_NM);
    }

    function onChangeMTGL_MAKER_NM() {
        EVF.V("MTGL_MAKER_CD", "");
    }

    function onClearMTGL_MAKER_NM() {
        EVF.V("MTGL_MAKER_CD", "");
    }

    //첨부파일갯수제어-------------------------
    function _doUpload() {
        if(EVF.C("IMG_ATT_FILE_NUM").getFileCount() > 4) {
            return alert("${IM03_015_002}");
        }

        EVF.C("IMG_ATT_FILE_NUM").uploadFile();
    }

    function _setImages() {

        var fileManager = EVF.C("IMG_ATT_FILE_NUM");
        var store = new EVF.Store();

        store.setParameter("fileManagerId", fileManager.getID());
        store.setParameter("bizType", "IMG");
        store.setParameter("fileId", fileManager.getFileId());
        store.load("/common/file/fileAttach/getUploadedFileInfo", function() {

            var mainImgSq = EVF.V("MAIN_IMG_SQ");
            var fileInfoJson = JSON.parse(this.getParameter("fileInfo"));
            $("#mainImgContainer").empty();
            $.each(fileInfoJson, function(i, datum) {
                if(i==0){
                    $itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: 110px; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"><input id="'+datum.UUID_SQ+'" name="itemImage" type="radio" checked="checked"/></div>');
                }else{
                    $itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: 110px; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"><input id="'+datum.UUID_SQ+'" name="itemImage" type="radio" '+(datum.UUID_SQ == mainImgSq ? 'checked="checked"': '')+' /></div>');
                }
                $("#mainImgContainer").append($itemImage);
            });
        });
    }

    //첨부파일갯수제어-------------------------
    function _doUpload2() {
        if(EVF.C('ITEM_DETAIL_FILE_NUM').getFileCount()>1){
            return alert("${IM03_009_014}");
        }

        EVF.C('ITEM_DETAIL_FILE_NUM').uploadFile();
    }
    function _setImages2() {

        var detailFileManager = EVF.C('ITEM_DETAIL_FILE_NUM');
        var store = new EVF.Store();

        store.setParameter('fileManagerId', detailFileManager.getID());
        store.setParameter('bizType', 'IMG');
        store.setParameter('fileId', detailFileManager.getFileId());
        store.load('/common/file/fileAttach/getUploadedFileInfo', function() {

            var fileInfoJson = JSON.parse(this.getParameter('fileInfo'));
            $('#DetailImgContainer').empty();
            $.each(fileInfoJson, function(i, datum) {
                var $itemImage;
                //$itemImage = $('<div style="float: left; padding-right: 10px;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: auto; cursor: pointer; display: block;" onclick="javascript:_setMainImage(this)" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"></div>');
                $itemImage = $('<div style="overflow:scroll; height:180px; text-align:center;"><img data-uuid="'+datum.UUID+'" data-uuid_sq="'+datum.UUID_SQ+'" style="width: auto; height: auto; cursor: pointer;" src="data:image/'+datum.FILE_EXTENSION+';base64,'+datum.BYTE_ARRAY+'"></div>');
                $('#DetailImgContainer').append($itemImage);
            });
        });
    }

    function onError() {
        $('.ui-icon-circle-arrow-w').trigger('click');
    }
 </script>
	<e:window id="IM03_015" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:panel id="leftPanelA" height="fit" width="30%">
            <e:title title="${IM03_015_CAPTION1 }" depth="1"/>
        </e:panel>
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="CMS_MAKER_CD" name="CMS_MAKER_CD" value="${DATA.CMS_MAKER_CD}"/>
            <e:inputHidden id="CMS_MAKER_NM" name="CMS_MAKER_NM" value="${DATA.CMS_MAKER_NM}"/>

            <e:row>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="${DATA.CUST_NM}" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                    <e:inputHidden id="CUST_CD" name="CUST_CD" value="${DATA.CUST_CD}"/>
                </e:field>
                <e:label for="PLANT_NM" title="${form_PLANT_NM_N}" />
                <e:field>
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="${DATA.PLANT_NM}" width="${form_PLANT_NM_W}" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                    <e:inputHidden id="PLANT_CD" name="PLANT_CD" value="${DATA.PLANT_CD}"/>
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
                <e:field>
                    <e:inputText id="DEPT_NM" name="DEPT_NM" value="${DATA.DEPT_NM}" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}" />
                <e:field>
                    <e:inputText id="REQ_USER_NM" name="REQ_USER_NM" value="${DATA.REQ_USER_NM}" width="${form_REQ_USER_NM_W}" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
                    <e:inputHidden id="REQ_USER_ID" name="REQ_USER_ID" value="${DATA.REQ_USER_ID}"/>
                </e:field>
                <e:label for="REQUEST_DATE" title="${form_REQUEST_DATE_N}" />
                <e:field>
                    <e:inputText id="REQUEST_DATE" name="REQUEST_DATE" value="${DATA.REQUEST_DATE}" width="${form_REQUEST_DATE_W}" maxLength="${form_REQUEST_DATE_M}" disabled="${form_REQUEST_DATE_D}" readOnly="${form_REQUEST_DATE_RO}" required="${form_REQUEST_DATE_R}" />
                </e:field>
                <e:label for="ITEM_REQ_NO" title="${form_ITEM_REQ_NO_N}" />
                <e:field>
                    <e:inputText id="ITEM_REQ_NO" name="ITEM_REQ_NO" value="${DATA.ITEM_REQ_NO}" width="${form_ITEM_REQ_NO_W}" maxLength="${form_ITEM_REQ_NO_M}" disabled="${form_ITEM_REQ_NO_D}" readOnly="${form_ITEM_REQ_NO_RO}" required="${form_ITEM_REQ_NO_R}" />
                    <e:inputHidden id="ITEM_REQ_SEQ" name="ITEM_REQ_SEQ" value="${DATA.ITEM_REQ_SEQ}"/>
                </e:field>
            </e:row>

            <e:row>
                <e:label for="ITEM_NM" title="${form_ITEM_NM_N}" />
                <e:field colSpan="3">
                    <e:inputText id="ITEM_NM" name="ITEM_NM" value="${DATA.ITEM_NM}" width="${form_ITEM_NM_W}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}" />
                </e:field>
                <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
                <e:field>
                    <e:inputText id="MAKER_NM" name="MAKER_NM" value="${DATA.MAKER_NM}" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field colSpan="3">
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="${DATA.ITEM_SPEC}" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
                <e:label for="MODEL_NM" title="${form_MODEL_NM_N}" />
                <e:field>
                    <e:inputText id="MODEL_NM" name="MODEL_NM" value="${DATA.MODEL_NM}" width="${form_MODEL_NM_W}" maxLength="${form_MODEL_NM_M}" disabled="${form_MODEL_NM_D}" readOnly="${form_MODEL_NM_RO}" required="${form_MODEL_NM_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="UNIT_CD" title="${form_UNIT_CD_N}" />
                <e:field>
                    <e:inputText id="UNIT_CD" name="UNIT_CD" value="${DATA.UNIT_CD}" width="${form_UNIT_CD_W}" maxLength="${form_UNIT_CD_M}" disabled="${form_UNIT_CD_D}" readOnly="${form_UNIT_CD_RO}" required="${form_UNIT_CD_R}" />
                </e:field>
                <e:label for="ORIGIN_NM" title="${form_ORIGIN_NM_N}" />
                <e:field>
                    <e:inputText id="ORIGIN_NM" name="ORIGIN_NM" value="${DATA.ORIGIN_NM}" width="${form_ORIGIN_NM_W}" maxLength="${form_ORIGIN_NM_M}" disabled="${form_ORIGIN_NM_D}" readOnly="${form_ORIGIN_NM_RO}" required="${form_ORIGIN_NM_R}" />
                </e:field>
                <e:label for="PREV_VENDOR_NM" title="${form_PREV_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="PREV_VENDOR_NM" name="PREV_VENDOR_NM" value="${DATA.PREV_VENDOR_NM}" width="${form_PREV_VENDOR_NM_W}" maxLength="${form_PREV_VENDOR_NM_M}" disabled="${form_PREV_VENDOR_NM_D}" readOnly="${form_PREV_VENDOR_NM_RO}" required="${form_PREV_VENDOR_NM_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="EST_PO_QT" title="${form_EST_PO_QT_N}"/>
                <e:field>
                    <e:inputNumber id="EST_PO_QT" name="EST_PO_QT" value="${DATA.EST_PO_QT}" width="${form_EST_PO_QT_W}" maxValue="${form_EST_PO_QT_M}" decimalPlace="${form_EST_PO_QT_NF}" disabled="${form_EST_PO_QT_D}" readOnly="${form_EST_PO_QT_RO}" required="${form_EST_PO_QT_R}" />
                </e:field>
                <e:label for="HOPE_UNIT_PRICE" title="${form_HOPE_UNIT_PRICE_N}"/>
                <e:field>
                    <e:inputNumber id="HOPE_UNIT_PRICE" name="HOPE_UNIT_PRICE" value="${DATA.HOPE_UNIT_PRICE}" width="${form_HOPE_UNIT_PRICE_W}" maxValue="${form_HOPE_UNIT_PRICE_M}" decimalPlace="${form_HOPE_UNIT_PRICE_NF}" disabled="${form_HOPE_UNIT_PRICE_D}" readOnly="${form_HOPE_UNIT_PRICE_RO}" required="${form_HOPE_UNIT_PRICE_R}" />
                </e:field>
                <e:label for="CUR" title="${form_CUR_N}" />
                <e:field>
                    <e:inputText id="CUR" name="CUR" value="${DATA.CUR}" width="${form_CUR_W}" maxLength="${form_CUR_M}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="PIC_USER_NM" title="${form_PIC_USER_NM_N}" />
                <e:field>
                    <e:inputText id="PIC_USER_NM" name="PIC_USER_NM" value="${DATA.PIC_USER_NM}" width="${form_PIC_USER_NM_W}" maxLength="${form_PIC_USER_NM_M}" disabled="${form_PIC_USER_NM_D}" readOnly="${form_PIC_USER_NM_RO}" required="${form_PIC_USER_NM_R}" />
                </e:field>
                <e:label for="TEL_NO" title="${form_TEL_NO_N}" />
                <e:field>
                    <e:inputText id="TEL_NO" name="TEL_NO" value="${DATA.TEL_NO}" width="${form_TEL_NO_W}" maxLength="${form_TEL_NO_M}" disabled="${form_TEL_NO_D}" readOnly="${form_TEL_NO_RO}" required="${form_TEL_NO_R}" />
                </e:field>
                <e:label for="dummy"/>
                <e:field colSpan="1" />
            </e:row>

            <e:row>
                <e:label for="RFQ_REQ_TXT" title="${form_RFQ_REQ_TXT_N}"/>
                <e:field colSpan="5">
                    <e:textArea id="RFQ_REQ_TXT" name="RFQ_REQ_TXT" value="${DATA.RFQ_REQ_TXT}" height="100px" width="${form_RFQ_REQ_TXT_W}" maxLength="${form_RFQ_REQ_TXT_M}" disabled="${form_RFQ_REQ_TXT_D}" readOnly="${form_RFQ_REQ_TXT_RO}" required="${form_RFQ_REQ_TXT_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}"/>
                <e:field colSpan="5">
                    <e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" fileId="${DATA.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="IT" height="60px" readOnly="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_RMK" title="${form_ITEM_RMK_N}"/>
                <e:field colSpan="5">
                    <e:textArea id="ITEM_RMK" name="ITEM_RMK" value="${DATA.ITEM_RMK}" height="100px" width="${form_ITEM_RMK_W}" maxLength="${form_ITEM_RMK_M}" disabled="${form_ITEM_RMK_D}" readOnly="${form_ITEM_RMK_RO}" required="${form_ITEM_RMK_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="IMAGE_UUID" title="${form_IMAGE_UUID_N}" />
                <e:field colSpan="5">
                    <e:fileManager id="IMAGE_UUID" name="IMAGE_UUID" fileId="${DATA.IMAGE_UUID}" downloadable="true" width="100%" bizType="IT" height="60px" readOnly="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>
		</e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Copy" name="Copy" label="${Copy_N}" onClick="doCopy" disabled="${Copy_D}" visible="${Copy_V}"/>
            <e:button id="Clear" name="Clear" label="${Clear_N}" onClick="doClear" disabled="${Clear_D}" visible="${Clear_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form2" title="${IM03_015_CAPTION2}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="true" onEnter="doSearch">
            <e:row>
                <e:label for="MTGL_ITEM_CLS_NM" title="${form2_MTGL_ITEM_CLS_NM_N}"/>
                <e:field colSpan="3">
                    <e:search id="MTGL_ITEM_CLS_NM" name="MTGL_ITEM_CLS_NM" value="${DATA.ITEM_CLS_NM}" width="${form2_MTGL_ITEM_CLS_NM_W}" maxLength="${form2_MTGL_ITEM_CLS_NM_M}" onIconClick="${form2_MTGL_ITEM_CLS_NM_RO ? 'everCommon.blank' : 'searchMTGL_ITEM_CLS_NM'}" disabled="${form2_MTGL_ITEM_CLS_NM_D}" readOnly="${form2_MTGL_ITEM_CLS_NM_RO}" required="${form2_MTGL_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="MTGL_ITEM_CLS1" name="MTGL_ITEM_CLS1" value="${DATA.ITEM_CLS1}"/>
                    <e:inputHidden id="MTGL_ITEM_CLS2" name="MTGL_ITEM_CLS2" value="${DATA.ITEM_CLS2}"/>
                    <e:inputHidden id="MTGL_ITEM_CLS3" name="MTGL_ITEM_CLS3" value="${DATA.ITEM_CLS3}"/>
                    <e:inputHidden id="MTGL_ITEM_CLS4" name="MTGL_ITEM_CLS4" value="${DATA.ITEM_CLS4}"/>
                </e:field>
                <e:label for="MTGL_SG_CTRL_USER_ID" title="${form2_MTGL_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="MTGL_SG_CTRL_USER_ID" name="MTGL_SG_CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserNmOptions}" width="${form2_MTGL_SG_CTRL_USER_ID_W}" disabled="${form2_MTGL_SG_CTRL_USER_ID_D}" readOnly="${form2_MTGL_SG_CTRL_USER_ID_RO}" required="${form2_MTGL_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MTGL_ITEM_NM" title="${form2_MTGL_ITEM_NM_N}" />
                <e:field colSpan="3">
                    <e:inputText id="MTGL_ITEM_NM" name="MTGL_ITEM_NM" value="${DATA.ITEM_NM}" width="${form2_MTGL_ITEM_NM_W}" maxLength="${form2_MTGL_ITEM_NM_M}" disabled="${form2_MTGL_ITEM_NM_D}" readOnly="${form2_MTGL_ITEM_NM_RO}" required="${form2_MTGL_ITEM_NM_R}" />
                </e:field>
                <e:label for="MTGL_CMS_CTRL_USER_ID" title="${form2_MTGL_CMS_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="MTGL_CMS_CTRL_USER_ID" name="MTGL_CMS_CTRL_USER_ID" value="${ses.userId}" options="${MTGL_CMS_CTRL_USER_ID_options}" width="${form2_MTGL_CMS_CTRL_USER_ID_W}" disabled="${form2_MTGL_CMS_CTRL_USER_ID_D}" readOnly="${form2_MTGL_CMS_CTRL_USER_ID_RO}" required="${form2_MTGL_CMS_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MTGL_ITEM_SPEC" title="${form2_MTGL_ITEM_SPEC_N}"/>
                <e:field colSpan="3">
                    <e:search id="MTGL_ITEM_SPEC" name="MTGL_ITEM_SPEC" value="${DATA.ITEM_SPEC}" width="${form2_MTGL_ITEM_SPEC_W}" maxLength="${form2_MTGL_ITEM_SPEC_M}" onIconClick="${form2_MTGL_ITEM_SPEC_D ? 'everCommon.blank' : 'searchMTGL_ITEM_SPEC'}" disabled="${form2_MTGL_ITEM_SPEC_D}" readOnly="${form2_MTGL_ITEM_SPEC_RO}" required="${form2_MTGL_ITEM_SPEC_R}" />
                </e:field>
                <e:label for="MTGL_ITEM_KIND_CD" title="${form2_MTGL_ITEM_KIND_CD_N}"/>
                <e:field>
                    <e:select id="MTGL_ITEM_KIND_CD" name="MTGL_ITEM_KIND_CD" value="10" options="${mtglItemKindCdOptions}" width="${form2_MTGL_ITEM_KIND_CD_W}" disabled="${form2_MTGL_ITEM_KIND_CD_D}" readOnly="${form2_MTGL_ITEM_KIND_CD_RO}" required="${form2_MTGL_ITEM_KIND_CD_R}" placeHolder="" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MTGL_MAKER_CD" title="${form2_MTGL_MAKER_CD_N}" />
                <e:field>
                    <e:inputText id="MTGL_MAKER_CD" name="MTGL_MAKER_CD" value="${DATA.CMS_MAKER_CD}" width="40%" maxLength="${form2_MTGL_MAKER_CD_M}" disabled="${form2_MTGL_MAKER_CD_D}" readOnly="${form2_MTGL_MAKER_CD_RO}" required="${form2_MTGL_MAKER_CD_R}" />
                    <e:search id="MTGL_MAKER_NM" name="MTGL_MAKER_NM" value="${DATA.CMS_MAKER_NM}" width="60%" maxLength="${form2_MTGL_MAKER_NM_M}" onClear="onClearMTGL_MAKER_NM" onChange="onChangeMTGL_MAKER_NM" onIconClick="${form2_MTGL_MAKER_NM_RO ? 'everCommon.blank' : 'searchMTGL_MAKER_NM'}" disabled="${form2_MTGL_MAKER_NM_D}" readOnly="${form2_MTGL_MAKER_NM_RO}" required="${form2_MTGL_MAKER_NM_R}" />
                </e:field>
                <e:label for="MTGL_MAKER_PART_NO" title="${form2_MTGL_MAKER_PART_NO_N}" />
                <e:field>
                    <e:inputText id="MTGL_MAKER_PART_NO" name="MTGL_MAKER_PART_NO" value="${DATA.MODEL_NM}" width="${form2_MTGL_MAKER_PART_NO_W}" maxLength="${form2_MTGL_MAKER_PART_NO_M}" disabled="${form2_MTGL_MAKER_PART_NO_D}" readOnly="${form2_MTGL_MAKER_PART_NO_RO}" required="${form2_MTGL_MAKER_PART_NO_R}" />
                </e:field>
				<e:label for="MTGL_BRAND_CD" title="${form2_MTGL_BRAND_CD_N}" />
				<e:field>
				<e:inputText id="MTGL_BRAND_CD" name="MTGL_BRAND_CD" value="" width="${form2_MTGL_BRAND_CD_W}" maxLength="${form2_MTGL_BRAND_CD_M}" disabled="${form2_MTGL_BRAND_CD_D}" readOnly="${form2_MTGL_BRAND_CD_RO}" required="${form2_MTGL_BRAND_CD_R}" />
				</e:field>
            </e:row>

            <e:row>
                <e:label for="MTGL_ORIGIN_CD" title="${form2_MTGL_ORIGIN_CD_N}"/>
                <e:field>
                    <e:select id="MTGL_ORIGIN_CD" name="MTGL_ORIGIN_CD" value="${DATA.CMS_ORIGIN_CD}" useMultipleSelect="true" singleSelect="true" options="${mtglOriginCdOptions}" width="${form2_MTGL_ORIGIN_CD_W}" disabled="${form2_MTGL_ORIGIN_CD_D}" readOnly="${form2_MTGL_ORIGIN_CD_RO}" required="${form2_MTGL_ORIGIN_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="MTGL_UNIT_CD" title="${form2_MTGL_UNIT_CD_N}"/>
                <e:field>
                    <e:select id="MTGL_UNIT_CD" name="MTGL_UNIT_CD" value="EA" options="${mtglUnitCdOptions}" width="${form2_MTGL_UNIT_CD_W}" disabled="${form2_MTGL_UNIT_CD_D}" readOnly="${form2_MTGL_UNIT_CD_RO}" required="${form2_MTGL_UNIT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="MTGL_VAT_CD" title="${form2_MTGL_VAT_CD_N}"/>
                <e:field>
                    <e:select id="MTGL_VAT_CD" name="MTGL_VAT_CD" value="${DATA.VAT_CD}" options="${mtglVatCdOptions}" width="${form2_MTGL_VAT_CD_W}" disabled="${form2_MTGL_VAT_CD_D}" readOnly="${form2_MTGL_VAT_CD_RO}" required="${form2_MTGL_VAT_CD_R}" placeHolder="" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MTGL_CMS_REMARK" title="${form2_MTGL_CMS_REMARK_N}"/>
                <e:field colSpan="5">
                    <e:textArea id="MTGL_CMS_REMARK" name="MTGL_CMS_REMARK" value="${DATA.CMS_REMARK}" height="100px" width="${form2_MTGL_CMS_REMARK_W}" maxLength="${form2_MTGL_CMS_REMARK_M}" disabled="${form2_MTGL_CMS_REMARK_D}" readOnly="${form2_MTGL_CMS_REMARK_RO}" required="${form2_MTGL_CMS_REMARK_R}" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MTGL_ATT_FILE_NUM" title="${form2_MTGL_ATT_FILE_NUM_N}" />
                <e:field colSpan="5">
                    <e:fileManager id="MTGL_ATT_FILE_NUM" name="MTGL_ATT_FILE_NUM" fileId="" downloadable="true" width="100%" bizType="IT" height="80px" readOnly="false" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
                </e:field>
            </e:row>

			<e:label for="MTGL_ITEM_RMK" title="${form_MTGL_ITEM_RMK_N}"/>
			<e:field colSpan="5">
			<e:textArea id="MTGL_ITEM_RMK" name="MTGL_ITEM_RMK" value="${DATA.MTGL_ITEM_RMK}" height="100px" width="${form_MTGL_ITEM_RMK_W}" maxLength="${form_MTGL_ITEM_RMK_M}" disabled="${form_MTGL_ITEM_RMK_D}" readOnly="${form_MTGL_ITEM_RMK_RO}" required="${form_MTGL_ITEM_RMK_R}" />
			</e:field>

        </e:searchPanel>

        <e:searchPanel id="form3" title="${IM03_015_CAPTION3}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="true" onEnter="doSearch">
            <e:row>
                <e:field colSpan="2">
                    <e:fileManager id="IMG_ATT_FILE_NUM" name="IMG_ATT_FILE_NUM" fileId="" bizType="IMG" width="100%" height="140px" readOnly="false" required="false" onFileAdd="_doUpload" onSuccess="_setImages" onAfterRemove="_setImages" onError="onError"/>
                </e:field>
                <e:field colSpan="4">
                    <div id="mainImgContainer" style="width: 100%; height: 100%;"></div>
                    <e:inputHidden id="MAIN_IMG_SQ" name="MAIN_IMG_SQ" value="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="searchPanel8" title="${IM03_015_CAPTION8}" labelWidth="${labelWidth}" width="100%" height="200px" columnCount="1" useTitleBar="true">
            <e:row>
                <e:label for="ITEM_DETAIL_URL" title="${form_ITEM_DETAIL_URL_N}" />
                <e:field>
                    <e:inputText id="ITEM_DETAIL_URL" name="ITEM_DETAIL_URL" value="${formData.ITEM_DETAIL_URL}" width="${form_ITEM_DETAIL_URL_W}" maxLength="${form_ITEM_DETAIL_URL_M}" disabled="${form_ITEM_DETAIL_URL_D}" readOnly="${form_ITEM_DETAIL_URL_RO}" required="${form_ITEM_DETAIL_URL_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2">
                    <e:fileManager id="ITEM_DETAIL_FILE_NUM" name="ITEM_DETAIL_FILE_NUM" fileId="${formData.ITEM_DETAIL_FILE_NUM}" bizType="IMG" width="100%" height="40px" readOnly="${form_IMG_ATT_FILE_NUM_RO}" required="${form_IMG_ATT_FILE_NUM_R}" onFileAdd="_doUpload2" onSuccess="_setImages2" onAfterRemove="_setImages2" maxFileCount="1" onError="onError"/>
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="2">
                    <div id="DetailImgContainer" style="width: 100%; height: 185px;"></div>
                </e:field>
            </e:row>
        </e:searchPanel>


        <e:searchPanel id="form4" title="${IM03_015_CAPTION4}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="true" onEnter="doSearch">
            <e:row>
                <e:field colSpan="6">
                    <e:inputHidden id="MTGL_ITEM_DETAIL_TEXT_NUM" name="MTGL_ITEM_DETAIL_TEXT_NUM" value="" />
                    <e:richTextEditor height="300" width="100%" disabled="false" required="false" id="MTGL_TEXT_CONTENTS" readOnly="false" name="MTGL_TEXT_CONTENTS" value=""/>

                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="searchPanel7" title="${IM03_015_CAPTION7}" labelWidth="300px" width="100%" columnCount="1" useTitleBar="true">
            <e:row>
                <e:label for="ITEM_NOTC_DESC" title="${form_ITEM_NOTC_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_DESC" name="ITEM_NOTC_DESC" value="${formData.ITEM_NOTC_DESC}" width="${form_ITEM_NOTC_DESC_W}" maxLength="${form_ITEM_NOTC_DESC_M}" disabled="${form_ITEM_NOTC_DESC_D}" readOnly="${form_ITEM_NOTC_DESC_RO}" required="${form_ITEM_NOTC_DESC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_CERT" title="${form_ITEM_NOTC_CERT_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_CERT" name="ITEM_NOTC_CERT" value="${formData.ITEM_NOTC_CERT}" width="${form_ITEM_NOTC_CERT_W}" maxLength="${form_ITEM_NOTC_CERT_M}" disabled="${form_ITEM_NOTC_CERT_D}" readOnly="${form_ITEM_NOTC_CERT_RO}" required="${form_ITEM_NOTC_CERT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_ORIGIN" title="${form_ITEM_NOTC_ORIGIN_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_ORIGIN" name="ITEM_NOTC_ORIGIN" value="${formData.ITEM_NOTC_ORIGIN}" width="${form_ITEM_NOTC_ORIGIN_W}" maxLength="${form_ITEM_NOTC_ORIGIN_M}" disabled="${form_ITEM_NOTC_ORIGIN_D}" readOnly="${form_ITEM_NOTC_ORIGIN_RO}" required="${form_ITEM_NOTC_ORIGIN_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_MAKER" title="${form_ITEM_NOTC_MAKER_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_MAKER" name="ITEM_NOTC_MAKER" value="${formData.ITEM_NOTC_MAKER}" width="${form_ITEM_NOTC_MAKER_W}" maxLength="${form_ITEM_NOTC_MAKER_M}" disabled="${form_ITEM_NOTC_MAKER_D}" readOnly="${form_ITEM_NOTC_MAKER_RO}" required="${form_ITEM_NOTC_MAKER_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_NOTC_AS" title="${form_ITEM_NOTC_AS_N}" />
                <e:field>
                    <e:inputText id="ITEM_NOTC_AS" name="ITEM_NOTC_AS" value="${formData.ITEM_NOTC_AS eq null ? IM03_015_015 : formData.ITEM_NOTC_AS }" width="${form_ITEM_NOTC_AS_W}" maxLength="${form_ITEM_NOTC_AS_M}" disabled="${form_ITEM_NOTC_AS_D}" readOnly="${form_ITEM_NOTC_AS_RO}" required="${form_ITEM_NOTC_AS_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
		</e:buttonBar>

        <e:panel id="hiddenP" height="0" width="0%">
            <e:gridPanel gridType="${_gridType}" id="gridat" name="gridat" height="0px" readOnly="${param.detailView}" columnDef="${gridInfos.gridat.gridColData}"/>
        </e:panel>
	</e:window>
</e:ui>