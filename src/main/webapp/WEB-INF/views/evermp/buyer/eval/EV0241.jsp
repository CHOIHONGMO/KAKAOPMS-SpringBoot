<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/',
        grid;
    var selRow;

    function init() {

        grid = EVF.C('grid');
        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

        	if(selRow == undefined) selRow = rowId;

        	if (colId == 'multiSelect') {
   	         <%-- cell 1개만 클릭 --%>
   	          if(selRow != rowId) {
   	            grid.checkRow(selRow, false);
   	            selRow = rowId;
   	          }
   	        }


            if(colId == 'ESG_POP') {
            	var evTypeCd = grid.getCellValue(rowId,'EV_TYPE_CD');
            	if (value=='') return;
            	params = {
                		EV_NUM : grid.getCellValue(rowId, "EV_NUM")
                	   ,VENDOR_CD : '${ses.companyCd}'
       	               ,detailView    	: true
                };
                everPopup.openPopupByScreenId('EV0270P01', 1000, 900, params);
            }

            if(colId == 'EV_NUM') {
            	var ev_num					= grid.getCellValue(rowId, "EV_NUM");
                var ev_user_id 				= grid.getCellValue(rowId, "EV_USER_ID");
                var ev_user_nm 				= grid.getCellValue(rowId, "EV_USER_NM");
                var ev_ctrl_user_id 		= grid.getCellValue(rowId, "EV_CTRL_USER_ID");
                var ev_progress_cd 			= grid.getCellValue(rowId, "EV_PROGRESS_CD");
                var result_enter_cd			= grid.getCellValue(rowId, "RESULT_ENTER_CD");
                var request_date			= grid.getCellValue(rowId, "REQUEST_DATE");
                var rep_ev_user_id			= grid.getCellValue(rowId, "REP_EV_USER_ID");
                var complete_date			= grid.getCellValue(rowId, "COMPLETE_DATE");
                var ev_type					= grid.getCellValue(rowId, "EV_TYPE");

                var params = {
                		EV_NUM: ev_num,
    	                EV_USER_ID      : ev_user_id,
    	                EV_USER_NM      : ev_user_nm,
    	                RESULT_ENTER_CD : result_enter_cd,
    	                EV_CTRL_USER_ID : ev_ctrl_user_id,
    	                EV_TYPE : ev_type,
                        paramPopupFlag  : 'N',
                        onClose         : 'closePopupAndRequeryParent',
                        detailView      : true,
                    };
                everPopup.openPopupByScreenId('EV0250', 1200, 800, params);



            }


   	        if(colId == "VENDOR_CNT"){
   	        	var ev_num					= grid.getCellValue(rowId, "EV_NUM");
   	            var ev_user_id 				= grid.getCellValue(rowId, "EV_USER_ID");
   	            var ev_user_nm 				= grid.getCellValue(rowId, "EV_USER_NM");

   	            var params = {
   	            		EV_NUM: ev_num,
   		                EV_USER_NM: ev_user_nm,
   		                EV_USER_ID: ev_user_id,
   	                    paramPopupFlag: 'N',
   	                    onClose: 'closePopupAndRequeryParent',
   	                    detailView : true,
   	                };
   	            everPopup.openPopupByScreenId('EV0250', 1200, 800, params);
   	        }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case '':

            default:
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

			doSearch();

    }
	<%-- 조회 --%>
    function doSearch() {

        var store = new EVF.Store();

        store.setGrid([grid]);
        store.load(baseUrl + 'EV0241/doSearch', function() {
            if(grid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }

            //grid.setColMerge.call(['EV_NUM','EV_NM'], true);
            grid.setColMerge(['EV_NUM','EV_NM']);

        });
    }

    <%-- 결과등록 --%>
    function doRegResult() {

        if (!grid.isExistsSelRow()) {
        	EVF.alert("${msg.M0004}");
            return;
        }

        if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
        	EVF.alert("${msg.M0006}");
            return;
        }

        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

        for (var i = 0; i < selRowId.length; i++) {

        	var ev_num					= grid.getCellValue(selRowId[i], "EV_NUM");
            var ev_user_id 				= grid.getCellValue(selRowId[i], "EV_USER_ID");
            var ev_user_nm 				= grid.getCellValue(selRowId[i], "EV_USER_NM");
            var ev_ctrl_user_id 		= grid.getCellValue(selRowId[i], "EV_CTRL_USER_ID");
            var ev_progress_cd 			= grid.getCellValue(selRowId[i], "EV_PROGRESS_CD");
            var result_enter_cd			= grid.getCellValue(selRowId[i], "RESULT_ENTER_CD");
            var request_date			= grid.getCellValue(selRowId[i], "REQUEST_DATE");
            var rep_ev_user_id			= grid.getCellValue(selRowId[i], "REP_EV_USER_ID");
            var complete_date			= grid.getCellValue(selRowId[i], "COMPLETE_DATE");
            var ev_type					= grid.getCellValue(selRowId[i], "EV_TYPE");


            var esg_chk_type			= grid.getCellValue(selRowId[i], "ESG_CHK_TYPE");
			if(esg_chk_type=='E') {
				EVF.alert("${EV0241_0020}");
				return;
			}


            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }

            <%-- 평가결과입력 코드가 --%>
			if( result_enter_cd == "EVALUSER" ) { <%--평가담당자--%>

				if( ev_ctrl_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0241_0001}");
					//return;
				}

			} else if( result_enter_cd == "PERUSER" ) {<%--평가자--%>

				if( ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0241_0002}");
					//return;
				}

			} else if( result_enter_cd == "REPUSER" ) {<%--대표평가자--%>

				if( rep_ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0241_0003}");
					//return;
				}
			}

			<%-- 평가자 평가상태가 완료일 경우 --%>
			if ( ev_progress_cd == "200" ) {
				EVF.alert("${EV0241_0004}");
				return;
			}

			<%-- 등록평가 진행상태가 완료일 경우 --%>
			if ( complete_date != null && complete_date != ""  ) {
				EVF.alert("${EV0241_0005}");
				return;
			}

            var params = {
            		EV_NUM: ev_num,
	                EV_USER_ID      : ev_user_id,
	                EV_USER_NM      : ev_user_nm,
	                RESULT_ENTER_CD : result_enter_cd,
	                EV_CTRL_USER_ID : ev_ctrl_user_id,
	                EV_TYPE : ev_type,
                    paramPopupFlag  : 'N',
                    onClose         : 'closePopupAndRequeryParent',
                    detailView      : false,
                };
            everPopup.openPopupByScreenId('EV0250', 1200, 800, params);
            return;
     	}
    }

    <%-- 평가완료 --%>
    function doComplete(){

        if (!grid.isExistsSelRow()) {
        	EVF.alert("${msg.M0004}");
            return;
        }

		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			EVF.alert("${msg.M0006}");
	            return;
	    }

		var selRowId = grid.jsonToArray(grid.getSelRowId()).value

        var esg_chk_type = grid.getCellValue(selRowId[0], "ESG_CHK_TYPE");
		if(esg_chk_type=='E') {
			EVF.alert("${EV0241_0020}");
			return;
		}




   	 	var store = new EVF.Store();
	   	store.setGrid([grid]);
	 	store.getGridData(grid, 'sel');
   		store.load(baseUrl + 'EV0241/doComplete', function() {
   			var completeFlag = this.getParameter("completeFlag");
   			if(completeFlag == "all"){<%--모든 유저가 점수가있으면 --%>
   				allUserComplete();
   			} else if(completeFlag == "part"){<%--하나이상 완료되었으면 --%>
   				<%-- 개별완료처리 하시겠습니까? --%>
   				EVF.confirm("${EV0241_0006}", function () {
					doIndivisualComplete();
				});
   			} else if(completeFlag == "not") {<%--아예 평가가 안되었으면--%>
   				EVF.alert("${EV0241_0011}");
   			}
   		});
   	}

    function allUserComplete() {
		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

		for (var i = 0; i < selRowId.length; i++) {
            var request_date = grid.getCellValue(selRowId[i], "REQUEST_DATE");
            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }
		}

		EVF.confirm("${msg.M8888 }", function () {
			var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([grid]);
        	store.getGridData(grid, 'sel')

			store.load(baseUrl + 'EV0241/allUserComplete', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

    <%-- eveu 개별완료 --%>
    function doIndivisualComplete(){
    	var store = new EVF.Store();
    	store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
        store.load(baseUrl + 'EV0241/doIndivisualComplete', function() {
        	var vendorList = this.getParameter("vendorList");
        	EVF.alert("${EV0241_0010}"+vendorList);
        	doSearch();
        });
    	//EV_NUM, EV_USER_ID
    }

    <%-- 완료취소 --%>
     function doCancel() {
         if (!grid.isExistsSelRow()) {
        	 EVF.alert("${msg.M0004}");
         	return;
         }

         if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			 EVF.alert("${msg.M0006}");
	         return;
	     }

		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

		for (var i = 0; i < selRowId.length; i++) {
            var request_date = grid.getCellValue(selRowId[i], "REQUEST_DATE");


            var esg_chk_type = grid.getCellValue(selRowId[i], "ESG_CHK_TYPE");
    		if(esg_chk_type=='E') {
    			EVF.alert("${EV0241_0020}");
    			return;
    		}


            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }

            if(grid.getCellValue(selRowId[i], "EV_PROGRESS_CD") != "200") {
				return EVF.alert("${EV0241_0007}");
			}

			if(grid.getCellValue(selRowId[i], "PROGRESS_CD") != "200") {
				return EVF.alert("${EV0241_0012}");
			}
		}

		EVF.confirm("${msg.M8888 }", function () {
			var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');

			store.load(baseUrl + 'EV0241/doCancel', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

     function checkRequestDate(requestDate) {
     	if(requestDate === '') {
     		EVF.alert('${EV0241_0008}');
     		return false;
     	} else {
     		return true;
     	}
     }

    <%-- 평가번호 검색 --%>
    function selectEvNum(){
    	var param = {
    			callBackFunction : "setEvNum"
    	};
    	everPopup.openCommonPopup(param, 'SP0046');
    }

    function setEvNum(param){
    	EVF.C("EV_NUM").setValue(param.EV_NUM);
    	EVF.C("EV_NM").setValue(param.EV_NM);
    }

    <%-- 평가 담당자 검색 --%>
    function selectEvCtrlUser(){
    	var param = {
    			callBackFunction : "setEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }

    function setEvCtrlUser(param){
    	EVF.C("EV_CTRL_USER_NM").setValue(param.USER_NM);
    }

    <%-- 평가자 조회--%>
    function selectEvUser(){
    	var param = {
    			callBackFunction : "setEvUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }

    function setEvUser(param){
    	EVF.C("EV_USER_NM").setValue(param.USER_NM);
    }

    </script>
<e:window id="EV0241" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
    <e:row>
	    <%-- 평가생성일  --%>
	    <e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
		<e:text>&nbsp;~&nbsp;</e:text>
		<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
		</e:field>
	    <%-- 평가자 진행상태 --%>
	    <e:label for="EVPROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
		</e:field>
	    <%-- 평가명 --%>
	    <e:label for="EV_NM" title="${form_EV_NM_N}"/>
		<e:field>
		<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
		</e:field>
	</e:row>

    <e:row>
	    <%-- 평가번호 --%>
	    <e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
		<e:field colSpan="5">
		<e:search id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="" width="${form_EV_NUM_W}" maxLength="${form_EV_NUM_M}" onIconClick="${form_EV_NUM_RO ? 'everCommon.blank' : 'selectEvNum'}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}" />
		</e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    	<e:button id="doRegResult" name="doRegResult" label="${doRegResult_N}" onClick="doRegResult" disabled="${doRegResult_D}" visible="${doRegResult_V}"/>
    	<e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
    	<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>
</e:ui>
