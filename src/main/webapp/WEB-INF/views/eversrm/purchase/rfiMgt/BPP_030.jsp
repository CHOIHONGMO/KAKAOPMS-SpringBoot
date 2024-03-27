<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
    	var grid = {};
    	var baseUrl = '/eversrm/purchase/rfiMgt';

		function init() {
			grid = EVF.C("grid");

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

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				var params = {};
				if( celname == 'RFI_NUM' ) {
		            params = {
						detailView: true,
						RFI_NUM: grid.getCellValue(rowid, "RFI_NUM")
					};

		            everPopup.openRfiRequestPopup(params);
				} else if( celname == 'ANSWER_SQ') {
		            params = {
						RFI_NUM: grid.getCellValue(rowid, "RFI_NUM"),
						detailView: true
					};

					everPopup.openSearchVendorReplyInfomationPopup(params);
				} else ;
			});
		}


	    function doSearch() {
			if( !everDate.fromTodateValid('REQ_DATE_FROM', 'REQ_DATE_TO', '${ses.dateFormat }') ) {
				alert('${msg.M0073}'); return;
			}

	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + '/BPP_030/doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	alert("${msg.M0002 }");
	            }
	        });
	    }

	    function doChange() {
			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
			    alert("${msg.M0004}");
			    return;
			}

			if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			    alert("${msg.M0006}");
			    return;
			}

			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

			for(var i = 0;i < selRowId.length;i++) {
			    var progressCode = grid.getCellValue(selRowId[i],'PROGRESS_CD');
			    if(progressCode > "200") return alert("${msg.M0044 }");
			}

	        var params = {
				RFI_NUM: grid.getCellValue(selRowId[0],'RFI_NUM'),
				detailView: true
			};

	        everPopup.openRfiRequestPopup(params);
	    }

	    function doDelete() {
	    	if( Object.keys( grid.getSelRowValue() ).length == 0 ) { alert("${msg.M0004}"); return; }

	    	if (confirm("${msg.M0009}")) {
		        var store = new EVF.Store();
		        store.setGrid([grid]);
		        store.getGridData(grid, 'sel');
		        store.load(baseUrl + '/BPP_030/doDeleteRfiStatus', function() {
	            	alert(this.getResponseMessage());
	            	doSearch();
		        });
	    	}
	    }

	    function doDeadLine() {
			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
			    alert("${msg.M0004}");
			    return;
			}

			if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			    alert("${msg.M0006}");
			    return;
			}

			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

			for(var i = 0;i < selRowId.length;i++) {
			    var progressCode = grid.getCellValue(selRowId[i],'PROGRESS_CD');
			    if(progressCode > "500") return alert("${msg.M0044 }");
			}

	        var params = {
	            RFI_NUM: grid.getCellValue(selRowId[0],'RFI_NUM'),
	            CLOSE_DATE: grid.getCellValue(selRowId[0],'CLOSE_DATE'),
	            paramPopupFlag: 'N',
	            onClose: 'doSearch'
	        };

	        everPopup.openDeadlineExtendPopup(params);
	    }

	    function doSearchDept() {
	        if ("${ses.userType}" != 'S') {
		        var param = {
		            callBackFunction: "selectDept",
		            BUYER_CD: "${ses.companyCd}"
				};

		        everPopup.openCommonPopup(param, 'SP0002');
	        } else {
	            alert("BPP_030_NOT_DEPT");

	        }
	    }

	    function selectDept(dataJsonArray) {
	    	if( typeof dataJsonArray != 'object' ) {
	    		dataJsonArray = $.parseJSON(dataJsonArray);
	    	}

	        EVF.C('REQ_DEPT_NM').setValue(dataJsonArray.DEPT_NM);
	    }

	    function selectBuyer() {
	        everPopup.openCommonPopup({
	            callBackFunction: "selectUser"
	        }, 'SP0001');
        }
        function selectUser(dataJsonArray) {
	    	if( typeof dataJsonArray != 'object' ) {
	    		dataJsonArray = $.parseJSON(dataJsonArray);
	    	}

	        EVF.C("REQ_USER_ID").setValue(dataJsonArray.USER_NM);
        }
        function doFinish() {
			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
	        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

	        for (var i = 0; i < selRowId.length; i++) {
	            var progress_cd = grid.getCellValue(selRowId[i],'PROGRESS_CD');
	            if (progress_cd != "300") {
	                alert("${msg.M0044 }");
	                return;
	            }
	     	}

	    	if (confirm("${msg.M8888}")) {
		        var store = new EVF.Store();
		        store.setGrid([grid]);
		        store.getGridData(grid, 'sel');
		        store.load(baseUrl + '/BPP_030/doFinishRfi', function() {
	            	alert(this.getResponseMessage());
	            	doSearch();
		        });
	    	}

	    }
    </script>

    <e:window id="BPP_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    	<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
    		<e:row>
				<e:label for="REQ_DATE" title="${form_REQ_DATE_N}"/>
				<e:field>
					<e:inputDate id="REQ_DATE_FROM" name="REQ_DATE_FROM" value="${REQ_DATE_FROM}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_FROM_R}" disabled="${form_REQ_DATE_FROM_D}" readOnly="${form_REQ_DATE_FROM_RO}" />
                	<label style="float : left;">~&nbsp;</label>
					<e:inputDate id="REQ_DATE_TO" name="REQ_DATE_TO" value="${REQ_DATE_TO}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_TO_R}" disabled="${form_REQ_DATE_TO_D}" readOnly="${form_REQ_DATE_TO_RO}" />
				</e:field>
				<e:label for="RFI_NUM" title="${form_RFI_NUM_N}"/>
				<e:field>
					<e:inputText id="RFI_NUM" name="RFI_NUM" value="${form.RFI_NUM}" width="${inputTextWidth }" maxLength="${form_RFI_NUM_M}" disabled="${form_RFI_NUM_D}" readOnly="${form_RFI_NUM_RO}" required="${form_RFI_NUM_R}" />
				</e:field>
				<e:label for="RFI_SUBJECT" title="${form_RFI_SUBJECT_N}"/>
				<e:field>
					<e:inputText id="RFI_SUBJECT" name="RFI_SUBJECT" value="${form.RFI_SUBJECT}" width="100%" maxLength="${form_RFI_SUBJECT_M}" disabled="${form_RFI_SUBJECT_D}" readOnly="${form_RFI_SUBJECT_RO}" required="${form_RFI_SUBJECT_R}" />
				</e:field>
    		</e:row>

			<e:row>

				<e:label for="RFI_TYPE" title="${form_RFI_TYPE_N}"/>
				<e:field>
					<e:select id="RFI_TYPE" name="RFI_TYPE" value="${form.RFI_TYPE}" options="${rfiType }" width="${inputTextWidth}" disabled="${form_RFI_TYPE_D}" readOnly="${form_RFI_TYPE_RO}" required="${form_RFI_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="REQ_DEPT_NM" title="${form_REQ_DEPT_NM_N}"/>
				<e:field>
					<e:search id="REQ_DEPT_NM" name="REQ_DEPT_NM" value="" width="${inputTextWidth}" maxLength="${form_REQ_DEPT_NM_M}" onIconClick="${form_REQ_DEPT_NM_RO ? 'everCommon.blank' : 'doSearchDept'}" disabled="${form_REQ_DEPT_NM_D}" readOnly="${form_REQ_DEPT_NM_RO}" required="${form_REQ_DEPT_NM_R}" />
				</e:field>

				<e:label for="REQ_USER_ID" title="${form_REQ_USER_ID_N}"/>
				<e:field>
					<e:search id="REQ_USER_ID" name="REQ_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_REQ_USER_ID_M}" onIconClick="${form_REQ_USER_ID_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_REQ_USER_ID_D}" readOnly="${form_REQ_USER_ID_RO}" required="${form_REQ_USER_ID_R}" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressStatus }" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>

				<e:label for="REQ_PERSON_TYPE" title="${form_REQ_PERSON_TYPE_N}"/>
				<e:field colSpan="3">
					<e:select id="REQ_PERSON_TYPE" name="REQ_PERSON_TYPE" value="${form.REQ_PERSON_TYPE}" options="${requestPersonType }" width="${inputTextWidth}" disabled="${form_REQ_PERSON_TYPE_D}" readOnly="${form_REQ_PERSON_TYPE_RO}" required="${form_REQ_PERSON_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
    	</e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
    		<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    		<e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}"/>
    		<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
    		<e:button id="doDeadLine" name="doDeadLine" label="${doDeadLine_N}" onClick="doDeadLine" disabled="${doDeadLine_D}" visible="${doDeadLine_V}"/>
    		<e:button id="doFinish" name="doFinish" label="${doFinish_N}" onClick="doFinish" disabled="${doFinish_D}" visible="${doFinish_V}"/>
    	</e:buttonBar>

    	<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>