<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/evermp/IM04/IM0402/";
    var icGrid;
    var ptGrid;
    var SelectRowId;
    var SelectGrid;

    function init() {

        delType = 'ic';
    	icGrid = EVF.C("icGrid");
    	icGrid.setProperty('shrinkToFit', true);
    	icGrid.setProperty('panelVisible', ${panelVisible});

        // Grid Excel Export
        icGrid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            fileName : "${screenName }"
        });
        icGrid.addRowEvent(function() {
            icGrid.addRow();
        });

        <%--ptGrid = EVF.C("ptGrid");--%>
        <%--ptGrid.setProperty('shrinkToFit', true);--%>
        <%--ptGrid.setProperty('panelVisible', ${panelVisible});--%>
        <%--ptGrid.excelExportEvent({--%>
            <%--allCol : "${excelExport.allCol}",--%>
            <%--fileName : "${screenName }"--%>
        <%--});--%>
        <%--ptGrid.addRowEvent(function() {--%>
            <%--ptGrid.addRow();--%>
        <%--});--%>

        icGrid.delRowEvent(function() {
            if(!icGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            var selRowId = icGrid.jsonToArray(icGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(icGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${IM04_003_0004}');
                }
            }
            icGrid.delRow();
        });

        <%--ptGrid.delRowEvent(function() {--%>
            <%--if(!ptGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }--%>
            <%--var selRowId = ptGrid.jsonToArray(ptGrid.getSelRowId()).value;--%>
            <%--for (var i = 0; i < selRowId.length; i++) {--%>
                <%--if(ptGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){--%>
                    <%--return alert('${IM04_003_0004}');--%>
                <%--}--%>
            <%--}--%>
            <%--ptGrid.delRow();--%>
        <%--});--%>

        icGrid.cellClickEvent(function(rowid, colId, value) {
            switch (colId) {
                case 'SG_CLS_PATH':
                    var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
                    var param = {
                        callBackFunction: '_setSg_Grid',
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true
                    };
                    SelectGrid = "ic";
                    SelectRowId = rowid;
                    everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
                    break;
				case 'ITEM_CLS_PATH':
                    var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                    var param = {
                        callBackFunction : "_setItemClassNm_Grid",
                        'detailView': false,
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true,
                        'custCd' : '${ses.companyCd}',
                        'custNm' : '${ses.companyNm}'
                    };
                    SelectGrid = "ic";
                    SelectRowId = rowid;
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
			    break;
            }
        });

        <%--ptGrid.cellClickEvent(function(rowid, colId, value) {--%>
            <%--switch (colId) {--%>
                <%--case 'SG_CLS_PATH':--%>
                    <%--var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";--%>
                    <%--var param = {--%>
                        <%--callBackFunction: '_setSg_Grid',--%>
                        <%--'multiYN' : false,--%>
                        <%--'ModalPopup' : true,--%>
                        <%--'searchYN' : true--%>
                    <%--};--%>
                    <%--SelectGrid = "pt";--%>
                    <%--SelectRowId = rowid;--%>
                    <%--everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");--%>
                    <%--break;--%>
                <%--case 'ITEM_CLS_PATH':--%>
                    <%--var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";--%>
                    <%--var param = {--%>
                        <%--callBackFunction : "_setItemClassNm_Grid",--%>
                        <%--'detailView': false,--%>
                        <%--'multiYN' : false,--%>
                        <%--'ModalPopup' : true,--%>
                        <%--'searchYN' : true,--%>
                        <%--'ptYn' : true,--%>
                        <%--'screenName': '분류체계(판촉)',--%>
                        <%--'custCd' : '${ses.manageCd}',--%>
                        <%--'custNm' : '${ses.companyNm}'--%>
                    <%--};--%>
                    <%--SelectGrid = "pt";--%>

                    <%--SelectRowId = rowid;--%>
                    <%--everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");--%>
                <%--break;--%>
            <%--}--%>
        <%--});--%>
    }

    function getContentTab(uu) {
        if (uu == '1') {
            delType = 'ic'
        }
        if (uu == '2') {
            delType = 'pt'
        }
    }

    $(document.body).ready(function() {
        $('#e-tabs').height(($('.ui-layout-center').height() - 30)).tabs({
            activate : function(event, ui) {

                $(window).trigger('resize');
            }
        });
        $('#e-tabs').tabs('option', 'active', 0);
    });

    function doSearch() {
        var store = new EVF.Store();
//        store.setGrid([icGrid,ptGrid]);
        store.setGrid([icGrid]);
        store.load(baseUrl + "IM04_003/doSearch", function() {
        });
    }

    function doSave() {

    	var store = new EVF.Store();
        var method = '';

        if (delType == 'ic') {
            if ((icGrid.jsonToArray(icGrid.getSelRowId()).value).length == 0) {
                return alert("${msg.M0004}");
            }
            store.setGrid([icGrid]);
            method = 'doSaveIcGrid';
            store.getGridData(icGrid, 'sel');
        }

        <%--if (delType == 'pt') {--%>
            <%--if ((ptGrid.jsonToArray(ptGrid.getSelRowId()).value).length == 0) {--%>
            	<%--return alert("${msg.M0004}");--%>
            <%--}--%>
            <%--store.setGrid([ptGrid]);--%>
            <%--method = 'doSaveptGrid';--%>
            <%--store.getGridData(ptGrid, 'sel');--%>
        <%--}--%>



        if(!confirm('${msg.M0021}')) { return; }
        store.load(baseUrl + '/IM04_003/'+method+'', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }


    function doDelete() {

    	var store = new EVF.Store();
		var method = '';
    	<%--if (delType == 'pt') {--%>
			<%--if ((ptGrid.jsonToArray(ptGrid.getSelRowId()).value).length == 0) {--%>
	            <%--return alert("${msg.M0004}");--%>
	        <%--}--%>
            <%--var selRowId = ptGrid.jsonToArray(ptGrid.getSelRowId()).value;--%>
            <%--for (var i = 0; i < selRowId.length; i++) {--%>
                <%--if(ptGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){--%>
                    <%--return alert('${IM04_003_0005}');--%>
                <%--}--%>
            <%--}--%>

			<%--store.setGrid([ptGrid]);--%>
			<%--method = 'doDeleteptGrid';--%>
			<%--store.getGridData(ptGrid, 'sel');--%>
    	<%--}--%>

    	if (delType == 'ic') {
			if ((icGrid.jsonToArray(icGrid.getSelRowId()).value).length == 0) {
				return alert("${msg.M0004}");
	        }

            var selRowId = icGrid.jsonToArray(icGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(icGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                    return alert('${IM04_003_0005}');
                }
            }
			store.setGrid([icGrid]);
			method = 'doDeleteIcGrid';
			store.getGridData(icGrid, 'sel');
    	}

    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}

    	store.load(baseUrl + '/IM04_003/'+method+'', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function _getItemClsNm()  {

        var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
        var param = {
            callBackFunction : "_setItemClassNm",
            'detailView': false,
            'multiYN' : false,
            'ModalPopup' : true,
			'searchYN' : true,
            'custCd' : '${ses.companyCd}',
            'custNm' : '${ses.companyNm}'
        };
        everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
    }

    function _setItemClassNm(data) {
        if(data!=null){
            data = JSON.parse(data);
            EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
            if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
            if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
            if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
            EVF.C("ITEM_CLS").setValue(data.ITEM_CLS_PATH_NM);
		} else {
            EVF.C("ITEM_CLS1").setValue("");
            EVF.C("ITEM_CLS2").setValue("");
            EVF.C("ITEM_CLS3").setValue("");
            EVF.C("ITEM_CLS4").setValue("");
            EVF.C("ITEM_CLS").setValue("");
		}
    }

    function _setItemClassNm_Grid(data){
        if(data!=null){
            data = JSON.parse(data);

            if(data.SG_YN!=''){
                return alert(data.ITEM_CLS_PATH_NM+'${IM04_003_0006}')
            }
            if (SelectGrid == "ic") {

                icGrid.setCellValue(SelectRowId, "M_CATE_YN", "1");
                icGrid.setCellValue(SelectRowId, "P_CATE_YN", "0");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", data.ITEM_CLS_PATH_NM);
                icGrid.setCellValue(SelectRowId, "ITEM_CLS1", data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){
                    icGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                }else{
                    icGrid.setCellValue(SelectRowId, "ITEM_CLS2", data.ITEM_CLS2);
                }
                if(data.ITEM_CLS3=="*"){
                    icGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                }else{
                    icGrid.setCellValue(SelectRowId, "ITEM_CLS3", data.ITEM_CLS3);
                }
                if(data.ITEM_CLS3=="*"){
                    icGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
                }else{
                    icGrid.setCellValue(SelectRowId, "ITEM_CLS4", data.ITEM_CLS4);
                }


            } else if (SelectGrid == "pt") {
                ptGrid.setCellValue(SelectRowId, "M_CATE_YN", "0");
                ptGrid.setCellValue(SelectRowId, "P_CATE_YN", "1");
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", data.ITEM_CLS_PATH_NM);
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS1", data.ITEM_CLS1);
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
                if(data.ITEM_CLS2=="*"){
                    ptGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                }else{
                    ptGrid.setCellValue(SelectRowId, "ITEM_CLS2", data.ITEM_CLS2);
                }
                if(data.ITEM_CLS3=="*"){
                    ptGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                }else{
                    ptGrid.setCellValue(SelectRowId, "ITEM_CLS3", data.ITEM_CLS3);
                }
            }

        }else{
            if (SelectGrid == "ic") {
                icGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS1", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
            } else if (SelectGrid == "pt") {
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", "");
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS1", "");
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                ptGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
            }
        }
    }

    function _getSGClsNm(){

    	var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
        var param = {
            callBackFunction: '_setSg',
            'multiYN' : false,
            'ModalPopup' : true,
            'searchYN' : true
        };
        everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
	}

    function _setSg(data) {
        if(data!=null){
            data = JSON.parse(data);
            EVF.C("SG_NUM1").setValue(data.ITEM_CLS1);
            if(data.ITEM_CLS2=="*"){EVF.C("SG_NUM2").setValue("");}else{EVF.C("SG_NUM2").setValue(data.ITEM_CLS2);}
            if(data.ITEM_CLS3=="*"){EVF.C("SG_NUM3").setValue("");}else{EVF.C("SG_NUM3").setValue(data.ITEM_CLS3);}
            if(data.ITEM_CLS4=="*"){EVF.C("SG_NUM4").setValue("");}else{EVF.C("SG_NUM4").setValue(data.ITEM_CLS4);}
            EVF.C("SG_NUM").setValue(data.ITEM_CLS_PATH_NM);
        } else {
            EVF.C("SG_NUM1").setValue("");
            EVF.C("SG_NUM2").setValue("");
            EVF.C("SG_NUM3").setValue("");
            EVF.C("SG_NUM4").setValue("");
            EVF.C("SG_NUM").setValue("");
		}
    }

    function _setSg_Grid(data) {
        if (data != null) {
            data = JSON.parse(data);

            if (SelectGrid == "ic") {
                icGrid.setCellValue(SelectRowId, "SG_CLS_PATH", data.ITEM_CLS_PATH_NM);
                icGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS1);
                if (data.ITEM_CLS2 == "*") {
                    icGrid.setCellValue(SelectRowId, "SG_CLS_NM2", "");
                } else {
                    icGrid.setCellValue(SelectRowId, "SG_CLS_NM2", data.ITEM_CLS2);
                    icGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS2);
                }
                if (data.ITEM_CLS3 == "*") {
                    icGrid.setCellValue(SelectRowId, "SG_CLS_NM3", "");
                } else {
                    icGrid.setCellValue(SelectRowId, "SG_CLS_NM3", data.ITEM_CLS3);
                    icGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS3);
                }
                if (data.ITEM_CLS4 == "*") {
                    icGrid.setCellValue(SelectRowId, "SG_CLS_NM4", "");
                } else {
                    icGrid.setCellValue(SelectRowId, "SG_CLS_NM4", data.ITEM_CLS4);
                    icGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS4);
                }
            } else if (SelectGrid == "pt") {
                ptGrid.setCellValue(SelectRowId, "SG_CLS_PATH", data.ITEM_CLS_PATH_NM);
                ptGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS1);
                if (data.ITEM_CLS2 == "*") {
                    ptGrid.setCellValue(SelectRowId, "SG_CLS_NM2", "");
                } else {
                    ptGrid.setCellValue(SelectRowId, "SG_CLS_NM2", data.ITEM_CLS2);
                    ptGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS2);
                }
                if (data.ITEM_CLS3 == "*") {
                    ptGrid.setCellValue(SelectRowId, "SG_CLS_NM3", "");
                } else {
                    ptGrid.setCellValue(SelectRowId, "SG_CLS_NM3", data.ITEM_CLS3);
                    ptGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS3);
                }
                if (data.ITEM_CLS4 == "*") {
                    ptGrid.setCellValue(SelectRowId, "SG_CLS_NM4", "");
                } else {
                    ptGrid.setCellValue(SelectRowId, "SG_CLS_NM4", data.ITEM_CLS4);
                    ptGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS4);
                }
            }
        } else {
            if (SelectGrid == "ic") {
                icGrid.setCellValue(SelectRowId, "SG_CLS_PATH", "");
                icGrid.setCellValue(SelectRowId, "SG_NUM", "");
            } else if (SelectGrid == "pt") {
                ptGrid.setCellValue(SelectRowId, "SG_CLS_PATH", "");
                ptGrid.setCellValue(SelectRowId, "SG_NUM", "");
            }
        }
    }

    function cleanSGClass() {
        EVF.C("SG_NUM1").setValue('');
        EVF.C("SG_NUM2").setValue('');
        EVF.C("SG_NUM3").setValue('');
        EVF.C("SG_NUM4").setValue('');
        EVF.C("SG_NUM").setValue('');
    }

    function cleanItemClass() {
        EVF.C("ITEM_CLS1").setValue('');
        EVF.C("ITEM_CLS2").setValue('');
        EVF.C("ITEM_CLS3").setValue('');
        EVF.C("ITEM_CLS4").setValue('');
        EVF.C("ITEM_CLS").setValue('');
    }

