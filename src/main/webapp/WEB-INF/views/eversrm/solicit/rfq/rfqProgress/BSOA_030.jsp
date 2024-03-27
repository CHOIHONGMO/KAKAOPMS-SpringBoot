<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/rfqProgress/";

    function init() {
        EVF.C("RFX_NUM").setValue('${param.rfxNum}');
        EVF.C("RFX_CNT").setValue('${param.rfxCnt}');
        EVF.C("RFX_TYPE").setValue('${param.rfxType}');
        getCloseDate();
    }

    function getCloseDate() {

        var store = new EVF.Store();
        store.load(baseUrl + "BSOA_030/getCloseDate", function() {
            var curCloseDate = this.getParameter('curCloseDate');
            curCloseDate = curCloseDate.replace(/\//g, "");
            var date = curCloseDate.split(" ", 2);
            var hour = date[1].split(":", 2);
            EVF.C("CLOSE_DATE").setValue(date[0]);
            EVF.C("CLOSE_HOURS").setValue(hour[0]);
            EVF.C("CLOSE_MINUTES").setValue(hour[1]);
        });
    }


    function doSave() {

    	
        var store = new EVF.Store();
        if(!store.validate()) return;
    	
        var fromDate = EVF.C('CLOSE_DATE').getValue();
        everDate.diffWithServerDate(fromDate, function(status, message) {
            if (status === '-1') {
                alert('${BSOA_030_CLOSE_DATE}');

            } else {
                if (!confirm("${msg.M0021}")) return;

                var store = new EVF.Store();
                store.load(baseUrl + "BSOA_030/doSave", function() {
                    alert(this.getResponseMessage());
                    opener.window["${param.callBackFunction}"]();
                    doClose();
                });
            }
        });
    }

    function doClose() {
        formUtil.close();
    }
	</script>

    <e:window id="BSOA_030" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">

        <e:inputHidden id='RFX_NUM' name="RFX_NUM" />
        <e:inputHidden id='RFX_CNT' name="RFX_CNT" />
        <e:inputHidden id='RFX_TYPE' name="RFX_TYPE" />
        <e:inputHidden id='GATE_CD' name="GATE_CD" />

        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="2" labelWidth="135">
            <e:row>
                <e:label for="CLOSE_DATE" title="${form_CLOSE_DATE_N}"/>
                <e:field>
                    <e:inputDate id="CLOSE_DATE" name="CLOSE_DATE" value="${form.CLOSE_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_CLOSE_DATE_R}" disabled="${form_CLOSE_DATE_D}" readOnly="${form_CLOSE_DATE_RO}" />
                    <e:select id="CLOSE_HOURS" name="CLOSE_HOURS" value="${form.CLOSE_HOURS}" options="${hoursCombo}" width="70" disabled="${form_CLOSE_HOURS_D}" readOnly="${form_CLOSE_HOURS_RO}" required="${form_CLOSE_HOURS_R}" placeHolder="" />
                    <e:text>${form_CLOSE_HOURS_N } </e:text>
                    <e:select id="CLOSE_MINUTES" name="CLOSE_MINUTES" value="${form.CLOSE_MINUTES}" options="${minutesCombo}" width="70" disabled="${form_CLOSE_MINUTES_D}" readOnly="${form_CLOSE_MINUTES_RO}" required="${form_CLOSE_MINUTES_R}" placeHolder="" />
                    <e:text>${form_CLOSE_MINUTES_N }</e:text>
                </e:field>
            </e:row>
            
            <e:row>
				<e:label for="EXTEND_RMK" title="${form_EXTEND_RMK_N}"/>
				<e:field>
				<e:inputText id="EXTEND_RMK" style="${imeMode}" name="EXTEND_RMK" value="${form.EXTEND_RMK}" width="300" maxLength="${form_EXTEND_RMK_M}" disabled="${form_EXTEND_RMK_D}" readOnly="${form_EXTEND_RMK_RO}" required="${form_EXTEND_RMK_R}"/>
				</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' data='${doSave_A }'/>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }'/>
        </e:buttonBar>
    </e:window>
</e:ui>