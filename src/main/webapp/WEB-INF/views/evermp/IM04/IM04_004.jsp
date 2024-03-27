<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

	var baseUrl = "/evermp/IM04/IM0402/";
    var gridV;
    var gridSG;
    var SelectRowId;
    var SelectGrid;

    function init() {

    	gridV = EVF.C("gridV");
    	gridSG = EVF.C("gridSG");
    	gridV.setProperty('shrinkToFit', true);
    	gridSG.setProperty('shrinkToFit', true);
    	gridV.setProperty('panelVisible', ${panelVisible});
    	gridSG.setProperty('panelVisible', ${panelVisible});

        gridV.excelExportEvent({
            allCol : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        gridSG.excelExportEvent({
            allCol : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        gridV.addRowEvent(function() {
            gridV.addRow();
        });

        gridSG.addRowEvent(function() {
            gridSG.addRow();
        });

        gridV.delRowEvent(function() {
            if(!gridV.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = gridV.jsonToArray(gridV.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(gridV.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${IM04_004_0004}');
                }
            }
            gridV.delRow();
        });

        gridSG.delRowEvent(function() {
            if(!gridSG.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = gridSG.jsonToArray(gridSG.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(gridSG.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                    return alert('${IM04_004_0004}');
                }
            }
            gridSG.delRow();
        });


    	gridSG.cellClickEvent(function(rowid, colId, value) {
	        switch (colId) {
            case 'VENDOR_CD':
				var param = {
					callBackFunction : "selectVendorCd_Grid"
				};
                SelectGrid = "SG";
				SelectRowId = rowid;
				everPopup.openCommonPopup(param, 'SP0063');
            	break;
			case 'SG_CLS_PATH':
                var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
                var param = {
                    callBackFunction: '_setSg_Grid',
                    'multiYN' : false,
                    'ModalPopup' : true,
                    'searchYN' : true
                };
                SelectGrid = "SG";
                SelectRowId = rowid;
                everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
		    break;
	        }
		});

    	gridV.cellClickEvent(function(rowid, colId, value) {
	        switch (colId) {
            case 'VENDOR_CD':
				var param = {
					callBackFunction : "selectVendorCd_Grid"
				};
				SelectGrid = "V";
				SelectRowId = rowid;
				everPopup.openCommonPopup(param, 'SP0063');
				break;
			case 'SG_CLS_PATH':
				var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
				var param = {
					callBackFunction: '_setSg_Grid',
					'multiYN' : false,
					'ModalPopup' : true,
					'searchYN' : true
				};
				SelectGrid = "V";
				SelectRowId = rowid;
				everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
			break;
	        }
		});
    }

    function getContentTab(uu) {
        if (uu == '1') {
        	delType = 'sg'
        }
        if (uu == '2') {
        	delType = 'eg'
        }
    }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                  activate: function(event, ui) {

                    $(window).trigger('resize');
                  }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        //getContentTab('1');
      });

    function chSg() {
        var store = new EVF.Store;
        var sg_type = this.getData();

        if (sg_type=='2') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS01').getValue());
            clearY('3');
            clearY('4');
        }
        if (sg_type=='3') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS02').getValue());
            clearY('4');
        }
        if (sg_type=='4') {
            store.setParameter('PARENT_SG_NUM',EVF.getComponent('CLS03').getValue());
        }
        store.load('/eversrm/srm/master/sgItemClass' + '/SRM_030/chSg', function() {
        	EVF.getComponent('CLS0'+sg_type).setOptions(this.getParameter("sgData"));
        });
    }

    function clearY( cls_typef ) {
		EVF.C('CLS0'+ cls_typef ).setOptions( JSON.parse('[]')    );
	}

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridV,gridSG]);
        store.load(baseUrl + "IM04_004/doSearch", function() {
        });
    }

    var delType ='sg';

    function doDelete() {
    	var store = new EVF.Store();
		var method = '';
    	if (delType == 'sg') {
			if ((gridSG.jsonToArray(gridSG.getSelRowId()).value).length == 0) {
				return alert("${msg.M0004}");
	        }

            var selRowId = gridSG.jsonToArray(gridSG.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(gridSG.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                    return alert('${IM04_004_0005}');
                }
            }
			store.setGrid([gridSG]);
			method = 'doDeleteGridSG';
			store.getGridData(gridSG, 'sel');
    	}

    	if (delType == 'eg') {
			if ((gridV.jsonToArray(gridV.getSelRowId()).value).length == 0) {
				return alert("${msg.M0004}");
	        }

            var selRowId = gridV.jsonToArray(gridV.getSelRowId()).value;
            for (var i = 0; i < selRowId.length; i++) {
                if(gridV.getCellValue(selRowId[i],'INSERT_FLAG') !="Y"){
                    return alert('${IM04_004_0005}');
                }
            }
			store.setGrid([gridV]);
			method = 'doDeleteGridV';
			store.getGridData(gridV, 'sel');
    	}

    	if (!confirm("${msg.M8888}")) { // 처리하시겠습니까?
			return;
		}
		store.load(baseUrl + 'IM04_004/'+method+'', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function doSave() {
        var store = new EVF.Store();
        var method = '';
        if (delType == 'sg') {
            if ((gridSG.jsonToArray(gridSG.getSelRowId()).value).length == 0) {
            	return alert("${msg.M0004}");
            }
            store.setGrid([gridSG]);
            method = 'doSaveGridSG';
            store.getGridData(gridSG, 'sel');
        }

        if (delType == 'eg') {
            if ((gridV.jsonToArray(gridV.getSelRowId()).value).length == 0) {
            	return alert("${msg.M0004}");
            }
            store.setGrid([gridV]);
            method = 'doSaveGridV';
            store.getGridData(gridV, 'sel');
        }

        if(!confirm('${msg.M0021}')) { return; }
        store.load(baseUrl + 'IM04_004/'+method+'', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0063');
    }

    function selectVendorCd(dataJsonArray) {
		EVF.getComponent("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
		EVF.getComponent("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
    }

    function selectVendorCd_Grid(dataJsonArray) {

        if(SelectGrid=="V") {
            gridV.setCellValue(SelectRowId, "VENDOR_CD" ,dataJsonArray.VENDOR_CD );
            gridV.setCellValue(SelectRowId, "VENDOR_NM" ,dataJsonArray.VENDOR_NM );
            gridV.setCellValue(SelectRowId, "MAJOR_ITEM_TEXT" ,dataJsonArray.MAJOR_ITEM_TEXT );
		} else if(SelectGrid=="SG") {
            gridSG.setCellValue(SelectRowId, "VENDOR_CD" ,dataJsonArray.VENDOR_CD );
            gridSG.setCellValue(SelectRowId, "VENDOR_NM" ,dataJsonArray.VENDOR_NM );
            gridSG.setCellValue(SelectRowId, "MAJOR_ITEM_TEXT" ,dataJsonArray.MAJOR_ITEM_TEXT );
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
            EVF.C("CLS01").setValue(data.ITEM_CLS1);
            if(data.ITEM_CLS2=="*"){EVF.C("CLS02").setValue("");}else{EVF.C("CLS02").setValue(data.ITEM_CLS2);}
            if(data.ITEM_CLS3=="*"){EVF.C("CLS03").setValue("");}else{EVF.C("CLS03").setValue(data.ITEM_CLS3);}
            if(data.ITEM_CLS4=="*"){EVF.C("CLS04").setValue("");}else{EVF.C("CLS04").setValue(data.ITEM_CLS4);}
            EVF.C("SG_NUM").setValue(data.ITEM_CLS_PATH_NM);
        } else {
            EVF.C("CLS01").setValue("");
            EVF.C("CLS02").setValue("");
            EVF.C("CLS03").setValue("");
            EVF.C("CLS04").setValue("");
            EVF.C("SG_NUM").setValue("");
        }
    }

    function _setSg_Grid(data) {
        if(data!=null){
            data = JSON.parse(data);

            if(SelectGrid=="V"){
                gridV.setCellValue(SelectRowId, "SG_CLS_PATH" ,data.ITEM_CLS_PATH_NM );
                gridV.setCellValue(SelectRowId, "CLS01" ,data.ITEM_CLS1 );
                if(data.ITEM_CLS2=="*"){
                    gridV.setCellValue(SelectRowId, "CLS02" ,"");
                }else{
                    gridV.setCellValue(SelectRowId, "CLS02" ,data.ITEM_CLS2);
                    gridV.setCellValue(SelectRowId, "SG_NUM" ,data.ITEM_CLS2);
                }
                if(data.ITEM_CLS3=="*"){
                    gridV.setCellValue(SelectRowId, "CLS03" ,"");
                }else{
                    gridV.setCellValue(SelectRowId, "CLS03" ,data.ITEM_CLS3);
                    gridV.setCellValue(SelectRowId, "SG_NUM" ,data.ITEM_CLS3);
                }
                if(data.ITEM_CLS4=="*"){
                    gridV.setCellValue(SelectRowId, "CLS04" ,"");
                }else{
                    gridV.setCellValue(SelectRowId, "CLS04" ,data.ITEM_CLS4);
                    gridV.setCellValue(SelectRowId, "SG_NUM" ,data.ITEM_CLS4);
                }
            }else if(SelectGrid=="SG"){
                gridSG.setCellValue(SelectRowId, "SG_CLS_PATH" ,data.ITEM_CLS_PATH_NM );
                gridSG.setCellValue(SelectRowId, "CLS01" ,data.ITEM_CLS1 );
                if(data.ITEM_CLS2=="*"){
                    gridSG.setCellValue(SelectRowId, "CLS02" ,"");
                }else{
                    gridSG.setCellValue(SelectRowId, "CLS02" ,data.ITEM_CLS2);
                    gridSG.setCellValue(SelectRowId, "SG_NUM" ,data.ITEM_CLS2);
                }
                if(data.ITEM_CLS3=="*"){
                    gridSG.setCellValue(SelectRowId, "CLS03" ,"");
                }else{
                    gridSG.setCellValue(SelectRowId, "CLS03" ,data.ITEM_CLS3);
                    gridSG.setCellValue(SelectRowId, "SG_NUM" ,data.ITEM_CLS3);
                }
                if(data.ITEM_CLS4=="*"){
                    gridSG.setCellValue(SelectRowId, "CLS04" ,"");
                }else{
                    gridSG.setCellValue(SelectRowId, "CLS04" ,data.ITEM_CLS4);
                    gridSG.setCellValue(SelectRowId, "SG_NUM" ,data.ITEM_CLS4);
                }
            }
        } else {
            if(SelectGrid=="V"){
                gridV.setCellValue(SelectRowId, "SG_CLS_PATH" ,"");
                gridV.setCellValue(SelectRowId, "SG_NUM" ,"");
            }else if(SelectGrid=="SG"){
                gridSG.setCellValue(SelectRowId, "SG_CLS_PATH" ,"");
                gridSG.setCellValue(SelectRowId, "SG_NUM" ,"");
			}
        }
    }

    function cleanSGClass() {
        EVF.C("CLS01").setValue('');
        EVF.C("CLS02").setValue('');
        EVF.C("CLS03").setValue('');
        EVF.C("CLS04").setValue('');
        EVF.C("SG_NUM").setValue('');
    }

</script>

<e:window id="IM04_004" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${longLabelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
				<e:label for="SG_NUM" title="${form_SG_NUM_N}"/>
				<e:field>
					<e:search id="SG_NUM" name="SG_NUM" value="" width="100%" maxLength="${form_SG_NUM_M}" onIconClick="_getSGClsNm" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}"  onClear="cleanSGClass" onChange="cleanSGClass"/>
				</e:field>
				<e:inputHidden id="CLS01" name="CLS01" value=""/>
				<e:inputHidden id="CLS02" name="CLS02" />
				<e:inputHidden id="CLS03" name="CLS03" />
				<e:inputHidden id="CLS04" name="CLS04" />

				<%--<e:label for="CLS01" title="${form_CLS01_N}"/>--%>
				<%--<e:field colSpan="3">--%>
				<%--<e:select id="CLS01" onChange="chSg" data='2' name="CLS01" value="${form.CLS01}" options="${refClass1 }" width="${inputTextWidth}" disabled="${form_CLS01_D}" readOnly="${form_CLS01_RO}" required="${form_CLS01_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="CLS02" onChange="chSg" data='3' name="CLS02" value="${form.CLS02}" options="" width="${inputTextWidth}" disabled="${form_CLS02_D}" readOnly="${form_CLS02_RO}" required="${form_CLS02_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="CLS03" onChange="chSg" data='4' name="CLS03" value="${form.CLS03}" options="" width="${inputTextWidth}" disabled="${form_CLS03_D}" readOnly="${form_CLS03_RO}" required="${form_CLS03_R}" placeHolder="" />--%>
				<%--<e:text>&nbsp;</e:text>--%>
				<%--<e:select id="CLS04" name="CLS04" value="${form.CLS04}" options="" width="${inputTextWidth}" disabled="${form_CLS04_D}" readOnly="${form_CLS04_RO}" required="${form_CLS04_R}" placeHolder="" />--%>
				<%--</e:field>--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
				</e:field>
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
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${IM04_004_SG}</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${IM04_004_VENDOR}</a></li>
          </ul>

          <div id="ui-tabs-1">
			<div style="height: auto;">
			<e:gridPanel gridType="${_gridType}" id="gridSG" name="gridSG" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridSG.gridColData}"/>
				</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
				<e:gridPanel gridType="${_gridType}" id="gridV" name="gridV" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridV.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
	</div>

</e:window>
</e:ui>