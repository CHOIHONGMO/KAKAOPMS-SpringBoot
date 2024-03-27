<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        function init() {
        }
        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function doClose() {

            if(opener) {
                window.open("", "_self");
                window.close();
            } else if(parent) {
                new EVF.ModalWindow().close(null);
            }
        }

		function doApply() {


            var data = {
        			 VENDOR_NM             :    EVF.V('VENDOR_NM')
        			,VENDOR_CD             :    EVF.V('VENDOR_CD')
        			,CONT_UNIT_PRICE       :    EVF.V('CONT_UNIT_PRICE')
        			,SALES_UNIT_PRICE      :    EVF.V('SALES_UNIT_PRICE')
        			,MOQ_QTY               :    EVF.V('MOQ_QTY')
        			,RV_QTY                :    EVF.V('RV_QTY')
        			,LEAD_TIME             :    EVF.V('LEAD_TIME')
        			,CUR                   :    EVF.V('CUR')
        			,DELY_TYPE             :    EVF.V('DELY_TYPE')
        			,DEAL_CD               :    EVF.V('DEAL_CD')
        			,VALID_FROM_DATE       :    EVF.V('VALID_FROM_DATE')
        			,VALID_TO_DATE         :    EVF.V('VALID_TO_DATE')
                };

			opener.setApplyAll(data)
		}

    </script>

    <e:window id="IM03_009P" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar id="tab2_btn1" align="right" width="100%">
			<e:button id="Apply" name="Apply" label="${Apply_N}" onClick="doApply" disabled="${Apply_D}" visible="${Apply_V}"/>
			<e:button id="Close" name="Close" label="${Close_N}" onClick="doClose" disabled="${Close_D}" visible="${Close_V}"/>
        </e:buttonBar>


        <e:searchPanel id="form1" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false">
			<e:row>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD"/>
				</e:field>
				<e:label for="CONT_UNIT_PRICE" title="${form_CONT_UNIT_PRICE_N}"/>
				<e:field>
				<e:inputNumber id="CONT_UNIT_PRICE" name="CONT_UNIT_PRICE" value="" width="${form_CONT_UNIT_PRICE_W}" maxValue="${form_CONT_UNIT_PRICE_M}" decimalPlace="${form_CONT_UNIT_PRICE_NF}" disabled="${form_CONT_UNIT_PRICE_D}" readOnly="${form_CONT_UNIT_PRICE_RO}" required="${form_CONT_UNIT_PRICE_R}" />
				</e:field>
				<e:label for="SALES_UNIT_PRICE" title="${form_SALES_UNIT_PRICE_N}"/>
				<e:field>
				<e:inputNumber id="SALES_UNIT_PRICE" name="SALES_UNIT_PRICE" value="" width="${form_SALES_UNIT_PRICE_W}" maxValue="${form_SALES_UNIT_PRICE_M}" decimalPlace="${form_SALES_UNIT_PRICE_NF}" disabled="${form_SALES_UNIT_PRICE_D}" readOnly="${form_SALES_UNIT_PRICE_RO}" required="${form_SALES_UNIT_PRICE_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="MOQ_QTY" title="${form_MOQ_QTY_N}"/>
				<e:field>
				<e:inputNumber id="MOQ_QTY" name="MOQ_QTY" value="1" width="${form_MOQ_QTY_W}" maxValue="${form_MOQ_QTY_M}" decimalPlace="${form_MOQ_QTY_NF}" disabled="${form_MOQ_QTY_D}" readOnly="${form_MOQ_QTY_RO}" required="${form_MOQ_QTY_R}" />
				</e:field>
				<e:label for="RV_QTY" title="${form_RV_QTY_N}"/>
				<e:field>
				<e:inputNumber id="RV_QTY" name="RV_QTY" value="1" width="${form_RV_QTY_W}" maxValue="${form_RV_QTY_M}" decimalPlace="${form_RV_QTY_NF}" disabled="${form_RV_QTY_D}" readOnly="${form_RV_QTY_RO}" required="${form_RV_QTY_R}" />
				</e:field>
				<e:label for="LEAD_TIME" title="${form_LEAD_TIME_N}"/>
				<e:field>
				<e:inputNumber id="LEAD_TIME" name="LEAD_TIME" value="5" width="${form_LEAD_TIME_W}" maxValue="${form_LEAD_TIME_M}" decimalPlace="${form_LEAD_TIME_NF}" disabled="${form_LEAD_TIME_D}" readOnly="${form_LEAD_TIME_RO}" required="${form_LEAD_TIME_R}" />
				</e:field>

			</e:row>
			<e:row>
				<e:label for="CUR" title="${form_CUR_N}"/>
				<e:field>
				<e:select id="CUR" name="CUR" value="KRW" options="${curOptions}" width="${form_CUR_W}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" />
				</e:field>
				<e:label for="DELY_TYPE" title="${form_DELY_TYPE_N}"/>
				<e:field>
				<e:select id="DELY_TYPE" name="DELY_TYPE" value="" options="${delyTypeOptions}" width="${form_DELY_TYPE_W}" disabled="${form_DELY_TYPE_D}" readOnly="${form_DELY_TYPE_RO}" required="${form_DELY_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
				<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="VALID_FROM_DATE" title="${form_VALID_FROM_DATE_N}"/>
				<e:field>
				<e:inputDate id="VALID_FROM_DATE" name="VALID_FROM_DATE" toDate="VALID_TO_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_VALID_FROM_DATE_R}" disabled="${form_VALID_FROM_DATE_D}" readOnly="${form_VALID_FROM_DATE_RO}" />
				</e:field>
				<e:label for="VALID_TO_DATE" title="${form_VALID_TO_DATE_N}"/>
				<e:field colSpan="3">
				<e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE" fromDate="VALID_FROM_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_VALID_TO_DATE_R}" disabled="${form_VALID_TO_DATE_D}" readOnly="${form_VALID_TO_DATE_RO}" />
				</e:field>
			</e:row>
        </e:searchPanel>

    </e:window>
</e:ui>