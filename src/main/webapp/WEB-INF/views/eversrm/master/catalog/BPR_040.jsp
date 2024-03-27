<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/master/catalog/BPR_040/";
    var grid;
    var gridTree;
    var popupFlag;
    var searchKey;
    var colHideFlag = true;
    var prevInfo = {'rowid' : '', 'cellNm' : ''};

    function init() {
        grid = EVF.C("grid");
        gridTree = EVF.C("gridTree");
        popupFlag = '${param.popupFlag}';

        if (popupFlag) {
            EVF.C('doSelect').setVisible(true);
            <%--EVF.C('doClose').setVisible(true);--%>
        } else {
            EVF.C('doSelect').setVisible(false);
            <%--EVF.C('doClose').setVisible(false);--%>
        }

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

		gridTree.excelExportEvent({
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

        grid.hideCol('IMAGE', colHideFlag);
        grid.setColImgTxtResize('IMAGE', 100, 100);
        gridTree.setProperty('shrinkToFit', true);
        gridTree.setTreeGrid('TEXT');

        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
            if (celname == 'ITEM_DESC') {
                var param = {
					ITEM_CD: grid.getCellValue(rowid, "ITEM_CD"),
                    onClose: 'closePopup'
                };
                everPopup.openItemDetailInformation(param);
            }
	        if (celname == "VENDOR_NM" || celname == 'VENDOR_CD') {
	            var params = {
	                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }
        });

        gridTree.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
        	var value = gridTree.getRowValue(rowid).VALUE;
        	var itemlist = {};

			if( !gridTree.isEmpty( treeInfo ) ) {
				if( prevInfo.rowid == '' ) {
					prevInfo.rowid = rowid;
					prevInfo.cellNm = celname;
				} else if( prevInfo.rowid != rowid ) {
					gridTree.setCellFontWeight(prevInfo.rowid, prevInfo.cellNm, false);
				} else ;

				gridTree.setCellFontWeight(rowid, celname, true);
				prevInfo.rowid = rowid;
				prevInfo.cellNm = celname;
			}

			EVF.C('ITEM_CLS1').setOptions('${refITEM_CLASS1}');
            EVF.C('ITEM_CLS2').resetOption();
            EVF.C('ITEM_CLS2').appendOption('-----------------', '');
            EVF.C('ITEM_CLS3').resetOption();
            EVF.C('ITEM_CLS3').appendOption('-----------------', '');
            EVF.C('ITEM_CLS4').resetOption();
            EVF.C('ITEM_CLS4').appendOption('-----------------', '');

            if(value== 'C1'){
            	EVF.C('ITEM_CLS1').setValue(rowid);
			} else if(value== 'C2') {
				var store = new EVF.Store();
                store.setParameter("idNode",rowid);
                store.setParameter("idType",value);
		        store.load(baseUrl + "doGetParentId", function() {
		        	itemlist = JSON.parse(this.getParameter('itemlist_rst'));
		        	EVF.C('ITEM_CLS1').setValue(itemlist[0].ITEM_CLS1);

					var storeList = new EVF.Store();
					storeList.setParameter('type', '2');
					storeList.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
	                    EVF.C('ITEM_CLS2').setOptions(this.getParameter('itemClassList'));
	                    setTimeout(function(){
	                    	EVF.C('ITEM_CLS2').setValue(itemlist[0].ITEM_CLS2);
	                    }, 0.1);
	                });
		        });
			} else if(value== 'C3') {
				var store = new EVF.Store();
                store.setParameter("idNode",rowid);
                store.setParameter("idType",value);
		        store.load(baseUrl + "doGetParentId", function() {
		        	itemlist = JSON.parse(this.getParameter('itemlist_rst'));
		        	EVF.C('ITEM_CLS1').setValue(itemlist[0].ITEM_CLS1);

					var storeList = new EVF.Store();
					storeList.setParameter('type', '2');
					storeList.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
	                    EVF.C('ITEM_CLS2').setOptions(this.getParameter('itemClassList'));
	                    setTimeout(function(){
	                    	EVF.C('ITEM_CLS2').setValue(itemlist[0].ITEM_CLS2);

	    					var storeList2 = new EVF.Store();
	    					storeList2.setParameter('type', '3');
	    					storeList2.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
			                    EVF.C('ITEM_CLS3').setOptions(this.getParameter('itemClassList'));
			                    setTimeout(function(){
			                    	EVF.C('ITEM_CLS3').setValue(itemlist[0].ITEM_CLS3);
			                    }, 0.4);
	    					});
	                    }, 0.2);
	                });
		        });
             } else if (value== 'C4') {
 				var store = new EVF.Store();
                store.setParameter("idNode",rowid);
                store.setParameter("idType",value);
		        store.load(baseUrl + "doGetParentId", function() {
		        	itemlist = JSON.parse(this.getParameter('itemlist_rst'));
		        	EVF.C('ITEM_CLS1').setValue(itemlist[0].ITEM_CLS1);

					var storeList = new EVF.Store();
					storeList.setParameter('type', '2');
					storeList.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
	                    EVF.C('ITEM_CLS2').setOptions(this.getParameter('itemClassList'));
	                    setTimeout(function(){
	                    	EVF.C('ITEM_CLS2').setValue(itemlist[0].ITEM_CLS2);

	    					var storeList2 = new EVF.Store();
	    					storeList2.setParameter('type', '3');
	    					storeList2.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
			                    EVF.C('ITEM_CLS3').setOptions(this.getParameter('itemClassList'));
			                    setTimeout(function(){
			                    	EVF.C('ITEM_CLS3').setValue(itemlist[0].ITEM_CLS3);

			    					var storeList3 = new EVF.Store();
			    					storeList3.setParameter('type', '4');
			    					storeList3.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
			    						EVF.C('ITEM_CLS4').setOptions(this.getParameter('itemClassList'));
			    						setTimeout(function(){
			    							EVF.C('ITEM_CLS4').setValue(itemlist[0].ITEM_CLS4);
			    						}, 0.6);
			    					});
			                    }, 0.4);
	    					});
	                    }, 0.2);
	                });
		        });
			}

		});

        doSearchTree();
    }

    function doSearchTree() {
        var store = new EVF.Store();
        store.setGrid([gridTree]);
        store.load(baseUrl + "doSearchTree", function() {});
    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;

        store.setGrid([grid]);
        store.load(baseUrl + "doSearchItemCatalog", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }
    function checkSearchCondition() {

        if (EVF.C("ITEM_CLS1").getValue() != "") return true;
        if (EVF.C("ITEM_CLS2").getValue() != "") return true;
        if (EVF.C("ITEM_CLS3").getValue() != "") return true;
        if (EVF.C("ITEM_CLS4").getValue() != "") return true;
        if (EVF.C("ITEM_CD").getValue() != "") return true;
        if (EVF.C("ITEM_DESC").getValue() != "") return true;
        if (EVF.C("ITEM_SPEC").getValue() != "") return true;
        if (EVF.C("MAKER").getValue() != "") return true;

        return false;
    }

    function doSelect() {
        window.close();
        opener.window['${param.callBackFunction}'](JSON.stringify(grid.getSelRowValue()));
    }

    function doSave() {

        var gridDatas = grid.getSelRowValue();
        for( var i = 0, len = gridDatas.length; i < len; i++ ) {
        	if( !gridDatas[i].ITEM_QT > 0 ) { alert("${msg.M0014}"); return; }
        }

        var param = {
            datax: JSON.stringify(gridDatas),
            popupFlag: true
        };

        everPopup.openCatalogTemplatePopup(param);
    }

    function doClose() {
    	window.close();
    }

    function doRegister() {
        var valid = grid.validate();

        if( !valid.flag ) { alert("${msg.M0004}"); return; }
        if (!confirm("${BPR_040_PICKTOCATALOG}")) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + "doRegisterItemCatalog", function() {
            alert(this.getResponseMessage());
        });
    }

    function doPickToBasket() {
        var valid = grid.validate()
    		, selRows = grid.getSelRowValue();

		if( !valid.flag ) { alert("${msg.M0004}"); return; }

		for( var i = 0, len = selRows.length; i < len; i++ ) {
			if( Number(selRows[i].ITEM_QT) == 0 ) { alert("${msg.M0014}"); return; }
		}

		if (EVF.C("PLANT_CD").getValue()=='') {
			alert('${BPR_040_PICKTOBASKET1}');
			return;

		}

        if (!confirm("${BPR_040_PICKTOBASKET}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + "doPickToBasket", function() {
            if (this.getResponseMessage() == '${msg.M0001}') {
            	alert(this.getResponseMessage());
            	<%-- 2014.11.11 daguri
            	     Cart 조회 막음.
                if (confirm('${msg.M0001}\n${BPR_040_001}')) {
                    var params = {
                        popupFlag: '1'
                        , catalogSearch: '1'
                        , gate_cd: ${ses.gateCd}
                        /* , item_code:  grid.getCellValue('ITEM_CD') */
                    };
                    everPopup.openeShoppingBasket(params);
                }
                --%>
            } else {
                alert(this.getResponseMessage());
            }
        });
    }

    function onChangeItemClass() {
    	var id = this.getID();
        var store = new EVF.Store();

        switch(id) {
            case 'ITEM_CLS1':
                EVF.C('ITEM_CLS3').resetOption();
                EVF.C('ITEM_CLS3').appendOption('-----------------', '');
                EVF.C('ITEM_CLS4').resetOption();
                EVF.C('ITEM_CLS4').appendOption('-----------------', '');
                store.setParameter('type', '2');
                store.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
                    EVF.C('ITEM_CLS2').setOptions(this.getParameter('itemClassList'));
                }, false);
                break;
            case 'ITEM_CLS2':
                EVF.C('ITEM_CLS4').resetOption();
                EVF.C('ITEM_CLS4').appendOption('-----------------', '');
                store.setParameter('type', '3');
                store.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
                    EVF.C('ITEM_CLS3').setOptions(this.getParameter('itemClassList'));
                }, false);
                break;
            case 'ITEM_CLS3':
                store.setParameter('type', '4');
                store.load('/eversrm/system/task/BSYT_030/getItemClassList', function() {
                    EVF.C('ITEM_CLS4').setOptions(this.getParameter('itemClassList'));
                }, false);
                break;
        }
    }

    function doHideShowImage() {
    	colHideFlag = !colHideFlag;
    	grid.hideCol('IMAGE', colHideFlag);
    }
