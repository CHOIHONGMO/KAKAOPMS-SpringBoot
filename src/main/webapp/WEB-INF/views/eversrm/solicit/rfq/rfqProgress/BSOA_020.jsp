<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/rfqProgress/";

    function init() {
        grid = EVF.C("grid");

		EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PURCHASE_TYPE').removeOption('OMRO'); // 해외MRO
		grid.setProperty('panelVisible', ${panelVisible});
        grid.setProperty('singleSelect', true);
        grid.setColEllipsis (['FORCE_CLOSE_RMK'], true);



        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            if (celName == "RFX_NUM") {
                var param = {
                    gateCd: grid.getCellValue(rowId, "GATE_CD"),
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxType: grid.getCellValue(rowId, "RFX_TYPE"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openRfxDetailInformation(param);
            } else if (celName == "VENDOR") {
                var param = {
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxSubject: grid.getCellValue(rowId, "RFX_SUBJECT"),
                    popupFlag: true,
                    detailView: false
                };
                everPopup.openPopupByScreenId('BPX_220', 850, 600, param);
            } else if (celName == "FAIL_BID_RMK") {
        	    var param = {
      				  havePermission : false
      				, callBackFunction : 'setTextContents'
      				, TEXT_CONTENTS : grid.getCellValue(rowId, "FAIL_BID_RMK")
      			};
    	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }
        });

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

        EVF.C('RFQ_DATE_COMBO').setValue('R');
    }

    function doSearch() {
        if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }')) {
            alert('${msg.M0073}');
            return;
        }
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + "BSOA_020/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

    function doDeptSearch() {
        var param = {
            callBackFunction: "selectDeptSearch",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, "SP0002");
    }

    function selectDeptSearch(data) {
        EVF.C("DEPT_NM").setValue(data.DEPT_NM);
    }

    function doUserSearch() {
        var param = {
            callBackFunction: "selectUser",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0040');
    }
    function selectUser(data) {
        EVF.C("USER_NM").setValue(data.CTRL_USER_NM);
    }
    function chCtrlNm() {
        var param = {
            callBackFunction: "setCtrlNm",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0040');
    }
    function setCtrlNm(data) {
        EVF.C("USER_NM").setValue(data.CTRL_USER_NM);
        EVF.C("USER_ID").setValue(data.CTRL_USER_ID);
    }
    function doUserChangedSearch() {
        var param = {
            callBackFunction: "selectUserChanged",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0040');
    }
    function selectUserChanged(data) {
        EVF.C("USER_NM_CHANGED").setValue(data.CTRL_USER_NM);
        EVF.C("USER_ID_CHANGED").setValue(data.CTRL_USER_ID);
        EVF.C("PUR_ORG_CD_CHANGED").setValue(data.PUR_ORG_CD);
    }
    function doBuyerChange() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

        if (EVF.C('USER_ID_CHANGED').getValue() == '') return alert("${BSOA_020_SELECT}");
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

//        var selectedRow = gridUtil.getJSONDataOneOnly(grid, 'SELECTED');
        if(!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        var selectedRow = grid.getSelRowValue()[0];
        if ('${ses.userId}' != selectedRow['CTRL_USER_ID']) return alert('${msg.M0008}');
        if (!confirm("${msg.M0082}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.setParameter('USER_ID_CHANGED', EVF.C('USER_ID_CHANGED').getValue());
        store.setParameter('PUR_ORG_CD_CHANGED', EVF.C('PUR_ORG_CD_CHANGED').getValue());
        store.load(baseUrl + "BSOA_020/doChange", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    //변경
    function doChange() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];

        if ('${ses.userId}' != selectedRow['CTRL_USER_ID']) return alert('${msg.M0008}');
        var progressCode = parseInt(selectedRow['PROGRESS_CD']);
        var vCnt = parseInt(selectedRow['VCNT']);
        //if ((progressCode >= 2400 && selectedRow['SIGN_STATUS'] == "P") || progressCode === 2550) return alert("${msg.M0044}");

        //업체가 견적서생성하면(vCnt가 0보다 커짐) ==> 변경 못하도록 처리
//        if ((progressCode >= 2330 && vCnt > 0) || progressCode === 2550) return alert("${msg.M0044}");

        //if ((progressCode >= 2330 ) || progressCode === 2550 || parseInt(selectedRow.PROGRESS_CD) == 1300) return alert("${msg.M0044}");

        if (parseInt(selectedRow.PROGRESS_CD) != 2300 && vCnt != 0) return alert("${msg.M0044}");

        if (parseInt(selectedRow.PROGRESS_CD) == 1300) return alert("${msg.M0044}");



        var param = {
            gateCd: selectedRow['GATE_CD'],
            rfxNum: selectedRow['RFX_NUM'],
            rfxCnt: selectedRow['RFX_CNT'],
            rfxType: selectedRow['RFX_TYPE'],
            baseDataType: 'RFX',
            detailView: false,
            callBackFunction: "doSearch"
        };
        everPopup.openPopupByScreenId('BSOX_010', 1250, 800, param);
    }

    //마감일 연장
    function doExDeadline() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];

        if (!selectedRow) return alert("${msg.M0004}");
        if ('${ses.userId}' != selectedRow.CTRL_USER_ID) return alert('${msg.M0008}');
//        if (parseInt(selectedRow.PROGRESS_CD) >= 2500) return alert("${msg.M0044}");

        if (parseInt(selectedRow.PROGRESS_CD) >= 2500 || parseInt(selectedRow.PROGRESS_CD) == 1300 || parseInt(selectedRow.PROGRESS_CD) == 2300 ) return alert("${msg.M0044}");

        if ( selectedRow.OPEN_YN != 'X' ) return alert("${msg.M0044}");

        var params = {
            gateCd: selectedRow['GATE_CD'],
            rfxNum: selectedRow['RFX_NUM'],
            rfxCnt: selectedRow['RFX_CNT'],
            rfxType: selectedRow['RFX_TYPE'],
            popupFlag: true,
            callBackFunction: "doSearch"
            //detailView : true
        };
        everPopup.openRfqExtendDeadline(params);
    }

    //마감
    function doClose() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];
        if ('${ses.userId}' != selectedRow.CTRL_USER_ID) return alert('${msg.M0008}');
        if (parseInt(selectedRow.PROGRESS_CD) >= 2400 || parseInt(selectedRow.PROGRESS_CD) == 1300 || parseInt(selectedRow.PROGRESS_CD) == 2300) return alert("${msg.M0044}");
        var vendor = selectedRow.VENDOR+'   ';
        var kkk = vendor.substring(0,1);

        if(!confirm((kkk == '0' ? '${BSOA_020_0005} ': '')+'${BSOA_020_0001}')) { return; }

        var param = {
				  havePermission : false
				, callBackFunction : 'doClose2'
				, TEXT_CONTENTS : ''
				, detailView : false
			};
	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
    }



    function doClose2(texts) {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('FORCE_CLOSE_RMK',texts);

        store.getGridData(grid, 'sel');
        store.load(baseUrl+'BSOA_020/doCloseRfq', function() {
            alert('${BSOA_020_0002}');
            doSearch();
        });
    }

    function doPriceInput() {

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];
        if ('${ses.userId}' != selectedRow.CTRL_USER_ID) return alert('${msg.M0008}');
        if (parseInt(selectedRow.PROGRESS_CD) >= 2500) return alert("${msg.M0044}");

        var param = {
            gateCd: selectedRow['GATE_CD'],
            rfxNum: selectedRow['RFX_NUM'],
            rfxCnt: selectedRow['RFX_CNT'],
            rfxType: selectedRow['RFX_TYPE'],
            popupFlag: true,
            detailView: false,
            callBackFunction: "doSearch"
        };
        everPopup.openPopupByScreenId('SPX_020', 800, 800, param);
    }



    function doPubChange() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}
        if(!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        var selectedRow = grid.getSelRowValue()[0];
        if ('${ses.superUserFlag}' != '1') {
        	return alert('${msg.M0008}');
        }

        /* 공인인증서 사용여부는 진행상태가 "작성중, 입찰진행중"인 경우에만 변경 가능함 */
        if (selectedRow.PROGRESS_CD != 2300 && selectedRow.PROGRESS_CD != 2330 && selectedRow.PROGRESS_CD != 2350  ) {
        	alert('${BSOA_020_0004}');

        	return;
        }


        if (!confirm("${BSOA_020_0003}")) return;
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.setParameter('PUB_CERT_YN', EVF.C('PUB_CERT_YN').getValue());
        store.load(baseUrl + "BSOA_020/doPubChange", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }


    function doEval() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

		var valid = grid.validate()
			, selRows = grid.getSelRowValue();

		for( var i = 0, len = selRows.length; i < len; i++ ) {
	        if (parseInt(selRows[i].PROGRESS_CD) == 2500 || parseInt(selRows[i].PROGRESS_CD) == 2300 || parseInt(selRows[i].PROGRESS_CD) == 1300) return alert("${msg.M0044}");

			if (selRows[i].OPEN_USER_ID != "${ses.userId}") return alert("${msg.M0008}");
			if (selRows[i].EVAL_STATUS !='Y') {
				alert('${BSOA_020_006}');
				return;
			}
		}

		if (!confirm("${BSOA_020_007}")) return;
        var param = {
        		RFX_NUM: selRows[0]['RFX_NUM'],
        		RFX_CNT: selRows[0]['RFX_CNT'],
        		detailView: false
            };
            everPopup.openPopupByScreenId('BSOX_231', 1250, 800, param);
    }

    function doModifyStartDate() {


		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];

        if (!selectedRow) return alert("${msg.M0004}");
        if ('${ses.userId}' != selectedRow.CTRL_USER_ID) return alert('${msg.M0008}');

        var vCnt = parseInt(selectedRow['VCNT']);
		if (vCnt != 0 ) {
			alert('${BSOA_020_008}');
			return;
		}


        if (parseInt(selectedRow.PROGRESS_CD) >= 2500 || parseInt(selectedRow.PROGRESS_CD) == 1300 || parseInt(selectedRow.PROGRESS_CD) == 2300) return alert("${msg.M0044}");

        var params = {
            gateCd: selectedRow['GATE_CD'],
            rfxNum: selectedRow['RFX_NUM'],
            rfxCnt: selectedRow['RFX_CNT'],
            rfxType: selectedRow['RFX_TYPE'],
            popupFlag: true,
            callBackFunction: "doSearch",
            detailView : false
        };
        everPopup.openPopupByScreenId('BSOA_031', 600, 200, params);

    }

