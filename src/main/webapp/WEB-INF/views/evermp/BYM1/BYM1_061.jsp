<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var baseUrl = "/evermp/BYM1/BYM1_061/";

	function init() {

        var VC_NO = EVF.C("VC_NO").getValue();
        var USER_TYPE = EVF.C("USER_TYPE").getValue();
        var PROGRESS_CD = EVF.C("PROGRESS_CD").getValue();
        var USER_EQ = EVF.C("USER_EQ").getValue();
        var CTRL_CD = EVF.C("CTRL_CD").getValue();
        var USER_DS_EQ = EVF.C("USER_DS_EQ").getValue();

        if("" === VC_NO) {
            EVF.C("Save").setDisabled(false);
            EVF.C("Update").setDisabled(true);
            EVF.C("Delete").setDisabled(true);
		} else {
            EVF.C("Save").setDisabled(true);

            if("N" === USER_EQ) {
                EVF.C("Update").setDisabled(true);
                EVF.C("Delete").setDisabled(true);
            } else if("Y" === USER_EQ) {
                if("100" === PROGRESS_CD) {
                    EVF.C("Update").setDisabled(false);
                    EVF.C("Delete").setDisabled(false);
                }else if("200" === PROGRESS_CD || "300" === PROGRESS_CD || "400" === PROGRESS_CD) {
                    EVF.C("Update").setDisabled(true);
                    EVF.C("Delete").setDisabled(true);
                } else {
                    EVF.C("Update").setDisabled(false);
                    EVF.C("Delete").setDisabled(true);
                }
            }
		}

        if("S" === USER_TYPE || "B" === USER_TYPE) {

            if("N" === USER_EQ) {
                EVF.C("VOC_TYPE").setReadOnly(true);
                EVF.C("PH_DATE").setReadOnly(true);
                EVF.C("ORDER_NO").setReadOnly(true);
                EVF.C("ITEM_CD").setReadOnly(true);
                EVF.C("REQ_RMK").setReadOnly(true);
                EVF.C("ATTACH_FILE_NO").setReadOnly(true);

            } else if("Y" === USER_EQ) {

                if("100" === PROGRESS_CD) {
                    EVF.C("VOC_TYPE").setReadOnly(false);
                    EVF.C("PH_DATE").setReadOnly(false);
                    EVF.C("ORDER_NO").setReadOnly(false);
                    EVF.C("ITEM_CD").setReadOnly(false);
                    EVF.C("REQ_RMK").setReadOnly(false);
                    EVF.C("ATTACH_FILE_NO").setReadOnly(false);
                }else if("200" === PROGRESS_CD || "300" === PROGRESS_CD || "400" === PROGRESS_CD) {
                    EVF.C("VOC_TYPE").setReadOnly(true);
                    EVF.C("PH_DATE").setReadOnly(true);
                    EVF.C("ORDER_NO").setReadOnly(true);
                    EVF.C("ITEM_CD").setReadOnly(true);
                    EVF.C("REQ_RMK").setReadOnly(true);
                    EVF.C("ATTACH_FILE_NO").setReadOnly(true);
                }
            }

		}
	}

	function doSave() {

        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!confirm("${msg.M0021}")) { return; }

        store.doFileUpload(function() {
			store.load(baseUrl + "bym1061_doSave", function() {
				alert(this.getResponseMessage());
				if (parent["${callbackFunction}"]) {
					parent["${callbackFunction}"]();
					new EVF.ModalWindow().close(null);
				} else if(opener) {
					opener["${callbackFunction}"]();
					window.close();
				}
			});
        });
    }

    function doUpdate() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!confirm("${msg.M0012}")) { return; }

        store.doFileUpload(function() {
			store.load(baseUrl + "bym1061_doUpdate", function() {
				alert(this.getResponseMessage());
				if (parent["${callbackFunction}"]) {
					parent["${callbackFunction}"]();
					new EVF.ModalWindow().close(null);
				} else if(opener) {
					opener["${callbackFunction}"]();
                    window.close();
				}
			});
		});
    }

    function doDelete() {
        var store = new EVF.Store();

        if (!store.validate()) { return; }
        if(!confirm("${msg.M0013}")) { return; }

        store.doFileUpload(function() {
            store.load(baseUrl + "bym1061_doDelete", function() {
                alert(this.getResponseMessage());
                if (parent["${callbackFunction}"]) {
                    parent["${callbackFunction}"]();
                    new EVF.ModalWindow().close(null);
                } else if(opener) {
                    opener["${callbackFunction}"]();
                    window.close();
                }
            });
        });
    }

 </script>
	<e:window id="BYM1_061" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:inputHidden id="USER_TYPE" name="USER_TYPE" value="${USER_TYPE}"/>
		<e:inputHidden id="REQ_COM_CD" name="REQ_COM_CD" value="${REQ_COM_CD}"/>
		<e:inputHidden id="REQ_COM_TYPE" name="REQ_COM_TYPE" value="${REQ_COM_TYPE}" />
		<e:inputHidden id="REQ_DATE" name="REQ_DATE" value="${REQ_DATE}" />
		<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${DATA.PROGRESS_CD}" />
		<e:inputHidden id="USER_EQ" name="USER_EQ" value="${USER_EQ}" />
		<e:inputHidden id="USER_DS_EQ" name="USER_DS_EQ" value="${USER_DS_EQ}" />
		<e:inputHidden id="CTRL_CD" name="CTRL_CD" value="${CTRL_CD}" />
		<e:inputHidden id="REQ_COMPANY_NM" name="REQ_COMPANY_NM" value="${REQ_COMPANY_NM}" />


		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="VC_NO" title="${form_VC_NO_N}" />
				<e:field>
					<e:inputText id="VC_NO" name="VC_NO" value="${VC_NO}" width="${form_VC_NO_W}" maxLength="${form_VC_NO_M}" disabled="${form_VC_NO_D}" readOnly="${form_VC_NO_RO}" required="${form_VC_NO_R}" />
				</e:field>
				<e:label for="REQ_COM_TEXT" title="${form_REQ_COM_TEXT_N}" />
				<e:field>
					<e:inputText id="REQ_COM_TEXT" name="REQ_COM_TEXT" value="${REQ_COM_TEXT}" width="${form_REQ_COM_TEXT_W}" maxLength="${form_REQ_COM_TEXT_M}" disabled="${form_REQ_COM_TEXT_D}" readOnly="${form_REQ_COM_TEXT_RO}" required="${form_REQ_COM_TEXT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REQ_INFO_TEXT" title="${form_REQ_INFO_TEXT_N}" />
				<e:field>
					<e:inputText id="REQ_INFO_TEXT" name="REQ_INFO_TEXT" value="${REQ_INFO_TEXT}" width="${form_REQ_INFO_TEXT_W}" maxLength="${form_REQ_INFO_TEXT_M}" disabled="${form_REQ_INFO_TEXT_D}" readOnly="${form_REQ_INFO_TEXT_RO}" required="${form_REQ_INFO_TEXT_R}" />
				</e:field>
				<e:label for="REQ_INFO_DEPT_TEXT" title="${form_REQ_INFO_DEPT_TEXT_N}" />
				<e:field>
					<e:inputText id="REQ_INFO_DEPT_TEXT" name="REQ_INFO_DEPT_TEXT" value="${REQ_INFO_DEPT_TEXT}" width="${form_REQ_INFO_DEPT_TEXT_W}" maxLength="${form_REQ_INFO_DEPT_TEXT_M}" disabled="${form_REQ_INFO_DEPT_TEXT_D}" readOnly="${form_REQ_INFO_DEPT_TEXT_RO}" required="${form_REQ_INFO_DEPT_TEXT_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="VOC_TYPE" title="${form_VOC_TYPE_N}"/>
				<e:field>
					<e:select id="VOC_TYPE" name="VOC_TYPE" value="${DATA.VOC_TYPE}" options="${vocTypeOptions}" width="${form_VOC_TYPE_W}" disabled="${form_VOC_TYPE_D}" readOnly="${form_VOC_TYPE_RO}" required="${form_VOC_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="PH_DATE" title="${form_PH_DATE_N}"/>
				<e:field>
					<e:inputDate id="PH_DATE" name="PH_DATE" value="${PH_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_PH_DATE_R}" disabled="${form_PH_DATE_D}" readOnly="${form_PH_DATE_RO}" fromDate="PH_DATE"/>
				</e:field>
			</e:row>

			<e:row>
				<e:label for="ORDER_NO" title="${form_ORDER_NO_N}" />
				<e:field>
					<e:inputText id="ORDER_NO" name="ORDER_NO" value="${DATA.ORDER_NO}" width="${form_ORDER_NO_W}" maxLength="${form_ORDER_NO_M}" disabled="${form_ORDER_NO_D}" readOnly="${form_ORDER_NO_RO}" required="${form_ORDER_NO_R}" />
				</e:field>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${DATA.ITEM_CD}" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REQ_RMK" title="${form_REQ_RMK_N}"/>
				<e:field colSpan="3">
					<e:textArea id="REQ_RMK" name="REQ_RMK" value="${DATA.REQ_RMK}" height="90px" width="${form_REQ_RMK_W}" maxLength="${form_REQ_RMK_M}" disabled="${form_REQ_RMK_D}" readOnly="${form_REQ_RMK_RO}" required="${form_REQ_RMK_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="ATTACH_FILE_NO" title="${form_ATTACH_FILE_NO_N}" />
				<e:field colSpan="3">
					<e:fileManager id="ATTACH_FILE_NO" name="ATTACH_FILE_NO" readOnly="${form_ATTACH_FILE_NO_RO}"  fileId="${DATA.ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="MP" height="90px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="V_RECV_DATE" title="${form_V_RECV_DATE_N}" />
				<e:field>
					<e:inputText id="V_RECV_DATE" name="V_RECV_DATE" value="${DATA.V_RECV_DATE}" width="${form_V_RECV_DATE_W}" maxLength="${form_V_RECV_DATE_M}" disabled="${form_V_RECV_DATE_D}" readOnly="${form_V_RECV_DATE_RO}" required="${form_V_RECV_DATE_R}" />
				</e:field>
				<e:label for="PROGRESS_NM" title="${form_PROGRESS_NM_N}" />
				<e:field>
					<e:inputText id="PROGRESS_NM" name="PROGRESS_NM" value="${DATA.PROGRESS_NM}" width="${form_PROGRESS_NM_W}" maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="DS_USER_NM" title="${form_DS_USER_NM_N}" />
				<e:field>
					<e:inputText id="DS_USER_NM" name="DS_USER_NM" value="${DATA.DS_USER_NM}" width="${form_DS_USER_NM_W}" maxLength="${form_DS_USER_NM_M}" disabled="${form_DS_USER_NM_D}" readOnly="${form_DS_USER_NM_RO}" required="${form_DS_USER_NM_R}" />
				</e:field>
				<e:label for="CD_DATE" title="${form_CD_DATE_N}" />
				<e:field>
					<e:inputText id="CD_DATE" name="CD_DATE" value="${DATA.CD_DATE}" width="${form_CD_DATE_W}" maxLength="${form_CD_DATE_M}" disabled="${form_CD_DATE_D}" readOnly="${form_CD_DATE_RO}" required="${form_CD_DATE_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="DS_DATE" title="${form_DS_DATE_N}" />
				<e:field>
					<e:inputText id="DS_DATE" name="DS_DATE" value="${DATA.DS_DATE}" width="${form_DS_DATE_W}" maxLength="${form_DS_DATE_M}" disabled="${form_DS_DATE_D}" readOnly="${form_DS_DATE_RO}" required="${form_DS_DATE_R}" />
				</e:field>
				<e:label for="RUB_TYPE_NM" title="${form_RUB_TYPE_NM_N}" />
				<e:field>
					<e:inputText id="RUB_TYPE_NM" name="RUB_TYPE_NM" value="${DATA.RUB_TYPE_NM}" width="${form_RUB_TYPE_NM_W}" maxLength="${form_RUB_TYPE_NM_M}" disabled="${form_RUB_TYPE_NM_D}" readOnly="${form_RUB_TYPE_NM_RO}" required="${form_RUB_TYPE_NM_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="DF_RMK" title="${form_DF_RMK_N}"/>
				<e:field colSpan="3">
					<e:textArea id="DF_RMK" name="DF_RMK" value="${DATA.DF_RMK}" height="90px" width="${form_DF_RMK_W}" maxLength="${form_DF_RMK_M}" disabled="${form_DF_RMK_D}" readOnly="${form_DF_RMK_RO}" required="${form_DF_RMK_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DS_ATTACH_FILE_NO" title="${form_DS_ATTACH_FILE_NO_N}" />
				<e:field colSpan="3">
					<e:fileManager id="DS_ATTACH_FILE_NO" name="DS_ATTACH_FILE_NO" readOnly="${form_DS_ATTACH_FILE_NO_RO}"  fileId="${DATA.DS_ATTACH_FILE_NO}" downloadable="true" width="100%" bizType="MP" height="90px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
			<e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
			<e:button id="Update" name="Update" label="${Update_N}" onClick="doUpdate" disabled="${Update_D}" visible="${Update_V}"/>
			<e:button id="Delete" name="Delete" label="${Delete_N}" onClick="doDelete" disabled="${Delete_D}" visible="${Delete_V}"/>
		</e:buttonBar>
	</e:window>
</e:ui>