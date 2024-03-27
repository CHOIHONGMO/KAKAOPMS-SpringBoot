<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    	var baseUrl = "/eversrm/system/org/";
    	var grid = {};
    	var flag = "";
    	
		function init() {

			grid = EVF.C('grid');
			grid.setProperty('multiselect', false);
			
			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if(celname == "GATE_CD") {
					setFormData(rowid);
	            }
			});

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",        
			    excelOptions : {
					 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
					,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
			        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});

			doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();        	
        	store.setGrid([grid]);
            store.load(baseUrl + 'houseUnit/selectGate', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                } else {
                	if (flag != null) {
                		var rowIds = grid.jsonToArray(grid.getAllRowId()).value;
                		for (var i = 0, length = rowIds.length; i < length; i++) {
	                        if (grid.getCellValue(rowIds[i], "GATE_CD") == EVF.C('gateCd').getValue()) {
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

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        if(!store.validate()) return;
	        
        	store.load(baseUrl + 'houseUnit/saveGate', function(){
        		alert(this.getResponseMessage());
        		flag = 1;
        		doSearch();
        	});
        }

		function doDelete() {

			if (!confirm("${msg.M0013 }")) return;

			flag = null;
			var store = new EVF.Store();
        	store.load(baseUrl + 'houseUnit/deleteGate', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

        function clearForm() {
	        if (!confirm("${msg.M0029}")) return;
	        EVF.C('gateCd').setValue("");
           	EVF.C('gateCdOri').setValue("");
           	EVF.C('gateNm').setValue("");
           	EVF.C('gateNmEng').setValue("");
           	EVF.C('gmtCd').setValue("");
           	EVF.C('regDate').setValue("");
           	EVF.C('delFlag').setValue("");
        }
        function setFormData(rowid) {
			EVF.C('gateCd').setValue(grid.getCellValue(rowid, "GATE_CD"));
           	EVF.C('gateCdOri').setValue(grid.getCellValue(rowid, "GATE_CD_ORI"));
           	EVF.C('gateNm').setValue(grid.getCellValue(rowid, "GATE_NM"));
           	EVF.C('gateNmEng').setValue(grid.getCellValue(rowid, "GATE_NM_ENG"));
           	EVF.C('gmtCd').setValue(grid.getCellValue(rowid, "GMT_CD"));
           	EVF.C('regDate').setValue(grid.getCellValue(rowid, "REG_DATE"));
           	EVF.C('delFlag').setValue(grid.getCellValue(rowid, "DEL_FLAG"));
        }
        function doExcelDown() {
	        gridUtil.excelDown(grid);
	    }

    </script>
    <e:window id="BSYO_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    
    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Clear" name="Clear" label="${Clear_N }" disabled="${Clear_D }" onClick="clearForm" />
        </e:buttonBar>
        
    	<e:panel id="leftPanel" height="fit" width="35%">
    		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="98%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    	</e:panel>
		
		
    	<e:panel id="rightPanel" height="fit" width="65%">
		<e:searchPanel id="form" title="${form_caption_form_N}" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="1">
	        <e:row>
                <e:label for="gateCd" title="${form_gateCd_N}"></e:label>   
                <e:field>
					<e:inputText id="gateCd" name="gateCd" width="100%" maxLength="${form_gateCd_M }" required="${form_gateCd_R }" readOnly="${form_gateCd_RO }" disabled="${form_gateCd_D}" visible="${form_gateCd_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="gateNm" title="${form_gateNm_N}"></e:label>   
                <e:field>
					<e:inputText id="gateNm" name="gateNm" width="100%" maxLength="${form_gateNm_M }" required="${form_gateNm_R }" readOnly="${form_gateNm_RO }" disabled="${form_gateNm_D}" visible="${form_gateNm_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="gateNmEng" title="${form_gateNmEng_N}"></e:label>   
                <e:field>
					<e:inputText id="gateNmEng" name="gateNmEng" width="100%" maxLength="${form_gateNmEng_M }" required="${form_gateNmEng_R }" readOnly="${form_gateNmEng_RO }" disabled="${form_gateNmEng_D}" visible="${form_gateNmEng_V}" ></e:inputText>
                </e:field>               
	        </e:row>
	        <e:row>
                <e:label for="gmtCd" title="${form_gmtCd_N}"></e:label>   
                <e:field>
					<e:select id="gmtCd" name="gmtCd" value="${form.gmtCd}" options="${gmtCdList}" width="100%" disabled="${form_gmtCd_D}" readOnly="${form_gmtCd_RO}" required="${form_gmtCd_R}" placeHolder="" />
					<e:inputHidden id="gateCdOri" name="gateCdOri"/>
					<e:inputHidden id="regUserId" name="regUserId"/>
					<e:inputHidden id="regDate"   name="regDate"/>
					<e:inputHidden id="delFlag"   name="delFlag"/>
                </e:field>               
	        </e:row>
		</e:searchPanel>
	    </e:panel>

    </e:window>
</e:ui>