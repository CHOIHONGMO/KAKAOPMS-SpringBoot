<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var baseUrl = "/eversrm/master/vendor/";

	function init() {
		grid = EVF.getComponent('grid');
		grid.setProperty('panelVisible', ${panelVisible});
		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				 imgWidth      : 0.12
				,imgHeight     : 0.26
				,colWidth      : 20
				,rowSize       : 500
		        ,attachImgFlag : false
		    }
		});

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

	        switch (celname) {
            case 'VENDOR_CD':
	            var params = {
	                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
	                popupFlag  : true,
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
            	break;
            case 'SUBJECT':
	            var params = {
            		docNum     : grid.getCellValue(rowid, "DOC_NUM"),
	                popupFlag  : true,
	                detailView : true
	            };
	            everPopup.openOFDetailInformation(params);
                break;

            	default:
	        }
		});

		grid.setProperty('shrinkToFit', true);

    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BBV_071/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    function doUpdate() {

		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        var rowData = grid.getSelRowId();
    	for (var nRow in rowData) {
    		if (grid.getCellValue(rowData[nRow], 'REG_USER_ID') != "${ses.userId  }") {
                alert("${msg.M0102}");
				return;
    		}
    	}

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        var docNum   = grid.getCellValue(selRowId[0],'DOC_NUM');
        var params = {
        		docNum     : docNum,
                popupFlag  : true,
                detailView : false
        };
		everPopup.openOFDetailInformation(params);
    }

    function doDelete() {

		var rowIds = grid.jsonToArray(grid.getSelRowId()).value;

		if (rowIds.length == 0) {
            alert("${msg.M0004}");
            return;
        }

		for(var i = 0; i < rowIds.length; i++) {
			var selectedData = [];
			selectedData[0] = grid.getRowValue(rowIds[i]);

			if (!(selectedData[0].SIGN_STATUS == "T" || selectedData[0].SIGN_STATUS == "R")) {
				alert("${msg.M0044}");
	        	return;
			}
		}

		if (!confirm("${msg.M0013}")) {
			return;
		}

		var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
		store.load(baseUrl + 'BBV_071/doDelete', function() {
			alert(this.getResponseMessage());

			doSearch();
		});

    }

	function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0013');
    }
    function selectVendorCd(dataJsonArray) {
		//EVF.getComponent("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
		EVF.getComponent("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
    }

    </script>

	<e:window id="BBV_071" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" onEnter="doSearch">
			<e:row>
				<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
				</e:field>
				<!--
				<e:label for="DOC_TYPE" title="${form_DOC_TYPE_N}" />
				<e:field>
					<e:select id="DOC_TYPE" name="DOC_TYPE" value="" options="${refDocType }" width="${inputTextWidth}" disabled="${form_DOC_TYPE_D}" readOnly="${form_DOC_TYPE_RO}" required="${form_DOC_TYPE_R}" placeHolder="" />
				</e:field>
				 -->
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${refProgressCd }" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
				<e:field>
					<e:search id="VENDOR_NM" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field colSpan="5">
					<e:inputText id="SUBJECT" name="SUBJECT" value="" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" style="${imeMode}"/>
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<e:button id="doUpdate" name="doUpdate" label="${doUpdate_N}" onClick="doUpdate" disabled="${doUpdate_D}" visible="${doUpdate_V}" />
			<%--
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
			 --%>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
