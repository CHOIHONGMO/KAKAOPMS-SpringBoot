<!--
* BSYL_020 : 화면속성관리
* 시스템관리 > 화면 > 화면속성관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid;
    	var addParam = [];
    	var eventRow;
    	var eventType;
    	var baseUrl = "/eversrm/system/multiLang/";

		function init() {

			grid = EVF.C('jqGrid');

			grid.setProperty('shrinkToFit', false);
			grid.setProperty('multiSelect', true);

			grid.addRowEvent(function() {
				var screenId = EVF.V("SCREEN_ID")== null ? "" : EVF.V("SCREEN_ID");
				var multiType = EVF.V("MULTI_TYPE")== null ? "F" : EVF.V("MULTI_TYPE");
				var form_grid_id = EVF.V("FORM_GRID_ID") == null ? "F" : EVF.V("FORM_GRID_ID");
                var maxSeq = -1;
                var rowIds = grid.getAllRowId();
                for(var i in rowIds) {
                    if( maxSeq < Number(grid.getCellValue(rowIds[i], 'SORT_SQ'))) {
                        maxSeq = Number(grid.getCellValue(rowIds[i], 'SORT_SQ'));
                    }
                }
                maxSeq = maxSeq + 1;

				addParam = [{"SCREEN_ID": screenId, "SORT_SQ": maxSeq, "LANG_CD": "${ses.langCd}", "MULTI_TYPE": multiType, "COLUMN_TYPE": "text", "USE_FLAG": "1", "DATA_TYPE": "D", "FONT_COLOR_TEXT": "D", "BACK_COLOR_TEXT": "D", "WIDTH_UNIT": "X" ,"FORM_GRID_ID" : form_grid_id ,"DECIMAL_YN" : "1" }];
            	grid.addRow(addParam);
			});

			grid.delRowEvent(function() {
                if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
				grid.delRow();
			});

			grid._gvo.setPasteOptions({
				checkReadOnly: true
			});

			grid._gvo.onRowsPasted = function (gridObj, items) {

				console.log(items);

				var baseRowId;
				var columnId = '';

				if(items instanceof Array) {

					baseRowId = items[0];
					for(var i = 0; i < items.length; i++) {
						grid.setCellValue(items[i], "SCREEN_ID", grid.getCellValue(baseRowId, "SCREEN_ID"));
						grid.setCellValue(items[i], "SCREEN_NM", grid.getCellValue(baseRowId, "SCREEN_NM"));
						grid.setCellValue(items[i], "LANG_CD", grid.getCellValue(baseRowId, "LANG_CD"));
						grid.setCellValue(items[i], "FORM_GRID_ID", grid.getCellValue(baseRowId, "FORM_GRID_ID"));
						grid.setCellValue(items[i], "MULTI_CD", grid.getCellValue(baseRowId, "MULTI_CD"));
						grid.setCellValue(items[i], "MULTI_TYPE", grid.getCellValue(baseRowId, "MULTI_TYPE"));
					}

					_getColumnAttribute(baseRowId, items);

				} else {

					baseRowId = items.endRow;
					columnId = grid.getCellValue(items.endRow, "COLUMN_ID");

					_getColumnAttribute(baseRowId, [baseRowId]);
				}
			};

			grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {

				eventRow = rowid;
        		eventType = "jqGrid";
        		grid.checkRow(rowid, true);

				if(celname == 'COLUMN_ID') {

					grid.setCellValue(rowid, 'COLUMN_ID', everString.lrTrim(value));
					var multiType = grid.getCellValue(rowid, "MULTI_TYPE");
            		var columnId = everString.lrTrim(grid.getCellValue(rowid, 'COLUMN_ID'));

            		if (multiType == "F" || multiType == "G") {

            			var store = new EVF.Store();
			        	store.setGrid([grid]);
			        	store.setParameter("searchWord", columnId);
			            store.load(baseUrl + 'doChoiceDomain', function() {

			                var openFlag = this.getParameter("openFlag");

		                    grid.setCellValue(rowid, "MULTI_CD", columnId);

		                    if (openFlag == "Y")
		                    {
		                    	setDomain2();
//		                        openSearchDomainPopup(columnId, multiType);
		                    }
		                    else if (openFlag == "N") {

		                        var domainData = JSON.parse(this.getParameter("domainData"));
		                        var mostUsedWord = JSON.parse(this.getParameter("mostUsedWord")) || {};
		                        var jsonHDs = [{
		                            source: 'COL_TYPE',
		                            target: 'COLUMN_TYPE'
		                        }, {
		                            source: 'DATA_LENGTH',
		                            target: 'MAX_LENGTH'
		                        }, {
		                            source: 'ALIGNMENT',
		                            target: 'ALIGNMENT_TYPE'
		                        }, {
		                            source: 'COL_WIDTH',
		                            target: 'COLUMN_WIDTH'
		                        }];

		                        grid.setCellValue(rowid, 'USE_FLAG', '1');
		                        grid.setCellValue(rowid, 'MAX_LENGTH', domainData.DATA_LENGTH);
		                        grid.setCellValue(rowid, 'DATA_TYPE', domainData.PRE_FORMAT);
		                        grid.setCellValue(rowid, 'COLUMN_TYPE', domainData.COL_TYPE);
		                        grid.setCellValue(rowid, 'COLUMN_WIDTH', domainData.COL_WIDTH);
//		                        grid.setCellValue(rowid, 'MULTI_CONTENTS', domainData.DOMAIN_DESC);
		                        grid.setCellValue(rowid, 'DOMAIN_NM', domainData.DOMAIN_NM);
		                        grid.setCellValue(rowid, 'ALIGNMENT_TYPE', domainData.ALIGNMENT);
		                        grid.setCellValue(rowid, 'FONT_COLOR_TEXT', 'D');
		                        grid.setCellValue(rowid, 'BACK_COLOR_TEXT', 'D');
                                grid.setCellValue(rowid, 'MULTI_CONTENTS', mostUsedWord.DOMAIN_DESC);
//								grid.setCellReadOnly(rowid, 'MULTI_CONTENTS', false);

								if(this.getParameter("dataLengthMsg") != null && this.getParameter("dataLengthMsg") != "") {
									alert(everString.replaceAll(this.getParameter("dataLengthMsg"), "@@", "\n"));
								}
		                    } else {
		                    	setDomain2();
//		                        openSearchDomainPopup(columnId, multiType);
		                    }
			            }, false);
            		}
            		else if (multiType == "M") {
                        grid.setCellValue(rowid, "MULTI_CD", columnId);
                        grid.setCellValue(rowid, "COLUMN_TYPE", "text");
                        grid.setCellValue(rowid, "DOMAIN_NM", "_TEXT");
                        grid.setCellValue(rowid, "MAX_LENGTH", "2000");
                        grid.setCellValue(rowid, "COLUMN_WIDTH", "0");
                        grid.setCellValue(rowid, "EDIT_FLAG", "0");
                    }
            		else {
                		grid.setCellValue(rowid, "MULTI_CD", columnId);
            		}
				}
				if (celname == 'COLUMN_WIDTH') {
		        	if(value > 0 && value < 10)
		        		grid.setCellValue(rowid, "WIDTH_UNIT", 'F');
		        	else {
		        		grid.setCellValue(rowid, "WIDTH_UNIT", 'X');
		        	}
		        }
		        if (celname == "MULTI_TYPE") {
		        	if (value == "M") {
		                grid.setCellValue(rowid, "FORM_GRID_ID", "msg");
		            } else if (value == "B") {
		                grid.setCellValue(rowid, "FORM_GRID_ID", "btn");
		            } else {
		            	grid.setCellValue(rowid, "FORM_GRID_ID", '');
		            }
		        }

		        if (celname == "EDIT_FLAG") {
		        	if (value == '1') {
		                grid.setCellValue(rowid, "BACK_COLOR_TEXT", 'O');
		            } else {
		                grid.setCellValue(rowid, "BACK_COLOR_TEXT", 'D');
		            }
		        }

		        if (celname == "COLUMN_TYPE") {
		        	if (value == "imagetext") {
		                grid.setCellValue(rowid, 'FONT_COLOR_TEXT', 'I');
		            } else {
		                grid.setCellValue(rowid, 'FONT_COLOR_TEXT', 'D');
		            }
		        }

		        if (celname == "DATA_TYPE") {
		        	if (value == "AMT" || value == "PER" || value == "QTY" || value == "MAX" || value == "SCO") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22.2);
		            } else if (value == "CNT" || value == "NUM" || value == "SEQ") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22);
		            } else if (value == "PRI" || value == "RAT") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22.3);
		            } else if (value == "DEC1") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22.1);
		            } else if (value == "DEC2") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22.2);
		            } else if (value == "DEC3") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22.3);
		            } else if (value == "DEC4") {
		                grid.setCellValue(rowid, 'MAX_LENGTH', 22.4);
		            }
		        }
			});

			grid.cellClickEvent(function(rowid, colId, value) {
				eventRow = rowid;
				eventType = "jqGrid";
				if(colId == "DOMAIN_NM") {
					openSearchDomainPopup(grid.getCellValue(rowid, 'COLUMN_ID'), grid.getCellValue(rowid, "MULTI_TYPE"));
	            }
				else if(colId == "IMAGE_BUTTON") {
				    var param = {
				        screen_Id: grid.getCellValue(rowid, "SCREEN_ID"),
                        column_Id: grid.getCellValue(rowid, "COLUMN_ID"),
                        detailView: false
                    };

				    everPopup.openPopupByScreenId("BSYL_022", 700, 300, param);
                }
			});


            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			EVF.C('LANGUAGE_LIST').setValue("KO");

			if ('${param.screenId}' != '') {
	            doSearch();
	        }

			grid.setColIconify("IMAGE_BUTTON", "IMAGE_BUTTON", "detail", true);
        }

		function _getColumnAttribute(rowId, rowIdArray) {

			var value = grid.getCellValue(rowId, 'COLUMN_ID');
			console.log(rowId, value);

			//grid.setCellValue(rowId, 'SORT_SQ', Number(grid.getCellValue(rowId, 'SORT_SQ'))+1);
			grid.setCellValue(rowId, 'COLUMN_ID', everString.lrTrim(value));
			var columnId = everString.lrTrim(grid.getCellValue(rowId, 'COLUMN_ID'));

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.setParameter("searchWord", columnId);
			store.load(baseUrl + 'doChoiceDomain', function() {

				console.log(1);

				var openFlag = this.getParameter("openFlag");

				grid.setCellValue(rowId, "MULTI_CD", columnId);
				console.log(2);

				var domainData = '';
				if(this.getParameter("domainData")) {
					domainData = JSON.parse(this.getParameter("domainData"));
				}
				var mostUsedWord = JSON.parse(this.getParameter("mostUsedWord"));

				console.log(rowId, ' log start:');
				console.log('mostUsedWord:', mostUsedWord);
				console.log('domainData:', domainData);
				console.log(rowId, ' log finish:');

				if(domainData == null && mostUsedWord != null) {
					domainData = mostUsedWord;
				}

				grid.setCellValue(rowId, 'USE_FLAG', '1');
				grid.setCellValue(rowId, 'MAX_LENGTH', domainData.DATA_LENGTH);
				grid.setCellValue(rowId, 'DATA_TYPE', domainData.PRE_FORMAT);
				grid.setCellValue(rowId, 'COLUMN_TYPE', domainData.COL_TYPE);
				grid.setCellValue(rowId, 'COLUMN_WIDTH', domainData.COL_WIDTH);
				grid.setCellValue(rowId, 'DOMAIN_NM', domainData.DOMAIN_NM);
				grid.setCellValue(rowId, 'ALIGNMENT_TYPE', domainData.ALIGNMENT);
				grid.setCellValue(rowId, 'DOMAIN_TYPE', domainData.DOMAIN_TYPE);
				grid.setCellValue(rowId, 'DOMAIN_NM', domainData.DOMAIN_NM);
				grid.setCellValue(rowId, 'FONT_COLOR_TEXT', 'D');
				grid.setCellValue(rowId, 'BACK_COLOR_TEXT', 'D');
				if(mostUsedWord != null) {
					grid.setCellValue(rowId, 'MULTI_CONTENTS', mostUsedWord.DOMAIN_DESC);
//					grid.setCellValue(rowId, 'COMMON_ID', mostUsedWord.COMMON_ID);
				}

				if(rowIdArray.length > 0) {
					var a = rowIdArray.shift();
					_getColumnAttribute(a, rowIdArray);
				}

			}, false);
			grid.setCellValue(rowId, "MULTI_CD", columnId);

		}
		function setDomain2() {
	        var data = {
	        		USE_FLAG: '',
	        		MAX_LENGTH: '',
	        		DATA_TYPE: '',
	        		COLUMN_TYPE: '',
	        		COLUMN_WIDTH: '',
	        		ALIGNMENT_TYPE: '',
	        		FONT_COLOR_TEXT: '',
	        		BACK_COLOR_TEXT: '',
	        		DOMAIN_NM: '',
	        		DATA: '',
		    };


	        data.USE_FLAG = 1;
	        data.MAX_LENGTH = '2000';
	        data.DATA_TYPE = 'D';
	        data.COLUMN_TYPE = 'text';
	        data.COLUMN_WIDTH = '150';
	        data.ALIGNMENT_TYPE = 'L';
	        data.FONT_COLOR_TEXT = 'D';
	        data.BACK_COLOR_TEXT = 'D';
	        data.EDIT_FLAG = '0';

	        grid.setRowValue(eventRow, deleteItem(data));
	        grid.setCellValue(eventRow, 'DOMAIN_NM', '_TEXT');
	    }
        function doSearch() {

			var anotherLangVal = EVF.C("ANOTHER_LANG").isChecked() == true ? "1" : "0";

			if((EVF.V('SCREEN_ID') == '' || EVF.V('SCREEN_ID') == null)
				&& (EVF.V('SCREEN_NM') == '' || EVF.V('SCREEN_NM') == null)
				&& (EVF.V('COLUMN_ID') == '' || EVF.V('COLUMN_ID') == null)
				&& (EVF.V('MULTI_CONTENTS') == '' || EVF.V('MULTI_CONTENTS') == null)) {
				alert("${BSYL_020_001 }");
				return;
			}

        	var store = new EVF.Store();
        	store.setGrid([grid]);
        	store.setParameter('anotherLangVal', anotherLangVal);
            store.load(baseUrl + 'doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });

        }

        function doSave() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	        var validM = grid.validate(["SCREEN_ID", "LANG_CD", "MULTI_TYPE", "MULTI_CONTENTS", "FORM_GRID_ID", "COLUMN_ID"]);
	        if (!validM.flag) {
				alert("${msg.M0014}");
			    return;
			}
			var validB = grid.validate(["SCREEN_ID", "LANG_CD", "MULTI_TYPE", "MULTI_CONTENTS", "FORM_GRID_ID", "COLUMN_ID"]);
			if (!validB.flag) {
				alert("${msg.M0014}");
			    return;
			}
			var validF = grid.validate(["SCREEN_ID", "LANG_CD", "MULTI_TYPE", "MULTI_CONTENTS", "FORM_GRID_ID", "COLUMN_ID", "DOMAIN_NM", "MAX_LENGTH", "EDIT_FLAG"]);
			if (!validF.flag) {
				alert("${msg.M0014}");
			    return;
			}
			var validG = grid.validate(["SCREEN_ID", "LANG_CD", "MULTI_TYPE", "MULTI_CONTENTS", "FORM_GRID_ID", "COLUMN_ID", "COLUMN_TYPE", "DOMAIN_NM", "MAX_LENGTH", "EDIT_FLAG"]);
			if (!validG.flag) {
				alert("${msg.M0014}");
			    return;
			}

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doSave', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

		function doCopy() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	        var argsIndex = 0;
	        var copyArgs = [];

			var rowIds = grid.getSelRowId();
			var domainNmData = "";

			//grid.checkAll(false);

			for(var i = 0; i < rowIds.length; i++) {

				var selectedData = [];
				selectedData[0] = grid.getRowValue(rowIds[i]);

				selectedData[0].DOMAIN_NM = '';
				selectedData[0].MULTI_CONTENTS = '';
				selectedData[0].TAG_GUIDE = '';
				selectedData[0].SORT_SQ = '';
				grid.addRow(selectedData);

				grid.checkRow(rowIds[i], false);
			}
	    }

		function openSearchDomainPopup(columnId, multiType) {

	        var param = {
	            searchWord: (multiType == "M" ? "TEXT" : columnId)
	        };

	        var url = baseUrl + 'BSYL_040/view';
	        var width = 1060;
	        var height = 500;
	        // everPopup.openWindowPopup(url, width, height, param, 'searchDomainPopup');
            new EVF.ModalWindow(url, param, width, height).open();
	    }

		function setDomain(data) {
	        data.USE_FLAG = 1;
	        data.MAX_LENGTH = data.DATA_LENGTH;
	        data.DATA_TYPE = data.PRE_FORMAT;
	        data.COLUMN_TYPE = data.COL_TYPE;
	        data.COLUMN_WIDTH = data.COL_WIDTH;
	        data.ALIGNMENT_TYPE = data.ALIGNMENT;
	        data.FONT_COLOR_TEXT = 'D';
	        data.BACK_COLOR_TEXT = 'D';
            if(EVF.isEmpty(grid.getCellValue(eventRow, 'MULTI_CONTENTS'))) {
                data.MULTI_CONTENTS = data.DOMAIN_DESC;
            }
	        grid.setRowValue(eventRow, deleteItem(data));
	        grid.setCellValue(eventRow, 'DOMAIN_NM', data.DOMAIN_NM);
	    }

		function deleteItem(JsonObj) {
			delete JsonObj['DATA'];
	        delete JsonObj['DATA_LENGTH'];
	        delete JsonObj['NUM'];
	        delete JsonObj['PRE_FORMAT'];
	        delete JsonObj['ALIGNMENT'];
	        delete JsonObj['COL_WIDTH'];
	        delete JsonObj['COL_TYPE'];
            delete JsonObj['DOMAIN_DESC'];

	        return JsonObj;
	    }


		function dosetReSortNum() {
			var rowIds = grid.getAllRowId();
			var k = 0;

			if(EVF.C('FORM_GRID_ID').getValue() == '') {
				alert('폼/그리드 ID 입력 후 조회 사용');
				return;
			}



			for(var i = 0; i < rowIds.length; i++) {
				if(grid.getCellValue(rowIds[i],'MULTI_TYPE') != 'G') continue;
				if(grid.getCellValue(rowIds[i],'COLUMN_WIDTH') == '0') {
					grid.setCellValue(rowIds[i], "SORT_SQ", '99');
				} else {
					grid.setCellValue(rowIds[i], "SORT_SQ", k++);
				}
			}
		}
    </script>
    <e:window id="BSYL_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="150" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
                <e:field>
                    <e:inputText id="SCREEN_ID" name="SCREEN_ID" width="${form_SCREEN_ID_W }" maxLength="${form_SCREEN_ID_M }" required="${form_SCREEN_ID_R }" readOnly="${form_SCREEN_ID_RO }" disabled="${form_SCREEN_ID_D }" value="${param.screenId}"/>
                </e:field>

                <e:label for="SCREEN_NM" title="${form_SCREEN_NM_N }" />
                <e:field>
                    <e:inputText id="SCREEN_NM" name="SCREEN_NM" width="${form_SCREEN_NM_W }" maxLength="${form_SCREEN_NM_M }" required="${form_SCREEN_NM_R }" readOnly="${form_SCREEN_NM_RO }" disabled="${form_SCREEN_NM_D }" />
                </e:field>

                <e:label for="" title="${form_LANGUAGE_LIST_N }" />
                <e:field>
                    <e:select id="LANGUAGE_LIST" name="LANGUAGE_LIST" label="" value="" options="${languageListOptions}" width="${form_LANGUAGE_LIST_W}" required="${form_LANGUAGE_LIST_R }" readOnly="${form_LANGUAGE_LIST_RO }" disabled="${form_LANGUAGE_LIST_D }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MULTI_TYPE" title="${form_MULTI_TYPE_N }" />
                <e:field>
                    <e:select id="MULTI_TYPE" name="MULTI_TYPE" label="" value="" options="${multiTypeOptions}" width="${form_MULTI_TYPE_W }" required="${form_MULTI_TYPE_R }" readOnly="${form_MULTI_TYPE_RO }" disabled="${form_MULTI_TYPE_D }" />
                </e:field>

                <e:label for="MODULE_TYPE" title="${form_MODULE_TYPE_N }" />
                <e:field>
                    <e:select id="MODULE_TYPE" name="MODULE_TYPE" label="" value="" options="${moduleTypeOptions}" width="${form_MODULE_TYPE_W }" required="${form_MODULE_TYPE_R }" readOnly="${form_MODULE_TYPE_RO }" disabled="${form_MODULE_TYPE_D }" />
                </e:field>

                <e:label for="" title="${form_COLUMN_ID_N }" />
                <e:field>
                    <e:inputText id="COLUMN_ID" name="COLUMN_ID" width="${form_COLUMN_ID_W }" maxLength="${form_COLUMN_ID_M }" required="${form_COLUMN_ID_R }" readOnly="${form_COLUMN_ID_RO }" disabled="${form_COLUMN_ID_D }" />
                </e:field>
            </e:row>

            <e:row>
                <e:label for="" title="${form_FORM_GRID_ID_N }"/>
                <e:field>
                    <e:inputText id="FORM_GRID_ID" name="FORM_GRID_ID" width="${form_FORM_GRID_ID_W }" maxLength="${form_FORM_GRID_ID_M }" required="${form_FORM_GRID_ID_R }" readOnly="${form_FORM_GRID_ID_RO }" disabled="${form_FORM_GRID_ID_D }" value=""/>
                </e:field>

                <e:label for="ANOTHER_LANG" title="${form_ANOTHER_LANG_N }" />
                <e:field>
                	<e:checkGroup id="cg" name="cg" visible="true" disabled="" readOnly="" required="">
                        <e:check id="ANOTHER_LANG" name="ANOTHER_LANG" value="1" required="${form_ANOTHER_LANG_R }" readOnly="${form_ANOTHER_LANG_RO }" disabled="${form_ANOTHER_LANG_D }" />
                    </e:checkGroup>
                </e:field>
                <e:label for="" title="${form_MULTI_CONTENTS_N }" />
                <e:field>
                    <e:inputText id="MULTI_CONTENTS" name="MULTI_CONTENTS" width="${form_MULTI_CONTENTS_W }" maxLength="${form_MULTI_CONTENTS_M }" required="${form_MULTI_CONTENTS_R }" readOnly="${form_MULTI_CONTENTS_RO }" disabled="${form_MULTI_CONTENTS_D }" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Copy" name="Copy" label="${Copy_N }" disabled="${Copy_D }" onClick="doCopy" />
            <e:button id="setReSortNum" name="setReSortNum" label="${setReSortNum_N}" onClick="dosetReSortNum" disabled="${setReSortNum_D}" visible="${setReSortNum_V}"/>
        </e:buttonBar>
        <e:gridPanel id="jqGrid" name="jqGrid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.jqGrid.gridColData}" />
    </e:window>
</e:ui>