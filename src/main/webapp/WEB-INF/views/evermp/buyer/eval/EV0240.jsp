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
        EVF.C('EV_TYPE').removeOption('REGISTRATION');

		if('${ses.ctrlCd}'.indexOf('E100') > -1) {
	        EVF.C('EV_TYPE').setValue('ESG');
		}

        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

        	if(selRow == undefined) selRow = rowId;

        	if (colId == 'multiSelect') {
   	         <%-- cell 1개만 클릭 --%>
   	          if(selRow != rowId) {
//   	            grid.checkRow(selRow, false);
//   	            selRow = rowId;
   	          }
   	        }

   	        if (colId == "EV_NUM") {
   	        	var params = {
   		                EV_NUM : grid.getCellValue(rowId, "EV_NUM")
   		               ,POPUPFLAG : 'Y'
   		               ,detailView    	: true
   	                   ,havePermission : false
   		            };
   		        everPopup.openPopupByScreenId('EV0210', 1100, 900, params);
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
	                	EV_TYPE : grid.getCellValue(rowId, "EV_TYPE"),
	                	ESG_CHK_TYPE : grid.getCellValue(rowId, "ESG_CHK_TYPE")
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

		if("${autoSearchFlag}" == "Y") {
			EVF.V("PROGRESS_CD", "100");

//			doSearch();
		}

	    //멀티셀렉트 박스에서 처음 조회시 전체값 가져오기
	    var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
	    EVF.V('BUYER_CD',values.join(','));

		doSearch();

    }
	<%-- 조회 --%>
    function doSearch() {

        var store = new EVF.Store();

        store.setGrid([grid]);
        store.load(baseUrl + 'EV0240/doSearch', function() {
            if(grid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }

            //grid.setColMerge.call(['EV_NUM','EV_NM'], true);
            grid.setColMerge(['EV_NUM','EV_NM']);

        });
    }

    <%-- 결과등록 --%>
    function doRegResult() {

		var ctrlCd = '${ses.ctrlCd}';

		var esgCtrlCdYn = ctrlCd.indexOf('E100') > -1 ? true : false;

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
            var esgChkType				= grid.getCellValue(selRowId[i], "ESG_CHK_TYPE");

            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }


            <%-- 평가결과입력 코드가 --%>
			if( result_enter_cd == "EVALUSER" ) { <%--평가담당자--%>

				if( ev_ctrl_user_id != "${ses.userId}") {
					EVF.alert("${EV0240_0001}");
					return;
				}

			} else if( result_enter_cd == "PERUSER") {<%--평가자--%>

				if( ev_user_id != "${ses.userId}") {
					EVF.alert("${EV0240_0002}");
					return;
				}

			} else if( result_enter_cd == "REPUSER") {<%--대표평가자--%>

				if( rep_ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0240_0003}");
					return;
				}
			}


			if(ev_type == 'ESG' && !esgCtrlCdYn) {
				EVF.alert("${EV0240_0014}");
				return;
			}
			<%-- 평가자 평가상태가 완료일 경우 --%>
			if ( ev_progress_cd == "200" ) {
				EVF.alert("${EV0240_0004}");
				return;
			}

			<%-- 등록평가 진행상태가 완료일 경우 --%>
			if ( complete_date != null && complete_date != ""  ) {
				EVF.alert("${EV0240_0005}");
				return;
			}

            var params = {
            		EV_NUM: ev_num,
	                EV_USER_ID      : ev_user_id,
	                EV_USER_NM      : ev_user_nm,
	                RESULT_ENTER_CD : result_enter_cd,
	                EV_CTRL_USER_ID : ev_ctrl_user_id,
	                paramPopupFlag  : 'N',
                    onClose         : 'closePopupAndRequeryParent',
                    detailView      : false,
				    EV_TYPE 		: ev_type,

				    ESG_CHK_TYPE    : esgChkType

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
//			EVF.alert("${msg.M0006}");
//	            return;
	    }

   	 	var store = new EVF.Store();
	   	store.setGrid([grid]);
	 	store.getGridData(grid, 'sel');
   		store.load(baseUrl + 'EV0240/doComplete', function() {
   			var completeFlag = this.getParameter("completeFlag");
   			//salert(completeFlag)
   			if(completeFlag == "all"){<%--모든 유저가 점수가있으면 --%>
   				allUserComplete();
   			} else if(completeFlag == "part"){<%--하나이상 완료되었으면 --%>
   				<%-- 개별완료처리 하시겠습니까? --%>
   				EVF.confirm("${EV0240_0006}", function () {
					doIndivisualComplete();
				});
   			} else if(completeFlag == "not") {<%--아예 평가가 안되었으면--%>
   				EVF.alert("${EV0240_0011}");
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

			store.load(baseUrl + 'EV0240/allUserComplete', function() {
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
        store.load(baseUrl + 'EV0240/doIndivisualComplete', function() {
        	var vendorList = this.getParameter("vendorList");
        	EVF.alert("${EV0240_0010}"+vendorList);
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
//			 EVF.alert("${msg.M0006}");
//	         return;
	     }

		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

		for (var i = 0; i < selRowId.length; i++) {
            var request_date = grid.getCellValue(selRowId[i], "REQUEST_DATE");

            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }

            if(grid.getCellValue(selRowId[i], "EV_PROGRESS_CD") != "200") {
				return EVF.alert("${EV0240_0007}");
			}

			if(grid.getCellValue(selRowId[i], "PROGRESS_CD") != "200") {
				return EVF.alert("${EV0240_0012}");
			}
		}

		EVF.confirm("${msg.M8888 }", function () {
			var store = new EVF.Store();
            if(!store.validate()) return;

            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');

			store.load(baseUrl + 'EV0240/doCancel', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

     function checkRequestDate(requestDate) {
     	if(requestDate === '') {
     		EVF.alert('${EV0240_0008}');
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
    	everPopup.openCommonPopup(param, 'SP0001');
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

	function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0063');
	}

	function selectVendorCd(dataJsonArray) {
		EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
		EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
	}

    </script>
    
	<e:window id="EV0240" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
	    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
	    <e:row>
		    <%-- 평가생성일  --%>
		    <e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
			<e:field>
				<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
				<e:text>&nbsp;~&nbsp;</e:text>
				<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
			</e:field>
			<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
			<e:field>
				<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${form.VENDOR_CD}" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
				<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				<e:inputHidden id="ESG_CHK_TYPE" name="ESG_CHK_TYPE" value="${form.ESG_CHK_TYPE}"/>
			</e:field>
			<%-- 평가담당자 --%>
			<e:label for="EV_CTRL_NM" title="${form_EV_CTRL_NM_N}"/>
			<e:field>
				<e:inputText id="EV_CTRL_NM" name="EV_CTRL_NM" value="${form.EV_CTRL_USER_NM}" width="${form_EV_CTRL_NM_W}" maxLength="${form_EV_CTRL_NM_M}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" />
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
			</e:field>
		</e:row>
	    <e:row>
			<%-- 평가명 --%>
			<e:label for="EV_NM" title="${form_EV_NM_N}"/>
			<e:field>
				<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
			</e:field>
	
		<c:if test="${ses.userType=='C'}">
		    <%-- 평가자 --%>
		    <e:label for="EV_USER_NM" title="${form_EV_USER_NM_N}"/>
			<e:field>
				<e:inputText id="EV_USER_NM" name="EV_USER_NM" value="${ses.userNm}" width="${form_EV_USER_NM_W}" maxLength="${form_EV_USER_NM_M}" disabled="${form_EV_USER_NM_D}" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}" />
			</e:field>
		</c:if>
		<c:if test="${ses.userType =='B'}">
			<e:label for="EV_USER_NM" title="${form_EV_USER_NM_N}"/>
			<e:field>
				<e:inputHidden id="EV_USER_ID" name="EV_USER_ID" value="${ses.userId}"/>
				<e:inputText id="EV_USER_NM" name="EV_USER_NM" value="${ses.userNm}" width="${form_EV_USER_NM_W}" maxLength="${form_EV_USER_NM_M}" disabled="true" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}" />
			</e:field>
		</c:if>
			<%-- 평가자 진행상태 --%>
			<e:label for="EVPROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
			<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="140px" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
			</e:field>
	    </e:row>
	    <e:row>
	    </e:row>
		<e:row>
			<%-- 평가구분 --%>
			<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
			<e:field>
				<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="140px" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
			</e:field>
			<e:label for="" title="" />
			<e:field> </e:field>
			<e:label for="" title="" />
			<e:field> </e:field>
			<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
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
