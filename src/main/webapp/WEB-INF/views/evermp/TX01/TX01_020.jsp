<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">


	<style>

		.table_bg_line_color   {background-color:#518dcb}
		.cell_title {background-color:#cee5f5;height:30px;font-weight:bold;font-size:12px;color:#3575a6;padding-left:10px;}
		.cell_title1 {background-color:#cee5f5;height:25px;font-weight:bold;font-size:12px;color:#3575a6;padding-left:10px;}
		.cell_data {background-color:#ffffff; padding-left:7px;font-size:12px}
		.cell1_title {background-color:#f5dbde;height:30px;font-weight:bold;font-size:12px;color:#bc2d3f;padding-left:10px;}
		.cell1_data {background-color:#ffffff; padding-left:7px;}


	</style>



    <script>
        var grid;
        var baseUrl = "/evermp/TX01/";
        var ROW_ID;

        function init() {
            grid = EVF.C("grid");

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            var val = {visible: true, count: 1, height: 40};
            var footerTxt = {
                styles: {
                    textAlignment: "center",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: ["합 계"]
            };
            var footerSum = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    numberFormat: "###,###",
                    fontBold: true
                },
                text: "0",
                expression: ["sum"],
                groupExpression: "sum"
            };


            grid.cellClickEvent(function(rowId, colId, value) {
                var param;
                ROW_ID = rowId;
				if (colId === "MGRNO") {


					if('S' != grid.getCellValue(rowId, "STATUS")) {
						document.getElementById("mmm").innerHTML =  '';
						//return;
					}

					var MGRNO = grid.getCellValue(rowId, "MGRNO");



                        var store = new EVF.Store();
						store.setParameter('MGRNO',MGRNO);
                        store.load(baseUrl + "tx01020_detail", function () {


							var data = JSON.parse(this.getResponseMessage());

							var chaTable = "";
							var daeTable = "";
							var chahob = 0;
							var daehob = 0;
							var h_amt = 0;
							var v_h_amt = 0;
							var v_code = "";
							var v_name = "";
							var v_s_amt = 0;
							var shType = "";

							var s_flag = false;
							var h_flag = false;

        					for(var i = 0 ; i < data.length ; i++){
        						v_code = data[i].HKONT; //계정코드
        						v_name = data[i].HKONTNM; //계정과목
        						shType = data[i].SHKZG; //차대구분 - 한글로 들어옴
        						h_amt  = data[i].H_AMT;  //대변금액

        						s_amt = parseFloat(data[i].S_AMT); //차변금액
        						chahob += parseFloat(data[i].S_AMT);
        						daehob += parseFloat(data[i].H_AMT);


        						//차변
        						if(shType == "S"){
        							if(i < data.length-1){//다음로우의 값과 비교하기
        								var is_code = data[i + 1].HKONT;
        								var code = data[i].HKONT;

        								if(code==is_code){//만일 값이 같으면
        									v_s_amt += s_amt; //금액만 더한다
        									s_flag = true;
        								}else{
        									if(s_flag){
        										v_s_amt += s_amt;
        										s_amt = v_s_amt;
        										v_s_amt = 0;
        									}
        									s_flag = false;
        										chaTable += "				<tr>\n";
        										chaTable += "					<td class=\"cell_data\" >" + v_code + "</td>\n"
        										chaTable += "					<td class=\"cell_data\" >" + v_name + "</td>\n"
        										chaTable += "					<td class=\"cell_data\" align=\"right\" >" + add_comma(s_amt) + "</td>\n";
        										chaTable += "				</tr>";
        								}
        							}else{
        								if(s_flag){
        									v_s_amt += s_amt;
        									s_amt = v_s_amt;
        								}
        								chaTable += "				<tr>\n";
        								chaTable += "					<td class=\"cell_data\" >" + v_code + "</td>\n"
        								chaTable += "					<td class=\"cell_data\" >" + v_name + "</td>\n"
        								chaTable += "					<td class=\"cell_data\" align=\"right\">" + add_comma(s_amt)+ "</td>\n";
        								chaTable += "				</tr>";
        							}
        						}else if(shType == "H"){
        							if(i < data.length -1){
        								var is_code = data[i + 1].HKONT;
        								var code = data[i].HKONT;
        								if(code == is_code){
        									v_h_amt += parseFloat(data[i].H_AMT);
        									h_flag = true;
        								}else{
        									if(h_flag){
        										v_h_amt += parseFloat(data[i].H_AMT);
        										h_amt = v_h_amt;
        										v_h_amt = 0;
        									}
        									h_flag = false;

        									daeTable += "				<tr>\n";
        									daeTable += "					<td class=\"cell_data\">" + v_code + "</td>\n"
        									daeTable += "					<td class=\"cell_data\">" + v_name + "</td>\n"
        									daeTable += "					<td class=\"cell_data\" align=\"right\">" + add_comma(h_amt) + "</td>\n";
        									daeTable += "				</tr>";
        								}
        		 					}else{
        		 						if(h_flag){
        									v_h_amt += parseFloat(objGrid.GetCellValue("H_AMT",i));
        									h_amt = v_h_amt;
        								}

        								daeTable += "				<tr>\n";
        								daeTable += "					<td class=\"cell_data\">" + v_code + "</td>\n"
        								daeTable += "					<td class=\"cell_data\">" + v_name + "</td>\n"
        								daeTable += "					<td class=\"cell_data\" align=\"right\">" + add_comma(h_amt) + "</td>\n";
        								daeTable += "				</tr>";
        							}
        						}

        					}

        					var v_chahob = "			<tr>";
        					v_chahob += "					<td class=\"cell_data\" colspan=\"2\">차변합계</td>";
        					v_chahob += "					<td class=\"cell_data\" align=\"right\">"+  add_comma(chahob) + "</td>";
        					v_chahob += "				</tr>";

        					var v_daehob = "			<tr>"
        					v_daehob += "					<td class=\"cell_data\" colspan=\"2\" >대변합계</td>";
        					v_daehob += "					<td class=\"cell_data\" align=\"right\">" + add_comma(daehob) + "</td>";
        					v_daehob += "				</tr>"


                			var table = "<table width =\"98%\" border=\"0\" cellpadding=\"0\" cellspacing=\"1\" class=\"table_bg_line_color\">";
                			table += "	<tr bgcolor=\"#FFFFFF\">";
                			table += "		<td valign=\"top\" width=\"50%\">";
                			table += "			<table width=\"100%\" border=\"0\">";
                			table += "				<colgroup>";
                			table += "					<col width=\"30%\" />";
                			table += "					<col width=\"40%\" />";
                			table += "					<col width=\"30%\" />";
                			table += "				</colgroup>";
                			table += chaTable;
                			table += "			</table>";
                			table += "  	</td>";
                			table += "  	<td valign=\"top\" width=\"50%\">";
                			table += "			<table width=\"100%\" border=\"0\">";
                			table += "				<colgroup>";
                			table += "					<col width=\"30%\" />";
                			table += "					<col width=\"40%\" />";
                			table += "					<col width=\"30%\" />";
                			table += "				</colgroup>";
                			table += daeTable;
                			table += "			</table>";
                			table += "  	</td>";
                			table += "	</tr>";
                			table += "	<tr bgcolor=\"#FFFFFF\">";
                			table += "		<td valign=\"top\">";
                			table += "			<table width=\"100%\" border=\"0\">";
                			table += v_chahob;
                			table += "			</table>";
                			table += "  	</td>";
                			table += "  	<td>";
                			table += "			<table width=\"100%\" border=\"0\">";
                			table += v_daehob;
                			table += "			</table>";
                			table += "  	</td>";
                			table += "	</tr>";
                			table += "</table>";
                            document.getElementById("mmm").innerHTML =  table;


                        });

                }
            });








            grid.setProperty("footerVisible", val);
            grid.setRowFooter("ISSUE_DATE", footerTxt);
            grid.setRowFooter("SUP_AMT", footerSum);
            grid.setRowFooter("TAX_AMT", footerSum);
            grid.setRowFooter("TOT_AMT", footerSum);

            //grid.freezeCol("CLOSE_USER_NM");
            doSearch();
            chkClose();
        }


    	//천단위에 콤마넣기
    	function add_comma(n){

    		var reg = /(^[+-]?\d+)(\d{3})/; //정규식
    		n += ''; // 숫자를 문자로 변환
    		while(reg.test(n)){
    			n = n.replace(reg, '$1' + ',' + '$2');
    		}
    		return n;
    	}

        function doSearch() {
            var store = new EVF.Store();
            // if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "tx01020_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    alert('${msg.M0002}');
                } else {
                    var S_SUP_AMT = 0;
                    var P_SUP_AMT = 0;
                    var S_TAX_AMT = 0;
                    var P_TAX_AMT = 0;
                    var TOT_AMT = 0;

                    var rows = grid.getAllRowValue();
                    var rowIds = grid.getAllRowId();
                    for( var i = 0; i < rows.length; i++ ) {
                    	if (grid.getCellValue(rowIds[i],"STATUS") == 'S') {
                            grid.setCellBgColor(rowIds[i], "STATUS", "#bae3ff");
                            grid.setCellBgColor(rowIds[i], "MESSAGE", "#bae3ff");
                    	} else if (grid.getCellValue(rowIds[i],"STATUS") == 'E') {
                            grid.setCellBgColor(rowIds[i], "STATUS", "#FF0000");
                            grid.setCellBgColor(rowIds[i], "MESSAGE", "#FF0000");
                    	}

                    	if (grid.getCellValue(rowIds[i],"DEL_FLAG") == '1') {
                            grid.setCellBgColor(rowIds[i], "DEL_FLAG", "#FF2424");
                    	}



                    }
                }
            });
        }

        function doAccV() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if (grid.getCellValue(rowIds[i], "ACCOUNT_CHECK_YN") == "Y") {
                    return alert("${TX01_020_006}"); // 이미 회계검증된 계산서 입니다.
                }
            }

            if (!confirm("${TX01_020_001 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01020_doAccV", function () {
                doSearch();
                return alert('${msg.M0001}');
            });
        }

        function doAccV_Cancel() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if (grid.getCellValue(rowIds[i], "ACCOUNT_CHECK_YN") == "N") {
                    return alert("${TX01_020_012}"); // 회계검증을 진행 후 회계검증취소를 하여 주시기 바랍니다.
                }

                if (grid.getCellValue(rowIds[i], "ACCOUNT_CONFIRM_YN") == "Y") {
                    return alert("${TX01_020_007}");
                }
            }

            if (!confirm("${TX01_020_002 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01020_doAccV_Cancel", function () {
                doSearch();
                return alert('${msg.M0001}');
            });
        }

        function doAccC() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if (grid.getCellValue(rowIds[i], "ACCOUNT_CONFIRM_YN") == "Y") {
                    return alert("${TX01_020_007}"); // 이미 회계확정된 계산서 입니다.
                }

                if (grid.getCellValue(rowIds[i], "ACCOUNT_CHECK_YN") == "N") {
                    return alert("${TX01_020_014}");
                }
            }

            if (!confirm("${TX01_020_003 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01020_doAccC", function () {
                doSearch();
                return alert('${msg.M0001}');
            });
        }

        function doAccC_Cancel() {
            if (grid.getSelRowCount() == 0) { return alert('${msg.M0004}'); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if (grid.getCellValue(rowIds[i], "ACCOUNT_CONFIRM_YN") == "N") {
                    return alert("${TX01_020_011}"); // 회계확정을 진행 후 회계확정취소를 하여 주시기 바랍니다.
                }
            }

            if (!confirm("${TX01_020_004 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01020_doAccC_Cancel", function () {
                doSearch();
                return alert('${msg.M0001}');
            });
        }

        function doAutoDocExe() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            var rowIds = grid.getSelRowId();
            var confirmYN = "Y";

            for( var i in rowIds ) {
                if (grid.getCellValue(rowIds[i], "STATUS") == "S") {
                    return alert("${TX01_020_008}"); // 이미 전표이관된 계산서 입니다.
                }

            }

            if(confirmYN == "Y") {
                if (!confirm("${TX01_020_005 }")) return;
            } else {
                if (!confirm("${TX01_020_016 }")) return;
            }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01020_doAutoDocExe", function () {
                doSearch();
                return alert('${TX01_020_018}');
            });
        }
        function doSalesClose() {

/*
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if (grid.getCellValue(rowIds[i], "ACCOUNT_CLOSE_YN") == "Y") {
                    return alert("${TX01_020_013}"); // 이미 월매출마감종료된 계산서 입니다.
                }
            }
*/


            if (!confirm(everString.getMessage("${TX01_020_009 }", EVF.V("CLOSE_YEAR") + "년 " + EVF.V("CLOSE_MONTH") + "월") +
                    "\n" + everString.getMessage("${TX01_020_010 }", EVF.V("CLOSE_YEAR") + "년 " + EVF.V("CLOSE_MONTH") + "월"))) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.setParameter("TYPE", "S");
            store.load(baseUrl + "tx01020_doSalesClose", function () {
                doSearch();
                chkClose();
                return alert('${msg.M0001}');
            });
        }







        function doSalesCloseCancel() {
            var store = new EVF.Store();
            store.setParameter("TYPE", "S");
            store.load(baseUrl + "doSalesCloseCancel", function () {
                doSearch();
                chkClose();
                return alert('${msg.M0001}');
            });
       	}





        function onIconClickCUST_CD() {
            var param = {
                callBackFunction: "callbackCUST_CD"
            };
            everPopup.openCommonPopup(param, "SP0067");
        }

        function callbackCUST_CD(data) {
            EVF.V("CUST_CD", data.CUST_CD);
            EVF.V("CUST_NM", data.CUST_NM);
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${TX01_020_019}");
            var param = {
                callBackFunction : "callBackPlant",
                custCd: EVF.V("CUST_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
        }







        function chkClose() {
   	            var store = new EVF.Store();
   	            store.setParameter("TYPE", "S");
   	            store.load(baseUrl + "chkClose", function () {
   	            	var chkCount = this.getResponseMessage();
					var ctrlCd = '${ses.ctrlCd}';

					if(chkCount=='0') {
						if ( ctrlCd.indexOf('P100')!= -1 ) {
							EVF.C("doAutoDocExe").setDisabled(false);
							EVF.C("doSalesClose").setDisabled(false);
						}
							EVF.C("doSalesCloseCancel").setDisabled(true);
					} else {
						EVF.C("doAutoDocExe").setDisabled(true);
						EVF.C("doSalesClose").setDisabled(true);
						if ( ctrlCd.indexOf('P100')!= -1 ) {
						EVF.C("doSalesCloseCancel").setDisabled(false);
						}
					}
   	            });
        }




    </script>

    <e:window id="TX01_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <%-- 매출 : S, 매입 : P --%>
        <e:inputHidden id="C_FLAG" name="C_FLAG" value="S" />

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CLOSE_YEAR" title="${form_CLOSE_YEAR_N}"/>
                <e:field>
                    <e:select id="CLOSE_YEAR" name="CLOSE_YEAR" onChange="chkClose" value="${CLOSE_YEAR}" options="${closeYearOptions}" width="80" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false" />
                    <e:text>년 </e:text>
                    <e:select id="CLOSE_MONTH" name="CLOSE_MONTH" onChange="chkClose" value="${CLOSE_MONTH}" width="50" disabled="${form_CLOSE_MONTH_D}" readOnly="${form_CLOSE_MONTH_RO}" required="${form_CLOSE_MONTH_R}" placeHolder="" usePlaceHolder="false">
                        <e:option text="01" value="01"/>
                        <e:option text="02" value="02"/>
                        <e:option text="03" value="03"/>
                        <e:option text="04" value="04"/>
                        <e:option text="05" value="05"/>
                        <e:option text="06" value="06"/>
                        <e:option text="07" value="07"/>
                        <e:option text="08" value="08"/>
                        <e:option text="09" value="09"/>
                        <e:option text="10" value="10"/>
                        <e:option text="11" value="11"/>
                        <e:option text="12" value="12"/>
                    </e:select>
                    <e:text>월 </e:text>
                </e:field>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'onIconClickCUST_CD'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
					<e:inputHidden id="TYPE" name="TYPE" value="AR"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
                <e:field>
                    <e:select id="AM_USER_ID" name="AM_USER_ID" value="${ses.userId}" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
                </e:field>
                <e:label for="" title="" />
                <e:field> </e:field>
                <e:label for="" title="" />
                <e:field> </e:field>
            </e:row>
        </e:searchPanel>



        <e:buttonBar align="right" width="100%">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                <e:button id="doAutoDocExe" name="doAutoDocExe" label="${doAutoDocExe_N}" onClick="doAutoDocExe" disabled="${doAutoDocExe_D}" visible="${doAutoDocExe_V}"/>
                <e:button id="doSalesClose" name="doSalesClose" label="${doSalesClose_N}" onClick="doSalesClose" disabled="${doSalesClose_D}" visible="${doSalesClose_V}"/>
				<e:button id="doSalesCloseCancel" name="doSalesCloseCancel" label="${doSalesCloseCancel_N}" onClick="doSalesCloseCancel" disabled="${doSalesCloseCancel_D}" visible="${doSalesCloseCancel_V}"/>
        </e:buttonBar>
	        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="600px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
			<div id="mmm" name="mmm" align="center">
			</div>
    </e:window>
</e:ui>