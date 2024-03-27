<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

		var baseUrl      = "/eversrm/eContract/eStatistics/P09_004/";
		var grid = {};

	    var val = {"visible": true, "count": 1, "height": 30};

	    var footer1 = {
	        "styles": {
	            "textAlignment": "far",
	            /*"suffix": " 원",*/
	            "numberFormat": "#,###.##"
	        },
	        "text": "${P09_004_101}",
	        "expression": ["sum"],
	        "groupExpression": "sum"
	    };

	    var footer2 = {
	        "styles": {
	            "textAlignment": "per"
	        },
	        "text":"${P09_004_101}"
	    };

		function init() {

			grid = EVF.C("grid");

			grid.setProperty('multiselect', false);

			grid.excelExportEvent({

				allItems : "${excelExport.allCol}",
                fileName : "${screenName }"

			});

		}

        function doSearch() {

			var store = new EVF.Store();

			grid = EVF.C("grid");

			if(EVF.C("STYPE").getValue() == "100") {

				grid.hideCol("PRE_MONTH_AMT", true)


			}else if(EVF.C("STYPE").getValue() == "101"){

				grid.hideCol("PRE_MONTH_AMT", false)

			}

			store.setGrid([ grid ]);

			store.load(baseUrl + 'p09004_doSearch', function() {

				if(grid.getRowCount() == 0){

					return alert("${P09_004_001}");

	            } else {

	                grid.setProperty('footerVisible', val);
	                grid.setRowFooter("CUST_NM", footer2);
	                grid.setRowFooter("INV_AMT", footer1);
	                grid.setRowFooter("RATE", footer1);
	                if(EVF.C("STYPE").getValue() == "101"){

	                	grid.setRowFooter("PRE_MONTH_AMT", footer1);

	    			}

	            }

			});
        }

        function doClose() {

            window.close();

        }

        function getCustCd() {
            var param = {
                callBackFunction : "setCustCd"
            };
            everPopup.openCommonPopup(param, 'MP0013');
        }

        function setCustCd(data) {

	        var custCd="";
	        var custNm="";

	        if(data.length != undefined) {

                for (var idx in data) {
                    if (idx == 0) {
                        custCd = data[0].CUST_CD;
                        custNm = data[0].CUST_NM;
                    } else {
                        custCd = custCd + "," + data[idx].CUST_CD;
						custNm =  data[0].CUST_NM + " 외 "+idx +"건";
                    }
                }
            }

            EVF.C("CUST_CD").setValue(custCd);
            EVF.C("CUST_NM").setValue(custNm);
        }

        function cleanCustCd() {
        	var custNm = EVF.C("CUST_NM").getValue();
        	if(everString.lrTrim(custNm) == "") {
        		EVF.C("CUST_CD").setValue('');
        	}
        }

        function fromChange() {

        	if(EVF.C("STYPE").getValue() == "100") {

        		var val = EVF.C("DATE_FROM").getValue();

        		var year = val.substr(0,4);
        		var month = val.substr(4,2);
        		var day = val.substr(6,2);
        		var date = new Date(year, month-1, day);

        		var endDay = new Date(year, month, 0);

        		EVF.C("DATE_TO").setValue((date.getFullYear()+1) + month + endDay.getDate());

        	}else{

        		EVF.C("DATE_FROM").setValue(EVF.C("DATE_FROM").getValue().substr(0,6)+"01");

        	}

        }

        function toChange() {

        	var val = EVF.C("DATE_TO").getValue();

    		var year = val.substr(0,4);
    		var month = val.substr(4,2);
    		var day = val.substr(6,2);
    		var date = new Date(year, month-1, day);

        	if(EVF.C("STYPE").getValue() == "100") {

        		EVF.C("DATE_FROM").setValue((date.getFullYear()-1) + month + "01");

        	}else{

        		var endDay = new Date(year, month, 0);
        		EVF.C("DATE_TO").setValue(EVF.C("DATE_TO").getValue().substr(0,6) + endDay.getDate());

        	}

        }

        function stypeChange(){

        	if(EVF.C("STYPE").getValue() == "100"){

        		var date = new Date();
        		var fYear = date.getFullYear()-1;
        		var tYear = date.getFullYear();
        		var month = date.getMonth()+1;
        		var day = date.getDate();
        		var endDay = new Date(tYear, month-1, 0);

        		EVF.C("DATE_FROM").setValue(fYear+""+month+"01");
        		EVF.C("DATE_TO").setValue(tYear+""+month+""+endDay.getDate());

        	}

        }

	</script>

	<e:window id="P09_004" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:row>

            	<e:label for="DATE_FROM" title="${form_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="DATE_FROM" name="DATE_FROM" value="${fromDate}" format="yyyy-mm" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" onChange="fromChange" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="DATE_TO" name="DATE_TO" value="${toDate}"  format="yyyy-mm" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" onChange="toChange" />
				</e:field>

				<e:label for="STYPE" title="${form_STYPE_N}"/>
				<e:field>
					<e:radioGroup id="STYPE" name="STYPE" value="${empty form.STYPE ? '100' : form.STYPE}" width="100%" disabled="${form_STYPE_D}" readOnly="${form_STYPE_RO}" required="${form_STYPE_R}" onChange="stypeChange">
						<c:forEach var="item" items="${sType}">
							<e:radio id="STYPE_${item.value}" name="S_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_STYPE_D}" readOnly="${form_STYPE_RO}" />
						</c:forEach>
					</e:radioGroup>
				</e:field>

				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'getCustCd'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onChange="cleanCustCd" />
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
