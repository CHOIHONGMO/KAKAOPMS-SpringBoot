<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui>
	<script type="text/javascript">

	var grid = {};
	var addParam = [];
	var baseUrl = "/evermp/buyer/eval/";
	var selRow;

	function init() {

		grid = EVF.C('grid');
		EVF.C('EV_USER_NM').setValue('${ses.userNm}');
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

		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			var params;

			 if(selRow == undefined) selRow = rowid;

	        if (celname == 'multiSelect') {
	          // cell 1개만 클릭
	          if(selRow != rowid) {
	            grid.checkRow(selRow, false);
	            selRow = rowid;
	          }
	        }

	        if (celname == "EV_NUM") {
	        	params = {
					EV_NUM : grid.getCellValue(rowid, "EV_NUM")
		            , detailView: grid.getCellValue(rowid, "EV_CTRL_USER_ID")=="${ses.userId}"?false:true
	                , havePermission: false
				};
		        everPopup.openPopupByScreenId('EV0045', 950, 700, params);
	        }
	        else  if (celname == "VENDOR_CD") {
                var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                       // 'IRS_NUM' : grid.getCellValue(rowId, 'IRS_NO'),
                        'buttonAuth' : false,
                        'detailView': true
                    };
                    everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
	        }
	        else if (celname == "EVAL_SCORE") {
	            params = {
	                EV_NUM: grid.getCellValue(rowid				,"EV_NUM"          ),
	                VENDOR_CD: grid.getCellValue(rowid		, "VENDOR_CD"   ),
	                VENDOR_NM: grid.getCellValue(rowid		, "VENDOR_NM"  ),
	                EV_USER_NM: grid.getCellValue(rowid		, "EV_USER_NM" ),
	                EV_USER_ID: grid.getCellValue(rowid		, "EV_USER_ID"   ),
	                popupFlag: true,
	                detailView : true
	            };
	            everPopup.openPopupByScreenId('EV0196', 950, 700, params);
	        }
		});

		if("${autoSearchFlag}" == "Y") {
			EVF.V("PROGRESS_CD", "200");

			doSearch();
		}
    }

    <%-- 협력사팝업 --%>
	function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0013');
	}

	function selectVendorCd(data) {
		var existVendor = true;

    	if(data.VENDOR_CD == ''){
    		return;
    	}
	   	EVF.C('VENDOR_NM').setValue(data.VENDOR_NM);
	   	EVF.C('VENDOR_CD').setValue(data.VENDOR_CD);
	}

    <%--사용자찾기 --%>
    function selectUserA(){ console.log('a');
    	SearchUser("A");
    }

    function selectUserB(){  console.log('b');
    	SearchUser("B");
    }

	function SearchUser(gbn) {
		var fn_name = "";
		if( gbn == "A") {
			fn_name = "setUserA";
		} else {
			fn_name = "setUserB";
		}
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: fn_name
        };
		everPopup.openCommonPopup(param,"SP0001");
    }

    function setUserA(dataJsonArray) {
        EVF.C("EV_CTRL_USER_NM").setValue(dataJsonArray.USER_NM);
        EVF.C("EV_CTRL_USER_ID").setValue(dataJsonArray.USER_ID);
    }

    function setUserB(dataJsonArray) {
        EVF.C("EV_USER_NM").setValue(dataJsonArray.USER_NM);
        EVF.C("EV_USER_ID").setValue(dataJsonArray.USER_ID);
    }

    <%-- 조회 --%>
    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;

        // 날짜 체크
        if(!everDate.checkTermDate('REQ_START_DATE','REQ_END_DATE','${msg.M0073}')) {
            return;
        }

        store.setGrid([grid]);
        store.load(baseUrl + 'EV0195/doSearch', function() {
            if(grid.getRowCount() == 0){
            	EVF.alert("${msg.M0002 }");
            }

            // if( selRow != null) {
            // 	grid.checkRow(selRow, true);
            // }

            //grid.setCellMerge.call(['EV_NUM'], true);
			grid.setColMerge(['EV_NUM']);
        });
    }

    function checkRequestDate(requestDate) {
    	if(requestDate === '') {
    		EVF.alert('${EV0195_0008}');
    		return false;
    	} else {
    		return true;
    	}
    }

    <%-- 평가등록 --%>
    function doRegEvaluation() {
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

        	var ev_num		= grid.getCellValue(selRowId[i], "EV_NUM");
            var vendor_cd 	= grid.getCellValue(selRowId[i], "VENDOR_CD");
            var vendor_nm 	= grid.getCellValue(selRowId[i], "VENDOR_NM");
            var ev_user_id 	= grid.getCellValue(selRowId[i], "EV_USER_ID");
            var ev_user_nm 	= grid.getCellValue(selRowId[i], "EV_USER_NM");
            var ev_tpl_num 	= grid.getCellValue(selRowId[i], "EV_TPL_NUM");

            var complete_date 		= grid.getCellValue(selRowId[i], "COMPLETE_DATE");
            var ev_ctrl_user_id 	= grid.getCellValue(selRowId[i], "EV_CTRL_USER_ID");
            var ev_progress_cd 		= grid.getCellValue(selRowId[i], "EV_PROGRESS_CD");
            var result_enter_user_cd= grid.getCellValue(selRowId[i], "RESULT_ENTER_CD");
            var rep_ev_user_id		= grid.getCellValue(selRowId[i], "REP_EV_USER_ID");
            var request_date		= grid.getCellValue(selRowId[i], "REQUEST_DATE");

            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }

            <%-- 평가결과입력 코드가 --%>
			if( result_enter_user_cd == "EVALUSER" ) { <%--평가담당자--%>

				if( ev_ctrl_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0001}");
					//return;
				}

			} else if( result_enter_user_cd == "PERUSER" ) {<%--평가자--%>

				if( ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0002}");
					//return;
				}

			} else if( result_enter_user_cd == "REPUSER" ) {<%--대표평가자--%>

				if( rep_ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0003}");
					//return;
				}
			}

			<%-- 평가자 평가상태가 완료일 경우 --%>
			if ( ev_progress_cd == "200" ) {
				EVF.alert("${EV0195_0004}");
				return;
			}

			<%-- 등록평가 진행상태가 완료일 경우 --%>
			if ( complete_date != null && complete_date != ""  ) {
				EVF.alert("${EV0195_0005}");
				return;
			}


            var params = {
            		EV_NUM: ev_num,
            		EV_TPL_NUM: ev_tpl_num,
	                VENDOR_CD: vendor_cd,
	                VENDOR_NM: vendor_nm,
	                EV_USER_NM: ev_user_nm,
	                EV_USER_ID: ev_user_id,
                    paramPopupFlag: 'N',
                    onClose: 'closePopupAndRequeryParent ',
                    detailView : false
                };
            everPopup.openPopupByScreenId('EV0196', 900, 800, params);
            return;

     	}
    }

    <%-- 평가완료 --%>
    function doComplete() {

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
			var ev_num		= grid.getCellValue(selRowId[i], "EV_NUM");
			var vendor_cd 	= grid.getCellValue(selRowId[i], "VENDOR_CD");
			var vendor_nm 	= grid.getCellValue(selRowId[i], "VENDOR_NM");
			var ev_user_id 	= grid.getCellValue(selRowId[i], "EV_USER_ID");
			var ev_user_nm 	= grid.getCellValue(selRowId[i], "EV_USER_NM");
			var ev_tpl_num 	= grid.getCellValue(selRowId[i], "EV_TPL_NUM");

			var complete_date 		= grid.getCellValue(selRowId[i], "COMPLETE_DATE");
			var ev_ctrl_user_id 	= grid.getCellValue(selRowId[i], "EV_CTRL_USER_ID");
			var ev_progress_cd 		= grid.getCellValue(selRowId[i], "EV_PROGRESS_CD");
			var result_enter_user_cd= grid.getCellValue(selRowId[i], "RESULT_ENTER_CD");
			var rep_ev_user_id		= grid.getCellValue(selRowId[i], "REP_EV_USER_ID");
			var request_date		= grid.getCellValue(selRowId[i], "REQUEST_DATE");

            <%-- 요청일자가 존재하지 않으면 처리 불가 --%>
            if(!checkRequestDate(request_date)) {
            	return;
            }

			<%-- 평가결과입력 코드가 --%>
			if( result_enter_user_cd == "EVALUSER" ) { <%--평가담당자--%>

				if( ev_ctrl_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0001}");
					//return;
				}

			} else if( result_enter_user_cd == "PERUSER" ) {<%--평가자--%>

				if( ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0002}");
					//return;
				}

			} else if( result_enter_user_cd == "REPUSER" ) {<%--대표평가자--%>

				if( rep_ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0003}");
					//return;
				}
			}

			<%-- 평가자 평가상태가 완료일 경우 --%>
			if ( ev_progress_cd == "200" ) {
				EVF.alert("${EV0195_0004}");
				return;
			}

			<%-- 등록평가 진행상태가 완료일 경우 --%>
			if ( complete_date != null && complete_date != ""  ) {
				EVF.alert("${EV0195_0005}");
				return;
			}
		}

		EVF.confirm("${msg.M8888 }", function () {
            var store = new EVF.Store();

            if(!store.validate()) return;

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'EV0195/doComplete', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });

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
			var ev_num		= grid.getCellValue(selRowId[i], "EV_NUM");
			var vendor_cd 	= grid.getCellValue(selRowId[i], "VENDOR_CD");
			var vendor_nm 	= grid.getCellValue(selRowId[i], "VENDOR_NM");
			var ev_user_id 	= grid.getCellValue(selRowId[i], "EV_USER_ID");
			var ev_user_nm 	= grid.getCellValue(selRowId[i], "EV_USER_NM");
			var ev_tpl_num 	= grid.getCellValue(selRowId[i], "EV_TPL_NUM");

			var complete_date 		= grid.getCellValue(selRowId[i], "COMPLETE_DATE");
			var ev_ctrl_user_id 	= grid.getCellValue(selRowId[i], "EV_CTRL_USER_ID");
			var ev_progress_cd 		= grid.getCellValue(selRowId[i], "EV_PROGRESS_CD");
			var result_enter_user_cd= grid.getCellValue(selRowId[i], "RESULT_ENTER_CD");
			var rep_ev_user_id		= grid.getCellValue(selRowId[i], "REP_EV_USER_ID");
			var request_date		= grid.getCellValue(selRowId[i], "REQUEST_DATE");

			<%-- 요청일자가 존재하지 않으면 처리 불가 --%>
			if(!checkRequestDate(request_date)) {
				return;
			}

			<%-- 평가결과입력 코드가 --%>
			if( result_enter_user_cd == "EVALUSER" ) { <%--평가담당자--%>

				if( ev_ctrl_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0001}");
					//return;
				}

			} else if( result_enter_user_cd == "PERUSER" ) {<%--평가자--%>

				if( ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0002}");
					//return;
				}

			} else if( result_enter_user_cd == "REPUSER" ) {<%--대표평가자--%>

				if( rep_ev_user_id != "${ses.userId}" ) {
					EVF.alert("${EV0195_0003}");
					//return;
				}
			}

			if ( ev_progress_cd != "200" ) {
				EVF.alert("${EV0195_0007}");
				return;
			}

			<%-- 등록평가 진행상태가 완료일 경우 --%>
			if ( complete_date != null && complete_date != ""  ) {
				EVF.alert("${EV0195_0005}");
				return;
			}
		}

		EVF.confirm("${msg.M8888 }", function () {
            var store = new EVF.Store();

            if(!store.validate()) return;

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'EV0195/doCancel', function() {
                EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
        });
    }

    </script>
    <e:window id="EV0195" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
        	<e:row>
                <%--요청일--%>
				<e:label for="REQ_START_DATE" title="${form_REQ_START_DATE_N}"/>
				<e:field>
				<e:inputDate id="REQ_START_DATE" toDate="REQ_END_DATE" name="REQ_START_DATE" value="${form.REQ_START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REQ_START_DATE_R}" disabled="${form_REQ_START_DATE_D}" readOnly="${form_REQ_START_DATE_RO}" />
				<e:text>~</e:text>
				<e:inputDate id="REQ_END_DATE" fromDate="REQ_START_DATE" name="REQ_END_DATE" value="${form.REQ_END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REQ_END_DATE_R}" disabled="${form_REQ_END_DATE_D}" readOnly="${form_REQ_END_DATE_RO}" />
				</e:field>
			   <%--진행상태--%>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
                <%--평가담당자명--%>
                <e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
				<e:field>
				<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="100%" maxLength="${form_EV_CTRL_USER_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'selectUserA'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
				</e:field>
			</e:row>
			<e:row>
                <%--협력사명--%>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM }" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
                <%--평가자명--%>
                <e:label for="EV_USER_NM" title="${form_EV_USER_NM_N}"/>
				<e:field>
				<e:search id="EV_USER_NM" style="${imeMode}" name="EV_USER_NM" value="${form.EV_USER_NM }" width="100%" maxLength="${form_EV_USER_NM_M}" onIconClick="${form_EV_USER_NM_RO ? 'everCommon.blank' : 'selectUserB'}" disabled="${form_EV_USER_NM_D}" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}" />
				<e:inputHidden id="EV_USER_ID" name="EV_USER_ID" value="${form.EV_USER_ID }"/>
				</e:field>

                <%--평가구분--%>
                <e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
				<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doRegEvaluation" name="doRegEvaluation" label="${doRegEvaluation_N}" onClick="doRegEvaluation" disabled="${doRegEvaluation_D}" visible="${doRegEvaluation_V}"/>
			<e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>