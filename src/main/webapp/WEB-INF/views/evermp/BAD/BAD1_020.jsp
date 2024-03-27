<%-- 고객사 > Admin > 사용자관리 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">
<!--
    var grid;
    var baseUrl = "/evermp/BAD/BAD1/";
    var eventRowId = 0;

    function init() {
    	
    	if( EVF.V("ERP_IF_FLAG") == "1" ) {
            EVF.C('Insert').setDisabled(true);
            EVF.C('Delete').setDisabled(true);
    	}
    	
        grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value) {
        	eventRowId = rowId;
            if (colId == "USER_ID") {
                var param = {
                    'USER_ID': grid.getCellValue(rowId, 'USER_ID'),
                    'detailView': false,
                    'popupFlag': true
                };
                everPopup.openPopupByScreenId("BAD1_021", 850, 600, param);
            }
            if(colId === 'DELY_NM') {
            	if(grid.getCellValue(rowId, "DELY_NM") != '' && grid.getCellValue(rowId, "DELY_NM") != null)
            		{
	                    var param = {
	                    	callBackFunction: "setCsdmCdSearchG",
	                    	CUST_CD: "${ses.companyCd}",
	                        DELY_NM: grid.getCellValue(rowId, "DELY_NM"),
	                        detailView: false
	                    };
	                    everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
            		}
            }
            if(colId === 'CUBL_NM') {
            	if(grid.getCellValue(rowId, "CUBL_NM") != '' && grid.getCellValue(rowId, "CUBL_NM") != null)
            		{
	                    var param = {
	                    	callBackFunction: "setCublCdSearchG",
	                        CUST_CD: "${ses.companyCd}",
	                        CUBL_NM: grid.getCellValue(rowId, "CUBL_NM"),
	                        detailView: false
	                    };
	                    everPopup.openPopupByScreenId("MY01_008", 900, 600, param);
            		}
            }
        });

        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        grid._gvo.setFixedOptions({colCount: 1});
        grid.setProperty('shrinkToFit', false);
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) { return;}
        store.setGrid([grid]);
        store.load(baseUrl + 'bad1020_doSearch', function() {
            if(grid.getRowCount() == 0){
                alert("${msg.M0002 }");
            }
        });
    }



    function doInsert() {
		
        var param = {
            'USER_ID': '',
            'detailView': false,
            'popupFlag': true
        };
        everPopup.openPopupByScreenId("BAD1_021", 850, 600, param);
    }

    function doSave() {
    	
    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        if(!grid.validate().flag) { return alert(grid.validate().msg); }

        var rowIds = grid.getSelRowId();
        for( var i in rowIds ) {
            if( grid.getCellValue(rowIds[i], 'MNG_YN') == "1" && grid.getCellValue(rowIds[i], 'BLOCK_FLAG') == "1" ) {
				return alert("${BAD1_020_002}");
			}
		}

        if(!confirm('${msg.M0021}')) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + 'bad1020_doSave', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function doDelete() {
    	
    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

        <%--var rowIds = grid.getSelRowId();--%>
        <%--for( var i in rowIds ) {--%>
            <%--if( grid.getCellValue(rowIds[i], 'MNG_YN') == "1" ) {--%>
				<%--return alert("${BAD1_020_001}");--%>
			<%--}--%>
		<%--}--%>

        if (!confirm("${msg.M0013 }")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + 'bad1020_doDelete', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function setCsdmCdSearchG(data) {
    	grid.setCellValue(eventRowId, "CSDM_SEQ", data.CSDM_SEQ);
    	grid.setCellValue(eventRowId, "DELY_NM", data.DELY_NM);
    	grid.setCellValue(eventRowId, "DELY_RECIPIENT_NM", data.DELY_RECIPIENT_NM);
    	grid.setCellValue(eventRowId, "DELY_ADDR", data.DELY_ADDR);
    	//grid.setCellValue(eventRowId, "DELY_RECIPIENT_TEL_NUM", data.DELY_RECIPIENT_TEL_NUM);
    	//grid.setCellValue(eventRowId, "DELY_RECIPIENT_FAX_NUM", data.DELY_RECIPIENT_FAX_NUM);
    	//grid.setCellValue(eventRowId, "DELY_RECIPIENT_CELL_NUM", data.DELY_RECIPIENT_CELL_NUM);
    	//grid.setCellValue(eventRowId, "DELY_RECIPIENT_EMAIL", data.DELY_RECIPIENT_EMAIL);

    }

    function setCublCdSearchG(data) {
    	grid.setCellValue(eventRowId, "CUBL_SQ", data.CUBL_SQ);
    	grid.setCellValue(eventRowId, "CUBL_NM", data.CUBL_NM);
    	grid.setCellValue(eventRowId, "CUBL_COMPANY_NM", data.CUBL_COMPANY_NM);
    	grid.setCellValue(eventRowId, "CUBL_IRS_NUM", data.CUBL_IRS_NUM);
    	grid.setCellValue(eventRowId, "CUBL_ADDR", data.CUBL_ADDR);
    	//grid.setCellValue(eventRowId, "CUBL_CEO_USER_NM", data.HIDDEN_CUBL_CEO_USER_NM);
    	//grid.setCellValue(eventRowId, "CUBL_BUSINESS_TYPE", data.CUBL_BUSINESS_TYPE);
    	//grid.setCellValue(eventRowId, "CUBL_INDUSTRY_TYPE", data.CUBL_INDUSTRY_TYPE);
    	//grid.setCellValue(eventRowId, "CUBL_BANK_NM", data.CUBL_BANK_NM);
    	//grid.setCellValue(eventRowId, "CUBL_ACCOUNT_NUM", data.CUBL_ACCOUNT_NUM);
    	//grid.setCellValue(eventRowId, "CUBL_ACCOUNT_NM", data.HIDDEN_CUBL_ACCOUNT_NM);
    	//grid.setCellValue(eventRowId, "CUBL_USER_NM", data.HIDDEN_CUBL_USER_NM);
    	//grid.setCellValue(eventRowId, "CUBL_USER_TEL_NUM", data.HIDDEN_CUBL_USER_TEL_NUM);
    	//grid.setCellValue(eventRowId, "CUBL_USER_FAX_NUM", data.HIDDEN_CUBL_USER_FAX_NUM);
    	//grid.setCellValue(eventRowId, "CUBL_USER_CELL_NUM", data.HIDDEN_CUBL_USER_CELL_NUM);
    	//grid.setCellValue(eventRowId, "CUBL_USER_EMAIL", data.HIDDEN_CUBL_USER_EMAIL);
    }

// -->
</script>

    <e:window id="BAD1_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
         <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="ERP_IF_FLAG" name="ERP_IF_FLAG" value="${ses.erpIfFlag}"/>
            <e:row>
          	  <e:label for="USER_ID" title="${form_USER_ID_N }" />
          	  <e:field>
          	     <e:inputText id="USER_ID" name="USER_ID" value=""   readOnly="${form_USER_ID_RO }"   maxLength="${form_USER_ID_M}"  width="50%" required="${form_USER_ID_R }" disabled="${form_USER_ID_D }" onFocus="onFocus" />
          	  </e:field>
          	  <e:label for="DEPT_NM" title="${form_DEPT_NM_N}" />
          	  <e:field>
          	     <e:inputText id="DEPT_NM" name="DEPT_NM" value="" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
          	  </e:field>
          	  <e:label for="BLOCK_YN" title="${form_BLOCK_YN_N}"/>
          	  <e:field>
             	 <e:select id="BLOCK_YN" name="BLOCK_YN" value="" options="${blockYnOptions}" width="${form_BLOCK_YN_W}" disabled="${form_BLOCK_YN_D}" readOnly="${form_BLOCK_YN_RO}" required="${form_BLOCK_YN_R}" placeHolder="" />
              </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" visible="${Insert_V}" onClick="doInsert" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>