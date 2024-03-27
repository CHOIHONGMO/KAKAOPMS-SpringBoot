<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var gridb;
	    var baseUrl = "/eversrm/master/item/";
	    var popupFlag = '';
	    var isImageView = true;
	    var catalogSearch = 0;
	    var colHideFlag = true;

		function init() {

	        <c:if test="${ses.ctrlCd == null || ses.ctrlCd == '' }">
		        alert('구매담당자만 처리할 수 있습니다.');
			</c:if>

			gridb = EVF.C('gridb');
	        gridb.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {
	        	currRow = rowid;
		        if (celname == "VENDOR_CD_IMG") {
		    	    	everPopup.openCommonPopup({
		    	            callBackFunction: "selectVendor"
		    	        }, 'SP0025');
		        }
		        if (celname == "ITEM_CD_IMG") {
		            var param = {
		                    callBackFunction: 'selectItemCode'
		                };
		                everPopup.openCommonPopup(param, 'SP0018');
	   		    }
	        });

	        gridb.excelExportEvent({
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

	        gridb.setProperty('shrinkToFit', true);

		}

	    function selectItemCode(dataJsonArray) {
	    	gridb.setCellValue(currRow,'ITEM_NM',dataJsonArray.ITEM_DESC);
	    	gridb.setCellValue(currRow,'ITEM_CD',dataJsonArray.ITEM_CD)
	    }

	    function selectVendor(data) {
	    	gridb.setCellValue(currRow,'VENDOR_NM',data.VENDOR_NM);
	    	gridb.setCellValue(currRow,'VENDOR_CD',data.VENDOR_CD)
        }
        var currRow;

        function excelUploadCallBack( msg, code ) {
        	gridb.checkAll(true);
            alert('엑셀 업로드에 성공 하였습니다.');
        }

		function EXCELUP() {
			   gridb.delAllRow();
			   gridb.excelImport(
						{ 'append' : true }
						, excelUploadCallBack
					).call( grid );
		}


	    function doSave() {
	        var valid = gridb.validate()
    			, selRows = gridb.getSelRowValue();

			if (gridb.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			if (!gridb.validate().flag) { return alert(gridb.validate().msg); }

			for( var i = 0, len = selRows.length; i < len; i++ ) {
				if( Number(selRows[i].UNIT_PRC) == 0 ) { alert("${BBM_080A_001}"); return; }


				if (selRows[i].VALID_FROM_DATE < '${toDate}') {
					alert("${BBM_080A_002}");
					return;
				}

				if (selRows[i].VALID_FROM_DATE >= selRows[i].VALID_TO_DATE) {
					alert("${BBM_080A_003}");
					return;
				}

			}

			if (!confirm("${msg.M0021}")) return;

	        var store = new EVF.Store();
	        store.setGrid([gridb]);
	        store.getGridData( gridb, 'sel');
	        store.load(baseUrl + "/BBM_080A/doCreateInfo", function() {
	            alert(this.getResponseMessage());
	            gridb.delAllRow();
	        });
	    }

	    function ADDROW() {
	    	addParam = [
    	            	{
    	        	    	"VENDOR_CD" : ''
    	        	    	,"VALID_FROM_DATE" : '${toDate}'
    	        	    	,"VALID_TO_DATE" :  '${toDate}'.substring(0,4)+'1231'
    	            	}
    	            ];
	    		gridb.addRow(addParam);
	    }

	    function DELROW() {
			var selRows = gridb.getSelRowId();
			mm = gridb.jsonToArray(selRows );
			for (var k = 0; k < mm.value.length; k++) {
	    		var krowId = mm.value[k];
			       gridb.delRow(krowId);
			}
	    }

		function EXECELUP() {
			   //gridb.delAllRow();
			   gridb.excelImport(
						{ 'append' : true }
						, excelUploadCallBack
					).call( gridb );
		}

		</script>

	<e:window id="BBM_080A" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
        			<e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}"/>
			<e:row>
			<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
			<e:field>
			<e:inputDate id="REG_DATE" name="REG_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
			</e:field>
			<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
			<e:field>
			<e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${ses.userNm}" width="30%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
			</e:field>
			</e:row>
			<e:row>
                <e:label for="RMK_TEXT_NUM" title="${form_RMK_TEXT_NUM_N}" />
                <e:field colSpan="3">
                	<e:richTextEditor id="RMK_TEXT_NUM_TEXT" value="${form.RMK_TEXT_NUM_TEXT }"  height="180px" name="RMK_TEXT_NUM_TEXT" width="100%" required="${form_RMK_TEXT_NUM_TEXT_R }" readOnly="${form_RMK_TEXT_NUM_TEXT_RO }" disabled="${form_RMK_TEXT_NUM_TEXT_D }" />
				</e:field>
			</e:row>
        </e:searchPanel>

	        <c:if test="${ses.ctrlCd != null && ses.ctrlCd != '' }">
		<e:buttonBar align="right">
				<e:button id="ADDROW" name="ADDROW" label="${ADDROW_N}" onClick="ADDROW" disabled="${ADDROW_D}" visible="${ADDROW_V}" align="left"/>

				<e:button id="DELROW" name="DELROW" label="${DELROW_N}" onClick="DELROW" disabled="${DELROW_D}" visible="${DELROW_V}" align="left"/>

				<e:button id="EXECELUP" name="EXECELUP" label="${EXECELUP_N}" onClick="EXECELUP" disabled="${EXECELUP_D}" visible="${EXECELUP_V}"/>

				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
		</e:buttonBar>
			</c:if>

		<e:panel id="rightPanel" height="fit" width="100%">
			<e:gridPanel gridType="${_gridType}" id="gridb" name="gridb" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridb.gridColData}"/>
		</e:panel>

	</e:window>
</e:ui>