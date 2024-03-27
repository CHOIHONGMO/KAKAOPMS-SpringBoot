<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

		var grid;
        var baseUrl = "/eversrm/buyer/bmy";

        function init() {

        	grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
            grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
            grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
            grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
            grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
            grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
            grid.setProperty('multiSelect', false);                 // [선택] 컬럼의 사용여부를 지정한다. [true/false]

        	grid.cellClickEvent(function(rowId, colId, value) {
        		if(colId == "DELY_NM") {
        			var selectedData = grid.getRowValue(rowId);
					opener['${param.callBackFunction}'](selectedData);
					doClose();
				}
			});
        	
			doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.setParameter("CUST_CD", "${param.CUST_CD}");
            store.load(baseUrl + '/BMY01_030_doSearch', function() {
                
            });
        }

        function doInit() {
            opener["${param.callBackFunction}"]({});
            doClose();
        }

        function doClose() {
            window.close();
        }

    </script>
    <e:window id="BMY01_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2" onEnter="doSearch">
            <e:row>
                <e:label for="DELY_NM" title="${form_DELY_NM_N}"/>
                <e:field>
                    <e:inputText id='DELY_NM' name="DELY_NM" label='${form_DELY_NM_N }' value="${param.DELY_NM}" width='${form_DELY_NM_W }' maxLength='${form_DELY_NM_M }' required='${form_DELY_NM_R }' readOnly='${form_DELY_NM_RO }' disabled='${form_DELY_NM_D }' visible='${form_DELY_NM_V }'/>
                </e:field>
                <e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}"/>
                <e:field>
                    <e:inputText id='RECIPIENT_NM' name="RECIPIENT_NM" label='${form_RECIPIENT_NM_N }' value="" width='${form_RECIPIENT_NM_W }' maxLength='${form_RECIPIENT_NM_M }' required='${form_RECIPIENT_NM_R }' readOnly='${form_RECIPIENT_NM_RO }' disabled='${form_RECIPIENT_NM_D }' visible='${form_RECIPIENT_NM_V }'/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar width="100%" align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doInit" name="doInit" label="${doInit_N}" onClick="doInit" disabled="${doInit_D}" visible="${doInit_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
 