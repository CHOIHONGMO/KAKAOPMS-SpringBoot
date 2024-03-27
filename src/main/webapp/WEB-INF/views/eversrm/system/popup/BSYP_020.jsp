<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
        var addParam = [];
        var baseUrl = "/eversrm/system/popup/";

        function init() {
            if(window.opener != undefined) {
                EVF.C('doClose').setVisible(false);
            } else {
                EVF.C('doClose').setVisible(false);
            }
        }

        function delete2() {
            if (!confirm("${msg.M0013 }")) return;
            var store = new EVF.Store();
            store.load(baseUrl + 'doDelete', function(){
                alert(this.getResponseMessage());
                if ('${param.POPUPFLAG}' == 'Y' ){
                    opener.search();
                    closePopup();

                }
            });
        }

        function save() {
            if (!confirm("${msg.M0021 }")) return;
            var store = new EVF.Store();
            store.load(baseUrl + 'doSave', function(){
                alert(this.getResponseMessage());
                if ('${param.POPUPFLAG}' == 'Y' ){
                    opener.search();
                }
            });
        }

        function verify() {
            var store = new EVF.Store();
            store.load(baseUrl + 'doVerify', function(){
                alert(this.getResponseMessage());
            });
        }

        function search() {
            location.href =baseUrl + 'BSYP_020/view.so?COMMON_ID='+EVF.C('COMMON_ID').getValue()+'&DATABASE_CD='+EVF.C('DATABASE_CD').getValue()+'&POPUPFLAG=${param.POPUPFLAG}';
        }

        function insTitleText() {
            if (!checkCommonId()) return;
            var param = {
                "multi_cd": "TT",
                "common_id": EVF.C('COMMON_ID').getValue(),
                "callBackFunction": "setCommonTitle"
            };
            everPopup.openMultiLanguagePopup(param);
        }

        function setCommonTitle(multiLangReturn) {
            EVF.C("TITLE_TEXT").setValue(multiLangReturn.multiNm);
        }

        function insSearchCon() {

            if (!checkCommonId()) return;
            var param = {
                "multi_cd": "ST",
                "common_id": EVF.C('COMMON_ID').getValue(),
                "callBackFunction": "setCommonSearch"
            };
            everPopup.openMultiLanguagePopup(param);
        }

        function setCommonSearch(multiLangReturn) {
            EVF.C("SEARCH_CONDITION_TEXT").setValue(multiLangReturn.multiNm);
        }

        function insListItem() {
            if (!checkCommonId()) return;
            var param = {
                "multi_cd": "LT",
                "common_id": EVF.C('COMMON_ID').getValue(),
                "callBackFunction": "setCommonList"
            };
            everPopup.openMultiLanguagePopup(param);
        }

        function setCommonList(multiLangReturn) {
            EVF.C("LIST_ITEM_TEXT").setValue(multiLangReturn.multiNm);
        }

        function insCommonDesc() {
            if (!checkCommonId()) return;
            var param = {
                "multi_cd": "CC",
                "common_id": EVF.C('COMMON_ID').getValue(),
                "callBackFunction": "setCommonDesc"
            };
            everPopup.openMultiLanguagePopup(param);
        }

        function setCommonDesc(multiLangReturn) {
            EVF.C("COMMON_DESC").setValue(multiLangReturn.multiNm);
        }

        function checkCommonId() {
            if (EVF.C('COMMON_ID').getValue() == "") {
                alert("${BSYP_020_MSG_0001 }");
                return false;
            } else {
                return true;
            }
        }

        function closePopup() {
            window.close();
        }

    </script>
    <e:window id="BSYP_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 5px">

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="search" />
            <e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="save" />
            <e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="delete2" />
            <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="closePopup" />
        </e:buttonBar>
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="150" width="100%" columnCount="2">
            <e:row>
                <e:label for="COMMON_ID" title="${form_COMMON_ID_N }" />
                <e:field>
                    <e:inputText id="COMMON_ID" name="COMMON_ID"   readOnly="${form_COMMON_ID_RO }"   maxLength="${form_COMMON_ID_M}"  value="${detailData.COMMON_ID }" width="100%" required="${form_COMMON_ID_R }" disabled="${form_COMMON_ID_D }" />
                </e:field>
                <e:label for="COMMON_DESC" title="${form_COMMON_DESC_N }" />
                <e:field>
                    <e:search id="COMMON_DESC" name="COMMON_DESC"  readOnly="${form_COMMON_DESC_RO }"  maxLength="${form_COMMON_DESC_M }" value="${detailData.COMMON_DESC}" width="100%" required="${form_COMMON_DESC_R }" disabled="${form_COMMON_DESC_D }"  onIconClick="${param.detailView ? 'everCommon.blank' : 'insCommonDesc'}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DATABASE_CD" title="${form_DATABASE_CD_N }" />
                <e:field>
                    <e:select id="DATABASE_CD" name="DATABASE_CD"  readOnly="${form_DATABASE_CD_RO }"  value="${detailData.DATABASE_CD}"  options="${databaseCodeData}" width="${form_DATABASE_CD_W }" required="${form_DATABASE_CD_R }" disabled="${form_DATABASE_CD_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="TYPE_CD" title="${form_TYPE_CD_N }" />
                <e:field>
                    <e:select id="TYPE_CD" name="TYPE_CD"  value="${detailData.TYPE_CD}"  readOnly="${form_TYPE_CD_RO }"   options="${typeOfData}" width="${form_TYPE_CD_W }" required="${form_TYPE_CD_R }" disabled="${form_TYPE_CD_D }" onFocus="onFocus" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="USE_FLAG" title="${form_USE_FLAG_N }" />
                <e:field>
                    <e:select id="USE_FLAG" name="USE_FLAG"  value="${detailData.USE_FLAG}"  readOnly="${form_USE_FLAG_RO }"  options="${yesNoData}" width="${form_USE_FLAG_W }" required="${form_USE_FLAG_R }" disabled="${form_USE_FLAG_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="AUTO_SEARCH_FLAG" title="${form_AUTO_SEARCH_FLAG_N }" />
                <e:field>
                    <e:select id="AUTO_SEARCH_FLAG" name="AUTO_SEARCH_FLAG"  value="${detailData.AUTO_SEARCH_FLAG}"  readOnly="${form_AUTO_SEARCH_FLAG_RO }"   options="${yesNoData}" width="${form_AUTO_SEARCH_FLAG_W }" required="${form_AUTO_SEARCH_FLAG_R }" disabled="${form_AUTO_SEARCH_FLAG_D }" onFocus="onFocus" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="TITLE_TEXT" title="${form_TITLE_TEXT_N }" />
                <e:field>
                    <e:search id="TITLE_TEXT" name="TITLE_TEXT" value="${detailData.TITLE_TEXT}" maxLength="${form_TITLE_TEXT_M }" readOnly="${form_TITLE_TEXT_RO }"  width="100%" required="${form_TITLE_TEXT_R }" disabled="${form_TITLE_TEXT_D }"  onIconClick="${param.detailView ? 'everCommon.blank' : 'insTitleText'}" />
                </e:field>
                <e:label for="SEARCH_CONDITION_TEXT" title="${form_SEARCH_CONDITION_TEXT_N }" />
                <e:field>
                    <e:search id="SEARCH_CONDITION_TEXT" name="SEARCH_CONDITION_TEXT" maxLength="${form_SEARCH_CONDITION_TEXT_M }" readOnly="${form_SEARCH_CONDITION_TEXT_RO }"  value="${detailData.SEARCH_CONDITION_TEXT}" width="100%" required="${form_SEARCH_CONDITION_TEXT_R }" disabled="${form_SEARCH_CONDITION_TEXT_D }"  onIconClick="${param.detailView ? 'everCommon.blank' : 'insSearchCon'}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="LIST_ITEM_CD" title="${form_LIST_ITEM_CD_N }" alt="GATE_CD(L:50)###COMPANY_CD" />
                <e:field>
                    <e:inputText id="LIST_ITEM_CD" name="LIST_ITEM_CD"  readOnly="${form_LIST_ITEM_CD_RO }"  maxLength="${form_LIST_ITEM_CD_M}"    value="${detailData.LIST_ITEM_CD}" width="100%" required="${form_LIST_ITEM_CD_R }" disabled="${form_LIST_ITEM_CD_D }" />
                </e:field>
                <e:label for="LIST_ITEM_TEXT" title="${form_LIST_ITEM_TEXT_N }" />
                <e:field>
                    <e:search id="LIST_ITEM_TEXT" name="LIST_ITEM_TEXT"  readOnly="${form_LIST_ITEM_TEXT_RO }" maxLength="${form_LIST_ITEM_TEXT_M }" value="${detailData.LIST_ITEM_TEXT}" width="100%" required="${form_LIST_ITEM_TEXT_R }" disabled="${form_LIST_ITEM_TEXT_D }"  onIconClick="${param.detailView ? 'everCommon.blank' : 'insListItem'}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="WINDOW_WIDTH" title="${form_WINDOW_WIDTH_N }" />
                <e:field>
                    <e:inputText id="WINDOW_WIDTH" name="WINDOW_WIDTH"   readOnly="${form_WINDOW_WIDTH_RO }"   maxLength="${form_WINDOW_WIDTH_M}"   value="${detailData.WINDOW_WIDTH}" width="${form_WINDOW_WIDTH_W }" required="${form_WINDOW_WIDTH_R }" disabled="${form_WINDOW_WIDTH_D }" />
                </e:field>
                <e:label for="WINDOW_HEIGHT" title="${form_WINDOW_HEIGHT_N }" />
                <e:field>
                    <e:inputText id="WINDOW_HEIGHT" name="WINDOW_HEIGHT" readOnly="${form_WINDOW_HEIGHT_RO }"   maxLength="${form_WINDOW_HEIGHT_M}"  value="${detailData.WINDOW_HEIGHT}" width="${form_WINDOW_HEIGHT_W }" required="${form_WINDOW_HEIGHT_R }" disabled="${form_WINDOW_HEIGHT_D }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SQL_TEXT" title="${form_SQL_TEXT_N }"  />
                <e:field colSpan="3">
                    <e:textArea id="SQL_TEXT" name="SQL_TEXT" width="100%" height="380px" readOnly="${form_SQL_TEXT_RO }" maxLength="${form_SQL_TEXT_M }"  required="${form_SQL_TEXT_R }" disabled="${form_SQL_TEXT_D }" value="${detailData.SQL_TEXT}" style="font-family: 'Consolas' !important" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REG_DATE" title="${form_REG_DATE_N }" />
                <e:field>
                    <e:inputText id="REG_DATE" name="REG_DATE" maxLength="${form_REG_DATE_M}" value="${detailData.REG_DATE}" width="${inputDateWidth }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="false" />
                </e:field>
                <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N }" />
                <e:field>
                    <e:inputText id="REG_USER_NM" name="REG_USER_NM" maxLength="${form_REG_USER_NM_M}" value="${detailData.REG_USER_NM}" width="${form_REG_USER_NM_W }" required="${form_REG_USER_NM_R }" readOnly="${form_REG_USER_NM_RO }" disabled="false" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MOD_DATE" title="${form_MOD_DATE_N }" />
                <e:field>
                    <e:inputText id="MOD_DATE" name="MOD_DATE" maxLength="${form_MOD_DATE_M}" value="${detailData.MOD_DATE}" width="${inputDateWidth }" required="${form_MOD_DATE_R }" readOnly="${form_MOD_DATE_RO }" disabled="false" />
                </e:field>
                <e:label for="CHANGE_USER_NM" title="${form_CHANGE_USER_NM_N }" />
                <e:field>
                    <e:inputText id="CHANGE_USER_NM" name="CHANGE_USER_NM" maxLength="${form_CHANGE_USER_NM_M}" value="${detailData.MOD_USER_NM}" width="${form_CHANGE_USER_NM_W }" required="${form_CHANGE_USER_NM_R }" readOnly="${form_CHANGE_USER_NM_RO }" disabled="false" />
                </e:field>
            </e:row>
        </e:searchPanel>
    </e:window>
</e:ui>