<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e"  uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

<c:set var="ifItemMultiSelection" value="${param.returnType ne 'S'}" />

<style rel="stylesheet" type="text/css">

    .northPanel {
        padding: 0px;
        margin: 0px;
    }

    .ui-layout-north {
        padding: 0px;
    }

    .ui-layout-south {
        padding: 0px;
    }

    .ui-layout-west {
        padding: 0px;
    }

    .ui-layout-center {
        padding: 0 3px;
    }

    .e-window-container-body {
        height: 100%;
    }

    body {
        overflow: hidden;
    }
</style>
<script>

    var baseUrl = "/eversrm/master/catalog/BPR_040/";
    var grid;
    var gridBottom;
    var gridTree;
    var popupFlag;

    function init() {

        grid = EVF.C("grid");
        gridTree = EVF.C("gridTree");
        grid.setProperty('panelVisible', ${panelVisible});
        grid.setProperty('noSameValueWhenAddRow', ['ITEM_CD']);
        popupFlag = '${param.popupFlag}';

        var disabledId = '${param.disabledId}';
        if(EVF.isNotEmpty(disabledId)) {
            var disabledIdArr = disabledId.split(',');
            for(var i in disabledIdArr) {
                var id = disabledIdArr[i];
                EVF.C(id).setDisabled(true);
            }
        }

<c:if test="${ifItemMultiSelection}">
        if (popupFlag) {
            EVF.C('doSelect').setVisible(true);
        } else {
            EVF.C('doSelect').setVisible(false);
        }
</c:if>

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.cellClickEvent(function(rowId, colId, value) {
            if (colId == 'ITEM_CD') {
<c:choose>
    <c:when test="${ifItemMultiSelection}">
                var param = {
                    itemCd: value,
                    onClose: 'closePopup'
                };
                everPopup.openItemDetailInformation(param);
    </c:when>
    <c:otherwise>
                //opener.window['${param.callBackFunction}']('['+JSON.stringify(grid.getRowValue(rowId))+']','${param.rowId}');
	        	grid.checkRow(rowId, true, true, true);
                doClose();
    </c:otherwise>
</c:choose>

            } else if(colId == 'multiSelect') {

<c:if test="${not ifItemMultiSelection}">
                opener.window['${param.callBackFunction}'](JSON.stringify(grid.getSelRowValue()),'${param.rowId}');
                doClose();
</c:if>
            }
        });

        var itemTypeClkablePosNum = ${empty param.ITEM_CLS4 ? (empty param.ITEM_CLS3 ? (empty param.ITEM_CLS2 ? (empty param.ITEM_CLS1 ? 0
                                                                                                                     : fn:length(param.ITEM_CLS1))
                                                                                            : fn:length(param.ITEM_CLS2))
                                                                   : fn:length(param.ITEM_CLS3))
                                          : fn:length(param.ITEM_CLS4)};

        gridTree.cellClickEvent(function(rowId, colId, value) {

            var data = gridTree.getRowValue(rowId);
            if(data['tree'].length >= itemTypeClkablePosNum) {

                data['LAST_ITEM'] = (gridTree.getGridViewObj().getDescendants(gridTree.getIndex(rowId)) == null ? true : false);

                EVF.C('itemClassPath').setValue('▶ 품목분류: ' + gridTree.getRowValue(rowId)['ITEM_CLS_PATH_NM']);

                EVF.V('ITEM_CLS1', (data['ITEM_CLS1'] == '*' ? '' : data['ITEM_CLS1']));
                EVF.V('ITEM_CLS2', (data['ITEM_CLS2'] == '*' ? '' : data['ITEM_CLS2']));
                EVF.V('ITEM_CLS3', (data['ITEM_CLS3'] == '*' ? '' : data['ITEM_CLS3']));
                EVF.V('ITEM_CLS4', (data['ITEM_CLS4'] == '*' ? '' : data['ITEM_CLS4']));

	                if(data['ITEM_CLS4'] != '*')
	                {
	                  doSearch();
	                }
            }
        });

        var treeViewObj = gridTree.getGridViewObj();
        treeViewObj.setHeader({visible: true});
//        treeViewObj.setTreeOptions({showCheckBox: true}); // 체크박스를 노드명 앞에 두려면 이 설정을 한다.
        treeViewObj.setCheckBar({visible: false});
        treeViewObj.setIndicator({visible: false});

        gridTree.setProperty('shrinkToFit', true);
        gridTree.setColCursor('ITEM_CLS_NM', 'pointer');

        gridTree._gdp.onRowCountChanged = function(provider, count) {

            var layoutProp = EVF.Properties.layout;
            layoutProp.west.minSize = 300;
            layoutProp.west.maxSize = 300;
<c:if test="${param.treeView eq 'false'}">
            layoutProp.west__initClosed = true;
</c:if>
            layoutProp.panes = {};
            layoutProp.onopen = function() {
                $(window).trigger('resize');
            };
            layoutProp.onclose = function() {
                $(window).trigger('resize');
            };
            setTimeout(function() {
                $('#e-window-container-body').layout(layoutProp);
                $(window).trigger('resize');
            }, 1000);
        };

        doSearchTree2();

<c:choose>
    <c:when test="${ifItemMultiSelection}">
        gridBottom = EVF.C("gridBottom");
    </c:when>
    <c:otherwise>
        grid.setProperty('singleSelect', true);
    </c:otherwise>
</c:choose>

        $(window).trigger('resize');

        $(window).on('resize', function() {
            setTimeout(function() {
                grid.resize();
                if(gridBottom != null) {
                    gridBottom.resize();
                }
            }, 500);
        });


        if(EVF.V("BUSINESS_TYPE")!=''){
            _setMakerOption();
        }

    }

    function doSearchTree2() {

        var store = new EVF.Store();
        store.load(baseUrl + '/doSearchDtree', function() {

            var treeData = this.getParameter("treeData");
            var jsonTree = JSON.parse(treeData);

            gridTree.getDataProvider().setRows(jsonTree, 'tree', true, '', 'icon');

            var treeViewObj = gridTree.getGridViewObj();
            treeViewObj.expandAll();

            var allRowId = gridTree.getAllRowId();
            for(var i in allRowId) {
                var rowId = allRowId[i];
                var datum = gridTree.getRowValue(rowId);
                if(datum['ITEM_CLS1']+datum['ITEM_CLS2']+datum['ITEM_CLS3']+datum['ITEM_CLS4']
                    == EVF.defaultIfEmpty(EVF.V('ITEM_CLS1'), '*')+EVF.defaultIfEmpty(EVF.V('ITEM_CLS2'), '*')
                    +EVF.defaultIfEmpty(EVF.V('ITEM_CLS3'), '*')+EVF.defaultIfEmpty(EVF.V('ITEM_CLS4'), '*')) {
                    EVF.C('itemClassPath').setValue('▶ 품목분류: '+gridTree.getRowValue(rowId)['ITEM_CLS_PATH_NM']);
                    break;
                }
            }
        });
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

    function doSelect() {

        if(gridBottom.getSelRowCount() == 0) {
            if(!confirm('${BPR_041_NO_SELECTED_ITEM}')) {
                return;
            }
        }
        opener.window['${param.callBackFunction}'](JSON.stringify(gridBottom.getSelRowValue()),'${param.rowId}');

        doClose();
    }

    function doClose() {
    	window.close();
    }

    function _setMakerOption() {

        var maker = EVF.C('MAKER');
        var businessType = EVF.C('BUSINESS_TYPE');
        var businessTypeValue = businessType.getValue();

        if(businessTypeValue == '100') <%-- IT --%> {
            maker.setOptions(${makerItOptions});
            EVF.C("BRAND_CD").setDisabled(true);
        } else if(businessTypeValue == '200') {
            maker.setOptions(${makerRetailOptions});
            EVF.C("BRAND_CD").setDisabled(false);
        } else {
            maker.resetOption();
        }
    }

    function _getVendors() {
        var param = {
            callBackFunction: "_setVendor"
        };
        everPopup.openCommonPopup(param, 'SP0025');
    }

    function _setVendor(jsonData) {

        EVF.C("VENDOR_CD").setValue(jsonData.VENDOR_CD);
        EVF.C("VENDOR_NM").setValue(jsonData.VENDOR_NM);
    }

    function moveToUp() {

        var data = gridBottom.getSelRowValue();
        var rowId = grid.addRow(data);

        if(rowId instanceof String) {
            grid.checkRow(rowId, false);
        } else {
            for(var i in rowId) {
                var ri = rowId[i];
                grid.checkRow(ri, false);
            }
        }

        gridBottom.delRow();
    }

    function moveToDown() {
        var rtnHaltItem="";
        var	rows = grid.getSelRowId();
        for(var	i =	rows.length-1; i >=	0; i--)	{
            var	row	= rows[i];

            if(grid.getCellValue(row,"ORDER_HALT_FLAG") ==	"1")	{
                if(rtnHaltItem==""){
                    rtnHaltItem = grid.getCellValue(row,"ITEM_CD")+", "+grid.getCellValue(row,"ITEM_DESC");
                }else{
                    rtnHaltItem = rtnHaltItem + "\n" + grid.getCellValue(row,"ITEM_CD")+", "+grid.getCellValue(row,"ITEM_DESC");
                }
            }else{
                gridBottom.addRow(grid.getRowValue(row));

                if(${param.dupItemAllow eq true}) {
                    gridBottom.setProperty('noSameValueWhenAddRow', null);
                } else {
                    gridBottom.setProperty('noSameValueWhenAddRow', ["ITEM_CD"]);
                    grid.delRow(row);
                }
            }
        }


        if(rtnHaltItem!=""){
            alert(rtnHaltItem+'${BPR_041_001}');
        }


        <%--if(${param.dupItemAllow eq true}) {--%>
            <%--gridBottom.setProperty('noSameValueWhenAddRow', null);--%>
        <%--} else {--%>
            <%--gridBottom.setProperty('noSameValueWhenAddRow', ["ITEM_CD"]);--%>
            <%--grid.delRow();--%>
        <%--}--%>

    }

</script>

    <e:window id="BPR_041" onReady="init" initData="${initData}" title="${fullScreenName}">

        <div class="ui-layout-west" style="visibility: hidden;">
            <div class="ui-layout-center" style="overflow-x:hidden;overflow-y:auto;" >
                <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${param.ITEM_CLS1}" />
                <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${param.ITEM_CLS2}" />
                <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${param.ITEM_CLS3}" />
                <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${param.ITEM_CLS4}" />
                <e:inputHidden id="SOLE_ITEM_YN" name="SOLE_ITEM_YN" value="${param.soleItemYn}" />

                <c:if test="${empty param.ITEM_CLS2 and empty param.ITEM_CLS3 and empty param.ITEM_CLS4}">
                    <e:searchPanel id="formTree" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearchTree2">
                        <e:row>
                            <e:label for="ITEM_TYPE" title="${formTree_ITEM_TYPE_N}" />
                            <e:field>
                                <e:inputText id="ITEM_TYPE" name="ITEM_TYPE" style="${imeMode}" value="${form.ITEM_TYPE}" width="100%" maxLength="${formTree_ITEM_TYPE_M}" disabled="${formTree_ITEM_TYPE_D}" readOnly="${formTree_ITEM_TYPE_RO}" required="${formTree_ITEM_TYPE_R}" />
                            </e:field>
                        </e:row>
                    </e:searchPanel>
                    <e:buttonBar align="right">
                        <e:button label='${doSearchTree_N }' id='doSearchTree' onClick='doSearchTree2' disabled='${doSearchTree_D }' visible='${doSearchTree_V }' data='${doSearchTree_A}' />
                    </e:buttonBar>
                </c:if>
                <e:gridPanel gridType="RGT" id="gridTree" name="gridTree" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTree.gridColData}" />
            </div>
        </div>

        <div id="contentsBody" class="ui-layout-center" style="visibility: hidden;">
            <e:searchPanel useTitleBar="false" id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
                <e:row>
                    <e:label for="BUSINESS_TYPE" title="${form_BUSINESS_TYPE_N}"/>
                    <e:field>
                        <e:select id="BUSINESS_TYPE" name="BUSINESS_TYPE" value="${param.BUSINESS_TYPE}" options="${businessTypeOptions}" width="100%" disabled="${not empty param.BUSINESS_TYPE ? 'true' : form_BUSINESS_TYPE_D}" readOnly="${form_BUSINESS_TYPE_RO}" required="${form_BUSINESS_TYPE_R}" placeHolder="" onChange="_setMakerOption" />
                    </e:field>
                    <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                    <e:field>
                        <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                    </e:field>
                    <e:label for="STOCK_ITEM_YN" title="${form_STOCK_ITEM_YN_N}"/>
                    <e:field>
                        <e:select id="STOCK_ITEM_YN" name="STOCK_ITEM_YN" value="${param.stockItemYn}" options="${stockItemYnOptions}" width="100%" disabled="${form_STOCK_ITEM_YN_D}" readOnly="${form_STOCK_ITEM_YN_RO}" required="${form_STOCK_ITEM_YN_R}" placeHolder="" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
                    <e:field>
                        <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                    </e:field>
                    <e:label for="MAKER" title="${form_MAKER_N}"/>
                    <e:field>
                        <e:select id="MAKER" name="MAKER" value="" options="${makerOptions}" width="100%" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true">
                            <e:option text="-------------------" value="" />
                        </e:select>
                    </e:field>
                    <e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}"/>
                    <e:field>
                        <e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="" width="100%" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                    <e:field>
                        <e:search id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="30%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : '_getVendors'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                        <e:text>&nbsp;</e:text>
                        <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="40%" disabled="${form_VENDOR_CD_D}" maxLength="${form_VENDOR_CD_M}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    </e:field>
                    <e:label for="BRAND_CD" title="${form_BRAND_CD_N}"/>
                    <e:field>
                        <e:select id="BRAND_CD" name="BRAND_CD" value="" options="${brandCdOptions}" width="100%" disabled="${form_BRAND_CD_D}" readOnly="${form_BRAND_CD_RO}" required="${form_BRAND_CD_R}" placeHolder="" />
                    </e:field>
                    <e:label for="ORDER_HALT_FLAG" title="${form_ORDER_HALT_FLAG_N}"/>
                    <e:field>
                        <e:select id="ORDER_HALT_FLAG" name="ORDER_HALT_FLAG" value="${empty form.ORDER_HALT_FLAG ? '0' : form.ORDER_HALT_FLAG}" options="${orderHaltFlagOptions}" width="100%" disabled="${form_ORDER_HALT_FLAG_D}" readOnly="${form_ORDER_HALT_FLAG_RO}" required="${form_ORDER_HALT_FLAG_R}" placeHolder="" />
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar align="right">
                <e:text id="itemClassPath" style="float: left"></e:text>
                <div style="display: block; text-align: right; position: absolute; width: 151px; top: -1px; right: 140px;">
                    <e:text>패키지 여부:</e:text>
                    <e:checkGroup id="PACKAGE_TYPE" name="PACKAGE_TYPE" disabled="${not empty param.PACKAGE_TYPE ? 'true' : 'false'}" readOnly="false" required="false">
                        <e:check id="PACKAGE_TYPE_Y" name="PACKAGE_TYPE_Y" label="Y" value="200" checked="${param.PACKAGE_TYPE eq '200' ? 'true' : 'false'}" disabled="${not empty param.PACKAGE_TYPE ? 'true' : 'false'}" />
                        <e:text>, </e:text>
                        <e:check id="PACKAGE_TYPE_N" name="PACKAGE_TYPE_N" label="N" value="100" checked="${param.PACKAGE_TYPE eq '100' ? 'true' : 'false'}" disabled="${not empty param.PACKAGE_TYPE ? 'true' : 'false'}" />
                    </e:checkGroup>
                </div>
                <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A}' />
