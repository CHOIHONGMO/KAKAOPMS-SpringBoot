<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/eversrm/system/auth/BSYA_040/";
        var meGrid;
        var buGrid;
        var SelectRowId;
        var SelectGrid;

        function init() {
            meGrid = EVF.C("meGrid");
            buGrid = EVF.C("buGrid");
            meGrid.setProperty('shrinkToFit', false);
            buGrid.setProperty('shrinkToFit', false);

            meGrid.setProperty('panelVisible', ${panelVisible});
            buGrid.setProperty('panelVisible', ${panelVisible});

            // Grid Excel Export
            meGrid.excelExportEvent({
                allCol : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            buGrid.excelExportEvent({
                allCol : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function getContentTab(uu) {
            if (uu == '1') {
                delType = 'me'
            }
            if (uu == '2') {
                delType = 'bu'
            }
        }

        $(document.body).ready(function() {
            $('#e-tabs').height(($('.ui-layout-center').height() - 30)).tabs({
                activate : function(event, ui) {

                    $(window).trigger('resize');
                }
            });
            $('#e-tabs').tabs('option', 'active', 0);
        });

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([meGrid,buGrid]);
            store.load(baseUrl + "/doSearch", function() {
            });
        }

        function getRegUserId() {
            var param = {
                callBackFunction : "setRegUserId"
            };
            everPopup.openCommonPopup(param, 'SP0011');
        }
        function setRegUserId(dataJsonArray) {
            EVF.C("USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function getScreenId() {
            var popupUrl = "/eversrm/system/screen/BSYS_030/view";
            everPopup.openWindowPopup(popupUrl, 1000, 500, {
                onSelect: 'selectScreen',
                screen_Id: ""
            }, 'screenIdPopup');
        }
        function selectScreen(dataJsonArray) {
            EVF.C("SCREEN_ID").setValue(dataJsonArray.SCREEN_ID);
            EVF.C("SCREEN_NM").setValue(dataJsonArray.SCREEN_NM);
        }



    </script>

    <e:window id="BSYA_040" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
                <e:field>
                    <e:search id="SCREEN_ID" name="SCREEN_ID" value="" width="40%" maxLength="${form_SCREEN_ID_M}" onIconClick="getScreenId" disabled="${form_SCREEN_ID_D}" readOnly="${form_SCREEN_ID_RO}" required="${form_SCREEN_ID_R}" />
                    <e:inputText id="SCREEN_NM" name="SCREEN_NM"  value="" width="60%" maxLength="${form_SCREEN_NM_M}" disabled="${form_SCREEN_NM_D}" readOnly="${form_SCREEN_NM_RO}" required="${form_SCREEN_NM_R}" />
                </e:field>
                <e:label for="ACTION_CD" title="${form_ACTION_CD_N }" />
                <e:field>
                    <e:inputText id="ACTION_CD" name="ACTION_CD" maxLength="${form_ACTION_ID_M}" width="${form_ACTION_CD_W }" required="${form_ACTION_CD_R }" readOnly="${form_ACTION_CD_RO }" disabled="${form_ACTION_CD_D }" />
                </e:field>
                <e:label for="ACTION_NM" title="${form_ACTION_NM_N }" />
                <e:field>
                    <e:inputText id="ACTION_NM" name="ACTION_NM" maxLength="${form_ACTION_NM_M}" width="${form_ACTION_NM_W }" required="${form_ACTION_NM_R }" readOnly="${form_ACTION_NM_RO }" disabled="${form_ACTION_NM_D }" />
                </e:field>

            </e:row>
            <e:row>
                <e:label for="CTRL_NM" title="${form_CTRL_NM_N }" />
                <e:field>
                    <e:select id="CTRL_NM" name="CTRL_NM" value="" options="${ctrlNmOptions}" width="100%" disabled="${form_CTRL_NM_D}" readOnly="${form_CTRL_NM_RO}" required="${form_CTRL_NM_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N }" />
                <e:field>
                    <e:search id="USER_ID" name="USER_ID" value="" width="40%" maxLength="${form_USER_ID_M}" onIconClick="getRegUserId" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
                    <e:inputText id="USER_NM" name="USER_NM"  value="" width="60%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                </e:field>
                <e:label for=""></e:label>
                <e:field></e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

        <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
            <tr><td><div>
                <ul>
                    <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${BSYA_040_TAB1}</a></li>
                    <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${BSYA_040_TAB2}</a></li>
                </ul>

                <div id="ui-tabs-1">
                    <div style="height: auto;">
                        <e:gridPanel gridType="${_gridType}" id="meGrid" name="meGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.meGrid.gridColData}"/>
                    </div>
                </div>

                <div id="ui-tabs-2">
                    <div style="height: auto;">
                        <e:gridPanel gridType="${_gridType}" id="buGrid" name="buGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.buGrid.gridColData}"/>
                    </div>
                </div>
            </div></td></tr>
        </div>

    </e:window>
</e:ui>