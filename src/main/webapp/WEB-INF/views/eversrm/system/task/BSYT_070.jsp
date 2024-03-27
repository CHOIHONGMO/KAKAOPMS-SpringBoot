<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : BSYT_070(사용자 - 플랜트 Mapping)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
    <script>

        var grid;
        var baseUrl = "/eversrm/system/task/BSYT_070";
        var selRow;

        function init() {

            grid = EVF.C('grid');
            <%-- grid.setProperty("shrinkToFit", true); --%>
            grid.setProperty('panelVisible', ${panelVisible});
            // grid Column Head Merge
            grid.setProperty('multiselect', true);

            // Grid AddRow Event
            grid.addRowEvent(function() {
                addParam = [{'USE_FLAG' : '1'}];
                grid.addRow(addParam);
            });

            // Grid Excel Event
            grid.excelExportEvent({
                allCol : "${excelExport.allCol}",
                selRow : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }",
                excelOptions : {
                    imgWidth      : 0.12, 		// 이미지 너비
                    imgHeight     : 0.26,		    // 이미지 높이
                    colWidth      : 20,        	// 컬럼의 넓이
                    rowSize       : 500,       	// 엑셀 행에 높이 사이즈
                    attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
                }
            });

            grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
                selRow = rowid;

                switch(celname) {

                    case 'USER_ID_IMG':
                        var param = {
                            callBackFunction : 'selectUserAss'
                        };

                        everPopup.openCommonPopup(param, 'SP0011');

                        break;
                }
            });

            grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});

            //doSearch();
        }

        // 조회
        function doSearch() {
            var store = new EVF.Store();

            // form validation Check
            if(!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl+'/doSearch', function() {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // 저장
        function doSave() {
            var store = new EVF.Store();
            var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

            if(selRowIds.length == 0) {
                return alert("${msg.M0004}");
            }

            // Grid Validation Check
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            /*
             // 동일한 데이터 여부 체크
             var cnt = 0;
             var alertMsg = "";
             var selRowId = grid.getSelRowId();

             for(var i = 0; i < grid.getRowCount(); i++) {

             // 선택된 Id 갯수만큼 돌면서
             for(idx in selRowId) {
             // 전체 갯수와 Id 가 동일하지 않은 데이터를 대상으로 체크
             if(i != selRowId[idx]) {
             if(grid.getCellValue(i, "USER_ID") == grid.getCellValue(selRowId[idx], "USER_ID") &&
             grid.getCellValue(i, "PLANT_CD") == grid.getCellValue(selRowId[idx], "PLANT_CD")) {
             //alert(everString.getMessage("${BSYT_070_0001}", grid.getCellValue(i, "USER_ID")+", "+grid.getCellValue(i, "PLANT_CD")));
             alertMsg += grid.getCellValue(i, "USER_ID")+", "+grid.getCellValue(i, "PLANT_CD")+"\n";
             cnt++;
             }
             }
             }
             }

             if(cnt > 0) {
             alert(everString.getMessage("${msg.M0034}", alertMsg));
             //alert(everString.getMessage("${BSYT_070_0001}", alertMsg));
             return;
             }
             */
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            if (!confirm("${msg.M0021}")) return;
            store.load(baseUrl + '/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 삭제
        function doDelete() {
            if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
                alert("${msg.M0004}");
                return;
            }

            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doDelete', function(){
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // form 사용자명 아이콘 클릭
        function searchUserNm() {
            var param = {
                callBackFunction : 'doSetUserNmForm'
            };
            everPopup.openCommonPopup(param, 'SP0040');
        }

        // form 사용자명 팝업 리턴 셋팅
        function doSetUserNmForm(data) {
            EVF.C("USER_NM").setValue(data.CTRL_USER_NM);
            EVF.C("USER_ID").setValue(data.CTRL_USER_ID);
        }

        // grid 사용자명 팝업 리턴 셋팅
        function selectUserAss(data) {
            grid.setCellValue(selRow, "USER_ID", data.USER_ID);
            grid.setCellValue(selRow, "USER_NM", data.USER_NM);

            var selectedRow = grid.getSelRowValue();
            var selRowIds = grid.getSelRowId();
            if (selectedRow.length > 1) {
                if (confirm('${BSYT_070_0002}')) {
                    for(var x in selRowIds) {
                        var rowId = selRowIds[x];
                        grid.setCellValue(rowId, 'USER_ID', data.USER_ID);
                        grid.setCellValue(rowId, 'USER_NM', data.USER_NM);
                    }
                }
            }
        }

    </script>

    <e:window id="BSYT_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <%--사용자명--%>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
                    <e:search id="USER_NM" style="ime-mode:inactive" name="USER_NM" value="" width="${inputTextWidth}" maxLength="${form_USER_NM_M}" onIconClick="searchUserNm" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                    <e:inputHidden id="USER_ID" name="USER_ID" />
                </e:field>
                <%--플랜트--%>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${refFlant}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar width="100%" align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>