<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/eversrm/main/MSI_030/";

        function init() {

        }

        function doSearch() {
            removeSpace();
            var store = new EVF.Store();
            store.load(baseUrl + "doSearch", function() {

            });
        }

        function doFindID() {

            var store = new EVF.Store();
            if(!store.validate()) return;
            if (!chkFieldEnter()) {
                alert("${MSI_030_ENTER_INFO}");
                return;
            }
            removeSpace();

            store.load(baseUrl + "doFindID", function() {
                var formValues = JSON.parse(this.getParameter('formDatas'));
                if (formValues != null) {
                    if (formValues['MSG_RETURN'] != "") {
                        alert(formValues['MSG_RETURN']);
                    } else {
                        EVF.C("USER_ID").setValue(formValues['USER_ID']);
                        var strUserFound = '${MSI_030_USERFOUND}'.replace("@@USER_ID", formValues.USER_ID);
                        alert(strUserFound);
                    }
                }
            });
        }

        function doFindPassword() {
            <%--if (!formUtil.validHandler(['form'], "${msg.M0054 }")) return;--%>
            if (EVF.C("USER_ID").getValue() == "") {
                alert("${MSI_030_ENTER_USER_ID}");
                return;
            }
            if (EVF.C("EMAIL").getValue() == "") {
                alert("${MSI_030_ENTER_EMAIL}");
                return;
            }
            removeSpace();
            var store = new EVF.Store();
            if(!store.validate()) { return; }
            store.load(baseUrl + "doFindPassword", function() {
                alert(this.getResponseMessage());
            });
        }

        function chkFieldEnter() {
            if (everString.lrTrim(EVF.C("EMAIL").getValue()) == ""
                    && everString.lrTrim(EVF.C("CELL_NUM").getValue()) == ""
                    && everString.lrTrim(EVF.C("COMPANY_NM").getValue()) == ""
                    && everString.lrTrim(EVF.C("IRS_NUM").getValue()) == "") {
                return false;
            }
            return true;
        }

        function removeSpace() {
            EVF.C("USER_NM").setValue(everString.lrTrim(EVF.C("USER_NM").getValue()).toUpperCase());
            EVF.C("EMAIL").setValue(everString.lrTrim(EVF.C("EMAIL").getValue()).toUpperCase());
            EVF.C("CELL_NUM").setValue(everString.lrTrim(EVF.C("CELL_NUM").getValue()).toUpperCase());
            EVF.C("COMPANY_NM").setValue(everString.lrTrim(EVF.C("COMPANY_NM").getValue()).toUpperCase());
            EVF.C("IRS_NUM").setValue(everString.lrTrim(EVF.C("IRS_NUM").getValue()).toUpperCase());
            EVF.C("USER_ID").setValue(everString.lrTrim(EVF.C("USER_ID").getValue()).toUpperCase());
        }

        function doClose() {
            formUtil.close();
        }
    </script>
    <e:window id="MSI_030" onReady="init" initData="${initData}" title="${fullScreenName}" margin="3px">
        <e:searchPanel id="form" title="사용자정보 입력" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1">
            <e:row>
                <e:label for="IRS_NUM" title="${form_IRS_NUM_N}" />
                <e:field>
                    <e:inputText id='IRS_NUM' style='ime-mode:inactive' name="IRS_NUM" label='${form_IRS_NUM_N }' width='100%' maxLength='${form_IRS_NUM_M }' required='${form_IRS_NUM_R }' readOnly='${form_IRS_NUM_RO }' disabled='${form_IRS_NUM_D }' visible='${form_IRS_NUM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="USER_NM" title="${form_USER_NM_N}" />
                <e:field>
                    <e:inputText id='USER_NM' style="${imeMode}" name="USER_NM" label='${form_USER_NM_N }' width='100%' maxLength='${form_USER_NM_M }' required='${form_USER_NM_R }' readOnly='${form_USER_NM_RO }' disabled='${form_USER_NM_D }' visible='${form_USER_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="EMAIL" title="${form_EMAIL_N}" />
                <e:field>
                    <e:inputText id='EMAIL' style='ime-mode:inactive' name="EMAIL" label='${form_EMAIL_N }' width='100%' maxLength='${form_EMAIL_M }' required='${form_EMAIL_R }' readOnly='${form_EMAIL_RO }' disabled='${form_EMAIL_D }' visible='${form_EMAIL_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}" />
                <e:field>
                    <e:inputText id='CELL_NUM' style='ime-mode:inactive' name="CELL_NUM" label='${form_CELL_NUM_N }' width='100%' maxLength='${form_CELL_NUM_M }' required='${form_CELL_NUM_R }' readOnly='${form_CELL_NUM_RO }' disabled='${form_CELL_NUM_D }' visible='${form_CELL_NUM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}" />
                <e:field>
                    <e:inputText id='COMPANY_NM' style="${imeMode}" name="COMPANY_NM" label='${form_COMPANY_NM_N }'  width='100%' maxLength='${form_COMPANY_NM_M }' required='${form_COMPANY_NM_R }' readOnly='${form_COMPANY_NM_RO }' disabled='${form_COMPANY_NM_D }' visible='${form_COMPANY_NM_V }'/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="USER_ID" title="${form_USER_ID_N}" />
                <e:field>
                    <e:inputText id='USER_ID' style='ime-mode:inactive' name="USER_ID" label='${form_USER_ID_N }' width='100%' maxLength='${form_USER_ID_M }' required='${form_USER_ID_R }' readOnly='${form_USER_ID_RO }' disabled='${form_USER_ID_D }' visible='${form_USER_ID_V }'/>
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="center">
            <e:button label='${doFindID_N }' id='doFindID'  onClick='doFindID' disabled='${doFindID_D }' visible='${doFindID_V }' data='${doFindID_A }'/>
            <e:button label='${doFindPassword_N }' id='doFindPassword' onClick='doFindPassword' disabled='${doFindPassword_D }' visible='${doFindPassword_V }' data='${doFindPassword_A }'/>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }'/>
        </e:buttonBar>
    </e:window>
</e:ui>