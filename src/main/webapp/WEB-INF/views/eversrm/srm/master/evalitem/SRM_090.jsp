<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/eversrm/srm/master/evalitem/";
    var gridMain;
    var gridQly;
    var gridQty;
    function init() {
    	gridMain = EVF.C("gridMain");
    	gridQly = EVF.C("gridQly");
    	gridQty = EVF.C("gridQty");



    	gridMain.setProperty('panelVisible', ${panelVisible});
    	gridQly.setProperty('panelVisible', ${panelVisible});
    	gridQty.setProperty('panelVisible', ${panelVisible});

		if('${_gridType}' != "RG") {
			gridQly.acceptZero(true);
			gridQty.acceptZero(true);
		}
    	gridMain.setProperty('multiselect', true);

        // Grid Excel Export
        gridMain.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        // Grid Excel Export
        gridQly.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        // Grid Excel Export
        gridQty.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

    	gridQly.addRowEvent(function () {
	    	var addParam = [
				{ "INSERT_FLAG" : 'I' }
			];
    		gridQly.addRow(addParam);
	    });

    	gridQly.delRowEvent(function() {
            if (gridQly.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            var rowIds = gridQly.getSelRowId();
    		for(var i in rowIds) {
    			if(gridQly.getCellValue(rowIds[i], 'INSERT_FLAG') == "I") {
    				gridQly.delRow();
    			}
        	}
		});

    	gridQty.addRowEvent(function () {
    		var addParam = [
				{ "INSERT_FLAG" : 'I' }
			];
    		gridQty.addRow(addParam);
	    });

    	gridQty.delRowEvent(function() {
            if (gridQty.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            var rowIds = gridQty.getSelRowId();
    		for(var i in rowIds) {
    			if(gridQty.getCellValue(rowIds[i], 'INSERT_FLAG') == "I") {
    				gridQty.delRow();
    			}
        	}
		});

    	gridMain.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
    		if (celname =='EV_ITEM_SUBJECT') {
    			EVF.getComponent('EV_ITEM_KIND_CD_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_KIND_CD')  ,false  );
    			EVF.getComponent('EV_ITEM_METHOD_CD_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_METHOD_CD')    );
    			EVF.getComponent('SCALE_TYPE_CD_R').setValue( gridMain.getCellValue(rowid,'SCALE_TYPE_CD')    );
    			EVF.getComponent('EV_ITEM_CONTENTS_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_CONTENTS')    );
    			EVF.getComponent('EV_ITEM_SUBJECT_R').setValue( gridMain.getCellValue(rowid,'EV_ITEM_SUBJECT')    );
    			EVF.getComponent('EV_ITEM_NUM').setValue( gridMain.getCellValue(rowid,'EV_ITEM_NUM'));
    			EVF.getComponent('QTY_ITEM_CD').setValue( gridMain.getCellValue(rowid,'QTY_ITEM_CD'));
    			getEvItemTypeRValue2(gridMain.getCellValue(rowid,'EV_ITEM_KIND_CD'),  gridMain.getCellValue(rowid,'EV_ITEM_TYPE_CD') );
    			doSearchDetail(gridMain.getCellValue(rowid,'EV_ITEM_NUM'));

    	    	if(gridMain.getCellValue(rowid,'EV_ITEM_METHOD_CD') == '') {
    	    		$('#tab1').focus();
    				var e = jQuery.Event( 'keydown', { keyCode: 13 } );
    				$("#tab1").trigger(e);
    		          window.scrollbars = true;
    	    	}
    	    	else if (gridMain.getCellValue(rowid,'EV_ITEM_METHOD_CD') == 'QUA') {
    	    		$('#tab2').hide();
    				$('#tab1').show();
    	    		$('#tab1').focus();
    				var e = jQuery.Event( 'keydown', { keyCode: 13 } );
    				$("#tab1").trigger(e);
	    	          window.scrollbars = true;
    			} else {
    				$('#tab1').hide();
    				$('#tab2').show();
    				$('#tab2').focus();
    				var e = jQuery.Event( 'keydown', { keyCode: 13 } );
    				$("#tab2").trigger(e);
    	          window.scrollbars = true;
    			}
    		}
        });
    }

    function doNew() {
		EVF.getComponent('EV_ITEM_KIND_CD_R').setValue( ''  ,false  );
		EVF.getComponent('EV_ITEM_METHOD_CD_R').setValue( ''    );
		EVF.getComponent('SCALE_TYPE_CD_R').setValue( ''    );
		EVF.getComponent('EV_ITEM_CONTENTS_R').setValue( ''    );
		EVF.getComponent('EV_ITEM_SUBJECT_R').setValue( ''    );
		EVF.getComponent('EV_ITEM_NUM').setValue( ''   );
		EVF.getComponent('EV_ITEM_TYPE_CD_R').setValue( ''  );

		gridQly.delAllRow();
		gridQty.delAllRow();
    }

    function chgMethod() {
    	var method = EVF.getComponent('EV_ITEM_METHOD_CD_R').getValue();
    	if(method == '') {
    		$('#tab1').show();
    		$('#tab2').show();
    		$('#tab1').focus();
			var e = jQuery.Event( 'keydown', { keyCode: 13 } );
			$("#tab1").trigger(e);
	          window.scrollbars = true;
    	}
    	else if (method == 'QUA') {
			$('#tab2').hide();
			$('#tab1').show();
			$('#tab1').focus();
			var e = jQuery.Event( 'keydown', { keyCode: 13 } );
			$("#tab1").trigger(e);
	          window.scrollbars = true;
		} else {
			$('#tab1').hide();
			$('#tab2').show();
			$('#tab2').focus();
			var e = jQuery.Event( 'keydown', { keyCode: 13 } );
			$("#tab2").trigger(e);
          window.scrollbars = true;
		}


    }

    function getEvItemTypeRValue2(type,value) {
        var store = new EVF.Store;
        store.setParameter('EV_ITEM_KIND_CD',type);
        store.load(baseUrl + '/SRM_090/changeComboItemKindValue', function() {
          EVF.getComponent('EV_ITEM_TYPE_CD_R').setOptions(this.getParameter("itemTypeCode"));
          EVF.getComponent('EV_ITEM_TYPE_CD_R').setValue( value  );
        });
    }

    function doSearchDetail(value) {
        var store = new EVF.Store();
        store.setParameter('EV_ITEM_NUM',value);
        store.setGrid([gridQly,gridQty]);
        store.load(baseUrl + "SRM_090/doSearchDetail", function() {
        });
    }
    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridMain]);
        store.load(baseUrl + "SRM_090/doSearch", function() {
            if (gridMain.getRowCount() == 0) {
                alert("${msg.M0002 }");

            }
            doNew();
        });
    }
    function getEvItemType() {
        var store = new EVF.Store;
        store.load(baseUrl + '/SRM_090/changeComboItemKindL', function() {
          EVF.getComponent('EV_ITEM_TYPE_CD').setOptions(this.getParameter("itemTypeCode"));
        });
    }

    function getEvItemTypeR() {
        var store = new EVF.Store;
        store.load(baseUrl + '/SRM_090/changeComboItemKindR', function() {
          EVF.getComponent('EV_ITEM_TYPE_CD_R').setOptions(this.getParameter("itemTypeCode"));
        });
    }

    function getContentTab(uu) {
    	return;
        if (uu == '1') {
        }
        if (uu == '2') {
        }
      }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                  activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                  }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        $(window).trigger('resize');
        //getContentTab('1');
      });


    function doDelete() {

    	/*if (EVF.getComponent('EV_ITEM_NUM').getValue()=='') {
    		return;
    	}*/

		if (!gridMain.isExistsSelRow()) { return alert('${msg.M0004}'); }

    	var store = new EVF.Store();
		if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.setGrid([gridMain]);
		store.getGridData(gridMain, 'sel');
		store.load(baseUrl + '/SRM_090/doDelete', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function doSave() {

    	var store = new EVF.Store();
		if (!store.validate())
			return;

		gridQly.checkAll(true);
		gridQty.checkAll(true);

    	var method = EVF.getComponent('EV_ITEM_METHOD_CD_R').getValue();
    	var scaleType = EVF.C('SCALE_TYPE_CD_R').getValue();

		if (method == 'QUA') {
			if(!gridQly.validate().flag) { return alert(gridQly.validate().msg); }
		} else {
			if(!gridQty.validate().flag) { return alert(gridQty.validate().msg); }
		}

		store.setGrid([ gridQly,gridQty ]);
		store.getGridData(gridQly, 'sel');
		store.getGridData(gridQty, 'sel');
		if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.load(baseUrl + '/SRM_090/doSave', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function doDeleteR() {

    	var store = new EVF.Store();
		store.setGrid([ gridQly, gridQty ]);
		store.getGridData(gridQly, 'sel');
		store.getGridData(gridQty, 'sel');
		if (!confirm("${msg.M0013}")) {
			return;
		}
		store.load(baseUrl + '/SRM_090/doDeleteR', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function doSearchQtyItem() {
    	var method = EVF.getComponent('EV_ITEM_METHOD_CD_R').getValue();

		if (method == 'QUA') {
			alert('${SRM_090_MSG_001}'); <%-- 정량평가인 경우에만 처리 가능합니다. --%>
			return;
		}

        var param = {
	          callBackFunction : 'doSetQtyItem'
	        , title : '평가항목'
	        , codeType : 'M207'
        };

        everPopup.openCommonPopup(param, 'SP0029');
    }

    function doSetQtyItem(data) {
    	EVF.C("EV_ITEM_SUBJECT_R").setValue(data.CODE_DESC);
    	EVF.C("QTY_ITEM_CD").setValue(data.CODE);
    }
</script>

<e:window id="SRM_090" onReady="init" initData="${initData}" title="${fullScreenName}">

    <e:panel width="54%" height="100%">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
				<e:label for="EV_ITEM_KIND_CD" title="${form_EV_ITEM_KIND_CD_N}"/>
				<e:field>
				<e:select id="EV_ITEM_KIND_CD" name="EV_ITEM_KIND_CD" value="${form.EV_ITEM_KIND_CD}" onChange="getEvItemType"  options="${itemKindCode }" width="100%" disabled="${form_EV_ITEM_KIND_CD_D}" readOnly="${form_EV_ITEM_KIND_CD_RO}" required="${form_EV_ITEM_KIND_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="EV_ITEM_TYPE_CD" title="${form_EV_ITEM_TYPE_CD_N}"/>
				<e:field>
				<e:select id="EV_ITEM_TYPE_CD" name="EV_ITEM_TYPE_CD" value="${form.EV_ITEM_TYPE_CD}" options="" width="100%" disabled="${form_EV_ITEM_TYPE_CD_D}" readOnly="${form_EV_ITEM_TYPE_CD_RO}" required="${form_EV_ITEM_TYPE_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EV_ITEM_METHOD_CD" title="${form_EV_ITEM_METHOD_CD_N}"/>
				<e:field>
				<e:select id="EV_ITEM_METHOD_CD" name="EV_ITEM_METHOD_CD" value="${form.EV_ITEM_METHOD_CD}" options="${itemMethodCode }" width="100%" disabled="${form_EV_ITEM_METHOD_CD_D}" readOnly="${form_EV_ITEM_METHOD_CD_RO}" required="${form_EV_ITEM_METHOD_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="EV_ITEM_SUBJECT" title="${form_EV_ITEM_SUBJECT_N}" />
				<e:field>
				<e:inputText id="EV_ITEM_SUBJECT" style="ime-mode:auto" name="EV_ITEM_SUBJECT" value="${form.EV_ITEM_SUBJECT}" width="100%" maxLength="${form_EV_ITEM_SUBJECT_M}" disabled="${form_EV_ITEM_SUBJECT_D}" readOnly="${form_EV_ITEM_SUBJECT_RO}" required="${form_EV_ITEM_SUBJECT_R}"/>
				</e:field>

            </e:row>
            <e:row>

				<e:label for="EV_ITEM_CONTENTS" title="${form_EV_ITEM_CONTENTS_N}" />
				<e:field colSpan="3">
				<e:inputText id="EV_ITEM_CONTENTS" style="${imeMode}" name="EV_ITEM_CONTENTS" value="${form.EV_ITEM_CONTENTS}" width="100%" maxLength="${form_EV_ITEM_CONTENTS_M}" disabled="${form_EV_ITEM_CONTENTS_D}" readOnly="${form_EV_ITEM_CONTENTS_RO}" required="${form_EV_ITEM_CONTENTS_R}"/>
				</e:field>
            </e:row>

        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doNew" name="doNew" label="${doNew_N}" onClick="doNew" disabled="${doNew_D}" visible="${doNew_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>
    </e:panel>
    <e:panel width="1%">&nbsp;</e:panel>
    <e:panel width="45%" height="100%">
        <e:searchPanel useTitleBar="false" id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
				<e:label for="EV_ITEM_KIND_CD_R" title="${form_EV_ITEM_KIND_CD_R_N}"/>
				<e:field>
				<e:select id="EV_ITEM_KIND_CD_R" name="EV_ITEM_KIND_CD_R"  onChange="getEvItemTypeR" value="${form.EV_ITEM_KIND_CD_R}" options="${itemKindCode }" width="100%" disabled="${form_EV_ITEM_KIND_CD_R_D}" readOnly="${form_EV_ITEM_KIND_CD_R_RO}" required="${form_EV_ITEM_KIND_CD_R_R}" placeHolder="" />
				</e:field>
				<e:label for="EV_ITEM_TYPE_CD_R" title="${form_EV_ITEM_TYPE_CD_R_N}"/>
				<e:field>
				<e:select id="EV_ITEM_TYPE_CD_R" name="EV_ITEM_TYPE_CD_R" value="${form.EV_ITEM_TYPE_CD_R}" options="" width="100%" disabled="${form_EV_ITEM_TYPE_CD_R_D}" readOnly="${form_EV_ITEM_TYPE_CD_R_RO}" required="${form_EV_ITEM_TYPE_CD_R_R}" placeHolder="" />
				<e:inputHidden id="EV_ITEM_NUM" name="EV_ITEM_NUM"/>
				<e:inputHidden id="QTY_ITEM_CD" name="QTY_ITEM_CD"/>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EV_ITEM_METHOD_CD_R" title="${form_EV_ITEM_METHOD_CD_R_N}"/>
				<e:field>
				<e:select id="EV_ITEM_METHOD_CD_R" name="EV_ITEM_METHOD_CD_R" onChange="chgMethod" value="${form.EV_ITEM_METHOD_CD_R}" options="${itemMethodCode }" width="100%" disabled="${form_EV_ITEM_METHOD_CD_R_D}" readOnly="${form_EV_ITEM_METHOD_CD_R_RO}" required="${form_EV_ITEM_METHOD_CD_R_R}" placeHolder="" />
				</e:field>
				<e:label for="SCALE_TYPE_CD_R" title="${form_SCALE_TYPE_CD_R_N}"/>
				<e:field>
				<e:select id="SCALE_TYPE_CD_R" name="SCALE_TYPE_CD_R" value="${form.SCALE_TYPE_CD_R}" options="${scaleTypeCode }" width="100%" disabled="${form_SCALE_TYPE_CD_R_D}" readOnly="${form_SCALE_TYPE_CD_R_RO}" required="${form_SCALE_TYPE_CD_R_R}" placeHolder="" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EV_ITEM_SUBJECT_R" title="${form_EV_ITEM_SUBJECT_R_N}"/>
				<e:field>
				<e:search id="EV_ITEM_SUBJECT_R" style="ime-mode:auto" name="EV_ITEM_SUBJECT_R" value="${form.EV_ITEM_SUBJECT_R}" width="100%" maxLength="${form_EV_ITEM_SUBJECT_R_M}" onIconClick="${form_EV_ITEM_SUBJECT_R_RO ? 'everCommon.blank' : 'doSearchQtyItem'}" disabled="${form_EV_ITEM_SUBJECT_R_D}" readOnly="${form_EV_ITEM_SUBJECT_R_RO}" required="${form_EV_ITEM_SUBJECT_R_R}" />
				</e:field>
				<e:label for="EV_ITEM_CONTENTS_R" title="${form_EV_ITEM_CONTENTS_R_N}"/>
				<e:field>
				<e:inputText id="EV_ITEM_CONTENTS_R" style="${imeMode}" name="EV_ITEM_CONTENTS_R" value="${form.EV_ITEM_CONTENTS_R}" width="100%" maxLength="${form_EV_ITEM_CONTENTS_R_M}" disabled="${form_EV_ITEM_CONTENTS_R_D}" readOnly="${form_EV_ITEM_CONTENTS_R_RO}" required="${form_EV_ITEM_CONTENTS_R_R}"/>
				</e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDeleteR" name="doDeleteR" label="${doDeleteR_N}" onClick="doDeleteR" disabled="${doDeleteR_D}" visible="${doDeleteR_V}"/>
        </e:buttonBar>
    </e:panel>
		<e:panel id="leftPanel" height="fit" width="54%">
			<e:gridPanel gridType="${_gridType}" id="gridMain" name="gridMain" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridMain.gridColData}"/>
		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
	<e:panel id="righttPanel1" height="fit" width="45%">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${SRM_090_QLY }</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${SRM_090_QTY }</a></li>
          </ul>

          <div id="ui-tabs-1">
			<div style="height: auto;">
				<e:gridPanel gridType="${_gridType}" id="gridQly" name="gridQly" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridQly.gridColData}"/>
			</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
				<e:gridPanel gridType="${_gridType}" id="gridQty" name="gridQty" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridQty.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
	</e:panel>
	</div>

</e:window>
</e:ui>