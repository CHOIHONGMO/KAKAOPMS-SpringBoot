<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
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
    var gwdoc;
	var grid;
    var baseUrl = "/eversrm/master/bom/";

    function init() {

        gridV = EVF.C("gridV");
        gridI = EVF.C("gridI");
        //gridV.setProperty('shrinkToFit', true);
        gwdoc =  EVF.C("gwdoc");
        gridI.setColEllipsis (['CHANGE_REASON_CD'], true);
        gridI.setColEllipsis (['RMK'], true);
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

        	if (celName === 'CTRL_NM') {
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
			}
			if (celName === 'PUR_ORG_NM') {
				var param = {
					'callBackFunction': 'purOrgCodeCallback',
					'detailView': false,
					'rowId': rowId,
					BUYER_CD: gridI.getCellValue(rowId,"BUYER_CD"),
					PLANT_CD: gridI.getCellValue(rowId,"PLANT_CD")
				};
				everPopup.openCommonPopup(param, "SP0042");
			}

            if (celName == "CHANGE_REASON_NM") {
            	setRowId = rowId;
        	    var param = {
        				  callBackFunction : 'setTextContents'
        				, CHANGE_REASON_CD : gridI.getCellValue(rowId, "CHANGE_REASON_CD")
        				, detailView : false
        			};
            	everPopup.openPopupByScreenId('DH0600ChReaCd', 650, 350, param);
            }


			if (celName == "RMK") {
            	setRowId = rowId;
        	    var param = {
        				  havePermission : true
        				, callBackFunction : 'setTextContents2'
        				, TEXT_CONTENTS : gridI.getCellValue(rowId, "RMK")
        				, detailView : false
        			};
      	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
            }
        });

        gridI.cellChangeEvent(function (rowId, celName, iRow, iCol, newValue, oldValue) {
        });

        doSearch();
    }
	function setTextContents(codes,texts) {




		gridI.setCellValue(setRowId, "CHANGE_REASON_CD",codes);
		gridI.setCellValue(setRowId, "CHANGE_REASON_NM",texts);
	}

	function setTextContents2(tests) {
		gridI.setCellValue(setRowId, "RMK",tests);
	}



	function ctrlCodeCallback(data) {
		gridI.setCellValue(data.rowId, "CTRL_CD", data.CTRL_CD);
		gridI.setCellValue(data.rowId, "CTRL_NM", data.CTRL_NM);
	}

	function purOrgCodeCallback(data) {
		gridI.setCellValue(data.rowId, "PUR_ORG_CD", data.PUR_ORG_CD);
		gridI.setCellValue(data.rowId, "PUR_ORG_NM", data.PUR_ORG_NM);
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
        var data =; ${param.itemList} == false ? '' : ${param.itemList};
        store.setParameter('itemList', data == '' ? '' : JSON.stringify(data));



        store.load(baseUrl + "DH0540/doSearchVendor", function() {
            if (gridV.getRowCount() != 0) {
            	doSearchItem();
            }
        });
    }

  	//품목 조회
    function doSearchItem() {
        var store = new EVF.Store();
		var data =; ${param.itemList} == false ? '' : ${param.itemList};
        store.setParameter('itemList', data == '' ? '' : JSON.stringify(data));

        store.setGrid([gridI]);
        store.load(baseUrl + "DH0540/doSearchItem", function() {
        });
    }


  	//저장
    function doSave() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}

	    var signStatus = this.getData();
        var valid = gridV.validate()
   			, selRowsV = gridV.getSelRowValue()
        	, selRowsI = gridI.getSelRowValue();
        var store = new EVF.Store();
        if(!store.validate()) return;
    	EVF.getComponent("SIGN_STATUS").setValue(signStatus);

		gridV.checkAll(true);
		gridI.checkAll(true);

        if(!gridI.validate().flag) {
            alert('${msg.M0014}');
            return;
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

	    for (var k = 0; k <selRowsI.length; k++) {
	    	if (selRowsI[k].VALID_FROM_DATE < '${currDate2}') {
	    		alert('${DH0540_0010}');
	    		return;
	    	}
	    	if (selRowsI[k].VALID_FROM_DATE.substring(6,8) != '01') {
	    		alert('${DH0540_0010}');
	    		return;
	    	}
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
		var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

		if (signStatus == 'P') { //결재요청일 경우
			if (EVF.getComponent('EXEC_NUM').getValue()== '') {
				alert('${DH0540_004}');
				return;
			}

			store.setGrid([gridV, gridI,gwdoc]);
			store.getGridData( gridV, 'all');
			store.getGridData( gridI, 'all');
			store.getGridData( gwdoc, 'all');

			store.doFileUpload(function() {
	        	store.load(baseUrl + "/DH0540/doSave", function() {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

	        		var legacyKey = this.getParameter('legacy_key');
	        		if (legacyKey == 'ERROR') {
		        		alert(this.getResponseMessage());
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
		    			window.open(url, "signwindow", gwParam);
	    			}

	    			window.close();
		        });
            });
		}
		else { //저장일 경우
			store.setGrid([gridV, gridI,gwdoc]);
			store.getGridData( gridV, 'all');
			store.getGridData( gridI, 'all');
			store.getGridData( gwdoc, 'all');

			store.doFileUpload(function() {
	        	store.load(baseUrl + "/DH0540/doSave", function() {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

	        		var legacyKey = this.getParameter('legacy_key');
	        		if (legacyKey == 'ERROR') {
		        		alert(this.getResponseMessage());
		        		return;
	        		}

		            alert(this.getResponseMessage());
		            opener.doSearch();
		            location.href='/eversrm/master/bom/DH0540/view.so?SCREEN_ID=DH0540&popupFlag=true&itemList=false&EXEC_NUM='+this.getParameter("EXEC_NUM");
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

		store.setGrid([gridV, gridI]);
		store.getGridData( gridV, 'all');
		store.getGridData( gridI, 'all');
	  	store.doFileUpload(function() {
		   	store.load(baseUrl + "/doSave", function() {
		        alert(this.getResponseMessage());
		        opener.doSearch();
		        //alert(this.getParameter("EXEC_NUM"));
		            location.href='/eversrm/solicit/rfq/DH0540/view.so?SCREEN_ID=DH0540&popupFlag=true&EXEC_NUM='+this.getParameter("EXEC_NUM");
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
        store.setGrid([gridV]);
    	store.getGridData(gridV, 'all');
    	store.load(baseUrl + 'DH0540/doDelete', function(){
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
    function doSearchGwDocData() {
        var store = new EVF.Store();
        store.setGrid([gwdoc]);
        store.load(baseUrl + "DH0540/doSearchGwDocData", function () {
        	gwdoc.checkAll(true);
        });
    }
    function doApply2() {
  	  var datea = EVF.getComponent('APPLY_DATE').getValue();
	  if(datea=='') return;
	  var selRowIds = gridI.jsonToArray(gridI.getSelRowId()).value;
	  for (var k = 0; k < selRowIds.length; k++) {
		gridI.setCellValue(selRowIds[k],'VALID_FROM_DATE',datea);

	  }
    }

    function doApply3() {
    	var datea = EVF.getComponent('APPLY_DATE3').getValue();
    	if(datea=='') return;

  	  	var selRowIds = gridI.jsonToArray(gridI.getSelRowId()).value;
  	  	for (var k = 0; k < selRowIds.length; k++) {
  			gridI.setCellValue(selRowIds[k],'SAP_SO_DATE',datea);
  	  	}
	}

</script>

    <e:window id="DH0540" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="RFX_NUM" name="RFX_NUM" value="${param.rfxNum}"/>
        <e:inputHidden id="RFX_CNT" name="RFX_CNT" value="${param.rfxCnt}"/>
        <e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty form.GATE_CD ? param.gateCd : form.GATE_CD}" />
        <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}"/>
        <e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD" value="${form.PUR_ORG_CD}"/>
        <e:inputHidden id="CUR" name="CUR" value="${form.CUR}"/>
        <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}"/>
        <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}"/>
        <e:inputHidden id="approvalFormData" name="approvalFormData"/>
    	<e:inputHidden id="approvalGridData" name="approvalGridData"/>
    	<e:inputHidden id="attachFileDatas" name="attachFileDatas"/>
		<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${form.APP_DOC_NUM}"/>
		<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${form.APP_DOC_CNT}"/>

        <e:buttonBar align="right">
	        <c:if test="${form.SIGN_STATUS != 'P' && form.SIGN_STATUS != 'E'  && form.CTRL_USER_ID == ses.userId }">
	        	<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data='T'/>
				<c:if test="${form.EXEC_NUM != null}">
	        	<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doSave" disabled="${doRequest_D}" visible="${doRequest_V}" data='P'/>
				</c:if>
	        	<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doSave" disabled="${doApproval_D}" visible="${doApproval_V}" data='E'/>
				<c:if test="${form.EXEC_NUM != null}">
					<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
				</c:if>
			</c:if>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
            <e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}" />
            <e:field>
                <e:inputText id='EXEC_NUM' name="EXEC_NUM" value='${form.EXEC_NUM}' width='130' maxLength='${form_EXEC_NUM_M }' required='${form_EXEC_NUM_R }' readOnly='true' disabled='true' visible='${form_EXEC_NUM_V }' />
        		<e:inputHidden id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="D"/>
        		<e:inputHidden id="EXEC_AMT" name="EXEC_AMT" value="0"/>
            </e:field>
	        <%--구매유형--%>
	        <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
	        <e:field>
	          	<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="NORMAL" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
	        </e:field>
	        </e:row>

	        <e:row>
	        <e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}"/>
			<e:field colSpan="3">
				<e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="${form.EXEC_SUBJECT}" width="100%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
			</e:field>
	        </e:row>

	        <e:row>


            <e:label for="EXEC_DATE" title="${form_EXEC_DATE_N}"/>
			<e:field>
				<e:inputDate id="EXEC_DATE" name="EXEC_DATE" value="${form.EXEC_DATE}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_R}" disabled="${form_EXEC_DATE_D}" readOnly="${form_EXEC_DATE_RO}" />
			</e:field>
			<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
            <e:field>
                <e:search id='CTRL_USER_NM' name="CTRL_USER_NM" value='${empty form.CTRL_USER_NM ? ses.userNm : form.CTRL_USER_NM}' width='${inputTextWidth }' required='${form_CTRL_USER_NM_R }' readOnly='true' disabled='${form_CTRL_USER_NM_D }' visible='${form_CTRL_USER_NM_V }' maxLength="${form_CTRL_USER_NM_M}" />
                <e:inputHidden id='CTRL_USER_ID' name="CTRL_USER_ID" value='${empty CTRL_USER_ID ? ses.userId : form.CTRL_USER_ID}' />
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


        </e:searchPanel>

		<div style="display:none;">
        <e:gridPanel gridType="${_gridType}" id="gwdoc" name="gwdoc" height="0" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gwdoc.gridColData}" />
        <e:gridPanel gridType="${_gridType}" id="gridV" name="gridV" height="200" columnDef="${gridInfos.gridV.gridColData}" />
		</div>

        <e:searchPanel id="form3" title="${form_CAPTION3_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">

        <e:buttonBar align="right">
        <e:text>&nbsp;&nbsp;${form_APPLY_DATE_N } : &nbsp;</e:text>
		<e:inputDate id="APPLY_DATE" name="APPLY_DATE" value="${form.APPLY_DATE}" width="${inputTextDate}" datePicker="true" required="${form_APPLY_DATE_R}" disabled="${form_APPLY_DATE_D}" readOnly="${form_APPLY_DATE_RO}" />
		<e:text>&nbsp;</e:text>
		<e:button id="doApply2" name="doApply2" label="${doApply2_N}" onClick="doApply2" disabled="${doApply2_D}" visible="${doApply2_V}" align="left"/>

        <e:text>&nbsp;&nbsp;${form_APPLY_DATE3_N } : &nbsp;</e:text>
		<e:inputDate id="APPLY_DATE3" name="APPLY_DATE3" value="${form.APPLY_DATE}" width="${inputTextDate}" datePicker="true" required="${form_APPLY_DATE_R}" disabled="${form_APPLY_DATE_D}" readOnly="${form_APPLY_DATE_RO}" />
		<e:text>&nbsp;</e:text>
		<e:button id="doApply3" name="doApply3" label="${doApply3_N}" onClick="doApply3" disabled="${doApply3_D}" visible="${doApply3_V}" align="left"/>



        </e:buttonBar>



        <e:gridPanel gridType="${_gridType}" id="gridI" name="gridI" height="280" columnDef="${gridInfos.gridI.gridColData}" />
        </e:searchPanel>

	</e:window>
</e:ui>