</script>
    <e:window id="BSOA_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="REG_DATE">
                    <e:select id='RFQ_DATE_COMBO' name="RFQ_DATE_COMBO" options="${rfqDateCombo}" width='100' required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" usePlaceHolder="false" />
                </e:label>
                <e:field>
                    <e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>

                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
                <e:field>
                    <e:inputText id="RFX_NUM" style='ime-mode:inactive' name="RFX_NUM" value="${form.RFX_NUM}" width="35%"  maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
		            <e:text>&nbsp;</e:text>
                    <e:inputText id="RFX_SUBJECT" style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
                </e:field>
			</e:row>
            <e:row>
                <e:label for="SUBMIT_TYPE" title="${form_SUBMIT_TYPE_N}"/>
                <e:field>
                    <e:select id="SUBMIT_TYPE" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="${inputTextWidth}" disabled="${form_SUBMIT_TYPE_D}" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>
                <e:inputHidden id="DEPT_NM" name="DEPT_NM" />
				<e:label for="USER_ID" title="${form_USER_ID_N}"/>
				<e:field>
					<e:search id="USER_ID" style="ime-mode:inactive" name="USER_ID" value="${ses.userId}" width="${inputTextWidth}" maxLength="${form_USER_ID_M}" onIconClick="${form_USER_ID_RO ? 'everCommon.blank' : 'chCtrlNm'}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" value="${ses.userNm}" width="${inputTextWidth }" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}"/>
				</e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${refPROGRESS_CD}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
            </e:row>

        </e:searchPanel>
        <e:buttonBar align="left">
        	<e:text>&nbsp;&nbsp;${form_USER_NM_CHANGED_N } : &nbsp;</e:text>
            <e:search id='USER_NM_CHANGED' name="USER_NM_CHANGED" width='120' required='${form_USER_NM_CHANGED_R }' maxLength="${form_USER_NM_CHANGED_M}" readOnly='${form_USER_NM_CHANGED_RO }' disabled='${form_USER_NM_CHANGED_D }' visible='${form_USER_NM_CHANGED_V }' onIconClick="doUserChangedSearch" data="USER_ID_CHANGED" />
            <e:text>&nbsp;</e:text>
            <e:button label='${doBuyerChange_N }' id='doBuyerChange' onClick='doBuyerChange' disabled='${doBuyerChange_D }' visible='${doBuyerChange_V }' data='${doBuyerChange_A }' align="left"  />
            <e:inputText id='USER_ID_CHANGED' name="USER_ID_CHANGED" width='0' maxLength='${form_USER_ID_CHANGED_M }' required='${form_USER_ID_CHANGED_R }' readOnly='${form_USER_ID_CHANGED_RO }' disabled='${form_USER_ID_CHANGED_D }' visible='${form_USER_ID_CHANGED_V }'/>
            <e:inputHidden id='PUR_ORG_CD_CHANGED' name="PUR_ORG_CD_CHANGED" />

			<c:if test="${ses.superUserFlag == '1'}">
	            <e:text>${form_PUB_CERT_YN_N }</e:text>
	            <e:select id="PUB_CERT_YN" name="PUB_CERT_YN" value="${form.PUB_CERT_YN}" options="${pubCertYnOptions}" width="100" disabled="${form_PUB_CERT_YN_D}" readOnly="${form_PUB_CERT_YN_RO}" required="${form_PUB_CERT_YN_R}" placeHolder="" />
	            <e:text>&nbsp;</e:text>
	            <e:button id="doPubChange" name="doPubChange" label="${doPubChange_N}" onClick="doPubChange" disabled="${doPubChange_D}" visible="${doPubChange_V}"/>
			</c:if>

            <%--<e:button label='${doPriceInput_N }' id='doPriceInput' onClick='doPriceInput' disabled='${doPriceInput_D }' visible='${doPriceInput_V }' data='${doPriceInput_A }' align="right" />--%>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" align="right" />
            <e:button label='${doExDeadline_N }' id='doExDeadline' onClick='doExDeadline' disabled='${doExDeadline_D }' visible='${doExDeadline_V }' data='${doExDeadline_A }' align="right" />
			<e:button id="doModifyStartDate" name="doModifyStartDate" label="${doModifyStartDate_N}" onClick="doModifyStartDate" disabled="${doModifyStartDate_D}" visible="${doModifyStartDate_V}" align="right"/>
			<e:button id="doEval" name="doEval" label="${doEval_N}" onClick="doEval" disabled="${doEval_D}" visible="${doEval_V}" align="right"/>
            <e:button label='${doChange_N }' id='doChange' onClick='doChange' disabled='${doChange_D }' visible='${doChange_V }' data='${doChange_A }' align="right" />
            <e:button label="${doSearch_N }" id="doSearch" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V }" data="${doSearch_A }" align="right" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>