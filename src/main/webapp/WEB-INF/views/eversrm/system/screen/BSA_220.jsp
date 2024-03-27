<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/system/screen/actionProfileManagement";
        var gridL = {};
        var gridR = {};
        var gridT = {};

        function init() {

            gridL = EVF.C("gridL");
            gridR = EVF.C("gridR");
            gridT = EVF.C("gridT");
            gridT.setColFontColor('ACTION_PROFILE_CD', '0|0|255');
            gridT.setProperty('shrinkToFit', 'true');
            gridL.setProperty('shrinkToFit', 'true');
            gridR.setProperty('shrinkToFit', 'true');

            gridL.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }-1",
                excelOptions: {
                    imgWidth: 0.12, <%-- // 이미지의 너비. --%>
                    imgHeight: 0.26, <%-- // 이미지의 높이. --%>
                    colWidth: 20, <%-- // 컬럼의 넓이. --%>
                    rowSize: 500, <%-- // 엑셀 행에 높이 사이즈. --%>
                    attachImgFlag: false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            gridR.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }-2",
                excelOptions: {
                    imgWidth: 0.12, <%-- // 이미지의 너비. --%>
                    imgHeight: 0.26, <%-- // 이미지의 높이. --%>
                    colWidth: 20, <%-- // 컬럼의 넓이. --%>
                    rowSize: 500, <%-- // 엑셀 행에 높이 사이즈. --%>
                    attachImgFlag: false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            gridT.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }-3",
                excelOptions: {
                    imgWidth: 0.12, <%-- // 이미지의 너비. --%>
                    imgHeight: 0.26, <%-- // 이미지의 높이. --%>
                    colWidth: 20, <%-- // 컬럼의 넓이. --%>
                    rowSize: 500, <%-- // 엑셀 행에 높이 사이즈. --%>
                    attachImgFlag: false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            gridT.addRowEvent(function () {
                addParam = [{"INSERT_FLAG": "I", "USER_TYPE": "C"}];
                gridT.addRow(addParam);
            });

            gridT.cellClickEvent(function (rowid, celname, value, iRow, iCol) {
                if (celname == 'SCREEN_NM_IMG') {
                    if (gridT.getCellValue(rowid, "ACTION_PROFILE_CD") == '') {
                        alert('${BSA_220_0002}');
                        return;
                    }
                    var params = {
                        multi_cd: 'AP',
                        screen_id: '-',
                        action_profile_cd: gridT.getCellValue(rowid, "ACTION_PROFILE_CD"),
                        choose_button_visibility: true,
                        rowid: rowid
                    };
                    everPopup.openMultiLanguagePopup(params);
                }
                if (celname == 'ACTION_PROFILE_CD') {
                    EVF.C("ACTION_PROFILE_CD").setValue(gridT.getCellValue(rowid, "ACTION_PROFILE_CD"));
                    doSearchL();
                }
            });
        }

        function multiLanguagePopupCallBack(multiLanguagePopupReturn) {
            gridT.setCellValue(multiLanguagePopupReturn.rowid, 'ACTION_PROFILE_NM', multiLanguagePopupReturn.multiNm);
        }
        function doSearchAUTH(strColumnKey, nRow) {
            var param = {
                callBackFunction: "selectAthorization"
            };
            everPopup.openCommonPopup(param, 'SP0008');
        }
        function selectAthorization(data) {
            //  	alert(data);
            //	data = $.parseJSON( data );
            EVF.C("AUTH_CD").setValue(data.AUTH_CD);
            //  EVF.C("MAIN_MODULE_TYPE").setValue(data.MAIN_MODULE_TYPE);
            doSearchL();
        }
        function doSendLeft() {
            doSaveL();
        }
        function doSave() {
            if (gridL.isEmpty(gridL.getSelRowId())) {
                alert("${msg.M0004}");
                return;
            }

            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.getGridData(gridL, 'sel');
            store.load(baseUrl + 'doSave', function () {
                alert(this.getResponseMessage());
                doSearchL();
            });
        }
        function doDelete() {
            if (gridL.isEmpty(gridL.getSelRowId())) {
                alert("${msg.M0004}");
                return;
            }

            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.getGridData(gridL, 'sel');
            store.load(baseUrl + 'doDelete', function () {
                alert(this.getResponseMessage());
                doSearchL();
            });
        }
        function doSearchACPF(strColumnKey, nRow) {
            EVF.C("ACTION_PROFILE_CD").setValue("");
            var param = {
                callBackFunction: "selectACPF"
            };
            everPopup.openCommonPopup(param, 'SP0010');
        }
        function selectACPF(dataJsonArray) {
            EVF.C("ACTION_PROFILE_CD_SEARCH").setValue(dataJsonArray.ACTION_PROFILE_NM);
            EVF.C("T_ACTION_PROFILE_CD").setValue(dataJsonArray.ACTION_PROFILE_CD);
        }
        function doSearchT() {
            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.load(baseUrl + '/doSearchT', function () {
                if (gridT.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }
        function doSaveT() {
            if (gridT.isEmpty(gridT.getSelRowId())) {
                alert("${msg.M0004}");
                return;
            }

            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.getGridData(gridT, 'sel');
            store.load(baseUrl + '/doSaveT', function () {
                alert(this.getResponseMessage());
                doSearchT();
            });
        }
        function doDeleteT() {
            if (gridT.isEmpty(gridT.getSelRowId())) {
                alert("${msg.M0004}");
                return;
            }
            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([gridT]);
            store.getGridData(gridT, 'sel');
            store.load(baseUrl + '/doDeleteT', function () {
                alert(this.getResponseMessage());
                doSearchT();
            });
        }

        function doSearchL() {

            if (EVF.C('actionTypeL').getValue().length <= 0) {
                return alert("${BSA_220_0003}");
            }
            var store = new EVF.Store();	// formL
            if (!store.validate()) return;
            store.setGrid([gridL]);
            store.load(baseUrl + '/doSearchL', function () {
                if (gridL.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSaveL() {

            if (EVF.C("ACTION_PROFILE_CD").getValue() == '') {
                alert('${BSA_220_0001}');
                return;
            }

            if (gridR.isEmpty(gridR.getSelRowId())) {
                alert("${msg.M0004}");
                return;
            }

            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([gridR]);
            store.getGridData(gridR, 'sel');
            store.setParameter("ACTION_PROFILE_CD", EVF.C("ACTION_PROFILE_CD").getValue());
            store.load(baseUrl + '/doSaveL', function () {
                alert(this.getResponseMessage());
                doSearchL();
            });
        }

        function doDeleteL() {

            if (gridL.isEmpty(gridL.getSelRowId())) {
                alert("${msg.M0004}");
                return;
            }
            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.getGridData(gridL, 'sel');
            store.load(baseUrl + '/doDeleteL', function () {
                alert(this.getResponseMessage());
                doSearchL();
            });
        }

        function doSearchR() {

            if (EVF.C('actionType').getValue().length <= 0) {
                return alert("${BSA_220_0003}");
            }
            var store = new EVF.Store();	// formR
            store.setGrid([gridR]);
            store.load(baseUrl + '/doSearchR', function () {
                if (gridR.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function cleanActionProfileCd() {
            EVF.C('T_ACTION_PROFILE_CD').setValue('');
        }

    </script>

    <e:window id="BSA_220" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}"
              title="${fullScreenName}">

        <e:panel id="pnl0" width="100%">
            <e:searchPanel id="frmLeftv" title="${form_CAPTION_N}" labelWidth="${labelWidth}" width="100%"
                           columnCount="2" onEnter="doSearchT" useTitleBar="false">
                <e:row>
                    <e:label for="ACTION_PROFILE_CD_SEARCH" title="${tForm_ACTION_PROFILE_CD_SEARCH_N}"/>
                    <e:field>
                        <e:search id="ACTION_PROFILE_CD_SEARCH" name="ACTION_PROFILE_CD_SEARCH" value=""
                                  width="${inputTextWidth}" maxLength="${tForm_ACTION_PROFILE_CD_SEARCH_M}"
                                  onIconClick="${tForm_ACTION_PROFILE_CD_SEARCH_RO ? 'everCommon.blank' : 'doSearchACPF'}"
                                  disabled="${tForm_ACTION_PROFILE_CD_SEARCH_D}"
                                  readOnly="${tForm_ACTION_PROFILE_CD_SEARCH_RO}"
                                  required="${tForm_ACTION_PROFILE_CD_SEARCH_R}" onKeyDown="cleanActionProfileCd"/>
                        <e:inputHidden id="T_ACTION_PROFILE_CD" name="T_ACTION_PROFILE_CD" value=""/>
                    </e:field>

                    <e:label for="ACTION_PROFILE_NM" title="${tForm_ACTION_PROFILE_NM_N}"/>
                    <e:field>
                        <e:inputText id="ACTION_PROFILE_NM" name="ACTION_PROFILE_NM" value="${form.ACTION_PROFILE_NM}"
                                     width="100%" maxLength="${tForm_ACTION_PROFILE_NM_M}"
                                     disabled="${tForm_ACTION_PROFILE_NM_D}" readOnly="${tForm_ACTION_PROFILE_NM_RO}"
                                     required="${tForm_ACTION_PROFILE_NM_R}"/>
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar id="c" width="100%" align="right">
                <e:button id="doSearchT" name="doSearchT" label="${doSearchT_N}" onClick="doSearchT"
                          disabled="${doSearchT_D}" visible="${doSearchT_V}"/>
                <e:button id="doSaveT" name="doSaveT" label="${doSaveT_N}" onClick="doSaveT" disabled="${doSaveT_D}"
                          visible="${doSaveT_V}"/>
                <e:button id="doDeleteT" name="doDeleteT" label="${doDeleteT_N}" onClick="doDeleteT"
                          disabled="${doDeleteT_D}" visible="${doDeleteT_V}"/>
            </e:buttonBar>

            <e:gridPanel id="gridT" name="gridT" width="100%" height="200px" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}"/>
        </e:panel>

        <e:panel id="pnl1" width="48%">
            <e:searchPanel id="frmLeft" title="${form_CAPTION_N}" labelWidth="150" width="100%" columnCount="2"
                           onEnter="doSearchL" useTitleBar="false">
                <e:row>
                    <e:label for="ACTION_PROFILE_CD" title="${lForm_ACTION_PROFILE_CD_N}"/>
                    <e:field>
                        <e:inputText id="ACTION_PROFILE_CD" name="ACTION_PROFILE_CD" value="${form.ACTION_PROFILE_CD}"
                                     width="100%" maxLength="${lForm_ACTION_PROFILE_CD_M}"
                                     disabled="${lForm_ACTION_PROFILE_CD_D}" readOnly="${lForm_ACTION_PROFILE_CD_RO}"
                                     required="${lForm_ACTION_PROFILE_CD_R}"/>
                    </e:field>
                    <e:label for="">
                        <e:select id="actionTypeL" name="actionTypeL" placeHolder="${placeHolder }" required="false"
                                  disabled="false" readOnly="false" visible="true" value="2" width="120">
                            <e:option text="Screen Name" value="1"/>
                            <e:option text="Screen ID" value="2"/>
                            <e:option text="Action Name" value="3"/>
                            <e:option text="Action Code" value="4"/>
                        </e:select>
                    </e:label>
                    <e:field>
                        <e:inputText id="actionValueL" name="actionValueL" value="${form.SCREEN_NM}" width="100%"
                                     maxLength="${lForm_SCREEN_NM_M}" disabled="false" readOnly="false"
                                     required="false"/>
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar id="a" width="100%" align="right">
                <e:button id="doSearchL" name="doSearchL" label="${doSearchL_N}" onClick="doSearchL"
                          disabled="${doSearchL_D}" visible="${doSearchL_V}"/>
                <e:button id="doDeleteL" name="doDeleteL" label="${doDeleteL_N}" onClick="doDeleteL"
                          disabled="${doDeleteL_D}" visible="${doDeleteL_V}"/>
            </e:buttonBar>

            <e:gridPanel id="gridL" name="gridL" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
        </e:panel>

        <e:panel id="pnl2" width="20px" height="100%">
            <div><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
                <img src="/images/everuxf/icons/13x22_thumb_prev.png" width="13" height="22" onClick="doSendLeft()"
                     style="cursor: pointer;">
            </div>
        </e:panel>

        <e:panel id="pnl3" width="50%">
            <e:searchPanel id="frmRight" title="${form_CAPTION_N}" labelWidth="150" width="100%" columnCount="1"
                           onEnter="doSearchR" useTitleBar="false">
                <e:row>
                    <e:label for="">
                        <e:select id="actionType" name="actionType" placeHolder="${placeHolder }" required="false"
                                  disabled="false" readOnly="false" visible="true" value="" width="120">
                            <e:option text="Screen Name" value="1"/>
                            <e:option text="Screen ID" value="2"/>
                            <e:option text="Action Name" value="3"/>
                            <e:option text="Action Code" value="4"/>
                        </e:select>
                    </e:label>
                    <e:field>

                        <e:inputText id="actionValue" name="actionValue" value="${form.SCREEN_NM}" width="50%"
                                     maxLength="${lForm_SCREEN_NM_M}" disabled="false" readOnly="false"
                                     required="false"/>
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar id="b" width="100%" align="right">
                <e:button id="doSearchR" name="doSearchR" label="${doSearchR_N}" onClick="doSearchR"
                          disabled="${doSearchR_D}" visible="${doSearchR_V}"/>
                <!-- e:button id="doSaveL" name="doSaveL" label="${doSaveL_N}" onClick="doSaveL" disabled="${doSaveL_D}" visible="${doSaveL_V}"/ -->
            </e:buttonBar>

            <e:gridPanel id="gridR" name="gridR" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
        </e:panel>


    </e:window>
</e:ui>

