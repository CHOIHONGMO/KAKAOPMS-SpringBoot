<!--
 * BSYO_020 : 회사단위
 * 시스템관리 > 조직관리 > 회사단위
-->

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    	var baseUrl = "/eversrm/system/org/";
    	var grid = {};
    	var saveCd;

		function init() {
			grid = EVF.C('grid');
			grid.setProperty('multiselect', false);

			grid.cellClickEvent(function(rowid, colId, value) {
				if(colId == "BUYER_CD") {
					setFormData(rowid);
	            }
			});
			grid.setProperty('panelVisible', ${panelVisible});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


			doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'companyUnit/selectCompany', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                } else {
                	if (saveCd != null) {
                		var rowIds = grid.getSelRowId();
                		for (var i = 0, length = grid.getSelRowCount(); i < length; i++) {
	                        if (grid.getCellValue(rowIds[i], "BUYER_CD") == saveCd) {
	                            setFormData(rowIds[i]);
	                            return;
	                        }
	                    }
	                }
                	setFormData(0);
                }
            });
        }

        function doSave() {

	        var store = new EVF.Store();
	        if(!store.validate()) return;

				if (!confirm("${msg.M0021 }")) return;

		        saveCd = EVF.C('buyerCd').getValue();
		        var store = new EVF.Store();
		        if(!store.validate()) return;

	        	store.doFileUpload(function() {
			        store.load(baseUrl + 'companyUnit/saveCompany', function () {
				        alert(this.getResponseMessage());
				        doSearch();
			        });
		        });
        }

		function doDelete() {

			//if (formUtil.validHandler(['form'], "${msg.M0054 }")) {

				if (!confirm("${msg.M0013 }")) return;

				saveCd = null;
				var store = new EVF.Store();
	        	store.load(baseUrl + 'companyUnit/deleteCompany', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	        //}
	    }

        function clearForm() {
	        if (!confirm("${msg.M0029}")) return;
	        EVF.C('gateCd').setValue("");
			EVF.C('buyerCd').setValue("");
			EVF.C('langCd').setValue("");
			EVF.C('buyerNm').setValue("");
			EVF.C('buyerNmEng').setValue("");
			EVF.C('countryCd').setValue("");
			EVF.C('cityNm').setValue("");
			EVF.C('zipCd').setValue("");
			EVF.C('irsNum').setValue("");
			EVF.C('address').setValue("");
			EVF.C('addressEng').setValue("");
			EVF.C('telNum').setValue("");
			EVF.C('faxNum').setValue("");
			EVF.C('ceoUserNm').setValue("");
			EVF.C('ceoUserNmEng').setValue("");
			EVF.C('businessType').setValue("");
			EVF.C('industryType').setValue("");
			EVF.C('foundationDate').setValue("");
			EVF.C('cur').setValue("");
			EVF.C('companyRegNum').setValue("");
			EVF.C('dunsNum').setValue("");
			EVF.C('gmtCd').setValue("");
			EVF.C('regDate').setValue("");
			EVF.C('regUserId').setValue("");
			EVF.C('gateCdOri').setValue("");
			EVF.C('buyerCdOri').setValue("");
			EVF.C('GATE_CD_ORI').setValue("");
			EVF.C('BUYER_CD_ORI').setValue("");
			EVF.C('ACCOUNT_UNIT_CD').setValue("");
			EVF.C('ZIP_CD_5').setValue("");
			EVF.C('USE_FLAG').setChecked(true);
			EVF.C('IRS_SUB_ZIP_CD').setValue("");
			EVF.C('SUB_ZIP_CD_5').setValue("");
			EVF.C('IRS_SUB_NO').setValue("");
			EVF.C('IRS_SUB_ADDR').setValue("");
			EVF.C('IRS_SUB_NM').setValue("");
        }
        function setFormData(rowid) {
 			EVF.C('gateCd').setValue(grid.getCellValue(rowid, "GATE_CD"));
			EVF.C('buyerCd').setValue(grid.getCellValue(rowid, "BUYER_CD"));
			EVF.C('langCd').setValue(grid.getCellValue(rowid, "LANG_CD"));
			EVF.C('buyerNm').setValue(grid.getCellValue(rowid, "BUYER_NM"));
			EVF.C('buyerNmEng').setValue(grid.getCellValue(rowid, "BUYER_NM_ENG"));
			EVF.C('countryCd').setValue(grid.getCellValue(rowid, "COUNTRY_CD"));
			EVF.C('cityNm').setValue(grid.getCellValue(rowid, "CITY_NM"));
			EVF.C('zipCd').setValue(grid.getCellValue(rowid, "ZIP_CD"));
			EVF.C('irsNum').setValue(grid.getCellValue(rowid, "IRS_NUM"));
			EVF.C('address').setValue(grid.getCellValue(rowid, "ADDR"));
			EVF.C('addressEng').setValue(grid.getCellValue(rowid, "ADDR_ENG"));
			EVF.C('telNum').setValue(grid.getCellValue(rowid, "TEL_NUM"));
			EVF.C('faxNum').setValue(grid.getCellValue(rowid, "FAX_NUM"));
			EVF.C('ceoUserNm').setValue(grid.getCellValue(rowid, "CEO_USER_NM"));
			EVF.C('ceoUserNmEng').setValue(grid.getCellValue(rowid, "CEO_USER_NM_ENG"));
			EVF.C('businessType').setValue(grid.getCellValue(rowid, "BUSINESS_TYPE"));
			EVF.C('industryType').setValue(grid.getCellValue(rowid, "INDUSTRY_TYPE"));
			EVF.C('foundationDate').setValue(grid.getCellValue(rowid, "FOUNDATION_DATE"));
			EVF.C('cur').setValue(grid.getCellValue(rowid, "CUR"));
			EVF.C('companyRegNum').setValue(grid.getCellValue(rowid, "COMPANY_REG_NUM"));
			EVF.C('dunsNum').setValue(grid.getCellValue(rowid, "DUNS_NUM"));
			EVF.C('gmtCd').setValue(grid.getCellValue(rowid, "GMT_CD"));
			EVF.C('regDate').setValue(grid.getCellValue(rowid, "REG_DATE"));
			EVF.C('regUserId').setValue(grid.getCellValue(rowid, "REG_USER_NM"));
			EVF.C('gateCdOri').setValue(grid.getCellValue(rowid, "GATE_CD"));
			EVF.C('buyerCdOri').setValue(grid.getCellValue(rowid, "BUYER_CD_ORI"));
			EVF.C('GATE_CD_ORI').setValue(grid.getCellValue(rowid, "GATE_CD_ORI"));
			EVF.C('BUYER_CD_ORI').setValue(grid.getCellValue(rowid, "BUYER_CD_ORI"));
			EVF.C('ACCOUNT_UNIT_CD').setValue(grid.getCellValue(rowid, "ACCOUNT_UNIT_CD"));
			EVF.C('ZIP_CD_5').setValue(grid.getCellValue(rowid, "ZIP_CD_5"));
			if (grid.getCellValue(rowid, "USE_FLAG") == 'Y') {
				EVF.C('USE_FLAG').setChecked(true);
			} else {
				EVF.C('USE_FLAG').setChecked(false);
			}
			EVF.C('IRS_SUB_ZIP_CD').setValue(grid.getCellValue(rowid, "IRS_SUB_ZIP_CD"));
			EVF.C('SUB_ZIP_CD_5').setValue(grid.getCellValue(rowid, "SUB_ZIP_CD_5"));
			EVF.C('IRS_SUB_NO').setValue(grid.getCellValue(rowid, "IRS_SUB_NO"));
			EVF.C('IRS_SUB_ADDR').setValue(grid.getCellValue(rowid, "IRS_SUB_ADDR"));
			EVF.C('IRS_SUB_NM').setValue(grid.getCellValue(rowid, "IRS_SUB_NM"));
	        // EVF.C("CI_FILE_NUM").getUploadedFileInfo('IMG', grid.getCellValue(rowid, "CI_FILE_NUM"));
	        EVF.C("CI_FILE_NUM").setValue(grid.getCellValue(rowid, "CI_FILE_NUM"));
		}

		function searchZipCode() {

        	var url = '/common/code/BADV_020/view';
        	var param = {
            	callBackFunction: "setZipCode"
        	};
        	//everPopup.openWindowPopup(url, 700, 600, param);
        	everPopup.jusoPop(url, param);
        }
        function setZipCode(data) {
        	EVF.C("zipCd").setValue(data.ZIP_CD);
			EVF.C("ZIP_CD_5").setValue(data.ZIP_CD_5);
        	EVF.C("address").setValue(data.ADDR);
        }

		function searchZipCodeSub() {

        	var url = '/common/code/BADV_020/view';
        	var param = {
            	callBackFunction: "setZipCodeSub"
        	};
        	//everPopup.openWindowPopup(url, 700, 600, param);
        	everPopup.jusoPop(url, param);
        }
        function setZipCodeSub(data) {
        	EVF.C("IRS_SUB_ZIP_CD").setValue(data.ZIP_CD);
			EVF.C("SUB_ZIP_CD_5").setValue(data.ZIP_CD_5);
        	EVF.C("IRS_SUB_ADDR").setValue(data.ADDR);
        }

    </script>
    <e:window id="BSYO_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <%--
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Clear" name="Clear" label="${Clear_N }" disabled="${Clear_D }" onClick="clearForm" />
            --%>
        </e:buttonBar>

    	<e:panel id="leftPanel" height="fit" width="35%">
    		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="98%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    	</e:panel>

    	<e:panel id="rightPanel" height="fit" width="65%">
		<e:searchPanel id="form" title="${form_caption_form_N}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
	        <e:row>
                <e:label for="gateCd" title="${form_gateCd_N}"></e:label>
                <e:field colSpan="3">
 					<e:select id="gateCd" width="100%" name="gateCd" options="${gateCdList}" required="${form_gateCd_R }" disabled="${form_gateCd_D }" readOnly="${form_gateCd_RO }" value="100"></e:select>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="buyerCd" title="${form_buyerCd_N}"></e:label>
                <e:field>
					<e:inputText id="buyerCd" style='ime-mode:inactive' name="buyerCd" width="100%" maxLength="${form_buyerCd_M }" required="${form_buyerCd_R }" readOnly="${form_buyerCd_RO }" disabled="${form_buyerCd_D}" visible="${form_buyerCd_V}" ></e:inputText>
                </e:field>
                <e:label for="langCd" title="${form_langCd_N}"></e:label>
                <e:field>
 					<e:select id="langCd" name="langCd" width="100%" options="${languageCdList}" required="${form_langCd_R }" disabled="${form_langCd_D }" readOnly="${form_langCd_RO }" value="${st_default}"></e:select>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="buyerNm" title="${form_buyerNm_N}"></e:label>
                <e:field>
					<e:inputText id="buyerNm" name="buyerNm" style="${imeMode}" width="100%" maxLength="${form_buyerNm_M }" required="${form_buyerNm_R }" readOnly="${form_buyerNm_RO }" disabled="${form_buyerNm_D}" visible="${form_buyerNm_V}" ></e:inputText>
                </e:field>
                <e:label for="buyerNmEng" title="${form_buyerNmEng_N}"></e:label>
                <e:field>
					<e:inputText id="buyerNmEng" style='ime-mode:inactive' name="buyerNmEng" width="100%" maxLength="${form_buyerNmEng_M }" required="${form_buyerNmEng_R }" readOnly="${form_buyerNmEng_RO }" disabled="${form_buyerNmEng_D}" visible="${form_buyerNmEng_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="countryCd" title="${form_countryCd_N}"></e:label>
                <e:field>
 					<e:select id="countryCd" name="countryCd" width="100%" options="${countryCdList}" required="${form_countryCd_R }" disabled="${form_countryCd_D }" readOnly="${form_countryCd_RO }" value="${st_default}"></e:select>
                </e:field>
                <e:label for="cityNm" title="${form_cityNm_N}"></e:label>
                <e:field>
					<e:inputText id="cityNm" style="${imeMode}" name="cityNm" width="100%" maxLength="${form_cityNm_M }" required="${form_cityNm_R }" readOnly="${form_cityNm_RO }" disabled="${form_cityNm_D}" visible="${form_cityNm_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="zipCd" title="${form_zipCd_N}"></e:label>
                <e:field>
					<e:search id="zipCd" name="zipCd" width="100%" onIconClick="searchZipCode" maxLength="${form_zipCd_M }" required="${form_zipCd_R }" readOnly="${form_zipCd_RO }" disabled="${form_zipCd_D}" visible="${form_zipCd_V}" />
					<e:inputHidden id="ZIP_CD_5" name="ZIP_CD_5" />
                </e:field>
                <e:label for="irsNum" title="${form_irsNum_N}"></e:label>
                <e:field>
					<e:inputText id="irsNum" name="irsNum" width="100%" maxLength="${form_irsNum_M }" required="${form_irsNum_R }" readOnly="${form_irsNum_RO }" disabled="${form_irsNum_D}" visible="${form_irsNum_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="address" title="${form_address_N}"></e:label>
                <e:field>
					<e:inputText id="address" style="${imeMode}" name="address" width="100%" maxLength="${form_address_M }" required="${form_address_R }" readOnly="${form_address_RO }" disabled="${form_address_D}" visible="${form_address_V}" ></e:inputText>
                </e:field>
                <e:label for="addressEng" title="${form_addressEng_N}"></e:label>
                <e:field>
					<e:inputText id="addressEng" style='ime-mode:inactive' name="addressEng" width="100%" maxLength="${form_addressEng_M }" required="${form_addressEng_R }" readOnly="${form_addressEng_RO }" disabled="${form_addressEng_D}" visible="${form_addressEng_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="IRS_SUB_ZIP_CD" title="${form_IRS_SUB_ZIP_CD_N}"></e:label>
                <e:field>
					<e:search id="IRS_SUB_ZIP_CD" name="IRS_SUB_ZIP_CD" width="100%" onIconClick="searchZipCodeSub" maxLength="${form_IRS_SUB_ZIP_CD_M }" required="${form_IRS_SUB_ZIP_CD_R }" readOnly="${form_IRS_SUB_ZIP_CD_RO }" disabled="${form_IRS_SUB_ZIP_CD_D}" visible="${form_IRS_SUB_ZIP_CD_V}" />
					<e:inputHidden id="SUB_ZIP_CD_5" name="SUB_ZIP_CD_5" />
                </e:field>
                <e:label for="IRS_SUB_NO" title="${form_IRS_SUB_NO_N}"></e:label>
                <e:field>
					<e:inputText id="IRS_SUB_NO" name="IRS_SUB_NO" width="100%" maxLength="${form_IRS_SUB_NO_M }" required="${form_IRS_SUB_NO_R }" readOnly="${form_IRS_SUB_NO_RO }" disabled="${form_IRS_SUB_NO_D}" visible="${form_IRS_SUB_NO_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="IRS_SUB_ADDR" title="${form_IRS_SUB_ADDR_N}"></e:label>
                <e:field>
					<e:inputText id="IRS_SUB_ADDR" style="${imeMode}" name="IRS_SUB_ADDR" width="100%" maxLength="${form_IRS_SUB_ADDR_M }" required="${form_IRS_SUB_ADDR_R }" readOnly="${form_IRS_SUB_ADDR_RO }" disabled="${form_IRS_SUB_ADDR_D}" visible="${form_IRS_SUB_ADDR_V}" ></e:inputText>
                </e:field>
                <e:label for="IRS_SUB_NM" title="${form_IRS_SUB_NM_N}"></e:label>
                <e:field>
					<e:inputText id="IRS_SUB_NM" style="${imeMode}" name="IRS_SUB_NM" width="100%" maxLength="${form_IRS_SUB_NM_M }" required="${form_IRS_SUB_NM_R }" readOnly="${form_IRS_SUB_NM_RO }" disabled="${form_IRS_SUB_NM_D}" visible="${form_IRS_SUB_NM_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="telNum" title="${form_telNum_N}"></e:label>
                <e:field>
					<e:inputText id="telNum" name="telNum" width="100%" maxLength="${form_telNum_M }" required="${form_telNum_R }" readOnly="${form_telNum_RO }" disabled="${form_telNum_D}" visible="${form_telNum_V}" ></e:inputText>
                </e:field>
                <e:label for="faxNum" title="${form_faxNum_N}"></e:label>
                <e:field>
					<e:inputText id="faxNum" name="faxNum" width="100%" maxLength="${form_faxNum_M }" required="${form_faxNum_R }" readOnly="${form_faxNum_RO }" disabled="${form_faxNum_D}" visible="${form_faxNum_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="ceoUserNm" title="${form_ceoUserNm_N}"></e:label>
                <e:field>
					<e:inputText id="ceoUserNm" style="${imeMode}" name="ceoUserNm" width="100%" maxLength="${form_ceoUserNm_M }" required="${form_ceoUserNm_R }" readOnly="${form_ceoUserNm_RO }" disabled="${form_ceoUserNm_D}" visible="${form_ceoUserNm_V}" ></e:inputText>
                </e:field>
                <e:label for="ceoUserNmEng" title="${form_ceoUserNmEng_N}"></e:label>
                <e:field>
					<e:inputText id="ceoUserNmEng" style='ime-mode:inactive' name="ceoUserNmEng" width="100%" maxLength="${form_ceoUserNmEng_M }" required="${form_ceoUserNmEng_R }" readOnly="${form_ceoUserNmEng_RO }" disabled="${form_ceoUserNmEng_D}" visible="${form_ceoUserNmEng_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="businessType" title="${form_businessType_N}"></e:label>
                <e:field>
					<e:inputText id="businessType" style="${imeMode}" name="businessType" width="100%" maxLength="${form_businessType_M }" required="${form_businessType_R }" readOnly="${form_businessType_RO }" disabled="${form_businessType_D}" visible="${form_businessType_V}" ></e:inputText>
                </e:field>
                <e:label for="industryType" title="${form_industryType_N}"></e:label>
                <e:field>
					<e:inputText id="industryType" style="${imeMode}"  name="industryType" width="100%" maxLength="${form_industryType_M }" required="${form_industryType_R }" readOnly="${form_industryType_RO }" disabled="${form_industryType_D}" visible="${form_industryType_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="foundationDate" title="${form_foundationDate_N}"/>
                <e:field>
                <e:inputDate id="foundationDate" name="foundationDate" value="${form.foundationDate}" width="${inputDateWidth}" datePicker="true" required="${form_foundationDate_R}" disabled="${form_foundationDate_D}" readOnly="${form_foundationDate_RO}" />
                </e:field>
                <e:label for="cur" title="${form_cur_N}"></e:label>
                <e:field>
 					<e:select id="cur" name="cur" width="100%" options="${currencyList}" required="${form_cur_R }" disabled="${form_cur_D }" readOnly="${form_cur_RO }" value="${st_default}" ></e:select>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="companyRegNum" title="${form_companyRegNum_N}"></e:label>
                <e:field>
					<e:inputText id="companyRegNum" name="companyRegNum" width="100%" maxLength="${form_companyRegNum_M }" required="${form_companyRegNum_R }" readOnly="${form_companyRegNum_RO }" disabled="${form_companyRegNum_D}" visible="${form_companyRegNum_V}" ></e:inputText>
                </e:field>
                <e:label for="dunsNum" title="${form_dunsNum_N}"></e:label>
                <e:field>
					<e:inputText id="dunsNum" name="dunsNum" width="100%" maxLength="${form_dunsNum_M }" required="${form_dunsNum_R }" readOnly="${form_dunsNum_RO }" disabled="${form_dunsNum_D}" visible="${form_dunsNum_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="gmtCd" title="${form_gmtCd_N}"></e:label>
                <e:field>
 					<e:select id="gmtCd" name="gmtCd" width="100%" options="${gmtCdList}" required="${form_gmtCd_R }" disabled="${form_gmtCd_D }" readOnly="${form_gmtCd_RO }" value="${st_default}" ></e:select>
                </e:field>
				<e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
				<e:field>
                    <e:check id='USE_FLAG' name="USE_FLAG" value="1" checked="${form.USE_FLAG eq '1' ? 'true' : 'false'}" width='${inputTextWidth }' required='${form_USE_FLAG_R }' disabled='${form_USE_FLAG_D }' visible='${form_USE_FLAG_V }' />
				</e:field>
	        </e:row>
	        <e:row>
                <e:label for="regDate" title="${form_regDate_N}"></e:label>
                <e:field>
					<e:inputText id="regDate" name="regDate" width="${inputTextWidth }" maxLength="${form_regDate_M }" required="${form_regDate_R }" readOnly="${form_regDate_RO }" disabled="${form_regDate_D}" visible="${form_regDate_V}" ></e:inputText>
                </e:field>
                <e:label for="regUserId" title="${form_regUserId_N}"></e:label>
                <e:field>
					<e:inputText id="regUserId" name="regUserId" width="${inputTextWidth }" maxLength="${form_regUserId_M }" required="${form_regUserId_R }" readOnly="${form_regUserId_RO }" disabled="${form_regUserId_D}" visible="${form_regUserId_V}" ></e:inputText>
					<e:inputHidden id="gateCdOri" name="gateCdOri"/>
					<e:inputHidden id="buyerCdOri" name="buyerCdOri"/>
					<e:inputHidden id="GATE_CD_ORI"   name="GATE_CD_ORI"/>
					<e:inputHidden id="BUYER_CD_ORI"   name="BUYER_CD_ORI"/>
					<e:inputHidden id="ACCOUNT_UNIT_CD"   name="ACCOUNT_UNIT_CD"/>
                </e:field>
	        </e:row>
			<e:row>
				<e:label for="CI_FILE_NUM" title="${form_CI_FILE_NUM_N}" />
				<e:field colSpan="3">
						<e:fileManager id="CI_FILE_NUM" name="CI_FILE_NUM" fileId="${form.CI_FILE_NUM}" downloadable="true" width="100%" bizType="OG" height="100px" readOnly="${form_CI_FILE_NUM_RO}" required="${form_CI_FILE_NUM_R}" maxFileCount="1" fileExtension="${fileExtension}" />
				</e:field>
			</e:row>
		</e:searchPanel>
	    </e:panel>

    </e:window>
</e:ui>