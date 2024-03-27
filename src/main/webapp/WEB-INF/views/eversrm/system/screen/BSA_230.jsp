<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
    var baseUrl = "/eversrm/system/screen/BSA_230/";
    var gridL   = {};
    var gridR   = {};
	var cuurRow;
    function init() {
        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");
		gridL.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }-1",
		    excelOptions : {
				imgWidth      : 0.12,       <%-- // 이미지의 너비. --%>
				imgHeight     : 0.26,      <%-- // 이미지의 높이. --%>
				colWidth      : 20,        <%-- // 컬럼의 넓이. --%>
				rowSize       : 500,       <%-- // 엑셀 행에 높이 사이즈. --%>
		        attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		gridR.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }-2",
		    excelOptions : {
				imgWidth      : 0.12,       <%-- // 이미지의 너비. --%>
				imgHeight     : 0.26,      <%-- // 이미지의 높이. --%>
				colWidth      : 20,        <%-- // 컬럼의 넓이. --%>
				rowSize       : 500,       <%-- // 엑셀 행에 높이 사이즈. --%>
		        attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});

		gridL.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			if (celname == 'USER_NM' ) {
				cuurRow  = rowid;
				everPopup.userSearchPopup('setUser', rowid, '', 'buyer', '');
			}
		});
    }

    function setUser(dataJsonArray) {
   		gridL.setCellValue(cuurRow, "USER_ID",  dataJsonArray.USER_ID<e:gridPanel gridType="${_gridType}");
   		gridL.setCellValue(cuurRow, "USER_NM",  dataJsonArray.USER_NM);
	}

    function doSearchL() {

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
        EVF.C("AUTH_CD").setValue(data.AUTH_CD<e:gridPanel gridType="${_gridType}");
        doSearchL();
	}
	function doSendLeft() {
    	if( gridR.isEmpty( gridR.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        var kkk = gridR.jsonToArray(gridR.getSelRowId()).value;

        for (var i = kkk.length - 1; i > -1; i--) {


                var user_id = gridR.getCellValue(i,"USER_ID");
                var auth_cd = gridR.getCellValue(i, "AUTH_CD");

                var leftRowCount  = gridL.getRowCount();
                var addOk = "ok";

                for (var j = leftRowCount - 1; j > -1; j--) {
                    if (gridL.getCellValue(j, "USER_ID") == user_id && gridL.getCellValue(j, "AUTH_CD") == auth_cd) {
                        addOk = "fail";
                    }
                }
                if (addOk == "ok") {

                	gridL.addRow([{
    	 						   'INSERT_FLAG'         : 'I'

    	                	 	   , 'USER_ID'         : gridR.getCellValue(kkk[i], "USER_ID")
    	                	 	   , 'USER_NM'         : gridR.getCellValue(kkk[i], "USER_NM")
    	                	 	   , 'AUTH_CD'         : gridR.getCellValue(kkk[i], "AUTH_CD")
    	                	 	   , 'AUTH_NM'         : gridR.getCellValue(kkk[i], "AUTH_NM")

            	 				   , 'GATE_CD'             : gridR.getCellValue(kkk[i], "GATE_CD")
            		}]);
                }
        }
	}
	function doSave() {

		if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            return alert("${msg.M0004}");
        }

    	if (!gridL.validate().flag) { return alert(gridL.validate().msg); }

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
	function doSelectUserL() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUserL'
        };
		everPopup.openCommonPopup(param,"SP0011");
	}
	function selectUserL(dataJsonArray) {
        EVF.C("USER_ID_L").setValue(dataJsonArray.USER_ID<e:gridPanel gridType="${_gridType}");
	}
	function doSelectUserR() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUserR'
        };
		everPopup.openCommonPopup(param,"SP0011");
	}
	function selectUserR(dataJsonArray) {
        EVF.C("USER_ID_R").setValue(dataJsonArray.USER_ID<e:gridPanel gridType="${_gridType}");
	}

	</script>

    <e:window id="BSA_230" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
	<e:panel id="pnl1" width="48%">
    	<e:searchPanel id="frmLeft" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchL">
        	<e:row>
                <e:label for="AUTH_CD" title="${lForm_AUTH_CD_N}"></e:label>
                <e:field>
					<e:search id="AUTH_CD" name="AUTH_CD" width="100%" onIconClick="doSearchAUTH"  disabled="${lForm_AUTH_CD_D }"     maxLength="${lform_AUTH_CD_M}" required="${lForm_AUTH_CD_R }" readOnly="${lform_AUTH_CD_RO }" />
               </e:field>
            </e:row>
        	<e:row>
				<e:label for="USER_ID_L" title="${lForm_USER_ID_L_N}"/>
				<e:field>
				<e:search id="USER_ID_L" name="USER_ID_L" value="" width="100%" maxLength="${lForm_USER_ID_L_M}" onIconClick="${lForm_USER_ID_L_RO ? 'everCommon.blank' : 'doSelectUserL'}" disabled="${lForm_USER_ID_L_D}" readOnly="${lForm_USER_ID_L_RO}" required="${lForm_USER_ID_L_R}" />
				</e:field>
			</e:row>

        	<e:row>
				<e:label for="USER_NM_L" title="${lForm_USER_NM_L_N}"/>
				<e:field>
				<e:inputText id="USER_NM_L" name="USER_NM_L" value="${form.USER_NM_L}" width="100%" maxLength="${lForm_USER_NM_L_M}" disabled="${lForm_USER_NM_L_D}" readOnly="${lForm_USER_NM_L_RO}" required="${lForm_USER_NM_L_R}" />
				 </e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%"  align="right">
           	<e:button id="doSearchL"       name="doSearchL"             label="${doSearchL_N }"       onClick="doSearchL"       disabled="${doSearchL_D }"        visible="${doSearchL_V }"        />
           	<e:button id="doSave"          name="doSave"                   label="${doSave_N }"          onClick="doSave"          disabled="${doSave_D }"           visible="${doSave_V }"        />
           	<e:button id="doDelete"        name="doDelete"               label="${doDelete_N }"        onClick="doDelete"        disabled="${doDelete_D }"         visible="${doDelete_V }"        />
        </e:buttonBar>

        <e:gridPanel id="gridL" name="gridL" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
	</e:panel>

	<e:panel id="pnl2" width="20px" height="100%">
        <div ><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
        	<img src="/images/everuxf/icons/13x22_thumb_prev.png" width="13" height="22" onClick="doSendLeft()" style="cursor: pointer;">
        </div>
	</e:panel>

	<e:panel id="pnl3" width="50%">
         <e:searchPanel id="frmRight" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchR">
            <e:row>
				<e:label for="USER_ID_R" title="${rForm_USER_ID_R_N}"/>
				<e:field>
				<e:search id="USER_ID_R" name="USER_ID_R" value="" width="100%" maxLength="${rForm_USER_ID_R_M}" onIconClick="${rForm_USER_ID_R_RO ? 'everCommon.blank' : 'doSelectUserR'}" disabled="${rForm_USER_ID_R_D}" readOnly="${rForm_USER_ID_R_RO}" required="${rForm_USER_ID_R_R}" />
				</e:field>
            </e:row>

            <e:row>
				<e:label for="USER_NM_R" title="${rForm_USER_NM_R_N}"/>
				<e:field>
				<e:inputText id="USER_NM_R" name="USER_NM_R" value="${form.USER_NM_R}" width="100%" maxLength="${rForm_USER_NM_R_M}" disabled="${rForm_USER_NM_R_D}" readOnly="${rForm_USER_NM_R_RO}" required="${rForm_USER_NM_R_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="b" width="100%"  align="right">
            <e:button id="doSearchR"       name="doSearchR"             label="${doSearchR_N }"       onClick="doSearchR"       disabled="${doSearchR_D }"        visible="${doSearchR_V }"        />
        </e:buttonBar>

         <e:gridPanel id="gridR" name="gridR" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
	</e:panel>

    </e:window>
</e:ui>