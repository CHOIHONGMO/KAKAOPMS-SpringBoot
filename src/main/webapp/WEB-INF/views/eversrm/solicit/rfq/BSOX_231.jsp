<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var gridL;
    var gridR;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
    	gridL = EVF.C("gridL");
    	gridR = EVF.C("gridR");

    	gridL.setProperty('shrinkToFit', true);
    	gridR.setProperty('shrinkToFit', true);
        gridL.cellClickEvent(function(rowId, celName, value, iRow, iCol) {

        });

        // 정량만 있는 경우 평가자 세팅 제외
        var evTplCd = EVF.C('EV_TPL_CD').getValue();
        var scndEvTplCd = EVF.C('SCND_EV_TPL_CD').getValue();
        if ((evTplCd == '' || evTplCd == 'QTY') &&  (scndEvTplCd == '' || scndEvTplCd == 'QTY')) {
        	EVF.C('PLANT_CD').setDisabled(true);
        	EVF.C('USER_NM').setDisabled(true);

        	formUtil.setVisible(['doSearch'], false);
        }
    }

    //조회
    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([gridL]);
        store.load(baseUrl + "BSOX_231/doSearch", function() {
            if (gridL.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }
	function doSendRight() {
		if( gridL.isEmpty( gridL.getSelRowId() ) ) {
	        alert("${msg.M0004}");
	        return;
	    }
        var selAllRowDataL = gridL.getSelRowValue();

        for(k=0;k<selAllRowDataL.length;k++) {

        	var chk = true;
            var selAllRowDataR = gridR.getSelRowValue();
            for(t=0;t<selAllRowDataR.length;t++) {
				if (selAllRowDataL[k].USER_ID == selAllRowDataR[t].USER_ID) {
					chk = false;
					break;
				}
            }

        	if (chk == true) {
		        var rows = [
					{
						USER_ID : selAllRowDataL[k].USER_ID,
						EV_USER_ID : selAllRowDataL[k].USER_ID,
						USER_NM : selAllRowDataL[k].USER_NM,
						POSITION_NM : selAllRowDataL[k].POSITION_NM,
						PLANT_NM : selAllRowDataL[k].PLANT_NM,
						DEPT_NM : selAllRowDataL[k].DEPT_NM
					}
				];
				gridR.addRow(rows);
        	}


        }
    }
    function doClose() {
        formUtil.close();
    }
    function doSendLeft() {
    	var selRowIdR = gridR.getSelRowId();
    	for(var x in selRowIdR) {
            var rowIdR = selRowIdR[x];
            gridR.delRow(rowIdR);
    	}
    }

    function doSave() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		// 정성이 하나라도 있는 경우 : 평가자를 등록해야 함
		if ((EVF.C('EV_TPL_CD').getValue() == 'QUA' || EVF.C('SCND_EV_TPL_CD').getValue() == 'QUA') && gridR.getRowCount() == 0) {
			alert('${BSOX_231_9991}');
			return;
		}

    	if (!confirm("${msg.M8888}")) {  <%--처리하시겠습니까?--%>
			return;
		}

		store.setGrid([gridR]);
		store.getGridData(gridR, 'sel');
		store.load(baseUrl + 'SRM_231/doSave', function() {
			alert(this.getResponseMessage());
			opener.doSearch();
			window.close();
		});
    }

</script>


    <e:window id="BSOX_231" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${BSOX_231_0000}" labelWidth="${labelWidth}" labelAlign="190" columnCount="2" onEnter="doSearch">
			<e:row>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
                <e:field>
                    <e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty form.GATE_CD ? param.gateCd : form.GATE_CD}" />
                    <e:inputText id='RFX_NUM' name="RFX_NUM" value='${empty form.RFX_NUM ? param.rfxNum : form.RFX_NUM}' width='130' maxLength='${form_RFX_NUM_M }' required='${form_RFX_NUM_R }' readOnly='true' disabled='true' visible='${form_RFX_NUM_V }' />
                    <e:text>/</e:text>
                    <e:inputText id='RFX_CNT' name="RFX_CNT" align='right' value='${empty form.RFX_CNT ? param.rfxCnt : form.RFX_CNT}' width='40' required='${form_RFX_CNT_R }' readOnly='true' disabled='${form_RFX_CNT_D }' maxLength="${form_RFX_CNT_M}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE"  onChange="chPurchaseType"  name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
			</e:row>
			<e:row>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
                <e:field>
                    <e:inputText id='RFX_SUBJECT' style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width='100%' maxLength='${form_RFX_SUBJECT_M }' required='${form_RFX_SUBJECT_R }' readOnly='${form_RFX_SUBJECT_RO }' disabled='${form_RFX_SUBJECT_D }' visible='${form_RFX_SUBJECT_V }' />
                </e:field>
                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
                <e:field>
                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='${form_RFX_TYPE_D }' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
                    </e:select>
                </e:field>
			</e:row>
			<e:row>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" onChange="chVendorOpenType" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenType }" width="${inputTextWidth}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
                </e:field>

                <e:label for="SUBMIT_TYPE" title="${form_SUBMIT_TYPE_N}"/>
                <e:field>
                    <e:select id="SUBMIT_TYPE" onChange="clearTplNum" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="${inputTextWidth}" disabled="${form_SUBMIT_TYPE_D}" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>

			</e:row>
			<e:row>
		                <e:label for="PRC_PERCENT" title="${form_PRC_PERCENT_N}"/>
		                <e:field>
		                    <e:text>${BSOX_231_9009}</e:text>
		                    <e:inputNumber id="PRC_PERCENT"  width="50"  name="PRC_PERCENT" value="${form.PRC_PERCENT}" maxValue="${form_PRC_PERCENT_M}" decimalPlace="${form_PRC_PERCENT_NF}" disabled="${form_PRC_PERCENT_D}" readOnly="${form_PRC_PERCENT_RO}" required="${form_PRC_PERCENT_R}" />
		                    <e:text>% /</e:text>
		                    <e:inputNumber id="NOT_PRC_PERCENT"  width="50"  name="NOT_PRC_PERCENT" value="${form.NOT_PRC_PERCENT}" maxValue="${form_NOT_PRC_PERCENT_M}" decimalPlace="${form_NOT_PRC_PERCENT_NF}" disabled="${form_NOT_PRC_PERCENT_D}" readOnly="${form_NOT_PRC_PERCENT_RO}" required="${form_NOT_PRC_PERCENT_R}" />
		                    <e:text>%</e:text>
		                    <e:br/>
		                    <e:text>${BSOX_231_9010}</e:text>
		                    <e:inputNumber id="SCND_PRC_PERCENT"  width="50"  name="SCND_PRC_PERCENT" value="${form.SCND_PRC_PERCENT}" maxValue="${form_SCND_PRC_PERCENT_M}" decimalPlace="${form_SCND_PRC_PERCENT_NF}" disabled="${form_SCND_PRC_PERCENT_D}" readOnly="${form_SCND_PRC_PERCENT_RO}" required="${form_SCND_PRC_PERCENT_R}" />
		                    <e:text>% /</e:text>
		                    <e:inputNumber id="SCND_NOT_PRC_PERCENT"  width="50"  name="SCND_NOT_PRC_PERCENT" value="${form.SCND_NOT_PRC_PERCENT}" maxValue="${form_SCND_NOT_PRC_PERCENT_M}" decimalPlace="${form_SCND_NOT_PRC_PERCENT_NF}" disabled="${form_SCND_NOT_PRC_PERCENT_D}" readOnly="${form_SCND_NOT_PRC_PERCENT_RO}" required="${form_SCND_NOT_PRC_PERCENT_R}" />
		                    <e:text>%</e:text>
		                </e:field>
		                <e:label for="EV_TPL_NM" title="${form_EV_TPL_NM_N}"/>
		                <e:field>
		                    <e:text>${BSOX_231_9009}</e:text>
		                    <e:select id="EV_TPL_CD" name="EV_TPL_CD" value="${form.EV_TPL_CD}" options="${evTplCd}" width="${inputTextWidth}" disabled="${form_EV_TPL_CD_D}" readOnly="${form_EV_TPL_CD_RO}" required="${form_EV_TPL_CD_R}" placeHolder="" />
		                    <e:text>&nbsp;</e:text>
		                    <e:search id="EV_TPL_NM" style="${imeMode}" name="EV_TPL_NM" value="${form.EV_TPL_NM}" width="50%" maxLength="${form_EV_TPL_NM_M}" onIconClick="${form_EV_TPL_NM_RO ? 'everCommon.blank' : 'openTplNum'}" disabled="${form_EV_TPL_NM_D}" readOnly="${form_EV_TPL_NM_RO}" required="${form_EV_TPL_NM_R}" />
		                    <e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM" value="${form.EV_TPL_NUM}"/>
		                    <e:br/>
		                    <e:text>${BSOX_231_9010}</e:text>
							<e:select id="SCND_EV_TPL_CD" name="SCND_EV_TPL_CD" value="${form.SCND_EV_TPL_CD}" options="${evTplCd}" width="${inputTextWidth}" disabled="true" readOnly="${from_SCND_EV_TPL_CD_RO}" required="${from_SCND_EV_TPL_CD_R}" placeHolder="" />
		                    <e:text>&nbsp;</e:text>
							<e:search id="SCND_EV_TPL_NM" style="${imeMode}" name="SCND_EV_TPL_NM" value="${form.SCND_EV_TPL_NM}" width="50%" maxLength="${from_SCND_EV_TPL_NM_M}" onIconClick="${from_SCND_EV_TPL_NM_RO ? 'everCommon.blank' : 'openTplNumScnd'}" disabled="true" readOnly="${from_SCND_EV_TPL_NM_RO}" required="${from_SCND_EV_TPL_NM_R}" />
		                    <e:inputHidden id="SCND_EV_TPL_NUM" name="SCND_EV_TPL_NUM" value="${form.SCND_EV_TPL_NUM}"/>
		                </e:field>

			</e:row>
        </e:searchPanel>


        <e:searchPanel id="form2" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="140" columnCount="2" onEnter="doSearch">
			<e:row>
				<e:label for="PLANT_CD" title="${form2_PLANT_CD_N}"/>
				<e:field>
				<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form2_PLANT_CD_D}" readOnly="${form2_PLANT_CD_RO}" required="${form2_PLANT_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="USER_NM" title="${form2_USER_NM_N}"/>
				<e:field>
				<e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" value="${form.USER_NM}" width="${inputTextWidth}" maxLength="${form2_USER_NM_M}" disabled="${form2_USER_NM_D}" readOnly="${form2_USER_NM_RO}" required="${form2_USER_NM_R}"/>
				</e:field>
			</e:row>
		</e:searchPanel>

        <e:buttonBar align="right">
            <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A }'/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
           	<e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }'/>
        </e:buttonBar>
        <e:panel height="fit" width="100%">
            <e:panel width="49%">
                <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" height="fit" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
            </e:panel>
            <e:panel width="2%" height="100%">
                <div style="width: 100%; margin-top: 200px; vertical-align: middle;" align="center">
                    <div id="doSendRight" style="background: url(/images/eversrm/button/thumb_next.png) no-repeat; width: 13px; height: 22px; display: inline-block; cursor: pointer;" onclick="doSendRight();">&nbsp;</div>
                    <div id="doSendLeft" style="background: url(/images/eversrm/button/thumb_prev.png) no-repeat; width: 13px; height: 22px; display: inline-block; margin-top: 10px; cursor: pointer;" onclick="doSendLeft();">&nbsp;</div>
                </div>
            </e:panel>
            <e:panel width="49%">
                <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" height="fit" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
            </e:panel>
        </e:panel>

	</e:window>
</e:ui>