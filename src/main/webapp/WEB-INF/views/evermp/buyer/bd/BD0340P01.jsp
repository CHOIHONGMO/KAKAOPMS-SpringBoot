<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0340P01";
	    var grid;
	    var gridV;


	    function init() {
	        grid = EVF.C("grid");
			grid.setProperty("shrinkToFit", false);        			// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

	        gridV = EVF.C("gridV");
	        gridV.setProperty("shrinkToFit", false);        			// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
	        gridV.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
	        gridV.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
	        gridV.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
	        gridV.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
	        gridV.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
	        gridV.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			gridV.excelExportEvent({
				allCol   : "${excelOption.allCol}",
				selRow   : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});

			grid.excelExportEvent({
				allCol   : "${excelOption.allCol}",
				selRow   : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});

		    gridV.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
		    	 if(colId === 'QTA_NUM' && value !== ''){
				     var param = {
					      QTA_NUM     : gridV.getCellValue(rowId,'QTA_NUM')
						 ,QTA_CNT     : gridV.getCellValue(rowId,'QTA_CNT')
					     ,popupFlag : true
					     ,detailView : true
				     };
				     everPopup.openPopupByScreenId('BQ0320', 1200, 900, param);
				 } else if(colId === 'SLT_RMK'){
			            var param = {
			                      rowId: rowId
			                    , havePermission: true
			                    , screenName: '비고'
			                    , callBackFunction: 'setSltRmk'
			                    , TEXT_CONTENTS: gridV.getCellValue(rowId, "SLT_RMK")
			                    , detailView: false
			                };
			           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				 } else if(colId === 'VENDOR_NM'){
				     EVF.getComponent("QTA_NUM").setValue(gridV.getCellValue(rowId,'QTA_NUM'));
				     EVF.getComponent("QTA_CNT").setValue(gridV.getCellValue(rowId,'QTA_CNT'));
				     doSearchItem();
				 }
		    });

	        gridV.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

			    if (colId === "SLT_FLAG") {
				    for (var i = 0; i < gridV.getRowCount(); i++) {
						gridV.setCellValue(i, 'SLT_FLAG', '0');
				    }
				   	gridV.setCellValue(rowId, 'SLT_FLAG', value);
			    }
		    });

		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

		    	if(colId == "BATT_FILE_CNT") {
					param = {
							detailView		: true,
							attFileNum		: grid.getCellValue(rowId, "BATT_FILE_NUM"),
							rowId			: rowId,
							callBackFunction: "setAttFile",
							bizType			: "BD",
							fileExtension	: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		    	} else if(colId == "SATT_FILE_CNT") {
					param = {
							detailView		: true,
							attFileNum		: grid.getCellValue(rowId, "SATT_FILE_NUM"),
							rowId			: rowId,
							callBackFunction: "setAttFile",
							bizType			: "BD",
							fileExtension	: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		    	} else if(colId === 'BRMK'){
		            var param = {
		                      rowId				: rowId
		                    , havePermission	: false
		                    , screenName		: '비고'
		                    , callBackFunction	: ''
		                    , TEXT_CONTENTS		: grid.getCellValue(rowId, "BRMK")
		                    , detailView		: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				} else if(colId === 'SRMK'){
		            var param = {
		                      rowId				: rowId
		                    , havePermission	: false
		                    , screenName		: '비고'
		                    , callBackFunction	: ''
		                    , TEXT_CONTENTS		: grid.getCellValue(rowId, "SRMK")
		                    , detailView		: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}

		    });


		    if(EVF.V('SLT_FLAG')==='0'){
		    	EVF.V('APP_DOC_NUM','');
		    	EVF.V('APP_DOC_CNT','');
		    }

		    $('#RFX_NUM').click(function(){
			    var param = {
				    BUYER_CD    : EVF.V('BUYER_CD')
				    ,RFX_NUM    : EVF.V('RFX_NUM')
				    ,RFX_CNT    : EVF.V('RFX_CNT')
				    ,detailView : true
			    };
			    everPopup.openPopupByScreenId('BD0310', 1200, 900, param);
			});

			doSearch();
	    }

	    function setSltRmk(text, rowId) {
			gridV.setCellValue(rowId, 'SLT_RMK', text);
	    }

	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;
	        store.setGrid([gridV]);
	        store.load(baseUrl + "/doSearchDocVendor", function() {
		        setBgColor();
		        setSltResult();
		        <c:if test="${(form.SLT_FLAG == '0' && form.PROGRESS_CD == '2900') || (form.PROGRESS_CD == '2800' && form.SIGN_STATUS2 != 'P')}">
			        if(gridV.getRowCount() === 0){
				        EVF.C('doReRfq').setVisible(false);
				        EVF.C('doSettle').setVisible(false);
			        }
				</c:if>
	        });
        }

	    function setBgColor(){
		    var allgrid = gridV.getAllRowValue();
		    var bgPink = '#FFECFF';
		    var cnt = 0;
		    for(var i in allgrid){
			    if(allgrid[i].SLT_FLAG === '1'){
				    gridV.setCellBgColor(i,'RFX_AMT',bgPink);
				    gridV.setCellBgColor(i,'RANK',bgPink);
				    gridV.setCellBgColor(i,'VENDOR_CD',bgPink);
				    gridV.setCellBgColor(i,'VENDOR_NM',bgPink);
				    cnt++;
			    }
		    }
		    var bgBlue = '#DFF0FF';
		    if(cnt===0){
			    for(var i in allgrid){
				    if(allgrid[i].RANK === '1'){
					    gridV.setCellBgColor(i,'RFX_AMT',bgBlue);
					    gridV.setCellBgColor(i,'RANK',bgBlue);
					    gridV.setCellBgColor(i,'VENDOR_CD',bgBlue);
					    gridV.setCellBgColor(i,'VENDOR_NM',bgBlue);
				    }
			    }
		    }
	    }

	    function setSltResult(){
		    var allgrid = gridV.getAllRowValue();
		    for(var i in allgrid){
		    	if(allgrid[i].QTA_YN === 'N') {
		    		gridV.checkRow(i, false);
		    	} else {
				    if(allgrid[i].RANK === '1'){
					    gridV.setCellValue(i, 'SLT_FLAG','1');
				    }else{
					    gridV.setCellValue(i, 'SLT_FLAG','0');
				    }
		    	}
		    }
	    }

	    function doSearchItem() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;
	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearchDocItem", function() {
	        	
	        });
        }

	    //재입찰
	    function doReRfq() {
		    var rebidOb = '';
		    if(EVF.V('VENDOR_OPEN_TYPE') === 'OB'){
			    rebidOb = 'ReBid_OB';
		    }

		    var param = {
			     BUYER_CD   	: '${form.BUYER_CD}'
			    ,RFX_NUM    	: '${form.RFX_NUM}'
			    ,RFX_CNT    	: '${form.RFX_CNT}'
			    ,ReBid_OB		: rebidOb
				,baseDataType 	: "RERFX"
			    ,detailView 	: false
		    };
		    everPopup.openPopupByScreenId('BD0310', 1200, 900, param);
	    }


		//협력업체선정
		function doSettle() {
			var settleCou = 0;
			for (var i = 0; i < gridV.getSelRowCount(); i++) {
				if(gridV.getCellValue(i,'QTA_YN') !== 'Y') {
					return alert("${BD0340P01_0008}");
				}
				if(gridV.getCellValue(i,'SLT_FLAG') === '1') {
					var rank   = gridV.getCellValue(i,'RANK');
					var sltRmk = everString.lrTrim(gridV.getCellValue(i,'SLT_RMK'));
					if(rank !== '1' && sltRmk === ''){
						return alert('${BD0340P01_0002}'); //"최저가"가 아닌 경우 : 선택된 협력업체의 순위가 1위가 아닌 경우 선정사유를 필수로 등록해야 합니다.
					}
					
					EVF.getComponent("QTA_NUM").setValue(gridV.getCellValue(i,'QTA_NUM'));
					EVF.getComponent("QTA_CNT").setValue(gridV.getCellValue(i,'QTA_CNT'));
					EVF.getComponent("SLT_RMK").setValue(gridV.getCellValue(i,'SLT_RMK'));
					
					settleCou++;
				}
            }
			
			if(settleCou === 0) {
				return alert('${BD0340P01_0003}'); 	//선정된 협력업체가 없습니다.
			}
			if (!confirm("${BD0340P01_0004}")) { 	//선택된 협력업체로 업체선정 품의를 진행 하시겠습니까?
				return;
			}

			//doSign();
    		/*var store = new EVF.Store();
    		store.load(baseUrl + '/doDocSettle', function(){
        		alert(this.getResponseMessage());
        		doClose2();
        	});*/
			EVF.V('SIGN_STATUS','E');
        	
			doSave();
		}

	    function doSign() {

		    gridV.checkAll(true);

		    EVF.V("SIGN_STATUS", "P");
			param = {
					subject			: EVF.V("RFX_SUBJECT"),
					docType			: "EXEC1",
					signStatus		: "P",
					screenId		: "BD0340P01",
					approvalType	: 'APPROVAL',
					oldApprovalFlag	: EVF.V("SIGN_STATUS"),
					attFileNum		: "",
					docNum			: EVF.V("RFX_NUM"),
					appDocNum		: EVF.V("APP_DOC_NUM"),
					callBackFunction: "doSave"
				};
			everPopup.openApprovalRequestIIPopup(param);
	    }

	    function doSave(formData, gridData, attachData){

		    EVF.V("approvalFormData", formData);
		    EVF.V("approvalGridData", gridData);
		    //EVF.V("attachFileDatas", attachData);
		    EVF.V("SIGN_STATUS", "E");

		    var store = new EVF.Store();
		    store.setGrid([gridV]);
		    store.getGridData(gridV,'all');
    		store.load(baseUrl + '/doDocSettle', function(){
        		alert(this.getResponseMessage());
			    doClose2();
        	});
		}

		//유찰
		function doCancelRfq() {
			if (!confirm("${BD0340P01_0005}")) return;
    		var store = new EVF.Store();
    		store.load(baseUrl + '/doCancelRfq', function(){
        		alert(this.getResponseMessage());
			    doClose2();
        	});
		}

		//견적비교
		function doCompareQta(){
			var param = {
				BUYER_CD    : EVF.V('BUYER_CD')
				,RFX_NUM    : EVF.V('RFX_NUM')
				,RFX_CNT    : EVF.V('RFX_CNT')
				,detailView : false
			};
			everPopup.openPopupByScreenId('BD0340P03', 1200, 600, param);
		}

	    function doClose2() {
		    if(opener != null) {
			    opener.doSearch();
			    window.close();
		    } else {
			    parent.doSearch();
			    new EVF.ModalWindow().close(null);
		    }
	    }

	    //닫기
	    function doClose() {
		    if(opener != null) {
			    //opener.doSearch();
			    window.close();
		    } else {
			    //parent.doSearch();
			    new EVF.ModalWindow().close(null);
		    }
	    }

	    //결재List
	    function doApprovalList(){
		    if(EVF.isEmpty(EVF.V("APP_DOC_NUM")) || EVF.isEmpty(EVF.V("APP_DOC_CNT"))){ return alert("${BD0340P01_0007}");}
		    var params = {
			    GATE_CD : ${ses.gateCd},
			    APP_DOC_NUM 	: EVF.V("APP_DOC_NUM"),
			    APP_DOC_CNT 	: EVF.V("APP_DOC_CNT"),
			    from 			: "mailBox",
			    callBackFunction: ""
		    };
		    everPopup.approvalPathSearchPopup(params);
	    }

	</script>

	<e:window id="BD0340P01" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${BD0340P01_labelTitle}" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
			<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS2}" />
			<e:inputHidden id='APP_DOC_NUM' name="APP_DOC_NUM" value="${empty param.appDocNum ? form.APP_DOC_NUM2 : param.appDocNum}" />
			<e:inputHidden id='APP_DOC_CNT' name="APP_DOC_CNT" value="${empty param.appDocCnt ? form.APP_DOC_CNT2 : param.appDocCnt}" />

			<e:inputHidden id="approvalFormData" name="approvalFormData"/>
			<e:inputHidden id="approvalGridData" name="approvalGridData"/>
        	<e:inputHidden id="QTA_NUM" name="QTA_NUM" value=""/>
			<e:inputHidden id="QTA_CNT" name="QTA_CNT" value=""/>
        	<e:inputHidden id="SLT_RMK" name="SLT_RMK" value=""/>
			<e:inputHidden id="SLT_FLAG" name="SLT_FLAG" value="${form.SLT_FLAG}" />

			<e:row>
				<%--견적요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}"  style="color:blue; cursor:pointer" />
					<e:text>&nbsp;/&nbsp;</e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--견적명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--입찰기간--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:text> ${form.RFX_FROM_DATE2} </e:text>
					<e:text>&nbsp;~&nbsp;</e:text>
					<e:text> ${form.RFX_TO_DATE2} </e:text>
				</e:field>
            </e:row>
            <e:row>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
				<%--선정방식--%>
				<e:label for="PRC_SLT_TYPE" title="${form_PRC_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="PRC_SLT_TYPE" name="PRC_SLT_TYPE" value="${form.PRC_SLT_TYPE}" options="${prcSltTypeOptions}" width="${form_PRC_SLT_TYPE_W}" disabled="${form_PRC_SLT_TYPE_D}" readOnly="${form_PRC_SLT_TYPE_RO}" required="${form_PRC_SLT_TYPE_R}" placeHolder="" />
					<e:text>/</e:text>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${form.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>


        </e:searchPanel>

        <e:buttonBar align="right">

		<c:if test="${(form.SLT_FLAG == '0' && form.PROGRESS_CD == '2900') || (form.PROGRESS_CD == '2800' && form.SIGN_STATUS2 != 'P')}">
			<e:button id="doReRfq" name="doReRfq" label="${doReRfq_N}" onClick="doReRfq" disabled="${doReRfq_D}" visible="${doReRfq_V}"/>
			<e:button id="doSettle" name="doSettle" label="${doSettle_N}" onClick="doSettle" disabled="${doSettle_D}" visible="${doSettle_V}"/>
			<e:button id="doCancelRfq" name="doCancelRfq" label="${doCancelRfq_N}" onClick="doCancelRfq" disabled="${doCancelRfq_D}" visible="${doCancelRfq_V}"/>
		</c:if>
		<%--<c:if test="${form.SIGN_STATUS2 == 'P' || form.SIGN_STATUS2 == 'E'}">
			<e:button id="doApprovalList" name="doApprovalList" label="${doApprovalList_N}" onClick="doApprovalList" disabled="${doApprovalList_D}" visible="${doApprovalList_V}"/>
		</c:if>--%>
			<e:button id="doCompareQta" name="doCompareQta" label="${doCompareQta_N}" onClick="doCompareQta" disabled="${doCompareQta_D}" visible="${doCompareQta_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="gridV" name="gridV" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.gridV.gridColData}"/>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>