<%-- <c:if test="${ifItemMultiSelection}">
                <e:button label='${doSelect_N }' id='doSelect' onClick='doSelect' disabled='${doSelect_D }' visible='${doSelect_V }' data='${doSelect_A}' />
</c:if> --%>
                <%--<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>--%>
            </e:buttonBar>

            <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="${ifItemMultiSelection ? '300' : 'fit'}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

            <%-- 품목을 하나만 선택해야할 경우 returnType=S 로 파라미터 받는다. --%>
<c:if test="${ifItemMultiSelection}">
                <div style="width: 100%; height: 25px; text-align: center;">
                    <a href="javascript:moveToDown();">
                        <div style="display: inline-block; height: 22px; width: 22px; background: url(/images/everuxf/theme/kakao/icons/arrow_d.png) no-repeat"></div>
                    </a>
                    <a href="javascript:moveToUp();">
                        <div style="display: inline-block; height: 22px; width: 22px; background: url(/images/everuxf/theme/kakao/icons/arrow_t.png) no-repeat"></div>
                    </a>
<c:if test="${ifItemMultiSelection}">
                <e:button  align="right" label='${doSelect_N }' id='doSelect' onClick='doSelect' disabled='${doSelect_D }' visible='${doSelect_V }' data='${doSelect_A}' />
</c:if>
                </div>


                <e:gridPanel gridType="${_gridType}" id="gridBottom" width="100%" name="gridBottom" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridBottom.gridColData}"/>
</c:if>
        </div>

    </e:window>
</e:ui>