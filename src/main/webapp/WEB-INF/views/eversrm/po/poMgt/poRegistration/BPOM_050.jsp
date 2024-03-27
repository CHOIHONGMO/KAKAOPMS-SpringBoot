<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
    var baseUrl = "/eversrm/po/poMgt/poRegistration/";

    function init() {
        grid = EVF.getComponent("grid");

		grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				  imgWidth      : 0.12      <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
    })
        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			switch (celname) {
				case 'PO_NUM':
		            var param = {
		                poNum: grid.getCellValue(rowid, "PO_NUM"),
		                detaiView: true
		            };
		            everPopup.openPoDetailInformation(param);
					break;

				case 'VENDOR_CD':
		            var params = {
		                VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
		                popupFlag: true,
		                detailView: true
		            };
		            everPopup.openSupManagementPopup(params);
					break;

				default:
					return;
			}
		});

		EVF.getComponent('grid').setColCellRadio('SELECTED', true);
        EVF.getComponent('USER_NM').setValue('${ses.userNm}');
    }

    function doSearch() {

    	var store = new EVF.Store();
		if(!store.validate()) { return; }

		if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');

    	store.setGrid([grid]);
        store.load(baseUrl + 'BPOM_050/doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }

        });
    }

    function doClose() {
    	window.close();
    }

    function doSelect() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

		var gridData = grid.getSelRowValue();
        var selectedRow = gridData[0];
        opener.window['${param.callBackFunction}'](selectedRow);
        doClose();
    }

    function doSearchVendor() {
        var param = {
            callBackFunction: "selectVendorSearch",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, "SP0025");
    }

    function selectVendorSearch(data) {
        EVF.getComponent("VENDOR_CD").setValue(data['VENDOR_CD']);
    }

    function doSearchUser() {
        var param = {
            callBackFunction: "selectUser",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0040');
    }

    function selectUser(data) {
        EVF.getComponent("USER_NM").setValue(data.CTRL_USER_NM);
    }

    </script>

	<e:window id="BPOM_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" onEnter="doSearch">
			<e:row>
				<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
				</e:field>

				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
				</e:field>

				<e:label for="PO_NUM" title="${form_PO_NUM_N}" />
				<e:field>
					<e:inputText id="PO_NUM" name="PO_NUM" value="" width="100%" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PO_TYPE" title="${form_PO_TYPE_N}" />
				<e:field>
					<e:select id="PO_TYPE" name="PO_TYPE" value="" options="${poType}" width="${inputTextWidth}" disabled="${form_PO_TYPE_D}" readOnly="${form_PO_TYPE_RO}" required="${form_PO_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="USER_NM" title="${form_USER_NM_N}" />
				<e:field>
					<e:search id="USER_NM" name="USER_NM" value="" width="${inputTextWidth}" maxLength="${form_USER_NM_M}" onIconClick="${form_USER_NM_RO ? 'everCommon.blank' : 'doSearchUser'}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				</e:field>

			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}" />
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
