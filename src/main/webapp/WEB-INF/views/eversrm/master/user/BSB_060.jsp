<!--
* BSB_060 : 사용자정보
* 시스템관리 > 사용자관리 > 사용자정보
-->

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

<script>
    var baseUrl = "/eversrm/master/user/";
    var grid    = {};
    var auGrid  = {};
    var acGrid  = {};
    var cRow;
    var currentUserId = '';
    var tagObj = {};
    var selRow;

    function init() {

    	grid   = EVF.C('sGrid');
		acGrid = EVF.C('acGrid');
		auGrid = EVF.C('auGrid');

		grid.setProperty('panelVisible', ${panelVisible});
		acGrid.setProperty('panelVisible', ${panelVisible});
		auGrid.setProperty('panelVisible', ${panelVisible});

		acGrid.setProperty('shrinkToFit', true);
		auGrid.setProperty('shrinkToFit', true);
        auGrid.setProperty('singleSelect', true);
		grid.setProperty('multiselect', false);

		grid.cellClickEvent(function(rowid, colId, value) {
			if( colId == 'USER_ID_V') { onCellClickS("USER_ID", rowid); }
		});

		auGrid.cellClickEvent(function(rowid, colId, value) {

			if(selRow == undefined) selRow = rowid;

            if (colId == 'SELECTED') {
                if(selRow != rowid) {
                    auGrid.setCellValue(selRow, "SELECTED", "0");
                    auGrid.checkRow(selRow, false);
                    selRow = rowid;
                }
            }
        });

        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        acGrid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        auGrid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        grid._gvo.setColumnProperty('USER_NM_DISPLAY', 'renderer', {type:"shape", showTooltip: true});
        grid._gvo.setColumnProperty('USER_NM_DISPLAY', 'dynamicStyles', [{
            criteria: "(value['LOGIN_STATUS'] = 'Y')",
            styles: {figureBackground: "#ff00aa00", figureName: 'ellipse', iconLocation: 'left', figureSize: "60%", paddingRight: 6}
        },
			{criteria: "(value['LOGIN_STATUS'] = 'N')",
			styles: {figureBackground: "#ffeeeeee", figureName: 'ellipse', iconLocation: 'left', figureSize: "60%", paddingRight: 6}
		}]);

		setCommonForm();
        searchProfile();
        UserTypeSearchChange();
    }

    function doSearch() {

        EVF.C('USER_TYPE_SEARCH').setRequired(true);

		var store = new EVF.Store();
		if(EVF.V("USER_TYPE_SEARCH")==""){
            alert("${BSB_060_0002}");
            EVF.C('USER_TYPE_SEARCH').setFocus();
            return;
		}
        store.setParameter("userType", "${ses.userType}");
        store.setGrid([grid]);
		store.load(baseUrl + 'userInformation/doSearchUser', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
            	var gridData = grid.getAllRowValue();
                for (var x in gridData) {
                	var rowData = gridData[x];

                    if (rowData['USER_ID'] === currentUserId) {
                        onCellClickS("USER_ID", x);
                        return;
                    }
                }
                onCellClickS("USER_ID", 0);
            }

            grid.resize();
        });
    }

    function clearForm() {
        document.location.reload();
        setCommonForm();
        EVF.C('INSERT_FLAG').setValue("I");
    }

    function setCommonForm() {

        if ("${ses.userType}" == 'S') {
            EVF.C('USER_TYPE_SEARCH').setValue("S");
            EVF.C('USER_TYPE_SEARCH').setDisabled(true);
            EVF.C('COMPANY_CD_SEARCH').setValue("${ses.companyCd}");
            EVF.C('COMPANY_CD_SEARCH').setDisabled(true);
            EVF.C('COMPANY_NM_SEARCH').setValue("${ses.companyNm}");
            EVF.C('COMPANY_NM_SEARCH').setDisabled(true);
            EVF.C('DEPT_NM_SEARCH').setDisabled(true);
            EVF.C('USER_TYPE').setValue("S");
            EVF.C('USER_TYPE').setDisabled(true);
            EVF.C('COMPANY_CD').setValue("${ses.companyCd}");
            EVF.C('COMPANY_CD').setDisabled(true);
            EVF.C('COMPANY_NM').setValue("${ses.companyNm}");
            EVF.C('COMPANY_NM').setDisabled(true);
            EVF.C('PLANT_NM').setDisabled(true);
            EVF.C('DEPT_NM').setDisabled(true);
        }

        EVF.C('GATE_CD').setValue("${ses.gateCd}");

    }

    function onCellClickS(strkey, nRow) {

        EVF.C('USER_TYPE_SEARCH').setRequired(false);
        EVF.V("CHANGE_PW", "");
        setRequired(false);

        if (strkey == "USER_ID") {
            EVF.C('USER_ID').setValue( grid.getCellValue(nRow, strkey) );
            EVF.C('GRID_USER_TYPE').setValue(grid.getCellValue(nRow, "USER_TYPE"));

			var store = new EVF.Store();
	        store.setParameter("userType", "${ses.userType}");
	        store.setParameter("gridData", encodeURIComponent(JSON.stringify(grid.getRowValue(nRow))) );
			store.load(baseUrl + 'userInformation/doGetUser', function() {
				var data = this.data.formData;
				for( var id in data ) {
					if(    id == 'PW_WRONG_CNT'
						|| id == 'MOD_USER_ID'
						|| id == 'MOD_USER_NM'
						|| id == 'PW_RESET_FLAG'
						|| id == 'LAST_LOGIN_TIME'
						|| id == 'PW_RESET_DATE'
						|| id == 'MOD_DATE_LAST'
						|| id == 'DEL_FLAG'
						|| id == 'IP_ADDR'
						|| id == 'LAST_LOGIN_DATE'
					) { continue; }

					EVF.C(id).setValue( data[id] );
				}

				setCommonForm();
                if ("${ses.userType}" == 'S') {
                    EVF.C('COMPANY_CD_SEARCH').setValue("${ses.companyCd}");
                    EVF.C('COMPANY_NM_SEARCH').setValue("${ses.companyNm}");
                    EVF.C('USER_TYPE_SEARCH').setValue("S");
                }

                currentUserId = EVF.C("USER_ID").getValue();
                searchProfile();

                EVF.V("INSERT_FLAG", "U");
                EVF.C('USER_TYPE').setReadOnly(true);
                EVF.C('USER_ID').setReadOnly(true);

                // 2022.12.22 추가
                // I/F 고객사의 사용자인 경우 조직정보 변경 안됨
                if(EVF.V("IF_USER_FLAG") == '1') {
                	EVF.C("COMPANY_CD").setDisabled(true);
                	EVF.C("PLANT_CD").setDisabled(true);
                	EVF.C("DIVISION_CD").setDisabled(true);
                	EVF.C("DEPT_CD").setDisabled(true);
                	EVF.C("PART_CD").setDisabled(true);
                	EVF.C("USER_NM").setReadOnly(true);
                	EVF.C("USER_NM_ENG").setReadOnly(true);
                } else {
                	EVF.C("COMPANY_CD").setDisabled(false);
                	EVF.C("PLANT_CD").setDisabled(false);
                	EVF.C("DIVISION_CD").setDisabled(false);
                	EVF.C("DEPT_CD").setDisabled(false);
                	EVF.C("PART_CD").setDisabled(false);
                	EVF.C("USER_NM").setReadOnly(false);
                	EVF.C("USER_NM_ENG").setReadOnly(false);
                }

                if( EVF.V("USER_TYPE") == "C" ){
                	if( EVF.V("IF_USER_FLAG") == '1' ) {
                        EVF.C("deleteUser").setDisabled(true);
                	} else {
                		EVF.C("deleteUser").setDisabled(false);
                	}
				} else {
                    EVF.C("deleteUser").setDisabled(true);
				}
			});
        }
    }

    function searchProfile() {
    	var storeR = new EVF.Store();
        storeR.setParameter("userType", "${ses.userType}");
        storeR.setGrid([auGrid, acGrid]);
		storeR.load(baseUrl + 'userInformation/doGetProfile', function() {
			var auGridData = auGrid.getAllRowValue()
				, acGridData = acGrid.getAllRowValue();

			setRequired(true);
			for( var idx in auGridData ) {
				for( var col in auGridData[idx] ) {
					if( col == 'SELECTED' && auGridData[idx][col] == 1 ) {
						auGrid.checkRow( idx, true );
					}
				}
			}

			for( var idx in acGridData ) {
				for( var col in acGridData[idx] ) {
					if( col == 'SELECTED' && acGridData[idx][col] == 1 ) {
						acGrid.checkRow( idx, true );
					}
				}
			}
		});
    }

    function setRequired(valr) {
    	var tagIds = ['USER_ID',
			'USER_TYPE',
			'USER_NM',
			'PASSWORD',
			'PASSWORD_CHECK',
			'COMPANY_CD',
			'COMPANY_NM',
			'USE_FLAG',
			'PROGRESS_CD' ];

		for( var i in tagIds ) { EVF.C(tagIds[i]).setRequired(valr); }
    }

    function companySearch_S() {

    	if ("${ses.userType}" == 'S') { return; }

        if (EVF.V('USER_TYPE_SEARCH') == '') {
            alert("${BSB_060_0002}");
            EVF.C('USER_TYPE_SEARCH').setFocus();
            return;
        }

        if (EVF.V('USER_TYPE_SEARCH') == 'C') {
            var param = {
                callBackFunction: "selectCompany_S"
            };
            everPopup.openCommonPopup(param, 'SP0004');
        } else if (EVF.V('USER_TYPE_SEARCH') == 'S') {
            var param = {
                callBackFunction: "selectCompany_V"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        } else if (EVF.V('USER_TYPE_SEARCH') == 'B') {
            var param = {
                callBackFunction: "selectCompany_B"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }
    }

    function selectCompany_V(dataJsonArray) {
        EVF.C('COMPANY_CD_SEARCH').setValue(dataJsonArray.VENDOR_CD);
        EVF.C('COMPANY_NM_SEARCH').setValue(dataJsonArray.VENDOR_NM);
    }
    function selectCompany_B(dataJsonArray) {
        EVF.C('COMPANY_CD_SEARCH').setValue(dataJsonArray.CUST_CD);
        EVF.C('COMPANY_NM_SEARCH').setValue(dataJsonArray.CUST_NM);
    }

    function selectCompany_S(dataJsonArray) {
        EVF.C('COMPANY_CD_SEARCH').setValue(dataJsonArray.BUYER_CD);
        EVF.C('COMPANY_NM_SEARCH').setValue(dataJsonArray.BUYER_NM);
    }

    function companySearch_I() {
    	if ("${ses.userType}" == 'S') {
    		return;
    	}

    	if (EVF.V('USER_TYPE') == '') {
            alert("${form_USER_TYPE_N } - ${msg.M0004}.");
            return;
        }

        if (EVF.V('USER_TYPE') == 'S') {
            if ("${ses.userType}" == 'S') {
                alert("${BSB_060_0003}");
            } else {
                var param = {
                    callBackFunction: "selectVendor_I"
                };
                everPopup.openCommonPopup(param, 'SP0063');
            }
        } else if (EVF.V('USER_TYPE') == 'B') {
            var param = {
                callBackFunction : "selectCust_I"
            };
            everPopup.openCommonPopup(param, 'SP0067');
		} else {
            var param = {
                callBackFunction: "selectCompany_I"
            };
            everPopup.openCommonPopup(param, 'SP0004');
        }
    }

    function selectCompany_I(dataJsonArray) {
        EVF.C('COMPANY_CD').setValue(dataJsonArray.BUYER_CD);
        EVF.C('COMPANY_NM').setValue(dataJsonArray.BUYER_NM);
    }

    function selectVendor_I(dataJsonArray) {
        EVF.C('COMPANY_CD').setValue(dataJsonArray.VENDOR_CD);
        EVF.C('COMPANY_NM').setValue(dataJsonArray.VENDOR_NM);
    }

    function selectCust_I(dataJsonArray) {
        EVF.C('COMPANY_CD').setValue(dataJsonArray.CUST_CD);
        EVF.C('COMPANY_NM').setValue(dataJsonArray.CUST_NM);
    }

    function plantSearch_I() {

    	if ("${ses.userType}" == 'S') {return;}

        if (EVF.V("USER_TYPE") == "") {
            alert("${form_USER_TYPE_N } - ${msg.M0004}.");
            return;
        }

        if (EVF.V("COMPANY_CD") == "") {
            alert("${form_COMPANY_NM_N } - ${msg.M0004}.");
            return;
        }

        if ("${ses.userType}" != 'S' && EVF.V('USER_TYPE') != 'S') {
            var param = {
                callBackFunction: "selectPlant",
                custCd: EVF.V("COMPANY_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        } else {
            alert("${BSB_060_0001}");
        }
    }

    function selectPlant(dataJsonArray) {
		EVF.C('PLANT_CD').setValue(dataJsonArray.PLANT_CD);
		EVF.C('PLANT_NM').setValue(dataJsonArray.PLANT_NM);
		EVF.C('DIVISION_CD').setValue("");
		EVF.C('DIVISION_NM').setValue("");
		EVF.C('DEPT_CD').setValue("");
		EVF.C('DEPT_NM').setValue("");
		EVF.C('PART_CD').setValue("");
		EVF.C('PART_NM').setValue("");
    }

    function doSearchDivision() {

    	if ("${ses.userType}" == 'S') { return; }

        if (EVF.V("USER_TYPE") == "") {
            alert("${BSB_060_0002}");
            return;
        }

        if (EVF.V("COMPANY_CD") == "") {
            EVF.C('COMPANY_CD').setFocus();
            alert("${BSB_060_0005}");
            return;
        }

        if (EVF.V("PLANT_CD") == "") {
            EVF.C('PLANT_CD').setFocus();
            alert("${BSB_060_0006}");
            return;
        }

    	var param = {
                callBackFunction: "setDivision",
                custCd : EVF.V("COMPANY_CD"),
               	plantCd: EVF.V("PLANT_CD")
            };
        everPopup.openCommonPopup(param, "SP0020");
    }

    function setDivision(data) {
        EVF.C("DIVISION_CD").setValue(data.DIVISION_CD);
        EVF.C("DIVISION_NM").setValue(data.DIVISION_NM);
		EVF.C('DEPT_CD').setValue("");
		EVF.C('DEPT_NM').setValue("");
		EVF.C('PART_CD').setValue("");
		EVF.C('PART_NM').setValue("");
    }

    function doSearchDept() {
    	var param = {
                callBackFunction: "setDept",
                custCd : EVF.V("COMPANY_CD"),
               	plantCd: EVF.V("PLANT_CD"),
               	divisionCd: EVF.V("DIVISION_CD")
            };
        everPopup.openCommonPopup(param, "SP0071");
    }

    function setDept(data) {
        EVF.C("DEPT_CD").setValue(data.DEPT_CD);
        EVF.C("DEPT_NM").setValue(data.DEPT_NM);
		EVF.C('PART_CD').setValue("");
		EVF.C('PART_NM').setValue("");
    }

    function doSearchPart() {
    	var param = {
                callBackFunction: "setPart",
                custCd : EVF.V("COMPANY_CD"),
                plantCd: EVF.V("PLANT_CD"),
               	divisionCd: EVF.V("DIVISION_CD"),
               	deptCd: EVF.V("DEPT_CD")
            };
        everPopup.openCommonPopup(param, "SP0084");
    }

    function setPart(data) {
        EVF.C("PART_CD").setValue(data.PART_CD);
        EVF.C("PART_NM").setValue(data.PART_NM);
    }

    function getDeptCd() {

        if(EVF.V("COMPANY_CD_SEARCH")==""){
            EVF.C("COMPANY_CD_SEARCH").setFocus();
            return alert("${BSB_060_0005}");
		}

        var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
        var param = {
            callBackFunction: "setDeptCd_s",
            'AllSelectYN': true,
            'detailView': false,
            'multiYN': false,
            'ModalPopup': true,
            'custCd' : EVF.V("COMPANY_CD_SEARCH"),
            'custNm' :  EVF.V("COMPANY_NM_SEARCH")
        };
        everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
    }

    function setDeptCd_s(data) {
        data = JSON.parse(data);
        EVF.V('S_DEPT_CD', data.DEPT_CD);
        EVF.V('S_DEPT_NM', data.DEPT_NM);
    }

    function deptCdSearch_I() {
    	if ("${ses.userType}" == 'S') { return; }

        if (EVF.V("USER_TYPE") == "") {
            alert("${BSB_060_0002}");
            return;
        }

        if (EVF.V("COMPANY_CD") == "") {
            EVF.C('COMPANY_CD').setFocus();
            alert("${BSB_060_0005}");
            return;
        }

        if (EVF.V('USER_TYPE') == 'S') {
            alert("${BSB_060_0004}");
		} else {

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "selectDept_I",
                'AllSelectYN': false,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : EVF.V("COMPANY_CD"),
                'custNm' :  EVF.V("COMPANY_NM")
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
        }
    }

    function selectDept_I(data) {
        data = JSON.parse(data);
        EVF.V('DEPT_CD', data.DEPT_CD);
        EVF.V('DEPT_NM', data.DEPT_NM);
    }

    function checkPass(type) {
        var pass = EVF.V('PASSWORD');
        var passc = EVF.V('PASSWORD_CHECK');

        if(pass != passc) {
        	alert("${msg.M0028}");
        	return;
        }

        var store = new EVF.Store();
        if(!store.validate()) return;
		store.setAsync(false);

		store.load( baseUrl + "userInformation/checkPass", function(){
			if (this.getParameter("chkFlag") == "false") {
                alert("${msg.M0028}");
                EVF.C('PASSWORD_CHECK').setValue(this.getParameter("PASSWORD"));

                return -1;
            } else {
                EVF.C('PASSWORD').setValue(this.getParameter("PASSWORD"));
                EVF.C('PASSWORD_CHECK').setValue(this.getParameter("PASSWORD"));

                if(type === 'saveUser') {
                	saveUserLogic();
                }

                return 0;
            }
		});
    }

    function resetLast() {

        var valueNew = EVF.V('USER_ID');
        var valueOld = EVF.V('USER_ID_ORI');

        if (valueNew != valueOld || valueOld == "") {
            return alert("${msg.M0007}");
        }

		if (confirm("${msg.M0029}")) {
			var store = new EVF.Store();
			store.load(baseUrl + "userInformation/doResetLast", function() {
				alert(this.getResponseMessage());
			});
		}
    }

    function issuePass() {

        var valueNew = EVF.V('USER_ID');
        var valueOld = EVF.V('USER_ID_ORI');
        var gateCd = EVF.V('GATE_CD');

        if (valueNew != valueOld || valueOld == "") {
            alert('${msg.M0007}');
            return;
        }

        var param = {
            "GATE_CD": "${ses.gateCd }",
            "USER_ID": EVF.V('USER_ID'),
            "USER_TYPE": EVF.V('USER_TYPE'),
            "onClose": "doClosePopup"
        };

        var popupUrl = baseUrl + 'passwordNumberIssue/view';
        everPopup.openWindowPopup(popupUrl, 700, 150, param, 'issuePass', false);
    }

    function InitPass() {

        var valueNew = EVF.V('USER_ID');
        var valueOld = EVF.V('USER_ID_ORI');

        if (valueNew != valueOld || valueOld == "") {
            return alert('${msg.M0007}');
        }

        if (confirm("${BSB_060_0007}")) {
            var store = new EVF.Store();
            if(EVF.V("USER_TYPE") == "C"){ <%-- 운영사 --%>
                store.load(baseUrl + 'userInformation/doInitPassword', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
			} else {
                store.load(baseUrl + 'userInformation/doInitPassword_CVUR', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
			}
		}
	}

    function doClosePopup() {
        doSearch();
    }

    function saveUser() {

        if (auGrid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

    	var userId = everString.lrTrim(EVF.C('USER_ID').getValue().toUpperCase());
    	EVF.C('USER_ID').setValue(userId);
        setRequired(true);

        if (confirm("${msg.M0021}")) {
            if(eval(checkPass('saveUser')) != 0) {

            }
        }
    }

    function saveUserLogic() {

        var store = new EVF.Store();
        if(!store.validate()) return;

       	currentUserId = EVF.C('USER_ID').getValue();
        if( EVF.V("USER_TYPE") == "C" ){
            var chkRowId = acGrid.getSelRowId();
            for( var rowId in chkRowId ) {
                acGrid.setCellValue(chkRowId[rowId], "USER_ID", currentUserId);
            }

            chkRowId = auGrid.getSelRowId();
            for( var rowId in chkRowId ) {
                auGrid.setCellValue(chkRowId[rowId], "USER_ID", currentUserId);
            }

            if (auGrid.getSelRowCount() == 0) {
                alert("Menu Profile !! " + "${msg.M0004}");
                return;
            }

            store.setGrid([acGrid, auGrid]);
            store.getGridData(acGrid, 'sel');
            store.getGridData(auGrid, 'sel');
            store.setParameter("mode", "I");
            store.load( baseUrl + "userInformation/doSaveUserInfo", function() {
            	EVF.V("USER_ID_SEARCH", EVF.V("USER_ID"));
                if (this.getParameter("checkResult") == "confirm") {
                    if (confirm("${msg.M0027}")) {
                        var store = new EVF.Store();
                        store.setGrid([acGrid, auGrid]);
                        store.getGridData(acGrid, 'sel');
                        store.getGridData(auGrid, 'sel');
                        store.setParameter("mode", "O");
                        store.load( baseUrl + "userInformation/doSaveUserInfo", function() {
                            alert(this.getResponseMessage());
                            doSearch();
                        });
                    }
                } else {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }
        else {
            chkRowId = auGrid.getSelRowId();
            for( var rowId in chkRowId ) {
                auGrid.setCellValue(chkRowId[rowId], "USER_ID", currentUserId);
            }
            store.setGrid([auGrid]);
            store.getGridData(auGrid, 'sel');
            store.setParameter("mode", "I");
            store.load( baseUrl + "userInformation/doSaveUserInfo_VNGL", function() {
            	EVF.V("USER_ID_SEARCH", EVF.V("USER_ID"));
                if (this.getParameter("checkResult") == "confirm") {
                    if (confirm("${msg.M0027}")) {
                        var store = new EVF.Store();
                        store.setGrid([acGrid, auGrid]);
                        store.getGridData(acGrid, 'sel');
                        store.getGridData(auGrid, 'sel');
                        store.setParameter("mode", "O");
                        store.load( baseUrl + "userInformation/doSaveUserInfo_VNGL", function() {
                            alert(this.getResponseMessage());
                            doSearch();
                        });
                    }
                } else {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }
    }

    function deleteUser() {

        var valueNew = EVF.C('USER_ID').getValue();
        var valueOld = EVF.C('USER_ID_ORI').getValue();

        if( EVF.V("IF_USER_FLAG") == '1' ) {
        	return alert("${BSB_060_0005}");
        }

        if (valueNew != valueOld || valueOld == "") {
            alert("${msg.M0007}");
            return;
        }

        if (!confirm("${msg.M0013}")) {
            return;
        }

		if(grid.isEmpty(valueOld) || !/\S/.test(valueOld) ) {
			alert("${msg.M0054 }"); return;
		}

		var store = new EVF.Store();
		store.load(baseUrl + "userInformation/doDeleteUser", function() {
			alert(this.getResponseMessage());
			clearForm();
		});
    }

    $(document.body).ready(function() {
    	$('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
			{
                activate: function(event, ui) {
                    $(window).trigger('resize');
                }
            }
    	);
		$('#e-tabs').tabs('option', 'active', 0);
		getContentTab('1');
	});

    function getContentTab(uu) {
		if (uu == '1') {
			window.scrollbars = true;
		}
		if (uu == '2') {
			window.scrollbars = true;
		}
	}

	function UserTypeSearchChange(){

        EVF.C('COMPANY_CD_SEARCH').setValue("");
        EVF.C('COMPANY_NM_SEARCH').setValue("");
        EVF.C('S_DEPT_NM').setValue("");
        EVF.C('S_DEPT_CD').setValue("");

        if(EVF.V("USER_TYPE_SEARCH")=="S"){
            EVF.C('S_DEPT_CD').setDisabled(true);
            EVF.C('S_DEPT_NM').setDisabled(true);
        }else{
            EVF.C('S_DEPT_CD').setDisabled(false);
            EVF.C('S_DEPT_NM').setDisabled(false);
        }

        if(EVF.V("USER_TYPE_SEARCH")=="C"){
            EVF.C('COMPANY_CD_SEARCH').setValue("${ses.companyCd}");
            EVF.C('COMPANY_NM_SEARCH').setValue("${ses.companyNm}");
		}
	}

    function _onChangeUserType(){

	    if( EVF.V("USER_TYPE") == "C" ){
            EVF.C("PLANT_CD").setRequired(true);
            EVF.C("PLANT_NM").setRequired(true);
            EVF.C("DIVISION_CD").setRequired(false);
            EVF.C("DIVISION_NM").setRequired(false);
		} else if(EVF.V("USER_TYPE") == "B"){
            EVF.C("PLANT_CD").setRequired(true);
            EVF.C("PLANT_NM").setRequired(true);
            EVF.C("DIVISION_CD").setRequired(true);
            EVF.C("DIVISION_NM").setRequired(true);
		} else{
            EVF.C("PLANT_CD").setRequired(false);
            EVF.C("PLANT_NM").setRequired(false);
            EVF.C("DIVISION_CD").setRequired(false);
            EVF.C("DIVISION_NM").setRequired(false);
		}

        searchProfile();
	}

	function ModCheckPW(){
        var checkType = this.getData();
        if(checkType == "1") {
            EVF.V("PASSWORD","");
            EVF.V("CHANGE_PW","Y");
		}
        if(checkType == "2") {
            EVF.V("PASSWORD_CHECK","");
            EVF.V("CHANGE_PW","Y");
        }
	}

    function CheckCall(){
        var str;
        if(this.data=="1"){
            str = EVF.V("PASSWORD");
        }else{
            str = EVF.V("PASSWORD_CHECK");
        }
        if(!chkPwd(str)){
            EVF.C("PASSWORD").setValue("");
            EVF.C("PASSWORD_CHECK").setValue("");
            $('#PASSWORD').focus();
        }
    }

    // 비밀번호 : 영문, 숫자, 특수 포함 6 ~ 12자리
    function chkPwd(str){
        var SamePass_0 = 0;
        var SamePass_1 = 0;
        var SamePass_2 = 0;

		var reg_pwd  = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[a-zA-Z]).*$/;					//영문,숫자
		var reg_pwd2 = /^.*(?=.{6,12})(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;				//영문,특수
		var reg_pwd3 = /^.*(?=.{6,12})(?=.*[0-9])(?=.*[!@#$%^&+=]).*$/;					//숫자,특수
		var reg_pwd4 = /^.*(?=^.{6,12}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$/;	//영문,숫자,특수문자

        if(reg_pwd.test(str) || reg_pwd2.test(str)|| reg_pwd3.test(str)|| reg_pwd4.test(str)){
        } else {
        	return alert("${BSB_060_021}"); // 비밀번호는 영문, 숫자, 특수문자의 조합으로 6~12자리로 입력해주세요.
        }

        if(str.length > 12){ // 비밀번호는 영문, 숫자, 특수문자의 조합으로 6~12자리로 입력해주세요.
            return alert("${BSB_060_021}");
        }

		//동일문자 카운트
		for(var i=0; i < str.length; i++) {
			var chr_pass_0 = str.charAt(i);
			var chr_pass_1 = str.charAt(i+1);
			var chr_pass_2 = str.charAt(i+2);

			if(chr_pass_0 == chr_pass_1 && chr_pass_1 == chr_pass_2) {
				SamePass_0 = SamePass_0 + 1
			}

            var chr_pass_2 = str.charAt(i+2);
            if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == 1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == 1) {
                SamePass_1 = SamePass_1 + 1
            }

            if(chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == -1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == -1) {
                SamePass_2 = SamePass_2 + 1
            }
        }

        if(SamePass_0 > 0) {
            alert("${BSB_060_022}"); // 동일한 문자를 3번 이상 사용할 수 없습니다.
            return false;
        }

        if(SamePass_1 > 1 || SamePass_2 > 1 ) {
            alert("${BSB_060_023}"); // 연속된 문자열(123 또는 321, abc, cba 등)을 3자 이상 사용 할 수 없습니다.
            return false;
        }
        return true;
    }

	function checkEmail(){

        if(!everString.isValidEmail(EVF.V("EMAIL"))) {
            alert("${msg.EMAIL_INVALID}");

            EVF.V("EMAIL","");
        }
	}

    function checkTelNo() {
        var checkType = this.getData();
        if(checkType == "FAX_NUM") {
            if(!everString.isTel(EVF.C("FAX_NUM").getValue())) {
                alert("${msg.M0128}");
                EVF.C("FAX_NUM").setValue("");
                EVF.C('FAX_NUM').setFocus();
            }
        }
        if(checkType == "TEL_NUM") {
            if(!everString.isTel(EVF.C("TEL_NUM").getValue())) {
                alert("${msg.M0128}");
                EVF.C("TEL_NUM").setValue("");
                EVF.C('TEL_NUM').setFocus();
            }
        }
    }

    function checkCellNo() {
	    var CellNum = EVF.V("CELL_NUM");
		var rgEx = /(01[016789])[-](\d{4}|\d{3})[-]\d{4}$/g;
		var chkFlg = rgEx.test(CellNum);
		if(!chkFlg){
			EVF.C("CELL_NUM").setValue("");
			EVF.C('CELL_NUM').setFocus();
			return alert("${msg.M0128}");
		}
    }
</script>

<e:window id="BSB_060" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">

	<e:panel id="pnl1" width="39%" height="100%">
		<e:buttonBar id="a" align="right" width="100%" title="${BSB_060_TITLE1}">
			<e:button id="searchUser" name="searchUser" label="${searchUser_N }" onClick="doSearch" disabled="${searchUser_D }" visible="${searchUser_V }"  />
		</e:buttonBar>

        <e:searchPanel id="formL" title="${msg.M9999}" onEnter="doSearch" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="1">
            <e:row>
                <e:label for="USER_TYPE_SEARCH" title="${sForm_USER_TYPE_SEARCH_N}"></e:label>
                <e:field>
					<e:select id="USER_TYPE_SEARCH" name="USER_TYPE_SEARCH" value="C" options="${userTypeSearchOptions}" width="100%" disabled="${sForm_USER_TYPE_SEARCH_D}" readOnly="${sForm_USER_TYPE_SEARCH_RO}" required="${sForm_USER_TYPE_SEARCH_R}" placeHolder=""  usePlaceHolder="false" onChange="UserTypeSearchChange" />
					<e:inputHidden id="GRID_USER_TYPE" name="GRID_USER_TYPE" value=""/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="COMPANY_NM_SEARCH" title="${sForm_COMPANY_NM_SEARCH_N}"></e:label>
                <e:field>
					<e:search id="COMPANY_CD_SEARCH" style="ime-mode:inactive" name="COMPANY_CD_SEARCH" value="${form.COMPANY_CD_SEARCH}" width="40%" maxLength="${form_COMPANY_CD_SEARCH_M}" onIconClick="${form_COMPANY_CD_SEARCH_RO ? 'everCommon.blank' : 'companySearch_S'}" disabled="${form_COMPANY_CD_SEARCH_D}" readOnly="${form_COMPANY_CD_SEARCH_RO}" required="${form_COMPANY_CD_SEARCH_R}" />
					<e:inputText id="COMPANY_NM_SEARCH" style="${imeMode}" name="COMPANY_NM_SEARCH" value="" width="60%" maxLength="${form_COMPANY_NM_SEARCH_M}" disabled="${form_COMPANY_NM_SEARCH_D}" readOnly="${form_COMPANY_NM_SEARCH_RO}" required="${form_COMPANY_NM_SEARCH_R}"  />
                </e:field>
            </e:row>
            	<e:row>
                	<e:label for="DEPT_NM_SEARCH" title="${sForm_DEPT_NM_SEARCH_N}"></e:label>
					<e:field>
						<e:search id="S_DEPT_CD" style="ime-mode:inactive" name="S_DEPT_CD" value="" width="40%" maxLength="${sForm_S_DEPT_CD_M}" onIconClick="${sForm_S_DEPT_CD_RO ? 'everCommon.blank' : 'getDeptCd'}" data ="S" disabled="${sForm_S_DEPT_CD_D}" readOnly="${sForm_S_DEPT_CD_RO}" required="${sForm_S_DEPT_CD_R}" />
						<e:inputText id="S_DEPT_NM" style="${imeMode}" name="S_DEPT_NM" value="" width="60%" maxLength="${sForm_S_DEPT_NM_M}" disabled="${sForm_S_DEPT_NM_D}" readOnly="${sForm_S_DEPT_NM_RO}" required="${sForm_S_DEPT_NM_R}" onKeyDown="cleanBsCd" />
					</e:field>
	            </e:row>
           	<e:row>
               	<e:label for="USER_ID_SEARCH" title="${sForm_USER_ID_SEARCH_N}"></e:label>
                <e:field>
					<e:inputText id="USER_ID_SEARCH" style='ime-mode:inactive' name="USER_ID_SEARCH" value="${form.USER_ID_SEARCH}" width="100%" maxLength="${sForm_USER_ID_SEARCH_M}" disabled="${sForm_USER_ID_SEARCH_D}" readOnly="${sForm_USER_ID_SEARCH_RO}" required="${sForm_USER_ID_SEARCH_R}" />
               	</e:field>
            </e:row>
           	<e:row>
               	<e:label for="USER_NM_SEARCH" title="${sForm_USER_NM_SEARCH_N}"></e:label>
                <e:field>
					<e:inputText id="USER_NM_SEARCH" style="${imeMode}" name="USER_NM_SEARCH" value="${form.USER_NM_SEARCH}" width="100%" maxLength="${sForm_USER_NM_SEARCH_M}" disabled="${sForm_USER_NM_SEARCH_D}" readOnly="${sForm_USER_NM_SEARCH_RO}" required="${sForm_USER_NM_SEARCH_R}" />
               	</e:field>
            </e:row>
		</e:searchPanel>
        <e:gridPanel gridType="${_gridType}" id="sGrid" name="sGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.sGrid.gridColData}" />
	</e:panel>

    <e:panel id="blank_pn" width="1%">&nbsp;</e:panel>

	<e:panel id="pnl2" width="60%" 	height="100%">
		<e:buttonBar id="b" width="100%" align="right" title="${BSB_060_TITLE2}">
			<e:button id="InitPass" name="InitPass" label="${InitPass_N }" onClick="InitPass"  visible="${InitPass_V }"  />
			<e:button id="issuePass" name="issuePass" label="${issuePass_N }" onClick="issuePass" visible="${issuePass_V }"  />
			<e:button id="resetLast" name="resetLast" label="${resetLast_N }" onClick="resetLast"  visible="${resetLast_V }"  />
			<e:button id="saveUser"  name="saveUser"  label="${saveUser_N }" onClick="saveUser" visible="${saveUser_V }"  />
			<e:button id="deleteUser" name="deleteUser" label="${deleteUser_N }" onClick="deleteUser" visible="${deleteUser_V }"  />
			<e:button id="clearForm"  name="clearForm"  label="${clearForm_N }"  onClick="clearForm" visible="${clearForm_V }"  />
		</e:buttonBar>

        <e:searchPanel id="formR" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2">
			<e:inputHidden id="GATE_CD" name="GATE_CD"/>
           	<e:inputHidden id="WORK_TYPE" name="WORK_TYPE" value="${form.WORK_TYPE}"/>
			<e:inputHidden id="USER_ID_ORI" name="USER_ID_ORI"/>
			<e:inputHidden id="INSERT_FLAG" name="INSERT_FLAG" value="I"/>
			<e:inputHidden id="TMP_WORD" name="TMP_WORD"/>
			<e:inputHidden id="TMP_WORD_CHK" name="TMP_WORD_CHK"/>
           	<e:inputHidden id="COUNTRY_CD" name="COUNTRY_CD" value="${form.COUNTRY_CD}" />
            <e:inputHidden id="USER_DATE_FORMAT_CD" name="USER_DATE_FORMAT_CD" value="${form.USER_DATE_FORMAT_CD}" />
            <e:inputHidden id="USER_NUMBER_FORMAT_CD" name="USER_NUMBER_FORMAT_CD" value="${form.USER_NUMBER_FORMAT_CD}" />
            <!-- I/F 사용자의 조직정보는 변경할 수 없다. -->
			<e:inputHidden id="IF_USER_FLAG" name="IF_USER_FLAG" value="${form.IF_USER_FLAG}"/>

            <e:row>
                <e:label for="USER_TYPE" title="${form_USER_TYPE_N}"></e:label>
                <e:field>
					<e:select id="USER_TYPE" name="USER_TYPE" value="${form.USER_TYPE}" options="${userTypeOptions}" width="100%" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder=""  onChange="_onChangeUserType" />
                </e:field>
                <e:label for="COMPANY_CD" title="${form_COMPANY_CD_N}"></e:label>
                <e:field>
					<e:search id="COMPANY_CD" name="COMPANY_CD" value="${form.COMPANY_CD}" width="35%" maxLength="${form_COMPANY_CD_M}" onIconClick="companySearch_I" disabled="${form_COMPANY_CD_D}" readOnly="${form_COMPANY_CD_RO}" required="${form_COMPANY_CD_R}" />
					<e:inputText id="COMPANY_NM" style='ime-mode:inactive' name="COMPANY_NM" value="${form.COMPANY_NM}" width="65%" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="true" required="${form_COMPANY_NM_R}" />
                </e:field>
            </e:row>
           	<e:row>
               	<e:label for="USER_ID" title="${form_USER_ID_N}"></e:label>
                <e:field>
					<e:inputText id="USER_ID" style='ime-mode:inactive' name="USER_ID" value="${form.USER_ID}" width="100%" maxLength="${form_USER_ID_M}" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
               	</e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"></e:label>
                <e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="" width="35%" maxLength="${form_PLANT_CD_M}" onIconClick="plantSearch_I" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" style='ime-mode:inactive' name="PLANT_NM" value="${form.PLANT_NM}" width="65%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="true" required="${form_PLANT_NM_R}" />
                </e:field>
            </e:row>
           	<e:row>
               	<e:label for="USER_NM" title="${form_USER_NM_N}"></e:label>
                <e:field>
					<e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" value="${form.USER_NM}" width="100%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
               	</e:field>
                <e:label for="USER_NM_ENG" title="${form_USER_NM_ENG_N}"></e:label>
                <e:field>
					<e:inputText id="USER_NM_ENG" style='ime-mode:inactive' name="USER_NM_ENG" value="${form.USER_NM_ENG}" width="100%" maxLength="${form_USER_NM_ENG_M}" disabled="${form_USER_NM_ENG_D}" readOnly="${form_USER_NM_ENG_RO}" required="${form_USER_NM_ENG_R}" />
                </e:field>
            </e:row>
           	<e:row>
               	<e:label for="PASSWORD" title="${form_PASSWORD_N}"></e:label>
                <e:field>
					<e:inputPassword id="PASSWORD" style='ime-mode:inactive' name="PASSWORD" value="${form.PASSWORD}"  width="100%" maxLength="${form_PASSWORD_M}" disabled="${form_PASSWORD_D}" readOnly="${form_PASSWORD_RO}" required="${form_PASSWORD_R}" onChange="CheckCall" data="1" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리" />
					<e:inputHidden id="CHANGE_PW" name="CHANGE_PW" value="" />
               	</e:field>
                <e:label for="PASSWORD_CHECK" title="${form_PASSWORD_CHECK_N}"></e:label>
                <e:field>
					<e:inputPassword id="PASSWORD_CHECK" style='ime-mode:inactive' name="PASSWORD_CHECK" value="${form.PASSWORD_CHECK}"  width="100%" maxLength="${form_PASSWORD_CHECK_M}" disabled="${form_PASSWORD_CHECK_D}" readOnly="${form_PASSWORD_CHECK_RO}" required="${form_PASSWORD_CHECK_R}" onChange="CheckCall" data="2" onClick="ModCheckPW" placeHolder="영문, 숫자, 특수문자의 조합으로 6~12자리"/>
                </e:field>
            </e:row>
            <e:row>
               	<e:label for="DIVISION_CD" title="${form_DIVISION_CD_N}"/>
				<e:field>
					<e:search id="DIVISION_CD" name="DIVISION_CD" value="${form.DIVISION_CD}" width="35%" maxLength="${form_DIVISION_CD_M}" onIconClick="doSearchDivision" disabled="${form_DIVISION_CD_D}" readOnly="${form_DIVISION_CD_RO}" required="${form_DIVISION_CD_R}" />
					<e:inputText id="DIVISION_NM" name="DIVISION_NM" value="${form.DIVISION_NM}" width="65%" maxLength="${form_DIVISION_NM_M}" disabled="${form_DIVISION_NM_D}" readOnly="${form_DIVISION_NM_RO}" required="${form_DIVISION_NM_R}" />
				</e:field>
				<e:label for="DEPT_CD" title="${form_DEPT_CD_N}"/>
				<e:field>
					<e:search id="DEPT_CD" name="DEPT_CD" value="${form.DEPT_CD}" width="35%" maxLength="${form_DEPT_CD_M}" onIconClick="doSearchDept" disabled="${form_DEPT_CD_D}" readOnly="${form_DEPT_CD_RO}" required="${form_DEPT_CD_R}" />
					<e:inputText id="DEPT_NM" name="DEPT_NM" value="${form.DEPT_NM}" width="65%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PART_CD" title="${form_PART_CD_N}"/>
				<e:field>
					<e:search id="PART_CD" name="PART_CD" value="${form.PART_CD}" width="35%" maxLength="${form_PART_CD_M}" onIconClick="doSearchPart" disabled="${form_PART_CD_D}" readOnly="${form_PART_CD_RO}" required="${form_PART_CD_R}" />
					<e:inputText id="PART_NM" name="PART_NM" value="${form.PART_NM}" width="65%" maxLength="${form_PART_NM_M}" disabled="${form_PART_NM_D}" readOnly="${form_PART_NM_RO}" required="${form_PART_NM_R}" />
				</e:field>
				<e:label for="EMPLOYEE_NUM" title="${form_EMPLOYEE_NUM_N}" />
				<e:field>
					<e:inputText id="EMPLOYEE_NUM" name="EMPLOYEE_NUM" value="${form.EMPLOYEE_NUM}" width="${form_EMPLOYEE_NUM_W}" maxLength="${form_EMPLOYEE_NUM_M}" disabled="${form_EMPLOYEE_NUM_D}" readOnly="${form_EMPLOYEE_NUM_RO}" required="${form_EMPLOYEE_NUM_R}" />
				</e:field>
            </e:row>
           	<e:row>
               	<e:label for="POSITION_NM" title="${form_POSITION_NM_N}"></e:label>
                <e:field>
					<e:inputText id="POSITION_NM" style="${imeMode}" name="POSITION_NM" value="${form.POSITION_NM}" width="100%" maxLength="${form_POSITION_NM_M}" disabled="${form_POSITION_NM_D}" readOnly="${form_POSITION_NM_RO}" required="${form_POSITION_NM_R}" />
               	</e:field>
                <e:label for="DUTY_NM" title="${form_DUTY_NM_N}"></e:label>
                <e:field>
					<e:inputText id="DUTY_NM" style="${imeMode}" name="DUTY_NM" value="${form.DUTY_NM}" width="100%" maxLength="${form_DUTY_NM_M}" disabled="${form_DUTY_NM_D}" readOnly="${form_DUTY_NM_RO}" required="${form_DUTY_NM_R}" />
                </e:field>
            </e:row>
           	<e:row>
                <e:label for="EMAIL" title="${form_EMAIL_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="EMAIL" name="EMAIL" style='ime-mode:inactive' value="${form.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" onChange="checkEmail"/>
                </e:field>
            </e:row>
           	<e:row>
               	<e:label for="TEL_NUM" title="${form_TEL_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" value="${form.TEL_NUM}" placeHolder="000-0000-0000" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" onChange="checkTelNo" data="TEL_NUM" />
               	</e:field>
                <e:label for="CELL_NUM" title="${form_CELL_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="CELL_NUM" name="CELL_NUM" value="${form.CELL_NUM}"  placeHolder="000-0000-0000" width="100%" maxLength="${form_CELL_NUM_M}" disabled="${form_CELL_NUM_D}" readOnly="${form_CELL_NUM_RO}" required="${form_CELL_NUM_R}" onChange="checkCellNo" data="CELL_NUM" />
                </e:field>
            </e:row>
           	<e:row>
               	<e:label for="FAX_NUM" title="${form_FAX_NUM_N}"></e:label>
                <e:field>
					<e:inputText id="FAX_NUM" name="FAX_NUM" value="${form.FAX_NUM}" placeHolder="000-0000-0000"  width="100%" maxLength="${form_FAX_NUM_M}" disabled="${form_FAX_NUM_D}" readOnly="${form_FAX_NUM_RO}" required="${form_FAX_NUM_R}" onChange="checkTelNo" data="FAX_NUM" />
               	</e:field>
               	<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"></e:label>
                <e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="100%" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
           	<e:row>
                <e:label for="SUPER_USER_FLAG" title="${form_SUPER_USER_FLAG_N}"></e:label>
                <e:field>
					<e:select id="SUPER_USER_FLAG" name="SUPER_USER_FLAG" value="${form.SUPER_USER_FLAG}" options="${superUserFlagOptions}" width="100%" disabled="${form_SUPER_USER_FLAG_D}" readOnly="${form_SUPER_USER_FLAG_RO}" required="${form_SUPER_USER_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="USE_FLAG" title="${form_USE_FLAG_N}"></e:label>
                <e:field>
					<e:select id="USE_FLAG" name="USE_FLAG" value="${form.USE_FLAG}" options="${refYN}" width="100%" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>
             <e:row>
                <e:label for="MOD_DATE" title="${form_MOD_DATE_N}"></e:label>
                <e:field>
                	<e:inputDate id="MOD_DATE" name="MOD_DATE" value="${MOD_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_MOD_DATE_R}" disabled="${form_MOD_DATE_D}" readOnly="${form_MOD_DATE_RO}" />
                </e:field>
               	<e:label for="CHANGE_USER_ID" title="${form_CHANGE_USER_ID_N}"></e:label>
                <e:field>
					<e:inputText id="CHANGE_USER_ID" name="CHANGE_USER_ID" value="${form.CHANGE_USER_ID}" width="100%" maxLength="${form_CHANGE_USER_ID_M}" disabled="${form_CHANGE_USER_ID_D}" readOnly="${form_CHANGE_USER_ID_RO}" required="${form_CHANGE_USER_ID_R}" />
               	</e:field>
            </e:row>
        </e:searchPanel>

		<e:title title="${form_CAPTION_MENU_N }" />
		<e:gridPanel gridType="${_gridType}" id="auGrid" name="auGrid" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.auGrid.gridColData}" />

		<div style="height: 0; width: 0; display: none;">
			<e:gridPanel gridType="${_gridType}" id="acGrid" name="acGrid" width="0" height="0" readOnly="${param.detailView}" columnDef="${gridInfos.acGrid.gridColData}" />
		</div>
	</e:panel>
</e:window>

</e:ui>
