<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">
        var grid;
        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
            grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
            grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
            grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
            grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
            grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
            grid.setProperty('multiSelect', ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]
            grid._gvo.setCheckBar({ exclusive: true });

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "SUBJECT" && value != "") {
                    var param = {
                        'NOTICE_NUM': grid.getCellValue(rowId, "NOTICE_NUM"),
                        'NOTICE_TYPE': grid.getCellValue(rowId, "NOTICE_TYPE"),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_011P", 1000, 1200, param);
                }
                if(colId == "ATT_FILE_NUM_ICON" && value != "") {
                    if( !EVF.isEmpty(grid.getCellValue(rowId, 'ATT_FILE_NUM_ICON')) ) {
                        var uuid = grid.getCellValue(rowId, 'ATT_FILE_NUM');
                        var param = {
                            havePermission : false,
                            attFileNum     : uuid,
                            rowId          : rowId,
                            callBackFunction: '',
                            detailView : true,
                            bizType: 'NT'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 330, param);
                    }
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            grid.setProperty('multiSelect', true);
            grid.setProperty('shrinkToFit', true);

            if("${param.SUBJECT}" != null) {
                EVF.V("SUBJECT","${param.SUBJECT}");
            }

            if(EVF.V("NOTICE_TYPE") == ''){
                EVF.V("NOTICE_TYPE","PCR");
            }

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + '/BS03_011_doSearch', function() {
                if(grid.getRowCount() == 0){
                    EVF.alert("${msg.M0002 }");
                }
            });
        }

        function doCreate(){
            var param = {
                'NOTICE_NUM': "",
                'detailView': false,
                'popupFlag': true,
                'NOTICE_TYPE': EVF.V("NOTICE_TYPE")
            };
            everPopup.openWindowPopup('/evermp/BS03/BS0301/BS03_011P/view.so?', 1000, 1200, param, '거래제안');
        }

        function doChange() {

            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return EVF.alert('${msg.M0006}'); }

            var noticeNum = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                /*
                if("${ses.userId }" != grid.getCellValue(rowIds[i], "REG_USER_ID")) {
                    return EVF.alert("${BS03_011_001}");
                }
                */
                noticeNum = grid.getCellValue(rowIds[i], "NOTICE_NUM");
            }

            var param = {
                'NOTICE_NUM': noticeNum,
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS03_011P", 1000, 1200, param);
        }


        function doDelete() {

            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

            if(confirm("${msg.M0013 }")) {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl + '/BS03_011_doDelete', function(){
                    EVF.alert(this.getResponseMessage());
                    doSearch();
                });
            }
        }

    </script>
    <e:window id="BS03_011" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${BUYER_CD}"/>
            <e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${BUYER_NM}"/>
            <e:inputHidden id="NOTICE_TYPE" name="NOTICE_TYPE" value="${NOTICE_TYPE}"/>
            <e:row>
                <e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}" />
                <e:field>
                    <e:inputDate id="ADD_FROM_DATE" toDate="ADD_TO_DATE" name="ADD_FROM_DATE" value="${addFromDate}" width="${inputDateWidth }" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
                    <e:text>~&nbsp;</e:text>
                    <e:inputDate id="ADD_TO_DATE" fromDate="ADD_FROM_DATE" name="ADD_TO_DATE" value="${addToDate}" width="${inputDateWidth }" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
                </e:field>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}" />
                <e:field>
                    <e:inputText id="SUBJECT" name="SUBJECT" value="" width="${form_SUBJECT_W}" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Create" name="Create" label="${Create_N }" disabled="${Create_D }" visible="${Create_V}" onClick="doCreate" />
            <%--
            <c:if test="${ses.userType == 'C'}">
                <e:button id="Change" name="Change" label="${Change_N }" disabled="${Change_D }" visible="${Change_V}" onClick="doChange" />
                <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
            </c:if>
            --%>
        </e:buttonBar>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>