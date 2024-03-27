<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

		var gridD;
        var baseUrl = "/evermp/MY01/";
        var eventRowId = 0;

        function init() {

        	gridD = EVF.C("gridD");
//        	gridD.setProperty('multiSelect', false);

        	gridD.cellClickEvent(function(rowId, colId, value) {
        		if(colId == "SELECTED") {
                    if(EVF.isEmpty(gridD.getCellValue(rowId, "SEQ"))) {
                    	return;
                    }

        			var selectedData = gridD.getRowValue(rowId);
					opener['${param.callBackFunction}'](selectedData);
					doClose();
				}

                if (colId == "DELY_ZIP_CD") {
                    eventRowId = rowId;
                    param = {
                        callBackFunction: "setGridZipCode",
                        modalYn: false
                    };
                    //everPopup.openWindowPopup(url, 700, 600, param);
                    everPopup.jusoPop("/common/code/BADV_020/view", param);
                }



			});


            gridD.addRowEvent(function() {
                var store = new EVF.Store();
                if(!store.validate()) { return;}

                gridD.addRow([{
                    CUST_CD: '${param.CUST_CD}',
                    USE_FLAG : '1'
                }]);
            });


            gridD.delRowEvent(function() {
                if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var delCnt = 0;
                var rowIds = gridD.getSelRowId();
                for(var i = rowIds.length -1; i >= 0; i--) {
                    if(!EVF.isEmpty(gridD.getCellValue(rowIds[i], "SEQ"))) {
                        delCnt++;
                    } else {
                        gridD.delRow(rowIds[i]);
                    }
                }
                if(delCnt > 0) {
                    doDeleteDT();
                }
            });




			doSearch();
        }




        function setGridZipCode(data) {
            if (data.ZIP_CD != "") {
                gridD.setCellValue(eventRowId, "DELY_ZIP_CD", data.ZIP_CD_5);
                gridD.setCellValue(eventRowId, 'DELY_ADDR_1', data.ADDR1);
                gridD.setCellValue(eventRowId, 'DELY_ADDR_2', data.ADDR2);
            }
        }




        // 고객사배송지삭제
        function doDeleteDT() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm("${msg.M0013}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load("/evermp/BS01/BS0102/" + "bs01050_doDeleteDT", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doSave() {
            var store = new EVF.Store();
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!gridD.validate().flag) { return alert(gridD.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load("/evermp/BS01/BS0102/" + "bs01050_doSaveDT", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }



        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([gridD]);
            store.setParameter("CUST_CD", "${param.CUST_CD}");
            store.load(baseUrl + 'my01007_doSearch', function() {
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
    <e:window id="MY01_007" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
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
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
            <e:button id="doInit" name="doInit" label="${doInit_N}" onClick="doInit" disabled="${doInit_D}" visible="${doInit_V}" align="left" />
        </e:buttonBar>

		<e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />

    </e:window>
</e:ui>
