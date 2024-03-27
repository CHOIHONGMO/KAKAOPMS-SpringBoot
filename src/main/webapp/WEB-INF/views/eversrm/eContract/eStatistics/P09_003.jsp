<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

		var baseUrl      = "/eversrm/eContract/eStatistics/P09_003/";
		var grid = {};

	    var val = {"visible": true, "count": 1, "height": 30};

	    var footer1 = {
	        "styles": {
	            "textAlignment": "far",
	            /*"suffix": " 원",*/
	            "numberFormat": "#,###.##"
	        },
	        "text": "${P09_003_101}",
	        "expression": ["sum"],
	        "groupExpression": "sum"
	    };

	    var footer2 = {
	        "styles": {
	            "textAlignment": "per"
	        },
	        "text":"${P09_003_101}"
	    };

		function init() {

			grid = EVF.C("grid");

			grid.setProperty('multiselect', false);

			grid.excelExportEvent({

				allItems : "${excelExport.allCol}",
                fileName : "${screenName }"

			});

			_setMakerOption();

		}

        function _setMakerOption() {

            var store = new EVF.Store();
            store.setParameter('BUSINESS_TYPE','100');
            store.load('/common/combo/getMakerOptions', function() {
                EVF.C('MAKER').setOptions(this.getParameter('makerOptions'));
            }, false);

         }

        function doSearch() {

			var store = new EVF.Store();

			grid = EVF.C("grid");

			if(EVF.C("STYPE").getValue() == "100") {

				grid.setColName("TITLE_NM","사업구분");
				grid.hideCol("ITEM_CLS2_NM", true);
				grid.hideCol("MAKER_NM", true)

			}else if(EVF.C("STYPE").getValue() == "101"){

				grid.setColName("TITLE_NM","제조사");
				grid.hideCol("ITEM_CLS2_NM", true);
				grid.hideCol("MAKER_NM", true)


			}else if(EVF.C("STYPE").getValue() == "102"){

				grid.setColName("TITLE_NM","품목별");
				grid.hideCol("ITEM_CLS2_NM", false);
				grid.hideCol("MAKER_NM", false)

			}

			store.setGrid([ grid ]);

			store.load(baseUrl + 'p09003_doSearch', function() {

				if(grid.getRowCount() == 0){

					return alert("${P09_003_001}");

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

	</script>

	<e:window id="P09_003" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

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

				<e:label for="BS_TYPE" title="${form_BS_TYPE_N}"/>
				<e:field>
					<e:select id="BS_TYPE" name="BS_TYPE" value="" options="${bsTypeOptions}" width="${form_BS_TYPE_W}" disabled="${form_BS_TYPE_D}" readOnly="${form_BS_TYPE_RO}" required="${form_BS_TYPE_R}" placeHolder="" />
				</e:field>

			</e:row>

			<e:row>

				<e:label for="MAKER" title="${form_MAKER_N}"/>
				<e:field>
					<e:select id="MAKER" name="MAKER" value="${form.MAKER}" options="${makerOptions}" width="100%" disabled="${form_MAKER_D}" readOnly="${form_MAKER_RO}" required="${form_MAKER_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true" />
				</e:field>

                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"  style="${imeMode}"/>
				</e:field>

				<e:field colSpan="2">
				</e:field>

			</e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
        	<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
