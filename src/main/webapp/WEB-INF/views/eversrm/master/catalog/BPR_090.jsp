<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var grid;
	    var baseUrl = "/eversrm/master/catalog/shoppingBasketMgt/";
	    var popupFlag = '';
	    var isImageView = true;
	    var catalogSearch = 0;

		function init() {
	        popupFlag = '${param.popupFlag}';
	        catalogSearch = '${param.catalogSearch}';

	        if (popupFlag) {
	            EVF.C('doClose').setVisible(true);
	        } else {
	            EVF.C('doClose').setVisible(false);
	        }

	        if( popupFlag && catalogSearch != 1) {
	        	EVF.C('doSelect').setVisible(true);
	        } else {
	        	EVF.C('doSelect').setVisible(false);
	        }

			grid = EVF.C('grid');

			//grid.setProperty('footerrow', true);
			//grid.setRowFooter('AMOUNT', 'sum', 'Total', 'ITEM_CD');
			grid.setProperty('footVisible', true);
			var footer = {
				"text": "Total",
				"styles": { "fontBold": true }
			};
			grid._gvo.setColumnProperty("ITEM_CD", "footer", footer);
			footer = {
				"expression": "sum",
				"styles": {
					"numberFormat": "0,000",
					"fontBold": true
				}
			};
			grid._gvo.setColumnProperty("AMOUNT", "footer", footer);

			grid.setColImgTxtResize('IMAGE', 100, 100);
			grid.excelExportEvent({
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});

	        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
	            if (celname == "ITEM_CD") {
	                var param = {
						ITEM_CD: grid.getCellValue(rowid, celname),
	                    onClose: 'closePopup'
	                };
	                everPopup.openItemDetailInformation(param);
	            }
	        });

			grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
				if( 'CART_QT' == celname ) {
	                var currency = grid.getCellValue(rowid, 'CUR');
	                var price = everCurrency.getPrice(currency, grid.getCellValue(rowid, 'UNIT_PRC'));
	                var qty = everCurrency.getQty(currency, grid.getCellValue(rowid, 'CART_QT'));
	                sum = price * qty;

	                var amt = everCurrency.getAmount(currency, sum);
	                grid.setCellValue(rowid, "AMOUNT", amt);
					calculateSum();
				}
			});

			doSearch();
		}

	    function doSearch() {
	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + "doSearchItemCatalog", function() {
	            if (grid.getRowCount() == 0) {
	                alert("${msg.M0002 }");
	            } else {
	            	calculateSum();
	            }
	        });
	    }

	    function calculateSum() {
	    	var gridDatas = grid.getAllRowValue()
	    		, gridData = {}
	    		, sum = 0
	    		, currency = '';

	    	for( var i = 0, len = gridDatas.length; i < len; i++ ) {
				gridData = gridDatas[i];
				currency = gridData.CUR;

				var price = everCurrency.getPrice( currency, gridData.UNIT_PRC);
				var qty = everCurrency.getQty( currency, gridData.CART_QT );
				sum += price * qty;
	    	}

	        var amt = everCurrency.getAmount(currency, sum);
	        EVF.C('total_amount').setValue(amt);
	    }

	    function toggleImage() {
	        isImageView = !isImageView;

	        if (grid.getRowCount() === 0) {
	            doSearch();
	        }

	        grid.hideCol('IMAGE', isImageView);
        }
        function doCopyToCatalog() {
	        var valid = grid.validate();

			if( !valid.flag ) { alert("${msg.M0004}"); return; }
	        if (!confirm("${msg.M0021}")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.getGridData( grid, 'sel');
	        store.load("/eversrm/master/catalog/catalogSearch/doSaveCatalog", function() {
	            alert(this.getResponseMessage());
	            doSearch();
	        });
	    }

	    function doSave() {
	        var valid = grid.validate()
    			, selRows = grid.getSelRowValue();

			if( !valid.flag ) { alert("${msg.M0004}"); return; }
			for( var i = 0, len = selRows.length; i < len; i++ ) {
				if( selRows[i].ITEM_QT == '0.00' ) { alert("${msg.M0014}"); return; }
			}

			if (!confirm("${msg.M0021}")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.getGridData( grid, 'sel');
	        store.load("/eversrm/master/catalog/catalogSearch/doSaveToBasket", function() {
	            alert(this.getResponseMessage());
	            doSearch();
	        });
	    }

	    function doDelete() {
	        var valid = grid.validate();

			if( !valid.flag ) { alert("${msg.M0004}"); return; }
	        if (!confirm("${msg.M0013}")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.getGridData( grid, 'sel');
	        store.load(baseUrl + "doDelete", function() {
	            alert(this.getResponseMessage());
	            doSearch();
	        });
	    }

	    function doClose() {
	    	window.close();
	    }

        function doSelect() {
            var valid = grid.validate();

            if( !valid.flag ) { alert("${msg.M0004}"); return; }

            if ('${param.openerScreen}' === 'BPRM_010') {
                var resultData = [];
                var selectedData = grid.getSelRowValue();
                for(var x in selectedData) {
                    var data = {};
                    data['ITEM_CD'] = selectedData[x]['ITEM_CD'];
                    data['ITEM_DESC'] = selectedData[x]['ITEM_DESC'];
                    data['ITEM_SPEC'] = selectedData[x]['ITEM_SPEC'];
                    data['UNIT_CD'] = selectedData[x]['UNIT_CD'];
                    data['UNIT_PRC'] = selectedData[x]['UNIT_PRC'];
                    data['ITEM_AMT'] = selectedData[x]['AMOUNT'];
                    data['PR_QT'] = selectedData[x]['CART_QT'];
                    resultData.push(data);
                }
                opener.window['${param.callBackFunction}'](JSON.stringify(resultData));
                doClose();
            } else {
            	opener.window['${param.callBackFunction}'](JSON.stringify(grid.getSelRowValue()));
                window.close();
            }
        }
    </script>

	<e:window id="BPR_090" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearchTree">
            <e:row>
				<e:label for="total_amount" title="${form_total_amount_N}"/>
				<e:field>
					<e:inputNumber id="total_amount" name="total_amount" value="${form.total_amount}" maxValue="${form_total_amount_M}" width="${inputNumberWidth}" decimalPlace="${form_total_amount_NF}" disabled="${form_total_amount_D}" readOnly="${form_total_amount_RO}" required="${form_total_amount_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

		<e:buttonBar align="right">
			<e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}"/>
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doCopyToCatalog" name="doCopyToCatalog" label="${doCopyToCatalog_N}" onClick="doCopyToCatalog" disabled="${doCopyToCatalog_D}" visible="${doCopyToCatalog_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>