<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/rq/RQ0340P02";
	    var grid;


	    function init() {
	        grid = EVF.C("grid");
			grid.setProperty("shrinkToFit", false);        			// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});

		    grid.setColMerge(['PR_BUYER_CD']);
		    grid.setColMerge(['ITEM_CD']);
		    grid.setColMerge(['ITEM_DESC']);
		    grid.setColMerge(['ITEM_SPEC']);
		    grid.setColMerge(['CUR']);
		    grid.setColMerge(['UNIT_CD']);
		    /*grid.setColMerge(['RFX_QT']);
		    grid.setColMerge(['RFX_PRC']);
		    grid.setColMerge(['RFX_AMT']);*/

		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
		    		let param;
		    	if(colId == "BATT_FILE_CNT") {
					 param = {
							detailView: true,
							attFileNum: grid.getCellValue(rowId, "BATT_FILE_NUM"),
							rowId: rowId,
							callBackFunction: "setAttFile",
							bizType: "RQ",
							fileExtension: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		    	} else if(colId == "SATT_FILE_CNT") {
				     param = {
							detailView: true,
							attFileNum: grid.getCellValue(rowId, "SATT_FILE_NUM"),
							rowId: rowId,
							callBackFunction: "setAttFile",
							bizType: "RQ",
							fileExtension: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
		    	} else if(colId === "SLT_RMK") {
				     param = {
					      rowId: rowId
					    , havePermission: true
					    , screenName: '비고'
					    , callBackFunction: 'callback_setSltRmk'
					    , TEXT_CONTENTS: grid.getCellValue(rowId, "SLT_RMK")
					    , detailView: false
				    };
				    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);

			    } else if(colId === 'QTA_NUM'){
				     param = {
					     QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')
					    ,popupFlag : true
					    ,detailView : true
				    };
				    everPopup.openPopupByScreenId('QT0320', 1200, 900, param);
				} else if(colId === 'BRMK'){
				     param = {
					    rowId: rowId
					    , havePermission: false
					    , screenName: '비고'
					    , callBackFunction: ''
					    , TEXT_CONTENTS: grid.getCellValue(rowId, "BRMK")
					    , detailView: true
				    };
				    everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
			    } else if(colId === 'SRMK'){
		             param = {
		                      rowId: rowId
		                    , havePermission: false
		                    , screenName: '비고'
		                    , callBackFunction: ''
		                    , TEXT_CONTENTS: grid.getCellValue(rowId, "SRMK")
		                    , detailView: true
		                };
		           everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}
		    });

	        grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
	        	if(colId == "SLT_FLAG") {
        			for (var i = 0; i < grid.getRowCount(); i++) {
        	        	var iRFX_NUM  = grid.getCellValue(i, 'RFX_NUM');
        	        	var iRFX_CNT  = grid.getCellValue(i, 'RFX_CNT');
        	        	var iRFX_SQ   = grid.getCellValue(i, 'RFX_SQ');

    	        		if(grid.getCellValue(rowId, 'RFX_NUM') == iRFX_NUM && grid.getCellValue(rowId, 'RFX_CNT') == iRFX_CNT && grid.getCellValue(rowId, 'RFX_SQ') == iRFX_SQ){
            				grid.setCellValue(i, 'SLT_FLAG','0');
    	        		}

                    }
        			grid.setCellValue(rowId, 'SLT_FLAG',value);
	        	}
		    });

		    if(EVF.V('SLT_FLAG')==='0'){
			    EVF.V('APP_DOC_NUM','');
			    EVF.V('APP_DOC_CNT','');
		    }

		    $('#RFX_NUM').click(function(){
			    var param = {
				    BUYER_CD   : EVF.V('BUYER_CD')
				    ,RFX_NUM   : EVF.V('RFX_NUM')
				    ,RFX_CNT     : EVF.V('RFX_CNT')
				    ,detailView : true
			    };
			    everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);
		    });

			doSearch();
	    }

	    function callback_setSltRmk(text, rowId) {

	    	EVF.confirm('${RQ0340P02_0008}', function(){

			    var vendorCd = grid.getCellValue(rowId, 'VENDOR_CD');
			    var slt = grid.getCellValue(rowId, 'SLT_FLAG');

	    		var allgid = grid.getAllRowId();
	    		for(var i in allgid){
					var rowVendorCd = grid.getCellValue(i, 'VENDOR_CD');
				    var rowSlt = grid.getCellValue(i, 'SLT_FLAG');
	    			if(vendorCd === rowVendorCd && slt === rowSlt){
					    grid.setCellValue(i, 'SLT_RMK', text);
					}
				}
			});
		    grid.setCellValue(rowId, 'SLT_RMK', text);
	    }

	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);
	        store.load(baseUrl + "/doSearch", function() {
		        setBgColor();
		        <c:if test="${(form.SLT_FLAG == '0' && form.PROGRESS_CD == '2500') || (form.PROGRESS_CD == '2400' && form.SIGN_STATUS2 != 'P')}">
		        if(grid.getRowCount() === 0){
			        EVF.C('doSettle').setVisible(false);
		        }
				</c:if>
	        });
        }

        function setBgColor(){
	        var allgrid = grid.getAllRowValue();
	        var bgPink = '#FFECFF';
	        var cnt = 0;
	        for(var i in allgrid){
		        if(allgrid[i].SLT_FLAG === '1'){
			        grid.setCellBgColor(i,'RFX_AMT',bgPink);
			        grid.setCellBgColor(i,'RANK',bgPink);
			        grid.setCellBgColor(i,'VENDOR_CD',bgPink);
			        grid.setCellBgColor(i,'VENDOR_NM',bgPink);
			        cnt++;
		        }
	        }
			var bgBlue = '#DFF0FF';
	        if(cnt===0){
		        for(var i in allgrid){
			        if(allgrid[i].RANK === '1'){
			        	grid.setCellValue(i,'SLT_FLAG','1')
				        grid.setCellBgColor(i,'RFX_AMT',bgBlue);
				        grid.setCellBgColor(i,'RANK',bgBlue);
				        grid.setCellBgColor(i,'VENDOR_CD',bgBlue);
				        grid.setCellBgColor(i,'VENDOR_NM',bgBlue);
					}else{
						grid.setCellValue(i,'SLT_FLAG','0')
						if(allgrid[i].QTA_YN =='0'){
							grid.setCellReadOnly(i, "SLT_FLAG", true);
						}
					}
		        }
			}
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

        function doClose() {
     		if(opener != null) {
     			//opener.doSearch();
     			window.close();
     		} else {
     			//parent.doSearch();
     			new EVF.ModalWindow().close(null);
     		}
        }

        //재견적
		function doReRfq() {
			var param = {
				BUYER_CD   : '${form.BUYER_CD}'
				,RFX_NUM   : '${form.RFX_NUM}'
				,RFX_CNT   : '${form.RFX_CNT}'
				,baseDataType: "RERFX"
				,detailView: false
			};
			everPopup.openPopupByScreenId('RQ0310', 1200, 900, param);
		}

		//유찰
		function doCancelRfq() {
			if (!confirm("${RQ0340P02_0003}")) return;
    		var store = new EVF.Store();
    		store.load(baseUrl + '/doCancelRfq', function(){
        		alert(this.getResponseMessage());
			    doClose2();
        	});
		}

		//협력업체 선정
		function doSettle() {
	        var countAward = 0;
	        for (var i = 0; i < grid.getRowCount(); i++) {
	        	var iRFX_NUM  = grid.getCellValue(i, 'RFX_NUM');
	        	var iRFX_CNT  = grid.getCellValue(i, 'RFX_CNT');
	        	var iRFX_SQ   = grid.getCellValue(i, 'RFX_SQ');

        		//품목별 업체선정여부 체크
	        	var countAward = 0;
	        	for (var j = 0; j < grid.getRowCount(); j++) {
	        		if(grid.getCellValue(j, 'SLT_FLAG') == "1" && grid.getCellValue(j, 'UNIT_PRC') == "0"){
						return alert('${RQ0340P02_0009}'); //제출한 단가가 ＂0＂(견적포기)인 경우 선정할 수 없습니다.
					}

// 	        		console.log(grid.getCellValue(j, 'SLT_FLAG') +":::"+j+":: SLT_FLAG")
// 	        		console.log(grid.getCellValue(j, 'RFX_NUM') +":::"+j+":: iRFX_NUM"+"::"+iRFX_NUM)
// 	        		console.log(grid.getCellValue(j, 'RFX_CNT') +":::"+j+":: RFX_CNT"+"::"+iRFX_CNT)
// 	        		console.log(grid.getCellValue(j, 'RFX_SQ') +":::"+j+":: RFX_SQ"+"::"+iRFX_SQ)
	        		if(grid.getCellValue(j, 'SLT_FLAG') == "1" && grid.getCellValue(j, 'RFX_NUM') == iRFX_NUM && grid.getCellValue(j, 'RFX_CNT') == iRFX_CNT && grid.getCellValue(j, 'RFX_SQ') == iRFX_SQ){
	        			countAward++;
	        		}

	        		if(grid.getCellValue(j, 'SLT_FLAG') == "1" && grid.getCellValue(j, 'RANK') != "1" && grid.getCellValue(j, 'SLT_RMK') == ""){
						return alert('${RQ0340P02_0006}'); //선택된 협력업체 품목의 순위가 1위가 아닌 경우 선정사유를 필수로 등록해야 합니다.
					}
	        	}

	        	if (countAward > 1) {
	        		alert('${RQ0340P02_0004}'); //업체선정여부는 한건만 입력하시기 바랍니다.
	                return;
	            }

	        	if (countAward == 0 && grid.getCellValue(i, 'QTA_YN') !="0") {
	        		alert('${RQ0340P02_0005}'); //품목별로 한 업체를 꼭 선정하셔야 합니다.
	                return;
	            }
	        }

	        /* for (var i = 0; i < grid.getRowCount(); i++) {
	        	if(grid.getCellValue(i, 'AWARD') == "1" && grid.getCellValue(i, 'SETTLE_RMK').text == ''
	        		&& grid.getCellValue(i, 'PRICE_RANK') != '1'
	        	){
	        		alert(everString.getMessage("${msg.M0109}", "선정사유")); return;//선정사유는 필수입력사항입니다.
	        	}
	        } */

			if (!confirm("${RQ0340P02_0002}")) return;

			//doSign();
    		/*var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid,'all');
    		store.load(baseUrl + '/doItemSettle', function(){
        		alert(this.getResponseMessage());
        		doClose();
        	});*/

			EVF.V('SIGN_STATUS','E');
			doSave();
		}

	    function doSign() {

		    grid.checkAll(true);

		    EVF.V("SIGN_STATUS", "P");
		    param = {
			    subject: EVF.V("RFX_SUBJECT"),
			    docType: "EXEC2",
			    signStatus: "P",
			    screenId: "RQ0340P01",
			    approvalType: 'APPROVAL',
			    oldApprovalFlag: EVF.V("SIGN_STATUS"),
			    attFileNum: "",
			    docNum: EVF.V("RFX_NUM"),
			    appDocNum: EVF.V("APP_DOC_NUM"),
			    callBackFunction: "doSave"
		    };
		    everPopup.openApprovalRequestIIPopup(param);
	    }

	    function doSave(formData, gridData, attachData){

		    EVF.V("approvalFormData", formData);
		    EVF.V("approvalGridData", gridData);
		    //EVF.V("attachFileDatas", attachData);

		    var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid,'all');
    		store.load(baseUrl + '/doItemSettle', function(){
        		alert(this.getResponseMessage());
			    doClose2();
        	});
		}

	    //견적비교
	    function doCompareQta(){
		    var param = {
			    BUYER_CD   : EVF.V('BUYER_CD')
			    ,RFX_NUM   : EVF.V('RFX_NUM')
			    ,RFX_CNT   : EVF.V('RFX_CNT')
			    ,detailView: false
		    };
		    everPopup.openPopupByScreenId('RQ0340P03', 1200, 600, param);
	    }

	    //결재List
		function doApprovalList(){
			if(EVF.isEmpty(EVF.V("APP_DOC_NUM")) || EVF.isEmpty(EVF.V("APP_DOC_CNT"))){ return alert("${RQ0340P02_0007}");}
			var params = {
				GATE_CD : ${ses.gateCd},
				APP_DOC_NUM : EVF.V("APP_DOC_NUM"),
				APP_DOC_CNT : EVF.V("APP_DOC_CNT"),
				from : "mailBox",
				callBackFunction: ""
			};
			everPopup.approvalPathSearchPopup(params);
		}


	</script>

	<e:window id="RQ0340P02" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
        <e:searchPanel id="form" title="견적비교(자재별)" labelWidth="150" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
			<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS2}" />
			<e:inputHidden id='APP_DOC_NUM' name="APP_DOC_NUM" value="${empty param.appDocNum ? form.APP_DOC_NUM2 : param.appDocNum}" />
			<e:inputHidden id='APP_DOC_CNT' name="APP_DOC_CNT" value="${empty param.appDocCnt ? form.APP_DOC_CNT2 : param.appDocCnt}" />

			<e:inputHidden id="approvalFormData" name="approvalFormData"/>
			<e:inputHidden id="approvalGridData" name="approvalGridData"/>
			<e:inputHidden id="SLT_FLAG" name="SLT_FLAG" value="${form.SLT_FLAG}" />

			<e:row>
				<%--견적요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" style="color:blue; cursor:pointer" />
					<e:text> / </e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
            </e:row>
            <e:row>
				<%--견적명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
				<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--견적기간--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:text> ${form.RFX_FROM_DATE2} </e:text>
					<e:text> ~ </e:text>
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

		<c:if test="${(form.SLT_FLAG == '0' && form.PROGRESS_CD == '2500') || (form.PROGRESS_CD == '2400' && form.SIGN_STATUS2 != 'P')}">
			<e:button id="doSettle" name="doSettle" label="${doSettle_N}" onClick="doSettle" disabled="${doSettle_D}" visible="${doSettle_V}"/>
			<e:button id="doReRfq" name="doReRfq" label="${doReRfq_N}" onClick="doReRfq" disabled="${doReRfq_D}" visible="${doReRfq_V}"/>
			<e:button id="doCancelRfq" name="doCancelRfq" label="${doCancelRfq_N}" onClick="doCancelRfq" disabled="${doCancelRfq_D}" visible="${doCancelRfq_V}"/>
		</c:if>
		<%--
		<c:if test="${form.SIGN_STATUS2 == 'P' || form.SIGN_STATUS2 == 'E'}">
			<e:button id="doApprovalList" name="doApprovalList" label="${doApprovalList_N}" onClick="doApprovalList" disabled="${doApprovalList_D}" visible="${doApprovalList_V}"/>
		</c:if>
		--%>
			<e:button id="doCompareQta" name="doCompareQta" label="${doCompareQta_N}" onClick="doCompareQta" disabled="${doCompareQta_D}" visible="${doCompareQta_V}"/>
			<%--
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
			--%>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>