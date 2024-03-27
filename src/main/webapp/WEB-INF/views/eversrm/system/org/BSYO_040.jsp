<!--
* BSYO_040 : 구매조직
* 시스템관리 > 조직관리 > 구매조직
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
			
			grid.cellClickEvent(function(rowid, colId, value) {
				if(colId == "PUR_ORG_CD") {
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
            store.load(baseUrl + 'BSYO_040/selectPurchaseOrg', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                } else {
                	if (saveCd != null) {
                		var rowIds = grid.getAllRowId();
                		//for (var i = 0, length = rowIds.length; i < length; i++) {
//	                        if (grid.getCellValue(rowIds[i], "PUR_ORG_CD") == saveCode) {
	//                            setFormData(rowIds[i]);
	   //                         return;
	      //                  }
	                    //}
	                }
                	setFormData(0);
                }
            });
        }

        function doSave() {

				if (!confirm("${msg.M0021 }")) return;

		        saveCd = EVF.V('purOrgCd');

		        var store = new EVF.Store();
		        if(!store.validate()) return;
		        
	        	store.load(baseUrl + 'BSYO_040/savePurchaseOrg', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
        }

		function doDelete() {

				if (!confirm("${msg.M0013 }")) return;

				saveCd = null;
				var store = new EVF.Store();
	        	store.load(baseUrl + 'BSYO_040/deletePurchaseOrg', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	    }

        function doReset() {
	        if (!confirm("${msg.M0029}")) return;
	        EVF.C('buyerCd').setValue("");
           	EVF.C('purOrgCd').setValue("");
           	EVF.C('purOrgNm').setValue("");
           	EVF.C('purOrgNmEng').setValue("");
           	EVF.C('regDate').setValue("");
           	EVF.C('regUserId').setValue("");
           	EVF.C('GATE_CD').setValue("");
           	EVF.C('buyerCdOri').setValue("");
           	EVF.C('purOrgCdOri').setValue("");
        }
        function setFormData(rowid) {
			EVF.C('buyerCd').setValue(grid.getCellValue(rowid, "BUYER_CD"));
           	EVF.C('purOrgCd').setValue(grid.getCellValue(rowid, "PUR_ORG_CD"));
           	EVF.C('purOrgNm').setValue(grid.getCellValue(rowid, "PUR_ORG_NM"));
           	EVF.C('purOrgNmEng').setValue(grid.getCellValue(rowid, "PUR_ORG_NM_ENG"));
           	EVF.C('regDate').setValue(grid.getCellValue(rowid, "REG_DATE_FORM"));
           	EVF.C('regUserId').setValue(grid.getCellValue(rowid, "REG_USER_NM"));
           	EVF.C('GATE_CD').setValue(grid.getCellValue(rowid, "GATE_CD"));
           	EVF.C('buyerCdOri').setValue(grid.getCellValue(rowid, "BUYER_CD"));
           	EVF.C('purOrgCdOri').setValue(grid.getCellValue(rowid, "PUR_ORG_CD"));
        }

    </script>
    <e:window id="BSYO_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Reset" name="Reset" label="${Reset_N }" disabled="${Reset_D }" onClick="doReset" />
        </e:buttonBar>

    	<e:panel id="leftPanel" height="100%" width="50%">
    		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="98%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    	</e:panel>
    	
    	<e:panel id="rightPanel" height="100%" width="50%">
		<e:searchPanel id="form" title="${form_caption_form_N}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="1">
	        <e:row>
                <e:label for="buyerCd" title="${form_buyerCd_N}"></e:label>   
                <e:field>
					<e:select id="buyerCd" name="buyerCd" options="${refBuyerCd}" required="${form_buyerCd_R }" disabled="${form_buyerCd_D }" readOnly="${form_buyerCd_RO }" value="${st_default}" width="100%"></e:select>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="purOrgCd" title="${form_purOrgCd_N}"></e:label>   
                <e:field>
					<e:inputText id="purOrgCd" name="purOrgCd" width="100%" maxLength="${form_purOrgCd_M }" required="${form_purOrgCd_R }" readOnly="${form_purOrgCd_RO }" disabled="${form_purOrgCd_D}" visible="${form_purOrgCd_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="purOrgNm" title="${form_purOrgNm_N}"></e:label>   
                <e:field>
					<e:inputText id="purOrgNm" name="purOrgNm" width="100%" maxLength="${form_purOrgNm_M }" required="${form_purOrgNm_R }" readOnly="${form_purOrgNm_RO }" disabled="${form_purOrgNm_D}" visible="${form_purOrgNm_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="purOrgNmEng" title="${form_purOrgNmEng_N}"></e:label>   
                <e:field>
					<e:inputText id="purOrgNmEng" name="purOrgNmEng" width="100%" maxLength="${form_purOrgNmEng_M }" required="${form_purOrgNmEng_R }" readOnly="${form_purOrgNmEng_RO }" disabled="${form_purOrgNmEng_D}" visible="${form_purOrgNmEng_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="regDate" title="${form_regDate_N}"></e:label>   
                <e:field>
					<e:inputText id="regDate" name="regDate" width="100%" maxLength="${form_regDate_M }" required="${form_regDate_R }" readOnly="${form_regDate_RO }" disabled="${form_regDate_D}" visible="${form_regDate_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="regUserId" title="${form_regUserId_N}"></e:label>   
                <e:field>
					<e:inputText id="regUserId" name="regUserId" width="100%" maxLength="${form_regUserId_M }" required="${form_regUserId_R }" readOnly="${form_regUserId_RO }" disabled="${form_regUserId_D}" visible="${form_regUserId_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	    </e:searchPanel>
		
		<e:inputHidden id="GATE_CD"      name="GATE_CD"/>
		<e:inputHidden id="buyerCdOri"   name="buyerCdOri"/>
		<e:inputHidden id="purOrgCdOri"  name="purOrgCdOri"/>
		<e:inputHidden id="mode"         name="mode"/>

	    </e:panel>
    </e:window>
</e:ui>