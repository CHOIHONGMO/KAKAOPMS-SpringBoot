<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
    var baseUrl = "/eversrm/system/auth/BSA_120/";
    var gridL   = {};
    var gridR   = {};

    function init() {
        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");

		gridL.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }-1",
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		gridR.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }-2",
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});
    }

    function doSearchL() {

        var authCode = EVF.C("AUTH_CD").getValue();

        if (authCode == "") {
            alert("You must enter Authorization Profile Code.");
            return;
        }

		var store = new EVF.Store();	// formL
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
        doSearchL();
    }
    function doSendLeft() {
        var auth_cd = EVF.C("AUTH_CD").getValue();
        if (auth_cd == '') {
            alert("${BSA_120_0001 }");
            return;
        }

    	if( gridR.isEmpty( gridR.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        var rightRowCount = gridR.getRowCount();
        var kkk = gridR.jsonToArray(gridR.getSelRowId()).value;
        var auth_code = EVF.C("AUTH_CD").getValue();






        for (var i = kkk.length - 1; i > -1; i--) {


                var menu_group_code = gridR.getCellValue("MODULE_TYPE", i);
                var screen_id = gridR.getCellValue("SCREEN_ID", i);
                var action_code = gridR.getCellValue("ACTION_CD", i);
                var leftRowCount = gridL.getRowCount();
                var addOk = "ok";





                var leftRowCount  = gridL.getRowCount();
                var addOk = "ok";

                for (var j = leftRowCount - 1; j > -1; j--) {
                    if (gridL.getCellValue("MODULE_TYPE", j) == menu_group_code && gridL.getCellValue("SCREEN_ID", j) == screen_id && gridL.getCellValue("ACTION_CODE", j) == action_code && gridL.getCellValue("AUTH_CODE", j) == auth_code) {
                        addOk = "fail";
                    }
                }

                if (addOk == "ok") {

                	gridL.addRow([{
    	 						   'INSERT_FLAG'         : 'I'

    	                	 	   , 'MODULE_TYPE'         : gridR.getCellValue(kkk[i], "MODULE_TYPE")
    	                	 	   , 'SCREEN_ID'         : gridR.getCellValue(kkk[i], "SCREEN_ID")
    	                	 	   , 'SCREEN_NM'         : gridR.getCellValue(kkk[i], "SCREEN_NM")

    	                	 	   , 'ACTION_CD'         : gridR.getCellValue(kkk[i], "ACTION_CD")
    	                	 	   , 'ACTION_NM'         : gridR.getCellValue(kkk[i], "ACTION_NM")

    	                	 	   , 'AUTH_MAPPING_TYPE'         : 'SCAC'

        	                	   , 'AUTH_CD'         : EVF.C("AUTH_CD").getValue()
            	 				   , 'GATE_CD'             : gridR.getCellValue(kkk[i], "GATE_CD")
            		}]);
                }
        }
    }
    function doSave() {
    	if( gridR.isEmpty( gridR.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0021}")) return;

		var store = new EVF.Store();
		if(!store.validate()) return;
		store.setGrid([gridR]);
		store.getGridData(gridR, 'sel');
		store.load(baseUrl + 'doSave', function(){
    		alert(this.getResponseMessage());
    		doSearchL();
    	});
    }
    function doDelete() {
    	if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

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

    <e:window id="BSA_120" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
	<e:panel id="pnl1" width="48%">
    	<e:searchPanel id="frmLeft" useTitleBar="false" title="${fullScreenName}" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchL">
        	<e:row>
                <e:label for="AUTH_CD" title="${lForm_AUTH_CD_N}"></e:label>
                <e:field>
					<e:search id="AUTH_CD" name="AUTH_CD" width="40%" onIconClick="doSearchAUTH"  disabled="${lForm_AUTH_CD_D }"     maxLength="${lform_AUTH_CD_M}" required="${lForm_AUTH_CD_R }" readOnly="${lform_AUTH_CD_RO }" />
               </e:field>
            </e:row>
			<e:label for="SCREEN_NM" title="${lForm_SCREEN_NM_N}"/>
			<e:field>
				<e:inputText id="SCREEN_NM" name="SCREEN_NM" value="${form.SCREEN_NM}" width="40%" maxLength="${lForm_SCREEN_NM_M}" disabled="${lForm_SCREEN_NM_D}" readOnly="${lForm_SCREEN_NM_RO}" required="${lForm_SCREEN_NM_R}" />
			</e:field>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%"  align="right">
           	<e:button id="doSearchL"       name="doSearchL"             label="${doSearchL_N }"       onClick="doSearchL"       disabled="${doSearchL_D }"        visible="${doSearchL_V }"        />
           	<e:button id="doDelete"        name="doDelete"               label="${doDelete_N }"        onClick="doDelete"        disabled="${doDelete_D }"         visible="${doDelete_V }"        />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
	</e:panel>

	<e:panel id="pnl2" width="20px" height="100%">
        <div ><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
        	<img src="/images/gallery/thumb_prev.png" width="13" height="22" onClick="doSave()" style="cursor: pointer;">
        </div>
	</e:panel>

	<e:panel id="pnl3" width="50%">
         <e:searchPanel id="frmRight" useTitleBar="false" title="${fullScreenName}" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchR">
            <e:row>
			<e:label for="sCAPTION" title="${lForm_sCAPTION_N}"/>
			<e:field>
                        <e:select id="actionType" name="actionType" placeHolder="${placeHolder }" required="false" disabled="false" readOnly="false" visible="true"  value=""  width="99">
			      <e:option text="Screen Name" value="1" />
			      <e:option text="Screen ID" value="2" />
			      <e:option text="Action Name" value="3" />
			      <e:option text="Action Code" value="4" />
                        </e:select>
			<e:inputText id="actionValue" name="actionValue" value="${form.SCREEN_NM}" width="50%" maxLength="${lForm_SCREEN_NM_M}" disabled="false" readOnly="false" required="false" />
			</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="b" width="100%"  align="right">
            <e:button id="doSearchR"       name="doSearchR"             label="${doSearchR_N }"       onClick="doSearchR"       disabled="${doSearchR_D }"        visible="${doSearchR_V }"        />
           	<e:button id="doSave"          name="doSave"                   label="${doSave_N }"          onClick="doSave"          disabled="${doSave_D }"           visible="${doSave_V }"        />
        </e:buttonBar>

         <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
	</e:panel>

    </e:window>
</e:ui>