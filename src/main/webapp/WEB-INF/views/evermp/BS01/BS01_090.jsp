<!--
* BS01_080 : 고객사 결재경로관리
* 운영사 > 기준정보 > 고객사 정보관리 > 고객사 결재경로관리
-->

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script>

        var baseUrl = "/evermp/BS01/BS0102/BS01_090/";
        var grid;

        function init() {

            EVF.C("PROGRESS_CD").removeOption("E");

            grid = EVF.C('grid');
            grid.setProperty("singleSelect", true);


            grid.cellClickEvent(function(rowId, colId, value) {
                if (colId === "CUST_CD") {
                    var param = {
                        'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }else if(colId === "REJECT_RMK" && value != ''){
                    var param = {
                        title: "${BS01_090_0003}",
                        message: grid.getCellValue(rowId, 'REJECT_RMK')
                    };
                    everPopup.openModalPopup('/common/popup/common_text_view/view', 500, 300, param);
                }

            });

            grid.cellClickEvent(function(rowIdx, colIdx, value) {


            });


            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            fn_multiCombo();
            //doSearch();
        }
        function fn_multiCombo(){
           	var chkName = "";
            $('.ui-multiselect-checkboxes li input').each(function (k, v) {
              if(v.value == 'J' || v.value == 'T' || v.value == 'P') {
                 chkName += v.title + ", ";
                 v.checked = true;
                  }
              });
            $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            doSearch();


	    }

        function doSearch(){

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'doSerach', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });

        }

        function doInsert() {
            var param = {
                'CUST_CD': '',
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
        }


        function doReject(){

            if(grid.getSelRowCount() === 0){
                return EVF.alert("${msg.M0004}");
            }

            if(grid.getSelRowCount() > 1){
                return EVF.alert("${msg.M0006}");
            }

            if(grid.getSelRowValue()[0].PROGRESS_CD != 'J' && grid.getSelRowValue()[0].SIGN_STATUS !== 'R'){
                return EVF.alert("${BS01_090_0002}");
            }
            if(grid.getSelRowValue()[0].PROGRESS_CD == 'R'){
                return EVF.alert("${BS01_090_0004}");
            }

            var param = {
                  rowId: grid.getSelRowId()
                , havePermission: true
                , screenName: '반려 사유'
                , callBackFunction: 'setRejectRemark'
                , TEXT_CONTENTS: ''
                , detailView: false
            };
            everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
        }

        function setRejectRemark(data, rowId){
            if(data.trim() === ""){
                return EVF.alert("${BS01_090_0001}");
            }

            grid.setCellValue(rowId, 'PROGRESS_CD', 'R');
            grid.setCellValue(rowId, 'REJECT_RMK', data);

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'doReject', function() {
                EVF.alert('${msg.M0001}');
                doSearch();
            });

        }


    </script>

    <e:window id="BS01_090" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">


        <e:searchPanel id="formS" title="${msg.M9999}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="IRS_NUM" title="${form_IRS_NUM_N}" />
                <e:field>
                    <e:inputText id="IRS_NUM" name="IRS_NUM" value="" width="${form_IRS_NUM_W}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="J" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false" />
                </e:field>
                <e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}" />
                <e:field>
                    <e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="" width="${form_CEO_USER_NM_W}" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="btn" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
            <e:button id="doInsert" name="doInsert" label="${doInsert_N}" onClick="doInsert" disabled="${doInsert_D}" visible="${doInsert_V}"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
