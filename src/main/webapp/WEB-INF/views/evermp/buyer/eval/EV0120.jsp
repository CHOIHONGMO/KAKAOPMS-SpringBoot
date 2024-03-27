<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui>
<script>

	var baseUrl = "/evermp/buyer/eval/";
    var leftGrid;
    var rightGrid;

    function init() {

    	if('${ses.ctrlCd}'.indexOf('E100') === -1 && '${ses.ctrlCd}'.indexOf('R100') === -1){
//    		EVF.C('doNew').setVisible(false);
//		    EVF.C('doEdit').setVisible(false);
//		    EVF.C('doDelete').setVisible(false);
//		    EVF.C('doSave').setVisible(false);
	    }

    	leftGrid = EVF.C("leftGrid");
    	rightGrid = EVF.C("rightGrid");
    	leftGrid.setProperty('multiselect', true);
    	leftGrid.setProperty('shrinkToFit', true);
    	rightGrid.setProperty('shrinkToFit', true);

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
    			EVF.C('EVAL_KIND02').setValue( leftGrid.getCellValue(rowid,'EV_TPL_TYPE_CD')    );
    			EVF.C('PERIODIC_EV_TYPE2').setValue( leftGrid.getCellValue(rowid,'PERIODIC_EV_TYPE')    );
    			EVF.C('TEMPLATE_NM2').setValue( leftGrid.getCellValue(rowid,'EV_TPL_SUBJECT')    );
    			EVF.C('EV_TPL_NUM').setValue( leftGrid.getCellValue(rowid,'EV_TPL_NUM')    );
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
				everPopup.openCommonPopup(param, 'SP0127');
    		} else {
    			var param = {
    					EV_ITEM_NUM : rightGrid.getCellValue(rowid,"EV_ITEM_NUM")
		              	};
				everPopup.openCommonPopup(param, 'SP0128');

	    		}
    		}
    	});


    	rightGrid.addRowEvent(function () {
			if ( EVF.C('EVAL_KIND02').getValue() == '') {
				return;
			}
	        var param = {
	        		evalKind : EVF.C('EVAL_KIND02').getValue()
	        		,callBackFunction : 'addEvalItem'
	        	    ,detailView : false
			};
		    everPopup.openPopupByScreenId('EV0101', 1200, 800, param);
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



            	var evalKind02 = EVF.V("EVAL_KIND02");
				if(evalKind02=='G') {
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
       	        	    	,"WEIGHT" : 1
       	            	}
       	            ];
		   	    	rightGrid.addRow(addParam);
				} else {
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
    }

    function doNew() {
		EVF.C('EVAL_KIND02').setValue('');
		EVF.C('PERIODIC_EV_TYPE2').setValue('');
		EVF.C('TEMPLATE_NM2').setValue('');
		EVF.C('EV_TPL_NUM').setValue('');
		rightGrid.delAllRow();
    }


    function doSearchDetail(value) {
        var store = new EVF.Store();
        store.setParameter('EV_TPL_NUM',value);
        store.setGrid([rightGrid]);
        store.load(baseUrl + "EV0120/doSearchRightGrid", function() {
        });
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([leftGrid]);
        store.load(baseUrl + "EV0120/doSearchLeftGrid", function() {
            if (leftGrid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }
            doNew();
        });
    }

    function doSave() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		rightGrid.checkAll(true);

        if (EVF.V("EVAL_KIND02") == "E") {
        	if (EVF.V("PERIODIC_EV_TYPE2") == "") {
    			//EVF.alert("${EV0120_MSG_05}");
    		    //return;
        	}
        } else {
        	EVF.C("PERIODIC_EV_TYPE2").setValue("");
        }

		var rowIds = rightGrid.getSelRowId();
		var rowIdsSub = rightGrid.getSelRowId();
		for(var i in rowIds) {
			var chkWeight = 0;
			for(var k in rowIdsSub) {// 100 체크
				chkWeight += rightGrid.getCellValue(rowIdsSub[k], 'WEIGHT');
			}
			if (chkWeight!=100) {
				alert("${EV0120_MSG_02}");
				return;
			}
		}


		store.setGrid([ rightGrid ]);
		store.getGridData(rightGrid, 'sel');

		EVF.confirm("${msg.M8888 }", function () {
            store.load(baseUrl + '/EV0120/doSave', function() {
                EVF.alert(this.getResponseMessage(), function() {
					doSearchDetail(EVF.V("EV_TPL_NUM"));
                });
            });
        });
    }

    function doEdit(){

    	if (!leftGrid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

    	EVF.confirm("${msg.M8888 }", function () {
            var store = new EVF.Store();
            store.setGrid([leftGrid]);
            store.getGridData(leftGrid, 'sel');
            store.load(baseUrl + '/EV0120/doEdit', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

    function doDelete() {

		if (!leftGrid.isExistsSelRow()) { return alert('${msg.M0004}'); }

		EVF.confirm("${msg.M8888 }", function () {
            var store = new EVF.Store();
            store.setGrid([leftGrid]);
            store.getGridData(leftGrid, 'sel');
            store.load(baseUrl + '/EV0120/doDelete', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

    function doCopy() {
    	if (EVF.C('EV_TPL_NUM').getValue()=='') {
    		return;
    	}

    	EVF.confirm("${EV0120_MSG_04}", function () {
            var store = new EVF.Store();

            rightGrid.checkAll(true);

            store.setGrid([rightGrid]);
            store.getGridData(rightGrid, 'sel');
            store.load(baseUrl + '/EV0120/doCopy', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }



    function getEvItemType() {
    	return;
        var store = new EVF.Store;
        store.load(baseUrl + '/EV0110/chgEVAL_KIND02', function() {
        	if(EVF.isNotEmpty(this.getParameter("itemTypeCode"))) {
				EVF.C('PERIODIC_EV_TYPE2').setOptions(this.getParameter("itemTypeCode"));
			}
        });
    }

</script>

<e:window id="EV0120" onReady="init" initData="${initData}" title="${fullScreenName}">

    <e:panel width="39%" height="100%">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearchTree">
            <e:row>
				<e:label for="EVAL_KIND01" title="${form_EVAL_KIND01_N}"/>
				<e:field>
					<e:select id="EVAL_KIND01" name="EVAL_KIND01" value="${form.EVAL_KIND01}" options="${evalKind }" width="${form_EVAL_KIND01_W}" disabled="${form_EVAL_KIND01_D}" readOnly="${form_EVAL_KIND01_RO}" required="${form_EVAL_KIND01_R}" placeHolder="" />
				</e:field>
				<e:label for="TEMPLATE_NM1" title="${form_TEMPLATE_NM1_N}" />
				<e:field>
					<e:inputText id="TEMPLATE_NM1" style="${imeMode}" name="TEMPLATE_NM1" value="${form.TEMPLATE_NM1}" width="100%" maxLength="${form_TEMPLATE_NM1_M}" disabled="${form_TEMPLATE_NM1_D}" readOnly="${form_TEMPLATE_NM1_RO}" required="${form_TEMPLATE_NM1_R}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
				<%--회사명--%>
				<%--<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />--%>
			</e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doNew" name="doNew" label="${doNew_N}" onClick="doNew" disabled="${doNew_D}" visible="${doNew_V}"/>
			<e:button id="doEdit" name="doEdit" label="${doEdit_N }" onClick="doEdit" disabled="${doEdit_D }" visible="${doEdit_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>
    </e:panel>
    <e:panel width="1%">&nbsp;</e:panel>
    <e:panel width="60%" height="100%">
        <e:searchPanel useTitleBar="false" id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch">
            <e:row>
				<e:label for="EVAL_KIND02" title="${form2_EVAL_KIND02_N}"/>
				<e:field>
				<e:select id="EVAL_KIND02" name="EVAL_KIND02" onChange="getEvItemType" value="${form.EVAL_KIND02}" options="${evalKind }" width="${form2_EVAL_KIND02_W}" disabled="${form2_EVAL_KIND02_D}" readOnly="${form2_EVAL_KIND02_RO}" required="${form2_EVAL_KIND02_R}" placeHolder="" />
				<e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM"/>
				<e:inputHidden id="PERIODIC_EV_TYPE2" name="PERIODIC_EV_TYPE2"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="TEMPLATE_NM2" title="${form2_TEMPLATE_NM2_N}" />
				<e:field>
				<e:inputText id="TEMPLATE_NM2" style="${imeMode}" name="TEMPLATE_NM2" value="${form.TEMPLATE_NM2}" width="100%" maxLength="${form2_TEMPLATE_NM2_M}" disabled="${form2_TEMPLATE_NM2_D}" readOnly="${form2_TEMPLATE_NM2_RO}" required="${form2_TEMPLATE_NM2_R}"/>
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>

			<!-- e:button id="doCopy" name="doCopy" label="${doCopy_N}" onClick="doCopy" disabled="${doCopy_D}" visible="${doCopy_V}"/-->

        </e:buttonBar>
    </e:panel>
		<e:panel id="leftPanel" height="fit" width="39%">
			<e:gridPanel gridType="${_gridType}" id="leftGrid" name="leftGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.leftGrid.gridColData}"/>
		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>

	<e:panel id="righttPanel1" height="fit" width="60%">
		<e:gridPanel gridType="${_gridType}" id="rightGrid" name="rightGrid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.rightGrid.gridColData}"/>
	</e:panel>

</e:window>
</e:ui>