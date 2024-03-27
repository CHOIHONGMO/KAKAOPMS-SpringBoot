<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/eApproval/eApprovalBox/";

    function init() {
        grid = EVF.C("grid");
        grid.setProperty('shrinkToFit', true);

		grid.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
			onCellClick( cellName, rowId );
		});

		grid.cellChangeEvent(function(rowId, cellName, iRow, iCol, value, oldValue) {
			onCellChange( cellName, rowId, value );
		});

		grid.addRowEvent(function() {
			doAddLine();
		});

		grid.delRowEvent(function() {
			doDelLine();
		});

        var oldApprovalFlag = '${param.oldApprovalFlag}';

        if (oldApprovalFlag === 'C' || oldApprovalFlag === 'R' || oldApprovalFlag === 'E') {
            doSelectPreviousInfo();
        }

        window.focus();
    }

    function doSelectPreviousInfo() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('docNum', '${param.docNum}');
        store.setParameter('docCnt', '${param.docCnt}');
        store.load(baseUrl + 'BAPP_050/doSelectPreviousInfo', function() {
            fillFixData();
        });

    }

    function doAddLine() {
		addParam = [{}];
      	grid.addRow(addParam);

        fillFixData();
    }

    function doDelLine() {
		if (grid.getSelRowId() == null) {
		   	alert("${msg.M0004}");
			return;
		}

		grid.delRow();

        fillFixData();
    }

    function fillPathSeq() {
    	var seq = 1;
		var rowIds = grid.getAllRowId();
    	for (var i in rowIds) {
    		var check = grid.multiSelTest(i);
    		grid.setCellValue(i, 'SIGN_PATH_SQ', seq++);
    	}
    }

    function up() {
        if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        <%-- -------------------------------------------------------------------------------------------------------------- --%>

        var selectedRowId = grid.jsonToArray(grid.getSelRowId()).value[0]
                ,selectedRowData = grid.getRowValue(selectedRowId);

        var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
        /*grid.setProperty("setCheckFlag", false);
        for(var i=0; i < allRowIds.length; i++) {
            grid.setCellValue(allRowIds[i], 'CHECK_FLAG', ' ');
        }
        grid.setProperty("setCheckFlag", true);*/

        grid.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('sortType', 'up');
        store.getGridData(grid, 'all');
        store.load('/eversrm/eApproval/eApprovalModule/getRealignmentApprovalList', function() {
            grid.checkAll(false);
            recountSignSequence();
        }, false);
    }

    function down() {
        if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }

        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
            alert("${msg.M0006}");
            return;
        }

        <%-- -------------------------------------------------------------------------------------------------------------- --%>

        var selectedRowId = grid.jsonToArray(grid.getSelRowId()).value[0]
                ,selectedRowData = grid.getRowValue(selectedRowId);

