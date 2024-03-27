<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/eversrm/solicit/rfq/rfqProgress/";

        function init() {
            grid = EVF.getComponent("grid");
            grid.setProperty('panelVisible', ${panelVisible});
            EVF.getComponent("RFX_NUM").setValue("${param.rfxNum}");
            EVF.getComponent("RFX_CNT").setValue("${param.rfxCnt}");
            EVF.getComponent("RFX_SUBJECT").setValue("${param.rfxSubject}");
            
            grid.setColEllipsis (['ANN_FAIL_RMK'], true);
            grid.setColEllipsis (['QTA_GIVEUP_RMK'], true);

            
            <c:if test="${form.ANN_FLAG == '0' }">
            grid.hideCol('ANN_PASS_YN',true);
            grid.hideCol('ANN_FAIL_RMK',true);
			</c:if>            
            
            
            doSearch();
            if ("${param.rfxType }" != "" && "${param.rfxType }" == "RA") {
                grid.hideCol("PROGRESS_CD", true);
            }
            
            grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {
            	onCellClick(celName, rowId);
            });
            
            
            
            grid.cellChangeEvent(function(rowId, colKey, iRow, iCol, newVal, oldVal) {
				if (colKey=='ANN_PASS_YN') {
					
					if (
							grid.getCellValue(rowId,'PROGRESS_CD') != '100'
					) {
						alert('${BPX_220_002}');
						grid.setCellValue(rowId,'ANN_PASS_YN',oldVal);
					}
					
				}
            
            
            
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "participatingVendorSearch/doSearch", function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doClose() {
            formUtil.close();
        }

        function onCellClick(strColumnKey, nRow) {
            if (strColumnKey == "VENDOR_CD") {
                var param = {
                    VENDOR_CD: grid.getCellValue(nRow, "VENDOR_CD"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openSupManagementPopup(param);
            }
            if (strColumnKey == "ANN_FAIL_RMK") {
            	setRowId = nRow;
        	    var param = {
        				  havePermission : true
        				, callBackFunction : 'setTextContents'
        				, TEXT_CONTENTS : grid.getCellValue(nRow, "ANN_FAIL_RMK")
        				, detailView : false
        			};
      	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }
            
            if (strColumnKey == "QTA_GIVEUP_RMK") {
            	setRowId = nRow;
        	    var param = {
        				  havePermission : false
        				, callBackFunction : 'setTextContents'
        				, TEXT_CONTENTS : grid.getCellValue(nRow, "QTA_GIVEUP_RMK")
        			};
      	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }
        }
		var setRowId;
		function setTextContents(tests) {
			grid.setCellValue(setRowId, "ANN_FAIL_RMK",tests);
		}        
        function doRegResult() {

        	grid.checkAll(true);
            if (!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) {
            	alert(grid.validate().msg);
            	return false;
            }

			var selRows = grid.getSelRowValue();
			for( var i = 0, len = selRows.length; i < len; i++ ) {
				if (selRows[i].ANN_PASS_YN == '0' && selRows[i].ANN_FAIL_RMK == '') {
					alert('${BPX_220_001}');
					return;
				}

				if (selRows[i].ANN_PASS_YN == '1') {
					grid.setCellValue(i,'ANN_FAIL_RMK','');
				}
				
				
			}
            
            
            if (confirm('${msg.M0021}')) {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl + "participatingVendorSearch/doRegResult", function () {
                    alert(this.getResponseMessage());
                    doSearch();
                    opener.doSearch();
                });
            }
        }
        
        
        
    </script>

    <e:window id="BPX_220" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 3px 0 3px">
        <e:searchPanel id="form" title="${form_GENERAL_INFORMATION_N }" useTitleBar="false" columnCount="2" labelWidth="135">
            <e:row>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
                <e:field>
                    <e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${inputTextWidth}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text> / </e:text>
					<e:inputText id="RFX_CNT" style="ime-mode:inactive" name="RFX_CNT" value="${form.RFX_CNT}" width="30" maxLength="${form_RFX_CNT_M}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}"/>
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>

            </e:row>
            <e:row>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}"/>
                <e:field>
                    <e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="95%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
                </e:field>
            
                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
                <e:field>
                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='${form_RFX_TYPE_D }' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
                    </e:select>
                </e:field>            
            </e:row>


            <e:row>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenType }" width="${inputTextWidth}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
					<e:text> / </e:text>
                    <e:select id="SUBMIT_TYPE" onChange="clearTplNum" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="45%" disabled="true" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>
                
                
                <e:label for="PRC_STL_TYPE" title="${form_PRC_STL_TYPE_N}"/>
                <e:field>
                    <e:select id="PRC_STL_TYPE" name="PRC_STL_TYPE" value="${form.PRC_STL_TYPE}" options="${prcStlType }" width="${inputTextWidth}" disabled="${form_PRC_STL_TYPE_D}" readOnly="${form_PRC_STL_TYPE_RO}" required="${form_PRC_STL_TYPE_R}" placeHolder="" />
                    <e:text> / </e:text>
                    <e:select id="SETTLE_TYPE"  name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" options="${settleType}" width='45%' required='${form_SETTLE_TYPE_R }' readOnly='${form_SETTLE_TYPE_RO }' disabled='true' visible='${form_SETTLE_TYPE_V }' placeHolder='${placeHolder }' />
                </e:field>
                
            </e:row>

        </e:searchPanel>
        <e:buttonBar align="right">
<c:if test="${form.ANN_FLAG == '1' && form.PROGRESS_CD2 < '2400' && form.PROGRESS_CD2 > '2300' }">
			<e:button id="doRegResult" name="doRegResult" label="${doRegResult_N}" onClick="doRegResult" disabled="${doRegResult_D}" visible="${doRegResult_V}"/>
</c:if>
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }'/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>