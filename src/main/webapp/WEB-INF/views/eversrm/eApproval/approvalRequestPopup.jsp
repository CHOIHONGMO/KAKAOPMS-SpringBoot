<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var gridL = {};
    	var gridR = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/eApproval/";
    	var checkRow = -1;
    	var isDevelopmentMode = "";

		function init() {

			gridL = EVF.C('gridL');
			gridR = EVF.C('gridR');

            gridL.cellChangeEvent(function(rowid, celName, iRow, iCol, value, oldValue) {
                if(celName == 'SIGN_REQ_TYPE') {
                    recountSignSequence();
                }
            });

			gridR.cellClickEvent(function(rowid, celName, value, iRow, iCol) {

				if(celName == 'SIGN_USER_NM') {

					var selectedData = gridR.getRowValue(rowid);
					gridR.checkRow(rowid, true);


					var abc = selectedData.SIGN_USER_ID;
					for(var k=0;k < gridL.getRowCount();k++)  {
						if (gridL.getCellValue(k,'SIGN_USER_ID') == abc) {
							alert('동일한 사용자가 이미 결재 경로에 존재합니다.');
							return;
						}
					}

					if(${isDevelopmentMode } == false && ("${ses.userId }" == selectedData.SIGN_USER_ID);) {
						return alert("기안자 본인을 결재경로에 추가할 수 없습니다.");
					}


			<c:if test="${param.approvalType == 'APPROVAL'}">
					var addParam = [{"SIGN_USER_ID": selectedData.SIGN_USER_ID, "SIGN_USER_NM": selectedData.SIGN_USER_NM, "DEPT_CD": selectedData.DEPT_CD, "DEPT_NM": selectedData.DEPT_NM, "POSITION_NM": selectedData.POSITION_NM, "SIGN_REQ_TYPE": (EVF.C('SIGN_REQ_TYPE').getCheckedValue() == null || EVF.C('SIGN_REQ_TYPE').getCheckedValue() == "") ? "1" : EVF.C('SIGN_REQ_TYPE').getCheckedValue()}];
			</c:if>
			<c:if test="${param.approvalType != 'APPROVAL'}">
					var addParam = [{"SIGN_USER_ID": selectedData.SIGN_USER_ID, "SIGN_USER_NM": selectedData.SIGN_USER_NM, "DEPT_CD": selectedData.DEPT_CD, "DEPT_NM": selectedData.DEPT_NM, "POSITION_NM": selectedData.POSITION_NM, "SIGN_REQ_TYPE": "9"}];
			</c:if>

            		gridL.addRow(addParam);
            		fillFixData('add');
            		recountSignSequence();
				}
			});

			if("${param.approvalType }" == "NOTICE") {
				<%--EVF.C('SIGN_REQ_TYPE').setChecked('R4');--%>
				window.resizeTo(1070, 700);
			} else if("${param.approvalType }" == "APPROVAL") {
				window.resizeTo(1070, 790);
			}

			gridL.setProperty('shrinkToFit', true);
			gridR.setProperty('shrinkToFit', true);

			doSearchSync();

        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([gridR]);
            store.load(baseUrl + 'userSearch', function() {
                if(gridR.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
                if(gridR.getRowCount() == 1) {
					EVF.C('SIGN_USER_NM').setValue('');

                	var selectedData = gridR.getRowValue(0);
					gridR.checkRow(0, true);

					if(${isDevelopmentMode } == false && ("${ses.userId }" == selectedData.SIGN_USER_ID);) {
						return alert("기안자 본인을 결재경로에 추가할 수 없습니다.");
					}

			<c:if test="${param.approvalType == 'APPROVAL'}">
					var addParam = [{"SIGN_USER_ID": selectedData.SIGN_USER_ID, "SIGN_USER_NM": selectedData.SIGN_USER_NM, "DEPT_CD": selectedData.DEPT_CD, "DEPT_NM": selectedData.DEPT_NM, "POSITION_NM": selectedData.POSITION_NM, "SIGN_REQ_TYPE": (EVF.C('SIGN_REQ_TYPE').getCheckedValue() == null || EVF.C('SIGN_REQ_TYPE').getCheckedValue() == "") ? "1" : EVF.C('SIGN_REQ_TYPE').getCheckedValue()}];
			</c:if>
			<c:if test="${param.approvalType != 'APPROVAL'}">
					var addParam = [{"SIGN_USER_ID": selectedData.SIGN_USER_ID, "SIGN_USER_NM": selectedData.SIGN_USER_NM, "DEPT_CD": selectedData.DEPT_CD, "DEPT_NM": selectedData.DEPT_NM, "POSITION_NM": selectedData.POSITION_NM, "SIGN_REQ_TYPE": "9"}];
			</c:if>

            		gridL.addRow(addParam);
            		fillFixData('add');
                    recountSignSequence();
                }
            });
        }

        function doSearchSync() {

			if ('${param.USER_IDS}' == '') return;

            var store = new EVF.Store();
		    store.setParameter('USER_IDS', '${param.USER_IDS}');
        	store.setGrid([gridL]);
            store.load(baseUrl + 'doSearchSync', function() {
                recountSignSequence();
				gridR.showCheckBar(false);
            }, true);
        }

        function doApprovalRequest() {

			gridL.checkAll(true);

			if("${param.approvalType }" == 'APPROVAL') {
				if(EVF.getByteLength(EVF.C('SUBJECT').getValue()) > 60) {
					alert("${BAPP_050_M001 }");
					return;
				}
			}

			if (  !${isDevelopmentMode }  ) {
				var kkk = gridL.getSelRowValue();
				for(k=0;  k <   kkk.length;  k++) {
					if (kkk[k].SIGN_REQ_TYPE == '1'  || kkk[k].SIGN_REQ_TYPE == '2' || kkk[k].SIGN_REQ_TYPE == '3'  || kkk[k].SIGN_REQ_TYPE == '7'  || kkk[k].SIGN_REQ_TYPE == '4'     ) {
						if ( kkk[k].SIGN_USER_ID == '${ses.userId}') {
							alert("${BAPP_050_M005}");
							return;
						}
					}
				}
			}

			if("${param.approvalType }" == 'APPROVAL') {
				<%--
				if(EVF.C('OPINION').getValue().length <= 0) {
					alert("${BAPP_050_M003 }");
					return;
				}
				--%>
				if(EVF.getByteLength(EVF.C('OPINION').getValue()) > 1024) {
					alert("${BAPP_050_M004 }");
					return;
				}
			}
			if (gridL.getSelRowId() == null) {
	            alert("${msg.M0004}");
	            return;
	        }

			if (!gridL.validate().flag) { return alert(gridL.validate().msg); }

			if(confirm("${param.approvalType }" == "NOTICE" ? "${msg.M0099 }" : "${msg.M0100 }")) {

				var gridData = gridL.getSelRowValue();

				var store = new EVF.Store();
				if(!store.validate()) return;
				store.doFileUpload(function() {

	                <%-- EVF.C('UUID').setValue(EVF.C('ATT_FILE_NUM').getFileId()); --%>
	        		var formData = {
		                IMPORTANCE_STATUS: EVF.C('IMPORTANCE_STATUS').getValue(),
		                SUBJECT: EVF.C('SUBJECT').getValue(),
		                TEXT_CONTENTS: EVF.C('TEXT_CONTENTS').getValue(),
		                OPINION: EVF.C('OPINION').getValue(),
		                CONTENTS_TEXT_NUM: EVF.C('CONTENTS_TEXT_NUM').getValue(),
		                ATT_FILE_NUM: "",

					<c:if test="${param.approvalType == 'APPROVAL'}">
						SECURITY_TYPE: EVF.C('SECURITY_TYPE').getCheckedValue(),
					</c:if>
					<c:if test="${param.approvalType != 'APPROVAL'}">
						SECURITY_TYPE: EVF.C('SECURITY_TYPE').getValue(),
					</c:if>

		                DOC_NUM: EVF.C('DOC_NUM').getValue(),
		                DOC_TYPE: EVF.C('DOC_TYPE').getValue(),
		                SIGN_STATUS: EVF.C('SIGN_STATUS').getValue(),
		                DOC_ATT_FILE_NUM: EVF.C('DOC_ATT_FILE_NUM').getValue(),
		                SCREEN_ID: EVF.C('SCREEN_ID').getValue(),
		                DOC_SUB_TYPE: EVF.C('DOC_SUB_TYPE').getValue(),
		                APP_DOC_NUM: EVF.C('APP_DOC_NUM').getValue()
		            };
		            var attachData = [{"UUID":EVF.C('UUID').getValue()}];
		            opener.window.focus();
	                opener.window['${param.callBackFunction}'](JSON.stringify(formData), JSON.stringify(gridData), JSON.stringify(attachData));
	       			window.close();
	            });
		    }
        }

        function doClose() {
        	window.close();
        }

        <%-- @description 행 추가/삭제 시 호출된다.
             @param flag add, del
        --%>
		function fillFixData(flag) {
	        fillImgUrl(flag);
	    }

        <%-- 결재 순번 계산 --%>
	    function recountSignSequence() {

            <%-- 병렬타입의 행을 만났는지 여부 --%>
            var isBeforeArrangeAgree = false;
            var isBeforeArrangeApproval = false;
            var rowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
            var selectedRowIdx = [];
            for(var i = 0, pathSq = 0; i < rowIds.length; i++) {
                var rowData = gridL.getRowValue(rowIds[i]);
                var signReqType = rowData['SIGN_REQ_TYPE'];
                <%-- 병렬결재 혹은 병렬합의면 번호를 증가시키지 않는다. --%>
                if(signReqType === '4') {
                    if(!isBeforeArrangeAgree) {
                        pathSq++;
                        isBeforeArrangeAgree = true;
                    }
                } else if(signReqType == '7') {
                    if(!isBeforeArrangeApproval) {
                        pathSq++;
                        isBeforeArrangeApproval = true;
                    }
                } else {
                    pathSq++;
                    isBeforeArrangeAgree = false;
                    isBeforeArrangeApproval = false;
                }

                var checkFlag = rowData['CHECK_FLAG'];
                if(checkFlag == '1') {
                    selectedRowIdx.push(rowIds[i]);
                }

                gridL.setCellValue(rowIds[i], "CHECK_FLAG", "");
                gridL.setCellValue(rowIds[i], 'SIGN_PATH_SQ', pathSq);
            }

            var allRowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
            //gridL.setProperty("setCheckFlag", false);
            for(var i=0; i < allRowIds.length; i++) {
                gridL.setCellValue(allRowIds[i], 'CHECK_FLAG', '');
            }
            //gridL.setProperty("setCheckFlag", true);

			gridL.checkAll(false);

            for(var i=0; i < selectedRowIdx.length; i++) {
                gridL.checkRow(selectedRowIdx[i], true);
            }
	    }

	    function fillImgUrl(flag) {

	        if(flag == 'add') {
		        var rowIds = gridL.jsonToArray(gridL.getSelRowId()).value;
		        for(var i = 0; i < rowIds.length; i++) {
		        	gridL.setCellValue(rowIds[i], 'SIGN_USER_NM_IMG', { src : '/images/icon/grid_search.gif', test : ''});
		        }
	        }
            else {

		    	var checkRowData = gridL.getSelRowId();
	        	var argData = gridL.jsonToArray(checkRowData).value;

				for(var i = 0; i < argData.length; i++) {
		        	gridL.setCellValue(argData[i], 'SIGN_USER_NM_IMG', { src : '/images/icon/grid_search.gif'});
		        }
		    }
	    }

	    function changeSecurity() {
	    	alert(EVF.C('SECURITY_TYPE').getCheckedValue());
	    }

        <%-- 병렬 버튼 --%>
	    function doArranging() {
	    	doChangeArg("A");
	    }

        <%-- 병렬해제 버튼 --%>
	    function doCancelArg() {
	    	doChangeArg("D");
	    }

	    function doChangeArg(argVal) {

			/*
				docSubType - 결재 : 1, 합의 : 2, 후결 : 3, 병렬합의 : 4, 병렬결재 : 7, 통보 : 9
			*/
	        var argData = gridL.jsonToArray(gridL.getSelRowId()).value;

			if (argData.length < 2) {
	            alert("${msg.M0091 }");
	            return;
	        }
	        <!-- 병렬 -->
	        if(argVal == "A") {

				for(var i = 0; i < argData.length; i++) {

					if(gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE') != "1" && gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE') != "2") {
			        	alert("${msg.M0092 }");
			        	return;
			        }
				}

		        for(var i = 0; i < argData.length; i++) {
		        	var beforeReqType = gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE');
		            gridL.setCellValue(argData[i], 'SIGN_REQ_TYPE', beforeReqType == "1" ? "7" : (beforeReqType == "2" ? "4" : "1"));
		        }
		    }
		    <!-- 병렬해제 -->
		    else if(argVal == "D") {
		        for(var i = 0; i < argData.length; i++) {
	        		var beforeReqType = gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE');
		            gridL.setCellValue(argData[i], 'SIGN_REQ_TYPE', beforeReqType == "7" ? "1" : (beforeReqType == "4" ? "2" : "1"));
		        }
		    }

            recountSignSequence();
            fillFixData('add');
	    }

	    function doDelete() {
	    	if (gridL.getSelRowId() == null) {
	            alert("${msg.M0004}");
	            return;
	        }
			gridL.delRow();

            recountSignSequence();
			// fillFixData('del');
	    }

		function doUp() {

			if ((gridL.jsonToArray(gridL.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

	        if ((gridL.jsonToArray(gridL.getSelRowId()).value).length > 1) {
	            alert("${msg.M0006}");
	            return;
	        }

        <%-- -------------------------------------------------------------------------------------------------------------- --%>

            var selectedRowId = gridL.jsonToArray(gridL.getSelRowId()).value[0]
               ,selectedRowData = gridL.getRowValue(selectedRowId);

            var signReqType = selectedRowData['SIGN_REQ_TYPE'];
            if(signReqType === '4' || signReqType === '7') {
                return alert('병렬의 건은 이동시키실 수 없습니다.');
            }

            var allRowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
            /*gridL.setProperty("setCheckFlag", false);
            for(var i=0; i < allRowIds.length; i++) {
                gridL.setCellValue(allRowIds[i], 'CHECK_FLAG', ' ');
            }
            gridL.setProperty("setCheckFlag", true);*/

            gridL.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.setParameter('sortType', 'up');
            store.getGridData(gridL, 'all');
            store.load(baseUrl+'/getRealignmentApprovalList', function() {
                gridL.checkAll(false);
                recountSignSequence();
            }, false);
	    }

	    function doDown() {

	        if ((gridL.jsonToArray(gridL.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

	        if ((gridL.jsonToArray(gridL.getSelRowId()).value).length > 1) {
	            alert("${msg.M0006}");
	            return;
	        }

        <%-- -------------------------------------------------------------------------------------------------------------- --%>

            var selectedRowId = gridL.jsonToArray(gridL.getSelRowId()).value[0]
               ,selectedRowData = gridL.getRowValue(selectedRowId);

            var signReqType = selectedRowData['SIGN_REQ_TYPE'];
            if(signReqType === '4' || signReqType === '7') {
                return alert('병렬의 건은 이동시키실 수 없습니다.');
            }

            var allRowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
            /*gridL.setProperty("setCheckFlag", false);
            for(var i=0; i < allRowIds.length; i++) {
                gridL.setCellValue(allRowIds[i], 'CHECK_FLAG', ' ');
            }
            gridL.setProperty("setCheckFlag", true);*/

            gridL.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.setParameter('sortType', 'down');
            store.getGridData(gridL, 'all');
            store.load(baseUrl+'/getRealignmentApprovalList', function() {
                gridL.checkAll(false);
                recountSignSequence();
            }, false);
        }

    </script>
    <e:window id="BAPP_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form1" title="${form_FORM_CAPTION_N }" columnCount="2" labelWidth="150">
        	<e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                    <e:inputText id="SUBJECT" style="${imeMode }" name="SUBJECT" width="100%" maxLength="${form_SUBJECT_M }" value="${param.subject }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
                </e:field>
			</e:row>
			<c:if test="${param.approvalType == 'APPROVAL'}">
	        	<e:row>
	                <e:label for="OPINION" title="${form_OPINION_N }" />
	                <e:field colSpan="3">
	                	<e:textArea id="OPINION" style="${imeMode }" name="OPINION" width="100%" height="90px" maxLength="${form_OPINION_M }" required="${form_OPINION_R }" readOnly="${form_OPINION_RO }" disabled="${form_OPINION_D }" />
	                </e:field>
				</e:row>
			</c:if>
			<c:if test="${param.approvalType != 'APPROVAL'}">
               	<e:inputHidden id="OPINION" name="OPINION" />
			</c:if>

			<c:if test="${param.approvalType == 'APPROVAL'}">
			<e:row>
				<e:label for="SIGN_USER_NM" title="${form_SIGN_USER_NM_N }" />
                <e:field>
                	<e:inputText id="SIGN_USER_NM" name="SIGN_USER_NM" width="150" maxLength="${form_SIGN_USER_NM_M}" required="${form_SIGN_USER_NM_R }" readOnly="${form_SIGN_USER_NM_RO }" disabled="${form_SIGN_USER_NM_D }" style="${imeMode }" onEnter="doSearch" />
                	&nbsp;&nbsp;
                	<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
                </e:field>


			<e:label  for="DEPT_CD" title="${form_DEPT_CD_N }"/>
			  <e:field>
			 <e:inputText id="DEPT_CD" style="${imeMode }" name="DEPT_CD"  readOnly="${form_DEPT_CD_RO }"  maxLength="${form_DEPT_CD_M}"  value=""  width="50%" required="${form_DEPT_CD_R }" disabled="${form_DEPT_CD_D }" onFocus="onFocus" />
			 </e:field>

            </e:row>
			<e:row>
				<e:label for="SIGN_REQ_TYPE" title="${form_SIGN_REQ_TYPE_N }" />
                <e:field>
                    <e:radioGroup id="SIGN_REQ_TYPE" name="SIGN_REQ_TYPE" disabled="" readOnly="" required="">
                        <e:radio id="R1" name="R1" label="결재" value="1" checked="true" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }" />
                        <e:radio id="R2" name="R2" label="합의" value="2" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }" />
                        <e:radio id="R3" name="R3" label="후결" value="3" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }" />
                        <e:radio id="R4" name="R4" label="통보" value="9" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }" />
                    </e:radioGroup>
                </e:field>


                <e:label for="SECURITY_TYPE" title="${form_SECURITY_TYPE_N }" />
                <e:field>
                    <e:radioGroup id="SECURITY_TYPE" name="SECURITY_TYPE" disabled="" readOnly="" required="">
                        <e:radio id="S1" name="S1" label="일반" value="0" checked="true" readOnly="${form_SECURITY_TYPE_RO }" disabled="${form_SECURITY_TYPE_D }"/>
                        <e:radio id="S2" name="S2" label="대외비" value="1" readOnly="${form_SECURITY_TYPE_RO }" disabled="${form_SECURITY_TYPE_D }"/>
                        <e:radio id="S3" name="S3" label="극비" value="2" readOnly="${form_SECURITY_TYPE_RO }" disabled="${form_SECURITY_TYPE_D }"/>
                    </e:radioGroup>
                    <span class="e-text-wrapper"> / </span>
                    <e:checkGroup id="cg" name="cg" disabled="" readOnly="" required="">
                        <e:check id="IMPORTANCE_STATUS" name="IMPORTANCE_STATUS" label="긴급" value="1" required="${form_IMPORTANCE_STATUS_R }" readOnly="${form_IMPORTANCE_STATUS_RO }" disabled="${form_IMPORTANCE_STATUS_D }" />
                    </e:checkGroup>
                </e:field>
            </e:row>

			</c:if>
			<c:if test="${param.approvalType != 'APPROVAL'}">

			<e:row>
				<e:label for="SIGN_USER_NM" title="${form_SIGN_USER_NM_N }" />
                <e:field colSpan="3">
                	<e:inputText id="SIGN_USER_NM" style="${imeMode }" name="SIGN_USER_NM" width="150" maxLength="${form_SIGN_USER_NM_M}" required="${form_SIGN_USER_NM_R }" readOnly="${form_SIGN_USER_NM_RO }" disabled="${form_SIGN_USER_NM_D }" onEnter="doSearch" />
                	&nbsp;&nbsp;
                	<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
                </e:field>
            </e:row>

               	<e:inputHidden id="SIGN_REQ_TYPE" name="SIGN_REQ_TYPE"  value="9"/>
               	<e:inputHidden id="IMPORTANCE_STATUS" name="IMPORTANCE_STATUS"  value=""/>
               	<e:inputHidden id="SECURITY_TYPE" name="SECURITY_TYPE"  value="0"/>

			</c:if>

        </e:searchPanel>

        <e:buttonBar id="buttonBarTop" align="left" width="100%">
        <c:if test="${param.approvalType == 'APPROVAL' }">
            <e:button id="Arranging" name="Arranging" label="${Arranging_N }" disabled="${Arranging_D }" onClick="doArranging" />
           	<e:button id="CancelArg" name="CancelArg" label="${CancelArg_N }" disabled="${CancelArg_D }" onClick="doCancelArg" />
        </c:if>
           	<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
           	<e:button id="Up" name="Up" label="${Up_N }" disabled="${Up_D }" onClick="doUp" />
           	<e:button id="Down" name="Down" label="${Down_N }" disabled="${Down_D }" onClick="doDown" />
        </e:buttonBar>

        <e:panel id="fg1" width="60%">
        	<e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="200px" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
        </e:panel>
        <e:panel id="fg2" width="40%">
        	<e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="200px" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
        </e:panel>

		<e:searchPanel id="form2" columnCount="1" labelWidth="150">
        	<e:row>
                <e:label for="TEXT_CONTENTS" title="내용" />
                <e:field>
                	<e:richTextEditor id="TEXT_CONTENTS" value="${param.textContents }"  height="210" name="TEXT_CONTENTS" width="100%" required="${form_TEXT_CONTENTS_R }" readOnly="${form_TEXT_CONTENTS_RO }" disabled="${form_TEXT_CONTENTS_D }" />
                	<e:inputHidden id="CONTENTS_TEXT_NUM" name="CONTENTS_TEXT_NUM" value="" />
                	<e:inputHidden id="UUID" name="UUID" value="" />
                    <e:inputHidden id="DOC_NUM" name="DOC_NUM" value="${param.docNum }" />
		            <e:inputHidden id="DOC_TYPE" name="DOC_TYPE" value="${param.docType }" />
		            <e:inputHidden id="DOC_ATT_FILE_NUM" name="DOC_ATT_FILE_NUM" value="${param.attFileNum }" />
		            <e:inputHidden id="DOC_SUB_TYPE" name="DOC_SUB_TYPE" value="${param.approvalType }" />
		            <e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="${param.screenId }" />
		            <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${param.signStatus }" />
		            <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.appDocNum }" />
		            <e:inputHidden id="ATT_FILE_NUM" name="ATT_FILE_NUM" value="" />
                </e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBarBottom" align="right" width="100%">
            <e:button id="ApprovalRequest" name="ApprovalRequest" label="${ApprovalRequest_N }" disabled="${ApprovalRequest_D }" onClick="doApprovalRequest" />
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
        </e:buttonBar>
    </e:window>
</e:ui>