<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS03/BS0302/";
        var eventRowId = 0;

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {
               eventRowId = rowId;
                if (colId == "USER_ID") {
                    var param = {
                        'USER_ID': grid.getCellValue(rowId, 'ORI_USER_ID'),
                        'detailView': false,
                        'popupFlag': true
                    };

               if (grid.getCellValue(rowId, 'USER_TYPE') == 'B') {
                       everPopup.openPopupByScreenId("BS03_006", 800, 720, param);
               } else {
                       everPopup.openPopupByScreenId("BS03_006_1", 800, 720, param);
               }

                }
                if(colId === 'CONFIRM_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "CONFIRM_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId === 'CHIEF_USER_NM') {
                   if(grid.getCellValue(rowId, "CHIEF_USER_ID") != '' && grid.getCellValue(rowId, "CHIEF_USER_ID") != null)
                      {
                          var param = {
                              callbackFunction: "",
                              USER_ID: grid.getCellValue(rowId, "CHIEF_USER_ID"),
                              detailView: true
                          };
                          everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                      }
                }
                if(colId === 'DELY_NM') {
                   if(grid.getCellValue(rowId, "DELY_NM") != '' && grid.getCellValue(rowId, "DELY_NM") != null)
                      {
                          var param = {
                             callBackFunction: "setCsdmCdSearchG",
                             CUST_CD: grid.getCellValue(rowId, "COMPANY_CD"),
                              DELY_NM: grid.getCellValue(rowId, "DELY_NM"),
                              detailView: false
                          };
                          everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                      }
                }
                if(colId === 'CUBL_NM') {
                   if(grid.getCellValue(rowId, "CUBL_NM") != '' && grid.getCellValue(rowId, "CUBL_NM") != null)
                      {
                          var param = {
                             callBackFunction: "setCublCdSearchG",
                              CUST_CD: grid.getCellValue(rowId, "COMPANY_CD"),
                              CUBL_NM: grid.getCellValue(rowId, "CUBL_NM"),
                              detailView: false
                          };
                          everPopup.openPopupByScreenId("MY01_008", 900, 600, param);
                      }
                }
            });

            //동일 회사에 관리자여부 1명이상 존재 할 수 없음>> 체크
            grid.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "MNG_YN") {
                    if (value == "1") {
                        if(grid.getCellValue(rowid, 'BLOCK_FLAG')=="1"){
                            grid.setCellValue(rowid, 'MNG_YN', "0");
                            return alert("${BS03_005_006}");
                        }
                        if(grid.getCellValue(rowid, 'MNG_USER_ID')!=""){
                            if(grid.getCellValue(rowid, 'ORI_USER_ID')!=grid.getCellValue(rowid, 'MNG_USER_ID')){
                                if(confirm("${BS03_005_002}"+"("+grid.getCellValue(rowid, 'MNG_USER_NM')+")\n"+"${BS03_005_003}")) {
                                    grid.setCellValue(rowid, 'CHANGE_MNG_YN', "Y");
                                    alert("${BS03_005_004}");
                                }else{
                                    grid.setCellValue(rowid, 'MNG_YN', "0");
                                }
                            }
                        }

                    }

                }
            });


            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid._gvo.setFixedOptions({colCount: 6});

        }

        function setCsdmCdSearchG(data) {
           grid.setCellValue(eventRowId, "CSDM_SEQ", data.CSDM_SEQ);
           grid.setCellValue(eventRowId, "DELY_NM", data.DELY_NM);
           grid.setCellValue(eventRowId, "DELY_RECIPIENT_NM", data.DELY_RECIPIENT_NM);
           grid.setCellValue(eventRowId, "DELY_ADDR", data.DELY_ADDR);
           //grid.setCellValue(eventRowId, "DELY_RECIPIENT_TEL_NUM", data.DELY_RECIPIENT_TEL_NUM);
           //grid.setCellValue(eventRowId, "DELY_RECIPIENT_FAX_NUM", data.DELY_RECIPIENT_FAX_NUM);
           //grid.setCellValue(eventRowId, "DELY_RECIPIENT_CELL_NUM", data.DELY_RECIPIENT_CELL_NUM);
           //grid.setCellValue(eventRowId, "DELY_RECIPIENT_EMAIL", data.DELY_RECIPIENT_EMAIL);

        }

        function setCublCdSearchG(data) {
           grid.setCellValue(eventRowId, "CUBL_SQ", data.CUBL_SQ);
           grid.setCellValue(eventRowId, "CUBL_NM", data.CUBL_NM);
           grid.setCellValue(eventRowId, "CUBL_COMPANY_NM", data.CUBL_COMPANY_NM);
           grid.setCellValue(eventRowId, "CUBL_IRS_NUM", data.CUBL_IRS_NUM);
           grid.setCellValue(eventRowId, "CUBL_ADDR", data.CUBL_ADDR);
           //grid.setCellValue(eventRowId, "CUBL_CEO_USER_NM", data.HIDDEN_CUBL_CEO_USER_NM);
           //grid.setCellValue(eventRowId, "CUBL_BUSINESS_TYPE", data.CUBL_BUSINESS_TYPE);
           //grid.setCellValue(eventRowId, "CUBL_INDUSTRY_TYPE", data.CUBL_INDUSTRY_TYPE);
           //grid.setCellValue(eventRowId, "CUBL_BANK_NM", data.CUBL_BANK_NM);
           //grid.setCellValue(eventRowId, "CUBL_ACCOUNT_NUM", data.CUBL_ACCOUNT_NUM);
           //grid.setCellValue(eventRowId, "CUBL_ACCOUNT_NM", data.HIDDEN_CUBL_ACCOUNT_NM);
           //grid.setCellValue(eventRowId, "CUBL_USER_NM", data.HIDDEN_CUBL_USER_NM);
           //grid.setCellValue(eventRowId, "CUBL_USER_TEL_NUM", data.HIDDEN_CUBL_USER_TEL_NUM);
           //grid.setCellValue(eventRowId, "CUBL_USER_FAX_NUM", data.HIDDEN_CUBL_USER_FAX_NUM);
           //grid.setCellValue(eventRowId, "CUBL_USER_CELL_NUM", data.HIDDEN_CUBL_USER_CELL_NUM);
           //grid.setCellValue(eventRowId, "CUBL_USER_EMAIL", data.HIDDEN_CUBL_USER_EMAIL);
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}

            if(EVF.isEmpty(EVF.V("USER_TYPE")) && EVF.isEmpty(EVF.V("USER_ID")) &&
                EVF.isEmpty(EVF.V("USER_NM")) && EVF.isEmpty(EVF.V("FROM_DATE")) &&
                EVF.isEmpty(EVF.V("USER_NM")) && EVF.isEmpty(EVF.V("FROM_DATE")) &&
                EVF.isEmpty(EVF.V("TO_DATE")) && EVF.isEmpty(EVF.V("COMPANY_NM")) && EVF.isEmpty(EVF.V("DEPT_NM"))) {
                return alert("${BS03_005_001}");
            }
            store.setGrid([grid]);
            store.load(baseUrl + 'bs03005_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doInsert() {
            var param = {
                'USER_ID': '',
                'detailView': false,
                'popupFlag': true
            };

            if(EVF.C("USER_TYPE").getValue() == 'B') {
                everPopup.openPopupByScreenId("BS03_006", 800, 720, param);
            } else {
                everPopup.openPopupByScreenId("BS03_006_1", 800, 620, param);
            }
        }

        function dosendMessage() {
            var param = {
                    'USER_ID'   : '',
    				 usrList    : JSON.stringify(grid.getSelRowValue()),
                    'detailView': false
                };
            everPopup.openPopupByScreenId("BSN_040", 1000, 620, param);
        }


        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if(!confirm('${msg.M0021}')) { return; }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'MNG_YN') == "1" && grid.getCellValue(rowIds[i], 'BLOCK_FLAG') == "1" ) {
                    return alert("${BS03_005_005}");
                }
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs03005_doUpdate', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs03005_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doInitPass() {
            if (confirm("${BS03_005_007}")) {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.setParameter('gridFlag', 'Y');
                store.load('/eversrm/master/user/userInformation/doInitPassword_CVUR', function () {
                    alert(this.getResponseMessage());
                    doSearch();
                });
            }
        }
      function selectCust(){
           if (EVF.V('USER_TYPE') == '') {
              alert("${form_USER_TYPE_N } - ${msg.M0004}.");
              return;
              }
           if (EVF.V('USER_TYPE') == 'S') {
              var param = {
                 callBackFunction: "selectVendor_I"
               };
              everPopup.openCommonPopup(param, 'SP0063');
             }
           else if (EVF.V('USER_TYPE') == 'B') {
               var param = {
                 callBackFunction : "selectCust_I"
                 };
                 everPopup.openCommonPopup(param, 'SP0902');
           }
        }

      function selectVendor_I(dataJsonArray) {
   	       EVF.C('CUST_CD').setValue(dataJsonArray.VENDOR_CD);
     	   EVF.C('CUST_NM').setValue(dataJsonArray.VENDOR_NM);
      }

      function selectCust_I(dataJsonArray) {
          EVF.C('CUST_CD').setValue(dataJsonArray.CUST_CD);
          EVF.C('CUST_NM').setValue(dataJsonArray.CUST_NM);
      }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${BS03_005_008}");
            var param = {
                callBackFunction : "callBackPlant",
                custCd: EVF.V("CUST_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
        }

    </script>

    <e:window id="BS03_005" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="USER_TYPE" title="${form_USER_TYPE_N }"/>
                <e:field>
                    <e:select id="USER_TYPE" name="USER_TYPE" value="${param.USER_TYPE}" options="${userTypeOptions}" width="100%" disabled="true" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
                </e:field>
                <e:label for="CUST_CD" title='${param.USER_TYPE=="S" ? "공급사":"고객사"}'/>
	            <e:field>
	               <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'selectCust'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
	               <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
	            </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N}" />
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
                <e:label for="USER_ID" title="${form_USER_ID_N }" />
                <e:field>
                    <e:inputText id="USER_ID" name="USER_ID" value=""   readOnly="${form_USER_ID_RO }"   maxLength="${form_USER_ID_M}"  width="${form_USER_ID_W }" required="${form_USER_ID_R }" disabled="${form_USER_ID_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N }" />
                <e:field>
                    <e:inputText id="DEPT_NM" name="DEPT_NM" value=""   readOnly="${form_DEPT_NM_RO }"   maxLength="${form_DEPT_NM_M}"  width="${form_DEPT_NM_W }" required="${form_DEPT_NM_R }" disabled="${form_DEPT_NM_D }" onFocus="onFocus" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${Insert_V}" onClick="doInsert" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
            <e:button id="InitPass" name="InitPass" label="${InitPass_N}" onClick="doInitPass" disabled="${InitPass_D}" visible="${InitPass_V}"/>

            <e:button id="sendMessage" name="sendMessage" label="${sendMessage_N}" onClick="dosendMessage" disabled="${sendMessage_D}" visible="${sendMessage_V}"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />


    </e:window>
</e:ui>