<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/srm/master/sgItemClass/";
    var icGrid;
    var sgGrid;
    var SelectRowId;
    var SelectGrid;

    function init() {
    	icGrid = EVF.C("icGrid");
    	sgGrid = EVF.C("sgGrid");
    	icGrid.setProperty('shrinkToFit', true);
    	sgGrid.setProperty('shrinkToFit', true);

    	icGrid.setProperty('panelVisible', ${panelVisible});
    	sgGrid.setProperty('panelVisible', ${panelVisible});

        // Grid Excel Export
        icGrid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        sgGrid.excelExportEvent({
            allCol : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        icGrid.addRowEvent(function() {
            icGrid.addRow();
        });

        sgGrid.addRowEvent(function() {
            sgGrid.addRow();
        });

        icGrid.delRowEvent(function() {
            if(!icGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = icGrid.jsonToArray(icGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(icGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${SRM_030_0004}');
                }
            }

            icGrid.delRow();
        });

        sgGrid.delRowEvent(function() {
            if(!sgGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = sgGrid.jsonToArray(sgGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(sgGrid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${SRM_030_0004}');
                }
            }

            sgGrid.delRow();
        });


        icGrid.cellClickEvent(function(rowid, colId, value) {
            switch (colId) {
                case 'SG_CLS_PATH':
                    var popupUrl = "/eversrm/srm/master/sourcing/SRM_010_TREEP/view";
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
                    var popupUrl = "/eversrm/master/item/BBM_011/view";
                    var param = {
                        callBackFunction : "_setItemClassNm_Grid",
                        'detailView': false,
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true
                    };
                    SelectGrid = "ic";
                    SelectRowId = rowid;
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
				    break;

            }
        });

        sgGrid.cellClickEvent(function(rowid, colId, value) {
            switch (colId) {
                case 'SG_CLS_PATH':
                    var popupUrl = "/eversrm/srm/master/sourcing/SRM_010_TREEP/view";
                    var param = {
                        callBackFunction: '_setSg_Grid',
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true
                    };
                    SelectGrid = "sg";
                    SelectRowId = rowid;
                    everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
                    break;
                case 'ITEM_CLS_PATH':
                    var popupUrl = "/eversrm/master/item/BBM_011/view";
                    var param = {
                        callBackFunction : "_setItemClassNm_Grid",
                        'detailView': false,
                        'multiYN' : false,
                        'ModalPopup' : true,
                        'searchYN' : true
                    };
                    SelectGrid = "sg";
                    SelectRowId = rowid;
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
                    break;

            }
        });


        /*
                sgGrid.setColFooter(
                        {
                               'merge'      : true
                            , 'groupField' :
                                [
                                    'SG_CLS_NM1'
                                    ,'SG_CLS_NM2'
                                    ,'SG_CLS_NM3'
                                    ,'SG_CLS_NM4'
                                ]
                        }
                );

                icGrid.setColFooter(
                        {
                               'merge'      : true
                            , 'groupField' :
                                [
                                    'ITEM_CLS_NM1'
                                    ,'ITEM_CLS_NM2'
                                    ,'ITEM_CLS_NM3'
                                    ,'ITEM_CLS_NM4'
                                ]
                        }
                );*/
    }

    function getContentTab(uu) {
        if (uu == '1') {
        	delType = 'sg'
        }
        if (uu == '2') {
        	delType = 'ic'
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

//    function chSg() {
//        var store = new EVF.Store;
//        var sg_type = this.getData();
//
//        if (sg_type=='2') {
//            store.setParameter('PARENT_SG_NUM',EVF.getComponent('SG_NUM1').getValue());
//            clearY('3');
//            clearY('4');
//        }
//        if (sg_type=='3') {
//            store.setParameter('PARENT_SG_NUM',EVF.getComponent('SG_NUM2').getValue());
//            clearY('4');
//        }
//        if (sg_type=='4') {
//            store.setParameter('PARENT_SG_NUM',EVF.getComponent('SG_NUM3').getValue());
//        }
//        store.load(baseUrl + '/SRM_030/chSg', function() {
//          EVF.getComponent('SG_NUM'+sg_type).setOptions(this.getParameter("sgData"));
//        });
//    }
//
//	function clearY( cls_typef ) {
//		EVF.C('SG_NUM'+ cls_typef ).setOptions( JSON.parse('[]')    );
//	}


//	function getitem_cls() {
//    	var store = new EVF.Store();
//
//    	var cls_type = this.getData();
//    	item_cls='';
//    	if (cls_type=='2') {
//    		item_cls= EVF.getComponent("ITEM_CLS1").getValue();
//    		clearX('3');
//    		clearX('4');
//    	}
//    	if (cls_type=='3') {
//    		item_cls= EVF.getComponent("ITEM_CLS2").getValue();
//    		clearX('4');
//    	}
//    	if (cls_type=='4') {
//    		item_cls= EVF.getComponent("ITEM_CLS3").getValue();
//    	}
//
//	    	store.load('/eversrm/master/item/' + 'getItem_Cls.so?CLS_TYPE='+cls_type+'&ITEM_CLS='+item_cls, function() {
//    		EVF.C('ITEM_CLS'+ cls_type ).setOptions(this.getParameter("item_cls"));
//        });
//	}

//	function clearX( cls_typef ) {
//		EVF.C('ITEM_CLS'+ cls_typef ).setOptions( JSON.parse('[]')    );
//	}

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([icGrid,sgGrid]);
        store.load(baseUrl + "SRM_030/doSearch", function() {
        });
    }
    var delType ='sg';

    function doDelete() {
    	var store = new EVF.Store();
		var method = '';
    	if (delType == 'sg') {
			if ((sgGrid.jsonToArray(sgGrid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
            var selRowId = sgGrid.jsonToArray(sgGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(sgGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                    return alert('${SRM_030_0005}');
                }
            }

			store.setGrid([sgGrid]);
			method = 'doDeleteSgGrid';
			store.getGridData(sgGrid, 'sel');
    	}

    	if (delType == 'ic') {
			if ((icGrid.jsonToArray(icGrid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

            var selRowId = icGrid.jsonToArray(icGrid.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(icGrid.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                    return alert('${SRM_030_0005}');
                }
            }
			store.setGrid([icGrid]);
			method = 'doDeleteIcGrid';
			store.getGridData(icGrid, 'sel');
    	}


    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.load(baseUrl + '/SRM_030/'+method+'', function() {
			alert(this.getResponseMessage());
			doSearch();
		});

    }

    function doSave() {
        var store = new EVF.Store();
        var method = '';
        if (delType == 'sg') {
            if ((sgGrid.jsonToArray(sgGrid.getSelRowId()).value).length == 0) {
                alert("${msg.M0004}");
                return;
            }

            store.setGrid([sgGrid]);
            method = 'doSaveSgGrid';
            store.getGridData(sgGrid, 'sel');
        }

        if (delType == 'ic') {
            if ((icGrid.jsonToArray(icGrid.getSelRowId()).value).length == 0) {
                alert("${msg.M0004}");
                return;
            }

            store.setGrid([icGrid]);
            method = 'doSaveIcGrid';
            store.getGridData(icGrid, 'sel');
        }

        if(!confirm('${msg.M0021}')) { return; }
        store.load(baseUrl + '/SRM_030/'+method+'', function() {
            alert(this.getResponseMessage());
            doSearch();
        });

    }

    function _getItemClsNm()  {

        var popupUrl = "/eversrm/master/item/BBM_011/view";
        var param = {
            callBackFunction : "_setItemClassNm",
            'detailView': false,
            'multiYN' : false,
            'ModalPopup' : true,
			'searchYN' : true
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
		}else{
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
            if (SelectGrid == "ic") {
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

            } else if (SelectGrid == "sg") {
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", data.ITEM_CLS_PATH_NM);
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS1", data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){
                    sgGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                }else{
                    sgGrid.setCellValue(SelectRowId, "ITEM_CLS2", data.ITEM_CLS2);
                }
                if(data.ITEM_CLS3=="*"){
                    sgGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                }else{
                    sgGrid.setCellValue(SelectRowId, "ITEM_CLS3", data.ITEM_CLS3);
                }
                if(data.ITEM_CLS3=="*"){
                    sgGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
                }else{
                    sgGrid.setCellValue(SelectRowId, "ITEM_CLS4", data.ITEM_CLS4);
                }
            }

        }else{
            if (SelectGrid == "ic") {
                icGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS1", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                icGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
            } else if (SelectGrid == "sg") {
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS_PATH", "");
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS1", "");
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS2", "");
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS3", "");
                sgGrid.setCellValue(SelectRowId, "ITEM_CLS4", "");
            }
        }
    }



    function _getSGClsNm(){
        var popupUrl = "/eversrm/srm/master/sourcing/SRM_010_TREEP/view";
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
        }else{
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
                icGrid.setCellValue(SelectRowId, "SG_CLS_NM1", data.ITEM_CLS1);
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
            } else if (SelectGrid == "sg") {
                sgGrid.setCellValue(SelectRowId, "SG_CLS_PATH", data.ITEM_CLS_PATH_NM);
                sgGrid.setCellValue(SelectRowId, "SG_CLS_NM1", data.ITEM_CLS1);
                if (data.ITEM_CLS2 == "*") {
                    sgGrid.setCellValue(SelectRowId, "SG_CLS_NM2", "");
                } else {
                    sgGrid.setCellValue(SelectRowId, "SG_CLS_NM2", data.ITEM_CLS2);
                    sgGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS2);
                }
                if (data.ITEM_CLS3 == "*") {
                    sgGrid.setCellValue(SelectRowId, "SG_CLS_NM3", "");
                } else {
                    sgGrid.setCellValue(SelectRowId, "SG_CLS_NM3", data.ITEM_CLS3);
                    sgGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS3);
                }
                if (data.ITEM_CLS4 == "*") {
                    sgGrid.setCellValue(SelectRowId, "SG_CLS_NM4", "");
                } else {
                    sgGrid.setCellValue(SelectRowId, "SG_CLS_NM4", data.ITEM_CLS4);
                    sgGrid.setCellValue(SelectRowId, "SG_NUM", data.ITEM_CLS4);
                }
            }

        } else {
            if (SelectGrid == "ic") {
                icGrid.setCellValue(SelectRowId, "SG_CLS_PATH", "");
                icGrid.setCellValue(SelectRowId, "SG_NUM", "");
            } else if (SelectGrid == "sg") {
                sgGrid.setCellValue(SelectRowId, "SG_CLS_PATH", "");
                sgGrid.setCellValue(SelectRowId, "SG_NUM", "");
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

<e:window id="SRM_030" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${longLabelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearchTree">
            <e:row>
				<%--<e:label for="SG_NUM" title="${form_SG_NUM_N}"/>--%>
				<%--<e:field>--%>
				<%--<e:select id="SG_NUM1" onChange="chSg" data='2'  name="SG_NUM1" value="${form.SG_NUM}" options="${refSG_NUM1 }" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="SG_NUM2" onChange="chSg" data='3' name="SG_NUM2" value="" options="" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="SG_NUM3" onChange="chSg" data='4' name="SG_NUM3" value="" options="" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="SG_NUM4" name="SG_NUM4" value="" options="" width="${inputTextWidth}" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" placeHolder="" />--%>
				<%--</e:field>--%>

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
				<%--<e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}"/>--%>
				<%--<e:field>--%>
				<%--<e:select id="ITEM_CLS1" name="ITEM_CLS1" data="2" onChange="getitem_cls" value="${form.ITEM_CLS}" options="${refITEM_CLASS1 }" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="ITEM_CLS2" name="ITEM_CLS2" data="3" onChange="getitem_cls"  value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="ITEM_CLS3" name="ITEM_CLS3" data="4" onChange="getitem_cls"  value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="ITEM_CLS4" name="ITEM_CLS4"  value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />--%>
				<%--</e:field>--%>
			</e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${SRM_030_IC_TAB}</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${SRM_030_SG_TAB}</a></li>
          </ul>

          <div id="ui-tabs-1">
			<div style="height: auto;">
			<e:gridPanel gridType="${_gridType}" id="sgGrid" name="sgGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.sgGrid.gridColData}"/>
				</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
				<e:gridPanel gridType="${_gridType}" id="icGrid" name="icGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.icGrid.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
	</div>

</e:window>
</e:ui>