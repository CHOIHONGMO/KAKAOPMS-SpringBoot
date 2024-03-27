<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/master/item/";
		var selRow;

		function init() {

			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
            grid.setProperty('singleSelect', true);
			grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

				if (colId=='ITEM_CD') {
		            var param = {
		            	itemCd: grid.getCellValue(rowId,"ITEM_CD")
		             };

		             everPopup.openItemDetailInformation(param);
				}
			});

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
			    excelOptions : {
			        attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});
        }

		function setRMK(data) {
			console.log(data);
			grid.setCellValue(data.rowId, 'PROCESS_RMK', data.message);
		}

        function doSearch() {

        	if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'BBM_020/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

	    function doChange() {
			var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

			if (selRowId.length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }
	        if (selRowId.length > 1) {
	            alert("${msg.M0006}");
	            return;
	        }

	        for (var i = 0; i < selRowId.length; i++) {
                var progress_code = grid.getCellValue(selRowId[i],'PROGRESS_CD');
                var reg_user_id = grid.getCellValue(selRowId[i],'REG_USER_ID');

                if('${ses.ctrlCd}' == '' || '${ses.ctrlCd}' == null) {
                	if(reg_user_id != '${ses.userId}') {
                		alert('${msg.M0008}');
                		return;
                	}
                }

                // 작성중(T), 반려(R)인 경우에만 수정 가능함
                if (progress_code == "T" || progress_code == "R") {
                    var param = {
                        itemCd: grid.getCellValue(selRowId[i],"ITEM_CD"),
                        changeFrom: 'Approval',
                        popupFlag : true,
                        callBackFunction : 'doSearch'
                    };
                    everPopup.openItemManagement(param);
                } else {
                    alert("${BBM_020_0001}");
	                return;
	            }
		    }
	    }

	    function doSelectUser() {
	        var param = {
					callBackFunction: "SelectUser"
				};
			everPopup.openCommonPopup(param, 'SP0011');
	    }
	    function SelectUser(data) {
	        EVF.C("REQ_USER_NM").setValue(data.USER_NM);
	        EVF.C("REQ_USER_ID").setValue(data.USER_ID);
	    }

    </script>

	<e:window id="BBM_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" style='ime-mode:inactive'/>
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="100%" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"  style="${imeMode}"/>
				</e:field>
				<e:label for="REQ_USER_ID" title="${form_REQ_USER_ID_N}"/>
				<e:field>
					<e:search id="REQ_USER_ID" style="ime-mode:inactive" name="REQ_USER_ID" value="${ses.userId }" width="40%" maxLength="${form_REQ_USER_ID_M}" onIconClick="${form_REQ_USER_ID_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_REQ_USER_ID_D}" readOnly="${form_REQ_USER_ID_RO}" required="${form_REQ_USER_ID_R}" />
					<e:inputText id="REQ_USER_NM" style="${imeMode}" name="REQ_USER_NM" value="${ses.userNm }" width="60%" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
				</e:field>
				<e:label for="MAKER" title="${form_MAKER_N}"/>
				<e:field>
					<e:select id="MAKER" name="MAKER" value="" options="${makerOptions}" width="100%" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>