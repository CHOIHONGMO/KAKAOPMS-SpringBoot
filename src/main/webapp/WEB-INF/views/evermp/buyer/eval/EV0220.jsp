<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/EV0220';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');

        EVF.C('EV_TYPE').removeOption('REGISTRATION');
//        EVF.C("EV_CTRL_USER_NM").setValue('${ses.userNm}');

        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function (rowid, celname, value, iRow, iCol) {

        	<%--셀 여러개 선택 방지--%>
        	if(selRow == undefined){
				selRow = rowid;
			}

			if (celname == "multiSelect") {
				if(selRow != rowid) {
					grid.checkRow(selRow, false);
					selRow = rowid;
				}
			}

			<%-- 평가번호 클릭 --%>
			if (celname == "EV_NUM") {
	        	var params = {
		                EV_NUM : grid.getCellValue(rowid, "EV_NUM")
		               ,POPUPFLAG : 'Y'
		               ,detailView    	: true
	                   ,havePermission : false
		            };
		        everPopup.openPopupByScreenId('EV0210', 1100, 900, params);
	        }
        });





		if('${ses.ctrlCd}'.indexOf('E100') > -1) {
	        EVF.C('EV_TYPE').setValue('ESG');
		}



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

		if(${_gridType eq "RG"}) {
			grid.setColGroup([{
				"groupName": '정량평가',
				"columns": [ "QTY_FLAG", "QTY_RSLT_FLAG" ]
			}])
		} else {
			grid.setGroupCol([{'colName': 'QTY_FLAG', 'colIndex': 2, 'titleText': '정량평가'}]);
		}

	    //멀티셀렉트 박스에서 처음 조회시 전체값 가져오기
	    var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
	    EVF.V('BUYER_CD',values.join(','));

    }

    <%-- 조회 --%>
    function doSearch() {
    	<%-- 날짜 체크--%>
        if(!everDate.checkTermDate('REG_DATE_FROM','REG_DATE_TO','${msg.M0073}')) {
            return;
        }
        var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }
        });
    }

    <%-- 수정 --%>
	function doChange(){
		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

		<%-- 평가 완료인 경우에는 수정할수 없습니다.--%>
		if(grid.getCellValue(selRowId, "PROGRESS_CD") == '300'){
			EVF.alert('${EV0220_progress_begin}');
			return;
		}

		<%-- 평가 담당자만 처리가능 --%>
		if(grid.getCellValue(selRowId, "EV_CTRL_USER_ID") != '${ses.userId}'){
			EVF.alert('${EV0220_userId}');
			return;
		}

		var param = {
				 EV_NUM : grid.getCellValue(selRowId, "EV_NUM")
	            ,detailView    : "false"
	            ,havePermission : false
	   	};
		everPopup.openPopupByScreenId('EV0210', 1100, 900, param);
	}

    <%-- 정량평가 실행 --%>
    function doExecute(){
    	if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

		var confirmMessage = "${EV0220_EXEC_QT}";
		<%-- 평가 진행중인 경우에만 처리 가능--%>
		if(grid.getCellValue(selRowId, "PROGRESS_CD") != '200'){
			EVF.alert('${EV0220_progress_ing}');
			return;
		}

		<%-- 평가 담당자만 처리가능 --%>
		if(grid.getCellValue(selRowId, "EV_CTRL_USER_ID") != '${ses.userId}'){
			EVF.alert('${EV0220_userId}');
			return;
		}

		<%-- 정량평가 대상인 경우에만 실행가능 --%>
		if(grid.getCellValue(selRowId, "QTY_FLAG") == 'Y'){
			// 이미 실행한 경우 다시 실행할 것인지 의향 묻기
			if (grid.getCellValue(selRowId, "QTY_RSLT_FLAG") == 'Y') {
				confirmMessage = "${EV0220_MSG_15}";
			}
		} else {
			EVF.alert('${EV0220_MSG_14}');
			return;
		}

		EVF.confirm(confirmMessage, function () {

			var store = new EVF.Store();

			store.setGrid([grid]);
	        store.getGridData(grid,'sel');
	        store.load(baseUrl + '/doExecute', function() {
	        	var msg = this.getResponseMessage();
	        	var msg2 = this.getParameter("msg2");
	        	if( msg2 != "" ) {
	        		EVF.confirm(msg+"\n"+"${EV0220_MSG_09} ${EV0220_MSG_10}", function () {
	        			loadPopupBox(msg2);
	        		});
	        		//if( confirm(msg+"\n"+"${EV0220_MSG_09} ${EV0220_MSG_10}") ) {
			        //	loadPopupBox(msg2);
	        		//}
	        	} else {
		        	EVF.alert(msg);
	        	}
	        	doSearch();
	       });
        });
    }


    <%-- 평가번호 검색 --%>
    function EV_NUM(){
    	var param = {
    			callBackFunction : "selectEvalNum"
    	};
    	everPopup.openCommonPopup(param, 'SP0046');
    }

    function selectEvalNum(param){
    	EVF.C("EV_NUM").setValue(param.EV_NUM);
    }

    <%-- 평가 담당자 검색 --%>
    function EV_CTRL_USER(){
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0001');
    }

    function selectEvCtrlUser(param){
    	EVF.C("EV_CTRL_USER_NM").setValue(param.USER_NM);
    	EVF.C("EV_CTRL_USER_ID").setValue(param.USER_ID);
    }

    $(document).ready( function() {

        $('#popupBoxClose').click( function() {
            unloadPopupBox();
        });

        $('#popupBox').draggable();
    });

    function unloadPopupBox() {    <%-- TO Unload the Popupbox--%>
        $('#popupBox').fadeOut("fast");
    }

    function loadPopupBox(msg) {    <%-- To Load the Popupbox--%>

    	var winwidth=document.all?document.body.clientWidth:window.innerWidth; <%-- 브라우저 가로폭 사이즈 가져오기--%>
    	var left = winwidth/2 - (600/2 + 100);
    	if(left < 300) left = 300;
    	var top = 90;

    	$("#popupBox").css({"left":left+"px"});
    	$("#popupBox").css({"top":top+"px"});
        $('#popupBox').fadeIn("fast");
        $("#taMsg").text(msg);
    }

    function doRegEsgGugan() {

		if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
		var selRowId = grid.jsonToArray(grid.getSelRowId()).value;


		<%-- 평가 담당자만 처리가능 --%>
		if(grid.getCellValue(selRowId, "EV_CTRL_USER_ID") != '${ses.userId}'){
//			EVF.alert('${EV0220_userId}');
//			return;
		}



		if(grid.getCellValue(selRowId, "EV_TYPE") != 'ESG'){
			EVF.alert('${EV0220_MSG_20}');
			return;
		}






		var param = {
				 EV_NUM : grid.getCellValue(selRowId, "EV_NUM")
	            ,detailView    : "false"
	            ,havePermission : false
	   	};
		everPopup.openPopupByScreenId('EV0221', 500, 280, param);



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
<e:window id="EV0220" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

    <div id="popupBox" style="position:absolute;display:none;width:600px;height:300px;left:300px;top:150px;z-index:100;background:#FFFFFF;border:2px solid #d2d2d2;padding:15px;-moz-box-shadow: 0 0 5px #d2d2d2; -webkit-box-shadow: 0 0 5px #d2d2d2; box-shadow: 0 0 5px #d2d2d2;">
    	<table style="width:600px;height:290px"  class="font-form">
    		<tr>
    			<td style="margin-left:15px;font-weight:bold;font-size:12px;">
    					<div class='e-window-container-header-bullet'></div>&nbsp;<span >${EV0220_CAPTION01}</span>
    			</td>
    		</tr>
    		<tr>
    			<td align="center">
    					<textarea id="taMsg" style="width:90%;height:200px;overflow:auto;"  class="font-form" readOnly>
    					</textarea>
    			</td>
    		</tr>
    		<tr>
    			<td align="center"><a style="cursor:pointer;" id="popupBoxClose">&lt; Close &gt;</a></td>
    		</tr>
    		<tr>
    			<td align="center" height="10px"></td>
    		</tr>
    	</table>
    </div>

    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
    <e:row>
		<%-- 평가생성일 --%>
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
		</e:field>

		<%-- 평가담당자 --%>
		<e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}" />
		<e:field>
			<e:inputText id="EV_CTRL_USER_NM" name="EV_CTRL_USER_NM" value="${ses.userNm}" width="${form_EV_CTRL_USER_NM_W}" maxLength="${form_EV_CTRL_USER_NM_M}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
		</e:field>
		<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>
	 </e:row>

    <e:row>
		<%-- 진행상태 --%>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
			<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
			<e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE"/>
		</e:field>

		<%-- 평가구분--%>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field>
			<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="120px" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>

		<%-- 평가명 --%>
		<e:label for="EV_NM" title="${form_EV_NM_N}"/>
		<e:field>
		<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="${form_EV_NM_W}" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
		</e:field>

    </e:row>

		<e:row>
			<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
			<%--회사명--%>
			<%--<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
			<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false"/>
			</e:field>
			<e:label for="dummy" />
			<e:field colSpan="1" />
			<e:label for="dummy" />
			<e:field colSpan="1" />--%>
		</e:row>

    	<input type="hidden" id="FAIL_BASE" name="FAIL_BASE" />
    	<input type="hidden" id="FAILCLAIM_BASE" name="FAILCLAIM_BASE" />
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/><%-- 조회  --%>
    	<e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}"/><%-- 수정 --%>
    	<!-- e:button id="doExecute" name="doExecute" label="${doExecute_N}" onClick="doExecute" disabled="${doExecute_D}" visible="${doExecute_V}"/--><%-- 정량평가 실행 --%>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
</e:window>
</e:ui>