//        var signReqType = selectedRowData['SIGN_REQ_TYPE'];
//        if(signReqType === '4' || signReqType === '7') {
//            return alert('병렬의 건은 이동시키실 수 없습니다.');
//        }

        var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
        /*grid.setProperty("setCheckFlag", false);
        for(var i=0; i < allRowIds.length; i++) {
            grid.setCellValue(allRowIds[i], 'CHECK_FLAG', ' ');
        }
        grid.setProperty("setCheckFlag", true);*/

        grid.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('sortType', 'down');
        store.getGridData(grid, 'all');
        store.load('/eversrm/eApproval/eApprovalModule/getRealignmentApprovalList', function() {
            grid.checkAll(false);
            recountSignSequence();
        }, false);
    }

    <%-- 결재 순번 계산 --%>
    function recountSignSequence() {

        var rowIds = grid.jsonToArray(grid.getAllRowId()).value;
        var selectedRowIdx = [];
        for(var i = 0; i < rowIds.length; i++) {

            var rowData = grid.getRowValue(rowIds[i]);
            var checkFlag = rowData['CHECK_FLAG'];
            if(checkFlag == '1') {
                selectedRowIdx.push(rowIds[i]);
            }

            grid.setCellValue(rowIds[i], "CHECK_FLAG", "");
            grid.setCellValue(rowIds[i], 'SIGN_PATH_SQ', i+1);
        }

        var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
        //grid.setProperty("setCheckFlag", false);
        for(var i=0; i < allRowIds.length; i++) {
            grid.setCellValue(allRowIds[i], 'CHECK_FLAG', '');
        }
        //grid.setProperty("setCheckFlag", true);

        grid.checkAll(false);

        for(var i=0; i < selectedRowIdx.length; i++) {
            grid.checkRow(selectedRowIdx[i], true);
        }
    }

    function getMyApprovalPath() {
        everPopup.openMyApprovalPathPopup();
    }

    function myApprovalPathCallBack(dataJsonArray) {
	    dataJsonArray = $.parseJSON(dataJsonArray);

        var store = new EVF.Store();
        store.setGrid([grid]);
		store.setParameter('strApprovalPathKey', JSON.stringify(dataJsonArray));
        store.load(baseUrl + 'BAPP_050/doSelectMyPath', function() {
            fillFixData();
        });
    }

    function doApprovalRequest() {

    	 if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
             alert("${msg.M0004}");
             return;
         }
    	 
    	var store = new EVF.Store();
		store.doFileUpload(function() {
			var attaUuid = EVF.C('attFile').getFileId();

			if( attaUuid != '' ) {
				EVF.C('ATT_FILE_NUM').setValue( attaUuid );
			}
		});

		var approvalData = {};
        var formData = {
            ATT_FILE_NUM: EVF.C('ATT_FILE_NUM').getValue(),
            DOC_NUM: EVF.C('DOC_NUM').getValue(),
            IMPORTANCE_STATUS: EVF.C('IMPORTANCE_STATUS').getValue(),
            SUBJECT: EVF.C('SUBJECT').getValue(),
            DOC_CONTENTS: EVF.C('DOC_CONTENTS').getValue()
        };

        approvalData.formData = JSON.stringify(formData);
        approvalData.gridData = JSON.stringify(grid.getSelRowValue());

	    opener.${'approvalCallBack'}(JSON.stringify(approvalData));
	    opener.${'getApproval'}();

        window.close();
    }

    function fillImgUrl() {
		var rowIds = grid.getAllRowId();
    	for (var i in rowIds) {
        	grid.setCellValue(i, 'SIGN_USER_NM_IMG', '');
     	}
    }
	var currRow;
    function onCellClick(strColumnKey, nRow) {
        if (strColumnKey === 'SIGN_USER_NM_IMG') {
            //everPopup.userSearchPopup('setUser', nRow, '', 'buyer', '');
            currRow = nRow;
            var param = {
                 GATE_CD: '${ses.gateCd}'
                ,callBackFunction: 'setUser'
            };
        	everPopup.openCommonPopup(param,"SP0001");
        }
    }

    function setUser(dataJsonArray, nRow) {
  		grid.setCellValue(currRow, "SIGN_USER_ID",  dataJsonArray.USER_ID);
  		grid.setCellValue(currRow, "SIGN_USER_NM",  dataJsonArray.USER_NM);
  		grid.setCellValue(currRow, "DEPT_CD",       dataJsonArray.DEPT_CD);
  		grid.setCellValue(currRow, "DEPT_NM",       dataJsonArray.DEPT_NM);
  		grid.setCellValue(currRow, "POSITION_NM",   dataJsonArray.POSITION_NM);
  		grid.setCellValue(currRow, "DUTY_NM",       dataJsonArray.DUTY_NM);
  		grid.setCellValue(currRow, "SIGN_REQ_TYPE", 'E');

  		fillFixData();
    }

    function fillFixData() {
        fillPathSeq();
        fillImgUrl();
    }

    function closePopup() {
        window.close();
    }

    function onCellChange(strColumnKey, nRow, value) {
        if (strColumnKey === 'SIGN_USER_NM') {
            autoCompleteUserInfo(nRow, value);
        }
    }

    function autoCompleteUserInfo(nRow, userName) {
        doCheckUserName(nRow, userName);
    }

    function doCheckUserName(nRow, userName) {
        var store = new EVF.Store();
		store.setParameter('userName', userName);
        store.load(baseUrl + 'BAPP_050/doCheckUserName', function() {
            var message = this.getResponseMessage();
            if (message === 'oneUserSelected') {
                var userInfo = JSON.parse(this.getParameter('userInfo'));
                setUserByAutoComplete(nRow, userInfo);
                fillFixData();
            } else {
                alert(this.getResponseMessage());
                //everPopup.userSearchPopup('setUser', nRow, userName, 'buyer', '');
                currRow = nRow;
                var param = {
                        GATE_CD:  '${ses.gateCd}'
                        , callBackFunction: 'setUser'
                    };
            	everPopup.openCommonPopup(param,"SP0001");

            }
        });
    }

    function setUserByAutoComplete(nRow, userInfo) {
       	grid.setCellValue(nRow, "SIGN_USER_ID",  userInfo.USER_ID);
       	grid.setCellValue(nRow, "SIGN_USER_NM",  userInfo.USER_NM);
       	grid.setCellValue(nRow, "DEPT_CD",       userInfo.DEPT_CD);
       	grid.setCellValue(nRow, "DEPT_NM",       userInfo.DEPT_NM);
       	grid.setCellValue(nRow, "POSITION_NM",   userInfo.POSITION_NM);
       	grid.setCellValue(nRow, "DUTY_NM",       userInfo.DUTY_NM);
       	grid.setCellValue(nRow, "SIGN_REQ_TYPE", 'E');
        fillFixData();
    }

	function fileUpload() {
		var store = new EVF.Store();
		store.doFileUpload(function() {
			var attaUuid = EVF.C('attFile').getFileId();

			if( attaUuid != '' ) {
				EVF.C('ATT_FILE_NUM').setValue( attaUuid );
			}
		});
	}
    </script>

    <e:window id="BAPP_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" margin="0 5px 0 5px">

    	<e:buttonBar id="buttonBarM" align="right" width="100%">
            <e:button id="getMyApprovalPath" name="getMyApprovalPath" label="${getMyApprovalPath_N }" disabled="${getMyApprovalPath_D }" onClick="getMyApprovalPath" />
            <e:button id="doApprovalRequest" name="doApprovalRequest" label="${doApprovalRequest_N }" disabled="${doApprovalRequest_D }" onClick="doApprovalRequest" />
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="closePopup" />
        </e:buttonBar>

		<e:inputHidden id="ATT_FILE_NUM"  name="ATT_FILE_NUM"/>
		<e:inputHidden id="DOC_NUM"  name="DOC_NUM"/>
		<e:inputHidden id="CONTENTS_TEXT_NO"  name="CONTENTS_TEXT_NO"/>

		<e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"></e:label>
                <e:field>
					<e:inputText id="SUBJECT" name="SUBJECT" value="${param.subject}" width="100%" maxLength="${form_SUBJECT_M }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D}" visible="${form_SUBJECT_V}" ></e:inputText>
               </e:field>
                <e:label for="IMPORTANCE_STATUS" title="${form_IMPORTANCE_STATUS_N}"></e:label>
                <e:field>
					<e:select id="IMPORTANCE_STATUS" name="IMPORTANCE_STATUS" options="${ref_IMPORTANCE_STATUS}" required="${form_IMPORTANCE_STATUS_R }" disabled="${form_IMPORTANCE_STATUS_D }" readOnly='${form_IMPORTANCE_STATUS_RO }' value="N" visible="${form_IMPORTANCE_STATUS_V}"></e:select>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DOC_CONTENTS" title="${form_DOC_CONTENTS_N}"></e:label>
                <e:field colSpan="3">
                	<e:richTextEditor id="DOC_CONTENTS" name="DOC_CONTENTS" label="${DOC_CONTENTS_N }" height="200" width="100%" disabled="${form_RMK_TEXT_NUM_D }" visible="${form_RMK_TEXT_NUM_V }" readOnly="${form_RMK_TEXT_NUM_RO}" required="${form_RMK_TEXT_NUM_R}" />
               </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="4">
                    <e:fileManager id="attFile" name="attFile" downloadable="true" bizType="APP" height="90px" readOnly="${form_ATT_FILE_NUM_RO}" onSuccess="onSuccess" required="${form_ATT_FILE_NUM_R}"/>
                    <%--<e:button id="attFileUpload" onClick="fileUpload" label="파일업로드"/>--%>
               </e:field>
            </e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBarS" align="right" width="100%">
            <e:button id="Up" name="Up" label="${Up_N }" disabled="${Up_D }" onClick="up" />
            <e:button id="Down" name="Down" label="${Down_N }" disabled="${Down_D }" onClick="down" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>

