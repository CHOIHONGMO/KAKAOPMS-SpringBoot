
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

    	var grid = {};
    	var baseUrl = "/eversrm/master/item/BBM_100";
		var selRow;

		function init() {
			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.cellClickEvent(function(rowId, colId, value) {

				if(selRow == undefined) selRow = rowId;

				if (colId=='ITEM_CD') {
		            var param = {
		            	itemCd: grid.getCellValue(rowId,"ITEM_CD"),
                        detailView: '${!havePermission}',
						pcMaster : 'Y'

		             };

		             everPopup.openItemDetailInformation(param);
				}

				if (colId == 'PROCESS_RMK') {

					var param = {
						message: grid.getCellValue(rowId,'PROCESS_RMK'),
						callbackFunction: 'setRMK',
						rowId: rowId
					};

					var url = '/common/popup/common_text_input/view';
					everPopup.openModalPopup(url, 500, 310, param);
				}
			});

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
			    excelOptions : {
					  imgWidth     : 0.12      <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
					,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
			        ,attachImgFlag : false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});

			EVF.C('PROGRESS_CD').setValue('W');
			EVF.C("PROGRESS_CD").removeOption("T");

			doSearch();
        }

		function setRMK(data) {
			grid.setCellValue(data.rowId, 'PROCESS_RMK', data.message);
		}

        function doSearch() {

        	if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

		function doAccept() {

            if(grid.getSelRowCount() == 0) {
                return alert('${msg.M0004}');
            }

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {

                var progressCd = grid.getCellValue(selRowId[i], 'PROGRESS_CD');
                if(progressCd !== 'W') {
                    return alert('${BBM_100_0001}');
                }
            }

            if(confirm('${msg.M0025}')) {

                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl+'/doAccept', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
            }
        }

        function doReject() {

		    if(grid.getSelRowCount() == 0) {
		        return alert('${msg.M0004}');
			}

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {

                var progressCd = grid.getCellValue(selRowId[i], 'PROGRESS_CD');
                if(progressCd !== 'W') {
                    return alert('${BBM_100_0001}');
                }
            }

	        if (confirm("${msg.M0022}")) {

		        var store = new EVF.Store();
		        store.setGrid([grid]);
	        	store.getGridData(grid, 'sel');
	        	store.load(baseUrl + '/doReject', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	        }
        }

        function _doSelectUser() {
            var param = {
                callBackFunction: "setUser"
            };
            everPopup.openCommonPopup(param, 'SP0011');
        }

        function setUser(data) {
            EVF.C("REQ_USER_NM").setValue(data.USER_NM);
            EVF.C("REQ_USER_ID").setValue(data.USER_ID);
        }

    </script>
	<e:window id="BBM_100" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--요청일자--%>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>
				<%--품목코드--%>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" style='ime-mode:inactive'/>
				</e:field>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="100%" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--품명/규격--%>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<%--요청자--%>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
				<e:field>
					<e:search id="REQ_USER_ID" style="ime-mode:inactive" name="REQ_USER_ID" value="" width="40%" maxLength="${form_REQ_USER_ID_M}" onIconClick="${form_REQ_USER_ID_RO ? 'everCommon.blank' : '_doSelectUser'}" disabled="${form_REQ_USER_ID_D}" readOnly="${form_REQ_USER_ID_RO}" required="${form_REQ_USER_ID_R}" />
					<e:search id="REQ_USER_NM" style="${imeMode}" name="REQ_USER_NM" value="" width="60%" maxLength="${form_REQ_USER_NM_M}" onIconClick="${form_REQ_USER_NM_RO ? 'everCommon.blank' : ''}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
				</e:field>
				<%--제조사--%>
				<e:label for="MAKER" title="${form_MAKER_N}"/>
				<e:field>
					<e:select id="MAKER" name="MAKER" value="" options="${makerOptions}" width="100%" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
			<c:if test="${ses.ctrlCd != null}">
				<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doAccept" disabled="${doApproval_D}" visible="${doApproval_V}" />
				<e:button id="doReturn" name="doReturn" label="${doReturn_N}" onClick="doReject" disabled="${doReturn_D}" visible="${doReturn_V}" />
			</c:if>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>