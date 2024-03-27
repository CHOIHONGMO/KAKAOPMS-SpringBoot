<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
    var baseUrl = "/eversrm/system/auth/BSA_130/";
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
        if (EVF.C("BUYER_CD").getValue() == "") {
            EVF.C("BUYER_CD").setValue("${ses.companyCd }");
        }


		gridL.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
			if (cellName == 'SCR_ACT_PROFILE_CNT') {
				var store = new EVF.Store();	// formR
				store.setParameter("USER_ID",  gridL.getCellValue(rowId,"USER_ID"));
				 EVF.C("USER_ID").setValue( gridL.getCellValue(rowId,"USER_ID")    );
				 EVF.C("USER_NM").setValue(  gridL.getCellValue(rowId,"USER_NM")  );


				 EVF.C("GATE_CD").setValue(  gridL.getCellValue(rowId,"GATE_CD")  );


				 store.setGrid([gridR]);
				store.load(baseUrl + 'doSearchR', function() {
				    if(gridR.getRowCount() == 0){
				    	alert("${msg.M0002 }");
				    }
				});
			}
		});

		gridR.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
			if (cellName == 'ACTION_PROFILE_NM') {
				currRow = rowId;
		        var param = {
		                callBackFunction: "selectACPF"
		            };
		            everPopup.openCommonPopup(param, 'SP0010');
			}
		});

   			var store = new EVF.Store();
   			store.load('/eversrm/system/org/BSYO_060/doSearch', function() {
   				console.log(this.getParameter("treeData"));
        	var treeData = JSON.parse(this.getParameter("treeData"));
       		//	alert( JSON.stringify(treeData) );
				$("#tree").dynatree({
						persist: false,
						keyboard: true,
						children: treeData,
						minExpandLevel: 3,

						onActivate: function(node) {
							store.setGrid([gridL]);
							store.setParameter("DEPT_CD", node.data.DEPT_CD);
							EVF.C("DEPT_CD").setValue(node.data.DEPT_CD);
							store.load(baseUrl + 'doSearchL', function() {

							})

						}
					});
					$("#tree").dynatree("getTree").reload();
        });


			gridR.addRowEvent(function() {
				addParam = [{"USER_ID": EVF.C("USER_ID").getValue()   , GATE_CD : EVF.C("GATE_CD").getValue()    }];
            	gridR.addRow(addParam);
			});

    }

    function selectACPF(dataJsonArray) {
        gridR.setCellValue(currRow, "ACTION_PROFILE_CD", dataJsonArray.ACTION_PROFILE_CD);
        gridR.setCellValue(currRow, "ACTION_PROFILE_NM", dataJsonArray.ACTION_PROFILE_NM);
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


    function doSearchAUTH(strColumnKey, nRow) {
        var param = {
            callBackFunction: "selectAthorization"
        };

        everPopup.openCommonPopup(param, 'SP0008');
    }
    function selectAthorization(data) {
        EVF.C("AUTH_CD").setValue(data.AUTH_CD);
    }
    function doSave() {
    	if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

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
    function saveUSAC() {

    	if( gridR.isEmpty( gridR.getSelRowId() ) ) {
            return alert("${msg.M0004}");
        }
		var store = new EVF.Store();
		store.setGrid([gridR]);
		store.getGridData(gridR, 'sel');
        if(!store.validate()) return;

        if(!gridR.validate().flag) { return alert(gridR.validate().msg); }

        if (!confirm("${msg.M0021}")) return;
			store.load(baseUrl + 'saveUSAC', function(){
    		alert(this.getResponseMessage());


			var store = new EVF.Store();	// formR
			store.setGrid([gridR]);
			store.load(baseUrl + 'doSearchR', function() {
			    if(gridR.getRowCount() == 0){
			    	alert("${msg.M0002 }");
			    }
			});
		});
    }

    function deleteUSAC() {

    	if( gridR.isEmpty( gridR.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0013}")) return;

		var store = new EVF.Store();
		store.setGrid([gridR]);
		store.getGridData(gridR, 'sel');
		store.load(baseUrl + 'deleteUSAC', function(){
    		alert(this.getResponseMessage());
			var store = new EVF.Store();	// formR
			store.setGrid([gridR]);
			store.load(baseUrl + 'doSearchR', function() {
			    if(gridR.getRowCount() == 0){
			    	alert("${msg.M0002 }");
			    }
			});
		});
    }

    function saveUSAP() {

    	if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        authCode = EVF.C("AUTH_CD").getValue();
        if (authCode == "") {
            alert("Authorization Code - ${msg.M0004}");
            return;
        }

		var store = new EVF.Store();
		store.setParameter("AUTH_CD", EVF.C("AUTH_CD").getValue());
		store.setGrid([gridL]);
		store.getGridData(gridL, 'sel');
        if(!store.validate()) return;

        if(!gridL.validate().flag) { return alert(gridL.validate().msg); }

        if (!confirm("${msg.M0021}")) return;
			store.load(baseUrl + 'saveUSAP', function(){
    		alert(this.getResponseMessage());


			var store = new EVF.Store();	// formR
			store.setGrid([gridL]);
			store.load(baseUrl + 'doSearchL', function() {
			    if(gridL.getRowCount() == 0){
			    	alert("${msg.M0002 }");
			    }
			});
		});
    }

    function deleteUSAP() {

    	if( gridL.isEmpty( gridL.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0013}")) return;

		var store = new EVF.Store();
		store.setGrid([gridL]);
		store.getGridData(gridL, 'sel');
		store.load(baseUrl + 'deleteUSAP', function(){
    		alert(this.getResponseMessage());
			var store = new EVF.Store();	// formR
			store.setGrid([gridL]);
			store.load(baseUrl + 'doSearchL', function() {
			    if(gridL.getRowCount() == 0){
			    	alert("${msg.M0002 }");
			    }
			});
		});
    }

    function treeReload() {

		var store = new EVF.Store();
  			store.load('/eversrm/system/org/BSYO_060/doSearch', function() {
		console.log(this.getParameter("treeData"));
       	var treeData = JSON.parse(this.getParameter("treeData"));
      		//	alert( JSON.stringify(treeData) );
			$("#tree").dynatree({
					persist: false,
					keyboard: true,
					children: treeData,
					minExpandLevel: 3,

					onActivate: function(node) {
						store.setGrid([gridL]);
						store.setParameter("DEPT_CD", node.data.DEPT_CD);
						EVF.C("DEPT_CD").setValue(node.data.DEPT_CD);
						store.load(baseUrl + 'doSearchL', function() {
						})
					}
				});
				$("#tree").dynatree("getTree").reload();
        });
    }

	</script>

    <e:window id="BSA_130" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">

	<e:panel id="pnl0" width="25%">
			<e:searchPanel id="treeDept" title="부서정보">

				<e:row>
					<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
					<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"   onChange="treeReload"   options="${refBuyerCd}" width="${inputTextWidth}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}"  usePlaceHolder="false"/>

					<e:inputHidden id="DEPT_CD" name="DEPT_CD"/>


					</e:field>
				</e:row>
  			</e:searchPanel>

			<div id="tree" style="height: 600px; float: left; width: 100%;"> </div>

	</e:panel>


	<e:panel id="pnl1" width="35%">
    	<e:searchPanel id="formL" title="권한프로파일" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchL">
        	<e:row>
                <e:label for="AUTH_CD" title="${formL_AUTH_CD_N}"></e:label>
                <e:field>
					<e:search id="AUTH_CD" name="AUTH_CD" value="" width="${inputTextWidth}" maxLength="${formL_AUTH_CD_M}" onIconClick="doSearchAUTH" disabled="${formL_AUTH_CD_D}" readOnly="${formL_AUTH_CD_RO}" required="${formL_AUTH_CD_R}" />
               </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%"  align="right">
            <e:button id="doSaveUSAP" name="doSaveUSAP" label="${doSaveUSAP_N}" onClick="saveUSAP" disabled="${doSaveUSAP_D}" visible="${doSaveUSAP_V}"/>
            <e:button id="doDeleteUSAP" name="doDeleteUSAP" label="${doDeleteUSAP_N}" onClick="deleteUSAP" disabled="${doDeleteUSAP_D}" visible="${doDeleteUSAP_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
	</e:panel>

	<e:panel id="pnl3" width="35%">
         <e:searchPanel id="formR" title="액션프로파일" labelWidth="${labelWidth}" width="100%" columnCount="1" onEnter="doSearchR">
            <e:row>

				<e:label for="USER_ID" title="${formR_USER_ID_N}"/>
				<e:field>
				<e:inputText id="USER_ID" name="USER_ID" value="${form.USER_ID}" width="100%" maxLength="${formR_USER_ID_M}" disabled="${formR_USER_ID_D}" readOnly="${formR_USER_ID_RO}" required="${formR_USER_ID_R}" />
				 </e:field>
				<e:label for="USER_NM" title="${formR_USER_NM_N}"/>
				<e:field>
				<e:inputText id="USER_NM" name="USER_NM" value="${form.USER_NM}" width="100%" maxLength="${formR_USER_NM_M}" disabled="${formR_USER_NM_D}" readOnly="${formR_USER_NM_RO}" required="${formR_USER_NM_R}" />

					<e:inputHidden id="GATE_CD" name="GATE_CD"/>


				 </e:field>

            </e:row>
        </e:searchPanel>

        <e:buttonBar id="b" width="100%"  align="right">
	        <e:button id="doSaveUSAC" name="doSaveUSAC" label="${doSaveUSAC_N}" onClick="saveUSAC" disabled="${doSaveUSAC_D}" visible="${doSaveUSAC_V}"/>
	        <e:button id="doDeleteUSAC" name="doDeleteUSAC" label="${doDeleteUSAC_N}" onClick="deleteUSAC" disabled="${doDeleteUSAC_D}" visible="${doDeleteUSAC_V}"/>
        </e:buttonBar>

         <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
	</e:panel>

    </e:window>
</e:ui>