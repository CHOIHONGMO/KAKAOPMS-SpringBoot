<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>

<%
  	String devFlag = PropertiesManager.getString("eversrm.system.developmentFlag");
	String gwUrl = "";
	String gwLinkUrl = "";
	if ("true".equals(devFlag)) {
		gwUrl = PropertiesManager.getString("gw.dev.url");
		gwLinkUrl = PropertiesManager.getString("gw.link.dev.url");
	} else {
		gwUrl = PropertiesManager.getString("gw.real.url");
		gwLinkUrl = PropertiesManager.getString("gw.link.real.url");
	}
  	String gwParam = PropertiesManager.getString("gw.param");
%>

<c:set var="devFlag" value="<%=devFlag%>" />
<c:set var="gwUrl" value="<%=gwUrl%>" />
<c:set var="gwParam" value="<%=gwParam%>" />
<c:set var="gwLinkUrl" value="<%=gwLinkUrl%>" />
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    var gwdoc;
	var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {

        gridV = EVF.C("gridV");
        gridI = EVF.C("gridI");
        //gridV.setProperty('shrinkToFit', true);
        gwdoc =  EVF.C("gwdoc");

        gridV.setProperty('panelVisible', ${panelVisible});
        gridI.setProperty('panelVisible', ${panelVisible});
        gwdoc.addRowEvent(function() {
            gwdoc.addRow();
        });

        gwdoc.delRowEvent(function() {
            gwdoc.delRow();
        });

        gridI.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }I",
            excelOptions : {
                 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        gridV.excelExportEvent({
            allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }V",
            excelOptions : {
                 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
                ,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
                ,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
                ,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        });

        var purchase_type = EVF.getComponent('PURCHASE_TYPE').getValue();
        gridI.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	if (celName == "VENDOR_CD") {
        		var params = {
	                VENDOR_CD: gridI.getCellValue(rowId, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }
        	else if (celName == "RFX_NUM") {
				if (gridI.getCellValue(rowId, "RFX_NUM") == '') {
					return;
				}
                var param = {
                    gateCd: gridI.getCellValue(rowId, "GATE_CD"),
                    rfxNum: gridI.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: gridI.getCellValue(rowId, "RFX_CNT"),
                    rfxType: gridI.getCellValue(rowId, "RFX_TYPE"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openRfxDetailInformation(param);
            }
            else if (celName == "QTA_NUM") {
				if (gridI.getCellValue(rowId, "QTA_NUM") == '') {
					return;
				}
                var param = {
                    gateCd: gridI.getCellValue(rowId, "GATE_CD"),
                    qtaNum: gridI.getCellValue(rowId, "QTA_NUM"),
                    vendorCd: gridI.getCellValue(rowId, "VENDOR_CD"),
                    popupFlag: true,
                    detailView: true,
                    "isPrefferedBidder": false,
    	            "buttonStatus" : "N"
                };
    		    everPopup.openPopupByScreenId('DH2140', 1000, 800, param);
                //everPopup.openQtaDetailInformation(param);
            }
        	else if (celName === 'COST_ITEM_NEED') {
        		var costNeed = gridI.getCellValue(rowId, "COST_ITEM_NEED");

        		if(costNeed == 'Yes'){
        			var itemC = gridI.getCellValue(rowId, 'ITEM_CLASS_CD');

                	if( itemC == 'IMPORT' || itemC == 'SPEC' || itemC == 'ISP' || 1 == 1)
                	{
                		turl = '/eversrm/solicit/rfq/DH2150/view';
                		var param = {
                			flag: itemC,
                			rowid: rowId,
                			COST_NUM: gridI.getCellValue(rowId, 'COST_NUM'),
                			COST_CD: '',

                    		ITEM_CD : gridI.getCellValue(rowId, 'ITEM_CD'),
                    		ITEM_DESC : gridI.getCellValue(rowId, 'ITEM_DESC'),
                    		ITEM_SPEC : gridI.getCellValue(rowId, 'ITEM_SPEC'),
                    		RFX_QT : gridI.getCellValue(rowId, 'EXEC_QT'),


                			detailView: 'true',
                            callBackFunction: 'setCostItemNeed',
                            url: turl,
                            "buttonStatus": 'N'
                        };
                        everPopup.openCostItemNeed(param);
                	}
        		}
            } else if (celName == "ITEM_CD") {
				if (gridI.getCellValue(rowId, "ITEM_CD") == '') {
					return;
				}
	            var param = {
		        	 ITEM_CD: gridI.getCellValue(rowId,"ITEM_CD")
		        	,detailView : true
		        	,popupFlag : true
			    };
			    everPopup.openItemDetailInformation(param);
            } else if (celName === 'CTRL_NM') {
            	var ctrlType;
            	if (purchase_type == 'NORMAL') ctrlType = 'PPUR';
            	else ctrlType = 'NPUR';

				var param = {
					'callBackFunction': 'ctrlCodeCallback',
					'detailView': false,
					'rowId': rowId,
					'PLANT_CD': gridI.getCellValue(rowId, "PLANT_CD"),
					'CTRL_TYPE' : ctrlType
				};
				everPopup.openCommonPopup(param, "SP0037");
			} else if (celName === 'PUR_ORG_NM') {
				var param = {
					'callBackFunction': 'purOrgCodeCallback',
					'detailView': false,
					'rowId': rowId,
					BUYER_CD: gridI.getCellValue(rowId,"BUYER_CD"),
					PLANT_CD: gridI.getCellValue(rowId,"PLANT_CD")
				};
				everPopup.openCommonPopup(param, "SP0042");
			} else if (celName == "PR_NUM") {
				if (gridI.getCellValue(rowId, "PR_NUM") == '') {
					return;
				}
                everPopup.openPRDetailInformation(gridI.getCellValue(rowId, "PR_NUM"));
            }
        });

        gridV.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	if (celName == "VENDOR_CD") {
        		var params = {
	                VENDOR_CD: gridI.getCellValue(rowId, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);
	        }
        	if (celName == "PAY_TYPE_NM") {
        		// 납품유형이 "검수"인 경우에만 대금지불방식을 등록함
        		var deliveryType = gridV.getCellValue(rowId, "DELIVERY_TYPE");
        		if (deliveryType == null || deliveryType != 'PI') {
        			alert('${BFAR_020_0013}');
        			return;
        		}

        		var params = {
	                VENDOR_CD: gridV.getCellValue(rowId, "VENDOR_CD"),
	                EXEC_AMT : gridV.getCellValue(rowId, "SETTLE_AMT"),
	                CUR      : gridV.getCellValue(rowId, "CUR"),
	                EXEC_NUM : EVF.getComponent('EXEC_NUM').getValue(),
	                paramPopupFlag: "Y",
	                detailView : '${param.detailView}',
                    callBackFunction: "setPay_types",
                    rowid: rowId	,
                    PAY_TYPE : gridV.getCellValue(rowId,'PAY_TYPE'),
        		    PAY_TYPES    :gridV.getCellValue(rowId,'PAY_TYPES')
        		};
    		    everPopup.openPopupByScreenId('BFAR_030', 800, 400, params);
	        }
        	if (celName == "CONT_USER_NM") {
        		currRow = rowId;
                var param = {
                        callBackFunction: "_setBuyer2"
                    };
                    everPopup.openCommonPopup(param, 'SP0040');
        	}
        	if (celName == "PO_USER_NM") {
        		currRow = rowId;
                var param = {
                        callBackFunction: "_setBuyer3"
                    };
                    everPopup.openCommonPopup(param, 'SP0040');

        	}
        });

        gwdoc.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            var userwidth  = 810; // 고정(수정하지 말것)
			var userheight = (screen.height - 2);
			if (userheight < 780) userheight = 780; // 최소 780
			var LeftPosition = (screen.width-userwidth)/2;
			var TopPosition  = (screen.height-userheight)/2;
			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

			switch (celName) {
                case 'APRV_URL':
	            	if ('${param.detailView}' == 'true' && gwdoc.getCellValue(rowId, celName) != '' && gwdoc.getCellValue(rowId, celName).length > 200) {
    	            	window.open(gwdoc.getCellValue(rowId, celName), "signwindow", gwParam);
        	        }
            	    break;
				default:
			}
		});

        gridI.cellChangeEvent(function (rowId, celName, iRow, iCol, newValue, oldValue) {

        	if (celName == "TAX_CD") {
        		if (gridI.getRowCount() != 1) {
        			if(confirm('${BFAR_020_0300}')) {
        				for(var k=0;k<gridI.getRowCount();k++) {
       						gridI.setCellValue(gridI.getRowId(k), "TAX_CD", newValue);
        				}
        			}
        		}
        	}

        	if (celName == "INFO_FLAG") {
				if (EVF.isEmpty(gridI.getCellValue(rowId,'ITEM_CD') ) && newValue == '1' ) {
					alert('${BFAR_020_0399}');
					gridI.setCellValue(rowId, "INFO_FLAG", oldValue);
				}

        	}
        });



        gridV.cellChangeEvent(function (rowId, celName, iRow, iCol, newValue, oldValue) {
        	if (celName == "DELIVERY_TYPE") {
        		// 납품유형이 "납품"인 경우 대금지급방식 초기화
        		var deliveryType = gridV.getCellValue(rowId, "DELIVERY_TYPE");
        		if (deliveryType == 'DI') {
        			gridV.setCellValue(rowId, "PAY_TYPE", "");
        			gridV.setCellValue(rowId, "PAY_TYPES", "");
        			gridV.setCellValue(rowId, "PAY_TYPE_NM", "");
        		}
        	}
        });

        if ('${param.rfxNum}' !== '') {
            EVF.getComponent('RFX_NUM').setValue('${param.rfxNum}');
            EVF.getComponent('RFX_CNT').setValue('${param.rfxCnt}');

            doSearch();
        } else if ('${param.EXEC_NUM}' !== '') {
            EVF.getComponent('EXEC_NUM').setValue('${param.EXEC_NUM}');

            doSearch();
        } else if ('${param.appDocNum}' !== '') {
            doSearch();
        }

        // 구매유형이 "부품"인 경우 "투자구분,투자금액,견적가(Y+1,2,3)" Visible
        if (purchase_type == 'NORMAL') {
			EVF.C('EXEC_SUB_TYPE').removeOption('100'); // 공사
			EVF.C('EXEC_SUB_TYPE').removeOption('200'); // 제작
			EVF.C('EXEC_SUB_TYPE').removeOption('300'); // 표준품

			// 금형인 경우 "견적가(1,2,3)" Invisible
			if (EVF.C('EXEC_SUB_TYPE').getValue() == '1') {
		        gridI.hideCol('Y1_UNIT_PRC', true);
		        gridI.hideCol('Y2_UNIT_PRC', true);
		        gridI.hideCol('Y3_UNIT_PRC', true);

		        gridI.setColName('INIT_PRC', '최초금형단가');
		        gridI.setColName('FINAL_PRC', '금형단가');
		        gridI.setColName('FINAL_AMT', '금형비(수량*금형단가)');
			}
        } else {
			EVF.C('EXEC_SUB_TYPE').removeOption('1'); // 금형

	        gridI.hideCol('INVEST_CD',   true);
	        gridI.hideCol('Y1_UNIT_PRC', true);
	        gridI.hideCol('Y2_UNIT_PRC', true);
	        gridI.hideCol('Y3_UNIT_PRC', true);
        }

    	// 구매유형이 "품의(DC), 투자품의(ISP)"인 경우 "견적/입찰유형"은 필수(공사,제작,표준품)
    	// 구매유형이 "부품(NORMAL)"인 경우 "견적/입찰유형"은 옵션(금형)
    	if ('${param.detailView}' == 'true') {
            EVF.getComponent("EXEC_SUB_TYPE").setDisabled(true);
            EVF.getComponent("EXEC_SUB_TYPE").setRequired(false);
    	} else {
            if (purchase_type == 'DC' || purchase_type == 'ISP') {
                EVF.getComponent("EXEC_SUB_TYPE").setDisabled(false);
                EVF.getComponent("EXEC_SUB_TYPE").setRequired(true);

                EVF.getComponent("PURCHASE_TYPE_NM").setValue(EVF.getComponent('EXEC_SUB_TYPE').getText());
            } else if (purchase_type == 'NORMAL') {
                EVF.getComponent("EXEC_SUB_TYPE").setDisabled(false);
                EVF.getComponent("EXEC_SUB_TYPE").setRequired(false);

                EVF.getComponent("PURCHASE_TYPE_NM").setValue(EVF.getComponent('EXEC_SUB_TYPE').getText());
            } else {
                EVF.getComponent("EXEC_SUB_TYPE").setDisabled(true);
                EVF.getComponent("EXEC_SUB_TYPE").setRequired(false);

                EVF.getComponent("PURCHASE_TYPE_NM").setValue(EVF.getComponent('PURCHASE_TYPE').getText());
            }
    	}

    		doSearchGwDocData();
    }

    var currRow = '';
	function ctrlCodeCallback(data) {
		gridI.setCellValue(data.rowId, "CTRL_CD", data.CTRL_CD);
		gridI.setCellValue(data.rowId, "CTRL_NM", data.CTRL_NM);

		if (gridI.getRowCount() != 1) {
			if(confirm('${BFAR_020_0300}')) {
				for(var k=0;k<gridI.getRowCount();k++) {
					if ( gridI.getCellValue(data.rowId,'PLANT_CD') ==  gridI.getCellValue(gridI.getRowId(k),'PLANT_CD')  ) {
						gridI.setCellValue(gridI.getRowId(k), "CTRL_CD", data.CTRL_CD);
						gridI.setCellValue(gridI.getRowId(k), "CTRL_NM", data.CTRL_NM);
					}
				}
			}
		}
	}

	function purOrgCodeCallback(data) {
		gridI.setCellValue(data.rowId, "PUR_ORG_CD", data.PUR_ORG_CD);
		gridI.setCellValue(data.rowId, "PUR_ORG_NM", data.PUR_ORG_NM);

		if (gridI.getRowCount() !=1)
		if(confirm('${BFAR_020_0300}')) {
			for(var k=0;k<gridI.getRowCount();k++) {
				if ( gridI.getCellValue(data.rowId,'PLANT_CD') ==  gridI.getCellValue(gridI.getRowId(k),'PLANT_CD')  ) {
					gridI.setCellValue(gridI.getRowId(k), "PUR_ORG_CD", data.PUR_ORG_CD);
					gridI.setCellValue(gridI.getRowId(k), "PUR_ORG_NM", data.PUR_ORG_NM);
				}
			}
		}

	}

    function setPay_types(pay_type,pay_type_nm,gridData,rowId) {
    	gridV.setCellValue(rowId,'PAY_TYPE',pay_type);
    	gridV.setCellValue(rowId,'PAY_TYPE_NM',pay_type_nm);
    	gridV.setCellValue(rowId,'PAY_TYPES',gridData);
    }

    //조회
    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridV]);
        store.setParameter('rqList', JSON.stringify(${param.rqList}));

        store.load(baseUrl + "BFAR_020/doSearchVendor", function() {
        	var sumAmt = 0;
        	for (var k = 0; k < gridV.getRowCount(); k++) {
        		sumAmt += Number(gridV.getCellValue(k,'SETTLE_AMT'));
        	}
        	EVF.C('EXEC_AMT').setValue(sumAmt);

            <%--
            if (EVF.getComponent('LAST_PO_FLAG').getValue() == '1') {
    			for (var k = 0; k < gridV.getRowCount(); k++) {
    				gridV.setCellValue  (gridV.getRowId(k), "CONT_FLAG", 'N');
    				gridV.setCellReadOnly(gridV.getRowId(k), 'CONT_FLAG', true);
    			}
            }
            --%>

            if (gridV.getRowCount() != 0) {
            	doSearchItem();
            }
        });
    }

  	//품목 조회
    function doSearchItem() {
        var store = new EVF.Store();
        store.setParameter('rqList',JSON.stringify(${param.rqList}));
        store.setGrid([gridI]);

        store.load(baseUrl + "BFAR_020/doSearchItem", function() {
        });
    }


  	//저장
    function doSave() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}

        var store = new EVF.Store();
        if(!store.validate()) {
        	return;
        }

	    var signStatus = this.getData();
    	EVF.getComponent("SIGN_STATUS").setValue(signStatus);

		gridV.checkAll(true);
		gridI.checkAll(true);

        var valid = gridV.validate();
		var selRowsV = gridV.getSelRowValue();
    	var selRowsI = gridI.getSelRowValue();

        if(!valid.flag) {
            alert(valid.msg);
            return;
        }

        valid2 = gridI.validate();

        if(!valid2.flag) {
            alert(valid2.msg);
            return;
        }
        for (k = 0; k < selRowsI.length; k++) {
        	if (selRowsI[k].VALID_FROM_DATE > selRowsI[k].VALID_TO_DATE) {
        		alert('${BFAR_020_0012}');
        		return;
        	}
        }
        // 계약여부 "Y" => 계약담당자 필수
        for (k = 0; k < selRowsV.length; k++) {
        	if(selRowsV[k].CONT_FLAG == 'Y' && EVF.isEmpty(selRowsV[k].CONT_USER_ID)) {
        		alert('${BFAR_020_0021}');
        		return;
        	}

        	if(selRowsV[k].DELIVERY_TYPE == 'PI' && EVF.isEmpty(selRowsV[k].PAY_TYPE) ) {
        		alert('${BFAR_020_0023}');
        		return;
        	}
        }

        // 구매유형 "수선(AS),제작(NEW),품의(DC),투자품의(ISP)" => 발주담당자 필수
        var purchase_type = EVF.getComponent('PURCHASE_TYPE').getValue();
        if (purchase_type == 'AS' || purchase_type == 'NEW' || purchase_type == 'DC' || purchase_type == 'ISP') {
	        for (k = 0; k < selRowsV.length; k++) {
	        	if(selRowsV[k].PO_USER_ID == '') {
	        		alert('${BFAR_020_0022}');
	        		return;
	        	}
	        }
        }

        // 일반구매인 경우 "구매조직, 구매그룹" 필수, 부품구매인 경우 옵션
        if (purchase_type != 'NORMAL') {

        	for (k = 0; k < selRowsI.length; k++) {
            	if(  EVF.isEmpty(selRowsI[k].PUR_ORG_CD)  || EVF.isEmpty(selRowsI[k].CTRL_CD) ) {
            		alert('${BFAR_020_0020}');
            		return;
            	}
            }



        }

	    var confirmMessage;
	    switch (signStatus) {
	        case 'T':
	            confirmMessage = '${msg.M0021}';
	            break;
	        case 'E':
	            confirmMessage = '${msg.M0053}';
	            break;
	        case 'P':
	            confirmMessage = '${msg.M0053}';
	            break;
	    }

	    if (!confirm(confirmMessage)) {
	        return;
	    }

		store.setGrid([gridV, gridI,gwdoc]);
		store.getGridData( gridV, 'all');
		store.getGridData( gridI, 'all');
		store.getGridData( gwdoc, 'all');

        var userwidth  = 810; // 고정(수정하지 말것)
		var userheight = (screen.height - 2);
		if (userheight < 780) userheight = 780; // 최소 780
		var LeftPosition = (screen.width-userwidth)/2;
		var TopPosition  = (screen.height-userheight)/2;


		if (signStatus == 'P') { //결재요청일 경우

				var param = {
					subject: EVF.C('EXEC_SUBJECT').getValue(),
					docType: "EXEC",
					signStatus: "P",
					screenId: "BFAR_020",
					approvalType: 'APPROVAL',
					oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
					attFileNum: "",
					docNum: EVF.getComponent('EXEC_NUM').getValue(),
					appDocNum: EVF.C('APP_DOC_NUM').getValue(),
					callBackFunction: "goApproval"
				};

				everPopup.openApprovalRequestIIPopup(param);




		}
		else { //저장일 경우
			store.setGrid([gridV, gridI,gwdoc]);
			store.getGridData( gridV, 'all');
			store.getGridData( gridI, 'all');
			store.getGridData( gwdoc, 'all');

			store.doFileUpload(function() {
	        	store.load(baseUrl + "/doSave", function() {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

	        		var legacyKey = this.getParameter('legacy_key');
	        		if (legacyKey == 'ERROR') {
		        		alert(this.getResponseMessage());
		        		return;
	        		}

		            alert(this.getResponseMessage());
		            opener.doSearch();
		            location.href=baseUrl+'BFAR_020/view.so?EXEC_NUM='+this.getParameter("EXEC_NUM");
		        });
            });
		}
  	}

	//결재요청 Popup return시 수행
    function goApproval(formData, gridData, attachData) {
		EVF.getComponent('approvalFormData').setValue(formData);
		EVF.getComponent('approvalGridData').setValue(gridData);
		EVF.getComponent('attachFileDatas').setValue(attachData);
		var store = new EVF.Store();

		store.setGrid([gridV, gridI, gwdoc]);
		store.getGridData( gridV, 'all');
		store.getGridData( gridI, 'all');
		store.getGridData( gwdoc, 'all');
	  	store.doFileUpload(function() {
		   	store.load(baseUrl + "/doSave", function() {
		        alert(this.getResponseMessage());
		        opener.doSearch();
		        //alert(this.getParameter("EXEC_NUM"));
		            location.href='/eversrm/solicit/rfq/BFAR_020/view.so?SCREEN_ID=BFAR_020&popupFlag=true&EXEC_NUM='+this.getParameter("EXEC_NUM");
			    //if (popupFlag) {
				//	opener.doSearch();
			    //} else {
			    //}
    		});
		});
 	}

  	//삭제
    function doDelete() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}

    	var valid = gridV.validate()
		, selRows = gridV.getSelRowValue();

    	if (!confirm("${msg.M0013}")) return;

        var store = new EVF.Store();
        store.setGrid([gridV,gridI]);
    	store.getGridData(gridV, 'all');
    	store.getGridData(gridI, 'all');
    	store.load(baseUrl + 'BFAR_020/doDelete', function(){
        	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

    		alert(this.getResponseMessage());
    		window.close();
    		opener.doSearch();
    	});

  	}

  	//닫기
    function doClose() {
    	if ('${param.appDocNum}' == '') {
	    	window.close();
	    	<%-- opener.doSearch(); --%>
    	} else {
    		doClose2();
    	}
    }

    function doClose2() {
        new EVF.ModalWindow().close(null);
    }


    function doSearchBuyer() {
        var param = {
            callBackFunction: "_setBuyer"
        };
        everPopup.openCommonPopup(param, 'SP0040');
    }
    function _setBuyer(data) {
        EVF.C("CTRL_USER_ID").setValue(data['CTRL_USER_ID']);
        EVF.C("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
    }
    function _setBuyer2(data) {
    	gridV.setCellValue(currRow,'CONT_USER_ID', data['CTRL_USER_ID'] );
    	gridV.setCellValue(currRow,'CONT_USER_NM', data.CTRL_USER_NM );
    }
    function _setBuyer3(data) {
    	gridV.setCellValue(currRow,'PO_USER_ID', data['CTRL_USER_ID'] );
    	gridV.setCellValue(currRow,'PO_USER_NM', data.CTRL_USER_NM );
    }
    function doSearchGwDocData() {
        var store = new EVF.Store();

        store.setGrid([gwdoc]);
        store.load(baseUrl + "BFAR_020/doSearchGwDocData", function () {
        	gwdoc.checkAll(true);
        });
    }
    function changeExecSubType() {
    	if (EVF.getComponent('EXEC_SUB_TYPE').getValue() == '') {
    		EVF.getComponent("PURCHASE_TYPE_NM").setValue(EVF.getComponent('PURCHASE_TYPE').getText());
    	} else {
    		EVF.getComponent("PURCHASE_TYPE_NM").setValue(EVF.getComponent('EXEC_SUB_TYPE').getText());
    	}

    	if (EVF.getComponent('EXEC_SUB_TYPE').getValue() == '1') {
	        gridI.hideCol('Y1_UNIT_PRC', true);
	        gridI.hideCol('Y2_UNIT_PRC', true);
	        gridI.hideCol('Y3_UNIT_PRC', true);

    		gridI.setColName('INIT_PRC', '최초금형단가');
        	gridI.setColName('FINAL_PRC', '금형단가');
        	gridI.setColName('FINAL_AMT', '금형비(수량*금형단가)');
    	} else {
    		if (EVF.getComponent("PURCHASE_TYPE").getValue() == 'NORMAL') {
    	        gridI.hideCol('Y1_UNIT_PRC', false);
    	        gridI.hideCol('Y2_UNIT_PRC', false);
    	        gridI.hideCol('Y3_UNIT_PRC', false);
    		}

        	gridI.setColName('INIT_PRC', '최초견적단가');
        	gridI.setColName('FINAL_PRC', '견적단가(Y+0)');
        	gridI.setColName('FINAL_AMT', '견적금액(Y+0)');
    	}
    }
    function gwDocView() {

		var userwidth  = 820;
		var userheight = (screen.height - 2);
		var LeftPosition = (screen.width-userwidth)/2;
		var TopPosition  = (screen.height-userheight)/2;
		var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

		if (EVF.getComponent("BLSM_MSG").getValue() != '') {
			var url = '${gwLinkUrl}'+EVF.getComponent("BLSM_MSG").getValue();
			window.open(url, "signwindow", gwParam);
		} else {
    		alert('${BFAR_020_0024}');

		}
	}
    </script>

    <e:window id="BFAR_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="RFX_NUM" name="RFX_NUM" value="${param.rfxNum}"/>
        <e:inputHidden id="RFX_CNT" name="RFX_CNT" value="${param.rfxCnt}"/>
        <e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty form.GATE_CD ? param.gateCd : form.GATE_CD}" />
        <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
        <e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD" value="${form.PUR_ORG_CD}"/>
        <e:inputHidden id="CUR" name="CUR" value="${form.CUR}"/>
        <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}"/>
        <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}"/>
        <e:inputHidden id="approvalFormData" name="approvalFormData"/>
    	<e:inputHidden id="approvalGridData" name="approvalGridData"/>
    	<e:inputHidden id="attachFileDatas" name="attachFileDatas"/>
		<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${form.APP_DOC_NUM}"/>
		<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${form.APP_DOC_CNT}"/>
		<e:inputHidden id="PURCHASE_TYPE_NM" name="PURCHASE_TYPE_NM"/>
		<e:inputHidden id="BLSM_MSG" name="BLSM_MSG" value="${form.BLSM_MSG}"/>
		<e:inputHidden id="TEMP_VENDOR_CD" name="TEMP_VENDOR_CD" value="${form.TEMP_VENDOR_CD}"/>
		<e:inputHidden id="LAST_PO_FLAG" name="LAST_PO_FLAG" value="${form.LAST_PO_FLAG}"/>

        <e:buttonBar align="right">
	        <c:if test="${form.SIGN_STATUS != 'P' && form.SIGN_STATUS != 'E'  && form.CTRL_USER_ID == ses.userId }">
	        	<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data='T'/>

				<c:if test="${form.EXEC_NUM != null}">
					<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doSave" disabled="${doRequest_D}" visible="${doRequest_V}" data='P'/>
				</c:if>

				<c:if test="${devFlag != 'false'}">
	        		<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doSave" disabled="${doApproval_D}" visible="${doApproval_V}" data='E'/>
				</c:if>

				<c:if test="${form.EXEC_NUM != null}">
					<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
				</c:if>
			</c:if>
			<c:if test="${form.BLSM_MSG ne '' and form.BLSM_MSG ne null}">
				<e:button id="gwDocView" name="gwDocView" label="${gwDocView_N}" onClick="gwDocView" disabled="${gwDocView_D}" visible="${gwDocView_V}"/>
			</c:if>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">

            <e:row>
            <e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />
            <e:field>
                <e:inputText id='EXEC_NUM' name="EXEC_NUM" value='${form.EXEC_NUM}' width='130' maxLength='${form_EXEC_NUM_M }' required='${form_EXEC_NUM_R }' readOnly='true' disabled='true' visible='${form_EXEC_NUM_V }' />
            </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE"  onChange="chPurchaseType"  name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
	        </e:row>

	        <e:row>
	        <e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}"/>
			<e:field>
				<e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="${form.EXEC_SUBJECT}" width="100%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
			</e:field>
			<e:label for="EXEC_SUB_TYPE" title="${form_EXEC_SUB_TYPE_N}"/>
			<e:field>
				<e:select id="EXEC_SUB_TYPE" onChange="changeExecSubType" name="EXEC_SUB_TYPE" value="${form.EXEC_SUB_TYPE}" options="${execSubTypeOptions}" width="${inputTextWidth}" disabled="${form_EXEC_SUB_TYPE_D}" readOnly="${form_EXEC_SUB_TYPE_RO}" required="${form_EXEC_SUB_TYPE_R}" placeHolder="" />
			</e:field>
	        </e:row>

	        <e:row>

            <e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
            <e:field>
                 <e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="${form.SHIPPER_TYPE}" options="${shipperType }" width="${inputTextWidth}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" />
            </e:field>



            <e:label for="EXEC_DATE" title="${form_EXEC_DATE_N}"/>
			<e:field>
				<e:inputDate id="EXEC_DATE" name="EXEC_DATE" value="${form.EXEC_DATE}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_R}" disabled="${form_EXEC_DATE_D}" readOnly="${form_EXEC_DATE_RO}" />
			</e:field>
	        </e:row>

	        <e:row>
			<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
            <e:field>
                <e:search id='CTRL_USER_NM' name="CTRL_USER_NM" value='${empty form.CTRL_USER_NM ? ses.userNm : form.CTRL_USER_NM}' width='${inputTextWidth }' required='${form_CTRL_USER_NM_R }' readOnly='true' disabled='${form_CTRL_USER_NM_D }' visible='${form_CTRL_USER_NM_V }' maxLength="${form_CTRL_USER_NM_M}" />
                <e:inputHidden id='CTRL_USER_ID' name="CTRL_USER_ID" value='${empty CTRL_USER_ID ? ses.userId : form.CTRL_USER_ID}' />
            </e:field>
			<e:label for="EXEC_AMT" title="${form_EXEC_AMT_N}"/>
			<e:field>
			<e:inputNumber id="EXEC_AMT" name="EXEC_AMT" value="${form.EXEC_AMT}" maxValue="${form_EXEC_AMT_M}" decimalPlace="${form_EXEC_AMT_NF}" disabled="${form_EXEC_AMT_D}" readOnly="${form_EXEC_AMT_RO}" required="${form_EXEC_AMT_R}" />
			</e:field>
	        </e:row>

	        <e:row>
                <e:label for="RMK_TEXT_NUM_TEXT" title="${form_RMK_TEXT_NUM_TEXT_N}" />
                <e:field colSpan="3">
                	<e:richTextEditor id="RMK_TEXT_NUM_TEXT" value="${form.RMK_TEXT_NUM_TEXT }"  height="150px" name="RMK_TEXT_NUM_TEXT" width="100%" required="${form_RMK_TEXT_NUM_TEXT_R }" readOnly="${form_RMK_TEXT_NUM_TEXT_RO }" disabled="${form_RMK_TEXT_NUM_TEXT_D }" />
				</e:field>
			</e:row>

			<e:row>
				<e:label for="" title="${form_ATT_FILE_NUM_N}" />
				<e:field colSpan="3">
					<e:fileManager id="ATT_FILE_NUM" height="120px" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${param.detailView == true ? true : false}" bizType="EXEC" required="${form_ATT_FILE_NUM_R}" />
				</e:field>
			</e:row>

            <e:row>
                <e:label for="XXXXXXXXX" title="${BFAR_020_GW_RELATED_DOC}" />
                <e:field colSpan="3">
                    <e:gridPanel gridType="${_gridType}" id="gwdoc" name="gwdoc" height="150" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gwdoc.gridColData}" />
                </e:field>
            </e:row>


        </e:searchPanel>
		<jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true" >
			<jsp:param value="${form.APP_DOC_NUM}" name="APP_DOC_NUM"/>
			<jsp:param value="${form.APP_DOC_CNT}" name="APP_DOC_CNT"/>
		</jsp:include>
        <e:searchPanel id="form2" title="${form_CAPTION2_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
        <e:gridPanel gridType="${_gridType}" id="gridV" name="gridV" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.gridV.gridColData}" />
        </e:searchPanel>

        <e:searchPanel id="form3" title="${form_CAPTION3_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
        <e:gridPanel gridType="${_gridType}" id="gridI" name="gridI" height="280" readOnly="${param.detailView}" columnDef="${gridInfos.gridI.gridColData}" />
        </e:searchPanel>

	</e:window>
</e:ui>