</script>

<e:window id="IM04_003" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${longLabelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearchTree">
            <e:row>

				<e:label for="SG_NUM" title="${form_SG_NUM_N}"/>
				<e:field>
					<e:search id="SG_NUM" name="SG_NUM" value="" width="100%" maxLength="${form_SG_NUM_M}" onIconClick="_getSGClsNm" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" onClear="cleanSGClass" onChange="cleanSGClass"/>
				</e:field>
				<e:inputHidden id="SG_NUM1" name="SG_NUM1" value=""/>
				<e:inputHidden id="SG_NUM2" name="SG_NUM2" />
				<e:inputHidden id="SG_NUM3" name="SG_NUM3" />
				<e:inputHidden id="SG_NUM4" name="SG_NUM4" />

				<e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}"/>
				<e:field>
					<e:search id="ITEM_CLS" name="ITEM_CLS" value="" width="100%" maxLength="${form_ITEM_CLS_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" onClear="cleanItemClass" onChange="cleanItemClass"/>
				</e:field>
				<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
				<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
				<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
				<e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
			</e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>
	<e:gridPanel gridType="${_gridType}" id="icGrid" name="icGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.icGrid.gridColData}"/>


    <%--<div id="e-tabs" class="e-tabs" style="padding: 0 !important;">--%>
        <%--<tr><td><div>--%>
          <%--<ul>--%>
            <%--<li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${IM04_003_IC_TAB}</a></li>--%>
            <%--<li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${IM04_003_PT_TAB}</a></li>--%>
          <%--</ul>--%>

          <%--<div id="ui-tabs-1">--%>
			<%--<div style="height: auto;">--%>
				<%--<e:gridPanel gridType="${_gridType}" id="icGrid" name="icGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.icGrid.gridColData}"/>--%>
			<%--</div>--%>
          <%--</div>--%>
          <%----%>
          <%--<div id="ui-tabs-2">--%>
			<%--<div style="height: auto;">--%>
				<%--<e:gridPanel gridType="${_gridType}" id="ptGrid" name="ptGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.ptGrid.gridColData}"/>--%>
			<%--</div>--%>
          <%--</div>--%>
		<%--</div></td></tr>--%>
	<%--</div>          --%>

</e:window>
</e:ui>