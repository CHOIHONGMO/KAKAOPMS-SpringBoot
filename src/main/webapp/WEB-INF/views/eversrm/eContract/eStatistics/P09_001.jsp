<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

		var baseUrl      = "/eversrm/eContract/eStatistics/P09_001/";
		var grid = {};

	    var val = {"visible": true, "count": 1, "height": 30};

	    var footer1 = {
	        "styles": {
	            "textAlignment": "far",
	            /*"suffix": " 원",*/
	            "numberFormat": "#,###.##"
	        },
	        "text": "${P09_001_101}",
	        "expression": ["sum"],
	        "groupExpression": "sum"
	    };

	    var footer2 = {
	        "styles": {
	            "textAlignment": "per"
	        },
	        "text":"${P09_001_101}"
	    };

		function init() {

			grid = EVF.C("grid");

			//grid.checkAll(true);

			//grid.setProperty('shrinkToFit', true);

			grid.setProperty('multiselect', false);

			grid.excelExportEvent({

				allItems : "${excelExport.allCol}",
                fileName : "${screenName }"

			});

			_setMakerOption();

		}

        function _setMakerOption() {

           //EVF.C("MAKER").setDisabled(false);

           var store = new EVF.Store();
           store.setParameter('BUSINESS_TYPE','100');
           store.load('/common/combo/getMakerOptions', function() {
               EVF.C('MAKER').setOptions(this.getParameter('makerOptions'));
           }, false);

        }

        function doSearch() {

			var store = new EVF.Store();
			store.setGrid([ grid ]);

			store.load(baseUrl + 'p09001_doSearch', function() {

				if(grid.getRowCount() == 0){

					return alert("${P09_001_001}");

	            } else {

	                grid.setProperty('footerVisible', val);
	                grid.setRowFooter("FORM_NM", footer2);
	                grid.setRowFooter("SUPPLY_AMT", footer1);
	                grid.setRowFooter("INV_AMT", footer1);

	            }

			});
        }

        function doClose() {

            window.close();

        }

        function getUser() {
        	var param = {
        			callBackFunction: "setUser",
        			BUYER_CD: "${ses.companyCd}"
        		};
    		everPopup.openCommonPopup(param,"SP0011");
        }

    	function setUser(dataJsonArray) {
    	    EVF.C("USER_NM").setValue(dataJsonArray.USER_NM);
            EVF.C("USER_ID").setValue(dataJsonArray.USER_ID);
        }

        function getDeptCd() {
        	var param = {
        			callBackFunction: "setDeptCd",
        		};
    		everPopup.openCommonPopup(param,"SP0002");
        }

    	function setDeptCd(dataJsonArray) {
    	    EVF.C("DEPT_NM").setValue(dataJsonArray.DEPT_NM);
            EVF.C("DEPT_CD").setValue(dataJsonArray.DEPT_CD);
        }

        function cleanDeptCd() {
        	var deptNm = EVF.C("DEPT_NM").getValue();
        	if(everString.lrTrim(deptNm) == "") {
        		EVF.C("DEPT_CD").setValue('');
        	}
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

	<e:window id="P09_001" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:row>

            	<e:label for="DATE_FROM" title="${form_DATE_FROM_N}"/>
				<e:field>
					<e:inputDate id="DATE_FROM" name="DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="DATE_TO" name="DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" />
				</e:field>

				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'getCustCd'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onChange="cleanCustCd" />
				</e:field>

				<e:label for="BS_TYPE" title="${form_BS_TYPE_N}"/>
				<e:field>
				<e:select id="BS_TYPE" name="BS_TYPE" value="" options="${bsTypeOptions}" width="${form_BS_TYPE_W}" disabled="${form_BS_TYPE_D}" readOnly="${form_BS_TYPE_RO}" required="${form_BS_TYPE_R}" placeHolder="" />
				</e:field>

			</e:row>

			<e:row>

				<e:label for="DEPT_CD" title="${form_DEPT_CD_N}" />
				<e:field>
					<e:search id="DEPT_CD" style="ime-mode:inactive" name="DEPT_CD" value="" width="40%" maxLength="${form_DEPT_CD_M}" onIconClick="${form_DEPT_CD_RO ? 'everCommon.blank' : 'getDeptCd'}" disabled="${form_DEPT_CD_D}" readOnly="true" required="${form_DEPT_CD_R}" />
					<e:inputText id="DEPT_NM" style="${imeMode}" name="DEPT_NM" value="" width="60%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" onChange="cleanDeptCd" />
				</e:field>

				<e:label for="USER_NM" title="${form_USER_NM_N}"/>
				<e:field>
					<e:search id="USER_ID" name="USER_ID" value="${ses.userId }" width="40%" maxLength="${form_USER_ID_M}" onIconClick="getUser" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
					<e:inputText id="USER_NM" name="USER_NM" value="${ses.userNm }" width="60%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				</e:field>

				<e:label for="CONTRACT_TYPE" title="${form_CONTRACT_TYPE_N}"/>
				<e:field>
				<e:select id="CONTRACT_TYPE" name="CONTRACT_TYPE" value="" options="${contractTypeOptions}" width="100%" disabled="${form_CONTRACT_TYPE_D}" readOnly="${form_CONTRACT_TYPE_RO}" required="${form_CONTRACT_TYPE_R}" placeHolder="" />
				</e:field>

			</e:row>

			<e:row>

				<e:label for="CONT_DESC" title="${form_CONT_DESC_N}" />
				<e:field>
				<e:inputText id="CONT_DESC" name="CONT_DESC" value="" width="100%" maxLength="${form_CONT_DESC_M}" disabled="${form_CONT_DESC_D}" readOnly="${form_CONT_DESC_RO}" required="${form_CONT_DESC_R}" />
				</e:field>

				<e:label for="COST_TYPE" title="${form_COST_TYPE_N}"/>
				<e:field>
				<e:select id="COST_TYPE" name="COST_TYPE" value="" options="${costTypeOptions}" width="${form_COST_TYPE_W}" disabled="${form_COST_TYPE_D}" readOnly="${form_COST_TYPE_RO}" required="${form_COST_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="MAKER" title="${form_MAKER_N}"/>
				<e:field>
					<e:select id="MAKER" name="MAKER" value="${form.MAKER}" options="${makerOptions}" width="100%" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
				</e:field>

			</e:row>

			<e:row>

				<e:label for="VENDOR_TYPE" title="${form_VENDOR_TYPE_N}"/>
				<e:field>
				<e:select id="VENDOR_TYPE" name="VENDOR_TYPE" value="" options="${vendorTypeOptions}" width="${form_VENDOR_TYPE_W}" disabled="${form_VENDOR_TYPE_D}" readOnly="${form_VENDOR_TYPE_RO}" required="${form_VENDOR_TYPE_R}" placeHolder="" />
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
