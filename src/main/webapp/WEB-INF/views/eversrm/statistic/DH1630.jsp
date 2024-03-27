<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var grid2;
    var baseUrl = "/eversrm/statistic/DH1630";
    var selRow;
	var currrow;

    function init() {
      	//grid = new EVF.GridPanel('grid');
		grid = new EVF.C('grid');
		grid2 = EVF.getComponent('grid2');
		grid.createColumn('ITEM_CLS_NM4', '구분', 200, 'center', 'text', 20, false,'');
		grid.setProperty('panelVisible', ${panelVisible});
        grid2.setProperty('panelVisible', ${panelVisible});
		<c:forEach varStatus="status" var="columnx" items="${columnInfos}">
			grid.createColumn('${columnx.COLUMN_ID}', '${columnx.COLUMN_NM}', 150, 'right', 'number', 50, false,false, '', 0);
		</c:forEach>

		grid.createColumn('TOTAL_AMT', '계', 150, 'right', 'number', 50, false,false, '', 0);

		//grid.boundColumns();

		grid.excelExportEvent({
		});

		//grid.setProperty('footerrow', true);
		//grid.setProperty('footerVisible', true);

		//grid2.setProperty('footerrow', true);
		//grid2.setRowFooter('PER', 'sum', '합 계', 'VENDOR_NM');
		grid2.setProperty('footerVisible', true);
		var footer = {
			"text": "합 계",
			"styles": { "fontBold": true }
		};
		grid2._gvo.setColumnProperty("VENDOR_NM", "footer", footer);
		footer = {
			"expression": "sum",
			"styles": {
				"numberFormat": "0,000.00",
				"fontBold": true
			}
		};
		grid2._gvo.setColumnProperty("PER", "footer", footer);

		doSearch2();
    }

    var tab_id = '1';
    function doSearch() {
        var store = new EVF.Store();
        if(!store.validate()) return;
        var param = {
        		 START_DATE : EVF.C('START_DATE').getValue()
        		,END_DATE : EVF.C('END_DATE').getValue()
        		,PLANT_CD : EVF.C('PLANT_CD').getValue()
        		,VENDOR_CD : EVF.C('VENDOR_CD').getValue()
        		,VENDOR_NM : EVF.C('VENDOR_NM').getValue()
        		,TAP_ID : tab_id
            };
        location.href=baseUrl+'/view.so?' + $.param(param);


      }
    // 조회
    function doSearch2() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;
      store.setGrid([grid,grid2]);
      store.load(baseUrl+'/doSearch', function() {


      });
    }

	function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0013');
	}

	function selectVendorCd(dataJsonArray) {
		EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
		EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
	}


    $(document.body).ready(function() {
    	$('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
			{
                activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                }
            }
    	);

	    $('#e-tabs').tabs('option', 'active', 0);

        if ('${param.TAP_ID}' == '2') {
            getContentTab('2');
        } else {
            getContentTab('1');
        }
	});

    function getContentTab(uu) {
		if (uu == '1') {
			window.scrollbars = true;
			$('#tab1').focus();
			var e = jQuery.Event( 'keydown', { keyCode: 13 } );
			$("#tab1").trigger(e);
		}
		if (uu == '2') {
			window.scrollbars = true;
            $('#tab2').focus();
            // 이동된 위치에서 엔터
            var e = jQuery.Event( 'keydown', { keyCode: 13 } );
            $("#tab2").trigger(e);
		}
		tab_id = uu;
	}


    function doGrp() {

    	var datas;
    	var datas2;
    	var str = '';
    	var title = '';
    	if (tab_id == '1') {
    		title = '월부자재 매입대비 각사비중';
    		datas =[
<c:forEach varStatus="status" var="columnx" items="${columnInfos}">
	'${columnx.COLUMN_NM}',
</c:forEach>      ];

    		datas2 =[
<c:forEach varStatus="status" var="columnx" items="${columnInfos}">
	'${columnx.COLUMN_ID}',
</c:forEach>      ];

	    var totalData = grid.getRowValue(grid.getRowCount()-3);
    	for(var k=0;k<datas.length;k++) {
			var ttype=datas2[k];
			str+= ",['"+ datas[k] + "'," + totalData[ttype] / totalData.TOTAL_AMT * 100 +"]\n"
    	}


    	} else {
    		title = '월부자재 매입대비 협력회사비중';
    	    var totalData = grid2.getAllRowValue();
        	for(var k=0;k<totalData.length;k++) {
    			str+= ",['"+ totalData[k].VENDOR_NM + "'," + totalData[k].PER +"]\n"
        	}
    	}



        var param = {
        		TITLE : title
        	   ,DATA : str
               ,'detailView': true
			};
		everPopup.openPopupByScreenId('gChart', 950, 550, param);

    }



    </script>

  <e:window id="DH1630" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>

		<e:label for="START_DATE" title="${form_START_DATE_N}"/>
		<e:field>
		<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
		</e:field>

        <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
        <e:field>
        <e:select id="PLANT_CD" name="PLANT_CD" useMultipleSelect="true" value="${param.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
        </e:field>
        		<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:search id="VENDOR_NM" name="VENDOR_NM" value="${param.VENDOR_NM}" width="65%" maxLength="${form_VENDOR_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>



					<e:text>&nbsp;</e:text>

					<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}" width="30%" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" style='ime-mode:inactive'/>


				</e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doGrp" name="doGrp" label="${doGrp_N}" onClick="doGrp" disabled="${doGrp_D}" visible="${doGrp_V}"/>
    </e:buttonBar>

            <div id="e-tabs" class="e-tabs">
                <ul>
                    <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${form_TEXT1_N }</a></li>
                    <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${form_TEXT2_N }</a></li>
                </ul>
                <div id="ui-tabs-1">
				    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    			</div>

                <div id="ui-tabs-2">
				    <e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}"/>
    			</div>
            </div>
  </e:window>
</e:ui>