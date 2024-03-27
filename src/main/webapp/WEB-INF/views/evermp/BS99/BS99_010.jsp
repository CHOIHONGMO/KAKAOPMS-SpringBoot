<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

	    var grid;
	    var baseUrl = "/evermp/BS99/BS9901/";

	    function init() {

	        grid = EVF.C("grid");

	        grid.cellClickEvent(function(rowId, colName, value) {
				if(colName == 'ATT_FILE_NM') {
				     everPopup.fileAttachPopup('BI', grid.getCellValue(rowId, 'ATT_FILE_NUM'), 'setFileNm', rowId, false);
				}
			});

	        grid.addRowEvent(function() {
				var newRow = [{}];
            	grid.addRow(newRow);
			});

			grid.delRowEvent(function() {
				if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
		            return alert("${msg.M0004}");
		        }
				grid.delRow();
			});

			grid.setProperty('shrinkToFit', true);
			doSearch();
	    }

	    function doSearch() {

	    	var store = new EVF.Store();
			if(!store.validate()) { return;}
	        store.setGrid([grid]);
	        store.load(baseUrl + 'bs99010_doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	alert("${msg.M0002 }");
	            }
	        });
	    }

	    function doSave() {

	    	var rowIds = grid.jsonToArray(grid.getSelRowId()).value;

            if (rowIds.length == 0) {
                return alert("${msg.M0004}");
            }

            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs99010_doSave', function() {
				alert(this.getResponseMessage());
				doSearch();
            });
	    }

	    function setFileNm(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, 'ATT_FILE_NUM', uuid);
            grid.setCellValue(rowId, 'ATT_FILE_NM', 'y');
		}

    </script>
	<e:window id="BS99_010" initData="${initData}" onReady="init" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${longLabelWidth}" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="TMPL_NM" title="${form_TMPL_NM_N}"/>
				<e:field>
					<e:inputText id="TMPL_NM" name="TMPL_NM" value="${form.TMPL_NM}" width="100%" maxLength="${form_TMPL_NM_M}" disabled="${form_TMPL_NM_D}" readOnly="${form_TMPL_NM_RO}" required="${form_TMPL_NM_R}" />
				</e:field>
				<e:label for="TMPL_CONTENTS" title="${form_TMPL_CONTENTS_N}"/>
				<e:field>
					<e:inputText id="TMPL_CONTENTS" name="TMPL_CONTENTS" value="${form.TMPL_CONTENTS}" width="100%" maxLength="${form_TMPL_CONTENTS_M}" disabled="${form_TMPL_CONTENTS_D}" readOnly="${form_TMPL_CONTENTS_RO}" required="${form_TMPL_CONTENTS_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
			<e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>