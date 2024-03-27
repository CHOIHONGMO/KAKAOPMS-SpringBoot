<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
	var baseUrl = "/eversrm/basic/user/";
    var gridL   = {};
    var gridR   = {};

    function init() {
        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");

        gridR.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			if (celname == 'USER_ID' || celname == 'USER_NM') {
				gridR.delRow(rowid);
			}
		});

        gridL.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			if (celname == 'USER_ID' || celname == 'USER_NM') {
				setUserInfo(rowid);
			}
		});

        gridL.setProperty('shrinkToFit', true);
        gridR.setProperty('shrinkToFit', true);

        gridL.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        gridR.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        doSearchR();
    }

    function setUserInfo(rowid) {
	    var user_id        = gridL.getCellValue(rowid, "USER_ID");
	    var rightRowCount  = gridR.getRowCount();
	    var addOk = "ok";

	    for (var j = rightRowCount - 1; j > -1; j--) {
	        if (gridR.getCellValue(j, "USER_ID") == user_id) {
	            addOk = "fail";
	        }
	    }

	    if (addOk == "ok") {
			gridR.addRow([{
							   'USER_ID'         : gridL.getCellValue(rowid, "USER_ID")
	 					 , 'USER_NM'       : gridL.getCellValue(rowid, "USER_NM")
		 				 , 'DEPT_NM'       : gridL.getCellValue(rowid, "DEPT_NM")
	    	 			 , 'POSITION_NM' : gridL.getCellValue(rowid, "POSITION_NM")
			}]);
	    }
    }

    function doSearchL() {
		var store = new EVF.Store();	// formL
		store.setGrid([gridL]);
		store.load(baseUrl + '/userMultiSearch/doSearchL', function() {
		    if(gridL.getRowCount() == 0){
		    	alert("${msg.M0002 }");
		    }
		    else if(gridL.getRowCount() === 1) {
//		    	setUserInfo(0);
		    	gridR.checkAll(true);
		    	gridL.checkAll(true);

				var store = new EVF.Store();
				store.setGrid([gridL,gridR]);
		        store.getGridData(gridL, 'sel');
		        store.getGridData(gridR, 'sel');
				store.load(baseUrl + '/userMultiSearch/doSendR', function() {
				});


		    }
		});

    }

    function doSearchR() {
		var store = new EVF.Store();	// formL
		var mmm = '${param.USER_IDS}';

		if (mmm == '') {
			return;
		}

		store.setParameter('USER_IDS', mmm);
		store.setGrid([gridR]);
		store.load(baseUrl + '/userMultiSearch/doSearchR', function() {
		});
    }

    function doSendLeft() {

    	var kkk = gridR.jsonToArray(gridR.getSelRowId()).value;
    	 for (var i = kkk.length - 1; i > -1; i--) {
    		 gridR.delRow(kkk[i]);

    	 }
    }
/*
    function doSendRight() {

    	if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        var kkk = gridL.jsonToArray(gridL.getSelRowId()).value;

        for (var i = kkk.length - 1; i > -1; i--) {

                var user_id       = gridL.getCellValue(kkk[i], "USER_ID");
                var rightRowCount = gridR.getRowCount();
                var addOk = "ok";

                for (var j = rightRowCount - 1; j > -1; j--) {
                    if (gridR.getCellValue(j, "USER_ID") == user_id) {
                        addOk = "fail";

                        //gridR.deleteRow(i);
                       // gridR.setCellValue(i, "SELECTED", "0");
                       break;
                    }
                }

                if (addOk == "ok") {
            		gridR.addRow([{
    	 						   'USER_ID'     : gridL.getCellValue(kkk[i], "USER_ID")
        	 					 , 'USER_NM'     : gridL.getCellValue(kkk[i], "USER_NM")
            	 				 , 'DEPT_NM'     : gridL.getCellValue(kkk[i], "DEPT_NM")
                	 			 , 'POSITION_NM' : gridL.getCellValue(kkk[i], "POSITION_NM")
            		}]);
                }
        }
    };
*/
    function doSendRight() {

    	if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

    	gridR.checkAll(true);

		var store = new EVF.Store();
		store.setGrid([gridL,gridR]);
        store.getGridData(gridL, 'sel');
        store.getGridData(gridR, 'sel');
		store.load(baseUrl + '/userMultiSearch/doSendR', function() {
		});
    }
    function doApply() {
    	gridR.checkAll(true);
    	var data = gridR.getSelRowValue();
    	opener['${param.callBackFunction}'](data);

    	doClose();
    }

	function doClose() {
        window.close();
    }

	</script>

    <e:window id="userMultiSearch" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
	<e:panel id="pnl1" width="100%">
    	<e:searchPanel id="form" title="${msg.M9999}"  useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2" onEnter="doSearchL">
    	    <e:inputHidden id="USER_TYPE_CHECK" name="USER_TYPE_CHECK" value="${param.userTypeCheck}"/>
        	<e:row>
        		<e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}" />
				<e:field>
					<e:inputText id="COMPANY_NM" name="COMPANY_NM" value="" width="${form_COMPANY_NM_W}" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="${form_COMPANY_NM_RO}" required="${form_COMPANY_NM_R}" />
				</e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N}"/>
                <e:field>
					<e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" width='100%' maxLength="${form_USER_NM_M }" required="${form_USER_NM_R }" readOnly="${form_USER_NM_RO }" disabled="${form_USER_NM_D}" />
                </e:field>
                <e:label for="USER_ID" title="${form_USER_ID_N}"/>
                <e:field>
					<e:inputText id="USER_ID" name="USER_ID" width='100%' maxLength="${form_USER_ID_L_M }" required="${form_USER_ID_R }" readOnly="${form_USER_ID_RO }" disabled="${form_USER_ID_D}" />
               </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%"  align="right">
           	<e:button id="doSearch"       name="doSearch"             label="${doSearch_N }"       onClick="doSearchL"       disabled="${doSearch_D }"        visible="${doSearch_V }"        />
           	<e:button id="doApply"        name="doApply"               label="${doApply_N }"        onClick="doApply"         disabled="${doApply_D }"         visible="${doApply_V }"        />
        </e:buttonBar>

    	<e:panel id="x1" width="48.7%">
    	<e:title title="${userMultiSearch_0001 }" />
        <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
    	</e:panel>

		<e:panel id="x3" width="20px" height="100%">
	        <div><BR><BR><BR><BR><BR><BR><BR><BR>
	        	&nbsp;<img src="/images/eversrm/button/thumb_next.png" width="10" height="22" onClick="doSendRight()" style="cursor: pointer;">
	        	<BR><BR><BR>
	        	&nbsp;<img src="/images/eversrm/button/thumb_prev.png" width="10" height="22" onClick="doSendLeft()" style="cursor: pointer;">
	        </div>
		</e:panel>
			<e:panel id="x2" width="48.7%">
			<e:title title="${userMultiSearch_0002 }" />
	         <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
		</e:panel>
	</e:panel>

    </e:window>
</e:ui>

