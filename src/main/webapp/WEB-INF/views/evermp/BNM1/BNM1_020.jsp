<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
	    
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	 <script type="text/javascript">
	        
	    var baseUrl = "/evermp/BNM1/BNM101/";

	    function init() {

	    }

	    function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            var rtnData = {
                rowId: "${param.rowId}",
                BUDGET_DEPT_CD: EVF.C("BUDGET_DEPT_CD").getValue(),
                BUDGET_DEPT_NM: EVF.C("BUDGET_DEPT_NM").getValue(),
                ACCOUNT_CD: EVF.C("ACCOUNT_CD").getValue(),
                ACCOUNT_NM: EVF.C("ACCOUNT_NM").getValue(),
                RECIPIENT_NM: EVF.C("RECIPIENT_NM").getValue(),
                RECIPIENT_DEPT_NM: EVF.C("RECIPIENT_DEPT_NM").getValue(),
                RECIPIENT_TEL_NO: EVF.C("RECIPIENT_TEL_NO").getValue(),
                RECIPIENT_CELL_NO: EVF.C("RECIPIENT_CELL_NO").getValue(),
                DELY_ZIP_CD: EVF.C("DELY_ZIP_CD").getValue(),
                DELY_ADDR_1: EVF.C("DELY_ADDR_1").getValue(),
                DELY_ADDR_2: EVF.C("DELY_ADDR_2").getValue(),
                REQ_TXT: EVF.C("REQ_TXT").getValue()
            };
            parent['${param.callBackFunction}'](rtnData);
			doClose();
	    }

        function onSerachAccDept() {
            var param = {
                callBackFunction: "setAccDept",
                custCd : "${ses.companyCd}",
                plantCd: "${ses.plantCd}"
            };
            everPopup.openCommonPopup(param, "SP0087");
        }

        function setAccDept(data) {
            EVF.C("BUDGET_DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("BUDGET_DEPT_NM").setValue(data.DEPT_NM);
        }

        function onSerachAccCode() {
        	var param = {
       			custCd: "${ses.companyCd}",
       			callBackFunction: "setAccCode"
        	};
        	everPopup.openCommonPopup(param, "SP0085");
        }

        function setAccCode(data) {
        	EVF.C("ACCOUNT_CD").setValue(data.ACCOUNT_CD);
            EVF.C("ACCOUNT_NM").setValue(data.ACCOUNT_NM);
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
                EVF.C("DELY_ZIP_CD").setValue(zipcd.ZIP_CD_5);
                EVF.C('DELY_ADDR_1').setValue(zipcd.ADDR1);
                EVF.C('DELY_ADDR_2').setValue(zipcd.ADDR2);
                EVF.C('DELY_ADDR_2').setFocus();
            }
        }

        function _checkTelNum() {
        	if(!everString.isTel(EVF.C("RECIPIENT_TEL_NO").getValue())) {
        		alert("${msg.M0128}");
        		EVF.C("RECIPIENT_TEL_NO").setValue("");
        	}
        }

        function _checkCellNum() {
        	if(!everString.isTel(EVF.C("RECIPIENT_CELL_NO").getValue())) {
        		alert("${msg.CELL_NUM_INVALID}");
        		EVF.C("RECIPIENT_CELL_NO").setValue("");
        	}
        }

        function doClose() {
			new EVF.ModalWindow().close(null);
		}

    </script>
	<e:window id="BNM1_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false">
            <e:row>
            	<e:label for="BUDGET_DEPT_CD" title="${form_BUDGET_DEPT_CD_N}"/>
		        <e:field>
		        	<e:search id="BUDGET_DEPT_CD" name="BUDGET_DEPT_CD" value="${param.BUDGET_DEPT_CD }" width="40%" maxLength="${form_BUDGET_DEPT_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'onSerachAccDept'}" disabled="${form_BUDGET_DEPT_CD_D}" readOnly="${form_BUDGET_DEPT_CD_RO}" required="${form_BUDGET_DEPT_CD_R}" />
		        	<e:inputText id="BUDGET_DEPT_NM" name="BUDGET_DEPT_NM" value="${param.BUDGET_DEPT_NM }" width="60%" maxLength="${form_BUDGET_DEPT_NM_M}" disabled="${form_BUDGET_DEPT_NM_D}" readOnly="${form_BUDGET_DEPT_NM_RO}" required="${form_BUDGET_DEPT_NM_R}" />
		        </e:field>
            	<e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}"/>
		        <e:field>
		        	<e:search id="ACCOUNT_CD" name="ACCOUNT_CD" value="${param.ACCOUNT_CD }" width="40%" maxLength="${form_ACCOUNT_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'onSerachAccCode'}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
		        	<e:inputText id="ACCOUNT_NM" name="ACCOUNT_NM" value="${param.ACCOUNT_NM }" width="60%" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
		        </e:field>
            </e:row>
            <e:row>
            	<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}"/>
		        <e:field>
		        	<e:inputText id="RECIPIENT_NM" name="RECIPIENT_NM" value="${empty param.RECIPIENT_NM ? ses.userNm : param.RECIPIENT_NM }" width="${form_RECIPIENT_NM_W }" maxLength="${form_RECIPIENT_NM_M}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO}" required="${form_RECIPIENT_NM_R}" />
		        </e:field>
            	<e:label for="RECIPIENT_DEPT_NM" title="${form_RECIPIENT_DEPT_NM_N}"/>
		        <e:field>
		        	<e:inputText id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM" value="${empty param.RECIPIENT_DEPT_NM ? ses.deptNm : param.RECIPIENT_DEPT_NM }" width="${form_RECIPIENT_DEPT_NM_W }" maxLength="${form_RECIPIENT_DEPT_NM_M}" disabled="${form_RECIPIENT_DEPT_NM_D}" readOnly="${form_RECIPIENT_DEPT_NM_RO}" required="${form_RECIPIENT_DEPT_NM_R}" />
		        </e:field>
            </e:row>
            <e:row>
            	<e:label for="RECIPIENT_TEL_NO" title="${form_RECIPIENT_TEL_NO_N}"/>
		        <e:field>
		        	<e:inputText id="RECIPIENT_TEL_NO" name="RECIPIENT_TEL_NO" value="${empty param.RECIPIENT_TEL_NO ? ses.telNum : param.RECIPIENT_TEL_NO }" width="${form_RECIPIENT_TEL_NO_W }" maxLength="${form_RECIPIENT_TEL_NO_M}" disabled="${form_RECIPIENT_TEL_NO_D}" readOnly="${form_RECIPIENT_TEL_NO_RO}" required="${form_RECIPIENT_TEL_NO_R}" onChange="_checkTelNum" />
		        </e:field>
            	<e:label for="RECIPIENT_CELL_NO" title="${form_RECIPIENT_CELL_NO_N}"/>
		        <e:field>
		        	<e:inputText id="RECIPIENT_CELL_NO" name="RECIPIENT_CELL_NO" value="${empty param.RECIPIENT_CELL_NO ? ses.cellNum : param.RECIPIENT_CELL_NO }" width="${form_RECIPIENT_CELL_NO_W }" maxLength="${form_RECIPIENT_CELL_NO_M}" disabled="${form_RECIPIENT_CELL_NO_D}" readOnly="${form_RECIPIENT_CELL_NO_RO}" required="${form_RECIPIENT_CELL_NO_R}" onChange="_checkCellNum" />
		        </e:field>
            </e:row>
            <e:row>
            	<e:label for="DELY_ZIP_CD" title="${form_DELY_ZIP_CD_N}"/>
		        <e:field colSpan="3">
		        	<e:search id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${empty param.DELY_ZIP_CD ? ses.zipCd : param.DELY_ZIP_CD }" width="140px" maxLength="${form_DELY_ZIP_CD_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchZipCd'}" disabled="${form_DELY_ZIP_CD_D}" readOnly="${form_DELY_ZIP_CD_RO}" required="${form_DELY_ZIP_CD_R}" />
		        </e:field>
            </e:row>
            <e:row>
            	<e:label for="DELY_ADDR_1" title="${form_DELY_ADDR_1_N}"/>
		        <e:field>
		        	<e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="${empty param.DELY_ADDR_1 ? ses.addr1 : param.DELY_ADDR_1 }" width="${form_DELY_ADDR_1_W }" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
		        </e:field>
		        <e:field colSpan="2">
		        	<e:inputText id="DELY_ADDR_2" name="DELY_ADDR_2" value="${empty param.DELY_ADDR_2 ? ses.addr2 : param.DELY_ADDR_2 }" width="${form_DELY_ADDR_2_W }" maxLength="${form_DELY_ADDR_2_M}" disabled="${form_DELY_ADDR_2_D}" readOnly="${form_DELY_ADDR_2_RO}" required="${form_DELY_ADDR_2_R}" />
		        </e:field>
            </e:row>
            <e:row>
                <e:label for="REQ_TXT" title="${form_REQ_TXT_N}"/>
                <e:field colSpan="3">
                    <e:textArea id="REQ_TXT" name="REQ_TXT" value="${param.REQ_TXT }" width="100%" height="230px" disabled="${form_REQ_TXT_D }" maxLength="${form_REQ_TXT_M }" required="${form_REQ_TXT_R }" readOnly="${form_REQ_TXT_RO }" />
                </e:field>
            </e:row>
        </e:searchPanel>

		<e:buttonBar align="right" width="100%">
		    <e:text style="color:black;font-weight:bold;">${BNM1_010_TITLE1}</e:text>
			<e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
			<e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" />
		</e:buttonBar>

	</e:window>
</e:ui>