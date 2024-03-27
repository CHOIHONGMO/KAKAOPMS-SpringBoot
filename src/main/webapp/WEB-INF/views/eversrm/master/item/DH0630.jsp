<%--
  Date: 2015/11/11
  Time: 17:21:53
  Scrren ID : DH0630(단가변경품의)
--%>
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
    var grid;
    var baseUrl = "/eversrm/master/item/DH0630";
    var selRow;
    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", false);
      grid.setProperty('panelVisible', ${panelVisible});
      //grid Column Head Merge
      grid.setProperty('multiselect', true);

      // Grid Excel Event
      grid.excelExportEvent({
        allCol : "${excelExport.allCol}",
        selRow : "${excelExport.selRow}",
        fileType : "${excelExport.fileType }",
        fileName : "${screenName }",
        excelOptions : {
          imgWidth      : 0.12,
          imgHeight     : 0.26,
          colWidth      : 20,
          rowSize       : 500,
          attachImgFlag : false
        }
      });

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
        // cell one click
        if(selRow == undefined) selRow = rowid;

        switch(celname) {

          case 'multiSelect':
            if(selRow != rowid) {
              grid.checkRow(selRow, false);
              selRow = rowid;
            }

            break;

          case 'ITEM_CD':
            var param = {
              ITEM_CD: grid.getCellValue(rowid, 'ITEM_CD')
            };
            everPopup.openItemDetailInformation(param);

            break;

          case 'VENDOR_CD':
            var params = {
              VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
              paramPopupFlag: true,
              detailView : true
            };
            everPopup.openSupManagementPopup(params);

            break;
        }
      });
      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});

      // 단가현황에서 넘어온 Grid의 데이터 추출
      var data = JSON.stringify(${param.gridList});
   	  if (data != undefined && data.length > 0) {
 	        EVF.getComponent('INFO_LIST').setValue(data);
   	  }
      doSearch();
    }

    // Search
    function doSearch() {
      var store = new EVF.Store();
      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    // Save
    function doSave() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}

      	var sign_status = this.getData();
      	EVF.getComponent("SIGN_STATUS").setValue(sign_status);

      	var store = new EVF.Store();
      	// form validation Check
      	if(!store.validate()) return;

      	// grid 전체 체크
      	grid.checkAll(true);
      	if(!grid.validate().flag) { return alert("${msg.M0014}"); }
      	var selRowsI = grid.getSelRowValue();
        for (k = 0; k < selRowsI.length; k++) {
        	if (selRowsI[k].VALID_FROM_DATE > selRowsI[k].VALID_TO_DATE) {
        		alert('${DH0630_0012}');
        		return;
        	}
        }

      	store.setGrid([grid]);
      	store.getGridData(grid, 'sel');
      	if(sign_status == "T") {
        	if (!confirm("${msg.M0021}")) return;
      	} else {
        	if (!confirm("${msg.M0053}")) return;
      	}

      	var userwidth  = 810; // 고정(수정하지 말것)
	  	var userheight = (screen.height - 2);
	  	if (userheight < 780) userheight = 780; // 최소 780
      	var LeftPosition = (screen.width-userwidth)/2;
      	var TopPosition  = (screen.height-userheight)/2;
      	var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;


		if (sign_status == 'P') { //결재요청일 경우

			var param = {
				subject: EVF.C('EXEC_SUBJECT').getValue(),
				docType: "INFOCH",
				signStatus: "P",
				screenId: "DH0630",
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
	            location.href=baseUrl+'/view.so?EXEC_NUM='+this.getParameter("EXEC_NUM");
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

      	store.setGrid([grid]);
      	store.getGridData(grid, 'sel');
	  	store.doFileUpload(function() {
		   	store.load(baseUrl + "/doSave", function() {
		        alert(this.getResponseMessage());
		        opener.doSearch();
  		        location.href=baseUrl+'/view.so?EXEC_NUM='+this.getParameter("EXEC_NUM");
  		        window.close();
    		});
		});
 	}





    // Delete
    function doDelete() {
		if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
			alert('${msg.M0123}');
			return;
		}

      	if (EVF.C("EXEC_NUM").getValue() == "") {
		  	return;
      	}

      	if (!confirm("${msg.M0013 }")) return;

      	var store = new EVF.Store();
      	store.setGrid([grid]);
      	store.getGridData(grid, 'sel');
      	store.load(baseUrl + '/doDelete', function(){
        	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

        	alert(this.getResponseMessage());

        	opener.doSearch();
        	window.close();
      	});
    }

    function doSearchBuyer() {
      var param = {
        callBackFunction: "_setBuyer"
      };
      everPopup.openCommonPopup(param, 'SP0040');
    }

    function _setBuyer(data) {
      EVF.C("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
      EVF.C("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
    }

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

  </script>

  <e:window id="DH0630" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <form id="formData" name="formData" method="post">
	<e:buttonBar width="100%" align="right">
      <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}" data="T"/>
      <e:button id="doApprovalReq" name="doApprovalReq" label="${doApprovalReq_N}" onClick="doSave" disabled="${doApprovalReq_D}" visible="${doApprovalReq_V}" data="P"/>
      <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
      <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
      <!--
      <e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doSave" disabled="${doApproval_D}" visible="${doApproval_V}" data="E"/>
      -->
    </e:buttonBar>

    <e:searchPanel id="form" title="${DH0630_GENERAL_INFO}" labelWidth="135" width="100%" columnCount="2" useTitleBar="true" onEnter="doSearch">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

      	<e:inputHidden id="INFO_LIST" name="INFO_LIST" />
      	<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}"/>
      	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${empty form.BUYER_CD ? ses.companyCd : form.BUYER_CD}"/>
      	<e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD" value="${empty form.PUR_ORG_CD ? param.PUR_ORG_CD : form.PUR_ORG_CD}"/>
      	<e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}"/>
      	<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${form.APP_DOC_NUM}"/>
      	<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${form.APP_DOC_CNT}"/>
      	<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"/>
      	<e:inputHidden id="EXEC_TYPE" name="EXEC_TYPE" value="${form.EXEC_TYPE}"/>
      	<e:inputHidden id="PURCHASE_TYPE_NM" name="PURCHASE_TYPE_NM" value="부자재"/>

        <e:inputHidden id="approvalFormData" name="approvalFormData"/>
    	<e:inputHidden id="approvalGridData" name="approvalGridData"/>
    	<e:inputHidden id="attachFileDatas" name="attachFileDatas"/>


      <e:row>
        <%--품의번호--%>
        <e:label for="EXEC_NUM" title="${form_EXEC_NUM_N}"/>
        <e:field>
          <e:inputText id="EXEC_NUM" style="ime-mode:inactive" name="EXEC_NUM" value="${form.EXEC_NUM}" width="${inputTextWidth}" maxLength="${form_EXEC_NUM_M}" disabled="${form_EXEC_NUM_D}" readOnly="${form_EXEC_NUM_RO}" required="${form_EXEC_NUM_R}"/>
        </e:field>
        <%--구매유형--%>
        <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
        <e:field>
          <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE }" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
        </e:field>
      </e:row>
      <e:row>
        <%--품의명--%>
        <e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}"/>
        <e:field colSpan="3">
          	<e:inputText id="EXEC_SUBJECT" style="ime-mode:auto" name="EXEC_SUBJECT" value="${form.EXEC_SUBJECT}" width="100%" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--품의일자--%>
        <e:label for="EXEC_DATE" title="${form_EXEC_DATE_N}"/>
        <e:field>
          <e:inputDate id="EXEC_DATE" name="EXEC_DATE" value="${defaultDate}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_R}" disabled="${form_EXEC_DATE_D}" readOnly="${form_EXEC_DATE_RO}" />
        </e:field>
        <%--구매담당자--%>
        <e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}"/>
        <e:field>
          <e:search id='CTRL_USER_NM' name="CTRL_USER_NM" value='${empty form.CTRL_USER_NM ? ses.userNm : form.CTRL_USER_NM}' width='${inputTextWidth }' required='${form_CTRL_USER_NM_R }' readOnly='true' disabled='${form_CTRL_USER_NM_D }' visible='${form_CTRL_USER_NM_V }' maxLength="${form_CTRL_USER_NM_M}" />
          <e:inputHidden id='CTRL_USER_ID' name="CTRL_USER_ID" value='${empty CTRL_USER_ID ? ses.userId : form.CTRL_USER_ID}' />
        </e:field>
      </e:row>
      <e:row>
        <%--특기사항--%>
        <e:label for="RMK_TEXT_NUM_TEXT" title="${form_RMK_TEXT_NUM_TEXT_N}" />
        <e:field colSpan="3">
          <e:richTextEditor id="RMK_TEXT_NUM_TEXT" value="${form.RMK_TEXT_NUM_TEXT }"  height="150px" name="RMK_TEXT_NUM_TEXT" width="100%" required="${form_RMK_TEXT_NUM_TEXT_R }" readOnly="${form_RMK_TEXT_NUM_TEXT_RO }" disabled="${form_RMK_TEXT_NUM_TEXT_D }" />
        </e:field>
      </e:row>
      <e:row>
        <%--파일첨부--%>
        <e:label for="" title="${form_ATT_FILE_NUM_N}" />
        <e:field colSpan="3">
          <e:fileManager id="ATT_FILE_NUM" height="120px" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${param.detailView == true ? true : false}" bizType="EXEC" required="${form_ATT_FILE_NUM_R}" />
        </e:field>
      </e:row>
    </e:searchPanel>

    <e:searchPanel id="form2" title="${DH0630_ITEM_INFO}" labelWidth="${labelWidth}" labelAlign="${labelAlign}">
      <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:searchPanel>
  </form>
  </e:window>
</e:ui>
