<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/eversrm/purchase/prMgt/prReceipt/";

    function init() {
		grid = EVF.getComponent('grid');

		// 구매유형에서 "수선,제작" 제외하고 나머지 코드값은 Invisible
		EVF.C('PR_TYPE').removeOption('DC'); // 품의
		EVF.C('PR_TYPE').removeOption('ISP'); // 투자품의
		EVF.C('PR_TYPE').removeOption('SMT'); // 부자재
		EVF.C('PR_TYPE').removeOption('NORMAL'); // 부품
		EVF.C('PR_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PR_TYPE').removeOption('OMRO'); // 해외MRO
		grid.setProperty('panelVisible', ${panelVisible});
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

		// 구매진행상태에서 "구매요청중" 제외
		EVF.C('PROGRESS_CD').removeOption('1100'); // 구매요청중
        EVF.C('PROGRESS_CD').removeOption('6200'); // 입고완료
        EVF.C('PROGRESS_CD').removeOption('1200'); // 구매반송

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			onCellClick(celname, rowid);
		});




		grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
	          if(celname == 'PR_QT' || celname == 'LAST_UNIT_PRC') {
	            var cur = grid.getCellValue(rowid, 'CUR');
	            var price = everCurrency.getPrice(cur, grid.getCellValue(rowid, 'LAST_UNIT_PRC'));
	            var qty = everCurrency.getQty(cur, grid.getCellValue(rowid, 'PR_QT'));

	            grid.setCellValue(rowid, 'LAST_ITEM_AMT', everCurrency.getAmount(cur, price * qty));
	          }
	        });


    }

    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + 'BPRR_020/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }
	var selRow2;
    function onCellClick(strColumnKey, nRow) {
        selRow2 = nRow;

        if (strColumnKey == "PR_NUM") {
            everPopup.openPRDetailInformation(grid.getCellValue(nRow, "PR_NUM"));
        }

        if (strColumnKey == "ITEM_CD") {
        	var param = {
            	ITEM_CD: grid.getCellValue(nRow,"ITEM_CD")
            };

        	everPopup.openItemDetailInformation(param);
        }

        if (strColumnKey == "REC_VENDOR") {
            everPopup.openSupManagementPopup({
                VENDOR_CD: grid.getCellValue(nRow, "REC_VENDOR_CD")
            });
        }

        if (strColumnKey == "LAST_VENDOR") {
            var param = {
                buyerCd: grid.getCellValue(nRow, "BUYER_CD"),
                buyerReqCd: grid.getCellValue(nRow, "BUYER_REQ_CD"),
                purOrgCd: grid.getCellValue(nRow, "PUR_ORG_CD"),
                item_cd: grid.getCellValue(nRow, "ITEM_CD"),
                currentRow: nRow,
                callBackFunction: 'chooseVendorIssuing'
            };
            everPopup.openVendorIssuingPopup(param);
        }


        if (strColumnKey == "LAST_VENDOR_CD2") {
            var param = {
                    'callBackFunction': 'selectVendor'
                  };
            everPopup.openCommonPopup(param, "SP0025");
        }





    }

    function selectVendor(data) {
        grid.setCellValue(selRow2, "LAST_VENDOR_CD2", data.VENDOR_CD);
        grid.setCellValue(selRow2, "LAST_VENDOR_NM", data.VENDOR_NM);
      }




    function chooseVendorIssuing(data, nRow) {
        grid.setCellValue(nRow, "LAST_VENDOR_CD", data[0].VENDOR_CD);
        grid.setCellValue(nRow, "LAST_VENDOR", data[0].VENDOR_NM);
    }

    function selectRequestDept() {
        var param = {
            callBackFunction: "selectDept",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0002');
    }

    function selectDept(dataJsonArray) {
        EVF.getComponent('REQ_DEPT_NM').setValue(dataJsonArray.DEPT_NM);
    }

    function selectPurchaseDept() {
        var param = {
            callBackFunction: "selectPurDept",
            BUYER_CD: "${ses.companyCd}"
        };
        everPopup.openCommonPopup(param, 'SP0002');
    }

    function selectPurDept(dataJsonArray) {
        EVF.getComponent('CTRL_DEPT_NM').setValue(dataJsonArray.DEPT_NM);
    }

    function selectBuyer() {
        everPopup.openCommonPopup({
            callBackFunction: "selectUser"
        }, 'SP0040');
    }
    function selectUser(data) {
        EVF.getComponent("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
//        EVF.getComponent("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
    }
    function selectTransfer() {
    	// 데이터가 미존재 시 조회를 먼저한다.
        if(grid.getRowCount() == 0) {
            alert("${BPRR_020_0009}"); // 구매담당자이관을 지정하기 위해 조회 후 데이터를 선택하여 주시기 바랍니다.
            doSearch();
            return;
        }

        // 데이터 선택 여부
        var rowIdx = grid.jsonToArray(grid.getSelRowId()).value;
        if (rowIdx.length == 0) {
            alert("${msg.M0004}");
            return;
        }

        // 구매그룹 동일여부 판단
        /* 제외(2016.01.13)
        var ctrl_cd;
        for(idx in rowIdx) {
            var ctrlValue = grid.getRowValue(rowIdx[idx]);
            if(grid.getRowValue(rowIdx[0]).CTRL_CD != ctrlValue.CTRL_CD) {
                alert("${BPRR_020_0010}"); // 동일한 구매그룹을 선택 후 구매담당자이관을 지정하시기 바랍니다.
                return;
            } else {
                ctrl_cd = ctrlValue.CTRL_CD;
            }
        }*/

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        /* 구매담당자 이관 : 접수 완료건에 대해서만 이관 가능함 */
        for (var i = 0;i < selRowId.length;i++) {
            if ('${ses.userId}' != grid.getCellValue(selRowId[i],'CTRL_USER_ID')) {
                return alert("${msg.M0008}");
            }

            if (parseInt(grid.getCellValue(selRowId[i],'PROGRESS_CD')) != 2200) {
                return alert("${msg.M0044}");
            }
        }

		// 동일 플랜트에 대해 담당자 지정
		var plantCd;
		for (idx in rowIdx) {
			var plantCdValue = grid.getRowValue(rowIdx[idx]);

			if(grid.getRowValue(rowIdx[0]).PLANT_CD != plantCdValue.PLANT_CD) {
				alert("${BPRR_020_0010}"); // 동일한 플랜트 선택 후 구매담당자를 지정하시기 바랍니다.
				return;
			} else {
				plantCd = plantCdValue.PLANT_CD;
			}
		}

        var param = {
            'callBackFunction': 'selectUserTransfer',
			'PLANT_CD': plantCd
        };
        everPopup.openCommonPopup(param, 'SP0040');
    }
    function selectUserTransfer(data) {
        EVF.getComponent("BUYER_NM").setValue(data.CTRL_USER_NM);
        EVF.getComponent("BUYER_CD").setValue(data.CTRL_USER_ID);
        //EVF.getComponent("CTRL_CD").setValue(data.CTRL_CD);
        //EVF.getComponent("PUR_ORG_CD").setValue(data.PUR_ORG_CD);
    }
    function doTransfer() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        /* 구매담당자 이관 : 자신이 접수한 건에 한해 가능함 */
        for(var i = 0;i < selRowId.length;i++) {
            if ('${ses.userId}' != grid.getCellValue(selRowId[i],'CTRL_USER_ID')) {
                return alert("${msg.M0008}");
            }

            if (parseInt(grid.getCellValue(selRowId[i],'PROGRESS_CD')) != 2200) {
                return alert("${msg.M0044}");
            }
        }

        if (EVF.getComponent("BUYER_CD").getValue() == "") {
        	return alert("${BPRR_020_0001}");
        }

        if (!confirm("${msg.M0082}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
    	store.load(baseUrl + 'BPRR_020/doTransfer', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
    }
    function doReceipt() {
		if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

        for(var i = 0;i < selRowId.length;i++) {
            if (grid.getCellValue(selRowId[i],'CTRL_USER_ID') != '' && '${ses.userId}' != grid.getCellValue(selRowId[i],'CTRL_USER_ID')) {
                return alert("${msg.M0008}");
            }
        	if (parseInt(grid.getCellValue(selRowId[i], 'STATUS_HIDDEN')) == 200) {
                return alert("${BPRR_020_0006}");
            }
            if (parseInt(grid.getCellValue(selRowId[i], 'PROGRESS_CD')) == 2200) {
                return alert("${msg.M0046}");
            }
            if (parseInt(grid.getCellValue(selRowId[i], 'PROGRESS_CD')) > 2100) {
                return alert("${msg.M0044}");
            }
        }

        if (!confirm("${msg.M0066}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
    	store.load(baseUrl + 'BPRR_020/doReceipt', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
    }
    function doReturn() {
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        if (selRowId.length == 0) {
            alert("${msg.M0004}");
            return;
        }

        <%--
        for(var i = 0;i < selRowId.length;i++) {
            if ('${ses.userId}' != grid.getCellValue(selRowId[i],'CTRL_USER_ID')) {
                return alert("${msg.M0008}");
            }
            if (parseInt(grid.getCellValue(selRowId[i], 'PROGRESS_CD')) != 2200) {
//                return alert("${BPRR_020_0011}");
            }
        }
        --%>

        if (!confirm("${msg.M8888}" + "\n" + "${BPRR_020_0008}")) return;

        var param = {
				  'havePermission' : true
				, 'callBackFunction' : 'setReturnTextContents'
                , 'detailView': false
			};

		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
    }

    function setReturnTextContents(contents) {
    	EVF.C('REJECT_RMK').setValue(contents);

        var store = new EVF.Store();
        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
    	store.load(baseUrl + 'BPRR_020/doReturn', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
    }

    function doRequest(_rfxType) {
        var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
        if(selRowIds.length == 0) {
            return alert("${msg.M0004}");
        }

        for (var i in selRowIds) {
            if (selRowIds.hasOwnProperty(i)) {
                var gridData1 = grid.getRowValue(selRowIds[i]);

                if (gridData1.PROGRESS_CD != '2200') {
                	alert('${BPRR_020_0013}');
                	return;
                }
                if ('${ses.userId}' != gridData1.CTRL_USER_ID) {
                    return alert("${msg.M0008}");
                }
             	// 입찰/견적은 동일 구매유형, 동일 통화에 대해서만 가능함
                if (grid.getRowValue(selRowIds[0]).PR_TYPE != gridData1.PR_TYPE || grid.getRowValue(selRowIds[0]).CUR != gridData1.CUR) {
                    alert("${BPRR_020_0012}");
                    return;
                }
            }
        }

        var params = {
            'prList': JSON.stringify(grid.getSelRowValue()),
            'rfxType': _rfxType,
            'baseDataType': 'PR',
            'callBackFunction': 'doSearch',
            'detailView': false,
            'screenFlag': '0',
            'purcharseType': grid.getRowValue(selRowIds[0]).PR_TYPE,
            'cur': grid.getRowValue(selRowIds[0]).CUR
        };

        everPopup.openPopupByScreenId("BSOX_010", 1300, 1000, params);
    }


    function doJongGa() {

    	var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
        if(selRowIds.length == 0) {
            return alert("${msg.M0004}");
        }

		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}
		var screenId = 'BPRR_020JONGGA1'; // 있을경우
        for (var i in selRowIds) {
                var gridData1 = grid.getRowValue(selRowIds[i]);
                if (gridData1.PROGRESS_CD != '2200') {
                	alert('${BPRR_020_0013}');
                	return;
                }
                if ('${ses.userId}' != gridData1.CTRL_USER_ID) {
                    return alert("${msg.M0008}");
                }

                if (gridData1.ITEM_CD == '') {
                	screenId = 'BPRR_020JONGGA2';/// 품목코드가 없을경우
                }
        }




        var params = {
            'prList': JSON.stringify(grid.getSelRowValue()),
            'detailView': false
        };


        everPopup.openPopupByScreenId(screenId, 1000, 600, params);

    }


    function doRFQ() {
        doRequest('RFQ');
    }

    function doRFP() {
        doRequest('RFP');
    }

    function doSearchCtrlCd() {
        // 플랜트 코드 존재 시 조회, 미 존재 시 조회
        if(EVF.getComponent("PLANT_CD").getValue() == "") {
            var param = {
                'callBackFunction': 'ctrlCodeCallback',
                'detailView': false,
                'CTRL_TYPE' : 'NPUR'
            };
            everPopup.openCommonPopup(param, "SP0038");
        } else {
            var param = {
                'callBackFunction': 'ctrlCodeCallback',
                'detailView': false,
                'PLANT_CD': EVF.getComponent("PLANT_CD").getValue(),
                'CTRL_TYPE' : 'NPUR'
            };
            everPopup.openCommonPopup(param, "SP0037");
        }
    }

    function ctrlCodeCallback(data) {
        EVF.getComponent("CTRL_NM").setValue(data.CTRL_NM);
        EVF.getComponent("CTRL_CD").setValue(data.CTRL_CD);
    }

    function doReqSearchUser() {
        everPopup.openCommonPopup({
            callBackFunction: "selectReqUser"
        }, 'SP0039');
    }

    function selectReqUser(data) {
        EVF.getComponent("REQ_USER_NM").setValue(data.REQ_USER_NM);
        EVF.getComponent("REQ_USER_ID").setValue(data.REQ_USER_ID);
    }

    function doSendPo() {

        var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
        if(selRowIds.length == 0) {
          return alert("${msg.M0004}");
        }

        // 요청품의업체, 통화, 요청품의수량, 요충품의단가, 단위, 요청품의금액
        // Grid Validation Check
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        for (var i in selRowIds) {
          if (selRowIds.hasOwnProperty(i)) {
            var gridData = grid.getRowValue(selRowIds[i]);

            if ('${ses.userId}' != gridData.CTRL_USER_ID) {
              return alert("${msg.M0008}");
            }

            if (everString.isEmptyNum(gridData.LAST_UNIT_PRC)  ) {
            	alert("${BPRR_020_0102}");
            	return;
            }
            if (everString.isEmptyNum(gridData.LAST_ITEM_AMT)    ) {
            	alert("${BPRR_020_0104}");
            	return;
            }
            if (everString.isEmptyNum(gridData.PR_QT)  ) {
            	alert("${BPRR_020_0101}");
            	return;
            }
            if ( everString.isEmpty(gridData.LAST_VENDOR_CD2)  ) {
            	alert("${BPRR_020_0100}");
            	return;
            }
          }
        }

        var selectedRow = grid.getSelRowValue()[0];
        var progressCode = selectedRow['PROGRESS_CD'];

        if (progressCode == '') {
          return alert("${msg.M0044}");
        }
        <%--
        else {
          if (parseInt(progressCode) >= 2300) {
            return alert("${msg.M0044}");
          }
        }
        --%>

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        if (!confirm("${BPRR_020_0099}")) return;
        store.load(baseUrl + 'BPRR_020/doOrderWait', function() {
          alert(this.getResponseMessage());

          doSearch();
        });
      }

    function validColRequired(flag) {
        grid.setColRequired("LAST_VENDOR_CD2", flag);
        grid.setColRequired("PR_QT", flag);
        grid.setColRequired("CUR", flag);
        grid.setColRequired("LAST_UNIT_PRC", flag);
        grid.setColRequired("LAST_ITEM_AMT", flag);
      }

    function doContractWait() {

        var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
        if(selRowIds.length == 0) {
          return alert("${msg.M0004}");
        }

        // 요청품의업체, 통화, 요청품의수량, 요충품의단가, 단위, 요청품의금액
        // Grid Validation Check
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        for (var i in selRowIds) {
          if (selRowIds.hasOwnProperty(i)) {
            var gridData = grid.getRowValue(selRowIds[i]);

            if ('${ses.userId}' != gridData.CTRL_USER_ID) {
              return alert("${msg.M0008}");
            }



            if (everString.isEmptyNum(gridData.LAST_UNIT_PRC)  ) {
            	alert("${BPRR_020_0102}");

            	return;
            }
            if (everString.isEmptyNum(gridData.LAST_ITEM_AMT)    ) {
            	alert("${BPRR_020_0104}");

            	return;
            }


            if (everString.isEmptyNum(gridData.PR_QT)  ) {
            	alert("${BPRR_020_0101}");
            	return;
            }

            if ( everString.isEmpty(gridData.LAST_VENDOR_CD2)  ) {
            	alert("${BPRR_020_0100}");
            	return;
            }

          }
        }

        var selectedRow = grid.getSelRowValue()[0];
        var progressCode = selectedRow['PROGRESS_CD'];

        if (progressCode == '') {
          return alert("${msg.M0044}");
        }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        if (!confirm("${BPRR_020_0105}")) return;
        store.load(baseUrl + 'BPRR_020/doContractWait', function() {
          alert(this.getResponseMessage());
          doSearch();
        });
      }


</script>
    <e:window id="BPRR_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" useTitleBar="false" onEnter="doSearch">
        	<e:inputHidden id="REJECT_RMK" name="REJECT_RMK"/>
        	<e:row>
        		<%-- 구매요청일자 --%>
        		<e:label for="REQ_DATE_FROM" title="${form_REQ_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="REQ_DATE_FROM" toDate="REQ_DATE_TO" name="REQ_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_FROM_R}" disabled="${form_REQ_DATE_FROM_D}" readOnly="${form_REQ_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="REQ_DATE_TO" fromDate="REQ_DATE_FROM" name="REQ_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REQ_DATE_TO_R}" disabled="${form_REQ_DATE_TO_D}" readOnly="${form_REQ_DATE_TO_RO}" />
				</e:field>
                <%--플랜트--%>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
                </e:field>
				<%-- 구매유형 --%>
                <e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
                <e:field>
                    <e:select id="PR_TYPE" name="PR_TYPE" value="${form.PR_TYPE}" options="${prTypeOptions}" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
                </e:field>
			</e:row>
			<e:row>
                <%-- 요청번호 --%>
				<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
				<e:field>
					<e:inputText id="PR_NUM" style="ime-mode:inactive" name="PR_NUM" value="${form.PR_NUM}" width="${inputTextWidth }" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}"/>
				</e:field>
                <%-- 요청명 --%>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
                <e:field>
                    <e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="98%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
                </e:field>
				<%--요청자--%>
				<e:label for="REQ_USER_ID" title="${form_REQ_USER_ID_N}"/>
				<e:field>
					<e:search id="REQ_USER_ID" style="ime-mode:inactive" name="REQ_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_REQ_USER_ID_M}" onIconClick="${form_REQ_USER_ID_RO ? 'everCommon.blank' : 'doReqSearchUser'}" disabled="${form_REQ_USER_ID_D}" readOnly="${form_REQ_USER_ID_RO}" required="${form_REQ_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="REQ_USER_NM" style="${imeMode}" name="REQ_USER_NM" value="${form.REQ_USER_NM}" width="${inputTextWidth }" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}"/>
				</e:field>
			</e:row>
			<e:row>
                <%--구매그룹--%>
				<e:label for="CTRL_CD" title="${form_CTRL_CD_N}"/>
				<e:field>
					<e:search id="CTRL_CD" style="ime-mode:inactive" name="CTRL_CD" value="" width="${inputTextWidth}" maxLength="${form_CTRL_CD_M}" onIconClick="${form_CTRL_CD_RO ? 'everCommon.blank' : 'doSearchCtrlCd'}" disabled="${form_CTRL_CD_D}" readOnly="${form_CTRL_CD_RO}" required="${form_CTRL_CD_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="CTRL_NM" style="${imeMode}" name="CTRL_NM" value="${form.CTRL_NM}" width="${inputTextWidth}" maxLength="${form_CTRL_NM_M}" disabled="${form_CTRL_NM_D}" readOnly="${form_CTRL_NM_RO}" required="${form_CTRL_NM_R}"/>
				</e:field>
				<%-- 구매담당자 --%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_NM" style="ime-mode:inactive" name="CTRL_USER_NM" value="${ses.userNm }" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="${form_CTRL_USER_NM_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
                    <e:text>미지정 제외</e:text>
                    <e:check id="PIC_FLAG" name="PIC_FLAG" value="Y" />
				</e:field>
                <%--접수상태--%>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<!--
			<e:panel id="yyyy" name="yyyy">
				<e:text>&nbsp;${form_CNG_CTRL_NM_N } : </e:text>
				<e:search id="CNG_CTRL_NM" style="${imeMode}" name="CNG_CTRL_NM" value="" width="${inputTextWidth}" maxLength="${form_CNG_CTRL_NM_M}" onIconClick="${form_CNG_CTRL_NM_RO ? 'everCommon.blank' : 'selectTransCtrlCd'}" disabled="${form_CNG_CTRL_NM_D}" readOnly="${form_CNG_CTRL_NM_RO}" required="${form_CNG_CTRL_NM_R}" />
				<e:inputHidden id="CNG_CTRL_CD" name="CNG_CTRL_CD"/>
				<e:text>&nbsp;</e:text>
				<e:button id="doTransCtrlCd" name="doTransCtrlCd" label="${doTransfer_N}" onClick="doTransferCtrlCd" disabled="${doTransfer_D}" visible="${doTransfer_V}"/>
			</e:panel>
			-->
			<e:panel id="xxxx" name="xxxx">
				<e:text>&nbsp;${form_BUYER_CD_N } : </e:text>
				<e:search id="BUYER_NM"  name="BUYER_NM" height="30" value="" width="${inputTextWidth}" maxLength="${form_BUYER_CD_M}" onIconClick="selectTransfer" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
				<e:inputHidden id="BUYER_CD" name="BUYER_CD"/>
				<e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD"/>
				<e:text>&nbsp;</e:text>
				<e:button id="doTransfer" name="doTransfer" label="${doTransfer_N}" onClick="doTransfer" disabled="${doTransfer_D}" visible="${doTransfer_V}"/>
			</e:panel>

			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doReceipt" name="doReceipt" label="${doReceipt_N}" onClick="doReceipt" disabled="${doReceipt_D}" visible="${doReceipt_V}"/>
			<e:button id="doReturn" name="doReturn" label="${doReturn_N}" onClick="doReturn" disabled="${doReturn_D}" visible="${doReturn_V}"/>
			<e:button id="doRFQ" name="doRFQ" label="${doRFQ_N}" onClick="doRFQ" disabled="${doRFQ_D}" visible="${doRFQ_V}"/>
			<e:button id="doJongGa" name="doJongGa" label="${doJongGa_N}" onClick="doJongGa" disabled="${doJongGa_D}" visible="${doJongGa_V}"/>
			<e:button id="doSendPo" name="doSendPo" label="${doSendPo_N}" onClick="doSendPo" disabled="${doSendPo_D}" visible="${doSendPo_V}"/>

			<e:button id="doContractWait" name="doContractWait" label="${doContractWait_N}" onClick="doContractWait" disabled="${doContractWait_D}" visible="${doContractWait_V}"/>

			<%--
			<e:button id="doAuction" name="doAuction" label="${doAuction_N}" onClick="doAuction" disabled="${doAuction_D}" visible="${doAuction_V}"/>
			<e:button id="doLastPrice" name="doLastPrice" label="${doLastPrice_N}" onClick="doLastPrice" disabled="${doLastPrice_D}" visible="${doLastPrice_V}"/>
			--%>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>

</e:ui>