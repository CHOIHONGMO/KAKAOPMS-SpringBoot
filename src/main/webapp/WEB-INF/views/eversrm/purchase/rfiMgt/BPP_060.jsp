<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
    	var grid = {};
    	var baseUrl = '/eversrm/purchase/rfiMgt';

		function init() {
			grid = EVF.C("grid");
			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				var params = {};
				if( celname == 'RFI_NUM' ) {
		            params = {
						detailView: true,
						RFI_NUM: grid.getCellValue(rowid, "RFI_NUM")
					};

		            everPopup.openRfiRequestPopup(params);
				} else if( celname == 'VENDOR_CD') {
		            params = {
		            	VENDOR_CD  : grid.getCellValue(rowid, "VENDOR_CD"),
		            	popupFlag  : true,
						detailView : true
					};

		            everPopup.openSupManagementPopup(params);
				} else ;
			});

			var excelProp = {
		            allCol: "${excelExport.allCol}",
		            selRow: "${excelExport.selRow}",
		            fileType: "${excelExport.fileType}",
		            fileName: "${fullScreenName}",
		            excelOptions: {
		                imgWidth: 0.12,        <%-- // 이미지의 너비. --%>
		                imgHeight: 0.26 ,      <%-- // 이미지의 높이. --%>
		                colWidth: 20,          <%-- // 컬럼의 넓이. --%>
		                rowSize: 500,          <%-- // 엑셀 행에 높이 사이즈. --%>
		                attachImgFlag: false   <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		            }
		    };

			grid.excelExportEvent(excelProp);

		}

		function doSearch() {
			if( !everDate.fromTodateValid('regDateFrom', 'regDateTo', '${ses.dateFormat }') ) {
				alert('${msg.M0073}'); return;
			}

	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + '/BPP_060/doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	alert("${msg.M0002 }");
	            }
	        });
		}

	    function doSearchPurchaseGroup() {
	        var param = {
	            callBackFunction: "selectPurGroup",
	            BUYER_CD: "${ses.companyCd}"
	        };

	        everPopup.openCommonPopup(param, 'SP0021');
	    }

	    function selectPurGroup(dataJsonArray) {
	    	if( typeof dataJsonArray != 'object') {
	    		dataJsonArray = $.parseJSON(dataJsonArray);
	    	}

	        EVF.getComponent('CTRL_CD').setValue(dataJsonArray.CTRL_NM);
	    }

	    function doSearchPurchaser() {
	        var param = {
				callBackFunction: "selectBuyer"
			};

	        everPopup.openCommonPopup(param, 'SP0040');
        }
        function selectBuyer(dataJsonArray) {
	    	if( typeof dataJsonArray != 'object') {
	    		dataJsonArray = $.parseJSON(dataJsonArray);
	    	}

	    	EVF.C('CTRL_USER_ID').setValue( dataJsonArray.CTRL_USER_NM);
        }
        function doSearchVendor() {
	        var param = {
				BUYER_CD: "${ses.companyCd}",
				callBackFunction: "_setVendor"
			};

			everPopup.openCommonPopup(param, 'SP0013');
        }
        function _setVendor(dataJsonArray) {
	    	if( typeof dataJsonArray != 'object') {
	    		dataJsonArray = $.parseJSON(dataJsonArray);
	    	}

	        EVF.getComponent("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
        }
    </script>

    <e:window id="BPP_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    	<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
    		<e:row>
				<e:label for="REQ_DATE" title="${form_REQ_DATE_N}"/>
				<e:field>
					<e:inputDate id="regDateFrom" name="regDateFrom" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_regDateFrom_R}" disabled="${form_regDateFrom_D}" readOnly="${form_regDateFrom_RO}" />
                	<label style="float : left;">~&nbsp;</label>
                    <e:inputDate id="regDateTo" name="regDateTo" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_regDateTo_R}" disabled="${form_regDateTo_D}" readOnly="${form_regDateTo_RO}" />
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
					<e:select id="RFI_TYPE" name="RFI_TYPE" value="${form.RFI_TYPE}" options="${refRFI_TYPE }" width="${inputTextWidth}" disabled="${form_RFI_TYPE_D}" readOnly="${form_RFI_TYPE_RO}" required="${form_RFI_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="CTRL_CD" title="${form_CTRL_CD_N}"/>
				<e:field>
					<e:search id="CTRL_CD" name="CTRL_CD" value="" width="${inputTextWidth}" maxLength="${form_CTRL_CD_M}" onIconClick="${form_CTRL_CD_RO ? 'everCommon.blank' : 'doSearchPurchaseGroup'}" disabled="${form_CTRL_CD_D}" readOnly="${form_CTRL_CD_RO}" required="${form_CTRL_CD_R}" />
				</e:field>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_ID" name="CTRL_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_RO ? 'everCommon.blank' : 'doSearchPurchaser'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
				</e:field>
    		</e:row>

    		<e:row>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${refPROGRESS_CD }" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field colSpan="3">
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
				</e:field>
    		</e:row>
    	</e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
    		<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    	</e:buttonBar>

    	<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>