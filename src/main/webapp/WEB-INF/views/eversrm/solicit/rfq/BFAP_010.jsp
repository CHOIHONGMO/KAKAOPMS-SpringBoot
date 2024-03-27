<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
	String devFlag = PropertiesManager.getString("eversrm.system.developmentFlag");
	String gwUrl = "";
	if ("true".equals(devFlag)) {
		  gwUrl = PropertiesManager.getString("gw.dev.url");
	} else {
		  gwUrl = PropertiesManager.getString("gw.real.url");
	}
	String gwParam = PropertiesManager.getString("gw.param");
%>

<c:set var="devFlag" value="<%=devFlag%>" />
<c:set var="gwUrl" value="<%=gwUrl%>" />
<c:set var="gwParam" value="<%=gwParam%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";
	var selRow;
	var flag = 0;

    function init() {
        grid = EVF.C("grid");
		EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
		EVF.C('PURCHASE_TYPE').removeOption('OMRO'); // 해외MRO
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

        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
			if(selRow == undefined) selRow = rowId;

			if (celName == 'multiSelect') {
				/*
				if(selRow != rowId) {
					grid.checkRow(selRow, false);
					selRow = rowId;
				}
				*/
			}

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
            }
        	else if (celName == "EXEC_NUM") {
                var param = {
                    gateCd: grid.getCellValue(rowId, "GATE_CD"),
                    EXEC_NUM: grid.getCellValue(rowId, "EXEC_NUM"),
					itemList: false,
                    popupFlag: true,
                    detailView: true,
					EXEC_TYPE: grid.getCellValue(rowId,'EXEC_TYPE')
                };

                var exec_type = grid.getCellValue(rowId,'EXEC_TYPE');

                var screenId='';
                if(exec_type == "G") {
                	screenId='BFAR_020';
        		} else if(exec_type == "C") {
                	screenId='DH0630';
        		} else if(exec_type == "O") {
                	screenId='DH0600';
        		} else if(exec_type == "S") {
                	screenId='DH0540';
        		} else if(exec_type == "U") {
                	screenId='DH0550';
        		}

                everPopup.openPopupByScreenId(screenId, 1200, 800, param);

        	}
        	else if (celName == "VENDOR_BID") {
                var param = {
                    rfxNum: grid.getCellValue(rowId, "RFX_NUM"),
                    rfxCnt: grid.getCellValue(rowId, "RFX_CNT"),
                    rfxSubject: grid.getCellValue(rowId, "RFX_SUBJECT"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.openPopupByScreenId('BPX_220', 800, 600, param);
            }
        	else if (celName == "VENDOR_CD") {
        		var params = {
	                VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
	                paramPopupFlag: "Y",
	                detailView : true
	            };
	            everPopup.openSupManagementPopup(params);

	        } else  if (celName == "QTA_NUM") {
            	if (grid.getCellValue(rowId,'QTA_NUM') == '') return;


            	if (grid.getCellValue(rowId,'QTA_NUM').substring(0,2) == 'PR') return;
    	        var param = {
    		            gateCd: grid.getCellValue(rowId,'${ses.gateCd}'),
    		            rfxNum: grid.getCellValue(rowId,'RFX_NUM'),
    		            qtaNum : grid.getCellValue(rowId,'QTA_NUM'),
    		            rfxCnt: grid.getCellValue(rowId,'RFX_CNT'),
    		            //rfxType: selectedRow['RFX_TYPE'],
    		            popupFlag: true,
    		            //callBackFunction: "doSearch"
    		            detailView: true,
    		            "isPrefferedBidder": false,
    		            "buttonStatus" : 'Y',
    		            vendorCd: grid.getCellValue(rowId,'VENDOR_CD')
    		    };
    		    everPopup.openPopupByScreenId('DH2140', 1000, 800, param);
        	} else if (celName == "multiSelect") {
				if(flag == 0) {
					var execNum = grid.getCellValue(rowId, 'EXEC_NUM');

					grid.checkAll(false);
					var gridData = grid.getAllRowValue();

					for (var i in gridData) {
						var item = gridData[i];
						if (execNum == item['EXEC_NUM']) {
							grid.checkRow(i, true);
						}

						if(gridData.length == parseInt(i) + 1) {
							flag = 0;
						} else {
							flag = 1;
						}
					}
				}
            }

        });

        <%--
		if(${_gridType eq "RG"}) {
			grid.setColGroup([{
				"groupName": '${form_TEXT1_N}',
				"columns": [ "CNVD_SIGN_STATUS", "CNVD_SIGN_DATE" ]
			}]);
		} else {
			grid.setGroupCol(
				[{'colName' : 'CNVD_SIGN_STATUS', 'colIndex' : 2, 'titleText' : '${form_TEXT1_N}'}]
			);
		}
		--%>

        //doSearch();
    }

    //조회
    function doSearch() {

        if (!everDate.fromTodateValid('EXEC_DATE_FROM', 'EXEC_DATE_TO', '${ses.dateFormat }')) return alert('${msg.M0073}');
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + "BFAP_010/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }
	function doSearchVendor() {
		var param = {
			BUYER_CD : "${ses.companyCd}",
			callBackFunction : "_setVendor"
		};
		everPopup.openCommonPopup(param, 'SP0013');
    }
    function _setVendor(data) {
		EVF.getComponent("VENDOR_CD").setValue(data.VENDOR_CD);
		EVF.getComponent("VENDOR_NM").setValue(data.VENDOR_NM);
    }
    function doSelectPurchaseUser() {
        var param = {
				callBackFunction: "selectPurchaseUser",
				BUYER_CD: "${ses.companyCd}"
			};
		everPopup.openCommonPopup(param, 'SP0040');
    }
    function selectPurchaseUser(dataJsonArray) {
        EVF.C("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
        EVF.C("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
    }
    function doChangePic() {
		/*if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}*/
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        var selectedRow = grid.getSelRowValue()[0];

        if ('${ses.userId}' != selectedRow['CTRL_USER_ID']) return alert('${msg.M0008}');

        if (selectedRow.SIGN_STATUS !='T'
        		&& selectedRow.SIGN_STATUS !='R'
        		&& selectedRow.SIGN_STATUS !='C'
        ) {
        	alert("${msg.M0044}");
			return;
        }

        if(selectedRow.EXEC_TYPE == "G") {
			var param = {
				gateCd: selectedRow.GATE_CD,
				EXEC_NUM: selectedRow.EXEC_NUM,
				popupFlag: true,
				detailView: false,
				EXEC_TYPE: selectedRow.EXEC_TYPE
			};
			everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
		} else if(selectedRow.EXEC_TYPE == "C") {
			var param = {
				EXEC_NUM: selectedRow.EXEC_NUM,
				VENDOR_CD : selectedRow.VENDOR_CD,
				popupFlag: true,
				detailView: false
			};
			everPopup.openPopupByScreenId('DH0630', 1200, 800, param);
		} else if(selectedRow.EXEC_TYPE == "O") {
			var param = {
					EXEC_NUM: selectedRow.EXEC_NUM,
					VENDOR_CD : selectedRow.VENDOR_CD,
					itemList : false,
					popupFlag: true,
					detailView: false
				};
				everPopup.openPopupByScreenId('DH0600', 1200, 800, param);
		} else if(selectedRow.EXEC_TYPE == "S") {
			var param = {
					EXEC_NUM: selectedRow.EXEC_NUM,
					VENDOR_CD : selectedRow.VENDOR_CD,
					itemList : false,
					popupFlag: true,
					detailView: false
				};
				everPopup.openPopupByScreenId('DH0540', 1200, 800, param);
		} else if(selectedRow.EXEC_TYPE == "U") {
			var param = {
					EXEC_NUM: selectedRow.EXEC_NUM,
					VENDOR_CD : selectedRow.VENDOR_CD,
					itemList : false,
					popupFlag: true,
					detailView: false
				};
				everPopup.openPopupByScreenId('DH0550', 1200, 800, param);
		}
    }

	function dummyAction() {

		if (!grid.isExistsSelRow()) {
			return alert('${msg.M0004}');
		}

		/*
		 * 구매유형 - 부품(NORMAL), 품의구분 - 협력회사선정품의(G), 진행상태 - 승인(E)인 건에 대해서만 개발요청서 작성 가능
		 */
		var gridData = grid.getSelRowValue()[0];
		if (!(gridData.PURCHASE_TYPE == "NORMAL" && gridData.EXEC_TYPE == "G" && gridData.SIGN_STATUS == "E")) {
			alert("${BFAP_010_0003}"); // 구매유형-부품, 품의구분-협력회사선정품의, 진행상태-승인\n건에 대해서만 개발요청서를 작성하실 수 있습니다.
			return;
		}

		if (gridData.CNVD_SIGN_STATUS == "P" || gridData.CNVD_SIGN_STATUS == "E") {
			alert("${msg.M0044}");
			return;
		}

        var userwidth  = 810; // 고정(수정하지 말것)
		var userheight = (screen.height - 2);
		if (userheight < 780) userheight = 780; // 최소 780
		var LeftPosition = (screen.width-userwidth)/2;
		var TopPosition  = (screen.height-userheight)/2;
		var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

		var store = new EVF.Store();
		store.setGrid([grid]);
		store.getGridData(grid, 'sel');
		store.load(baseUrl + "BFAP_010/dummyAction", function() {
			var legacyKey = this.getParameter('legacy_key');
    		if (legacyKey == 'ERROR') {
				alert("${msg.M0044}");
        		return;
    		}

			var url;
			var gwUserId;
			if ('${devFlag}' == 'true') {
				gwUserId = 'hspark03';
			} else {
				gwUserId = '${ses.userId}';
			}
			if (legacyKey != '') {
				url = "${gwUrl}"+gwUserId+"${gwParam}"+legacyKey;
				var win = window.open(url, "signwindow", gwParam);
			}
			/*
			var interval = window.setInterval(function() {
				try {
					if(win == null || win.closed) {
						window.clearInterval(interval);
						doSearch();
					}
				} catch (e) {}
			}, 1000);
			*/
		});
	}
</script>


    <e:window id="BFAP_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
	            <e:row>
				<e:label for="EXEC_DATE_FROM" title="${form_EXEC_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="EXEC_DATE_FROM" toDate="EXEC_DATE_TO" name="EXEC_DATE_FROM" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_FROM_R}" disabled="${form_EXEC_DATE_FROM_D}" readOnly="${form_EXEC_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="EXEC_DATE_TO" fromDate="EXEC_DATE_FROM" name="EXEC_DATE_TO" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_TO_R}" disabled="${form_EXEC_DATE_TO_D}" readOnly="${form_EXEC_DATE_TO_RO}" />
				</e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
				<e:label for="EXEC_TYPE" title="${form_EXEC_TYPE_N}"/>
				<e:field>
					<e:select id="EXEC_TYPE" name="EXEC_TYPE" value="${form.EXEC_TYPE}" options="${execTypeOptions}" width="${inputTextWidth}" disabled="${form_EXEC_TYPE_D}" readOnly="${form_EXEC_TYPE_RO}" required="${form_EXEC_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}"/>
				<e:field>
					<e:inputText id="EXEC_NUM" style="ime-mode:inactive" name="EXEC_NUM" value="${form.EXEC_NUM}" width="35%" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}"/>
					<e:text>&nbsp;</e:text>
					<e:inputText id="EXEC_SUBJECT" style="ime-mode:auto" name="EXEC_SUBJECT" value="${form.EXEC_SUBJECT}" width="60%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}"/>
				</e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
					<e:field>
					<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
					<e:inputHidden id="VENDOR_CD" name="VENDOR_CD"/>
				</e:field>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
					<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}" options="${signStatusOptions}" width="${inputTextWidth}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:search id="CTRL_USER_ID" style="ime-mode:inactive" name="CTRL_USER_ID" value="${ses.userId }" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_RO ? 'everCommon.blank' : 'doSelectPurchaseUser'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" />
					<e:text>&nbsp;</e:text>
					<e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
				</e:field>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}"/>
				<e:field>
					<e:inputText id="RFX_NUM" style="ime-mode:inactive" name="RFX_NUM" value="${form.RFX_NUM}" width="${inputTextWidth}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}"/>
				</e:field>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}"/>
				<e:field>
					<e:inputText id="RFX_SUBJECT" style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${inputTextWidth}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}"/>
				</e:field>
			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doChangePic" name="doChangePic" label="${doChangePic_N}" onClick="doChangePic" disabled="${doChangePic_D}" visible="${doChangePic_V}"/>
			<%-- <e:button id="dummyAction" name="dummyAction" label="${dummyAction_N}" onClick="dummyAction" disabled="${dummyAction_D}" visible="${dummyAction_V}"/> --%>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>