<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-11-02
  Scrren ID : DH1510
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
  	String devFlag = PropertiesManager.getString("eversrm.system.developmentFlag");
	String gwUrl = "";
	if ("true".equals(devFlag)) {
		  gwUrl = PropertiesManager.getString("gw.dev.url");
	} else {
		  gwUrl = PropertiesManager.getString("gw.real.url");
	}
  	String gwParam = PropertiesManager.getString("gw.param");
%>

<c:set var="devFlag" value="<%=devFlag%>" />
<c:set var="gwUrl" value="<%=gwUrl%>" />
<c:set var="gwParam" value="<%=gwParam%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>
    var grid;
    var baseUrl = "/eversrm/master/bom/DH1510";
    var selRow;
	var setRowId;
    function init() {
      grid = EVF.getComponent('grid');
      grid.setColEllipsis (['RMK'], true);
      //grid Column Head Merge
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
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
        // cell 1개만 클릭 시 사용 아니면 삭제
        if(selRow == undefined) selRow = rowid;

        if(celname == "ITEM_CD") {
          var param = {
            'gate_cd': '${ses.gateCd}',
            'ITEM_CD': value
          };

          everPopup.openPopupByScreenId('BBM_040', 1200, 600, param);
        }

        if (celname == "RMK") {
        	setRowId = rowid;
    	    var param = {
    				  havePermission : true
    				, callBackFunction : 'setTextContents2'
    				, TEXT_CONTENTS : grid.getCellValue(rowid, "RMK")
    				, detailView : false
    			};
  	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
        }

        if (celname == "MOLD_MID01_IMG") {
        	if (grid.getCellValue(rowid,'MOLD_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}


        	if (Number(grid.getCellValue(rowid,'MOLD_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'MOLD_PRE_AMT') )
        		   +Number(grid.getCellValue(rowid,'MOLD_MID01_AMT'))
        		   +Number(grid.getCellValue(rowid,'MOLD_MID02_AMT') )
        		   +Number(grid.getCellValue(rowid,'MOLD_BAL_AMT') )
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}



        	if (grid.getCellValue(rowid,'MOLD_MID01_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'MOLD_MID01_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'MOLD_MID01_IMG');

        }
        if (celname == "MOLD_MID02_IMG") {
        	if (grid.getCellValue(rowid,'MOLD_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}
        	if (Number(grid.getCellValue(rowid,'MOLD_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'MOLD_PRE_AMT'))
        		   +Number(grid.getCellValue(rowid,'MOLD_MID01_AMT') )
        		   +Number(grid.getCellValue(rowid,'MOLD_MID02_AMT') )
        		   +Number(grid.getCellValue(rowid,'MOLD_BAL_AMT') )
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}
        	if (grid.getCellValue(rowid,'MOLD_MID01_SIGN_STATUS') != 'E' && Number(grid.getCellValue(rowid,'MOLD_NEGO_AMT')) > 30000000  ) {
        		alert('${DH1510_0003}');
        		return;
        	}
        	if (grid.getCellValue(rowid,'MOLD_MID02_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'MOLD_MID02_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'MOLD_MID02_IMG');

        }
        if (celname == "MOLD_BAL_IMG") {
        	if (grid.getCellValue(rowid,'MOLD_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}
        	if (Number(grid.getCellValue(rowid,'MOLD_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'MOLD_PRE_AMT'))
        		   +Number(grid.getCellValue(rowid,'MOLD_MID01_AMT'))
        		   +Number(grid.getCellValue(rowid,'MOLD_MID02_AMT'))
        		   +Number(grid.getCellValue(rowid,'MOLD_BAL_AMT'))
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}
        	if (grid.getCellValue(rowid,'MOLD_MID02_SIGN_STATUS') != 'E' && Number(grid.getCellValue(rowid,'MOLD_NEGO_AMT')) > 30000000  ) {
        		alert('${DH1510_0003}');
        		return;
        	}

        	if (grid.getCellValue(rowid,'MOLD_BAL_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'MOLD_BAL_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'MOLD_BAL_IMG');
        }





        if (celname == "JIG_MID_IMG") {
        	if (grid.getCellValue(rowid,'JIG_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}
        	if (Number(grid.getCellValue(rowid,'JIG_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'JIG_PRE_AMT'))
        		   +Number(grid.getCellValue(rowid,'JIG_MID_AMT'))
        		   +Number(grid.getCellValue(rowid,'JIG_BAL_AMT'))
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}

        	if (grid.getCellValue(rowid,'JIG_MID_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'JIG_MID_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'JIG_MID_IMG');

        }
        if (celname == "JIG_BAL_IMG") {
        	if (grid.getCellValue(rowid,'JIG_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}
        	if (Number(grid.getCellValue(rowid,'JIG_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'JIG_PRE_AMT'))
        		   +Number(grid.getCellValue(rowid,'JIG_MID_AMT'))
        		   +Number(grid.getCellValue(rowid,'JIG_BAL_AMT'))
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}
        	if (grid.getCellValue(rowid,'JIG_MID_SIGN_STATUS') != 'E' && Number(grid.getCellValue(rowid,'JIG_NEGO_AMT')) > 30000000  ) {
        		alert('${DH1510_0003}');
        		return;
        	}


        	if (grid.getCellValue(rowid,'JIG_BAL_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'JIG_BAL_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'JIG_BAL_IMG');

        }





        if (celname == "INSP_MID_IMG") {
        	if (grid.getCellValue(rowid,'INSP_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}

        	if (Number(grid.getCellValue(rowid,'INSP_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'INSP_PRE_AMT'))
        		   +Number(grid.getCellValue(rowid,'INSP_MID_AMT'))
        		   +Number(grid.getCellValue(rowid,'INSP_BAL_AMT'))
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}
        	if (grid.getCellValue(rowid,'INSP_MID_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'INSP_MID_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'INSP_MID_IMG');

        }
        if (celname == "INSP_BAL_IMG") {
        	if (grid.getCellValue(rowid,'INSP_NEGO_AMT') == 0 ) {
        		alert('${DH1510_0004}');
        		return;
        	}
        	if (Number(grid.getCellValue(rowid,'INSP_NEGO_AMT')) != (
        			Number(grid.getCellValue(rowid,'INSP_PRE_AMT'))
        		   +Number(grid.getCellValue(rowid,'INSP_MID_AMT'))
        		   +Number(grid.getCellValue(rowid,'INSP_BAL_AMT'))
        	   )) {
        		alert('${DH1510_0005}');
        		return;
        	}

        	if (grid.getCellValue(rowid,'INSP_MID_SIGN_STATUS') != 'E' && Number(grid.getCellValue(rowid,'INSP_NEGO_AMT')) > 30000000  ) {
        		alert('${DH1510_0003}');
        		return;
        	}
        	if (grid.getCellValue(rowid,'INSP_BAL_SIGN_STATUS') == 'P'  ||  grid.getCellValue(rowid,'INSP_BAL_SIGN_STATUS') == 'E') {
        		alert('${DH1510_0002}');
        		return;
        	}
        	grid.checkAll(false);
        	grid.checkRow(rowid, true);
        	execVnEtc(rowid , 'INSP_BAL_IMG');
        }



      });

		if(${_gridType eq "RG"}) {
			grid.setColGroup([{
				"groupName": '${formx_A_N}',
				"columns": [ "PROC01_NM", "PROC01_AMT", "PROC02_NM", "PROC02_AMT", "PROC03_NM", "PROC03_AMT", "PROC04_NM", "PROC04_AMT", "PROC05_NM", "PROC05_AMT", "PROC06_NM", "PROC06_AMT", "PROC07_NM", "PROC07_AMT", "PROC08_NM", "PROC08_AMT", "PROC09_NM", "PROC09_AMT", "PROC10_NM", "PROC10_AMT", "PROC11_NM", "PROC11_AMT", "PROC12_NM", "PROC12_AMT", "PROC13_NM", "PROC13_AMT", "PROC14_NM", "PROC14_AMT", "PROC15_NM", "PROC15_AMT" ]
			}, {
				"groupName": '${formx_B_N}',
				"columns": [ "WIDTH", "PITCH", "THICK", "QT", "MAT_CD", "DESIGN_WEIGHT", "WGT" ]
			}, {
				"groupName": '${formx_C_N}',
				"columns": [ "MOLD", "JIG", "INSP_CHAMBER" ]
			}, {
				"groupName": '${formx_D_N}',
				"columns": [ "MOLD_NEGO_AMT", "MOLD_PRE_AMT", "MOLD_MID01_AMT", "MOLD_MID01_IMG", "MOLD_MID01_DOC_NUM", "MOLD_MID01_DOC_CNT", "MOLD_MID01_SIGN_STATUS", "MOLD_MID01_SIGN_DATE", "MOLD_MID02_AMT", "MOLD_MID02_IMG", "MOLD_MID02_DOC_NUM", "MOLD_MID02_DOC_CNT", "MOLD_MID02_SIGN_STATUS", "MOLD_MID02_SIGN_DATE", "MOLD_BAL_AMT", "MOLD_BAL_IMG", "MOLD_BAL_DOC_NUM", "MOLD_BAL_DOC_CNT", "MOLD_BAL_SIGN_STATUS", "MOLD_BAL_SIGN_DATE" ]
			}, {
				"groupName": '${formx_E_N}',
				"columns": [ "JIG_NEGO_AMT", "JIG_PRE_AMT", "JIG_MID_AMT", "JIG_MID_IMG", "JIG_MID_DOC_NUM", "JIG_MID_DOC_CNT", "JIG_MID_SIGN_STATUS", "JIG_MID_SIGN_DATE", "JIG_BAL_AMT", "JIG_BAL_IMG", "JIG_BAL_DOC_NUM", "JIG_BAL_DOC_CNT", "JIG_BAL_SIGN_STATUS", "JIG_BAL_SIGN_DATE" ]
			}, {
				"groupName": '${formx_F_N}',
				"columns": [ "INSP_NEGO_AMT", "INSP_PRE_AMT", "INSP_MID_AMT", "INSP_MID_IMG", "INSP_MID_DOC_NUM", "INSP_MID_DOC_CNT", "INSP_MID_SIGN_STATUS", "INSP_MID_SIGN_DATE", "INSP_BAL_AMT", "INSP_BAL_IMG", "INSP_BAL_DOC_NUM", "INSP_BAL_DOC_CNT", "INSP_BAL_SIGN_STATUS", "INSP_BAL_SIGN_DATE" ]
			}, {
				"groupName": '${formx_G_N}',
				"columns": [ "IDENT_SQ", "CEO_NM", "ADDR", "TEL_NUM", "VENDOR_SIGN_STATUS" ]
			}]);
		} else {
			grid.setGroupCol(
					[
						{'colName' : 'PROC01_NM', 'colIndex' : 30, 'titleText' : '${formx_A_N}'}
						,{'colName' : 'WIDTH', 'colIndex' : 7, 'titleText' : '${formx_B_N}'}
						,{'colName' : 'MOLD', 'colIndex' : 3, 'titleText' : '${formx_C_N}'}
						,{'colName' : 'MOLD_NEGO_AMT', 'colIndex' : 20, 'titleText' : '${formx_D_N}'}
						,{'colName' : 'JIG_NEGO_AMT', 'colIndex' : 14, 'titleText' : '${formx_E_N}'}
						,{'colName' : 'INSP_NEGO_AMT', 'colIndex' : 14, 'titleText' : '${formx_F_N}'}
						,{'colName' : 'IDENT_SQ', 'colIndex' : 5, 'titleText' : '${formx_G_N}'}
					]
			);
		}


      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
    	  if (celname=='PROC01_AMT' ||celname=='PROC02_AMT' ||celname=='PROC03_AMT' ||celname=='PROC04_AMT' ||celname=='PROC05_AMT'
   			  ||celname=='PROC06_AMT' ||celname=='PROC07_AMT' ||celname=='PROC08_AMT' ||celname=='PROC09_AMT' ||celname=='PROC10_AMT'
   			  ||celname=='PROC11_AMT' ||celname=='PROC12_AMT' ||celname=='PROC13_AMT' ||celname=='PROC14_AMT' ||celname=='PROC15_AMT'
    	  ) {
    		  var proc01_amt = Number(grid.getCellValue(rowid,'PROC01_AMT'));
    		  var proc02_amt = Number(grid.getCellValue(rowid,'PROC02_AMT'));
    		  var proc03_amt = Number(grid.getCellValue(rowid,'PROC03_AMT'));
    		  var proc04_amt = Number(grid.getCellValue(rowid,'PROC04_AMT'));
    		  var proc05_amt = Number(grid.getCellValue(rowid,'PROC05_AMT'));
    		  var proc06_amt = Number(grid.getCellValue(rowid,'PROC06_AMT'));
    		  var proc07_amt = Number(grid.getCellValue(rowid,'PROC07_AMT'));
    		  var proc08_amt = Number(grid.getCellValue(rowid,'PROC08_AMT'));
    		  var proc09_amt = Number(grid.getCellValue(rowid,'PROC09_AMT'));
    		  var proc10_amt = Number(grid.getCellValue(rowid,'PROC10_AMT'));
    		  var proc11_amt = Number(grid.getCellValue(rowid,'PROC11_AMT'));
    		  var proc12_amt = Number(grid.getCellValue(rowid,'PROC12_AMT'));
    		  var proc13_amt = Number(grid.getCellValue(rowid,'PROC13_AMT'));
    		  var proc14_amt = Number(grid.getCellValue(rowid,'PROC14_AMT'));
    		  var proc15_amt = Number(grid.getCellValue(rowid,'PROC15_AMT'));

    		  var procTotal = proc01_amt+proc02_amt+proc03_amt+proc04_amt+proc05_amt+proc06_amt+proc07_amt+proc08_amt+proc09_amt+proc10_amt+proc11_amt+proc12_amt+proc13_amt+proc14_amt+proc15_amt;
    		  grid.setCellValue(rowid,'MOLD_NEGO_AMT', procTotal);


    		  var a = Math.round(procTotal * 30 / 100);
    		  var b = Math.round(procTotal * 30 / 100);
    		  var c = Math.round(procTotal * 20 / 100);


    		  grid.setCellValue(rowid,'MOLD_PRE_AMT', a);
    		  grid.setCellValue(rowid,'MOLD_MID01_AMT', b);
    		  grid.setCellValue(rowid,'MOLD_MID02_AMT', c);
    		  grid.setCellValue(rowid,'MOLD_BAL_AMT', procTotal - (       a + b + c          )  );
    		  countExec(rowid);
    	  }
    	  if (celname=='JIG_NEGO_AMT') {
    		  var jig_nego_amt = grid.getCellValue(rowid,'JIG_NEGO_AMT');
    		  var a = Math.round(jig_nego_amt * 30 / 100);
    		  var b = Math.round(jig_nego_amt * 30 / 100);
    		  grid.setCellValue(rowid,'JIG_PRE_AMT', a);
    		  grid.setCellValue(rowid,'JIG_MID_AMT', b);
    		  grid.setCellValue(rowid,'JIG_BAL_AMT', jig_nego_amt - (a + b) );



    	  }
    	  if (celname=='INSP_NEGO_AMT') {
    		  var insp_nego_amt = grid.getCellValue(rowid,'INSP_NEGO_AMT');
    		  var a = Math.round(insp_nego_amt * 30 / 100);
    		  var b = Math.round(insp_nego_amt * 30 / 100);

    		  grid.setCellValue(rowid,'INSP_PRE_AMT', insp_nego_amt * 30 / 100);
    		  grid.setCellValue(rowid,'INSP_MID_AMT', insp_nego_amt * 30 / 100);
    		  grid.setCellValue(rowid,'INSP_BAL_AMT', insp_nego_amt - (a + b));
    	  }

    	  if (celname=='WIDTH' || celname=='PITCH') {
    		  var width = grid.getCellValue(rowid,'WIDTH');
    		  var pitch = grid.getCellValue(rowid,'PITCH');
    		  grid.setCellValue(rowid,'DESIGN_WEIGHT', width * pitch);
    	  }

    	  if (celname=='MOLD_MID01_AMT') {
    		  var chi = oldValue - value;
    		  grid.setCellValue(rowid,'MOLD_MID02_AMT',  grid.getCellValue(rowid,'MOLD_MID02_AMT') +  chi );
    	  }

      });
    }

    function execVnEtc(rowid , colunum) {
    	var store = new EVF.Store();
        var selectedRow = grid.getSelRowValue();
      	if (grid.getCellValue(rowid, 'VENDOR_CD')  == '') {
  			  alert('${DH1510_0001}');
      		  return;
        }

      	store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.setParameter('SIGN_STATUS','P');
        store.setParameter('TYPE','REP');
		store.setParameter('TYPE2', colunum);

		var tempDocName = colunum.substring(0, colunum.indexOf('_IMG')  );

		store.setParameter('APP_DOC_NUM', grid.getCellValue(rowid,tempDocName+'_DOC_NUM')); // 금형,지그,검사구의 각 보고서별 결재문서번호
		store.setParameter('OLD_CNT',  grid.getCellValue(rowid,tempDocName+'_DOC_CNT')  ); // 금형,지그,검사구의 각 보고서별 결재상태

        if (!confirm("${msg.M0100}")) return;

        store.load(baseUrl + '/doSave', function() {

    		var legacyKey = this.getParameter('legacy_key');
    		if (legacyKey == 'ERROR') {
        		alert(this.getResponseMessage());

              	doSearch();
        		return;
    		}

			var url;
			var gwUserId;
			if ('${devFlag}' == 'true') {
				gwUserId = 'hspark03';
			} else {
				gwUserId = '${ses.userId}';
			}
			if (legacyKey != '') {
    			url = "${gwUrl}"+gwUserId+"${gwParam}"+legacyKey;
    			window.open(url, "signwindow", gwParam);
			}

          	//doSearch();
        });
    }

    function countExec(rowid) {
		  var proc01_amt = Number(grid.getCellValue(rowid,'PROC01_AMT'));
		  var proc02_amt = Number(grid.getCellValue(rowid,'PROC02_AMT'));
		  var proc03_amt = Number(grid.getCellValue(rowid,'PROC03_AMT'));
		  var proc04_amt = Number(grid.getCellValue(rowid,'PROC04_AMT'));
		  var proc05_amt = Number(grid.getCellValue(rowid,'PROC05_AMT'));
		  var proc06_amt = Number(grid.getCellValue(rowid,'PROC06_AMT'));
		  var proc07_amt = Number(grid.getCellValue(rowid,'PROC07_AMT'));
		  var proc08_amt = Number(grid.getCellValue(rowid,'PROC08_AMT'));
		  var proc09_amt = Number(grid.getCellValue(rowid,'PROC09_AMT'));
		  var proc10_amt = Number(grid.getCellValue(rowid,'PROC10_AMT'));
		  var proc11_amt = Number(grid.getCellValue(rowid,'PROC11_AMT'));
		  var proc12_amt = Number(grid.getCellValue(rowid,'PROC12_AMT'));
		  var proc13_amt = Number(grid.getCellValue(rowid,'PROC13_AMT'));
		  var proc14_amt = Number(grid.getCellValue(rowid,'PROC14_AMT'));
		  var proc15_amt = Number(grid.getCellValue(rowid,'PROC15_AMT'));

		  var count=0;
		  if (proc01_amt!=0) { count++}
		  if (proc02_amt!=0) { count++}
		  if (proc03_amt!=0) { count++}
		  if (proc04_amt!=0) { count++}
		  if (proc05_amt!=0) { count++}
		  if (proc06_amt!=0) { count++}
		  if (proc07_amt!=0) { count++}
		  if (proc08_amt!=0) { count++}
		  if (proc09_amt!=0) { count++}
		  if (proc10_amt!=0) { count++}
		  if (proc11_amt!=0) { count++}
		  if (proc12_amt!=0) { count++}
		  if (proc13_amt!=0) { count++}
		  if (proc14_amt!=0) { count++}
		  if (proc15_amt!=0) { count++}


		  grid.setCellValue(rowid,'MOLD',count);
    }


	function setTextContents2(tests) {
		grid.setCellValue(setRowId, "RMK",tests);
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

      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      // Grid Validation Check
      if(!grid.validate().flag) { return alert("${msg.M0014}"); }

      var selectedRow = grid.getSelRowValue();
      for(var k=0;k<selectedRow.length;k++) {
    	  if (selectedRow[k].VENDOR_CD == '') {
			  alert('${DH1510_0001}');
    		  return;
    	  }
      }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');

      store.setParameter('SIGN_STATUS','T');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    var userwidth  = 810; // 고정(수정하지 말것)
	var userheight = (screen.height - 2);
	if (userheight < 780) userheight = 780; // 최소 780
	var LeftPosition = (screen.width-userwidth)/2;
	var TopPosition  = (screen.height-userheight)/2;
	var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

	// 2차 공급자 현황보고
    function doExec2() {
        var store = new EVF.Store();

        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        // Grid Validation Check
        if(!grid.validate().flag) { return alert("${msg.M0014}"); }

        var selectedRow = grid.getSelRowValue();
        for(var k=0;k<selectedRow.length;k++) {
      	  if (selectedRow[k].VENDOR_CD == '') {
  			  alert('${DH1510_0001}');
      		  return;
      	  }
        }
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.setParameter('SIGN_STATUS','P');
        store.setParameter('TYPE','VN2');

        // 2차 공급자 현황보고는 무조건 결재번호를 새로 채번한다.
		store.setParameter('APP_DOC_NUM', "");
		store.setParameter('OLD_CNT',  "");

        if (!confirm("${msg.M0100}")) return;

        store.load(baseUrl + '/doSave', function() {

    		var legacyKey = this.getParameter('legacy_key');
    		if (legacyKey == 'ERROR') {
        		alert(this.getResponseMessage());

              	doSearch();
        		return;
    		}

			var url;
			var gwUserId;
			if ('${devFlag}' == 'true') {
				gwUserId = 'hspark03';
			} else {
				gwUserId = '${ses.userId}';
			}
			if (legacyKey != '') {
    			url = "${gwUrl}"+gwUserId+"${gwParam}"+legacyKey;
    			window.open(url, "signwindow", gwParam);
			}

          	//doSearch();
        });
    }

    function searchITEM_CD() {
      var param = {
        'callBackFunction': 'selectItemCd',
        'detailView': false
      };

      everPopup.openPopupByScreenId('DH0521', 1000, 550, param);
    }

    function selectItemCd(data) {
      EVF.getComponent("ITEM_CD").setValue(data.ITEM_CD);
      EVF.getComponent("ITEM_NM").setValue(data.ITEM_DESC);
    }

    function doEBOMSearch() {
      var param = {
        'ITEM_CD': EVF.getComponent('ITEM_CD').getValue(),
        'ITEM_NM': EVF.getComponent('ITEM_NM').getValue(),
        'detailView': false
      };

      everPopup.openPopupByScreenId('DH0522', 1000, 550, param);
    }

    function onClickItemCd() {
      EVF.getComponent("ITEM_NM").setValue("");
    }



    function doSearchVendor() {
      	everPopup.openCommonPopup({
              callBackFunction: "selectVendor"
          }, 'SP0013');
    }
    function selectVendor(data) {
          EVF.getComponent("VENDOR_NM").setValue(data['VENDOR_NM']);
          EVF.getComponent("VENDOR_CD").setValue(data['VENDOR_CD']);
      }


  </script>

  <e:window id="DH1510" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
        <%--품번--%>
        <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
        <e:field>
          <e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="40%" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onClick="onClickItemCd"/>
          <e:text>&nbsp;</e:text>
          <e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="55%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
        </e:field>


        <e:label for="DIV" title="${form_DIV_N}"/>
        <e:field>
        <e:radioGroup id="radio" name="radio" disabled="" readOnly="" required="">
          <e:text>&nbsp;&nbsp;</e:text>
          <e:radio id="FRONT" name="FRONT" label="${form_FRONT_N}" value="F" checked="true"/>
          <e:text>&nbsp;&nbsp;</e:text>
          <e:radio id="BACK" name="BACK" label="${form_BACK_N}" value="B"/>
        </e:radioGroup>
        </e:field>


		<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
		<e:field>
			<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
          	<e:text>&nbsp;</e:text>
			<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="55%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
		</e:field>



      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
		<e:button id="doExec2" name="doExec2" label="${doExec2_N}" onClick="doExec2" disabled="${doExec2_D}" visible="${doExec2_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>