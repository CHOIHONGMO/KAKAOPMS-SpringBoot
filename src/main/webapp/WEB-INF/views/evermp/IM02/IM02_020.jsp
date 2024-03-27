<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};
        var selRow;
        var newMode = false;

        function init() {

        	grid = EVF.C('grid');

            grid.cellClickEvent(function(rowId, colId, value) {

            	if(colId == "TIER_CD") {
            		var param = {
                    	ITEM_CLS1 : grid.getCellValue(rowId, 'ITEM_CLS1'),
                    	ITEM_CLS2 : grid.getCellValue(rowId, 'ITEM_CLS2'),
                    	ITEM_CLS3 : grid.getCellValue(rowId, 'ITEM_CLS3'),
                    	ITEM_CLS4 : grid.getCellValue(rowId, 'ITEM_CLS4'),
                    	TIER_CD : grid.getCellValue(rowId, 'TIER_CD'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("IM02_021", 800, 330, param);
				}
            	if(colId == "TIER_RATE") {
            		var param = {
        				ITEM_CLS1 : grid.getCellValue(rowId, 'ITEM_CLS1'),
                    	ITEM_CLS2 : grid.getCellValue(rowId, 'ITEM_CLS2'),
                    	ITEM_CLS3 : grid.getCellValue(rowId, 'ITEM_CLS3'),
                    	ITEM_CLS4 : grid.getCellValue(rowId, 'ITEM_CLS4'),
                    	TIER_CD : grid.getCellValue(rowId, 'TIER_CD'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("IM02_022", 800, 380, param);
				}
            	if(colId == "AMEND_REASON") {
                	var param = {
           				 title : "${IM02_020_003}"
           				,message : grid.getCellValue(rowId, "AMEND_REASON")
           				,detailView : true
           			};
                	var url = '/common/popup/common_text_view/view';
    				everPopup.openModalPopup(url, 500, 320, param);
				}
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('shrinkToFit', true);
            grid.setProperty('multiSelect', false);
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}

            store.setGrid([grid]);
            store.load(baseUrl + 'im02020_doSearch', function() {
            	if (newMode) {
                    newMode = false;
                    if (grid.getRowCount() > 0) {
    		            alert("${IM02_020_004 }");
    		        } else {
    		        	var param = {
  		                	ITEM_CLS1 : EVF.C("ITEM_CLASS1").getValue(),
  		                	ITEM_CLS2 : EVF.C("ITEM_CLASS2").getValue(),
  		                	ITEM_CLS3 : "*",
  		                	ITEM_CLS4 : "*",
  		                	TIER_CD : "",
  		                    'detailView': false,
  		                    'popupFlag': true
  		                };
  		                everPopup.openPopupByScreenId("IM02_023", 800, 330, param);
    		        }
                } else {
                	if(grid.getRowCount() == 0){
                        alert("${msg.M0002 }");
                    }
                    grid.setColMerge(['ITEM_CLS2_NM','ITEM_CLS1','ITEM_CLS2']);
                    grid.setColIconify("AMEND_REASON", "AMEND_REASON", "comment", false);
                }
            });
        }

        function doRegistration() {

        	if(EVF.isEmpty(EVF.C("ITEM_CLASS1").getValue())) {
        		return alert("${IM02_020_001 }");
        	}
        	if(EVF.isEmpty(EVF.C("ITEM_CLASS2").getValue())) {
        		return alert("${IM02_020_002 }");
        	}
        	newMode = true;
            doSearch();
        }


		function getItemClass2Options() {
			var store = new EVF.Store();
			store.setParameter("ITEM_CLASS1", EVF.C("ITEM_CLASS1").getValue());
            store.load(baseUrl + 'getMakerOptions', function() {
                EVF.C('ITEM_CLASS2').setOptions(this.getParameter('makerOptions'));
			}, false);
		}

    </script>

    <e:window id="IM02_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="ITEM_CLASS1" title="${form_ITEM_CLASS1_N}"/>
                <e:field>
                    <e:select id="ITEM_CLASS1" name="ITEM_CLASS1" value="" options="${itemClass1Options }" width="${form_ITEM_CLASS1_W }" disabled="${form_ITEM_CLASS1_D}" readOnly="${form_ITEM_CLASS1_RO}" required="${form_ITEM_CLASS1_R}" placeHolder="" onChange="getItemClass2Options" />
                </e:field>
                <e:label for="ITEM_CLASS2" title="${form_ITEM_CLASS2_N}"/>
                <e:field>
                    <e:select id="ITEM_CLASS2" name="ITEM_CLASS2" value="" options="" width="${form_ITEM_CLASS2_W }" disabled="${form_ITEM_CLASS2_D}" readOnly="${form_ITEM_CLASS2_RO}" required="${form_ITEM_CLASS2_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Registration" name="Registration" label="${Registration_N}" disabled="${Registration_D}" visible="${Registration_V}" onClick="doRegistration" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>