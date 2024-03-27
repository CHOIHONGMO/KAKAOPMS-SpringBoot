<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/srm/master/evalTemplate/";
    var leftGrid;
    var rightGrid;

    function init() {

    	leftGrid = EVF.C("leftGrid");
    	rightGrid = EVF.C("rightGrid");
    	leftGrid.setProperty('multiselect', true);
    	//leftGrid.setProperty('shrinkToFit', true);
    	//rightGrid.setProperty('shrinkToFit', true);

    	leftGrid.setProperty('panelVisible', ${panelVisible});
    	rightGrid.setProperty('panelVisible', ${panelVisible});

        // Grid Excel Export
        leftGrid.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
            imgWidth      : 0.12, 		// 이미지 너비
            imgHeight     : 0.26,		    // 이미지 높이
            colWidth      : 20,        	// 컬럼의 넓이
            rowSize       : 500,       	// 엑셀 행에 높이 사이즈
            attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
          }
        });

        // Grid Excel Export
        rightGrid.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
            imgWidth      : 0.12, 		// 이미지 너비
            imgHeight     : 0.26,		    // 이미지 높이
            colWidth      : 20,        	// 컬럼의 넓이
            rowSize       : 500,       	// 엑셀 행에 높이 사이즈
            attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
          }
        });

    	leftGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
    		if (celname =='EV_TPL_SUBJECT') {
    			EVF.getComponent('EVAL_KIND02').setValue( leftGrid.getCellValue(rowid,'EV_TPL_TYPE_CD')    );
    			EVF.getComponent('TEMPLATE_NM2').setValue( leftGrid.getCellValue(rowid,'EV_TPL_SUBJECT')    );
    			EVF.getComponent('EV_TPL_NUM').setValue( leftGrid.getCellValue(rowid,'EV_TPL_NUM')    );
    			doSearchDetail(leftGrid.getCellValue(rowid,'EV_TPL_NUM'));
    		}
    	});
    	rightGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
    		if (celname =='EV_ITEM_SUBJECT') {

    	    	var method = rightGrid.getCellValue(rowid,"EV_ITEM_METHOD_CD");
		    if (method == 'QUA') {
    			var param = {
    					EV_ITEM_NUM : rightGrid.getCellValue(rowid,"EV_ITEM_NUM")
		              	};
				everPopup.openCommonPopup(param, 'SP0030');
    		} else {
    			var param = {
    					EV_ITEM_NUM : rightGrid.getCellValue(rowid,"EV_ITEM_NUM")
		              	};
				everPopup.openCommonPopup(param, 'SP0032');

	    		}
    		}
    	});

    	rightGrid.addRowEvent(function () {
			if ( EVF.getComponent('EVAL_KIND02').getValue() == '') {
				return;
			}
	        var param = {
	        		evalKind : EVF.getComponent('EVAL_KIND02').getValue()
	        		,callBackFunction : 'addEvalItem'
	        	    ,detailView : false
			};
		    everPopup.openPopupByScreenId('SRM_101', 1200, 800, param);
    	});

    	rightGrid.delRowEvent(function() {
			var rowData = rightGrid.getSelRowId();
			//var LINE_THROUGH = 'line-through';
			for ( var nRow in rowData ) {
				rightGrid.setCellValue(rowData[nRow],'STATUS','D');
				//rightGrid.setRowStyle(nRow, "text-decoration", LINE_THROUGH);
				rightGrid.setRowBgColor(rowData[nRow], '#8C8C8C');
			}
	    });
    }

    function addEvalItem(data) {

        for (k = 0; k < data.length; k++) {
            var EV_ITEM_NUM       = data[k].EV_ITEM_NUM;
            var addOk = "ok";
    	    var rightRowCount  = rightGrid.getRowCount();

            for (var j = rightRowCount - 1; j > -1; j--) {
                if (rightGrid.getCellValue(j, "EV_ITEM_NUM") == EV_ITEM_NUM) {
                    addOk = "fail";
                   break;
                }
            }

            if (addOk == "ok") {
	   	    	addParam = [
	       	            	{
	       	        	    	 "EV_ITEM_KIND_CD" : data[k].EV_ITEM_KIND_CD
	       	        	    	,"EV_ITEM_KIND_CD_NM" : data[k].EV_ITEM_KIND_CD_NM
	       	        	    	,"EV_ITEM_METHOD_CD" : data[k].EV_ITEM_METHOD_CD
	       	        	    	,"EV_ITEM_NUM" : data[k].EV_ITEM_NUM
	       	        	    	,"GATE_CD" : data[k].GATE_CD
	       	        	    	,"SCALE_TYPE_CD" : data[k].SCALE_TYPE_CD
	       	        	    	,"EV_ITEM_SUBJECT" : data[k].EV_ITEM_SUBJECT
	       	        	    	,"EV_ITEM_TYPE_CD" : data[k].EV_ITEM_TYPE_CD
	       	        	    	,"EV_ITEM_METHOD_CD_NM" : data[k].EV_ITEM_METHOD_CD_NM
	       	        	    	,"SCALE_TYPE_CD_NM" : data[k].SCALE_TYPE_CD_NM
	       	            	}
	       	            ];
	   	    	rightGrid.addRow(addParam);
            }

        }
    }


    function doNew() {
		EVF.getComponent('EVAL_KIND02').setValue('');
		EVF.getComponent('TEMPLATE_NM2').setValue('');
		EVF.getComponent('EV_TPL_NUM').setValue('');
		rightGrid.delAllRow();
    }

    function doSearchDetail(value) {
        var store = new EVF.Store();
        store.setParameter('EV_TPL_NUM',value);
        store.setGrid([rightGrid]);
        store.load(baseUrl + "SRM_100/doSearchRightGrid", function() {
        });
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([leftGrid]);
        store.load(baseUrl + "SRM_100/doSearchLeftGrid", function() {
            if (leftGrid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
            doNew();
        });
    }
    function doSave() {

    	var store = new EVF.Store();
		if (!store.validate())
			return;
		rightGrid.checkAll(true);

		if(!rightGrid.validate().flag) { return alert(rightGrid.validate().msg); }

	    var rightRowCount  = rightGrid.getRowCount();
	    var sum = 0;
        for (var j = rightRowCount - 1; j > -1; j--) {
            if (rightGrid.getCellValue(j, "STATUS") != 'D') {
            	sum += Number(rightGrid.getCellValue(j, "WEIGHT"));

            }
        }

        <%-- 2015.11.04 daguri 가중치 합 100 이 되지 않아도 된다.
        if (sum!=100) {
        	alert('${SRM_100_MSG_02}');
        	return;
        }
        --%>

		store.setGrid([ rightGrid ]);
		store.getGridData(rightGrid, 'sel');
		if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.load(baseUrl + '/SRM_100/doSave', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function doDelete() {
    	/*if (EVF.getComponent('EV_TPL_NUM').getValue()=='') {
    		return;
    	}*/
		if (!leftGrid.isExistsSelRow()) { return alert('${msg.M0004}'); }

    	var store = new EVF.Store();
		store.setGrid([leftGrid]);
		store.getGridData(leftGrid, 'sel');
		if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.load(baseUrl + '/SRM_100/doDelete', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

    function doCopy() {
    	if (EVF.getComponent('EV_TPL_NUM').getValue()=='') {
    		return;
    	}
    	var store = new EVF.Store();
		if (!confirm("${SRM_100_MSG_04}")) { //처리하시겠습니까?
			return;
		}
		rightGrid.checkAll(true);
		store.setGrid([ rightGrid ]);
		store.getGridData(rightGrid, 'sel');


		store.load(baseUrl + '/SRM_100/doCopy', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }
</script>

<e:window id="SRM_100" onReady="init" initData="${initData}" title="${fullScreenName}">

    <e:panel width="44%" height="100%">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
				<e:label for="EVAL_KIND01" title="${form_EVAL_KIND01_N}"/>
				<e:field>
				<e:select id="EVAL_KIND01" name="EVAL_KIND01" value="${form.EVAL_KIND01}" options="${evalKind }" width="${inputTextWidth}" disabled="${form_EVAL_KIND01_D}" readOnly="${form_EVAL_KIND01_RO}" required="${form_EVAL_KIND01_R}" placeHolder="" />
				</e:field>
				<e:label for="TEMPLATE_NM1" title="${form_TEMPLATE_NM1_N}" />
				<e:field>
				<e:inputText id="TEMPLATE_NM1" style="${imeMode}" name="TEMPLATE_NM1" value="${form.TEMPLATE_NM1}" width="100%" maxLength="${form_TEMPLATE_NM1_M}" disabled="${form_TEMPLATE_NM1_D}" readOnly="${form_TEMPLATE_NM1_RO}" required="${form_TEMPLATE_NM1_R}"/>
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
    <e:panel width="55%" height="100%">
        <e:searchPanel useTitleBar="false" id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
				<e:label for="EVAL_KIND02" title="${form2_EVAL_KIND02_N}"/>
				<e:field>
				<e:select id="EVAL_KIND02" name="EVAL_KIND02" value="${form.EVAL_KIND02}" options="${evalKind }" width="100%" disabled="${form2_EVAL_KIND02_D}" readOnly="${form2_EVAL_KIND02_RO}" required="${form2_EVAL_KIND02_R}" placeHolder="" />
				<e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM"/>
				</e:field>
				<e:label for="TEMPLATE_NM2" title="${form2_TEMPLATE_NM2_N}" />
				<e:field>
				<e:inputText id="TEMPLATE_NM2" style="${imeMode}" name="TEMPLATE_NM2" value="${form.TEMPLATE_NM2}" width="100%" maxLength="${form2_TEMPLATE_NM2_M}" disabled="${form2_TEMPLATE_NM2_D}" readOnly="${form2_TEMPLATE_NM2_RO}" required="${form2_TEMPLATE_NM2_R}"/>
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doCopy" name="doCopy" label="${doCopy_N}" onClick="doCopy" disabled="${doCopy_D}" visible="${doCopy_V}"/>
        </e:buttonBar>
    </e:panel>
		<e:panel id="leftPanel" height="fit" width="44%">
			<e:gridPanel gridType="${_gridType}" id="leftGrid" name="leftGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.leftGrid.gridColData}"/>
		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>

	<e:panel id="righttPanel1" height="fit" width="55%">
		<e:gridPanel gridType="${_gridType}" id="rightGrid" name="rightGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.rightGrid.gridColData}"/>
	</e:panel>

</e:window>
</e:ui>