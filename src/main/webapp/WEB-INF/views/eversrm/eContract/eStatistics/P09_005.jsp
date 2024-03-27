<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

		var baseUrl      = "/eversrm/eContract/eStatistics/P09_005/";
		var grid = {};

	    var val = {"visible": true, "count": 1, "height": 30};

	    var footer1 = {
	        "styles": {
	            "textAlignment": "far",
	            /*"suffix": " 원",*/
	            "numberFormat": "#,###.##"
	        },
	        "text": "${P09_005_101}",
	        "expression": ["sum"],
	        "groupExpression": "sum"
	    };

	    var footer2 = {
	        "styles": {
	            "textAlignment": "per"
	        },
	        "text":"${P09_005_101}"
	    };

		function init() {

			grid = EVF.C("grid");

			grid.setProperty('multiselect', false);

			grid.hideCol("VENDOR_NM", false);
			grid.hideCol("INV_AMT", false);
			grid.hideCol("RATE", false);
			grid.hideCol("INCREASE_AMT", false);
			grid.hideCol("REMARK", false);

			grid.hideCol("CUST_NM", true);
			grid.hideCol("ITEM_CLS2_NM", true);
			grid.hideCol("ITEM_CLS3_NM", true);
			grid.hideCol("ITEM_CLS4_NM", true);
			grid.hideCol("INV_AMT_C", true);
			grid.hideCol("RATE_C", true);

			grid.excelExportEvent({

				allItems : "${excelExport.allCol}",
                fileName : "${screenName }"

			});

		}

        function doSearch() {

			var store = new EVF.Store();

			grid = EVF.C("grid");

			if(EVF.C("STYPE").getValue() == "100") {

				grid.hideCol("VENDOR_NM", false);
				grid.hideCol("INV_AMT", false);
				grid.hideCol("RATE", false);
				grid.hideCol("INCREASE_AMT", false);
				grid.hideCol("REMARK", false);

				grid.hideCol("CUST_NM", true);
				grid.hideCol("ITEM_CLS2_NM", true);
				grid.hideCol("ITEM_CLS3_NM", true);
				grid.hideCol("ITEM_CLS4_NM", true);
				grid.hideCol("INV_AMT_C", true);
				grid.hideCol("RATE_C", true)


			}else if(EVF.C("STYPE").getValue() == "101"){

				grid.hideCol("VENDOR_NM", true);
				grid.hideCol("INV_AMT", true);
				grid.hideCol("RATE", true);
				grid.hideCol("INCREASE_AMT", true);
				grid.hideCol("REMARK", true);

				grid.hideCol("CUST_NM", false);
				grid.hideCol("ITEM_CLS2_NM", false);
				grid.hideCol("ITEM_CLS3_NM", false);
				grid.hideCol("ITEM_CLS4_NM", false);
				grid.hideCol("INV_AMT_C", false);
				grid.hideCol("RATE_C", false)

			}

			store.setGrid([ grid ]);

			store.load(baseUrl + 'p09005_doSearch', function() {

				if(grid.getRowCount() == 0){

					return alert("${P09_005_001}");

	            } else {

	            	if(EVF.C("STYPE").getValue() == "100") {

	            		 grid.setProperty('footerVisible', val);
	  	                 grid.setRowFooter("VENDOR_NM", footer2);
	  	                 grid.setRowFooter("INV_AMT", footer1);
	  	                 grid.setRowFooter("RATE", footer1);
	  	                 grid.setRowFooter("INCREASE_AMT", footer1);

	            	}else{

	            		 grid.setProperty('footerVisible', val);
	  	                 grid.setRowFooter("CUST_NM", footer2);
	  	                 grid.setRowFooter("INV_AMT_C", footer1);
	  	                 grid.setRowFooter("RATE_C", footer1);

	            	}

	            }

			});
        }

        function doClose() {

            window.close();

        }

        function doSelectVendor() {
			everPopup.openCommonPopup({
				callBackFunction : "setVendor"
			}, 'SP0013');
        }
        function setVendor(vendor) {
			EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
			EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
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
                        //custNm = custNm + "," + data[idx].CUST_NM;
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

	</script>

	<e:window id="P09_005" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:row>

            	<e:label for="DATE_FROM" title="${form_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="DATE_FROM" name="DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="DATE_TO" name="DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" />
				</e:field>

				<e:label for="STYPE" title="${form_STYPE_N}"/>
				<e:field>
					<e:radioGroup id="STYPE" name="STYPE" value="${empty form.STYPE ? '100' : form.STYPE}" width="100%" disabled="${form_STYPE_D}" readOnly="${form_STYPE_RO}" required="${form_STYPE_R}">
						<c:forEach var="item" items="${sType}">
							<e:radio id="STYPE_${item.value}" name="S_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_STYPE_D}" readOnly="${form_STYPE_RO}" />
						</c:forEach>
					</e:radioGroup>
				</e:field>

                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="${form_VENDOR_CD_W}" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'doSelectVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>

			</e:row>

			<e:row>

				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'getCustCd'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onChange="cleanCustCd" />
				</e:field>

				<e:field colSpan="4">
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
