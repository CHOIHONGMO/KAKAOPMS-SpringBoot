<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">
        // 100: 승인요청, 150: 승인, 200: 승인요청취소, 300: 취소요청, 400: 취소승
        var grid;
        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {

        	grid = EVF.C("grid");
            grid.setProperty('singleSelect', true);
//            grid.setProperty("multiselect", true);

            grid.cellClickEvent(function(rowId, colId, value) {
                var param;

                switch (colId) {
                    case "VENDOR_CD":
                        param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            resultScore: grid.getCellValue(rowId, "EV_RESULT_SCORE"),
                            detailView: false,
                            popupFlag: true
                        };
                        console.log(JSON.stringify(param));
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                        break;

                    case "EV_CNT":
                        param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                            EV_RESULT_SCORE: grid.getCellValue(rowId, "EV_RESULT_SCORE"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BS03_009P", 600, 300, param);

                        break;

                    case "EV_RESULT_SCORE":
                        var progressCd = grid.getCellValue(rowId, "PROGRESS_CD");
                        var resultScore = grid.getCellValue(rowId, "EV_RESULT_SCORE");
                        var detailView;

                        if(resultScore == '') {
                        	return;
                        }

                        if(progressCd == "100" || progressCd == "200") {
                            detailView = false;
                        } else {
                        	detailView = true;
                        }
                        param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: detailView
                        };

                        everPopup.bs03_010open(param);

                        break;

                    case 'REJECT_RMK':
                    	var rejectRMK = grid.getCellValue(rowId, "REJECT_RMK");
                    	if(rejectRMK != '') {
                    		return;
                        }
                    	var param = {
              				title : '반려사유',
              				message : grid.getCellValue(rowId, 'REJECT_RMK'),
              				callbackFunction : 'setRejectText',
                  			detailView : false,
              				rowId : rowId
              			};
	            		var url = '/common/popup/common_text_input/view';
	            	    everPopup.openModalPopup(url, 500, 320, param);
						break;

                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            EVF.C('PROGRESS_CD').removeOption('E');
            fn_multiCombo();
            //doSearch();
        }
        function fn_multiCombo(){
           	var chkName = "";
            $('.ui-multiselect-checkboxes li input').each(function (k, v) {
              if(v.value == 'J' || v.value == 'T' || v.value == 'P') {
                 chkName += v.title + ", ";
                 v.checked = true;
                  }
              });
            $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            doSearch();


	    }

        function setRejectText(data){
        	grid.setCellValue(data.rowId, 'REJECT_RMK', data.message);
        }

        /*	조회	*/
        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs03009_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(data) {
            EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
        }

        /*	평가등록	*/
        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var value = grid.getSelRowValue()[0];
          //평가 횟수 존재시 CONFIRM
            if(value.EV_CNT != '0'){
            	if(!confirm("${BS03_009_014}")){return;}
            }
           	/* if (!(value.PROGRESS_CD == "150" || value.PROGRESS_CD == "400")) {
                return alert("${BS03_009_001}");
            } */

            if (value.PROGRESS_CD == "R") {
                return alert("${BS03_009_010}");
            }
            if (value.PROGRESS_CD == "P") {
            	return alert("${BS03_009_011}");
            }
            //console.log(JSON.stringify(value));

			var param;

			/* if(value.EV_RESULT_SCORE != '0'){
				//console.log("등록평가점수 있음");
				param = {
	                VENDOR_CD: value.VENDOR_CD,
	                detailView: false,
	                PROGRESS_CD: "100",
	                SPEV_YN: ""
			    };
			} else if(!((value.EV_RESULT_SCORE != '0'))){
				//console.log("등록평가점수 없음 == 신규");
				param = {
	                VENDOR_CD: value.VENDOR_CD,
	                detailView: false,
	                PROGRESS_CD: "100",
	                SPEV_YN: "Y"
		       	};
			} */


			param = {
	                VENDOR_CD: value.VENDOR_CD,
	                detailView: false,
	                PROGRESS_CD: "100",
	                SPEV_YN: "Y"
			};

			//console.log(JSON.stringify(param));
            everPopup.bs03_010open(param);
        }

        /*	반려	*/
        function doReject() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var selRowId = grid.getSelRowId();


            for(var i in selRowId) {
                var rowIdx = selRowId[i];

                if(grid.getCellValue(rowIdx, 'REJECT_RMK') == "") {
                	grid.setCellBgColor(rowIdx, "REJECT_RMK", '#fdd');
                	return alert("${BS03_009_012}");
                }

                var progressCd = grid.getCellValue(rowIdx, "PROGRESS_CD");
                var signStatus = grid.getCellValue(rowIdx, "SIGN_STATUS");

                if(progressCd == 'R') {
                	return alert("${BS03_009_010}");
                }
            }

            if(confirm("${BS03_009_013}")) {
	            doUpdateRejectStatus("R");
            }
        }

        function doUpdateRejectStatus(param){

        	var store = new EVF.Store();
            store.setGrid([grid]);
            store.setParameter("PROGRESS_CD", param);
            store.setParameter("SIGN_STATUS", param);
            store.getGridData(grid, "sel");

            store.load(baseUrl + 'bs03009_doUpdateRejectStatus', function() {
                alert("${msg.M0001}");
                doSearch();
            });
        }

        /*	승인(결재)	*/
        function doConfirm() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                var progressCd = grid.getCellValue(rowIdx, "PROGRESS_CD");

                if(progressCd != "100") {
                    return alert("${BS03_009_002}");
                }
            }

            doUpdateProgressCd("150");
        }

        /*	승인거부	*/
        function doConfirmReject() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                var progressCd = grid.getCellValue(rowIdx, "PROGRESS_CD");

                if(progressCd != "100") {
                    return alert("${BS03_009_003}");
                }
            }

            doUpdateProgressCd("200");
        }

        /*	취소요청	*/
        function doCancel() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                var progressCd = grid.getCellValue(rowIdx, "PROGRESS_CD");

                if(progressCd != "150") {
                    return alert("${BS03_009_004}");
                }
            }

            doUpdateProgressCd("300");
        }

        /*	취소	*/
        function doConfirmCancel() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                var progressCd = grid.getCellValue(rowIdx, "PROGRESS_CD");

                if(progressCd != "300") {
                    return alert("${BS03_009_005}");
                }
            }

            doUpdateProgressCd("400");
        }

        function doUpdateProgressCd(progressCd) {
            var message = "";
            if (progressCd == "150") {
                message = "${BS03_009_006}";
            } else if (progressCd == "200") {
                message = "${BS03_009_007}";
            } else if (progressCd == "300") {
                message = "${BS03_009_008}";
            } else if (progressCd == "400") {
                message = "${BS03_009_009}";
            }

            if (!confirm(message)) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.setParameter("PROGRESS_CD", progressCd);
            store.getGridData(grid, "sel");
            store.load(baseUrl + 'bs03009_doUpdateProgressCd', function() {
                alert("${msg.M0001}");
                doSearch();
            });
        }

        /*	수정	*/
		function doModify() {
        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var vendorCd = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
            }
            var param = {
                'VENDOR_CD': vendorCd,
                'SIGN_STATUS': grid.getCellValue(rowIds[i], 'SIGN_STATUS'),
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
		}

		function doInsert() {

            var param = {
                'VENDOR_CD': '',
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
        }

    </script>

    <e:window id="BS03_009" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="EVAL_DATE_FROM" name="EVAL_DATE_FROM"/>
			<e:inputHidden id="EVAL_DATE_TO" name="EVAL_DATE_TO"/>
            <e:row>
                <%-- 진행상태 --%>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false"/>
                </e:field>
               <%-- 협력업체 --%>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
<%--                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />--%>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
                <%-- 사업자번호 --%>
                <e:label for="IRS_NO" title="${form_IRS_NO_N}" />
                <e:field>
                    <e:inputText id="IRS_NO" name="IRS_NO" value="" width="${form_IRS_NO_W}" maxLength="${form_IRS_NO_M}" disabled="${form_IRS_NO_D}" readOnly="${form_IRS_NO_RO}" required="${form_IRS_NO_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
				<e:label for="CEO_NM" title="${form_CEO_NM_N}" />
				<e:field colSpan="3">
					<e:inputText id="CEO_NM" name="CEO_NM" value="" width="${form_CEO_NM_W}" maxLength="${form_CEO_NM_M}" disabled="${form_CEO_NM_D}" readOnly="${form_CEO_NM_RO}" required="${form_CEO_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<%-- 조회 --%>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <%-- 수정
			<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/> --%>
			<%-- 평가등록 --%>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <%-- 승인(결재)
            <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>--%>
            <%-- 반려 --%>
            <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
            <%-- 승인거부
            <e:button id="doConfirmReject" name="doConfirmReject" label="${doConfirmReject_N}" onClick="doConfirmReject" disabled="${doConfirmReject_D}" visible="${doConfirmReject_V}"/> --%>
            <!-- 신규등록 -->
			<e:button id="Insert" name="Insert" label="${Insert_N}" onClick="doInsert" disabled="${Insert_D}" visible="${Insert_V}"/>

			<%-- 2022.09.02 HMCHOI 취소요청, 취소
            <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
            <e:button id="doConfirmCancel" name="doConfirmCancel" label="${doConfirmCancel_N}" onClick="doConfirmCancel" disabled="${doConfirmCancel_D}" visible="${doConfirmCancel_V}"/>--%>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>