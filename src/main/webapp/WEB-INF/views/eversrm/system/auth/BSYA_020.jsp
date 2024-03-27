<!--
* BSYA_020 : 메뉴-권한 Mapping
* 시스템관리 > 권한 > 메뉴-권한 Mapping
-->
<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
    var baseUrl = "/eversrm/system/auth/BSYA_020/";
    var gridL   = {};
    var gridR   = {};

    function init() {
        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");

        gridL.setProperty('shrinkToFit', true);
        gridR.setProperty('shrinkToFit', true);

        gridL.setProperty('panelVisible', ${panelVisible});
        gridR.setProperty('panelVisible', ${panelVisible});
        gridL.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });
        gridR.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

    }

    function doSearchL() {

        var authCode = EVF.V("AUTH_CD");

        if (authCode == "") {
            return alert("${BSYA_020_0001}");
        }
		var store = new EVF.Store(); // formL
		store.setGrid([gridL]);
		store.load(baseUrl + 'doSearchL', function() {
		    if(gridL.getRowCount() == 0){
		    	alert("${msg.M0002 }");
		    }
		});
    }

    function doSearchR() {

		var store = new EVF.Store();	// formR
		store.setGrid([gridR]);
		store.load(baseUrl + 'doSearchR', function() {
		    if(gridR.getRowCount() == 0){
		    	alert("${msg.M0002 }");
		    }
		});
    }

    function doSearchAUTH(strColumnKey, nRow) {
        var param = {
            callBackFunction: "selectAthorization"
        };

        everPopup.openCommonPopup(param, 'SP0008');
    }
    function selectAthorization(data) {
        EVF.C("AUTH_CD").setValue(data.AUTH_CD);
        EVF.C("AUTH_NM").setValue(data.AUTH_NM);

      //  EVF.C("MAIN_MODULE_TYPE").setValue(data.MAIN_MODULE_TYPE);
        doSearchL();
    }
    function doSendLeft() {
        var auth_cd = EVF.V("AUTH_CD");
        if (auth_cd == '') {
            alert("${BSYA_020_0001 }");
            return;
        }

        if(!gridR.isExistsSelRow()) { return alert("${msg.M0004}"); }

        var rightRowCount = gridR.getRowCount();
        var kkk = gridR.getSelRowId();

        for (var i = kkk.length - 1; i > -1; i--) {

            var menu_group_cd = gridR.getCellValue(kkk[i], "MENU_GROUP_CD");
            var leftRowCount  = gridL.getRowCount();
            var addOk = "ok";

            for (var j = leftRowCount - 1; j > -1; j--) {
                if (gridL.getCellValue(j, "MENU_GROUP_CD") == menu_group_cd && gridL.getCellValue(j, "AUTH_CD") == auth_cd) {
                    addOk = "fail";

                    //gridR.deleteRow(i);
                   // gridR.setCellValue(i, "SELECTED", "0");
                }
            }

            if (addOk == "ok") {
        		gridL.addRow([{
	 						   'INSERT_FLAG'         : 'I'
    	 					 , 'MENU_GROUP_CD'       : gridR.getCellValue(kkk[i], "MENU_GROUP_CD")
        	 				 , 'MENU_GROUP_NM'       : gridR.getCellValue(kkk[i], "MENU_GROUP_NM")
            	 			 , 'MODULE_TYPE'         : gridR.getCellValue(kkk[i], "MODULE_TYPE")
                	 		 , 'MODULE_TYPE_NM'      : gridR.getCellValue(kkk[i], "MODULE_TYPE_NM")
                    	 	 , 'AUTH_CD'             : EVF.V("AUTH_CD")
                    	 	 , 'MAIN_MODULE_TYPE'    : EVF.V("MAIN_MODULE_TYPE")
	 						 , 'AUTH_MAPPING_TYPE'   : 'MUGR'
        	 				 , 'GATE_CD'             : gridR.getCellValue(kkk[i], "GATE_CD")
        		}]);
            }
        }
    }
    function doSave() {

        if(!gridL.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if (!confirm("${msg.M0021}")) return;

		var store = new EVF.Store();
		store.setGrid([gridL]);
		store.getGridData(gridL, 'sel');
		store.load(baseUrl + 'doSave', function(){
    		alert(this.getResponseMessage());
    		doSearchL();
    	});
    }
    function doDelete() {

        if(!gridL.isExistsSelRow()) { return alert("${msg.M0004}"); }

        if (!confirm("${msg.M0013}")) return;

		var store = new EVF.Store();
		store.setGrid([gridL]);
		store.getGridData(gridL, 'sel');
		store.load(baseUrl + 'doDelete', function(){
    		alert(this.getResponseMessage());
    		doSearchL();
    	});
    }

    </script>

    <e:window id="BSYA_020" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
	<e:panel id="pnl1" width="48%">
    	<e:searchPanel id="frmLeft" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchL">
        	<e:row>
                <e:label for="AUTH_CD" title="${lForm_AUTH_CD_N}"></e:label>
                <e:field>
                    <e:search id="AUTH_CD" name="AUTH_CD" value="${form.AUTH_CD}" width="30%" maxLength="${form_AUTH_CD_M}" onIconClick="doSearchAUTH" disabled="${form_AUTH_CD_D}" readOnly="true" required="${form_AUTH_CD_R}" />
                    <e:inputText id="AUTH_NM" name="AUTH_NM" value="${form.AUTH_NM}"  width="70%" maxLength="${form_AUTH_NM_M}" disabled="${form_AUTH_NM_D}" readOnly="true" required="${form_AUTH_NM_R}" />
                </e:field>
            </e:row>
					<e:inputHidden id="MAIN_MODULE_TYPE" name="MAIN_MODULE_TYPE"/>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%"  align="right">
           	<e:button id="doSearchL"       name="doSearchL"             label="${doSearchL_N }"       onClick="doSearchL"       disabled="${doSearchL_D }"        visible="${doSearchL_V }"        />
           	<e:button id="doSave"          name="doSave"                   label="${doSave_N }"          onClick="doSave"          disabled="${doSave_D }"           visible="${doSave_V }"        />
           	<e:button id="doDelete"        name="doDelete"               label="${doDelete_N }"        onClick="doDelete"        disabled="${doDelete_D }"         visible="${doDelete_V }"        />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
	</e:panel>

	<e:panel id="pnl2" width="20px" height="100%">
        <div ><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
        	<img src="/images/icon/thumb_prev.png" width="13" height="22" onClick="doSendLeft()" style="cursor: pointer;">
        </div>
	</e:panel>

	<e:panel id="pnl3" width="50%">
         <e:searchPanel id="frmRight" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchR">
            <e:row>
                <e:label for="MODULE_TYPE" title="${rForm_MODULE_TYPE_N}"></e:label>
                <e:field>
                	<e:select id="MODULE_TYPE" name="MODULE_TYPE" value=""   disabled="${form_MODULE_TYPE_D }"   options="${moduleTypeOptions}" width="100%" required="${form_MODULE_TYPE_R }" readOnly="${form_MODULE_TYPE_RO }"></e:select>
               </e:field>

                <e:label for="MENU_GROUP_NM_R" title="${rForm_MENU_GROUP_NM_R_N}"></e:label>
                <e:field>
					<e:inputText id="MENU_GROUP_NM_R" style="${imeMode}" name="MENU_GROUP_NM_R" width='100%' maxLength="${form_MENU_GROUP_NM_R_M }" required="${form_MENU_GROUP_NM_R_R }" readOnly="${form_MENU_GROUP_NM_R_RO }" disabled="${form_MENU_GROUP_NM_R_D}"></e:inputText>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="b" width="100%"  align="right">
            <e:button id="doSearchR"       name="doSearchR"             label="${doSearchR_N }"       onClick="doSearchR"       disabled="${doSearchR_D }"        visible="${doSearchR_V }"        />
        </e:buttonBar>

         <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
	</e:panel>

    </e:window>
</e:ui>

