<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/srm/master/evalClassScore/";
    var gridLeft;
    var gridRight;

    function init() {
    	gridLeft = EVF.C("gridLeft");
    	gridRight = EVF.C("gridRight");
        if('${_gridType}' != "RG") {
            gridRight.acceptZero(true);
        }
    	gridLeft.setProperty('multiselect', false);
    	gridLeft.setProperty('shrinkToFit', true);
    	gridRight.setProperty('shrinkToFit', true);


    	gridLeft.setProperty('panelVisible', ${panelVisible});
    	gridRight.setProperty('panelVisible', ${panelVisible});

        // Grid Excel Export
        gridLeft.excelExportEvent({
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
        gridRight.excelExportEvent({
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

    	gridLeft.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
    		if (celname =='EVAL_YEAR') {
    			EVF.getComponent('EVAL_YEAR_R').setValue( gridLeft.getCellValue(rowid,'EVAL_YEAR')    );
    			EVF.getComponent('PURCHASE_TYPE_R').setValue( gridLeft.getCellValue(rowid,'PURCHASE_TYPE')    );
    			doSearchDetail(gridLeft.getCellValue(rowid,'EVAL_YEAR'),gridLeft.getCellValue(rowid,'EV_TPL_NUM'),gridLeft.getCellValue(rowid,'PURCHASE_TYPE'));
    		}
    	});

    }

    function doSearchDetail(year,value,purchaseType) {
        var store = new EVF.Store();
        store.setParameter('EVAL_YEAR',year);
        store.setParameter('EV_TPL_NUM',value);
        store.setParameter('PURCHASE_TYPE',purchaseType);
        store.setGrid([gridRight]);
        store.load(baseUrl + "SRM_200/doSearchDetail", function() {
        });
    }
    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridLeft]);
        store.load(baseUrl + "SRM_200/doSearch", function() {
            if (gridLeft.getRowCount() == 0) {
                alert("${msg.M0002 }");

            }

            gridRight.delAllRow();
            //gridLeft.setCellMerge.call(gridLeft, ['EVAL_YEAR','PURCHASE_TYPE'], true);
            gridLeft.setColMerge(['EVAL_YEAR','PURCHASE_TYPE']);
        });
    }
    function doNew() {
		EVF.getComponent('EVAL_YEAR_R').setValue('');

		gridRight.delAllRow();
        var store = new EVF.Store();
        store.setGrid([gridRight]);
        store.setParameter('EVAL_YEAR','');
        store.load(baseUrl + "SRM_200/doSearchDetail", function() {
        });
    }


    function doSave() {

    	var store = new EVF.Store();

		if (!store.validate()) {
			return;
		}

		gridRight.checkAll(true);

		if(!gridRight.validate().flag) { return alert(gridRight.validate().msg); }

		store.setGrid([ gridRight ]);
		store.getGridData(gridRight, 'sel');
		if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}
		store.load(baseUrl + '/SRM_200/doSave', function() {
			alert(this.getResponseMessage());
			doSearch();
		});
    }

</script>

<e:window id="SRM_200" onReady="init" initData="${initData}" title="${fullScreenName}">

    <e:panel width="54%" height="100%">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearchTree">
            <e:row>
				<e:label for="EVAL_YEAR" title="${formLeft_EVAL_YEAR_N}"/>
				<e:field>
				<e:select id="EVAL_YEAR" name="EVAL_YEAR" value="${form.EVAL_YEAR}" options="${yearList }" width="100%" disabled="${formLeft_EVAL_YEAR_D}" readOnly="${formLeft_EVAL_YEAR_RO}" required="${formLeft_EVAL_YEAR_R}" placeHolder="" />
				</e:field>
				<e:label for="PURCHASE_TYPE" title="${formLeft_PURCHASE_TYPE_N}"/>
				<e:field>
				<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="100%" disabled="${formLeft_PURCHASE_TYPE_D}" readOnly="${formLeft_PURCHASE_TYPE_RO}" required="${formLeft_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="EVAL_GRADE_CLS" title="${formLeft_EVAL_GRADE_CLS_N}"/>
				<e:field>
				<e:select id="EVAL_GRADE_CLS" name="EVAL_GRADE_CLS" value="${form.EVAL_GRADE_CLS}" options="${classificationCode }" width="100%" disabled="${formLeft_EVAL_GRADE_CLS_D}" readOnly="${formLeft_EVAL_GRADE_CLS_RO}" required="${formLeft_EVAL_GRADE_CLS_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doNew" name="doNew" label="${doNew_N}" onClick="doNew" disabled="${doNew_D}" visible="${doNew_V}"/>
        </e:buttonBar>
    </e:panel>
    <e:panel width="1%">&nbsp;</e:panel>
    <e:panel width="45%" height="100%">
        <e:searchPanel useTitleBar="false" id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearch">
            <e:row>
				<e:label for="EVAL_YEAR_R" title="${formRight_EVAL_YEAR_R_N}"/>
				<e:field>
				<e:select id="EVAL_YEAR_R" name="EVAL_YEAR_R" value="${form.EVAL_YEAR_R}" options="${yearList }" width="100%" disabled="${formRight_EVAL_YEAR_R_D}" readOnly="${formRight_EVAL_YEAR_R_RO}" required="${formRight_EVAL_YEAR_R_R}" placeHolder="" />
				</e:field>
				<e:label for="PURCHASE_TYPE_R" title="${formRight_PURCHASE_TYPE_R_N}"/>
				<e:field>
				<e:select id="PURCHASE_TYPE_R" name="PURCHASE_TYPE_R" value="${form.PURCHASE_TYPE_R}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${formRight_PURCHASE_TYPE_R_D}" readOnly="${formRight_PURCHASE_TYPE_R_RO}" required="${formRight_PURCHASE_TYPE_R_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>
    </e:panel>
		<e:panel id="leftPanel" height="fit" width="54%">
			<e:gridPanel gridType="${_gridType}" id="gridLeft" name="gridLeft" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridLeft.gridColData}"/>
		</e:panel>
		<e:panel width="1%">&nbsp;</e:panel>

	<e:panel id="righttPanel1" height="fit" width="45%">
		<e:gridPanel gridType="${_gridType}" id="gridRight" name="gridRight" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridRight.gridColData}"/>
	</e:panel>

</e:window>
</e:ui>