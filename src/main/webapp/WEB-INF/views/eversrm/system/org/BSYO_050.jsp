<!--
* BSYO_050 : 플랜트단위
* 시스템관리 > 조직관리 > 플랜트단위
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
			grid.setProperty('shrinkToFit', true);
			grid.setProperty('panelVisible', ${panelVisible});
			grid.cellClickEvent(function(rowid, colId, value) {
				if(colId == "PLANT_CD") {
					setFormData(grid.getCellValue(rowid, "PLANT_CD"), grid.getCellValue(rowid, "BUYER_CD"));
	            }
			});
            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
			doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'BSYO_050/selectPlant', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                } else {
                	if (saveCd != null) {
                		var rowIds = grid.getSelRowId();
                		for (var i = 0, length = grid.getSelRowCount(); i < length; i++) {
	                        if (grid.getCellValue(rowIds[i], "PLANT_CD") == saveCd) {
	                            setFormData(grid.getCellValue(rowIds[i], "PLANT_CD"), grid.getCellValue(rowIds[i], "BUYER_CD"));
	                            return;
	                        }
	                    }
	                }
	               // setFormData(grid.getCellValue(0, "PLANT_CD"), grid.getCellValue(0, "BUYER_CD"));
	               doReset('1');
	            }
            });
        }

        function doSave() {
			if (!confirm("${msg.M0021 }")) return;

	        EVF.C('OVERWRITE_MODE').setValue('0');
	        saveCd = EVF.V('PLANT_CD');

	        var store = new EVF.Store();
	        if(!store.validate()) return;

        	store.load(baseUrl + 'BSYO_050/savePlant', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {
			if (!confirm("${msg.M0013 }")) return;

			saveCd = null;
			var store = new EVF.Store();
        	store.load(baseUrl + 'BSYO_050/deletePlant', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

		function doReset(a) {
			if(a != '1')
			if (!confirm("${msg.M0029}")) return;

			var formValue = formUtil.getFormData();
			var formKey = Object.keys(formValue);

			for(var i = 0; i < formKey.length; i++) {
				if(formKey[i] == "BUYER_CD") {
					EVF.C(formKey[i]).setValue("DONGHEE");
				} else if(formKey[i] == "PLANT_TYPE" || formKey[i] == "PLANT_TYPE_ORG") {
					EVF.C(formKey[i]).setValue("ZV");
				} else {
					EVF.C(formKey[i]).setValue("");
				}
			}
			/*
			EVF.C('BUYER_CD').setValue("DONGHEE");
           	EVF.C('PLANT_CD').setValue("");
           	EVF.C('PLANT_NM').setValue("");
           	EVF.C('PLANT_NM_ENG').setValue("");
           	EVF.C('COUNTRY_CD').setValue("");
           	EVF.C('CITY_NM').setValue("");
           	EVF.C('ZIP_CD').setValue("");
           	EVF.C('TEL_NUM').setValue("");
           	EVF.C('ADDR').setValue("");
           	EVF.C('ADDR_ENG').setValue("");
           	EVF.C('IRS_NUM').setValue("");
           	EVF.C('FAX_NUM').setValue("");
           	EVF.C('CEO_USER_NM').setValue("");
           	EVF.C('CEO_USER_NM_ENG').setValue("");
           	EVF.C('BUSINESS_TYPE').setValue("");
           	EVF.C('INDUSTRY_TYPE').setValue("");
           	EVF.C('BUYER_NM').setValue("");
           	EVF.C('BUYER_NM_ENG').setValue("");
           	EVF.C('COMPANY_REG_NUM').setValue("");
           	EVF.C('DUNS_NUM').setValue("");
           	EVF.C('REG_DATE').setValue("");
           	EVF.C('REG_USER_ID').setValue("");
           	EVF.C('GATE_CD').setValue("");
           	EVF.C('BUYER_CD_ORI').setValue("");
           	EVF.C('PLANT_CD_ORI').setValue("");
           	EVF.C('ATT_FILE_NUM').setValue("");
           	EVF.C('INSERT_FLAG').setValue("");
           	EVF.C('OVERWRITE_MODE').setValue("");
           	EVF.C('PLANT_TYPE').setValue("ZV");
           	EVF.C('REGION_CD').setValue("");
           	EVF.C('EMAIL').setValue("");
           	EVF.C('PLANT_STATUS_CD').setValue("");
           	EVF.C('MAPPING_PLANT_CD').setValue("");

           	EVF.C('PLANT_TYPE_ORG').setValue("ZV");
			EVF.C('ZIP_CD_5').setValue("");
			*/
		}

        function setFormData(plantCd, buyerCd) {

			EVF.C("PLANT_CD").setValue(plantCd);
            EVF.C("BUYER_CD_ORI").setValue(buyerCd);

            //Please check this line of code later
            EVF.C('INSERT_FLAG').setValue('Q');

            var store = new EVF.Store();
            store.load(baseUrl + 'BSYO_050/getInfo', function(){

				var formValue = this.getParameter("formData");
				var formKey = Object.keys(formValue);

				// 계약정보 셋팅
				for (var i = 0; i < formKey.length; i++) {
					if (formKey[i] != "ATT_FILE_NUM") {
						if( formKey[i] == "REG_USER_NM" ) {
							EVF.C("REG_USER_ID").setValue(formValue[formKey[i]]);
						} else {
							EVF.C(formKey[i]).setValue(formValue[formKey[i]]);
						}
					} else {
						//if( formValue[formKey[i]] != "" )
						//EVF.C(formKey[i]).setFileId(formValue[formKey[i]]);
						EVF.C('ATT_FILE_NUM').setValue(this.getParameter("formData").ATT_FILE_NUM);
					}
				}

            	/*
            	EVF.C('BUYER_CD').setValue(this.getParameter("formData").BUYER_CD);
            	EVF.C('PLANT_CD').setValue(this.getParameter("formData").PLANT_CD);
            	EVF.C('PLANT_NM').setValue(this.getParameter("formData").PLANT_NM);
            	EVF.C('PLANT_NM_ENG').setValue(this.getParameter("formData").PLANT_NM_ENG);
            	EVF.C('COUNTRY_CD').setValue(this.getParameter("formData").COUNTRY_CD);
            	EVF.C('CITY_NM').setValue(this.getParameter("formData").CITY_NM);
            	EVF.C('ZIP_CD').setValue(this.getParameter("formData").ZIP_CD);
            	EVF.C('TEL_NUM').setValue(this.getParameter("formData").TEL_NUM);
            	EVF.C('ADDR').setValue(this.getParameter("formData").ADDR);
            	EVF.C('ADDR_ENG').setValue(this.getParameter("formData").ADDR_ENG);
            	EVF.C('IRS_NUM').setValue(this.getParameter("formData").IRS_NUM);
            	EVF.C('FAX_NUM').setValue(this.getParameter("formData").FAX_NUM);
            	EVF.C('CEO_USER_NM').setValue(this.getParameter("formData").CEO_USER_NM);
            	EVF.C('CEO_USER_NM_ENG').setValue(this.getParameter("formData").CEO_USER_NM_ENG);
            	EVF.C('BUSINESS_TYPE').setValue(this.getParameter("formData").BUSINESS_TYPE);
            	EVF.C('INDUSTRY_TYPE').setValue(this.getParameter("formData").INDUSTRY_TYPE);
            	EVF.C('BUYER_NM').setValue(this.getParameter("formData").BUYER_NM);
            	EVF.C('BUYER_NM_ENG').setValue(this.getParameter("formData").BUYER_NM_ENG);
            	EVF.C('COMPANY_REG_NUM').setValue(this.getParameter("formData").COMPANY_REG_NUM);
            	EVF.C('DUNS_NUM').setValue(this.getParameter("formData").DUNS_NUM);
            	EVF.C('REG_DATE').setValue(this.getParameter("formData").REG_DATE);
            	EVF.C('REG_USER_ID').setValue(this.getParameter("formData").REG_USER_NM);
            	EVF.C('GATE_CD').setValue(this.getParameter("formData").GATE_CD);
            	EVF.C('BUYER_CD_ORI').setValue(this.getParameter("formData").BUYER_CD_ORI);
            	EVF.C('PLANT_CD_ORI').setValue(this.getParameter("formData").PLANT_CD_ORI);
            	EVF.C('ATT_FILE_NUM').setValue(this.getParameter("formData").ATT_FILE_NUM);
            	EVF.C('INSERT_FLAG').setValue(this.getParameter("formData").INSERT_FLAG);
            	EVF.C('OVERWRITE_MODE').setValue(this.getParameter("formData").OVERWRITE_MODE);
            	EVF.C('PLANT_TYPE').setValue(this.getParameter("formData").PLANT_TYPE);

            	EVF.C('PLANT_TYPE_ORG').setValue(this.getParameter("formData").PLANT_TYPE);


            	EVF.C('REGION_CD').setValue(this.getParameter("formData").REGION_CD);
            	EVF.C('EMAIL').setValue(this.getParameter("formData").EMAIL);
            	EVF.C('PLANT_STATUS_CD').setValue(this.getParameter("formData").PLANT_STATUS_CD);
            	EVF.C('MAPPING_PLANT_CD').setValue(this.getParameter("formData").MAPPING_PLANT_CD);
				EVF.C('ZIP_CD_5').setValue(this.getParameter("formData").ZIP_CD_5);
				*/
            	getAttachedInfo();
        	});
		}

		function getAttachedInfo() {

	        var param1 = {
	            bizType: 'SYSTEM',
	            uuid: "", //WUX.getComponent('ATTACH_FILE_NO').getValue(),
	            callback: 'callBackAttached',
	            detailView: "" //'${param.detailView}'
	        };
	        var url = '/wisec/common/file/fileAttach/show.wu?';
	        //WUX.getComponent('fileAttach1').setUrl(url + $.param(param1));
	    }

		function callBackAttached(result) {
	        //WUX.getComponent('ATTACH_FILE_NO').setValue(result.UUID);
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
        	EVF.C("ZIP_CD").setValue(data.ZIP_CD);
			EVF.C("ZIP_CD_5").setValue(data.ZIP_CD_5);
        	EVF.C("ADDR").setValue(data.ADDR);
        }

    </script>
    <e:window id="BSYO_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Reset" name="Reset" label="${Reset_N }" disabled="${Reset_D }" onClick="doReset" />
            <%-- <e:button id="ZipCode" name="ZipCode" label="우편번호" onClick="searchZipCode" /> --%>
        </e:buttonBar>

    	<e:panel id="leftPanel" height="100%" width="40%">
    		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="98%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    	</e:panel>

    	<e:panel id="rightPanel" height="100%" width="60%">

		<e:searchPanel id="form" title="${form_caption_form_N}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
	        <e:row>
                <e:label for="BUYER_CD" title="${form_BUYER_CD_N}"></e:label>
                <e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" options="${refBuyerCd}" required="${form_BUYER_CD_R }" disabled="${form_BUYER_CD_D }" readOnly="${form_BUYER_CD_RO }" value="${st_default}" width="100%"></e:select>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"></e:label>
                <e:field>
					<e:inputText id="PLANT_CD" style='ime-mode:inactive' name="PLANT_CD" width="100%" maxLength="${form_PLANT_CD_M }" required="${form_PLANT_CD_R }" readOnly="${form_PLANT_CD_RO }" disabled="${form_PLANT_CD_D}" visible="${form_PLANT_CD_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="PLANT_NM" title="${form_PLANT_NM_N}"></e:label>
                <e:field>
					<e:inputText id="PLANT_NM" name="PLANT_NM" style="${imeMode}" width="100%" maxLength="${form_PLANT_NM_M }" required="${form_PLANT_NM_R }" readOnly="${form_PLANT_NM_RO }" disabled="${form_PLANT_NM_D}" visible="${form_PLANT_NM_V}" ></e:inputText>
                </e:field>
                <e:label for="PLANT_NM_ENG" title="${form_PLANT_NM_ENG_N}"></e:label>
                <e:field>
					<e:inputText id="PLANT_NM_ENG" style='ime-mode:inactive' name="PLANT_NM_ENG" width="100%" maxLength="${form_PLANT_NM_ENG_M }" required="${form_PLANT_NM_ENG_R }" readOnly="${form_PLANT_NM_ENG_RO }" disabled="${form_PLANT_NM_ENG_D}" visible="${form_PLANT_NM_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>

	        <e:inputHidden id="PLANT_TYPE_ORG" name="PLANT_TYPE_ORG"/>
	        <e:inputHidden id="PLANT_TYPE" name="PLANT_TYPE"/>
	        <e:inputHidden id="PLANT_STATUS_CD" name="PLANT_STATUS_CD"/>

	        <e:row>
	        	<e:label for="EMAIL" title="${form_EMAIL_N}"/>
				<e:field>
					<e:inputText id="EMAIL" name="EMAIL" style='ime-mode:inactive' value="${form.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" />
				</e:field>
				<e:label for="REGION_CD" title="${form_REGION_CD_N}"/>
				<e:field>
					<e:select id="REGION_CD" name="REGION_CD" value="${form.REGION_CD}" options="${regionCdOptions}" width="${inputTextWidth}" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" required="${form_REGION_CD_R}" placeHolder="" />
				</e:field>
	        </e:row>
	        <e:row>
                <e:label for="COUNTRY_CD" title="${form_COUNTRY_CD_N}"></e:label>
                <e:field>
					<e:select id="COUNTRY_CD" name="COUNTRY_CD" options="${refCountryCd}" required="${form_COUNTRY_CD_R }" disabled="${form_COUNTRY_CD_D }" readOnly="${form_COUNTRY_CD_RO }" value="${st_default}" width="100%"></e:select>
                </e:field>
                <e:label for="CITY_NM" title="${form_CITY_NM_N}"></e:label>
                <e:field>
					<e:inputText id="CITY_NM" style="${imeMode}" name="CITY_NM" width="100%" maxLength="${form_CITY_NM_M }" required="${form_CITY_NM_R }" readOnly="${form_CITY_NM_RO }" disabled="${form_CITY_NM_D}" visible="${form_CITY_NM_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="ZIP_CD" title="${form_ZIP_CD_N}"></e:label>
                <e:field>
					<e:search id="ZIP_CD" name="ZIP_CD" width="100%" onIconClick="searchZipCode" maxLength="${form_ZIP_CD_M }" required="${form_ZIP_CD_R }" readOnly="${form_ZIP_CD_RO }" disabled="${form_ZIP_CD_D}" visible="${form_ZIP_CD_V}" />
					<e:inputHidden id="ZIP_CD_5" name="ZIP_CD_5" />
                 </e:field>
                <e:label for="TEL_NUM" title="${form_TEL_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" width="100%" maxLength="${form_TEL_NUM_M }" required="${form_TEL_NUM_R }" readOnly="${form_TEL_NUM_RO }" disabled="${form_TEL_NUM_D}" visible="${form_TEL_NUM_V}" ></e:inputText>
                </e:field>
	        </e:row>
	        <e:row>
                <e:label for="ADDR" title="${form_ADDR_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="ADDR" name="ADDR" style="${imeMode}" width="100%" maxLength="${form_ADDR_M }" required="${form_ADDR_R }" readOnly="${form_ADDR_RO }" disabled="${form_ADDR_D}" visible="${form_ADDR_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="ADDR_ENG" title="${form_ADDR_ENG_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="ADDR_ENG" style='ime-mode:inactive' name="ADDR_ENG" width="100%" maxLength="${form_ADDR_ENG_M }" required="${form_ADDR_ENG_R }" readOnly="${form_ADDR_ENG_RO }" disabled="${form_ADDR_ENG_D}" visible="${form_ADDR_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="IRS_NUM" name="IRS_NUM" width="100%" maxLength="${form_IRS_NUM_M }" required="${form_IRS_NUM_R }" readOnly="${form_IRS_NUM_RO }" disabled="${form_IRS_NUM_D}" visible="${form_IRS_NUM_V}" ></e:inputText>
                </e:field>
                <e:label for="FAX_NUM" title="${form_FAX_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="FAX_NUM" name="FAX_NUM" width="100%" maxLength="${form_FAX_NUM_M }" required="${form_FAX_NUM_R }" readOnly="${form_FAX_NUM_RO }" disabled="${form_FAX_NUM_D}" visible="${form_FAX_NUM_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}"></e:label>
                <e:field>
					<e:inputText id="CEO_USER_NM" style="${imeMode}" name="CEO_USER_NM" width="100%" maxLength="${form_CEO_USER_NM_M }" required="${form_CEO_USER_NM_R }" readOnly="${form_CEO_USER_NM_RO }" disabled="${form_CEO_USER_NM_D}" visible="${form_CEO_USER_NM_V}" ></e:inputText>
                </e:field>
                <e:label for="CEO_USER_NM_ENG" title="${form_CEO_USER_NM_ENG_N}"></e:label>
                <e:field>
					<e:inputText id="CEO_USER_NM_ENG" style='ime-mode:inactive' name="CEO_USER_NM_ENG" width="100%" maxLength="${form_CEO_USER_NM_ENG_M }" required="${form_CEO_USER_NM_ENG_R }" readOnly="${form_CEO_USER_NM_ENG_RO }" disabled="${form_CEO_USER_NM_ENG_D}" visible="${form_CEO_USER_NM_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}"></e:label>
                <e:field>
					<e:inputText id="BUSINESS_TYPE" style="${imeMode}" name="BUSINESS_TYPE" width="100%" maxLength="${form_BUSINESS_TYPE_M }" required="${form_BUSINESS_TYPE_R }" readOnly="${form_BUSINESS_TYPE_RO }" disabled="${form_BUSINESS_TYPE_D}" visible="${form_BUSINESS_TYPE_V}" ></e:inputText>
                </e:field>
                <e:label for="INDUSTRY_TYPE" title="${form_INDUSTRY_TYPE_N}"></e:label>
                <e:field>
					<e:inputText id="INDUSTRY_TYPE" style="${imeMode}" name="INDUSTRY_TYPE" width="100%" maxLength="${form_INDUSTRY_TYPE_M }" required="${form_INDUSTRY_TYPE_R }" readOnly="${form_INDUSTRY_TYPE_RO }" disabled="${form_INDUSTRY_TYPE_D}" visible="${form_INDUSTRY_TYPE_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="BUYER_NM" title="${form_BUYER_NM_N}"></e:label>
                <e:field>
					<e:inputText id="BUYER_NM" style="${imeMode}" name="BUYER_NM" width="100%" maxLength="${form_BUYER_NM_M }" required="${form_BUYER_NM_R }" readOnly="${form_BUYER_NM_RO }" disabled="${form_BUYER_NM_D}" visible="${form_BUYER_NM_V}" ></e:inputText>
                </e:field>
                <e:label for="BUYER_NM_ENG" title="${form_BUYER_NM_ENG_N}"></e:label>
                <e:field>
					<e:inputText id="BUYER_NM_ENG" style='ime-mode:inactive' name="BUYER_NM_ENG" width="100%" maxLength="${form_BUYER_NM_ENG_M }" required="${form_BUYER_NM_ENG_R }" readOnly="${form_BUYER_NM_ENG_RO }" disabled="${form_BUYER_NM_ENG_D}" visible="${form_BUYER_NM_ENG_V}" ></e:inputText>
                </e:field>
	        </e:row>
 	        <e:row>
                <e:label for="COMPANY_REG_NUM" title="${form_COMPANY_REG_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="COMPANY_REG_NUM" name="COMPANY_REG_NUM" width="100%" maxLength="${form_COMPANY_REG_NUM_M }" required="${form_COMPANY_REG_NUM_R }" readOnly="${form_COMPANY_REG_NUM_RO }" disabled="${form_COMPANY_REG_NUM_D}" visible="${form_COMPANY_REG_NUM_V}" ></e:inputText>
                </e:field>
                <e:label for="DUNS_NUM" title="${form_DUNS_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="DUNS_NUM" name="DUNS_NUM" width="100%" maxLength="${form_DUNS_NUM_M }" required="${form_DUNS_NUM_R }" readOnly="${form_DUNS_NUM_RO }" disabled="${form_DUNS_NUM_D}" visible="${form_DUNS_NUM_V}" ></e:inputText>
                </e:field>
	        </e:row>

			 <e:inputHidden id="MAPPING_PLANT_CD"        name="MAPPING_PLANT_CD"/>

 	        <e:row>
                <e:label for="REG_DATE" title="${form_REG_DATE_N}"></e:label>
                <e:field>
					<e:inputText id="REG_DATE" name="REG_DATE" width="100%" maxLength="${form_REG_DATE_M }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D}" visible="${form_REG_DATE_V}" ></e:inputText>
                </e:field>
                <e:label for="REG_USER_ID" title="${form_REG_USER_ID_N}"></e:label>
                <e:field>
					<e:inputText id="REG_USER_ID" name="REG_USER_ID" width="100%" maxLength="${form_REG_USER_ID_M }" required="${form_REG_USER_ID_R }" readOnly="${form_REG_USER_ID_RO }" disabled="${form_REG_USER_ID_D}" visible="${form_REG_USER_ID_V}" ></e:inputText>
                </e:field>
	        </e:row>
        </e:searchPanel>

		<e:inputHidden id="GATE_CD"        name="GATE_CD"/>
		<e:inputHidden id="BUYER_CD_ORI"   name="BUYER_CD_ORI"/>
		<e:inputHidden id="PLANT_CD_ORI"   name="PLANT_CD_ORI"/>
		<e:inputHidden id="ATT_FILE_NUM"   name="ATT_FILE_NUM"/>
		<e:inputHidden id="INSERT_FLAG"    name="INSERT_FLAG"/>
		<e:inputHidden id="OVERWRITE_MODE" name="OVERWRITE_MODE"/>
        <e:inputHidden id="_screenId" name="_screenId"/>

	    </e:panel>

    </e:window>
</e:ui>