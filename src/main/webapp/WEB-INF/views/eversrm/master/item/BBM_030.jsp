<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/master/item/";

		function init() {

			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.cellClickEvent(function(rowId, colId, value) {

			    if (colId == 'ITEM_CD') {
		            var param = {
		           		itemCd : grid.getCellValue(rowId,"ITEM_CD"),
						detailView: '${!havePermission}',
                        pcMaster : 'Y'
		            };
		            everPopup.openItemDetailInformation(param);
				}
                if (colId == 'VENDOR_NM') {
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, "VENDOR_CD"),
                        'detailView': true,
                        'popupFlag': true
                    };
                    // 협력사 기본정보 팝업
                    everPopup.vendorInfo(param);
				}
            });

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			grid.setProperty('shrinkToFit', false);
			grid.setProperty('multiSelect', false);
            _setMakerOption();

        }

        function _setMakerOption() {

            if(EVF.V('BUSINESS_TYPE') == '100') <%-- IT --%> {
                EVF.C("BRAND_CD").setDisabled(true);
                EVF.C("AC_ITEM_CLS_NM").setDisabled(true);
                EVF.C("MAKER").setDisabled(false);
            } else if(EVF.V('BUSINESS_TYPE') == '200') {
                EVF.C("BRAND_CD").setDisabled(false);
                EVF.C("AC_ITEM_CLS_NM").setDisabled(false);
                EVF.C("MAKER").setDisabled(false);
			}else{
                EVF.C("BRAND_CD").setDisabled(true);
                EVF.C("AC_ITEM_CLS_NM").setDisabled(true);
                EVF.C("MAKER").setDisabled(true);
			}

            var store = new EVF.Store();
            store.load('/common/combo/getMakerOptions', function() {
                EVF.C('MAKER').setOptions(this.getParameter('makerOptions'));
			}, false);
        }

        function doSearch() {
            if(EVF.V("ITEM_CLS_NM")==""){
                EVF.C("ITEM_CLS1").setValue('');
                EVF.C("ITEM_CLS2").setValue('');
                EVF.C("ITEM_CLS3").setValue('');
                EVF.C("ITEM_CLS4").setValue('');
            }
        	var store = new EVF.Store();
            if(!store.validate()) return;
        	store.setGrid([grid]);
            store.load(baseUrl + 'BBM_030/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function doRequestItem() {
		    var url = '/siis/M02/M02_001/view';
		    var param = {
		        detailView: false
			};
            everPopup.openWindowPopup(url, 1000, 700, param, 'NOTICELIST');
		}

        function _getAcItemClsNm() <%-- 손익분류 --%> {
            var popupUrl = "/siis/M01/M01_001P/view";
            var param = {
                callBackFunction: '_setAcItemClsNm',
				TopNodeYN : true
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setAcItemClsNm(data) {

            data = JSON.parse(data);

            EVF.C('AC_ITEM_CLS1').setValue(data.ITEM_CLS1);
            EVF.C('AC_ITEM_CLS2').setValue(data.ITEM_CLS2);
            EVF.C('AC_ITEM_CLS3').setValue(data.ITEM_CLS3);
            EVF.C('AC_ITEM_CLS4').setValue(data.ITEM_CLS4);
            EVF.C('AC_ITEM_CLS_NM').setValue(data.ITEM_CLS_PATH_NM);

        }

        function _getVendors() {

            var param = {
                callBackFunction: "_setVendor"
            };
            everPopup.openCommonPopup(param, 'SP0025');
        }

        function _setVendor(data) {

            EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
        }

        function _getItemClsNm() <%-- 품목분류 조회 --%> {

            if(EVF.isEmpty(EVF.V('BUSINESS_TYPE'))) {
                return alert('${BBM_030_0001}');
            }

            var popupUrl = "/eversrm/master/item/BBM_011/view";
            var param = {
                callBackFunction : "_setItemClassNm",
                businessType: EVF.V('BUSINESS_TYPE'),
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true
            };

            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNm(data) <%-- 품목분류 조회 후 콜백함수 --%> {

            if(data==null){
                cleanItemClass();
			}else{
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);
                EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);
                EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);
                EVF.C('ITEM_CLS_NM').setValue(data.ITEM_CLS_PATH_NM);
			}

        }

        function cleanItemClass() {
        		EVF.C("ITEM_CLS1").setValue('');
        		EVF.C("ITEM_CLS2").setValue('');
        		EVF.C("ITEM_CLS3").setValue('');
        		EVF.C("ITEM_CLS4").setValue('');
        		EVF.C("ITEM_CLS_NM").setValue('');
        }

        function cleanAcClass() {
        		EVF.C("AC_ITEM_CLS1").setValue('');
        		EVF.C("AC_ITEM_CLS2").setValue('');
        		EVF.C("AC_ITEM_CLS3").setValue('');
        		EVF.C("AC_ITEM_CLS4").setValue('');
        		EVF.C("AC_ITEM_CLS_NM").setValue('');
        }
    </script>
	<e:window id="BBM_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
		<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
		<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
		<e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
		<e:inputHidden id="AC_ITEM_CLS1" name="AC_ITEM_CLS1" />
		<e:inputHidden id="AC_ITEM_CLS2" name="AC_ITEM_CLS2" />
		<e:inputHidden id="AC_ITEM_CLS3" name="AC_ITEM_CLS3" />
		<e:inputHidden id="AC_ITEM_CLS4" name="AC_ITEM_CLS4" />

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}"/>
				<e:field>
					<e:select id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="" options="${businessTypeOptions}" width="100%" disabled="${form_BUSINESS_TYPE_D}" readOnly="${form_BUSINESS_TYPE_RO}" required="${form_BUSINESS_TYPE_R}" placeHolder="" onChange="_setMakerOption" />
				</e:field>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="STOCK_ITEM_YN" title="${form_STOCK_ITEM_YN_N}"/>
				<e:field>
					<e:select id="STOCK_ITEM_YN" name="STOCK_ITEM_YN" value="" options="${stockItemYnOptions}" width="100%" disabled="${form_STOCK_ITEM_YN_D}" readOnly="${form_STOCK_ITEM_YN_RO}" required="${form_STOCK_ITEM_YN_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="MAKER" title="${form_MAKER_N}"/>
				<e:field>
					<e:select id="MAKER" name="MAKER" value="" options="${makerOptions}" width="100%" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
				</e:field>
				<e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}"/>
				<e:field>
					<e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="" width="100%" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="30%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : '_getVendors'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}"  width="70%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:label for="BRAND_CD" title="${form_BRAND_CD_N}"/>
				<e:field>
					<e:select id="BRAND_CD" name="BRAND_CD" value="" options="${brandCdOptions}" width="100%" disabled="${form_BRAND_CD_D}" readOnly="${form_BRAND_CD_RO}" required="${form_BRAND_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="ORDER_HALT_FLAG" title="${form_ORDER_HALT_FLAG_N}"/>
				<e:field>
					<e:select id="ORDER_HALT_FLAG" name="ORDER_HALT_FLAG" value="${empty form.ORDER_HALT_FLAG ? '0' : form.ORDER_HALT_FLAG}" options="${orderHaltFlagOptions}" width="100%" disabled="${form_ORDER_HALT_FLAG_D}" readOnly="${form_ORDER_HALT_FLAG_RO}" required="${form_ORDER_HALT_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
				<e:field>
					<e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="100%" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" onBlur="cleanItemClass" onChange="cleanItemClass"/>
				</e:field>
				<e:label for="AC_ITEM_CLS_NM" title="${form_AC_ITEM_CLS_NM_N}"/>
				<e:field>
					<e:search id="AC_ITEM_CLS_NM" name="AC_ITEM_CLS_NM" value="" width="100%" maxLength="${form_AC_ITEM_CLS_NM_M}" onIconClick="_getAcItemClsNm" disabled="${form_AC_ITEM_CLS_NM_D}" readOnly="${form_AC_ITEM_CLS_NM_RO}" required="${form_AC_ITEM_CLS_NM_R}" onBlur="cleanAcClass" onChange="cleanAcClass"/>
				</e:field>
				<e:label for="VAT_CD" title="${form_VAT_CD_N}"/>
				<e:field>
					<e:select id="VAT_CD" name="VAT_CD" value="" options="${vatCdOptions}" width="100%" disabled="${form_VAT_CD_D}" readOnly="${form_VAT_CD_RO}" required="${form_VAT_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<e:button id="doRequestItem" name="doRequestItem" label="${doRequestItem_N}" onClick="doRequestItem" disabled="${doRequestItem_D}" visible="${doRequestItem_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>