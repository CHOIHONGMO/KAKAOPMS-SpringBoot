<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

		var baseUrl      = "/eversrm/eContract/eStatistics/P09_002/";
		var grid = {};

	    var val = {"visible": true, "count": 1, "height": 30};

	    var footer1 = {
	        "styles": {
	            "textAlignment": "far",
	            /*"suffix": " 원",*/
	            "numberFormat": "#,###.##"
	        },
	        "text": "${P09_002_101}",
	        "expression": ["sum"],
	        "groupExpression": "sum"
	    };

	    var footer2 = {
	        "styles": {
	            "textAlignment": "per"
	        },
	        "text":"${P09_002_101}"
	    };

		function init() {

			grid = EVF.C("grid");

			grid.setProperty('multiselect', false);

			grid.excelExportEvent({

				allItems : "${excelExport.allCol}",
                fileName : "${screenName }"

			});

		}

		function _getItemClsNm() {

			var popupUrl = "/eversrm/master/item/BBM_011/view";
			var param = {
				callBackFunction : "_setItemClassNm",
				//businessType: EVF.C("BSWM_CD").getValue()=="BW002"?"200":"100",
				businessType: "100",
				'detailView': false,
				'multiYN' : false,
				'ModalPopup' : true,
				'searchYN' : true
			};

			everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
		}

		function _setItemClassNm(data) {

			if(data==null){
				cleanItemClass();
			}else{
				data = JSON.parse(data);
				EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
				EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);
				EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);
				EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);
				EVF.C('ITEM_CLS_NM').setValue(data.ITEM_CLS_PATH_NM);
			}
		}

		function cleanItemClass() {

			EVF.C("ITEM_CLS1").setValue("");
			EVF.C("ITEM_CLS2").setValue("");
			EVF.C("ITEM_CLS3").setValue("");
			EVF.C("ITEM_CLS4").setValue("");
			EVF.C("ITEM_CLS_NM").setValue("");

		}

        function doSearch() {

			var store = new EVF.Store();

			if(EVF.C("ITEM_CLS_NM").getValue() == "") {

				cleanItemClass();

			}

			grid = EVF.C("grid");

			if(EVF.C("STYPE").getValue() == "100") {

				grid.setColName("TITLE_NM","항목(소분류)");

			}else if(EVF.C("STYPE").getValue() == "101"){

				grid.setColName("TITLE_NM","항목(사업구분)");

			}else if(EVF.C("STYPE").getValue() == "102"){

				grid.setColName("TITLE_NM","항목(관계사)");

			}else if(EVF.C("STYPE").getValue() == "103"){

				grid.setColName("TITLE_NM","항목(사업부)");

			}

			store.setGrid([ grid ]);

			store.load(baseUrl + 'p09002_doSearch', function() {

				if(grid.getRowCount() == 0){

					return alert("${P09_002_001}");

	            } else {

	                grid.setProperty('footerVisible', val);
	                grid.setRowFooter("TITLE_NM", footer2);
	                grid.setRowFooter("INV_AMT", footer1);
	                grid.setRowFooter("RATE", footer1);

	            }

			});
        }

        function doClose() {

            window.close();

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

	<e:window id="P09_002" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">

            <e:row>

				<e:label for="STD_MONTH" title="${form_STD_MONTH_N}"/>
				<e:field>
					<e:inputDate id="STD_MONTH" name="STD_MONTH" value="${toDate}" format="yyyy-mm" width="${inputDateWidth}" datePicker="true" required="${form_STD_MONTH_R}" disabled="${form_STD_MONTH_D}" readOnly="${form_STD_MONTH_RO}" />
				</e:field>

				<e:label for="STYPE" title="${form_STYPE_N}"/>
				<e:field>
					<e:radioGroup id="STYPE" name="STYPE" value="${empty form.STYPE ? '100' : form.STYPE}" width="100%" disabled="${form_STYPE_D}" readOnly="${form_STYPE_RO}" required="${form_STYPE_R}">
						<c:forEach var="item" items="${sType}">
							<e:radio id="STYPE_${item.value}" name="S_${item.value}" value="${item.value}" label="${item.text}" disabled="${form_STYPE_D}" readOnly="${form_STYPE_RO}" />
						</c:forEach>
					</e:radioGroup>
				</e:field>

			<e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
			<e:field>
				<e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onChange="cleanItemClass" onIconClick="${form_ITEM_CLS_NM_RO ? 'everCommon.blank' : '_getItemClsNm'}" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
				<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
				<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
				<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
				<e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
			</e:field>

			</e:row>

			<e:row>

				<e:label for="BS_TYPE" title="${form_BS_TYPE_N}"/>
				<e:field>
				<e:select id="BS_TYPE" name="BS_TYPE" value="" options="${bsTypeOptions}" width="${form_BS_TYPE_W}" disabled="${form_BS_TYPE_D}" readOnly="${form_BS_TYPE_RO}" required="${form_BS_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'getCustCd'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onChange="cleanCustCd" />
				</e:field>

				<e:label for="DEPT_CD" title="${form_DEPT_CD_N}" />
				<e:field>
					<e:search id="DEPT_CD" style="ime-mode:inactive" name="DEPT_CD" value="" width="40%" maxLength="${form_DEPT_CD_M}" onIconClick="${form_DEPT_CD_RO ? 'everCommon.blank' : 'getDeptCd'}" disabled="${form_DEPT_CD_D}" readOnly="true" required="${form_DEPT_CD_R}" />
					<e:inputText id="DEPT_NM" style="${imeMode}" name="DEPT_NM" value="" width="60%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" onChange="cleanDeptCd" />
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