</script>

<e:window id="BPR_040" onReady="init" initData="${initData}" title="${fullScreenName}">

    <e:inputHidden id="searchClassType" name="searchClassType" />
    <e:inputHidden id="SCREEN_OPEN_TYPE" name="SCREEN_OPEN_TYPE"  value="${param.SCREEN_OPEN_TYPE}"/>
    <e:inputHidden id="PR_TYPE" name="PR_TYPE"  value="${param.PR_TYPE}"/>
    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD"  value="${param.VENDOR_CD}"/>
    <e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD"  value="${param.PUR_ORG_CD}"/>
    <e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE"  value="${param.PURCHASE_TYPE}"/>

    <e:panel width="25%" height="100%">
        <e:searchPanel id="formTree" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearchTree">
            <e:row>
				<e:label for="ITEM_TYPE" title="${formTree_ITEM_TYPE_N}" />
				<e:field>
					<e:inputText id="ITEM_TYPE" name="ITEM_TYPE" style="${imeMode}" value="${form.ITEM_TYPE}" width="100%" maxLength="${formTree_ITEM_TYPE_M}" disabled="${formTree_ITEM_TYPE_D}" readOnly="${formTree_ITEM_TYPE_RO}" required="${formTree_ITEM_TYPE_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doSearchTree_N }' id='doSearchTree' onClick='doSearchTree' disabled='${doSearchTree_D }' visible='${doSearchTree_V }' data='${doSearchTree_A}' />
        </e:buttonBar>
    </e:panel>
    <e:panel width="1%">&nbsp;</e:panel>
    <e:panel width="74%" height="100%">
        <e:searchPanel useTitleBar="false" id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
            <e:row>
	            <!-- 품목구분(유형) - M035 -->
				<e:label for="ITEM_KIND" title="${form_ITEM_KIND_N}"/>
				<e:field>
					<e:select id="ITEM_KIND" name="ITEM_KIND" value="${form.ITEM_KIND}" options="${refM035}" width="100%" disabled="${form_ITEM_KIND_D}" readOnly="${form_ITEM_KIND_RO}" required="${form_ITEM_KIND_R}" placeHolder="" />
				</e:field>
	            <!-- 자재그룹 - M179 -->
				<e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
				<e:field>
					<e:select id="MAT_GROUP" name="MAT_GROUP" value="${form.MAT_GROUP}" options="${refM179}" width="100%" disabled="${form_MAT_GROUP_D}" readOnly="${form_MAT_GROUP_RO}" required="${form_MAT_GROUP_R}" placeHolder="" />
				</e:field>
				<e:label for="" title=""/>
				<e:field>
					&nbsp;
				</e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}"/>
                <e:field colSpan="5">
                    <e:select id="ITEM_CLS1" name="ITEM_CLS1" options="${refITEM_CLASS1}" onChange="onChangeItemClass" width="25%" required="${form_ITEM_CLS_R }"	readOnly="${form_ITEM_CLS_RO }" disabled="${form_ITEM_CLS_D}" />
                    <e:select id="ITEM_CLS2" name="ITEM_CLS2" options="" onChange="onChangeItemClass" width="25%" required="${form_ITEM_CLS_R }"	readOnly="${form_ITEM_CLS_RO }" disabled="${form_ITEM_CLS_D}" />
                    <e:select id="ITEM_CLS3" name="ITEM_CLS3" options="" onChange="onChangeItemClass" width="25%" required="${form_ITEM_CLS_R }"	readOnly="${form_ITEM_CLS_RO }" disabled="${form_ITEM_CLS_D}" />
                    <e:select id="ITEM_CLS4" name="ITEM_CLS4" options="" onChange="onChangeItemClass" width="25%" required="${form_ITEM_CLS_R }"	readOnly="${form_ITEM_CLS_RO }" disabled="${form_ITEM_CLS_D}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" style='ime-mode:inactive' name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
				<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="100%" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="doHideShowImage" name="doHideShowImage" label="${doHideShowImage_N}" onClick="doHideShowImage" disabled="${doHideShowImage_D}" visible="${doHideShowImage_V}" align="left"/>
            <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A}' />
            <e:button label='${doSelect_N }' id='doSelect' onClick='doSelect' disabled='${doSelect_D }' visible='${doSelect_V }' data='${doSelect_A}' />
        </e:buttonBar>
    </e:panel>
		<e:panel id="leftPanel" height="fit" width="25%">
			<e:gridPanel gridType="${_gridType}" id="gridTree" name="gridTree" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}"/>
		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>
		<e:panel id="righttPanel" height="fit" width="74%">
			<e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
		</e:panel>
</e:window>
</e:ui>