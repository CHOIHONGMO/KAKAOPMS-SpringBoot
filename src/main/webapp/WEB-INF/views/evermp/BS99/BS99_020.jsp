<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var grid;
	var baseUrl = "/evermp/BS99/BS9901/";

	function init() {

        grid = EVF.C("grid");
        grid.setProperty('shrinkToFit', true); 					// 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
	    grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
	    grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
	    grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
	    grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
	    grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
	    grid.setProperty('multiSelect', ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

	    // VOC담당자(구매담당자 : T100) 체크
        var btnViewFlag = true;
        var ctrlArgs = EVF.C("CTRL_CD").getValue().split(",");
		for(var i = 0; i < ctrlArgs.length; i++) {
            if ("T100" == everString.replaceAll(ctrlArgs[i], " ", "")) {
                btnViewFlag = true;
            }
        }
        if(!btnViewFlag) { EVF.C("Receipt").setDisabled(true); }

        grid.cellClickEvent(function(rowId, colName, value) {
            if(colName === 'VC_NO') {
                doSavePop(value);
            }
            else if(colName === 'REQ_USER_NM') {
                var REQ_COM_TYPE = grid.getCellValue(rowId, "REQ_COM_TYPE");
                var USER_TYPE = "";
                var param = {
                    callbackFunction: "",
                    USER_ID: grid.getCellValue(rowId, "REQ_USER_ID"),
                    detailView: true
                };

                everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
            }
        });

        var DS_USER_ID_Options =  ${DS_USER_ID_Options};

        var lookupKeys = [];
        var lookupValues = [];

        for(var i in DS_USER_ID_Options) {
            lookupKeys.push(DS_USER_ID_Options[i].value);
            lookupValues.push(DS_USER_ID_Options[i].text);
        }

        /*
        grid._gvo.setLookups([{
            "id": "lookup",
            "levels": 1,
            "keys": lookupKeys,
            "values": lookupValues
        }]);
        var Col = grid._gvo.columnByField('DS_USER_ID');
        Col.lookupDisplay = true;
        Col.lookupSourceId = 'lookup';
        Col.lookupKeyFields = ["DS_USER_ID"];
        grid._gvo.setColumn(Col);
         */

        if('${form.MOVE_LINK_YN}' == 'Y') {
            EVF.V('DS_USER_ID', '${ses.userId}');
            EVF.V('PROGRESS_CD', '${form.PROGRESS_CD}');

            var chkName = "";
            var vocTypeOptions2 = JSON.parse('${vocTypeOptions2}');
            $('input[name=multiselect_VOC_TYPE]').each(function (k, v) {

                for(var i in vocTypeOptions2) {
                    var vocOptionVal = vocTypeOptions2[i].value;
                    if(v.value == vocOptionVal) {
                        chkName += v.title + ", ";
                        v.checked = true;
					}
                }
            });
            $('#VOC_TYPE').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
        }

        if('${form.autoSearchFlag}' == 'Y') {
            EVF.V('PROGRESS_CD', '100');
            EVF.V('VOC_TYPE', 'PA');
            EVF.V('DS_USER_ID', '${ses.userId}');
            EVF.V('START_DATE', '');
            EVF.V('END_DATE', '');

            var store = new EVF.Store();

            store.setGrid([grid]);
            store.load(baseUrl + "bs99020_doSearch", function () {
                if(grid.getRowCount() === 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        doSearch();
	}

	function doSearch() {

		var store = new EVF.Store();
		if (!store.validate()) { return; }

        store.setGrid([grid]);
		store.load(baseUrl + "bs99020_doSearch", function () {
			if(grid.getRowCount() === 0) {
				return alert('${msg.M0002}');
			}
		});
	}

    function doSavePop(vc_no) {
        var param = {
            callbackFunction: "doSavePop_callback",
            VC_NO: vc_no,
            detailView: false
        };

        everPopup.openPopupByScreenId("BS99_021", 800, 700, param);
    }

    function doSavePop_callback() {
        doSearch();
    }

    function doReceipt() {

        var store = new EVF.Store();
        if(!store.validate()) { return; }

        var rows = grid.getSelRowValue();
        for( var i = 0; i < rows.length; i++ ) {
			if(rows[i].PROGRESS_CD !== "100") {
			    return alert("${msg.M0161}");
            }
			if(rows[i].DS_USER_ID == "") {
				return alert("${BS99_020_001}");
			}
        }

        if(!confirm("${msg.M0066}")) { return; }

        store.setGrid([grid]);
        store.getGridData(grid, "sel");
        store.load(baseUrl + "bs99020_doReceipt", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }
 </script>
	<e:window id="BS99_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="CTRL_CD" name="CTRL_CD" value="${CTRL_CD}" />

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE}" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE}" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="VOC_TYPE" title="${form_VOC_TYPE_N}"/>
				<e:field>
					<e:select id="VOC_TYPE" name="VOC_TYPE" value="" options="${vocTypeOptions}" width="${form_VOC_TYPE_W}" disabled="${form_VOC_TYPE_D}" readOnly="${form_VOC_TYPE_RO}" required="${form_VOC_TYPE_R}" placeHolder="" useMultipleSelect="true"/>
				</e:field>
			</e:row>

			<e:row>
				<e:label for="REQ_COM_CD" title="${form_REQ_COM_CD_N}" />
				<e:field>
					<e:inputText id="REQ_COM_CD" name="REQ_COM_CD" value="" width="${form_REQ_COM_CD_W}" maxLength="${form_REQ_COM_CD_M}" disabled="${form_REQ_COM_CD_D}" readOnly="${form_REQ_COM_CD_RO}" required="${form_REQ_COM_CD_R}" />
				</e:field>
				<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}" />
				<e:field>
					<e:inputText id="REQ_USER_NM" name="REQ_USER_NM" value="" width="${form_REQ_USER_NM_W}" maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}" />
				</e:field>
				<e:label for="DS_USER_ID" title="${form_DS_USER_ID_N}"/>
				<e:field>
					<e:select id="DS_USER_ID" name="DS_USER_ID" value="" options="${DS_USER_ID_Options}" width="${form_DS_USER_ID_W}" disabled="${form_DS_USER_ID_D}" readOnly="${form_DS_USER_ID_RO}" required="${form_DS_USER_ID_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<%--2022.12.26 일괄접수 제외
            <e:button id="Receipt" name="Receipt" label="${Receipt_N}" onClick="doReceipt" disabled="${Receipt_D}" visible="${Receipt_V}"/>
            --%>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>