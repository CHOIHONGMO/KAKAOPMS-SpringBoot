<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/EV0270';
    var grid;
    var selRow;

    function init() {

        grid = EVF.C('grid');

        EVF.C('EV_TYPE').removeOption('REGISTRATION');
        grid.setProperty('panelVisible', ${panelVisible});

		if('${ses.ctrlCd}'.indexOf('E100') > -1) {
	        EVF.C('EV_TYPE').setValue('ESG');
		}

        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
			var params;

        	if(selRow == undefined) selRow = rowId;

            if(colId == 'ESG_POP') {
            	var evTypeCd = grid.getCellValue(rowId,'EV_TYPE_CD');
            	if (value=='') return;
            	params = {
                		EV_NUM : grid.getCellValue(rowId, "EV_NUM")
                	   ,VENDOR_CD : grid.getCellValue(rowId, "VENDOR_CD")
       	               ,detailView    	: true
                };
                everPopup.openPopupByScreenId('EV0270P01', 1000, 900, params);
            }


        	if(colId === 'multiSelect'){
		        let selectedEvNum = grid.getCellValue(rowId, 'EV_NUM');

		        if(value === '1'){
			        grid.checkEqualRow("EV_NUM", selectedEvNum);
				}else{
			        grid._gvo.setCheckableExpression("values['EV_NUM'] \x3d '" + selectedEvNum + "'", false);
			        grid.checkAll(false);
			        grid._gvo.resetCheckables({
				        clearExpression: false
			        })
				}
			}

            if(colId == 'EV_NUM') {
            	params = {
            		EV_NUM : grid.getCellValue(rowId, "EV_NUM")
               	   ,POPUPFLAG : 'Y'
   	               ,detailView    	: true
                   ,havePermission : false
               	};
               	everPopup.openPopupByScreenId('EV0210', 1100, 900, params);
            }

            if(colId == 'VENDOR_CD') {
            	var param = {
                        VENDOR_CD: grid.getCellValue(rowId, 'VENDOR_CD'),
                        detailView: true,
                        popupFlag: true
                    };
                everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
            }

            if(colId == 'EV_USER_CNT') {//SRM_250 호출
            	var cnt = grid.getCellValue(rowId, "EV_USER_CNT");
            	var cntArray = grid.getCellValue(rowId, "EV_USER_CNT").toString().split('/');
				if(cntArray[1] == "0"){
					EVF.alert("${EV0270_EV_USER}");
					return;
				}

            	params = {
            	   EV_NUM: grid.getCellValue(rowId, "EV_NUM"),
            	   VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
            	   VENDOR_SQ: grid.getCellValue(rowId, "VENDOR_SQ"),
               	   POPUPFLAG: "Y",
   	               detailView: true,
                   havePermission: false,
					EV_TYPE : grid.getCellValue(rowId, "EV_TYPE_CD")
               	};

               	everPopup.openPopupByScreenId("EV0250", 1200, 1000, params);
            }
            if(colId == 'DETAIL') { //상세
				params = {
					 EV_NUM			: grid.getCellValue(rowId, "EV_NUM")
					,VENDOR_CD 		: grid.getCellValue(rowId, "VENDOR_CD")
				};
				everPopup.openCommonPopup(params, 'SP0050');
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

	    //멀티셀렉트 박스에서 처음 조회시 전체값 가져오기
	    var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
	    EVF.V('BUYER_CD',values.join(','));

    }

    <%-- 조회 --%>
    function doSearch() {

        var store = new EVF.Store();

        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
            	EVF.alert("${msg.M0002 }");
            }
            //grid.setColMerge.call(['EV_NUM','EV_NM'], true);
			grid.setColMerge(['EV_NUM','EV_NM']);

            //업체선정평가인 경우 점수조정이 불가
            var allgrid = grid.getAllRowId();
            for(var i in allgrid){
            	if(grid.getCellValue(allgrid[i], 'EV_TYPE_CD') === 'BD'){
            		grid.setCellReadOnly(allgrid[i], 'EV_SCORE', true);
		            grid.setCellReadOnly(allgrid[i], 'AMEND_REASON', true);
	            }
            }


        });
    }

    <%-- 평가완료  --%>
    function doComplete(){
    	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
    	for(var i = 0; i<selRowId.length; i++){
    		var ev_score 		= grid.getCellValue(selRowId[i],'EV_SCORE');
    		var ev_type_cd 		= grid.getCellValue(selRowId[i],'EV_TYPE_CD');



    		<%-- 평가담당자만 처리가능합니다--%>
    		if(grid.getCellValue(selRowId[i],'EV_CTRL_USER_ID') != '${ses.userId}'){
    			EVF.alert('${EV0270_EV_CTRL_USER}');
        		return;
    		}

			if(ev_type_cd=='ESG' && '${ses.ctrlCd}'.indexOf('E100') == -1) {
    			EVF.alert('${EV0270_NOESG}');
        		return;
			}


    		<%-- 평가완료된 경우에는  처리불가능 --%>
    		if(grid.getCellValue(selRowId[i],'PROGRESS_CD') == '300'){
    			EVF.alert('${EV0270_PROGRESS_C}');
        		return;
    		}
    	}

    	EVF.confirm("${EV0270_MSG_01}", function () {
        	var store = new EVF.Store();

        	store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doComplete', function() {
            	EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
    	});

    }

    <%-- 완료취소  --%>
    function doCancel(){
    	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

    	for (var i = 0; i < selRowId.length; i++) {
    		<%-- 평가담당자만 처리가능합니다--%>
    		if(grid.getCellValue(selRowId[i],'EV_CTRL_USER_ID') != '${ses.userId}'){
    			EVF.alert('${EV0270_EV_CTRL_USER}');
        		return;
    		}


			if(grid.getCellValue(selRowId[i],'EV_TYPE_CD') =='ESG' && '${ses.ctrlCd}'.indexOf('E100') == -1) {
    			EVF.alert('${EV0270_NOESG}');
        		return;
			}



    		<%-- 평가완료된 경우에만 처리가능 --%>
    		if(grid.getCellValue(selRowId[i],'PROGRESS_CD') != '300'){
    			EVF.alert('${EV0270_PROGRESS_F}');
        		return;
    		}
    	}

    	EVF.confirm("${EV0270_MSG_02}", function () {
        	var store = new EVF.Store();
        	if(!store.validate()) return;

            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doCancel', function() {
            	EVF.alert(this.getResponseMessage(), function() {
                    doSearch();
                });
            });
    	});
    }

    <%-- 점수수정  --%>
    function doEdit(){
    	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
    	for (var i = 0; i < selRowId.length; i++) {

    		<%-- 평가담당자만 처리가능합니다--%>
    		if(grid.getCellValue(selRowId[i],'EV_CTRL_USER_ID') != '${ses.userId}'){
    			EVF.alert('${EV0270_EV_CTRL_USER}');
        		return;
    		}

			if(grid.getCellValue(selRowId[i],'EV_TYPE_CD') =='ESG' && '${ses.ctrlCd}'.indexOf('E100') == -1) {
    			EVF.alert('${EV0270_NOESG}');
        		return;
			}

    		<%-- 평가완료된 경우에만 처리가능 --%>
    		if(grid.getCellValue(selRowId[i],'PROGRESS_CD') != '300'){
    			EVF.alert('${EV0270_PROGRESS_F}');
        		return;
    		}

    		var ev_score = grid.getCellValue(selRowId[i],'EV_SCORE');
    		var amend_reason 	= grid.getCellValue(selRowId[i],'AMEND_REASON');

    		<%-- 그리드 필수항목을 확인하세요 --%>
    		if(ev_score == '')	{
    			EVF.alert('${EV0270_TOTAL_SCORE}');
    			return;
    		}

    		if(amend_reason == '')	{
    			EVF.alert('${EV0270_RMK}');
    			return;
    		}
    	}

    	var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + '/doEdit', function() {
        	EVF.alert(this.getResponseMessage(), function() {
                doSearch();
            });
        });
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

    <%-- 협력사명 조회 --%>
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
<e:window id="EV0270" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
    <e:row>
		<%-- 평가생성일 --%>
		<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
		<e:text>&nbsp;~&nbsp;</e:text>
		<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
		</e:field>

		<%-- 협력사명 --%>
		<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
		<e:field>
			<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${form.VENDOR_CD}" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
			<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
			<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
			<e:inputHidden id="ESG_CHK_TYPE" name="ESG_CHK_TYPE" value="" />
		</e:field>

		<%-- 평가담당자 --%>
		<e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
		<e:field>
			<e:inputText id="EV_CTRL_USER_NM" name="EV_CTRL_USER_NM" value="" width="${form_EV_CTRL_USER_NM_W}" maxLength="${form_EV_CTRL_USER_NM_M}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
		</e:field>
		<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>

	</e:row>

   	<e:row>
		<%-- 평가명 --%>
		<e:label for="EV_NM" title="${form_EV_NM_N}"/>
		<e:field>
			<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="${form_EV_NM_W}" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
		</e:field>
		<%-- 진행상태 --%>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
			<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="140px" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
		</e:field>
		<%-- 평가구분 --%>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field>
			<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="140px" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    <e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
    <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
    <e:button id="doEdit" name="doEdit" label="${doEdit_N}" onClick="doEdit" disabled="${doEdit_D}" visible="${doEdit_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>
</e:ui>
