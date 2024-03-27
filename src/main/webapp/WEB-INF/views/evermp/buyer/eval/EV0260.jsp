<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/EV0260';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');
        grid.setProperty('panelVisible', ${panelVisible});
        EVF.C("EV_CTRL_USER_NM").setValue('${ses.userNm}');
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
        	var param;
        	if(selRow == undefined) selRow = rowId;

            if(colId == "VENDOR_CD") {
                var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                       // 'IRS_NUM' : grid.getCellValue(rowId, 'IRS_NO'),
                        'buttonAuth' : false,
                        'detailView': true
                    };
                    everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
            }

            if(colId == 'EV_NUM'){<%-- 평가생성페이지 --%>
            	params = {
            		EV_NUM: grid.getCellValue(rowId, "EV_NUM")
            	    , POPUPFLAG: 'Y'
            	    , detailView: true
            	    , havePermission: false
            	};
            	everPopup.openPopupByScreenId('SRM_210', 1100, 900, params);
            }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case 'FINAL_SCORE':
            	<%--
				  var weight = grid.getCellValue(rowId, "WEIGHT");
				  if(newValue > weight){
					  alert("${EV0260_BigInput}"); // 입력값이 가중치보다 큽니다.
					  grid.setCellValue(rowId, "FINAL_SCORE", weight);
				  }
				--%>
				  if (newValue > 100) {
					  alert("${EV0260_BigScore}"); // 최종점수는 100점 이하로 입력해야 합니다.
					  grid.setCellValue(rowId, "FINAL_SCORE", oldValue);
				  }
				  break;
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
      	if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
			//grid.setColMerge.call(['EV_NUM','EV_NM','VENDOR_CD','VENDOR_NM'], true);
			grid.setColMerge(['EV_NUM','EV_NM','VENDOR_CD','VENDOR_NM']);
        });
    }

    <%-- 저장 --%>
    function doSave() {

		var gridDatas = grid.getSelRowValue();
        if (gridDatas.length == 0) return alert("${msg.M0004}");

        for(var idx in gridDatas) {
            var rowData = gridDatas[idx];
            <%-- 평가담당자만 처리가능 --%>
            if (rowData['EV_CTRL_USER_ID'] != "${ses.userId }") return alert("${EV0260_EV_CTRL_USER}");
            <%-- 진행중인 상태만 처리가능--%>
            if (rowData['EM_PROGRESS'] != "200")           return alert("${EV0260_EM_PROGRESS}");

            if (rowData['REMARK'] == null || "" == rowData['REMARK'])	return alert("${EV0260_REMARK}")
        }

        var store = new EVF.Store();

        if(!confirm('${msg.M0021}')) { return; }

        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSave', function() {
            alert(this.getResponseMessage());
            doSearch();
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
    function EV_CTRL_USER_NM(){
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0001');
    }

    function selectEvCtrlUser(param){
    	EVF.C("EV_CTRL_USER_NM").setValue(param.USER_NM);
    	EVF.C("EV_CTRL_USER_ID").setValue(param.USER_ID);
    }


    <%-- 협력사 명 검색 --%>
	function VENDOR_NM(){
		var param = {
	    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0064');
	}

	function selectVendor(param){
    	EVF.C("VENDOR_NM").setValue(param.VENDOR_NM);
    	EVF.C("VENDOR_CD").setValue(param.VENDOR_CD);
    }

    </script>
<e:window id="EV0260" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
    <e:row>
	    <%-- 평가생성일 --%>
		<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
		<e:text>&nbsp;~&nbsp;</e:text>
		<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
		</e:field>
	    <%-- 평가번호 --%>
		<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
		<e:field>
		<e:search id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="" width="${form_EV_NUM_W}" maxLength="${form_EV_NUM_M}" onIconClick="${form_EV_NUM_RO ? 'everCommon.blank' : 'EV_NUM'}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}" />
		</e:field>
		<%-- 평가구분--%>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field>
		<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>
	</e:row>

    <e:row>
	    <%-- 평가담당자 --%>
	    <e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
		<e:field>
		<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="${form_EV_CTRL_USER_NM_W}" maxLength="${form_EV_CTRL_USER_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'EV_CTRL_USER_NM'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
		</e:field>
		<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>
	    <%-- 협력사명 --%>
	    <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field colSpan="3">
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'VENDOR_NM'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		</e:field>
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>

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
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    	<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>
</e:ui>
